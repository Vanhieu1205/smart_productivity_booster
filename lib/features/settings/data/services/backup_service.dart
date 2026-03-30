import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../eisenhower_matrix/data/models/task_model.dart';
import '../../../pomodoro_timer/data/models/pomodoro_session_model.dart';

// ============================================================
// BACKUP SERVICE – Data Layer
// ============================================================
// Service xử lý xuất/nhập dữ liệu ứng dụng (backup/restore).
//
// Chức năng:
// - Export: Đọc dữ liệu từ Hive → ghi JSON → chia sẻ file
// - Import: Chọn file JSON → đọc → validate → khôi phục vào Hive

class BackupService {
  /// Tên ứng dụng trong file backup (dùng để validate)
  static const String _appName = 'Smart Productivity Booster';

  /// Version của định dạng backup
  static const int _dataVersion = 1;

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
  Future<String> exportData() async {
    // Đọc dữ liệu từ Hive
    final tasksBox = Hive.box<TaskModel>('tasks_box');
    final sessionsBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');

    // Chuyển tasks sang list map (dùng toJson() để đảm bảo đúng format)
    final tasksList = tasksBox.values.map((task) => task.toJson()).toList();

    // Chuyển sessions sang list map (dùng toJson() để đảm bảo đúng format)
    final sessionsList = sessionsBox.values.map((session) => session.toJson()).toList();

    // Tạo map dữ liệu backup
    final backupData = {
      'version': _dataVersion,
      'app': _appName,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasksList,
      'sessions': sessionsList,
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

      // Bước 4: Clear boxes hiện tại
      final tasksBox = Hive.box<TaskModel>('tasks_box');
      final sessionsBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
      await tasksBox.clear();
      await sessionsBox.clear();

      // Bước 5: Khôi phục tasks bằng fromJson()
      final tasksList = data['tasks'] as List<dynamic>? ?? [];
      for (final taskData in tasksList) {
        final task = TaskModel.fromJson(taskData as Map<String, dynamic>);
        await tasksBox.put(task.id, task);
      }

      // Bước 6: Khôi phục sessions bằng fromJson()
      final sessionsList = data['sessions'] as List<dynamic>? ?? [];
      for (final sessionData in sessionsList) {
        final session = PomodoroSessionModel.fromJson(sessionData as Map<String, dynamic>);
        await sessionsBox.put(session.id, session);
      }

      return true;
    } catch (e) {
      // Log lỗi và trả về false
      rethrow;
    }
  }
}
