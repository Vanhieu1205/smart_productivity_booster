import 'package:hive/hive.dart';
import '../models/settings_model.dart';

// ============================================================
// SETTINGS LOCAL DATASOURCE – Data Layer
// ============================================================
// Đọc và Ghi Settings xuống Hive database.

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final HiveInterface hive;
  static const String _boxName = 'settings_box';
  static const String _settingsKey = 'app_settings';

  SettingsLocalDataSourceImpl({required this.hive});

  // Lazy getter đồng bộ trực tiếp lấy Box từ RAM vì _boxName đã được nạp bởi HiveService.
  Box<SettingsModel> get _box => hive.box<SettingsModel>(_boxName);

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final box = _box;
      // Trả về mặc định nếu lần đầu mở app (chưa có dữ liệu)
      return box.get(_settingsKey, defaultValue: SettingsModel(
        isDarkMode: false, // Mặc định là sáng
        languageCode: 'vi', // Mặc định là tiếng Việt
      ))!;
    } catch (e) {
      // Fallback nếu lỗi đọc Box
      return SettingsModel(isDarkMode: false, languageCode: 'vi');
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final box = _box;
      await box.put(_settingsKey, settings);
    } catch (e) {
      // Ghi log hoặc ném ngoại lệ nếu cần thiết
      rethrow;
    }
  }
}
