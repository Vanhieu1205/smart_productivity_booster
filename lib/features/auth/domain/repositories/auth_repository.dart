import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> register(String username, String email, String password, String securityQuestion, String securityAnswer);
  Future<UserEntity?> updateUser({String? newUsername, String? newAvatarPath});
  Future<UserEntity?> login(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<String?> getSecurityQuestion(String email);
  Future<bool> verifySecurityAnswer(String email, String answer);
  Future<void> resetPassword(String email, String newPassword);
}
