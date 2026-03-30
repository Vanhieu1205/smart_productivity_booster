import 'package:equatable/equatable.dart';
import 'timer_type.dart';

// ============================================================
// POMODORO SESSION ENTITY – Domain Layer
// ============================================================
//
// [Clean Architecture] Entity là "trái tim" của nghiệp vụ.
// PomodoroSessionEntity KHÔNG import bất kỳ package Hive, Flutter widget hay
// package bên thứ 3 nào → thuần Dart → dễ test hoàn toàn độc lập.
//
// Ý nghĩa: Một phiên Pomodoro đại diện cho một khoảng thời gian làm việc
// hoặc nghỉ ngơi được ghi lại.

/// Entity đại diện cho một phiên Pomodoro đã xảy ra hoặc đang diễn ra.
class PomodoroSessionEntity extends Equatable {
  /// ID duy nhất (UUID v4) – dùng để CRUD trong Hive box
  final String id;

  /// Thời điểm bắt đầu phiên đếm giờ
  final DateTime startTime;

  /// Thời điểm kết thúc (null nếu phiên chưa kết thúc / đang chạy)
  final DateTime? endTime;

  /// Loại phiên: làm việc / nghỉ ngắn / nghỉ dài
  final TimerType type;

  /// Phiên đã hoàn thành trọn vẹn hay bị ngắt giữa chừng (nhấn reset/skip)
  final bool isCompleted;

  /// ID của task đang được làm trong phiên này (tùy chọn, có thể null)
  /// Dùng để thống kê số pomodoro đã dành cho từng task.
  final String? taskId;

  const PomodoroSessionEntity({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.type,
    this.isCompleted = false,
    this.taskId,
  });

  /// Tổng thời lượng thực tế của phiên (endTime - startTime)
  /// Trả về null nếu phiên chưa kết thúc.
  Duration? get actualDuration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Kiểm tra đây có phải là phiên làm việc không (type == work)
  bool get isWorkSession => type == TimerType.work;

  /// Tạo bản sao với các trường được cập nhật (immutable pattern)
  PomodoroSessionEntity copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    TimerType? type,
    bool? isCompleted,
    String? taskId,
  }) {
    return PomodoroSessionEntity(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        type,
        isCompleted,
        taskId,
      ];

  @override
  String toString() =>
      'PomodoroSessionEntity(id: $id, type: ${type.name}, '
      'isCompleted: $isCompleted, taskId: $taskId)';
}
