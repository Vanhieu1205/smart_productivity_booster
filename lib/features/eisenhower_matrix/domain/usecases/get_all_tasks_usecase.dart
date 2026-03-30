import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

// ============================================================
// GET ALL TASKS USE CASE
// ============================================================
// 
// [Clean Architecture] Tại sao cần UseCase layer?
// 1. Single Responsibility: Mỗi UseCase đại diện cho một hành động duy nhất (business operation) của người dùng.
// 2. Tách biệt: Tách biệt logic ứng dụng khỏi Presentation (BLoC) và Data (Repository).
// 3. Document: Nhìn vào thư mục usecases, developer mới có thể biết ngay ứng dụng làm được những gì (Screaming Architecture).
// 4. Testability: Dễ dàng viết Unit Test cho một tính năng cụ thể bằng cách mock Repository.

class GetAllTasksUseCase implements UseCase<List<TaskEntity>, NoParams> {
  final TaskRepository repository;

  GetAllTasksUseCase(this.repository);

  @override
  Future<List<TaskEntity>> call(NoParams params) async {
    try {
      return await repository.getAllTasks();
    } catch (e) {
      // Xử lý lỗi cơ bản: rethrow hoặc đóng gói lại lỗi
      throw Exception('Lỗi khi lấy danh sách task: $e');
    }
  }
}
