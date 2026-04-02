import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/database/providers/stats_providers.dart';
import 'package:get_shit_done/src/database/providers/task_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats & Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: statsAsync.when(
          data: (stats) => tasksAsync.when(
            data: (tasks) {
              final heatMapData = _buildHeatMap(tasks);
              final weekly = _buildLastWeekCounts(tasks);
              final totalTasks = tasks.length;
              final completedTasks = tasks.where((task) => task.isCompleted).length;
              final completionRate = totalTasks == 0
                  ? 0
                  : ((completedTasks / totalTasks) * 100).round();

              return ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MetricTile(
                            label: 'Current Streak',
                            value: '${stats.currentStreak}d',
                            icon: Icons.local_fire_department,
                          ),
                          _MetricTile(
                            label: 'Best Streak',
                            value: '${stats.highestStreak}d',
                            icon: Icons.emoji_events,
                          ),
                          _MetricTile(
                            label: 'Done',
                            value: '${stats.totalCompleted}',
                            icon: Icons.task_alt,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Completion Rate', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(height: 8),
                          Text('$completionRate% ($completedTasks/$totalTasks tasks)'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Activity Heatmap (Last 6 Weeks)', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _HeatMap(data: heatMapData),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Last 7 Days Completed', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _WeeklyBars(values: weekly),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Map<DateTime, int> _buildHeatMap(List<Task> tasks) {
    final counts = <DateTime, int>{};
    for (final task in tasks) {
      if (!task.isCompleted || task.completedAt == null) {
        continue;
      }
      final date = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      counts.update(date, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  List<int> _buildLastWeekCounts(List<Task> tasks) {
    final counts = List<int>.filled(7, 0);
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));

    for (final task in tasks) {
      if (!task.isCompleted || task.completedAt == null) {
        continue;
      }
      final day = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      final diff = day.difference(start).inDays;
      if (diff >= 0 && diff < 7) {
        counts[diff] += 1;
      }
    }

    return counts;
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HeatMap extends StatelessWidget {
  const _HeatMap({required this.data});

  final Map<DateTime, int> data;

  Color _tileColor(BuildContext context, int count) {
    final base = Theme.of(context).colorScheme.primary;
    if (count <= 0) {
      return base.withValues(alpha: 0.08);
    }
    if (count == 1) {
      return base.withValues(alpha: 0.28);
    }
    if (count == 2) {
      return base.withValues(alpha: 0.48);
    }
    if (count == 3) {
      return base.withValues(alpha: 0.68);
    }
    return base.withValues(alpha: 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 41));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(42, (index) {
        final day = start.add(Duration(days: index));
        final key = DateTime(day.year, day.month, day.day);
        final count = data[key] ?? 0;

        return Tooltip(
          message: '${day.month}/${day.day}: $count completed',
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _tileColor(context, count),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(1, (max, value) => value > max ? value : max);
    final labels = const ['-6d', '-5d', '-4d', '-3d', '-2d', '-1d', 'Today'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final value = values[index];
        final ratio = value / maxValue;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$value', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  height: 16 + (ratio * 100),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(labels[index], style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        );
      }),
    );
  }
}
