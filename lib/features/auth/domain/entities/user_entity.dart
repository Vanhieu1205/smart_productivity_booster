class UserEntity {
  final String id;
  final String username;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final String avatarInitials;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.avatarInitials,
  });
}
