import 'package:flutter/material.dart';
import 'app_breakpoints.dart';
import 'app_spacing.dart';

/// Extension on BuildContext for easy responsive access
///
/// Usage:
/// ```dart
/// import 'package:mynt_plus/res/responsive_extensions.dart';
///
/// // Screen dimensions
/// final width = context.screenWidth;
/// final height = context.screenHeight;
///
/// // Device type checks
/// if (context.isMobile) { ... }
/// if (context.isDesktop) { ... }
///
/// // Responsive values
/// final padding = context.responsive(mobile: 16.0, tablet: 24.0, desktop: 32.0);
/// ```
extension ResponsiveContext on BuildContext {
  // === SCREEN DIMENSIONS ===

  /// Current screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Current screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Current screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Safe area padding (notches, status bar, etc.)
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// View insets (keyboard, etc.)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // === DEVICE TYPE CHECKS ===

  /// True if width < 600px (mobile phone)
  bool get isMobile => screenWidth < AppBreakpoints.sm;

  /// True if width >= 600px and < 992px (tablet)
  bool get isTablet =>
      screenWidth >= AppBreakpoints.sm && screenWidth < AppBreakpoints.lg;

  /// True if width >= 992px (desktop)
  bool get isDesktop => screenWidth >= AppBreakpoints.lg;

  /// True if width >= 1200px (large desktop)
  bool get isLargeDesktop => screenWidth >= AppBreakpoints.xl;

  /// True if width >= 1440px (widescreen)
  bool get isWidescreen => screenWidth >= AppBreakpoints.xxl;

  /// True if width >= 1600px (ultra wide)
  bool get isUltraWide => screenWidth >= AppBreakpoints.xxxl;

  /// True if width >= 600px (for modal/snackbar logic - matches existing code)
  /// Use this when deciding between Dialog vs BottomSheet
  bool get isWebLayout => screenWidth >= AppBreakpoints.sm;

  /// Current device type enum
  DeviceType get deviceType => AppBreakpoints.getDeviceType(this);

  // === RESPONSIVE VALUE HELPERS ===

  /// Returns different values based on screen size with full breakpoint support
  ///
  /// Mobile is used as fallback if specific value not provided
  ///
  /// Example:
  /// ```dart
  /// final columns = context.responsiveValue(
  ///   mobile: 1,
  ///   smallTablet: 2,
  ///   tablet: 2,
  ///   desktop: 3,
  ///   largeDesktop: 4,
  ///   widescreen: 5,
  /// );
  /// ```
  T responsiveValue<T>({
    required T mobile,
    T? smallTablet,
    T? tablet,
    T? desktop,
    T? largeDesktop,
    T? widescreen,
  }) {
    final width = screenWidth;

    if (width >= AppBreakpoints.xxl && widescreen != null) return widescreen;
    if (width >= AppBreakpoints.xl && largeDesktop != null) return largeDesktop;
    if (width >= AppBreakpoints.lg && desktop != null) return desktop;
    if (width >= AppBreakpoints.md && tablet != null) return tablet;
    if (width >= AppBreakpoints.sm && smallTablet != null) return smallTablet;
    return mobile;
  }

  /// Simplified responsive value with just mobile/tablet/desktop
  ///
  /// Example:
  /// ```dart
  /// final padding = context.responsive(
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return responsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop ?? tablet,
    );
  }

  /// Returns value based on simple mobile/web distinction (600px breakpoint)
  /// Matches the pattern used in responsive_modal.dart
  ///
  /// Example:
  /// ```dart
  /// final widget = context.mobileOrWeb(
  ///   mobile: BottomSheet(...),
  ///   web: Dialog(...),
  /// );
  /// ```
  T mobileOrWeb<T>({
    required T mobile,
    required T web,
  }) {
    return isWebLayout ? web : mobile;
  }

  // === RESPONSIVE PADDING ===

  /// Screen horizontal padding that adapts to screen size
  double get responsiveScreenPadding => responsiveValue(
        mobile: AppSpacing.md, // 16px
        tablet: AppSpacing.lg, // 24px
        desktop: AppSpacing.xl, // 32px
        largeDesktop: AppSpacing.xxl, // 48px
      );

  /// Returns EdgeInsets with responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding =>
      EdgeInsets.symmetric(horizontal: responsiveScreenPadding);

  /// Returns EdgeInsets with responsive all-around padding
  EdgeInsets get responsiveAllPadding => EdgeInsets.all(responsiveScreenPadding);

  // === RESPONSIVE SIZING ===

  /// Content max width (for centered content layouts)
  /// Returns full width on mobile, constrained on larger screens
  double get maxContentWidth => responsiveValue(
        mobile: screenWidth,
        tablet: 720.0,
        desktop: 960.0,
        largeDesktop: 1140.0,
        widescreen: 1320.0,
      );

  /// Modal/dialog width
  double get dialogWidth => responsiveValue(
        mobile: screenWidth * 0.95,
        tablet: 500.0,
        desktop: screenWidth * 0.4,
        largeDesktop: 600.0,
      );

  /// Modal/dialog max height (85% of screen)
  double get dialogMaxHeight => screenHeight * 0.85;

  /// Panel width for split layouts (watchlist, etc.)
  double get panelWidth => responsiveValue(
        mobile: screenWidth,
        tablet: screenWidth * 0.35,
        desktop: screenWidth * 0.28,
        largeDesktop: screenWidth * 0.25,
        widescreen: screenWidth * 0.20,
      );

  /// Default split ratio for two-panel layout
  double get defaultSplitRatio => responsiveValue(
        mobile: 1.0, // Full width on mobile
        tablet: 0.35,
        desktop: 0.32,
        largeDesktop: 0.28,
        widescreen: 0.25,
      );
}

/// Extension for responsive font scaling
/// Integrates with existing MyntWebTextStyles pattern
extension ResponsiveFontContext on BuildContext {
  /// Font scale factor based on screen width
  /// Matches existing pattern in mynt_web_text_styles.dart
  double get fontScaleFactor {
    final width = screenWidth;
    if (width < 1000) return 0.8;
    if (width < 1300) return 0.9;
    return 1.0;
  }

  /// Scale a font size responsively
  double scaledFontSize(double baseSize) => baseSize * fontScaleFactor;

  /// Responsive font size with explicit breakpoint values
  double responsiveFontSize({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Extension for percentage-based sizing
extension ResponsiveSizeContext on BuildContext {
  /// Width as percentage of screen (0-100)
  double widthPercent(double percent) => screenWidth * (percent / 100);

  /// Height as percentage of screen (0-100)
  double heightPercent(double percent) => screenHeight * (percent / 100);

  /// Width constrained between min and max values
  double constrainedWidth({
    required double percent,
    double min = 280,
    double max = 600,
  }) {
    final calculated = widthPercent(percent);
    return calculated.clamp(min, max);
  }

  /// Height constrained between min and max values
  double constrainedHeight({
    required double percent,
    double min = 200,
    double max = 600,
  }) {
    final calculated = heightPercent(percent);
    return calculated.clamp(min, max);
  }
}
