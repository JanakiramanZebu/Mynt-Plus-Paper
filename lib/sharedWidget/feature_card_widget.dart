import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../res/mynt_web_color_styles.dart';
import '../res/mynt_web_text_styles.dart';

/// A beautiful feature card with left colored section and right content
/// Layout: Left section with icon | Right section with headline and description
class FeatureCard extends StatelessWidget {
  final String badgeNumber;
  final String iconPath; // SVG path or IconData string name
  final IconData? iconData; // Direct IconData (for shadcn icons)
  final String title;
  final String description;
  final Color badgeColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const FeatureCard({
    super.key,
    required this.badgeNumber,
    this.iconPath = '',
    this.iconData,
    required this.title,
    required this.description,
    this.badgeColor = const Color(0xFF8B5CF6), // violet-500
    this.iconColor,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height ?? 100,
        decoration: BoxDecoration(
          color: resolveThemeColor(
            context,
            dark: MyntColors.backgroundColorDark,
            light: Colors.white,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 1),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left section - SQUARE with colored background and icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Center(
                child: iconData != null
                    ? Icon(
                        iconData,
                        size: 40,
                        color: iconColor ?? badgeColor,
                      )
                    : (iconPath.endsWith('.svg')
                        ? SvgPicture.asset(
                            iconPath,
                            width: 40,
                            height: 40,
                            colorFilter: ColorFilter.mode(
                              iconColor ?? badgeColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : Icon(
                            _getIconData(),
                            size: 40,
                            color: iconColor ?? badgeColor,
                          )),
              ),
            ),

            // Right section with content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Headline
                    Text(
                      title,
                      style: MyntWebTextStyles.title(
                        context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description (2 lines max)
                    Text(
                      description,
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: const Color(0xFF6B7280), // gray-500
                      ).copyWith(
                        height: 1.6,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    // Map icon names to Material icons
    switch (iconPath.toLowerCase()) {
      case 'portfolio':
        return Icons.pie_chart_outline;
      case 'trading':
        return Icons.trending_up;
      case 'reports':
        return Icons.description_outlined;
      case 'funds':
      case 'fund':
        return Icons.account_balance_wallet_outlined;
      case 'analytics':
        return Icons.analytics_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'design':
        return Icons.brush_outlined;
      default:
        return Icons.star_outline;
    }
  }
}

/// Grid of feature cards - for dashboard layout
class FeatureCardGrid extends StatelessWidget {
  final List<FeatureCardData> cards;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;

  const FeatureCardGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: cards.map((card) {
        return FeatureCard(
          badgeNumber: card.badgeNumber,
          iconPath: card.iconPath,
          title: card.title,
          description: card.description,
          badgeColor: card.badgeColor ?? const Color(0xFF8B5CF6),
          iconColor: card.iconColor,
          onTap: card.onTap,
          width: card.width,
        );
      }).toList(),
    );
  }
}

/// Data model for feature cards
class FeatureCardData {
  final String badgeNumber;
  final String iconPath;
  final String title;
  final String description;
  final Color? badgeColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final double? width;

  const FeatureCardData({
    required this.badgeNumber,
    required this.iconPath,
    required this.title,
    required this.description,
    this.badgeColor,
    this.iconColor,
    this.onTap,
    this.width,
  });
}

/// Example usage with different color themes
class FeatureCardExamples {
  static const violet = Color(0xFF8B5CF6); // violet-500
  static const blue = Color(0xFF3B82F6); // blue-500
  static const green = Color(0xFF10B981); // green-500
  static const orange = Color(0xFFF97316); // orange-500
  static const pink = Color(0xFFEC4899); // pink-500
  static const indigo = Color(0xFF6366F1); // indigo-500

  static List<FeatureCardData> get sampleCards => [
    FeatureCardData(
      badgeNumber: '01',
      iconPath: 'chart', // You can use icon name or path
      title: 'Portfolio Analysis',
      description: 'Track your investments with detailed analytics and performance metrics across all your holdings.',
      badgeColor: violet,
    ),
    FeatureCardData(
      badgeNumber: '02',
      iconPath: 'design',
      title: 'UI / UX Creative Design',
      description: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Esse fuga adipisicing elit',
      badgeColor: blue,
    ),
    FeatureCardData(
      badgeNumber: '03',
      iconPath: 'trading',
      title: 'Smart Trading',
      description: 'Execute trades seamlessly with our advanced trading platform and real-time market data.',
      badgeColor: green,
    ),
  ];
}
