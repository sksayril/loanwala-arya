import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Theme colors based on current theme mode
  Color get backgroundColor {
    return _themeMode == ThemeMode.dark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F7FA);
  }

  Color get cardBackground {
    return _themeMode == ThemeMode.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  Color get textPrimary {
    return _themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.black87;
  }

  Color get textSecondary {
    return _themeMode == ThemeMode.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  Color get borderColor {
    return _themeMode == ThemeMode.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
  }
}
