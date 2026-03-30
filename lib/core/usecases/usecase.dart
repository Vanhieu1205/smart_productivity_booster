/// Abstract base class cho tất cả Use Cases trong app.
/// [Type] là kiểu trả về, [Params] là tham số đầu vào.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Dùng khi UseCase không cần tham số đầu vào
class NoParams {
  const NoParams();
}
