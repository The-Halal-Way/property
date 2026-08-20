import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property/config/theme/theme_provider.dart';

void main() {
  test('ThemeProvider updates its mode and notifies only on changes', () {
    final provider = ThemeProvider();
    addTearDown(provider.dispose);
    var notifications = 0;
    provider.addListener(() => notifications += 1);

    expect(provider.themeMode, ThemeMode.system);

    provider.setThemeMode(ThemeMode.dark);
    expect(provider.themeMode, ThemeMode.dark);
    expect(notifications, 1);

    provider.setThemeMode(ThemeMode.dark);
    expect(notifications, 1);

    provider.setThemeMode(ThemeMode.light);
    expect(provider.themeMode, ThemeMode.light);
    expect(notifications, 2);
  });
}
