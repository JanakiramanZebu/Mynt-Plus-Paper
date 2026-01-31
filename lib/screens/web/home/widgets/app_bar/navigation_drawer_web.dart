import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';

/// Navigation drawer for mobile/tablet responsive view
class NavigationDrawerWeb extends StatelessWidget {
  final bool isDarkMode;
  final String clientId;
  final bool Function(String screenName)? isScreenActive;
  final VoidCallback onDashboardTap;
  final VoidCallback onPositionsTap;
  final VoidCallback onHoldingsTap;
  final VoidCallback onOrderBookTap;
  final VoidCallback onFundsTap;
  final VoidCallback onIPOTap;
  final VoidCallback onSwapPanels;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onMutualFundTap;
  final VoidCallback? onBondsTap;
  final VoidCallback? onOptionZTap;

  const NavigationDrawerWeb({
    super.key,
    required this.isDarkMode,
    required this.clientId,
    this.isScreenActive,
    required this.onDashboardTap,
    required this.onPositionsTap,
    required this.onHoldingsTap,
    required this.onOrderBookTap,
    required this.onFundsTap,
    required this.onIPOTap,
    required this.onSwapPanels,
    this.onThemeToggle,
    this.onMutualFundTap,
    this.onBondsTap,
    this.onOptionZTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? WebDarkColors.surface : Colors.white;
    final textColor = isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary;
    final dividerColor = isDarkMode ? WebDarkColors.divider : WebColors.divider;

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: dividerColor.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    assets.appLogoIcon,
                    width: 80,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context: context,
                    title: 'Home',
                    icon: Icons.home_outlined,
                    screenName: 'dashboard',
                    onTap: () {
                      Navigator.of(context).pop();
                      onDashboardTap();
                    },
                  ),
                  if (onMutualFundTap != null)
                    _buildDrawerItem(
                      context: context,
                      title: 'Mutual Fund',
                      icon: Icons.pie_chart_outline,
                      screenName: 'mutualFund',
                      onTap: () {
                        Navigator.of(context).pop();
                        onMutualFundTap!();
                      },
                    ),
                  _buildDrawerItem(
                    context: context,
                    title: 'IPO',
                    icon: Icons.new_releases_outlined,
                    screenName: 'ipo',
                    onTap: () {
                      Navigator.of(context).pop();
                      onIPOTap();
                    },
                  ),
                  if (onBondsTap != null)
                    _buildDrawerItem(
                      context: context,
                      title: 'Bonds',
                      icon: Icons.account_balance_outlined,
                      screenName: 'bond',
                      onTap: () {
                        Navigator.of(context).pop();
                        onBondsTap!();
                      },
                    ),
                  if (onOptionZTap != null)
                    _buildDrawerItem(
                      context: context,
                      title: 'OptionZ',
                      icon: Icons.analytics_outlined,
                      screenName: 'tradeAction',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOptionZTap!();
                      },
                    ),

                  Divider(color: dividerColor.withValues(alpha: 0.3), height: 24),

                  _buildDrawerItem(
                    context: context,
                    title: 'Positions',
                    icon: Icons.trending_up_outlined,
                    screenName: 'positions',
                    onTap: () {
                      Navigator.of(context).pop();
                      onPositionsTap();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Holdings',
                    icon: Icons.account_balance_wallet_outlined,
                    screenName: 'holdings',
                    onTap: () {
                      Navigator.of(context).pop();
                      onHoldingsTap();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Orders',
                    icon: Icons.receipt_long_outlined,
                    screenName: 'orderBook',
                    onTap: () {
                      Navigator.of(context).pop();
                      onOrderBookTap();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Funds',
                    icon: Icons.account_balance_outlined,
                    screenName: 'funds',
                    onTap: () {
                      Navigator.of(context).pop();
                      onFundsTap();
                    },
                  ),

                  Divider(color: dividerColor.withValues(alpha: 0.3), height: 24),

                  // // Swap panels option
                  // _buildDrawerActionItem(
                  //   context: context,
                  //   title: 'Swap Panels',
                  //   icon: Icons.swap_horiz_outlined,
                  //   onTap: () {
                  //     Navigator.of(context).pop();
                  //     onSwapPanels();
                  //   },
                  // ),

                  // // Theme toggle
                  // if (onThemeToggle != null)
                  //   _buildDrawerActionItem(
                  //     context: context,
                  //     title: isDarkMode ? 'Light Mode' : 'Dark Mode',
                  //     icon: isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  //     onTap: () {
                  //       Navigator.of(context).pop();
                  //       onThemeToggle!();
                  //     },
                  //   ),
                ],
              ),
            ),

            // Footer with client ID
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: dividerColor.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isDarkMode
                        ? WebDarkColors.primary.withValues(alpha: 0.2)
                        : WebColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      clientId.isNotEmpty ? clientId[0].toUpperCase() : 'U',
                      style: WebTextStyles.sub(
                        isDarkTheme: isDarkMode,
                        color: isDarkMode ? WebDarkColors.primary : WebColors.primary,
                        fontWeight: WebFonts.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client ID',
                          style: WebTextStyles.caption(
                            isDarkTheme: isDarkMode,
                            color: isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                          ),
                        ),
                        Text(
                          clientId,
                          style: WebTextStyles.sub(
                            isDarkTheme: isDarkMode,
                            color: textColor,
                            fontWeight: WebFonts.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String screenName,
    required VoidCallback onTap,
  }) {
    // Check if this screen is currently active using the callback
    final isActive = isScreenActive?.call(screenName) ?? false;

    final activeColor = isDarkMode ? WebDarkColors.primary : WebColors.primary;
    final textColor = isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary;
    final hoverColor = isDarkMode
        ? WebDarkColors.primary.withValues(alpha: 0.1)
        : WebColors.primary.withValues(alpha: 0.1);

    return Material(
      color: isActive ? hoverColor : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? activeColor : textColor.withValues(alpha: 0.7),
          size: 22,
        ),
        title: Text(
          title,
          style: WebTextStyles.sub(
            isDarkTheme: isDarkMode,
            color: isActive ? activeColor : textColor,
            fontWeight: isActive ? WebFonts.bold : WebFonts.medium,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        selectedTileColor: hoverColor,
        selected: isActive,
      ),
    );
  }

  Widget _buildDrawerActionItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final textColor = isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary;

    return ListTile(
      leading: Icon(
        icon,
        color: textColor.withValues(alpha: 0.7),
        size: 22,
      ),
      title: Text(
        title,
        style: WebTextStyles.sub(
          isDarkTheme: isDarkMode,
          color: textColor,
          fontWeight: WebFonts.medium,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
