import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';
import '../../../pomodoro_timer/data/services/notification_service.dart';

// ============================================================
// DELETE TASK USE CASE
// ============================================================
// 
// [Clean Architecture] Tại sao cần UseCase layer?
// 1. Module hóa cao: BLoC (Presentation) chỉ làm nhiệm vụ kết nối UI và UseCase.
// UI không gọi thẳng Repository để giữ cho mã nguồn tách rời (loose coupling).
// 2. Tái sử dụng dễ: Nếu có nhiều màn hình cùng xóa Task, chúng đều gọi UseCase
// giống hệt nhau, duy trì tính "Single Source of Truth".

class DeleteTaskUseCase implements UseCase<void, String> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<void> call(String id) async {
    try {
      // Hủy lịch nhắc nhở deadline trước khi xóa task
      await NotificationService.cancelDeadlineReminder(id);

      // Gọi repository để xóa task khỏi cơ sở dữ liệu dựa vào id
      await repository.deleteTask(id);
    } catch (e) {
      // Xử lý lỗi cơ bản (try/catch)
      throw Exception('Lỗi khi xóa task (ID: $id): $e');
    }
  }
}
