import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';

// ============================================================
// EISENHOWER EVENT - BLoC Layer
// ============================================================
// 
// [Clean Architecture] Tại sao cần Event?
// 1. Event (Sự kiện) đại diện cho những gì người dùng tương tác trên UI.
// 2. Chuyển UI Action thành một "Object" có thể quản lý, dễ dàng truyền vào BLoC.
// 3. Tách biệt hoàn toàn việc người dùng ấn nút gì với xử lý logic bên dưới.

abstract class EisenhowerEvent extends Equatable {
  const EisenhowerEvent();

  @override
  List<Object?> get props => [];
}

/// Người dùng muốn tải danh sách các Task
class LoadTasks extends EisenhowerEvent {
  const LoadTasks();
}

/// Người dùng muốn thêm một Task mới
class AddTask extends EisenhowerEvent {
  final TaskEntity task;

  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// Người dùng muốn cập nhật thông tin Task
class UpdateTask extends EisenhowerEvent {
  final TaskEntity task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// Người dùng muốn xóa một Task dựa vào ID
class DeleteTask extends EisenhowerEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Người dùng kéo thả (Drag and Drop) Task sang góc phần tư khác
class MoveTask extends EisenhowerEvent {
  final String taskId;
  final QuadrantType newQuadrant;

  const MoveTask({required this.taskId, required this.newQuadrant});

  @override
  List<Object?> get props => [taskId, newQuadrant];
}

/// Người dùng nhấn Checkbox để đánh dấu hoàn thành/chưa hoàn thành
class ToggleComplete extends EisenhowerEvent {
  final TaskEntity task;

  const ToggleComplete(this.task);

  @override
  List<Object?> get props => [task];
}
