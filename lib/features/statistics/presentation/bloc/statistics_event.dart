import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Nạp dữ liệu thống kê của tuần hiện tại (hoặc tuần được chỉ định nếu có date)
class LoadWeeklyStats extends StatisticsEvent {
  final DateTime? date;

  const LoadWeeklyStats({this.date});

  @override
  List<Object?> get props => [date];
}

/// Thay đổi tuần: direction = -1 (tuần trước), direction = 1 (tuần sau)
class ChangeWeek extends StatisticsEvent {
  final int direction;

  const ChangeWeek(this.direction);

  @override
  List<Object?> get props => [direction];
}

/// Nạp dữ liệu thống kê của 30 ngày gần nhất (cho tab Tháng)
class LoadMonthlyStats extends StatisticsEvent {
  const LoadMonthlyStats();
}
