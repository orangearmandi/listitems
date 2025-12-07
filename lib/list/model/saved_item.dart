import 'package:hive/hive.dart';
import 'item.dart';

part 'saved_item.g.dart';

@HiveType(typeId: 0)
class SavedItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String? image;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  DateTime created;

  @HiveField(6)
  DateTime updated;

  SavedItem({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.imageUrl,
    required this.created,
    required this.updated,
  });

  factory SavedItem.fromItem(Item item, String? imageUrl) {
    return SavedItem(
      id: item.id,
      name: item.name,
      description: item.description,
      image: item.image,
      imageUrl: imageUrl,
      created: item.createdDate,
      updated: item.updatedDate,
    );
  }

  factory SavedItem.fromJson(Map<String, dynamic> json, String customName) {
    return SavedItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      imageUrl: json['imageUrl'] as String?,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
    );
  }
}
