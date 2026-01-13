import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// ===============================================================
/// WEB FONTS – single source of truth
/// ===============================================================
class WebFonts {
  static const String fontFamily = 'Geist';

  // HEADERS
  static const double heroSize = 20;
  static const double headSize = 18;
  static const double titleSize = 16;
  static const double titleMediumSize = 15;

  // BODY
  static const double subSize = 14;
  static const double bodySmallSize = 13;
  static const double paraSize = 12;

  // SMALL TEXT
  static const double captionSize = 10;
  static const double overlineSize = 8;

  // WEIGHTS
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// ===============================================================
/// THEME HELPERS (optional, edge use only)
/// ===============================================================

bool isDarkMode(BuildContext context) {
  return shadcn.Theme.of(context).brightness == Brightness.dark;
}

Color resolveThemeColor(
  BuildContext context, {
  required Color darkColor,
  required Color lightColor,
}) {
  return isDarkMode(context) ? darkColor : lightColor;
}

/// ===============================================================
/// CORE TEXT STYLE FACTORY
/// ===============================================================
///
/// Color priority:
/// 1. `color` (explicit override)
/// 2. `darkColor + lightColor` (theme-aware custom)
/// 3. shadcn `colorScheme.foreground` (default)
///
TextStyle webTextStyle(
  BuildContext context, {
  Color? color,
  Color? darkColor,
  Color? lightColor,
  double? fontSize,
  FontWeight? fontWeight,
  double letterSpacing = 0, // 👈 stable default
  double? height,
  TextDecoration? decoration,
}) {
  final scheme = shadcn.Theme.of(context).colorScheme;

  final Color resolvedColor = color ??
      ((darkColor != null && lightColor != null)
          ? resolveThemeColor(
              context,
              darkColor: darkColor,
              lightColor: lightColor,
            )
          : scheme.foreground);

  return TextStyle(
    fontFamily: WebFonts.fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight ?? WebFonts.regular,
    color: resolvedColor,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
  );
}

/// ===============================================================
/// SEMANTIC TEXT STYLES
/// ===============================================================
class WebTextStyles {
  // ---------------- HEADERS ----------------

  static TextStyle hero(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.heroSize,
        fontWeight: WebFonts.bold,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle head(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.headSize,
        fontWeight: WebFonts.semiBold,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle title(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.titleSize,
        fontWeight: WebFonts.semiBold,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle titleMedium(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.titleMediumSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  // ---------------- BODY ----------------

  static TextStyle sub(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.subSize,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle bodySmall(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle para(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.paraSize,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle caption(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.captionSize,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  // ---------------- TABLE ----------------

  static TextStyle tableHeader(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.paraSize,
        fontWeight: WebFonts.bold,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle tableData(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.subSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  // ---------------- NAV / TABS ----------------

  static TextStyle tab(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        fontWeight: WebFonts.semiBold,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  // ---------------- DIALOGS ----------------

  static TextStyle dialogTitle(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.titleSize,
        fontWeight: WebFonts.semiBold,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle dialogContent(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.subSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  // ---------------------------------------- Watchlist ````````````````````````````

  static TextStyle symbol(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );
  static TextStyle price(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );
  static TextStyle priceChng(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );
  static TextStyle priceChngperc(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle priceWatch(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );

  static TextStyle pricePercent(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) =>
      webTextStyle(
        context,
        fontSize: WebFonts.bodySmallSize,
        fontWeight: WebFonts.medium,
        color: color,
        darkColor: darkColor,
        lightColor: lightColor,
      );
}
