import 'package:equatable/equatable.dart';

/// Entity đại diện cho trạng thái của một phiên Pomodoro
class PomodoroSession extends Equatable {
  final String? linkedTaskId; // ID của task đang được làm (nếu có)
  final int workMinutes;       // Thời gian làm việc (phút)
  final int shortBreakMinutes; // Thời gian nghỉ ngắn (phút)
  final int longBreakMinutes;  // Thời gian nghỉ dài (phút)
  final int sessionsUntilLongBreak; // Số session trước khi nghỉ dài
  final int completedSessionsToday; // Số session đã hoàn thành hôm nay

  const PomodoroSession({
    this.linkedTaskId,
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsUntilLongBreak = 4,
    this.completedSessionsToday = 0,
  });

  PomodoroSession copyWith({
    String? linkedTaskId,
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsUntilLongBreak,
    int? completedSessionsToday,
  }) {
    return PomodoroSession(
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      completedSessionsToday: completedSessionsToday ?? this.completedSessionsToday,
    );
  }

  @override
  List<Object?> get props => [
        linkedTaskId, workMinutes, shortBreakMinutes,
        longBreakMinutes, sessionsUntilLongBreak, completedSessionsToday,
      ];
}
