import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  ThemeData get light => AppTheme.lightTheme;
  ThemeData get dark => AppTheme.darkTheme;

  void toggleDark(bool enabled) {
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
