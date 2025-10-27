import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../provider/version_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';

class VersionBottomSheet extends ConsumerWidget {
  const VersionBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final version = ref.watch(versionProvider);
    return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 3,
            ),
            const CustomDragHandler(),
            SizedBox(
              height: version.versionmodel!.attributes.version.mandate == "no"
                  ? 0
                  : 5,
            ),
            version.versionmodel!.attributes.version.mandate == "yes"
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              assets.remove,
                              width: 25,
                            ))),
                  ),
            SizedBox(
              height: version.versionmodel!.attributes.version.mandate == "no"
                  ? 0
                  : 10,
            ),
            Center(
              child: Text(
                  defaultTargetPlatform == TargetPlatform.iOS
                      ? "${version.versionmodel?.attributes.version.ios}"
                      : "${version.versionmodel?.attributes.version.android}",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      30,
                      2)),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text("🚀 A newer App is available!",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      20,
                      2)),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                  "Enhance your experience with the latest features, improvements, and fixes.",
                  textAlign: TextAlign.center,
                  style: textStyle(colors.colorGrey, 15, 3)),
            ),
            Center(
              child: Text("Update now to stay ahead!",
                  textAlign: TextAlign.center,
                  style: textStyle(colors.colorGrey, 15, 3)),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: MediaQuery.of(context).size.width,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.isDarkMode
                        ? colors.colorbluegrey
                        : colors.colorBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    )),
                onPressed: () {
                  defaultTargetPlatform == TargetPlatform.android
                      ? launch(
                          'https://play.google.com/store/apps/details?id=com.mynt.trading_app_zebu&hl=en')
                      : launch(
                          'https://apps.apple.com/in/app/mynt-stocks-options-ipo-mf/id6478270319');
                },
                child: Text("Update",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        15,
                        0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
