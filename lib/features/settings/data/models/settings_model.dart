import 'package:hive/hive.dart';

part 'settings_model.g.dart'; // File tự động sinh của Hive

// ============================================================
// SETTINGS MODEL – Data Layer
// ============================================================
// Định nghĩa Hive Type và các mốc lưu trữ cho phần cấu hình app.
// Cần chạy lệnh build_runner để tạo file .g.dart trước khi build:
// > flutter pub run build_runner build --delete-conflicting-outputs

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String languageCode;

  /// Bật/tắt âm thanh thông báo Pomodoro (mặc định: true)
  @HiveField(2)
  final bool isSoundEnabled;

  /// Số ngày streak hiện tại (đếm số ngày liên tiếp hoàn thành công việc)
  @HiveField(3)
  final int currentStreak;

  /// Kỷ lục streak dài nhất từng đạt được
  @HiveField(4)
  final int longestStreak;

  /// Ngày hoạt động cuối cùng (định dạng yyyy-MM-dd)
  @HiveField(5)
  final String? lastActiveDateStr;

  /// Mục tiêu Pomodoro hàng ngày (mặc định: 8)
  @HiveField(6)
  final int dailyPomodoroGoal;

  SettingsModel({
    required this.isDarkMode,
    required this.languageCode,
    this.isSoundEnabled = true,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDateStr,
    this.dailyPomodoroGoal = 8,
  });

  /// Hỗ trợ copy với giá trị mới (thường dùng khi user toggle switch)
  SettingsModel copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? isSoundEnabled,
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDateStr,
    int? dailyPomodoroGoal,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDateStr: lastActiveDateStr ?? this.lastActiveDateStr,
      dailyPomodoroGoal: dailyPomodoroGoal ?? this.dailyPomodoroGoal,
    );
  }
}
