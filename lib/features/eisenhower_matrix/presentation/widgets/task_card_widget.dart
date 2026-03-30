import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      // onTap: mở màn hình chi tiết task
      onTap: () {
        // TODO: Navigator.push tới TaskDetailPage (truyền TaskEntity)
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (_) => TaskDetailPage(task: task),
        // ));
      },
      // onLongPress: giữ để chuẩn bị mở menu / kéo thả (giữ nguyên behavior sau này)
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
            width: 200,
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDragging
            ? color.withOpacity(0.15)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
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
                // Tiêu đề – gạch ngang nếu đã hoàn thành
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? theme.colorScheme.outline : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Mô tả (nếu có)
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                const SizedBox(height: 4),

                // Hiển thị Chip nhỏ nếu task có nhãn (label)
                if (task.label != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        task.label!.name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
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
              icon: Icon(Icons.close_rounded, size: 16, color: theme.colorScheme.outline),
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
              // Gửi Event DeleteTask vào BLoC
              context.read<EisenhowerBloc>().add(DeleteTask(task.id));
            },
            child: Text(l10n.deleteTask),
          ),
        ],
      ),
    );
  }
}
