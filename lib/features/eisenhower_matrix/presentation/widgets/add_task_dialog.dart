import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/quadrant_type.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_label.dart';
import '../bloc/eisenhower_bloc.dart';
import '../bloc/eisenhower_event.dart';
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
// ADD TASK DIALOG – Presentation Layer
// ============================================================
// Dialog thu thập thông tin từ người dùng để thêm Task mới.
// Sử dụng StatefulWidget vì cần quản lý state cục bộ (TextController, Dropdown).

class AddTaskDialog extends StatefulWidget {
  /// Quadrant được chọn sẵn khi mở dialog (người dùng có thể đổi)
  final QuadrantType initialQuadrant;

  const AddTaskDialog({super.key, required this.initialQuadrant});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  // Controller để lấy text người dùng nhập
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Quadrant được chọn trong Dropdown
  late QuadrantType _selectedQuadrant;

  // Nhãn Task được chọn trong Dropdown (có thể null)
  TaskLabel? _selectedLabel;

  @override
  void initState() {
    super.initState();
    _selectedQuadrant = widget.initialQuadrant;
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi dialog đóng
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Tạo Task mới với ID duy nhất bằng uuid
    final newTask = TaskEntity(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      quadrant: _selectedQuadrant,
      createdAt: DateTime.now(),
      label: _selectedLabel,
    );

    // Gửi Event AddTask vào BLoC để xử lý
    context.read<EisenhowerBloc>().add(AddTask(newTask));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quadrantColor = _selectedQuadrant.color;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          // Icon màu thay đổi theo quadrant được chọn
          Icon(_selectedQuadrant.icon, color: quadrantColor),
          const SizedBox(width: 10),
          Text(l10n.addTask),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Tiêu đề task ─────────────────────────────────
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.taskTitle,
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.cannotBeEmpty : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // ── Mô tả task ───────────────────────────────────
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: l10n.taskDescription,
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // ── Chọn Quadrant ────────────────────────────────
              Text(l10n.classify, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<QuadrantType>(
                value: _selectedQuadrant,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.grid_view_rounded, color: quadrantColor),
                ),
                items: QuadrantType.values.map((q) {
                  return DropdownMenuItem(
                    value: q,
                    child: Row(
                      children: [
                        Icon(q.icon, size: 18, color: q.color),
                        const SizedBox(width: 8),
                        Text(_getQuadrantName(l10n, q)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (q) {
                  if (q != null) setState(() => _selectedQuadrant = q);
                },
              ),

              const SizedBox(height: 16),

              // ── Chọn nhãn Task (tùy chọn) ─────────────────────
              Text(l10n.taskLabels, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<TaskLabel?>(
                value: _selectedLabel,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                items: [
                  // Item đầu tiên: "Không gắn nhãn"
                  DropdownMenuItem<TaskLabel?>(
                    value: null,
                    child: Text(l10n.noLabel),
                  ),
                  ...TaskLabel.values.map(
                    (label) => DropdownMenuItem<TaskLabel?>(
                      value: label,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: label.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(label.name),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedLabel = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(l10n.save),
        ),
      ],
    );
  }
}
