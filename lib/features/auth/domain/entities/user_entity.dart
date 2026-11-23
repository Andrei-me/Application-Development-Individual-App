/// Represents an authenticated user in the app.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
  });

  final String id;
  final String username;
  final String email;

  /// Optional profile information (e.g. a short bio/about me).
  final String? bio;
}
