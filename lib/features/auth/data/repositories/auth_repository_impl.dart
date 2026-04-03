import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity?> register(
    String username,
    String email,
    String password,
    String securityQuestion,
    String securityAnswer,
  ) async {
    final existingUser = await localDataSource.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Email đã được sử dụng.');
    }

    final id = const Uuid().v4();
    final passwordHash = UserModel.hashPassword(password);
    final answerHash = UserModel.hashAnswer(securityAnswer);
    
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
      securityQuestion: securityQuestion,
      securityAnswer: answerHash,
    );

    await localDataSource.createUser(newUser);
    return newUser;
  }

  @override
  Future<UserEntity?> updateUser({String? newUsername, String? newAvatarPath}) async {
    final currentUserId = await localDataSource.getCurrentSession();
    if (currentUserId == null) throw Exception('Người dùng chưa đăng nhập');

    final currentUser = await localDataSource.getUserById(currentUserId);
    if (currentUser == null) throw Exception('Không tìm thấy dữ liệu người dùng');

    final updatedUsername = newUsername ?? currentUser.username;
    
    String initials = currentUser.avatarInitials;
    if (newUsername != null && newUsername.isNotEmpty) {
      final parts = newUsername.trim().split(' ');
      if (parts.length > 1) {
        initials = parts.first[0].toUpperCase() + parts.last[0].toUpperCase();
      } else {
        initials = parts.first[0].toUpperCase();
      }
    }

    // Use newAvatarPath if provided, otherwise keep the current one
    final updatedAvatarPath = newAvatarPath ?? currentUser.avatarPath;

    final updatedUser = UserModel(
      id: currentUser.id,
      username: updatedUsername,
      email: currentUser.email,
      passwordHash: currentUser.passwordHash,
      createdAt: currentUser.createdAt,
      avatarInitials: initials,
      securityQuestion: currentUser.securityQuestion,
      securityAnswer: currentUser.securityAnswer,
      avatarPath: updatedAvatarPath,
    );

    await localDataSource.updateUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    final user = await localDataSource.getUserByEmail(email);
    if (user == null) {
      throw Exception('Tài khoản không tồn tại.');
    }

    final hash = UserModel.hashPassword(password);
    if (user.passwordHash != hash) {
      throw Exception('Mật khẩu không chính xác.');
    }

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

  @override
  Future<String?> getSecurityQuestion(String email) async {
    final user = await localDataSource.getUserByEmail(email);
    if (user == null) return null;
    return user.securityQuestion;
  }

  @override
  Future<bool> verifySecurityAnswer(String email, String answer) async {
    final user = await localDataSource.getUserByEmail(email);
    if (user == null) return false;
    final answerHash = UserModel.hashAnswer(answer);
    return user.securityAnswer == answerHash;
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    final user = await localDataSource.getUserByEmail(email);
    if (user == null) throw Exception('Tài khoản không tồn tại.');

    final newHash = UserModel.hashPassword(newPassword);
    final updatedUser = UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      passwordHash: newHash,
      createdAt: user.createdAt,
      avatarInitials: user.avatarInitials,
      securityQuestion: user.securityQuestion,
      securityAnswer: user.securityAnswer,
    );

    await localDataSource.updateUser(updatedUser);
  }
}
