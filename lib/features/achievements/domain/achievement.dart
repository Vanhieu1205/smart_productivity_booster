import 'package:flutter/material.dart';

// ============================================================
// ACHIEVEMENT ID – Domain Layer
// ============================================================
// Enum định danh duy nhất cho mỗi achievement trong hệ thống.

enum AchievementId {
  firstTask,    // Hoàn thành task đầu tiên
  firstPomo,    // Hoàn thành Pomodoro đầu tiên
  streak3,      // Đạt streak 3 ngày liên tiếp
  streak7,      // Đạt streak 7 ngày liên tiếp
  task10,       // Hoàn thành 10 tasks
  task50,       // Hoàn thành 50 tasks
  pomo10,       // Hoàn thành 10 Pomodoros
  all4Quad,     // Sử dụng đủ cả 4 quadrant trong 1 ngày
  earlyBird,    // Hoàn thành Pomodoro trước 7h sáng
  nightOwl,     // Hoàn thành Pomodoro sau 22h đêm
}

// ============================================================
// ACHIEVEMENT MODEL – Domain Layer
// ============================================================
// Entity đại diện cho một achievement với đầy đủ thông tin hiển thị.

class Achievement {
  final AchievementId id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Tạo bản sao với trạng thái unlocked
  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

// ============================================================
// ALL ACHIEVEMENTS – Danh sách 10 achievements mặc định
// ============================================================

List<Achievement> allAchievements = [
  const Achievement(
    id: AchievementId.firstTask,
    title: 'Khởi đầu',
    description: 'Hoàn thành task đầu tiên',
    icon: Icons.flag_rounded,
    color: Color(0xFF4CAF50),
  ),
  const Achievement(
    id: AchievementId.firstPomo,
    title: 'Pomodoro đầu tiên',
    description: 'Hoàn thành 1 Pomodoro',
    icon: Icons.timer_rounded,
    color: Color(0xFFE53935),
  ),
  const Achievement(
    id: AchievementId.streak3,
    title: '3 Ngày liên tiếp',
    description: 'Sử dụng app 3 ngày liên tiếp',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF9800),
  ),
  const Achievement(
    id: AchievementId.streak7,
    title: '1 Tuần bền bỉ',
    description: 'Sử dụng app 7 ngày liên tiếp',
    icon: Icons.whatshot_rounded,
    color: Color(0xFFF44336),
  ),
  const Achievement(
    id: AchievementId.task10,
    title: '10 Tasks',
    description: 'Hoàn thành 10 công việc',
    icon: Icons.task_alt_rounded,
    color: Color(0xFF2196F3),
  ),
  const Achievement(
    id: AchievementId.task50,
    title: '50 Tasks',
    description: 'Hoàn thành 50 công việc',
    icon: Icons.assignment_turned_in_rounded,
    color: Color(0xFF9C27B0),
  ),
  const Achievement(
    id: AchievementId.pomo10,
    title: '10 Pomodoros',
    description: 'Hoàn thành 10 Pomodoros',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF00BCD4),
  ),
  const Achievement(
    id: AchievementId.all4Quad,
    title: 'Ma trận hoàn hảo',
    description: 'Sử dụng đủ 4 quadrant trong 1 ngày',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF673AB7),
  ),
  const Achievement(
    id: AchievementId.earlyBird,
    title: 'Người đi sớm',
    description: 'Hoàn thành Pomodoro trước 7h sáng',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFFEB3B),
  ),
  const Achievement(
    id: AchievementId.nightOwl,
    title: 'Cú đêm',
    description: 'Hoàn thành Pomodoro sau 22h đêm',
    icon: Icons.nightlight_rounded,
    color: Color(0xFF3F51B5),
  ),
];
