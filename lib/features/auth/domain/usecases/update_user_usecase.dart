import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// UseCase xử lý Update Tên cá nhân
class UpdateUserUseCase {
  final AuthRepository repository;
  UpdateUserUseCase(this.repository);

  Future<UserEntity?> call({String? newUsername}) {
    return repository.updateUser(newUsername: newUsername);
  }
}
