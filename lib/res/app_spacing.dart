import 'package:flutter/material.dart';

/// Spacing system for consistent layout and visual rhythm throughout the app.
///
/// Based on a 4px base unit with semantic naming for different spacing needs.
/// Provides predefined spacing values, component-specific spacing, and helper
/// methods for easy layout management.
///
/// All spacing values are multiples of 4px for pixel-perfect alignment and
/// visual harmony across different screen densities.

/// Consistent spacing system for unified layout throughout the application.
///
/// Provides a unified approach to spacing and layout with all values based on
/// a 4px base unit to ensure visual harmony and consistency.
///
/// Includes semantic spacing names, component-specific spacing values, and
/// helper methods for common layout patterns.
class AppSpacing {
  AppSpacing._(); // Private constructor

  // === BASE SPACING UNIT ===
  static const double _baseUnit = 4.0;

  // === SPACING SCALE ===
  static const double xs = _baseUnit; // 4px
  static const double sm = _baseUnit * 2; // 8px
  static const double md = _baseUnit * 4; // 16px
  static const double lg = _baseUnit * 6; // 24px
  static const double xl = _baseUnit * 8; // 32px
  static const double xxl = _baseUnit * 12; // 48px

  // === SEMANTIC SPACING ===
  static const double tiny = xs; // 4px
  static const double small = sm; // 8px
  static const double medium = md; // 16px
  static const double large = lg; // 24px
  static const double huge = xl; // 32px
  static const double massive = xxl; // 48px

  // === COMPONENT SPECIFIC SPACING ===
  static const double cardPadding = md; // 16px
  static const double screenPadding = md; // 16px
  static const double sectionSpacing = lg; // 24px
  static const double itemSpacing = sm; // 8px
  static const double elementSpacing = xs; // 4px

  // === BUTTON & INPUT SPACING ===
  static const double buttonPadding = md; // 16px
  static const double buttonSpacing = sm; // 8px
  static const double inputPadding = md; // 16px
  static const double inputSpacing = sm; // 8px

  // === COMPONENT DIMENSIONS ===
  static const double buttonHeight = 46.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double listItemHeight = 72.0;
  static const double avatarSize = 40.0;
  static const double iconSize = 24.0;

  // === BORDER RADIUS ===
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // === SEMANTIC RADIUS ===
  static const double buttonRadius = radiusMD; // 8px
  static const double cardRadius = radiusLG; // 12px
  static const double inputRadius = radiusMD; // 8px
  static const double dialogRadius = radiusLG; // 12px
  static const double sheetRadius = radiusXL; // 16px

  // === ELEVATION/SHADOW ===
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  // === HELPER METHODS ===

  /// Get horizontal padding with specified spacing
  static EdgeInsets horizontal(double spacing) =>
      EdgeInsets.symmetric(horizontal: spacing);

  /// Get vertical padding with specified spacing
  static EdgeInsets vertical(double spacing) =>
      EdgeInsets.symmetric(vertical: spacing);

  /// Get all-around padding with specified spacing
  static EdgeInsets all(double spacing) => EdgeInsets.all(spacing);

  /// Get padding with different horizontal and vertical spacing
  static EdgeInsets symmetric({double? horizontal, double? vertical}) =>
      EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );

  /// Get padding for only specific sides
  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) =>
      EdgeInsets.only(
        left: left ?? 0,
        top: top ?? 0,
        right: right ?? 0,
        bottom: bottom ?? 0,
      );

  /// Standard screen padding (usually 16px)
  static EdgeInsets get screenPaddingAll => all(screenPadding);

  /// Standard screen horizontal padding
  static EdgeInsets get screenPaddingHorizontal => horizontal(screenPadding);

  /// Standard card padding
  static EdgeInsets get cardPaddingAll => all(cardPadding);

  /// Standard vertical spacing between sections
  static Widget get verticalSpaceSection => SizedBox(height: sectionSpacing);

  /// Standard vertical spacing between items
  static Widget get verticalSpaceItem => SizedBox(height: itemSpacing);

  /// Small vertical spacing between elements
  static Widget get verticalSpaceElement => SizedBox(height: elementSpacing);

  /// Standard horizontal spacing between items
  static Widget get horizontalSpaceItem => SizedBox(width: itemSpacing);

  /// Small horizontal spacing between elements
  static Widget get horizontalSpaceElement => SizedBox(width: elementSpacing);

  /// Custom vertical spacing
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// Custom horizontal spacing
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  /// Border radius for different components
  static BorderRadius get buttonBorderRadius =>
      BorderRadius.circular(buttonRadius);
  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
  static BorderRadius get inputBorderRadius =>
      BorderRadius.circular(inputRadius);
  static BorderRadius get dialogBorderRadius =>
      BorderRadius.circular(dialogRadius);
  static BorderRadius get sheetBorderRadius =>
      BorderRadius.circular(sheetRadius);

  /// Custom border radius
  static BorderRadius borderRadius(double radius) =>
      BorderRadius.circular(radius);

  /// Border radius for only specific corners
  static BorderRadius borderRadiusOnly({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) =>
      BorderRadius.only(
        topLeft: Radius.circular(topLeft ?? 0),
        topRight: Radius.circular(topRight ?? 0),
        bottomLeft: Radius.circular(bottomLeft ?? 0),
        bottomRight: Radius.circular(bottomRight ?? 0),
      );
}
