import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// UseCase xử lý Đăng nhập
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) {
    return repository.login(email, password);
  }
}
