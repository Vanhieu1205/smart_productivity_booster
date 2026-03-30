import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/timer_type.dart';
import '../bloc/pomodoro_timer_state.dart';

// ============================================================
// CIRCULAR TIMER WIDGET
// ============================================================
//
// [CustomPaint – Cách hoạt động]
//
// CustomPaint nhận một CustomPainter và vẽ trực tiếp lên Canvas.
// Canvas là bề mặt vẽ 2D, tương tự HTML Canvas hoặc Android Canvas.
//
// Quy trình:
//   1. Flutter layout widget → biết size
//   2. Gọi painter.paint(canvas, size)
//   3. Painter vẽ arc dựa vào progress (0.0 → 1.0)
//   4. Khi state thay đổi (remainingSeconds--) → repaint() được gọi
//      → Canvas được vẽ lại với progress mới
//
// [Tại sao dùng Arc thay vì LinearProgressIndicator?]
//   - Circular timer trực quan hơn cho countdown
//   - Có thể tùy chỉnh stroke width, màu gradient, shadow
//   - Hiệu ứng smoother hơn nhờ AnimatedWidget

class CircularTimerWidget extends StatefulWidget {
  final PomodoroState state;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.state,
    this.size = 260,
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  // Giá trị progress hiện tại (để animate smooth)
  double _currentProgress = 1.0;

  @override
  void initState() {
    super.initState();
    // AnimationController để smooth transition khi progress thay đổi
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(CircularTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newProgress = _computeProgress(widget.state);

    // Chỉ animate khi progress thay đổi đáng kể (tránh jitter)
    if ((newProgress - _currentProgress).abs() > 0.001) {
      _animation = Tween<double>(
        begin: _currentProgress,
        end: newProgress,
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut),
      );
      _animController.forward(from: 0);
      _currentProgress = newProgress;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Tính progress (0.0 → 1.0) dựa trên remainingSeconds / totalSeconds
  double _computeProgress(PomodoroState state) {
    final totalSecs = state.currentType.duration.inSeconds;
    if (totalSecs == 0) return 0.0;
    return (state.remainingSeconds / totalSecs).clamp(0.0, 1.0);
  }

  /// Màu vòng tròn theo loại pha
  Color _colorFor(TimerType type) {
    switch (type) {
      case TimerType.work:
        return const Color(0xFFE53935);   // Đỏ – tập trung
      case TimerType.shortBreak:
        return const Color(0xFF1E88E5);   // Xanh – nghỉ ngắn
      case TimerType.longBreak:
        return const Color(0xFF7B1FA2);   // Tím – nghỉ dài
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final color = _colorFor(state.currentType);
    final timeStr = _formatTime(state.remainingSeconds);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            // Painter vẽ vòng tròn progress phía sau
            painter: _TimerRingPainter(
              progress: _animation.value,
              color: color,
              trackColor: color.withOpacity(0.1),
              strokeWidth: 14,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Thời gian MM:SS (font lớn, bold) ────────────
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                      color: state.remainingSeconds == 0
                      ? Theme.of(context).colorScheme.outline
                          : theme.colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ── Nhãn pha ─────────────────────────────────────
                  Text(
                    state.currentType.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ── Số pomodoro tổng ─────────────────────────────
                  Text(
                    '${state.completedPomodoros} 🍅 hoàn thành',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
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
// CustomPainter – Vẽ vòng tròn progress
// ──────────────────────────────────────────────────────────────
class _TimerRingPainter extends CustomPainter {
  final double progress;     // 0.0 → 1.0 (1.0 = đầy = còn nhiều giờ)
  final Color color;         // Màu vòng progress
  final Color trackColor;    // Màu vòng nền (mờ)
  final double strokeWidth;  // Độ dày vành tròn

  const _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth / 2;

    // ── 1. Vẽ vòng nền (track) ────────────────────────────────────────────────
    // Vòng đầy ở phía sau, màu nhạt → tạo "rãnh" để arc progress chạy trên đó
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // ── 2. Vẽ vòng progress (arc) ─────────────────────────────────────────────
    // drawArc(rect, startAngle, sweepAngle, useCenter, paint)
    //   - startAngle: -π/2 = vị trí 12 giờ (đỉnh vòng tròn)
    //   - sweepAngle: progress * 2π = bao nhiêu radian cần vẽ
    //   - useCenter: false → chỉ vẽ cung (arc), không nối tâm
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round; // Bo tròn đầu cung

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,          // Bắt đầu từ 12 giờ
        progress * 2 * math.pi, // Quét ngược chiều kim đồng hồ theo progress
        false,
        progressPaint,
      );
    }

    // ── 3. Chấm tròn ở đầu arc (đầu cung) ────────────────────────────────────
    // Tạo điểm nhấn hình ảnh – dot nhỏ chạy theo vị trí hiện tại của arc
    if (progress > 0 && progress < 1.0) {
      final angle = -math.pi / 2 + progress * 2 * math.pi;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 1, dotPaint);
    }
  }

  /// Chỉ repaint khi progress thay đổi (optimization)
  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
