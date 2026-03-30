import 'package:equatable/equatable.dart';

// ============================================================
// POMODORO EVENTS – BLoC Layer
// ============================================================
//
// Event là "tín hiệu" từ UI gửi vào BLoC.
// Mỗi loại tương tác của người dùng với đồng hồ = 1 Event riêng biệt.
// TimerTick là Event nội bộ – không do người dùng trigger mà do BLoC tự gửi.

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();
  @override
  List<Object?> get props => [];
}

/// Người dùng nhấn nút "Bắt đầu" phiên mới
class StartTimer extends PomodoroEvent {
  const StartTimer();
}

/// Người dùng nhấn nút "Tạm dừng" – timer sẽ dừng lại
class PauseTimer extends PomodoroEvent {
  const PauseTimer();
}

/// Người dùng nhấn "Tiếp tục" sau khi đã dừng
class ResumeTimer extends PomodoroEvent {
  const ResumeTimer();
}

/// Người dùng nhấn "Đặt lại" – hủy hoàn toàn, về trạng thái ban đầu
class ResetTimer extends PomodoroEvent {
  const ResetTimer();
}

/// Người dùng nhấn "Bỏ qua" – bỏ qua pha hiện tại, chuyển sang pha tiếp theo
class SkipPhase extends PomodoroEvent {
  const SkipPhase();
}

/// [Nội bộ] Event được BLoC tự phát mỗi giây từ Timer.periodic
/// UI không gọi Event này trực tiếp.
class TimerTick extends PomodoroEvent {
  /// Số giây còn lại SAU khi tick (đã trừ 1 giây)
  final int remainingSeconds;

  const TimerTick({required this.remainingSeconds});

  @override
  List<Object?> get props => [remainingSeconds];
}

/// Liên kết Task ID với phiên hiện tại để thống kê pomodoro theo task
class LinkTask extends PomodoroEvent {
  final String? taskId; // null = bỏ liên kết

  const LinkTask({this.taskId});

  @override
  List<Object?> get props => [taskId];
}
