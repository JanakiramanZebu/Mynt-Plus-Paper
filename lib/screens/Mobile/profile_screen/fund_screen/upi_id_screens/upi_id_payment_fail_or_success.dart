import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../provider/thems.dart';
import '../../../../../provider/transcation_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../../sharedWidget/functions.dart';
import '../../../../../sharedWidget/list_divider.dart';

class UpiIdSucessorFaliureScreen extends StatefulWidget {
  const UpiIdSucessorFaliureScreen({
    super.key,
  });

  @override
  State<UpiIdSucessorFaliureScreen> createState() =>
      _UpiIdSucessorFaliureScreenState();
}

class _UpiIdSucessorFaliureScreenState
    extends State<UpiIdSucessorFaliureScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
      },
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final fund = ref.watch(transcationProvider);
            final theme = ref.watch(themeProvider);
            return Container(
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
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const CustomDragHandler(),
                        Icon(
                          fund.hdfcpaymentstatus!.upiId!.status == "SUCCESS"
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          //
                          color:
                              fund.hdfcpaymentstatus!.upiId!.status == "SUCCESS"
                                  ? theme.isDarkMode
                                      ? colors.profitDark
                                      : colors.profitLight
                                  : theme.isDarkMode
                                      ? colors.errorDark
                                      : colors.errorLight,
                          size: 70,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextWidget.subText(
                          text: "${fund.hdfcpaymentstatus!.upiId!.status}",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 0,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextWidget.paraText(
                          text: fund.hdfcpaymentstatus!.upiId!.status == "SUCCESS"
                              ? "Transaction Success"
                              : "Transaction fail",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextWidget.custmText(
                            text: "₹${fund.hdfcpaymentstatus!.upiId!.amount}",
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                            fs: 40),
                        const SizedBox(
                          height: 10,
                        ),
                        TextWidget.paraText(
                          text: formatDateTimepaymet(
                              value:
                                  "${fund.hdfcpaymentstatus!.upiId!.transactionAuthDate}"),
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  data("UPI Address",
                      "${fund.hdfcpaymentstatus!.upiId!.clientVPA}", theme),
                  data("Order ID",
                      "${fund.hdfcpaymentstatus!.upiId!.orderNumber}", theme),
                  data(
                      "UPI Transaction ID",
                      "${fund.hdfcpaymentstatus!.upiId!.upiTransactionNo}",
                      theme),
                  data(
                      "Status Description",
                      "${fund.hdfcpaymentstatus!.upiId!.statusDescription}",
                      theme),
                  const SizedBox(height: 16),
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
                          child: TextWidget.subText(
                              text: 'Done',
                              theme: false,
                              color: colors.colorWhite,
                              fw: 2)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          },
        ),
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
              fw: 0,
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
                fw: 0,
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
