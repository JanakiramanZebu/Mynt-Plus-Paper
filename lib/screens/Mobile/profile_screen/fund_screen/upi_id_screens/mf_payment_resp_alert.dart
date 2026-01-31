import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/mf_provider.dart';

import '../../../../../provider/thems.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../res/res.dart';

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
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Consumer(
          builder: (context, ref, child) {
            final theme = ref.watch(themeProvider);
            final mfpro = ref.watch(mfProvider);
            return Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
              child: widget.conditionval == 'timeout' ?

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(

                               Icons.cancel_rounded,
                          //
                          color: theme.isDarkMode ? colors.lossDark : colors.lossLight,

                          size: 50,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Request timeout",
                          style: MyntWebTextStyles.body(
                            context,
                            darkColor: colors.textPrimaryDark,
                            lightColor: colors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.upiData?["status"] == "PAYMENT COMPLETED"
                              ? "Transaction Success"
                              : "Transaction fail",
                          style: MyntWebTextStyles.para(
                            context,
                            darkColor: colors.textSecondaryDark,
                            lightColor: colors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "₹${widget.upiData?["OrderVal"] ?? widget.upiData?["InstallmentAmount"]}",
                          style: MyntWebTextStyles.title(
                            context,
                            darkColor: colors.textPrimaryDark,
                            lightColor: colors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${widget.upiData?["datetime"]}",
                          style: MyntWebTextStyles.para(
                            context,
                            darkColor: colors.textSecondaryDark,
                            lightColor: colors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // data("UPI Address", "${widget.upiData?["datetime"]}", theme),
                  if(widget.upiData?["OrderId"] != null || widget.upiData?["OrderId"] != 'null' ||  widget.upiData?["OrderId"] != '')
                  data("Order ID", "${widget.upiData?["OrderId"]}", theme),
                  if(widget.upiData?["OrderId"] == null || widget.upiData?["OrderId"] == 'null' || widget.upiData?["OrderId"] == '')
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
                            Navigator.pop(context);
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            'Done',
                            style: MyntWebTextStyles.buttonMd(
                              context,
                              color: colors.colorWhite,
                            ),
                          )),
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
                        Icon(

                               Icons.cancel_rounded,
                          //
                          color:   theme.isDarkMode ? colors.lossDark : colors.lossLight,
                          size: 70,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Payment Not Initiated",
                          style: MyntWebTextStyles.body(
                            context,
                            darkColor: colors.textPrimaryDark,
                            lightColor: colors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Payment initiate fail",
                          style: MyntWebTextStyles.para(
                            context,
                            darkColor: colors.textSecondaryDark,
                            lightColor: colors.textSecondaryLight,
                          ),
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
                            Navigator.pop(context);
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            'Done',
                            style: MyntWebTextStyles.buttonMd(
                              context,
                              color: colors.colorWhite,
                            ),
                          )),
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
                        Icon(

                               Icons.cancel_rounded,
                          //
                          color:   theme.isDarkMode ? colors.lossDark : colors.lossLight,
                          size: 70,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Payment Not Initiated",
                          style: MyntWebTextStyles.body(
                            context,
                            darkColor: colors.textPrimaryDark,
                            lightColor: colors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Payment initiate fail",
                          style: MyntWebTextStyles.para(
                            context,
                            darkColor: colors.textSecondaryDark,
                            lightColor: colors.textSecondaryLight,
                          ),
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
                            Navigator.pop(context);
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            'Done',
                            style: MyntWebTextStyles.buttonMd(
                              context,
                              color: colors.colorWhite,
                            ),
                          )),
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
                        Icon(
                          widget.upiData?["status"] == "PAYMENT COMPLETED" || widget.upiData?["status"] == "REGISTERED"
                              ? Icons.check_circle_rounded : widget.upiData?["status"] == "PAYMENT PROCESSING" ?
                               Icons.schedule : Icons.cancel_rounded,
                          //
                          color: widget.upiData?["status"] == "PAYMENT COMPLETED" || widget.upiData?["status"] == "REGISTERED"
                              ? theme.isDarkMode ? colors.profitDark : colors.profitLight
                              : widget.upiData?["status"] == "PAYMENT PROCESSING"
                              ? colors.pending
                              : theme.isDarkMode ? colors.lossDark : colors.lossLight,
                          size: 70,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "${widget.upiData?["status"]}",
                          style: MyntWebTextStyles.body(
                            context,
                            darkColor: colors.textPrimaryDark,
                            lightColor: colors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        if(mfpro.mfOrderTpye != 'SIP')
                        Text(
                          widget.upiData?["status"] == "PAYMENT COMPLETED"
                              ? "Transaction Success" :  widget.upiData?["status"] == "PAYMENT PROCESSING" ?  "Transaction pending"
                              : "Transaction fail",
                          style: MyntWebTextStyles.para(
                            context,
                            darkColor: colors.textSecondaryDark,
                            lightColor: colors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "₹${widget.upiData?["OrderVal"] ?? widget.upiData?["InstallmentAmount"]}",
                          style: webText(
                            context,
                            size: 40,
                            darkColor: colors.textPrimaryDark,
                            lightColor: colors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${widget.upiData?["datetime"]}",
                          style: MyntWebTextStyles.para(
                            context,
                            darkColor: colors.textSecondaryDark,
                            lightColor: colors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // data("UPI Address", "${widget.upiData?["datetime"]}", theme),
                  if(mfpro.mfOrderTpye != 'SIP')
                  data("Order ID", "${widget.upiData?["OrderId"]}", theme),
                  if(mfpro.mfOrderTpye == 'SIP')

                  data("TransNo", "${widget.upiData?["OrderId"] ?? widget.upiData?["TransNo"]}", theme),

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
                            Navigator.pop(context);
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            'Done',
                            style: MyntWebTextStyles.buttonMd(
                              context,
                              color: colors.colorWhite,
                            ),
                          )),
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
            Text(
              name,
              style: MyntWebTextStyles.body(
                context,
                darkColor: colors.textSecondaryDark,
                lightColor: colors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: MyntWebTextStyles.body(
                  context,
                  darkColor: colors.textPrimaryDark,
                  lightColor: colors.textPrimaryLight,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }
}
