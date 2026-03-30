import 'package:hive/hive.dart';
import '../models/user_model.dart';

/*
  Giải thích: Vì sao dùng Local Auth (Hive) thay vì Firebase cho đề tài này?
  - Đề tài (Smart Productivity Booster - Tối ưu hiệu suất cá nhân) tập trung chủ yếu vào việc cá nhân hóa, quản lý dữ liệu offline (Local-First).
  - Sử dụng local database (Hive) giúp ứng dụng hoạt động ngay cả khi không có mạng, mang lại tốc độ phản hồi tức thì và mượt mà cho các tính năng Pomodoro hay quản lý task.
  - Tôn trọng quyền riêng tư của người dùng vì dữ liệu và thói quen làm việc hoàn toàn lưu trên máy cá nhân, không tự động đẩy lên máy chủ đám mây.
  - Tránh chi phí bảo trì và độ trễ từ backend Firebase không thực sự mang lại trải nghiệm cốt lõi cho ứng dụng productivity này.
*/

abstract class AuthLocalDataSource {
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(UserModel user);
  Future<UserModel?> getUserByEmail(String email);
  Future<UserModel?> getUserById(String id);
  Future<void> saveCurrentSession(String userId);
  Future<void> clearSession();
  Future<String?> getCurrentSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String usersBoxName = 'users';
  static const String sessionBoxName = 'session';
  static const String sessionKey = 'currentUserId';

  // Getter đồng bộ từ HiveService
  Box<UserModel> get _usersBox => Hive.box<UserModel>(usersBoxName);
  Box get _sessionBox => Hive.box(sessionBoxName);

  @override
  Future<UserModel> createUser(UserModel user) async {
    final box = _usersBox;
    await box.put(user.id, user);
    return user;
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    final box = _usersBox;
    await box.put(user.id, user);
    return user;
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final box = _usersBox;
    try {
      // Vì Hive Box không cung cấp khả năng truy vấn bằng key thứ cấp nên ta dùng firstWhere
      return box.values.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    final box = _usersBox;
    return box.get(id);
  }

  @override
  Future<void> saveCurrentSession(String userId) async {
    final box = _sessionBox;
    await box.put(sessionKey, userId);
  }

  @override
  Future<void> clearSession() async {
    final box = _sessionBox;
    await box.delete(sessionKey);
  }

  @override
  Future<String?> getCurrentSession() async {
    final box = _sessionBox;
    return box.get(sessionKey);
  }
}
