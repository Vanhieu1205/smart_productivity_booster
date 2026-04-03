import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_router.dart';
import '../../data/datasources/onboarding_local_datasource.dart';

// ============================================================
// ONBOARDING PAGE – Màn hình giới thiệu ứng dụng
// ============================================================
// Phong cách tối giản: nền trắng full màn hình.
// Hỗ trợ lướt ngang, bấm mũi tên trái/phải (hai bên ảnh), và nút Tiếp theo / Bắt đầu ngay!

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  static const Color _titleColor = Color(0xFF1A1A1A);
  static const Color _bodyColor = Color(0xFF6B7280);

  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _iconAnimController;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pageController.addListener(_onPageChanged);
    _iconAnimController.forward();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
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

  Future<void> _completeOnboarding() async {
    await sl<OnboardingLocalDataSource>().setOnboardingCompleted();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.auth);
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  final List<Map<String, dynamic>> _pagesData = [
    {
      'asset': 'assets/images/uutien1.png',
      'title': 'Ưu tiên thông minh',
      'description':
          'Sắp xếp công việc theo mức độ quan trọng và khẩn cấp với Ma trận Eisenhower.',
    },
    {
      'asset': 'assets/images/taptrung.png',
      'title': 'Tập trung sâu hơn',
      'description':
          'Sử dụng kỹ thuật Pomodoro 25 phút giúp duy trì sự tập trung cao độ.',
    },
    {
      'asset': 'assets/images/theodoi.png',
      'title': 'Theo dõi tiến độ',
      'description':
          'Xem thống kê chi tiết theo ngày, tuần, tháng để đánh giá hiệu suất làm việc.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh trên: nút Bỏ qua
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _completeOnboarding(),
                child: Text(
                  'Bỏ qua',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            // Nội dung chính
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pagesData.length,
                itemBuilder: (context, index) {
                  final data = _pagesData[index];
                  final isLast = index == _pagesData.length - 1;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hàng ảnh + mũi tên trái/phải ngang hàng
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Mũi tên trái
                              IconButton(
                                onPressed: _currentPage > 0
                                    ? () => _goToPage(_currentPage - 1)
                                    : null,
                                icon: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 36,
                                  color: _currentPage > 0
                                      ? primary
                                      : Colors.grey.shade300,
                                ),
                              ),

                              // Ảnh minh họa
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.6,
                                      height: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.6,
                                      child: index == _currentPage
                                          ? ScaleTransition(
                                              scale: _iconScaleAnimation,
                                              child: _OnboardingIllustration(
                                                asset: data['asset'] as String,
                                              ),
                                            )
                                          : _OnboardingIllustration(
                                              asset: data['asset'] as String,
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              // Mũi tên phải
                              IconButton(
                                onPressed: isLast
                                    ? () => _completeOnboarding()
                                    : () => _goToPage(_currentPage + 1),
                                icon: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 36,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tiêu đề
                        Text(
                          data['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _titleColor,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mô tả
                        Text(
                          data['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: _bodyColor,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Dot indicator + nút Tiếp theo / Bắt đầu ngay!
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                _pagesData.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 280),
                                  margin: const EdgeInsets.only(right: 6),
                                  width: i == _currentPage ? 22 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: i == _currentPage
                                        ? primary
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isLast)
                              ElevatedButton.icon(
                                onPressed: () => _completeOnboarding(),
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                                label: const Text('Bắt đầu ngay!'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () => _goToPage(_currentPage + 1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Tiếp theo'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  final String asset;

  const _OnboardingIllustration({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image_not_supported_outlined,
          size: 72,
          color: Colors.grey.shade400,
        );
      },
    );
  }
}
