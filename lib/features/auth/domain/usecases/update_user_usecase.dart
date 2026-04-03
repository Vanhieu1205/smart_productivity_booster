import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// UseCase xử lý Update Tên cá nhân và Avatar
class UpdateUserUseCase {
  final AuthRepository repository;
  UpdateUserUseCase(this.repository);

  Future<UserEntity?> call({String? newUsername, String? newAvatarPath}) {
    return repository.updateUser(newUsername: newUsername, newAvatarPath: newAvatarPath);
  }
}
