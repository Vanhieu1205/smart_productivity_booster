import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Khi đang đọc dữ liệu từ DB (Flash ngắn hoặc khởi tạo)
class SettingsLoading extends SettingsState {}

/// Khi tải xong hoặc user vừa thay đổi Settings
class SettingsLoaded extends SettingsState {
  final bool isDarkMode;
  final String languageCode;
  final bool isSoundEnabled;
  final int dailyPomodoroGoal;

  const SettingsLoaded({
    required this.isDarkMode,
    required this.languageCode,
    required this.isSoundEnabled,
    required this.dailyPomodoroGoal,
  });

  @override
  List<Object?> get props => [isDarkMode, languageCode, isSoundEnabled, dailyPomodoroGoal];
}

/// Lỗi ngoài ý muốn
class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
