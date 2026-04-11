import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service phát âm thanh cho Pomodoro Timer.
/// - Được dùng ở Presentation Layer (PomodoroBloc / UI) thông qua DI (GetIt).
/// - Có cờ [enabled] để tắt/mở âm thanh từ Settings.
class SoundService {
  final AudioPlayer _player = AudioPlayer();

  /// Cờ cho phép bật/tắt âm thanh (mặc định: true).
  bool enabled = true;

  /// Phát âm báo khi hoàn thành phiên làm việc (work).
  Future<void> playWorkComplete() async {
    // Rung mạnh hơn để báo kết thúc work
    HapticFeedback.heavyImpact();

    if (!enabled) return;

    await _player.play(
      AssetSource('sounds/timer_complete.mp3'),
    );
  }

  /// Phát âm báo khi hoàn thành phiên nghỉ (break).
  Future<void> playBreakComplete() async {
    // Rung nhẹ hơn cho break
    HapticFeedback.mediumImpact();

    if (!enabled) return;

    await _player.play(
      AssetSource('sounds/break_complete.mp3'),
    );
  }

  /// Phát âm thanh ăn mừng khi hoàn thành 1 Pomodoro work.
  Future<void> playWorkCelebration() async {
    if (!enabled) return;

    await _player.play(
      AssetSource('sounds/yeahhh.mp3'),
    );
  }
}

