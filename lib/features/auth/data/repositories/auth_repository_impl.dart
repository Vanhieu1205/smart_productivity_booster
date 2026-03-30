import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity?> register(String username, String email, String password) async {
    // 1. Kiểm tra xem email đã tồn tại hay chưa
    final existingUser = await localDataSource.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Email đã được sử dụng.');
    }

    // 2. Tạo ID mới và hash password
    final id = const Uuid().v4();
    final passwordHash = UserModel.hashPassword(password);
    
    // Tạo avatarInitials (2 chữ cái đầu)
    String initials = '';
    if (username.isNotEmpty) {
      final parts = username.trim().split(' ');
      if (parts.length > 1) {
        initials = parts.first[0].toUpperCase() + parts.last[0].toUpperCase();
      } else {
        initials = parts.first[0].toUpperCase();
      }
    }

    final newUser = UserModel(
      id: id,
      username: username,
      email: email,
      passwordHash: passwordHash,
      createdAt: DateTime.now(),
      avatarInitials: initials,
    );

    // 3. Lưu vào Hive Local
    await localDataSource.createUser(newUser);
    return newUser;
  }

  @override
  Future<UserEntity?> updateUser({String? newUsername}) async {
    final currentUserId = await localDataSource.getCurrentSession();
    if (currentUserId == null) throw Exception('Người dùng chưa đăng nhập');

    final currentUser = await localDataSource.getUserById(currentUserId);
    if (currentUser == null) throw Exception('Không tìm thấy dữ liệu người dùng');

    final updatedUsername = newUsername ?? currentUser.username;
    
    // Tạo lại avatar initials nếu có đổi tên
    String initials = currentUser.avatarInitials;
    if (newUsername != null && newUsername.isNotEmpty) {
      final parts = newUsername.trim().split(' ');
      if (parts.length > 1) {
        initials = parts.first[0].toUpperCase() + parts.last[0].toUpperCase();
      } else {
        initials = parts.first[0].toUpperCase();
      }
    }

    final updatedUser = UserModel(
      id: currentUser.id,
      username: updatedUsername,
      email: currentUser.email,
      passwordHash: currentUser.passwordHash,
      createdAt: currentUser.createdAt,
      avatarInitials: initials,
    );

    await localDataSource.updateUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    // 1. Tìm user theo Email trong Hive
    final user = await localDataSource.getUserByEmail(email);
    if (user == null) {
      throw Exception('Tài khoản không tồn tại.');
    }

    // 2. Kiểm tra mật khẩu
    final hash = UserModel.hashPassword(password);
    if (user.passwordHash != hash) {
      throw Exception('Mật khẩu không chính xác.');
    }

    // 3. Đăng nhập thành công, lưu lại current session ID
    await localDataSource.saveCurrentSession(user.id);
    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final currentUserId = await localDataSource.getCurrentSession();
    if (currentUserId == null) return null;

    final user = await localDataSource.getUserById(currentUserId);
    return user;
  }

  @override
  Future<bool> isLoggedIn() async {
    final currentUserId = await localDataSource.getCurrentSession();
    return currentUserId != null;
  }
}
