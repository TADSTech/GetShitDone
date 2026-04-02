import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/database/models/category.dart';
import 'package:get_shit_done/src/database/models/user_stats.dart';

class IsarDB {
  static Isar? _instance;

  static Isar get instance {
    if (_instance == null) {
      throw Exception('Isar not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_instance != null) {
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [TaskSchema, CategorySchema, UserStatsSchema],
      directory: dir.path,
    );
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
