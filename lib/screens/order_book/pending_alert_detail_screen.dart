import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_drag_handler.dart';
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
      double currentLtp =
          double.tryParse(widget.alert.ltp ?? widget.alert.close ?? "0.0") ??
              0.0;

      // Check alert type
      if ((widget.alert.aiT == "LTP_A" || widget.alert.aiT == "LTP_B") &&
          value.isNotEmpty) {
        double enteredValue = double.parse(value);

        // Format numbers to show 2 decimal places
        String formattedLtp = currentLtp.toStringAsFixed(2);
        String formattedEnteredValue = enteredValue.toStringAsFixed(2);

        // Validation based on condition
        if (widget.alert.aiT == "LTP_A" && enteredValue <= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already above ₹$formattedEnteredValue";
        } else if (widget.alert.aiT == "LTP_B" && enteredValue >= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already below ₹$formattedEnteredValue";
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
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.05,
        maxChildSize: 0.99,
        builder: (context, scrollController) {
          return Consumer(builder: (context, ref, _) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                decoration: BoxDecoration(
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const CustomDragHandler(),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              TextWidget.headText(
                                                  text: "${widget.alert.tsym?.replaceAll("-EQ", "")} ",
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? colors.textPrimaryDark
                                                      : colors.textPrimaryLight,
                                                  fw: 0,
                                                  textOverflow:
                                                      TextOverflow.ellipsis),
                                              CustomExchBadge(
                                                  exch: "${widget.alert.exch}"),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          TextWidget.titleText(
                                              text:
                                                  "₹${widget.alert.ltp ?? widget.alert.close ?? 0.00}",
                                              theme: theme.isDarkMode,
                                              color: widget.alert.perChange ==
                                                      null
                                                  ? theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight
                                                  : widget.alert.perChange!
                                                          .startsWith("-")
                                                      ? theme.isDarkMode
                                                          ? colors.lossDark
                                                          : colors.lossLight
                                                      : widget.alert
                                                                  .perChange ==
                                                              "0.00"
                                                          ? theme.isDarkMode
                                                              ? colors
                                                                  .textSecondaryDark
                                                              : colors
                                                                  .textSecondaryLight
                                                          : theme.isDarkMode
                                                              ? colors
                                                                  .profitDark
                                                              : colors
                                                                  .profitLight,
                                              fw: 3),
                                          const SizedBox(height: 4),
                                          TextWidget.paraText(
                                              text:
                                                  "${widget.alert.perChange ?? 0.00}%",
                                              theme: false,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              fw: 0),
                                        ]),
                                    const SizedBox(height: 16),
                                  ]),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: colors.btnBg,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  color:
                                                      colors.btnOutlinedBorder,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                shape:
                                                    const BeveledRectangleBorder(),
                                                child: InkWell(
                                                  customBorder:
                                                      const BeveledRectangleBorder(),
                                                  splashColor: theme.isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? colors.highlightDark
                                                      : colors.highlightLight,
                                                  onTap: (isModifying ||
                                                          isCancelling ||
                                                          errorText
                                                              .isNotEmpty ||
                                                          valueCtrl
                                                              .text.isEmpty)
                                                      ? null
                                                      : () async {
                                                          setState(() {
                                                            isModifying = true;
                                                          });

                                                          try {
                                                            await ref
                                                                .read(
                                                                    marketWatchProvider)
                                                                .fetchmodifyalert(
                                                                  "${widget.alert.exch}",
                                                                  "${widget.alert.tsym}",
                                                                  modifiedValue,
                                                                  "${widget.alert.aiT}",
                                                                  "${widget.alert.alId}",
                                                                  context,
                                                                );

                                                            await ref
                                                                .read(
                                                                    marketWatchProvider)
                                                                .fetchPendingAlert(
                                                                    context);

                                                            if (mounted)
                                                              Navigator.pop(
                                                                  context);
                                                          } catch (e) {
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    "Failed to modify alert: ${e.toString()}",
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          } finally {
                                                            if (mounted) {
                                                              setState(() {
                                                                isModifying =
                                                                    false;
                                                              });
                                                            }
                                                          }
                                                        },
                                                  child: Center(
                                                    child: isModifying
                                                        ? SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .primaryDark
                                                                  : colors
                                                                      .primaryLight,
                                                            ),
                                                          )
                                                        : TextWidget.subText(
                                                            text:
                                                                "Modify Alert",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .primaryDark
                                                                : colors
                                                                    .primaryLight,
                                                            fw: 2,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: colors.btnBg,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  color:
                                                      colors.btnOutlinedBorder,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                shape:
                                                    const BeveledRectangleBorder(),
                                                child: InkWell(
                                                  customBorder:
                                                      const BeveledRectangleBorder(),
                                                  splashColor: theme.isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? colors.highlightDark
                                                      : colors.highlightLight,
                                                  onTap: isModifying ||
                                                          isCancelling
                                                      ? null
                                                      : () async {
                                                          setState(() {
                                                            isCancelling = true;
                                                          });

                                                          try {
                                                            final String
                                                                alertId =
                                                                "${widget.alert.alId}";

                                                            await ref
                                                                .read(
                                                                    marketWatchProvider)
                                                                .fetchCancelAlert(
                                                                    alertId,
                                                                    context);

                                                            await ref
                                                                .read(
                                                                    marketWatchProvider)
                                                                .fetchPendingAlert(
                                                                    context);

                                                            if (mounted)
                                                              Navigator.pop(
                                                                  context);
                                                          } catch (e) {
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      "Failed to cancel alert: ${e.toString()}"),
                                                                ),
                                                              );
                                                            }
                                                          } finally {
                                                            if (mounted) {
                                                              setState(() {
                                                                isCancelling =
                                                                    false;
                                                              });
                                                            }
                                                          }
                                                        },
                                                  child: Center(
                                                    child: isCancelling
                                                        ? SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .primaryDark
                                                                  : colors
                                                                      .primaryLight,
                                                            ),
                                                          )
                                                        : TextWidget.subText(
                                                            text:
                                                                "Cancel Alert",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .primaryDark
                                                                : colors
                                                                    .primaryLight,
                                                            fw: 2,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
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
                              Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWidget.subText(
                                        text: "Condition",
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                    Row(
                                      children: [
                                        TextWidget.subText(
                                            text: widget.alert.aiT == "LTP_A"
                                                ? "Above"
                                                : widget.alert.aiT == "LTP_B"
                                                    ? "Below"
                                                    : widget.alert.aiT ==
                                                            "CH_PER_A"
                                                        ? "above"
                                                        : "Below",
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                        Transform.rotate(
                                          angle: 55 * (pi / 180),
                                          child: Icon(
                                              widget.alert.aiT == "LTP_A"
                                                  ? Icons.arrow_upward
                                                  : widget.alert.aiT == "LTP_B"
                                                      ? Icons.arrow_downward
                                                      : widget.alert.aiT ==
                                                              "CH_PER_A"
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward,
                                              size: 18,
                                              color: widget.alert.aiT == "LTP_A"
                                                  ? colors.ltpgreen
                                                  : widget.alert.aiT == "LTP_B"
                                                      ? colors.darkred
                                                      : widget.alert.aiT ==
                                                              "CH_PER_A"
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
                              alertData(
                                  "Date&Time",
                                  formatDateTime(
                                      value: "${widget.alert.norentm}"),
                                  theme),
                              Row(
                                children: [
                                  TextWidget.subText(
                                      text: "Modify Alert value",
                                      theme: theme.isDarkMode,
                                      fw: 0),
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
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
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
                                                const Color(0xff999999),
                                                14,
                                                FontWeight.w600),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 16),
                                            prefixIconColor:
                                                const Color(0xff586279),
                                            prefixIcon: widget.alert.aiT ==
                                                        "CH_PER_A" ||
                                                    widget.alert.aiT ==
                                                        "CH_PER_B"
                                                ? const Icon(
                                                    Icons.percent_outlined,
                                                    size: 18,
                                                  )
                                                : SvgPicture.asset(
                                                    assets.ruppeIcon,
                                                    fit: BoxFit.scaleDown),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            disabledBorder: InputBorder.none,
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30))),
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
                              if (errorText.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 4),
                                  child: TextWidget.captionText(
                                      text: errorText,
                                      theme: false,
                                      color: colors.darkred,
                                      fw: 0),
                                ),
                              ],
                              const SizedBox(
                                height: 8,
                              ),
                              widget.alert.remarks == ""
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Divider(
                                              color: theme.isDarkMode
                                                  ? colors.darkColorDivider
                                                  : colors.colorDivider),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          TextWidget.subText(
                                              text: "Remark",
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          TextWidget.subText(
                                              text: "${widget.alert.remarks}",
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                        ],
                                      ),
                                    ),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Padding alertData(
    String title1,
    String value,
    ThemesProvider theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(text: title1, theme: theme.isDarkMode, fw: 0),
            TextWidget.subText(text: value, theme: theme.isDarkMode, fw: 0),
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
}
