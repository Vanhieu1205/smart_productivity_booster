// ============================================================
// DEPENDENCY INJECTION – Smart Productivity Booster
// Sử dụng get_it làm Service Locator.
// Quy ước: sl = service locator (GetIt.instance)
// Thứ tự đăng ký: DataSource → Repository → UseCase → Bloc
// ============================================================

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// ── Core ──────────────────────────────────────────────────────────────────────
import '../../core/utils/streak_service.dart';

// ── Feature: Auth ─────────────────────────────────────────────────────────────
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/update_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// ── Feature: Onboarding ──────────────────────────────────────────────────────
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';

// ── Feature: Eisenhower Matrix ────────────────────────────────────────────────
import '../../features/eisenhower_matrix/data/datasources/task_local_datasource.dart';
import '../../features/eisenhower_matrix/data/repositories/task_repository_impl.dart';
import '../../features/eisenhower_matrix/domain/repositories/task_repository.dart';
import '../../features/eisenhower_matrix/domain/usecases/get_all_tasks_usecase.dart';
import '../../features/eisenhower_matrix/domain/usecases/add_task_usecase.dart';
import '../../features/eisenhower_matrix/domain/usecases/update_task_usecase.dart';
import '../../features/eisenhower_matrix/domain/usecases/delete_task_usecase.dart';
import '../../features/eisenhower_matrix/domain/usecases/move_task_usecase.dart';
import '../../features/eisenhower_matrix/presentation/bloc/eisenhower_bloc.dart';

// ── Feature: Pomodoro Timer ───────────────────────────────────────────────────
import '../../features/pomodoro_timer/presentation/bloc/pomodoro_timer_bloc.dart';
import '../../features/pomodoro_timer/data/services/sound_service.dart';

// ── Feature: Statistics ───────────────────────────────────────────────────────
import '../../features/statistics/data/datasources/statistics_local_datasource.dart';
import '../../features/statistics/domain/usecases/get_weekly_stats_usecase.dart';
import '../../features/statistics/presentation/bloc/statistics_bloc.dart';

// ── Feature: Settings ─────────────────────────────────────────────────────────
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/services/backup_service.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/data/models/settings_model.dart';

// ── Feature: Achievements ────────────────────────────────────────────────────
import '../../features/achievements/data/achievement_service.dart';

// ── Hive Boxes (lazy getters để tránh race condition) ───────────────────────
import 'package:hive_flutter/hive_flutter.dart';

/// Lazy getter cho settings box - đảm bảo box đã được mở trước khi sử dụng
Box<SettingsModel> get _settingsBox => Hive.box<SettingsModel>('settings_box');

/// Global service locator – truy cập ở bất kỳ đâu trong app
final sl = GetIt.instance;

/// Hàm khởi tạo tất cả dependencies.
/// Gọi trong main() trước runApp().
Future<void> init() async {
  // ──────────────────────────────────────────────────────────────────────────
  // 1. MỞ HIVE BOX
  // Cần mở box trước khi đăng ký datasource vào sl
  // ──────────────────────────────────────────────────────────────────────────
  // TaskLocalDataSourceImpl sẽ tự động quản lý việc mở box khi cần thiết

  // ──────────────────────────────────────────────────────────────────────────
  // 1.25. FEATURE: AUTHENTICATION
  // ──────────────────────────────────────────────────────────────────────────
  _initAuth();

  // ──────────────────────────────────────────────────────────────────────────
  // 1.5. FEATURE: ONBOARDING
  // ──────────────────────────────────────────────────────────────────────────
  _initOnboarding();

  // ──────────────────────────────────────────────────────────────────────────
  // 2. FEATURE: EISENHOWER MATRIX
  // ──────────────────────────────────────────────────────────────────────────
  _initEisenhowerMatrix();

  // ──────────────────────────────────────────────────────────────────────────
  // 3. FEATURE: POMODORO TIMER
  // ──────────────────────────────────────────────────────────────────────────
  _initPomodoroTimer();

  // ──────────────────────────────────────────────────────────────────────────
  // 4. FEATURE: STATISTICS
  // ──────────────────────────────────────────────────────────────────────────
  _initStatistics();

  // ──────────────────────────────────────────────────────────────────────────
  // 5. FEATURE: SETTINGS
  // ──────────────────────────────────────────────────────────────────────────
  _initSettings();

  // ──────────────────────────────────────────────────────────────────────────
  // 6. FEATURE: ACHIEVEMENTS
  // ──────────────────────────────────────────────────────────────────────────
  _initAchievements();
}

// =============================================================================
// FEATURE: AUTHENTICATION
// =============================================================================
void _initAuth() {
  // ── Data Source ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // ── Repository ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  // ── Use Cases ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));

  // ── Bloc ───────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      updateUserUseCase: sl(),
    ),
  );
}

// =============================================================================
// FEATURE: ONBOARDING
// =============================================================================
void _initOnboarding() {
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(),
  );
}

// =============================================================================
// FEATURE: EISENHOWER MATRIX
// =============================================================================
void _initEisenhowerMatrix() {
  // ── Data Source ────────────────────────────────────────────────────────────
  // registerLazySingleton: chỉ khởi tạo khi lần đầu gọi sl<T>()
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(hive: Hive),
  );

  // ── Repository ─────────────────────────────────────────────────────────────
  // Đăng ký interface (abstract) → implementation cụ thể
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: sl()),
  );

  // ── Use Cases ──────────────────────────────────────────────────────────────
  // Mỗi UseCase là một singleton nhẹ, inject Repository vào
  sl.registerLazySingleton(() => GetAllTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => MoveTaskUseCase(sl()));

  // ── Bloc ───────────────────────────────────────────────────────────────────
  // registerFactory: tạo instance mới mỗi lần gọi sl<EisenhowerBloc>()
  // Phù hợp cho Bloc vì mỗi màn hình nên có instance riêng
  sl.registerFactory(
    () => EisenhowerBloc(
      getAllTasksUseCase: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      moveTaskUseCase: sl(),
    ),
  );
}

// =============================================================================
// FEATURE: POMODORO TIMER
// =============================================================================
void _initPomodoroTimer() {
  // Service âm thanh cho Pomodoro (singleton)
  sl.registerLazySingleton<SoundService>(() => SoundService());

  // registerFactory: PomodoroTimerBloc có Timer nội bộ,
  // dùng factory để tránh memory leak nếu tạo nhiều lần
  sl.registerFactory(() => PomodoroTimerBloc(
    soundService: sl(),
    streakService: sl(),
  ));
}

// =============================================================================
// FEATURE: STATISTICS
// =============================================================================
void _initStatistics() {
  // ── Data Source ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<StatisticsLocalDataSource>(
    () => StatisticsLocalDataSourceImpl(hive: Hive),
  );

  // ── Use Case ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetWeeklyStatsUseCase(sl()));

  // ── Bloc ───────────────────────────────────────────────────────────────────
  sl.registerFactory(() => StatisticsBloc(getWeeklyStats: sl()));
}

// =============================================================================
// FEATURE: SETTINGS
// =============================================================================
void _initSettings() {
  // ── Data Source ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(hive: Hive),
  );

  // ── Streak Service ────────────────────────────────────────────────────────
  // Singleton vì dùng chung Box<SettingsModel> đã được HiveService mở sẵn
  // Sử dụng lazy getter để tránh race condition khi khởi tạo
  sl.registerLazySingleton<StreakService>(
    () => StreakService(settingsBox: _settingsBox),
  );

  // ── Backup Service ──────────────────────────────────────────────────────
  // Singleton vì dùng chung để export/import dữ liệu
  sl.registerLazySingleton(() => BackupService());

  // ── Bloc ───────────────────────────────────────────────────────────────────
  // registerLazySingleton: Settings nên là singleton vì nhiều màn hình
  // cần đọc cùng một state cài đặt
  sl.registerLazySingleton(() => SettingsBloc(localDataSource: sl()));
}

// =============================================================================
// FEATURE: ACHIEVEMENTS
// =============================================================================
void _initAchievements() {
  // ── Achievement Service ───────────────────────────────────────────────────
  // Singleton vì achievement state cần được dùng chung toàn app
  sl.registerLazySingleton<AchievementService>(() => AchievementService());
}
