import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

// ============================================================
// TASK REPOSITORY IMPL – Data Layer
// ============================================================
//
// Lớp này là 'chiếc cầu nối' vững chắc giữa bộ não Domain và bộ nhớ Data.
//
// Nhiệm vụ:
// 1. Override các method của TaskRepository để Domain gọi.
// 2. Chuyển Entity nhận được thành Model và gửi đến DataSource (Hive)
// 3. Nhận Models từ Data Source (Hive) và chuyển ngược thành Entity trả về Domain.
//
// Dưới đây đã thực hiện chuyển đổi Model ↔ Entity

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  // Injection DataSource vào trong Repository thông qua Constructor.
  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final models = await localDataSource.getAllTasks();
    // Convert Model -> Entity cho Layer trên xài
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByQuadrant(QuadrantType quadrant) async {
    final models = await localDataSource.getTasksByQuadrant(quadrant);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    // Convert Entity -> Model để đẩy xuống Database lưu trữ
    final model = TaskModel.fromEntity(task);
    await localDataSource.saveTask(model);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDataSource.deleteTask(id);
  }

  @override
  Future<void> moveTaskToQuadrant(String id, QuadrantType targetQuadrant) async {
    // 1. Phải lấy task cũ trước
    final models = await localDataSource.getAllTasks();
    final model = models.firstWhere((m) => m.id == id);
    
    // 2. Tạo bản sao mới nhưng thay đổi quadrantIndex
    final updatedModel = model.copyWith(quadrantIndex: targetQuadrant.index);
    
    // 3. Ghi đè task cũ
    await localDataSource.updateTask(updatedModel);
  }
}
