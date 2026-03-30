import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';

/// Lắng nghe vòng đời của App để can thiệp kịp thời bảo vệ Hive DB
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Khi AppPause (người dùng bấm Home ra ngoài), thực hiện lưu đệm phòng hờ hệ điều hành kill task
    if (state == AppLifecycleState.paused) {
      // Hive vốn tự ghi đĩa tức thì, tuy nhiên ta có thể gọi .compact() 
      // để flush/gom rác các box nếu cần để xả ram.
      // Dưới đây là ví dụ loop qua các box đang mở để compact.
      final boxNames = [
        'tasks_box', 
        'pomodoro_sessions_box', 
        'settings_box', 
        'users', 
        'session', 
        'onboardingBox'
      ];
      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          Hive.box(boxName).compact();
        }
      }
    } 
    // Khi App Detached (Bị tắt / Kill khỏi Recent Apps), đóng DB gọn gàng
    else if (state == AppLifecycleState.detached) {
      HiveService.closeAllBoxes();
    }
  }
}
