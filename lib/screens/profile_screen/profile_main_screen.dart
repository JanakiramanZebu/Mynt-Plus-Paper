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
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/loader_ui.dart';
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
      {'title': 'Reports'},
      {'title': 'Account'},
      {'title': 'Settings'},
      {'title': 'Refer'},
      {'title': 'Rate Us'},
      {'title': 'Contact'},
    ];

    return TransparentLoaderScreen(
      isLoading: mf.bestmfloader!,
      child: Column(
        children: [
          const SizedBox(height: 50),

          /// 🔹 Top: Notification & QR Code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                IconButton(
                  splashRadius: 20,
                  icon: SvgPicture.asset(
                    assets.notifyIcon, // This is your asset path
                    height: 20,
                    width: 20,
                    color: colors
                        .colorGrey, // Optional: set color if your SVG supports it
                  ),
                  onPressed: () async {
                    await ref
                        .read(notificationprovider)
                        .fetchexchagemsg(context);
                    await ref
                        .read(notificationprovider)
                        .fetchbrokermsg(context);
                    Navigator.pushNamed(context, Routes.notificationpage);
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
                              "U",
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
                  InkWell(
                    // customBorder: const CircleBorder(),
                    splashColor: Colors.black.withOpacity(0.15),
                    highlightColor: Colors.black.withOpacity(0.08),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget.heroText(
                                text: _truncateProfileName(
                                    userProfile.userDetailModel?.uname ?? ""),
                                theme: false,
                                color: !theme.isDarkMode
                                    ? const Color(0xff141414)
                                    : colors.colorGrey,
                                fw: 1),
                            SizedBox(width: 8),
                            Transform.rotate(
                              angle: 90 * 3.1416 / 180,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: !theme.isDarkMode
                                    ? colors.primaryLight
                                    : colors.primaryDark,
                              ),
                            ),
                          ],
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
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1, // Optional: customize the thickness
            ),
          ),

          /// 🔹 Horizontal Buttons (inline style)
          // _buildHorizontalButtons(context, ref, theme, funds, mf),

          /// 🔹 Account Balance (inline, outlined Add Fund)
          _buildAccountBalanceSection(context, ref, theme, funds, trancation),

          /// 🔹 Menu List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 0),
              itemCount: filteredMenu.length,
              itemBuilder: (context, index) {
                final title = filteredMenu[index]['title']!;
                return ListTile(
                  minTileHeight: 47,
                  onTap: () async {
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
                      case "Account":
                        Navigator.pushNamed(context, Routes.myaccountScreen);
                        break;
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
                        await ref.read(userProfileProvider).fetchsetting();
                        await ref.read(apikeyprovider).fetchapikey(context);
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
                    }
                  },
                  title: TextWidget.subText(
                      text: title,
                      theme: false,
                      color: !theme.isDarkMode
                          ? colors.textPrimaryLight
                          : colors.textPrimaryDark,
                      fw: 3),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: !theme.isDarkMode
                        ? colors.textPrimaryLight
                        : colors.textPrimaryDark,
                  ),
                );
              },
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: colors.fundbuttonBg, // Optional: customize the color
                  thickness: 1.5, // Optional: customize the thickness
                ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 0),
      child: Column(
        children: [
          // Divider(
          //   color: colors.fundbuttonBg, // Optional: customize the color
          //   thickness: 1, // Optional: customize the thickness
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                // onTap: () async {
                //   ref.read(indexListProvider).bottomMenu(2, context);
                //   await Future.delayed(
                //       const Duration(milliseconds: 2000)); // Delay of 300ms
                //   Navigator.pushReplacementNamed(context, Routes.homeScreen);

                  
                  
                // },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                          text: "Account Balance",
                          theme: false,
                          color: !theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          fw: 3),
                      const SizedBox(height: 4),
                      TextWidget.subText(
                          text: formatIndianCurrency(
                              funds.fundDetailModel?.avlMrg ?? "0.00"),
                          theme: false,
                          color: !theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          fw: 0),
                    ]),
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
                  // ref.read(transcationProvider).fetchValidateToken(context);
                  // Future.delayed(const Duration(milliseconds: 100), () async {
                  //   await trancation.ip();
                  //   await trancation.fetchupiIdView(
                  //       trancation.bankdetails!.dATA![trancation.indexss][1],
                  //       trancation.bankdetails!.dATA![trancation.indexss][2]);
                  //   await trancation.fetchcwithdraw(context);
                  // });
                  // trancation.changebool(true);
                  // Navigator.pushNamed(context, Routes.fundscreen,
                  //     arguments: trancation);
                  ref.read(portfolioProvider).changeTabIndex(3);
                  ref.read(indexListProvider).bottomMenu(2, context);
                },
                child: TextWidget.paraText(
                    text: "Add Fund",
                    theme: false,
                    color: !theme.isDarkMode
                        ? colors.colorBlue
                        : colors.colorLightBlue,
                    fw: 0,
                    align: TextAlign.center),
              ),
            ],
          ),
          // Add space between the content and the line
          const SizedBox(height: 15),

          // Step 2: Add the Divider widget
          Divider(
            color: colors.fundbuttonBg, // Optional: customize the color
            thickness: 1, // Optional: customize the thickness
          ),
        ],
      ),
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
      {'title': 'Order Preference', 'section': 'Settings'},
    ];

    final securityItems = [
      {'title': 'Freeze Account', 'section': 'Security'},
      {'title': 'Change Password', 'section': 'Security'},
      {'title': 'Generate TOTP', 'section': 'Security'},
      {'title': 'Generate API Key', 'section': 'Security'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          splashRadius: 20,
          icon: Icon(Icons.arrow_back,
              color: theme.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
          IconButton(
            splashRadius: 20,
            icon: SvgPicture.asset(
              assets.notifyIcon, // This is your asset path
              height: 20,
              width: 20,
              color: colors
                  .colorGrey, // Optional: set color if your SVG supports it
            ),
            onPressed: () async {
              await ref.read(notificationprovider).fetchexchagemsg(context);
              await ref.read(notificationprovider).fetchbrokermsg(context);
              Navigator.pushNamed(context, Routes.notificationpage);
            },
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.fundbuttonBg,
                  child: Text(
                    userProfile.userDetailModel?.uname
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        "U",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      text: _truncateProfileName(
                          userProfile.userDetailModel?.uname ?? ""),
                      theme: false,
                      color: !theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorGrey,
                      fw: 0,
                    ),
                    const SizedBox(height: 4),
                    TextWidget.paraText(
                      text: userProfile.userDetailModel?.uid ?? "",
                      theme: false,
                      color: colors.colorGrey,
                      fw: 00,
                    )
                  ],
                ),
                // const Spacer(),
                // Icon(Icons.arrow_forward_ios,
                //     size: 16, color: colors.colorGrey)
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1.5, // Optional: customize the thickness
            ),
          ),

          const SizedBox(height: 12),

          // Settings Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextWidget.heroText(
                text: "Settings",
                theme: false,
                color:
                    !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                fw: 1,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1.5, // Optional: customize the thickness
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settingsItems.length,
            itemBuilder: (context, index) {
              final item = settingsItems[index];
              return ListTile(
                minTileHeight: 47,
                title: TextWidget.subText(
                    text: item['title']!,
                    theme: false,
                    color: !theme.isDarkMode
                        ? colors.textPrimaryLight
                        : colors.textPrimaryDark,
                    fw: 3),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: !theme.isDarkMode
                      ? colors.textPrimaryLight
                      : colors.textPrimaryDark,
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
                    case 'Order Preference':
                      Navigator.pushNamed(context, Routes.orderPrefer);
                      break;
                  }
                },
              );
            },
            separatorBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: colors.fundbuttonBg, // Optional: customize the color
                thickness: 1, // Optional: customize the thickness
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1.5, // Optional: customize the thickness
            ),
          ),
          const SizedBox(height: 12),

          // Security Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextWidget.heroText(
                text: "Security",
                theme: false,
                color:
                    !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                fw: 1,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1.5, // Optional: customize the thickness
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: securityItems.length,
            itemBuilder: (context, index) {
              final item = securityItems[index];
              return ListTile(
                minTileHeight: 47,
                title: TextWidget.subText(
                    text: item['title']!,
                    theme: false,
                    color: !theme.isDarkMode
                        ? colors.textPrimaryLight
                        : colors.textPrimaryDark,
                    fw: 3),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: !theme.isDarkMode
                      ? colors.textPrimaryLight
                      : colors.textPrimaryDark,
                ),
                onTap: () async {
                  // Handle security navigation
                  switch (item['title']) {
                    case 'Freeze Account':
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: ref.read(themeProvider).isDarkMode
                                ? const Color.fromARGB(255, 18, 18, 18)
                                : colors.colorWhite,
                            titleTextStyle: textStyles.appBarTitleTxt.copyWith(
                                color: ref.read(themeProvider).isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack),
                            titlePadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14))),
                            scrollable: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            insetPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            // title: Padding(
                            //   padding: const EdgeInsets.only(top : 8.0),
                            //   child: TextWidget.titleText(
                            //       text: "Freeze Account!",
                            //       theme: theme.isDarkMode,
                            //       color : theme.isDarkMode
                            //           ? colors.textPrimaryDark
                            //           : colors.textPrimaryLight,
                            //       fw: 1),
                            // ),

                            content: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.titleText(
                                            text:
                                                "Freeze Account",
                                            theme: false,
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                            fw: 0),
                                        const SizedBox(height: 12),
                                        TextWidget.subText(
                                            text:
                                                "Account freeze notice: All open orders will be cancelled due to the freeze. Existing positions will remain open and will not be affected.",
                                            theme: false,
                                            color: theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                : colors.textSecondaryLight,
                                            fw: 3),
                                        SizedBox(height: 14),
                                      ])),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: theme.isDarkMode
                                        ? const Color(0xffF1F3F8)
                                        : const Color(0xffF1F3F8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4))),
                                child: TextWidget.subText(
                                    text: "Cancel",
                                    theme: false,
                                    color: !theme.isDarkMode
                                        ? const Color(0xff666666)
                                        : const Color(0xff666666),
                                    fw: 0),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  userProfile.fetchFreezeAc(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4))),
                                child: TextWidget.subText(
                                    text: "Continue",
                                    theme: false,
                                    color: colors.colorWhite,
                                    fw: 0),
                              ),
                            ],
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
            separatorBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: colors.fundbuttonBg, // Optional: customize the color
                thickness: 1, // Optional: customize the thickness
              ),
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
              fw: 3,
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
  late int _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initialIndex; // ← store the target tile
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
      // Fetch data for Profile and Bank when their sections are expanded
      // This mimics the initState behavior of the original pages
      if (title == 'Profile' || title == 'Bank') {
        ref.read(profileAllDetailsProvider).fetchClientProfileAllDetails();
      }
      // Add other data fetching logic for other sections if needed in the future
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
        leading: IconButton(
          splashRadius: 20,
          icon: Icon(Icons.arrow_back,
              color: theme.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            splashRadius: 20,
            icon: SvgPicture.asset(
              assets.qrIcon, // This is your asset path
              height: 20,
              width: 20,
              color: colors
                  .colorGrey, // Optional: set color if your SVG supports it
            ),
            onPressed: () => Navigator.pushNamed(context, Routes.qrscanner),
          ),
          IconButton(
            splashRadius: 20,
            icon: SvgPicture.asset(
              assets.notifyIcon, // This is your asset path
              height: 20,
              width: 20,
              color: colors
                  .colorGrey, // Optional: set color if your SVG supports it
            ),
            onPressed: () async {
              await ref.read(notificationprovider).fetchexchagemsg(context);
              await ref.read(notificationprovider).fetchbrokermsg(context);
              Navigator.pushNamed(context, Routes.notificationpage);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Header (retained from your original design)
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.fundbuttonBg,
                  child: Text(
                    userProfile.userDetailModel?.uname
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        "U",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      fw: 0,
                      text: _truncateProfileName(
                          userProfile.userDetailModel?.uname ?? ""),
                      theme: false,
                      color: !theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorGrey,
                    ),
                    const SizedBox(height: 6),
                    TextWidget.paraText(
                      text: userProfile.userDetailModel?.uid ?? "",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    )
                  ],
                ),
                // const Spacer(),
                // Icon(Icons.arrow_forward_ios,
                //     size: 16, color: colors.colorGrey)
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1, // Optional: customize the thickness
            ),
            const SizedBox(height: 8),
            TextWidget.heroText(
              text: "Account",
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 1,
            ),
            const SizedBox(height: 10),
            Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1, // Optional: customize the thickness
            ),

            /// Expandable List View
            Expanded(
              child: ListView.separated(
                itemCount: accountItems.length,
                itemBuilder: (context, index) {
                  final item = accountItems[index];
                  final title = item['title']!;

                  return ExpansionTile(
                    // The first item ("Profile") is expanded by default
                    initiallyExpanded: index == 0,
                    onExpansionChanged: (isExpanding) =>
                        _onExpansionChanged(isExpanding, title),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: TextWidget.titleText(
                      text: title,
                      theme: false,
                      color: !theme.isDarkMode
                          ? colors.textPrimaryLight
                          : colors.textPrimaryDark,
                      fw: 0,
                    ),
                    children: [
                      // Dynamically build the content based on the title
                      _buildExpansionContent(title, ref, theme),
                    ],
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 12.0, left: 12.0),
      child: Column(
        children: [
          _buildDetailRow("Name", clientData?.panName ?? "N/A", theme),
          _buildDetailRow("Email", clientData?.cLIENTIDMAIL ?? "N/A", theme),
          _buildDetailRow("Mobile", clientData?.mOBILENO ?? "N/A", theme),
          _buildDetailRow("PAN", clientData?.pANNO ?? "N/A", theme),
          _buildDetailRow("DP ID", clientData?.cLIENTDPCODE ?? "N/A", theme),
        ],
      ),
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
                  fw: 0,
                ),
                SizedBox(height: 4),
                TextWidget.paraText(
                  text: "View bank details and add new banks.",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 3,
                ),
                SizedBox(height: 10),
              ],
            ),
            IconButton(
              onPressed: () {
                profileDetails.openInWebURL(context, "manbank");
              },
              icon: Icon(
                Icons.add_circle_outline,
                color:
                    theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
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
            ),
          )
        else
          ...bankData.map((bank) {
            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side:
                    const BorderSide(color: Color.fromARGB(255, 214, 214, 214)),
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
                                      fw: 0,
                                    ),
                                  ),
                                  SizedBox(height: 25.0),
                                  if (bank.defaultAc == "Yes")
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.colorGrey
                                            : colors.darkGrey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextWidget.captionText(
                                        text: 'PRIMARY',
                                        theme: theme.isDarkMode,
                                        fw: 1,
                                      ),
                                    ),
                                ],
                              ),
                              TextWidget.paraText(
                                text:
                                    'A/C No: ${profileDetails.formateDataToDisplay(bank.bankAcNo ?? "", 2, 4)}',
                                theme: theme.isDarkMode,
                              ),
                              SizedBox(height: 5.0),
                              TextWidget.paraText(
                                text: 'IFSC: ${bank.iFSCCode ?? "N/A"}',
                                theme: theme.isDarkMode,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            profileDetails.openInWebURL(context, "manbank");
                          },
                          icon: Icon(
                            Icons.edit,
                            color: theme.isDarkMode
                                ? colors.colorLightBlue
                                : colors.colorBlue,
                            size: 16,
                          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
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
                          text: "Demat (CDSL)",
                          theme: theme.isDarkMode,
                          fw: 0,
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
                              color: theme.isDarkMode
                                  ? DDPIActive
                                      ? const Color.fromARGB(255, 9, 163, 17)
                                      : colors.colorGrey
                                  : DDPIActive
                                      ? Color.fromARGB(255, 9, 255, 0)
                                          .withOpacity(.1)
                                      : const Color(0xff666666).withOpacity(.1),
                            ),
                            child: Text("DDPI",
                                overflow: TextOverflow.ellipsis,
                                // maxLines: 1,
                                style: textStyle(
                                    theme.isDarkMode
                                        ? const Color(0xffFFFFFF)
                                        : const Color(0xff666666),
                                    12,
                                    FontWeight.w600)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: theme.isDarkMode
                                  ? POAActive
                                      ? const Color.fromARGB(255, 9, 163, 17)
                                      : colors.colorGrey
                                  : POAActive
                                      ? Color.fromARGB(255, 9, 255, 0)
                                          .withOpacity(.1)
                                      : const Color(0xff666666).withOpacity(.1),
                            ),
                            child: Text("POA",
                                overflow: TextOverflow.ellipsis,
                                // maxLines: 1,
                                style: textStyle(
                                    theme.isDarkMode
                                        ? const Color(0xffFFFFFF)
                                        : const Color(0xff666666),
                                    12,
                                    FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: UserInfoColumn(
                          label: "DP ID",
                          value: profileprovider
                                  .clientAllDetails.clientData?.cLIENTDPCODE!
                                  .substring(0, 8) ??
                              "",
                          theme: theme),
                    ),
                    Flexible(
                      child: UserInfoColumn(
                          label: "BO ID",
                          value: profileprovider
                                  .clientAllDetails.clientData?.cLIENTDPCODE!
                                  .substring(8) ??
                              "",
                          theme: theme),
                    ),
                  ],
                ),
                UserInfoColumn(
                  label: "DP Name",
                  value:
                      profileprovider.clientAllDetails.clientData?.dPNAME ?? "",
                  theme: theme,
                  expandable: true,
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
                    fw: 0),
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
                      fw: 0),
                ),
                SizedBox(height: 10.0),
              ],
            ),
        ],
      ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildStatusChip("DDPI", DDPIActive, theme),
            const SizedBox(width: 8),
            _buildStatusChip("POA", POAActive, theme),
          ],
        ),
        const SizedBox(height: 16),

        if (!DDPIActive && !POAActive)
          TextWidget.subText(
            text:
                "You need to enable DDPI before you can proceed with processing MTF (Margin Trading Facility).",
            theme: theme.isDarkMode,
            fw: 1,
            color: colors.kColorRedText,
          )
        else if (mtfCl && mtfClAuto) ...[
          TextWidget.subText(
            text:
                "You have activated the Margin Trading Facility (MTF) on your account",
            theme: theme.isDarkMode,
          ),
          const SizedBox(height: 16),
          Chip(
            label: TextWidget.subText(
              text: 'MTF Enabled',
              theme: theme.isDarkMode,
              fw: 1,
            ),
            backgroundColor: theme.isDarkMode
                ? const Color.fromARGB(255, 9, 163, 17)
                : const Color.fromARGB(255, 9, 255, 0).withOpacity(.1),
          ),
        ] else if (DDPIActive || POAActive) ...[
          TextWidget.subText(
            text:
                "Would you like to activate Margin Trading Facility (MTF) on your account",
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
                  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              side: BorderSide(
                width: 1,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
            child: TextWidget.subText(
              text: "Enable MTF",
              theme: theme.isDarkMode,
              fw: 1,
            ),
          ),
        ],

        Card(
          elevation: 0,
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: theme.isDarkMode
                                ? DDPIActive
                                    ? const Color.fromARGB(255, 9, 163, 17)
                                    : colors.colorGrey
                                : DDPIActive
                                    ? Color.fromARGB(255, 9, 255, 0)
                                        .withOpacity(.1)
                                    : const Color(0xff666666).withOpacity(.1),
                          ),
                          child: Text("DDPI",
                              overflow: TextOverflow.ellipsis,
                              // maxLines: 1,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? const Color(0xffFFFFFF)
                                      : const Color(0xff666666),
                                  12,
                                  FontWeight.w600)),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: theme.isDarkMode
                                ? POAActive
                                    ? const Color.fromARGB(255, 9, 163, 17)
                                    : colors.colorGrey
                                : POAActive
                                    ? Color.fromARGB(255, 9, 255, 0)
                                        .withOpacity(.1)
                                    : const Color(0xff666666).withOpacity(.1),
                          ),
                          child: Text("POA",
                              overflow: TextOverflow.ellipsis,
                              // maxLines: 1,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? const Color(0xffFFFFFF)
                                      : const Color(0xff666666),
                                  12,
                                  FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!DDPIActive && !POAActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextWidget.subText(
                        text:
                            "You need to enable DDPI before you can proceed with processing MTF (Margin Trading Facility).",
                        theme: theme.isDarkMode,
                        fw: 0,
                        color: colors.kColorRedText),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextWidget.subText(
                      text: "Enable DDPI under Depository tab.",
                      theme: theme.isDarkMode,
                      fw: 0,
                      color: colors.kColorRedText),
                ),
                if ((mtfCl && mtfClAuto)) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 16,),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextWidget.subText(
                          text:
                              "You have activated the Margin Trading Facility (MTF) on your account ",
                          theme: theme.isDarkMode,
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Chip(
                              label: TextWidget.subText(
                                  text: 'MTF Enabled',
                                  theme: theme.isDarkMode,
                                  fw: 1),
                              // labelPadding:EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                              backgroundColor: theme.isDarkMode
                                  ? mtfCl && mtfClAuto
                                      ? const Color.fromARGB(255, 9, 163, 17)
                                      : colors.colorGrey
                                  : mtfCl && mtfClAuto
                                      ? Color.fromARGB(255, 9, 255, 0)
                                          .withOpacity(.1)
                                      : const Color(0xff666666).withOpacity(
                                          .1), // Color(0xffecf8f1),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite, // Color(0xffc1e7ba),
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
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
                                text: "Enable MTF",
                                theme: theme.isDarkMode,
                                fw: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
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
                fw: 0,
              ),
              IconButton(
                onPressed: () {
                  profileDetails.openInWebURL(context, "segment");
                },
                icon: Icon(
                  Icons.edit,
                  color: theme.isDarkMode
                      ? colors.colorLightBlue
                      : colors.colorBlue,
                  size: 16,
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
        children: [
          if (clientData?.nomineeName == null ||
              clientData?.nomineeName == "") ...[
            TextWidget.paraText(
              text: "No nominee details found",
              theme: theme.isDarkMode,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                profileDetails.openInWebURL(context, "nominee");
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(double.infinity, 40),
                backgroundColor:
                    theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                side: BorderSide(
                  width: 1,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                ),
              ),
              child: TextWidget.subText(
                text: "Add Nominee",
                theme: theme.isDarkMode,
                fw: 1,
              ),
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
                IconButton(
                  onPressed: () {
                    profileDetails.openInWebURL(context, "nominee");
                  },
                  icon: Icon(
                    Icons.edit,
                    color: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                    size: 16,
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
              _buildDetailRow(
                  "Nominee DOB", _formatDate(clientData!.nomineeDOB!), theme),
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
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                profileDetails.openInWebURL(context, "formdownload");
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor: theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              child: TextWidget.subText(
                  text: "Download Forms",
                  theme: false,
                  color: colors.colorWhite,
                  fw: 0),
            ),
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
          SizedBox(height: 14.0),
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
            text:
                "* Closing your account is a permanent and irreversible action",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 3,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                profileDetails.openInWebURL(context, "closure");
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor: theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              child: TextWidget.subText(
                  text: "Close Account",
                  theme: false,
                  color: colors.colorWhite,
                  fw: 0),
            ),
          ),
          const SizedBox(height: 12),
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
                ? const Color.fromARGB(255, 9, 163, 17)
                : colors.colorGrey
            : isActive
                ? const Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                : const Color(0xff666666).withOpacity(.1),
      ),
      child: TextWidget.captionText(
        text: label,
        theme: theme.isDarkMode,
        fw: 1,
      ),
    );
  }

  /// Helper method to build segment rows
  Widget _buildSegmentRow(
      String label, Iterable segments, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.paraText(
            text: label,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0,
          ),
          Row(
            children: segments.map<Widget>((segment) {
              bool isActive = segment.aCTIVEINACTIVE == "A";
              String displayName =
                  ['CD_BSE', 'CD_NSE'].contains(segment.cOMPANYCODE)
                      ? segment.cOMPANYCODE.split("_")[1]
                      : segment.cOMPANYCODE.split("_")[0];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: theme.isDarkMode
                      ? isActive
                          ? const Color.fromARGB(255, 9, 163, 17)
                          : colors.colorGrey
                      : isActive
                          ? const Color.fromARGB(255, 9, 255, 0).withOpacity(.1)
                          : const Color(0xff666666).withOpacity(.1),
                ),
                child: TextWidget.captionText(
                  text: displayName,
                  theme: theme.isDarkMode,
                  fw: 1,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Helper method to format date
  String _formatDate(String dateString) {
    List<String> formatPart = dateString.split(" ")[0].split("-");
    return formatPart.length == 3
        ? '${formatPart[2]}-${formatPart[1]}-${formatPart[0]}'
        : dateString;
  }

  /// Helper for consistent styling of profile detail rows
  Widget _buildDetailRow(String label, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.paraText(
            text: label,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 3,
          ),
          TextWidget.paraText(
            text: value,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            theme: theme.isDarkMode,
            fw: 0,
          ),
        ],
      ),
    );
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
      {'title': 'Tradebook / Contract'},
      {'title': 'Downloads'},
      {'title': 'Corporate Actions'},
      // {'title': 'CA Events'},
      {'title': 'Pledge & Unpledge'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          splashRadius: 20,
          icon: Icon(Icons.arrow_back,
              color: theme.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
          IconButton(
            splashRadius: 20,
            icon: SvgPicture.asset(
              assets.notifyIcon, // This is your asset path
              height: 20,
              width: 20,
              color: colors
                  .colorGrey, // Optional: set color if your SVG supports it
            ),
            onPressed: () async {
              await ref.read(notificationprovider).fetchexchagemsg(context);
              await ref.read(notificationprovider).fetchbrokermsg(context);
              Navigator.pushNamed(context, Routes.notificationpage);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.fundbuttonBg,
                  child: Text(
                    userProfile.userDetailModel?.uname
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        "U",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      text: _truncateProfileName(
                          userProfile.userDetailModel?.uname ?? ""),
                      theme: false,
                      color: !theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorGrey,
                      fw: 0,
                    ),
                    const SizedBox(height: 4),
                    TextWidget.paraText(
                      text: userProfile.userDetailModel?.uid ?? "",
                      theme: false,
                      color: colors.colorGrey,
                      fw: 00,
                    )
                  ],
                ),
                // const Spacer(),
                // Icon(Icons.arrow_forward_ios,
                //     size: 16, color: colors.colorGrey)
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1, // Optional: customize the thickness
            ),
          ),

          const SizedBox(height: 10),

          // Reports Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextWidget.heroText(
                text: "Reports",
                theme: false,
                color: !theme.isDarkMode
                    ? colors.textPrimaryLight
                    : colors.textPrimaryDark,
                fw: 1,
              ),
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: colors.fundbuttonBg, // Optional: customize the color
              thickness: 1.5, // Optional: customize the thickness
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reportsItems.length,
                itemBuilder: (context, index) {
                  final item = reportsItems[index];
                  return ListTile(
                    minTileHeight: 47,
                    title: TextWidget.subText(
                        text: item['title']!,
                        theme: false,
                        color: !theme.isDarkMode
                            ? colors.textPrimaryLight
                            : colors.textPrimaryDark,
                        fw: 3),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: !theme.isDarkMode
                          ? colors.textPrimaryLight
                          : colors.textPrimaryDark,
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
                        case 'Tradebook / Contract':
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
                  child: Divider(
                    color: colors.fundbuttonBg, // Optional: customize the color
                    thickness: 1, // Optional: customize the thickness
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.paraText(
            text: label.toUpperCase(),
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 3,
          ),
          TextFormField(
            initialValue: value,
            readOnly: true,
            maxLines: expandable ? 4 : 1,
            minLines: 1,
            decoration: InputDecoration(
              enabled: editable ? true : false,
            ),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
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
