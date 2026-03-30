import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

// ============================================================
// UPDATE TASK USE CASE
// ============================================================
// 
// [Clean Architecture] Tại sao cần UseCase layer?
// 1. Dễ bảo trì: Tương lai nếu "Update Task" đòi hỏi phải gọi thêm API đồng bộ hóa
// hoặc phân tích Log (Analytics), ta chỉ cần sửa UseCase mà không thay đổi UI.
// 2. Chứa Single Responsibility (1 chức năng = 1 class).
// 3. Cho phép testing dễ dàng vì ta có thể mock Data Layer (Repository) và kiểm tra
// logic ở Domain Layer.

class UpdateTaskUseCase implements UseCase<void, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<void> call(UpdateTaskParams params) async {
    try {
      // Gọi repository để cập nhật thông tin task
      await repository.updateTask(params.task);
    } catch (e) {
      // Xử lý lỗi cơ bản (try/catch)
      throw Exception('Lỗi khi cập nhật task: $e');
    }
  }
}

/// Params class chứa thông tin cần thiết để update task. Cần Equatable!
class UpdateTaskParams extends Equatable {
  final TaskEntity task;

  const UpdateTaskParams({required this.task});

  @override
  List<Object?> get props => [task];
}
