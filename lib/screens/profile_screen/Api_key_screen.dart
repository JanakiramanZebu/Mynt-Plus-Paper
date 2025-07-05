import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final apikeys = ref.read(apikeyprovider);

    // final screenheight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
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
                const SizedBox(height: 16),
                TextWidget.titleText(
                    text: 'Generate API Key',
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                    fw: 1),
                const SizedBox(height: 10),

                Divider(
                  color: theme.isDarkMode
                      ? colors.dividerDark
                      : colors.dividerLight,
                  thickness: 1,
                ),

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
                      'It looks like you haven’t created an API key yet. Click below to generate your first key and get started.',
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 3,
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(apikeyprovider)
                      .fetchgenerateapikey(context, "1 year");
                  await ref.read(apikeyprovider).fetchapikey(context);
                  Navigator.pop(context);
                  Clipboard.setData(
                      ClipboardData(text: "${apikeys.apikeyres!.apikey}"));
                  ScaffoldMessenger.of(context).showSnackBar(successMessage(
                      context,
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
                              TextWidget.titleText(
                                  text: 'API Key',
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  fw: 1),
                              const SizedBox(width: 8.0),
                              Row(
                                children: [
                                  TextWidget.paraText(
                                      text: readTimestamp(int.parse(
                                          "${apikeys.apikeyres!.exd}000")),
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 3),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: apikeys.apikeyres!.apistatus ==
                                                "VALID"
                                            ? colors.kColorGreenButton
                                            : colors.kColorRedButton,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: TextWidget.captionText(
                                            text:
                                                "${apikeys.apikeyres!.apistatus}",
                                            theme: false,
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorWhite,
                                            fw: 0),
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
                              color: colors.colorbluegrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextWidget.paraText(
                                        text: "${apikeys.apikeyres!.apikey}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3,
                                        textOverflow: TextOverflow.ellipsis),
                                  ),
                                  //   InkWell(
                                  //   onTap: () {
                                  //     setState(() {
                                  //       isObscure = !isObscure;
                                  //     });
                                  //   },
                                  //   child: Icon(
                                  //     isObscure ? Icons.visibility_off : Icons.visibility,
                                  //     size: 22,
                                  //   ),
                                  // ),
                                  InkWell(
                                    onTap: () async {
                                      await Share.share(
                                        "API Key\n${apikeys.apikeyres!.apikey}",
                                      );
                                    },
                                    child: Icon(
                                      Icons.share_outlined,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text:
                                              "${apikeys.apikeyres!.apikey}"));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(successMessage(context,
                                              "Auth key copied to clipboard"));

                                      Navigator.pop(context);
                                    },
                                    child: const Icon(Icons.copy, size: 22),
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
                  await ref.read(apikeyprovider).fetchapikey(context);
                  Navigator.pop(context);
                  Clipboard.setData(
                      ClipboardData(text: "${apikeys.apikeyres!.apikey}"));
                  ScaffoldMessenger.of(context).showSnackBar(successMessage(
                      context,
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
    );
  }
}
