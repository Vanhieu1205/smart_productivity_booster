import 'package:flutter/material.dart';
import '../../domain/entities/timer_type.dart';
import '../bloc/pomodoro_timer_state.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

String _getPhaseName(AppLocalizations l10n, TimerType type) {
  if (type == TimerType.work) return l10n.workTime;
  if (type == TimerType.shortBreak) return l10n.shortBreak;
  return l10n.longBreak;
}

// ============================================================
// PHASE INDICATOR WIDGET
// ============================================================
// 3 pill buttons hiển thị 3 pha của Pomodoro.
// Active = FilledButton (màu solid), Inactive = OutlinedButton.
// Tap vào pill → không start timer, chỉ visual indicator.
// (Nếu muốn user chọn pha → có thể thêm callback onPhaseSelected)

class PhaseIndicatorWidget extends StatelessWidget {
  final PomodoroState state;

  const PhaseIndicatorWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PhasePill(type: TimerType.work, currentState: state),
        const SizedBox(width: 8),
        _PhasePill(type: TimerType.shortBreak, currentState: state),
        const SizedBox(width: 8),
        _PhasePill(type: TimerType.longBreak, currentState: state),
      ],
    );
  }
}

class _PhasePill extends StatelessWidget {
  final TimerType type;
  final PomodoroState currentState;

  const _PhasePill({required this.type, required this.currentState});

  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Pha đang active = currentType của state hiện tại
    final isActive = currentState.currentType == type;
    final color = _colorFor(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: isActive
          ? FilledButton(
              onPressed: null, // Chỉ hiển thị, không tap được
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const StadiumBorder(),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _getPhaseName(l10n, type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const StadiumBorder(),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _getPhaseName(l10n, type),
                style: TextStyle(
                  color: color.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
    );
  }

  Color _colorFor(TimerType type) {
    switch (type) {
      case TimerType.work:
        return const Color(0xFFE53935);       // Đỏ – tập trung
      case TimerType.shortBreak:
        return const Color(0xFF1E88E5);       // Xanh – nghỉ ngắn
      case TimerType.longBreak:
        return const Color(0xFF7B1FA2);       // Tím – nghỉ dài
    }
  }
}
