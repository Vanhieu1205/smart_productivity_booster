// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get onboardingTitle1 => 'Quản lý công việc thông minh';

  @override
  String get onboardingDesc1 =>
      'Phân loại hiệu quả mọi việc theo Ma trận Eisenhower để biết đâu là điều thực sự quan trọng.';

  @override
  String get onboardingTitle2 => 'Tập trung với Pomodoro';

  @override
  String get onboardingDesc2 =>
      'Áp dụng kỹ thuật 25 phút giúp tăng cường sự tập trung và giảm thiểu mệt mỏi.';

  @override
  String get onboardingTitle3 => 'Theo dõi tiến độ';

  @override
  String get onboardingDesc3 =>
      'Xem thống kê chi tiết mỗi tuần để luôn chủ động điều chỉnh thói quen làm việc.';

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get onboardingNext => 'Tiếp theo';

  @override
  String get onboardingGetStarted => 'Bắt đầu ngay';

  @override
  String get loginTitle => 'Đăng Nhập';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Mật khẩu';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get loginNoAccount => 'Chưa có tài khoản? Đăng ký ngay';

  @override
  String get registerTitle => 'Đăng ký tài khoản';

  @override
  String get registerUsername => 'Tên hiển thị';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Mật khẩu';

  @override
  String get registerConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get registerHasAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutConfirm =>
      'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?';

  @override
  String get logoutCancel => 'Hủy';

  @override
  String get logoutTitle => 'Xác nhận đăng xuất';

  @override
  String get exitTitle => 'Xác nhận thoát';

  @override
  String get exitConfirm => 'Bạn có muốn thoát ứng dụng không?';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get eisenhowerMatrix => 'Ma trận Eisenhower';

  @override
  String get matrix => 'Ma trận';

  @override
  String get urgent => 'Khẩn cấp';

  @override
  String get important => 'Quan trọng';

  @override
  String get notUrgent => 'Không khẩn cấp';

  @override
  String get notImportant => 'Không quan trọng';

  @override
  String get quadrant1 => 'Làm ngay';

  @override
  String get quadrant2 => 'Lên lịch';

  @override
  String get quadrant3 => 'Ủy thác';

  @override
  String get quadrant4 => 'Loại bỏ';

  @override
  String get addTask => 'Thêm công việc';

  @override
  String get editTask => 'Sửa công việc';

  @override
  String get deleteTask => 'Xóa công việc';

  @override
  String get deleteTaskLabel => 'Xóa công việc này';

  @override
  String get taskTitle => 'Tên công việc';

  @override
  String get taskDescription => 'Mô tả';

  @override
  String get confirmDelete => 'Bạn có chắc muốn xóa công việc này không?';

  @override
  String get taskCompleted => 'Đã hoàn thành';

  @override
  String get cannotBeEmpty => 'Trường này không được để trống';

  @override
  String get classify => 'Phân loại';

  @override
  String get taskLabels => 'Nhãn';

  @override
  String get noLabel => 'Không nhãn';

  @override
  String get dropTaskHere => 'Thả công việc vào đây';

  @override
  String get noTask => 'Không có công việc';

  @override
  String get pomodoroTimer => 'Đồng hồ Pomodoro';

  @override
  String get workTime => 'Thời gian làm việc';

  @override
  String get shortBreak => 'Nghỉ ngắn';

  @override
  String get longBreak => 'Nghỉ dài';

  @override
  String get startTimer => 'Bắt đầu';

  @override
  String get pauseTimer => 'Tạm dừng';

  @override
  String get resumeTimer => 'Tiếp tục';

  @override
  String get resetTimer => 'Đặt lại';

  @override
  String get skipPhase => 'Bỏ qua giai đoạn';

  @override
  String get pomodoroComplete =>
      'Tuyệt vời! Bạn đã hoàn thành một phiên làm việc.';

  @override
  String get breakComplete =>
      'Thời gian nghỉ đã hết! Sẵn sàng quay lại làm việc chưa?';

  @override
  String get pomodoroCount => 'Số Pomodoro';

  @override
  String get streak => 'Chuỗi hiệu suất';

  @override
  String get startPomodoro => 'Bắt đầu Pomodoro';

  @override
  String get focusMode => 'Chế độ tập trung';

  @override
  String get phaseComplete => 'Hoàn thành giai đoạn!';

  @override
  String get focusHint => 'Giữ tập trung! Làm việc chăm chỉ vào công việc này.';

  @override
  String get breakHint => 'Nghỉ ngơi một chút. Bạn đã xứng đáng!';

  @override
  String get longBreakHint =>
      'Làm tốt lắm! Nghỉ ngơi lâu hơn để nạp lại năng lượng.';

  @override
  String get statistics => 'Thống kê';

  @override
  String get weeklyStats => 'Thống kê Tuần';

  @override
  String get totalPomodoros => 'Tổng số Pomodoro';

  @override
  String get focusMinutes => 'Số phút tập trung';

  @override
  String get completedTasks => 'Công việc đã xong';

  @override
  String get mostProductiveDay => 'Ngày năng suất nhất';

  @override
  String get noDataThisWeek => 'Chưa có dữ liệu tuần này';

  @override
  String get previousWeek => 'Tuần trước';

  @override
  String get nextWeek => 'Tuần sau';

  @override
  String get week => 'Tuần';

  @override
  String get month => 'Tháng';

  @override
  String get shareStats => 'Chia sẻ thống kê';

  @override
  String get refresh => 'Làm mới';

  @override
  String get cannotCaptureImage => 'Không thể chụp ảnh';

  @override
  String get errorProcessingImage => 'Lỗi xử lý ảnh';

  @override
  String get shareText => 'Xem thống kê năng suất của tôi!';

  @override
  String get errorSharing => 'Lỗi chia sẻ';

  @override
  String get days => 'ngày';

  @override
  String get settings => 'Cài đặt';

  @override
  String get darkMode => 'Chế độ màn hình tối (Dark Mode)';

  @override
  String get language => 'Ngôn ngữ (Language)';

  @override
  String get vietnamese => 'Tiếng Việt (Mặc định)';

  @override
  String get english => 'English';

  @override
  String get about => 'Về ứng dụng';

  @override
  String get appVersion => 'Phiên bản';

  @override
  String get developerName => 'Tên Sinh Viên: Phạm Văn Hiệu';

  @override
  String get appName => 'Smart Productivity Booster';

  @override
  String get developedBy => 'Phát triển bởi';

  @override
  String get studentId => 'Mã số sinh viên';

  @override
  String get graduationProject => 'Đồ án thực tập tốt nghiệp';

  @override
  String get save => 'Lưu';

  @override
  String get done => 'Xong';

  @override
  String get error => 'Lỗi';

  @override
  String get success => 'Thành công';

  @override
  String get cannotLoadSettings => 'Không thể tải cài đặt';

  @override
  String get notificationSound => 'Âm thanh thông báo';

  @override
  String get playSoundOnComplete => 'Phát âm thanh khi hẹn giờ kết thúc';

  @override
  String get pomodoroGoal => 'Mục tiêu Pomodoro';

  @override
  String get dailyGoal => 'Mục tiêu hàng ngày';

  @override
  String get pomodoroPerDay => 'pomodoro/ngày';

  @override
  String get currentStreak => 'Chuỗi hiện tại';

  @override
  String get daysShort => 'ngày';

  @override
  String get streakRecord => 'Kỷ lục chuỗi';

  @override
  String get achievements => 'Thành tựu';

  @override
  String get viewAchievements => 'Xem thành tựu';

  @override
  String get checkAchievements => 'Kiểm tra thành tựu của bạn';

  @override
  String get dataBackup => 'Sao lưu dữ liệu';

  @override
  String get backupRestore => 'Sao lưu & Phục hồi';

  @override
  String get exportData => 'Xuất dữ liệu';

  @override
  String get shareBackupFile => 'Chia sẻ file sao lưu sang thiết bị khác';

  @override
  String get importData => 'Nhập dữ liệu';

  @override
  String get restoreFromBackup => 'Phục hồi từ file sao lưu';

  @override
  String get exportSuccess => 'Xuất dữ liệu thành công';

  @override
  String get exportError => 'Lỗi xuất dữ liệu';

  @override
  String get confirmImportData => 'Xác nhận nhập dữ liệu';

  @override
  String get importWarning =>
      'Điều này sẽ thay thế tất cả dữ liệu hiện tại. Tiếp tục?';

  @override
  String get continueText => 'Tiếp tục';

  @override
  String get importSuccess => 'Nhập dữ liệu thành công';

  @override
  String get importError => 'Lỗi nhập dữ liệu';

  @override
  String get dashboard => 'Bảng điều khiển';

  @override
  String get today => 'Hôm nay';

  @override
  String get todaySubtitle => 'Sự tập trung của bạn hôm nay';

  @override
  String get estimated => 'Ước tính';

  @override
  String get prioritiesToday => 'Ưu tiên hôm nay';

  @override
  String get noTasksInQuadrant => 'Không có công việc trong góc phần tư này';

  @override
  String get achievementsTitle => 'Thành tựu';

  @override
  String get totalAchievements => 'thành tựu tổng cộng';

  @override
  String get achievementUnlocked => 'Đã mở khóa thành tựu!';

  @override
  String get goToMatrixToComplete => 'Vào trang Ma trận để hoàn thành task này';

  @override
  String pomodoroProgress(int completed, int total) {
    return 'Pomodoro: $completed/$total';
  }

  @override
  String taskCount(int count) {
    return '$count công việc';
  }

  @override
  String get greetingNight => 'Chào buổi tối muộn';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi trưa';

  @override
  String get greetingEvening => 'Chào buổi chiều';

  @override
  String get greetingLateEvening => 'Chào buổi tối';

  @override
  String get greetingLateNight => 'Chào buổi tối muộn';

  @override
  String get calendarMode => 'Chế độ lịch';

  @override
  String get matrixMode => 'Chế độ ma trận';

  @override
  String get calendarViewMode => 'Chế độ lịch';

  @override
  String get reload => 'Tải lại';

  @override
  String get errorOccurred => 'Đã xảy ra lỗi';

  @override
  String get retry => 'Thử lại';

  @override
  String get initializing => 'Đang khởi tạo...';

  @override
  String get myProfile => 'Hồ sơ của tôi';

  @override
  String get profileUpdated => 'Cập nhật hồ sơ thành công';

  @override
  String get editNotes => 'Sửa ghi chú';

  @override
  String get dueDate => 'Ngày hết hạn';

  @override
  String get notes => 'Ghi chú';

  @override
  String get noNotesYet => 'Chưa có ghi chú';

  @override
  String get enterTaskNotes => 'Nhập ghi chú công việc...';
}
