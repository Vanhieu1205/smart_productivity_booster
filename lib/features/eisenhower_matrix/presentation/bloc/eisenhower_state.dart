import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';

// ============================================================
// EISENHOWER STATE - BLoC Layer
// ============================================================
// 
// [Clean Architecture] Tại sao cần State?
// 1. Dữ liệu trên màn hình chỉ được render dựa vào State hiện tại (Unidirectional Data Flow).
// 2. Tách biệt View và Model, UI không tự quản lý dữ liệu mà chỉ phản ứng với State.
// 3. Trạng thái "Loading/Error/Loaded" giúp quản lý các Progress Indicator rất dễ.

abstract class EisenhowerState extends Equatable {
  const EisenhowerState();
  
  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo, khi BLoC vừa được tạo
class EisenhowerInitial extends EisenhowerState {
  const EisenhowerInitial();
}

/// Trạng thái đang tải dữ liệu (Hiển thị Spinner ngầm)
class EisenhowerLoading extends EisenhowerState {
  const EisenhowerLoading();
}

/// Trạng thái dữ liệu đã tải thành công, chứa dữ liệu phân bố theo Quadrant
class EisenhowerLoaded extends EisenhowerState {
  /// Sử dụng một Map ánh xạ từ QuadrantType tới danh sách các Task
  final Map<QuadrantType, List<TaskEntity>> tasksByQuadrant;

  const EisenhowerLoaded({required this.tasksByQuadrant});

  @override
  List<Object?> get props => [tasksByQuadrant];
}

/// Trạng thái có lỗi (ném ra Exception hoặc Failure)
class EisenhowerError extends EisenhowerState {
  final String message;

  const EisenhowerError({required this.message});

  @override
  List<Object?> get props => [message];
}
