import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../di/injection_container.dart';

/// Notifier để thông báo khi task thay đổi (hoàn thành, xóa, di chuyển).
/// Các trang khác (Dashboard, Statistics) sẽ lắng nghe để cập nhật UI.
class TaskChangeNotifier extends ChangeNotifier {
  int _version = 0;

  int get version => _version;

  /// Gọi method này khi task thay đổi
  void notifyTaskChanged() {
    _version++;
    notifyListeners();
  }
}

/// Widget helper để lắng nghe TaskChangeNotifier và trigger callback
class TaskChangeListener extends StatefulWidget {
  final Widget child;
  final VoidCallback onTaskChanged;

  const TaskChangeListener({
    super.key,
    required this.child,
    required this.onTaskChanged,
  });

  @override
  State<TaskChangeListener> createState() => _TaskChangeListenerState();
}

class _TaskChangeListenerState extends State<TaskChangeListener> {
  int _lastVersion = 0;

  @override
  void initState() {
    super.initState();
    _lastVersion = sl<TaskChangeNotifier>().version;
    sl<TaskChangeNotifier>().addListener(_onNotifierChanged);
  }

  void _onNotifierChanged() {
    final currentVersion = sl<TaskChangeNotifier>().version;
    if (currentVersion != _lastVersion) {
      _lastVersion = currentVersion;
      widget.onTaskChanged();
    }
  }

  @override
  void dispose() {
    sl<TaskChangeNotifier>().removeListener(_onNotifierChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
