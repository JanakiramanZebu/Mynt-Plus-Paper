// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/src/mobile_scanner_controller.dart';
import '../../../res/res.dart';

class InValidQRui extends StatelessWidget {
  final MobileScannerController camera;
  const InValidQRui({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.only(top: 20),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
                color: const Color(0xff999999),
                borderRadius: BorderRadius.circular(20))),
        const SizedBox(height: 15),
        SvgPicture.asset(
          "assets/profile/invalid_qr.svg",
        ),
        const SizedBox(height: 15),
        Text(
          "Invalid QR Code",
          style: textStyle(colors.colorBlack, 16, FontWeight.w600),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Try again with a different QR code; the one you are trying to scan is incorrect.",
            style: textStyle(colors.colorBlack, 14, FontWeight.w500),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xff000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                )),
            onPressed: () {
              Navigator.pop(context);
              camera.start();
            },
            child: Text(
              "Retry",
              style: textStyle(colors.colorWhite, 13, FontWeight.w600),
            ),
          ),
        ),
      ],
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
