import 'package:equatable/equatable.dart';
import '../../domain/entities/timer_type.dart';

// ============================================================
// POMODORO STATES – BLoC Layer
// ============================================================
//
// State mô tả "bức ảnh chụp" hiện tại của đồng hồ Pomodoro.
// UI chỉ render dựa vào State → không cần tự lưu trữ gì.
//
// Các trường có mặt xuyên suốt States:
//   - currentType: đang ở pha nào (work / shortBreak / longBreak)
//   - remainingSeconds: giây còn lại của pha hiện tại  
//   - completedPomodoros: tổng số pha "work" đã làm xong
//   - currentStreak: số pomodoro liên tiếp trong loạt hiện tại
//     (reset về 0 sau mỗi longBreak)

abstract class PomodoroState extends Equatable {
  /// Pha đang hiển thị (work / shortBreak / longBreak)
  final TimerType currentType;

  /// Số giây còn lại của pha đang chạy
  final int remainingSeconds;

  /// Tổng số pomodoro work đã hoàn thành trong toàn phiên app
  final int completedPomodoros;

  /// Số pomodoro work liên tiếp trong chuỗi hiện tại (reset sau longBreak)
  final int currentStreak;

  const PomodoroState({
    required this.currentType,
    required this.remainingSeconds,
    required this.completedPomodoros,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [
        currentType,
        remainingSeconds,
        completedPomodoros,
        currentStreak,
      ];
}

// ──────────────────────────────────────────────────────────────────
// Trạng thái khởi tạo (chưa bao giờ bắt đầu hoặc đã reset hoàn toàn)
// ──────────────────────────────────────────────────────────────────
class PomodoroInitial extends PomodoroState {
  const PomodoroInitial()
      : super(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60, // 25 phút mặc định
          completedPomodoros: 0,
          currentStreak: 0,
        );
}

// ──────────────────────────────────────────────────────────────────
// Đồng hồ đang chạy
// ──────────────────────────────────────────────────────────────────
class PomodoroRunning extends PomodoroState {
  /// ID task được liên kết với phiên này (nếu có)
  final String? linkedTaskId;

  const PomodoroRunning({
    required super.currentType,
    required super.remainingSeconds,
    required super.completedPomodoros,
    required super.currentStreak,
    this.linkedTaskId,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        linkedTaskId,
      ];
}

// ──────────────────────────────────────────────────────────────────
// Đồng hồ đang tạm dừng (người dùng nhấn Pause)
// ──────────────────────────────────────────────────────────────────
class PomodoroPaused extends PomodoroState {
  /// ID task được liên kết (giữ nguyên sau khi pause)
  final String? linkedTaskId;

  const PomodoroPaused({
    required super.currentType,
    required super.remainingSeconds,
    required super.completedPomodoros,
    required super.currentStreak,
    this.linkedTaskId,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        linkedTaskId,
      ];
}

// ──────────────────────────────────────────────────────────────────
// Một pha vừa kết thúc (hết giờ hoặc bỏ qua)
// ──────────────────────────────────────────────────────────────────
class PomodoroCompleted extends PomodoroState {
  /// Pha vừa hoàn thành (để UI hiển thị thông báo phù hợp)
  final TimerType completedType;

  /// Pha tiếp theo sẽ bắt đầu (gợi ý cho người dùng)
  final TimerType nextType;

  const PomodoroCompleted({
    required this.completedType,
    required this.nextType,
    required super.completedPomodoros,
    required super.currentStreak,
  }) : super(
          currentType: nextType,
          remainingSeconds: 0,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        completedType,
        nextType,
      ];
}
