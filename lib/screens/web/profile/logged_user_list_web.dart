import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:html' as html;
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/ledger_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../utils/overlay_manager.dart';
import '../../Mobile/authentication/login/login_screen.dart';
import '../market_watch/tv_chart/chart_iframe_guard.dart';

class LoggedUserListWeb extends ConsumerStatefulWidget {
  final String initRoute;
  const LoggedUserListWeb({super.key, required this.initRoute});

  @override
  ConsumerState<LoggedUserListWeb> createState() => _LoggedUserListWebState();
}

class _LoggedUserListWebState extends ConsumerState<LoggedUserListWeb> {
  @override
  void initState() {
    super.initState();
    // Acquire chart iframe guard on init to prevent cursor bleed
    ChartIframeGuard.acquire();
    _disableAllChartIframes();
  }

  // Directly disable all chart iframes and reset cursor
  void _disableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'none';
          iframe.style.cursor = 'default';
        }
      }
      html.document.body?.style.cursor = 'default';
    } catch (e) {
    }
  }

  void _enableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'auto';
          iframe.style.cursor = '';
        }
      }
      html.document.body?.style.cursor = '';
    } catch (e) {
    }
  }

  @override
  void dispose() {
    // Release chart iframe guard and re-enable iframes
    ChartIframeGuard.release();
    _enableAllChartIframes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedUser = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider);

    final Preferences pref = locator<Preferences>();

    // Identify active and other accounts
    final activeAccount = loggedUser.loggedMobile.firstWhere(
      (acc) => acc.clientId == pref.clientId,
      orElse: () => loggedUser.loggedMobile.first,
    );
    final otherAccounts = loggedUser.loggedMobile
        .where((acc) => acc.clientId != pref.clientId)
        .toList();

    return PointerInterceptor(
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) {
          ChartIframeGuard.acquire();
          _disableAllChartIframes();
        },
        onHover: (_) {
          _disableAllChartIframes();
        },
        onExit: (_) {
          ChartIframeGuard.release();
          _enableAllChartIframes();
        },
        child: Listener(
          onPointerMove: (_) {
            _disableAllChartIframes();
          },
          child: GestureDetector(
            onTap: () {},
            child: Dialog(
      backgroundColor: theme.isDarkMode
          ? WebDarkColors.surface
          : WebColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Accounts',
                    style: WebTextStyles.dialogTitle(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.15)
                          : Colors.black.withOpacity(.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.08)
                          : Colors.black.withOpacity(.08),
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: theme.isDarkMode
                              ? WebDarkColors.iconSecondary
                              : WebColors.iconSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content area with padding
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 10, bottom: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Current Account ---
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? WebDarkColors.backgroundTertiary
                                : WebColors.backgroundTertiary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side with avatar and text
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.isDarkMode
                                        ? WebDarkColors.primary
                                        : WebColors.primary,
                                    radius: 20,
                                    child: Text(
                                      activeAccount.userName.isNotEmpty
                                          ? activeAccount.userName[0]
                                              .toUpperCase()
                                          : 'U',
                                      style: WebTextStyles.sub(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                        fontWeight: WebFonts.semiBold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activeAccount.userName,
                                        style: WebTextStyles.sub(
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.medium,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        activeAccount.clientId,
                                        style: WebTextStyles.para(
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textSecondary
                                              : WebColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Right side with logout button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (!context.mounted) return;
                                    
                                    // Add delay for visual feedback
                                    await Future.delayed(
                                        const Duration(milliseconds: 150));

                                    if (context.mounted) {
                                      _showLogoutDialog(context, ref, theme);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(.15)
                                      : Colors.black.withOpacity(.15),
                                  highlightColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(.08)
                                      : Colors.black.withOpacity(.08),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      "Log Out",
                                      style: WebTextStyles.sub(
                                        isDarkTheme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.tertiary
                                            : WebColors.tertiary,
                                        fontWeight: WebFonts.semiBold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (otherAccounts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const ListDivider(),
                        const SizedBox(height: 12),
                      ],

                      // --- Other Accounts List ---
                      if (otherAccounts.isNotEmpty)
                        ...otherAccounts.map((acc) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () async {
                                if (!context.mounted) return;
                                
                                // Close all open order/modify/GTT dialogs when switching accounts
                                OverlayManager.closeAll();

                                if (!context.mounted) return;
                                Navigator.pop(context);
                                
                                if (!context.mounted) return;
                                userProfile.profileloaderfun(true);
                                ref.read(ledgerProvider).clearCalendarPnLData();
                                ref.read(fundProvider).clearFunds();

                                userProfile.clearUserData();

                                final websocket = ref.read(websocketProvider);
                                websocket.closeSocket(true);

                                pref.setClientId(acc.clientId);
                                pref.setClientMob(acc.mobile);
                                pref.setClientSession(acc.sesstion);
                                pref.setClientName(acc.userName);
                                pref.setImei(acc.imei);
                                pref.setMobileLogin(true);

                                if (context.mounted) {
                                  await ref.read(authProvider).fetchMobileLogin(
                                        context,
                                        "",
                                        acc.clientId,
                                        "switchAc",
                                        acc.imei,
                                        true,
                                      );
                                }

                                if (context.mounted) {
                                  websocket.changeconnectioncount();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: theme.isDarkMode
                                        ? WebDarkColors.border
                                        : WebColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left side with avatar and text
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: theme.isDarkMode
                                                ? WebDarkColors.backgroundTertiary
                                                : WebColors.backgroundTertiary,
                                            radius: 20,
                                            child: Text(
                                              acc.userName.isNotEmpty
                                                  ? acc.userName[0]
                                                      .toUpperCase()
                                                  : 'U',
                                              style: WebTextStyles.sub(
                                                isDarkTheme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? WebDarkColors.textPrimary
                                                    : WebColors.textPrimary,
                                                fontWeight: WebFonts.semiBold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                acc.userName,
                                                style: WebTextStyles.sub(
                                                  isDarkTheme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? WebDarkColors.textPrimary
                                                      : WebColors.textPrimary,
                                                  fontWeight: WebFonts.medium,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                acc.clientId,
                                                style: WebTextStyles.para(
                                                  isDarkTheme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? WebDarkColors.textSecondary
                                                      : WebColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right side with remove button
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          if (!context.mounted) return;
                                          
                                          final originalIndex = loggedUser
                                              .loggedMobile
                                              .indexWhere((element) =>
                                                  element.clientId ==
                                                  acc.clientId);
                                          if (originalIndex != -1 && context.mounted) {
                                            loggedUser.removeUsers(
                                                acc, originalIndex, context);
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        splashColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(.15)
                                            : Colors.black.withOpacity(.15),
                                        highlightColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(.08)
                                            : Colors.black.withOpacity(.08),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            "Remove",
                                            style: WebTextStyles.sub(
                                              isDarkTheme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? WebDarkColors.tertiary
                                                  : WebColors.tertiary,
                                              fontWeight: WebFonts.semiBold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),

            // --- Add Account Button ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    if (!context.mounted) return;
                    
                    ref.read(orderProvider).clearAllorders();
                    ref.read(ledgerProvider).setterfornullallSwitch = null;
                    pref.setMobileLogin(true);
                    pref.setLogout(false);
                    ref.watch(websocketProvider).closeSocket(true);

                    loggedUser.addClient(false);
                    loggedUser.clearError();
                    loggedUser.loginMethCtrl.clear();
                    ref.read(authProvider).switchbackbutton(false);

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PopScope(
                            canPop: true,
                            onPopInvokedWithResult: (didPop, result) async {
                              if (didPop && context.mounted) {
                                ref
                                    .read(websocketProvider)
                                    .changeconnectioncount();
                                if (context.mounted) {
                                  ref
                                      .read(indexListProvider)
                                      .bottomMenu(4, context);
                                }
                              }
                            },
                            child: const LoginScreen(),
                          ),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(0, 45),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  child: Text(
                    "Add account",
                    style: WebTextStyles.buttonMd(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, WidgetRef ref, ThemesProvider theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: theme.isDarkMode
              ? WebDarkColors.surface
              : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Logout',
                        style: WebTextStyles.dialogTitle(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16, top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Are you sure you want to logout?",
                            style: WebTextStyles.dialogContent(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: Colors.white.withOpacity(0.2),
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  onTap: () async {
                                    // Capture provider ref before dialog
                                    // dismissal to avoid using WidgetRef
                                    // after the widget unmounts.
                                    final authProviderRef =
                                        ref.read(authProvider);
                                    Navigator.of(dialogContext).pop();
                                    if (!context.mounted) return;
                                    await authProviderRef
                                        .fetchLogout(context);
                                  },
                                  child: Center(
                                    child: Text(
                                      'Logout',
                                      style: WebTextStyles.buttonMd(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
