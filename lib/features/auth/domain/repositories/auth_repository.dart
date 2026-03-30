import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> register(String username, String email, String password);
  Future<UserEntity?> updateUser({String? newUsername});
  Future<UserEntity?> login(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
}
