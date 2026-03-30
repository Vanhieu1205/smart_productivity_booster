import '../../../../core/usecases/usecase.dart';
import '../../../../features/pomodoro_timer/domain/entities/timer_type.dart';
import '../entities/weekly_stats_entity.dart';
import '../../data/datasources/statistics_local_datasource.dart';

// ============================================================
// GET WEEKLY STATS USE CASE – Domain Layer
// ============================================================
//
// Trách nhiệm: Nhận đầu vào là ngày bắt đầu tuần, gọi data source lấy dữ liệu
// và TÍNH TOÁN để trả về WeeklyStatsEntity.
//
// [Kiến trúc Clean]: Usecase sẽ tổng hợp data raw thành các thông số nghiệp vụ
// cho feature Thống Kê, thay vì bắt UI phải tự vòng lặp cộng trừ.

class GetWeeklyStatsUseCase implements UseCase<WeeklyStatsEntity, DateTime> {
  // Thay vì interface Repository, trong feature nhỏ này ta gọi thẳng LocalDataSource
  final StatisticsLocalDataSource localDataSource;

  GetWeeklyStatsUseCase(this.localDataSource);

  @override
  Future<WeeklyStatsEntity> call(DateTime weekStart) async {
    // 1. Xác định khoảng thời gian đầu cuối của tuần (Từ 0:0:0 ngày đầu đến 23:59:59 ngày thứ 7)
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // 2. Lấy dữ liệu raw (các sessions và số count task)
    final sessions = await localDataSource.getPomodorosByDateRange(start, end);
    final completedTasks = await localDataSource.getCompletedTasksCount(start, end);

    // 3. Tính toán các metric
    final Map<DateTime, int> dailyPomodoros = {};
    int totalFocusMinutes = 0;

    // Khởi tạo map cho cả 7 ngày với giá trị mặc định 0 
    for (int i = 0; i < 7; i++) {
       final day = start.add(Duration(days: i));
       dailyPomodoros[DateTime(day.year, day.month, day.day)] = 0;
    }

    // Duyệt qua tất cả các phiên
    for (var session in sessions) {
      // Bỏ qua các phiên bị gián đoạn (chưa complete) hoặc các timeout không hợp lệ
      if (!session.isCompleted) continue;

      // Tính tổng phút (chỉ tính session làm việc)
      // Dùng typeIndex == 0 để check 'work', hoặc gọi method isWorkSession của entity nếu có.
      // Vì đang dùng model từ Data layer trả về nên kiểu của typeIndex == 0 là work
      // (Dựa theo PomodoroSessionModel)
      bool isWorkSession = session.typeIndex == TimerType.work.index;
      
      if (isWorkSession) {
        // Cộng tổng phút tập trung
        // Lấy thời lượng từ actualDuration hoặc endTime - startTime.
        if (session.endTime != null) {
            final diff = session.endTime!.difference(session.startTime).inMinutes;
            totalFocusMinutes += diff;
        }

        // Đếm pomodoro work cho ngày hôm đó (cắt bỏ phần time để map đúng)
        final sDate = session.startTime;
        final dateKey = DateTime(sDate.year, sDate.month, sDate.day);

        // Nếu ngày đó nằm trong map (thuộc tuần này)
        if (dailyPomodoros.containsKey(dateKey)) {
          dailyPomodoros[dateKey] = dailyPomodoros[dateKey]! + 1;
        }
      }
    }

    // 4. Tìm ngày có số pomodoro nhiều nhất (most productive day)
    DateTime? mostProductiveDay;
    int maxPomos = 0;

    dailyPomodoros.forEach((key, value) {
      if (value > maxPomos) {
        maxPomos = value;
        mostProductiveDay = key;
      }
    });

    // 5. Trả về Entity hoàn chỉnh để màn hình UI đem hiện biểu đồ
    return WeeklyStatsEntity(
      weekStart: start,
      weekEnd: end,
      dailyPomodoros: dailyPomodoros,
      totalFocusMinutes: totalFocusMinutes,
      completedTasks: completedTasks,
      mostProductiveDay: mostProductiveDay,
    );
  }
}
