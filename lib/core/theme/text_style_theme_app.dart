import 'package:flutter/material.dart';

class ThemeText {
  // Define your text styles here
  double? fontSizeHead1;
  double? fontSizeHead2;
  double? fontSizeHead3;
  double? fontSizeBody;

  FontWeight? fontWeight;
  Color? color;
  String? fontFamily;
  TextOverflow? overflow;
  List<Shadow>? shadows;
  TextDecoration? decoration;
  Color? decorationColor;
  TextDecorationStyle? decorationStyle;
  double? decorationThickness;
  FontStyle? fontStyle;
  double? letterSpacing;
  double? wordSpacing;
  TextBaseline? textBaseline;
  double? height;

  // text style

  TextStyle get headline1 {
    return TextStyle(
      fontSize: fontSizeHead1 ?? 32,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? Colors.black,
      fontFamily: fontFamily ?? '',
      overflow: overflow ?? TextOverflow.ellipsis,
      shadows: shadows,
      decoration: decoration ?? TextDecoration.none,
      decorationColor: decorationColor ?? Colors.black,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle ?? FontStyle.normal,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
    );
  }

  TextStyle get headline2 {
    return TextStyle(
      fontSize: fontSizeHead2 ?? 25,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? Colors.black,
      fontFamily: fontFamily ?? '',
      overflow: overflow ?? TextOverflow.ellipsis,
      shadows: shadows,
      decoration: decoration ?? TextDecoration.none,
      decorationColor: decorationColor ?? Colors.black,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle ?? FontStyle.normal,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
    );
  }

  TextStyle get headline3 {
    return TextStyle(
      fontSize: fontSizeHead3 ?? 18,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? Colors.black,
      fontFamily: fontFamily ?? '',
      overflow: overflow ?? TextOverflow.ellipsis,
      shadows: shadows,
      decoration: decoration ?? TextDecoration.none,
      decorationColor: decorationColor ?? Colors.black,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle ?? FontStyle.normal,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
    );
  }

  TextStyle get body1 {
    return TextStyle(
      fontSize: fontSizeBody ?? 16,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? Colors.black,
      fontFamily: fontFamily ?? '',
      overflow: overflow ?? TextOverflow.ellipsis,
      shadows: shadows,
      decoration: decoration ?? TextDecoration.none,
      decorationColor: decorationColor ?? Colors.black,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle ?? FontStyle.normal,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
    );
  }

  static TextTheme getTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Headline
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      // Title
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colorScheme.onPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onPrimary,
      ),
      // Body
      bodyLarge: TextStyle(fontSize: 16, color: colorScheme.onPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: colorScheme.onPrimary),
      bodySmall: TextStyle(fontSize: 12, color: colorScheme.onPrimary),
      // Label
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      labelMedium: TextStyle(fontSize: 12, color: colorScheme.onPrimary),
      labelSmall: TextStyle(fontSize: 10, color: colorScheme.onPrimary),
    );
  }
}
