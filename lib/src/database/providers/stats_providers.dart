import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_shit_done/src/database/models/user_stats.dart';
import 'package:get_shit_done/src/database/repositories/stats_repository.dart';
import 'package:get_shit_done/src/database/database.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final db = IsarDB.instance;
  return StatsRepository(db);
});

final statsStreamProvider = StreamProvider<UserStats>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.watchStats();
});

final currentStreakProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.watchStats().map((stat) => stat.currentStreak);
});

final highestStreakProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.watchStats().map((stat) => stat.highestStreak);
});

final totalCompletedProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.watchStats().map((stat) => stat.totalCompleted);
});


