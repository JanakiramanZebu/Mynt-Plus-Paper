// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
//import 'package:url_launcher/url_launcher.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/api_key_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/bonds_provider.dart';
import '../../provider/fund_provider.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/ledger_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/thems.dart';
import '../../provider/transcation_provider.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/functions.dart';
import 'need_help_screen.dart';

// enum Availability { loading, available, unavailable }

class UserAccountScreen extends ConsumerWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final theme = ref.watch(themeProvider);
    final trancation = ref.watch(transcationProvider);
    final mf = ref.watch(mfProvider);
    final portfolio = ref.watch(portfolioProvider);
    final reportsprovider = ref.watch(ledgerProvider);
    final auth = ref.watch(authProvider);
    final indexProvide = ref.watch(indexListProvider);

    //  int currentYear = DateTime.now().year;
    final funds = ref.watch(fundProvider);
    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";
    return userProfile.loading
        ? const Center(child: CircularProgressIndicator())
        : TransparentLoaderScreen(
            isLoading: mf.bestmfloader!,
            child: Column(children: [
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: userProfile.profileMenu.length,
                    itemBuilder: (context, int index) {
                      final acttitle = userProfile.profileMenu[index]['title'];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        onTap: () async {
                          if (["Verified P&L", "Corporate Action", "CA Events", "Pledge & Unpledge", "OptionZ"].contains(acttitle)) {
                            await funds.fetchHstoken(context);
                          }
                          if (acttitle == "Fund") {
                            await funds.fetchFunds(context);
                            indexProvide.bottomMenu(2, context);
                            portfolio.changeTabIndex(2);
                            // Navigator.pushNamed(context, Routes.fund);
                          } else if (acttitle == "My Account") {
                            Navigator.pushNamed(context, Routes.myAcc);
                          } else if (acttitle == "Reports") {
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
                              reportsprovider.fetchtradebookdata(
                                  context,
                                  reportsprovider.startDate,
                                  reportsprovider.today);
                            }
                            if (reportsprovider.pdfdownload == null) {
                              await reportsprovider.getCurrentDate('else');
                              reportsprovider.fetchpdfdownload(
                                  context,
                                  reportsprovider.startDate,
                                  reportsprovider.today);
                            }
                            // if (reportsprovider.positiondata == null) {
                            //   reportsprovider.fetchposition(context);
                            // }
                            Navigator.pushNamed(context, Routes.reports);
                          } else if (acttitle == "Verified P&L") {
                            Navigator.pushNamed(
                                context, Routes.reportWebViewApp,
                                arguments: "tradeverify");
                          } else if (acttitle == "Corporate Action") {
                            Navigator.pushNamed(
                                context, Routes.reportWebViewApp,
                                arguments: "corporateaction");
                          } else if (acttitle == "CA Events") {
                            // await reportsprovider.getCurrentDate('caevent');
                            // // reportsprovider.fetchcaeventsdata(context,
                            // //       reportsprovider.startDate,
                            // //       reportsprovider.endDate);
                            // if (reportsprovider.caeventalldata == null) {
                            //   await reportsprovider.getCurrentDate('caevent');
                            //   reportsprovider.fetchcaeventsdata(
                            //       context,
                            //       reportsprovider.startDate,
                            //       reportsprovider.endDate);
                            // }
                            // reportsprovider.taxpnlExTabchange(0);
                            // Navigator.pushNamed(context, Routes.caeventmainpage,
                            //     arguments: "DDDDD");
                            Navigator.pushNamed(
                                context, Routes.reportWebViewApp,
                                arguments: "event");
                          } else if (acttitle == "Pledge & Unpledge") {
                            // reportsprovider.fetchpledgeandunpledge(context);
                            // reportsprovider.getCurrentDate("pandu");
                            // // if (reportsprovider.pledgeandunpledge == null) {
                            // //   reportsprovider.getCurrentDate("pandu");
                            // //   reportsprovider.fetchpledgeandunpledge(context);
                            // // }
                            // Navigator.pushNamed(context, Routes.pledgeandun,
                            //     arguments: "DDDDD");
                            Navigator.pushNamed(
                                context, Routes.reportWebViewApp,
                                arguments: "pledge");
                          } else if (acttitle == "IPO") {
                            Navigator.pushNamed(context, Routes.ipo);
                            // launch(
                            //     "https://mynt.zebuetrade.com/ipo?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                          } else if (acttitle == "Mutual Fund") {
                            mf.mfApicallinit(context, 0);
                          } else if (acttitle == "OptionZ") {
                            funds.optionZ(context);
                          } else if (acttitle == "Refer") {
                            await Share.share(
                              "Get 20% of brokerage for trades made by your friends.\n ${Uri.parse(reflink)}",
                            );
                          } else if (acttitle == "Settings") {
                            await ref
                                .read(userProfileProvider)
                                .fetchsetting();
                            await ref
                                .read(apikeyprovider)
                                .fetchapikey(context);
                            Navigator.pushNamed(
                                context, Routes.profilesettingscreen);
                          } else if (acttitle == "Notification") {
                            await ref
                                .read(notificationprovider)
                                .fetchexchagemsg(context);

                            await ref
                                .read(notificationprovider)
                                .fetchbrokermsg(context);
                            Navigator.pushNamed(
                                context, Routes.notificationpage);
                          } else if (acttitle == "Need Help?") {
                            showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16))),
                                context: context,
                                builder: (context) {
                                  return const NeedHelpScreen();
                                });
                          } else if (acttitle == "Bonds") {
                            await ref.read(bondsProvider).fetchAllBonds();
                            Navigator.pushNamed(context, Routes.bonds);
                          } else if (acttitle == "Rate Us") {
                            String devicesurl = TargetPlatform.iOS ==
                                    defaultTargetPlatform
                                ? "https://apps.apple.com/app/id6478270319?action=write-review"
                                : "https://play.google.com/store/apps/details?id=com.mynt.trading_app_zebu&reviewId=0";
                            launch(devicesurl);

                            //  await userProfile.setAppreview(context);
                            //  _inAppReview.requestReview();
                            // _inAppReview.openStoreListing(
                            //   appStoreId: "id6478270319",
                            //   microsoftStoreId: "com.mynt.trading_app_zebu",
                            // );
                          } else {
                            // await context
                            //     .read(mfProvider)
                            //     .fetchMFWatchlist(null, "", context, false);
                            // await ref.read(mfProvider).fetchMasterMF();
                            // Navigator.pushNamed(context, Routes.mf);
                          }
                        },
                        dense: true,
                        minLeadingWidth: 20,
                        leading: SvgPicture.asset(
                            userProfile.profileMenu[index]['leading'],
                            width: 19,
                            color: const Color(0xff666666)),
                        title: Text(
                            "${acttitle == "Fund" ? "₹${getFormatter(value: double.parse(funds.fundDetailModel!.avlMrg ?? "0.00"), v4d: false, noDecimal: false)}" : userProfile.profileMenu[index]['title']}",
                            style: textStyle(
                                Color(
                                    theme.isDarkMode ? 0xffffffff : 0xff000000),
                                16,
                                FontWeight.w500)),
                        subtitle: Text(
                            userProfile.profileMenu[index]['subTitle'],
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                const Color(0xff666666), 12, FontWeight.w500)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (acttitle == "Fund") ...[
                              Container(
                                  height: 32,
                                  width: 125,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          backgroundColor: theme.isDarkMode
                                              ? colors.colorbluegrey
                                              : colors.colorBlack,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50))),
                                      onPressed: () async {
                                        ref
                                            .read(transcationProvider)
                                            .fetchValidateToken(context);
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () async {
                                          await trancation.ip();
                                          await trancation.fetchupiIdView(
                                              trancation.bankdetails!
                                                  .dATA![trancation.indexss][1],
                                              trancation.bankdetails!
                                                      .dATA![trancation.indexss]
                                                  [2]);
                                          await trancation
                                              .fetchcwithdraw(context);
                                        });

                                        trancation.changebool(true);
                                        Navigator.pushNamed(
                                            context, Routes.fundscreen,
                                            arguments: trancation);
                                      },
                                      child: Text("Deposit Money",
                                          textAlign: TextAlign.center,
                                          style: textStyle(
                                              !theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              12,
                                              FontWeight.w500))))
                            ],
                            if (acttitle == "Refer") ...[
                              TextButton(
                                  onPressed: () async {
                                    await Share.share(
                                      "Get 20% of brokerage for trades made by your friends.\n ${Uri.parse(reflink)}",
                                    );
                                  },
                                  child: Text("Share",
                                      style: theme.isDarkMode
                                          ? textStyles.darktextBtn
                                          : textStyles.textBtn))
                            ]
                            // else if (acttitle == "Settings") ...[
                            //   TextButton(
                            //       onPressed: () async {
                            //         showDialog(
                            //           context: context,
                            //           builder: (BuildContext context) {
                            //             return AlertDialog(
                            //               backgroundColor: context
                            //                       .read(themeProvider)
                            //                       .isDarkMode
                            //                   ? const Color.fromARGB(
                            //                       255, 18, 18, 18)
                            //                   : colors.colorWhite,
                            //               titleTextStyle: textStyles
                            //                   .appBarTitleTxt
                            //                   .copyWith(
                            //                       color: context
                            //                               .read(themeProvider)
                            //                               .isDarkMode
                            //                           ? colors.colorWhite
                            //                           : colors.colorBlack),
                            //               titlePadding:
                            //                   const EdgeInsets.symmetric(
                            //                       horizontal: 14, vertical: 12),
                            //               shape: const RoundedRectangleBorder(
                            //                   borderRadius: BorderRadius.all(
                            //                       Radius.circular(14))),
                            //               scrollable: true,
                            //               contentPadding:
                            //                   const EdgeInsets.symmetric(
                            //                       horizontal: 14),
                            //               insetPadding:
                            //                   const EdgeInsets.symmetric(
                            //                       horizontal: 20),
                            //               title: const Text("Freeze Account!"),
                            //               content: SizedBox(
                            //                   width: MediaQuery.of(context)
                            //                       .size
                            //                       .width,
                            //                   child: Column(
                            //                       crossAxisAlignment:
                            //                           CrossAxisAlignment.start,
                            //                       children: [
                            //                         Text(
                            //                           "Are you sure you want to Freeze yor Account?",
                            //                           style: textStyle(
                            //                               theme.isDarkMode
                            //                                   ? colors
                            //                                       .colorWhite
                            //                                   : colors
                            //                                       .colorBlack,
                            //                               16,
                            //                               FontWeight.w600),
                            //                         ),
                            //                         const SizedBox(height: 10),
                            //                         Text(
                            //                           "* Note: Open order(s) will be cancelled, but position(s) will not be closed",
                            //                           style: textStyle(
                            //                               colors.colorGrey,
                            //                               12,
                            //                               FontWeight.w600),
                            //                         )
                            //                       ])),
                            //               actions: [
                            //                 TextButton(
                            //                     onPressed: () =>
                            //                         Navigator.of(context).pop(),
                            //                     child: Text("Cancel",
                            //                         style: textStyles.textBtn.copyWith(
                            //                             color: context
                            //                                     .read(
                            //                                         themeProvider)
                            //                                     .isDarkMode
                            //                                 ? colors
                            //                                     .colorLightBlue
                            //                                 : colors
                            //                                     .colorBlue))),
                            //                 ElevatedButton(
                            //                     onPressed: () async {
                            //                       userProfile
                            //                           .fetchFreezeAc(context);
                            //                     },
                            //                     style: ElevatedButton.styleFrom(
                            //                         elevation: 0,
                            //                         backgroundColor: theme
                            //                                 .isDarkMode
                            //                             ? colors.colorbluegrey
                            //                             : colors.colorBlack,
                            //                         shape:
                            //                             RoundedRectangleBorder(
                            //                                 borderRadius:
                            //                                     BorderRadius
                            //                                         .circular(
                            //                                             50))),
                            //                     child: Text("Continue",
                            //                         style: textStyle(
                            //                             !context
                            //                                     .read(
                            //                                         themeProvider)
                            //                                     .isDarkMode
                            //                                 ? colors.colorWhite
                            //                                 : colors.colorBlack,
                            //                             14,
                            //                             FontWeight.w500))),
                            //               ],
                            //             );
                            //           },
                            //         );
                            //       },
                            //       child: Text("Freeze Account",
                            //           style: theme.isDarkMode
                            //               ? textStyles.darktextBtn
                            //               : textStyles.textBtn))
                            // ]
                            else ...[
                              SvgPicture.asset(
                                  userProfile.profileMenu[index]['trailing'])
                            ]
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          height: 0);
                    }),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  ref.read(themeProvider).isDarkMode
                                      ? const Color.fromARGB(255, 18, 18, 18)
                                      : colors.colorWhite,
                              titleTextStyle: textStyles.appBarTitleTxt
                                  .copyWith(
                                      color:
                                          ref.read(themeProvider).isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack),
                              contentTextStyle: textStyles.menuTxt,
                              titlePadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14))),
                              scrollable: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              title: const Text("Confirmation"),
                              content: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Are you sure you want to logout?")
                                      ])),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text("No",
                                        style: textStyles.textBtn.copyWith(
                                            color: ref
                                                    .read(themeProvider)
                                                    .isDarkMode
                                                ? colors.colorLightBlue
                                                : colors.colorBlue))),
                                ElevatedButton(
                                    onPressed: () async {
                                      ref
                                          .read(authProvider)
                                          .fetchLogout(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: theme.isDarkMode
                                            ? colors.colorbluegrey
                                            : colors.colorBlack,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        )),
                                    child: Text("Yes",
                                        style: textStyle(
                                            !ref
                                                    .read(themeProvider)
                                                    .isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500))),
                              ],
                            );
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                          backgroundColor: userProfile.userloader
                              ? colors.colorGrey
                              : theme.isDarkMode
                                  ? colors.colorbluegrey
                                  : colors.colorBlack,
                          padding: const EdgeInsets.symmetric(vertical: 10.5),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/profile/logout.svg',
                              color: !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                            ),
                            const SizedBox(width: 8),
                            Text("Log Out",
                                style: textStyle(
                                    !theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600))
                          ]))),
              Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(auth.versiontext,
                      style: textStyle(
                          const Color(0xff666666), 11, FontWeight.w500)))
            ]));
  }
}
