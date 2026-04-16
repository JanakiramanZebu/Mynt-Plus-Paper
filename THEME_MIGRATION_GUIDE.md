# 🎨 Theme System Migration Guide

## Overview

Your app now has a powerful centralized theme system that provides:
- **Consistent styling** across all screens
- **Automatic theme adaptation** (light/dark mode)
- **Type-safe design tokens** (colors, typography, spacing)
- **Pre-built UI patterns** for common components

## 📁 File Structure

```
lib/res/
├── app_theme.dart           # Main theme integration
├── app_colors.dart          # Theme-aware colors
├── app_typography.dart      # Typography system
├── app_spacing.dart         # Spacing and layout
├── app_theme_integration.dart # Integration helpers
└── THEME_MIGRATION_GUIDE.md # This file
```

## 🚀 Quick Start

### 1. Basic Text Styling

**Before (Old way):**
```dart
Text(
  "Welcome",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: theme.isDarkMode ? Colors.white : Colors.black,
  ),
)
```

**After (New way):**
```dart
// Option 1: Using AppTheme
Text(
  "Welcome",
  style: AppTheme.loginTitle(context),
)

// Option 2: Using AppTextWidget (recommended)
AppTextWidget.headlineLarge(
  "Welcome",
  fontWeight: AppFontWeight.semiBold,
)
```

### 2. Form Inputs

**Before:**
```dart
TextFormField(
  style: TextStyle(fontSize: 16),
  decoration: InputDecoration(
    labelText: "Email",
    labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
  ),
)
```

**After:**
```dart
TextFormField(
  style: AppTheme.inputText(context),
  decoration: InputDecoration(
    labelText: "Email",
    labelStyle: AppTheme.inputLabel(context),
    border: OutlineInputBorder(
      borderRadius: AppSpacing.inputBorderRadius,
    ),
  ),
)
```

### 3. Buttons

**Before:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text("Login", style: TextStyle(color: Colors.white)),
  onPressed: () {},
)
```

**After:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    padding: AppSpacing.all(AppSpacing.buttonPadding),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.buttonBorderRadius,
    ),
  ),
  child: Text(
    "Login",
    style: AppTheme.buttonText(context, color: Colors.white),
  ),
  onPressed: () {},
)
```

## 🎯 Available Text Styles

### Display Styles (Hero Content)
```dart
AppTextWidget.displayLarge("App Name")      // 32px
AppTextWidget.displayMedium("Hero Title")   // 28px
AppTextWidget.displaySmall("Subtitle")      // 24px
```

### Headline Styles (Page Titles)
```dart
AppTextWidget.headlineLarge("Page Title")   // 22px
AppTextWidget.headlineMedium("Section")     // 20px
AppTextWidget.headlineSmall("Subsection")   // 18px
```

### Body Styles (Content)
```dart
AppTextWidget.bodyLarge("Main content")     // 16px
AppTextWidget.bodyMedium("Description")     // 14px
AppTextWidget.bodySmall("Helper text")      // 12px
```

### Label Styles (Interactive)
```dart
AppTextWidget.labelLarge("Button text")     // 14px
AppTextWidget.labelMedium("Small button")   // 12px
AppTextWidget.labelSmall("Tiny label")      // 10px
```

### Caption Style (Metadata)
```dart
AppTextWidget.caption("Timestamp")          // 10px
```

## 🎨 Color System

### Theme-Aware Colors
```dart
// Automatically adapts to light/dark theme
AppColors.getTextColor(context)           // Primary text
AppColors.getTextColor(context, variant: AppTextColorVariant.secondary)  // Secondary text
AppColors.getSurfaceColor(context)        // Card backgrounds
AppColors.getBackgroundColor(context)     // Screen backgrounds
AppColors.getBorderColor(context)         // Borders
```

### Status Colors
```dart
AppColors.error                           // Error states
AppColors.warning                         // Warning states
AppColors.success                         // Success states
AppColors.info                            // Info states
```

### Brand Colors
```dart
AppColors.primary                         // Main brand color
AppColors.primaryVariant                  // Darker variant
```

## 📏 Spacing System

### Predefined Spacing
```dart
AppSpacing.xs      // 4px
AppSpacing.sm      // 8px
AppSpacing.md      // 16px
AppSpacing.lg      // 24px
AppSpacing.xl      // 32px
AppSpacing.xxl     // 48px
```

### Component Spacing
```dart
AppSpacing.cardPadding        // 16px
AppSpacing.screenPadding      // 16px
AppSpacing.buttonPadding      // 16px
AppSpacing.inputPadding       // 16px
```

### Spacing Widgets
```dart
AppSpacing.verticalSpaceSection    // SizedBox(height: 24)
AppSpacing.verticalSpaceItem       // SizedBox(height: 8)
AppSpacing.horizontalSpaceItem     // SizedBox(width: 8)
```

### Padding Helpers
```dart
AppSpacing.all(16)                 // EdgeInsets.all(16)
AppSpacing.horizontal(16)          // EdgeInsets.symmetric(horizontal: 16)
AppSpacing.vertical(16)            // EdgeInsets.symmetric(vertical: 16)
```

## 🔧 Integration with Existing Theme

Use the integration helpers to work with both systems:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../res/app_theme_integration.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppThemeIntegration.themedAppBar(
        context: context,
        title: "My Screen",
      ),
      body: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          children: [
            AppTextWidget.headlineLarge("Welcome"),
            AppSpacing.verticalSpaceSection,
            AppThemeIntegration.themedCard(
              context: context,
              child: AppTextWidget.bodyMedium("Card content"),
            ),
            AppSpacing.verticalSpaceItem,
            AppThemeIntegration.themedButton(
              context: context,
              text: "Action",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎨 Pre-built UI Patterns

### Common Text Styles
```dart
AppTheme.loginTitle(context)        // Login screen titles
AppTheme.buttonText(context)        // Button text
AppTheme.inputText(context)         // Form input text
AppTheme.inputLabel(context)        // Form labels
AppTheme.errorText(context)         // Error messages
AppTheme.linkText(context)          // Clickable links
AppTheme.appBarTitle(context)       // App bar titles
AppTheme.cardTitle(context)         // Card titles
AppTheme.sectionHeader(context)     // Section headers
AppTheme.captionText(context)       // Captions/metadata
```

### Component Styles
```dart
// Border radius
AppSpacing.buttonBorderRadius       // 8px
AppSpacing.cardBorderRadius         // 12px
AppSpacing.inputBorderRadius        // 8px
AppSpacing.dialogBorderRadius       // 12px

// Elevation
AppSpacing.elevationNone            // 0
AppSpacing.elevationLow             // 1
AppSpacing.elevationMedium          // 4
AppSpacing.elevationHigh            // 8
```

## 🔄 Migration Strategy

### Phase 1: Start with New Screens
- Use the new theme system for any new screens you create
- This ensures consistency going forward

### Phase 2: Update Existing Screens Gradually
- Pick one screen at a time to migrate
- Start with simpler screens (forms, lists)
- Move to complex screens later

### Phase 3: Replace Old Theme Provider
- Once all screens are migrated, you can remove the old theme system
- The new system handles light/dark mode automatically

## 📝 Best Practices

### 1. Use Semantic Names
```dart
// Good
AppTextWidget.headlineLarge("Welcome")
AppColors.getTextColor(context, variant: AppTextColorVariant.secondary)

// Avoid
AppTextWidget.text("Welcome", style: AppTextStyle.headlineLarge)
Colors.grey
```

### 2. Leverage Pre-built Patterns
```dart
// Use these instead of custom styles
AppTheme.buttonText(context)
AppTheme.inputText(context)
AppTheme.errorText(context)
```

### 3. Consistent Spacing
```dart
// Always use spacing constants
AppSpacing.verticalSpaceSection
AppSpacing.cardPaddingAll
AppSpacing.all(AppSpacing.md)
```

### 4. Theme-Aware Colors
```dart
// Always use theme-aware colors
AppColors.getTextColor(context)
AppColors.getSurfaceColor(context)
AppColors.getBackgroundColor(context)
```

## 🐛 Troubleshooting

### Common Issues

1. **Colors not adapting to theme**
   - Make sure you're using `AppColors.getTextColor(context)` instead of hardcoded colors
   - Check that your theme provider is properly set up

2. **Text styles not applying**
   - Ensure you're passing the `context` parameter to theme methods
   - Check that you're using the correct text style enum

3. **Spacing inconsistencies**
   - Always use `AppSpacing` constants instead of hardcoded values
   - Use the spacing widgets for consistent vertical/horizontal spacing

### Debug Tips

```dart
// Check current theme mode
final isDark = Theme.of(context).brightness == Brightness.dark;
print("Current theme: ${isDark ? 'Dark' : 'Light'}");

// Check text color
final textColor = AppColors.getTextColor(context);
print("Text color: $textColor");
```

## 🎯 Next Steps

1. **Start using the new system** in your next screen
2. **Migrate one screen at a time** to avoid breaking changes
3. **Use the integration helpers** to work with both systems
4. **Update your team** on the new conventions
5. **Create custom patterns** for your app's specific needs

The new theme system will make your app more maintainable, consistent, and easier to update in the future! 