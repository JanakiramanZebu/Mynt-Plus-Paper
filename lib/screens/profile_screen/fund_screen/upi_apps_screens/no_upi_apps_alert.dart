// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';

class NoUPIAppsAlert extends StatefulWidget {
  const NoUPIAppsAlert({super.key});

  @override
  State<NoUPIAppsAlert> createState() => _NoUPIAppsAlertState();
}

class _NoUPIAppsAlertState extends State<NoUPIAppsAlert> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    final fund = context.read(transcationProvider);

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
              const SizedBox(
                height: 6,
              ),
              const CustomDragHandler(),
              const SizedBox(
                height: 6,
              ),
              SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
              const SizedBox(
                height: 10,
              ),
              Text(
                  "No suitable app available, kindly choose a different mode of payment",
                  textAlign: TextAlign.center,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorGrey : colors.colorBlack,
                      15,
                      FontWeight.w600)),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.isDarkMode
                            ? colors.colorbluegrey
                            : colors.colorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                    onPressed: () async {
                      launch("https://play.google.com/store/apps");
                    },
                    child: Text("Get UPI Apps",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            12,
                            FontWeight.w600))),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
