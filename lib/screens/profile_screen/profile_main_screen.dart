// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../provider/mf_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:url_launcher/url_launcher.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/api_key_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/fund_provider.dart';
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
  Widget build(BuildContext context, ScopedReader watch) {
    final userProfile = watch(userProfileProvider);
    final theme = watch(themeProvider);
    final trancation = watch(transcationProvider);
    //  int currentYear = DateTime.now().year;
    final funds = watch(fundProvider);
    final mf = watch(mfProvider);
    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";
    List chips = [
      "profile",
      "report",
      "holding",
      "profile & loss",
      "pledge",
      "corporate action",
      "events",
      "verified p&l"
    ];
    return
        // userProfile.loading
        //     ? const Center(child: CircularProgressIndicator())
        //     :
        Stack(
      children: [
        Positioned.fill(
          child: ListView(
              shrinkWrap: false,
              physics: const ScrollPhysics(),
              children: [
                InkWell(
                  onTap: () async {
                    await funds.fetchFunds(context);
                    Navigator.pushNamed(context, Routes.fund);
                  },
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Funds",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(theme.isDarkMode
                                        ? 0xffffffff
                                        : 0xff000000),
                                    fontWeight: FontWeight.w600),
                              ),
                              Icon(Icons.arrow_forward,
                                  size: 20,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue)
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            trancation.bankdetails!
                                                .dATA![trancation.indexss][1],
                                            trancation.bankdetails!
                                                .dATA![trancation.indexss][2]);

                                        await trancation
                                            .fetchcwithdraw(context);
                                      });
                                      trancation.changebool(true);
                                      Navigator.pushNamed(
                                          context, Routes.fundscreen,
                                          arguments: trancation);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color: theme.isDarkMode
                                            ? const Color(0xFFffffff)
                                            : const Color(0xFF000000),
                                      ),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(60))),
                                    ),
                                    label: Text("Add Fund",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? const Color(0xFFffffff)
                                                : const Color(0xFF000000),
                                            14,
                                            FontWeight.w600)),
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
                                            trancation.bankdetails!
                                                .dATA![trancation.indexss][1],
                                            trancation.bankdetails!
                                                .dATA![trancation.indexss][2]);

                                        await trancation
                                            .fetchcwithdraw(context);
                                      });
                                      trancation.changebool(false);
                                      Navigator.pushNamed(
                                          context, Routes.fundscreen,
                                          arguments: trancation);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color: theme.isDarkMode
                                            ? const Color(0xFFffffff)
                                            : const Color(0xFF000000),
                                      ),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(60))),
                                    ),
                                    label: Text("Withdraw",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? const Color(0xFFffffff)
                                                : const Color(0xFF000000),
                                            14,
                                            FontWeight.w500)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                ),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    thickness: 0.6,
                    height: 0),
                productList('IPO', "A company's first public stock offering.",
                    "assets/profileimage/prd-ipo.svg", theme, () {
                  Navigator.pushNamed(context, Routes.ipo);
                  // launch(
                  //     "https://app.mynt.in/ipo?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                }),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    thickness: 0.6,
                    height: 0),
                productList(
                    'Mutual Fund',
                    "Invest in experts managed portfolio.",
                    "assets/profileimage/prd-mf.svg",
                    theme, () async {
                  // await portfolio.fetchMFHoldings(context);
                  await mf.fetchMFCategoryType();
                  // await mf.fetchmfNFO(context);
                  await mf.fetchMFWatchlist("", "", context, true, "");
                  Navigator.pushNamed(context, Routes.mfmainscreen);
                  // launch(
                  //     "https://app.mynt.in/mutualfund?sUserId=${pref.clientId}&sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}");
                }),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    thickness: 0.6,
                    height: 0),
                productList('OptionZ', "Options Trading Platform.",
                    "assets/profileimage/prd-optz.svg", theme, () async {
                  await funds.fetchHstoken(context);
                  funds.optionZ(context);
                }),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    thickness: 0.6,
                    height: 0),
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
                      Icon(Icons.arrow_forward,
                          size: 20,
                          color: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue)
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                        spacing: 4,
                        children: List.generate(
                            chips.length,
                            (index) => ChoiceChip(
                                  pressElevation: 0,
                                  label: Text(
                                    chips[index],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.isDarkMode
                                            ? colors.colorLightBlue
                                            : colors.colorBlue),
                                  ),
                                  elevation: 0,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.all(0),
                                  side: BorderSide.none,
                                  selected: false, // Mark selected chip
                                  onSelected: (isSelected) async {
                                    if ([
                                      "report",
                                      "holding",
                                      "profile & loss",
                                      "pledge",
                                      "corporate action",
                                      "events",
                                      "verified p&l"
                                    ].contains(chips[index])) {
                                      await funds.fetchHstoken(context);
                                    }
                                    if (chips[index] == "profile") {
                                      Navigator.pushNamed(
                                          context, Routes.myAcc);
                                    } else if (chips[index] == "report") {
                                      Navigator.pushNamed(
                                          context, Routes.reports);
                                    } else if (chips[index] == "holding") {
                                      Navigator.pushNamed(
                                          context, Routes.reportWebViewApp,
                                          arguments: "holding");
                                    } else if (chips[index] ==
                                        "profile & loss") {
                                      Navigator.pushNamed(
                                          context, Routes.reportWebViewApp,
                                          arguments: "pnl");
                                    } else if (chips[index] == "verified p&l") {
                                      Navigator.pushNamed(
                                          context, Routes.reportWebViewApp,
                                          arguments: "tradeverify");
                                    } else if (chips[index] ==
                                        "corporate action") {
                                      Navigator.pushNamed(
                                          context, Routes.reportWebViewApp,
                                          arguments: "corporateaction");
                                    } else if (chips[index] == "events") {
                                      Navigator.pushNamed(
                                          context, Routes.reportWebViewApp,
                                          arguments: "event");
                                    } else if (chips[index] == "pledge") {
                                      Navigator.pushNamed(
                                          context, Routes.reportWebViewApp,
                                          arguments: "pledge");
                                    }
                                  },
                                  backgroundColor: theme.isDarkMode
                                      ? const Color(0xff000000)
                                      : const Color(0xffffffff),
                                )))),
                Row(
                  children: [
                    ServiceCard(
                        icon: "assets/profileimage/privacy_settings.svg",
                        title: "Settings",
                        description: "Freeze Account",
                        actiontype: true,
                        action: () async {
                          await context
                              .read(userProfileProvider)
                              .fetchsetting();
                          await context
                              .read(apikeyprovider)
                              .fetchapikey(context);
                          Navigator.pushNamed(
                              context, Routes.profilesettingscreen);
                        },
                        subaction: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    context.read(themeProvider).isDarkMode
                                        ? const Color.fromARGB(255, 18, 18, 18)
                                        : colors.colorWhite,
                                titleTextStyle: textStyles.appBarTitleTxt
                                    .copyWith(
                                        color: context
                                                .read(themeProvider)
                                                .isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack),
                                titlePadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14))),
                                scrollable: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                insetPadding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                title: const Text("Freeze Account!"),
                                content: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Are you sure you want to Freeze yor Account?",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                16,
                                                FontWeight.w600),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "* Note: Open order(s) will be cancelled, but position(s) will not be closed",
                                            style: textStyle(colors.colorGrey,
                                                12, FontWeight.w600),
                                          )
                                        ])),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("Cancel",
                                          style: textStyles.textBtn.copyWith(
                                              color: context
                                                      .read(themeProvider)
                                                      .isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue))),
                                  ElevatedButton(
                                      onPressed: () async {
                                        userProfile.fetchFreezeAc(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: theme.isDarkMode
                                              ? colors.colorbluegrey
                                              : colors.colorBlack,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50))),
                                      child: Text("Continue",
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
                        theme: theme),
                    ServiceCard(
                        icon: "assets/profile/headphones.svg",
                        title: "Need Help ?",
                        description: "Contact & Follow us",
                        actiontype: false,
                        action: () {
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
                        },
                        subaction: () {},
                        theme: theme)
                  ],
                ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/profileimage/referal.svg",
                                    width: 40,
                                    color: theme.isDarkMode
                                        ? colors.colorLightBlue
                                        : colors.colorBlue,
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
                                          color: theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue,
                                        )),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward,
                                        size: 20,
                                        color: theme.isDarkMode
                                            ? colors.colorLightBlue
                                            : colors.colorBlue)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Invite your family and friends',
                            style: TextStyle(
                              color: Color(
                                  theme.isDarkMode ? 0xffffffff : 0xff000000),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                              'Get discount on brokerages by referring them with your referral link.',
                              style: TextStyle(
                                color: Color(
                                    theme.isDarkMode ? 0xffffffff : 0xff000000),
                              )),
                        ])),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    thickness: 0.6,
                    height: 0),
                const SizedBox(height: 2),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.star_rate_rounded,
                                  size: 30,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue),
                              Icon(Icons.star_rate_rounded,
                                  size: 30,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue),
                              Icon(Icons.star_rate_rounded,
                                  size: 30,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue),
                              Icon(Icons.star_rate_rounded,
                                  size: 30,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue),
                              Icon(Icons.star_rate_rounded,
                                  size: 30,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Write a Review',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: theme.isDarkMode
                                        ? colors.colorLightBlue
                                        : colors.colorBlue,
                                  )),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward,
                                  size: 20,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue)
                            ],
                          ),
                        ],
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: context
                                          .read(themeProvider)
                                          .isDarkMode
                                      ? const Color.fromARGB(255, 18, 18, 18)
                                      : colors.colorWhite,
                                  titleTextStyle: textStyles.appBarTitleTxt
                                      .copyWith(
                                          color: context
                                                  .read(themeProvider)
                                                  .isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack),
                                  contentTextStyle: textStyles.menuTxt,
                                  titlePadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(14))),
                                  scrollable: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  title: const Text("Confirmation"),
                                  content: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Are you sure you want to logout?")
                                          ])),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
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
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.5),
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
                              ])),
                    )),
                Center(
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                          "Version 3.0.2 Build 1.0.64(01) Released on 15 Feb",
                          style: textStyle(
                              const Color(0xff666666), 11, FontWeight.w500))),
                )
              ]),
        ),
      ],
    );
  }

  Widget productList(String title, String subtitle, String image,
      ThemesProvider theme, VoidCallback action) {
    return InkWell(
      onTap: action,
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
                      color: Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward,
                    size: 20,
                    color: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue)
              ],
            ),
            const SizedBox(height: 8),
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
              color: theme.isDarkMode
                  ? const Color(0xff666666).withOpacity(0.4)
                  : const Color(0xffEBF1FF),
              borderRadius: BorderRadius.circular(60)),
          child: SvgPicture.asset(
            image,
            width: 32,
            color: theme.isDarkMode
                ? const Color(0xffEBF1FF).withOpacity(0.8)
                : const Color(0xff000000),
          ),
        ),
      ),
    );
  }

  Widget ServiceCard(
      {required String icon,
      required String title,
      required String description,
      required bool actiontype,
      required VoidCallback action,
      required VoidCallback subaction,
      required ThemesProvider theme}) {
    return Expanded(
      child: InkWell(
        onTap: action,
        child: Container(
          margin:
              const EdgeInsets.only(left: 18, right: 18, top: 24, bottom: 30),
          decoration: BoxDecoration(
            border: Border.all(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
                width: 0.6),
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
                color: theme.isDarkMode
                    ? const Color(0xffffffff)
                    : const Color(0xff000000),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: subaction,
                child: Text(
                  description,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: actiontype
                        ? theme.isDarkMode
                            ? colors.colorLightBlue
                            : colors.colorBlue
                        : colors.colorGrey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
