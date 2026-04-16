import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

/// Utility class for responsive sizing calculations
///
/// Provides static methods for common responsive size patterns
/// used throughout the application.
///
/// Usage:
/// ```dart
/// import 'package:mynt_plus/res/responsive_sizes.dart';
///
/// final panelWidth = ResponsiveSizes.watchlistPanelWidth(context);
/// final tabWidth = ResponsiveSizes.tabWidth(context);
/// ```
class ResponsiveSizes {
  ResponsiveSizes._(); // Private constructor - utility class

  // === PERCENTAGE-BASED WIDTHS ===

  /// Get width as percentage of screen (percent: 0-100)
  static double widthPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }

  /// Get height as percentage of screen (percent: 0-100)
  static double heightPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }

  // === CONSTRAINED WIDTHS ===

  /// Returns width constrained between min and max
  static double constrainedWidth(
    BuildContext context, {
    required double percent,
    double minWidth = 280,
    double maxWidth = 600,
  }) {
    final calculated = widthPercent(context, percent);
    return calculated.clamp(minWidth, maxWidth);
  }

  /// Returns height constrained between min and max
  static double constrainedHeight(
    BuildContext context, {
    required double percent,
    double minHeight = 200,
    double maxHeight = 600,
  }) {
    final calculated = heightPercent(context, percent);
    return calculated.clamp(minHeight, maxHeight);
  }

  // === WATCHLIST PANEL WIDTHS ===
  // Matches pattern in watchlist_screen_web.dart

  /// Get responsive watchlist panel width based on screen size
  static double watchlistPanelWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double ratio;
    if (screenWidth >= AppBreakpoints.xxxl) {
      ratio = 0.20; // 20% on ultra wide
    } else if (screenWidth >= AppBreakpoints.xl) {
      ratio = 0.25; // 25% on large desktop
    } else if (screenWidth >= AppBreakpoints.lg) {
      ratio = 0.28; // 28% on desktop
    } else if (screenWidth >= AppBreakpoints.md) {
      ratio = 0.30; // 30% on tablet
    } else {
      ratio = 0.35; // 35% on small tablet
    }

    final calculatedWidth = screenWidth * ratio;
    // Clamp between 280px and 450px for readability
    return calculatedWidth.clamp(280.0, 450.0);
  }

  /// Get watchlist panel ratio (without min/max constraints)
  static double watchlistPanelRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= AppBreakpoints.xxxl) return 0.20;
    if (screenWidth >= AppBreakpoints.xl) return 0.25;
    if (screenWidth >= AppBreakpoints.lg) return 0.28;
    if (screenWidth >= AppBreakpoints.md) return 0.30;
    return 0.35;
  }

  // === TAB WIDTHS ===
  // From watchlist_screen_web.dart pattern

  /// Get responsive tab width based on available panel width
  static double tabWidth(BuildContext context) {
    final watchlistWidth = watchlistPanelWidth(context);

    if (watchlistWidth >= 400) {
      return 120.0;
    } else if (watchlistWidth >= 320) {
      return 100.0;
    } else {
      return 90.0;
    }
  }

  /// Get responsive tab width from explicit panel width
  static double tabWidthFromPanelWidth(double panelWidth) {
    if (panelWidth >= 400) {
      return 120.0;
    } else if (panelWidth >= 320) {
      return 100.0;
    } else {
      return 90.0;
    }
  }

  // === DIALOG SIZING ===

  /// Get responsive dialog width
  static double dialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < AppBreakpoints.sm) {
      return screenWidth * 0.95; // 95% on mobile
    } else if (screenWidth < AppBreakpoints.lg) {
      return 500; // Fixed 500px on tablet
    } else {
      return (screenWidth * 0.4).clamp(500.0, 700.0); // 40% on desktop, max 700px
    }
  }

  /// Get responsive dialog max height (85% of screen height)
  static double dialogMaxHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.85;
  }

  /// Get responsive bottom sheet height
  static double bottomSheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.7; // 70% of screen height
  }

  // === TABLE COLUMN WIDTHS ===

  /// Get responsive table column width
  static double tableColumnWidth(
    BuildContext context, {
    required double mobileWidth,
    required double desktopWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < AppBreakpoints.lg) {
      return mobileWidth;
    }
    return desktopWidth;
  }

  /// Get number of visible table columns based on screen width
  static int visibleTableColumns(
    BuildContext context, {
    required int totalColumns,
    int mobileColumns = 3,
    int tabletColumns = 5,
    int desktopColumns = 7,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    int columns;
    if (screenWidth < AppBreakpoints.sm) {
      columns = mobileColumns;
    } else if (screenWidth < AppBreakpoints.lg) {
      columns = tabletColumns;
    } else {
      columns = desktopColumns;
    }

    return columns.clamp(1, totalColumns);
  }

  // === SPLIT PANEL RATIOS ===

  /// Get default split ratio for two-panel layout
  static double defaultSplitRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= AppBreakpoints.xxl) {
      return 0.25; // 25% for left panel on widescreen
    } else if (screenWidth >= AppBreakpoints.xl) {
      return 0.28;
    } else if (screenWidth >= AppBreakpoints.lg) {
      return 0.32;
    } else {
      return 0.35;
    }
  }

  /// Minimum panel width to prevent overflow (280px default)
  static double minPanelWidth(BuildContext context) {
    return 280; // Minimum readable width for watchlist/panels
  }

  /// Maximum panel width (450px default)
  static double maxPanelWidth(BuildContext context) {
    return 450;
  }

  // === CONTENT WIDTHS ===

  /// Get maximum content width for centered layouts
  static double maxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < AppBreakpoints.sm) {
      return screenWidth; // Full width on mobile
    } else if (screenWidth < AppBreakpoints.md) {
      return 720.0;
    } else if (screenWidth < AppBreakpoints.lg) {
      return 960.0;
    } else if (screenWidth < AppBreakpoints.xl) {
      return 1140.0;
    } else {
      return 1320.0;
    }
  }

  // === CARD WIDTHS ===

  /// Get responsive card width for grid layouts
  static double cardWidth(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    double spacing = 16,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    int columns;
    if (screenWidth < AppBreakpoints.sm) {
      columns = mobileColumns;
    } else if (screenWidth < AppBreakpoints.lg) {
      columns = tabletColumns;
    } else {
      columns = desktopColumns;
    }

    // Calculate card width accounting for spacing
    final totalSpacing = spacing * (columns - 1);
    final availableWidth = screenWidth - totalSpacing - (spacing * 2); // Account for screen padding
    return availableWidth / columns;
  }

  // === TOUCH TARGET SIZES ===

  /// Minimum touch target size (44px on mobile, 36px on desktop)
  static double minTouchTarget(BuildContext context) {
    return AppBreakpoints.isMobile(context) ? 44.0 : 36.0;
  }

  /// Button height responsive
  static double buttonHeight(BuildContext context) {
    return AppBreakpoints.isMobile(context) ? 48.0 : 40.0;
  }
}
