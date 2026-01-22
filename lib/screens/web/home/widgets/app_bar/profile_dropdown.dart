import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart'
    hide MenuController, TextButton, AlertDialog, showDialog, DropdownMenu;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/locator/locator.dart';
import 'package:mynt_plus/locator/preference.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/user_profile_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/web/profile/logged_user_list_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../customizable_split_home_screen.dart' show ScreenType;

// Profile dropdown widget using shadcn
class ProfileDropdown extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final String clientId;
  final Function(dynamic)? onNavigateToScreen;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onSwapPanels;

  const ProfileDropdown({
    super.key,
    required this.isDarkMode,
    required this.clientId,
    this.onNavigateToScreen,
    this.onThemeToggle,
    this.onSwapPanels,
  });

  @override
  ConsumerState<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends ConsumerState<ProfileDropdown> {
  @override
  Widget build(BuildContext context) {
    // Capture parent context for navigation
    final parentContext = context;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GhostButton(
        onPressed: () {
          showDropdown(
            context: context,
            builder: (dropdownContext) {
              return ProfileDropdownMenu(
                isDarkMode: widget.isDarkMode,
                clientId: widget.clientId,
                onNavigateToScreen: widget.onNavigateToScreen,
                parentContext: parentContext,
                onThemeToggle: widget.onThemeToggle,
                onSwapPanels: widget.onSwapPanels,
              );
            },
          ).future.then((_) {
            if (kDebugMode) {
              print('Profile dropdown closed');
            }
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.clientId,
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.semiBold,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile dropdown menu content using shadcn DropdownMenu
class ProfileDropdownMenu extends ConsumerWidget {
  final bool isDarkMode;
  final String clientId;
  final Function(dynamic)? onNavigateToScreen;
  final BuildContext parentContext;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onSwapPanels;

  const ProfileDropdownMenu({
    super.key,
    required this.isDarkMode,
    required this.clientId,
    required this.parentContext,
    this.onNavigateToScreen,
    this.onThemeToggle,
    this.onSwapPanels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final theme = ref.watch(themeProvider);
    final funds = ref.watch(fundProvider);
    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";

    final userName = userProfile.userDetailModel?.uname ?? clientId;
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    final textColor = resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subtitleColor = resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final iconColor = resolveThemeColor(context, dark: MyntColors.iconDark, light: MyntColors.icon);

    return SizedBox(
      width: 300,
      child: DropdownMenu(
        children: [
          // User Profile Header
          MenuButton(
            onPressed: (ctx) {
              Navigator.pushNamed(parentContext, Routes.myAcc);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.primaryDark.withValues(alpha: 0.08),
                        light: MyntColors.primary.withValues(alpha: 0.08),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: MyntWebTextStyles.head(
                          context,
                          fontWeight: MyntFonts.semiBold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: MyntWebTextStyles.titlesub(
                            context,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          clientId,
                          style: MyntWebTextStyles.para(
                            context,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const MenuDivider(),

          // My Account
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'My Account',
              subtitle: 'Profile, Bank, Segment, MTF',
              iconColor: iconColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onPressed: (ctx) async {
                await funds.fetchHstoken(parentContext);
                final url = 'https://profile.zebuetrade.com/?uid=${pref.clientId}&token=${pref.token}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),

            // Reports
            _buildMenuItem(
              context,
              icon: Icons.description_outlined,
              title: 'Reports',
              subtitle: 'Ledger, Holdings, PnL, Tax',
              iconColor: iconColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onPressed: (ctx) async {
                await funds.fetchHstoken(parentContext);
                final url = 'https://profile.zebuetrade.com/?uid=${pref.clientId}&token=${pref.token}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),

            // Corporation Action
            _buildMenuItem(
              context,
              icon: Icons.business_outlined,
              title: 'Corporation Action',
              subtitle: 'Buyback, Delisting, Takeover, OFS',
              iconColor: iconColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onPressed: (ctx) async {
                await funds.fetchHstoken(parentContext);
                final url = 'https://profile.zebuetrade.com/?uid=${pref.clientId}&token=${pref.token}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),

            // Pledge & Unpledge
            _buildMenuItem(
              context,
              icon: Icons.lock_outline,
              title: 'Pledge & Unpledge',
              subtitle: 'Stocks held by various accounts',
              iconColor: iconColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onPressed: (ctx) async {
                await funds.fetchHstoken(parentContext);
                final url = 'https://profile.zebuetrade.com/?uid=${pref.clientId}&token=${pref.token}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),

            // Refer
            _buildMenuItem(
              context,
              icon: Icons.card_giftcard_outlined,
              title: 'Refer',
              subtitle: 'Refer your family & friends',
              iconColor: iconColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onPressed: (ctx) async {
                await Share.share(
                  "Get 20% of brokerage for trades made by your friends.\n ${Uri.parse(reflink)}",
                );
              },
            ),

            // Help & Support
            _buildMenuItem(
              context,
              icon: Icons.headset_mic_outlined,
              title: 'Help & Support',
              subtitle: 'Sales, Support & Desk',
              iconColor: iconColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onPressed: (ctx) async {
                await funds.fetchHstoken(parentContext);
                final url = 'https://profile.zebuetrade.com/?uid=${pref.clientId}&token=${pref.token}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),

            // Setting
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Setting',
              subtitle: 'API key, Change password',
              iconColor: iconColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onPressed: (ctx) async {
                if (onNavigateToScreen != null) {
                  onNavigateToScreen!(ScreenType.settings);
                } else {
                  await ref.read(userProfileProvider).fetchsetting();
                  Navigator.pushNamed(parentContext, Routes.profilesettingscreen);
                }
              },
            ),

          const MenuDivider(),

          // Swap Panels
          if (onSwapPanels != null)
            _buildSimpleMenuItem(
              context,
              icon: Icons.swap_horiz,
              title: 'Swap Panels',
              iconColor: iconColor,
              textColor: textColor,
              onPressed: (ctx) {
                onSwapPanels!();
              },
            ),

          // Theme Toggle
          if (onThemeToggle != null)
            _buildSimpleMenuItem(
              context,
              icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
              title: isDarkMode ? 'Light Mode' : 'Dark Mode',
              iconColor: iconColor,
              textColor: textColor,
              onPressed: (ctx) {
                onThemeToggle!();
              },
            ),

          // Switch Account
          _buildSimpleMenuItem(
            context,
            icon: Icons.switch_account_outlined,
            title: 'Switch Account',
            iconColor: iconColor,
            textColor: textColor,
            onPressed: (ctx) {
              material.showDialog(
                context: parentContext,
                builder: (context) => const LoggedUserListWeb(initRoute: ''),
              );
            },
          ),

          const MenuDivider(),

          // Logout
          MenuButton(
            onPressed: (ctx) {
              _showLogoutDialog(parentContext, ref, theme);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: 22,
                    color: resolveThemeColor(context, dark: MyntColors.iconDark, light: MyntColors.icon),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Logout',
                    style: MyntWebTextStyles.body(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  MenuButton _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color textColor,
    required Color subtitleColor,
    required void Function(BuildContext) onPressed,
  }) {
    return MenuButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MyntWebTextStyles.body(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: MyntWebTextStyles.para(
                      context,
                      color: subtitleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MenuButton _buildSimpleMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color textColor,
    required void Function(BuildContext) onPressed,
  }) {
    return MenuButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.medium,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, WidgetRef ref, ThemesProvider theme) {
    material.showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return material.AlertDialog(
          backgroundColor: resolveThemeColor(
            dialogContext,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor,
          ),
          titleTextStyle: MyntWebTextStyles.head(dialogContext),
          contentTextStyle: MyntWebTextStyles.body(dialogContext),
          titlePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          scrollable: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          title: Text(
            "Confirmation",
            style: MyntWebTextStyles.titlesub(dialogContext),
          ),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Are you sure you want to logout?",
                  style: MyntWebTextStyles.body(dialogContext),
                ),
              ],
            ),
          ),
          actions: [
            material.TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "No",
                style: MyntWebTextStyles.bodyMedium(
                  dialogContext,
                  color: resolveThemeColor(
                    dialogContext,
                    dark: MyntColors.primary,
                    light: MyntColors.primaryDark,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                ref.read(authProvider).fetchLogout(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: resolveThemeColor(
                  dialogContext,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.textBlack,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                "Yes",
                style: MyntWebTextStyles.bodyMedium(
                  dialogContext,
                  color: MyntColors.textWhite,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Keep these for backward compatibility if needed elsewhere
class ProfileMenuContentWrapper extends StatelessWidget {
  final VoidCallback onNavigate;

  const ProfileMenuContentWrapper({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class ProfileCloseCallback extends InheritedWidget {
  final VoidCallback onClose;

  const ProfileCloseCallback({
    super.key,
    required this.onClose,
    required super.child,
  });

  static ProfileCloseCallback? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfileCloseCallback>();
  }

  @override
  bool updateShouldNotify(ProfileCloseCallback oldWidget) {
    return onClose != oldWidget.onClose;
  }
}

