import 'package:flutter/material.dart';

// ============================================================
// QUADRANT TYPE – Ma trận Eisenhower
// ============================================================
// Tại sao tách riêng file này?
// → Enum QuadrantType là một phần của DOMAIN LAYER.
// → Không phụ thuộc vào bất kỳ package nào ngoại trừ Flutter (để có Color).
// → Dễ test độc lập, dễ thay đổi label/màu mà không ảnh hưởng logic nghiệp vụ.

/// Bốn góc phần tư của Ma trận Eisenhower.
/// Tên enum theo hành động (doIt, scheduleIt...) thay vì mô tả (urgent, important...)
/// → Trực quan hơn cho người dùng cuối.
enum QuadrantType {
  /// Q1 – Quan trọng & Khẩn cấp → Làm ngay
  doIt,

  /// Q2 – Quan trọng & Không khẩn cấp → Lên lịch
  scheduleIt,

  /// Q3 – Không quan trọng & Khẩn cấp → Ủy thác
  delegateIt,

  /// Q4 – Không quan trọng & Không khẩn cấp → Loại bỏ
  eliminateIt,
}

/// Extension bổ sung getter tiện ích cho QuadrantType.
/// Tách thành extension để enum core không phụ thuộc vào UI (Color, String locale).
extension QuadrantTypeExtension on QuadrantType {
  /// Nhãn hiển thị tiếng Việt
  String get label {
    switch (this) {
      case QuadrantType.doIt:
        return 'Làm Ngay';
      case QuadrantType.scheduleIt:
        return 'Lên Kế Hoạch';
      case QuadrantType.delegateIt:
        return 'Ủy Thác';
      case QuadrantType.eliminateIt:
        return 'Loại Bỏ';
    }
  }

  /// Mô tả đặc điểm góc phần tư
  String get description {
    switch (this) {
      case QuadrantType.doIt:
        return 'Quan trọng & Khẩn cấp';
      case QuadrantType.scheduleIt:
        return 'Quan trọng & Không khẩn cấp';
      case QuadrantType.delegateIt:
        return 'Không quan trọng & Khẩn cấp';
      case QuadrantType.eliminateIt:
        return 'Không quan trọng & Không khẩn cấp';
    }
  }

  /// Màu chính đại diện cho góc phần tư (dùng trong UI)
  Color get color {
    switch (this) {
      case QuadrantType.doIt:
        return const Color(0xFFE53935); // Đỏ – khẩn cấp
      case QuadrantType.scheduleIt:
        return const Color(0xFF1E88E5); // Xanh dương – kế hoạch
      case QuadrantType.delegateIt:
        return const Color(0xFFFB8C00); // Cam – cảnh báo nhẹ
      case QuadrantType.eliminateIt:
        return const Color(0xFF757575); // Xám – ít ưu tiên
    }
  }

  /// Màu nền nhạt (dùng cho card background)
  Color get lightColor {
    switch (this) {
      case QuadrantType.doIt:
        return const Color(0xFFFFEBEE);
      case QuadrantType.scheduleIt:
        return const Color(0xFFE3F2FD);
      case QuadrantType.delegateIt:
        return const Color(0xFFFFF3E0);
      case QuadrantType.eliminateIt:
        return const Color(0xFFF5F5F5);
    }
  }

  /// Icon đại diện cho góc phần tư
  IconData get icon {
    switch (this) {
      case QuadrantType.doIt:
        return Icons.priority_high_rounded;
      case QuadrantType.scheduleIt:
        return Icons.calendar_today_rounded;
      case QuadrantType.delegateIt:
        return Icons.people_alt_rounded;
      case QuadrantType.eliminateIt:
        return Icons.delete_outline_rounded;
    }
  }
}
