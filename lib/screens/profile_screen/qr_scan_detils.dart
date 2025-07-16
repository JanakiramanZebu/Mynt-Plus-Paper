// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: implementation_imports
import 'package:mobile_scanner/src/mobile_scanner_controller.dart';
import '../../models/profile_model/qr_response.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';

class QrDetails extends ConsumerWidget {
  final QrResponces details;
  final MobileScannerController camera;
  const QrDetails({super.key, required this.details, required this.camera});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return details.uniqueId == null
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomDragHandler(),
                const SizedBox(height: 20),
                SvgPicture.asset(
                  "assets/icon/invalid_qr.svg",
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                ),
                const SizedBox(height: 15),
                TextWidget.titleText(
                  text: "Invalid QR Code",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextWidget.subText(
                    text:
                        "Try again with a different QR code; the one you are trying to scan is incorrect.",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 3,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  width: MediaQuery.of(context).size.width,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      side: BorderSide(color: colors.btnOutlinedBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: colors.primaryDark,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      camera.start();
                    },
                    child: TextWidget.subText(
                      text: "Retry",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? Colors.black : Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomDragHandler(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.highlightDark
                            : colors.highlightLight,
                        onTap: () {
                          Navigator.pop(context);
                          camera.start();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: TextWidget.titleText(
                    text: "Login Conformation",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                  ),
                ),
                const SizedBox(height: 25),
                rowtable("IP Address", details.ip ?? "", theme),
                const SizedBox(height: 25),
                // rowtable("City", details.city ?? "", theme),
                // rowtable("State", details.region ?? "", theme),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      side: BorderSide(color: colors.btnOutlinedBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: colors.primaryDark,
                    ),
                    onPressed: () async {
                      await ref.read(userProfileProvider).fetchQR(
                          context,
                          details.uniqueId.toString(),
                          details.loginSource.toString(),
                          camera);
                    },
                    child: TextWidget.titleText(
                      text: "Confirm",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorWhite,
                      fw: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
  }
}

Row rowtable(String header, String description, ThemesProvider themes) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextWidget.subText(
        text: header,
        theme: themes.isDarkMode,
        color: themes.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        fw: 3,
      ),
      TextWidget.subText(
        text: description,
        theme: themes.isDarkMode,
        color: themes.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        fw: 3,
      ),
    ],
  );
}
