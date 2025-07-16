// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/screens/profile_screen/topt_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/api_key_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/bonds_provider.dart';
import '../../provider/change_password_provider.dart';
import '../../provider/fund_provider.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/ledger_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/profile_all_details_provider.dart';
import '../../provider/thems.dart';
import '../../provider/transcation_provider.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import 'Api_key_screen.dart';
import 'logged_user_bottom_sheet.dart';
import 'need_help_screen.dart';

class UserAccountScreen extends ConsumerWidget {
  const UserAccountScreen({super.key});

  String _truncateProfileName(String text, {int maxLength = 18}) {
    return (text.length > maxLength)
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  // Helper method to prevent double-tap issues
  bool _canTap() {
    final now = DateTime.now();
    if (now.difference(_lastTapTime).inMilliseconds < 500) {
      return false;
    }
    _lastTapTime = now;
    return true;
  }

  static DateTime _lastTapTime = DateTime.now();

  String formatIndianCurrency(String amount) {
    final formatter = NumberFormat.currency(
      locale: "en_IN",
      symbol: '', // Or '₹'
      decimalDigits: 2, // Always show 2 decimals
    );
    return formatter.format(double.tryParse(amount) ?? 0.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider);
    final trancation = ref.watch(transcationProvider);
    final mf = ref.watch(mfProvider);
    final reportsprovider = ref.watch(ledgerProvider);
    final funds = ref.watch(fundProvider);
    final auth = ref.watch(authProvider);
    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";

    final filteredMenu = [
      {'title': 'Account Balance', 'type': 'balance'},
      {'title': 'Reports'},
      // {'title': 'Account'},
      {'title': 'Settings'},
      {'title': 'Notification'},
      {'title': 'Refer'},
      {'title': 'Rate Us'},
      {'title': 'Contact'},
    ];

    return TransparentLoaderScreen(
      isLoading: userProfile.profileloader,
      child: Column(
        children: [
          const SizedBox(height: 50),

          /// 🔹 Top: QR Code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.highlightDark
                        : colors.highlightLight,
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          builder: (_) => const LoggedUserBottomSheet(
                              initRoute: 'switchAcc'));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        assets.switch2Icon,
                        height: 24,
                        width: 24,
                        color: colors.colorGrey,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  icon: SvgPicture.asset(
                    assets.qrIcon, // This is your asset path
                    height: 20,
                    width: 20,
                    color: colors
                        .colorGrey, // Optional: set color if your SVG supports it
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.qrscanner);
                  },
                ),
              ],
            ),
          ),

          /// 🔹 Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              // shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F3F8),
                        border: Border.all(
                          color: const Color(0xFF0037B7),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: TextWidget.custmText(
                          text: userProfile.userDetailModel?.uname
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              "",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : const Color(0xff0037B7),
                          fs: 40,
                          fw: 3,
                        ),
                      ),
                    ),
                  ),
                  IntrinsicWidth(
                    child: Container(
                      child: Material(
                        color: Colors.transparent,
                        // borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () async {
                            // Add delay for visual feedback
                            await Future.delayed(
                                const Duration(milliseconds: 150));

                            if (context.mounted) {
                              Navigator.pushNamed(
                                  context, Routes.myaccountScreen);
                            }
                          },
                          // borderRadius: BorderRadius.circular(10),
                          splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWidget.heroText(
                                    text: _truncateProfileName((userProfile
                                                .userDetailModel?.uname ??
                                            "")
                                        .toLowerCase()
                                        .split(' ')
                                        .map((word) => word.isNotEmpty
                                            ? '${word[0].toUpperCase()}${word.substring(1)}'
                                            : '')
                                        .join(' ')),
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 1),
                                const SizedBox(width: 8),
                                Transform.rotate(
                                  angle: 0 * 3.1416 / 180,
                                  child: userProfile.userDetailModel?.uname
                                              ?.isNotEmpty ??
                                          false
                                      ? Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                          color: !theme.isDarkMode
                                              ? colors.textPrimaryLight
                                              : colors.textPrimaryDark,
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16,16,16,0),
          //   child: Divider(
          //    height: 2,
          //    color: colors.fundbuttonBg,
          //                    ),
          // ),
          // const SizedBox(height: 4),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Divider(
          //     color: colors.fundbuttonBg, // Optional: customize the color
          //     thickness: 1, // Optional: customize the thickness
          //   ),
          // ),

          /// 🔹 Horizontal Buttons (inline style)
          // _buildHorizontalButtons(context, ref, theme, funds, mf),

          /// 🔹 Menu List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 0),
              itemCount: filteredMenu.length,
              itemBuilder: (context, index) {
                final item = filteredMenu[index];
                final title = item['title']!;
                final type = item['type'];

                // Handle account balance section
                if (type == 'balance') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        ListDivider(),
                        _buildAccountBalanceSection(
                            context, ref, theme, funds, trancation),
                      ],
                    ),
                  );
                }

                return ListTile(
                  minTileHeight: 60,
                  onTap: () async {
                    // Prevent double-tap issues
                    // if (!_canTap()) return;

                    if ([
                      "Verified P&L",
                      "Corporate Action",
                      "CA Events",
                      "Pledge & Unpledge",
                      "OptionZ"
                    ].contains(title)) {
                      await funds.fetchHstoken(context);
                    }
                    switch (title) {
                      case "Account Balance":
                        // This is not a clickable item, just return
                        return;
                      // case "Account":
                      //   Navigator.pushNamed(context, Routes.myaccountScreen);
                      //   break;
                      case "Reports":
                        if (reportsprovider.ledgerAllData == null) {
                          await reportsprovider.getCurrentDate('else');
                          reportsprovider.fetchLegerData(
                              context,
                              reportsprovider.startDate,
                              reportsprovider.endDate);
                        }
                        if (reportsprovider.holdingsAllData == null) {
                          await reportsprovider.getCurrentDate('else');
                          reportsprovider.fetchholdingsData(
                              reportsprovider.today, context);
                        }
                        if (reportsprovider.pnlAllData == null) {
                          await reportsprovider.getCurrentDate('else');
                          reportsprovider.fetchpnldata(
                              context,
                              reportsprovider.startDate,
                              reportsprovider.today,
                              true);
                        }
                        if (reportsprovider.calenderpnlAllData == null) {
                          await reportsprovider.getCurrentDate('else');
                          reportsprovider.calendarProvider();
                          reportsprovider.fetchcalenderpnldata(
                              context,
                              reportsprovider.startDate,
                              reportsprovider.today,
                              'Equity');
                        }
                        if (reportsprovider.taxpnldercomcur == null &&
                            reportsprovider.taxpnleq == null) {
                          await reportsprovider.getYearlistTaxpnl();
                          await reportsprovider.getCurrentDate('');
                          reportsprovider.fetchtaxpnleqdata(
                              context, reportsprovider.yearforTaxpnl);
                          reportsprovider.taxpnlExTabchange(0);
                          reportsprovider.chargesforeqtaxpnl(
                              context, reportsprovider.yearforTaxpnl);
                        }
                        if (reportsprovider.tradebookdata == null) {
                          await reportsprovider.getCurrentDate('tradebook');
                          reportsprovider.fetchtradebookdata(context,
                              reportsprovider.startDate, reportsprovider.today);
                        }
                        if (reportsprovider.pdfdownload == null) {
                          await reportsprovider.getCurrentDate('else');
                          reportsprovider.fetchpdfdownload(context,
                              reportsprovider.startDate, reportsprovider.today);
                        }
                        await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ReportsScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              final slideTween = Tween(
                                begin: const Offset(
                                    -1.0, 0.0), // Slide in from right
                                end: Offset.zero,
                              ).chain(CurveTween(
                                  curve:
                                      Curves.easeOutQuart)); // Optional curve

                              return SlideTransition(
                                position: animation.drive(slideTween),
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 180),
                          ),
                        );
                        break;
                      case "IPO":
                        Navigator.pushNamed(context, Routes.ipo);
                        break;
                      case "Mutual Fund":
                        mf.mfApicallinit(context, 0);
                        break;
                      case "Bonds":
                        await ref.read(bondsProvider).fetchAllBonds();
                        Navigator.pushNamed(context, Routes.bonds);
                        break;
                      case "OptionZ":
                        funds.optionZ(context);
                        break;
                      case "Refer":
                        await Share.share(
                          "Get 20% of brokerage for trades made by your friends.\n ${Uri.parse(reflink)}",
                        );
                        break;
                      case "Settings":
                        await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SettingsScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              final slideTween = Tween(
                                begin: const Offset(
                                    -1.0, 0.0), // Slide in from right
                                end: Offset.zero,
                              ).chain(CurveTween(
                                  curve:
                                      Curves.easeOutQuart)); // Optional curve

                              return SlideTransition(
                                position: animation.drive(slideTween),
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 180),
                          ),
                        );

                        break;
                      case "Rate Us":
                        if (TargetPlatform.iOS == defaultTargetPlatform) {
                          String iosUrl =
                              "https://apps.apple.com/app/id6478270319?action=write-review";
                          await launch(iosUrl);
                        } else {
                          String marketUrl =
                              "market://details?id=com.mynt.trading_app_zebu";
                          String webUrl =
                              "https://play.google.com/store/apps/details?id=com.mynt.trading_app_zebu";

                          try {
                            bool canLaunchMarket = await canLaunch(marketUrl);
                            if (canLaunchMarket) {
                              await launch(marketUrl);
                            } else {
                              await launch(webUrl);
                            }
                          } catch (e) {
                            await launch(webUrl);
                          }
                        }
                        break;
                      case "Contact":
                        showModalBottomSheet(
                          useSafeArea: true,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
                          context: context,
                          builder: (context) {
                            return const NeedHelpScreen();
                          },
                        );
                        break;
                      case "Notification":
                        Navigator.pushNamed(context, Routes.notificationpage);
                        break;
                    }
                  },
                  title: TextWidget.subText(
                    text: title,
                    theme: false,
                    color: !theme.isDarkMode
                        ? colors.textSecondaryLight
                        : colors.textSecondaryDark,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: !theme.isDarkMode
                        ? colors.textSecondaryLight
                        : colors.textSecondaryDark,
                  ),
                );
              },
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ListDivider(),
              ),
            ),
          ),

          /// 🔹 Version
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextWidget.captionText(
                text: auth.versiontext,
                theme: false,
                color: !theme.isDarkMode
                    ? colors.textSecondaryLight
                    : colors.textSecondaryDark,
                fw: 0),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAccountBalanceSection(
      BuildContext context, WidgetRef ref, theme, funds, trancation) {
    return Column(
      children: [
        ListTile(
          minTileHeight: 60,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  // Add delay for visual feedback
                  await Future.delayed(const Duration(milliseconds: 150));

                  ref.read(portfolioProvider).changeTabIndex(3);
                  ref.read(indexListProvider).bottomMenu(2, context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                        text: "Account Balance",
                        theme: false,
                        color: !theme.isDarkMode
                            ? colors.textPrimaryLight
                            : colors.textPrimaryDark,
                      ),
                      const SizedBox(height: 4),
                      TextWidget.subText(
                        text: formatIndianCurrency(
                            funds.fundDetailModel?.avlMrg ?? "0.00"),
                        theme: false,
                        color: !theme.isDarkMode
                            ? colors.textSecondaryLight
                            : colors.textSecondaryDark,
                      ),
                    ],
                  ),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: colors.fundbuttonBg,
                  side: BorderSide(
                    color: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {   
                  // await trancation.fetchValidateToken(context);
                  // Future.delayed(
                  //   const Duration(milliseconds: 100),
                  //   () async {
                  //     await trancation.ip();
                  //     await trancation.fetchupiIdView(
                  //       trancation.bankdetails!.dATA![trancation.indexss][1],
                  //       trancation.bankdetails!.dATA![trancation.indexss][2],
                  //     );
                  //     await trancation.fetchcwithdraw(context);
                  //   },
                  // );
                  trancation.changebool(true);
                  Navigator.pushNamed(context, Routes.fundscreen,
                      arguments: trancation);
                },
                child: TextWidget.subText(
                  text: "Add Fund",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight,
                  fw: 2,
                  align: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // ListDivider(),
      ],
    );
  }

  Widget _buildHorizontalButtons(
      BuildContext context, WidgetRef ref, theme, funds, mf) {
    final buttons = [
      {
        'title': 'Mutual Fund',
        'icon': assets.mfIcon,
        'onTap': () => mf.mfApicallinit(context, 0)
      },
      {
        'title': 'IPO',
        'icon': assets.ipoIcon,
        'onTap': () => Navigator.pushNamed(context, Routes.ipo)
      },
      {
        'title': 'Bond',
        'icon': assets.bondIcon,
        'onTap': () async {
          await ref.read(bondsProvider).fetchAllBonds();
          Navigator.pushNamed(context, Routes.bonds);
        }
      },
      {
        'title': 'OptionZ',
        'icon': assets.optionZIcon,
        'onTap': () async {
          await funds.fetchHstoken(context);
          funds.optionZ(context);
        }
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons.map(
          (button) {
            return InkWell(
              onTap: button['onTap'] as VoidCallback,
              child: Row(
                children: [
                  SvgPicture.asset(button['icon'] as String,
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue,
                      width: 14),
                  const SizedBox(width: 8),
                  TextWidget.subText(
                      text: button['title'] as String,
                      theme: false,
                      color: !theme.isDarkMode
                          ? colors.colorBlue
                          : colors.colorBlue,
                      fw: 0,
                      align: TextAlign.center),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends ConsumerWidget {
  String _truncateProfileName(String text, {int maxLength = 18}) {
    return (text.length > maxLength)
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider);
    final Preferences pref = locator<Preferences>();
    final apikeys = ref.read(apikeyprovider);

    final settingsItems = [
      // {'title': 'Theme', 'section': 'Settings'},
      // {'title': 'Order Preference', 'section': 'Security'},
    ];

    final securityItems = [
      {'title': 'Change Password', 'section': 'Security'},
      {'title': 'Order Preference', 'section': 'Settings'},
      {'title': 'Generate TOTP', 'section': 'Security'},
      {'title': 'Generate API Key', 'section': 'Security'},
      {'title': 'Freeze Account', 'section': 'Security'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 48,
        titleSpacing: 0,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.grey.withOpacity(0.4),
            highlightColor: Colors.grey.withOpacity(0.2),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 44, // Increased touch area
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 18,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ),
        ),
        title: TextWidget.titleText(
          text: "Settings",
          theme: false,
          color: !theme.isDarkMode
              ? colors.textPrimaryLight
              : colors.textPrimaryDark,
          fw: 1,
        ),
        // actions: [
        //   IconButton(
        //     splashRadius: 20,
        //     icon: SvgPicture.asset(
        //       assets.qrIcon, // This is your asset path
        //       height: 20,
        //       width: 20,
        //       // Optional: set color if your SVG supports it
        //     ),
        //     onPressed: () {
        //       Navigator.pushNamed(context, Routes.qrscanner);
        //     },
        //   ),
        //   IconButton(
        //     splashRadius: 20,
        //     icon: SvgPicture.asset(
        //       assets.notifyIcon, // This is your asset path
        //       height: 20,
        //       width: 20,
        //       color: colors
        //           .colorGrey, // Optional: set color if your SVG supports it
        //     ),
        //     onPressed: () async {
        //       await ref.read(notificationprovider).fetchexchagemsg(context);
        //       await ref.read(notificationprovider).fetchbrokermsg(context);
        //       Navigator.pushNamed(context, Routes.notificationpage);
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          /// Profile Header
          ///  // showModalBottomSheet(
          //     context: context,
          //     isScrollControlled: true,
          //     isDismissible: true,
          //     shape: const RoundedRectangleBorder(
          //       borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(10),
          //         topRight: Radius.circular(10),
          //       ),
          //     ),
          //     builder: (_) =>
          //         const LoggedUserBottomSheet(initRoute: 'switchAcc'));
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Row(
          //     children: [
          //       CircleAvatar(
          //           radius: 24,
          //           backgroundColor: colors.fundbuttonBg,
          //           child: TextWidget.titleText(
          //             text: userProfile.userDetailModel?.uname
          //                     ?.substring(0, 1)
          //                     .toUpperCase() ??
          //                 "U",
          //             theme: false,
          //             color: theme.isDarkMode
          //                 ? colors.textPrimaryDark
          //                 : colors.textPrimaryLight,
          //             fw: 2,
          //           )),
          //       const SizedBox(width: 12),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           TextWidget.subText(
          //             text: _truncateProfileName(
          //                 userProfile.userDetailModel?.uname ?? ""),
          //             theme: false,
          //             color: theme.isDarkMode
          //                 ? colors.textPrimaryDark
          //                 : colors.textPrimaryLight,
          //             fw: 0,
          //           ),
          //           const SizedBox(height: 4),
          //           TextWidget.paraText(
          //             text: userProfile.userDetailModel?.uid ?? "",
          //             theme: false,
          //             color: colors.textSecondaryLight,
          //           )
          //         ],
          //       ),
          //       // const Spacer(),
          //       // Icon(Icons.arrow_forward_ios,
          //       //     size: 16, color: colors.colorGrey)
          //     ],
          //   ),
          // ),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: ListDivider(),
          // ),

          // const SizedBox(height: 12),

          // Settings Section

          // const SizedBox(height: 16),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: ListDivider(),
          // ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settingsItems.length,
            itemBuilder: (context, index) {
              final item = settingsItems[index];
              return ListTile(
                minTileHeight: 60,
                title: TextWidget.subText(
                  text: item['title']!,
                  theme: false,
                  color: !theme.isDarkMode
                      ? colors.textSecondaryLight
                      : colors.textSecondaryDark,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: !theme.isDarkMode
                      ? colors.textSecondaryLight
                      : colors.textSecondaryDark,
                ),
                onTap: () {
                  // Handle settings navigation
                  switch (item['title']) {
                    case 'Theme':
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: theme.isDarkMode
                                  ? const Color.fromARGB(255, 18, 18, 18)
                                  : colors.colorWhite,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                              scrollable: true,
                              actionsPadding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 14, top: 3),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              titlePadding: const EdgeInsets.only(left: 16),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget.titleText(
                                      text: "Choose theme",
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      fw: 1),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                    ),
                                    color: theme.isDarkMode
                                        ? const Color(0xffBDBDBD)
                                        : colors.colorGrey,
                                  )
                                ],
                              ),
                              content: SizedBox(
                                  height: 115,
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : colors.colorDivider,
                                            height: 0),
                                        const SizedBox(height: 10),
                                        ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: theme.themeTypes.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ListTile(
                                              onTap: () async {
                                                theme.toggleTheme(
                                                    themeMod: theme
                                                        .themeTypes[index]);
                                                Navigator.pop(context);
                                              },
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0,
                                                      vertical: 0),
                                              dense: true,
                                              minLeadingWidth: 22,
                                              leading: SvgPicture.asset(theme
                                                      .isDarkMode
                                                  ? theme.themeTypes[index] ==
                                                          theme.deviceTheme
                                                      ? assets
                                                          .darkActProductIcon
                                                      : assets.darkProductIcon
                                                  : theme.themeTypes[index] ==
                                                          theme.deviceTheme
                                                      ? assets.actProductIcon
                                                      : assets.productIcon),
                                              title: TextWidget.subText(
                                                  text: theme.themeTypes[index],
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? Color(theme.themeTypes[
                                                                  index] ==
                                                              theme.deviceTheme
                                                          ? 0xffffffff
                                                          : 0xff666666)
                                                      : Color(
                                                          theme.themeTypes[
                                                                      index] ==
                                                                  theme
                                                                      .deviceTheme
                                                              ? 0xff000000
                                                              : 0xff666666,
                                                        ),
                                                  fw: 0),
                                            );
                                          },
                                        )
                                      ])),
                            );
                          });
                      break;
                    // case 'Order Preference':
                    //   Navigator.pushNamed(context, Routes.orderPrefer);
                    //   break;
                  }
                },
              );
            },
            separatorBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color:
                    theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                thickness: 1,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListDivider(),
          ),
          // const SizedBox(height: 16),

          // Security Section
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Align(
          //     alignment: Alignment.centerLeft,
          //     child: TextWidget.titleText(
          //       text: "Security",
          //       theme: false,
          //       color:
          //           !theme.isDarkMode ? colors.textPrimaryLight : colors.textPrimaryDark,
          //       fw: 1,
          //     ),
          //   ),
          // ),

          // const SizedBox(height: 16),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child:ListDivider(),
          // ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: securityItems.length,
            itemBuilder: (context, index) {
              final item = securityItems[index];
              return ListTile(
                minTileHeight: 60,
                title: TextWidget.subText(
                  text: item['title']!,
                  theme: false,
                  color: !theme.isDarkMode
                      ? colors.textSecondaryLight
                      : colors.textSecondaryDark,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: !theme.isDarkMode
                      ? colors.textSecondaryLight
                      : colors.textSecondaryDark,
                ),
                onTap: () async {
                  // Handle security navigation
                  switch (item['title']) {
                    case 'Freeze Account':
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CustomDragHandler(),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget.titleText(
                                          text: 'Freeze Account',
                                          theme: false,
                                          color: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          fw: 1),
                                      Material(
                                        color: Colors.transparent,
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          onTap: () async {
                                            await Future.delayed(const Duration(
                                                milliseconds: 150));
                                            Navigator.of(context).pop();
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          splashColor: theme.isDarkMode
                                              ? colors.splashColorDark
                                              : colors.splashColorLight,
                                          highlightColor: theme.isDarkMode
                                              ? colors.highlightDark
                                              : colors.highlightLight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 22,
                                              color: theme.isDarkMode
                                                  ? const Color(0xffBDBDBD)
                                                  : colors.colorGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListDivider(),
                                const SizedBox(height: 16.0),
                                TextWidget.subText(
                                  text:
                                      "Account freeze notice: All open orders will be cancelled due to the freeze. Existing positions will remain open and will not be affected.",
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                ),
                                const SizedBox(height: 24.0),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        userProfile.fetchFreezeAc(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        //  minimumSize: const Size(0, 40),
                                        elevation: 0,
                                        backgroundColor: theme.isDarkMode
                                            ? colors.primaryDark
                                            : colors.primaryLight,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ),
                                      child: TextWidget.subText(
                                          text: "Freeze",
                                          theme: false,
                                          color: colors.colorWhite,
                                          fw: 2),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0)
                              ],
                            ),
                          );
                        },
                      );
                      break;
                    case 'Change Password':
                      ref.read(changePasswordProvider).userIdController.text =
                          "${pref.clientId}";
                      Navigator.pushNamed(context, Routes.changePass,
                          arguments: "Yes");
                      break;
                    case 'Order Preference':
                      Navigator.pushNamed(context, Routes.orderPrefer);
                      break;
                    case 'Generate API Key':
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          builder: (_) => ApiKeyScreen());
                      break;
                    case 'Generate TOTP':
                      await apikeys.fetchTotp();

                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          builder: (_) => TotpScreen(
                              secretKey:
                                  ref.read(apikeyprovider).totpkey!.pwd));
                      break;
                  }
                },
              );
            },
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListDivider(),
            ),
          ),

          const Spacer(),

          // Version
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextWidget.captionText(
              text: ref.watch(authProvider).versiontext,
              theme: false,
              color: !theme.isDarkMode
                  ? colors.textSecondaryLight
                  : colors.textSecondaryDark,
            ),
          ),
          SizedBox(height: 8.0)
        ],
      ),
      // bottomNavigationBar: buildBottomNav(4, theme, context, ref),
    );
  }

  // Widget buildBottomNav(int selectedTab, ThemesProvider theme,
  //     BuildContext context, WidgetRef ref) {
  //   final uid = ref.watch(userProfileProvider.select(
  //       (userProfile) => userProfile.userDetailModel?.uid?.toString() ?? ""));
  //   return BottomAppBar(
  //     height: 64,
  //     shadowColor:
  //         theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
  //     padding: EdgeInsets.zero,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         _buildBottomNavItem(
  //             1, assets.watchlistIcon, "Watchlists", selectedTab, theme,
  //             context: context, ref: ref),
  //         _buildBottomNavItem(
  //             2, assets.portfolioIcon, "Portfolio", selectedTab, theme,
  //             context: context, ref: ref),
  //         _buildBottomNavItem(
  //             3, assets.ordersIcon, "Orders", selectedTab, theme,
  //             context: context, ref: ref),
  //         _buildBottomNavItem(4, assets.profileIcon, uid, selectedTab, theme,
  //             useHeight: true, height: 18, context: context, ref: ref),
  //       ],
  //     ),
  //   );
  // }

  // Add this function
  // Widget _buildBottomNavItem(int index, String iconAsset, String label,
  //     int selectedIndex, ThemesProvider theme,
  //     {bool useHeight = false,
  //     double height = 24,
  //     required BuildContext context,
  //     required WidgetRef ref}) {
  //   final isSelected = selectedIndex == index;

  //   return Expanded(
  //     child: RepaintBoundary(
  //       child: InkWell(
  //         onTap: () {
  //           // Navigate to the corresponding screen
  //           switch (index) {
  //             case 1:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(1, context);
  //               break;
  //             case 2:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(2, context);
  //               break;
  //             case 3:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(3, context);
  //               break;
  //             case 4:
  //               // Already on profile screen
  //               break;
  //           }
  //         },
  //         child: Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 7),
  //           decoration: BoxDecoration(
  //               border: isSelected
  //                   ? Border(
  //                       top: BorderSide(
  //                           color: theme.isDarkMode
  //                               ? colors.colorLightBlue
  //                               : colors.colorBlue,
  //                           width: 2))
  //                   : null),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               useHeight
  //                   ? SvgPicture.asset(
  //                       iconAsset,
  //                       height: height,
  //                       color: _getBottomNavColor(theme, isSelected),
  //                     )
  //                   : SvgPicture.asset(
  //                       iconAsset,
  //                       color: _getBottomNavColor(theme, isSelected),
  //                     ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 label,
  //                 style: TextWidget.textStyle(
  //                     fontSize: 12,
  //                     color: _getBottomNavColor(theme, isSelected),
  //                     theme: theme.isDarkMode,
  //                     fw: isSelected ? 1 : 00),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Add this function
  Color _getBottomNavColor(ThemesProvider theme, bool isSelected) {
    if (theme.isDarkMode && isSelected) {
      return colors.colorLightBlue;
    } else if (isSelected) {
      return colors.colorBlue;
    } else {
      return colors.colorGrey;
    }
  }
}

// My Account Screen
class MyAccountScreen extends ConsumerStatefulWidget {
  const MyAccountScreen({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  ConsumerState<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends ConsumerState<MyAccountScreen> {
  // late int _expandedIndex;

  @override
  void initState() {
    super.initState();
    // _expandedIndex = widget.initialIndex; // ← store the target tile
  }

  String _truncateProfileName(String text, {int maxLength = 18}) {
    return (text.length > maxLength)
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  // Add this variable
  final selectedBtmIndx = 4;

  // // Add this function
  // Widget buildBottomNav(int selectedTab, ThemesProvider theme) {
  //   final uid = ref.watch(userProfileProvider.select(
  //       (userProfile) => userProfile.userDetailModel?.uid?.toString() ?? ""));
  //   return BottomAppBar(
  //     height: 64,
  //     shadowColor:
  //         theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
  //     padding: EdgeInsets.zero,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         _buildBottomNavItem(
  //             1, assets.watchlistIcon, "Watchlists", selectedTab, theme),
  //         _buildBottomNavItem(
  //             2, assets.portfolioIcon, "Portfolio", selectedTab, theme),
  //         _buildBottomNavItem(
  //             3, assets.ordersIcon, "Orders", selectedTab, theme),
  //         _buildBottomNavItem(4, assets.profileIcon, uid, selectedTab, theme,
  //             useHeight: true, height: 18),
  //       ],
  //     ),
  //   );
  // }

  // // Add this function
  // Widget _buildBottomNavItem(int index, String iconAsset, String label,
  //     int selectedIndex, ThemesProvider theme,
  //     {bool useHeight = false, double height = 24}) {
  //   final isSelected = selectedIndex == index;

  //   return Expanded(
  //     child: RepaintBoundary(
  //       child: InkWell(
  //         onTap: () {
  //           // Navigate to the corresponding screen
  //           switch (index) {
  //             case 1:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(1, context);
  //               break;
  //             case 2:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(2, context);
  //               break;
  //             case 3:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(3, context);
  //               break;
  //             case 4:
  //               // Already on profile screen
  //               break;
  //           }
  //         },
  //         child: Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 7),
  //           decoration: BoxDecoration(
  //               border: isSelected
  //                   ? Border(
  //                       top: BorderSide(
  //                           color: theme.isDarkMode
  //                               ? colors.colorLightBlue
  //                               : colors.colorBlue,
  //                           width: 2))
  //                   : null),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               useHeight
  //                   ? SvgPicture.asset(
  //                       iconAsset,
  //                       height: height,
  //                       color: _getBottomNavColor(theme, isSelected),
  //                     )
  //                   : SvgPicture.asset(
  //                       iconAsset,
  //                       color: _getBottomNavColor(theme, isSelected),
  //                     ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 label,
  //                 style: TextWidget.textStyle(
  //                     fontSize: 12,
  //                     color: _getBottomNavColor(theme, isSelected),
  //                     theme: theme.isDarkMode,
  //                     fw: isSelected ? 1 : 00),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Add this function
  Color _getBottomNavColor(ThemesProvider theme, bool isSelected) {
    if (theme.isDarkMode && isSelected) {
      return colors.colorLightBlue;
    } else if (isSelected) {
      return colors.colorBlue;
    } else {
      return colors.colorGrey;
    }
  }

  String? _expandedTitle;

  // List of items for the account screen
  final accountItems = [
    {'title': 'Profile'},
    {'title': 'Bank'},
    {'title': 'Depository'},
    {'title': 'Margin Trading Facility (MTF)'},
    {'title': 'Trading Preferences'},
    {'title': 'Nominee'},
    {'title': 'Form Download'},
    {'title': 'Closure'},
  ];

  // This method fetches data lazily when an expansion tile is opened
  void _onExpansionChanged(bool isExpanding, String title) {
    if (isExpanding) {
      // Expand the new tile
      setState(() {
        _expandedTitle = title;
      });

      // Lazy load data if needed
      if (title == 'Profile' || title == 'Bank') {
        ref.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
      }
    } else {
      // Prevent collapsing if it's the currently expanded one
      if (_expandedTitle == title) {
        setState(() {
          _expandedTitle = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        // title: TextWidget.subText(text: "My Accounts", theme: theme.isDarkMode, fw: 1),
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 48,
        titleSpacing: 0,
        leading: CustomBackBtn(),
        title: TextWidget.titleText(
          text: "Account",
          theme: false,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        // actions: [
        //   IconButton(
        //     splashRadius: 20,
        //     icon: SvgPicture.asset(
        //       assets.qrIcon, // This is your asset path
        //       height: 20,
        //       width: 20,
        //       color: colors
        //           .colorGrey, // Optional: set color if your SVG supports it
        //     ),
        //     onPressed: () => Navigator.pushNamed(context, Routes.qrscanner),
        //   ),
        //   IconButton(
        //     splashRadius: 20,
        //     icon: SvgPicture.asset(
        //       assets.notifyIcon, // This is your asset path
        //       height: 20,
        //       width: 20,
        //       color: colors
        //           .colorGrey, // Optional: set color if your SVG supports it
        //     ),
        //     onPressed: () async {
        //       await ref.read(notificationprovider).fetchexchagemsg(context);
        //       await ref.read(notificationprovider).fetchbrokermsg(context);
        //       Navigator.pushNamed(context, Routes.notificationpage);
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Header (retained from your original design)
            // const SizedBox(height: 10),
            // Row(
            //   children: [
            //     CircleAvatar(
            //       radius: 24,
            //       backgroundColor: colors.fundbuttonBg,
            //       child: Text(
            //         userProfile.userDetailModel?.uname
            //                 ?.substring(0, 1)
            //                 .toUpperCase() ??
            //             "U",
            //         style: const TextStyle(color: Colors.black),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         TextWidget.subText(
            //           fw: 0,
            //           text: _truncateProfileName(
            //               userProfile.userDetailModel?.uname ?? ""),
            //           theme: false,
            //           color: !theme.isDarkMode
            //               ? colors.colorBlack
            //               : colors.colorGrey,
            //         ),
            //         const SizedBox(height: 6),
            //         TextWidget.paraText(
            //           text: userProfile.userDetailModel?.uid ?? "",
            //           theme: false,
            //           color: theme.isDarkMode
            //               ? colors.textSecondaryDark
            //               : colors.textSecondaryLight,
            //         )
            //       ],
            //     ),
            //     // const Spacer(),
            //     // Icon(Icons.arrow_forward_ios,
            //     //     size: 16, color: colors.colorGrey)
            //   ],
            // ),
            // const SizedBox(height: 10),
            // Divider(
            //   color: colors.fundbuttonBg, // Optional: customize the color
            //   thickness: 1, // Optional: customize the thickness
            // ),
            // const SizedBox(height: 8),

            // const SizedBox(height: 10),
            // Divider(
            //   color: colors.fundbuttonBg, // Optional: customize the color
            //   thickness: 1, // Optional: customize the thickness
            // ),

            /// Expandable List View
            Expanded(
              child: ListView.separated(
                itemCount: accountItems.length,
                itemBuilder: (context, index) {
                  final item = accountItems[index];
                  final title = item['title']!;

                  return Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      dividerTheme: const DividerThemeData(
                        thickness: 0,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: _expandedTitle == title
                            ? theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight
                            : theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                        key: ValueKey('${title}_${_expandedTitle == title}'),
                        initiallyExpanded: _expandedTitle == title,
                        onExpansionChanged: (isExpanding) =>
                            _onExpansionChanged(isExpanding, title),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                        title: TextWidget.subText(
                          text: title,
                          theme: false,
                          color: _expandedTitle == title
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                          fw: _expandedTitle == title ? 0 : 3,
                        ),
                        children: [
                          // Dynamically build the content based on the title
                          _buildExpansionContent(title, ref, theme),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 0),
              ),
            ),

            /// Version Text
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 16),
                child: TextWidget.captionText(
                  text: ref.watch(authProvider).versiontext,
                  theme: false,
                  color: const Color(0xff666666),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      // bottomNavigationBar: buildBottomNav(selectedBtmIndx, theme),
    );
  }

  /// Helper to build the content inside each ExpansionTile
  Widget _buildExpansionContent(
      String title, WidgetRef ref, ThemesProvider theme) {
    switch (title) {
      case 'Profile':
        return _buildProfileDetailsContent(ref, theme);
      case 'Bank':
        return _buildBankDetailsContent(ref, theme);
      case 'Depository':
        return _buildDepositoryContent(ref, theme);
      case 'Margin Trading Facility (MTF)':
        return _buildMTFContent(ref, theme);
      case 'Trading Preferences':
        return _buildTradingPreferencesContent(ref, theme);
      case 'Nominee':
        return _buildNomineeContent(ref, theme);
      case 'Form Download':
        return _buildFormDownloadContent(ref, theme);
      case 'Closure':
        return _buildClosureContent(ref, theme);
      default:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextWidget.paraText(
            text: 'Details for $title will be shown here.',
            color: colors.colorGrey,
            theme: theme.isDarkMode,
          ),
        );
    }
  }

  /// Builds the UI for the "Profile" section, replicating ProfileInfoDetails
  Widget _buildProfileDetailsContent(WidgetRef ref, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);
    final clientData = profileDetails.clientAllDetails.clientData;

    // if (profileDetails.isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return Column(
      children: [
        _buildDetailRow("Name", clientData?.panName ?? "N/A", theme),
        _buildDetailRow("Email", clientData?.cLIENTIDMAIL ?? "N/A", theme),
        _buildDetailRow("Mobile", clientData?.mOBILENO ?? "N/A", theme),
        _buildDetailRow("PAN", clientData?.pANNO ?? "N/A", theme),
        // _buildDetailRow("DP ID", clientData?.cLIENTDPCODE ?? "N/A", theme),
      ],
    );
  }

  /// Builds the UI for the "Bank" section, replicating ProfileDetailsBank with proper functionality
  Widget _buildBankDetailsContent(WidgetRef ref, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);
    final bankData = profileDetails.clientAllDetails.bankData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Bank button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.subText(
                  text: "Bank Accounts Linked",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
                // SizedBox(height: 4),
                // TextWidget.paraText(
                //   text: "View bank details and add new banks.",
                //   theme: theme.isDarkMode,
                //   color: theme.isDarkMode
                //       ? colors.textSecondaryDark
                //       : colors.textSecondaryLight,
                // ),
                // SizedBox(height: 10),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  // Add delay for visual feedback
                  await Future.delayed(const Duration(milliseconds: 150));

                  profileDetails.openInWebURL(context, "manbank");
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.highlightDark
                    : colors.highlightLight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: colors.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Bank Cards
        if (bankData == null || bankData.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextWidget.paraText(
              text: "No bank accounts found.",
              theme: theme.isDarkMode,
              color: colors.textSecondaryLight,
            ),
          )
        else
          ...bankData.map((bank) {
            return Card(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: colors.colorDivider),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Bank Logo
                        CircleAvatar(
                          backgroundColor: colors.colorGrey,
                          radius: 20.5,
                          child: CircleAvatar(
                            backgroundColor: colors.colorWhite,
                            radius: 20,
                            child: SvgPicture.network(
                              "https://rekycbe.mynt.in/autho/banklogo?bank=${(bank.iFSCCode ?? "").substring(0, 4).toLowerCase()}&type=svg&t=${DateTime.now().millisecondsSinceEpoch}",
                              fit: BoxFit.contain,
                              height: 25,
                              placeholderBuilder: (context) => Icon(
                                Icons.account_balance,
                                color: colors.colorGrey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextWidget.subText(
                                      text: bank.bankName ?? "Unknown Bank",
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                    ),
                                  ),
                                  // SizedBox(height: 25.0),
                                ],
                              ),
                              TextWidget.paraText(
                                text:
                                    'A/C No: ${profileDetails.formateDataToDisplay(bank.bankAcNo ?? "", 2, 4)}',
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                              ),
                              SizedBox(height: 5.0),
                              TextWidget.paraText(
                                text: 'IFSC: ${bank.iFSCCode ?? "N/A"}',
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                              ),
                            ],
                          ),
                        ),

                        Column(
                          children: [
                            if (bank.defaultAc == "Yes")
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextWidget.captionText(
                                    text: 'PRIMARY',
                                    theme: theme.isDarkMode,
                                    color: colors.colorWhite),
                              ),
                            SizedBox(height: 4),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  // Add delay for visual feedback
                                  await Future.delayed(
                                      const Duration(milliseconds: 150));

                                  profileDetails.openInWebURL(
                                      context, "manbank");
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: theme.isDarkMode
                                    ? colors.splashColorDark
                                    : colors.splashColorLight,
                                highlightColor: theme.isDarkMode
                                    ? colors.highlightDark
                                    : colors.highlightLight,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xff666666),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildDepositoryContent(WidgetRef ref, ThemesProvider theme) {
    final profileprovider = ref.watch(profileAllDetailsProvider);
    final theme = ref.watch(themeProvider);
    bool DDPIActive = profileprovider.clientAllDetails.clientData!.dDPI == 'Y';
    bool POAActive = profileprovider.clientAllDetails.clientData!.pOA == 'Y';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.subText(
                        text: "CDSL",
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: DDPIActive ? colors.primaryLight : null,
                            border: !DDPIActive
                                ? Border(
                                    bottom: BorderSide(
                                      color: colors.error,
                                      width: 1,
                                    ),
                                  )
                                : null,
                          ),
                          child: TextWidget.subText(
                            text: "DDPI",
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            color:
                                DDPIActive ? colors.colorWhite : colors.error,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: POAActive ? colors.primaryLight : null,
                            border: !POAActive
                                ? Border(
                                    bottom: BorderSide(
                                      color: colors.error,
                                      width: 1,
                                    ),
                                  )
                                : null,
                          ),
                          child: TextWidget.subText(
                            text: "POA",
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            color: POAActive ? colors.colorWhite : colors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildDataWidget(
                      "DP ID",
                      profileprovider.clientAllDetails.clientData?.cLIENTDPCODE!
                              .substring(0, 8) ??
                          "",
                      theme),
                  _buildDataWidget(
                      "BO ID",
                      profileprovider.clientAllDetails.clientData?.cLIENTDPCODE!
                              .substring(8) ??
                          "",
                      theme),
                  _buildDataWidget(
                      "DP NAME",
                      profileprovider.clientAllDetails.clientData?.dPNAME ?? "",
                      theme),
                ],
              ),
            ],
          ),
        ),
        if (!DDPIActive && !POAActive)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.paraText(
                text: "Do you want to sell your stocks without CDSL T-Pin",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  profileprovider.openInWebURL(context, "deposltory");
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                child: TextWidget.subText(
                    text: "Activate DDPI",
                    theme: false,
                    color: colors.colorWhite,
                    fw: 2),
              ),
              SizedBox(height: 10.0),
            ],
          ),
      ],
    );
  }

  /// Builds the MTF content section
  Widget _buildMTFContent(WidgetRef ref, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);
    final clientData = profileDetails.clientAllDetails.clientData;

    bool DDPIActive = clientData?.dDPI == 'Y';
    bool POAActive = clientData?.pOA == 'Y';
    bool mtfCl = clientData?.mTFCl == 'Y';
    bool mtfClAuto = clientData?.mTFClAuto == "Y";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status badges
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     _buildStatusChip("DDPI", DDPIActive, theme),
        //     const SizedBox(width: 8),
        //     _buildStatusChip("POA", POAActive, theme),
        //   ],
        // ),
        // const SizedBox(height: 16),

        if (!DDPIActive && !POAActive) ...[
          TextWidget.subText(
            text:
                "You need to enable DDPI before you can proceed with processing MTF (Margin Trading Facility).",
            theme: theme.isDarkMode,
            color: colors.error,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: colors.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: BorderSide(
                width: 1,
                color: theme.isDarkMode
                    ? colors.textDisabled.withOpacity(0.5)
                    : colors.textDisabled.withOpacity(0.3),
              ),
            ),
            child: TextWidget.subText(
              text: "Enable MTF",
              theme: theme.isDarkMode,
              fw: 2,
              color: theme.isDarkMode
                  ? colors.textDisabled.withOpacity(0.7)
                  : colors.textDisabled.withOpacity(0.5),
            ),
          ),
        ] else if (mtfCl && mtfClAuto) ...[
          TextWidget.subText(
            text:
                "You have activated the Margin Trading Facility (MTF) on your account",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
          ),
          const SizedBox(height: 16),
          Chip(
            label: TextWidget.subText(
              text: 'MTF Enabled',
              theme: theme.isDarkMode,
              color: colors.colorWhite,
            ),
            backgroundColor: colors.primaryLight,
          ),
        ] else if (DDPIActive || POAActive) ...[
          TextWidget.subText(
            text:
                "Would you like to activate Margin Trading Facility (MTF) on your account",
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            theme: theme.isDarkMode,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              profileDetails.openInWebURL(context, "mtf");
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: TextWidget.subText(
              text: "Enable MTF",
              theme: theme.isDarkMode,
              fw: 2,
              color: colors.colorWhite,
            ),
          ),
        ] else ...[
          if ((profileDetails.clientAllDetails.clientData!.mTFCl == 'N' &&
                  profileDetails.clientAllDetails.clientData!.mTFClAuto ==
                      'N') &&
              (profileDetails.clientAllDetails.clientData!.dDPI == 'Y' ||
                  profileDetails.clientAllDetails.clientData!.pOA == "Y"))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.subText(
                    text:
                        "Would you like to activate Margin Trading Facility (MTF) on your account ",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        //  if (Platform.isAndroid) {
                        //           await ref.read(fundProvider).fetchHstoken(context);
                        //             Navigator.pushNamed(
                        //                 context, Routes.profileWebViewApp,
                        //                 arguments: "mtf");

                        //         } else {
                        profileDetails.openInWebURL(context, "mtf");
                        // }

                        // await ref.read(fundProvider).fetchHstoken(context);
                        // Navigator.pushNamed(context, Routes.profileWebViewApp,
                        //     arguments: "mtf");
                        //  profileDetails.openInWebURL(context,"mtf");
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        side: BorderSide(
                          width: 1,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                        ),
                      ),
                      child: TextWidget.subText(
                          text: "Enable MTF", theme: theme.isDarkMode, fw: 2),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ]),
    );
  }

  /// Builds the Trading Preferences content section
  Widget _buildTradingPreferencesContent(WidgetRef ref, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);
    final segmentsData =
        profileDetails.clientAllDetails.clientData?.segmentsData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: "Segments",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    // Add delay for visual feedback
                    await Future.delayed(const Duration(milliseconds: 150));

                    profileDetails.openInWebURL(context, "segment");
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.highlightDark
                      : colors.highlightLight,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Color(0xff666666),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 5),
          if (segmentsData != null) ...[
            _buildSegmentRow(
                "Equities",
                segmentsData.where(
                    (s) => ['BSE_CASH', 'NSE_CASH'].contains(s.cOMPANYCODE)),
                theme),
            _buildSegmentRow(
                "F&O",
                segmentsData.where(
                    (s) => ['NSE_FNO', 'BSE_FNO'].contains(s.cOMPANYCODE)),
                theme),
            _buildSegmentRow(
                "Currency",
                segmentsData
                    .where((s) => ['CD_NSE', 'CD_BSE'].contains(s.cOMPANYCODE)),
                theme),
            _buildSegmentRow(
                "Commodities",
                segmentsData.where((s) =>
                    ['MCX', 'NSE_COM', 'BSE_COM'].contains(s.cOMPANYCODE)),
                theme),
          ] else
            TextWidget.paraText(
              text: "No segment data available",
              theme: theme.isDarkMode,
            ),
        ],
      ),
    );
  }

  /// Builds the Nominee content section
  Widget _buildNomineeContent(WidgetRef ref, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);
    final clientData = profileDetails.clientAllDetails.clientData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (clientData?.nomineeName == null ||
              clientData?.nomineeName == "") ...[
            TextWidget.subText(
              text: "No nominee details found",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              theme: theme.isDarkMode,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 150));
                    profileDetails.openInWebURL(context, "nominee");
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4))),
                  child: TextWidget.subText(
                    text: "Add Nominee",
                    color: colors.colorWhite,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.subText(
                  text: "Nominee Details",
                  theme: theme.isDarkMode,
                  fw: 0,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      // Add delay for visual feedback
                      await Future.delayed(const Duration(milliseconds: 150));

                      profileDetails.openInWebURL(context, "nominee");
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.15),
                    highlightColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Color(0xff666666),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            _buildDetailRow(
                "Nominee Name", clientData?.nomineeName ?? "N/A", theme),
            _buildDetailRow("Nominee Relation",
                clientData?.nomineeRelation ?? "N/A", theme),
            if (clientData?.nomineeDOB != null)
              _buildDetailRow("Nominee DOB",
                  formatNomineeDOB(clientData!.nomineeDOB!), theme),
          ],
        ],
      ),
    );
  }

  /// Builds the Form Download content section
  Widget _buildFormDownloadContent(WidgetRef ref, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: "Download various forms and documents",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 150));

                  profileDetails.openInWebURL(context, "formdownload");
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                child: TextWidget.subText(
                    text: "Download Forms",
                    theme: false,
                    color: colors.colorWhite,
                    fw: 2),
              ),
            ],
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     profileDetails.openInWebURL(context, "formdownload");
          //   },
          //   style: ElevatedButton.styleFrom(
          //     elevation: 0,
          //     minimumSize: const Size(double.infinity, 40),
          //     backgroundColor:
          //         theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(32),
          //     ),
          //     side: BorderSide(
          //       width: 1,
          //       color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          //     ),
          //   ),
          //   child: TextWidget.subText(
          //     text: "Download Forms",
          //     theme: theme.isDarkMode,
          //     fw: 1,
          //   ),
          // ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  /// Builds the Closure content section
  Widget _buildClosureContent(WidgetRef ref, ThemesProvider theme) {
    final profileDetails = ref.watch(profileAllDetailsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: "Closing your account is a permanent and irreversible action",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 150));

              profileDetails.openInWebURL(context, "closure");
            },
            style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
            child: TextWidget.subText(
                text: "Close Account",
                theme: false,
                color: colors.colorWhite,
                fw: 2),
          )
        ],
      ),
    );
  }

  /// Helper method to build status chips
  Widget _buildStatusChip(String label, bool isActive, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: theme.isDarkMode
            ? isActive
                ? colors.primaryDark
                : colors.btnBg
            : isActive
                ? colors.primaryLight
                : colors.btnBg,
      ),
      child: TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: isActive ? colors.colorWhite : colors.colorBlack),
    );
  }

  /// Helper method to build segment rows
  Widget _buildSegmentRow(
      String label, Iterable segments, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: label,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
            ),
            Row(
              children: segments.map<Widget>((segment) {
                bool isActive = segment.aCTIVEINACTIVE == "A";
                String displayName =
                    ['CD_BSE', 'CD_NSE'].contains(segment.cOMPANYCODE)
                        ? segment.cOMPANYCODE.split("_")[1]
                        : segment.cOMPANYCODE.split("_")[0];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isActive ? colors.primaryLight : null,
                    border: !isActive
                        ? Border(
                            bottom: BorderSide(
                              color: colors.error,
                              width: 1,
                            ),
                          )
                        : null,
                  ),
                  child: TextWidget.subText(
                      text: displayName,
                      theme: theme.isDarkMode,
                      color: isActive ? colors.colorWhite : colors.error),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 1,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }

  /// Helper method to format date
  String _formatDate(String dateString) {
    List<String> formatPart = dateString.split(" ")[0].split("-");
    return formatPart.length == 3
        ? '${formatPart[2]}-${formatPart[1]}-${formatPart[0]}'
        : dateString;
  }

  /// Helper for consistent styling of profile detail rows (using data widget from holding_detail_screen)
  Widget _buildDetailRow(String label, String value, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: label,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
            ),
            TextWidget.subText(
              text: value,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }

  /// Helper method to build data widget (same as data() from holding_detail_screen)
  Widget _buildDataWidget(String label, String value, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget.subText(
              text: label,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
            ),
            SizedBox(
              width: 250,
              child: TextWidget.subText(
                text: value,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                align: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 1,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }

  /// Formats nominee DOB from 'October, 07 1983 00:00:00 +0530' to '07/10/1983'
  String formatNomineeDOB(String rawDate) {
    try {
      DateTime date = DateFormat("MMMM, dd yyyy HH:mm:ss Z").parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return rawDate;
    }
  }
}

// Reports Screen
class ReportsScreen extends ConsumerWidget {
  String _truncateProfileName(String text, {int maxLength = 18}) {
    return (text.length > maxLength)
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider);
    final ledgerdate = ref.watch(ledgerProvider);

    final reportsItems = [
      {'title': 'P&L Insights'},
      {'title': 'Ledger'},
      {'title': 'Holdings'},
      {'title': 'Positions'},
      {'title': 'Profit & Loss'},
      {'title': 'Tax P&L'},
      {'title': 'Tradebook'},
      {'title': 'Downloads'},
      {'title': 'Corporate Actions'},
      // {'title': 'CA Events'},
      {'title': 'Pledge & Unpledge'},
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        leadingWidth: 48,
        titleSpacing: 0,
        leading: const CustomBackBtn(),
        title: TextWidget.titleText(
          text: "Reports",
          theme: false,
          color: !theme.isDarkMode
              ? colors.textPrimaryLight
              : colors.textPrimaryDark,
          fw: 1,
        ),
      ),
      body: Column(
        children: [
          /// Profile Header
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Row(
          //     children: [
          //       CircleAvatar(
          //         radius: 24,
          //         backgroundColor: colors.fundbuttonBg,
          //         child: Text(
          //           userProfile.userDetailModel?.uname
          //                   ?.substring(0, 1)
          //                   .toUpperCase() ??
          //               "U",
          //           style: const TextStyle(color: Colors.black),
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           TextWidget.subText(
          //             text: _truncateProfileName(
          //                 userProfile.userDetailModel?.uname ?? ""),
          //             theme: false,
          //             color: !theme.isDarkMode
          //                 ? colors.colorBlack
          //                 : colors.colorGrey,
          //             fw: 0,
          //           ),
          //           const SizedBox(height: 4),
          //           TextWidget.paraText(
          //             text: userProfile.userDetailModel?.uid ?? "",
          //             theme: false,
          //             color: colors.colorGrey,
          //             fw: 00,
          //           )
          //         ],
          //       ),
          //       // const Spacer(),
          //       // Icon(Icons.arrow_forward_ios,
          //       //     size: 16, color: colors.colorGrey)
          //     ],
          //   ),
          // ),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Divider(
          //     color: colors.fundbuttonBg, // Optional: customize the color
          //     thickness: 1, // Optional: customize the thickness
          //   ),
          // ),

          // const SizedBox(height: 10),

          // Reports Section

          // const SizedBox(height: 10),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Divider(
          //     color: colors.fundbuttonBg, // Optional: customize the color
          //     thickness: 1.5, // Optional: customize the thickness
          //   ),
          // ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reportsItems.length,
                itemBuilder: (context, index) {
                  final item = reportsItems[index];
                  return ListTile(
                    minTileHeight: 60,
                    title: TextWidget.subText(
                      text: item['title']!,
                      theme: false,
                      color: !theme.isDarkMode
                          ? colors.textSecondaryLight
                          : colors.textSecondaryDark,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: !theme.isDarkMode
                          ? colors.textSecondaryLight
                          : colors.textSecondaryDark,
                    ),
                    onTap: () async {
                      // Handle reports navigation - you can add the existing navigation logic here
                      switch (item['title']) {
                        case 'P&L Insights':
                          await ledgerdate.getCurrentDate('else');
                          Navigator.pushNamed(context, Routes.calenderpnlScreen,
                              arguments: "DDDDD");
                        case 'Ledger':
                          await ledgerdate.getCurrentDate('else');

                          Navigator.pushNamed(context, Routes.ledgerscreen,
                              arguments: "DDDDD");
                          break;
                        case 'Holdings':
                          await ledgerdate.getCurrentDate('else');

                          Navigator.pushNamed(context, Routes.holdingscreen,
                              arguments: "DDDDD");
                          break;
                        case 'Positions':
                          ledgerdate.fetchposition(context);

                          Navigator.pushNamed(context, Routes.positionscreen,
                              arguments: "DDDDD");
                          break;
                        case 'Profit & Loss':
                          // ledgerdate.fetchposition(context);
                          if (ledgerdate.pnlAllData == null) {
                            await ledgerdate.getCurrentDate('else');
                            ledgerdate.fetchpnldata(context,
                                ledgerdate.startDate, ledgerdate.today, true);
                          }

                          Navigator.pushNamed(context, Routes.pnlscreen,
                              arguments: "DDDDD");
                          break;

                        case 'Tax P&L':
                          // await ledgerdate.getYearlistTaxpnl();
                          if (ledgerdate.taxpnldercomcur == null &&
                              ledgerdate.taxpnleq == null) {
                            await ledgerdate.getYearlistTaxpnl();
                            ledgerdate.getCurrentDate('');
                            ledgerdate.fetchtaxpnleqdata(
                                context, ledgerdate.yearforTaxpnl);

                            ledgerdate.taxpnlExTabchange(0);
                            ledgerdate.chargesforeqtaxpnl(
                                context, ledgerdate.yearforTaxpnl);
                          }

                          Navigator.pushNamed(context, Routes.taxpnlscreen,
                              arguments: "DDDDD");
                          break;
                        case 'Tradebook':
                          // await ledgerdate.getCurrentDate('tradebook');
                          if (ledgerdate.tradebookdata == null) {
                            await ledgerdate.getCurrentDate('tradebook');
                            ledgerdate.fetchtradebookdata(context,
                                ledgerdate.startDate, ledgerdate.today);
                          }
                          Navigator.pushNamed(context, Routes.tradebook,
                              arguments: "DDDDD");
                          break;
                        case 'Downloads':
                          // ledgerdate.fetchposition(context);
                          if (ledgerdate.pdfdownload == null) {
                            await ledgerdate.getCurrentDate('else');
                            ledgerdate.fetchpdfdownload(context,
                                ledgerdate.startDate, ledgerdate.today);
                          }
                          Navigator.pushNamed(context, Routes.pdfdownload,
                              arguments: "DDDDD");
                          break;
                        case 'Corporate Actions':
                          // ledgerdate.fetchposition(context);
                          if (ledgerdate.holdingsAllData == null) {
                            await ledgerdate.getCurrentDate('else');
                            Navigator.pushNamed(context, Routes.cabuyback,
                                arguments: "DDDDD");
                            await ledgerdate.fetchholdingsData(
                                ledgerdate.today, context);
                            if (ledgerdate.cpactiondata == null) {
                              ledgerdate.fetchcpactiondata(context);
                            }
                          } else {
                            Navigator.pushNamed(context, Routes.cabuyback,
                                arguments: "DDDDD");
                          }
                          // cop action

                          break;
                        case 'CA Events':
                          // ledgerdate.fetchposition(context);
                          // }
                          if (ledgerdate.caeventalldata == null) {
                            await ledgerdate.getCurrentDate('caevent');
                            ledgerdate.fetchcaeventsdata(context,
                                ledgerdate.startDate, ledgerdate.endDate);
                          }

                          Navigator.pushNamed(context, Routes.caeventmainpage,
                              arguments: "DDDDD");
                          break;
                        case 'Pledge & Unpledge':
                          if (ledgerdate.pledgeandunpledge == null) {
                            await ledgerdate.getCurrentDate("pandu");
                            ledgerdate.fetchpledgeandunpledge(context);
                          }
                          Navigator.pushNamed(context, Routes.pledgeandun,
                              arguments: "DDDDD");
                          break;
                        // Add other cases as needed
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListDivider(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          // Version
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextWidget.captionText(
              text: ref.watch(authProvider).versiontext,
              theme: false,
              color: !theme.isDarkMode
                  ? colors.textSecondaryLight
                  : colors.textSecondaryDark,
              fw: 3,
            ),
          )
        ],
      ),
      // bottomNavigationBar: buildBottomNav(4, theme, context, ref),
    );
  }

  final selectedBtmIndx = 4;

  // Add this function
  // Widget buildBottomNav(int selectedTab, ThemesProvider theme,
  //     BuildContext context, WidgetRef ref) {
  //   final uid = ref.watch(userProfileProvider.select(
  //       (userProfile) => userProfile.userDetailModel?.uid?.toString() ?? ""));
  //   return BottomAppBar(
  //     height: 64,
  //     shadowColor:
  //         theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
  //     padding: EdgeInsets.zero,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         _buildBottomNavItem(
  //             1, assets.watchlistIcon, "Watchlists", selectedTab, theme,
  //             context: context, ref: ref),
  //         _buildBottomNavItem(
  //             2, assets.portfolioIcon, "Portfolio", selectedTab, theme,
  //             context: context, ref: ref),
  //         _buildBottomNavItem(
  //             3, assets.ordersIcon, "Orders", selectedTab, theme,
  //             context: context, ref: ref),
  //         _buildBottomNavItem(4, assets.profileIcon, uid, selectedTab, theme,
  //             useHeight: true, height: 18, context: context, ref: ref),
  //       ],
  //     ),
  //   );
  // }

  // // Add this function
  // Widget _buildBottomNavItem(int index, String iconAsset, String label,
  //     int selectedIndex, ThemesProvider theme,
  //     {bool useHeight = false,
  //     double height = 24,
  //     required BuildContext context,
  //     required WidgetRef ref}) {
  //   final isSelected = selectedIndex == index;

  //   return Expanded(
  //     child: RepaintBoundary(
  //       child: InkWell(
  //         onTap: () {
  //           // Navigate to the corresponding screen
  //           switch (index) {
  //             case 1:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(1, context);
  //               break;
  //             case 2:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(2, context);
  //               break;
  //             case 3:
  //               Navigator.pushReplacementNamed(context, Routes.homeScreen);
  //               ref.read(indexListProvider).bottomMenu(3, context);
  //               break;
  //             case 4:
  //               // Already on profile screen
  //               break;
  //           }
  //         },
  //         child: Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 7),
  //           decoration: BoxDecoration(
  //               border: isSelected
  //                   ? Border(
  //                       top: BorderSide(
  //                           color: theme.isDarkMode
  //                               ? colors.colorLightBlue
  //                               : colors.colorBlue,
  //                           width: 2))
  //                   : null),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               useHeight
  //                   ? SvgPicture.asset(
  //                       iconAsset,
  //                       height: height,
  //                       color: _getBottomNavColor(theme, isSelected),
  //                     )
  //                   : SvgPicture.asset(
  //                       iconAsset,
  //                       color: _getBottomNavColor(theme, isSelected),
  //                     ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 label,
  //                 style: TextWidget.textStyle(
  //                     fontSize: 12,
  //                     color: _getBottomNavColor(theme, isSelected),
  //                     theme: theme.isDarkMode,
  //                     fw: isSelected ? 1 : 00),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Add this function
  Color _getBottomNavColor(ThemesProvider theme, bool isSelected) {
    if (theme.isDarkMode && isSelected) {
      return colors.colorLightBlue;
    } else if (isSelected) {
      return colors.colorBlue;
    } else {
      return colors.colorGrey;
    }
  }
}

class UserInfoColumn extends StatelessWidget {
  final ThemesProvider theme;
  final String section;
  final String label;
  final String value;
  final bool editable;
  final bool expandable;
  const UserInfoColumn(
      {super.key,
      required this.theme,
      required this.label,
      required this.value,
      this.section = "profile",
      this.editable = false,
      this.expandable = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: label.toUpperCase(),
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
            ),
            TextWidget.subText(
              text: value,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 1,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }
}
//   final selectedBtmIndx = 4;

//   // Add this function
//   Widget buildBottomNav(int selectedTab, ThemesProvider theme,
//       BuildContext context, WidgetRef ref) {
//     final uid = ref.watch(userProfileProvider.select(
//         (userProfile) => userProfile.userDetailModel?.uid?.toString() ?? ""));
//     return BottomAppBar(
//       height: 64,
//       shadowColor:
//           theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
//       padding: EdgeInsets.zero,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           _buildBottomNavItem(
//               1, assets.watchlistIcon, "Watchlists", selectedTab, theme,
//               context: context, ref: ref),
//           _buildBottomNavItem(
//               2, assets.portfolioIcon, "Portfolio", selectedTab, theme,
//               context: context, ref: ref),
//           _buildBottomNavItem(
//               3, assets.ordersIcon, "Orders", selectedTab, theme,
//               context: context, ref: ref),
//           _buildBottomNavItem(4, assets.profileIcon, uid, selectedTab, theme,
//               useHeight: true, height: 18, context: context, ref: ref),
//         ],
//       ),
//     );
//   }

//   // Add this function
//   Widget _buildBottomNavItem(int index, String iconAsset, String label,
//       int selectedIndex, ThemesProvider theme,
//       {bool useHeight = false,
//       double height = 24,
//       required BuildContext context,
//       required WidgetRef ref}) {
//     final isSelected = selectedIndex == index;

//     return Expanded(
//       child: RepaintBoundary(
//         child: InkWell(
//           onTap: () {
//             // Navigate to the corresponding screen
//             switch (index) {
//               case 1:
//                 Navigator.pushReplacementNamed(context, Routes.homeScreen);
//                 ref.read(indexListProvider).bottomMenu(1, context);
//                 break;
//               case 2:
//                 Navigator.pushReplacementNamed(context, Routes.homeScreen);
//                 ref.read(indexListProvider).bottomMenu(2, context);
//                 break;
//               case 3:
//                 Navigator.pushReplacementNamed(context, Routes.homeScreen);
//                 ref.read(indexListProvider).bottomMenu(3, context);
//                 break;
//               case 4:
//                 // Already on profile screen
//                 break;
//             }
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 7),
//             decoration: BoxDecoration(
//                 border: isSelected
//                     ? Border(
//                         top: BorderSide(
//                             color: theme.isDarkMode
//                                 ? colors.colorLightBlue
//                                 : colors.colorBlue,
//                             width: 2))
//                     : null),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 useHeight
//                     ? SvgPicture.asset(
//                         iconAsset,
//                         height: height,
//                         color: _getBottomNavColor(theme, isSelected),
//                       )
//                     : SvgPicture.asset(
//                         iconAsset,
//                         color: _getBottomNavColor(theme, isSelected),
//                       ),
//                 const SizedBox(height: 8),
//                 Text(
//                   label,
//                   style: TextWidget.textStyle(
//                       fontSize: 12,
//                       color: _getBottomNavColor(theme, isSelected),
//                       theme: theme.isDarkMode,
//                       fw: isSelected ? 1 : 00),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Add this function
//   Color _getBottomNavColor(ThemesProvider theme, bool isSelected) {
//     if (theme.isDarkMode && isSelected) {
//       return colors.colorLightBlue;
//     } else if (isSelected) {
//       return colors.colorBlue;
//     } else {
//       return colors.colorGrey;
//     }
//   }
// }
