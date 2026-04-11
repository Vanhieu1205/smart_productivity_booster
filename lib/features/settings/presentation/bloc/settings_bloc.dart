import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/models/settings_model.dart';

// ============================================================
// SETTINGS BLOC – Presentation Layer
// ============================================================
// Bloc quản lý thao tác với cấu hình ứng dụng (Dark Mode, Language).
// Hoàn toàn phụ thuộc vào Local DataSource để đọc/lưu xuống Hive.

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsLocalDataSource localDataSource;

  SettingsBloc({required this.localDataSource}) : super(SettingsLoading()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ToggleSoundEnabled>(_onToggleSoundEnabled);
    on<ChangeDailyPomodoroGoal>(_onChangeDailyPomodoroGoal);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(SettingsLoading());
      final settings = await localDataSource.getSettings();
      // Phục hồi setting và quăng state để làm tươi màn hình toàn App.
      emit(SettingsLoaded(
        isDarkMode: settings.isDarkMode,
        languageCode: settings.languageCode,
        isSoundEnabled: settings.isSoundEnabled,
        dailyPomodoroGoal: settings.dailyPomodoroGoal,
      ));
    } catch (e) {
      // Nếu chưa có cài đặt lưu trong Hive (chạy lần đầu) hoặc lỗi,
      // thì phải trả về giá trị mặc định tránh lỗi logic UI.
      emit(const SettingsLoaded(
        isDarkMode: false,
        languageCode: 'vi',
        isSoundEnabled: true,
        dailyPomodoroGoal: 8,
      ));
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    // Chỉ xử lý nếu dữ liệu Settings đang loaded
    if (state is SettingsLoaded) {
      try {
        final stored = await localDataSource.getSettings();
        final newSettings = stored.copyWith(isDarkMode: event.isDarkMode);
        await localDataSource.saveSettings(newSettings);
        // Phát state làm thay đổi theme toàn app nếu MaterialApp lắng nghe
        emit(SettingsLoaded(
          isDarkMode: newSettings.isDarkMode,
          languageCode: newSettings.languageCode,
          isSoundEnabled: newSettings.isSoundEnabled,
          dailyPomodoroGoal: newSettings.dailyPomodoroGoal,
        ));
      } catch (e) {
        // Có thể rollback, hoặc log.
        emit(SettingsError('Lỗi lưu chế độ tối: ${e.toString()}'));
      }
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final stored = await localDataSource.getSettings();
        final newSettings = stored.copyWith(languageCode: event.languageCode);
        await localDataSource.saveSettings(newSettings);
        emit(SettingsLoaded(
          isDarkMode: newSettings.isDarkMode,
          languageCode: newSettings.languageCode,
          isSoundEnabled: newSettings.isSoundEnabled,
          dailyPomodoroGoal: newSettings.dailyPomodoroGoal,
        ));
      } catch (e) {
        emit(SettingsError('Lỗi đổi ngôn ngữ: ${e.toString()}'));
      }
    }
  }

  Future<void> _onToggleSoundEnabled(
    ToggleSoundEnabled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final stored = await localDataSource.getSettings();
        final newSettings = stored.copyWith(isSoundEnabled: event.isSoundEnabled);
        await localDataSource.saveSettings(newSettings);
        emit(SettingsLoaded(
          isDarkMode: newSettings.isDarkMode,
          languageCode: newSettings.languageCode,
          isSoundEnabled: newSettings.isSoundEnabled,
          dailyPomodoroGoal: newSettings.dailyPomodoroGoal,
        ));
      } catch (e) {
        emit(SettingsError('Lỗi lưu âm thanh thông báo: ${e.toString()}'));
      }
    }
  }

  /// Xử lý thay đổi mục tiêu Pomodoro hàng ngày
  Future<void> _onChangeDailyPomodoroGoal(
    ChangeDailyPomodoroGoal event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final stored = await localDataSource.getSettings();
        final newSettings =
            stored.copyWith(dailyPomodoroGoal: event.dailyPomodoroGoal);
        await localDataSource.saveSettings(newSettings);
        emit(SettingsLoaded(
          isDarkMode: newSettings.isDarkMode,
          languageCode: newSettings.languageCode,
          isSoundEnabled: newSettings.isSoundEnabled,
          dailyPomodoroGoal: newSettings.dailyPomodoroGoal,
        ));
      } catch (e) {
        emit(SettingsError('Lỗi lưu mục tiêu Pomodoro: ${e.toString()}'));
      }
    }
  }
}
