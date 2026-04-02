import 'package:get_shit_done/src/database/models/category.dart';
import 'package:get_shit_done/src/database/models/task.dart';
import 'package:get_shit_done/src/database/models/user_stats.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

Future<Isar> openIsarInstance() async {
  if (Isar.instanceNames.isNotEmpty) {
    return Future.value(Isar.getInstance());
  }

  final directory = await getApplicationDocumentsDirectory();

  return Isar.open(
    [
      TaskSchema,
      CategorySchema,
      UserStatsSchema,
    ],
    directory: directory.path,
  );
}
