import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/list_divider.dart';

class UPIAppsPaymentSuccessAlert extends StatefulWidget {
  const UPIAppsPaymentSuccessAlert({
    super.key,
  });

  @override
  State<UPIAppsPaymentSuccessAlert> createState() =>
      _UPIAppsPaymentSuccessAlertState();
}

class _UPIAppsPaymentSuccessAlertState
    extends State<UPIAppsPaymentSuccessAlert> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
      child: Consumer(
        builder: (context, watch, child) {
          final fund = watch(transcationProvider);
          final theme = watch(themeProvider);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xff999999),
                      blurRadius: 4.0,
                      offset: Offset(2.0, 0.0))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomDragHandler(),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        //
                        color: fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                            ? colors.kColorGreenButton
                            : colors.kColorRedButton,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${fund.hdfcUPIStatus!.data!.status}",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                            ? "Transaction Success"
                            : "Transaction fail",
                        style: textStyle(colors.colorGrey, 14, FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "₹${fund.hdfcUPIStatus!.data!.amount}",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            40,
                            FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        formatDateTimepaymet(
                            value:
                                "${fund.hdfcUPIStatus!.data!.transactionAuthDate}"),
                        style: textStyle(colors.colorGrey, 13, FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const ListDivider(),
                const SizedBox(
                  height: 10,
                ),
                headerTitleText("UPI Address"),
                contantTitleText(
                    "${fund.hdfcUPIStatus!.data!.clientVPA}", theme),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("Order ID"),
                contantTitleText(
                    "${fund.hdfcUPIStatus!.data!.orderNumber}", theme),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("UPI Transaction ID"),
                contantTitleText(
                    "${fund.hdfcUPIStatus!.data!.upiTransactionNo}", theme),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("Status Description"),
                contantTitleText(
                    "${fund.hdfcUPIStatus!.data!.statusDescription}", theme),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.isDarkMode
                            ? colors.colorbluegrey
                            : colors.colorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                      },
                      child: Text(
                        'Close',
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            15,
                            FontWeight.w600),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        },
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

  Text contantTitleText(String text, ThemesProvider theme) {
    return Text(
      text,
      style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          15, FontWeight.w600),
    );
  }
}
