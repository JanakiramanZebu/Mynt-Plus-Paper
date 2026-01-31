import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/sharedWidget/custom_drag_handler.dart';

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
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final theme = ref.watch(themeProvider);
            final mfpro = ref.watch(mfProvider);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),

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
                                  ),

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
                        const CustomDragHandler(),
                        Icon(

                               Icons.cancel_rounded,
                          //
                          color: theme.isDarkMode ? colors.lossDark : colors.lossLight,

                          size: 70,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Request timeout",
                          style: MyntWebTextStyles.title(
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
                  if(widget.upiData?["OrderId"] != null || widget.upiData?["OrderId"] != 'null' ||  widget.upiData?["OrderId"] != '')
                  _dataRow("Order ID", "${widget.upiData?["OrderId"]}", context),
                  if(widget.upiData?["OrderId"] == null || widget.upiData?["OrderId"] == 'null' || widget.upiData?["OrderId"] == '')
                  _dataRow("TransNo", "${widget.upiData?["TransNo"]}", context),

                  _dataRow("UPI Transaction ID", "${widget.upiData?["TransNo"]}", context),
                  _dataRow("Status Description", "Request Timeout reinitiate from orderbook", context),
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
                        const CustomDragHandler(),
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
                          style: MyntWebTextStyles.title(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _dataRow("Status Description", "${widget.conditionval}", context),
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
                        const CustomDragHandler(),
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
                          style: MyntWebTextStyles.title(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _dataRow("Payment type", "${widget.upiData?["type"]}", context),
                  _dataRow("Status Description", "${widget.upiData?['responsestring'] ?? widget.upiData?['emsg']}", context),
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
                        const CustomDragHandler(),
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
                          style: MyntWebTextStyles.title(
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
                  if(mfpro.mfOrderTpye != 'SIP')
                  _dataRow("Order ID", "${widget.upiData?["OrderId"]}", context),
                  if(mfpro.mfOrderTpye == 'SIP')

                  _dataRow("TransNo", "${widget.upiData?["OrderId"] ?? widget.upiData?["TransNo"]}", context),

                  _dataRow("UPI Transaction ID", "${widget.upiData?["TransNo"]}", context),
                  _dataRow("Status Description", "${widget.upiData?['Remarks']}", context),
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

  Widget _dataRow(String name, String value, BuildContext context) {
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
                lightColor: colors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: MyntWebTextStyles.body(
                  context,
                  darkColor: colors.textPrimaryDark,
                  lightColor: colors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: isDarkMode(context) ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }
}
