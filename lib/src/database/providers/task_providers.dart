import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:get_shit_done/src/database/database.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/database/providers/stats_providers.dart';
import 'package:get_shit_done/src/database/repositories/task_repository.dart';
import 'package:get_shit_done/src/features/notifications/notification_providers.dart';

final taskDatabaseProvider = FutureProvider<Isar>((ref) async {
  await IsarDB.initialize();
  return IsarDB.instance;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = IsarDB.instance;
  return TaskRepository(db);
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});

final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks().map((tasks) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isAfter(startOfDay) &&
              task.dueDate!.isBefore(endOfDay),
        )
        .toList();
  });
});

final completedTasksCountProvider = StreamProvider<int>((ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchAllTasks().map(
    (taskList) => taskList.where((t) => t.isCompleted).length,
  );
});

final taskByIdProvider = FutureProvider.family<Task?, int>((ref, taskId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(taskId);
});

final taskActionsProvider = Provider<TaskActionsController>((ref) {
  return TaskActionsController(ref);
});

class TaskActionsController {
  TaskActionsController(this._ref);

  final Ref _ref;

  TaskRepository get _tasks => _ref.read(taskRepositoryProvider);

  DateTime _addMonths(DateTime date, int months) {
    final yearDelta = (date.month - 1 + months) ~/ 12;
    final newYear = date.year + yearDelta;
    final newMonth = ((date.month - 1 + months) % 12) + 1;

    final maxDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = date.day > maxDay ? maxDay : date.day;
    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  DateTime? _nextDueDate(Task task) {
    if (task.repeatType == TaskRepeat.none) {
      return null;
    }

    final baseDue = task.dueDate ?? DateTime.now();
    switch (task.repeatType) {
      case TaskRepeat.daily:
        return baseDue.add(const Duration(days: 1));
      case TaskRepeat.weekly:
        return baseDue.add(const Duration(days: 7));
      case TaskRepeat.monthly:
        return _addMonths(baseDue, 1);
      case TaskRepeat.custom:
        final interval = task.repeatIntervalDays > 0
            ? task.repeatIntervalDays
            : 1;
        return baseDue.add(Duration(days: interval));
      default:
        return null;
    }
  }

  Future<void> _refreshStats() async {
    final statsRepository = _ref.read(statsRepositoryProvider);
    final tasks = await _tasks.getAllTasks();
    await statsRepository.recomputeFromTasks(tasks);
  }

  Future<void> upsertTask(Task task) async {
    await _tasks.saveTask(task);
    final notifications = _ref.read(notificationServiceProvider);
    await notifications.scheduleForTask(task);
    await _refreshStats();
  }

  Future<void> deleteTask(Id taskId) async {
    final notifications = _ref.read(notificationServiceProvider);
    await notifications.cancelForTask(taskId);
    await _tasks.deleteTask(taskId);
    await _refreshStats();
  }

  Future<void> setTaskCompleted({
    required Id taskId,
    required bool isCompleted,
  }) async {
    final existing = await _tasks.getTaskById(taskId);
    if (existing == null || existing.isCompleted == isCompleted) {
      return;
    }

    await _tasks.setTaskCompleted(taskId: taskId, isCompleted: isCompleted);

    final notifications = _ref.read(notificationServiceProvider);
    if (isCompleted) {
      await notifications.cancelForTask(taskId);

      if (existing.repeatType != TaskRepeat.none) {
        final nextDue = _nextDueDate(existing);
        final nextTask = Task(
          title: existing.title,
          description: existing.description,
          dueDate: nextDue,
          priority: existing.priority,
          useAlarm: existing.useAlarm,
          repeatType: existing.repeatType,
          repeatIntervalDays: existing.repeatIntervalDays,
          isCompleted: false,
          categoryId: existing.categoryId,
        );
        await _tasks.saveTask(nextTask);
        await notifications.scheduleForTask(nextTask);
      }
    } else {
      final refreshed = await _tasks.getTaskById(taskId);
      if (refreshed != null) {
        await notifications.scheduleForTask(refreshed);
      }
    }

    if (isCompleted) {
      await _refreshStats();
      return;
    }

    await _refreshStats();
  }
}
