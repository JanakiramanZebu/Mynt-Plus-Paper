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
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';

class QrDetails extends ConsumerWidget {
  final QrResponces details;
  final MobileScannerController camera;
  const QrDetails({super.key, required this.details, required this.camera});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    return details.uniqueId == null
        ? Container(
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
                const SizedBox(height: 15),
                SvgPicture.asset(
                  "assets/icon/invalid_qr.svg",
                  color: theme.isDarkMode
                  ?colors.colorWhite
                  :colors.colorBlack,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      style: textStyle( theme.isDarkMode
                  ?colors.colorBlack
                  :colors.colorWhite, 13, FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
        )
        : Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const CustomDragHandler(),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Login Conformation",
                    style: textStyle(
                      theme.isDarkMode
                      ?colors.colorWhite
                      :colors.colorBlack, 16, FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                rowtable("IP Address", details.ip ?? "", theme),
                rowtable("City", details.city ?? "", theme),
                rowtable("State", details.region??"",theme),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                          "Cancel",
                          style:
                              textStyle(
                                theme.isDarkMode
                                ?colors.colorBlack
                                :colors.colorWhite, 16, FontWeight.w600),
                        ),
                      )),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: theme.isDarkMode
                            ?colors.colorbluegrey
                            :colors.colorBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )),
                        onPressed: () async{
                           await context
                              .read(userProfileProvider)
                              .fetchQR(context, details.uniqueId.toString(),details.loginSource.toString(),camera);
                        },
                        child: Text(
                          "Confirm",
                          style:
                              textStyle(
                                theme.isDarkMode
                                ?colors.colorBlack
                                :colors.colorWhite, 16, FontWeight.w600),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
        );
  }
}

Padding rowtable(String header, String description , ThemesProvider themes) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          header,
          style: textStyle(
            themes.isDarkMode
            ?colors.colorGrey
            :colors.colorBlack, 15, FontWeight.w600),
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          description,
          style: textStyle(
            themes.isDarkMode
            ?colors.colorWhite
            :colors.colorGrey, 15, FontWeight.w600),
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
