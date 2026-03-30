import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

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

// ===================================================================
// UNIT TEST CHO EISENHOWER BLOC
// ===================================================================
// Tại sao Unit Test quan trọng cho BLoC?
// 1. Tính độc lập: Kiểm chứng logic nghiệp vụ cốt lõi mà không cần build UI -> Nhanh, nhẹ.
// 2. Chống hồi quy (Regression Check): Đảm bảo khi bạn sửa lỗi A không làm hỏng tính năng B.
// 3. Tư duy State/Event: bloc_test cung cấp luồng "Given -> When -> Then" cưc kỳ tường minh.
// Nhờ mock các UseCase, ta hoàn toàn cắt dứt khỏi database (Hive) hay API.

// Khai báo Mock Class bằng Mocktail
class MockGetAllTasksUseCase extends Mock implements GetAllTasksUseCase {}
class MockAddTaskUseCase extends Mock implements AddTaskUseCase {}
class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}
class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}
class MockMoveTaskUseCase extends Mock implements MoveTaskUseCase {}

// Fallback value cho Mocktail (ví dụ truyền tham số là class Model, nó cần biết Fake Instance)
class FakeTaskEntity extends Fake implements TaskEntity {}
class FakeNoParams extends Fake implements NoParams {}

void main() {
  late EisenhowerBloc bloc;
  late MockGetAllTasksUseCase mockGetAllTasksUseCase;
  late MockAddTaskUseCase mockAddTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late MockMoveTaskUseCase mockMoveTaskUseCase;

  // Setup đồ thị khởi tạo trước mỗi hàm test
  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetAllTasksUseCase = MockGetAllTasksUseCase();
    mockAddTaskUseCase = MockAddTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    mockMoveTaskUseCase = MockMoveTaskUseCase();

    bloc = EisenhowerBloc(
      getAllTasksUseCase: mockGetAllTasksUseCase,
      addTaskUseCase: mockAddTaskUseCase,
      updateTaskUseCase: mockUpdateTaskUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
      moveTaskUseCase: mockMoveTaskUseCase,
    );
  });

  // Dọn dẹp Bloc sau mỗi test để tránh tràn bộ nhớ (Memory Leak)
  tearDown(() {
    bloc.close();
  });

  final sampleTask = TaskEntity(
    id: '1',
    title: 'Test Task',
    quadrant: QuadrantType.doIt, // Góc phần tư "Làm Ngay"
    isCompleted: false,
    createdAt: DateTime.now(),
  );

  // Helper trả về khung dữ liệu chuẩn sau khi load task
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

    // TEST 1: Kiểm thử lộ trình lấy dữ liệu thành công
    blocTest<EisenhowerBloc, EisenhowerState>(
      'emit [Loading, Loaded] khi LoadTasks thành công',
      build: () {
        // Giả lập UseCase trả về 1 task
        when(() => mockGetAllTasksUseCase(any())).thenAnswer((_) async => [sampleTask]);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () {
        final expectedMap = buildEmptyQuadrants();
        expectedMap[QuadrantType.doIt] = [sampleTask]; // Add 1 task vào DoIt
        return [
          const EisenhowerLoading(),
          EisenhowerLoaded(tasksByQuadrant: expectedMap),
        ];
      },
      // Xác nhận xem UseCase có bị gọi đúng 1 lần duy nhất hay không
      verify: (_) {
        verify(() => mockGetAllTasksUseCase(any())).called(1);
      },
    );

    // TEST 2: Kiểm thử tính năng Thêm Task mới
    blocTest<EisenhowerBloc, EisenhowerState>(
      'emit [Loading, Loaded] với task mới khi AddTask',
      build: () {
        // Hành động Thêm (Add) không ném lỗi
        when(() => mockAddTaskUseCase(any())).thenAnswer((_) async => Future.value());
        // Sau khi Add thành công, BLoC tự động Load lại danh sách
        when(() => mockGetAllTasksUseCase(any())).thenAnswer((_) async => [sampleTask]);
        return bloc;
      },
      act: (bloc) => bloc.add(AddTask(sampleTask)),
      expect: () {
        final expectedMap = buildEmptyQuadrants();
        expectedMap[QuadrantType.doIt] = [sampleTask];
        return [
          const EisenhowerLoading(),
          EisenhowerLoaded(tasksByQuadrant: expectedMap),
        ];
      },
      verify: (_) {
        verify(() => mockAddTaskUseCase(any())).called(1);
        verify(() => mockGetAllTasksUseCase(any())).called(1);
      },
    );

    // TEST 3: Kiểm thử tính năng Xóa Task
    blocTest<EisenhowerBloc, EisenhowerState>(
      'emit [Loading, Loaded] không có task khi DeleteTask',
      build: () {
        // Giả lập API trả về List rỗng sau khi xóa
        when(() => mockDeleteTaskUseCase(any())).thenAnswer((_) async => Future.value());
        when(() => mockGetAllTasksUseCase(any())).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteTask('1')),
      expect: () {
        return [
          const EisenhowerLoading(),
          EisenhowerLoaded(tasksByQuadrant: buildEmptyQuadrants()), // Bản đồ rỗng
        ];
      },
      verify: (_) {
        verify(() => mockDeleteTaskUseCase(any())).called(1);
        verify(() => mockGetAllTasksUseCase(any())).called(1);
      },
    );

    // TEST 4: Kiểm thử tính năng Kéo thả Task (Move Task sang góc khác)
    final movedTask = sampleTask.copyWith(quadrant: QuadrantType.scheduleIt);

    blocTest<EisenhowerBloc, EisenhowerState>(
      'emit [Loading, Loaded] với task ở quadrant mới khi MoveTask',
      build: () {
        // Giả lập trả về task sau khi đã bị đổi sang góc mới
        when(() => mockMoveTaskUseCase(any())).thenAnswer((_) async => Future.value());
        when(() => mockGetAllTasksUseCase(any())).thenAnswer((_) async => [movedTask]);
        return bloc;
      },
      act: (bloc) => bloc.add(const MoveTask(taskId: '1', newQuadrant: QuadrantType.scheduleIt)),
      expect: () {
        final expectedMap = buildEmptyQuadrants();
        expectedMap[QuadrantType.scheduleIt] = [movedTask]; // Task hiện xuất hiện ở góc Schedule
        return [
          const EisenhowerLoading(),
          EisenhowerLoaded(tasksByQuadrant: expectedMap),
        ];
      },
      verify: (_) {
        verify(() => mockMoveTaskUseCase(any())).called(1);
        verify(() => mockGetAllTasksUseCase(any())).called(1);
      },
    );

    // TEST 5: Kiểm thử sự cố khi có lỗi xảy ra
    blocTest<EisenhowerBloc, EisenhowerState>(
      'emit [Loading, Error] khi LoadTasks thất bại',
      build: () {
        // Giả lập Database/Hive sập, ném Ngoại lệ
        when(() => mockGetAllTasksUseCase(any())).thenThrow(Exception('Hive Box is closed'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadTasks()),
      expect: () => [
        const EisenhowerLoading(),
        const EisenhowerError(message: 'Exception: Hive Box is closed'),
      ],
      verify: (_) {
        verify(() => mockGetAllTasksUseCase(any())).called(1);
      },
    );
  });
}
