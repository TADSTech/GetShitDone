import 'package:isar/isar.dart';

part 'task.g.dart';

class TaskRepeat {
  static const int none = 0;
  static const int daily = 1;
  static const int weekly = 2;
  static const int monthly = 3;
  static const int custom = 4;
}

@collection
class Task {
  Task({
    this.id = Isar.autoIncrement,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 1,
    this.useAlarm = false,
    this.repeatType = TaskRepeat.none,
    this.repeatIntervalDays = 1,
    this.isCompleted = false,
    this.completedAt,
    this.categoryId,
  });

  Id id;
  String title;
  String? description;
  DateTime? dueDate;
  int priority;
  bool useAlarm;
  int repeatType;
  int repeatIntervalDays;
  bool isCompleted;
  DateTime? completedAt;
  int? categoryId;
}
