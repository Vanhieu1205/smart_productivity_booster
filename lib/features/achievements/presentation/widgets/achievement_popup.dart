import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  static void show(Achievement achievement) {
    // Lấy context từ NavigatorState
    final navigatorState = achievementNavigatorKey.currentState;
    if (navigatorState == null) {
      debugPrint('AchievementPopup: NavigatorState is null');
      return;
    }

    // Sử dụng SchedulerBinding thay vì WidgetsBinding
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!navigatorState.mounted) return;

      try {
        final context = navigatorState.context;

        // Lấy Overlay từ context
        final overlay = Overlay.of(context, rootOverlay: true);

        // Lấy localized text
        final isVietnamese = PlatformDispatcher.instance.locale.languageCode == 'vi';
        final unlockedText = isVietnamese ? '🎉 Đã mở khóa thành tựu!' : '🎉 Achievement Unlocked!';

        late OverlayEntry overlayEntry;

        overlayEntry = OverlayEntry(
          builder: (context) => _AchievementPopupWidget(
            achievement: achievement,
            unlockedText: unlockedText,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
        );

        overlay.insert(overlayEntry);
      } catch (e, stackTrace) {
        debugPrint('AchievementPopup error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    });
  }
}

// ──────────────────────────────────────────────────────────────
// Widget popup bên trong Overlay
// ──────────────────────────────────────────────────────────────

class _AchievementPopupWidget extends StatefulWidget {
  final Achievement achievement;
  final String unlockedText;
  final VoidCallback onDismiss;

  const _AchievementPopupWidget({
    required this.achievement,
    required this.unlockedText,
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: Positioned(
        bottom: bottomPadding + 16,
        left: 16,
        right: 16,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    achievement.color,
                    achievement.color.withAlpha(200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: achievement.color.withAlpha(100),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon achievement
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      achievement.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nội dung
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.unlockedText,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.description,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
