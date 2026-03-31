import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pomodoro_timer_bloc.dart';
import '../bloc/pomodoro_timer_state.dart';

class WhiteNoiseWidget extends StatefulWidget {
  const WhiteNoiseWidget({super.key});

  @override
  State<WhiteNoiseWidget> createState() => _WhiteNoiseWidgetState();
}

class _WhiteNoiseWidgetState extends State<WhiteNoiseWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isWhiteNoiseEnabled = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _manageAudio(PomodoroState state) async {
    if (!_isWhiteNoiseEnabled) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      }
      return;
    }

    final isActive = state is PomodoroRunning;

    if (isActive && !_isPlaying) {
      try {
        // Sử dụng file nhạc cục bộ từ assets
        await _audioPlayer.setSource(AssetSource('sounds/chill_rain.mp3'));
        await _audioPlayer.resume();
        _isPlaying = true;
      } catch (e) {
        debugPrint('Lỗi phát âm thanh: $e');
        _isPlaying = false;
      }
    } else if (!isActive && _isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PomodoroTimerBloc, PomodoroState>(
      listener: (context, state) {
        _manageAudio(state);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note_rounded),
          const SizedBox(width: 8),
          const Text('Tiếng ồn trắng (Mưa)'),
          Switch(
            value: _isWhiteNoiseEnabled,
            onChanged: (val) {
              setState(() {
                _isWhiteNoiseEnabled = val;
              });
              // Trigger audio update manually
              _manageAudio(context.read<PomodoroTimerBloc>().state);
            },
          ),
        ],
      ),
    );
  }
}
