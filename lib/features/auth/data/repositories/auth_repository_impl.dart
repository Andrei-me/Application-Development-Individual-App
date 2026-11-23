import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

/// Data-layer implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final user = await _localDataSource.register(
      username: username,
      email: email,
      password: password,
    );
    return user.toEntity();
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final user = await _localDataSource.login(email: email, password: password);
    return user.toEntity();
  }

  @override
  Future<void> logout() {
    return _localDataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await _localDataSource.getCurrentUser();
    return user?.toEntity();
  }

  @override
  Future<UserEntity> updateProfile({
    required String userId,
    required String username,
    String? bio,
  }) async {
    final user = await _localDataSource.updateProfile(
      userId: userId,
      username: username,
      bio: bio,
    );
    return user.toEntity();
  }
}
