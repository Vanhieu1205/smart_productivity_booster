import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/weekly_stats_entity.dart';

// ============================================================
// POMODORO BAR CHART WIDGET
// ============================================================
// Dùng thư viện fl_chart để vẽ biểu đồ cột.
// Trục X hiển thị ngày (T2-CN), Trục Y hiển thị số lượt Pomodoro.
//
// [Giải thích fl_chart parameters]:
// - maxY: Giới hạn trên cùng của trục Y. Giúp biểu đồ scale chuẩn, không lủng củng.
// - barGroups: Mảng dữ liệu các cột. Tạo bằng vòng lặp gán từng data value vô BarChartGroupData.
// - gridData: Quy định cách chia lưới ngang/dọc làm nền cho biểu đồ.
// - titlesData: Quy định text các mốc quanh viền biểu đồ. (leftTitles = Y, bottomTitles = X).
// - barTouchData: Nơi cấu hình action và tooltip khi user chạm ngón tay vào cột.

class PomodoroBarChart extends StatelessWidget {
  final WeeklyStatsEntity stats;

  const PomodoroBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Tìm ngày có số pomodoro lớn nhất để set auto scale cho trục Y
    int maxYValue = 1; // Giá trị thấp nhất phòng hờ trống dữ liệu
    for (var count in stats.dailyPomodoros.values) {
      if (count > maxYValue) maxYValue = count;
    }
    // padding 2 để có khoảng trống trên đỉnh cột
    final maxY = (maxYValue + 2).toDouble();

    // Màu gradient bắt mắt cho mỗi cột (Yêu cầu: tím → xanh)
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF1E88E5), // Xanh Blue
        const Color(0xFF7B1FA2), // Tím Purple
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tuần này',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                // barTouchData chịu trách nhiệm hiển thị Tooltip Pop-up trên cột
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade900,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        // Giá trị cột rod.toY phản ánh số pomodoro
                        '${rod.toY.toInt()} 🍅',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                // Cấu hình các đoạn text quanh viền axis
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Giấu trục phải
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),   // Giấu trục trên
                  // Cấu hình trục bottom (X - ngày trong tuần)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => _getBottomTitles(value, meta, context),
                      reservedSize: 32,
                    ),
                  ),
                  // Cấu hình trục left (Y - số lượt)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1, // Chia khoảng mỗi vạch là 1
                      getTitlesWidget: (value, meta) => _getLeftTitles(value, meta, context),
                    ),
                  ),
                ),
                // Xóa đi khung border bao quanh chart mặc định xấu
                borderData: FlBorderData(show: false),
                // Gắn dữ liệu cột
                barGroups: _buildBarGroups(context, gradient),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mapping Data cho trục BarChart ──────────────────────────────────
  // Do entity trả về là Map<DateTime, int>, ta convert qua List<BarChartGroupData>
  List<BarChartGroupData> _buildBarGroups(BuildContext context, LinearGradient gradient) {
    List<BarChartGroupData> groups = [];
    final days = stats.dailyPomodoros.keys.toList()..sort();

    for (int i = 0; i < days.length; i++) {
      final pomodoroCount = stats.dailyPomodoros[days[i]]?.toDouble() ?? 0;
      
      groups.add(
        BarChartGroupData(
          x: i, // Index định vị label trục X
          barRods: [
            BarChartRodData(
              toY: pomodoroCount, // Vươn cao cột
              gradient: gradient,
              width: 14, // Độ rộng thân cột
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), // Bo hai đầu
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 10, // Độ sâu của cột shadow ở sau lưng
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.1),
              ),
            )
          ],
        ),
      );
    }
    return groups;
  }

  // ── Widget phụ cho nhãn (T2-CN) ────────────────────────────────────
  Widget _getBottomTitles(double value, TitleMeta meta, BuildContext context) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    
    // Mặc định mapping 0->T2, 6->CN (chuẩn ISO)
    final text = switch (value.toInt()) {
      0 => Text('T2', style: style),
      1 => Text('T3', style: style),
      2 => Text('T4', style: style),
      3 => Text('T5', style: style),
      4 => Text('T6', style: style),
      5 => Text('T7', style: style),
      6 => Text('CN', style: style),
      _ => Text('', style: style),
    };
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: text,
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta, BuildContext context) {
    // Ẩn bớt số trên trục Y nếu nó lẻ hoặc 0 cho giao diện thoáng (chỉ giữ tròn số nguyên)
    if (value == 0 || value % 1 != 0) {
      return Container();
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        '${value.toInt()}',
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant, 
            fontSize: 12, 
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
