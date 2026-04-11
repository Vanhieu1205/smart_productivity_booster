import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';
import '../../domain/usecases/get_weekly_stats_usecase.dart';
import '../../../pomodoro_timer/data/models/pomodoro_session_model.dart';

// ============================================================
// STATISTICS BLOC – Presentation Layer
// ============================================================
//
// Trách nhiệm: Quản lý luồng xử lý số liệu thống kê.
// Gắn liền sự kiện từ UI (load, đổi tuần) với UseCase tính toán.
// Và phản hồi lại qua State.

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetWeeklyStatsUseCase getWeeklyStats;

  /// Lưu trữ ngày bắt đầu của tuần đang được xem hiện tại
  DateTime _currentWeekStart = _getStartOfWeek(DateTime.now());

  StatisticsBloc({required this.getWeeklyStats}) : super(const StatisticsLoading()) {
    on<LoadWeeklyStats>(_onLoadWeeklyStats);
    on<ChangeWeek>(_onChangeWeek);
    on<LoadMonthlyStats>(_onLoadMonthlyStats);
  }

  Future<void> _onLoadWeeklyStats(
      LoadWeeklyStats event, Emitter<StatisticsState> emit) async {
    emit(const StatisticsLoading());
    try {
      if (event.date != null) {
        _currentWeekStart = _getStartOfWeek(event.date!);
      }

      final weeklyStats = await getWeeklyStats(_currentWeekStart);
      final monthlyDailyPomos = _computeMonthlyData();

      emit(StatisticsLoaded(
        weeklyStats: weeklyStats,
        monthlyDailyPomos: monthlyDailyPomos,
      ));
    } catch (e) {
      emit(StatisticsError('Không thể tải lỗi thống kê: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMonthlyStats(
      LoadMonthlyStats event, Emitter<StatisticsState> emit) async {
    if (state is StatisticsLoaded) {
      final current = state as StatisticsLoaded;
      final monthlyDailyPomos = _computeMonthlyData();
      emit(StatisticsLoaded(
        weeklyStats: current.weeklyStats,
        monthlyDailyPomos: monthlyDailyPomos,
      ));
    }
  }

  List<int> _computeMonthlyData() {
    final box = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
    final now = DateTime.now();
    final thirtyDaysAgo = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 29));

    final List<int> dailyPomos = List.filled(30, 0);
    for (final session in box.values) {
      if (!session.isCompleted || session.typeIndex != 0) continue;
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      if (!sessionDate.isBefore(thirtyDaysAgo)) {
        final diff = sessionDate.difference(thirtyDaysAgo).inDays;
        if (diff >= 0 && diff < 30) {
          dailyPomos[diff]++;
        }
      }
    }
    return dailyPomos;
  }

  Future<void> _onChangeWeek(ChangeWeek event, Emitter<StatisticsState> emit) async {
    // direction = -1 (lui 1 tuần), = 1 (tiến 1 tuần)
    final modifiedDate = _currentWeekStart.add(Duration(days: event.direction * 7));
    _currentWeekStart = _getStartOfWeek(modifiedDate);

    // Gửi sự kiện lặp vòng để load data của tuần mới
    add(LoadWeeklyStats(date: _currentWeekStart));
  }

  /// Tiện ích: Lùi ngày về thứ 2 của tuần chứa ngày truyền vào
  static DateTime _getStartOfWeek(DateTime day) {
    // day.weekday trả về int: 1 là Thứ Hai, 7 là Chủ Nhật
    final daysToSubtract = day.weekday - 1;
    final monday = day.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
