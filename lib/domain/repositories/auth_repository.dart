import '../entities/user.dart';

abstract class AuthRepository {
  Future<({String token, User user})> login({
    required String email,
    required String password,
  });

  Future<User> getProfile();

  Future<void> logout();

  bool isAuthenticated();

  User? get currentUser;

  String? get currentToken;
}
