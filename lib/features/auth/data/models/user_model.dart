import '../../domain/entities/user_entity.dart';

/// Data model for storing and retrieving user records locally.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.bio,
    required this.passwordHash,
  });

  final String passwordHash;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      passwordHash: json['passwordHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'passwordHash': passwordHash,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      bio: bio,
    );
  }

  UserModel copyWith({
    String? username,
    String? email,
    String? bio,
    String? passwordHash,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}
