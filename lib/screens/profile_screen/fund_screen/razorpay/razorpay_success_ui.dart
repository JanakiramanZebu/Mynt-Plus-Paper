import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import '../../../../provider/thems.dart';
//import '../../../../provider/transcation_provider.dart';
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
    return WillPopScope(
      onWillPop: () async {
        return false;
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
                      Text(
                        "SUCCESS",
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
                        "Payment Successful",
                        style: textStyle(colors.colorGrey, 14, FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "₹${widget.amount}.00".toString(),
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
                        time,
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
