import 'package:hive/hive.dart';
import '../domain/achievement.dart';

// ============================================================
// ACHIEVEMENT SERVICE – Data Layer
// ============================================================
// Service quản lý việc kiểm tra điều kiện và lưu trữ achievements vào Hive.

class AchievementService {
  static const String _boxName = 'achievements_box';

  /// Lazy getter cho box - kiểm tra box đã mở chưa trước khi sử dụng
  Box? _boxCache;

  Box _getBox() {
    // Nếu box chưa được cache, thử lấy từ Hive
    _boxCache ??= Hive.isBoxOpen(_boxName) ? Hive.box(_boxName) : null;
    return _boxCache!;
  }

  /// Kiểm tra box có đang mở không
  bool get _isBoxReady => _boxCache != null || Hive.isBoxOpen(_boxName);

  /// Khởi tạo box achievements (gọi trong HiveService.openAllBoxes)
  static Future<void> initBox() async {
    await Hive.openBox(_boxName);
  }

  /// Kiểm tra điều kiện và mở khóa achievements nếu thỏa mãn.
  /// Trả về danh sách achievements mới được unlock.
  ///
  /// Các tham số:
  /// - [totalTasks]: tổng số task đã hoàn thành
  /// - [totalPomodoros]: tổng số Pomodoros đã hoàn thành
  /// - [streak]: số ngày streak hiện tại
  /// - [todayPomos]: số Pomodoros hôm nay
  /// - [usedAll4]: đã sử dụng cả 4 quadrant hôm nay
  /// - [hour]: giờ hiện tại (0-23)
  List<Achievement> checkAndUnlock({
    required int totalTasks,
    required int totalPomodoros,
    required int streak,
    required int todayPomos,
    required bool usedAll4,
    required int hour,
  }) {
    // Kiểm tra box đã sẵn sàng chưa
    if (!_isBoxReady) {
      return [];
    }

    final newlyUnlocked = <Achievement>[];
    final box = _getBox();

    for (final achievement in allAchievements) {
      // Bỏ qua nếu đã unlock rồi
      if (_isUnlockedInternal(box, achievement.id)) continue;

      // Kiểm tra điều kiện unlock
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

  /// Kiểm tra achievement đã unlock chưa (internal với box parameter)
  bool _isUnlockedInternal(dynamic box, AchievementId id) {
    final data = box.get(id.name);
    return data != null && data['isUnlocked'] == true;
  }

  /// Lưu achievement đã unlock vào Hive (internal với box parameter)
  void _saveAchievementInternal(dynamic box, Achievement achievement) {
    box.put(achievement.id.name, {
      'isUnlocked': true,
      'unlockedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Kiểm tra điều kiện cho từng loại achievement
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

  /// Kiểm tra achievement đã unlock chưa
  bool isUnlocked(AchievementId id) {
    if (!_isBoxReady) return false;
    final box = _getBox();
    return _isUnlockedInternal(box, id);
  }

  /// Lấy trạng thái tất cả achievements (kết hợp default + trạng thái từ Hive)
  List<Achievement> getStatus() {
    return allAchievements.map((a) {
      if (!_isBoxReady) return a;
      final box = _getBox();
      final data = box.get(a.id.name);
      if (data != null && data['isUnlocked'] == true) {
        final unlockedAtStr = data['unlockedAt'] as String?;
        return a.copyWith(
          isUnlocked: true,
          unlockedAt: unlockedAtStr != null ? DateTime.parse(unlockedAtStr) : null,
        );
      }
      return a;
    }).toList();
  }

  /// Lấy số lượng achievements đã unlock
  int get unlockedCount {
    if (!_isBoxReady) return 0;
    final box = _getBox();
    return allAchievements.where((a) => _isUnlockedInternal(box, a.id)).length;
  }

  /// Reset tất cả achievements (dùng cho debug/testing)
  Future<void> resetAll() async {
    if (!_isBoxReady) return;
    final box = _getBox();
    await box.clear();
  }
}
