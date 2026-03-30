import 'package:equatable/equatable.dart';

/// Base class cho tất cả lỗi trong app
abstract class Failure extends Equatable {
  final String message;
  const Failure({this.message = ''});

  @override
  List<Object?> get props => [message];
}

/// Lỗi từ local database (Hive)
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Lỗi cơ sở dữ liệu cục bộ'});
}

/// Lỗi không tìm thấy dữ liệu
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Không tìm thấy dữ liệu'});
}

/// Lỗi xác thực đầu vào
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Dữ liệu không hợp lệ'});
}
