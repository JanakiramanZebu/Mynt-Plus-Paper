import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
// ignore: unused_import
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/res/global_state_text.dart';

import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/user_profile_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../customizable_split_home_screen.dart' show ScreenType;
import 'ledger/ledger_screen.dart';

class ReportsScreenWeb extends ConsumerWidget {
  final Function(dynamic)? onNavigateToScreen;

  const ReportsScreenWeb({super.key, this.onNavigateToScreen});

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
      {'title': 'P&L Summary'},
      {'title': 'Tax P&L'},
      {'title': 'Notional P&L'},
      {'title': 'Ledger'},
      {'title': 'Tradebook'},
      {'title': 'Contract Note'},
      {'title': 'Client Master(CMR)'},
      {'title': 'Positions'},
      // {'title': 'DP Holdings & Transcation'},
      // {'title': 'Corporate Actions'},
      {'title': 'CA Events'},
      {'title': 'PDF Download'},
      // {'title': 'Pledge & Unpledge'},
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
      body: SafeArea(
        child: Column(
          children: [
            /// Profile Header
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16,  vertical: 8),
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
                physics: ClampingScrollPhysics(),
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
                        fw: 0,
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
                          case 'P&L Summary':
                            await ledgerdate.getCurrentDate('pandu');
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.calendarPnl);
                            }

                          case 'Tax P&L':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.taxPnl);
                            }
                            break;
                          case 'Notional P&L':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.notionalPnl);
                            }
                            break;
                          case 'Ledger':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.ledger);
                            } else {
                              await ledgerdate.getCurrentDate('else');
                              ledgerdate.fetchLegerData(
                                  context, ledgerdate.startDate, ledgerdate.endDate, ledgerdate.includeBillMargin);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LedgerScreen(ddd: "DDDDD"),
                                ),
                              );
                            }
                            break;

                          case 'Client Master(CMR)':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.clientMaster);
                            }
                            break;
                          //          case 'DP Holdings & Transcation':
                          //           await showModalBottomSheet(
                          //           isScrollControlled: true,
                          //           backgroundColor: Colors.transparent,
                          //           shape: const RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.only(
                          //               topLeft: Radius.circular(16),
                          //               topRight: Radius.circular(16),
                          //             ),
                          //           ),
                          //           isDismissible: true,
                          //           enableDrag: false,
                          //           useSafeArea: true,
                          //           context: context,
                          //           builder: (context) => Stack(
                          //             children: [
                          //               Container(
                          //                 decoration: BoxDecoration(
                          //                   borderRadius: BorderRadius.circular(16),
                          //                   color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                          //                   boxShadow: const [
                          //                     BoxShadow(
                          //                       color: Color(0xff999999),
                          //                       blurRadius: 4.0,
                          //                       offset: Offset(2.0, 0.0),
                          //                     )
                          //                   ],
                          //                 ),
                          //                 child: Padding(
                          //                   padding: EdgeInsets.only(
                          //                     bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
                          //                   ),
                          //                   child: Column(
                          //                     mainAxisSize: MainAxisSize.min,
                          //                     crossAxisAlignment: CrossAxisAlignment.start,
                          //                     children: [
                          //                       Padding(
                          //                         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          //                         child: Row(
                          //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                           children: [
                          //                             TextWidget.titleText(
                          //                               text: "DP Holding & Transaction",
                          //                               theme: theme.isDarkMode,
                          //                               fw: 1,
                          //                             ),
                          //                             Material(
                          //                               color: Colors.transparent,
                          //                               shape: const CircleBorder(),
                          //                               child: InkWell(
                          //                                 onTap: () async {
                          //                                   await Future.delayed(const Duration(milliseconds: 150));
                          //                                   Navigator.pop(context);
                          //                                 },
                          //                                 borderRadius: BorderRadius.circular(20),
                          //                                 splashColor: theme.isDarkMode
                          //                                     ? Colors.white.withOpacity(0.15)
                          //                                     : Colors.black.withOpacity(0.15),
                          //                                 highlightColor: theme.isDarkMode
                          //                                     ? Colors.white.withOpacity(0.08)
                          //                                     : Colors.black.withOpacity(0.08),
                          //                                 child: Padding(
                          //                                   padding: const EdgeInsets.all(6.0),
                          //                                   child: Icon(
                          //                                     Icons.close_rounded,
                          //                                     size: 22,
                          //                                     color: theme.isDarkMode ? const Color(0xffBDBDBD) : colors.colorGrey,
                          //                                   ),
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       ),
                          //                       Divider(
                          //                         color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                          //                         height: 0,
                          //                       ),
                          //                       const SizedBox(height: 16),
                          //                       Padding(
                          //                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          //                         child: TextWidget.subText(
                          //                           text: "Financial Year",
                          //                           theme: theme.isDarkMode,
                          //                         ),
                          //                       ),
                          //                       const SizedBox(height: 8),
                          //                       Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Container(
                          //         width: double.infinity,
                          //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          //         decoration: BoxDecoration(
                          //           color: Color(0xffF1F3F8),
                          //           border: Border.all(
                          //             color: colors.colorBlue,
                          //           ),
                          //           borderRadius: BorderRadius.circular(5),
                          //         ),
                          //         child: Row(
                          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             Material(
                          //               color: Colors.transparent,
                          //               borderRadius: BorderRadius.circular(20),
                          //               child: InkWell(
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 splashColor: theme.isDarkMode
                          //                     ? colors.colorWhite.withOpacity(0.1)
                          //                     : colors.colorBlack.withOpacity(0.1),
                          //                 onTap: (){},
                          //                 child: Container(
                          //                   width: 40,
                          //                   height: 40,
                          //                   alignment: Alignment.center,
                          //                   child: Icon(
                          //                     Icons.chevron_left,
                          //                     size: 24,
                          //                     color: theme.isDarkMode
                          //                             ? colors.colorWhite
                          //                             : colors.colorBlack,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //             TextWidget.subText(
                          //               text: "Apr 2025 - Mar 2026",
                          //               theme: theme.isDarkMode,
                          //               fw: 1,
                          //             ),
                          //             Material(
                          //               color: Colors.transparent,
                          //               borderRadius: BorderRadius.circular(20),
                          //               child: InkWell(
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 splashColor: theme.isDarkMode
                          //                     ? colors.colorWhite.withOpacity(0.1)
                          //                     : colors.colorBlack.withOpacity(0.1),
                          //                 onTap: () {

                          //                 },
                          //                 child: Container(
                          //                   width: 40,
                          //                   height: 40,
                          //                   alignment: Alignment.center,
                          //                   child: Icon(
                          //                     Icons.chevron_right,
                          //                     size: 24,
                          //                     color:theme.isDarkMode
                          //                             ? colors.colorWhite
                          //                             : colors.colorBlack,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          //                       const SizedBox(height: 24),
                          //                       Padding(
                          //                         padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          //                         child: SizedBox(
                          //                           width: double.infinity,
                          //                           height: 48,
                          //                           child: OutlinedButton(
                          //                             style: OutlinedButton.styleFrom(
                          //                               elevation: 0,
                          //                               minimumSize: const Size(0, 48),
                          //                               backgroundColor: theme.isDarkMode
                          //                                   ? colors.primaryDark
                          //                                   : colors.primaryLight,
                          //                               shape: RoundedRectangleBorder(
                          //                                 borderRadius: BorderRadius.circular(5),
                          //                               ),
                          //                               padding: EdgeInsets.zero,
                          //                             ),
                          //                             onPressed: () {
                          //                               // Download functionality will be added later
                          //                             },
                          //                             child: TextWidget.subText(
                          //                               text: "Download",
                          //                               theme: theme.isDarkMode,
                          //                               color: colors.colorWhite,
                          //                               fw: 2,
                          //                               align: TextAlign.center,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         );
                          //         break;
                          // case 'Holdings':
                          //   await ledgerdate.getCurrentDate('else');

                          //   Navigator.pushNamed(context, Routes.holdingscreen,
                          //       arguments: "DDDDD");
                          //   break;
                          case 'Positions':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.reportPositions);
                            }
                            break;
                          // case 'Profit & Loss':
                          //   // ledgerdate.fetchposition(context);
                          //   if (ledgerdate.pnlAllData == null) {
                          //     await ledgerdate.getCurrentDate('else');
                          //     ledgerdate.fetchpnldata(context,
                          //         ledgerdate.startDate, ledgerdate.today, true);
                          //   }

                          //   Navigator.pushNamed(context, Routes.pnlscreen,
                          //       arguments: "DDDDD");
                          //   break;

                          // case 'Tradebook':
                          //   // await ledgerdate.getCurrentDate('tradebook');
                          //   if (ledgerdate.tradebookdata == null) {
                          //     await ledgerdate.getCurrentDate('tradebook');
                          //     ledgerdate.fetchtradebookdata(context,
                          //         ledgerdate.startDate, ledgerdate.today);
                          //   }
                          //   Navigator.pushNamed(context, Routes.tradebook,
                          //       arguments: "DDDDD");
                          //   break;
                          case 'Tradebook':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.tradebook);
                            }
                            break;

                          case 'Contract Note':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.contractNote);
                            }
                            break;

                          case 'CA Events':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.corporateActions);
                            }
                            break;
                          case 'PDF Download':
                            if (onNavigateToScreen != null) {
                              onNavigateToScreen!(ScreenType.pdfDownload);
                            }
                            break;
                          // case 'Positions':
                          //  ledgerdate.redirecttopositionsbeta(context);
                          //   break;
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
Widget downloadBottomSheet(BuildContext context, ThemesProvider theme, LDProvider ledgerdate) {
  String selectedFormat = "PDF";

  return StatefulBuilder(
    builder: (context, setState) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                    text: "Client Master(CMR)",
                    theme: theme.isDarkMode,
                    fw: 1,
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark.withOpacity(0.15)
                          : colors.splashColorLight.withOpacity(0.15),
                      highlightColor: theme.isDarkMode
                          ? colors.splashColorDark.withOpacity(0.08)
                          : colors.splashColorLight.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: !theme.isDarkMode
                              ? colors.colorGrey
                              : colors.colorWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Options (PDF / Excel) - Updated Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PDF Option
                  InkWell(
                    onTap: () {
                      ledgerdate.fetchcmrdownload(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SvgPicture.asset(assets.pdfIcon,
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download, size: 16, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                              TextWidget.subText(
                                text: " PDF",
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                fw: 0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Excel Option
                  // InkWell(
                  //   onTap: () {
                  //     ledgerdate.fetchcmrdownload(context);
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Column(
                  //       children: [
                  //         SvgPicture.asset(assets.excelIcon,
                  //           height: 60,
                  //           width: 60,
                  //           fit: BoxFit.contain,
                  //         ),
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Icon(Icons.download, size: 16, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                  //             TextWidget.subText(
                  //               text: " Excel",
                  //               theme: theme.isDarkMode,
                  //               color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  //               fw: 0,
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 30),

              // Download Button - Updated to handle both formats
              
            ],
          ),
        ),
      );
    },
  );
}
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