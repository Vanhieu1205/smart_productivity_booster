import 'package:hive/hive.dart';
import '../../../../features/pomodoro_timer/data/models/pomodoro_session_model.dart';
import '../../../../features/eisenhower_matrix/data/models/task_model.dart';

// ============================================================
// STATISTICS LOCAL DATASOURCE – Data Layer
// ============================================================
//
// Lớp chịu trách nhiệm đọc dữ liệu từ Hive DB để phục vụ tính toán thống kê.
// Nó độc lập với business logic, chỉ đóng vai trò lấy đúng data.

abstract class StatisticsLocalDataSource {
  /// Lấy danh sách các session Pomodoro trong một khoảng thời gian
  Future<List<PomodoroSessionModel>> getPomodorosByDateRange(DateTime start, DateTime end);

  /// Đếm số Task được hoàn thành trong một khoảng thời gian
  Future<int> getCompletedTasksCount(DateTime start, DateTime end);
}

class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  final HiveInterface hive;
  
  // Tên box chuẩn nên được khai báo trong constants nếu app scale lớn
  static const String _pomodoroBoxName = 'pomodoro_sessions_box';
  static const String _taskBoxName = 'tasks_box';

  StatisticsLocalDataSourceImpl({required this.hive});

  /// Getter đồng bộ vì đã nạp ở HiveService
  Box<T> _getBox<T>(String boxName) {
    return hive.box<T>(boxName);
  }

  @override
  Future<List<PomodoroSessionModel>> getPomodorosByDateRange(DateTime start, DateTime end) async {
    try {
      final box = _getBox<PomodoroSessionModel>(_pomodoroBoxName);
      final allSessions = box.values.toList();
      
      // Lọc các session rơi vào khoảng thời gian [start, end]
      return allSessions.where((session) {
        final startTime = session.startTime;
        return startTime.isAfter(start.subtract(const Duration(seconds: 1))) && 
               startTime.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
    } catch (e) {
      // Trong môi trường thực tế, nên log lỗi và quăng CustomException
      rethrow;
    }
  }

  @override
  Future<int> getCompletedTasksCount(DateTime start, DateTime end) async {
    try {
      final box = _getBox<TaskModel>(_taskBoxName);
      final allTasks = box.values.toList();

      // Đếm các task thỏa mãn 2 điều kiện:
      // 1. Đã hoàn thành
      // 2. Thuộc khoảng thời gian được tính (dựa vào createdAt hoặc updatedAt nếu có)
      // Lưu ý: TaskEntity chỉ có createdAt hiện tại. Tạm thời tính các task
      // tạo ra trong tuần này và đã hoàn thành. Nếu muốn đếm chính xác thời điểm ấn "Hoàn thành",
      // thì TaskEntity cần có trường `completedAt`.
      return allTasks.where((task) {
        if (!task.isCompleted) return false;
        
        // Mặc định so sánh ngày tạo
        return task.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) && 
               task.createdAt.isBefore(end.add(const Duration(seconds: 1)));
      }).length;
    } catch (e) {
      rethrow;
    }
  }
}
