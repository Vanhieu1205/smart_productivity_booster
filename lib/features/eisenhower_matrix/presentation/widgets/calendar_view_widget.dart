import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/quadrant_type.dart';

class CalendarViewWidget extends StatefulWidget {
  final Map<QuadrantType, List<TaskEntity>> tasksByQuadrant;

  const CalendarViewWidget({super.key, required this.tasksByQuadrant});

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  late final ValueNotifier<List<TaskEntity>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  /// Gom tất cả tasks thành một list và lọc theo ngày
  List<TaskEntity> _getEventsForDay(DateTime day) {
    final allTasks = widget.tasksByQuadrant.values.expand((element) => element).toList();
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<TaskEntity>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<TaskEntity>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              if (value.isEmpty) {
                return const Center(child: Text('Không có công việc nào trong ngày này.'));
              }
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final task = value[index];
                  return ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: null, // Read-only in this view for simplicity
                    ),
                    title: Text(task.title),
                    subtitle: task.dueDate != null ? Text(task.dueDate.toString()) : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
