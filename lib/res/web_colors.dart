import 'package:flutter/material.dart';

/// Web-specific color constants and theme management
/// This file handles all colors for web platform
class WebColors {
  // === PRIMARY BRAND COLORS ===
  static const Color primary = Color(0xFF0037B7);
  static const Color primaryLight = Color(0xFF0037B7);
  static const Color primaryDark = Color(0xFF002A8F);
  
  // === SECONDARY COLORS ===
  static const Color secondary = Color(0xFF0052CC);
  static const Color tertiary = Color(0xFFC40024);
  
  // === TEXT COLORS ===
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF434343);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF999999);
  
  // === STATUS COLORS ===
  static const Color success = Color(0xFF00B14F);
  static const Color error = Color(0xFFFF1717);
  static const Color warning = Color(0xFFFFB038);
  static const Color info = Color(0xFF3182CE);
  static const Color pending = Color(0xFFFFB038);
  
  // === BACKGROUND COLORS ===
  static const Color background = Color(0xFF09090B); // zinc-950 - same as dark theme background
  static const Color backgroundSecondary = Color(0xFFF9F9F9);
  static const Color backgroundTertiary = Color(0xFFF1F3F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color overlay = Color(0x80000000);
  
  // === SURFACE COLORS ===
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFFAFAFA);
  
  // === BORDER COLORS ===
  static const Color border = Color(0xFFDDE2E7);
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderFocus = Color(0xFF0037B7);
  static const Color borderError = Color(0xFFFF1717);
  static const Color borderSuccess = Color(0xFF00B14F);
  static const Color divider = Color(0xFFDDE2E7);
  
  // === INTERACTIVE COLORS ===
  static const Color buttonPrimary = Color(0xFF0037B7);
  static const Color buttonSecondary = Color(0xFFF1F3F8);
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonHover = Color(0xFF002A8F);
  static const Color buttonActive = Color(0xFF001F7A);
  
  // === INPUT COLORS ===
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFB0B0B0);
  static const Color inputBorderFocus = Color(0xFF0037B7);
  static const Color inputBorderError = Color(0xFFFF1717);
  static const Color inputPlaceholder = Color(0xFF999999);
  
  // === NAVIGATION COLORS ===
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navItem = Color(0xFF4A4A4A);
  static const Color navItemHover = Color(0xFF0037B7);
  static const Color navItemActive = Color(0xFF0037B7);
  static const Color navDivider = Color(0xFFDDE2E7);
  
  // === DATA COLORS ===
  static const Color profit = Color(0xFF00B14F); // Match main colors.profit
  static const Color loss = Color(0xFFFF1717); // Match main colors.loss (fixed invalid color)
  static const Color neutral = Color(0xFF4A4A4A);
  
  // === ICON COLORS ===
  static const Color icon = Color(0xFF777777);
  static const Color iconPrimary = Color(0xFF0037B7);
  static const Color iconSecondary = Color(0xFF4A4A4A);
  static const Color iconDisabled = Color(0xFFBDBDBD);
  
  // === FEEDBACK COLORS ===
  static const Color toastSuccess = Color(0xFF00B14F);
  static const Color toastError = Color(0xFFFF1717);
  static const Color toastWarning = Color(0xFFFFB038);
  static const Color toastInfo = Color(0xFF3182CE);
}

/// Dark theme colors
class WebDarkColors {
  // === PRIMARY BRAND COLORS ===
  static const Color primary = Color(0xFF2E65F6);
  static const Color primaryLight = Color(0xFF2E65F6);
  static const Color primaryDark = Color(0xFF0037B7);
  
  // === SECONDARY COLORS ===
  static const Color secondary = Color(0xFF0052CC);
  static const Color tertiary = Color(0xFFFF6B6B);
  
  // === TEXT COLORS ===
  // Using shadcn zinc palette for text
  static const Color textPrimary = Color(0xFFFAFAFA); // zinc-50 - primary text
  static const Color textSecondary = Color(0xFFA1A1AA); // zinc-400 - secondary text
  static const Color textTertiary = Color(0xFF71717A); // zinc-500 - tertiary text
  static const Color textDisabled = Color(0xFF52525B); // zinc-600 - disabled text
  static const Color textHint = Color(0xFF71717A); // zinc-500 - hint text

  // === STATUS COLORS ===
  static const Color success = Color(0xFF68D391);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);
  static const Color info = Color(0xFF63B3ED);
  static const Color pending = Color(0xFFFFD93D);

  // === BACKGROUND COLORS ===
  // Using shadcn zinc palette - matching official shadcn_flutter docs
  static const Color background = Color(0xFF09090B); // zinc-950 - main background (shadcn default)
  static const Color backgroundSecondary = Color(0xFF18181B); // zinc-900 - secondary surfaces
  static const Color backgroundTertiary = Color(0xFF27272A); // zinc-800 - tertiary surfaces
  static const Color cardBackground = Color(0xFF18181B); // zinc-900 - card surfaces
  static const Color overlay = Color(0x80000000);

  // === SURFACE COLORS ===
  static const Color surface = Color(0xFF18181B); // zinc-900
  static const Color surfaceVariant = Color(0xFF27272A); // zinc-800
  static const Color surfaceContainer = Color(0xFF3F3F46); // zinc-700
  
  // === BORDER COLORS ===
  // Using shadcn zinc palette for borders
  static const Color border = Color(0xFF27272A); // zinc-800 - default borders
  static const Color borderLight = Color(0xFF3F3F46); // zinc-700 - lighter borders
  static const Color borderFocus = Color(0xFF2E65F6);
  static const Color borderError = Color(0xFFFF6B6B);
  static const Color borderSuccess = Color(0xFF68D391);
  static const Color divider = Color(0xFF27272A); // zinc-800 - dividers
  
  // === INTERACTIVE COLORS ===
  static const Color buttonPrimary = Color(0xFF2E65F6);
  static const Color buttonSecondary = Color(0xFF27272A); // zinc-800
  static const Color buttonDisabled = Color(0xFF3F3F46); // zinc-700
  static const Color buttonHover = Color(0xFF5A8AFF);
  static const Color buttonActive = Color(0xFF0037B7);

  // === INPUT COLORS ===
  static const Color inputBackground = Color(0xFF09090B); // zinc-950 - matches main bg
  static const Color inputBorder = Color(0xFF3F3F46); // zinc-700
  static const Color inputBorderFocus = Color(0xFF2E65F6);
  static const Color inputBorderError = Color(0xFFFF6B6B);
  static const Color inputPlaceholder = Color(0xFF71717A); // zinc-500

  // === NAVIGATION COLORS ===
  static const Color navBackground = Color(0xFF09090B); // zinc-950 - matches main bg
  static const Color navItem = Color(0xFFA1A1AA); // zinc-400
  static const Color navItemHover = Color(0xFF2E65F6);
  static const Color navItemActive = Color(0xFF2E65F6);
  static const Color navDivider = Color(0xFF27272A); // zinc-800
  
  // === DATA COLORS ===
  static const Color profit = Color(0xFF68D391);
  static const Color loss = Color(0xFFFF6B6B);
  static const Color neutral = Color(0xFFA1A1AA); // zinc-400

  // === ELEVATION/SHADOW ===
  static const Color shadow = Color(0x33000000);
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowHeavy = Color(0x4D000000);

  // === ICON COLORS ===
  static const Color icon = Color(0xFFA1A1AA); // zinc-400
  static const Color iconPrimary = Color(0xFF2E65F6);
  static const Color iconSecondary = Color(0xFF71717A); // zinc-500
  static const Color iconDisabled = Color(0xFF52525B); // zinc-600
  
  // === FEEDBACK COLORS ===
  static const Color toastSuccess = Color(0xFF68D391);
  static const Color toastError = Color(0xFFFF6B6B);
  static const Color toastWarning = Color(0xFFFFD93D);
  static const Color toastInfo = Color(0xFF63B3ED);
}



/// Complete color scheme for web
class WebColorScheme {
  // Primary colors
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  
  // Secondary colors
  final Color secondary;
  final Color tertiary;
  
  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textHint;
  
  // Status colors
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color pending;
  
  // Background colors
  final Color background;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color cardBackground;
  final Color overlay;
  
  // Surface colors
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceContainer;
  
  // Border colors
  final Color border;
  final Color borderLight;
  final Color borderFocus;
  final Color borderError;
  final Color borderSuccess;
  final Color divider;
  
  // Interactive colors
  final Color buttonPrimary;
  final Color buttonSecondary;
  final Color buttonDisabled;
  final Color buttonHover;
  final Color buttonActive;
  
  // Input colors
  final Color inputBackground;
  final Color inputBorder;
  final Color inputBorderFocus;
  final Color inputBorderError;
  final Color inputPlaceholder;
  
  // Navigation colors
  final Color navBackground;
  final Color navItem;
  final Color navItemHover;
  final Color navItemActive;
  final Color navDivider;
  
  // Data colors
  final Color profit;
  final Color loss;
  final Color neutral;
  
  
  // Icon colors
  final Color icon;
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconDisabled;
  
  // Feedback colors
  final Color toastSuccess;
  final Color toastError;
  final Color toastWarning;
  final Color toastInfo;
  
  const WebColorScheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.tertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textHint,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.pending,
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.cardBackground,
    required this.overlay,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceContainer,
    required this.border,
    required this.borderLight,
    required this.borderFocus,
    required this.borderError,
    required this.borderSuccess,
    required this.divider,
    required this.buttonPrimary,
    required this.buttonSecondary,
    required this.buttonDisabled,
    required this.buttonHover,
    required this.buttonActive,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputBorderFocus,
    required this.inputBorderError,
    required this.inputPlaceholder,
    required this.navBackground,
    required this.navItem,
    required this.navItemHover,
    required this.navItemActive,
    required this.navDivider,
    required this.profit,
    required this.loss,
    required this.neutral,
    required this.icon,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconDisabled,
    required this.toastSuccess,
    required this.toastError,
    required this.toastWarning,
    required this.toastInfo,
  });
  
  /// Light theme constructor
  factory WebColorScheme.light() {
    return  const WebColorScheme(
      primary: WebColors.primary,
      primaryLight: WebColors.primaryLight,
      primaryDark: WebColors.primaryDark,
      secondary: WebColors.secondary,
      tertiary: WebColors.tertiary,
      textPrimary: WebColors.textPrimary,
      textSecondary: WebColors.textSecondary,
      textTertiary: WebColors.textTertiary,
      textDisabled: WebColors.textDisabled,
      textHint: WebColors.textHint,
      success: WebColors.success,
      error: WebColors.error,
      warning: WebColors.warning,
      info: WebColors.info,
      pending: WebColors.pending,
      background: WebColors.background,
      backgroundSecondary: WebColors.backgroundSecondary,
      backgroundTertiary: WebColors.backgroundTertiary,
      cardBackground: WebColors.cardBackground,
      overlay: WebColors.overlay,
      surface: WebColors.surface,
      surfaceVariant: WebColors.surfaceVariant,
      surfaceContainer: WebColors.surfaceContainer,
      border: WebColors.border,
      borderLight: WebColors.borderLight,
      borderFocus: WebColors.borderFocus,
      borderError: WebColors.borderError,
      borderSuccess: WebColors.borderSuccess,
      divider: WebColors.divider,
      buttonPrimary: WebColors.buttonPrimary,
      buttonSecondary: WebColors.buttonSecondary,
      buttonDisabled: WebColors.buttonDisabled,
      buttonHover: WebColors.buttonHover,
      buttonActive: WebColors.buttonActive,
      inputBackground: WebColors.inputBackground,
      inputBorder: WebColors.inputBorder,
      inputBorderFocus: WebColors.inputBorderFocus,
      inputBorderError: WebColors.inputBorderError,
      inputPlaceholder: WebColors.inputPlaceholder,
      navBackground: WebColors.navBackground,
      navItem: WebColors.navItem,
      navItemHover: WebColors.navItemHover,
      navItemActive: WebColors.navItemActive,
      navDivider: WebColors.navDivider,
      profit: WebColors.profit,
      loss: WebColors.loss,
      neutral: WebColors.neutral,
      icon: WebColors.icon,
      iconPrimary: WebColors.iconPrimary,
      iconSecondary: WebColors.iconSecondary,
      iconDisabled: WebColors.iconDisabled,
      toastSuccess: WebColors.toastSuccess,
      toastError: WebColors.toastError,
      toastWarning: WebColors.toastWarning,
      toastInfo: WebColors.toastInfo,
    );
  }
  
  /// Dark theme constructor
  factory WebColorScheme.dark() {
    return const WebColorScheme(
      primary: WebDarkColors.primary,
      primaryLight: WebDarkColors.primaryLight,
      primaryDark: WebDarkColors.primaryDark,
      secondary: WebDarkColors.secondary,
      tertiary: WebDarkColors.tertiary,
      textPrimary: WebDarkColors.textPrimary,
      textSecondary: WebDarkColors.textSecondary,
      textTertiary: WebDarkColors.textTertiary,
      textDisabled: WebDarkColors.textDisabled,
      textHint: WebDarkColors.textHint,
      success: WebDarkColors.success,
      error: WebDarkColors.error,
      warning: WebDarkColors.warning,
      info: WebDarkColors.info,
      pending: WebDarkColors.pending,
      background: WebDarkColors.background,
      backgroundSecondary: WebDarkColors.backgroundSecondary,
      backgroundTertiary: WebDarkColors.backgroundTertiary,
      cardBackground: WebDarkColors.cardBackground,
      overlay: WebDarkColors.overlay,
      surface: WebDarkColors.surface,
      surfaceVariant: WebDarkColors.surfaceVariant,
      surfaceContainer: WebDarkColors.surfaceContainer,
      border: WebDarkColors.border,
      borderLight: WebDarkColors.borderLight,
      borderFocus: WebDarkColors.borderFocus,
      borderError: WebDarkColors.borderError,
      borderSuccess: WebDarkColors.borderSuccess,
      divider: WebDarkColors.divider,
      buttonPrimary: WebDarkColors.buttonPrimary,
      buttonSecondary: WebDarkColors.buttonSecondary,
      buttonDisabled: WebDarkColors.buttonDisabled,
      buttonHover: WebDarkColors.buttonHover,
      buttonActive: WebDarkColors.buttonActive,
      inputBackground: WebDarkColors.inputBackground,
      inputBorder: WebDarkColors.inputBorder,
      inputBorderFocus: WebDarkColors.inputBorderFocus,
      inputBorderError: WebDarkColors.inputBorderError,
      inputPlaceholder: WebDarkColors.inputPlaceholder,
      navBackground: WebDarkColors.navBackground,
      navItem: WebDarkColors.navItem,
      navItemHover: WebDarkColors.navItemHover,
      navItemActive: WebDarkColors.navItemActive,
      navDivider: WebDarkColors.navDivider,
      profit: WebDarkColors.profit,
      loss: WebDarkColors.loss,
      neutral: WebDarkColors.neutral,
      icon: WebDarkColors.icon,
      iconPrimary: WebDarkColors.iconPrimary,
      iconSecondary: WebDarkColors.iconSecondary,
      iconDisabled: WebDarkColors.iconDisabled,
      toastSuccess: WebDarkColors.toastSuccess,
      toastError: WebDarkColors.toastError,
      toastWarning: WebDarkColors.toastWarning,
      toastInfo: WebDarkColors.toastInfo,
    );
  }
}