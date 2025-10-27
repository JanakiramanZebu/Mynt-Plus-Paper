import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import '../../../../../provider/thems.dart';
//import '../../../../provider/transcation_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../../sharedWidget/functions.dart';
import '../../../../../sharedWidget/list_divider.dart';
import '../../../../../sharedWidget/loader_ui.dart';
import '../../../../../sharedWidget/splash_loader.dart';

class RazorpaySuccessUi extends StatefulWidget {
  final String amount;
  const RazorpaySuccessUi({
    super.key,
    required this.amount,
  });

  @override
  State<RazorpaySuccessUi> createState() => _RazorpaySuccessUiState();
}

class _RazorpaySuccessUiState extends State<RazorpaySuccessUi> {
  String time = '';
  @override
  void initState() {
    time = convDateWithTime();

    super.initState();
  }

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
        
            final amount = fund.razorpayTranstationRes?.amount;
            final amountString =
                amount != null ? (amount / 100).toStringAsFixed(2) : "0.00";
            return TransparentLoaderScreen(
              isLoading: fund.fundLoading,
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
                              Icons.check_circle_rounded,
                              //
                              color: theme.isDarkMode
                                  ? colors.profitDark
                                  : colors.profitLight,
                              size: 70,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TextWidget.subText(
                              text: "SUCCESS",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextWidget.paraText(
                              text: "Payment Successful",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextWidget.custmText(
                              text: "₹$amountString".toString(),
                              fs: 40,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextWidget.paraText(
                              text: time,
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      data(
                          "Bank Name",
                          fund.razorpayTranstationRes?.notes?.bankname
                                  ?.toString() ??
                              "",
                          theme),
                      data(
                          "A/c No",
                          fund.razorpayTranstationRes?.notes?.accNo?.toString() ??
                              "",
                          theme),
                      data(
                          "Payment Id",
                          fund.razorpayTranstationRes?.id?.toString() ?? "",
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
                                FocusScope.of(context).unfocus();
                              },
                              child: TextWidget.titleText(
                                  text: 'Close',
                                  theme: false,
                                  color: colors.colorWhite,
                                  fw: 2)),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )),
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
