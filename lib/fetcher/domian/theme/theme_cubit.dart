// lib/theme/theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeChanged(ThemeMode.system)) {
    loadTheme();
  }

  static const String _themeKey = StringApp.themeMode;

  void toggleTheme(bool isDark) {
    final newThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    _saveTheme(newThemeMode);

    emit(ThemeChanged(newThemeMode));
  }

  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex;
    if (themeMode == ThemeMode.light) {
      themeIndex = 0;
    } else if (themeMode == ThemeMode.dark) {
      themeIndex = 1;
    } else {
      themeIndex = 2;
    }
    await prefs.setInt(_themeKey, themeIndex);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? 2;
    ThemeMode loadedThemeMode;

    switch (themeIndex) {
      case 0:
        loadedThemeMode = ThemeMode.light;
        break;
      case 1:
        loadedThemeMode = ThemeMode.dark;
        break;
      default:
        loadedThemeMode = ThemeMode.system;
        break;
    }

    emit(ThemeChanged(loadedThemeMode));
  }
}
