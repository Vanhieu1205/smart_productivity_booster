import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:smart_productivity_booster/core/usecases/usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/entities/quadrant_type.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/entities/task_entity.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/add_task_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/delete_task_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/get_all_tasks_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/move_task_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/update_task_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/presentation/bloc/eisenhower_bloc.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/presentation/bloc/eisenhower_event.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/presentation/bloc/eisenhower_state.dart';
import 'package:smart_productivity_booster/features/achievements/data/achievement_service.dart';

class MockGetAllTasksUseCase extends Mock implements GetAllTasksUseCase {}
class MockAddTaskUseCase extends Mock implements AddTaskUseCase {}
class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}
class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}
class MockMoveTaskUseCase extends Mock implements MoveTaskUseCase {}
class MockAchievementService extends Mock implements AchievementService {}

class FakeTaskEntity extends Fake implements TaskEntity {}
class FakeNoParams extends Fake implements NoParams {}
class FakeAddTaskParams extends Fake implements AddTaskParams {}

void main() {
  late EisenhowerBloc bloc;
  late MockGetAllTasksUseCase mockGetAllTasksUseCase;
  late MockAddTaskUseCase mockAddTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late MockMoveTaskUseCase mockMoveTaskUseCase;
  late MockAchievementService mockAchievementService;
  final getIt = GetIt.instance;

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeAddTaskParams());
    registerFallbackValue('fallback_string');
  });

  setUp(() {
    mockGetAllTasksUseCase = MockGetAllTasksUseCase();
    mockAddTaskUseCase = MockAddTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    mockMoveTaskUseCase = MockMoveTaskUseCase();
    mockAchievementService = MockAchievementService();

    when(() => mockAchievementService.checkAndUnlock(
      totalTasks: any(named: 'totalTasks'),
      totalPomodoros: any(named: 'totalPomodoros'),
      streak: any(named: 'streak'),
      todayPomos: any(named: 'todayPomos'),
      usedAll4: any(named: 'usedAll4'),
      hour: any(named: 'hour'),
    )).thenReturn([]);

    if (getIt.isRegistered<AchievementService>()) {
      getIt.unregister<AchievementService>();
    }
    getIt.registerLazySingleton<AchievementService>(() => mockAchievementService);

    bloc = EisenhowerBloc(
      getAllTasksUseCase: mockGetAllTasksUseCase,
      addTaskUseCase: mockAddTaskUseCase,
      updateTaskUseCase: mockUpdateTaskUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
      moveTaskUseCase: mockMoveTaskUseCase,
    );
  });

  tearDown(() {
    bloc.close();
    if (getIt.isRegistered<AchievementService>()) {
      getIt.unregister<AchievementService>();
    }
  });

  final sampleTask = TaskEntity(
    id: '1',
    title: 'Test Task',
    quadrant: QuadrantType.doIt,
    isCompleted: false,
    createdAt: DateTime.now(),
  );

  Map<QuadrantType, List<TaskEntity>> buildEmptyQuadrants() => {
        QuadrantType.doIt: [],
        QuadrantType.scheduleIt: [],
        QuadrantType.delegateIt: [],
        QuadrantType.eliminateIt: [],
      };

  group('EisenhowerBloc Tests', () {
    test('State lúc khởi tạo ban đầu phải là EisenhowerInitial', () {
      expect(bloc.state, const EisenhowerInitial());
    });

    test('emit [Loading, Loaded] khi LoadTasks thành công', () async {
      when(() => mockGetAllTasksUseCase(any())).thenAnswer((_) async => [sampleTask]);

      bloc.add(const LoadTasks());

      await Future.delayed(const Duration(milliseconds: 200));

      final expectedMap = buildEmptyQuadrants();
      expectedMap[QuadrantType.doIt] = [sampleTask];

      expect(bloc.state, EisenhowerLoaded(tasksByQuadrant: expectedMap));

      verify(() => mockGetAllTasksUseCase(any())).called(1);
    });

    test('emit [Loading, Loaded] với task mới khi AddTask', () async {
      when(() => mockAddTaskUseCase(any())).thenAnswer((_) async {});
      when(() => mockGetAllTasksUseCase(any())).thenAnswer((_) async => [sampleTask]);

      bloc.add(AddTask(sampleTask));

      await Future.delayed(const Duration(milliseconds: 300));

      verify(() => mockAddTaskUseCase(any())).called(1);
      verify(() => mockGetAllTasksUseCase(any())).called(1);
    });

    test('emit [Loading, Loaded] không có task khi DeleteTask', () async {
      when(() => mockDeleteTaskUseCase(any())).thenAnswer((_) async {});
      when(() => mockGetAllTasksUseCase(any())).thenAnswer((_) async => []);

      bloc.add(DeleteTask('1'));

      await Future.delayed(const Duration(milliseconds: 300));

      verify(() => mockDeleteTaskUseCase(any())).called(1);
      verify(() => mockGetAllTasksUseCase(any())).called(1);
    });

    test('emit [Loading, Error] khi LoadTasks thất bại', () async {
      when(() => mockGetAllTasksUseCase(any())).thenThrow(Exception('Hive Box is closed'));

      bloc.add(const LoadTasks());

      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state, const EisenhowerError(message: 'Exception: Hive Box is closed'));

      verify(() => mockGetAllTasksUseCase(any())).called(1);
    });
  });
}
