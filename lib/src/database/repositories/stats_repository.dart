import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/database/models/user_stats.dart';
import 'package:isar/isar.dart';

class StatsRepository {
  StatsRepository(this._isar);

  final Isar _isar;

  Stream<UserStats> watchStats() async* {
    final initial = await _getOrCreateStats();
    yield initial;

    yield* _isar.userStats.watchObject(0, fireImmediately: true).map(
      (stats) => stats ?? initial,
    );
  }

  Future<UserStats> getStats() {
    return _getOrCreateStats();
  }

  Future<void> saveStats(UserStats stats) async {
    await _isar.writeTxn(() async {
      await _isar.userStats.put(stats);
    });
  }

  Future<void> incrementCompletedCount() async {
    final stats = await _getOrCreateStats();
    stats.totalCompleted += 1;
    await saveStats(stats);
  }

  Future<void> recomputeFromTasks(List<Task> tasks) async {
    final stats = await _getOrCreateStats();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    final completedDays = <DateTime>{
      for (final task in completedTasks)
        if (task.completedAt != null)
          DateTime(
            task.completedAt!.year,
            task.completedAt!.month,
            task.completedAt!.day,
          ),
    }.toList()
      ..sort();

    stats.totalCompleted = completedTasks.length;
    stats.currentStreak = _calculateCurrentStreak(completedDays);
    stats.highestStreak = _calculateHighestStreak(completedDays);

    await saveStats(stats);
  }

  int _calculateCurrentStreak(List<DateTime> completedDays) {
    if (completedDays.isEmpty) {
      return 0;
    }

    final days = completedDays.toSet();
    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);

    if (!days.contains(cursor)) {
      final yesterday = cursor.subtract(const Duration(days: 1));
      if (!days.contains(yesterday)) {
        return 0;
      }
      cursor = yesterday;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _calculateHighestStreak(List<DateTime> completedDays) {
    if (completedDays.isEmpty) {
      return 0;
    }

    var highest = 1;
    var current = 1;

    for (var i = 1; i < completedDays.length; i++) {
      final previous = completedDays[i - 1];
      final currentDay = completedDays[i];
      final difference = currentDay.difference(previous).inDays;

      if (difference == 1) {
        current += 1;
      } else {
        current = 1;
      }

      if (current > highest) {
        highest = current;
      }
    }

    return highest;
  }

  Future<UserStats> _getOrCreateStats() async {
    final existing = await _isar.userStats.get(0);
    if (existing != null) {
      return existing;
    }

    final stats = UserStats();
    await saveStats(stats);
    return stats;
  }
}
