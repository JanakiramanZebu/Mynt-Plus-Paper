// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';

class BondCancelAlert extends ConsumerWidget {
  final BondsOrderBookModel bondcancel;
  const BondCancelAlert({super.key, required this.bondcancel});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final bonds = watch(bondsProvider);
    return AlertDialog(
      backgroundColor: theme.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
                "Are you sure you want to cancel the (${bondcancel.symbol} order)",
                textAlign: TextAlign.center,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600))
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(155, 40),
                      elevation: 0,
                      backgroundColor: const Color(0xffF1F3F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No",
                      style: textStyle(colors.colorGrey, 12, FontWeight.w500))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(155, 40),
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () async {                   


                      Map<String, dynamic> bondOrderData = {};
                          bondOrderData["clientApplicationNumber"] =
                              bondcancel.clientApplicationNumber;
                          bondOrderData["orderNumber"] =
                              bondcancel.orderNumber;
                          bondOrderData["symbol"] = bondcancel.symbol;
                          bondOrderData["investmentValue"] = 
                              bondcancel.investmentValue;
                          bondOrderData["price"] =
                              bondcancel.bidDetail?.price ?? 0;

                         
                              Navigator.
                              pop(context);
                              Navigator.pop(context);

                               await context
                              .read(bondsProvider)
                              .cancelBondOrder(context, bondOrderData);
                              print(' cancel bond data :::::::;  $bondOrderData');

                    
                  },
                  child: Text("Yes",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          12,
                          FontWeight.w500))),
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
