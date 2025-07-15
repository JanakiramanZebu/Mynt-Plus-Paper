// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';

class NoUPIAppsAlert extends ConsumerStatefulWidget {
  const NoUPIAppsAlert({super.key});

  @override
  ConsumerState<NoUPIAppsAlert> createState() => _NoUPIAppsAlertState();
}

class _NoUPIAppsAlertState extends ConsumerState<NoUPIAppsAlert> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final fund = ref.read(transcationProvider);

    return GestureDetector(
        onTap: () => fund.focusNode.unfocus(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
              const SizedBox(
                height: 16,
              ),
              TextWidget.subText(
                  text:
                      "No suitable app available, kindly choose a different mode of payment",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  align: TextAlign.center),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(0, 40),
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                    onPressed: () async {
                      launch("https://play.google.com/store/apps");
                    },
                    child: TextWidget.subText(
                      text: "Get UPI Apps",
                      theme: false,
                      color: colors.colorWhite,
                      fw: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              )
            ],
          ),
        ));
  }
}
