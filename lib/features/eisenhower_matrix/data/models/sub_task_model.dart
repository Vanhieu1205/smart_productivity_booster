import 'package:hive/hive.dart';
import '../../domain/entities/sub_task_entity.dart';

part 'sub_task_model.g.dart';

@HiveType(typeId: 4)
class SubTaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  SubTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SubTaskModel.fromEntity(SubTaskEntity entity) {
    return SubTaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
    );
  }

  SubTaskEntity toEntity() {
    return SubTaskEntity(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
