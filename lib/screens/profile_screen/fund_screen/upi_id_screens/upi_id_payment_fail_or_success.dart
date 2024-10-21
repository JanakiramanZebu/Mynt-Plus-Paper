import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/list_divider.dart';

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
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Consumer(
        builder: (context, watch, child) {
          final fund = watch(transcationProvider);
          final theme = watch(themeProvider);
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
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
                                ? colors.kColorGreenButton
                                : colors.kColorRedButton,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${fund.hdfcpaymentstatus!.upiId!.status}",
                        style:
                            textStyle(colors.colorBlack, 16, FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        fund.hdfcpaymentstatus!.upiId!.status == "SUCCESS"
                            ? "Transaction Success"
                            : "Transaction fail",
                        style: textStyle(colors.colorGrey, 14, FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "₹${fund.hdfcpaymentstatus!.upiId!.amount}",
                        style:
                            textStyle(colors.colorBlack, 40, FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        formatDateTimepaymet(
                            value:
                                "${fund.hdfcpaymentstatus!.upiId!.transactionAuthDate}"),
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
                contantTitleText("${fund.hdfcpaymentstatus!.upiId!.clientVPA}"),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("Order ID"),
                contantTitleText(
                    "${fund.hdfcpaymentstatus!.upiId!.orderNumber}"),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("UPI Transaction ID"),
                contantTitleText(
                    "${fund.hdfcpaymentstatus!.upiId!.upiTransactionNo}"),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText("Status Description"),
                contantTitleText(
                    "${fund.hdfcpaymentstatus!.upiId!.statusDescription}"),
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
                        'Done',
                        style:
                            textStyle(colors.colorWhite, 16, FontWeight.w400),
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

  Text contantTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorBlack, 15, FontWeight.w600),
    );
  }
}
