import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
class SettingsService {
  static const hasLaunchedBeforeKey = 'hasLaunchedBefore';
  static const themeModeKey = 'themeMode';

  Future<bool> hasLaunchedBefore() async {
    final prefs = await SharedPreferences.getInstance();
    final maybeHasLaunchedBefore = prefs.getBool(hasLaunchedBeforeKey);
    return maybeHasLaunchedBefore ?? false;
  }

  Future<void> setHasLaunchedBefore(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasLaunchedBeforeKey, value);
  }

  /// Loads the User's preferred ThemeMode from local.
  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(themeModeKey);
    if (index == null || index >= ThemeMode.values.length || index < 0) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }

  /// Persists the user's preferred ThemeMode to local.
  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeModeKey, theme.index);
  }
}
