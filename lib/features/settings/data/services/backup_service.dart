import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../eisenhower_matrix/data/models/task_model.dart';
import '../../../pomodoro_timer/data/models/pomodoro_session_model.dart';
import '../../../settings/data/models/settings_model.dart';
import '../../../auth/data/models/user_model.dart';

// ============================================================
// BACKUP SERVICE – Data Layer
// ============================================================
// Service xử lý xuất/nhập dữ liệu ứng dụng (backup/restore).
//
// Chức năng:
// - Export: Đọc dữ liệu từ Hive → ghi JSON → chia sẻ file
// - Import: Chọn file JSON → đọc → validate → khôi phục vào Hive
// - Restore: Khôi phục dữ liệu + tự động đăng nhập với tài khoản trong backup

class BackupService {
  /// Tên ứng dụng trong file backup (dùng để validate)
  static const String _appName = 'Smart Productivity Booster';

  /// Version của định dạng backup
  static const int _dataVersion = 2;

  /// Tên file backup mặc định (có timestamp)
  String get _backupFileName {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return 'smart_productivity_backup_$timestamp.json';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // XUẤT DỮ LIỆU (EXPORT)
  // ────────────────────────────────────────────────────────────────────────────

  /// Xuất dữ liệu ra file JSON và chia sẻ qua Share.
  /// Trả về đường dẫn file đã lưu.
  ///
  /// Dữ liệu xuất bao gồm:
  /// - Tasks (tasks_box)
  /// - Pomodoro Sessions (pomodoro_sessions_box)
  /// - Settings (settings_box)
  /// - User accounts (users box)
  /// - Achievements (achievements_box)
  Future<String> exportData() async {
    // Đọc dữ liệu từ Hive
    final tasksBox = Hive.box<TaskModel>('tasks_box');
    final sessionsBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
    final settingsBox = Hive.box<SettingsModel>('settings_box');
    final usersBox = Hive.box<UserModel>('users');
    final achievementsBox = Hive.box<dynamic>('achievements_box');

    // Chuyển tasks sang list map
    final tasksList = tasksBox.values.map((task) => task.toJson()).toList();

    // Chuyển sessions sang list map
    final sessionsList = sessionsBox.values.map((session) => session.toJson()).toList();

    // Chuyển settings sang list map
    final settingsList = settingsBox.values.map((settings) => settings.toJson()).toList();

    // Chuyển users sang list map
    final usersList = usersBox.values.map((user) => user.toJson()).toList();

    // Chuyển achievements sang list map
    final achievementsList = <Map<String, dynamic>>[];
    for (final key in achievementsBox.keys) {
      final value = achievementsBox.get(key);
      if (value is Map) {
        achievementsList.add({
          'id': key.toString(),
          ...Map<String, dynamic>.from(value),
        });
      }
    }

    // Tạo map dữ liệu backup
    final backupData = {
      'version': _dataVersion,
      'app': _appName,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasksList,
      'sessions': sessionsList,
      'settings': settingsList,
      'users': usersList,
      'achievements': achievementsList,
    };

    // Lấy thư mục documents của app
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$_backupFileName';

    // Ghi dữ liệu ra file JSON
    final file = File(filePath);
    await file.writeAsString(jsonEncode(backupData));

    return filePath;
  }

  /// Chia sẻ file backup qua system share dialog
  Future<void> shareBackup() async {
    final filePath = await exportData();
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Backup $_appName',
      text: 'Dữ liệu backup từ $_appName',
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // NHẬP DỮ LIỆU (IMPORT)
  // ────────────────────────────────────────────────────────────────────────────

  /// Chọn file backup và khôi phục dữ liệu.
  /// Trả về true nếu thành công, false nếu có lỗi.
  ///
  /// Quy trình:
  /// 1. FilePicker chọn file .json
  /// 2. Đọc và parse JSON
  /// 3. Validate app name
  /// 4. Clear boxes hiện tại
  /// 5. Khôi phục từng item
  Future<bool> importData() async {
    try {
      // Bước 1: Chọn file qua FilePicker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // Người dùng hủy chọn file
        return false;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      // Bước 2: Đọc nội dung file
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Bước 3: Validate app name
      final appName = data['app'] as String?;
      if (appName != _appName) {
        throw Exception('File không phải là backup của $_appName');
      }

      await _restoreData(data);

      return true;
    } catch (e) {
      // Log lỗi và trả về false
      rethrow;
    }
  }

  /// Khôi phục dữ liệu từ map đã parse (dùng chung cho import và restore)
  Future<void> _restoreData(Map<String, dynamic> data) async {
    // Clear boxes hiện tại
    final tasksBox = Hive.box<TaskModel>('tasks_box');
    final sessionsBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
    final settingsBox = Hive.box<SettingsModel>('settings_box');
    final usersBox = Hive.box<UserModel>('users');
    final achievementsBox = Hive.box<dynamic>('achievements_box');

    await tasksBox.clear();
    await sessionsBox.clear();
    await settingsBox.clear();
    await usersBox.clear();
    await achievementsBox.clear();

    // Khôi phục tasks
    final tasksList = data['tasks'] as List<dynamic>? ?? [];
    for (final taskData in tasksList) {
      final task = TaskModel.fromJson(taskData as Map<String, dynamic>);
      await tasksBox.put(task.id, task);
    }

    // Khôi phục sessions
    final sessionsList = data['sessions'] as List<dynamic>? ?? [];
    for (final sessionData in sessionsList) {
      final session = PomodoroSessionModel.fromJson(sessionData as Map<String, dynamic>);
      await sessionsBox.put(session.id, session);
    }

    // Khôi phục settings
    final settingsList = data['settings'] as List<dynamic>? ?? [];
    for (final settingsData in settingsList) {
      final settings = SettingsModel.fromJson(settingsData as Map<String, dynamic>);
      await settingsBox.put(settings.id, settings);
    }

    // Khôi phục users
    final usersList = data['users'] as List<dynamic>? ?? [];
    for (final userData in usersList) {
      final user = UserModel.fromJson(userData as Map<String, dynamic>);
      await usersBox.put(user.id, user);
    }

    // Khôi phục achievements
    final achievementsList = data['achievements'] as List<dynamic>? ?? [];
    for (final achData in achievementsList) {
      final achMap = achData as Map<String, dynamic>;
      final id = achMap['id'] as String?;
      if (id != null) {
        achMap.remove('id');
        await achievementsBox.put(id, achMap);
      }
    }
  }

  /// Khôi phục dữ liệu từ file backup và trả về thông tin tài khoản đầu tiên (nếu có)
  /// Dùng cho tính năng đăng nhập từ backup
  Future<Map<String, dynamic>?> restoreDataAndGetUser() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return null;
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final appName = data['app'] as String?;
      if (appName != _appName) {
        throw Exception('File không phải là backup của $_appName');
      }

      await _restoreData(data);

      // Trả về thông tin tài khoản đầu tiên (nếu có)
      final usersList = data['users'] as List<dynamic>? ?? [];
      if (usersList.isNotEmpty) {
        final firstUser = usersList.first as Map<String, dynamic>;
        return {
          'email': firstUser['email'] as String?,
          'password': _decodePassword(firstUser['passwordHash'] as String?),
        };
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Giải mã password từ hash (base64)
  String? _decodePassword(String? hash) {
    if (hash == null || hash.isEmpty) return null;
    try {
      final bytes = base64Decode(hash);
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }
}
