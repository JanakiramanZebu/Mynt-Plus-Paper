import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

/// Simple AppBar for the Scalper Screen matching the home screen design
class ScalperAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onPositionsTap;
  final VoidCallback? onHoldingsTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onFundsTap;

  const ScalperAppBar({
    super.key,
    this.onHomeTap,
    this.onPositionsTap,
    this.onHoldingsTap,
    this.onOrdersTap,
    this.onFundsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final isDark = theme.isDarkMode;
    final pref = locator<Preferences>();
    final clientId = pref.clientId ?? '';

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor,
        ),
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo
          SvgPicture.asset(
            assets.appLogoIcon,
            width: 100,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 32),
          // Left navigation items
          _buildNavItem(context, 'Mutual Fund', false, isDark, null),
          _buildNavItem(context, 'IPO', false, isDark, null),
          _buildNavItem(context, 'Bonds', false, isDark, null),
          _buildNavItem(context, 'OptionZ', false, isDark, null),
          _buildNavItem(context, 'Flash', false, isDark, null),
          _buildNavItem(context, 'Scalper', true, isDark, null), // Active
          const Spacer(),
          // Right navigation items
          _buildNavItem(context, 'Home', false, isDark, onHomeTap, isRightSide: true),
          _buildNavItem(context, 'Positions', false, isDark, onPositionsTap, isRightSide: true),
          _buildNavItem(context, 'Holdings', false, isDark, onHoldingsTap, isRightSide: true),
          _buildNavItem(context, 'Orders', false, isDark, onOrdersTap, isRightSide: true),
          _buildNavItem(context, 'Funds', false, isDark, onFundsTap, isRightSide: true),
          const SizedBox(width: 16),
          // Profile dropdown
          _buildProfileButton(context, clientId, isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    bool isActive,
    bool isDark,
    VoidCallback? onTap, {
    bool isRightSide = false,
  }) {
    final activeColor = isRightSide
        ? resolveThemeColor(context, dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary);
    final inactiveColor = resolveThemeColor(
      context,
      dark: MyntColors.textSecondaryDark,
      light: MyntColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: MyntWebTextStyles.body(
              context,
              fontWeight: isActive ? MyntFonts.semiBold : MyntFonts.medium,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, String clientId, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.listItemBgDark,
          light: MyntColors.listItemBg,
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: resolveThemeColor(
            context,
            dark: MyntColors.dividerDark,
            light: MyntColors.divider,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            clientId.isNotEmpty ? clientId : 'User',
            style: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.medium,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
