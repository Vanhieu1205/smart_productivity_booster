import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';
import '../bloc/eisenhower_bloc.dart';
import '../bloc/eisenhower_event.dart';
import 'task_card_widget.dart';
import 'add_task_dialog.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

String _getQuadrantName(AppLocalizations l10n, QuadrantType type) {
  switch (type) {
    case QuadrantType.doIt: return l10n.quadrant1;
    case QuadrantType.scheduleIt: return l10n.quadrant2;
    case QuadrantType.delegateIt: return l10n.quadrant3;
    case QuadrantType.eliminateIt: return l10n.quadrant4;
  }
}

// ============================================================
// QUADRANT WIDGET – Presentation Layer
// ============================================================
// Đại diện cho một ô (quadrant) trong lưới 2×2 của Ma trận Eisenhower.
// Tính năng:
//   - Header màu sắc riêng biệt per quadrant
//   - DragTarget<TaskEntity>: Chấp nhận task kéo thả vào
//   - Hiệu ứng highlight khi task đang được kéo lên trên ô
//   - ListView các TaskCardWidget bên trong

class QuadrantWidget extends StatefulWidget {
  final QuadrantType quadrant;
  final List<TaskEntity> tasks;

  const QuadrantWidget({
    super.key,
    required this.quadrant,
    required this.tasks,
  });

  @override
  State<QuadrantWidget> createState() => _QuadrantWidgetState();
}

class _QuadrantWidgetState extends State<QuadrantWidget> {
  // Trạng thái khi task đang được kéo bên trên ô này (để đổi màu nền)
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.quadrant;
    final completedCount = widget.tasks.where((t) => t.isCompleted).length;

    return DragTarget<TaskEntity>(
      // Chấp nhận tất cả TaskEntity trừ task đã thuộc quadrant này
      onWillAcceptWithDetails: (details) => details.data.quadrant != widget.quadrant,

      // Khi task được thả vào ô này
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        // Gửi Event MoveTask với quadrant đích mới
        context.read<EisenhowerBloc>().add(
              MoveTask(taskId: details.data.id, newQuadrant: widget.quadrant),
            );
      },

      onLeave: (_) => setState(() => _isDragOver = false),

      onMove: (_) {
        if (!_isDragOver) setState(() => _isDragOver = true);
      },

      builder: (context, candidateData, rejectedData) {
        // Xác định nền highlight khi đang kéo vào
        final bgColor = _isDragOver
            ? q.color.withOpacity(0.15)
            : q.lightColor.withOpacity(0.5);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDragOver ? q.color : q.color.withOpacity(0.25),
              width: _isDragOver ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header của quadrant ─────────────────────────
              _QuadrantHeader(
                quadrant: q,
                totalCount: widget.tasks.length,
                completedCount: completedCount,
                isDragOver: _isDragOver,
              ),

              // ── Danh sách tasks ─────────────────────────────
              Expanded(
                child: widget.tasks.isEmpty
                    ? _EmptyQuadrant(quadrant: q, isDragOver: _isDragOver)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        itemCount: widget.tasks.length,
                        itemBuilder: (_, i) => TaskCardWidget(task: widget.tasks[i]),
                      ),
              ),

              // ── Nút thêm task nhanh ────────────────────────
              _AddTaskButton(quadrant: q),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Header của Quadrant
// ──────────────────────────────────────────────────────────────
class _QuadrantHeader extends StatelessWidget {
  final QuadrantType quadrant;
  final int totalCount;
  final int completedCount;
  final bool isDragOver;

  const _QuadrantHeader({
    required this.quadrant,
    required this.totalCount,
    required this.completedCount,
    required this.isDragOver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: quadrant.color.withOpacity(isDragOver ? 0.25 : 0.12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(
            children: [
              // Icon đại diện
              Icon(quadrant.icon, size: 18, color: quadrant.color),
              const SizedBox(width: 8),

              // Tên quadrant + mô tả
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getQuadrantName(l10n, quadrant),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: quadrant.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      quadrant.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: quadrant.color.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Thống kê số task hoàn thành / tổng số task trong quadrant
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Thanh progress thể hiện tỷ lệ hoàn thành trong quadrant
        LinearProgressIndicator(
          value: totalCount == 0 ? 0 : completedCount / totalCount,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 3,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Trạng thái rỗng khi không có task
// ──────────────────────────────────────────────────────────────
class _EmptyQuadrant extends StatelessWidget {
  final QuadrantType quadrant;
  final bool isDragOver;

  const _EmptyQuadrant({required this.quadrant, required this.isDragOver});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDragOver ? Icons.add_circle_outline_rounded : Icons.inbox_outlined,
            size: 32,
            color: quadrant.color.withOpacity(isDragOver ? 0.8 : 0.3),
          ),
          const SizedBox(height: 6),
          Text(
            isDragOver ? l10n.dropTaskHere : l10n.noTask,
            style: TextStyle(
              color: quadrant.color.withOpacity(isDragOver ? 0.8 : 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Nút thêm task nhanh ở cuối mỗi quadrant
// ──────────────────────────────────────────────────────────────
class _AddTaskButton extends StatelessWidget {
  final QuadrantType quadrant;

  const _AddTaskButton({required this.quadrant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<EisenhowerBloc>(),
          child: AddTaskDialog(initialQuadrant: quadrant),
        ),
      ),
      icon: Icon(Icons.add_rounded, size: 16, color: quadrant.color),
      label: Text(
        l10n.addTask,
        style: TextStyle(color: quadrant.color, fontSize: 12),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
        ),
      ),
    );
  }
}
