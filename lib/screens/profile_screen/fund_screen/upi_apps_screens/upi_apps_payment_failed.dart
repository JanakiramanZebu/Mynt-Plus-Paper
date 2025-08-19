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
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                border: Border(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.5)
                        : colors.colorWhite,
                  ),
                  left: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.5)
                        : colors.colorWhite,
                  ),
                  right: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.5)
                        : colors.colorWhite,
                  ),
                ),
              ),
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
                          height: 16,
                        ),
                        TextWidget.subText(
                          text: "${fund.hdfcUPIStatus!.data!.status}",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextWidget.subText(
                          text: fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                              ? "Transaction Success"
                              : "Transaction fail",
                          theme: false,
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextWidget.custmText(
                            text: "₹${fund.hdfcUPIStatus!.data!.amount}",
                            theme: false,
                            fs: 40,
                           color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,),
                        const SizedBox(
                          height: 10,
                        ),
                        TextWidget.subText(
                          text: formatDateTimepaymet(
                              value:
                                  "${fund.hdfcUPIStatus!.data!.transactionAuthDate}"),
                          theme: false,
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  data("UPI Address", "${fund.hdfcUPIStatus!.data!.clientVPA}",
                      theme),
                  data("Order ID", "${fund.hdfcUPIStatus!.data!.orderNumber}",
                      theme),
                  data("UPI Transaction ID",
                      "${fund.hdfcUPIStatus!.data!.upiTransactionNo}", theme),
                  data("Status Description",
                      "${fund.hdfcUPIStatus!.data!.statusDescription}", theme),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size(0, 45),
                          backgroundColor: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          // Clear the amount text field
                          ref.read(transcationProvider).amount.clear();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                        },
                        child: TextWidget.titleText(
                            text: 'Close',
                            theme: false,
                            color: colors.colorWhite,
                            fw: 2),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  data(String name, String value, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: name,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextWidget.subText(
                text: value,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                align: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }
}
