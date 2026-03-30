import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/quadrant_type.dart';
import '../repositories/task_repository.dart';

/// Tham số cho UseCase MoveTaskToQuadrant
class MoveTaskToQuadrantParams extends Equatable {
  final String taskId;
  final QuadrantType targetQuadrant;

  const MoveTaskToQuadrantParams({
    required this.taskId,
    required this.targetQuadrant,
  });

  @override
  List<Object?> get props => [taskId, targetQuadrant];
}

/// UseCase: Di chuyển task sang góc phần tư khác
class MoveTaskToQuadrant implements UseCase<void, MoveTaskToQuadrantParams> {
  final TaskRepository repository;
  MoveTaskToQuadrant(this.repository);

  @override
  Future<void> call(MoveTaskToQuadrantParams params) =>
      repository.moveTaskToQuadrant(params.taskId, params.targetQuadrant);
}
