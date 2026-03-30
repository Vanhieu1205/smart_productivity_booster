import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';
import '../../domain/entities/task_label.dart';
import 'package:smart_productivity_booster/l10n/app_localizations.dart';

/// Màn hình chi tiết Task
/// - Hiển thị thông tin đầy đủ của Task (quadrant, label, deadline, pomodoro)
/// - Cho phép người dùng xem và chỉnh sửa ghi chú (notes)
/// - Có action Edit / Delete trên AppBar
class TaskDetailPage extends StatefulWidget {
  final TaskEntity task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TaskEntity _task;
  late TextEditingController _notesController;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _notesController = TextEditingController(text: _task.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final quadrantColor = _task.quadrant.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Nút Edit ghi chú – chuyển sang chế độ chỉnh sửa
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: l10n.editNotes,
            onPressed: () {
              setState(() {
                _isEditingNotes = true;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.deleteTaskLabel,
            onPressed: () {
              // TODO: Gửi event xóa qua BLoC nếu cần
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Quadrant chip ─────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      _quadrantLabelL10n(_task.quadrant, l10n),
                      style: const TextStyle(color: Colors.white),
                    ),
                    avatar: Icon(
                      _task.quadrant.icon,
                      size: 16,
                      color: Colors.white,
                    ),
                    backgroundColor: quadrantColor,
                  ),

                  // Nhãn Task (nếu có)
                  if (_task.label != null)
                    Chip(
                      label: Text(
                        _task.label!.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _task.label!.color,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Deadline ─────────────────────────────────────
              if (_task.dueDate != null)
                Row(
                  children: [
                    const Icon(Icons.event_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.dueDate}: ${_task.dueDate}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // ── Ghi chú (Notes) ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.notes,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (_isEditingNotes)
                    TextButton.icon(
                      onPressed: _saveNotes,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(l10n.save),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildNotesField(theme, l10n),

              const SizedBox(height: 24),

              // ── Pomodoro counter ─────────────────────────────
              Row(
                children: [
                  const Icon(Icons.timer_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.pomodoroTimer}: ${_task.completedPomodoros}/${_task.estimatedPomodoros}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TextField ghi chú – hỗ trợ chế độ chỉ đọc và chế độ chỉnh sửa
  Widget _buildNotesField(ThemeData theme, AppLocalizations l10n) {
    if (!_isEditingNotes) {
      final text = (_task.notes ?? '').trim();
      if (text.isEmpty) {
        return Text(
          l10n.noNotesYet,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        );
      }
      return Text(
        text,
        style: theme.textTheme.bodyMedium,
      );
    }

    return TextField(
      controller: _notesController,
      autofocus: true,
      maxLines: null,
      minLines: 4,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: l10n.enterTaskNotes,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveNotes() {
    setState(() {
      _task = _task.copyWith(notes: _notesController.text);
      _isEditingNotes = false;
    });
    // TODO: Cập nhật xuống BLoC/Hive (ví dụ: gửi UpdateTask)
  }

  String _quadrantLabelL10n(QuadrantType type, AppLocalizations l10n) {
    switch (type) {
      case QuadrantType.doIt:
        return l10n.quadrant1;
      case QuadrantType.scheduleIt:
        return l10n.quadrant2;
      case QuadrantType.delegateIt:
        return l10n.quadrant3;
      case QuadrantType.eliminateIt:
        return l10n.quadrant4;
    }
  }
}

