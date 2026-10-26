import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final SecureStorageService _storageService;

  User? _currentUser;
  String? _currentToken;

  AuthRepositoryImpl({
    required AuthService authService,
    required SecureStorageService storageService,
  })  : _authService = authService,
        _storageService = storageService {
    _currentToken = _storageService.getToken();
    _currentUser = _storageService.getUser();
  }

  @override
  User? get currentUser => _currentUser;

  @override
  String? get currentToken => _currentToken;

  @override
  bool isAuthenticated() {
    return _currentToken != null && _currentToken!.isNotEmpty;
  }

  @override
  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(email: email, password: password);
    final data = response['data'] as Map<String, dynamic>;
    final token = data['accessToken'] as String;
    final userData = data['user'] as Map<String, dynamic>;
    final user = User.fromJson(userData);

    _currentToken = token;
    _currentUser = user;

    await _storageService.saveToken(token);
    await _storageService.saveUser(user);

    return (token: token, user: user);
  }

  @override
  Future<User> getProfile() async {
    final response = await _authService.getProfile();
    final data = response['data'] as Map<String, dynamic>;
    final user = User.fromJson(data);
    _currentUser = user;
    await _storageService.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    _currentToken = null;
    _currentUser = null;
    await _storageService.clearSession();
  }
}
