// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';

class UPIAppsPaymentSuccessAlert extends StatefulWidget {
  final TranctionProvider fund;
  const UPIAppsPaymentSuccessAlert({super.key, required this.fund});

  @override
  State<UPIAppsPaymentSuccessAlert> createState() =>
      _UPIAppsPaymentSuccessAlertState();
}

class _UPIAppsPaymentSuccessAlertState
    extends State<UPIAppsPaymentSuccessAlert> {
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
          child: Icon(
            Icons.check_circle_rounded,
            color: colors.kColorGreenButton,
            size: 70,
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("SUCCESS",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w600)),
            ),
            const SizedBox(
              height: 2,
            ),
            Center(
              child: Text("Your payment has failed.",
                  style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text("₹ 1234.00",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      23,
                      FontWeight.w600)),
            ),
            const SizedBox(
              height: 6,
            ),
            Center(
              child: Text("Fri Oct 11 2024 12:31:51",
                  style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
            ),
            SizedBox(
              height: 10,
            ),
            ListDivider(),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerTitleText("UPI ID"),
                contantTitleText("8248005079@ybl"),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("Payment ID"),
                contantTitleText("3456787654345678765"),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("Reason"),
                contantTitleText("Transaction success"),
                const SizedBox(
                  height: 10,
                ),
              ],
            )
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
                onPressed: () async {},
                child: Text("DONE",
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

  Text headerTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorGrey, 14, FontWeight.w500),
    );
  }

  Text contantTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorBlack, 15, FontWeight.w600),
    );
  }
}
