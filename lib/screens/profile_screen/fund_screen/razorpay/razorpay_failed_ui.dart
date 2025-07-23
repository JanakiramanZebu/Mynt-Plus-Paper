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

class RazorpayFailedUi extends StatefulWidget {
  final String acco;
  final String ifsc;
  final String amount;
  final String bankname;
  const RazorpayFailedUi({
    super.key,
    required this.acco,
    required this.ifsc,
    required this.amount,
    required this.bankname,
  });

  @override
  State<RazorpayFailedUi> createState() => _RazorpayFailedUiState();
}

class _RazorpayFailedUiState extends State<RazorpayFailedUi> {
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
      child: Consumer(
        builder: (context, ref, child) {
          //  final fund = ref.watch(transcationProvider);
          final theme = ref.watch(themeProvider);
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const CustomDragHandler(),
                        Icon(
                          Icons.cancel_rounded,
                          //
                          color: colors.kColorRedButton,
                          size: 70,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextWidget.subText(
                          text: "Failed",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextWidget.subText(
                          text: "Your payment has failed.",
                          theme: false,
                          color: colors.textSecondaryLight,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextWidget.custmText(
                            text: "₹${widget.amount}.00",
                            fs: 40,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: false),
                        const SizedBox(
                          height: 10,
                        ),
                        TextWidget.paraText(
                          text: time,
                          theme: false,
                          color: colors.textSecondaryLight,
                        ),
                      ],
                    ),
                  ),
                  data("Bank Name", widget.bankname, theme),
                  data("A/c No", widget.acco, theme),
                  data(
                      "Reason",
                      "Your payment has been cancelled. Try again or complete the payment later.",
                      theme),
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
                            minimumSize: const Size(0, 40),
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
                          child: TextWidget.subText(
                              text: 'Close',
                              theme: false,
                              color: colors.colorWhite,
                              fw: 2)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ));
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
            SizedBox(
              width: 200,
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
