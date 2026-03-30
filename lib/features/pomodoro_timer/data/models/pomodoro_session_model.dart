import 'package:hive/hive.dart';
import '../../domain/entities/pomodoro_session_entity.dart';
import '../../domain/entities/timer_type.dart';

// ============================================================
// POMODORO SESSION MODEL – Data Layer
// ============================================================
//
// [Clean Architecture] Model biết cách serialization và lưu trữ,
// Entity chỉ biết nghiệp vụ thuần khiết.
//
// PomodoroSessionModel kế thừa HiveObject để có thể:
//   - Lưu/xóa trực tiếp (model.save(), model.delete())
//   - Theo dõi vị trí trong Box
//
// ⚠️ Sau khi sửa file này, cần chạy lại:
//   flutter pub run build_runner build --delete-conflicting-outputs
// để regenerate pomodoro_session_model.g.dart

part 'pomodoro_session_model.g.dart'; // File sẽ được hive_generator tạo ra

/// typeId: 1 (TaskModel đang dùng 0, nên session dùng 1)
/// typeId phải unique trong toàn bộ app Hive
@HiveType(typeId: 1)
class PomodoroSessionModel extends HiveObject {
  // ── Fields được lưu vào Hive ─────────────────────────────

  /// ID duy nhất (UUID v4) – key chính trong Hive box
  @HiveField(0)
  final String id;

  /// Timestamp bắt đầu phiên (lưu dưới dạng int millisecondsSinceEpoch)
  @HiveField(1)
  final DateTime startTime;

  /// Timestamp kết thúc phiên (null nếu đang chạy hoặc bị huỷ)
  @HiveField(2)
  final DateTime? endTime;

  /// Loại phiên lưu dưới dạng index của enum TimerType
  /// (0 = work, 1 = shortBreak, 2 = longBreak)
  /// Hive không hiểu enum trực tiếp nên dùng int
  @HiveField(3)
  final int typeIndex;

  /// Phiên đã chạy xong trọn thời gian hay bị ngắt sớm
  @HiveField(4)
  final bool isCompleted;

  /// ID của Task được liên kết với phiên này (để tính pomodoro per task)
  @HiveField(5)
  final String? taskId;

  PomodoroSessionModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.typeIndex,
    this.isCompleted = false,
    this.taskId,
  });

  // ── Factory constructors ──────────────────────────────────

  /// Tạo Model từ Entity (Domain Layer → Data Layer)
  /// Gọi khi cần lưu session vào Hive sau khi kết thúc phiên
  factory PomodoroSessionModel.fromEntity(PomodoroSessionEntity entity) {
    return PomodoroSessionModel(
      id: entity.id,
      startTime: entity.startTime,
      endTime: entity.endTime,
      typeIndex: entity.type.index,
      isCompleted: entity.isCompleted,
      taskId: entity.taskId,
    );
  }

  /// Tạo Model từ JSON map (hỗ trợ export/import backup)
  factory PomodoroSessionModel.fromJson(Map<String, dynamic> json) {
    return PomodoroSessionModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      typeIndex: json['typeIndex'] as int,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      taskId: json['taskId'] as String?,
    );
  }

  // ── Conversion methods ────────────────────────────────────

  /// Chuyển Model → Entity để Domain Layer sử dụng
  PomodoroSessionEntity toEntity() {
    return PomodoroSessionEntity(
      id: id,
      startTime: startTime,
      endTime: endTime,
      type: TimerType.values[typeIndex.clamp(0, TimerType.values.length - 1)],
      isCompleted: isCompleted,
      taskId: taskId,
    );
  }

  /// Serialize sang JSON map (dùng khi backup dữ liệu)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'typeIndex': typeIndex,
      'isCompleted': isCompleted,
      'taskId': taskId,
    };
  }

  /// Tạo bản sao với các trường được cập nhật (immutable pattern)
  PomodoroSessionModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? typeIndex,
    bool? isCompleted,
    String? taskId,
  }) {
    return PomodoroSessionModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      typeIndex: typeIndex ?? this.typeIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  String toString() =>
      'PomodoroSessionModel(id: $id, type: ${TimerType.values[typeIndex].name}, '
      'isCompleted: $isCompleted)';
}
