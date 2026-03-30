import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/streak_service.dart';
import '../../../../core/widgets/daily_progress_ring.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/eisenhower_matrix/domain/entities/quadrant_type.dart';
import '../../../../features/eisenhower_matrix/domain/entities/task_entity.dart';
import '../../../../features/eisenhower_matrix/data/models/task_model.dart';
import '../../../../features/pomodoro_timer/data/models/pomodoro_session_model.dart';
import '../../../../features/pomodoro_timer/presentation/pages/pomodoro_page.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';

/// Màn hình Dashboard "Hôm nay"
/// - Chào người dùng theo giờ
/// - Tổng quan Pomodoro / phút tập trung / số task hôm nay
/// - Vòng tròn tiến độ ngày
/// - Danh sách 5 task ưu tiên (quadrant doIt)
/// - Nút điều hướng sang PomodoroPage
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final greeting = _buildGreeting(now, l10n);
    final dateText = DateFormat.yMMMMEEEEd('vi').format(now);

    // Đọc dữ liệu thống kê trong ngày từ Hive
    final dashboardData = _loadTodayStats(today);

    // Lấy mục tiêu Pomodoro hàng ngày từ SettingsBloc
    final settingsState = context.watch<SettingsBloc>().state;
    final dailyGoal = settingsState is SettingsLoaded
        ? settingsState.dailyPomodoroGoal
        : 8;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────────────────────────────────────────────
              // Phần 1: Greeting
              // ────────────────────────────────────────────────
              Text(
                greeting,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 8),

              // ────────────────────────────────────────────────
              // Phần 2: Streak hiển thị
              // ────────────────────────────────────────────────
              _StreakBadge(streak: sl<StreakService>().getCurrentStreak(), l10n: l10n),

              const SizedBox(height: 20),

              // ────────────────────────────────────────────────
              // Phần 3: 3 metric card
              // ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: l10n.pomodoroCount,
                      value: dashboardData.pomodoroCount.toString(),
                      subtitle: l10n.todaySubtitle,
                      icon: Icons.timer,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      label: l10n.focusMinutes,
                      value: dashboardData.focusMinutes.toString(),
                      subtitle: l10n.estimated,
                      icon: Icons.access_time,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      label: l10n.taskCompleted,
                      value: dashboardData.tasksToday.toString(),
                      subtitle: l10n.todaySubtitle,
                      icon: Icons.check_circle_outline,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ────────────────────────────────────────────────
              // Phần 3: DailyProgressRing với completed và goal
              // ────────────────────────────────────────────────
              Center(
                child: DailyProgressRing(
                  completed: dashboardData.pomodoroCount,
                  goal: dailyGoal,
                  size: 110,
                ),
              ),

              const SizedBox(height: 24),

              // ────────────────────────────────────────────────
              // Phần 4: Danh sách 5 task doIt
              // ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.prioritiesToday,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${dashboardData.doItTasks.length} task',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dashboardData.doItTasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.noTasksInQuadrant,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
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
                    return _TaskListTile(task: task);
                  },
                ),

              const SizedBox(height: 24),

              // ────────────────────────────────────────────────
              // Phần 5: Nút điều hướng Pomodoro
              // ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Điều hướng sang PomodoroPage – dùng Navigator.push
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PomodoroPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.startPomodoro),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng câu chào dựa theo giờ hiện tại
  String _buildGreeting(DateTime now, AppLocalizations l10n) {
    final hour = now.hour;
    if (hour < 5) return l10n.greetingNight;
    if (hour < 11) return l10n.greetingMorning;
    if (hour < 14) return l10n.greetingAfternoon;
    if (hour < 18) return l10n.greetingEvening;
    if (hour < 22) return l10n.greetingLateEvening;
    return l10n.greetingLateNight;
  }

  /// Đọc thống kê hôm nay từ Hive
  ///
  /// Sử dụng:
  /// - Box `pomodoro_sessions_box` (PomodoroSessionModel)
  /// - Box `tasks_box` (TaskModel)
  _DashboardData _loadTodayStats(DateTime today) {
    int pomodoroCount = 0;
    int focusMinutes = 0;

    // Box pomodoro_sessions_box lưu PomodoroSessionModel – đã được mở trong HiveService.openAllBoxes()
    Box<PomodoroSessionModel> sessionsBox;
    try {
      sessionsBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
    } catch (_) {
      // Nếu box chưa mở (trường hợp hiếm) → trả về dữ liệu rỗng, tránh crash UI.
      return const _DashboardData(
        pomodoroCount: 0,
        focusMinutes: 0,
        tasksToday: 0,
        doItTasks: [],
      );
    }

    for (final model in sessionsBox.values) {
      final entity = model.toEntity();
      if (!entity.isCompleted) continue;

      final sessionDate = DateTime(
        entity.startTime.year,
        entity.startTime.month,
        entity.startTime.day,
      );

      if (sessionDate == today) {
        pomodoroCount += 1;

        // Nếu có endTime → tính số phút, nếu không thì bỏ qua (phiên không trọn vẹn)
        if (entity.endTime != null) {
          final minutes =
              entity.endTime!.difference(entity.startTime).inMinutes;
          if (minutes > 0) {
            focusMinutes += minutes;
          }
        }
      }
    }

    // Đọc task hôm nay đã hoàn thành (bất kể quadrant nào)
    final tasksBox = Hive.box<TaskModel>('tasks_box');
    int completedTasksToday = 0;
    final List<TaskEntity> todayDoItTasks = [];

    for (final model in tasksBox.values) {
      final entity = model.toEntity();
      final createdDate = DateTime(
        entity.createdAt.year,
        entity.createdAt.month,
        entity.createdAt.day,
      );

      // Đếm task đã hoàn thành trong ngày hôm nay (bất kể ngày tạo)
      if (entity.isCompleted && createdDate == today) {
        completedTasksToday++;
      }

      // Lấy task doIt được tạo hôm nay để hiển thị ưu tiên
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

/// Model nội bộ gói dữ liệu Dashboard
class _DashboardData {
  final int pomodoroCount;
  final int focusMinutes;
  final int tasksToday;
  final List<TaskEntity> doItTasks;

  const _DashboardData({
    required this.pomodoroCount,
    required this.focusMinutes,
    required this.tasksToday,
    required this.doItTasks,
  });
}

/// Card hiển thị 1 metric nhỏ ở đầu màn hình
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item hiển thị task ưu tiên trong danh sách 5 task doIt
class _TaskListTile extends StatelessWidget {
  final TaskEntity task;

  const _TaskListTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = QuadrantType.doIt.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted
                ? color
                : theme.colorScheme.onSurface.withOpacity(0.5),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  'Pomodoro: ${task.completedPomodoros}/${task.estimatedPomodoros}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge hiển thị streak hiện tại với icon lửa.
class _StreakBadge extends StatelessWidget {
  final int streak;
  final AppLocalizations l10n;

  const _StreakBadge({required this.streak, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
          const SizedBox(width: 6),
          Text(
            '$streak ${l10n.days}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

