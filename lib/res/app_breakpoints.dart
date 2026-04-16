import 'package:flutter/material.dart';

/// Centralized breakpoint system for Mynt-Plus
///
/// Based on Bootstrap-inspired breakpoints commonly used in the codebase.
///
/// Usage:
/// ```dart
/// import 'package:mynt_plus/res/app_breakpoints.dart';
///
/// // Static method
/// if (AppBreakpoints.isMobile(context)) { ... }
///
/// // Or use with responsive_extensions.dart for extension methods
/// if (context.isMobile) { ... }
/// ```
class AppBreakpoints {
  AppBreakpoints._(); // Private constructor - utility class

  // === BREAKPOINT VALUES ===
  // These align with Bootstrap and patterns already used in the codebase

  /// Extra small devices (phones in portrait) - 0px and up
  static const double xs = 0;

  /// Small devices (phones in landscape, small tablets) - 600px and up
  /// This is the primary mobile/desktop breakpoint used in responsive_modal.dart
  static const double sm = 600;

  /// Medium devices (tablets) - 768px and up
  static const double md = 768;

  /// Large devices (small laptops, tablets in landscape) - 992px and up
  static const double lg = 992;

  /// Extra large devices (desktops) - 1200px and up
  static const double xl = 1200;

  /// Extra extra large devices (large desktops) - 1440px and up
  static const double xxl = 1440;

  /// Ultra wide displays - 1600px and up
  static const double xxxl = 1600;

  // === SEMANTIC BREAKPOINTS ===
  // For clearer code intent - aliases to the numeric values

  /// Mobile breakpoint (600px) - matches existing responsive_modal.dart
  static const double mobile = sm;

  /// Tablet breakpoint (768px)
  static const double tablet = md;

  /// Desktop breakpoint (992px)
  static const double desktop = lg;

  /// Large desktop breakpoint (1200px)
  static const double largeDesktop = xl;

  /// Widescreen breakpoint (1440px)
  static const double widescreen = xxl;

  // === STATIC HELPER METHODS ===
  // For use when context extension is not preferred

  /// Returns true if screen width is below mobile breakpoint (< 600px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < sm;
  }

  /// Returns true if screen width is at or above mobile breakpoint but below desktop (600px - 992px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= sm && width < lg;
  }

  /// Returns true if screen width is at or above desktop breakpoint (>= 992px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= lg;
  }

  /// Returns true if screen width is at or above large desktop breakpoint (>= 1200px)
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= xl;
  }

  /// Returns true if screen width is at or above widescreen breakpoint (>= 1440px)
  static bool isWidescreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= xxl;
  }

  /// Returns true if screen width is at or above ultra wide breakpoint (>= 1600px)
  static bool isUltraWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= xxxl;
  }

  /// Returns true if width >= 600px (web/desktop layout)
  /// Matches the pattern used in responsive_modal.dart
  static bool isWebLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= sm;
  }

  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < sm) return DeviceType.mobile;
    if (width < md) return DeviceType.smallTablet;
    if (width < lg) return DeviceType.tablet;
    if (width < xl) return DeviceType.desktop;
    if (width < xxl) return DeviceType.largeDesktop;
    return DeviceType.widescreen;
  }

  /// Get screen width from context
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height from context
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

/// Enum representing device types for responsive layouts
enum DeviceType {
  /// Mobile phones (< 600px)
  mobile,

  /// Small tablets (600px - 768px)
  smallTablet,

  /// Tablets (768px - 992px)
  tablet,

  /// Desktop computers (992px - 1200px)
  desktop,

  /// Large desktop monitors (1200px - 1440px)
  largeDesktop,

  /// Widescreen monitors (>= 1440px)
  widescreen,
}
