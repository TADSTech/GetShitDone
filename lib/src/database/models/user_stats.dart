import 'package:isar/isar.dart';

part 'user_stats.g.dart';

@collection
class UserStats {
  UserStats({
    this.id = 0,
    this.currentStreak = 0,
    this.highestStreak = 0,
    this.totalCompleted = 0,
  });

  Id id;
  int currentStreak;
  int highestStreak;
  int totalCompleted;
}
