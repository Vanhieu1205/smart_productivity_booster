import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../bloc/pomodoro_timer_bloc.dart';
import '../bloc/pomodoro_timer_event.dart';
import '../bloc/pomodoro_timer_state.dart';
import '../widgets/circular_timer_widget.dart';

// ============================================================
// FOCUS MODE PAGE – Chế độ tập trung toàn màn hình
// ============================================================
//
// Màn hình immersive để người dùng tập trung hoàn toàn vào công việc.
// Đặc điểm:
//   - Ẩn system UI (status bar, navigation bar)
//   - Nền tối để giảm phiền distract
//   - Hiển thị quote truyền cảm hứng ngẫu nhiên
//   - Timer lớn ở giữa màn hình
//   - Điều khiển tối giản: pause/resume và thoát

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  // Danh sách câu trích dẫn tiếng Việt truyền cảm hứng
  // Mỗi phút sẽ hiển thị một câu khác nhau
  static const List<String> _quotes = [
    'Hãy kiên nhẫn, thành công không đến trong một ngày.',
    'Mỗi phút tập trung là một bước tiến gần hơn đến mục tiêu.',
    'Đừng chờ đợi cơ hội, hãy tạo ra nó.',
    'Sự kiên trì có thể thay đổi bất cứ điều gì.',
    'Làm việc chăm chỉ hôm nay để tự hào ngày mai.',
  ];

  // Lấy quote dựa trên phút hiện tại (thay đổi mỗi phút)
  late final String _randomQuote;

  @override
  void initState() {
    super.initState();
    // Chọn quote theo phút hiện tại
    _randomQuote = _quotes[DateTime.now().minute % _quotes.length];
    // Ẩn system UI để immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Bật wakelock - giữ màn hình sáng trong chế độ tập trung
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Tắt wakelock
    WakelockPlus.disable();
    // Khôi phục system UI về chế độ edge-to-edge
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // Hiện dialog xác nhận trước khi thoát chế độ tập trung
  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát chế độ tập trung?'),
        content: const Text('Bạn có muốn quay lại màn hình chính không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        // Nền tối để tập trung
        backgroundColor: colorScheme.inverseSurface,
        body: BlocBuilder<PomodoroTimerBloc, PomodoroState>(
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Quote truyền cảm hứng ──────────────────────
                    Text(
                      _randomQuote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Timer tròn lớn ─────────────────────────────
                    CircularTimerWidget(
                      size: 260,
                      state: state,
                    ),

                    const SizedBox(height: 32),

                    // ── Nút Pause/Resume ──────────────────────────
                    _buildPauseButton(context, state),

                    const SizedBox(height: 24),

                    // ── Nút thu nhỏ / thoát ───────────────────────
                    TextButton(
                      onPressed: () async {
                        final shouldPop = await _onWillPop();
                        if (shouldPop && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Thu nhỏ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Xây dựng nút pause/resume với icon lớn
  Widget _buildPauseButton(BuildContext context, PomodoroState state) {
    final bloc = context.read<PomodoroTimerBloc>();
    final isRunning = state is PomodoroRunning;
    final isPaused = state is PomodoroPaused;

    // Xác định icon: play hoặc pause
    final iconData = (isRunning) ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return IconButton(
      onPressed: (isRunning)
          ? () => bloc.add(const PauseTimer())
          : (isPaused)
              ? () => bloc.add(const ResumeTimer())
              : () => bloc.add(const StartTimer()),
      icon: Icon(
        iconData,
        color: Colors.white,
        size: 64,
      ),
    );
  }
}
