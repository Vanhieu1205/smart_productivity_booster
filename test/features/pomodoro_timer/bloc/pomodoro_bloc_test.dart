import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_productivity_booster/features/pomodoro_timer/presentation/bloc/pomodoro_timer_bloc.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/presentation/bloc/pomodoro_timer_event.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/presentation/bloc/pomodoro_timer_state.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/domain/entities/timer_type.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/data/services/sound_service.dart';
import 'package:smart_productivity_booster/core/utils/streak_service.dart';

// Mock SoundService cho unit test
class MockSoundService extends Mock implements SoundService {}

// Mock StreakService cho unit test
class MockStreakService extends Mock implements StreakService {}

// ===================================================================
// UNIT TEST CHO POMODORO BLOC
// ===================================================================
//
// [Chiến thuật Test Asynchronous Timer]
// 1. Nếu dùng fake_async: Sẽ bị conflict với bản chất trả về Future của `blocTest`.
// 2. Tối ưu hơn: Bloc đã được thiết kế tuân theo Event-Driven Architecture.
//    Nghĩa là Timer.periodic CHỈ đơn giản là bắn ra `TimerTick(n)`.
//    Do đó, để kiểm thử logic xử lý hết giờ, ta chỉ cần giả lập hành động
//    bắn event `TimerTick(remainingSeconds: 0)` thẳng vào Bloc mà không cần đợi 25 phút.
//
// Cách này vừa nhanh gọn (chạy < 0.1s), vừa cô lập được logic tính toán phase.

void main() {
  late PomodoroTimerBloc bloc;
  late MockSoundService mockSoundService;
  late MockStreakService mockStreakService;

  setUpAll(() {
    // Đăng ký fallback value cho MockSoundService để tránh lỗi khi mock không stub
    registerFallbackValue(MockSoundService());
  });

  setUp(() {
    mockSoundService = MockSoundService();
    mockStreakService = MockStreakService();
    // Stub các phương thức async để tránh lỗi 'Null is not a subtype of Future<void>'
    when(() => mockSoundService.playWorkComplete()).thenAnswer((_) async {});
    when(() => mockSoundService.playBreakComplete()).thenAnswer((_) async {});
    // Stub streak update
    when(() => mockStreakService.update()).thenAnswer((_) async {});
    bloc = PomodoroTimerBloc(
      soundService: mockSoundService,
      streakService: mockStreakService,
    );
  });

  tearDown(() {
    // Đảm bảo đóng BLoC để cancel Timer.periodic đang chạy ngầm nếu có StartTimer
    bloc.close();
  });

  group('PomodoroTimerBloc Tests', () {
    // TEST 1: State ban đầu
    test('1. state ban đầu là PomodoroInitial', () {
      expect(bloc.state, const PomodoroInitial());
    });

    // TEST 2: Start Timer
    blocTest<PomodoroTimerBloc, PomodoroState>(
      '2. emit PomodoroRunning khi StartTimer',
      build: () => bloc,
      act: (bloc) => bloc.add(const StartTimer()),
      expect: () => [
        const PomodoroRunning(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60, // 25 phút
          completedPomodoros: 0,
          currentStreak: 0,
          linkedTaskId: null,
        ),
      ],
    );

    // TEST 3: Pause Timer
    blocTest<PomodoroTimerBloc, PomodoroState>(
      '3. emit PomodoroPaused khi PauseTimer',
      build: () => bloc,
      // Hành động: Start -> Chờ 1 chút hoặc Pause ngay
      act: (bloc) {
        bloc.add(const StartTimer());
        bloc.add(const PauseTimer());
      },
      expect: () => [
        const PomodoroRunning(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
          linkedTaskId: null,
        ),
        const PomodoroPaused(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
          linkedTaskId: null,
        ),
      ],
    );

    // TEST 4: Resume Timer
    blocTest<PomodoroTimerBloc, PomodoroState>(
      '4. tiếp tục đếm khi ResumeTimer',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const StartTimer());
        bloc.add(const PauseTimer());
        bloc.add(const ResumeTimer());
      },
      expect: () => [
        const PomodoroRunning(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
        ),
        const PomodoroPaused(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
        ),
        const PomodoroRunning(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
        ),
      ],
    );

    // TEST 5 & 6: Chuyển Phase sang Short Break
    blocTest<PomodoroTimerBloc, PomodoroState>(
      '5 & 6. emit PomodoroCompleted, tăng completedPomodoros, chuyển sang shortBreak khi timer về 0',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const StartTimer());
        // Giả lập timer chạy đến 0 giây
        bloc.add(const TimerTick(remainingSeconds: 0));
      },
      expect: () => [
        const PomodoroRunning(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
        ),
        const PomodoroCompleted(
          completedType: TimerType.work,
          nextType: TimerType.shortBreak,
          completedPomodoros: 1, // Tăng thêm 1
          currentStreak: 1, // Streak cũng tăng lên 1
        ),
      ],
    );

    // TEST 7: Long Break sau 4 pomodoros
    blocTest<PomodoroTimerBloc, PomodoroState>(
      '7. chuyển sang longBreak sau 4 pomodoros',
      build: () => PomodoroTimerBloc(
        soundService: mockSoundService,
        streakService: mockStreakService,
      ),
      act: (bloc) {
        bloc.add(const StartTimer());
        // Lặp 4 lần xong work để đạt longBreak
        for (int i = 0; i < 4; i++) {
          bloc.add(const TimerTick(remainingSeconds: 0)); // Xong Work
          bloc.add(const TimerTick(remainingSeconds: 0)); // Bỏ qua Break
        }
      },
      skip: 7, // Bỏ qua 7 states đầu, lấy PomodoroCompleted cuối + state work tiếp theo
      expect: () => [
        const PomodoroCompleted(
          completedType: TimerType.work,
          nextType: TimerType.longBreak,
          completedPomodoros: 4,
          currentStreak: 4,
        ),
        const PomodoroCompleted(
          completedType: TimerType.longBreak,
          nextType: TimerType.work,
          completedPomodoros: 4,
          currentStreak: 0, // Streak reset sau longBreak
        ),
      ],
    );

    // TEST 8: Reset Timer
    blocTest<PomodoroTimerBloc, PomodoroState>(
      '8. emit PomodoroInitial khi ResetTimer',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const StartTimer());
        bloc.add(const TimerTick(remainingSeconds: 15 * 60)); // Giả lập chạy 10 phút
        bloc.add(const ResetTimer());
      },
      expect: () => [
        const PomodoroRunning(
          currentType: TimerType.work,
          remainingSeconds: 25 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
        ),
        const PomodoroRunning(
          currentType: TimerType.work,
          remainingSeconds: 15 * 60,
          completedPomodoros: 0,
          currentStreak: 0,
        ),
        const PomodoroInitial(),
      ],
    );
  });
}
