import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import '../../../../provider/thems.dart';
//import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/list_divider.dart';

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
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const CustomDragHandler(),
                      Icon(
                        Icons.check_circle_rounded,
                        //
                        color: colors.kColorGreenButton,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.titleText(
                          text: "SUCCESS",
                          theme: false,
                          color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                          fw: 1),
                      const SizedBox(
                        height: 5,
                      ),
                      TextWidget.subText(
                          text: "Payment Successful",
                          theme: false,
                          color: colors.colorGrey,
                          fw: 0),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.custmText(
                          text: "₹${widget.amount}.00".toString(),
                          fs: 40,
                          theme: theme.isDarkMode,
                          fw: 1),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.subText(
                          text: time,
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
                headerTitleText("Bank Name"),
                contantTitleText(
                    fund.razorpayTranstationRes!.notes!.bankname.toString(),
                    theme),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("A/c No"),
                contantTitleText(
                    fund.razorpayTranstationRes!.notes!.accNo.toString(),
                    theme),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("Payment Id"),
                contantTitleText(
                    fund.razorpayTranstationRes!.id.toString(), theme),
                const SizedBox(
                  height: 15,
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
                        FocusScope.of(context).unfocus();
                      },
                      child: TextWidget.titleText(
                          text: 'Close',
                          theme: false,
                          color: theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                          fw: 1)),
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
