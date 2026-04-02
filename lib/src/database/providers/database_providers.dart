import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/database/app_database.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/database/models/user_stats.dart';
import 'package:get_shit_done/src/database/repositories/stats_repository.dart';
import 'package:get_shit_done/src/database/repositories/task_repository.dart';
import 'package:isar/isar.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final isar = await openIsarInstance();
  ref.onDispose(() async {
    if (isar.isOpen) {
      await isar.close();
    }
  });
  return isar;
});

final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return TaskRepository(isar);
});

final statsRepositoryProvider = FutureProvider<StatsRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return StatsRepository(isar);
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) async* {
  final repository = await ref.watch(taskRepositoryProvider.future);
  yield* repository.watchAllTasks();
});

final userStatsStreamProvider = StreamProvider<UserStats>((ref) async* {
  final repository = await ref.watch(statsRepositoryProvider.future);
  yield* repository.watchStats();
});
