import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_service.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final mode = HiveService.settingsBox.get('theme_mode', defaultValue: 'system');
    switch (mode) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await HiveService.settingsBox.put('theme_mode', value);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class MinAttendanceNotifier extends StateNotifier<double> {
  MinAttendanceNotifier() : super(75.0) {
    _loadMinAttendance();
  }

  void _loadMinAttendance() {
    state = HiveService.settingsBox.get('min_attendance', defaultValue: 75.0);
  }

  Future<void> setMinAttendance(double value) async {
    state = value;
    await HiveService.settingsBox.put('min_attendance', value);
  }
}

final minAttendanceProvider = StateNotifierProvider<MinAttendanceNotifier, double>((ref) {
  return MinAttendanceNotifier();
});
