import 'package:equatable/equatable.dart';
import 'quadrant_type.dart';
import 'sub_task_entity.dart';
import 'task_label.dart';

// ============================================================
// TASK ENTITY – Domain Layer
// ============================================================
//
// [Clean Architecture] Tại sao cần tách Entity và Model?
//
// ┌─────────────────────────────────────────────────────────┐
// │  ENTITY (domain layer)   │  MODEL (data layer)          │
// ├─────────────────────────────────────────────────────────┤
// │  - Pure Dart, không có   │  - Có @HiveType, @HiveField  │
// │    annotation nào        │    (phụ thuộc package Hive)  │
// │  - Là "ngôn ngữ chung"   │  - Có fromJson / toJson      │
// │    của toàn hệ thống     │    (phụ thuộc định dạng DB)  │
// │  - Dùng trong UseCase,   │  - Chỉ dùng ở tầng Data      │
// │    BLoC, Presentation    │    (datasource, repository)  │
// │  - Dễ test: không cần   │  - Khi đổi DB (Hive→SQLite)  │
// │    mock bất kỳ package   │    chỉ sửa Model, Entity     │
// │    nào                   │    không thay đổi gì cả!     │
// └─────────────────────────────────────────────────────────┘
//
// Kết luận: Entity = "what it IS" (nghiệp vụ thuần túy)
//           Model  = "how it's STORED" (cách lưu trữ)

/// Entity thuần túy đại diện cho một Task trong domain layer.
/// Không phụ thuộc vào bất kỳ framework, package, hay DB nào.
class TaskEntity extends Equatable {
  /// ID duy nhất (UUID hoặc Hive key)
  final String id;

  /// Tên task
  final String title;

  /// Mô tả chi tiết (có thể rỗng)
  final String description;

  /// Góc phần tư Eisenhower (doIt / scheduleIt / delegateIt / eliminateIt)
  final QuadrantType quadrant;

  /// Thời điểm tạo task
  final DateTime createdAt;

  /// Task đã hoàn thành chưa
  final bool isCompleted;

  /// Ngày đến hạn (tùy chọn)
  final DateTime? dueDate;

  /// Số pomodoro ước tính để hoàn thành
  final int estimatedPomodoros;

  /// Số pomodoro đã làm xong
  final int completedPomodoros;

  /// Danh sách task con
  final List<SubTaskEntity> subTasks;

  /// Danh sách nhãn/tags
  final List<String> tags;

  /// Chuỗi quy tắc lặp lại (ví dụ: 'DAILY', 'WEEKLY', vv)
  final String? recurrenceRule;

  /// Nhãn phân loại chính (work / study / personal / health / finance / other)
  /// Có thể null nếu người dùng không chọn.
  final TaskLabel? label;

  /// Ghi chú chi tiết cho task (tùy chọn)
  final String? notes;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.quadrant,
    required this.createdAt,
    this.isCompleted = false,
    this.dueDate,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.subTasks = const [],
    this.tags = const [],
    this.recurrenceRule,
    this.label,
    this.notes,
  });

  /// Tạo bản sao với các trường được cập nhật (immutable pattern)
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    QuadrantType? quadrant,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? dueDate,
    int? estimatedPomodoros,
    int? completedPomodoros,
    List<SubTaskEntity>? subTasks,
    List<String>? tags,
    String? recurrenceRule,
    TaskLabel? label,
    bool clearLabel = false,
    String? notes,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      quadrant: quadrant ?? this.quadrant,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      subTasks: subTasks ?? this.subTasks,
      tags: tags ?? this.tags,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      // clearLabel = true cho phép xóa label (gán null)
      label: clearLabel ? null : (label ?? this.label),
      notes: notes ?? this.notes,
    );
  }

  /// Toggle trạng thái hoàn thành – helper method thường dùng
  TaskEntity toggleCompletion() => copyWith(isCompleted: !isCompleted);

  /// Kiểm tra task có quá hạn không
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Tiến độ pomodoro (0.0 → 1.0)
  double get pomodoroProgress {
    if (estimatedPomodoros == 0) return 0;
    return (completedPomodoros / estimatedPomodoros).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id, title, description, quadrant,
        createdAt, isCompleted, dueDate,
        estimatedPomodoros, completedPomodoros,
        subTasks, tags, recurrenceRule, label, notes,
      ];

  @override
  String toString() =>
      'TaskEntity(id: $id, title: "$title", quadrant: ${quadrant.name}, '
      'isCompleted: $isCompleted)';
}
