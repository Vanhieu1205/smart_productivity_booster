import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../widgets/pomodoro_bar_chart.dart';
import '../widgets/focus_summary_cards.dart';
import '../widgets/share_card.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// STATISTICS PAGE
// ============================================================
// Màn hình chính chức năng Thống kê (Statistics).
// Hỗ trợ xem thống kê theo Tuần và theo Tháng thông qua TabBar.
// Tab Tuần: Hiển thị biểu đồ cột 7 ngày trong tuần.
// Tab Tháng: Hiển thị biểu đồ đường 30 ngày gần nhất.
// Hỗ trợ chia sẻ thống kê tuần qua ảnh chụp màn hình.

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  // Biến hỗ trợ dùng DateFormat
  final DateFormat _dateFormat = DateFormat('dd/MM');

  // TabController quản lý chuyển đổi giữa Tuần và Tháng
  late TabController _tabController;

  // Controller để chụp ảnh ShareCard
  final GlobalKey _shareCardKey = GlobalKey();

  // Số ngày streak (có thể lấy từ repository sau)
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHIA SẺ THỐNG KÊ QUA ẢNH
  // ============================================================
  // Chụp ảnh ShareCard và chia sẻ qua ứng dụng khác.
  Future<void> _shareStats() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Tìm RenderRepaintBoundary từ GlobalKey
      final boundary = _shareCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotCaptureImage)),
          );
        }
        return;
      }

      // Chụp ảnh với độ phân giải cao (pixelRatio: 2.0)
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorProcessingImage)),
          );
        }
        return;
      }

      // Lưu ảnh vào thư mục tạm
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/stats_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Chia sẻ ảnh qua share_plus
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: l10n.shareText,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorSharing}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.week),
            Tab(text: l10n.month),
          ],
        ),
        actions: [
          // Nút share (ShareCard không đặt trong actions: AppBar chỉ cho chiều cao ~kToolbarButtonHeight → overflow)
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.shareStats,
            onPressed: _shareStats,
          ),
          // Nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => context.read<StatisticsBloc>().add(const LoadWeeklyStats()),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Stack(
        fit: StackFit.expand,
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildWeekView(context, l10n),
              _buildMonthView(context, l10n),
            ],
          ),
          // Card ẩn ngoài màn hình để chụp ảnh — phải nằm trong body (constraints đủ cao)
          Positioned(
            left: -4000,
            top: 0,
            child: IgnorePointer(
              child: BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsLoaded) {
                    return RepaintBoundary(
                      key: _shareCardKey,
                      child: ShareCard(
                        stats: state.weeklyStats,
                        streakDays: _streakDays,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GIAO DIỆN XEM THEO TUẦN
  // ============================================================
  // Giữ nguyên giao diện cũ: Thanh chọn tuần, 3 cards tóm tắt, BarChart.
  Widget _buildWeekView(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return SafeArea(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // 3 SkeletonBox metric cards
                Row(
                  children: List.generate(
                    3,
                    (_) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(child: SkeletonBox(height: 60, width: 60, radius: 30)),
                            ),
                            const SizedBox(height: 12),
                            const SkeletonBox(height: 24, width: 50),
                            const SizedBox(height: 8),
                            const SkeletonBox(height: 12, width: 70),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // SkeletonBox chart height 200
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 20, width: 100),
                      SizedBox(height: 24),
                      Expanded(child: SkeletonBox(height: 14)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        if (state is StatisticsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<StatisticsBloc>().add(const LoadWeeklyStats()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (state is StatisticsLoaded) {
          final stats = state.weeklyStats;
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<StatisticsBloc>().add(const LoadWeeklyStats());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // ===== 1. Thanh chọn Tuần (Week Selector) =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút Prev
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 32),
                        tooltip: l10n.previousWeek,
                        onPressed: () => context.read<StatisticsBloc>().add(const ChangeWeek(-1)),
                      ),
                      // Text Label tuần
                      Column(
                        children: [
                          Text(l10n.weeklyStats, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '${_dateFormat.format(stats.weekStart)} - ${_dateFormat.format(stats.weekEnd)}',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      // Nút Next
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 32),
                        tooltip: l10n.nextWeek,
                        onPressed: () => context.read<StatisticsBloc>().add(const ChangeWeek(1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ===== 2. 3 Cards Tóm tắt =====
                  FocusSummaryCards(stats: stats),

                  const SizedBox(height: 32),

                  // ===== 3. Bar Chart Biểu đồ Cột =====
                  PomodoroBarChart(stats: stats),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ============================================================
  // GIAO DIỆN XEM THEO THÁNG
  // ============================================================
  // Tải dữ liệu 30 ngày gần nhất, hiển thị LineChart với số Pomodoro mỗi ngày.
  Widget _buildMonthView(BuildContext context, AppLocalizations l10n) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is StatisticsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<StatisticsBloc>().add(const LoadWeeklyStats()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (state is StatisticsLoaded) {
          final stats = state.weeklyStats;

          // Tính tổng số Pomodoro trong 30 ngày từ weeklyStats
          // Gom các ngày trong tuần hiện tại và các tuần trước đó
          final List<int> dailyPomos = List.filled(30, 0);

          // Đếm số pomodoro mỗi ngày trong 30 ngày
          // Với mỗi ngày trong khoảng 30 ngày, kiểm tra xem ngày đó thuộc tuần nào
          // và lấy dữ liệu từ weeklyStats (dữ liệu tuần được chọn)
          for (int i = 0; i < 30; i++) {
            final day = thirtyDaysAgo.add(Duration(days: i));
            // Chuẩn hóa ngày về đầu ngày để so sánh
            final normalizedDay = DateTime(day.year, day.month, day.day);
            // Kiểm tra nếu ngày nằm trong tuần hiện tại của stats
            if (!day.isBefore(stats.weekStart) && !day.isAfter(stats.weekEnd)) {
              // Sử dụng dailyPomodoros (Map<DateTime, int>) thay vì dailyPomodoro (List)
              if (stats.dailyPomodoros.containsKey(normalizedDay)) {
                dailyPomos[i] = stats.dailyPomodoros[normalizedDay] ?? 0;
              }
            }
          }

          // Tổng số Pomodoro trong tháng
          final totalMonthPomos = dailyPomos.fold<int>(0, (sum, count) => sum + count);

          // Tạo spots cho LineChart (30 điểm dữ liệu)
          final List<FlSpot> spots = List.generate(30, (i) {
            return FlSpot(i.toDouble(), dailyPomos[i].toDouble());
          });

          return SafeArea(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // ===== 1. Tiêu đề và Tổng tháng =====
                const SizedBox(height: 16),
                Text(
                  'Tổng tháng: $totalMonthPomos Pomodoro',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // ===== 2. LineChart 30 ngày =====
                Container(
                  height: 300,
                  padding: const EdgeInsets.only(right: 16, top: 16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              // Hiển thị nhãn cho ngày 1, 8, 15, 22, 30
                              const labelDays = [1, 8, 15, 22, 30];
                              if (labelDays.contains(value.toInt())) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 29,
                      minY: 0,
                      maxY: _calculateMaxY(dailyPomos),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final day = thirtyDaysAgo.add(Duration(days: spot.x.toInt()));
                              return LineTooltipItem(
                                '${DateFormat('dd/MM').format(day)}\n${spot.y.toInt()} Pomodoro',
                                TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ===== 3. Ghi chú =====
                Text(
                  'Biểu đồ 30 ngày gần nhất',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Tính giá trị maxY cho LineChart (luôn cao hơn giá trị lớn nhất một chút)
  double _calculateMaxY(List<int> dailyPomos) {
    final maxValue = dailyPomos.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return 10;
    return (maxValue + 2).toDouble();
  }
}
