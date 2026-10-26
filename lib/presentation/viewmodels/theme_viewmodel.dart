import 'package:flutter/material.dart';
import '../../core/storage/secure_storage_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final SecureStorageService _storageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeViewModel({required SecureStorageService storageService})
      : _storageService = storageService {
    final savedMode = _storageService.getThemeMode();
    if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedMode == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    _storageService.saveThemeMode(modeStr);
    notifyListeners();
  }
}
