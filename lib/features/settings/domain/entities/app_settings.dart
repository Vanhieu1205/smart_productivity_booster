import 'package:equatable/equatable.dart';

/// Entity chứa toàn bộ cài đặt của ứng dụng
class AppSettings extends Equatable {
  final bool isDarkMode;
  final String languageCode;   // 'vi' hoặc 'en'
  final int workMinutes;       // Thời gian pomodoro (phút)
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsUntilLongBreak;
  final bool notificationsEnabled;

  const AppSettings({
    this.isDarkMode = false,
    this.languageCode = 'vi',
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsUntilLongBreak = 4,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsUntilLongBreak,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode, languageCode, workMinutes,
        shortBreakMinutes, longBreakMinutes,
        sessionsUntilLongBreak, notificationsEnabled,
      ];
}
