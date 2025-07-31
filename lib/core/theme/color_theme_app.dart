import 'package:flutter/material.dart';

class ColorThemeApp {
  static Color primaryColor = const Color(0xFF183B4E);
  static Color secondaryColor = const Color(0xFFDDA853);
  static Color tertiaryColor = const Color(0xFFF5EEDC);
  static Color backgroundColor = const Color(0xFF27548A);

  static Color c1 = const Color(0xFF7FD6EB);
  static Color c2 = const Color(0xFF7C61E8);
  static Color c3 = const Color(0xFFD905A7);
  static Color c4 = const Color(0xFF4239C6);
  static Color c5 = const Color(0xFFFD1C3F);
  static Color c6 = const Color(0xFF1B1B1B);
  static Color c7 = const Color(0xFFBA1467);
  static Color c8 = const Color(0xFF38071B);
  static Color c9 = const Color(0xFF6C8697);
  static Color c10 = const Color(0xFF624F3F);
  static Color c11 = const Color(0xFF53DCCD);

  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: backgroundColor,
    brightness: Brightness.light,
  );

  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.dark,
  );
}
