import '../entities/task_entity.dart';
import '../entities/quadrant_type.dart';

// ============================================================
// TASK REPOSITORY – Domain Layer
// ============================================================
//
// [Clean Architecture] Tại sao lại chọn Future đơn giản thay vì Either<Failure, TaskEntity>?
//
// 1. Bản chất Project: Ứng dụng này sử dụng Hive (Local Database).
//    - Hive chạy ở dưới client, đồng bộ, cực kỳ nhanh gọn và ít khi bị lỗi mạng/server.
//    - Lỗi phổ biến nhất thường là TypeAdapter chưa được đăng ký (do code) chứ không phải do môi trường.
//
// 2. Không làm phức tạp hóa (Over-engineering):
//    - Nếu có remote API (Firebase, REST), việc dùng `Either` từ package `dartz` hoặc `fpdart`
//      là cần thiết để bắt các exception mạng (ServerFailure, OfflineFailure...).
//    - Với local-only app, việc bọc lại trong `Either` khiến UseCase, BLoC phải xử lý map/fold
//      rườm rà không cần thiết. Nếu có lỗi nghiêm trọng (hỏng DB), ta có thể quăng thẳng
//      Exception và bắt ở Block (try-catch) để hiển thị.
//
// Dưới đây là Interface (Contract) mà Data layer bắt buộc phải tuân theo.

/// Hợp đồng giao tiếp (Contract) giữa Domain và Data layer
abstract class TaskRepository {
  /// Lấy toàn bộ danh sách Task hiện có
  Future<List<TaskEntity>> getAllTasks();

  /// Lấy danh sách Task theo một góc phần tư (Quadrant) cụ thể
  Future<List<TaskEntity>> getTasksByQuadrant(QuadrantType quadrant);

  /// Thêm một Task mới
  Future<void> addTask(TaskEntity task);

  /// Cập nhật thông tin của một Task
  Future<void> updateTask(TaskEntity task);

  /// Xóa một Task dựa trên ID
  Future<void> deleteTask(String id);

  /// Đổi góc phần tư của một Task (move/drag-drop)
  Future<void> moveTaskToQuadrant(String id, QuadrantType targetQuadrant);
}
