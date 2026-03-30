import 'package:flutter/material.dart';

// ============================================================
// APP COLORS
// ============================================================
// Quản lý các màu sắc trong ứng dụng.
// Cung cấp các helper methods để lấy màu từ Theme thay vì hardcode.

class AppColors {
  AppColors._(); // Ngăn khởi tạo

  // ── Helper methods lấy màu theo Theme hiện tại (Light/Dark) ──
  
  static Color textPrimary(BuildContext context) => Theme.of(context).colorScheme.onBackground;
  
  static Color textSecondary(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;
  
  static Color surface(BuildContext context) => Theme.of(context).colorScheme.surface;
  
  static Color cardBackground(BuildContext context) => Theme.of(context).colorScheme.surfaceVariant;

  // ── Map màu cố định cho Eisenhower Matrix (Không đổi theo Theme) ──
  // Do đặc thù các góc phần tư cần mã màu nhận diện logic (Đỏ, Xanh, Vàng, Xám)
  // nên ta vẫn giữ nguyên static const color cho chúng.
  
  static const Map<int, Color> quadrantColors = {
    0: Color(0xFFE53935), // Q1 – Quan trọng & Khẩn cấp
    1: Color(0xFF1E88E5), // Q2 – Quan trọng & Không Khẩn cấp
    2: Color(0xFFFB8C00), // Q3 – Không Quan Trọng & Khẩn cấp
    3: Color(0xFF757575), // Q4 – Không Quan Trọng & Không Khẩn cấp
  };

  /// Lấy màu chính của quadrant theo index (0–3)
  static Color quadrantColor(int index) {
    return quadrantColors[index.clamp(0, 3)]!;
  }

  /// Lấy màu nền nhạt của quadrant. Để dùng chung cho cả 2 Theme,
  /// ta dùng backgroundColor với độ trong suốt 10%.
  static Color quadrantLightColor(int index) {
    return quadrantColor(index).withOpacity(0.1);
  }
}
