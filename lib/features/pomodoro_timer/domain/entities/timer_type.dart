// ============================================================
// TIMER TYPE – Domain Entity
// ============================================================
// 
// Enum định nghĩa 3 loại phiên Pomodoro.
// Tách riêng file để có thể import độc lập trong cả Domain và Data layer.
//
// [Clean Architecture] Enum dùng trong Entity được giữ tại Domain Layer
// để không bị phụ thuộc vào bất kỳ framework nào (thuần Dart).

/// Loại phiên đếm giờ trong kỹ thuật Pomodoro Technique
enum TimerType {
  /// Phiên làm việc tập trung – mặc định 25 phút
  work,

  /// Nghỉ ngắn giữa các pomodoro – mặc định 5 phút
  shortBreak,

  /// Nghỉ dài sau mỗi 4 pomodoro – mặc định 15 phút
  longBreak,
}

extension TimerTypeExtension on TimerType {
  /// Thời lượng mặc định theo kỹ thuật Pomodoro chuẩn
  Duration get duration {
    switch (this) {
      case TimerType.work:
        return const Duration(minutes: 25);
      case TimerType.shortBreak:
        return const Duration(minutes: 5);
      case TimerType.longBreak:
        return const Duration(minutes: 15);
    }
  }

  /// Nhãn hiển thị tiếng Việt cho người dùng
  String get label {
    switch (this) {
      case TimerType.work:
        return 'Làm Việc';
      case TimerType.shortBreak:
        return 'Nghỉ Ngắn';
      case TimerType.longBreak:
        return 'Nghỉ Dài';
    }
  }

  /// Mô tả ngắn kèm thời lượng
  String get labelWithDuration {
    final mins = duration.inMinutes;
    return '$label ($mins phút)';
  }

  /// Số phút của phiên (thường dùng trong UI hiển thị)
  int get minutes => duration.inMinutes;
}
