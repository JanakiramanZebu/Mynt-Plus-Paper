import 'package:flutter/material.dart';
import '../../../../res/app_theme.dart';
import '../../../../res/app_colors.dart';
import '../../../../res/app_spacing.dart';
import '../../../../res/app_typography.dart';

/// Example of how to use the new standardized design system
/// in your login screen - this shows the improved approach
class LoginScreenNewSystemExample extends StatelessWidget {
  const LoginScreenNewSystemExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getSurfaceColor(context),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.getTextColor(context),
          ),
        ),
        title: Text(
          "Login",
          style: AppTheme.appBarTitle(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalSpace(AppSpacing.xl), // 32px spacing

            // === MAIN TITLE ===
            const AppTextWidget.headlineLarge(
              "Sign in with MYNT",
              fontWeight: AppFontWeight.semiBold,
            ),

            AppSpacing.verticalSpaceItem, // 8px spacing

            // === SUBTITLE (Optional) ===
            const AppTextWidget.bodyMedium(
              "Every login is a step closer to your goals.",
              colorVariant: AppTextColorVariant.secondary,
            ),

            AppSpacing.verticalSpace(AppSpacing.lg), // 24px spacing

            // === MOBILE/CLIENT ID FIELD ===
            TextFormField(
              style: AppTheme.inputText(context),
              decoration: InputDecoration(
                labelText: "Mobile / Client ID",
                labelStyle: AppTheme.inputLabel(context),
                filled: true,
                fillColor: AppColors.getSurfaceColor(context),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.inputBorderRadius,
                  borderSide: BorderSide(
                    color: AppColors.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.inputBorderRadius,
                  borderSide: BorderSide(
                    color: AppColors.getBorderColor(context, focused: true),
                  ),
                ),
                contentPadding: AppSpacing.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),

            AppSpacing.verticalSpaceElement, // 4px spacing

            // === CHARACTER COUNTER ===
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Error message would go here
                AppTextWidget.caption(
                  "Invalid mobile number",
                  customColor: AppColors.error,
                ),
                AppTextWidget.caption(
                  "8/10",
                  colorVariant: AppTextColorVariant.tertiary,
                ),
              ],
            ),

            AppSpacing.verticalSpaceItem, // 8px spacing

            // === PASSWORD FIELD ===
            TextFormField(
              style: AppTheme.inputText(context),
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: AppTheme.inputLabel(context),
                filled: true,
                fillColor: AppColors.getSurfaceColor(context),
                suffixIcon: IconButton(
                  onPressed: () {}, // Toggle password visibility
                  icon: Icon(
                    Icons.visibility_off,
                    color: AppColors.getTextColor(
                      context,
                      variant: AppTextColorVariant.tertiary,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.inputBorderRadius,
                  borderSide: BorderSide(
                    color: AppColors.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.inputBorderRadius,
                  borderSide: BorderSide(
                    color: AppColors.getBorderColor(context, focused: true),
                  ),
                ),
                contentPadding: AppSpacing.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),

            AppSpacing.verticalSpace(AppSpacing.lg), // 24px spacing

            // === LOGIN BUTTON ===
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonBorderRadius,
                  ),
                  elevation: AppSpacing.elevationLow,
                ),
                child: Text(
                  "Login",
                  style: AppTheme.buttonText(context, color: Colors.white),
                ),
              ),
            ),

            AppSpacing.verticalSpaceItem, // 8px spacing

            // === ACTION LINKS ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Switch account",
                    style: AppTheme.linkText(context),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot password?",
                    style: AppTheme.linkText(context),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpace(AppSpacing.massive), // 48px spacing

            // === VERSION INFO ===
            const Center(
              child: AppTextWidget.caption(
                "Version 3.0.2",
                colorVariant: AppTextColorVariant.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// This example shows how you can easily adapt the system for different scenarios
class LoginScreenVariations {
  // Different title styles for different contexts
  static Widget welcomeBackTitle(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppTextWidget.headlineLarge(
          "Welcome back,",
          fontWeight: AppFontWeight.medium,
          colorVariant: AppTextColorVariant.secondary,
        ),
        AppTextWidget.headlineLarge(
          name,
          fontWeight: AppFontWeight.bold,
        ),
      ],
    );
  }

  // Quick login variation
  static Widget quickLoginTitle(BuildContext context) {
    return const AppTextWidget.headlineMedium(
      "Quick Login",
      fontWeight: AppFontWeight.semiBold,
    );
  }

  // Error state
  static Widget errorMessage(BuildContext context, String message) {
    return Container(
      padding: AppSpacing.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(AppStatusColor.error, light: true),
        borderRadius: AppSpacing.borderRadius(AppSpacing.radiusSM),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppSpacing.iconSize,
          ),
          AppSpacing.horizontalSpaceElement,
          Expanded(
            child: AppTextWidget.bodySmall(
              message,
              customColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // Success state
  static Widget successMessage(BuildContext context, String message) {
    return Container(
      padding: AppSpacing.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(AppStatusColor.success, light: true),
        borderRadius: AppSpacing.borderRadius(AppSpacing.radiusSM),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: AppSpacing.iconSize,
          ),
          AppSpacing.horizontalSpaceElement,
          Expanded(
            child: AppTextWidget.bodySmall(
              message,
              customColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
