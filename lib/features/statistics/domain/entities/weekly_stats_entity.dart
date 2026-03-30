import 'package:equatable/equatable.dart';

// ============================================================
// WEEKLY STATS ENTITY – Domain Layer
// ============================================================
//
// Entity chứa dữ liệu thống kê cho một tuần làm việc.
// Không phụ thuộc vào framework, chỉ chứa logic cốt lõi.

class WeeklyStatsEntity extends Equatable {
  /// Ngày bắt đầu của tuần thống kê (thường là Thứ Hai)
  final DateTime weekStart;

  /// Ngày kết thúc của tuần thống kê (thường là Chủ Nhật)
  final DateTime weekEnd;

  /// Map thống kê số phiên Pomodoro hoàn thành theo từng ngày trong tuần.
  /// Key: Ngày (DateTime - chỉ lấy phần Date, bỏ Time)
  /// Value: Số lượng phiên Pomodoro (work) đã hoàn thành
  final Map<DateTime, int> dailyPomodoros;

  /// Tổng số phút tập trung (chỉ tính thời gian của các phiên 'work')
  final int totalFocusMinutes;

  /// Số Task đã được đánh dấu hoàn thành (isCompleted = true) trong tuần này
  final int completedTasks;

  /// Ngày có số phiên Pomodoro (work) nhiều nhất trong tuần.
  /// Có thể null nếu chưa có phiên nào trong tuần.
  final DateTime? mostProductiveDay;

  const WeeklyStatsEntity({
    required this.weekStart,
    required this.weekEnd,
    required this.dailyPomodoros,
    required this.totalFocusMinutes,
    required this.completedTasks,
    this.mostProductiveDay,
  });

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        dailyPomodoros,
        totalFocusMinutes,
        completedTasks,
        mostProductiveDay,
      ];
}
