import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/app_router.dart';

import '../../features/eisenhower_matrix/presentation/bloc/eisenhower_bloc.dart';
import '../../features/eisenhower_matrix/presentation/bloc/eisenhower_event.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_event.dart';

import '../../core/di/injection_container.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// ============================================================
// SPLASH SCREEN
// ============================================================
// Hiển thị logo khi mới mở app, đồng thời thực hiện các tác vụ
// khởi tạo nền (Load Hive DB, setup DI, load cấu hình Setting)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    // Kích hoạt animation Logo
    Future.microtask(() => setState(() => _startAnimation = true));
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Gọi Bloc load data (Dữ liệu nền)
      if (mounted) {
        context.read<SettingsBloc>().add(const LoadSettings());
        context.read<EisenhowerBloc>().add(const LoadTasks());
      }

      // Giữ màn hình Splash tối thiểu 1.5 giây để tránh chớp nhoáng (nhìn chuyên nghiệp hơn)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 5. Điều hướng theo Hive Session / Onboarding
      final isCompleted = await sl<OnboardingLocalDataSource>().isOnboardingCompleted();
      final isLoggedIn = await sl<AuthRepository>().isLoggedIn();

      if (mounted) {
        if (!isCompleted) {
          // Lần đầu mở app -> Chuyển đến Onboarding
          Navigator.pushReplacementNamed(context, AppRouter.onboarding);
        } else if (!isLoggedIn) {
          // Lần sau mở app nếu chưa Login -> Chuyển đến AuthPage (Đăng nhập)
          Navigator.pushReplacementNamed(context, AppRouter.auth);
        } else {
          // Đã Login -> Vào Trang Chính
          Navigator.pushReplacementNamed(context, AppRouter.main);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo ứng dụng: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon cực lớn và sang trọng có hiệu ứng scale
            AnimatedScale(
              scale: _startAnimation ? 1.0 : 0.5,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutBack,
              child: Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/icons/app_icon_remove_bg.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.task_alt,
                      size: 80,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tên Ứng dụng
            const Text(
              'Smart Productivity',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              'BOOSTER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 64),

            // Vòng quay Loading
            if (!_hasError)
              const CircularProgressIndicator(color: Colors.white)
            else
              const Icon(Icons.error_outline, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }
}
