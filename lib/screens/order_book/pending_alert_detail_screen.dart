import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';

class PendingAlertDetails extends ConsumerStatefulWidget {
  final AlertPendingModel alert;
  const PendingAlertDetails({super.key, required this.alert});

  @override
  ConsumerState<PendingAlertDetails> createState() =>
      _PendingAlertDetailsState();
}

class _PendingAlertDetailsState extends ConsumerState<PendingAlertDetails> {
  bool isModifying = false;
  bool isCancelling = false;
  late TextEditingController valueCtrl;
  String modifiedValue = "";
  String errorText = "";
  
  @override
  void initState() {
    super.initState();
    valueCtrl = TextEditingController(text: widget.alert.d);
    modifiedValue = widget.alert.d ?? "";
    
    // Listen for changes to preserve the value
    valueCtrl.addListener(() {
      modifiedValue = valueCtrl.text;
    });
  }
  
  // Add validation logic similar to set_alert_screen.dart
  validateAlertValue(String value) {
    try {
      if (value.isEmpty) {
        errorText = "* Value is required";
        return;
      }
      
      // Get current LTP
      double currentLtp = double.tryParse(widget.alert.ltp ?? widget.alert.close ?? "0.0") ?? 0.0;
      
      // Check alert type
      if ((widget.alert.aiT == "LTP_A" || widget.alert.aiT == "LTP_B") && value.isNotEmpty) {
        double enteredValue = double.parse(value);
        
        // Format numbers to show 2 decimal places
        String formattedLtp = currentLtp.toStringAsFixed(2);
        String formattedEnteredValue = enteredValue.toStringAsFixed(2);
        
        // Validation based on condition
        if (widget.alert.aiT == "LTP_A" && enteredValue <= currentLtp) {
          errorText = "The Current LTP (₹$formattedLtp) is already above ₹$formattedEnteredValue";
        } else if (widget.alert.aiT == "LTP_B" && enteredValue >= currentLtp) {
          errorText = "The Current LTP (₹$formattedLtp) is already below ₹$formattedEnteredValue";
        } else {
          errorText = "";
        }
      } else {
        // For percentage change, no validation needed
        errorText = "";
      }
    } catch (e) {
      errorText = "Please enter a valid number";
    }
  }
  
  @override
  void dispose() {
    valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 41,
        titleSpacing: 6,
        leading: const CustomBackBtn(),
        elevation: 0.3,
        title: Text('Alert',
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w600)),
      ),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar:
       SafeArea(
         child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
           child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: isModifying || isCancelling || errorText.isNotEmpty || valueCtrl.text.isEmpty
                          ? null 
                          : () async {
                            setState(() {
                              isModifying = true;
                            });
                            
                            try {
                              // Use the preserved value for the API call
                              await ref.read(marketWatchProvider).fetchmodifyalert(
                              "${widget.alert.exch}",
                              "${widget.alert.tsym}",
                                  modifiedValue,
                              "${widget.alert.aiT}",
                              "${widget.alert.alId}",
                              context);
                                  
                              // Then fetch updated pending alerts
                              await ref.read(marketWatchProvider).fetchPendingAlert(context);
                              
                              // Finally navigate back
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              // Show error if modification fails
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to modify alert: ${e.toString()}")),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isModifying = false;
                                });
                              }
                            }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: (isModifying || errorText.isNotEmpty || valueCtrl.text.isEmpty)
                                ? Colors.grey
                                : theme.isDarkMode
                                ? colors.colorbluegrey
                                : colors.colorBlack,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50))),
                        child: isModifying
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                                ))
                            : Text("Modify Alert",
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)))),
                const SizedBox(width: 16),
                Expanded(
                    child: ElevatedButton(
                        onPressed: isModifying || isCancelling
                          ? null
                          : () async {
                            setState(() {
                              isCancelling = true;
                            });
                            
                            try {
                              // Store the alert ID
                          final String alertId = "${widget.alert.alId}";
           
                              // First cancel the alert
                              await ref.read(marketWatchProvider).fetchCancelAlert(alertId, context);
           
                              // Then fetch updated pending alerts
                              await ref.read(marketWatchProvider).fetchPendingAlert(context);
                              
                              // Finally navigate back
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              // Show error if cancellation fails
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to cancel alert: ${e.toString()}")),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isCancelling = false;
                                });
                              }
                            }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: isCancelling 
                                ? Colors.grey 
                                : colors.darkred,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50))),
                        child: isCancelling
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.colorWhite,
                                ))
                            : Text("Cancel Alert",
                            style: textStyle(
                                const Color(0xffFFFFFF), 14, FontWeight.w500)))),
              ],
            ),
                 ),
         ),
       ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        width: 4))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${widget.alert.tsym} ",
                            overflow: TextOverflow.ellipsis,
                            style: textStyles.scripNameTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack)),
                        Row(
                          children: [
                            Text(" LTP: ",
                                style: textStyle(const Color(0xff5E6B7D), 13,
                                    FontWeight.w600)),
                            Text(
                                "₹${widget.alert.ltp ?? widget.alert.close ?? 0.00}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500)),
                          ],
                        )
                      ]),
                  const SizedBox(height: 4),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomExchBadge(exch: "${widget.alert.exch}"),
                        Text(" (${widget.alert.perChange ?? 0.00}%)",
                            style: textStyle(
                                widget.alert.perChange == null
                                    ? colors.ltpgrey
                                    : widget.alert.perChange!.startsWith("-")
                                    ? colors.darkred
                                    : widget.alert.perChange == "0.00"
                                        ? colors.ltpgrey
                                        : colors.ltpgreen,
                                12,
                                FontWeight.w500))
                      ]),
                ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Details",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      15,
                      FontWeight.w600),
                ),
              ],
            ),
          ),
          alertData(
              "Type",
              widget.alert.aiT == "LTP_A"
                  ? "LTP"
                  : widget.alert.aiT == "LTP_B"
                      ? "LTP"
                      : widget.alert.aiT == "CH_PER_A"
                          ? "Perc.Change"
                          : "Perc.Change",
              theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Condition",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w500)),
                  Row(
                    children: [
                      Text(
                          widget.alert.aiT == "LTP_A"
                              ? "Above"
                              : widget.alert.aiT == "LTP_B"
                                  ? "Below"
                                  : widget.alert.aiT == "CH_PER_A"
                                      ? "above"
                                      : "Below",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                      Transform.rotate(
                        angle: 55 * (pi / 180),
                        child: Icon(
                            widget.alert.aiT == "LTP_A"
                                ? Icons.arrow_upward
                                : widget.alert.aiT == "LTP_B"
                                    ? Icons.arrow_downward
                                    : widget.alert.aiT == "CH_PER_A"
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                            size: 18,
                            color: widget.alert.aiT == "LTP_A"
                                ? colors.ltpgreen
                                : widget.alert.aiT == "LTP_B"
                                    ? colors.darkred
                                    : widget.alert.aiT == "CH_PER_A"
                                        ? colors.ltpgreen
                                        : colors.darkred),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider)
            ]),
          ),
          alertData("Date&Time",
              formatDateTime(value: "${widget.alert.norentm}"), theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text("Modify Alert value",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                const SizedBox(
                  width: 50,
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextFormField(
                      //textAlign: TextAlign.right,
                      controller: valueCtrl,
                      inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          filled: true,
                          hintText: "0",
                          hintStyle: textStyle(
                              const Color(0xff999999), 14, FontWeight.w600),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          prefixIconColor: const Color(0xff586279),
                          prefixIcon: widget.alert.aiT == "CH_PER_A" ||
                                  widget.alert.aiT == "CH_PER_B"
                              ? const Icon(
                                  Icons.percent_outlined,
                                  size: 18,
                                )
                              : SvgPicture.asset(assets.ruppeIcon,
                                  fit: BoxFit.scaleDown),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30))),
                      onChanged: (value) {
                        // Don't block the input operation, apply validation after the text change
                        Future.microtask(() {
                          if (mounted) {
                            setState(() {
                              // Handle validation
                              validateAlertValue(value);
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorText.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
              child: Text(errorText,
                  style: textStyle(colors.darkred, 10, FontWeight.w500)),
            ),
          ],
          const SizedBox(
            height: 8,
          ),
          widget.alert.remarks == ""
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider),
                      const SizedBox(
                        height: 8,
                      ),
                      Text("Remark",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text("${widget.alert.remarks}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                    ],
                  ),
                ),
        ]),
      ),
    );
  }

  Padding alertData(
    String title1,
    String value,
    ThemesProvider theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title1,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            Text(value,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
