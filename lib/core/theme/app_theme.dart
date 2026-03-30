import 'package:flutter/material.dart';

// ============================================================
// APP THEME – Smart Productivity Booster
// Material 3 | Light & Dark Mode | Eisenhower Colors
// ============================================================

/// Màu sắc chủ đạo của giao diện
class AppColors {
  AppColors._(); // Ngăn khởi tạo

  // ── Seed color (tím/xanh tím) ──────────────────────────────
  static const Color primary = Color(0xFF6750A4);       // Tím Material3
  static const Color secondary = Color(0xFF3D7FEA);     // Xanh dương nhạt

  // ── 4 Góc phần tư Eisenhower ───────────────────────────────

  /// Q1 – Quan trọng & Khẩn cấp → Làm Ngay (đỏ hồng)
  static const Color quadrant1 = Color(0xFFE53935);
  static const Color quadrant1Light = Color(0xFFFFEBEE);
  static const Color quadrant1Dark = Color(0xFF7F0000);

  /// Q2 – Quan trọng & Không Khẩn cấp → Lên Kế Hoạch (xanh dương)
  static const Color quadrant2 = Color(0xFF1E88E5);
  static const Color quadrant2Light = Color(0xFFE3F2FD);
  static const Color quadrant2Dark = Color(0xFF0D47A1);

  /// Q3 – Không Quan Trọng & Khẩn cấp → Ủy Thác (vàng cam)
  static const Color quadrant3 = Color(0xFFFB8C00);
  static const Color quadrant3Light = Color(0xFFFFF3E0);
  static const Color quadrant3Dark = Color(0xFFE65100);

  /// Q4 – Không Quan Trọng & Không Khẩn cấp → Loại Bỏ (xám)
  static const Color quadrant4 = Color(0xFF757575);
  static const Color quadrant4Light = Color(0xFFF5F5F5);
  static const Color quadrant4Dark = Color(0xFF212121);

  // ── Màu hỗ trợ ────────────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);

  /// Lấy màu chính của quadrant theo index (0–3)
  static Color quadrantColor(int index) {
    return [quadrant1, quadrant2, quadrant3, quadrant4][index.clamp(0, 3)];
  }

  /// Lấy màu nền nhạt của quadrant (dùng cho card background)
  static Color quadrantLightColor(int index) {
    return [quadrant1Light, quadrant2Light, quadrant3Light, quadrant4Light]
        [index.clamp(0, 3)];
  }
}

// ============================================================
// TEXT STYLES
// ============================================================

/// Các style chữ dùng chung trong toàn app
class AppTextStyles {
  AppTextStyles._();

  // ── Tiêu đề ────────────────────────────────────────────────

  /// Tiêu đề màn hình lớn (AppBar, Header)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// Tiêu đề màn hình trung bình
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  /// Tiêu đề section / nhóm
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Tiêu đề card / tile
  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // ── Nội dung ───────────────────────────────────────────────

  /// Nội dung chính
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  /// Mô tả, phụ đề
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  // ── Nhãn / Badge ───────────────────────────────────────────

  /// Nhãn nút hoặc chip
  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Nhãn nhỏ (metadata, timestamp)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ── Pomodoro Timer ─────────────────────────────────────────

  /// Hiển thị đồng hồ đếm ngược to (25:00)
  static const TextStyle timerDisplay = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w200,
    letterSpacing: -2,
    fontFeatures: [FontFeature.tabularFigures()], // Chữ số cố định width
  );

  /// Trạng thái timer nhỏ (Work / Break)
  static const TextStyle timerLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
  );
}

// ============================================================
// APP THEME
// ============================================================

/// Factory tạo ThemeData Light và Dark cho toàn app
class AppTheme {
  AppTheme._();

  // ── Light Theme ────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // AppBar trong suốt, chữ tối
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Card bo góc, có shadow nhẹ
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLowest,
      ),

      // Nút FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Nút OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input field
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Chip (filter, label)
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),

      // NavigationBar (bottom nav)
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
      ),

      // Divider mỏng
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Typography sử dụng TextTheme mặc định Material3
      textTheme: _buildTextTheme(colorScheme.onSurface),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────
  // Dark mode với ColorScheme.fromSeed và brightness: dark
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // AppBar trong suốt, elevation 0
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Card bo góc 12, elevation 0
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLow,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      textTheme: _buildTextTheme(colorScheme.onSurface),
    );
  }

  // ── Helper ─────────────────────────────────────────────────

  /// Tạo TextTheme với màu chữ đúng theo brightness
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: textColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: textColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: textColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textColor),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: textColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: textColor),
    );
  }
}
