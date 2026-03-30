import '../repositories/auth_repository.dart';

// UseCase xử lý Đăng xuất
class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
