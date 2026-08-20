import 'package:flutter/material.dart';

/// Holds the user's appearance choice for the lifetime of the app.
///
/// System is the lightweight default. Persistence can be added later without
/// changing the screens that consume this provider.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }
}
