import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; 
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/api_key_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/fund_provider.dart';
import '../../provider/notification_provider.dart';

import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart'; 
import '../../sharedWidget/functions.dart'; 
import 'need_help_screen.dart';

class UserAccountScreen extends ConsumerWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final userProfile = watch(userProfileProvider);
    final theme = watch(themeProvider);
    // final portfolio = watch(portfolioProvider);
    // final indexProvide = watch(indexListProvider);
    final funds = watch(fundProvider);
     final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";
    return userProfile.loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: userProfile.profileMenu.length,
                    itemBuilder: (context, int index) {
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        onTap: () async {
                          await funds.fetchFunds(context);
                          if (index == 0) {
                            Navigator.pushNamed(context, Routes.fund);
                          }
                        else  if (index == 1) {
                            Navigator.pushNamed(context, Routes.myAcc);
                          } else if (index == 2) {
                            Navigator.pushNamed(context, Routes.reports);
                          } else if (index == 3) {
                            await context
                                .read(fundProvider)
                                .fetchHstoken(context);
                            Navigator.pushNamed(
                                context, Routes.reportWebViewApp,
                                arguments: "corporateaction");
                          } else if (index == 4) {
                            await context
                                .read(fundProvider)
                                .fetchHstoken(context);
                            Navigator.pushNamed(
                                context, Routes.reportWebViewApp,
                                arguments: "pledge");
                          } else if (index == 6) {
                            await context
                                .read(userProfileProvider)
                                .fetchsetting();
                            await context
                                .read(apikeyprovider)
                                .fetchapikey(context);
                            Navigator.pushNamed(
                                context, Routes.profilesettingscreen);
                          } else if (index == 5) {
                            await Share.share(
                              "Get 20% of brokerage for trades made by your friends.\n ${Uri.parse(reflink)}",
                            );
                          } else if (index == 7) {
                            await context
                                .read(notificationprovider)
                                .fetchexchagemsg(context);

                            await context
                                .read(notificationprovider)
                                .fetchbrokermsg(context);
                            Navigator.pushNamed(
                                context, Routes.notificationpage);
                          } else {
                             showModalBottomSheet(
                                  useSafeArea: true,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16))),
                                  context: context,
                                  builder: (context) {
                                    return const NeedHelpScreen( );
                                  });
                            // Navigator.pushNamed(context, Routes.needHelp);
                          }
                        },
                        dense: true,
                        minLeadingWidth: 20,
                        leading: SvgPicture.asset(
                          userProfile.profileMenu[index]['leading'],
                          width: 19,
                          color: const Color(0xff666666),
                        ),
                        title: Text(
                            "${index == 0 ? "₹${getFormatter(value: double.parse(funds.fundDetailModel!.avlMrg ?? "0.00"), v4d: false, noDecimal: false)}" : userProfile.profileMenu[index]['title']}",
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
                            if (index == 0) ...[
                              Container(
                                height: 32,
                                margin: const EdgeInsets.only(right: 12),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      backgroundColor: theme.isDarkMode
                                          ? colors.colorbluegrey
                                          : colors.colorBlack,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      )),
                                  onPressed: () async {
                                    await context
                                        .read(fundProvider)
                                        .fetchHstoken(context);
                                    Navigator.pushNamed(
                                        context, Routes.fundTransaction,
                                        arguments: "fund");
                                  },
                                  child: Text("Deposit Money",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          12,
                                          FontWeight.w500)),
                                ),
                              ),
                            ],
                            index == 5
                                ? TextButton(
                                    onPressed: () async {
                                      await Share.share(
                                        "Get 20% of brokerage for trades made by your friends.\n ${Uri.parse(reflink)}",
                                      );
                                    },
                                    child: Text(
                                      "Share",
                                      style: 
                                      theme.isDarkMode
                                      ?textStyles.darktextBtn
                                      :textStyles.textBtn,
                                    ))
                                : SvgPicture.asset(
                                    userProfile.profileMenu[index]['trailing'])
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                          
                            color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider, height: 0);
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            insetPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            title: const Text("Confirmation"),
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Are you sure you want to logout?")
                                ],
                              ),
                            ),
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
                                      ?colors.colorbluegrey
                                      :colors.colorBlack,
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
                        backgroundColor: theme.isDarkMode
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
                        ])),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Version 3.0.2 Build 1.0.32(01) Released on 31 Jul",
                    style: textStyle(
                        const Color(0xff666666), 11, FontWeight.w500)),
              )
            ],
          );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
