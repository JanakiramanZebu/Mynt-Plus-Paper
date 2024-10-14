// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/payment_loader.dart';

class UPIIDPaymentCancelAlert extends StatefulWidget {
  const UPIIDPaymentCancelAlert({super.key});

  @override
  State<UPIIDPaymentCancelAlert> createState() =>
      _UPIIDPaymentCancelAlertState();
}

class _UPIIDPaymentCancelAlertState extends State<UPIIDPaymentCancelAlert> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    //final basket = context.read(orderProvider);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color.fromARGB(255, 18, 18, 18)
              : colors.colorWhite,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          scrollable: true,
          actionsPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          titlePadding: const EdgeInsets.only(left: 16),
          title: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            alignment: Alignment.center,
            child: Text('Awaiting UPI conformation',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600)),
          ),
          content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                // const ListDivider(),
                const SizedBox(height: 3),
                const ProgressiveDotsLoader(),
                const SizedBox(height: 3),
                Text('This will take a few seconds.',
                    style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
              ])),
          actions: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text("Cancel Transaction",
                        style: GoogleFonts.inter(
                            textStyle: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)))))
          ]),
    );
  }
}
