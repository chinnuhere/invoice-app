import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final savedTheme = await _storage.read(key: _themeKey);
    if (savedTheme != null) {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.write(key: _themeKey, value: mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
  
  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  ThemeData getTheme(BuildContext context) {
    return _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
}
