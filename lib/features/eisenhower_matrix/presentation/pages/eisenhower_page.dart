import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/quadrant_type.dart';
import '../bloc/eisenhower_bloc.dart';
import '../bloc/eisenhower_event.dart';
import '../bloc/eisenhower_state.dart';
import '../widgets/quadrant_widget.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/calendar_view_widget.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// EISENHOWER PAGE – Presentation Layer
// ============================================================
// Màn hình chính hiển thị Ma trận Eisenhower 2×2 và Lịch.

class EisenhowerPage extends StatefulWidget {
  const EisenhowerPage({super.key});

  @override
  State<EisenhowerPage> createState() => _EisenhowerPageState();
}

class _EisenhowerPageState extends State<EisenhowerPage> {
  bool _isCalendarView = false; // Add toggle state

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCalendarView ? l10n.calendarMode : l10n.eisenhowerMatrix),
        actions: [
          // Nút chuyển đổi View
          IconButton(
            icon: Icon(_isCalendarView ? Icons.grid_view_rounded : Icons.calendar_month_rounded),
            tooltip: _isCalendarView ? l10n.matrixMode : l10n.calendarViewMode,
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
          // Nút làm mới thủ công
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.reload,
            onPressed: () => context.read<EisenhowerBloc>().add(const LoadTasks()),
          ),
        ],
      ),

      body: BlocBuilder<EisenhowerBloc, EisenhowerState>(
        builder: (context, state) {
          // ── Đang tải ─────────────────────────────────────────
          if (state is EisenhowerLoading) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isWide ? 0.9 : 0.75,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, i) => const QuadrantSkeleton(),
                );
              },
            );
          }

          // ── Có lỗi ────────────────────────────────────────────
          if (state is EisenhowerError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      l10n.errorOccurred,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.read<EisenhowerBloc>().add(const LoadTasks()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Dữ liệu đã tải xong ───────────────────────────────
          if (state is EisenhowerLoaded) {
            if (_isCalendarView) {
              return CalendarViewWidget(tasksByQuadrant: state.tasksByQuadrant);
            }
            return _EisenhowerGrid(state: state);
          }

          // ── Trạng thái khởi tạo (EisenhowerInitial) ──────────
          return Center(child: Text(l10n.initializing));
        },
      ),

      // FAB mở dialog thêm task mới với quadrant mặc định Q1 (DoIt)
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'eisenhower_fab',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            // Truyền BLoC hiện tại vào dialog (không tạo instance mới)
            value: context.read<EisenhowerBloc>(),
            child: const AddTaskDialog(initialQuadrant: QuadrantType.doIt),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addTask),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Grid 2×2 hiển thị 4 quadrant
// ──────────────────────────────────────────────────────────────
class _EisenhowerGrid extends StatelessWidget {
  final EisenhowerLoaded state;

  const _EisenhowerGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    // Thứ tự hiển thị: Q1 (trên-trái), Q2 (trên-phải), Q3 (dưới-trái), Q4 (dưới-phải)
    final quadrantOrder = [
      QuadrantType.doIt,
      QuadrantType.scheduleIt,
      QuadrantType.delegateIt,
      QuadrantType.eliminateIt,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Trên màn hình rộng (tablet/web) → tăng tỷ lệ ô
        final isWide = constraints.maxWidth > 700;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            // Tỷ lệ cao hơn trên màn hình rộng để có nhiều chỗ cho tasks
            childAspectRatio: isWide ? 0.9 : 0.75,
          ),
          itemCount: 4,
          itemBuilder: (_, i) {
            final quadrant = quadrantOrder[i];
            final tasks = state.tasksByQuadrant[quadrant] ?? [];

            return QuadrantWidget(quadrant: quadrant, tasks: tasks);
          },
        );
      },
    );
  }
}
