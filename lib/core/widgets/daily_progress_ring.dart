import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================
// DAILY PROGRESS RING – Core Widget
// ============================================================
// Widget hiển thị vòng tròn tiến độ Pomodoro hàng ngày.
// Sử dụng CustomPainter để vẽ arc background + progress.

// ──────────────────────────────────────────────────────────────
// Widget chính
// ──────────────────────────────────────────────────────────────

/// Widget hiển thị vòng tròn tiến độ Pomodoro hàng ngày.
///
/// [completed]: số Pomodoro đã hoàn thành hôm nay
/// [goal]: mục tiêu Pomodoro hàng ngày
/// [size]: kích thước widget (mặc định 120)
class DailyProgressRing extends StatelessWidget {
  /// Số Pomodoro đã hoàn thành
  final int completed;

  /// Mục tiêu Pomodoro hàng ngày
  final int goal;

  /// Kích thước widget (width = height)
  final double size;

  const DailyProgressRing({
    super.key,
    required this.completed,
    required this.goal,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    // Tính tỷ lệ hoàn thành (0.0 -> 1.0+)
    final progress = goal > 0 ? completed / goal : 0.0;
    final isCompleted = progress >= 1.0;

    // Màu progress: xanh khi đã đạt mục tiêu, primary khi chưa
    final progressColor = isCompleted
        ? Colors.green
        : Theme.of(context).colorScheme.primary;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
      builder: (context, animatedProgress, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: animatedProgress,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              progressColor: progressColor,
              strokeWidth: 10,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Số lớn - số Pomodoro đã hoàn thành
                  Text(
                    '$completed',
                    style: TextStyle(
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                  // Số nhỏ - mục tiêu
                  Text(
                    '/$goal',
                    style: TextStyle(
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// CustomPainter vẽ vòng tròn tiến độ
// ──────────────────────────────────────────────────────────────

/// CustomPainter vẽ 2 arc: background (vòng nền) + progress (vòng tiến độ)
class _RingPainter extends CustomPainter {
  /// Tỷ lệ tiến độ (0.0 -> 1.0)
  final double progress;

  /// Màu vòng nền
  final Color backgroundColor;

  /// Màu vòng tiến độ
  final Color progressColor;

  /// Độ dày stroke
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Paint cho vòng nền
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Paint cho vòng tiến độ
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vẽ vòng nền (toàn bộ vòng tròn)
    canvas.drawCircle(center, radius, backgroundPaint);

    // Vẽ vòng tiến độ (từ đỉnh, ngược chiều kim đồng hồ)
    // -pi/2 = bắt đầu từ đỉnh (12 giờ)
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,       // Bắt đầu từ đỉnh
      sweepAngle,         // Góc quét = progress
      false,              // Không vẽ theo đường kính
      progressPaint,
    );
  }

  /// Chỉ repaint khi progress thay đổi
  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
