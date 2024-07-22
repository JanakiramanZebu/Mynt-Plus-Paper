import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: implementation_imports
import 'package:mobile_scanner/src/mobile_scanner_controller.dart';
 
 
 
import '../../models/profile_model/qr_response.dart';
import '../../res/res.dart';

class QrDetails extends StatelessWidget {
  final QrResponces details;
  final MobileScannerController camera;
  const QrDetails({super.key, required this.details, required this.camera});

  @override
  Widget build(BuildContext context) {
    return details.uniqueId == null
        ? Column(
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
                "assets/icon/invalid_qr.svg",
              ),
              const SizedBox(height: 15),
              Text(
                "Invalid QR Code",
                style: textStyle(colors.colorBlack, 16, FontWeight.w600),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: const Color(0xff999999),
                          borderRadius: BorderRadius.circular(20)))),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Login Conformation",
                  style: textStyle(colors.colorBlack, 16, FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              rowtable("IP Address", details.ip ?? ""),
              rowtable("Browser", details.browser ?? ""),
              rowtable("OS", details.os ?? ""),
              rowtable("City", details.city ?? ""),
              rowtable("State", details.region ?? ""),
              rowtable("Country", details.country ?? ""),
              rowtable("Device", details.device ?? ""),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
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
                        "Cancel",
                        style:
                            textStyle(colors.colorWhite, 16, FontWeight.w600),
                      ),
                    )),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xff000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      onPressed: () {},
                      child: Text(
                        "Confirm",
                        style:
                            textStyle(colors.colorWhite, 16, FontWeight.w600),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          );
  }
}

Padding rowtable(String header, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          header,
          style: textStyle(colors.colorBlack, 15, FontWeight.w600),
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          description,
          style: textStyle(colors.colorGrey, 15, FontWeight.w600),
        ),
      ],
    ),
  );
}

textStyle(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle: TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  ));
}
