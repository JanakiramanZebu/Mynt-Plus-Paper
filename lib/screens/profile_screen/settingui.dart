import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/api_key_provider.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';
import 'topt_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final usersettings = watch(userProfileProvider);
    final apikeys = context.read(apikeyprovider);
    final theme = context.read(themeProvider);

    final Preferences pref = locator<Preferences>();
    return Scaffold(
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          title: Text("Settings",
              style: textStyles.appBarTitleTxt.copyWith(
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack))),
      body: Column(
        children: [
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              return ListTile(
                onTap: () async {
                  if (index == 0) {
                    copyToClipboard("${apikeys.apikeyres!.apikey}",
                        apikeys.apikeyres!.apistatus, context);
                  } else if (index == 1) {
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
                                context.read(apikeyprovider).totpkey!.pwd));
                  } else if (index == 2) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style: textStyle(colors.colorGrey, 12,
                                          FontWeight.w600),
                                    )
                                  ])),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("Cancel",
                                    style: textStyles.textBtn.copyWith(
                                        color: context
                                                .read(themeProvider)
                                                .isDarkMode
                                            ? colors.colorLightBlue
                                            : colors.colorBlue))),
                            ElevatedButton(
                                onPressed: () async {
                                  usersettings.fetchFreezeAc(context);
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
                                        !context.read(themeProvider).isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w500))),
                          ],
                        );
                      },
                    );
                  } else if (index == 3) {
                    context.read(changePasswordProvider).userIdController.text =
                        "${pref.clientId}";
                    Navigator.pushNamed(context, Routes.changePass,
                        arguments: "Yes");
                  } else if (index == 5) {
                    // String pwd = apikeys.totpkey!.pwd;
                    // _showAlertDialog(context, pwd, theme);
                    Navigator.pushNamed(context, Routes.logError);
                  } else if (index == 4) {
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Choose theme',
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        16,
                                        FontWeight.w600)),
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
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ListTile(
                                            onTap: () async {
                                              theme.toggleTheme(
                                                  themeMod:
                                                      theme.themeTypes[index]);
                                              Navigator.pop(context);
                                            },
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 0, vertical: 0),
                                            dense: true,
                                            minLeadingWidth: 22,
                                            leading: SvgPicture.asset(theme
                                                    .isDarkMode
                                                ? theme.themeTypes[index] ==
                                                        theme.deviceTheme
                                                    ? assets.darkActProductIcon
                                                    : assets.darkProductIcon
                                                : theme.themeTypes[index] ==
                                                        theme.deviceTheme
                                                    ? assets.actProductIcon
                                                    : assets.productIcon),
                                            title: Text(theme.themeTypes[index],
                                                style: textStyles.prdText
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? Color(theme.themeTypes[
                                                                        index] ==
                                                                    theme
                                                                        .deviceTheme
                                                                ? 0xffffffff
                                                                : 0xff666666)
                                                            : Color(
                                                                theme.themeTypes[
                                                                            index] ==
                                                                        theme
                                                                            .deviceTheme
                                                                    ? 0xff000000
                                                                    : 0xff666666,
                                                              ))),
                                          );
                                        },
                                      )
                                    ])),
                          );
                        });
                  } else if (index == 6) {
                    Navigator.pushNamed(context, Routes.orderPrefer);
                  }
                },
                dense: true,
                minLeadingWidth: 20,
                leading: index == 2
                    ? const Icon(
                        Icons.lock_outline_rounded,
                        size: 21,
                      )
                    : SvgPicture.asset(
                        usersettings.settingmenu[index]['leading'],
                        width: 19,
                        color: const Color(0xff666666),
                      ),
                title: Text(usersettings.settingmenu[index]['title'],
                    style: textStyle(
                        theme.isDarkMode
                            ? const Color(0xffffffff)
                            : const Color(0xff000000),
                        16,
                        FontWeight.w500)),
                subtitle: Row(
                  children: [
                    if (index == 0) ...[
                      Row(
                        children: [
                          apikeys.apikeyres!.apistatus == "VALID"
                              ? Row(
                                  children: [
                                    Text(
                                        "${apikeys.apikeyres!.apikey}"
                                            .substring(0, 4),
                                        style: textStyle(
                                            const Color(0xff666666),
                                            12,
                                            FontWeight.w500)),
                                    Text(".........",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            12,
                                            FontWeight.w500)),
                                    Text(
                                        "${apikeys.apikeyres!.apikey}"
                                            .substring(28, 32),
                                        style: textStyle(
                                            const Color(0xff666666),
                                            12,
                                            FontWeight.w500)),
                                    const SizedBox(width: 5),
                                    apikeys.apikeyres!.apistatus == "VALID"
                                        ? InkWell(
                                            onTap: () async {
                                              await Share.share(
                                                "API Key\n${apikeys.apikeyres!.apikey}",
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              child: Text(
                                                "Share",
                                                style: textStyles.textBtn,
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                )
                              : Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  width: 180,
                                  child: Text(
                                      "API Key is Experied please generate a new key",
                                      style: textStyle(const Color(0xff666666),
                                          12, FontWeight.w500)),
                                ),
                        ],
                      ),
                    ],
                    Text(
                        index != 0
                            ? usersettings.settingmenu[index]['subTitle']
                            : "",
                        overflow: TextOverflow.ellipsis,
                        style: textStyle(
                            const Color(0xff666666), 12, FontWeight.w500)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index == 0) ...[
                      apikeys.apikeyres!.apistatus == "VALID"
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Expire on",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorGrey
                                          : colors.colorBlack,
                                      13,
                                      FontWeight.w500),
                                ),
                                Text(
                                  readTimestamp(int.parse(
                                      "${apikeys.apikeyres!.exd}000")),
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      13,
                                      FontWeight.w500),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    backgroundColor: const Color(0xff000000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                onPressed: () async {
                                  await context
                                      .read(apikeyprovider)
                                      .fetchregenerateapikey(context, "1 year");
                                  await context
                                      .read(apikeyprovider)
                                      .fetchapikey(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      successMessage(context,
                                          'API Key as been ${apikeys.generateApikey?.status}'));
                                },
                                child: Text("API Key",
                                    textAlign: TextAlign.center,
                                    style: textStyle(const Color(0xffffffff),
                                        12, FontWeight.w500)),
                              ),
                            ),
                    ],
                    index != 2 && index != 0
                        ? SvgPicture.asset(
                            usersettings.settingmenu[index]['trailing'])
                        : Container()
                  ],
                ),
              );
            },
            shrinkWrap: true,
            itemCount: usersettings.settingmenu.length,
            separatorBuilder: (BuildContext context, int index) {
              return const ListDivider();
            },
          ),
        ],
      ),
    );
  }

  // void _showAlertDialog(
  //     BuildContext context, String pwd, ThemesProvider theme) {
  //   bool isHidden = true; // Local variable to track visibility

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             titleTextStyle: textStyles.appBarTitleTxt,
  //             contentTextStyle: textStyles.menuTxt,
  //             titlePadding:
  //                 const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  //             shape: const RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(14))),
  //             scrollable: true,
  //             contentPadding: const EdgeInsets.symmetric(
  //               horizontal: 14,
  //             ),
  //             insetPadding: const EdgeInsets.symmetric(horizontal: 20),
  //             title: Text("Sensitive Information"),
  //             content: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 // Display sensitive text
  //                 Expanded(
  //                   child: Text(
  //                     isHidden ? "••••••••••••••••••••••••••••••••" : "$pwd",
  //                     style: TextStyle(fontSize: 16),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 // Toggle button
  //                 IconButton(
  //                   icon: Icon(
  //                     isHidden ? Icons.visibility_off : Icons.visibility,
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       isHidden = !isHidden; // Toggle visibility
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //               Row(
  //                 children: [
  //                   SizedBox(
  //                     child: ElevatedButton(
  //                         onPressed: () {},
  //                         style: ElevatedButton.styleFrom(
  //                             elevation: 0,
  //                             backgroundColor: theme.isDarkMode
  //                                 ? colors.colorbluegrey
  //                                 : colors.colorBlack,
  //                             padding: const EdgeInsets.symmetric(vertical: 13),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(30),
  //                             )),
  //                         child: Text("Proceed", style: textStyles.btnText)),
  //                   ),
  //                   SizedBox(
  //                     child: ElevatedButton(
  //                         onPressed: () {},
  //                         style: ElevatedButton.styleFrom(
  //                             elevation: 0,
  //                             backgroundColor: theme.isDarkMode
  //                                 ? colors.colorbluegrey
  //                                 : colors.colorBlack,
  //                             padding: const EdgeInsets.symmetric(vertical: 13),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(30),
  //                             )),
  //                         child: Text("Proceed", style: textStyles.btnText)),
  //                   ),
  //                 ],
  //               )
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  copyToClipboard(String text, String? status, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    if (status == "VALID") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Click on API Key button to Generate API Key')),
      );
    }
  }
}
