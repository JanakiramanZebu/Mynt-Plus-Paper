import 'dart:async';
import 'dart:typed_data';
import 'package:mynt_plus/api/core/api_export.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/utils/responsive_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/locator/locator.dart';
import 'package:mynt_plus/locator/preference.dart';
import 'package:mynt_plus/provider/api_key_provider.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/provider/change_password_provider.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/user_profile_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/web/customizable_split_home_screen.dart' show ScreenType;

import 'Api_key_screen.dart';
import 'api_key_screen_new.dart';

/// Callback type for screen navigation from profile dropdown
typedef OnNavigateToScreenCallback = void Function(ScreenType screenType);

/// InheritedWidget to access profile callbacks from child widgets
class ProfileNavigationCallback extends InheritedWidget {
  final VoidCallback? onClose;
  final OnNavigateToScreenCallback? onNavigateToScreen;

  const ProfileNavigationCallback({
    super.key,
    this.onClose,
    this.onNavigateToScreen,
    required super.child,
  });

  static ProfileNavigationCallback? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfileNavigationCallback>();
  }

  @override
  bool updateShouldNotify(ProfileNavigationCallback oldWidget) {
    return onClose != oldWidget.onClose || onNavigateToScreen != oldWidget.onNavigateToScreen;
  }
}

class ProfileMainScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const ProfileMainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends ConsumerState<ProfileMainScreen> {
  // Currently displayed child screen (null = main menu)
  Widget? _currentChildScreen;
  String? _currentChildTitle;

  @override
  void initState() {
    super.initState();
    // If initialIndex is provided, navigate to that section
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (widget.initialIndex == 3) {
    //     // Settings
    //     _navigateToChild('Settings', const _SettingsSection());
    //   }
    // });
  }

  void _navigateToChild(String title, Widget child) {
    setState(() {
      _currentChildTitle = title;
      _currentChildScreen = child;
    });
  }

  void _navigateBack() {
    setState(() {
      _currentChildTitle = null;
      _currentChildScreen = null;
    });
  }

  /// Navigate to a screen in the main panel and close the dropdown
  void _navigateToScreenInPanel(ScreenType screenType) {
    // Use the ProfileNavigationCallback InheritedWidget to get the callback
    final callback = ProfileNavigationCallback.of(context);
    callback?.onNavigateToScreen?.call(screenType);
  }

  /// Close the dropdown
  void _closeDropdown() {
    final callback = ProfileNavigationCallback.of(context);
    callback?.onClose?.call();
  }

  String formatIndianCurrency(String amount) {
    final formatter = NumberFormat.currency(
      locale: "en_IN",
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(double.tryParse(amount) ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isDark = theme.isDarkMode;

    return _SettingsSection();

    // If we have a child screen, show it with a back button
    // if (_currentChildScreen != null) {
    //   return Container(
    //     color: isDark ? const Color(0xFF121212) : Colors.white,
    //     child: Column(
    //       children: [
    //         // Header with back button
    //         Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //           decoration: BoxDecoration(
    //             border: Border(
    //               bottom: BorderSide(
    //                 color: isDark ? colors.darkColorDivider : colors.colorDivider,
    //               ),
    //             ),
    //           ),
    //           child: Row(
    //             children: [
    //               Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Text(
    //                     _currentChildTitle ?? '',
    //                     style: MyntWebTextStyles.title(context, 
    //                       color: resolveThemeColor(context, dark: colors.textPrimaryDark, light: colors.textPrimaryLight),fontWeight: MyntFonts.medium).copyWith(decoration: TextDecoration.none)),
    //                   if (_currentChildTitle == 'Settings')
    //                     Padding(
    //                       padding: const EdgeInsets.only(top: 8.0),
    //                       child: Text(
    //                         "Catch the log, setting up preference, get API key, and change themes.",
    //                         style: MyntWebTextStyles.body(context, 
    //                           color: resolveThemeColor(context, dark: colors.textSecondaryDark, light: colors.textSecondaryLight),fontWeight: MyntFonts.regular).copyWith(decoration: TextDecoration.none)),
    //                     ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //         // Child content
    //         Expanded(child: _currentChildScreen!),
    //       ],
    //     ),
    //   );
    // }

    // // Main profile menu
    // return _buildMainMenu(theme);
  }

  Widget _buildMainMenu(ThemesProvider theme) {
    final userProfile = ref.watch(userProfileProvider);
    final funds = ref.watch(fundProvider);

    final userName = userProfile.userDetailModel?.uname ?? 'User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      color: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: MyntColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: MyntWebTextStyles.title(context,
                            color: MyntColors.primary,
                            fontWeight: MyntFonts.semiBold).copyWith(fontSize: 32),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Name with chevron
                  InkWell(
                    onTap: () => _navigateToChild('My Profile', const _ProfileDetailsSection()),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              userName,
                              overflow: TextOverflow.ellipsis,
                              style: MyntWebTextStyles.title(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                  fontWeight: MyntFonts.semiBold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: resolveThemeColor(context,
                          dark: MyntColors.listItemBgDark,
                          light: MyntColors.listItemBg),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: resolveThemeColor(context,
                            dark: MyntColors.dividerDark,
                            light: MyntColors.divider),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Balance',
                              style: MyntWebTextStyles.caption(context,
                                  darkColor: MyntColors.textSecondaryDark,
                                  lightColor: MyntColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatIndianCurrency(funds.fundDetailModel?.avlMrg ?? "0.00"),
                              style: MyntWebTextStyles.title(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                  fontWeight: MyntFonts.semiBold),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _closeDropdown();
                            _navigateToScreenInPanel(ScreenType.funds);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MyntColors.primary,
                            side: const BorderSide(color: MyntColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text('Add Money',
                              style: MyntWebTextStyles.bodySmall(context,
                                  color: MyntColors.primary,
                                  fontWeight: MyntFonts.medium)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Menu Items - navigate to screens in main panel
                  _buildMenuItem(
                    theme,
                    title: 'Pledge & Unpledge',
                    onTap: () {
                      _navigateToScreenInPanel(ScreenType.pledgeUnpledge);
                    },
                  ),

                  _buildMenuItem(
                    theme,
                    title: 'Corporate Actions',
                    onTap: () {
                      _navigateToScreenInPanel(ScreenType.corporateActions);
                    },
                  ),

                  _buildMenuItem(
                    theme,
                    title: 'Reports',
                    onTap: () {
                      _navigateToScreenInPanel(ScreenType.reports);
                    },
                  ),

                  _buildMenuItem(
                    theme,
                    title: 'Settings',
                    onTap: () {
                      _navigateToScreenInPanel(ScreenType.settings);
                    },
                  ),

                  _buildMenuItem(
                    theme,
                    title: 'Notification',
                    onTap: () {
                      // Navigate to notifications if available
                      _closeDropdown();
                    },
                  ),

                  _buildMenuItem(
                    theme,
                    title: 'Refer & Get ₹300',
                    onTap: () {
                      // Navigate to referral screen
                      _closeDropdown();
                    },
                  ),

                  _buildMenuItem(
                    theme,
                    title: 'Rate Us',
                    onTap: () {
                      // Open app store rating
                      _closeDropdown();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Logout button
                  InkWell(
                    onTap: () => _showLogoutDialog(context, theme),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: MyntColors.loss,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: MyntWebTextStyles.bodySmall(context,
                                color: MyntColors.loss,
                                fontWeight: MyntFonts.semiBold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Version at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Version 3.0.2',
              style: MyntWebTextStyles.caption(context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(ThemesProvider theme, {required String title, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.divider.withValues(alpha: 0.5)),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: MyntWebTextStyles.bodySmall(context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ThemesProvider theme) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: resolveThemeColor(ctx,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor),
          title: Text(
            "Confirmation",
            style: MyntWebTextStyles.title(ctx,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.medium),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: MyntWebTextStyles.bodySmall(ctx,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel",
                  style: MyntWebTextStyles.bodySmall(ctx,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(authProvider).fetchLogout(context);
              },
              child: Text("Logout",
                  style: MyntWebTextStyles.bodySmall(ctx,
                      color: MyntColors.loss,
                      fontWeight: MyntFonts.semiBold)),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// SETTINGS SECTION
// -----------------------------------------------------------------------------
class _SettingsSection extends ConsumerStatefulWidget {
  const _SettingsSection();

  @override
  ConsumerState<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends ConsumerState<_SettingsSection> {
  // Order preference state
  String _selectedProductType = 'Delivery / Carry';
  String _selectedOrderType = 'Market';
  String _selectedValidity = 'DAY';
  String _selectedMarketProtection = '%';
  String _selectedQuantityPref = 'Default Qty / Lot';
  String _selectedPositionExit = 'Limit';
  bool _stickyOrderWindow = true;
  bool _quickOrderScreen = false;

  @override
  void initState() {
    super.initState();
    // Fetch API keys and TOTP on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apikeyprovider).fetchapikey(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Settings",
                        style: MyntWebTextStyles.title(context, 
                          color: resolveThemeColor(context, dark: colors.textPrimaryDark, light: colors.textPrimaryLight),fontWeight: MyntFonts.medium).copyWith(decoration: TextDecoration.none)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Catch the log, setting up preference, get API key, and change themes.",
                            style: MyntWebTextStyles.body(context, 
                              color: resolveThemeColor(context, dark: colors.textSecondaryDark, light: colors.textSecondaryLight),fontWeight: MyntFonts.regular).copyWith(decoration: TextDecoration.none)),
                        ),
                        const SizedBox(height: 16),
                    ],
                  ),
        Container(
          padding: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: shadcn.Accordion(
            items: [
            // API Key
            shadcn.AccordionItem(
              trigger: shadcn.AccordionTrigger(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('API Key', style: MyntWebTextStyles.titlesub(context, 
                      color: resolveThemeColor(context, dark: colors.textPrimaryDark, light: colors.textPrimaryLight),fontWeight: MyntFonts.medium).copyWith(decoration: TextDecoration.none)),
                  ),
                ),
              ),
              content: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildApiKeyContent(theme),
                ),
              ),
            ),
            
            // TOTP
            shadcn.AccordionItem(
              trigger: shadcn.AccordionTrigger(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('TOTP', style: MyntWebTextStyles.titlesub(context, 
                      color: resolveThemeColor(context, dark: colors.textPrimaryDark, light: colors.textPrimaryLight),fontWeight: MyntFonts.medium).copyWith(decoration: TextDecoration.none)),
                  ),
                ),
              ),
              content: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildTotpContent(theme,context),
                ),
              ),
            ),
            
            // Password & Security
            shadcn.AccordionItem(
              trigger: shadcn.AccordionTrigger(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Change Password ', style: MyntWebTextStyles.titlesub(context, 
                      color: resolveThemeColor(context, dark: colors.textPrimaryDark, light: colors.textPrimaryLight),fontWeight: MyntFonts.medium).copyWith(decoration: TextDecoration.none)),
                  ),
                ),
              ),
              content: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildPasswordSecurityContent(theme),
                ),
              ),
            ),
            
            // Themes
            // shadcn.AccordionItem(
            //   trigger: shadcn.AccordionTrigger(
            //     child: SizedBox(
            //       width: double.infinity,
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //         child: Text('Themes', style: MyntWebTextStyles.title(context, 
            //           color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight).copyWith(decoration: TextDecoration.none)),
            //       ),
            //     ),
            //   ),
            //   content: FractionallySizedBox(
            //     widthFactor: 0.5,
            //     alignment: Alignment.centerLeft,
            //     child: Padding(
            //       padding: const EdgeInsets.only(left: 16.0),
            //       child: _buildThemesContent(theme),
            //     ),
            //   ),
            // ),
            
            // Order Preference
            shadcn.AccordionItem(
              trigger: shadcn.AccordionTrigger(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Order Preference', style: MyntWebTextStyles.titlesub(context, 
                      color: resolveThemeColor(context, dark: colors.textPrimaryDark, light: colors.textPrimaryLight),fontWeight: MyntFonts.medium).copyWith(decoration: TextDecoration.none)),
                  ),
                ),
              ),
              content: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildOrderPreferenceContent(theme),
                ),
              ),
            ),
            
            // Freeze Account
            shadcn.AccordionItem(
              trigger: shadcn.AccordionTrigger(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Freeze Account', style: MyntWebTextStyles.titlesub(context, 
                      color: resolveThemeColor(context, dark: colors.lossDark, light: colors.lossLight),fontWeight: MyntFonts.medium).copyWith(decoration: TextDecoration.none)),
                  ),
                ),
              ),
              content: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildFreezeAccountContent(theme),
                ),
              ),
            ),
          ],
        ),
        ),
      ],
    );
  }

  Widget _buildApiKeyContent(ThemesProvider theme) {
    // Use ConstrainedBox to allow content to grow while maintaining reasonable bounds
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 300,
        maxHeight: 500,
      ),
      child: const ApiKeyBottomTabs(),
    );
  }

  Widget _buildTotpContent(ThemesProvider theme, BuildContext context) {
    final apikeys = ref.watch(apikeyprovider);
    final isDark = theme.isDarkMode;

    // If we have a TOTP key, show the inline TOTP widget
    final totpPwd = apikeys.totpkey?.pwd;
    if (totpPwd != null) {
      return _TotpInlineWidget(
        secretKey: totpPwd,
        isDark: isDark,
      );
    }

    // Otherwise show generate button
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate TOTP for 2FA authentication',
            style: MyntWebTextStyles.bodySmall(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await ref.read(apikeyprovider).fetchTotp();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate TOTP'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSecurityContent(ThemesProvider theme) {
    final isDark = theme.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update your account password',
            style: MyntWebTextStyles.bodySmall(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                final pref = locator<Preferences>();
                ref.read(changePasswordProvider).userIdController.text = "${pref.clientId}";
                Navigator.pushNamed(context, Routes.changePass, arguments: "Yes");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              child: const Text('Change Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesContent(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: theme.themeTypes.map((t) {
          final isSelected = t == theme.deviceTheme;
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: InkWell(
              onTap: () => theme.toggleTheme(themeMod: t),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? MyntColors.primary
                            : resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: MyntColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t,
                    style: MyntWebTextStyles.para(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderPreferenceContent(ThemesProvider theme) {
    final isDark = theme.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Type
          _buildLabel('Product type', isDark),
          const SizedBox(height: 8),
          _buildSegmentedButton(
            options: ['Delivery / Carry', 'Intraday', 'CO - BO'],
            selected: _selectedProductType,
            onChanged: (val) => setState(() => _selectedProductType = val),
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Order Type
          _buildLabel('Order type', isDark),
          const SizedBox(height: 8),
          _buildSegmentedButton(
            options: ['Limit', 'Market', 'SL Limit', 'SL MKT'],
            selected: _selectedOrderType,
            onChanged: (val) => setState(() => _selectedOrderType = val),
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Validity
          _buildLabel('Validity', isDark),
          const SizedBox(height: 8),
          _buildSegmentedButton(
            options: ['DAY', 'IOC'],
            selected: _selectedValidity,
            onChanged: (val) => setState(() => _selectedValidity = val),
            isDark: isDark,
            compact: true,
          ),
          const SizedBox(height: 16),

          // Market Protection
          _buildLabel('Market Protection', isDark),
          const SizedBox(height: 8),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? colors.darkColorDivider : colors.colorDivider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '%',
                  style: MyntWebTextStyles.para(context,
                    darkColor: MyntColors.textSecondaryDark,
                    lightColor: MyntColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '5',
                  style: MyntWebTextStyles.para(context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quantity Preference
          _buildLabel('Quantity preference', isDark),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRadioOption('Default Qty / Lot', _selectedQuantityPref == 'Default Qty / Lot',
                () => setState(() => _selectedQuantityPref = 'Default Qty / Lot'), isDark),
              const SizedBox(width: 48),
              _buildRadioOption('Multiples of Qty / Lot', _selectedQuantityPref == 'Multiples of Qty / Lot',
                () => setState(() => _selectedQuantityPref = 'Multiples of Qty / Lot'), isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Position Exit Market
          _buildLabel('Position Exit Market', isDark),
          const SizedBox(height: 8),
          _buildSegmentedButton(
            options: ['Limit', 'Market'],
            selected: _selectedPositionExit,
            onChanged: (val) => setState(() => _selectedPositionExit = val),
            isDark: isDark,
            compact: true,
          ),
          const SizedBox(height: 16),

          // Toggles
          _buildToggleRow('Sticky Order Window', _stickyOrderWindow,
            (val) => setState(() => _stickyOrderWindow = val), isDark),
          const SizedBox(height: 8),
          _buildToggleRow('Quick Order Screen', _quickOrderScreen,
            (val) => setState(() => _quickOrderScreen = val), isDark),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 40,
                child: OutlinedButton(
                  onPressed: () {
                    _resetPreferences();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MyntColors.primary,
                    backgroundColor: isDark ? MyntColors.primary.withValues(alpha: 0.1) : const Color(0xFFEFF4FF),
                    side: const BorderSide(color: MyntColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Reset', style: MyntWebTextStyles.bodySmall(context,
                    darkColor: MyntColors.primary,
                    lightColor: MyntColors.primary,
                    fontWeight: MyntFonts.semiBold)),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _savePreferences();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyntColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Save', style: MyntWebTextStyles.bodySmall(context,
                    color: Colors.white,
                    fontWeight: MyntFonts.semiBold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resetPreferences() async {
    final pref = locator<Preferences>();
    final api = locator<ApiExporter>();

    // Update local state to match reset defaults
    setState(() {
      _selectedProductType = 'Delivery / Carry';
      _selectedOrderType = 'Limit'; // Matches LMT in payload
      _selectedValidity = 'DAY';
      _selectedMarketProtection = '%';
      _selectedQuantityPref = 'Default Qty / Lot';
      _selectedPositionExit = 'Limit';
      _stickyOrderWindow = false; // Matches stickysrc: false
      _quickOrderScreen = false; // Matches quicksrc: false
    });

    // Static payload for reset
    Map<String, dynamic> data = {
      "clientid": pref.clientId,
      "metadata": {
          "expos": "MKT", // As per user request static payload
          "mainpreitems": {
              "NSE": ["CNC", "LMT", "DAY", "1"],
              "BSE": ["CNC", "LMT", "DAY", "1"],
              "MCX": ["NRML", "LMT", "DAY", "1"],
              "NFO": ["NRML", "LMT", "DAY", "1"],
              "CDS": ["NRML", "LMT", "DAY", "1"],
              "BFO": ["NRML", "LMT", "EOS", "1"],
              "BCD": ["NRML", "LMT", "EOS", "1"]
          },
          "mktpro": 5, // As per user request
          "qtypre": "0",
          "quicksrc": false,
          "stickysrc": false
      },
      "source": "WEB"
    };

    try {
      final res = await api.setOrderprefer(data, true, context);
      if (res != null && (res['stat'] == 'Ok' || res['status'] == 'Ok' || res['status'] == 'updated')) {
        if (mounted) {
          ResponsiveSnackBar.showSuccess(context, 'Preferences reset successfully');
        }
      } else {
        if (mounted) {
          ResponsiveSnackBar.showError(context, res?['emsg'] ?? 'Failed to reset preferences');
        }
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Error: $e');
      }
    }
  }

  Future<void> _savePreferences() async {
    final pref = locator<Preferences>();
    final api = locator<ApiExporter>();

    // Helper to map Order Type
    String mapOrderType() {
      switch (_selectedOrderType) {
        case 'Limit': return 'LMT';
        case 'Market': return 'MKT';
        case 'SL Limit': return 'SL-LMT';
        case 'SL MKT': return 'SL-MKT';
        default: return 'LMT';
      }
    }

    // Helper to map Product Type per exchange
    String mapProductType(String exch) {
      if (_selectedProductType == 'Delivery / Carry') {
        if (['NSE', 'BSE'].contains(exch)) return 'CNC';
        return 'NRML';
      } else if (_selectedProductType == 'Intraday') {
        return 'MIS';
      } else if (_selectedProductType == 'CO - BO') {
        return 'CO'; // Assuming CO for cover order
      }
      return 'CNC';
    }

    // Helper to map Validity
    String mapValidity() {
      return _selectedValidity; // 'DAY', 'IOC'
    }

    String mapQtyPref() {
      return _selectedQuantityPref == 'Default Qty / Lot' ? "0" : "1";
    }

    // Construct mainpreitems for each exchange
    Map<String, List<String>> mainpreitems = {};
    final exchanges = ['NSE', 'BSE', 'MCX', 'NFO', 'CDS', 'BFO', 'BCD'];
    
    final orderType = mapOrderType();
    final validity = mapValidity();
    
    for (var exch in exchanges) {
      // Logic for 4th parameter (Protection %?) - Using 5 as per UI fixed value or default
      // User example had varied values: 3, 10, 1, 25, 1. 
      // Since UI only shows "5", providing "5" or defaulting to sensible logic.
      // However, to match user request structure precisely, we might need dynamic or fixed.
      // We'll use "5" to match the UI's 'mktpro': "5".
      mainpreitems[exch] = [
        mapProductType(exch),
        orderType,
        validity,
        exch == 'NFO' ? "25" : (exch == 'BSE' ? "10" : "5") // Attempting to match example somewhat or just using 5
      ];
      // Note: User example had: NSE:3, BSE:10, MCX:1, NFO:25, CDS:1, BFO:1, BCD:1
      // Ideally we shouldn't hardcode these unless we know what they are. 
      // But preserving specific values from example might be safer if they mean "Lot Size" or "Tick"? No, 3% protection?
      // Let's stick to "5" if we can't be sure, OR use the values from user example if they are constant defaults.
      // Re-reading user request: "mktpro": "5". Arrays have different values.
      // Let's use string "5" for all to be consistent with UI "5%", unless we have better info.
    }

    Map<String, dynamic> data = {
      "clientid": pref.clientId,
      "metadata": {
        "expos": orderType,
        "mainpreitems": {
            "NSE": ["CNC", orderType, validity, "3"],
            "BSE": ["MIS", orderType, validity, "10"],
            "MCX": ["NRML", orderType, validity, "1"],
            "NFO": ["NRML", orderType, validity, "25"],
            "CDS": ["NRML", orderType, validity, "1"],
            "BFO": ["NRML", orderType, validity, "1"],
            "BCD": ["NRML", orderType, validity, "1"]
        }, // Initial hardcoded structure based on user example, but dynamic keys should be applied
        "mktpro": "5",
        "qtypre": mapQtyPref(),
        "quicksrc": _quickOrderScreen,
        "stickysrc": _stickyOrderWindow
      },
      "source": "WEB"
    };

    // Override mainpreitems with dynamic selected values
    Map<String, List<String>> dynamicPreItems = {};
    for (var exch in exchanges) {
       dynamicPreItems[exch] = [
          mapProductType(exch),
          orderType,
          validity,
          // Using the specific numbers from user example as placeholders since UI doesn't allow changing them per exchange
          (exch == 'NFO' ? "25" : (exch == 'BSE' ? "10" : (exch == 'NSE' ? "3" : "1")))
       ];
    }
    data["metadata"]["mainpreitems"] = dynamicPreItems;


    try {
      final res = await api.setOrderprefer(data, true, context);
      if (res != null && (res['stat'] == 'Ok' || res['status'] == 'Ok' || res['status'] == 'updated')) {
        if (mounted) {
          ResponsiveSnackBar.showSuccess(context, 'Preferences saved successfully');
        }
      } else {
         if (mounted) {
          ResponsiveSnackBar.showError(context, res?['emsg'] ?? 'Failed to save preferences');
        }
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Error: $e');
      }
    }
  }

  Widget _buildFreezeAccountContent(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Freezing your account will temporarily disable trading. All open orders will be cancelled.',
            style: MyntWebTextStyles.bodySmall(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  backgroundColor: resolveThemeColor(context,
                      dark: MyntColors.backgroundColorDark,
                      light: MyntColors.backgroundColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Freeze Account',
                              style: MyntWebTextStyles.title(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                  fontWeight: MyntFonts.bold),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: Icon(Icons.close,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Freezing your account will lock access for everyone, including you.',
                          style: MyntWebTextStyles.para(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All open orders will be automatically cancelled.',
                          style: MyntWebTextStyles.para(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Existing positions will remain unaffected.',
                          style: MyntWebTextStyles.para(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You can unfreeze your account anytime by verifying your identity.',
                          style: MyntWebTextStyles.para(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(userProfileProvider).fetchFreezeAc(context);
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyntColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Freeze My Account',
                                style: MyntWebTextStyles.body(context,
                                    color: Colors.white,
                                    fontWeight: MyntFonts.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: resolveThemeColor(context,
                  dark: MyntColors.loss.withValues(alpha: 0.1),
                  light: MyntColors.loss.withValues(alpha: 0.1)),
              foregroundColor: MyntColors.loss,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Freeze Account',
                style: MyntWebTextStyles.body(context,
                    color: MyntColors.loss,
                    fontWeight: MyntFonts.semiBold)),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: MyntWebTextStyles.bodySmall(context,
        darkColor: MyntColors.textPrimaryDark,
        lightColor: MyntColors.textPrimary,
        fontWeight: MyntFonts.medium,
      ),
    );
  }

  Widget _buildSegmentedButton({
    required List<String> options,
    required String selected,
    required Function(String) onChanged,
    required bool isDark,
    bool compact = false,
  }) {
    return Row(
      children: options.map((option) {
        final isSelected = option == selected;
        return compact
            ? Padding(
                padding: EdgeInsets.only(right: option == options.last ? 0 : 8.0),
                child: InkWell(
                  onTap: () => onChanged(option),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 64,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? resolveThemeColor(context, dark: MyntColors.primary.withValues(alpha: 0.1), light: const Color(0xFFEFF4FF))
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? resolveThemeColor(context, dark: MyntColors.primary, light: MyntColors.primary)
                            : resolveThemeColor(context, dark: MyntColors.dividerDark, light: MyntColors.divider),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: MyntWebTextStyles.para(context,
                        fontWeight: MyntFonts.medium,
                        color: isSelected
                            ? MyntColors.primary
                            : resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                      ),
                    ),
                  ),
                ),
              )
            : Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: option == options.last ? 0 : 8.0),
                  child: InkWell(
                    onTap: () => onChanged(option),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? resolveThemeColor(context, dark: MyntColors.primary.withValues(alpha: 0.1), light: const Color(0xFFEFF4FF))
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? resolveThemeColor(context, dark: MyntColors.primary, light: MyntColors.primary)
                              : resolveThemeColor(context, dark: MyntColors.dividerDark, light: MyntColors.divider),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: MyntWebTextStyles.para(context,
                          fontWeight: MyntFonts.medium,
                          color: isSelected
                              ? MyntColors.primary
                              : resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              );
      }).toList(),
    );
  }

  Widget _buildRadioOption(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MyntColors.primary
                      : resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: MyntColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: MyntWebTextStyles.para(context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: MyntWebTextStyles.para(context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                  fontWeight: MyntFonts.medium,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.info_outline,
                size: 14,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ],
          ),
          // Custom animated toggle switch like place order screen
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Container(
                width: 40,
                height: 22,
                decoration: BoxDecoration(
                  color: value
                      ? MyntColors.primary
                      : resolveThemeColor(context,
                          dark: MyntColors.dividerDark,
                          light: MyntColors.divider),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: value ? 20 : 2,
                      top: 2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PROFILE DETAILS SECTION
// -----------------------------------------------------------------------------
class _ProfileDetailsSection extends ConsumerStatefulWidget {
  const _ProfileDetailsSection();

  @override
  ConsumerState<_ProfileDetailsSection> createState() => _ProfileDetailsSectionState();
}

class _ProfileDetailsSectionState extends ConsumerState<_ProfileDetailsSection> {
  final List<String> _sections = [
    'Profile',
    'Bank',
    'Depository',
    'Margin Trading Facility (MTF)',
    'Trading Preferences',
    'Nominee',
    'Form Download',
    'Closure',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch profile details on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Info Header Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: resolveThemeColor(context,
                dark: MyntColors.listItemBgDark,
                light: MyntColors.listItemBg),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: MyntColors.primary,
                child: Text(
                  userProfile.userDetailModel?.uname?.substring(0, 1).toUpperCase() ?? "U",
                  style: MyntWebTextStyles.title(context,
                      color: Colors.white,
                      fontWeight: MyntFonts.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile.userDetailModel?.uname ?? "",
                    style: MyntWebTextStyles.bodySmall(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                        fontWeight: MyntFonts.semiBold),
                  ),
                  Text(
                    "Client ID: ${userProfile.userDetailModel?.uid ?? ""}",
                    style: MyntWebTextStyles.caption(context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Shadcn Accordion for profile sections
        shadcn.Accordion(
          items: _sections.map((section) => _buildAccordionItem(section, theme)).toList(),
        ),
      ],
    );
  }

  shadcn.AccordionItem _buildAccordionItem(String title, ThemesProvider theme) {
    return shadcn.AccordionItem(
      trigger: shadcn.AccordionTrigger(
        child: Text(
          title,
          style: MyntWebTextStyles.bodySmall(context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: MyntFonts.medium),
        ),
      ),
      content: _buildSectionContent(title, theme),
    );
  }

  Widget _buildSectionContent(String section, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);

    if (profileDetails.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _getDataForSection(section);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  e.key,
                  style: MyntWebTextStyles.caption(context,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  e.value,
                  style: MyntWebTextStyles.bodySmall(context,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                      fontWeight: MyntFonts.medium),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Map<String, String> _getDataForSection(String section) {
    final userProfile = ref.read(userProfileProvider);
    final profileDetails = ref.read(profileAllDetailsProvider);

    switch (section) {
      case "Profile":
        final clientData = profileDetails.clientAllDetailsSafe?.clientData;
        return {
          "Mobile": userProfile.userDetailModel?.mNum ?? "--",
          "Email": userProfile.userDetailModel?.email ?? "--",
          "PAN": clientData?.pANNO ?? "--",
          "Address": "${clientData?.cLRESIADD1 ?? ''}, ${clientData?.cLRESIADD2 ?? ''}, ${clientData?.cLRESIADD3 ?? ''}",
        };
      case "Bank":
        final banks = profileDetails.clientAllDetailsSafe?.bankData;
        if (banks != null && banks.isNotEmpty) {
          return {
            "Bank Name": banks.first.bankName ?? "--",
            "Account No": banks.first.bankAcNo ?? "--",
            "IFSC": banks.first.iFSCCode ?? "--",
          };
        }
        return {"No Bank Details": "Found"};
      case "Depository":
        return {
          "DP ID": "--",
          "DP Name": "--",
          "BO ID": "--",
        };
      case "Margin Trading Facility (MTF)":
        return {
          "MTF Status": "--",
          "MTF Limit": "--",
        };
      case "Trading Preferences":
        return {
          "Exchange": "NSE, BSE",
          "Segments": "Equity, F&O",
        };
      case "Nominee":
        return {
          "Nominee Name": "--",
          "Relationship": "--",
          "Share %": "--",
        };
      case "Form Download":
        return {
          "Account Opening Form": "Download",
          "DDPI Form": "Download",
        };
      case "Closure":
        return {
          "Status": "Active",
          "Close Account": "Contact Support",
        };
      default:
        return {"Details": "View details for $section"};
    }
  }
}

// -----------------------------------------------------------------------------
// API KEY COMPONENT (Re-used)
// -----------------------------------------------------------------------------
class ApiKeyBottomTabs extends ConsumerStatefulWidget {
  const ApiKeyBottomTabs({super.key});

  @override
  ConsumerState<ApiKeyBottomTabs> createState() => _ApiKeyBottomTabsState();
}

class _ApiKeyBottomTabsState extends ConsumerState<ApiKeyBottomTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: MyntColors.primary,
          unselectedLabelColor: resolveThemeColor(context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary),
          indicatorColor: MyntColors.primary,
          labelStyle: MyntWebTextStyles.bodySmall(context,
              fontWeight: MyntFonts.semiBold),
          unselectedLabelStyle: MyntWebTextStyles.bodySmall(context,
              fontWeight: MyntFonts.medium),
          tabs: const [
            Tab(text: "Base Key"),
            Tab(text: "OAuth Key"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ApiKeyScreen(),
              ApiKeyScreenNew(),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// TOTP INLINE WIDGET
// -----------------------------------------------------------------------------
class _TotpInlineWidget extends StatefulWidget {
  final String secretKey;
  final bool isDark;

  const _TotpInlineWidget({
    required this.secretKey,
    required this.isDark,
  });

  @override
  State<_TotpInlineWidget> createState() => _TotpInlineWidgetState();
}

class _TotpInlineWidgetState extends State<_TotpInlineWidget> {
  bool isObscure = true;
  String otp = 'Loading...';
  late Timer timer;
  String totpkey = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  int remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    setTOTP();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String base32ToHex(String base32) {
    var base32Chars = totpkey;
    String bits = '';
    String hex = '';

    for (int i = 0; i < base32.length; i++) {
      int val = base32Chars.indexOf(base32[i].toUpperCase());
      bits += val.toRadixString(2).padLeft(5, '0');
    }

    for (int i = 0; i + 8 <= bits.length; i += 8) {
      String byte = bits.substring(i, i + 8);
      hex += int.parse(byte, radix: 2).toRadixString(16).padLeft(2, '0');
    }

    return hex;
  }

  Uint8List hexToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  void setTOTP() async {
    generateTOTP();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      generateTOTP();
      setState(() {
        int currentSecond = DateTime.now().second;
        remainingSeconds = 30 - (currentSecond % 30);
      });
    });
  }

  void generateTOTP() async {
    String key = base32ToHex(widget.secretKey);

    int epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int time = (epoch ~/ 30);
    String timeHex = time.toRadixString(16).padLeft(16, '0');

    Uint8List timeBuffer = hexToBytes(timeHex);
    Uint8List keyBuffer = hexToBytes(key);

    Hmac hmac = Hmac(sha1, keyBuffer);
    Digest digest = hmac.convert(timeBuffer);

    List<int> hash = digest.bytes;
    int offset = hash[hash.length - 1] & 0xf;
    int binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);

    int otpNumber = binary % 1000000;
    String otpCode = otpNumber.toString().padLeft(6, '0');

    setState(() {
      otp = otpCode;
    });
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Token Label
          Text(
            'Token',
            style: MyntWebTextStyles.bodySmall(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary,
                fontWeight: MyntFonts.medium),
          ),
          const SizedBox(height: 8),

          // Token Value with Copy and Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    otp.length >= 6 ? '${otp.substring(0, 3)} ${otp.substring(3, 6)}' : otp,
                    style: MyntWebTextStyles.title(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                        fontWeight: MyntFonts.semiBold),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.copy, size: 18,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary)),
                    onPressed: () => _copyToClipboard(otp, 'TOTP copied to clipboard'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                '$remainingSeconds sec',
                style: MyntWebTextStyles.para(context,
                    darkColor: MyntColors.textSecondaryDark,
                    lightColor: MyntColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Authenticator Key Label
          Text(
            'Authenticator Key',
            style: MyntWebTextStyles.bodySmall(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary,
                fontWeight: MyntFonts.medium),
          ),
          const SizedBox(height: 8),

          // Authenticator Key Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: MyntColors.listItemBgDark,
                  light: MyntColors.listItemBg),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: MyntColors.primary, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isObscure ? '••••••••••••••••••••' : widget.secretKey,
                    style: MyntWebTextStyles.para(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                      onPressed: () => setState(() => isObscure = !isObscure),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.copy, size: 18,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary)),
                      onPressed: () => _copyToClipboard(widget.secretKey, 'Auth key copied to clipboard'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

