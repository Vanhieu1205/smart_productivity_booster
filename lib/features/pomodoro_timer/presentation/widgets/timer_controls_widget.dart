import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pomodoro_timer_bloc.dart';
import '../bloc/pomodoro_timer_event.dart';
import '../bloc/pomodoro_timer_state.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// TIMER CONTROLS WIDGET
// ============================================================
// Widget điều khiển timer gồm:
//   1. Row nút hành động: Start/Pause/Resume, Skip, Reset
//   2. Info row: "Pomodoro X/4 | Streak 🔥Y"

class TimerControlsWidget extends StatelessWidget {
  final PomodoroState state;

  const TimerControlsWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Thông tin streak ──────────────────────────────────
        _buildInfoRow(context),
        const SizedBox(height: 24),
        // ── Nút điều khiển ────────────────────────────────────
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    final theme = Theme.of(context);
    // Pha số trong chuỗi hiện tại (hiển thị X/4)
    final streakInCycle = (state.currentStreak % 4) == 0 && state.currentStreak > 0
        ? 4
        : state.currentStreak % 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pomodoro counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                'Pomodoro $streakInCycle/4',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Streak lửa
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                'Streak: ${state.currentStreak}',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bloc = context.read<PomodoroTimerBloc>();
    final l10n = AppLocalizations.of(context)!;

    // Tuỳ state → hiển thị nút khác nhau
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Nút Reset (luôn hiện) ──────────────────────────────
        _CircleButton(
          icon: Icons.stop_rounded,
          tooltip: l10n.resetTimer,
          onPressed: state is PomodoroInitial
              ? null
              : () => bloc.add(const ResetTimer()),
          color: Colors.grey,
        ),
        const SizedBox(width: 16),

        // ── Nút chính (Start / Pause / Resume) ────────────────
        _MainTimerButton(state: state, bloc: bloc),

        const SizedBox(width: 16),

        // ── Nút Skip (bỏ qua pha hiện tại) ───────────────────
        _CircleButton(
          icon: Icons.skip_next_rounded,
          tooltip: l10n.skipPhase,
          onPressed: state is PomodoroRunning || state is PomodoroPaused
              ? () => bloc.add(const SkipPhase())
              : null,
          color: Colors.orange,
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────
// Nút tròn nhỏ (Reset & Skip)
// ───────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;

  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        shape: const CircleBorder(),
        color: onPressed != null
            ? color.withOpacity(0.12)
            : Colors.grey.withOpacity(0.06),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              icon,
              color: onPressed != null ? color : Colors.grey.shade400,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────
// Nút Start / Pause / Resume (nút lớn ở giữa)
// ───────────────────────────────────────────────────
class _MainTimerButton extends StatelessWidget {
  final PomodoroState state;
  final PomodoroTimerBloc bloc;

  const _MainTimerButton({required this.state, required this.bloc});

  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Xác định icon, label, event và màu theo state
    late IconData icon;
    late String label;
    late PomodoroEvent event;
    late Color color;

    if (state is PomodoroRunning) {
      icon = Icons.pause_rounded;
      label = l10n.pauseTimer;
      event = const PauseTimer();
      color = const Color(0xFFE53935);
    } else if (state is PomodoroPaused) {
      icon = Icons.play_arrow_rounded;
      label = l10n.resumeTimer;
      event = const ResumeTimer();
      color = const Color(0xFF1E88E5);
    } else if (state is PomodoroCompleted) {
      icon = Icons.play_arrow_rounded;
      label = l10n.startTimer;
      event = const StartTimer();
      color = const Color(0xFF43A047);
    } else {
      // PomodoroInitial
      icon = Icons.play_arrow_rounded;
      label = l10n.startTimer;
      event = const StartTimer();
      color = const Color(0xFFE53935);
    }

    return GestureDetector(
      onTap: () => bloc.add(event),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
