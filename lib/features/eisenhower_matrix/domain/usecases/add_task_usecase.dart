import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';
import '../../../pomodoro_timer/data/services/notification_service.dart';

// ============================================================
// ADD TASK USE CASE
// ============================================================
// 
// [Clean Architecture] Tại sao cần UseCase layer?
// 1. Chứa các quy tắc nghiệp vụ (Business Rules). Ví dụ: Có thể kiểm tra
// tính hợp lệ của AddTaskParams trước khi gọi Repository.
// 2. Không dính dáng trực tiếp tới Framework hay UI (như Flutter Widget).
// 3. Đóng gói Logic: Giúp tái sử dụng hoặc test (Unit Test) một cách độc lập.

class AddTaskUseCase implements UseCase<void, AddTaskParams> {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  @override
  Future<void> call(AddTaskParams params) async {
    try {
      // Gọi repository để thêm task
      await repository.addTask(params.task);

      // Đặt lịch nhắc nhở deadline nếu task có dueDate
      if (params.task.dueDate != null) {
        await NotificationService.scheduleDeadlineReminder(
          taskId: params.task.id,
          taskTitle: params.task.title,
          deadline: params.task.dueDate!,
        );
      }
    } catch (e) {
      // Xử lý lỗi cơ bản (try/catch)
      throw Exception('Lỗi khi thêm task mới: $e');
    }
  }
}

/// Params class kế thừa từ Equatable để so sánh tham trị (value equality)
class AddTaskParams extends Equatable {
  final TaskEntity task;

  const AddTaskParams({required this.task});

  @override
  List<Object?> get props => [task];
}
