import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/eisenhower_matrix/presentation/bloc/eisenhower_bloc.dart';
import '../../../features/eisenhower_matrix/presentation/bloc/eisenhower_state.dart';
import '../../../features/eisenhower_matrix/domain/entities/quadrant_type.dart';
import '../../../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../../../features/statistics/presentation/bloc/statistics_event.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/eisenhower_matrix/presentation/pages/eisenhower_page.dart';
import '../../../features/pomodoro_timer/presentation/pages/pomodoro_page.dart';
import '../../../features/statistics/presentation/pages/statistics_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';

/// Widget điều hướng chính – Bottom Navigation Bar với 4 tab
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Danh sách màn hình tương ứng với các tab
  // IndexedStack giữ nguyên state khi người dùng chuyển tab
  final List<Widget> _screens = const [
    DashboardPage(),
    EisenhowerPage(),
    PomodoroPage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      // canPop: false → chặn back mặc định, tự mình xử lý
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Người dùng nhấn back → hỏi có thoát không
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          // Thoát app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      // IndexedStack: render tất cả màn hình nhưng chỉ hiện 1 cái
      // → Không mất state khi chuyển tab (khác PageView)
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Bottom Navigation Bar theo Material 3
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        animationDuration: const Duration(milliseconds: 300),
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);

          // Khi chuyển sang tab Thống kê (index 3 sau khi thêm tab "Hôm nay")
          // → tải lại dữ liệu
          if (index == 3) {
            final eisenhowerState = context.read<EisenhowerBloc>().state;
            if (eisenhowerState is EisenhowerLoaded) {
              context.read<StatisticsBloc>().add(const LoadWeeklyStats());
            }
          }
        },
        destinations: [
          // Tab Dashboard "Hôm nay"
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.today,
            tooltip: l10n.today,
          ),

          // Tab Ma trận Eisenhower – hiển thị Badge số task "Làm ngay" quá hạn
          //
          // Điều kiện quá hạn:
          // - Thuộc quadrant doIt (Q1 – Làm ngay)
          // - Có deadline (dueDate != null)
          // - deadline trước thời điểm hiện tại
          // - Chưa hoàn thành (isCompleted == false)
          BlocBuilder<EisenhowerBloc, EisenhowerState>(
            builder: (context, state) {
              int overdueCount = 0;
              if (state is EisenhowerLoaded) {
                final doItTasks =
                    state.tasksByQuadrant[QuadrantType.doIt] ?? [];
                final now = DateTime.now();
                overdueCount = doItTasks
                    .where(
                      (task) =>
                          task.dueDate != null &&
                          task.dueDate!.isBefore(now) &&
                          !task.isCompleted,
                    )
                    .length;
              }

              return NavigationDestination(
                icon: Badge(
                  isLabelVisible: overdueCount > 0,
                  label: Text(
                    '$overdueCount',
                    style: const TextStyle(fontSize: 10),
                  ),
                  child: const Icon(Icons.grid_view_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: overdueCount > 0,
                  label: Text(
                    '$overdueCount',
                    style: const TextStyle(fontSize: 10),
                  ),
                  child: const Icon(Icons.grid_view),
                ),
                label: l10n.matrix,
                tooltip: l10n.eisenhowerMatrix,
              );
            },
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.pomodoroTimer,
            tooltip: l10n.pomodoroTimer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
            tooltip: l10n.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
            tooltip: l10n.settings,
          ),
        ],
      ),
    ),
    );
  }

  /// Hiển thị dialog hỏi có muốn thoát app không.
  /// Trả về true nếu người dùng chọn "Có", false nếu "Không".
  Future<bool> _showExitDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitTitle),
        content: Text(l10n.exitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
