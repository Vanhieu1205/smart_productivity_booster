import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// UseCase: Cập nhật task đã có
class UpdateTask implements UseCase<void, TaskEntity> {
  final TaskRepository repository;
  UpdateTask(this.repository);

  @override
  Future<void> call(TaskEntity task) => repository.updateTask(task);
}
