import 'package:flutter/foundation.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;
  User? _user;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _checkInitialAuth();
  }

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.authenticating;
  String? get errorMessage => _errorMessage;
  User? get user => _user ?? _authRepository.currentUser;

  void _checkInitialAuth() {
    if (_authRepository.isAuthenticated()) {
      _user = _authRepository.currentUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email.trim(),
        password: password,
      );
      _user = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during login';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (_status == AuthStatus.error) {
        _status = _authRepository.isAuthenticated()
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
      }
      notifyListeners();
    }
  }
}
