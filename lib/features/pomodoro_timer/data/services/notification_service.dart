import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as flnp;

// ============================================================
// NOTIFICATION SERVICE
// ============================================================
//
// [Tại sao cần Local Notifications?]
//
// Khi Pomodoro kết thúc, app có thể ở background hoặc bị minimize.
// Người dùng cần được THÔNG BÁO để biết:
//   - Đã làm việc xong → Nghỉ ngơi
//   - Đã nghỉ xong → Bắt đầu làm việc lại
//
// flutter_local_notifications cho phép:
//   - Hiển thị notification với icon, title, body
//   - Tạo notification channel Android với importance level
//   - Schedule notification theo giờ (nếu cần)
//   - Gắn payload để deep link vào màn hình khi user tap

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// ID cho từng loại notification (phân biệt để update/cancel)
  static const int _workCompleteId = 2001;
  static const int _breakCompleteId = 2002;

  /// ID channel thông báo quan trọng (âm thanh + hiện trên màn hình khóa)
  static const String _channelId = 'pomodoro_alerts';
  static const String _channelName = 'Pomodoro Alerts';

  // ────────────────────────────────────────────────────────────────────────────
  // KHỞI TẠO
  // ────────────────────────────────────────────────────────────────────────────

  /// Khởi tạo plugin và tạo notification channel.
  /// Gọi trong main() sau khi initializeService().
  static Future<void> initialize() async {
    // ── Khởi tạo timezone (cần cho scheduled notifications) ───────────────────
    tz_data.initializeTimeZones();

    // ── Cài đặt cho Android ────────────────────────────────────────────────────
    // icon: tên file trong android/app/src/main/res/drawable/
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // ── Cài đặt cho iOS ────────────────────────────────────────────────────────
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,   // Hỏi xin quyền khi khởi động
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // Khởi tạo plugin, callback khi user tap vào notification
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // ── Tạo Notification Channel (bắt buộc Android 8.0+) ─────────────────────
    // Channel này dùng cho thông báo phát âm thanh khi timer xong
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Thông báo khi phiên Pomodoro hoàn thành',
      importance: Importance.high, // HIGH → phát âm thanh + hiện popup
      playSound: true,
      enableLights: true,          // Đèn LED nhấp nháy (nếu thiết bị hỗ trợ)
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // ── Tạo channel cho deadline reminders ───────────────────────────────────
    const deadlineChannel = AndroidNotificationChannel(
      'deadline_ch',
      'Nhắc deadline',
      description: 'Thông báo nhắc nhở deadline công việc',
      importance: Importance.high,
      playSound: true,
      enableLights: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deadlineChannel);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HIỂN THỊ THÔNG BÁO
  // ────────────────────────────────────────────────────────────────────────────

  /// Thông báo khi phiên work (25 phút) hoàn thành.
  /// Gợi ý người dùng nghỉ ngơi.
  static Future<void> showTimerCompleteNotification({
    required int breakMinutes, // 5 hoặc 15 phút tùy loại break
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Thông báo Pomodoro',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Pomodoro hoàn thành!',
      icon: '@mipmap/ic_launcher',
      // Hiển thị nút "Bắt đầu nghỉ" trực tiếp trên notification
      actions: [
        AndroidNotificationAction(
          'start_break',
          'Bắt đầu nghỉ',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      _workCompleteId,
      '🍅 Pomodoro hoàn thành!',
      'Tuyệt vời! Nghỉ $breakMinutes phút nhé.',
      details,
      payload: 'work_complete', // Dùng để navigate khi user tap
    );
  }

  /// Thông báo khi phiên nghỉ (ngắn hoặc dài) kết thúc.
  /// Nhắc người dùng quay lại làm việc.
  static Future<void> showBreakCompleteNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Thông báo Pomodoro',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Hết giờ nghỉ!',
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'start_work',
          'Bắt đầu làm việc',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      _breakCompleteId,
      '⏰ Hết giờ nghỉ!',
      'Bắt đầu làm việc thôi nào! Còn 25 phút. 💪',
      details,
      payload: 'break_complete',
    );
  }

  /// Hủy tất cả notifications (gọi khi reset timer hoặc thoát app)
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Hủy một notification theo ID
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // DEADLINE REMINDER (Nhắc nhở deadline)
  // ────────────────────────────────────────────────────────────────────────────

  /// Đặt lịch nhắc nhở deadline cho task.
  /// Notification sẽ được gửi vào lúc 9h sáng ngày trước deadline.
  ///
  /// [taskId]: ID của task để cancel reminder khi task bị xóa
  /// [taskTitle]: Tiêu đề task để hiển thị trong notification
  /// [deadline]: Ngày hết hạn của task
  static Future<void> scheduleDeadlineReminder({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    // Nhắc trước 1 ngày vào lúc 9h sáng
    final reminderTime = DateTime(
      deadline.year,
      deadline.month,
      deadline.day - 1,
      9,
      0,
    );

    // Nếu thời gian nhắc đã qua → không đặt lịch
    if (reminderTime.isBefore(DateTime.now())) return;

    // Sử dụng hashCode của taskId làm notification ID (để cancel được sau này)
    final notificationId = taskId.hashCode.abs();

    await flnp.FlutterLocalNotificationsPlugin().zonedSchedule(
      notificationId,
      'Deadline sắp đến! ⚠️',
      '"$taskTitle" hết hạn vào ngày mai',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_ch',
          'Nhắc deadline',
          channelDescription: 'Thông báo nhắc deadline công việc',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          flnp.UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: flnp.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Hủy lịch nhắc nhở deadline của một task.
  /// Gọi khi task bị xóa hoặc không còn deadline.
  static Future<void> cancelDeadlineReminder(String taskId) async {
    final notificationId = taskId.hashCode.abs();
    await flnp.FlutterLocalNotificationsPlugin().cancel(notificationId);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CALLBACK
  // ────────────────────────────────────────────────────────────────────────────

  /// Xử lý khi người dùng tap vào notification.
  /// payload dùng để điều hướng sang màn hình phù hợp.
  static void _onNotificationTap(NotificationResponse response) {
    // TODO: Điều hướng tới màn Pomodoro khi user tap notification
    // Có thể dùng GlobalKey<NavigatorState> hoặc go_router
    final payload = response.payload;
    if (payload == 'work_complete' || payload == 'break_complete') {
      // Navigate to pomodoro screen
    }
  }
}
