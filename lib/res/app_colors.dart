import 'package:flutter/material.dart';

/// Color system providing theme-aware colors and semantic color usage.
///
/// Automatically adapts to light and dark themes while providing consistent
/// color application across the application. Uses semantic color roles
/// rather than appearance-based color selection.
///
/// Provides proper contrast ratios for accessibility and type-safe color
/// variants to prevent errors.

/// Defines semantic color roles for consistent color usage.
///
/// Helps choose colors based on their purpose rather than appearance,
/// making the app more maintainable and theme-consistent.
enum AppColorRole {
  /// Primary brand color - for main actions, links, brand elements
  primary,

  /// Secondary text and less prominent elements
  secondary,

  /// Card backgrounds, dialog surfaces, elevated elements
  surface,

  /// Screen backgrounds, main container backgrounds
  background,

  /// Error states, destructive actions, validation errors
  error,

  /// Warning states, caution indicators
  warning,

  /// Success states, completion indicators
  success,

  /// Informational content, tips, neutral status
  info,
}

/// # Theme-Aware Color System
///
/// Provides consistent, accessible colors that automatically adapt to light/dark themes.
/// All colors are designed with proper contrast ratios and semantic meaning.
///
/// ## Color Categories:
///
/// ### 🎨 **Brand Colors**
/// Primary brand colors used for key actions and brand identity
/// - `primary` (#0037B7) - Main brand blue
/// - `primaryVariant` (#002E9B) - Darker brand blue for variants
///
/// ### 📱 **Surface Colors**
/// Background colors for different surface levels
/// - `surface` - Card backgrounds, dialog surfaces
/// - `background` - Main screen backgrounds
/// - `surfaceVariant` - Subtle background variations
///
/// ### 📝 **Text Colors**
/// Hierarchical text colors with proper contrast
/// - `textPrimary` - Main content text
/// - `textSecondary` - Secondary information
/// - `textTertiary` - Helper text, captions
/// - `textDisabled` - Disabled state text
///
/// ### 🚦 **Status Colors**
/// Semantic colors for different states
/// - `error` - Error states, validation failures
/// - `warning` - Caution, pending states
/// - `success` - Completion, positive feedback
/// - `info` - Neutral information, tips
///
/// ## Usage Examples:
/// ```dart
/// // Basic text color (adapts to theme)
/// Text(
///   "Hello World",
///   style: TextStyle(
///     color: AppColors.getTextColor(context),
///   ),
/// )
///
/// // Container with surface color
/// Container(
///   color: AppColors.getSurfaceColor(context),
///   child: Text("Card content"),
/// )
///
/// // Error message
/// Text(
///   "Invalid input",
///   style: TextStyle(color: AppColors.error),
/// )
///
/// // Status indicator
/// Container(
///   color: AppColors.getStatusColor(AppStatusColor.success),
///   child: Text("Complete"),
/// )
/// ```
///
/// ## Theme Integration:
/// ```dart
/// // The system automatically detects theme
/// final isDark = Theme.of(context).brightness == Brightness.dark;
///
/// // And provides appropriate colors
/// final textColor = AppColors.getTextColor(context); // White in dark, black in light
/// final bgColor = AppColors.getBackgroundColor(context); // Black in dark, white in light
/// ```
class AppColors {
  AppColors._(); // Private constructor

  // === PRIMARY COLORS ===
  static const Color primary = Color(0xFF0037B7);
  static const Color primaryVariant = Color(0xFF002E9B);
  static const Color primaryLight = Color(0xFF4A6CF7);
  static const Color primaryDark = Color(0xFF001F6B);

  // === SURFACE COLORS ===
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF000000);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceVariantDark = Color(0xFF1A1A1A);

  // === TEXT COLORS ===
  static const Color textPrimary = Color(0xFF141414);
  static const Color textSecondary = Color(0xFF737373);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);

  // Dark theme text colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color textDisabledDark = Color(0xFF404040);

  // === BACKGROUND COLORS ===
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFFF8F9FA);
  static const Color backgroundSecondaryDark = Color(0xFF0A0A0A);

  // === BORDER COLORS ===
  static const Color border = Color(0xFFDBDBDB);
  static const Color borderDark = Color(0xFF333333);
  static const Color borderFocused = Color(0xFF0037B7);
  static const Color borderError = Color(0xFFE53E3E);

  // === STATUS COLORS ===
  static const Color error = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFED7D7);
  static const Color errorDark = Color(0xFFC53030);

  static const Color warning = Color(0xFFDD6B20);
  static const Color warningLight = Color(0xFFFEEBC8);
  static const Color warningDark = Color(0xFFC05621);

  static const Color success = Color(0xFF38A169);
  static const Color successLight = Color(0xFFC6F6D5);
  static const Color successDark = Color(0xFF2F855A);

  static const Color info = Color(0xFF3182CE);
  static const Color infoLight = Color(0xFFBEE3F8);
  static const Color infoDark = Color(0xFF2C5282);

  // === NEUTRAL GRAYS ===
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // === THEME-AWARE COLOR METHODS ===

  /// Returns appropriate text color based on current theme and text hierarchy.
  ///
  /// Automatically adapts to light and dark themes while ensuring proper
  /// contrast ratios for accessibility.
  ///
  /// The [context] parameter is used to determine the current theme.
  /// The [variant] parameter specifies the text hierarchy level:
  /// primary (highest contrast), secondary (medium), tertiary (lower),
  /// or disabled (lowest contrast).
  static Color getTextColor(
    BuildContext context, {
    AppTextColorVariant variant = AppTextColorVariant.primary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (variant) {
      case AppTextColorVariant.primary:
        return isDark ? textPrimaryDark : textPrimary;
      case AppTextColorVariant.secondary:
        return isDark ? textSecondaryDark : textSecondary;
      case AppTextColorVariant.tertiary:
        return isDark ? textTertiaryDark : textTertiary;
      case AppTextColorVariant.disabled:
        return isDark ? textDisabledDark : textDisabled;
    }
  }

  /// Get theme-aware surface color
  static Color getSurfaceColor(BuildContext context, {bool variant = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (variant) {
      return isDark ? surfaceVariantDark : surfaceVariant;
    }
    return isDark ? surfaceDark : surface;
  }

  /// Get theme-aware background color
  static Color getBackgroundColor(BuildContext context,
      {bool secondary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (secondary) {
      return isDark ? backgroundSecondaryDark : backgroundSecondary;
    }
    return isDark ? backgroundDark : background;
  }

  /// Get theme-aware border color
  static Color getBorderColor(BuildContext context, {bool focused = false}) {
    if (focused) return borderFocused;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? borderDark : border;
  }

  /// Get status color with optional light variant
  static Color getStatusColor(AppStatusColor status, {bool light = false}) {
    switch (status) {
      case AppStatusColor.error:
        return light ? errorLight : error;
      case AppStatusColor.warning:
        return light ? warningLight : warning;
      case AppStatusColor.success:
        return light ? successLight : success;
      case AppStatusColor.info:
        return light ? infoLight : info;
    }
  }

  /// Get color for specific UI role
  static Color getRoleColor(
    BuildContext context,
    AppColorRole role, {
    bool variant = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (role) {
      case AppColorRole.primary:
        return variant ? primaryVariant : primary;
      case AppColorRole.secondary:
        return getTextColor(context, variant: AppTextColorVariant.secondary);
      case AppColorRole.surface:
        return getSurfaceColor(context, variant: variant);
      case AppColorRole.background:
        return getBackgroundColor(context, secondary: variant);
      case AppColorRole.error:
        return error;
      case AppColorRole.warning:
        return warning;
      case AppColorRole.success:
        return success;
      case AppColorRole.info:
        return info;
    }
  }
}

/// Text color variants for semantic usage
enum AppTextColorVariant {
  primary,
  secondary,
  tertiary,
  disabled,
}

/// Status color types
enum AppStatusColor {
  error,
  warning,
  success,
  info,
}