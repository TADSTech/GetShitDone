import 'package:get_shit_done/src/database/models/task.dart';
import 'package:isar/isar.dart';

class TaskRepository {
  TaskRepository(this._isar);

  final Isar _isar;

  Stream<List<Task>> watchAllTasks() {
    return _isar.tasks.where().watch(fireImmediately: true);
  }

  Future<List<Task>> getAllTasks() {
    return _isar.tasks.where().findAll();
  }

  Future<Task?> getTaskById(Id taskId) {
    return _isar.tasks.get(taskId);
  }

  Future<void> saveTask(Task task) async {
    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
  }

  Future<void> deleteTask(Id taskId) async {
    await _isar.writeTxn(() async {
      await _isar.tasks.delete(taskId);
    });
  }

  Future<void> setTaskCompleted({
    required Id taskId,
    required bool isCompleted,
  }) async {
    final task = await _isar.tasks.get(taskId);
    if (task == null) {
      return;
    }

    task.isCompleted = isCompleted;
    task.completedAt = isCompleted ? DateTime.now() : null;
    await saveTask(task);
  }
}
