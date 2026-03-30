import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// UseCase: Lấy tất cả tasks
class GetAllTasks implements UseCase<List<TaskEntity>, NoParams> {
  final TaskRepository repository;
  GetAllTasks(this.repository);

  @override
  Future<List<TaskEntity>> call(NoParams params) => repository.getAllTasks();
}
