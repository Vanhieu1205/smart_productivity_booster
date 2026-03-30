import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/timer_type.dart';
import '../bloc/pomodoro_timer_bloc.dart';
import '../bloc/pomodoro_timer_event.dart';
import '../bloc/pomodoro_timer_state.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/timer_controls_widget.dart';
import '../widgets/phase_indicator_widget.dart';
import '../widgets/white_noise_widget.dart';
import '../../data/models/pomodoro_session_model.dart';
import '../../../../core/widgets/daily_progress_ring.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import 'focus_mode_page.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// POMODORO PAGE – Presentation Layer
// ============================================================
//
// Màn hình chính của Pomodoro Timer.
//   - BlocListener: lắng nghe PomodoroCompleted để show Snackbar
//     và gọi NotificationService (chỉ trên mobile, skip trên web)
//   - BlocBuilder: render UI theo state hiện tại

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PomodoroTimerBloc, PomodoroState>(
      // Chỉ lắng nghe khi chuyển sang PomodoroCompleted
      listenWhen: (prev, curr) => curr is PomodoroCompleted,
      listener: (context, state) {
        if (state is PomodoroCompleted) {
          final l10n = AppLocalizations.of(context)!;
          _onPhaseCompleted(context, state, l10n);
        }
      },
      child: BlocBuilder<PomodoroTimerBloc, PomodoroState>(
        builder: (context, state) => _buildBody(context, state),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // XỬ LÝ KHI PHASE HOÀN THÀNH
  // ────────────────────────────────────────────────────────────────────────────

  void _onPhaseCompleted(BuildContext context, PomodoroCompleted state, AppLocalizations l10n) {
    // Xác định nội dung Snackbar theo pha vừa xong
    final isWorkDone = state.completedType == TimerType.work;
    final message = isWorkDone
        ? l10n.pomodoroComplete
        : l10n.breakComplete;

    final bgColor = isWorkDone
        ? const Color(0xFF43A047) // Xanh lá – hoàn thành tốt
        : const Color(0xFF1E88E5); // Xanh dương – kết thúc nghỉ

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: bgColor,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: l10n.startTimer,
            textColor: Colors.white,
            onPressed: () {
              context.read<PomodoroTimerBloc>().add(const StartTimer());
            },
          ),
        ),
      );

    // ── Notification (chỉ trên Android/iOS, không trên Web) ───────────────────
    // NotificationService.showTimerCompleteNotification không khả dụng trên web.
    // Sử dụng kDefaultTargetPlatform check để an toàn.
    // if (!kIsWeb) {
    //   if (isWorkDone) {
    //     NotificationService.showTimerCompleteNotification(
    //       breakMinutes: state.nextType.minutes,
    //     );
    //   } else {
    //     NotificationService.showBreakCompleteNotification();
    //   }
    // }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD BODY
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, PomodoroState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Màu nền gradient nhẹ theo pha hiện tại
    final phaseColor = _phaseColor(state.currentType);

    // Lấy số Pomodoro hôm nay và mục tiêu
    final todayPomos = _getTodayPomodoroCount();
    final settingsState = context.watch<SettingsBloc>().state;
    final dailyGoal = settingsState is SettingsLoaded
        ? settingsState.dailyPomodoroGoal
        : 8;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pomodoroTimer),
        centerTitle: true,
        // Badge tổng số pomodoro hoàn thành trong AppBar
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: phaseColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${state.completedPomodoros} 🍅',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: phaseColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Gradient nền rất nhạt để tạo atmosphere theo pha
      backgroundColor: Color.lerp(
        theme.colorScheme.surface,
        phaseColor.withOpacity(0.05),
        0.5,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── DailyProgressRing hiển thị tiến độ hôm nay ────
              DailyProgressRing(
                completed: todayPomos,
                goal: dailyGoal,
                size: 100,
              ),

              const SizedBox(height: 16),

              // ── Phase Indicator Pills ────────────────────────
              PhaseIndicatorWidget(state: state),

              const SizedBox(height: 36),

              // ── Vòng tròn đếm ngược ──────────────────────────
              // AnimatedSwitcher để slide-in khi phase thay đổi
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: CircularTimerWidget(
                  key: ValueKey(state.currentType), // Re-animate khi đổi pha
                  state: state,
                ),
              ),

              const SizedBox(height: 36),

              // ── Tips box theo pha ────────────────────────────
              _PhaseTipsBox(state: state),

              const SizedBox(height: 32),

              // ── Nút điều khiển ────────────────────────────────
              TimerControlsWidget(state: state),

              const SizedBox(height: 16),

              // ── Nút chế độ tập trung toàn màn hình ─────────
              TextButton.icon(
                icon: const Icon(Icons.fullscreen),
                label: Text(l10n.focusMode),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FocusModePage(),
                    fullscreenDialog: true,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Tiếng ồn trắng ──────────────────────────────
              const WhiteNoiseWidget(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _phaseColor(TimerType type) {
    switch (type) {
      case TimerType.work:
        return const Color(0xFFE53935);
      case TimerType.shortBreak:
        return const Color(0xFF1E88E5);
      case TimerType.longBreak:
        return const Color(0xFF7B1FA2);
    }
  }

  /// Đếm số Pomodoro work đã hoàn thành hôm nay từ Hive
  int _getTodayPomodoroCount() {
    try {
      final box = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int count = 0;
      for (final session in box.values) {
        final sessionDate = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        if (sessionDate == today &&
            session.isCompleted &&
            session.typeIndex == TimerType.work.index) {
          count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Tips / Tip box theo từng pha
// ──────────────────────────────────────────────────────────────
class _PhaseTipsBox extends StatelessWidget {
  final PomodoroState state;

  const _PhaseTipsBox({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final (icon, tip, color) = _tipFor(state, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (String, String, Color) _tipFor(PomodoroState state, AppLocalizations l10n) {
    if (state is PomodoroCompleted) {
      return ('🎉', l10n.phaseComplete, const Color(0xFF43A047));
    }
    switch (state.currentType) {
      case TimerType.work:
        return ('🧠', l10n.focusHint, const Color(0xFFE53935));
      case TimerType.shortBreak:
        return ('🚶', l10n.breakHint, const Color(0xFF1E88E5));
      case TimerType.longBreak:
        return ('☕', l10n.longBreakHint, const Color(0xFF7B1FA2));
    }
  }
}
