import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeText {
  // Define your text styles here
  double? fontSizeHead1;
  double? fontSizeHead2;
  double? fontSizeHead3;
  double? fontSizeBody;

  FontWeight? fontWeight;
  Color? color;
  String? fontFamily;
  GoogleFonts? googleFont;
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
      fontFamily: fontFamily ?? GoogleFonts.lato().fontFamily,
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
      fontFamily: fontFamily ?? GoogleFonts.lato().fontFamily,
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
      fontFamily: fontFamily ?? GoogleFonts.lato().fontFamily,
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
      fontFamily: fontFamily ?? GoogleFonts.lato().fontFamily,
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
    final baseTextTheme = GoogleFonts.cairoTextTheme();

    return baseTextTheme.copyWith(
      // Headline
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      // Title
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      // Body
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: colorScheme.onSurfaceVariant,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
      ),
      // Label
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 10,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
