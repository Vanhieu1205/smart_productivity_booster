import 'package:flutter/material.dart';
import '../../domain/entities/weekly_stats_entity.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// FOCUS SUMMARY CARDS WIDGET
// ============================================================
// Row chứa 3 card tổng hợp các chỉ số quan trọng trong tuần.

class FocusSummaryCards extends StatelessWidget {
  final WeeklyStatsEntity stats;

  const FocusSummaryCards({super.key, required this.stats});

  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Để có flex layout đẹp, ta bỏ vô Row và Expanded các thẻ
    
    // Tính tổng số lượng pomodoro từ Map các ngày
    int totalPomodoros = 0;
    stats.dailyPomodoros.forEach((_, count) => totalPomodoros += count);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: l10n.totalPomodoros,
            value: '$totalPomodoros',
            icon: Icons.timer,
            gradientColors: const [Color(0xFFEF5350), Color(0xFFC62828)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: l10n.focusMinutes,
            value: '${stats.totalFocusMinutes}m',
            icon: Icons.bolt,
            gradientColors: const [Color(0xFF42A5F5), Color(0xFF1565C0)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: l10n.completedTasks,
            value: '${stats.completedTasks}',
            icon: Icons.check_circle_outline,
            gradientColors: const [Color(0xFF66BB6A), Color(0xFF2E7D32)],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon tròn nhỏ dùng gradient nổi rực rỡ
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          // Số to bự
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Tiêu đề giải thích nhỏ
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
