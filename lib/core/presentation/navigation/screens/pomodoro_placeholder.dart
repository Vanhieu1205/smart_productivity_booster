import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/pomodoro_timer/presentation/bloc/pomodoro_timer_bloc.dart';
import '../../../../features/pomodoro_timer/presentation/bloc/pomodoro_timer_event.dart';
import '../../../../features/pomodoro_timer/presentation/bloc/pomodoro_timer_state.dart';
import '../../../../features/pomodoro_timer/domain/entities/timer_type.dart';
import '../../../theme/app_theme.dart';

/// Placeholder cho màn hình Pomodoro Timer
class PomodoroPlaceholder extends StatelessWidget {
  const PomodoroPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đồng hồ Pomodoro')),
      body: BlocBuilder<PomodoroTimerBloc, PomodoroState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimerDisplay(context, state),
                const SizedBox(height: 32),
                _buildControls(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, PomodoroState state) {
    String timeStr = '25:00';
    String label = 'LÀM VIỆC';
    Color color = AppColors.quadrant2;

    if (state is PomodoroRunning) {
      final m = state.remainingSeconds ~/ 60;
      final s = state.remainingSeconds % 60;
      timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      // Dùng currentType thay vì phase (field mới trong State)
      label = state.currentType == TimerType.work ? 'LÀM VIỆC' : 'NGHỈ NGƠI';
      color = state.currentType == TimerType.work ? AppColors.quadrant2 : AppColors.quadrant3;
    } else if (state is PomodoroPaused) {
      final m = state.remainingSeconds ~/ 60;
      final s = state.remainingSeconds % 60;
      timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      label = 'TẠM DỪNG';
      color = Colors.grey;
    } else if (state is PomodoroCompleted) {
      timeStr = '00:00';
      label = 'HOÀN THÀNH! 🎉';
      color = AppColors.success;
    }

    return Column(
      children: [
        Text(label, style: AppTextStyles.timerLabel.copyWith(color: color)),
        const SizedBox(height: 8),
        Text(timeStr, style: AppTextStyles.timerDisplay.copyWith(color: color)),
        if (state is! PomodoroInitial) ...[
          const SizedBox(height: 8),
          Text(
            'Đã hoàn thành: ${state.completedPomodoros} 🍅  |  Streak: ${state.currentStreak}',
            style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildControls(BuildContext context, PomodoroState state) {
    final bloc = context.read<PomodoroTimerBloc>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state is PomodoroRunning) ...[
          OutlinedButton.icon(
            // Tên event mới: PauseTimer (không có hậu tố 'Event')
            onPressed: () => bloc.add(const PauseTimer()),
            icon: const Icon(Icons.pause),
            label: const Text('Tạm dừng'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => bloc.add(const SkipPhase()),
            icon: const Icon(Icons.skip_next),
            label: const Text('Bỏ qua'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => bloc.add(const ResetTimer()),
            icon: const Icon(Icons.stop),
            label: const Text('Reset'),
          ),
        ] else if (state is PomodoroPaused) ...[
          FilledButton.icon(
            onPressed: () => bloc.add(const ResumeTimer()),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Tiếp tục'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => bloc.add(const ResetTimer()),
            icon: const Icon(Icons.stop),
            label: const Text('Reset'),
          ),
        ] else if (state is PomodoroCompleted) ...[
          FilledButton.icon(
            // Sau khi hoàn thành → bắt đầu phase tiếp theo
            onPressed: () => bloc.add(const StartTimer()),
            icon: const Icon(Icons.play_arrow),
            label: Text('Bắt đầu ${state.nextType.label}'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => bloc.add(const ResetTimer()),
            icon: const Icon(Icons.stop),
            label: const Text('Reset'),
          ),
        ] else ...[
          FilledButton.icon(
            onPressed: () => bloc.add(const StartTimer()),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Bắt đầu'),
          ),
        ],
      ],
    );
  }
}
