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
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/daily_progress_ring.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import 'focus_mode_page.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// POMODORO PAGE – Presentation Layer
// ============================================================

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PomodoroTimerBloc, PomodoroState>(
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

  void _onPhaseCompleted(
      BuildContext context, PomodoroCompleted state, AppLocalizations l10n) {
    final isWorkDone = state.completedType == TimerType.work;
    final message = isWorkDone ? l10n.pomodoroComplete : l10n.breakComplete;

    final bgColor =
        isWorkDone ? const Color(0xFF43A047) : const Color(0xFF1E88E5);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: bgColor,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: l10n.startTimer,
            textColor: Colors.white,
            onPressed: () {
              context.read<PomodoroTimerBloc>().add(const StartTimer());
            },
          ),
        ),
      );
  }

  Widget _buildBody(BuildContext context, PomodoroState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Responsive values
    final isSmall = ResponsiveUtils.isVerySmallPhone(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final horizontalPadding = ResponsiveUtils.horizontalPadding(context);
    final timerSize = ResponsiveUtils.timerSize(context);
    final progressSize = isSmall ? 80.0 : (isTablet ? 130.0 : 100.0);

    // Màu nền gradient nhẹ theo pha hiện tại
    final phaseColor = _phaseColor(state.currentType);

    // Lấy số Pomodoro hôm nay và mục tiêu
    final todayPomos = _getTodayPomodoroCount();
    final settingsState = context.watch<SettingsBloc>().state;
    final dailyGoal =
        settingsState is SettingsLoaded ? settingsState.dailyPomodoroGoal : 8;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 22),
            const SizedBox(width: 8),
            Text(l10n.pomodoroTimer),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isSmall ? 8 : 16),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 6 : 10, vertical: isSmall ? 2 : 4),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: phaseColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${state.completedPomodoros} 🍅',
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 13,
                    fontWeight: FontWeight.w600,
                    color: phaseColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color.lerp(
        theme.colorScheme.surface,
        phaseColor.withOpacity(0.05),
        0.5,
      ),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(context, state, l10n, todayPomos, dailyGoal,
                phaseColor, horizontalPadding, progressSize)
            : _buildPortraitLayout(context, state, l10n, todayPomos, dailyGoal,
                phaseColor, horizontalPadding, timerSize, isSmall),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    PomodoroState state,
    AppLocalizations l10n,
    int todayPomos,
    int dailyGoal,
    Color phaseColor,
    double horizontalPadding,
    double timerSize,
    bool isSmall,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          SizedBox(height: isSmall ? 12 : 20),

          // ── DailyProgressRing ──
          DailyProgressRing(
            completed: todayPomos,
            goal: dailyGoal,
            size: isSmall ? 80.0 : 100,
          ),

          SizedBox(height: isSmall ? 12 : 16),

          // ── Phase Indicator Pills ──
          PhaseIndicatorWidget(state: state),

          SizedBox(height: isSmall ? 24 : 36),

          // ── Vòng tròn đếm ngược ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: CircularTimerWidget(
              key: ValueKey(state.currentType),
              state: state,
              size: timerSize,
            ),
          ),

          SizedBox(height: isSmall ? 24 : 36),

          // ── Tips box ──
          _PhaseTipsBox(state: state, isSmall: isSmall),

          SizedBox(height: isSmall ? 24 : 32),

          // ── Nút điều khiển ──
          TimerControlsWidget(state: state),

          SizedBox(height: isSmall ? 8 : 16),

          // ── Nút chế độ tập trung ──
          TextButton.icon(
            icon: Icon(Icons.fullscreen, size: isSmall ? 18 : null),
            label: Text(l10n.focusMode,
                style: TextStyle(fontSize: isSmall ? 13 : null)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FocusModePage(),
                fullscreenDialog: true,
              ),
            ),
          ),

          SizedBox(height: isSmall ? 16 : 24),

          // ── Tiếng ồn trắng ──
          const WhiteNoiseWidget(),

          SizedBox(height: isSmall ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    PomodoroState state,
    AppLocalizations l10n,
    int todayPomos,
    int dailyGoal,
    Color phaseColor,
    double horizontalPadding,
    double progressSize,
  ) {
    return Row(
      children: [
        // Left side - Timer
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhaseIndicatorWidget(state: state),
                const SizedBox(height: 16),
                CircularTimerWidget(
                  key: ValueKey(state.currentType),
                  state: state,
                ),
                const SizedBox(height: 24),
                TimerControlsWidget(state: state),
              ],
            ),
          ),
        ),
        // Right side - Progress & Tips
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DailyProgressRing(
                  completed: todayPomos,
                  goal: dailyGoal,
                  size: progressSize,
                ),
                const SizedBox(height: 24),
                _PhaseTipsBox(state: state),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                const WhiteNoiseWidget(),
              ],
            ),
          ),
        ),
      ],
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
  final bool isSmall;

  const _PhaseTipsBox({required this.state, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final (icon, tip, color) = _tipFor(state, l10n);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16, vertical: isSmall ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: isSmall ? 16 : 20)),
          SizedBox(width: isSmall ? 8 : 12),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                fontSize: isSmall ? 12 : null,
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
