import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/index_list_provider.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../res/global_state_text.dart';

/// Reusable empty-state widget for Trading App.
///
/// - Modern, card-based design with dashed borders.
/// - structured layout suitable for dashboards.
class NoDataFound extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final Widget? body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryEnabled;
  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final bool secondaryEnabled;
  final String? assetIcon;
  final double iconSize;
  final bool showTip;
  final String tipText;

  const NoDataFound({
    super.key,
    this.title = "No Data Found",
    this.subtitle = "We couldn't find any data here.",
    this.body,
    this.primaryLabel = "Retry",
    this.onPrimary,
    this.primaryEnabled = false,
    this.secondaryLabel = "Explore",
    this.onSecondary,
    this.secondaryEnabled = true,
    this.assetIcon,
    this.iconSize = 50,
    this.showTip = false,
    this.tipText = "",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final isDark = theme.isDarkMode;

    final accent = isDark ? colors.primaryDark : colors.primaryLight;
    final textPrimary = isDark ? colors.textPrimaryDark : colors.textPrimaryLight;
    final textSecondary = isDark ? colors.textSecondaryDark : colors.textSecondaryLight;
    final bgCard = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);

    // Use a chart or document icon as default
    final iconAsset = assetIcon ?? assets.documentIcon;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: borderColor),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.03),
          //     blurRadius: 10,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with a soft glow background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.1),
                // boxShadow: [
                //   BoxShadow(
                //     color: accent.withOpacity(0.2),
                //     blurRadius: 20,
                //     spreadRadius: 5,
                //   ),
                // ],
              ),
              padding: const EdgeInsets.all(18),
              child: SvgPicture.asset(
                iconAsset,
                width: iconSize,
                height: iconSize,
                color: accent,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            TextWidget.custmText(
              text: title,
              fs: 18,
              theme: isDark,
              color: textPrimary,
              fw: 2,
            ),

            const SizedBox(height: 8),

            // Subtitle
            if (body != null)
              body!
            else if (subtitle != null)
              TextWidget.subText(
                text: subtitle!,
                theme: isDark,
                color: textSecondary,
                align: TextAlign.center,
                lineHeight: 1.4,
              ),

            const SizedBox(height: 24),

            // Buttons (Full width style)
            if (primaryEnabled || secondaryEnabled)
              Column(
                children: [
                  if (primaryEnabled)
                    SizedBox(
                      // width: 110,
                      child: ElevatedButton(
                        onPressed: onPrimary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark ? colors.colorBlack : colors.colorWhite,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextWidget.subText(
                            text: primaryLabel,
                            theme: isDark,
                            color: isDark ? colors.colorBlack : colors.colorWhite,
                            fw: 2,
                          ),
                        ),
                      ),
                    ),

                  if (primaryEnabled && secondaryEnabled)
                    const SizedBox(height: 12),

                  if (secondaryEnabled)
                    SizedBox(
                      // width: 150,
                      child: OutlinedButton(
                        onPressed: onSecondary ?? () {
                          ref.read(indexListProvider).bottomMenu(1, context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: textSecondary.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextWidget.subText(
                            text: secondaryLabel,
                            theme: isDark,
                            color: textPrimary,
                            fw: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            // Tip Section (Distinct Card)
            if (showTip) ...[
              const SizedBox(height: 24),
              Container(
                width: 110,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accent.withOpacity(0.1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.lightbulb_outline_rounded, size: 16, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextWidget.paraText(
                        text: tipText,
                        theme: isDark,
                        color: textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
