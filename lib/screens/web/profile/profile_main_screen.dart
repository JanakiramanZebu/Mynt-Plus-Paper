// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/Mobile/profile_screen/topt_screen.dart';
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
                  IconButton(
                    onPressed: _navigateBack,
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 18,
                      color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextWidget.titleText(
                    text: _currentChildTitle ?? '',
                    theme: false,
                    color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 2,
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
class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsItem(
          context, theme,
          title: "Themes",
          subtitle: "Switch between Light and Dark mode",
          icon: Icons.brightness_6_outlined,
          onTap: () => _showThemeDialog(context, theme, ref),
        ),
        _buildSettingsItem(
          context, theme,
          title: "Change Password",
          subtitle: "Update your account password",
          icon: Icons.lock_outline,
          onTap: () {
            final pref = locator<Preferences>();
            ref.read(changePasswordProvider).userIdController.text = "${pref.clientId}";
            Navigator.pushNamed(context, Routes.changePass, arguments: "Yes");
          },
        ),
        _buildSettingsItem(
          context, theme,
          title: "Order Preference",
          subtitle: "Manage default order settings",
          icon: Icons.tune,
          onTap: () => Navigator.pushNamed(context, Routes.orderPrefer),
        ),
        _buildSettingsItem(
          context, theme,
          title: "Generate TOTP",
          subtitle: "Setup 2FA for your account",
          icon: Icons.security,
          onTap: () async {
            final apikeys = ref.read(apikeyprovider);
            await apikeys.fetchTotp();
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(16),
                  child: TotpScreen(secretKey: ref.read(apikeyprovider).totpkey!.pwd),
                ),
              ),
            );
          },
        ),
        _buildSettingsItem(
          context, theme,
          title: "API Keys",
          subtitle: "Manage your API access keys",
          icon: Icons.vpn_key_rounded,
          onTap: () async {
            final apikeys = ref.read(apikeyprovider);
            await apikeys.fetchapikey(context);
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
                  child: const ApiKeyBottomTabs(),
                ),
              ),
            );
          },
        ),
        _buildSettingsItem(
          context, theme,
          title: "Freeze Account",
          subtitle: "Temporarily disable your account",
          icon: Icons.ac_unit,
          isDestructive: true,
          onTap: () => _showFreezeDialog(context, theme, ref),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, ThemesProvider theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = theme.isDarkMode;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive
              ? (isDark ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1))
              : (isDark ? colors.textSecondaryDark.withOpacity(0.1) : colors.textSecondaryLight.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? (isDark ? colors.lossDark : colors.lossLight)
              : (isDark ? colors.textPrimaryDark : colors.textPrimaryLight),
        ),
      ),
      title: TextWidget.subText(
        text: title,
        theme: false,
        color: isDestructive
            ? (isDark ? colors.lossDark : colors.lossLight)
            : (isDark ? colors.textPrimaryDark : colors.textPrimaryLight),
        fw: 2,
      ),
      subtitle: TextWidget.captionText(
        text: subtitle,
        theme: false,
        color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemesProvider theme, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text("Choose Theme", style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: theme.themeTypes.map((t) => ListTile(
            title: Text(t, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black)),
            leading: Icon(Icons.circle, color: t == theme.deviceTheme ? colors.primaryLight : Colors.grey),
            onTap: () {
              theme.toggleTheme(themeMod: t);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showFreezeDialog(BuildContext context, ThemesProvider theme, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode ? const Color(0xFF1E1E1E) : colors.colorWhite,
          title: TextWidget.titleText(
            text: "Freeze Account",
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            fw: 1,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.subText(
                text: "Are you sure you want to freeze your account? Open orders will be cancelled.",
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(userProfileProvider).fetchFreezeAc(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.lossLight,
                foregroundColor: Colors.white,
              ),
              child: const Text("Freeze"),
            ),
          ],
        );
      },
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

  String? _expandedSection;

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

        // Sections
        ..._sections.map((section) => _buildExpansionTile(section, theme)).toList(),
      ],
    );
  }

  Widget _buildExpansionTile(String title, ThemesProvider theme) {
    final isExpanded = _expandedSection == title;
    final isDark = theme.isDarkMode;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? colors.darkColorDivider : colors.colorDivider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key(title),
          initiallyExpanded: isExpanded,
          iconColor: isDark ? colors.primaryDark : colors.primaryLight,
          collapsedIconColor: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
          title: TextWidget.subText(
            text: title,
            theme: false,
            color: isExpanded
                ? (isDark ? colors.primaryDark : colors.primaryLight)
                : (isDark ? colors.textPrimaryDark : colors.textPrimaryLight),
            fw: isExpanded ? 2 : 0,
          ),
          onExpansionChanged: (val) {
            if (val) {
              setState(() => _expandedSection = title);
              if (title == 'Profile' || title == 'Bank') {
                ref.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
              }
            } else {
              setState(() => _expandedSection = null);
            }
          },
          children: [
            _buildSectionContent(title, theme),
          ],
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.captionText(
                text: e.key,
                theme: false,
                color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
              const SizedBox(height: 4),
              TextWidget.subText(
                text: e.value,
                theme: false,
                color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 1,
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
