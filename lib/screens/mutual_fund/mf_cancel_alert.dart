// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/mf_model/mf_orderbook_lumpsum_model.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
// import '../../../models/ipo_model/ipo_place_order_model.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';

class MfCancelAlert extends ConsumerWidget {
  final Data mfcancel;
  const MfCancelAlert({super.key, required this.mfcancel});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
      final mfData = watch(mfProvider);
    return AlertDialog(
      backgroundColor: theme.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
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
              "Are you sure you want to cancel the ( ${mfcancel.schemename} ) order" ,
              textAlign: TextAlign.center,
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w600))
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xffF1F3F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No",
                      style: textStyle(colors.colorGrey, 12, FontWeight.w600))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () async{
                
                        await mfData.cancelredumorder(context, mfcancel.ordernumber);
                        ;
                     Navigator.pop(context);
                  },
                  child: Text("Yes",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          12,
                          FontWeight.w600))),
            )
          ],
        ),
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}


