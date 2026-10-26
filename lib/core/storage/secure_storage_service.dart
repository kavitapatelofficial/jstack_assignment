import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

class SecureStorageService {
  static const String _keyToken = 'auth_access_token';
  static const String _keyUser = 'auth_user_data';
  static const String _keyBaseUrl = 'api_custom_base_url';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyCachedBalance = 'cached_wallet_balance';
  static const String _keyCachedTransactions = 'cached_transactions';

  final SharedPreferences _prefs;

  SecureStorageService(this._prefs);

  static Future<SecureStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SecureStorageService(prefs);
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
  }

  // User management
  Future<void> saveUser(User user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  User? getUser() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs.remove(_keyUser);
  }

  // Clear entire session
  Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  // Custom base URL for testing
  Future<void> saveCustomBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  String? getCustomBaseUrl() {
    return _prefs.getString(_keyBaseUrl);
  }

  Future<void> clearCustomBaseUrl() async {
    await _prefs.remove(_keyBaseUrl);
  }

  // Theme mode
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(_keyThemeMode);
  }

  // Cache wallet balance
  Future<void> cacheBalance(double balance) async {
    await _prefs.setDouble(_keyCachedBalance, balance);
  }

  double? getCachedBalance() {
    return _prefs.getDouble(_keyCachedBalance);
  }

  // Cache transactions JSON
  Future<void> cacheTransactions(List<Map<String, dynamic>> rawList) async {
    await _prefs.setString(_keyCachedTransactions, jsonEncode(rawList));
  }

  List<Map<String, dynamic>>? getCachedTransactions() {
    final raw = _prefs.getString(_keyCachedTransactions);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }
}
