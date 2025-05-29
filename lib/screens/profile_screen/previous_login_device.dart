import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/core/api_link.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/auth_provider.dart';
import '../../provider/network_state_provider.dart';
// import '../../provider/user_profile_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/no_internet_widget.dart';

class PreviousLoginDecive extends StatefulWidget {
  const PreviousLoginDecive({super.key});

  @override
  State<PreviousLoginDecive> createState() => _PreviousLoginDeciveState();
}

class _PreviousLoginDeciveState extends State<PreviousLoginDecive> {
  @override
  void initState() {
    // ref.read(networkStateProvider).networkStream();
    super.initState();
  }

  final Preferences pref = locator<Preferences>();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back behavior
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        await showExitPopup(); // Call the exit popup function
      },
      child: Consumer(builder: (context, WidgetRef ref, _) {
        final loggedUser = ref.watch(authProvider);
        // final user = ref.watch(userProfileProvider);
        final internet = ref.watch(networkStateProvider);
        return Scaffold(
          appBar: AppBar(
              elevation: .2,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(
                "Previously signed in account's on this device",
                style: textStyle(const Color(0xff000000), 15, FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              )),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: loggedUser.loggedMobile.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                            height: 1,
                            thickness: 1,
                            color: colors.colorDivider);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          onTap: internet.connectionStatus ==
                                  ConnectivityResult.none
                              ? null
                              : () async {
                                  pref.setClientId(
                                      loggedUser.loggedMobile[index].clientId);

                                  pref.setClientMob(
                                      loggedUser.loggedMobile[index].mobile);
                                  pref.setClientSession(
                                      loggedUser.loggedMobile[index].sesstion);
                                  pref.setClientName(
                                      loggedUser.loggedMobile[index].userName);

                                  final localstorage =
                                      await SharedPreferences.getInstance();

                                  // localstorage.setString("mobileNum",
                                  //     loggedUser.loggedMobile[index].mobile);
                                  // localstorage.setString("userId",
                                  //     loggedUser.loggedMobile[index].clientId);
                                  // localstorage.setString("session",
                                  //     loggedUser.loggedMobile[index].sesstion);
                                  localstorage.setString("userName",
                                      loggedUser.loggedMobile[index].userName);

                                  setState(() {
                                    ApiLinks.userName = ApiLinks.userName =
                                        localstorage.getString("userName") ??
                                            "";
                                    // ApiLinks.userID =
                                    //     localstorage.getString("userId") ?? "";
                                    // ApiLinks.session =
                                    //     localstorage.getString("session") ?? "";
                                  });

                                  // await user.fetchUserDetail(
                                  //     context,
                                  //     loggedUser.loggedMobile[index].clientId,
                                  //     loggedUser.loggedMobile[index].sesstion,
                                  //     "preLoginDecive");
                                  // if (initRoute != "initialRoute") {
                                  //   if (user.userDetailModel!.stat == "Ok") {
                                  //     Navigator.pop(context);
                                  //   }
                                  // }

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
                                  //   Navigator.of(context).pop();
                                  // }
                                },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          title: Text(loggedUser.loggedMobile[index].mobile,
                              style: textStyle(const Color(0xff000000), 14,
                                  FontWeight.w600)),
                          subtitle: Text(
                              "User ID ${loggedUser.loggedMobile[index].clientId}",
                              style: textStyle(const Color(0xff666666), 12,
                                  FontWeight.w500)),
                          trailing: loggedUser.loggedMobile[index].clientId ==
                                  pref.clientId
                              ? Text("Last active",
                                  style: textStyle(const Color(0xff0037B7), 13,
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
                          Navigator.pushNamed(context, Routes.loginScreen,
                              arguments: "login");
                        },
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 1.4, color: Color(0xff000000)),
                            padding: const EdgeInsets.symmetric(vertical: 10.5),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)))),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(assets.addCircleIcon,
                                  color: const Color(0xff000000)),
                              const SizedBox(width: 8),
                              Text("Add another account",
                                  style: textStyle(const Color(0xff000000), 14,
                                      FontWeight.w600))
                            ])),
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS)
                    const SizedBox(height: 20)
                ],
              ),
              if (internet.connectionStatus == ConnectivityResult.none) ...[
                const NoInternetWidget()
              ]
            ],
          ),
        );
      }),
    );
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                titleTextStyle: textStyles.appBarTitleTxt,
                contentTextStyle: textStyles.menuTxt,
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                scrollable: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: const Text("Exit App"),
                content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text("Do you want to Exit an App?")])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("No", style: textStyles.textBtn)),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xff0037B7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      child: Text("Yes",
                          style: textStyle(
                              const Color(0xffFFFFFF), 14, FontWeight.w500)))
                ]);
          },
        ) ??
        false;
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
