import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// UseCase: Thêm task mới
class AddTask implements UseCase<void, TaskEntity> {
  final TaskRepository repository;
  AddTask(this.repository);

  @override
  Future<void> call(TaskEntity task) => repository.addTask(task);
}
