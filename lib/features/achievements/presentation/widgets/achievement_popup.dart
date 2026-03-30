import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../domain/achievement.dart';

// ============================================================
// ACHIEVEMENT POPUP – Presentation Layer
// ============================================================
// Popup hiển thị thông báo achievement vừa unlock.
// Sử dụng OverlayEntry để hiển thị trên mọi màn hình.
// Tự động đóng sau 4 giây với animation scale.

class AchievementPopup {
  /// Hiển thị popup achievement
  /// Sử dụng GlobalKey để truy cập Navigator từ bất kỳ đâu
  static void show(Achievement achievement) {
    // Lấy context từ NavigatorState
    final context = achievementNavigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AchievementPopupWidget(
        achievement: achievement,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

// ──────────────────────────────────────────────────────────────
// Widget popup bên trong Overlay
// ──────────────────────────────────────────────────────────────

class _AchievementPopupWidget extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const _AchievementPopupWidget({
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<_AchievementPopupWidget> createState() => _AchievementPopupWidgetState();
}

class _AchievementPopupWidgetState extends State<_AchievementPopupWidget> {
  @override
  void initState() {
    super.initState();
    // Tự đóng sau 4 giây
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      left: 20,
      right: 20,
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    achievement.color,
                    achievement.color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: achievement.color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon achievement
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      achievement.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nội dung
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎉 Achievement Unlocked!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
