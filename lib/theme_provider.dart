import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default theme mode
  ThemeMode _themeMode = ThemeMode.light;

  // Getter: which theme mode is active
  ThemeMode get themeMode => _themeMode;

  // Getter: quick check if dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle between dark/light
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Optionally set directly
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
