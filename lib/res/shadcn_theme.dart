import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'web_colors.dart';

/// Shadcn theme configuration for Mynt Plus
/// Maps existing WebColors to shadcn theme system
class ShadcnTheme {
  /// Creates a light theme using WebColors
  static shadcn.ThemeData lightTheme() {
    // Start with a base shadcn color scheme and customize it
    const baseScheme = shadcn.ColorSchemes.lightDefaultColor;

    return shadcn.ThemeData(
      colorScheme: baseScheme.copyWith(
        // Primary brand colors
        primary: () => WebColors.primary,
        primaryForeground: () => Colors.white,

        // Secondary colors
        secondary: () => WebColors.buttonSecondary,
        secondaryForeground: () => WebColors.textPrimary,

        // Destructive (error/danger)
        destructive: () => WebColors.error,
        destructiveForeground: () => Colors.white,

        // Muted (subtle backgrounds)
        muted: () => WebColors.surfaceVariant,
        mutedForeground: () => WebColors.textSecondary,

        // Accent colors
        accent: () => WebColors.secondary,
        accentForeground: () => Colors.white,

        // Popover & Card surfaces
        popover: () => WebColors.cardBackground,
        popoverForeground: () => WebColors.textPrimary,
        card: () => WebColors.cardBackground,
        cardForeground: () => WebColors.textPrimary,

        // Borders
        border: () => WebColors.border,
        input: () => WebColors.inputBorder,

        // Backgrounds
        background: () => WebColors.background,
        foreground: () => WebColors.textPrimary,

        // Ring (focus outline)
        ring: () => WebColors.borderFocus,
      ),

      // Border radius (0.5 = medium roundness)
      radius: 0.5,
    );
  }

  /// Creates a dark theme using WebDarkColors
  static shadcn.ThemeData darkTheme() {
    // Start with a base shadcn dark color scheme and customize it
    const baseScheme = shadcn.ColorSchemes.darkDefaultColor;

    return shadcn.ThemeData(
      colorScheme: baseScheme.copyWith(
        // Primary brand colors
        primary: () => WebDarkColors.primary,
        primaryForeground: () => Colors.white,

        // Secondary colors
        secondary: () => WebDarkColors.buttonSecondary,
        secondaryForeground: () => WebDarkColors.textPrimary,

        // Destructive (error/danger)
        destructive: () => WebDarkColors.error,
        destructiveForeground: () => Colors.white,

        // Muted (subtle backgrounds)
        muted: () => WebDarkColors.surfaceVariant,
        mutedForeground: () => WebDarkColors.textSecondary,

        // Accent colors
        accent: () => WebDarkColors.secondary,
        accentForeground: () => Colors.white,

        // Popover & Card surfaces
        popover: () => WebDarkColors.cardBackground,
        popoverForeground: () => WebDarkColors.textPrimary,
        card: () => WebDarkColors.cardBackground,
        cardForeground: () => WebDarkColors.textPrimary,

        // Borders
        border: () => WebDarkColors.border,
        input: () => WebDarkColors.inputBorder,

        // Backgrounds
        background: () => WebDarkColors.background,
        foreground: () => WebDarkColors.textPrimary,

        // Ring (focus outline)
        ring: () => WebDarkColors.borderFocus,
      ),

      // Border radius (0.5 = medium roundness)
      radius: 0.5,
    );
  }

  /// Get theme based on dark mode boolean
  static shadcn.ThemeData getTheme({required bool isDarkMode}) {
    return isDarkMode ? darkTheme() : lightTheme();
  }
}

/// Extension to add custom colors to shadcn ColorScheme
/// These are trading-specific colors not in standard shadcn
extension TradingColorScheme on shadcn.ColorScheme {
  /// Profit/gain color (green)
  Color get profit => const Color(0xFF00B14F);

  /// Profit color for dark mode
  Color get profitDark => const Color(0xFF68D391);

  /// Loss/negative color (red)
  Color get loss => const Color(0xFFFF1717);

  /// Loss color for dark mode
  Color get lossDark => const Color(0xFFFF6B6B);

  /// Warning/pending color (orange)
  Color get warning => const Color(0xFFFFB038);

  /// Warning color for dark mode
  Color get warningDark => const Color(0xFFFFD93D);

  /// Info color (blue)
  Color get info => const Color(0xFF3182CE);

  /// Info color for dark mode
  Color get infoDark => const Color(0xFF63B3ED);

  /// Success color (matches profit but semantic difference)
  Color get success => const Color(0xFF00B14F);

  /// Success color for dark mode
  Color get successDark => const Color(0xFF68D391);
}
