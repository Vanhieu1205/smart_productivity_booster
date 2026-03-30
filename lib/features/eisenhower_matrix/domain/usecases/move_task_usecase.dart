import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/quadrant_type.dart';
import '../repositories/task_repository.dart';

// ============================================================
// MOVE TASK USE CASE
// ============================================================
// 
// [Clean Architecture] Tại sao cần UseCase layer?
// 1. Phân chia rõ ràng: Thao tác UI Kéo/Thả (Drag & Drop) sẽ trigger MoveTaskUseCase.
// 2. Không để cho BLoC biết cách Data thay đổi. BLoC chỉ việc bắn Params (id, góc phần tư mới)
// và đợi UseCase xử lý logic bên dưới.
// 3. Cho phép thay đổi nơi lưu (ví dụ từ Local DB qua Firebase) mà không ảnh hưởng UI.

class MoveTaskUseCase implements UseCase<void, MoveTaskParams> {
  final TaskRepository repository;

  MoveTaskUseCase(this.repository);

  @override
  Future<void> call(MoveTaskParams params) async {
    try {
      // Gọi repository chuyển task sang quadrant (góc phần tư) mới
      await repository.moveTaskToQuadrant(params.taskId, params.newQuadrant);
    } catch (e) {
      // Xử lý lỗi cơ bản (try/catch)
      throw Exception('Lỗi khi di chuyển task (ID: ${params.taskId}): $e');
    }
  }
}

/// Params class chứa ID task và góc phần tư đích đến (khi Drag & Drop)
class MoveTaskParams extends Equatable {
  final String taskId;
  final QuadrantType newQuadrant;

  const MoveTaskParams({
    required this.taskId,
    required this.newQuadrant,
  });

  @override
  List<Object?> get props => [taskId, newQuadrant];
}
