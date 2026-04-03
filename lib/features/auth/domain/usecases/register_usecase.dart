import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserEntity?> call(
    String username,
    String email,
    String password,
    String securityQuestion,
    String securityAnswer,
  ) {
    return repository.register(
      username,
      email,
      password,
      securityQuestion,
      securityAnswer,
    );
  }
}
