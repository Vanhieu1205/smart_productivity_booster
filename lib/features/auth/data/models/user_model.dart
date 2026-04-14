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

  @override
  @HiveField(6)
  final String? securityQuestion;

  @override
  @HiveField(7)
  final String? securityAnswer;

  @override
  @HiveField(8)
  final String? avatarPath;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.avatarInitials,
    this.securityQuestion,
    this.securityAnswer,
    this.avatarPath,
  }) : super(
          id: id,
          username: username,
          email: email,
          passwordHash: passwordHash,
          createdAt: createdAt,
          avatarInitials: avatarInitials,
          securityQuestion: securityQuestion,
          securityAnswer: securityAnswer,
          avatarPath: avatarPath,
        );

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      passwordHash: entity.passwordHash,
      createdAt: entity.createdAt,
      avatarInitials: entity.avatarInitials,
      securityQuestion: entity.securityQuestion,
      securityAnswer: entity.securityAnswer,
      avatarPath: entity.avatarPath,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    String? avatarInitials,
    String? securityQuestion,
    String? securityAnswer,
    String? avatarPath,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswer: securityAnswer ?? this.securityAnswer,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  static String hashPassword(String raw) {
    final bytes = utf8.encode(raw);
    return base64Encode(bytes);
  }

  static String hashAnswer(String raw) {
    final bytes = utf8.encode(raw.toLowerCase().trim());
    return base64Encode(bytes);
  }

  /// Chuyển đổi sang Map để lưu backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'avatarInitials': avatarInitials,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
      'avatarPath': avatarPath,
    };
  }

  /// Tạo UserModel từ Map (dùng khi restore backup)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      avatarInitials: json['avatarInitials'] as String,
      securityQuestion: json['securityQuestion'] as String?,
      securityAnswer: json['securityAnswer'] as String?,
      avatarPath: json['avatarPath'] as String?,
    );
  }
}
