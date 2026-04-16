import 'package:flutter/material.dart';
import 'app_typography.dart';
import 'app_colors.dart';

/// Main theme system that integrates typography, colors, and spacing.
///
/// Combines typography, colors, and spacing into a cohesive design system,
/// providing a single source of truth for consistent UI styling across
/// the entire application.
///
/// Features automatic theme integration with colors that adapt to light/dark
/// mode, consistent typography, and pre-built common styles for frequent
/// UI patterns.

/// # Complete Theme Integration System
///
/// Combines typography, colors, and spacing into a unified theming solution.
/// This class acts as the bridge between individual design systems and provides
/// convenient methods for common UI patterns.
///
/// ## Key Benefits:
/// - 🎯 **Consistency** - Same styling approach everywhere
/// - 🔄 **Theme Awareness** - Automatic light/dark adaptation
/// - 🚀 **Developer Experience** - Pre-built common patterns
/// - 🛡️ **Maintainability** - Single place to update styles
/// - ♿ **Accessibility** - Built-in contrast and sizing standards
///
/// ## Text Style Categories:
///
/// ### 📺 **Display Styles**
/// For hero content and major visual elements
/// - `displayLarge` (32px) - App names, hero titles
/// - `displayMedium` (28px) - Major promotional content
/// - `displaySmall` (24px) - Secondary hero content
///
/// ### 📰 **Headline Styles**
/// For page titles and section headers
/// - `headlineLarge` (22px) - Page titles, main headers
/// - `headlineMedium` (20px) - Section titles
/// - `headlineSmall` (18px) - Subsection headers
///
/// ### 🏷️ **Title Styles**
/// For card titles and dialog headers
/// - `titleLarge` (16px) - Card titles, dialog headers
/// - `titleMedium` (14px) - Form section titles
/// - `titleSmall` (12px) - Small content headers
///
/// ### 📝 **Body Styles**
/// For content text and form inputs
/// - `bodyLarge` (16px) - Primary content, form inputs
/// - `bodyMedium` (14px) - Secondary content
/// - `bodySmall` (12px) - Fine print, helper text
///
/// ### 🏷️ **Label Styles**
/// For interactive elements
/// - `labelLarge` (14px) - Button text, form labels
/// - `labelMedium` (12px) - Small buttons, tags
/// - `labelSmall` (10px) - Tiny labels, indicators
///
/// ### 📄 **Caption Style**
/// For metadata and supplementary information
/// - `caption` (10px) - Timestamps, version info, counters
///
/// ## Common Use Cases:
/// ```dart
/// // Login/Auth screens
/// AppTheme.loginTitle(context)
/// AppTheme.inputText(context)
/// AppTheme.inputLabel(context)
/// AppTheme.buttonText(context)
/// AppTheme.linkText(context)
/// AppTheme.errorText(context)
///
/// // Content screens
/// AppTheme.appBarTitle(context)
/// AppTheme.sectionHeader(context)
/// AppTheme.cardTitle(context)
/// AppTheme.captionText(context)
/// ```
class AppTheme {
  AppTheme._(); // Private constructor

  /// Get theme-aware text style with automatic color resolution
  static TextStyle text(
    BuildContext context,
    AppTextStyle style, {
    AppFontWeight? fontWeight,
    AppTextColorVariant colorVariant = AppTextColorVariant.primary,
    Color? customColor,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final color =
        customColor ?? AppColors.getTextColor(context, variant: colorVariant);

    switch (style) {
      case AppTextStyle.displayLarge:
        return AppTypography.displayLarge(
          fontWeight: fontWeight ?? AppFontWeight.bold,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.displayMedium:
        return AppTypography.displayMedium(
          fontWeight: fontWeight ?? AppFontWeight.bold,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.displaySmall:
        return AppTypography.displaySmall(
          fontWeight: fontWeight ?? AppFontWeight.semiBold,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.headlineLarge:
        return AppTypography.headlineLarge(
          fontWeight: fontWeight ?? AppFontWeight.semiBold,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.headlineMedium:
        return AppTypography.headlineMedium(
          fontWeight: fontWeight ?? AppFontWeight.medium,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.headlineSmall:
        return AppTypography.headlineSmall(
          fontWeight: fontWeight ?? AppFontWeight.medium,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.titleLarge:
        return AppTypography.titleLarge(
          fontWeight: fontWeight ?? AppFontWeight.medium,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.titleMedium:
        return AppTypography.titleMedium(
          fontWeight: fontWeight ?? AppFontWeight.medium,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.titleSmall:
        return AppTypography.titleSmall(
          fontWeight: fontWeight ?? AppFontWeight.regular,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.bodyLarge:
        return AppTypography.bodyLarge(
          fontWeight: fontWeight ?? AppFontWeight.regular,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.bodyMedium:
        return AppTypography.bodyMedium(
          fontWeight: fontWeight ?? AppFontWeight.regular,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.bodySmall:
        return AppTypography.bodySmall(
          fontWeight: fontWeight ?? AppFontWeight.regular,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.labelLarge:
        return AppTypography.labelLarge(
          fontWeight: fontWeight ?? AppFontWeight.medium,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.labelMedium:
        return AppTypography.labelMedium(
          fontWeight: fontWeight ?? AppFontWeight.medium,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.labelSmall:
        return AppTypography.labelSmall(
          fontWeight: fontWeight ?? AppFontWeight.regular,
          color: color,
          letterSpacing: letterSpacing,
        );
      case AppTextStyle.caption:
        return AppTypography.caption(
          fontWeight: fontWeight ?? AppFontWeight.regular,
          color: color,
          letterSpacing: letterSpacing,
        );
    }
  }

  // === COMMON UI PATTERNS ===
  // Pre-built styles for frequent use cases

  /// Creates a text style optimized for authentication screen titles.
  ///
  /// Returns a [TextStyle] with headlineLarge size (22px) and semiBold weight,
  /// perfect for main login and signup screen titles.
  ///
  /// The [context] parameter is used for theme-aware color selection.
  static TextStyle loginTitle(BuildContext context) =>
      text(context, AppTextStyle.headlineLarge,
          fontWeight: AppFontWeight.semiBold);

  /// **Button Text Style** - Optimized for all button types
  ///
  /// Perfect for ElevatedButton, TextButton, and OutlinedButton text.
  /// Uses labelLarge (14px) with medium weight for readability.
  ///
  /// ## Examples:
  /// ```dart
  /// // Primary button
  /// ElevatedButton(
  ///   child: Text(
  ///     "Login",
  ///     style: AppTheme.buttonText(context, color: Colors.white),
  ///   ),
  ///   onPressed: () {},
  /// )
  ///
  /// // Text button (uses theme color automatically)
  /// TextButton(
  ///   child: Text(
  ///     "Cancel",
  ///     style: AppTheme.buttonText(context),
  ///   ),
  ///   onPressed: () {},
  /// )
  /// ```
  static TextStyle buttonText(BuildContext context, {Color? color}) =>
      text(context, AppTextStyle.labelLarge,
          fontWeight: AppFontWeight.medium, customColor: color);

  /// **Input Field Text Style** - For TextFormField input text
  ///
  /// Optimized for form input text with proper sizing and readability.
  /// Uses bodyLarge (16px) for comfortable typing experience.
  ///
  /// ## Example:
  /// ```dart
  /// TextFormField(
  ///   style: AppTheme.inputText(context),
  ///   decoration: InputDecoration(
  ///     labelText: "Email Address",
  ///   ),
  /// )
  /// ```
  static TextStyle inputText(BuildContext context) =>
      text(context, AppTextStyle.bodyLarge);

  /// **Input Field Label Style** - For form field labels
  ///
  /// Optimized for InputDecoration labelText and hintText.
  /// Uses bodyMedium (14px) with secondary color for proper hierarchy.
  ///
  /// ## Example:
  /// ```dart
  /// TextFormField(
  ///   decoration: InputDecoration(
  ///     labelText: "Password",
  ///     labelStyle: AppTheme.inputLabel(context),
  ///     hintText: "Enter your password",
  ///     hintStyle: AppTheme.inputLabel(context),
  ///   ),
  /// )
  /// ```
  static TextStyle inputLabel(BuildContext context) =>
      text(context, AppTextStyle.bodyMedium,
          colorVariant: AppTextColorVariant.secondary);

  /// **Error Text Style** - For validation and error messages
  ///
  /// Consistent error styling with red color for all error states.
  /// Uses caption (10px) size to avoid overwhelming the UI.
  ///
  /// ## Examples:
  /// ```dart
  /// // Form validation error
  /// if (hasError)
  ///   Text(
  ///     "Please enter a valid email address",
  ///     style: AppTheme.errorText(context),
  ///   )
  ///
  /// // API error message
  /// SnackBar(
  ///   content: Text(
  ///     "Login failed. Please try again.",
  ///     style: AppTheme.errorText(context),
  ///   ),
  /// )
  /// ```
  static TextStyle errorText(BuildContext context) =>
      text(context, AppTextStyle.caption, customColor: AppColors.error);

  /// **Caption/Helper Text Style** - For supplementary information
  ///
  /// Perfect for timestamps, character counters, help text, and metadata.
  /// Uses caption (10px) with tertiary color for subtle appearance.
  ///
  /// ## Examples:
  /// ```dart
  /// // Character counter
  /// Text(
  ///   "${controller.text.length}/50",
  ///   style: AppTheme.captionText(context),
  /// )
  ///
  /// // Timestamp
  /// Text(
  ///   "Last updated 5 minutes ago",
  ///   style: AppTheme.captionText(context),
  /// )
  ///
  /// // Version info
  /// Text(
  ///   "Version 3.0.2",
  ///   style: AppTheme.captionText(context),
  /// )
  /// ```
  static TextStyle captionText(BuildContext context) =>
      text(context, AppTextStyle.caption,
          colorVariant: AppTextColorVariant.tertiary);

  /// **Link Text Style** - For clickable text links
  ///
  /// Optimized for TextButton, GestureDetector, and InkWell text.
  /// Uses primary brand color with medium weight for clear clickability.
  ///
  /// ## Examples:
  /// ```dart
  /// // Navigation link
  /// TextButton(
  ///   child: Text(
  ///     "Forgot password?",
  ///     style: AppTheme.linkText(context),
  ///   ),
  ///   onPressed: () => Navigator.push(...),
  /// )
  ///
  /// // Inline link
  /// GestureDetector(
  ///   onTap: () => launchUrl(termsUrl),
  ///   child: Text(
  ///     "Terms of Service",
  ///     style: AppTheme.linkText(context),
  ///   ),
  /// )
  /// ```
  static TextStyle linkText(BuildContext context) =>
      text(context, AppTextStyle.bodyMedium,
          fontWeight: AppFontWeight.medium, customColor: AppColors.primary);

  /// **App Bar Title Style** - For AppBar title text
  ///
  /// Optimized for AppBar titles with proper sizing and weight.
  /// Uses titleLarge (16px) with medium weight for clarity.
  ///
  /// ## Example:
  /// ```dart
  /// AppBar(
  ///   title: Text(
  ///     "Settings",
  ///     style: AppTheme.appBarTitle(context),
  ///   ),
  /// )
  /// ```
  static TextStyle appBarTitle(BuildContext context) =>
      text(context, AppTextStyle.titleLarge, fontWeight: AppFontWeight.medium);

  /// **Card Title Style** - For Card and ListTile titles
  ///
  /// Perfect for card headers, list item titles, and dialog titles.
  /// Uses titleMedium (14px) with medium weight for proper hierarchy.
  ///
  /// ## Examples:
  /// ```dart
  /// // Card title
  /// Card(
  ///   child: Column(
  ///     children: [
  ///       Text(
  ///         "Account Balance",
  ///         style: AppTheme.cardTitle(context),
  ///       ),
  ///       // Card content
  ///     ],
  ///   ),
  /// )
  ///
  /// // ListTile title
  /// ListTile(
  ///   title: Text(
  ///     "Notifications",
  ///     style: AppTheme.cardTitle(context),
  ///   ),
  ///   subtitle: Text("Manage your notification preferences"),
  /// )
  /// ```
  static TextStyle cardTitle(BuildContext context) =>
      text(context, AppTextStyle.titleMedium, fontWeight: AppFontWeight.medium);

  /// **Section Header Style** - For major content section titles
  ///
  /// Perfect for separating major content sections within a page.
  /// Uses titleLarge (16px) with semiBold weight for clear hierarchy.
  ///
  /// ## Examples:
  /// ```dart
  /// // Settings page sections
  /// Column(
  ///   crossAxisAlignment: CrossAxisAlignment.start,
  ///   children: [
  ///     Text(
  ///       "Account Settings",
  ///       style: AppTheme.sectionHeader(context),
  ///     ),
  ///     // Settings items
  ///
  ///     AppSpacing.verticalSpaceSection,
  ///
  ///     Text(
  ///       "Security",
  ///       style: AppTheme.sectionHeader(context),
  ///     ),
  ///     // Security items
  ///   ],
  /// )
  /// ```
  static TextStyle sectionHeader(BuildContext context) =>
      text(context, AppTextStyle.titleLarge,
          fontWeight: AppFontWeight.semiBold);
}

/// Text style enum for semantic usage
enum AppTextStyle {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  caption,
}

/// A [Text] widget replacement with built-in design system theming.
///
/// Automatically applies the app's design system including typography, colors,
/// and theme awareness. Provides named constructors for semantic text styles
/// and eliminates the need to manually combine styles and colors.
///
/// Colors automatically adapt to light and dark themes, and the widget uses
/// type-safe enum-based text styles to prevent errors.
class AppTextWidget extends StatelessWidget {
  final String text;
  final AppTextStyle style;
  final AppFontWeight? fontWeight;
  final AppTextColorVariant colorVariant;
  final Color? customColor;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final double? letterSpacing;

  const AppTextWidget(
    this.text, {
    super.key,
    required this.style,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  });

  // Convenience constructors for common use cases

  /// Creates a display large text widget (32px).
  ///
  /// Use for hero titles, app names, and the most prominent text elements.
  ///
  /// The [text] parameter specifies the text to display.
  /// The [fontWeight] parameter sets the font weight.
  /// The [colorVariant] parameter sets the text color hierarchy.
  /// The [customColor] parameter overrides the theme color.
  const AppTextWidget.displayLarge(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.displayLarge;

  /// Creates a headline large text widget (22px).
  ///
  /// Use for page titles, main screen headers, and dialog titles.
  ///
  /// The [text] parameter specifies the text to display.
  /// The [fontWeight] parameter sets the font weight.
  /// The [colorVariant] parameter sets the text color hierarchy.
  /// The [customColor] parameter overrides the theme color.
  const AppTextWidget.headlineLarge(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.headlineLarge;

  /// Medium headline (section titles)
  const AppTextWidget.headlineMedium(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.headlineMedium;

  /// Title text
  const AppTextWidget.titleLarge(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.titleLarge;

  /// Creates a body large text widget (16px).
  ///
  /// Use for primary content text, form inputs, and main body text.
  ///
  /// The [text] parameter specifies the text to display.
  /// The [fontWeight] parameter sets the font weight.
  /// The [colorVariant] parameter sets the text color hierarchy.
  /// The [customColor] parameter overrides the theme color.
  const AppTextWidget.bodyLarge(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.bodyLarge;

  const AppTextWidget.bodyMedium(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.bodyMedium;

  const AppTextWidget.bodySmall(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.bodySmall;

  /// Label text (buttons, form labels)
  const AppTextWidget.labelLarge(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.labelLarge;

  /// Creates a caption text widget (10px).
  ///
  /// Use for timestamps, metadata, character counters, and supplementary information.
  /// Defaults to tertiary color variant for subtle appearance.
  ///
  /// The [text] parameter specifies the text to display.
  /// The [fontWeight] parameter sets the font weight.
  /// The [colorVariant] parameter sets the text color hierarchy.
  /// The [customColor] parameter overrides the theme color.
  const AppTextWidget.caption(
    this.text, {
    super.key,
    this.fontWeight,
    this.colorVariant = AppTextColorVariant.tertiary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.letterSpacing,
  }) : style = AppTextStyle.caption;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.text(
        context,
        style,
        fontWeight: fontWeight,
        colorVariant: colorVariant,
        customColor: customColor,
        letterSpacing: letterSpacing,
      ),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
