// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:url_launcher/url_launcher.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/api_key_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/fund_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/thems.dart';
import '../../provider/transcation_provider.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/colors.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/functions.dart';
import 'need_help_screen.dart';

// enum Availability { loading, available, unavailable }

class UserAccountScreen extends ConsumerWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final userProfile = watch(userProfileProvider);
    final theme = watch(themeProvider);
    final trancation = watch(transcationProvider);
    //  int currentYear = DateTime.now().year;
    final funds = watch(fundProvider);
    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";
    var chips = [
      "profile",
      "ledger",
      "holding",
      "profile & loss",
      "pledge",
      "corporate action",
      "events",
      "verified p&l"
    ];
    return userProfile.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(0)),
                        child: InkWell(
                          onTap: () async {
                            await funds.fetchFunds(context);
                            Navigator.pushNamed(context, Routes.fund);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Funds",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(theme.isDarkMode
                                            ? 0xffffffff
                                            : 0xff000000),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const Icon(Icons.arrow_forward,
                                      size: 20, color: Color(0xff0037B7))
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "₹${getFormatter(value: double.parse(funds.fundDetailModel!.avlMrg ?? "0.00"), v4d: false, noDecimal: false)}",
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Color(theme.isDarkMode
                                        ? 0xffffffff
                                        : 0xff000000)),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Cash + Collateral - Margin Used ",
                                style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await trancation
                                              .fetchValidateToken(context);
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () async {
                                            await trancation.ip();
                                            await trancation.fetchupiIdView(
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][1],
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][2]);

                                            await trancation
                                                .fetchcwithdraw(context);
                                          });
                                          trancation.changebool(true);
                                          Navigator.pushNamed(
                                              context, Routes.fundscreen,
                                              arguments: trancation);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xffffffff),
                                          side: const BorderSide(
                                              color: Color(0xFF000000)),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(60))),
                                        ),
                                        label: Text("Add Fund",
                                            style: textStyle(
                                                const Color(0xFF000000),
                                                14,
                                                FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Flexible(
                                    child: SizedBox(
                                      height: 40,
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await trancation
                                              .fetchValidateToken(context);
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () async {
                                            await trancation.ip();
                                            await trancation.fetchupiIdView(
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][1],
                                                trancation.bankdetails!.dATA![
                                                    trancation.indexss][2]);

                                            await trancation
                                                .fetchcwithdraw(context);
                                          });
                                          trancation.changebool(false);
                                          Navigator.pushNamed(
                                              context, Routes.fundscreen,
                                              arguments: trancation);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xffffffff),
                                          side: const BorderSide(
                                              color: Color(0xFF000000)),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(60))),
                                        ),
                                        label: Text("Withdraw",
                                            style: textStyle(
                                                const Color(0xFF000000),
                                                14,
                                                FontWeight.w500)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )),
                    Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        thickness: 0.6,
                        height: 0),
                    productList(
                        'IPO',
                        "A company's first public stock offering.",
                        "assets/profileimage/prd-ipo.svg",
                        theme, () {
                      Navigator.pushNamed(context, Routes.ipo);
                      // launch(
                      //     "https://app.mynt.in/ipo?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                    }),
                    productList(
                        'Mutual Fund',
                        "Invest in experts managed portfolio.",
                        "assets/profileimage/prd-mf.svg",
                        theme, () async {
                      await funds.fetchHstoken(context);
                      // Navigator.pushNamed(context, Routes.mfmainscreen);
                      launch(
                          "https://app.mynt.in/mutualfund?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                    }),
                    productList('OptionZ', "Options Trading Platform.",
                        "assets/profileimage/prd-optz.svg", theme, () async {
                      await funds.fetchHstoken(context);
                      funds.optionZ(context);
                    }),
                    const SizedBox(height: 12),
                    ListTile(
                      minTileHeight: 18,
                      contentPadding: const EdgeInsets.fromLTRB(18, 4, 24, 0),
                      title: Row(
                        children: [
                          Text(
                            "Desk",
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(
                                    theme.isDarkMode ? 0xffffffff : 0xff000000),
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward,
                              size: 20, color: Color(0xff0037B7))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 0,
                        runSpacing: -18,
                        children: chips.map((chip) {
                          return ChoiceChip(
                            label: Text(
                              chip,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors().colorBlue),
                            ),
                            elevation: 0,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.all(0),
                            side: BorderSide.none,
                            selected: false, // Mark selected chip
                            onSelected: (isSelected) async {},
                            backgroundColor: theme.isDarkMode
                                ? const Color(0xff000000)
                                : const Color(0xffffffff),
                          );
                        }).toList(),
                      ),
                    ),
                    GridView.count(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 32),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.37,
                      children: [
                        ServiceCard(
                            icon: "assets/profileimage/privacy_settings.svg",
                            title: "Settings",
                            description: "Freeze Account",
                            actiontype: true,
                            action: () {}),
                        ServiceCard(
                            icon: "assets/profile/headphones.svg",
                            title: "Need Help ?",
                            description: "Contact & Follow us",
                            actiontype: false,
                            action: () {})
                      ],
                    ),

                    // const SizedBox(height: 32),

                    Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        thickness: 0.6,
                        height: 0),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/profileimage/referal.svg",
                                        width: 40,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await Share.share(
                                        "Get 20% of brokerage for trades made by your friends.\n ${Uri.parse(reflink)}",
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Share',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: AppColors().colorBlue,
                                            )),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward,
                                            size: 20, color: Color(0xff0037B7))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Invite your family and friends',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Get discount on brokerages by referring them with your referral link.',
                              ),
                            ])),
                    Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        thickness: 0.6,
                        height: 0),
                    const SizedBox(height: 2),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: TextButton(
                          onPressed: () {
                            String devicesurl = TargetPlatform.iOS ==
                                    defaultTargetPlatform
                                ? "https://apps.apple.com/app/id6478270319?action=write-review"
                                : "https://play.google.com/store/apps/details?id=com.mynt.trading_app_zebu&reviewId=0";
                            launch(devicesurl);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.star_rate_rounded,
                                      size: 30, color: Color(0xff0037B7)),
                                  Icon(Icons.star_rate_rounded,
                                      size: 30, color: Color(0xff0037B7)),
                                  Icon(Icons.star_rate_rounded,
                                      size: 30, color: Color(0xff0037B7)),
                                  Icon(Icons.star_rate_rounded,
                                      size: 30, color: Color(0xff0037B7)),
                                  Icon(Icons.star_rate_rounded,
                                      size: 30, color: Color(0xff0037B7)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('Write a Review',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: AppColors().colorBlue,
                                      )),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward,
                                      size: 20, color: Color(0xff0037B7))
                                ],
                              ),
                            ],
                          ),
                        )),
                    // Divider(
                    // color: theme.isDarkMode
                    //     ? colors.darkColorDivider
                    //     : colors.colorDivider,
                    // thickness: 0.6,
                    // height: 0),
                    // const SizedBox(height: 4),
                    // ListView.separated(
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     shrinkWrap: true,
                    //     itemCount: userProfile.profileMenu.length,
                    //     itemBuilder: (context, int index) {
                    //       final acttitle =
                    //           userProfile.profileMenu[index]['title'];
                    //       return ListTile(
                    //         contentPadding:
                    //             const EdgeInsets.symmetric(horizontal: 20),
                    //         onTap: () async {
                    //           if ([
                    //             'Verified P&L',
                    //             'Corporate Action',
                    //             'CA Events',
                    //             'pledge'
                    //           ].contains(acttitle)) {
                    //             await funds.fetchHstoken(context);
                    //           }
                    //           if (acttitle == "profile") {
                    //             Navigator.pushNamed(context, Routes.myAcc);
                    //           } else if (acttitle == "ledger") {
                    //             Navigator.pushNamed(context, Routes.reports);
                    //           } else if (acttitle == "Verified P&L") {
                    //             Navigator.pushNamed(
                    //                 context, Routes.reportWebViewApp,
                    //                 arguments: "tradeverify");
                    //           } else if (acttitle == "Corporate Action") {
                    //             Navigator.pushNamed(
                    //                 context, Routes.reportWebViewApp,
                    //                 arguments: "corporateaction");
                    //           } else if (acttitle == "CA Events") {
                    //             Navigator.pushNamed(
                    //                 context, Routes.reportWebViewApp,
                    //                 arguments: "event");
                    //           } else if (acttitle == "pledge") {
                    //             Navigator.pushNamed(
                    //                 context, Routes.reportWebViewApp,
                    //                 arguments: "pledge");
                    //           } else if (acttitle == "Settings") {
                    //             await context
                    //                 .read(userProfileProvider)
                    //                 .fetchsetting();
                    //             await context
                    //                 .read(apikeyprovider)
                    //                 .fetchapikey(context);
                    //             Navigator.pushNamed(
                    //                 context, Routes.profilesettingscreen);
                    //           } else if (acttitle == "Notification") {
                    //             await context
                    //                 .read(notificationprovider)
                    //                 .fetchexchagemsg(context);

                    //             await context
                    //                 .read(notificationprovider)
                    //                 .fetchbrokermsg(context);
                    //             Navigator.pushNamed(
                    //                 context, Routes.notificationpage);
                    //           } else if (acttitle == "Need Help?") {
                    //             showModalBottomSheet(
                    //                 useSafeArea: true,
                    //                 isScrollControlled: true,
                    //                 shape: const RoundedRectangleBorder(
                    //                     borderRadius: BorderRadius.vertical(
                    //                         top: Radius.circular(16))),
                    //                 context: context,
                    //                 builder: (context) {
                    //                   return const NeedHelpScreen();
                    //                 });
                    //           } else if (acttitle == "Rate Us") {
                    //             String devicesurl = TargetPlatform.iOS ==
                    //                     defaultTargetPlatform
                    //                 ? "https://apps.apple.com/app/id6478270319?action=write-review"
                    //                 : "https://play.google.com/store/apps/details?id=com.mynt.trading_app_zebu&reviewId=0";
                    //             launch(devicesurl);
                    //           }
                    //         },
                    //         dense: true,
                    //         minLeadingWidth: 20,
                    //         leading: SvgPicture.asset(
                    //             userProfile.profileMenu[index]['leading'],
                    //             // width: 18,
                    //             height: 20,
                    //             color: const Color(0xff666666)),
                    //         title: Text(
                    //             "${userProfile.profileMenu[index]['title']}",
                    //             style: textStyle(
                    //                 Color(theme.isDarkMode
                    //                     ? 0xffffffff
                    //                     : 0xff000000),
                    //                 16,
                    //                 FontWeight.w500)),
                    //         subtitle: Text(
                    //             userProfile.profileMenu[index]['subTitle'],
                    //             overflow: TextOverflow.ellipsis,
                    //             style: textStyle(const Color(0xff666666), 12,
                    //                 FontWeight.w500)),
                    //         trailing: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             if (acttitle == "Settings") ...[
                    //               TextButton(
                    //                   onPressed: () async {
                    //                     showDialog(
                    //                       context: context,
                    //                       builder: (BuildContext context) {
                    //                         return AlertDialog(
                    //                           backgroundColor: context
                    //                                   .read(themeProvider)
                    //                                   .isDarkMode
                    //                               ? const Color.fromARGB(
                    //                                   255, 18, 18, 18)
                    //                               : colors.colorWhite,
                    //                           titleTextStyle: textStyles
                    //                               .appBarTitleTxt
                    //                               .copyWith(
                    //                                   color: context
                    //                                           .read(
                    //                                               themeProvider)
                    //                                           .isDarkMode
                    //                                       ? colors.colorWhite
                    //                                       : colors.colorBlack),
                    //                           titlePadding:
                    //                               const EdgeInsets.symmetric(
                    //                                   horizontal: 14,
                    //                                   vertical: 12),
                    //                           shape:
                    //                               const RoundedRectangleBorder(
                    //                                   borderRadius:
                    //                                       BorderRadius.all(
                    //                                           Radius.circular(
                    //                                               14))),
                    //                           scrollable: true,
                    //                           contentPadding:
                    //                               const EdgeInsets.symmetric(
                    //                                   horizontal: 14),
                    //                           insetPadding:
                    //                               const EdgeInsets.symmetric(
                    //                                   horizontal: 20),
                    //                           title:
                    //                               const Text("Freeze Account!"),
                    //                           content: SizedBox(
                    //                               width: MediaQuery.of(context)
                    //                                   .size
                    //                                   .width,
                    //                               child: Column(
                    //                                   crossAxisAlignment:
                    //                                       CrossAxisAlignment
                    //                                           .start,
                    //                                   children: [
                    //                                     Text(
                    //                                       "Are you sure you want to Freeze yor Account?",
                    //                                       style: textStyle(
                    //                                           theme.isDarkMode
                    //                                               ? colors
                    //                                                   .colorWhite
                    //                                               : colors
                    //                                                   .colorBlack,
                    //                                           16,
                    //                                           FontWeight.w600),
                    //                                     ),
                    //                                     const SizedBox(
                    //                                         height: 10),
                    //                                     Text(
                    //                                       "* Note: Open order(s) will be cancelled, but position(s) will not be closed",
                    //                                       style: textStyle(
                    //                                           colors.colorGrey,
                    //                                           12,
                    //                                           FontWeight.w600),
                    //                                     )
                    //                                   ])),
                    //                           actions: [
                    //                             TextButton(
                    //                                 onPressed: () =>
                    //                                     Navigator.of(context)
                    //                                         .pop(),
                    //                                 child: Text("Cancel",
                    //                                     style: textStyles.textBtn.copyWith(
                    //                                         color: context
                    //                                                 .read(
                    //                                                     themeProvider)
                    //                                                 .isDarkMode
                    //                                             ? colors
                    //                                                 .colorLightBlue
                    //                                             : colors
                    //                                                 .colorBlue))),
                    //                             ElevatedButton(
                    //                                 onPressed: () async {
                    //                                   userProfile.fetchFreezeAc(
                    //                                       context);
                    //                                 },
                    //                                 style: ElevatedButton.styleFrom(
                    //                                     elevation: 0,
                    //                                     backgroundColor: theme
                    //                                             .isDarkMode
                    //                                         ? colors
                    //                                             .colorbluegrey
                    //                                         : colors.colorBlack,
                    //                                     shape: RoundedRectangleBorder(
                    //                                         borderRadius:
                    //                                             BorderRadius
                    //                                                 .circular(
                    //                                                     50))),
                    //                                 child: Text("Continue",
                    //                                     style: textStyle(
                    //                                         !context
                    //                                                 .read(
                    //                                                     themeProvider)
                    //                                                 .isDarkMode
                    //                                             ? colors
                    //                                                 .colorWhite
                    //                                             : colors.colorBlack,
                    //                                         14,
                    //                                         FontWeight.w500))),
                    //                           ],
                    //                         );
                    //                       },
                    //                     );
                    //                   },
                    //                   child: Text("Freeze Account",
                    //                       style: theme.isDarkMode
                    //                           ? textStyles.darktextBtn
                    //                           : textStyles.textBtn))
                    //             ] else ...[
                    //               SvgPicture.asset(userProfile
                    //                   .profileMenu[index]['trailing'])
                    //             ]
                    //           ],
                    //         ),
                    //       );
                    //     },
                    //     separatorBuilder: (BuildContext context, int index) {
                    //       return Divider(
                    //           color: theme.isDarkMode
                    //               ? colors.darkColorDivider
                    //               : colors.colorDivider,
                    //           height: 0);
                    //     }),
                  ],
                ),
              ),
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
                                context.read(themeProvider).isDarkMode
                                    ? const Color.fromARGB(255, 18, 18, 18)
                                    : colors.colorWhite,
                            titleTextStyle: textStyles.appBarTitleTxt.copyWith(
                                color: context.read(themeProvider).isDarkMode
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
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("No",
                                      style: textStyles.textBtn.copyWith(
                                          color: context
                                                  .read(themeProvider)
                                                  .isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue))),
                              ElevatedButton(
                                  onPressed: () async {
                                    context
                                        .read(authProvider)
                                        .fetchLogout(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: theme.isDarkMode
                                          ? colors.colorbluegrey
                                          : colors.colorBlack,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      )),
                                  child: Text("Yes",
                                      style: textStyle(
                                          !context
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
                child: Text("Version 3.0.2 Build 1.0.64(01) Released on 15 Feb",
                    style: textStyle(
                        const Color(0xff666666), 11, FontWeight.w500)))
          ]);
  }

  Widget productList(String title, String subtitle, String image,
      ThemesProvider theme, VoidCallback action) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              elevation: 0,
              backgroundColor: Colors.transparent),
          onPressed: action,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(18, 16, 24, 16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 18,
                          color:
                              Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward,
                        size: 20, color: Color(0xff0037B7))
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xffEBF1FF),
                  borderRadius: BorderRadius.circular(60)),
              child: SvgPicture.asset(
                image,
                width: 32,
                // color: AppColors().colorBlue.withOpacity(0.4),
              ),
            ),
          ),
        ),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            thickness: 0.6,
            height: 0),
      ],
    );
  }

  Widget ServiceCard(
      {required String icon,
      required String title,
      required String description,
      required bool actiontype,
      required VoidCallback action
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffdddddd), width: 1),
        // gradient: const LinearGradient(
        //   colors: [
        //     Color(0xFFFFFFFF), // White at 10%
        //     Color(0xFFF1F3F8), // Light Gray at 60%
        //   ],
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   stops: [0.1, 0.6], // 10% and 60%
        // ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 36,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: action,
            child: Text(
              description,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: actiontype ? AppColors().colorBlue : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
