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

bool _isDoItQuadrant(QuadrantType type) => type == QuadrantType.doIt;

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

  // Ngày và giờ đến hạn
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 23, minute: 59);

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

  /// Lấy DateTime hoàn chỉnh từ ngày và giờ đã chọn
  DateTime _getDueDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  /// Kiểm tra xem có deadline không
  bool get _hasDeadline {
    if (_selectedQuadrant == QuadrantType.doIt) {
      // Do It: chỉ cần giờ, mặc định là cuối ngày nếu chưa đổi
      // Kiểm tra cả ngày và giờ
      final isToday = _isSameDay(_selectedDate, DateTime.now());
      final isEndOfDay = _selectedTime.hour == 23 && _selectedTime.minute == 59;
      return !(isToday && isEndOfDay);
    }
    // Các quadrant khác: luôn cần deadline
    return true;
  }

  /// Kiểm tra 2 DateTime có cùng ngày không
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
      dueDate: _hasDeadline ? _getDueDateTime() : null,
    );

    // Gửi Event AddTask vào BLoC để xử lý
    context.read<EisenhowerBloc>().add(AddTask(newTask));
    Navigator.of(context).pop();
  }

  /// Mở date picker
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Mở time picker
  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
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
                  if (q != null) {
                    setState(() {
                      _selectedQuadrant = q;
                      // Reset về mặc định khi đổi quadrant sang Do It
                      if (q == QuadrantType.doIt) {
                        _selectedDate = DateTime.now();
                        _selectedTime = const TimeOfDay(hour: 23, minute: 59);
                      }
                    });
                  }
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

              const SizedBox(height: 16),

              // ── Chọn ngày/giờ đến hạn ────────────────────────
              Text(l10n.dueDateTime, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                l10n.dueDateInfo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),

              // Tab "Làm ngay" → chỉ chọn giờ trong ngày hôm nay
              if (_isDoItQuadrant(_selectedQuadrant)) ...[
                // Chỉ chọn giờ - ngày mặc định là hôm nay
                InkWell(
                  onTap: () => _selectTime(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: quadrantColor, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          l10n.todayOnly(
                            _selectedTime.hour.toString().padLeft(2, '0'),
                            _selectedTime.minute.toString().padLeft(2, '0'),
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Icon(Icons.edit, color: theme.colorScheme.primary, size: 18),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // 3 tab còn lại → chọn ngày VÀ giờ
                Row(
                  children: [
                    // Chọn ngày
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: quadrantColor, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chọn giờ
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: quadrantColor, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
