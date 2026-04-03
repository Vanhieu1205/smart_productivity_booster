import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../presentation/navigation/main_navigation.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/achievements/presentation/pages/achievements_page.dart';

// ============================================================
// APP ROUTER – Navigation Layer
// ============================================================
// Định nghĩa tập trung các Named Routes cho ứng dụng.
// Giúp việc chuyển trang dễ quản lý hơn, không bị hard-code string rải rác.

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth'; // Giữ nguyên '/auth' làm route Đăng nhập
  static const String register = '/register';
  static const String profile = '/profile';
  static const String main = '/main';
  static const String achievements = '/achievements';

  // Hàm sinh Route dựa trên settings name
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case achievements:
        return MaterialPageRoute(builder: (_) => const AchievementsPage());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      default:
        // Scaffold hiển thị lỗi nếu route không tồn tại (tránh crash)
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Lỗi Route')),
            body: Center(child: Text('Không tìm thấy đường dẫn: ${settings.name}')),
          ),
        );
    }
  }
}
