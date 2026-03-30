import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../../../../features/statistics/presentation/bloc/statistics_state.dart';
import '../../../theme/app_theme.dart';

/// Placeholder cho màn hình Thống kê (dùng [WeeklyStatsEntity] từ [StatisticsLoaded])
class StatisticsPlaceholder extends StatelessWidget {
  const StatisticsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê hiệu suất')),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StatisticsLoaded) {
            return _buildStats(context, state);
          }
          return const Center(
            child: Text(
              'Chưa có dữ liệu thống kê.\nHãy thêm tasks trước!',
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(BuildContext context, StatisticsLoaded state) {
    final ws = state.weeklyStats;
    final totalPomodoros =
        ws.dailyPomodoros.values.fold<int>(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tuần: ${_fmt(ws.weekStart)} — ${_fmt(ws.weekEnd)}',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 16),
        _summaryCard(
          totalPomodoros: totalPomodoros,
          totalFocusMinutes: ws.totalFocusMinutes,
          completedTasks: ws.completedTasks,
        ),
        const SizedBox(height: 16),
        Text('Pomodoro theo ngày', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        ...ws.dailyPomodoros.entries.map(
          (e) => ListTile(
            dense: true,
            title: Text(_fmt(e.key)),
            trailing: Text('${e.value} phiên'),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  Widget _summaryCard({
    required int totalPomodoros,
    required int totalFocusMinutes,
    required int completedTasks,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('Pomodoro', totalPomodoros, Icons.timer, AppColors.quadrant2),
            _statItem(
              'Tập trung (phút)',
              totalFocusMinutes,
              Icons.hourglass_top,
              AppColors.primary,
            ),
            _statItem(
              'Task xong',
              completedTasks,
              Icons.check_circle,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: AppTextStyles.titleLarge.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
