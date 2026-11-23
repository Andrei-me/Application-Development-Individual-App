import '../entities/user_entity.dart';

/// Contract for authentication operations.
/// Implementations can use local storage now and be swapped later.
abstract class AuthRepository {
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> updateProfile({
    required String userId,
    required String username,
    String? bio,
  });
}
