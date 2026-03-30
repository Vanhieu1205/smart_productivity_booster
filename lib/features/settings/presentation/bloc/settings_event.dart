import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Yêu cầu load dữ liệu settings từ database khi app khởi động
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Thay đổi chế độ Trắng/Đen
class ToggleDarkMode extends SettingsEvent {
  final bool isDarkMode;

  const ToggleDarkMode(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

/// Thay đổi ngôn ngữ ('vi' hoặc 'en')
class ChangeLanguage extends SettingsEvent {
  final String languageCode;

  const ChangeLanguage(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

/// Bật/tắt âm thanh thông báo Pomodoro
class ToggleSoundEnabled extends SettingsEvent {
  final bool isSoundEnabled;

  const ToggleSoundEnabled(this.isSoundEnabled);

  @override
  List<Object?> get props => [isSoundEnabled];
}

/// Thay đổi mục tiêu Pomodoro hàng ngày
class ChangeDailyPomodoroGoal extends SettingsEvent {
  final int dailyPomodoroGoal;

  const ChangeDailyPomodoroGoal(this.dailyPomodoroGoal);

  @override
  List<Object?> get props => [dailyPomodoroGoal];
}
