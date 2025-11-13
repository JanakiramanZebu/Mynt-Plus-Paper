import 'package:flutter/material.dart';
 
import 'package:google_fonts/google_fonts.dart';

import 'res.dart';

/// Web-specific font constants and text styles
/// This file handles all typography for web platform using Inter font
/// 
/// TYPOGRAPHY SYSTEM OVERVIEW:
/// ===========================
/// 
/// HEADERS (Use for titles, section headers, page titles):
/// - Hero (20px): Main page titles, major section headers
/// - Head (18px): Section titles, card headers, dialog titles
/// - Title (16px): Subsection titles, card titles, list item titles
/// - Title Medium (15px): Medium titles, slightly smaller card titles
/// 
/// BODY TEXT (Use for content, descriptions, data):
/// - Sub (14px): Primary body text, table data, form inputs, descriptions
/// - Body Small (13px): Secondary table data, compact text, smaller body content
/// - Para (12px): Secondary body text, helper text, fine print
/// 
/// SMALL TEXT (Use for metadata, labels, captions):
/// - Caption (10px): Timestamps, version info, small labels
/// - Overline (8px): Tiny labels, status indicators (rarely used)
/// 
/// USAGE EXAMPLES:
/// ===============
/// 
/// // Page/Screen Title
/// Text('Orders Book', style: WebTextStyles.head(isDarkTheme: theme.isDarkMode))
/// 
/// // Section Header
/// Text('Pending Orders', style: WebTextStyles.title(isDarkTheme: theme.isDarkMode))
/// 
/// // Table Header
/// Text('Instrument', style: WebTextStyles.tableHeader(isDarkTheme: theme.isDarkMode))
/// 
/// // Table Data / Body Text
/// Text('RELIANCE', style: WebTextStyles.sub(isDarkTheme: theme.isDarkMode))
/// 
/// // Button Text
/// Text('Submit', style: WebTextStyles.button(isDarkTheme: theme.isDarkMode))
/// 
/// // Helper Text / Caption
/// Text('Last updated 5 min ago', style: WebTextStyles.caption(isDarkTheme: theme.isDarkMode))
class WebFonts {
  // Font Family
  static const String fontFamily = 'inter';
  
  // ===== FONT SIZES - DO NOT CHANGE THESE =====
  // These are the ONLY allowed font sizes in the web project
  
  // HEADERS
  static const double heroSize = 20;      // Main page titles, major headers
  static const double headSize = 18;       // Section titles, card headers, dialog titles
  static const double titleSize = 16;      // Subsection titles, card titles, list item titles
  static const double titleMediumSize = 15; // Medium titles, slightly smaller card titles
  
  // BODY TEXT
  static const double subSize = 14;        // Primary body text, table data, form inputs
  static const double bodySmallSize = 13; // Secondary table data, compact text, smaller body text
  static const double paraSize = 12;      // Secondary body text, helper text, fine print
  
  // SMALL TEXT
  static const double captionSize = 10;    // Timestamps, version info, small labels
  static const double overlineSize = 8;    // Tiny labels (rarely used)
  
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

/// Web-specific text styles using Inter font
/// 
/// This class provides semantic text styles for consistent typography across the web app.
/// Always use these methods instead of hardcoding font sizes.
/// 
/// IMPORTANT: Use semantic methods (tableHeader, tableData, button, etc.) when available.
/// Only use custom() when absolutely necessary, and always use WebFonts constants for sizes.
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

  /// Title medium text style (15px)
  /// Use for medium titles, slightly smaller card titles, intermediate headings
  static TextStyle titleMedium({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.titleMediumSize,
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

  /// Body small text style (13px)
  /// Use for secondary table data, compact text, smaller body content
  static TextStyle bodySmall({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return _baseStyle(
      fontSize: WebFonts.bodySmallSize,
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
  /// 
  /// ⚠️ WARNING: Only use this when semantic methods don't fit your needs.
  /// Always use WebFonts constants (heroSize, headSize, etc.) for fontSize parameter.
  /// 
  /// Example:
  /// ```dart
  /// WebTextStyles.custom(
  ///   fontSize: WebFonts.subSize,  // ✅ Good - uses constant
  ///   isDarkTheme: theme.isDarkMode,
  /// )
  /// 
  /// WebTextStyles.custom(
  ///   fontSize: 13,  // ❌ Bad - hardcoded size
  ///   isDarkTheme: theme.isDarkMode,
  /// )
  /// ```
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

  // ===== SEMANTIC HELPER METHODS =====
  // Use these for common UI elements to ensure consistency

  /// Table header text style (14px, bold)
  /// Use for DataTable column headers, table column titles
  static TextStyle tableHeader({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.paraSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.bold,
    );
  }

  /// Table data text style (14px, regular)
  /// Use for DataTable cell content, table row data
  static TextStyle tableData({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight ?? WebFonts.medium,
    );
  }

  /// Compact table data text style (13px, regular)
  /// Use for secondary table data, compact displays, smaller table cells
  static TextStyle tableDataCompact({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return _baseStyle(
      fontSize: WebFonts.bodySmallSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight ?? WebFonts.medium,
    );
  }

  /// Button text style (14px, medium)
  /// Use for all button labels (ElevatedButton, TextButton, etc.)
  static TextStyle buttonXs({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return _baseStyle(
      fontSize: WebFonts.captionSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight ?? WebFonts.semiBold,
    );
  }
  static TextStyle buttonSm({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return _baseStyle(
      fontSize: WebFonts.paraSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight ?? WebFonts.semiBold,
    );
  }
  static TextStyle buttonMd({
    required bool isDarkTheme,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: fontWeight ?? WebFonts.semiBold,
    );
  }

  /// Form label text style (14px, medium)
  /// Use for TextFormField labels, InputDecoration labels
  static TextStyle formLabel({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.medium,
    );
  }

  /// Form input text style (14px, regular)
  /// Use for TextFormField input text, TextField content
  static TextStyle formInput({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.medium,
    );
  }

  /// Helper text style (12px, regular)
  /// Use for helper text, form hints, validation messages
  static TextStyle helperText({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.medium,
    );
  }

  /// Navigation item text style (14px, medium)
  /// Use for sidebar navigation, menu items, tabs
  static TextStyle navigation({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.medium,
    );
  }

  /// Card title text style (16px, semiBold)
  /// Use for card headers, card titles
  static TextStyle cardTitle({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.titleSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.semiBold,
    );
  }

  /// Card content text style (14px, regular)
  /// Use for card body content, card descriptions
  static TextStyle cardContent({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.regular,
    );
  }

  /// Dialog title text style (18px, bold)
  /// Use for dialog headers, modal titles
  static TextStyle dialogTitle({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.titleSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.semiBold,
    );
  }

  /// Dialog content text style (14px, regular)
  /// Use for dialog body text, modal content
  static TextStyle dialogContent({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.subSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.medium,
    );
  }

  /// Status badge text style (12px, medium)
  /// Use for status indicators, badges, chips
  static TextStyle statusBadge({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.paraSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.medium,
    );
  }

  /// Timestamp text style (10px, regular)
  /// Use for timestamps, dates, time displays
  static TextStyle timestamp({
    required bool isDarkTheme,
    Color? color,
  }) {
    return _baseStyle(
      fontSize: WebFonts.captionSize,
      isDarkTheme: isDarkTheme,
      color: color,
      fontWeight: WebFonts.regular,
    );
  }
}

 