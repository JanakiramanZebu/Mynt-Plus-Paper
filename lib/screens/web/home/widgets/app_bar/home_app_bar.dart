import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/responsive_extensions.dart';
import 'package:mynt_plus/screens/web/home/models/panel_config.dart';
import 'navigation_items.dart';
import 'profile_dropdown.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final String clientId;
  final List<PanelConfig> panels;
  final VoidCallback onDashboardTap;
  final VoidCallback onPositionsTap;
  final VoidCallback onHoldingsTap;
  final VoidCallback onOrderBookTap;
  final VoidCallback onFundsTap;
  final VoidCallback onIPOTap;
  final VoidCallback onSwapPanels;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onMenuTap; // Callback to open drawer on small screens

  /// Breakpoint below which hamburger menu is shown
  static const double mobileBreakpoint = 1200.0;

  const HomeAppBar({
    super.key,
    required this.isDarkMode,
    required this.clientId,
    required this.panels,
    required this.onDashboardTap,
    required this.onPositionsTap,
    required this.onHoldingsTap,
    required this.onOrderBookTap,
    required this.onFundsTap,
    required this.onIPOTap,
    required this.onSwapPanels,
    this.onThemeToggle,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showHamburger = screenWidth < mobileBreakpoint;

    return PreferredSize(
      preferredSize: const Size.fromHeight(58),
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? WebDarkColors.surface : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDarkMode
                    ? WebDarkColors.divider.withOpacity(0.3)
                    : WebColors.divider.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(mobile: 12.0, tablet: 16.0, desktop: 20.0),
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Hamburger menu (mobile) or Logo (desktop)
                Row(
                  children: [
                    // Hamburger menu icon for mobile/tablet
                    if (showHamburger && onMenuTap != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                            size: 24,
                          ),
                          onPressed: onMenuTap,
                          tooltip: 'Menu',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    // Logo section
                    RepaintBoundary(
                      child: SvgPicture.asset(
                        assets.appLogoIcon,
                        width: context.responsive(mobile: 80.0, tablet: 90.0, desktop: 100.0),
                        height: 38,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                // Right side: Navigation items (desktop) or Profile only (mobile)
                Row(
                  children: [
                    // Show full navigation only on larger screens
                    if (!showHamburger) ...[
                      NavigationItems(
                        isDarkMode: isDarkMode,
                        panels: panels,
                        onDashboardTap: onDashboardTap,
                        onPositionsTap: onPositionsTap,
                        onHoldingsTap: onHoldingsTap,
                        onOrderBookTap: onOrderBookTap,
                        onFundsTap: onFundsTap,
                        onIPOTap: onIPOTap,
                      ),
                      const SizedBox(width: 12),
                    ],
                    // Profile section - always visible
                    RepaintBoundary(
                      child: ProfileDropdown(
                        isDarkMode: isDarkMode,
                        clientId: clientId,
                        onSwapPanels: onSwapPanels,
                        onThemeToggle: onThemeToggle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
