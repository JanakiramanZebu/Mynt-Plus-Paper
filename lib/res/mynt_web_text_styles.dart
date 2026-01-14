import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:google_fonts/google_fonts.dart';

/// ===============================================================
/// WEB FONTS – single source of truth
/// ===============================================================
class WebFonts {
  static const String fontFamily = 'Inter'; // Google Fonts Inter

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

  // Use Google Fonts Inter as base and merge with custom properties
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight ?? WebFonts.regular,
    color: resolvedColor,
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
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.heroSize,
      fontWeight: WebFonts.bold,
      color: resolvedColor,
      
    );
  }

  static TextStyle head(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.headSize,
      fontWeight: WebFonts.semiBold,
      color: resolvedColor,
      
    );
  }

  static TextStyle title(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.titleSize,
      fontWeight: WebFonts.semiBold,
      color: resolvedColor,
      
    );
  }

  static TextStyle titleMedium(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.titleMediumSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }

  // ---------------- BODY ----------------

  static TextStyle sub(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.regular,
      color: resolvedColor,
      
    );
  }

  static TextStyle bodySmall(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.bodySmallSize,
      fontWeight: WebFonts.regular,
      color: resolvedColor,
      
    );
  }

  static TextStyle para(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.paraSize,
      fontWeight: WebFonts.regular,
      color: resolvedColor,
      
    );
  }

  static TextStyle caption(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.captionSize,
      fontWeight: WebFonts.regular,
      color: resolvedColor,
      
    );
  }













  // ---------------- BUTTONS ----------------
  static TextStyle buttonSm(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);

    return GoogleFonts.inter(
      fontSize: WebFonts.captionSize,
      fontWeight: WebFonts.bold,
      color: resolvedColor,
      
    );
  }
  static TextStyle buttonMd(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);

    return GoogleFonts.inter(
      fontSize: WebFonts.paraSize,
      fontWeight: WebFonts.bold,
      color: resolvedColor,
      
    );
  }
  static TextStyle buttonXl(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);

    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.bold,
      color: resolvedColor,
      
    );
  }
  // ---------------- TABLE ----------------

  static TextStyle tableHeader(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.paraSize,
      fontWeight: WebFonts.bold,
      color: resolvedColor,
      
    );
  }

  static TextStyle tableData(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }

  // ---------------- NAV / TABS ----------------

  static TextStyle tab(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.bodySmallSize,
      fontWeight: WebFonts.semiBold,
      color: resolvedColor,
      
    );
  }

  // ---------------- DIALOGS ----------------

  static TextStyle dialogTitle(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.titleSize,
      fontWeight: WebFonts.semiBold,
      color: resolvedColor,
      
    );
  }

  static TextStyle dialogContent(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }

  // ---------------------------------------- Watchlist ````````````````````````````

  static TextStyle symbol(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }
  static TextStyle price(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }
  static TextStyle priceChng(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }
  static TextStyle priceChngperc(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }

  static TextStyle priceWatch(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }

  static TextStyle pricePercent(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }

      // ---------------- search text and placeholder text ----------------

      static TextStyle searchText(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }
      static TextStyle placeholderText(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.subSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }


      // ---------------- Tab list text  ----------------

      static TextStyle tabListText(BuildContext context,
          {Color? color, Color? darkColor, Color? lightColor}) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final Color resolvedColor = color ??
        ((darkColor != null && lightColor != null)
            ? resolveThemeColor(
                context,
                darkColor: darkColor,
                lightColor: lightColor,
              )
            : scheme.foreground);
    
    return GoogleFonts.inter(
      fontSize: WebFonts.bodySmallSize,
      fontWeight: WebFonts.medium,
      color: resolvedColor,
      
    );
  }
}
