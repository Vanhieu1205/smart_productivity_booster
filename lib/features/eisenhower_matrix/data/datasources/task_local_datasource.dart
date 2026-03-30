import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../../domain/entities/quadrant_type.dart';

// ============================================================
// TASK LOCAL DATA SOURCE – Data Layer
// ============================================================

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<List<TaskModel>> getTasksByQuadrant(QuadrantType quadrant);
  Future<void> saveTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

/// Implementation của local datasource sử dụng thư viện Hive
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  // Tên box của Hive để lưu task.
  static const String boxName = 'tasks_box';

  final HiveInterface hive;

  TaskLocalDataSourceImpl({required this.hive});

  /// Hàm khởi tạo Box.
  /// Gọi một lần trước khi sử dụng datasource.
  /// Lazy getter đồng bộ - Lấy dữ liệu trực tiếp trong RAM (đã open ở main.dart)
  Box<TaskModel> get _box => hive.box<TaskModel>(boxName);

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final box = _box;
    // Map kết quả iterable sang List
    return box.values.toList();
  }

  @override
  Future<List<TaskModel>> getTasksByQuadrant(QuadrantType quadrant) async {
    final box = _box;
    // Lọc theo QuadrantIndex
    return box.values
        .where((model) => model.quadrantIndex == quadrant.index)
        .toList();
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final box = _box;
    // Sử dụng put(key, value) để có thể update dựa trên ID dễ dàng sau này
    await box.put(task.id, task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final box = _box;
    // put() ghi đè giá trị nếu key đã tồn tại
    await box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    final box = _box;
    await box.delete(id);
  }
}
