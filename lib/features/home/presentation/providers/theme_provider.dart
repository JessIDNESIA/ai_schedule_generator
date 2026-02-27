import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk manage tema aplikasi (Light/Dark)
/// Handles theme switching dan persistence menggunakan SharedPreferences
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  late SharedPreferences _prefs;
  bool _isDarkMode = false;

  ThemeProvider();

  /// Initialize theme dari stored preference
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
  }

  /// Get current theme mode
  bool get isDarkMode => _isDarkMode;

  /// Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  /// Set theme explicitly
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return; // No change
    _isDarkMode = isDark;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
