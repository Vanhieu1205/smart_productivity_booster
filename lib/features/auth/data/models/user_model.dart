import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 3)
class UserModel extends UserEntity {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String username;

  @override
  @HiveField(2)
  final String email;

  @override
  @HiveField(3)
  final String passwordHash;

  @override
  @HiveField(4)
  final DateTime createdAt;

  @override
  @HiveField(5)
  final String avatarInitials;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.avatarInitials,
  }) : super(
          id: id,
          username: username,
          email: email,
          passwordHash: passwordHash,
          createdAt: createdAt,
          avatarInitials: avatarInitials,
        );

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      passwordHash: entity.passwordHash,
      createdAt: entity.createdAt,
      avatarInitials: entity.avatarInitials,
    );
  }

  // Hàm băm mật khẩu đơn giản bằng base64 (Yêu cầu đề tài không cài thêm package ngoại như crypto)
  static String hashPassword(String raw) {
    final bytes = utf8.encode(raw);
    return base64Encode(bytes);
  }
}
