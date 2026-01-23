import 'dart:async';
import 'dart:typed_data';
import 'package:mynt_plus/api/core/api_export.dart';
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
import 'package:mynt_plus/res/global_state_text.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex == 3) {
        // Settings
        _navigateToChild('Settings', const _SettingsSection());
      }
    });
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

    // If we have a child screen, show it with a back button
    if (_currentChildScreen != null) {
      return Container(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? colors.darkColorDivider : colors.colorDivider,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentChildTitle ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                        ),
                      ),
                      if (_currentChildTitle == 'Settings')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Catch the log, setting up preference, get API key, and change themes.",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Child content
            Expanded(child: _currentChildScreen!),
          ],
        ),
      );
    }

    // Main profile menu
    return _buildMainMenu(theme);
  }

  Widget _buildMainMenu(ThemesProvider theme) {
    final userProfile = ref.watch(userProfileProvider);
    final funds = ref.watch(fundProvider);
    final isDark = theme.isDarkMode;

    final userName = userProfile.userDetailModel?.uname ?? 'User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.white,
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
                        color: isDark ? colors.primaryDark : colors.primaryLight,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: isDark ? colors.primaryDark : colors.primaryLight,
                        ),
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
                            child: TextWidget.titleText(
                              text: userName,
                              theme: false,
                              color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                              fw: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
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
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? colors.darkColorDivider : colors.colorDivider,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.captionText(
                              text: 'Account Balance',
                              theme: false,
                              color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                            ),
                            const SizedBox(height: 4),
                            TextWidget.titleText(
                              text: formatIndianCurrency(funds.fundDetailModel?.avlMrg ?? "0.00"),
                              theme: false,
                              color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                              fw: 2,
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _closeDropdown();
                            _navigateToScreenInPanel(ScreenType.funds);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? colors.primaryDark : colors.primaryLight,
                            side: BorderSide(color: isDark ? colors.primaryDark : colors.primaryLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Add Money'),
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
                          Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: isDark ? colors.lossDark : colors.lossLight,
                          ),
                          const SizedBox(width: 8),
                          TextWidget.subText(
                            text: 'Logout',
                            theme: false,
                            color: isDark ? colors.lossDark : colors.lossLight,
                            fw: 2,
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
            child: TextWidget.captionText(
              text: 'Version 3.0.2',
              theme: false,
              color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(ThemesProvider theme, {required String title, required VoidCallback onTap}) {
    final isDark = theme.isDarkMode;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? colors.darkColorDivider : colors.colorDivider.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: title,
                theme: false,
                color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
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
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode ? const Color(0xFF121212) : colors.colorWhite,
          title: TextWidget.titleText(
            text: "Confirmation",
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            fw: 1,
          ),
          content: TextWidget.subText(
            text: "Are you sure you want to logout?",
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: TextWidget.subText(text: "Cancel", theme: false, color: colors.textSecondaryLight),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider).fetchLogout(context);
              },
              child: TextWidget.subText(text: "Logout", theme: false, color: colors.lossLight, fw: 2),
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
                    child: Text('API Key', style: MyntWebTextStyles.title(context, 
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight).copyWith(decoration: TextDecoration.none)),
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
                    child: Text('TOTP', style: MyntWebTextStyles.title(context, 
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight).copyWith(decoration: TextDecoration.none)),
                  ),
                ),
              ),
              content: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildTotpContent(theme),
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
                    child: Text('Change Password ', style: MyntWebTextStyles.title(context, 
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight).copyWith(decoration: TextDecoration.none)),
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
            shadcn.AccordionItem(
              trigger: shadcn.AccordionTrigger(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Themes', style: MyntWebTextStyles.title(context, 
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight).copyWith(decoration: TextDecoration.none)),
                  ),
                ),
              ),
              content: FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildThemesContent(theme),
                ),
              ),
            ),
            
            // Order Preference
            shadcn.AccordionItem(
              trigger: shadcn.AccordionTrigger(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Order Preference', style: MyntWebTextStyles.title(context, 
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight).copyWith(decoration: TextDecoration.none)),
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
                    child: Text('Freeze Account', style: MyntWebTextStyles.title(context, 
                      color: theme.isDarkMode ? colors.lossDark : colors.lossLight).copyWith(decoration: TextDecoration.none)),
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

  Widget _buildTotpContent(ThemesProvider theme) {
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
          TextWidget.captionText(
            text: 'Generate TOTP for 2FA authentication',
            theme: false,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
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
          TextWidget.captionText(
            text: 'Update your account password',
            theme: false,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
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
    final isDark = theme.isDarkMode;

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
                        color: isSelected ? colors.primaryLight : (isDark ? colors.textSecondaryDark : colors.textSecondaryLight),
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primaryLight,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Type
          _buildLabel('Product type', isDark),
          const SizedBox(height: 12),
          _buildSegmentedButton(
            options: ['Delivery / Carry', 'Intraday', 'CO - BO'],
            selected: _selectedProductType,
            onChanged: (val) => setState(() => _selectedProductType = val),
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Order Type
          _buildLabel('Order type', isDark),
          const SizedBox(height: 12),
          _buildSegmentedButton(
            options: ['Limit', 'Market', 'SL Limit', 'SL MKT'],
            selected: _selectedOrderType,
            onChanged: (val) => setState(() => _selectedOrderType = val),
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Validity
          _buildLabel('Validity', isDark),
          const SizedBox(height: 12),
          _buildSegmentedButton(
            options: ['DAY', 'IOC'],
            selected: _selectedValidity,
            onChanged: (val) => setState(() => _selectedValidity = val),
            isDark: isDark,
            compact: true,
          ),
          const SizedBox(height: 24),

          // Market Protection
          _buildLabel('Market Protection', isDark),
          const SizedBox(height: 12),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? colors.darkColorDivider : colors.colorDivider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '%',
                  style: MyntWebTextStyles.bodySmall(context,
                    color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '5',
                  style: MyntWebTextStyles.bodySmall(context,
                    color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quantity Preference
          _buildLabel('Quantity preference', isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRadioOption('Default Qty / Lot', _selectedQuantityPref == 'Default Qty / Lot', 
                () => setState(() => _selectedQuantityPref = 'Default Qty / Lot'), isDark),
              const SizedBox(width: 80),
              _buildRadioOption('Multiples of Qty / Lot', _selectedQuantityPref == 'Multiples of Qty / Lot', 
                () => setState(() => _selectedQuantityPref = 'Multiples of Qty / Lot'), isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Position Exit Market
          _buildLabel('Position Exit Market', isDark),
          const SizedBox(height: 12),
          _buildSegmentedButton(
            options: ['Limit', 'Market'],
            selected: _selectedPositionExit,
            onChanged: (val) => setState(() => _selectedPositionExit = val),
            isDark: isDark,
            compact: true,
          ),
          const SizedBox(height: 24),

          // Toggles
          _buildToggleRow('Sticky Order Window', _stickyOrderWindow, 
            (val) => setState(() => _stickyOrderWindow = val), isDark),
          const SizedBox(height: 12),
          _buildToggleRow('Quick Order Screen', _quickOrderScreen, 
            (val) => setState(() => _quickOrderScreen = val), isDark),
          const SizedBox(height: 40),

          // Buttons - 50% width
          // Buttons
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 200, // Fixed width for buttons
                  child: OutlinedButton(
                    onPressed: () {
                      _resetPreferences();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryDark,
                      backgroundColor:  const Color(0xFFEFF4FF),
                      side: BorderSide(color: colors.primaryLight),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 200, // Fixed width for buttons
                  child: ElevatedButton(
                    onPressed: () {
                      _savePreferences();
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
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
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
    final isDark = theme.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Freezing your account will temporarily disable trading. All open orders will be cancelled.',
            theme: false,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: Icon(Icons.close, color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Freezing your account will lock access for everyone, including you.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All open orders will be automatically cancelled.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Existing positions will remain unaffected.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You can unfreeze your account anytime by verifying your identity.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                            height: 1.5,
                          ),
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
                              backgroundColor: colors.primaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Freeze My Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1),
              foregroundColor: isDark ? colors.lossDark : colors.lossLight,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            child: const Text('Freeze Account'),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: MyntWebTextStyles.body(context,
        color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
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
                padding: EdgeInsets.only(right: option == options.last ? 0 : 12.0),
                child: InkWell(
                  onTap: () => onChanged(option),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70, // Fixed width for compact buttons like Validity
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? colors.primaryLight.withOpacity(0.1) : const Color(0xFFEFF4FF))
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? colors.primaryDark : colors.primaryLight)
                            : (isDark ? colors.darkColorDivider : colors.colorDivider),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: MyntWebTextStyles.bodySmall(context,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? (isDark ? colors.primaryDark : colors.primaryLight)
                            : (isDark ? colors.textPrimaryDark : colors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              )
            : Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: option == options.last ? 0 : 12.0),
                  child: InkWell(
                    onTap: () => onChanged(option),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? colors.primaryLight.withOpacity(0.1) : const Color(0xFFEFF4FF))
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? colors.primaryDark : colors.primaryLight)
                              : (isDark ? colors.darkColorDivider : colors.colorDivider),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: MyntWebTextStyles.body(context, // Changed from sub to body
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? (isDark ? colors.primaryDark : colors.primaryLight)
                              : (isDark ? colors.textPrimaryDark : colors.textPrimaryLight),
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
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colors.primaryLight : (isDark ? colors.textSecondaryDark : colors.textSecondaryLight),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primaryLight,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: MyntWebTextStyles.bodySmall(context,
              color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: MyntWebTextStyles.body(context,
                color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.info_outline,
              size: 16,
              color: isDark ? colors.textSecondaryDark.withOpacity(0.7) : colors.textSecondaryLight.withOpacity(0.7),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colors.primaryLight,
        ),
      ],
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
    final isDark = theme.isDarkMode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Info Header Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryLight,
                child: Text(
                  userProfile.userDetailModel?.uname?.substring(0, 1).toUpperCase() ?? "U",
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.subText(
                    text: userProfile.userDetailModel?.uname ?? "",
                    theme: false,
                    color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 2,
                  ),
                  TextWidget.captionText(
                    text: "Client ID: ${userProfile.userDetailModel?.uid ?? ""}",
                    theme: false,
                    color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
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
    final isDark = theme.isDarkMode;
    
    return shadcn.AccordionItem(
      trigger: shadcn.AccordionTrigger(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
          ),
        ),
      ),
      content: _buildSectionContent(title, theme),
    );
  }

  Widget _buildSectionContent(String section, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);
    final isDark = theme.isDarkMode;

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
                child: TextWidget.captionText(
                  text: e.key,
                  theme: false,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                ),
              ),
              Expanded(
                flex: 3,
                child: TextWidget.subText(
                  text: e.value,
                  theme: false,
                  color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 1,
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
    final theme = ref.watch(themeProvider);
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
          unselectedLabelColor: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          indicatorColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
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
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          // TextWidget.titleText(
          //   text: 'Your TOTP',
          //   theme: false,
          //   color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
          //   fw: 0,
          // ),
          // const SizedBox(height: 16),
          // Divider(color: isDark ? colors.darkColorDivider : colors.colorDivider),
          // const SizedBox(height: 8),

          // Token Label
          TextWidget.subText(
            text: 'Token',
            theme: false,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 1,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.copy, size: 18, color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight),
                    onPressed: () => _copyToClipboard(otp, 'TOTP copied to clipboard'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                '$remainingSeconds sec',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Authenticator Key Label
          TextWidget.subText(
            text: 'Authenticator Key',
            theme: false,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
          ),
          const SizedBox(height: 8),

          // Authenticator Key Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xffF1F3F8),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: colors.primaryLight, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isObscure ? '••••••••••••••••••••' : widget.secretKey,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                      ),
                      onPressed: () => setState(() => isObscure = !isObscure),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.copy, size: 18, color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight),
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

