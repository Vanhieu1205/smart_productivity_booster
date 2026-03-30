import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_productivity_booster/core/usecases/usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/entities/quadrant_type.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/entities/task_entity.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/repositories/task_repository.dart';

import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/add_task_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/delete_task_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/get_all_tasks_usecase.dart';
import 'package:smart_productivity_booster/features/eisenhower_matrix/domain/usecases/move_task_usecase.dart';

// ===================================================================
// UNIT TEST CHO CÁC USECASES (EISENHOWER MATRIX)
// ===================================================================
//
// [Kiến trúc Clean Architecture]
// Tính độc lập: UseCase là cầu nối trung gian giữa BLoC và Repository.
// Chúng ta viết Unit Test để chứng minh rằng UseCase đã bóc tách dữ liệu
// từ Params và gọi chính xác hàm tương ứng dưới Repository.
// Tại sao phải giả lập (Mock) Repository?
// -> Thay vì gọi Database thật (Hive), ta dùng bản sao giả để kiểm soát kết quả trả về.

// Tạo Mock Class cho Repository bằng Mocktail (tạo ra bảng sao y hệt bản gốc)
class MockTaskRepository extends Mock implements TaskRepository {}

// Tạo Fake Class cho việc đăng ký Fallback của Mocktail
class FakeTaskEntity extends Fake implements TaskEntity {}

void main() {
  setUpAll(() {
    // Đăng ký giá trị phòng hờ (fallback) khi sử dụng hàm any() cho các Custom Object
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(QuadrantType.doIt);
  });

  late MockTaskRepository mockRepository;

  late GetAllTasksUseCase getAllTasksUseCase;
  late AddTaskUseCase addTaskUseCase;
  late DeleteTaskUseCase deleteTaskUseCase;
  late MoveTaskUseCase moveTaskUseCase;

  // Setup đồ thị trước khi chạy test, tạo mới mọi biến
  setUp(() {
    mockRepository = MockTaskRepository();
    getAllTasksUseCase = GetAllTasksUseCase(mockRepository);
    addTaskUseCase = AddTaskUseCase(mockRepository);
    deleteTaskUseCase = DeleteTaskUseCase(mockRepository);
    moveTaskUseCase = MoveTaskUseCase(mockRepository);
  });

  // Một Sample Task dùng chung cho các bộ kiểm thử
  final sampleTask = TaskEntity(
    id: '123',
    title: 'Code Unit Test cho app',
    quadrant: QuadrantType.doIt,
    isCompleted: false,
    createdAt: DateTime(2023, 1, 1), // Mốc thời gian cố định dễ test
  );

  group('GetAllTasksUseCase Tests', () {
    test('Nên trả về List<TaskEntity> lấy từ repository khi thành công', () async {
      // Dưới đây là kiến trúc kinh điển AAA (Arrange - Act - Assert)

      // 1. Arrange (Chuẩn bị)
      // Dành thời gian để dựng sân khấu:
      // Yêu cầu Mocktail khi bị ai đó gọi 'mockRepository.getAllTasks()'
      // thì GIẢ LẬP trả về list chứa 1 [sampleTask].
      when(() => mockRepository.getAllTasks()).thenAnswer((_) async => [sampleTask]);

      // 2. Act (Hành động)
      // Thực thi đoạn code cần kiểm thử (gọi UseCase).
      final result = await getAllTasksUseCase(const NoParams());

      // 3. Assert (Xác nhận kết quả)
      // Khẳng định những gì ta mong đợi: Kết quả trả về giống nội dung giả lập.
      expect(result, [sampleTask]);
      // Xác nhận hàm getAllTasks() của repository THẬT SỰ ĐƯỢC GỌI đúng 1 lần.
      verify(() => mockRepository.getAllTasks()).called(1);
      // Đảm bảo không còn hàm nào khác của mockRepository bị gọi dư thừa.
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('AddTaskUseCase Tests', () {
    test('Nên gọi repository.addTask() với parameter là TaskEntity', () async {
      // 1. Arrange
      // Giả lập hàm addTask chỉ trả về Future.value() thay vì chạy logic gì đó.
      when(() => mockRepository.addTask(any())).thenAnswer((_) async => Future.value());

      // 2. Act
      // Gọi UseCase. Nó sẽ bóc 'task' từ AddTaskParams rồi gọi cho Repository.
      await addTaskUseCase(AddTaskParams(task: sampleTask));

      // 3. Assert
      // Xác nhận hàm dưới Repository nhận được CHÍNH XÁC bản lỗi sampleTask chứ không phải dữ liệu sai.
      verify(() => mockRepository.addTask(sampleTask)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeleteTaskUseCase Tests', () {
    test('Nên gọi repository.deleteTask() với tham số taskId đúng', () async {
      // 1. Arrange
      when(() => mockRepository.deleteTask(any())).thenAnswer((_) async => Future.value());

      await deleteTaskUseCase('123');

      // 3. Assert
      verify(() => mockRepository.deleteTask('123')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('MoveTaskUseCase Tests', () {
    test('Nên gọi repository.moveTaskToQuadrant() với đúng tham số', () async {
      // 1. Arrange
      // Lấy dữ liệu mẫu ban đầu (doIt), mục tiêu kéo thả sang (delegateIt).
      final targetQuadrant = QuadrantType.delegateIt;

      // Nếu repository.moveTaskToQuadrant được truyền taskId="123" và quadrant="delegateIt"
      // Thì trả về Future completion.
      when(() => mockRepository.moveTaskToQuadrant(any(), any()))
          .thenAnswer((_) async => Future.value());

      // 2. Act
      await moveTaskUseCase(MoveTaskParams(
        taskId: '123',
        newQuadrant: targetQuadrant,
      ));

      // 3. Assert
      // Khẳng định hàm repository được UseCase truyền đúng 2 tham số rời rạc.
      verify(() => mockRepository.moveTaskToQuadrant('123', targetQuadrant)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
