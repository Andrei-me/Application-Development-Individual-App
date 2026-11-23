import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';

/// Handles local persistence for authentication using SharedPreferences.
///
/// Users are stored as a JSON list and the active session is stored as a user ID.
class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  static const String _usersKey = 'auth_users';
  static const String _currentUserIdKey = 'current_user_id';

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedUsername = username.trim();

    final emailExists = users.any(
      (user) => user.email.toLowerCase() == normalizedEmail,
    );
    if (emailExists) {
      throw Exception('An account with this email already exists.');
    }

    final usernameExists = users.any(
      (user) => user.username.toLowerCase() == normalizedUsername.toLowerCase(),
    );
    if (usernameExists) {
      throw Exception('This username is already taken.');
    }

    final newUser = UserModel(
      id: _uuid.v4(),
      username: normalizedUsername,
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
    );

    users.add(newUser);
    await _saveUsers(users);
    await _prefs.setString(_currentUserIdKey, newUser.id);

    return newUser;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final normalizedEmail = email.trim().toLowerCase();
    final hashedPassword = _hashPassword(password);

    try {
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );

      if (user.passwordHash != hashedPassword) {
        throw Exception('Incorrect email or password.');
      }

      await _prefs.setString(_currentUserIdKey, user.id);
      return user;
    } catch (_) {
      throw Exception('Incorrect email or password.');
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_currentUserIdKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUserId = _prefs.getString(_currentUserIdKey);
    if (currentUserId == null) {
      return null;
    }

    final users = await _loadUsers();
    for (final user in users) {
      if (user.id == currentUserId) {
        return user;
      }
    }

    // If the stored session points to a missing user, clear it.
    await _prefs.remove(_currentUserIdKey);
    return null;
  }

  Future<UserModel> updateProfile({
    required String userId,
    required String username,
    String? bio,
  }) async {
    final users = await _loadUsers();
    final normalizedUsername = username.trim();
    final normalizedBio = bio?.trim();

    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('User not found. Please log in again.');
    }

    final usernameTaken = users.any(
      (u) =>
          u.id != userId &&
          u.username.toLowerCase() == normalizedUsername.toLowerCase(),
    );
    if (usernameTaken) {
      throw Exception('This username is already taken.');
    }

    final updatedUser = users[index].copyWith(
      username: normalizedUsername,
      bio: (normalizedBio == null || normalizedBio.isEmpty)
          ? null
          : normalizedBio,
    );

    users[index] = updatedUser;
    await _saveUsers(users);
    return updatedUser;
  }

  Future<List<UserModel>> _loadUsers() async {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      return <UserModel>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveUsers(List<UserModel> users) async {
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await _prefs.setString(_usersKey, encoded);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
