import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── Localization ───────────────────────────────────────────────────────────────
import 'l10n/app_localizations.dart';

// ── Dependency Injection ──────────────────────────────────────────────────────
import 'core/di/injection_container.dart' as di;

// ── Theme ─────────────────────────────────────────────────────────────────────
import 'core/theme/app_theme.dart';

// ── Utils / Services ──────────────────────────────────────────────────────────
import 'core/utils/hive_service.dart';
import 'core/utils/app_lifecycle_observer.dart';

// ── Navigation ────────────────────────────────────────────────────────────────
import 'core/navigation/app_router.dart';

// ── BLoCs ─────────────────────────────────────────────────────────────────────
import 'features/eisenhower_matrix/presentation/bloc/eisenhower_bloc.dart';
import 'features/eisenhower_matrix/presentation/bloc/eisenhower_event.dart';
import 'features/pomodoro_timer/presentation/bloc/pomodoro_timer_bloc.dart';
import 'features/statistics/presentation/bloc/statistics_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

// ── Hive Models (TypeAdapters) ─────────────────────────────────────────────
import 'features/eisenhower_matrix/data/models/task_model.dart';
import 'features/eisenhower_matrix/data/models/sub_task_model.dart';
import 'features/pomodoro_timer/data/models/pomodoro_session_model.dart';
import 'features/settings/data/models/settings_model.dart';
import 'features/auth/data/models/user_model.dart';

/// Global key để truy cập NavigatorState từ bất kỳ đâu trong app
/// Dùng cho AchievementPopup hiển thị overlay trên toàn app
final GlobalKey<NavigatorState> achievementNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Đảm bảo Flutter engine đã sẵn sàng trước khi gọi native code
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Khởi tạo Hive ──────────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── 2. Đăng ký TypeAdapters ─────────────────────────────────────────────
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PomodoroSessionModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SettingsModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(UserModelAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SubTaskModelAdapter());

  // ── 3. Khởi tạo tập trung Toàn Bộ Hive Boxes (Chống mất dữ liệu) ────────
  await HiveService.openAllBoxes();

  // ── 4. Bảo vệ Hive DB bằng AppLifecycleObserver (Khi app xuống nền/đóng) ─
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());

  // ── 5. Khởi tạo toàn bộ Dependency Injection ──────────────────────────────
  // Hàm di.init() giờ đây không cần await các Box cục bộ nữa mà chỉ load class.
  await di.init();

  // Load Settings ngay khi app vừa khởi động
  di.sl<SettingsBloc>().add(const LoadSettings());

  runApp(const SmartProductivityApp());
}

/// Root widget của ứng dụng.
/// Chỉ chịu trách nhiệm cung cấp BLoCs và MaterialApp.
class SmartProductivityApp extends StatelessWidget {
  const SmartProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // ── Đăng ký tất cả BLoCs vào widget tree ────────────────────────────
      // sl<T>() lấy instance từ GetIt service locator
      providers: [
        // EisenhowerBloc: factory → instance mới mỗi lần tạo
        BlocProvider<EisenhowerBloc>(
          create: (_) =>
              di.sl<EisenhowerBloc>()..add(const LoadTasks()),
          // Tự động load tasks khi khởi động
        ),

        // PomodoroTimerBloc: factory → quản lý Timer nội bộ
        BlocProvider<PomodoroTimerBloc>(
          create: (_) => di.sl<PomodoroTimerBloc>(),
        ),

        // StatisticsBloc: factory → tính toán khi được yêu cầu
        BlocProvider<StatisticsBloc>(
          create: (_) => di.sl<StatisticsBloc>(),
        ),

        // SettingsBloc: singleton → toàn app dùng chung 1 instance
        // Chúng ta sử dụng .value vì Bloc đã được khởi tạo và gửi event LoadSettings ở hàm main
        BlocProvider<SettingsBloc>.value(
          value: di.sl<SettingsBloc>(),
        ),

        // AuthBloc: global state cho xác thực (đăng nhập, đăng xuất, check trạng thái)
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

/// Widget nội bộ lắng nghe SettingsBloc để đổi theme và locale động.
/// Tách riêng khỏi SmartProductivityApp để tránh rebuild toàn bộ BlocProvider tree.
class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    // BlocBuilder lắng nghe SettingsBloc để cập nhật theme & locale
    return BlocBuilder<SettingsBloc, SettingsState>(
      // Chỉ rebuild khi isDarkMode hoặc languageCode thay đổi
      buildWhen: (prev, curr) {
        if (prev is SettingsLoaded && curr is SettingsLoaded) {
          return prev.isDarkMode != curr.isDarkMode ||
              prev.languageCode != curr.languageCode;
        }
        return true;
      },
      builder: (context, settingsState) {
        // Đọc cài đặt hiện tại (mặc định nếu chưa load xong)
        final bool isDark =
            settingsState is SettingsLoaded && settingsState.isDarkMode;

        return MaterialApp(
          navigatorKey: achievementNavigatorKey,
          title: 'Smart Productivity Booster',
          debugShowCheckedModeBanner: false,

          // ── Localization ────────────────────────────────────────────
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi'), // Tiếng Việt (mặc định)
            Locale('en'), // English
          ],
          // GIẢI THÍCH:
          // Tại sao locale lại phải đặt vào ở MaterialApp chứ không phải rải rác ở các widget con?
          // Đó là vì thuộc tính `locale` của MaterialApp đóng vai trò như là "nguồn chân lý" (source of truth) cho ngôn ngữ của toàn app.
          // Khi locale ở MaterialApp thay đổi, Flutter sẽ tự động kích hoạt rebuild lại toàn bộ widget tree từ gốc rễ,
          // nhờ vậy tất cả các đoạn text dùng l10n (AppLocalizations.of(context)) ở mọi màn hình con đều được tự động cập nhật ngôn ngữ mới một cách đồng bộ.
          // Nếu gọi hoặc gán locale ở từng widget con, app sẽ bị phân mảnh, không thể đồng nhất hoặc cần rebuild thủ công từng cái widget.
          locale: settingsState is SettingsLoaded ? Locale(settingsState.languageCode) : const Locale('vi'),

          // ── Theme động theo SettingsBloc ────────────────────────────
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // ── Màn hình chính & Route ──────────────────────────────────────────
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
