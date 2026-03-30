import 'package:flutter/material.dart';

// ============================================================
// TASK LABEL – Nhãn phân loại Task
// ============================================================
//
// Dùng cho việc gắn "loại công việc" ở mức cao:
//   - work    : Công việc / dự án
//   - study   : Học tập
//   - personal: Cá nhân
//   - health  : Sức khỏe
//   - finance : Tài chính
//   - other   : Khác
//
// Enum nằm ở DOMAIN layer để có thể dùng ở mọi nơi (usecase, bloc, UI).

enum TaskLabel {
  work,
  study,
  personal,
  health,
  finance,
  other,
}

extension TaskLabelExtension on TaskLabel {
  /// Tên hiển thị tiếng Việt cho từng loại nhãn
  String get name {
    switch (this) {
      case TaskLabel.work:
        return 'Công việc';
      case TaskLabel.study:
        return 'Học tập';
      case TaskLabel.personal:
        return 'Cá nhân';
      case TaskLabel.health:
        return 'Sức khỏe';
      case TaskLabel.finance:
        return 'Tài chính';
      case TaskLabel.other:
        return 'Khác';
    }
  }

  /// Màu đại diện cố định cho từng loại nhãn
  Color get color {
    switch (this) {
      case TaskLabel.work:
        return const Color(0xFF1976D2); // Xanh dương
      case TaskLabel.study:
        return const Color(0xFF8E24AA); // Tím
      case TaskLabel.personal:
        return const Color(0xFFFB8C00); // Cam
      case TaskLabel.health:
        return const Color(0xFF43A047); // Xanh lá
      case TaskLabel.finance:
        return const Color(0xFF00897B); // Xanh teal
      case TaskLabel.other:
        return const Color(0xFF757575); // Xám
    }
  }
}

