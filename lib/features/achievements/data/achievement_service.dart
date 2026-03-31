import 'package:hive/hive.dart';
import '../domain/achievement.dart';

// ============================================================
// ACHIEVEMENT SERVICE – Data Layer
// ============================================================
// Service quản lý việc kiểm tra điều kiện và lưu trữ achievements vào Hive.

class AchievementService {
  static const String _boxName = 'achievements_box';

  /// Lấy box - luôn kiểm tra xem box có đang mở không
  Box<dynamic>? _getBox() {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return null;
  }

  /// Khởi tạo box achievements (gọi trong HiveService.openAllBoxes)
  static Future<void> initBox() async {
    await Hive.openBox(_boxName);
  }

  /// Kiểm tra điều kiện và mở khóa achievements nếu thỏa mãn.
  /// Trả về danh sách achievements mới được unlock.
  List<Achievement> checkAndUnlock({
    required int totalTasks,
    required int totalPomodoros,
    required int streak,
    required int todayPomos,
    required bool usedAll4,
    required int hour,
  }) {
    final box = _getBox();
    if (box == null) {
      return [];
    }

    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      if (_isUnlockedInternal(box, achievement.id)) continue;

      final shouldUnlock = _checkCondition(
        achievement.id,
        totalTasks: totalTasks,
        totalPomodoros: totalPomodoros,
        streak: streak,
        todayPomos: todayPomos,
        usedAll4: usedAll4,
        hour: hour,
      );

      if (shouldUnlock) {
        _saveAchievementInternal(box, achievement);
        newlyUnlocked.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }

    return newlyUnlocked;
  }

  bool _isUnlockedInternal(dynamic box, AchievementId id) {
    final data = box.get(id.name);
    return data != null && data['isUnlocked'] == true;
  }

  void _saveAchievementInternal(dynamic box, Achievement achievement) {
    box.put(achievement.id.name, {
      'isUnlocked': true,
      'unlockedAt': DateTime.now().toIso8601String(),
    });
  }

  bool _checkCondition(
    AchievementId id, {
    required int totalTasks,
    required int totalPomodoros,
    required int streak,
    required int todayPomos,
    required bool usedAll4,
    required int hour,
  }) {
    switch (id) {
      case AchievementId.firstTask:
        return totalTasks >= 1;
      case AchievementId.firstPomo:
        return totalPomodoros >= 1;
      case AchievementId.streak3:
        return streak >= 3;
      case AchievementId.streak7:
        return streak >= 7;
      case AchievementId.task10:
        return totalTasks >= 10;
      case AchievementId.task50:
        return totalTasks >= 50;
      case AchievementId.pomo10:
        return totalPomodoros >= 10;
      case AchievementId.all4Quad:
        return usedAll4;
      case AchievementId.earlyBird:
        return todayPomos >= 1 && hour < 7;
      case AchievementId.nightOwl:
        return todayPomos >= 1 && hour >= 22;
    }
  }

  bool isUnlocked(AchievementId id) {
    final box = _getBox();
    if (box == null) return false;
    return _isUnlockedInternal(box, id);
  }

  /// Lấy trạng thái tất cả achievements
  List<Achievement> getStatus() {
    final box = _getBox();

    return allAchievements.map((a) {
      if (box == null) return a;

      final data = box.get(a.id.name);
      if (data != null && data['isUnlocked'] == true) {
        final unlockedAtStr = data['unlockedAt'] as String?;
        return a.copyWith(
          isUnlocked: true,
          unlockedAt: unlockedAtStr != null ? DateTime.tryParse(unlockedAtStr) : null,
        );
      }
      return a;
    }).toList();
  }

  int get unlockedCount {
    final box = _getBox();
    if (box == null) return 0;
    return allAchievements.where((a) => _isUnlockedInternal(box, a.id)).length;
  }

  Future<void> resetAll() async {
    final box = _getBox();
    if (box == null) return;
    await box.clear();
  }
}
