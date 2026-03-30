import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_router.dart';
import '../../data/datasources/onboarding_local_datasource.dart';

// ============================================================
// ONBOARDING PAGE – Màn hình giới thiệu ứng dụng
// ============================================================
// Hiển thị 3 trang giới thiệu tính năng với animation cho icon và dot indicator.

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  // PageController để điều khiển PageView và lắng nghe sự thay đổi trang
  late PageController _pageController;

  // Trang hiện tại đang được hiển thị
  int _currentPage = 0;

  // AnimationController cho icon của mỗi trang (scale 0.5 -> 1.0)
  late AnimationController _iconAnimController;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Thiết lập AnimationController cho icon với duration 500ms
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Animation scale từ 0.5 đến 1.0 với Curves.easeOutBack để có hiệu ứng bounce nhẹ
    _iconScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.easeOutBack),
    );

    // Thêm listener để detect khi trang thay đổi
    _pageController.addListener(_onPageChanged);

    // Chạy animation ban đầu
    _iconAnimController.forward();
  }

  // Hàm lắng nghe sự thay đổi của PageView
  void _onPageChanged() {
    // Tính toán trang hiện tại dựa trên vị trí scroll
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      // Reset và chạy lại animation cho icon trang mới
      _iconAnimController.reset();
      _iconAnimController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _iconAnimController.dispose();
    super.dispose();
  }

  // Hoàn thành onboarding và chuyển sang trang Auth
  Future<void> _completeOnboarding() async {
    await sl<OnboardingLocalDataSource>().setOnboardingCompleted();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.auth);
    }
  }

  // Dữ liệu 3 trang onboarding với icon, màu sắc, tiêu đề, mô tả
  final List<Map<String, dynamic>> _pagesData = [
    {
      'icon': Icons.grid_view_rounded,
      'color': Colors.red,
      'title': 'Ưu tiên thông minh',
      'description': 'Sắp xếp công việc theo mức độ quan trọng và khẩn cấp với Ma trận Eisenhower.',
    },
    {
      'icon': Icons.timer_rounded,
      'color': Colors.orange,
      'title': 'Tập trung sâu hơn',
      'description': 'Sử dụng kỹ thuật Pomodoro 25 phút giúp duy trì sự tập trung cao độ.',
    },
    {
      'icon': Icons.insights_rounded,
      'color': Colors.blue,
      'title': 'Theo dõi tiến độ',
      'description': 'Xem thống kê chi tiết theo ngày, tuần, tháng để đánh giá hiệu suất làm việc.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Nút "Bỏ qua" ở góc trên phải
          TextButton(
            onPressed: () => _completeOnboarding(),
            child: Text(
              'Bỏ qua',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pagesData.length,
                itemBuilder: (context, index) {
                  final data = _pagesData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon với animation scale từ 0.5 -> 1.0
                        ScaleTransition(
                          scale: _iconScaleAnimation,
                          child: Icon(
                            data['icon'] as IconData,
                            size: 100,
                            color: data['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          data['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          data['description'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot Indicator với animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicator - mở rộng khi active, thu nhỏ khi inactive
                  Row(
                    children: List.generate(
                      _pagesData.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Nút hành động
                  if (_currentPage == _pagesData.length - 1)
                    // Trang cuối: nút lớn "Bắt đầu ngay!" với icon mũi tên
                    ElevatedButton.icon(
                      onPressed: () => _completeOnboarding(),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Bắt đầu ngay!'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    // Trang khác: nút "Tiếp theo"
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Tiếp theo'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
