import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Category({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.color,
    required this.icon,
  });

  Id id;
  String name;
  int color;
  int icon;
}
