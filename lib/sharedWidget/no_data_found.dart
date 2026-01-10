import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/index_list_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../res/res.dart';

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
    this.iconSize = 100,
    this.showTip = false,
    this.tipText = "",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a chart or document icon as default
    final iconAsset = assetIcon ?? assets.documentIcon;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with a soft glow background
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(0),
              child: SvgPicture.asset(
                iconAsset,
                width: 100,
                height: 100,
                color: shadcn.Theme.of(context).colorScheme.mutedForeground,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: shadcn.Theme.of(context).colorScheme.foreground,
                fontFamily: 'Geist',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            if (body != null)
              body!
            else if (subtitle != null)
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.7,
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                    fontFamily: 'Geist',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 24),

            // Buttons (Full width style)
            if (primaryEnabled || secondaryEnabled)
              Column(
                children: [
                  if (primaryEnabled)
                    shadcn.PrimaryButton(
                      onPressed: onPrimary,
                      child: Text(
                        primaryLabel,
                        style: const TextStyle(fontFamily: 'Geist'),
                      ),
                    ),

                  if (primaryEnabled && secondaryEnabled)
                    const SizedBox(height: 12),

                  if (secondaryEnabled)
                    shadcn.SecondaryButton(
                      onPressed: onSecondary ?? () {
                        ref.read(indexListProvider).bottomMenu(1, context);
                      },
                      child: Text(
                        secondaryLabel,
                        style: const TextStyle(fontFamily: 'Geist'),
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
                  color: shadcn.Theme.of(context).colorScheme.accent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: shadcn.Theme.of(context).colorScheme.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.lightbulb_outline_rounded, 
                        size: 16, 
                        color: shadcn.Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tipText,
                        style: TextStyle(
                          fontSize: 12,
                          color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                          fontFamily: 'Geist',
                          height: 1.3,
                        ),
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
