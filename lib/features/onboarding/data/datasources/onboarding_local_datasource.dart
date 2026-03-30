import 'package:hive/hive.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String _boxName = 'onboardingBox';
  static const String _key = 'onboarding_done';

  // Getter đồng bộ
  Box get _box => Hive.box(_boxName);

  // Tại sao dùng Hive thay vì SharedPreferences?
  // 1. Tốc độ: Hive ghi/đọc cực kỳ nhanh (sync cho read, async cho write) và tối ưu hóa tốt hơn cho Dart/Flutter.
  // 2. Nhất quán: Toàn bộ project (Eisenhower Matrix, Statistics, Settings) đều đã sử dụng Hive. Việc dùng chung Hive giúp quản lý một loại local database duy nhất, tránh phân mảnh công nghệ và dễ dàng viết Unit Test cùng với mock data.
  // 3. Linh hoạt: Nếu sau này cần lưu trữ thêm các complex objects thay vì chỉ bool, Hive có hỗ trợ TypeAdapter.

  @override
  Future<bool> isOnboardingCompleted() async {
    final box = _box;
    return box.get(_key, defaultValue: false) as bool;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    final box = _box;
    await box.put(_key, true);
  }
}
