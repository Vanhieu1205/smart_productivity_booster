import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ============================================================
// POMODORO BACKGROUND SERVICE
// ============================================================
//
// [Tại sao cần Background Service?]
//
// Flutter Timer.periodic (trong BLoC) bị DỪNG khi:
//   1. Người dùng minimize app (app chuyển sang background)
//   2. Android kill process để giải phóng RAM
//   3. Màn hình tắt (tùy thiết bị)
//
// Foreground Service Android là giải pháp:
//   - Chạy trong process riêng, tồn tại kể cả khi app bị minimized
//   - Hiển thị notification liên tục để báo user biết đang chạy
//   - Communicate với Flutter UI qua invoke/on channels
//   - Android bắt buộc hiển thị notification khi dùng Foreground Service
//     → Người dùng luôn biết service đang chạy (transparent)
//
// QUAN TRỌNG: Background Service chỉ cần thiết khi:
//   1. App chạy trên Android/iOS thực (physical device hoặc emulator)
//   2. Người dùng dùng app khi minimize (background mode)
// → Trên web, tính năng này KHÔNG hoạt động.

/// Tên channel notification cho Foreground Service
const String _kNotificationChannelId = 'pomodoro_foreground';
const String _kNotificationChannelName = 'Pomodoro Timer';

/// Keys cho message giao tiếp giữa Service và Flutter UI
class ServiceKeys {
  static const String stopTimer = 'stop_timer';
  static const String startTimer = 'start_timer';
  static const String timerProgress = 'timer_progress';    // Service → UI
  static const String timerCompleted = 'timer_completed';  // Service → UI
  static const String durationSeconds = 'duration_seconds';
  static const String remainingSeconds = 'remaining_seconds';
  static const String timerType = 'timer_type';
}

class PomodoroBackgroundService {
  static final _service = FlutterBackgroundService();
  static final _notifications = FlutterLocalNotificationsPlugin();

  // ────────────────────────────────────────────────────────────────────────────
  // KHỞI TẠO SERVICE
  // ────────────────────────────────────────────────────────────────────────────

  /// Khởi tạo và cấu hình Flutter Background Service.
  /// Gọi một lần trong main() trước runApp().
  static Future<void> initializeService() async {
    // ── Cấu hình Android Notification Channel ─────────────────────────────────
    // Channel này dùng cho foreground service notification (bắt buộc Android 8+)
    const androidChannel = AndroidNotificationChannel(
      _kNotificationChannelId,
      _kNotificationChannelName,
      description: 'Hiển thị khi Pomodoro Timer đang chạy ngầm',
      importance: Importance.low, // Low để không phát âm thanh mỗi giây
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // ── Cấu hình Background Service ───────────────────────────────────────────
    await _service.configure(
      // Android: Foreground Service (chạy liên tục trong notification tray)
      androidConfiguration: AndroidConfiguration(
        onStart: _onServiceStart, // Hàm entrypoint của service isolate
        autoStart: false,          // Không tự khởi động khi mở app
        isForegroundMode: true,    // Foreground = user thấy notification
        notificationChannelId: _kNotificationChannelId,
        initialNotificationTitle: 'Pomodoro Timer',
        initialNotificationContent: 'Đang chạy...',
        foregroundServiceNotificationId: 1001,
        foregroundServiceTypes: [
          AndroidForegroundType.dataSync, // Loại phù hợp nhất cho timer
        ],
      ),
      // iOS: Background fetch (giới hạn hơn Android)
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onServiceStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SỬ DỤNG SERVICE
  // ────────────────────────────────────────────────────────────────────────────

  /// Bắt đầu đếm ngược trong Background Service.
  /// [durationSeconds]: tổng thời gian (giây) của pha hiện tại
  /// [timerType]: loại pha ("work" / "shortBreak" / "longBreak")
  static Future<void> startBackgroundTimer({
    required int durationSeconds,
    required String timerType,
  }) async {
    // Khởi động service nếu chưa chạy
    await _service.startService();

    // Gửi lệnh start tới service isolate qua message channel
    _service.invoke(ServiceKeys.startTimer, {
      ServiceKeys.durationSeconds: durationSeconds,
      ServiceKeys.timerType: timerType,
    });
  }

  /// Dừng timer và tắt background service
  static Future<void> stopTimer() async {
    _service.invoke(ServiceKeys.stopTimer);
    _service.invoke('stopSelf');
  }

  /// Lắng nghe progress từ service (remainingSeconds mỗi giây)
  /// Trả về Stream để BLoC hoặc UI subscribe
  static Stream<Map<String, dynamic>?> get progressStream =>
      _service.on(ServiceKeys.timerProgress);

  /// Lắng nghe event hoàn thành từ service
  static Stream<Map<String, dynamic>?> get completedStream =>
      _service.on(ServiceKeys.timerCompleted);

  // ────────────────────────────────────────────────────────────────────────────
  // SERVICE ENTRYPOINT – chạy trong isolate riêng biệt
  // ────────────────────────────────────────────────────────────────────────────

  /// @pragma('vm:entry-point') là bắt buộc để Dart không tree-shake hàm này
  /// vì nó được gọi từ native code, không phải từ Dart code.
  @pragma('vm:entry-point')
  static Future<void> _onServiceStart(ServiceInstance service) async {
    // Đảm bảo plugin được khởi tạo trong isolate mới
    DartPluginRegistrant.ensureInitialized();

    // Giữ trace timer nội bộ
    Timer? _internalTimer;

    // Lắng nghe lệnh startTimer từ Flutter UI
    service.on(ServiceKeys.startTimer).listen((event) {
      if (event == null) return;
      final durationSeconds = event[ServiceKeys.durationSeconds] as int;
      final timerType = event[ServiceKeys.timerType] as String;

      int remaining = durationSeconds;

      // Cancel timer cũ nếu có (tránh double timer)
      _internalTimer?.cancel();

      // Cập nhật notification foreground mỗi giây
      _internalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        remaining--;

        // Cập nhật notification text với thời gian còn lại
        final mins = remaining ~/ 60;
        final secs = remaining % 60;
        final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Pomodoro đang chạy',
            content: '$timeStr còn lại',
          );
        }

        // Gửi progress về Flutter UI
        service.invoke(ServiceKeys.timerProgress, {
          ServiceKeys.remainingSeconds: remaining,
        });

        // Hết giờ → gửi completed event và dừng timer
        if (remaining <= 0) {
          _internalTimer?.cancel();
          service.invoke(ServiceKeys.timerCompleted, {
            ServiceKeys.timerType: timerType,
          });
        }
      });
    });

    // Lắng nghe lệnh dừng từ Flutter UI
    service.on(ServiceKeys.stopTimer).listen((_) {
      _internalTimer?.cancel();
      service.stopSelf();
    });
  }

  // iOS background handler (bắt buộc khai báo)
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    return true;
  }
}
