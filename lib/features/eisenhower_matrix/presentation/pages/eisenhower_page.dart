import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_logo.dart';
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

class EisenhowerPage extends StatefulWidget {
  const EisenhowerPage({super.key});

  @override
  State<EisenhowerPage> createState() => _EisenhowerPageState();
}

class _EisenhowerPageState extends State<EisenhowerPage> {
  bool _isCalendarView = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSmall = ResponsiveUtils.isVerySmallPhone(context);
    final spacing = isSmall ? 6.0 : 10.0;
    final padding = isSmall ? 8.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 32),
            const SizedBox(width: 8),
            Text(
              _isCalendarView ? l10n.calendarMode : l10n.eisenhowerMatrix,
              style: TextStyle(fontSize: isSmall ? 16 : null),
            ),
          ],
        ),
        actions: [
          // Nút chuyển đổi View
          IconButton(
            icon: Icon(_isCalendarView ? Icons.grid_view_rounded : Icons.calendar_month_rounded, size: isSmall ? 20 : null),
            tooltip: _isCalendarView ? l10n.matrixMode : l10n.calendarViewMode,
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
          // Nút làm mới thủ công
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: isSmall ? 20 : null),
            tooltip: l10n.reload,
            onPressed: () => context.read<EisenhowerBloc>().add(const LoadTasks()),
          ),
        ],
      ),

      body: BlocBuilder<EisenhowerBloc, EisenhowerState>(
        builder: (context, state) {
          // ── Đang tải ──
          if (state is EisenhowerLoading) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                final aspectRatio = ResponsiveUtils.quadrantAspectRatio(context);
                return GridView.builder(
                  padding: EdgeInsets.all(padding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: isWide ? 0.9 : aspectRatio,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, i) => const QuadrantSkeleton(),
                );
              },
            );
          }

          // ── Có lỗi ──
          if (state is EisenhowerError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(isSmall ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: isSmall ? 40 : 56, color: Colors.redAccent),
                    SizedBox(height: isSmall ? 8 : 12),
                    Text(
                      l10n.errorOccurred,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: isSmall ? 16 : null),
                    ),
                    SizedBox(height: isSmall ? 4 : 8),
                    Text(state.message, textAlign: TextAlign.center, style: TextStyle(fontSize: isSmall ? 12 : null)),
                    SizedBox(height: isSmall ? 12 : 20),
                    FilledButton.icon(
                      onPressed: () => context.read<EisenhowerBloc>().add(const LoadTasks()),
                      icon: Icon(Icons.refresh_rounded, size: isSmall ? 16 : null),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Dữ liệu đã tải xong ──
          if (state is EisenhowerLoaded) {
            if (_isCalendarView) {
              return CalendarViewWidget(tasksByQuadrant: state.tasksByQuadrant);
            }
            return _EisenhowerGrid(state: state);
          }

          // ── Trạng thái khởi tạo (EisenhowerInitial) ──
          return Center(child: Text(l10n.initializing));
        },
      ),

      // FAB mở dialog thêm task mới
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'eisenhower_fab',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<EisenhowerBloc>(),
            child: const AddTaskDialog(initialQuadrant: QuadrantType.doIt),
          ),
        ),
        icon: Icon(Icons.add_rounded, size: isSmall ? 20 : null),
        label: Text(l10n.addTask, style: TextStyle(fontSize: isSmall ? 13 : null)),
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
    final isSmall = ResponsiveUtils.isVerySmallPhone(context);
    final spacing = isSmall ? 6.0 : 10.0;
    final padding = isSmall ? 8.0 : 12.0;

    // Thứ tự hiển thị: Q1 (trên-trái), Q2 (trên-phải), Q3 (dưới-trái), Q4 (dưới-phải)
    final quadrantOrder = [
      QuadrantType.doIt,
      QuadrantType.scheduleIt,
      QuadrantType.delegateIt,
      QuadrantType.eliminateIt,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính aspect ratio theo đúng kích thước còn lại để 4 ô bằng nhau và "full màn".
        final availableWidth = constraints.maxWidth - (padding * 2) - spacing;
        final availableHeight = constraints.maxHeight - (padding * 2) - spacing;
        final tileWidth = availableWidth / 2;
        final tileHeight = availableHeight / 2;
        final aspectRatio = (tileHeight <= 0) ? 0.75 : (tileWidth / tileHeight);

        return GridView.builder(
          padding: EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
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
