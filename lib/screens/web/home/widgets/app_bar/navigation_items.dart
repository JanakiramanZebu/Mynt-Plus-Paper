import 'package:flutter/material.dart';
import 'package:mynt_plus/screens/web/home/models/panel_config.dart';
import 'package:mynt_plus/screens/web/home/models/screen_type.dart';
import 'hoverable_nav_item.dart';

class NavigationItems extends StatelessWidget {
  final bool isDarkMode;
  final List<PanelConfig> panels;
  final VoidCallback onDashboardTap;
  final VoidCallback onPositionsTap;
  final VoidCallback onHoldingsTap;
  final VoidCallback onOrderBookTap;
  final VoidCallback onFundsTap;
  final VoidCallback onIPOTap;

  const NavigationItems({
    super.key,
    required this.isDarkMode,
    required this.panels,
    required this.onDashboardTap,
    required this.onPositionsTap,
    required this.onHoldingsTap,
    required this.onOrderBookTap,
    required this.onFundsTap,
    required this.onIPOTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavItem('Dashboard', ScreenType.dashboard, onDashboardTap),
        const SizedBox(width: 8),
        _buildNavItem('Positions', ScreenType.positions, onPositionsTap),
        const SizedBox(width: 8),
        _buildNavItem('Holdings', ScreenType.holdings, onHoldingsTap),
        const SizedBox(width: 8),
        _buildNavItem('Orders', ScreenType.orderBook, onOrderBookTap),
        const SizedBox(width: 8),
        _buildNavItem('Fund', ScreenType.funds, onFundsTap),
        const SizedBox(width: 8),
        _buildNavItem('IPO', ScreenType.ipo, onIPOTap),
      ],
    );
  }

  Widget _buildNavItem(
      String title, ScreenType screenType, VoidCallback onTap) {
    // Check if this screen is currently active in any panel
    bool isActive = false;
    for (int i = 0; i < panels.length; i++) {
      final panel = panels[i];
      if (panel.screenType == screenType ||
          (panel.screens.isNotEmpty &&
              panel.activeScreenIndex >= 0 &&
              panel.activeScreenIndex < panel.screens.length &&
              panel.screens[panel.activeScreenIndex] == screenType)) {
        isActive = true;
        break;
      }
    }

    return HoverableNavItem(
      title: title,
      isActive: isActive,
      onTap: onTap,
      isDarkMode: isDarkMode,
    );
  }
}
