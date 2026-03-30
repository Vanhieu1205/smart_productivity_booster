import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';
import '../../../achievements/data/achievement_service.dart';
import '../../../achievements/presentation/widgets/achievement_popup.dart';
import '../../data/models/task_model.dart';

// Các UseCases đã được tạo
import '../../domain/usecases/get_all_tasks_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/move_task_usecase.dart';

// Kế thừa Event và State
import 'eisenhower_event.dart';
import 'eisenhower_state.dart';

// ============================================================
// EISENHOWER BLOC - Presentation Layer
// ============================================================
// 
// [Clean Architecture] Tại sao lại cần BLoC?
// 1. Quản lý trạng thái thông qua các luồng sư kiện (Stream of Events & States).
// 2. Trung gian kết nối giữa UI và UseCases: UI phát Event -> BLoC gọi UseCase -> BLoC trả State cho UI.
// 3. Sử dụng flutter_bloc ^8 mới nhất: dùng hàm on<Event>() và emit() không đồng bộ sạch sẽ, dễ scale.

class EisenhowerBloc extends Bloc<EisenhowerEvent, EisenhowerState> {
  // Inject UseCases thay vì Repository
  final GetAllTasksUseCase getAllTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final MoveTaskUseCase moveTaskUseCase;

  EisenhowerBloc({
    required this.getAllTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.moveTaskUseCase,
  }) : super(const EisenhowerInitial()) {
    // Đăng ký các hàm xử lý Event
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<MoveTask>(_onMoveTask);
    on<ToggleComplete>(_onToggleComplete);
  }

  /// Hàm LoadTasks sẽ gọi UseCase để tải tất cả tasks rồi nhóm chúng lại thành Map
  Future<void> _onLoadTasks(LoadTasks event, Emitter<EisenhowerState> emit) async {
    // Báo hiệu UI hiển thị loading spinner
    emit(const EisenhowerLoading());
    try {
      // Gọi UseCase với NoParams
      final List<TaskEntity> tasks = await getAllTasksUseCase(const NoParams());
      
      // Tạo khung Map rỗng cho 4 khoảng phần tư, nếu chưa có thì gán List rỗng
      final Map<QuadrantType, List<TaskEntity>> tasksByQuadrant = {
        QuadrantType.doIt: [],
        QuadrantType.scheduleIt: [],
        QuadrantType.delegateIt: [],
        QuadrantType.eliminateIt: [],
      };

      // Nhóm Task theo Quadrant
      for (final task in tasks) {
        tasksByQuadrant[task.quadrant]?.add(task);
      }
      
      // Emit trạng thái thành công
      emit(EisenhowerLoaded(tasksByQuadrant: tasksByQuadrant));
    } catch (e) {
      // Emit trạng thái có lỗi nếu UseCase ném Exception
      emit(EisenhowerError(message: e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<EisenhowerState> emit) async {
    try {
      await addTaskUseCase(AddTaskParams(task: event.task));
      // Tải lại tác vụ trên màn hình
      add(const LoadTasks());
    } catch (e) {
      emit(EisenhowerError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<EisenhowerState> emit) async {
    try {
      await updateTaskUseCase(UpdateTaskParams(task: event.task));
      // Tải lại tác vụ trên màn hình
      add(const LoadTasks());
    } catch (e) {
      emit(EisenhowerError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<EisenhowerState> emit) async {
    try {
      await deleteTaskUseCase(event.taskId);
      // Tải lại tác vụ
      add(const LoadTasks());
    } catch (e) {
      emit(EisenhowerError(message: e.toString()));
    }
  }

  Future<void> _onMoveTask(MoveTask event, Emitter<EisenhowerState> emit) async {
    try {
      await moveTaskUseCase(MoveTaskParams(taskId: event.taskId, newQuadrant: event.newQuadrant));
      // Tải lại tác vụ
      add(const LoadTasks());
    } catch (e) {
      emit(EisenhowerError(message: e.toString()));
    }
  }

  Future<void> _onToggleComplete(ToggleComplete event, Emitter<EisenhowerState> emit) async {
    try {
      // Tạo ra bản sao để đảo ngược giá trị hiện tại
      final updatedTask = event.task.copyWith(isCompleted: !event.task.isCompleted);

      await updateTaskUseCase(UpdateTaskParams(task: updatedTask));

      // Nếu task được hoàn thành → kiểm tra achievements
      if (updatedTask.isCompleted) {
        _checkTaskAchievements();
      }

      // Tải lại tác vụ
      add(const LoadTasks());
    } catch (e) {
      emit(EisenhowerError(message: e.toString()));
    }
  }

  /// Kiểm tra và unlock achievements liên quan đến task
  void _checkTaskAchievements() {
    final achievementService = sl<AchievementService>();

    // Đếm tổng số task đã hoàn thành từ Hive
    final taskBox = Hive.box<TaskModel>('tasks_box');
    final totalCompletedTasks = taskBox.values
        .where((task) => task.isCompleted)
        .length;

    // Kiểm tra điều kiện và lấy achievements mới unlock
    final newlyUnlocked = achievementService.checkAndUnlock(
      totalTasks: totalCompletedTasks,
      totalPomodoros: 0, // Sẽ được cập nhật từ Pomodoro
      streak: 0,        // Sẽ được cập nhật từ StreakService
      todayPomos: 0,
      usedAll4: false,
      hour: DateTime.now().hour,
    );

    // Hiển thị popup cho từng achievement mới
    for (final achievement in newlyUnlocked) {
      AchievementPopup.show(achievement);
    }
  }
}
