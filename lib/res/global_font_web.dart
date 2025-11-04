import 'package:flutter/material.dart';
 
import 'package:google_fonts/google_fonts.dart';

import 'res.dart';

/// Web-specific font constants and text styles
/// This file handles all typography for web platform using Tenon font
class WebFonts {
  // Font Family
  static const String fontFamily = 'inter';
  
  // Font Sizes
  static const double heroSize = 20;
  static const double headSize = 18;
  static const double titleSize = 16;
  static const double subSize = 14;
  static const double paraSize = 12;
  static const double captionSize = 10;
  static const double overlineSize = 8;
  
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // Letter Spacing
  static const double defaultLetterSpacing = 0.5;
  static const double tightLetterSpacing = 0.25;
  static const double wideLetterSpacing = 1.0;
}

/// Web-specific text styles using Tenon font
class WebTextStyles {
  /// Base text style with common properties
  static TextStyle _baseStyle({
    required double fontSize,
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    final base = TextStyle(
      fontSize: fontSize,
      color: color ?? (isDarkTheme ? colors.colorWhite : colors.colorBlack),
      fontWeight: fontWeight ?? WebFonts.regular,
      letterSpacing: letterSpacing ?? WebFonts.defaultLetterSpacing,
      height: height,
      decoration: decoration,
    );
    return GoogleFonts.inter(textStyle: base);
  }

  /// Hero text style (20px)
  static TextStyle hero({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.heroSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Head text style (18px)
  static TextStyle head({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.headSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Title text style (16px)
  static TextStyle title({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.titleSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Sub text style (14px)
  static TextStyle sub({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Paragraph text style (12px)
  static TextStyle para({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.paraSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Caption text style (10px)
  static TextStyle caption({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.captionSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Overline text style (8px)
  static TextStyle overline({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.overlineSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Custom text style with any font size
  static TextStyle custom({
    required double fontSize,
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return _baseStyle(
      fontSize: fontSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}

 