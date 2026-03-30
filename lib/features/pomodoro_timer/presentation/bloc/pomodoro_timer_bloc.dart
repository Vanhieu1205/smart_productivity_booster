import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/streak_service.dart';
import '../../domain/entities/timer_type.dart';
import '../../domain/entities/pomodoro_session_entity.dart';
import '../../data/models/pomodoro_session_model.dart';
import '../../data/services/sound_service.dart';
import '../../../achievements/data/achievement_service.dart';
import '../../../achievements/presentation/widgets/achievement_popup.dart';
import '../../../eisenhower_matrix/data/models/task_model.dart';
import 'pomodoro_timer_event.dart';
import 'pomodoro_timer_state.dart';

// ============================================================
// POMODORO BLOC – Presentation Layer
// ============================================================
//
// [Timer Management – Tại sao cần cẩn thận?]
//
// dart:async Timer.periodic hoạt động NGOÀI vòng lặp sự kiện của BLoC.
// Nếu không cancel đúng cách sẽ gây ra:
//   1. Memory Leak: Timer tiếp tục chạy kể cả sau khi BLoC bị dispose.
//   2. Concurrent Events: BLoC nhận TimerTick trong khi đang đóng → crash.
//   3. Ghost State: emit() sau khi stream đã đóng → exception.
//
// Giải pháp dùng trong code này:
//   - Luôn cancel timer trước khi tạo timer mới (_cancelTimer())
//   - Override close() để đảm bảo timer luôn được cancel
//   - Timer chỉ add(TimerTick) vào bloc queue thay vì emit trực tiếp
//     → Thread-safe, tuân thủ event-driven architecture
//
// [Pomodoro Phase Logic]
//   work → shortBreak (lặp lại) → sau 4 work sessions → longBreak
//   longBreak xong → reset streak → back to work

class PomodoroTimerBloc extends Bloc<PomodoroEvent, PomodoroState> {
  /// Sau bao nhiêu pomodoro work thì nghỉ dài
  static const int _pomodorosPerLongBreak = 4;

  // ── Trạng thái nội bộ ──────────────────────────────────────────────────────

  /// Timer.periodic – null khi không chạy
  Timer? _timer;

  /// Số pomodoro work đã hoàn thành toàn phiên
  int _completedPomodoros = 0;

  /// Đếm pomodoro work liên tiếp trong chuỗi (reset sau longBreak)
  int _currentStreak = 0;

  /// Pha đang hoạt động
  TimerType _currentType = TimerType.work;

  /// Task được liên kết với phiên hiện tại
  String? _linkedTaskId;

  /// Danh sách session đã hoàn thành (TODO: persist to Hive)
  final List<PomodoroSessionEntity> _completedSessions = [];

  /// Thời điểm phiên hiện tại bắt đầu (dùng để tính thời lượng thực tế)
  DateTime? _sessionStartTime;

  /// Service âm thanh/haptic khi kết thúc mỗi pha.
  final SoundService _soundService;

  /// Service cập nhật streak người dùng.
  final StreakService _streakService;

  PomodoroTimerBloc({
    required SoundService soundService,
    required StreakService streakService,
  })  : _soundService = soundService,
        _streakService = streakService,
        super(const PomodoroInitial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<ResetTimer>(_onResetTimer);
    on<SkipPhase>(_onSkipPhase);

    // TimerTick dùng EventTransformer sequential để tránh queue overflow
    on<TimerTick>(_onTimerTick);
    on<LinkTask>(_onLinkTask);
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  /// Bắt đầu phiên mới (luôn bắt đầu từ work)
  void _onStartTimer(StartTimer event, Emitter<PomodoroState> emit) {
    _cancelTimer(); // Luôn cancel timer cũ trước – tránh memory leak

    _currentType = TimerType.work;
    _sessionStartTime = DateTime.now();

    final seconds = _currentType.duration.inSeconds;
    _startTicking(seconds);

    emit(PomodoroRunning(
      currentType: _currentType,
      remainingSeconds: seconds,
      completedPomodoros: _completedPomodoros,
      currentStreak: _currentStreak,
      linkedTaskId: _linkedTaskId,
    ));
  }

  /// Tạm dừng – chỉ cancel timer, giữ nguyên state với số giây còn lại
  void _onPauseTimer(PauseTimer event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    if (state is PomodoroRunning) {
      final s = state as PomodoroRunning;
      emit(PomodoroPaused(
        currentType: s.currentType,
        remainingSeconds: s.remainingSeconds,
        completedPomodoros: s.completedPomodoros,
        currentStreak: s.currentStreak,
        linkedTaskId: s.linkedTaskId,
      ));
    }
  }

  /// Tiếp tục từ vị trí đã dừng – khởi động lại timer với số giây còn lại
  void _onResumeTimer(ResumeTimer event, Emitter<PomodoroState> emit) {
    if (state is PomodoroPaused) {
      final s = state as PomodoroPaused;
      _startTicking(s.remainingSeconds);
      emit(PomodoroRunning(
        currentType: s.currentType,
        remainingSeconds: s.remainingSeconds,
        completedPomodoros: s.completedPomodoros,
        currentStreak: s.currentStreak,
        linkedTaskId: s.linkedTaskId,
      ));
    }
  }

  /// Reset hoàn toàn – xóa mọi tiến trình, về trạng thái ban đầu
  void _onResetTimer(ResetTimer event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    _completedPomodoros = 0;
    _currentStreak = 0;
    _currentType = TimerType.work;
    _linkedTaskId = null;
    _sessionStartTime = null;
    emit(const PomodoroInitial());
  }

  /// Bỏ qua pha hiện tại – tính như hoàn thành nhưng không lưu session
  void _onSkipPhase(SkipPhase event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    _advanceToNextPhase(emit, isSkipped: true);
  }

  /// [Nội bộ] Xử lý mỗi giây đếm ngược
  ///
  /// Đây là handler quan trọng nhất:
  ///   - Nếu còn giây → emit PomodoroRunning với số giây mới
  ///   - Nếu hết giờ → hoàn thành pha, tính toán pha tiếp theo
  void _onTimerTick(TimerTick event, Emitter<PomodoroState> emit) {
    if (event.remainingSeconds > 0) {
      // Vẫn còn giờ – cập nhật countdown
      emit(PomodoroRunning(
        currentType: _currentType,
        remainingSeconds: event.remainingSeconds,
        completedPomodoros: _completedPomodoros,
        currentStreak: _currentStreak,
        linkedTaskId: _linkedTaskId,
      ));
    } else {
      // Hết giờ – hoàn thành pha hiện tại
      _cancelTimer();

      // Phát âm thanh theo loại phase vừa hoàn thành
      if (_currentType == TimerType.work) {
        _soundService.playWorkComplete();
        // Cập nhật streak sau khi hoàn thành 1 phase work
        _streakService.update();
        // Kiểm tra achievements liên quan đến Pomodoro
        _checkPomodoroAchievements();
      } else {
        _soundService.playBreakComplete();
      }

      // Chuyển phase và lưu session (logic đã được sửa trong _advanceToNextPhase)
      _advanceToNextPhase(emit, isSkipped: false);
    }
  }

  /// Liên kết hoặc bỏ liên kết Task với phiên hiện tại
  void _onLinkTask(LinkTask event, Emitter<PomodoroState> emit) {
    _linkedTaskId = event.taskId;
    // Nếu đang Running, update state để UI phản ánh
    if (state is PomodoroRunning) {
      final s = state as PomodoroRunning;
      emit(PomodoroRunning(
        currentType: s.currentType,
        remainingSeconds: s.remainingSeconds,
        completedPomodoros: s.completedPomodoros,
        currentStreak: s.currentStreak,
        linkedTaskId: _linkedTaskId,
      ));
    }
  }

  // ── Phương thức nội bộ ────────────────────────────────────────────────────

  /// Khởi động Timer.periodic mỗi 1 giây.
  ///
  /// [Thiết kế] Timer chỉ add(TimerTick) vào BLoC event queue.
  /// KHÔNG bao giờ emit() trực tiếp từ callback của Timer vì:
  ///   - Timer chạy trên isolate khác, không thread-safe với BLoC
  ///   - Tuân thủ Event-driven: mọi thay đổi state đều qua Event
  void _startTicking(int initialSeconds) {
    int remaining = initialSeconds;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        remaining--;
        // add() thread-safe, sẽ được xử lý tuần tự bởi BLoC
        add(TimerTick(remainingSeconds: remaining));
      },
    );
  }

  /// Cancel timer an toàn.
  /// Luôn gọi trước khi tạo timer mới hoặc trước emit terminal states.
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Logic chuyển phase theo quy tắc Pomodoro Technique:
  ///   - Sau mỗi work → shortBreak
  ///   - Sau 4 work liên tiếp → longBreak
  ///   - Sau break (bất kỳ) → work
  void _advanceToNextPhase(Emitter<PomodoroState> emit, {required bool isSkipped}) {
    // Lưu lại phase đã hoàn thành TRƯỚC KHI thay đổi _currentType
    final completedType = _currentType;

    if (_currentType == TimerType.work && !isSkipped) {
      // Work hoàn thành: cập nhật counters
      _completedPomodoros++;
      _currentStreak++;
    }

    // Xác định phase tiếp theo
    if (_currentType == TimerType.work) {
      // Cứ đủ N pomodoro thì nghỉ dài, còn lại nghỉ ngắn
      _currentType = (_currentStreak % _pomodorosPerLongBreak == 0 && _currentStreak > 0)
          ? TimerType.longBreak
          : TimerType.shortBreak;
    } else {
      // Sau bất kỳ break nào → quay về work
      // CHỈ reset streak khi longBreak thực sự hoàn thành (không phải bị skip)
      if (completedType == TimerType.longBreak && !isSkipped) {
        _currentStreak = 0;
      }
      _currentType = TimerType.work;
    }

    // Lưu session với đúng phase đã hoàn thành (trước khi _currentType thay đổi)
    _saveCompletedSession(completedType);

    emit(PomodoroCompleted(
      completedType: completedType,
      nextType: _currentType,
      completedPomodoros: _completedPomodoros,
      currentStreak: _currentStreak,
    ));
  }

  /// Lưu session vừa hoàn thành vào danh sách nội bộ.
  /// TODO: Inject PomodoroRepository và persist sang Hive.
  void _saveCompletedSession(TimerType completedPhase) {
    if (_sessionStartTime == null) return;

    final session = PomodoroSessionEntity(
      id: const Uuid().v4(),
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      type: completedPhase, // Lưu đúng phase đã hoàn thành
      isCompleted: true, // Hết giờ = hoàn thành trọn vẹn
      taskId: _linkedTaskId,
    );

    _completedSessions.add(session);
    _sessionStartTime = DateTime.now(); // Reset cho phiên kế tiếp
  }

  /// Lấy danh sách sessions đã hoàn thành (dùng cho Statistics)
  List<PomodoroSessionEntity> get completedSessions =>
      List.unmodifiable(_completedSessions);

  /// Kiểm tra và unlock achievements liên quan đến Pomodoro
  void _checkPomodoroAchievements() {
    final achievementService = sl<AchievementService>();

    // Đếm tổng số Pomodoro đã hoàn thành
    final pomodoroBox = Hive.box<PomodoroSessionModel>('pomodoro_sessions_box');
    final totalPomodoros = pomodoroBox.values
        .where((s) => s.isCompleted && s.typeIndex == TimerType.work.index)
        .length;

    // Đếm tổng số task đã hoàn thành
    final taskBox = Hive.box<TaskModel>('tasks_box');
    final totalTasks = taskBox.values.where((t) => t.isCompleted).length;

    // Lấy streak hiện tại
    final streak = _streakService.getCurrentStreak();

    // Kiểm tra early bird / night owl
    final now = DateTime.now();
    final hour = now.hour;

    // Kiểm tra điều kiện và lấy achievements mới unlock
    final newlyUnlocked = achievementService.checkAndUnlock(
      totalTasks: totalTasks,
      totalPomodoros: totalPomodoros,
      streak: streak,
      todayPomos: 1, // Mỗi lần hoàn thành 1 pomodoro work
      usedAll4: false, // Có thể mở rộng sau
      hour: hour,
    );

    // Hiển thị popup cho từng achievement mới
    for (final achievement in newlyUnlocked) {
      AchievementPopup.show(achievement);
    }
  }

  /// QUAN TRỌNG: Override close() để đảm bảo Timer luôn được cancel.
  ///
  /// Nếu không có dòng này:
  ///   - BLoC bị dispose (người dùng thoát màn hình)
  ///   - Timer vẫn chạy → add(TimerTick) vào BLoC đã đóng → Exception
  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
