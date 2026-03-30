import 'package:flutter_bloc/flutter_bloc.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';
import '../../domain/usecases/get_weekly_stats_usecase.dart';

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
  }

  Future<void> _onLoadWeeklyStats(
      LoadWeeklyStats event, Emitter<StatisticsState> emit) async {
    emit(const StatisticsLoading());
    try {
      // Xác định tuần: Nếu có ngày do UI truyền thì lấy ngày đó, không thì dùng ngày hiện tại
      if (event.date != null) {
        _currentWeekStart = _getStartOfWeek(event.date!);
      }

      // Gọi UserCase để tính toán và lấy dữ liệu Entity
      final weeklyStats = await getWeeklyStats(_currentWeekStart);

      // Đẩy dữ liệu ra UI
      emit(StatisticsLoaded(weeklyStats));
    } catch (e) {
      emit(StatisticsError('Không thể tải lỗi thống kê: ${e.toString()}'));
    }
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
