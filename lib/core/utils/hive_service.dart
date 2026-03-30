import 'package:hive_flutter/hive_flutter.dart';
import '../../features/eisenhower_matrix/data/models/task_model.dart';
import '../../features/pomodoro_timer/data/models/pomodoro_session_model.dart';
import '../../features/settings/data/models/settings_model.dart';
import '../../features/auth/data/models/user_model.dart';

/// Service quản lý tập trung việc mở và đóng Hive Boxes
class HiveService {
  /// Giải thích sự khác biệt giữa Hive.openBox() và Hive.box():
  /// - `Hive.openBox()`: Hàm Async. Cần chọc vào hệ thống lưu trữ (File System) trên thiết bị, 
  ///   sau đó nạp tuần tự toàn bộ Data lên RAM. Hàm này bắt buộc gọi đầu tiên và phải await.
  /// - `Hive.box()`: Hàm Sync. Hoạt động trên Data đã có sẵn ở RAM (do openBox nạp trước đó). 
  ///   Đọc ghi tức thời (Sync). Nếu chưa openBox mà lỡ gọi Hive.box() thì sẽ gây crash (Box not open).
  static Future<void> openAllBoxes() async {
    await Hive.openBox<TaskModel>('tasks_box');
    await Hive.openBox<PomodoroSessionModel>('pomodoro_sessions_box');
    await Hive.openBox<SettingsModel>('settings_box');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox('session');         // Box không có cấu trúc cố định
    await Hive.openBox('onboardingBox');   // Box lưu trữ trạng thái khởi chạy
    await Hive.openBox('achievements_box'); // Box lưu trữ achievements đã unlock
  }

  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }
}
