import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Manages authentication state for the UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  UserEntity? _currentUser;
  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _errorMessage;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  /// Loads the saved session when the app starts.
  Future<void> checkAuthStatus() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.getCurrentUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.login(
        email: email,
        password: password,
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String username,
    String? bio,
  }) async {
    final user = _currentUser;
    if (user == null) {
      _errorMessage = 'No logged-in user found.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      _currentUser = await _authRepository.updateProfile(
        userId: user.id,
        username: username,
        bio: bio,
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }
}
