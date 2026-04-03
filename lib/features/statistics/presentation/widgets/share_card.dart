import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/weekly_stats_entity.dart';

// ============================================================
// SHARE CARD WIDGET
// ============================================================
// Widget dùng để chụp ảnh (screenshot) và chia sẻ thống kê tuần.
// Sử dụng màu cố định thay vì Theme vì screenshot cần pixel chính xác.
// Giao diện: Nền xanh đậm, chữ trắng, mini chart 7 cột.

// Màu cố định cho share card (không dùng Theme)
class ShareCardColors {
  static const Color background = Color(0xFF1A237E);
  static const Color primary = Color(0xFF42A5F5);
  static const Color textWhite = Colors.white;
  static const Color dividerWhite = Color(0x33FFFFFF);
  static const Color chartBar = Color(0xB3FFFFFF); // Trắng mờ 70%
}

class ShareCard extends StatelessWidget {
  final WeeklyStatsEntity stats;
  final int streakDays;

  const ShareCard({
    super.key,
    required this.stats,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày cho tiêu đề tuần
    final dateFormat = DateFormat('dd/MM');
    final weekLabel = 'Tuần ${_getWeekNumber(stats.weekStart)} — '
        '${dateFormat.format(stats.weekStart)} đến ${dateFormat.format(stats.weekEnd)}';

    // Tính tổng số Pomodoro trong tuần
    final totalPomos = stats.dailyPomodoros.values.fold<int>(0, (sum, count) => sum + count);

    // Tạo danh sách 7 giá trị cho mini chart
    final List<int> dailyValues = _getDailyValues();

    return Container(
      height: 320, // Tăng chiều cao để tránh overflow
      color: ShareCardColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== Logo và Tên App =====
          Row(
            children: [
              // Logo đơn giản: Icon Timer
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ShareCardColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer,
                  color: ShareCardColors.textWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Smart Productivity Booster',
                  style: TextStyle(
                    color: ShareCardColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Divider trắng mờ
          Container(
            height: 1,
            color: ShareCardColors.dividerWhite,
          ),

          const SizedBox(height: 10),

          // ===== Tiêu đề Tuần =====
          Text(
            weekLabel,
            style: const TextStyle(
              color: ShareCardColors.textWhite,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          // ===== 3 Số Lớn: Pomodoro / Phút / Task =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('🍅', 'Pomodoro', totalPomos.toString()),
              _buildStatItem('⏱️', 'Phút', stats.totalFocusMinutes.toString()),
              _buildStatItem('✅', 'Task', stats.completedTasks.toString()),
            ],
          ),

          const SizedBox(height: 12),

          // ===== Mini Chart 7 Cột trắng mờ =====
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = dailyValues[index];
                final maxValue = dailyValues.reduce((a, b) => a > b ? a : b);
                final height = maxValue > 0 ? (value / maxValue) * 40 : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: height > 0 ? height : 3,
                      decoration: BoxDecoration(
                        color: ShareCardColors.chartBar,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _getDayLabel(index),
                      style: const TextStyle(
                        color: ShareCardColors.dividerWhite,
                        fontSize: 9,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // ===== Streak =====
          Text(
            '🔥 Streak: $streakDays ngày',
            style: const TextStyle(
              color: ShareCardColors.textWhite,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị một stat item (icon + label + value)
  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: ShareCardColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: ShareCardColors.dividerWhite,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Lấy 7 giá trị cho 7 ngày trong tuần
  List<int> _getDailyValues() {
    final List<int> values = List.filled(7, 0);
    for (int i = 0; i < 7; i++) {
      // Tạo DateTime cho mỗi ngày trong tuần
      final day = stats.weekStart.add(Duration(days: i));
      final normalizedDay = DateTime(day.year, day.month, day.day);
      values[i] = stats.dailyPomodoros[normalizedDay] ?? 0;
    }
    return values;
  }

  // Lấy nhãn ngày trong tuần
  String _getDayLabel(int index) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return days[index];
  }

  // Tính số tuần trong năm
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}
