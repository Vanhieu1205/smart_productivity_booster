import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/streak_service.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/daily_progress_ring.dart';
import '../../../../core/services/task_change_notifier.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/eisenhower_matrix/domain/entities/quadrant_type.dart';
import '../../../../features/eisenhower_matrix/domain/entities/task_entity.dart';
import '../../../../features/eisenhower_matrix/data/models/task_model.dart';
import '../../../../features/pomodoro_timer/data/models/pomodoro_session_model.dart';
import '../../../../features/pomodoro_timer/domain/entities/timer_type.dart';
import '../../../../features/pomodoro_timer/presentation/bloc/pomodoro_timer_bloc.dart';
import '../../../../features/pomodoro_timer/presentation/bloc/pomodoro_timer_state.dart';
import '../../../../features/pomodoro_timer/presentation/pages/pomodoro_page.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';

/// Màn hình Dashboard "Hôm nay"
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Key để rebuild Dashboard khi có sự kiện PomodoroCompleted
  final GlobalKey<_DashboardContentState> _contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PomodoroTimerBloc, PomodoroState>(
      listenWhen: (prev, curr) => curr is PomodoroCompleted,
      listener: (context, state) {
        // Trigger rebuild Dashboard khi hoàn thành Pomodoro
        _contentKey.currentState?.refreshData();
      },
      child: TaskChangeListener(
        onTaskChanged: () {
          _contentKey.currentState?.refreshData();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 32),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.today),
              ],
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: _DashboardContent(key: _contentKey),
          ),
        ),
      ),
    );
  }
}

/// Phần nội dung chính của Dashboard - tách riêng để có StateKey
class _DashboardContent extends StatefulWidget {
  const _DashboardContent({super.key});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  // Dùng để trigger rebuild khi có sự kiện từ ngoài
  Key _rebuildKey = UniqueKey();

  void refreshData() {
    // Rebuild lại toàn bộ dashboard khi có sự kiện thay đổi
    if (mounted) {
      setState(() {
        _rebuildKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _rebuildKey,
      child: _buildDashboardContent(context),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSmall = ResponsiveUtils.isVerySmallPhone(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    final authState = context.watch<AuthBloc>().state;
    final username = authState is AuthAuthenticated ? authState.user.username : null;
    final timeGreeting = _buildGreeting(now, l10n);
    final dateText = DateFormat.yMMMMEEEEd('vi').format(now);

    final dashboardData = _loadTodayStats(today);

    final settingsState = context.watch<SettingsBloc>().state;
    final dailyGoal = settingsState is SettingsLoaded
        ? settingsState.dailyPomodoroGoal
        : 8;

    final padding = ResponsiveUtils.horizontalPadding(context);
    final titleSize = ResponsiveUtils.titleFontSize(context);
    final spacing = ResponsiveUtils.spacing(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome (if logged in) ──
          if (username != null && username.isNotEmpty) ...[
            Text(
              '${l10n.welcomeLabel} $username!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: titleSize,
              ),
            ),
            SizedBox(height: isSmall ? 2 : 4),
          ],

          // ── Time-based Greeting ──
          Text(
            timeGreeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: username != null ? (isSmall ? 18 : 20) : titleSize,
              color: username != null ? theme.colorScheme.onSurface.withOpacity(0.7) : null,
            ),
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            dateText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: isSmall ? 12 : null,
            ),
          ),
          SizedBox(height: spacing),

          // ── Streak Badge ──
          _StreakBadge(streak: sl<StreakService>().getCurrentStreak(), l10n: l10n),
          SizedBox(height: isSmall ? 12 : 20),

          // ── Metric Cards (Row trên tablet, Column trên phone) ──
          if (isTablet)
            Row(
              children: [
                Expanded(child: _MetricCard(label: l10n.pomodoroCount, value: dashboardData.pomodoroCount.toString(), subtitle: l10n.todaySubtitle, icon: Icons.timer, color: Colors.redAccent)),
                SizedBox(width: padding),
                Expanded(child: _MetricCard(label: l10n.focusMinutes, value: dashboardData.focusMinutes.toString(), subtitle: l10n.estimated, icon: Icons.access_time, color: Colors.indigo)),
                SizedBox(width: padding),
                Expanded(child: _MetricCard(label: l10n.taskCompleted, value: dashboardData.tasksToday.toString(), subtitle: l10n.todaySubtitle, icon: Icons.check_circle_outline, color: Colors.teal)),
              ],
            )
          else
            _MetricCardsRow(dashboardData: dashboardData, l10n: l10n),

          SizedBox(height: isSmall ? 16 : 24),

          // ── DailyProgressRing ──
          Center(
            child: DailyProgressRing(
              completed: dashboardData.pomodoroCount,
              goal: dailyGoal,
              size: ResponsiveUtils.progressRingSize(context),
            ),
          ),
          SizedBox(height: isSmall ? 16 : 24),

          // ── Danh sách task ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.prioritiesToday,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmall ? 14 : null,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.taskCount(dashboardData.doItTasks.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 4 : 8),
          if (dashboardData.doItTasks.isEmpty)
            Container(
              width: double.infinity,
              padding: ResponsiveUtils.cardPadding(context),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.noTasksInQuadrant,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontSize: isSmall ? 12 : null,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashboardData.doItTasks.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final task = dashboardData.doItTasks[index];
                return _TaskListTile(task: task, isSmall: isSmall);
              },
            ),

          SizedBox(height: isSmall ? 16 : 24),

          // ── Nút Pomodoro ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PomodoroPage()),
                );
              },
              icon: Icon(Icons.play_arrow_rounded, size: isSmall ? 20 : 24),
              label: Text(
                l10n.startPomodoro,
                style: TextStyle(fontSize: isSmall ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: ResponsiveUtils.buttonPadding(context),
                textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmall ? 14 : 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildGreeting(DateTime now, AppLocalizations l10n) {
    final hour = now.hour;
    if (hour < 5) return l10n.greetingNight;
    if (hour < 11) return l10n.greetingMorning;
    if (hour < 14) return l10n.greetingAfternoon;
    if (hour < 18) return l10n.greetingEvening;
    if (hour < 22) return l10n.greetingLateEvening;
    return l10n.greetingLateNight;
  }

  _DashboardData _loadTodayStats(DateTime today) {
    int pomodoroCount = 0;
    int focusMinutes = 0;

    Box<PomodoroSessionModel> sessionsBox;
    try {
      sessionsBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
    } catch (_) {
      return const _DashboardData(pomodoroCount: 0, focusMinutes: 0, tasksToday: 0, doItTasks: []);
    }

    for (final model in sessionsBox.values) {
      final entity = model.toEntity();
      if (!entity.isCompleted || entity.type != TimerType.work) continue;

      final sessionDate = DateTime(entity.startTime.year, entity.startTime.month, entity.startTime.day);
      if (sessionDate == today) {
        pomodoroCount += 1;
        if (entity.endTime != null) {
          final minutes = entity.endTime!.difference(entity.startTime).inMinutes;
          if (minutes > 0) focusMinutes += minutes;
        }
      }
    }

    final tasksBox = Hive.box<TaskModel>('tasks_box');
    int completedTasksToday = 0;
    final List<TaskEntity> todayDoItTasks = [];

    for (final model in tasksBox.values) {
      final entity = model.toEntity();
      final createdDate = DateTime(entity.createdAt.year, entity.createdAt.month, entity.createdAt.day);

      if (entity.isCompleted && createdDate == today) {
        completedTasksToday++;
      }
      if (entity.quadrant == QuadrantType.doIt && createdDate == today) {
        todayDoItTasks.add(entity);
      }
    }

    return _DashboardData(
      pomodoroCount: pomodoroCount,
      focusMinutes: focusMinutes,
      tasksToday: completedTasksToday,
      doItTasks: todayDoItTasks.take(5).toList(),
    );
  }
}

/// Row 3 metric cards trên phone
class _MetricCardsRow extends StatelessWidget {
  final _DashboardData dashboardData;
  final AppLocalizations l10n;

  const _MetricCardsRow({required this.dashboardData, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveUtils.isVerySmallPhone(context);
    final spacing = isSmall ? 4.0 : 8.0;

    // IntrinsicHeight giúp 3 khung luôn bằng nhau theo chiều cao.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _MetricCard(label: l10n.pomodoroCount, value: dashboardData.pomodoroCount.toString(), subtitle: l10n.todaySubtitle, icon: Icons.timer, color: Colors.redAccent, isSmall: isSmall)),
          SizedBox(width: spacing),
          Expanded(child: _MetricCard(label: l10n.focusMinutes, value: dashboardData.focusMinutes.toString(), subtitle: l10n.estimated, icon: Icons.access_time, color: Colors.indigo, isSmall: isSmall)),
          SizedBox(width: spacing),
          Expanded(child: _MetricCard(label: l10n.taskCompleted, value: dashboardData.tasksToday.toString(), subtitle: l10n.todaySubtitle, icon: Icons.check_circle_outline, color: Colors.teal, isSmall: isSmall)),
        ],
      ),
    );
  }
}

class _DashboardData {
  final int pomodoroCount;
  final int focusMinutes;
  final int tasksToday;
  final List<TaskEntity> doItTasks;

  const _DashboardData({required this.pomodoroCount, required this.focusMinutes, required this.tasksToday, required this.doItTasks});
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSmall;

  const _MetricCard({required this.label, required this.value, required this.subtitle, required this.icon, required this.color, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = isSmall ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    final fixedHeight = isSmall ? 80.0 : 92.0;

    return SizedBox(
      height: fixedHeight,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label với icon - tự động thu nhỏ
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: isSmall ? 12 : 16, color: color),
                  SizedBox(width: isSmall ? 2 : 4),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Value - tự động thu nhỏ
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            // Subtitle - tự động thu nhỏ
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskListTile extends StatelessWidget {
  final TaskEntity task;
  final bool isSmall;

  const _TaskListTile({required this.task, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = QuadrantType.doIt.color;
    final padding = isSmall ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6) : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    final iconSize = isSmall ? 18.0 : 22.0;

    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 4 : 8),
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.goToMatrixToComplete,
                style: TextStyle(fontSize: isSmall ? 12 : 14),
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: task.isCompleted ? color : theme.colorScheme.onSurface.withOpacity(0.5),
              size: iconSize,
            ),
            SizedBox(width: isSmall ? 6 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      task.title,
                      maxLines: 1,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (task.description.isNotEmpty)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        task.description,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.pomodoroProgress(task.completedPomodoros, task.estimatedPomodoros),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  final AppLocalizations l10n;

  const _StreakBadge({required this.streak, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = ResponsiveUtils.isVerySmallPhone(context);
    final padding = isSmall ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    final iconSize = isSmall ? 16.0 : 20.0;
    final fontSize = isSmall ? 12.0 : null;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange, size: iconSize),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            '$streak ${l10n.days}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
