import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';
import '../../domain/entities/task_label.dart';
import 'sub_task_model.dart';

// ============================================================
// TASK MODEL – Data Layer
// ============================================================
//
// [Clean Architecture] Model vs Entity – Vai trò của Model:
//
// Model là "bản dịch" giữa DOMAIN và DATA SOURCE.
// Nó biết cách:
//   1. Lưu trữ dữ liệu vào Hive (nhờ @HiveType / @HiveField)
//   2. Serialize/Deserialize từ JSON (fromJson / toJson)
//   3. Chuyển đổi sang Entity để Domain Layer sử dụng (toEntity)
//   4. Nhận Entity từ Domain để lưu trữ (fromEntity)
//
// Rule: Domain layer KHÔNG BAO GIỜ biết đến Model.
//       Chỉ có Data layer (datasource, repository impl) mới dùng Model.
//
// Lưu ý: File này cần chạy build_runner để generate task_model.g.dart:
//   flutter pub run build_runner build --delete-conflicting-outputs

part 'task_model.g.dart'; // File generated bởi hive_generator

/// TypeId phải unique trong toàn app Hive.
/// task: 0 | (các model khác sẽ dùng 1, 2, 3...)
@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  // ── Fields được lưu vào Hive (mỗi field cần @HiveField) ──────────────────

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  /// Lưu QuadrantType dưới dạng index (int) vì Hive không biết enum trực tiếp
  @HiveField(3)
  final int quadrantIndex;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final int? labelIndex;

  @HiveField(7)
  final DateTime? dueDate;

  @HiveField(8)
  final int estimatedPomodoros;

  @HiveField(9)
  final int completedPomodoros;

  @HiveField(10)
  final List<SubTaskModel> subTasks;

  @HiveField(11)
  final List<String> tags;

  @HiveField(12)
  final String? recurrenceRule;

  @HiveField(13)
  final String? notes;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.quadrantIndex,
    required this.createdAt,
    this.isCompleted = false,
    this.labelIndex,
    this.dueDate,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.subTasks = const [],
    this.tags = const [],
    this.recurrenceRule,
    this.notes,
  });

  // ── Factory constructors ──────────────────────────────────────────────────

  /// Tạo Model từ Entity (Domain → Data)
  /// Dùng khi cần lưu task vào Hive hoặc serialize sang JSON
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      quadrantIndex: entity.quadrant.index,
      createdAt: entity.createdAt,
      isCompleted: entity.isCompleted,
      labelIndex: entity.label?.index,
      dueDate: entity.dueDate,
      estimatedPomodoros: entity.estimatedPomodoros,
      completedPomodoros: entity.completedPomodoros,
      subTasks: entity.subTasks.map((s) => SubTaskModel.fromEntity(s)).toList(),
      tags: entity.tags,
      recurrenceRule: entity.recurrenceRule,
      notes: entity.notes,
    );
  }

  /// Tạo Model từ JSON map (dùng khi đọc từ API hoặc file)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      quadrantIndex: json['quadrantIndex'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      labelIndex: json['labelIndex'] as int?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      estimatedPomodoros: (json['estimatedPomodoros'] as int?) ?? 1,
      completedPomodoros: (json['completedPomodoros'] as int?) ?? 0,
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recurrenceRule: json['recurrenceRule'] as String?,
      notes: json['notes'] as String?,
    );
  }

  // ── Conversion methods ────────────────────────────────────────────────────

  /// Chuyển Model → Entity để Domain Layer sử dụng
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      quadrant: QuadrantType.values[quadrantIndex.clamp(0, 3)],
      createdAt: createdAt,
      isCompleted: isCompleted,
      label: labelIndex != null
          ? TaskLabel.values[labelIndex!.clamp(0, TaskLabel.values.length - 1)]
          : null,
      dueDate: dueDate,
      estimatedPomodoros: estimatedPomodoros,
      completedPomodoros: completedPomodoros,
      subTasks: subTasks.map((s) => s.toEntity()).toList(),
      tags: tags,
      recurrenceRule: recurrenceRule,
      notes: notes,
    );
  }

  /// Serialize sang JSON map (dùng khi export backup hoặc gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quadrantIndex': quadrantIndex,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'labelIndex': labelIndex,
      'dueDate': dueDate?.toIso8601String(),
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'subTasks': subTasks.map((s) => s.toJson()).toList(),
      'tags': tags,
      'recurrenceRule': recurrenceRule,
      'notes': notes,
    };
  }

  /// Tạo bản sao với các trường được cập nhật
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    int? quadrantIndex,
    DateTime? createdAt,
    bool? isCompleted,
    int? labelIndex,
    DateTime? dueDate,
    int? estimatedPomodoros,
    int? completedPomodoros,
    List<SubTaskModel>? subTasks,
    List<String>? tags,
    String? recurrenceRule,
    String? notes,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      quadrantIndex: quadrantIndex ?? this.quadrantIndex,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      labelIndex: labelIndex ?? this.labelIndex,
      dueDate: dueDate ?? this.dueDate,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      subTasks: subTasks ?? this.subTasks,
      tags: tags ?? this.tags,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'TaskModel(id: $id, title: "$title", quadrantIndex: $quadrantIndex)';
}
