import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
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
        builder: (context, ref, child) {
          final fund = ref.watch(transcationProvider);
          final theme = ref.watch(themeProvider);
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
                      TextWidget.titleText(
                          text: "${fund.hdfcUPIStatus!.data!.status}",
                          theme: false,
                          color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                          fw: 1),
                      const SizedBox(
                        height: 5,
                      ),
                      TextWidget.subText(
                          text: fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                            ? "Transaction Success"
                            : "Transaction fail",
                          theme: false,
                          color: colors.colorGrey,
                          fw: 0),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.custmText(
                          text: "₹${fund.hdfcUPIStatus!.data!.amount}",
                          theme: false,
                          fs: 40,
                          fw: 1,
                          color: theme.isDarkMode
                                ? colors.colorWhite
                              : colors.colorBlack),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.subText(
                          text: formatDateTimepaymet(
                            value:
                                "${fund.hdfcUPIStatus!.data!.transactionAuthDate}"),
                          theme: false,
                          color: colors.colorGrey,
                          fw: 0),
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
                    child: TextWidget.titleText(
                        text: 'Close',
                        theme: false,
                        color: theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                        fw: 1),
                  ),
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

  Widget headerTitleText(String text) {
    return TextWidget.subText(
        text: text, theme: false, color: colors.colorGrey, fw: 0);
  }

  Widget contantTitleText(String text, ThemesProvider theme) {
    return TextWidget.titleText(
        text: text,
        theme: false,
        color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        fw: 1);
  }
}
