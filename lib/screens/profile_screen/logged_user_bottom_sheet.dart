// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/core/api_link.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/auth_provider.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class LoggedUserBottomSheet extends ConsumerWidget {
  final String initRoute;
  const LoggedUserBottomSheet({super.key, required this.initRoute});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final loggedUser = watch(authProvider);
    final user = watch(userProfileProvider);
    final marketWatch = watch(marketWatchProvider);
    final theme = watch(themeProvider);
    final Preferences pref = locator<Preferences>();
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: loggedUser.loggedMobile.length > 3 ? 0.79 : 0.35,
        minChildSize: 0.25,
        maxChildSize: loggedUser.loggedMobile.length < 3 ? 0.5 : 0.9,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xff999999),
                      blurRadius: 4.0,
                      offset: Offset(2.0, 0.0))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomDragHandler(),
                Padding(
                    padding: const EdgeInsets.only(left: 14.0, bottom: 10),
                    child: Text("Add / Switch to account",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w500))),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    shrinkWrap: true,
                    itemCount: loggedUser.loggedMobile.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const ListDivider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        onTap: () async {
                          final localstorage =
                              await SharedPreferences.getInstance();
                          pref.setClientId(
                              loggedUser.loggedMobile[index].clientId);

                          pref.setClientMob(
                              loggedUser.loggedMobile[index].mobile);
                          pref.setClientSession(
                              loggedUser.loggedMobile[index].sesstion);
                          pref.setClientName(
                              loggedUser.loggedMobile[index].userName);
                          // localstorage.setString(
                          //     "mobileNum", loggedUser.loggedMobile[index].mobile);
                          // localstorage.setString(
                          //     "userId", loggedUser.loggedMobile[index].clientId);
                          // localstorage.setString(
                          //     "session", loggedUser.loggedMobile[index].sesstion);
                          localstorage.setString("userName",
                              loggedUser.loggedMobile[index].userName);

                          // ApiLinks.userID =
                          //     localstorage.getString("userId") ?? "";
                          // ApiLinks.session =
                          //     localstorage.getString("session") ?? "";

                          ApiLinks.userName = ApiLinks.userName =
                              localstorage.getString("userName") ?? "";
                          marketWatch.changeWlName("", "No");

                          await marketWatch.fetchMWList(context);

                          if (marketWatch.marketWatchlist!.stat == "Ok") {
                            await context
                                .read(portfolioProvider)
                                .fetchHoldings(context, "");
                            context.read(portfolioProvider).changeTabIndex(0);
                            //  await   context
                            //               .read(portfolioProvider).   fetchMFHoldings(context);
                            await context
                                .read(portfolioProvider)
                                .fetchPositionBook(context, false);
                            await context
                                .read(orderProvider)
                                .fetchOrderBook(context, false);
                            await context
                                .read(orderProvider)
                                .fetchTradeBook(context);

                            await context
                                .read(orderProvider)
                                .fetchGTTOrderBook(context, "initLoad");
                            await marketWatch.fetchPendingAlert(context);
                            await user.fetchUserDetail(
                                context,
                                loggedUser.loggedMobile[index].clientId,
                                loggedUser.loggedMobile[index].sesstion,
                                "switchAcc");
                          }

                          // Navigator.pop(context);

                          // loggedUser.loginMethCtrl.text =
                          //     loggedUser.loggedMobile[index].mobile;
                          // if (user.userDetailModel!.emsg ==
                          //     "Session Expired :  Invalid Session Key") {
                          //   loggedUser.loginMethCtrl.text =
                          //       localstorage.getString("userId") ?? "";

                          //   Navigator.of(context).pop();
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //       errorSnackBar('${user.userDetailModel!.emsg}'));
                          //   Navigator.pushNamedAndRemoveUntil(
                          //       context,
                          //       Routes.loginScreen,
                          //       arguments: "deviceLogin",
                          //       (route) => false);
                          // } else if (initRoute == "initialRoute") {
                          //   await loggedUser.fetchLocalData();
                          //   await loggedUser.deviceAuth(context);
                          //   // context
                          //   //     .read(indexListProvider)
                          //   //     .getDeafultIndexList(context);
                          //   // await context
                          //   //     .read(marketWatchProvider)
                          //   //     .fetchMWList(context);
                          //   Navigator.of(context).pop();
                          //   Navigator.pushNamedAndRemoveUntil(
                          //       context, Routes.homeScreen, (route) => false);
                          // } else {

                          // }
                        },
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        title: Text(loggedUser.loggedMobile[index].mobile,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        subtitle: Text(
                            "User ID ${loggedUser.loggedMobile[index].clientId}",
                            style: textStyle(
                                const Color(0xff666666), 12, FontWeight.w500)),
                        trailing: loggedUser.loggedMobile[index].clientId ==
                                pref.clientId
                            ? Text("Active",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorLightBlue
                                        : colors.colorBlue,
                                    13,
                                    FontWeight.w600))
                            : Container(
                                width: .3,
                              ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: OutlinedButton(
                      onPressed: () {
                        ApiLinks.userName = "";
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.loginScreen,
                            arguments: "login");
                      },
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              width: 1.4,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack),
                          padding: const EdgeInsets.symmetric(vertical: 10.5),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(assets.addCircleIcon,
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack),
                            const SizedBox(width: 8),
                            Text("Add another account",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500))
                          ])),
                ),
                const SizedBox(height: 12)
              ],
            ),
          );
        });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
