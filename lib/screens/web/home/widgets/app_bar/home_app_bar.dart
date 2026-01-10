import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/screens/web/home/models/panel_config.dart';
import 'navigation_items.dart';
import 'swap_button.dart';
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
  });

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo section
                RepaintBoundary(
                  child: SvgPicture.asset(
                    assets.appLogoIcon,
                    width: 100,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
                // Navigation screens
                Row(
                  children: [
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
                    RepaintBoundary(
                      child: SwapButton(
                        isDarkMode: isDarkMode,
                        onTap: onSwapPanels,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Theme toggle button
                    if (onThemeToggle != null)
                      RepaintBoundary(
                        child: _ThemeToggleButton(
                          isDarkMode: isDarkMode,
                          onToggle: onThemeToggle!,
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Profile section
                    RepaintBoundary(
                      child: ProfileDropdown(
                        isDarkMode: isDarkMode,
                        clientId: clientId,
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

class _ThemeToggleButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const _ThemeToggleButton({
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? WebDarkColors.surfaceVariant.withOpacity(0.5)
                : WebColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode
                  ? WebDarkColors.border.withOpacity(0.3)
                  : WebColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            size: 20,
            color: isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
