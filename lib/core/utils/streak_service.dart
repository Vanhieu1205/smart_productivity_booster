import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../features/settings/data/models/settings_model.dart';

// ============================================================
// STREAK SERVICE – Core Utils
// ============================================================
// Service quản lý logic streak (chuỗi ngày liên tiếp).
// Gọi StreakService.update() sau mỗi lần hoàn thành 1 phase Pomodoro work.

/// Định dạng ngày dùng trong Hive (yyyy-MM-dd)
final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

/// Service quản lý streak:
///
/// - currentStreak: số ngày liên tiếp hoàn thành công việc
/// - longestStreak: kỷ lục streak dài nhất từng đạt được
/// - lastActiveDate: ngày hoạt động cuối cùng (yyyy-MM-dd)
///
/// Quy tắc cập nhật:
///   - diff == 0 (cùng ngày): không đổi (tránh spam)
///   - diff == 1 (hôm qua): streak++, update longest nếu cần
///   - diff > 1 (nghỉ >=2 ngày): streak = 1 (reset chuỗi)
///
/// Điều kiện "hoàn thành": đã gọi StreakService.update() sau phase work kết thúc.
class StreakService {
  /// Box chứa Settings (đã được mở bởi HiveService.openAllBoxes())
  final Box<SettingsModel> _settingsBox;

  /// Key lưu settings trong box
  static const String _settingsKey = 'app_settings';

  StreakService({required Box<SettingsModel> settingsBox})
      : _settingsBox = settingsBox;

  /// Đọc settings hiện tại từ Hive.
  /// Trả về default nếu chưa có.
  SettingsModel _readSettings() {
    return _settingsBox.get(
      _settingsKey,
      defaultValue: SettingsModel(
        isDarkMode: false,
        languageCode: 'vi',
      ),
    )!;
  }

  /// Lấy ngày hôm nay dạng chuỗi (yyyy-MM-dd).
  String _todayStr() => _dateFormat.format(DateTime.now());

  /// Parse chuỗi yyyy-MM-dd thành DateTime (chỉ lấy date, bỏ time).
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return _dateFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Tính số ngày chênh lệch giữa [dateStr] và hôm nay.
  /// Trả về null nếu dateStr không hợp lệ.
  int? _daysDiff(String? dateStr) {
    final lastDate = _parseDate(dateStr);
    if (lastDate == null) return null;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);

    return todayDate.difference(lastDateOnly).inDays;
  }

  /// Cập nhật streak sau khi hoàn thành 1 phase work.
  ///
  /// Gọi hàm này trong PomodoroBloc sau khi work phase kết thúc:
  ///   StreakService.update();
  Future<void> update() async {
    final settings = _readSettings();
    final today = _todayStr();
    final lastDate = settings.lastActiveDateStr;
    final diff = _daysDiff(lastDate);

    int newStreak;
    int newLongest;

    if (diff == null || diff > 1) {
      // Chưa từng có hoặc nghỉ >= 2 ngày → bắt đầu chuỗi mới = 1
      newStreak = 1;
      newLongest = settings.longestStreak; // Giữ nguyên kỷ lục
    } else if (diff == 1) {
      // Hôm qua có hoạt động → tăng streak
      newStreak = settings.currentStreak + 1;
      // Cập nhật kỷ lục nếu vượt
      newLongest = newStreak > settings.longestStreak
          ? newStreak
          : settings.longestStreak;
    } else {
      // diff == 0: cùng ngày → không đổi (tránh spam cùng ngày)
      return;
    }

    // Tạo settings mới với streak đã cập nhật
    final updatedSettings = settings.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastActiveDateStr: today,
    );

    // Lưu xuống Hive
    await _settingsBox.put(_settingsKey, updatedSettings);
  }

  /// Lấy streak hiện tại (đọc trực tiếp từ Hive, không cần await).
  int getCurrentStreak() {
    return _readSettings().currentStreak;
  }

  /// Lấy kỷ lục streak (đọc trực tiếp từ Hive, không cần await).
  int getLongestStreak() {
    return _readSettings().longestStreak;
  }
}
