import 'package:flutter/material.dart';
import 'package:lammah/core/theme/color_theme_app.dart';
import 'package:lammah/core/theme/text_style_theme_app.dart';

class ThemesApp {
  static ThemeData dark = ThemeData.dark().copyWith(
    colorScheme: ColorThemeApp.darkColorScheme,
    scaffoldBackgroundColor: ColorThemeApp.darkColorScheme.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorThemeApp.darkColorScheme.primary,
      foregroundColor: ColorThemeApp.darkColorScheme.onPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: ColorThemeApp.darkColorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorThemeApp.darkColorScheme.primary,
        foregroundColor: ColorThemeApp.darkColorScheme.onPrimary,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    ),

    textTheme: ThemeText.getTextTheme(ColorThemeApp.darkColorScheme),
  );

  static ThemeData light = ThemeData.light().copyWith(
    colorScheme: ColorThemeApp.lightColorScheme,
    scaffoldBackgroundColor: ColorThemeApp.lightColorScheme.tertiary,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorThemeApp.lightColorScheme.primary,
      foregroundColor: ColorThemeApp.lightColorScheme.onPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: ColorThemeApp.lightColorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorThemeApp.lightColorScheme.secondary,
        side: BorderSide(
          color: ColorThemeApp.lightColorScheme.primary,
          width: 2,
        ),
        foregroundColor: ColorThemeApp.lightColorScheme.onSecondary,
        elevation: 4,

        padding: EdgeInsets.all(10),
        iconColor: ColorThemeApp.tertiaryColor,
      ),
    ),
    iconTheme: IconThemeData(color: ColorThemeApp.secondaryColor, size: 30),

    textTheme: ThemeText.getTextTheme(ColorThemeApp.lightColorScheme),
  );
}
