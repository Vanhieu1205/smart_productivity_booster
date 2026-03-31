import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:smart_productivity_booster/features/pomodoro_timer/presentation/bloc/pomodoro_timer_bloc.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/presentation/bloc/pomodoro_timer_event.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/presentation/bloc/pomodoro_timer_state.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/domain/entities/timer_type.dart';
import 'package:smart_productivity_booster/features/pomodoro_timer/data/services/sound_service.dart';
import 'package:smart_productivity_booster/core/utils/streak_service.dart';
import 'package:smart_productivity_booster/features/achievements/data/achievement_service.dart';

class MockSoundService extends Mock implements SoundService {}
class MockStreakService extends Mock implements StreakService {}
class MockAchievementService extends Mock implements AchievementService {}

void main() {
  late PomodoroTimerBloc bloc;
  late MockSoundService mockSoundService;
  late MockStreakService mockStreakService;
  late MockAchievementService mockAchievementService;
  final getIt = GetIt.instance;

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(MockSoundService());
  });

  setUp(() async {
    mockSoundService = MockSoundService();
    mockStreakService = MockStreakService();
    mockAchievementService = MockAchievementService();

    when(() => mockSoundService.playWorkComplete()).thenAnswer((_) async {});
    when(() => mockSoundService.playBreakComplete()).thenAnswer((_) async {});
    when(() => mockStreakService.update()).thenAnswer((_) async {});
    when(() => mockStreakService.getCurrentStreak()).thenReturn(0);

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

    bloc = PomodoroTimerBloc(
      soundService: mockSoundService,
      streakService: mockStreakService,
    );
  });

  tearDown(() {
    bloc.close();
    if (getIt.isRegistered<AchievementService>()) {
      getIt.unregister<AchievementService>();
    }
  });

  group('PomodoroTimerBloc Tests', () {
    test('1. state ban đầu là PomodoroInitial', () {
      expect(bloc.state, const PomodoroInitial());
    });

    test('2. emit PomodoroRunning khi StartTimer', () async {
      bloc.add(const StartTimer());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state, isA<PomodoroRunning>());
      final runningState = bloc.state as PomodoroRunning;
      expect(runningState.currentType, TimerType.work);
      expect(runningState.remainingSeconds, 25 * 60);
      expect(runningState.completedPomodoros, 0);
    });

    test('3. emit PomodoroPaused khi PauseTimer', () async {
      bloc.add(const StartTimer());
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const PauseTimer());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<PomodoroPaused>());
      final pausedState = bloc.state as PomodoroPaused;
      expect(pausedState.currentType, TimerType.work);
    });

    test('4. tiếp tục đếm khi ResumeTimer', () async {
      bloc.add(const StartTimer());
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const PauseTimer());
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const ResumeTimer());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<PomodoroRunning>());
    });

    test('8. emit PomodoroInitial khi ResetTimer', () async {
      bloc.add(const StartTimer());
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const ResetTimer());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, const PomodoroInitial());
    });
  });
}
