import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/routing/app_router.dart';
import 'package:get_shit_done/src/database/providers/task_providers.dart';
import 'package:get_shit_done/src/database/providers/stats_providers.dart';
import 'package:get_shit_done/src/theme/theme_providers.dart';
import 'package:confetti/confetti.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _priorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      default:
        return 'Low';
    }
  }

  String _repeatLabel(Task task) {
    switch (task.repeatType) {
      case TaskRepeat.daily:
        return 'Daily';
      case TaskRepeat.weekly:
        return 'Weekly';
      case TaskRepeat.monthly:
        return 'Monthly';
      case TaskRepeat.custom:
        return 'Every ${task.repeatIntervalDays}d';
      default:
        return '';
    }
  }

  String _dueStatusLabel(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(now);

    if (diff.inMinutes <= -1) {
      return 'Overdue';
    }
    if (diff.inMinutes <= 30) {
      return 'Due now';
    }
    if (diff.inHours < 1) {
      return 'Due in ${diff.inMinutes}m';
    }
    if (diff.inHours < 24) {
      return 'Due in ${diff.inHours}h';
    }
    return 'Due in ${diff.inDays}d';
  }

  Color _dueStatusColor(DateTime dueDate) {
    final diff = dueDate.difference(DateTime.now());
    if (diff.inMinutes <= 0) {
      return Colors.red.withValues(alpha: 0.2);
    }
    if (diff.inHours < 6) {
      return Colors.orange.withValues(alpha: 0.22);
    }
    return Colors.blue.withValues(alpha: 0.18);
  }

  Future<bool> _handleDismiss(
    BuildContext context,
    WidgetRef ref,
    Task task,
    DismissDirection direction,
  ) async {
    final actions = ref.read(taskActionsProvider);
    final reducedMotion = ref.read(themeSettingsProvider).reducedMotion;

    if (direction == DismissDirection.endToStart) {
      await actions.deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deleted "${task.title}"')));
      }
      return true;
    }

    final nextValue = !task.isCompleted;
    await actions.setTaskCompleted(taskId: task.id, isCompleted: nextValue);
    if (nextValue && !reducedMotion) {
      _confettiController.play();
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextValue
                ? 'Marked "${task.title}" complete'
                : 'Marked "${task.title}" incomplete',
          ),
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final allTasksAsync = ref.watch(tasksStreamProvider);
    final statsAsync = ref.watch(statsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Shit Done'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              context.pushNamed(AppRoutes.statsName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.pushNamed(AppRoutes.settingsName);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: allTasksAsync.when(
              data: (allTasks) => todayTasksAsync.when(
                data: (todayTasks) => statsAsync.when(
                  data: (stats) {
                    final completedToday = todayTasks
                        .where((task) => task.isCompleted)
                        .length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Overview',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          todayTasks.isEmpty
                              ? 'No tasks due today. Add one and keep momentum.'
                              : '$completedToday of ${todayTasks.length} due tasks completed',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.local_fire_department),
                            title: const Text('Streak'),
                            subtitle: Text(
                              '${stats.currentStreak} days current • ${stats.highestStreak} days best',
                            ),
                            trailing: Text(
                              'Done: ${stats.totalCompleted}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tasks',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: allTasks.isEmpty
                              ? Center(
                                  child: Text(
                                    'Create your first task to begin',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                )
                              : AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: ListView.separated(
                                    key: ValueKey(
                                      allTasks.map((e) => e.id).join('-'),
                                    ),
                                    itemCount: allTasks.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final task = allTasks[index];
                                      final dueDate = task.dueDate;

                                      return TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration: Duration(
                                          milliseconds: 220 + (index * 35),
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(
                                                0,
                                                (1 - value) * 10,
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Dismissible(
                                          key: ValueKey(task.id),
                                          background: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Icon(
                                              task.isCompleted
                                                  ? Icons.undo
                                                  : Icons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                          secondaryBackground: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                          confirmDismiss: (direction) =>
                                              _handleDismiss(
                                                context,
                                                ref,
                                                task,
                                                direction,
                                              ),
                                          child: Card(
                                            child: ListTile(
                                              onTap: () {
                                                context.pushNamed(
                                                  AppRoutes.addTaskName,
                                                  extra: task,
                                                );
                                              },
                                              leading: Icon(
                                                task.isCompleted
                                                    ? Icons.check_circle
                                                    : Icons
                                                          .radio_button_unchecked,
                                                color: task.isCompleted
                                                    ? Colors.green
                                                    : null,
                                              ),
                                              title: Text(
                                                task.title,
                                                style: task.isCompleted
                                                    ? const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      )
                                                    : null,
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if ((task.description ?? '')
                                                      .isNotEmpty)
                                                    Text(task.description!),
                                                  const SizedBox(height: 2),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    children: [
                                                      Text(
                                                        dueDate == null
                                                            ? 'No deadline'
                                                            : 'Due ${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')} ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}',
                                                      ),
                                                      Chip(
                                                        label: Text(
                                                          _priorityLabel(
                                                            task.priority,
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            switch (task
                                                                .priority) {
                                                              3 =>
                                                                Colors.red
                                                                    .withValues(
                                                                      alpha:
                                                                          0.18,
                                                                    ),
                                                              2 =>
                                                                Colors.orange
                                                                    .withValues(
                                                                      alpha:
                                                                          0.2,
                                                                    ),
                                                              _ =>
                                                                Colors.green
                                                                    .withValues(
                                                                      alpha:
                                                                          0.18,
                                                                    ),
                                                            },
                                                        side: BorderSide.none,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                      ),
                                                      if (task.repeatType !=
                                                          TaskRepeat.none)
                                                        Chip(
                                                          label: Text(
                                                            _repeatLabel(task),
                                                          ),
                                                          avatar: const Icon(
                                                            Icons.repeat,
                                                            size: 16,
                                                          ),
                                                          side: BorderSide.none,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                        ),
                                                      if (task.useAlarm)
                                                        Chip(
                                                          label: const Text(
                                                            'Alarm',
                                                          ),
                                                          avatar: const Icon(
                                                            Icons.alarm,
                                                            size: 16,
                                                          ),
                                                          side: BorderSide.none,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                        ),
                                                      if (!task.isCompleted &&
                                                          dueDate != null)
                                                        Chip(
                                                          label: Text(
                                                            _dueStatusLabel(
                                                              dueDate,
                                                            ),
                                                          ),
                                                          avatar: Icon(
                                                            dueDate.isBefore(
                                                                  DateTime.now(),
                                                                )
                                                                ? Icons
                                                                      .warning_amber_rounded
                                                                : Icons.timer,
                                                            size: 16,
                                                          ),
                                                          backgroundColor:
                                                              _dueStatusColor(
                                                                dueDate,
                                                              ),
                                                          side: BorderSide.none,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              trailing: const Icon(
                                                Icons.chevron_right,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.04,
                numberOfParticles: 16,
                gravity: 0.25,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(AppRoutes.addTaskName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
