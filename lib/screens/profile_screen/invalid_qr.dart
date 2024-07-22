// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/src/mobile_scanner_controller.dart';
import '../../../res/res.dart';
import '../../provider/thems.dart';
import '../../sharedWidget/custom_drag_handler.dart';

class InValidQRui extends ConsumerWidget {
  final MobileScannerController camera;
  const InValidQRui({super.key, required this.camera});

  @override
  Widget build(BuildContext context,ScopedReader watch) {
    final theme = context.read(themeProvider);
    return Container(
      decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.isDarkMode ? Colors.black : Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: Color(0xff999999),
                  blurRadius: 4.0,
                  offset: Offset(2.0, 0.0))
            ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomDragHandler(),
          SvgPicture.asset(
            "assets/profile/invalid_qr.svg",
            color: theme.isDarkMode
            ?colors.colorWhite
            :colors.colorBlack
            ,
          ),
          const SizedBox(height: 15),
          Text(
            "Invalid QR Code",
            style: textStyle(
              theme.isDarkMode
              ?colors.colorWhite
              :colors.colorBlack, 16, FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              "Try again with a different QR code; the one you are trying to scan is incorrect.",
              style: textStyle(
                theme.isDarkMode
                ?colors.colorWhite
                :colors.colorBlack, 14, FontWeight.w500),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: theme.isDarkMode
                  ?colors.colorbluegrey
                  :colors.colorBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  )),
              onPressed: () {
                Navigator.pop(context);
                camera.start();
              },
              child: Text(
                "Retry",
                style: textStyle(
                  theme.isDarkMode
                  ?colors.colorBlack
                  :colors.colorWhite, 13, FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

textStyle(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle: TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  ));
}
