import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// UseCase kiểm tra trạng thái Session Hive
class CheckAuthStatusUseCase {
  final AuthRepository repository;
  CheckAuthStatusUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}
