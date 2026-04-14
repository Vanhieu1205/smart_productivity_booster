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
  /// ID cho Hive (luôn dùng 'default_settings' vì chỉ có 1 settings)
  @HiveField(0)
  final String id;

  @HiveField(1)
  final bool isDarkMode;

  @HiveField(2)
  final String languageCode;

  /// Bật/tắt âm thanh thông báo Pomodoro (mặc định: true)
  @HiveField(3)
  final bool isSoundEnabled;

  /// Số ngày streak hiện tại (đếm số ngày liên tiếp hoàn thành công việc)
  @HiveField(4)
  final int currentStreak;

  /// Kỷ lục streak dài nhất từng đạt được
  @HiveField(5)
  final int longestStreak;

  /// Ngày hoạt động cuối cùng (định dạng yyyy-MM-dd)
  @HiveField(6)
  final String? lastActiveDateStr;

  /// Mục tiêu Pomodoro hàng ngày (mặc định: 8)
  @HiveField(7)
  final int dailyPomodoroGoal;

  SettingsModel({
    this.id = 'default_settings',
    this.isDarkMode = false,
    this.languageCode = 'vi',
    this.isSoundEnabled = true,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDateStr,
    this.dailyPomodoroGoal = 8,
  });

  /// Hỗ trợ copy với giá trị mới (thường dùng khi user toggle switch)
  SettingsModel copyWith({
    String? id,
    bool? isDarkMode,
    String? languageCode,
    bool? isSoundEnabled,
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDateStr,
    int? dailyPomodoroGoal,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDateStr: lastActiveDateStr ?? this.lastActiveDateStr,
      dailyPomodoroGoal: dailyPomodoroGoal ?? this.dailyPomodoroGoal,
    );
  }

  /// Chuyển đổi sang Map để lưu backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isDarkMode': isDarkMode,
      'languageCode': languageCode,
      'isSoundEnabled': isSoundEnabled,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDateStr': lastActiveDateStr,
      'dailyPomodoroGoal': dailyPomodoroGoal,
    };
  }

  /// Tạo SettingsModel từ Map (dùng khi restore backup)
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'] as String? ?? 'default_settings',
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      languageCode: json['languageCode'] as String? ?? 'vi',
      isSoundEnabled: json['isSoundEnabled'] as bool? ?? true,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDateStr: json['lastActiveDateStr'] as String?,
      dailyPomodoroGoal: json['dailyPomodoroGoal'] as int? ?? 8,
    );
  }
}
