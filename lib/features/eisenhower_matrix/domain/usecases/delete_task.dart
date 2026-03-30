import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

/// UseCase: Xóa task theo ID
class DeleteTask implements UseCase<void, String> {
  final TaskRepository repository;
  DeleteTask(this.repository);

  @override
  Future<void> call(String id) => repository.deleteTask(id);
}
