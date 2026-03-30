import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// UseCase xử lý Đăng ký
class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserEntity?> call(String username, String email, String password) {
    return repository.register(username, email, password);
  }
}
