import 'package:equatable/equatable.dart';
import '../../domain/entities/weekly_stats_entity.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu, chưa có dữ liệu và đang load
class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

/// Dữ liệu đã load thành công
class StatisticsLoaded extends StatisticsState {
  final WeeklyStatsEntity weeklyStats;

  /// Dữ liệu 30 ngày cho tab Tháng (tính động từ Hive, không cần reload)
  final List<int> monthlyDailyPomos;

  const StatisticsLoaded({
    required this.weeklyStats,
    this.monthlyDailyPomos = const [],
  });

  @override
  List<Object?> get props => [weeklyStats, monthlyDailyPomos];
}

/// Có lỗi xảy ra trong quá trình load
class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
