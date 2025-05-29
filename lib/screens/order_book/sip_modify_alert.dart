import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/order_book_model/sip_order_book.dart';
import 'package:mynt_plus/provider/sip_order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';

import '../../models/order_book_model/sip_place_order.dart';
import '../../provider/order_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';

class SipModifyAlert extends ConsumerWidget {
  final SipProvider sips;
  final TextEditingController sipqtyctrl;
  final SipDetails sipdetails;
  final String value;
  final ThemesProvider themes;
  const SipModifyAlert(
      {super.key,
      required this.sips,
      required this.sipqtyctrl,
      required this.sipdetails,
      required this.value,
      required this.themes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: themes.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: const Padding(
        padding: EdgeInsets.all(10),
        child: Icon(
          Icons.edit_note_sharp,
          size: 50,
        ),
      ),
      content: Column(
        children: [
          Text(
              "Are you sure you want to modify the (${sipdetails.scrips![0].tsym.toString().toUpperCase()})",
              textAlign: TextAlign.center,
              style: textStyle(
                  themes.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                      backgroundColor: themes.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () async {
                    ModifySipInput sipOrderInput = ModifySipInput(
                        regdate: sipdetails.regDate.toString(),
                        startdate: sipdateformat(sips.datefield.text),
                        frequency: value == "Daily"
                            ? "0"
                            : value == "Weekly"
                                ? "1"
                                : value == "Fortnightly"
                                    ? "2"
                                    : "3",
                        endperiod: sips.numberofSips.text.toString(),
                        sipname: sipdetails.sipName,
                        prevExecutedate:
                            sipdetails.internal!.prevExecDate.toString(),
                        duedate: sipdetails.internal!.dueDate.toString(),
                        exedate: sipdetails.internal!.execDate.toString(),
                        period: sipdetails.internal!.period.toString(),
                        active: sipdetails.internal!.active.toString(),
                        sipId: sipdetails.internal!.sipId.toString(),
                        exch: sipdetails.scrips![0].exch.toString(),
                        tysm: sipdetails.scrips![0].tsym.toString(),
                        prd: sipdetails.scrips![0].prd.toString().toUpperCase(),
                        token: sipdetails.scrips![0].token.toString(),
                        qty: sipqtyctrl.text);
                    await ref.read(orderProvider).fetchModifySipOrder(
                          context,
                          sipOrderInput,
                        );
                    
                  },
                  child: Text("Yes",
                      style: textStyle(
                          themes.isDarkMode
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
