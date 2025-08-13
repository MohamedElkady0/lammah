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
      color: ColorThemeApp.darkColorScheme.primary,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: Colors.black12,
      surfaceTintColor: ColorThemeApp.lightColorScheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorThemeApp.darkColorScheme.secondary,
        side: BorderSide(
          color: ColorThemeApp.darkColorScheme.primary,
          width: 2,
        ),
        foregroundColor: ColorThemeApp.darkColorScheme.onSecondary,
        elevation: 4,

        padding: EdgeInsets.all(10),
        iconColor: ColorThemeApp.tertiaryColor,
      ),
    ),
    iconTheme: IconThemeData(color: ColorThemeApp.secondaryColor, size: 30),

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
      color: ColorThemeApp.lightColorScheme.primary,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: Colors.black12,
      surfaceTintColor: ColorThemeApp.lightColorScheme.onPrimary,
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
