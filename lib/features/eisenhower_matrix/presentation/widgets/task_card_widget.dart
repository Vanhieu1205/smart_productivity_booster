import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';
import '../../domain/entities/task_label.dart';
import '../bloc/eisenhower_bloc.dart';
import '../bloc/eisenhower_event.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

// ============================================================
// TASK CARD WIDGET – Presentation Layer
// ============================================================
// Widget đại diện cho một Task duy nhất trong danh sách.
// Tính năng:
//   - LongPressDraggable: giữ để kéo thả sang quadrant khác
//   - Checkbox để toggle hoàn thành
//   - Nút xóa
//   - Feedback widget mờ khi đang kéo

class TaskCardWidget extends StatelessWidget {
  final TaskEntity task;

  const TaskCardWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final color = task.quadrant.color;
    final theme = Theme.of(context);

    return GestureDetector(
      // onTap: mở dialog chi tiết task
      onTap: () => _showTaskDetail(context),
      // onLongPress: giữ để chuẩn bị kéo thả
      onLongPress: () {
        // TODO: triển khai menu ngữ cảnh (edit, move, delete) nếu cần
      },
      child: LongPressDraggable<TaskEntity>(
        // Dữ liệu được truyền khi kéo thả: chính là đối tượng task
        data: task,

        // Hiệu ứng kéo: widget hiện ra dưới ngón tay (opacity 0.8 + shadow)
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: ResponsiveUtils.isVerySmallPhone(context) ? 150 : 200,
            child: _buildCardContent(context, color, theme, isDragging: true),
          ),
        ),

        // Widget hiển thị tại vị trí gốc khi đang kéo (mờ đi)
        childWhenDragging: Opacity(
          opacity: 0.35,
          child: _buildCardContent(context, color, theme),
        ),

        // Widget bình thường khi không kéo
        child: _buildCardContent(context, color, theme),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    Color color,
    ThemeData theme, {
    bool isDragging = false,
  }) {
    final isSmall = ResponsiveUtils.isVerySmallPhone(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Responsive values
    final margin = isSmall ? const EdgeInsets.symmetric(vertical: 2) : const EdgeInsets.symmetric(vertical: 4);
    final padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 6)
        : (isTablet ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8) : const EdgeInsets.symmetric(horizontal: 6, vertical: 6));
    final borderRadius = isSmall ? 8.0 : 12.0;
    final iconSize = isSmall ? 14.0 : 16.0;
    final titleFontSize = isSmall ? 11.0 : null;
    final chipFontSize = isSmall ? 8.0 : 10.0;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isDragging
            ? color.withOpacity(0.15)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: isDragging
            ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
            : null,
      ),
      child: Row(
        children: [
          // ── Checkbox hoàn thành ────────────────────────────
          Checkbox(
            value: task.isCompleted,
            activeColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: isDragging
                ? null
                : (_) => context.read<EisenhowerBloc>().add(ToggleComplete(task)),
          ),

          // ── Nội dung task ───────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  task.title,
                  maxLines: isSmall ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? theme.colorScheme.outline : null,
                    fontWeight: FontWeight.w500,
                    fontSize: titleFontSize,
                  ),
                ),
                // Mô tả
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: isSmall ? 9 : null,
                    ),
                  ),
                SizedBox(height: isSmall ? 2 : 4),

                // Chip nhãn
                if (task.label != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        task.label!.name,
                        style: TextStyle(fontSize: chipFontSize, color: Colors.white),
                      ),
                      backgroundColor: task.label!.color,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),

          // ── Nút xóa ────────────────────────────────────────
          if (!isDragging)
            IconButton(
              icon: Icon(Icons.close_rounded, size: iconSize, color: theme.colorScheme.outline),
              visualDensity: VisualDensity.compact,
              tooltip: AppLocalizations.of(context)!.deleteTask,
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
    );
  }

  /// Hiện Dialog xác nhận trước khi xóa (tránh xóa nhầm)
  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteTask),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<EisenhowerBloc>().add(DeleteTask(task.id));
            },
            child: Text(l10n.deleteTask),
          ),
        ],
      ),
    );
  }

  /// Hiện Dialog chi tiết task khi bấm vào
  void _showTaskDetail(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = task.quadrant.color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header với icon quadrant ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(task.quadrant.icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getQuadrantName(l10n, task.quadrant),
                              style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Nội dung chi tiết ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mô tả
                    if (task.description.isNotEmpty) ...[
                      _DetailRow(
                        icon: Icons.notes_rounded,
                        label: l10n.taskDescription,
                        value: task.description,
                        color: color,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Ngày giờ đến hạn
                    if (task.dueDate != null) ...[
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: l10n.dueDate,
                        value: _formatDateTime(task.dueDate!),
                        color: color,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Nhãn
                    if (task.label != null) ...[
                      _DetailRow(
                        icon: Icons.label_rounded,
                        label: l10n.taskLabels,
                        value: task.label!.name,
                        color: color,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Ghi chú
                    if (task.notes != null && task.notes!.isNotEmpty) ...[
                      _DetailRow(
                        icon: Icons.sticky_note_2_rounded,
                        label: l10n.notes,
                        value: task.notes!,
                        color: color,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tiến độ Pomodoro
                    _DetailRow(
                      icon: Icons.timer_rounded,
                      label: l10n.pomodoroTimer,
                      value: l10n.pomodoroProgress(task.completedPomodoros, task.estimatedPomodoros),
                      color: color,
                    ),
                  ],
                ),
              ),

              // ── Nút đóng ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.done),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getQuadrantName(AppLocalizations l10n, QuadrantType type) {
    switch (type) {
      case QuadrantType.doIt: return l10n.quadrant1;
      case QuadrantType.scheduleIt: return l10n.quadrant2;
      case QuadrantType.delegateIt: return l10n.quadrant3;
      case QuadrantType.eliminateIt: return l10n.quadrant4;
    }
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }
}

/// Widget hiển thị một dòng chi tiết
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
