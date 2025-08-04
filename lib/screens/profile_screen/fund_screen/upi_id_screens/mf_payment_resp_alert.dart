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

class MfPaymentRespAlert extends StatefulWidget {
  final Map<String, dynamic>? upiData;
  final String? conditionval;
  const MfPaymentRespAlert({
    this.conditionval,
    this.upiData,
    super.key,
  });

  @override
  State<MfPaymentRespAlert> createState() => _MfPaymentRespAlertState();
}

class _MfPaymentRespAlertState extends State<MfPaymentRespAlert> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
      },
      child: Consumer(
        builder: (context, ref, child) { 
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
            child: widget.conditionval == 'timeout' ? 
            
            Column(
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
                        color:   colors.kColorRedButton,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextWidget.subText(
                        text: "Request timeout",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextWidget.paraText(
                        text: widget.upiData?["status"] == "PAYMENT COMPLETED"
                            ? "Transaction Success"
                            : "Transaction fail",
                        theme: false,
                        color: colors.textSecondaryLight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.custmText(
                          text: "₹${widget.upiData?["OrderVal"] ?? widget.upiData?["InstallmentAmount"]}",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          fs: 40),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.paraText(
                        text: "${widget.upiData?["datetime"]}",
                        theme: false,
                        color: colors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // data("UPI Address", "${widget.upiData?["datetime"]}", theme),
                if(widget.upiData?["OrderId"] != null || widget.upiData?["OrderId"] != 'null')
                data("Order ID", "${widget.upiData?["OrderId"]}", theme),
                if(widget.upiData?["OrderId"] == null || widget.upiData?["OrderId"] == 'null')
                data("TransNo", "${widget.upiData?["TransNo"]}", theme),

                data("UPI Transaction ID", "${widget.upiData?["TransNo"]}",
                    theme),
                data("Status Description", "Request Timeout reinitiate from orderbook",
                    theme),
                const SizedBox(height: 16),
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
            ) : (widget.conditionval != '' && widget.conditionval != 'timeout' &&  widget.conditionval != 'reinitiateerror') ? Column(
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
                        color:   colors.kColorRedButton,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextWidget.subText(
                        text: "Payment Not Initiated",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextWidget.paraText(
                        text:  "Payment initiate fail",
                        theme: false,
                        color: colors.textSecondaryLight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // TextWidget.custmText(
                      //     text: "₹${widget.upiData?["OrderVal"] ?? widget.upiData?["InstallmentAmount"]}",
                      //     theme: false,
                      //     color: theme.isDarkMode
                      //         ? colors.colorWhite
                      //         : colors.colorBlack,
                      //     fs: 40),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // TextWidget.paraText(
                      //   text: "${widget.upiData?["datetime"]}",
                      //   theme: false,
                      //   color: colors.textSecondaryLight,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // data("UPI Address", "${widget.upiData?["datetime"]}", theme),
                // if(widget.upiData?["OrderId"] != null || widget.upiData?["OrderId"] != 'null')
                // data("Order ID", "${widget.upiData?["OrderId"]}", theme),
                // if(widget.upiData?["OrderId"] == null || widget.upiData?["OrderId"] == 'null')
                // data("TransNo", "${widget.upiData?["TransNo"]}", theme),

                 
                data("Status Description", "${widget.conditionval}",
                    theme),
                const SizedBox(height: 16),
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
            ) 
             :  widget.conditionval == 'reinitiateerror' ? 
            Column(
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
                        color:   colors.kColorRedButton,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextWidget.subText(
                        text: "Payment Not Initiated",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextWidget.paraText(
                        text:  "Payment initiate fail",
                        theme: false,
                        color: colors.textSecondaryLight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // TextWidget.custmText(
                      //     text: "₹${widget.upiData?["OrderVal"] ?? widget.upiData?["InstallmentAmount"]}",
                      //     theme: false,
                      //     color: theme.isDarkMode
                      //         ? colors.colorWhite
                      //         : colors.colorBlack,
                      //     fs: 40),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // TextWidget.paraText(
                      //   text: "${widget.upiData?["datetime"]}",
                      //   theme: false,
                      //   color: colors.textSecondaryLight,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // data("UPI Address", "${widget.upiData?["datetime"]}", theme),
                // if(widget.upiData?["OrderId"] != null || widget.upiData?["OrderId"] != 'null')
                // data("Order ID", "${widget.upiData?["OrderId"]}", theme),
                // if(widget.upiData?["OrderId"] == null || widget.upiData?["OrderId"] == 'null')
                // data("TransNo", "${widget.upiData?["TransNo"]}", theme),

                data("Payment type", "${widget.upiData?["type"]}",
                    theme),
                data("Status Description", "${widget.upiData?['responsestring'] ?? widget.upiData?['emsg']}",
                    theme),
                const SizedBox(height: 16),
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
            ) 


            :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const CustomDragHandler(),
                      Icon(
                        widget.upiData?["status"] == "PAYMENT COMPLETED"
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        //
                        color: widget.upiData?["status"] == "PAYMENT COMPLETED"
                            ? colors.kColorGreenButton
                            : colors.kColorRedButton,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextWidget.subText(
                        text: "${widget.upiData?["status"]}",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextWidget.paraText(
                        text: widget.upiData?["status"] == "PAYMENT COMPLETED"
                            ? "Transaction Success"
                            : "Transaction fail",
                        theme: false,
                        color: colors.textSecondaryLight,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.custmText(
                          text: "₹${widget.upiData?["OrderVal"] ?? widget.upiData?["InstallmentAmount"]}",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          fs: 40),
                      const SizedBox(
                        height: 10,
                      ),
                      TextWidget.paraText(
                        text: "${widget.upiData?["datetime"]}",
                        theme: false,
                        color: colors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // data("UPI Address", "${widget.upiData?["datetime"]}", theme),
                if(widget.upiData?["OrderId"] != null || widget.upiData?["OrderId"] != 'null')
                data("Order ID", "${widget.upiData?["OrderId"]}", theme),
                if(widget.upiData?["OrderId"] == null || widget.upiData?["OrderId"] == 'null')
                data("TransNo", "${widget.upiData?["TransNo"]}", theme),

                data("UPI Transaction ID", "${widget.upiData?["TransNo"]}",
                    theme),
                data("Status Description", "${widget.upiData?['Remarks']}",
                    theme),
                const SizedBox(height: 16),
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
            )
            ,
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
