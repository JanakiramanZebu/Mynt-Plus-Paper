// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class NoUPIAppsAlert extends StatefulWidget {
  const NoUPIAppsAlert({super.key});

  @override
  State<NoUPIAppsAlert> createState() => _NoUPIAppsAlertState();
}

class _NoUPIAppsAlertState extends State<NoUPIAppsAlert> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    //final basket = context.read(orderProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        scrollable: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        titlePadding: const EdgeInsets.all(0),
        title: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
        ),
        content: Column(
          children: [
            Text(
                "No suitable app available, kindly choose a different mode of payment",
                textAlign: TextAlign.center,
                style: textStyle(
                    theme.isDarkMode ? colors.colorGrey : colors.colorBlack,
                    15,
                    FontWeight.w600))
          ],
        ),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: colors.colorBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                onPressed: () async {
                  launch("https://play.google.com/store/apps");
                },
                child: Text("Get UPI apps",
                    style: textStyle(colors.colorWhite, 12, FontWeight.w600))),
          ),
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
