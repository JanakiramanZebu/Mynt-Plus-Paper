import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:share_plus/share_plus.dart';

import '../../provider/api_key_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/functions.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({
    super.key,
  });

  @override
  ConsumerState<ApiKeyScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends ConsumerState<ApiKeyScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final apikeys = ref.watch(apikeyprovider);

    // final screenheight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
         decoration: BoxDecoration(
           borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
         border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),

         
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomDragHandler(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: TextWidget.titleText(
                        text: 'Generate API Key',
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 1),
                  ),
              
                  ListDivider(),
              
                  // TextWidget.titleText(
                  //     text: 'Authenticator Key',
                  //     theme: false,
                  //     color: theme.isDarkMode
                  //         ? colors.textPrimaryDark
                  //         : colors.textPrimaryLight,
                  //     fw: 0),
                  const SizedBox(height: 16.0),
                  // apikeys.apikeyres!.apistatus == "VALID"
                  //     ? TextWidget.subText(
                  //         text: 'Your API Key click to copy',
                  //         theme: false,
                  //         color: theme.isDarkMode
                  //             ? colors.textPrimaryDark
                  //             : colors.textPrimaryLight,
                  //         fw: 0)
                  //     : TextWidget.subText(
                  //         text: 'API Key is Expired Click to Generate',
                  //         theme: false,
                  //         color: theme.isDarkMode
                  //             ? colors.textSecondaryDark
                  //             : colors.textSecondaryLight,
                  //         fw: 0),
                  // TextWidget.paraText(
                  //     text: '${apikeys.apikeyres!.apistatus}',
                  //     theme: false,
                  //     color: theme.isDarkMode
                  //         ? colors.textSecondaryDark
                  //         : colors.textSecondaryLight,
                  //     fw: 0),
                  apikeys.apikeyres!.apistatus == "NOT_PRESENT"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 400, // Set a fixed width for the content
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 400,
                                        child: TextWidget.subText(
                                          maxLines: 2,
                                          textOverflow: TextOverflow.ellipsis,
                                          text:
                                              "It looks like you haven't created an API key yet. Click below to generate your first key and get started.",
                                          theme: false,
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await ref
                                              .read(apikeyprovider)
                                              .fetchgenerateapikey(
                                                  context, "1 year");
                                          await ref
                                              .read(apikeyprovider)
                                              .fetchapikey(context);
                                          Navigator.pop(context);
                                          Clipboard.setData(ClipboardData(
                                              text:
                                                  "${apikeys.apikeyres!.apikey}"));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(successMessage(
                                                  context,
                                                  'API Key has been ${apikeys.generateApikey?.status} and copied'));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          minimumSize:
                                              const Size(double.infinity, 45),
                                          backgroundColor: theme.isDarkMode
                                              ? colors.primaryDark
                                              : colors.primaryLight,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        child: TextWidget.subText(
                                            text: "Generate API Key",
                                            theme: false,
                                            color: colors.colorWhite,
                                            fw: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
              
                  apikeys.apikeyres!.apistatus != "NOT_PRESENT"
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget.subText(
                                  text: 'API Key',
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                      fw: 0,
                                ),
                                Row(
                                  children: [
                                    TextWidget.paraText(
                                      text: readTimestamp(int.parse(
                                          "${apikeys.apikeyres!.exd}000")),
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: apikeys.apikeyres!.apistatus ==
                                                  "VALID"
                                              ? theme.isDarkMode ? colors.profitDark.withOpacity(0.4) : colors.profitLight.withOpacity(0.4)
                                              : theme.isDarkMode ? colors.lossDark.withOpacity(0.4) : colors.lossLight.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: TextWidget.captionText(
                                            text:
                                                "${apikeys.apikeyres!.apistatus}",
                                            theme: false,
                                            color:  apikeys.apikeyres!.apistatus ==
                                                  "VALID"
                                              ? theme.isDarkMode ? colors.profitDark : colors.profitLight
                                              : theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: colors.primaryLight,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextWidget.paraText(
                                        text: apikeys.hidePass
                                            ? "•" *
                                                apikeys.apikeyres!.apikey!.length
                                            : "${apikeys.apikeyres!.apikey}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        textOverflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
                                          apikeys.hiddenPass();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: SvgPicture.asset(
                                            apikeys.hidePass
                                                ? "assets/icon/eye-off.svg"
                                                : "assets/icon/eye.svg",
                                            width: 20,
                                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    ),
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
                                        onTap: () async {
                                          await Future.delayed(
                                              const Duration(milliseconds: 150));
                                          await Share.share(
                                            "API Key\n${apikeys.apikeyres!.apikey}",
                                          );
                                        },
                                        child: Container(
                                          height: 32,
                                          width: 32,
                                          child: Center(
                                            child: Icon(
                                              Icons.share_outlined,
                                              size: 18,
                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
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
                                        onTap: () async {
                                          await Future.delayed(
                                              const Duration(milliseconds: 150));
                                          Clipboard.setData(ClipboardData(
                                              text:
                                                  "${apikeys.apikeyres!.apikey}"));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(successMessage(
                                                  context,
                                                  "Auth key copied to clipboard"));
              
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 32,
                                          width: 32,
                                          child: Center(
                                            child: Icon(Icons.copy, size: 18, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 18.0),
                  apikeys.apikeyres!.apistatus != "NOT_PRESENT" &&
                          apikeys.apikeyres!.apistatus != "VALID"
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await ref
                                    .read(apikeyprovider)
                                    .fetchgenerateapikey(context, "1 year");
                                await ref
                                    .read(apikeyprovider)
                                    .fetchapikey(context);
                                Navigator.pop(context);
                                Clipboard.setData(ClipboardData(
                                    text: "${apikeys.apikeyres!.apikey}"));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    successMessage(context,
                                        'API Key has been ${apikeys.generateApikey?.status} and copied'));
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 40),
                                backgroundColor: theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: TextWidget.subText(
                                  text: "Generate API Key",
                                  theme: false,
                                  color: colors.colorWhite,
                                  fw: 1),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            SizedBox(height: 30.0)
          ],
        ),
      ),
    );
  }
}
