import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/snack_bar.dart';

class PendingAlertDetailScreenWeb extends ConsumerStatefulWidget {
  final AlertPendingModel alert;

  const PendingAlertDetailScreenWeb({super.key, required this.alert});

  @override
  ConsumerState<PendingAlertDetailScreenWeb> createState() =>
      _PendingAlertDetailScreenWebState();
}

class _PendingAlertDetailScreenWebState
    extends ConsumerState<PendingAlertDetailScreenWeb> {
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
    return Dialog(
     backgroundColor: WebColors.surface,
      child: Container(
        width: 500,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: BoxDecoration(
              // color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(5),
              // border: Border.all(
              //   color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
              // ),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

             Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       // Symbol and Price Section
                    _buildSymbolSection(theme),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  
                    
                    // Action Buttons
                    // const SizedBox(height: 24),
                    
                    // Alert Details Section
                    _buildAlertDetailsSection(theme),
                    const SizedBox(height: 16),
                    _buildActionButtons(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Alert Details',
            style: TextWidget.textStyle(
              fontSize: 18,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSection(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symbol and Exchange
        Row(
          children: [
            Text(
              "${widget.alert.tsym?.replaceAll("-EQ", "")}",
              style: TextWidget.textStyle(
                fontSize: 16,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 1,
              ),
            ),

              const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode ? colors.primaryDark.withOpacity(0.7) : colors.primaryLight.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "${widget.alert.exch ?? ''}",
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      theme: false,
                     color: colors.textPrimaryDark,
                  fw: 1,
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Price and Change
        Row(
          children: [
            Text(
              "${widget.alert.ltp ?? widget.alert.close ?? 0.00}",
              style: TextWidget.textStyle(
                fontSize: 16,
                theme: false,
                color: widget.alert.change == null
                    ? theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight
                    : widget.alert.change!.startsWith("-")
                        ? theme.isDarkMode
                            ? colors.lossDark
                            : colors.lossLight
                        : widget.alert.change == "0.00"
                            ? theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight
                            : theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight,
                fw: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${widget.alert.perChange ?? 0.00}%",
              style: TextWidget.textStyle(
                fontSize: 16,
                theme: false,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                fw: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemesProvider theme) {
    return Row(
      children: [
        // Expanded(
        //   child: Container(
        //     height: 45,
        //     decoration: BoxDecoration(
        //       color: theme.isDarkMode
        //           ? colors.textSecondaryDark.withOpacity(0.6)
        //           : colors.btnBg,
        //       borderRadius: BorderRadius.circular(5),
        //       border: theme.isDarkMode
        //           ? null
        //           : Border.all(
        //               color: colors.primaryLight,
        //               width: 1),
        //     ),
        //     child: Material(
        //       color: Colors.transparent,
        //       child: InkWell(
        //         customBorder: const BeveledRectangleBorder(),
        //         splashColor: theme.isDarkMode
        //             ? colors.splashColorDark
        //             : colors.splashColorLight,
        //         highlightColor: theme.isDarkMode
        //             ? colors.highlightDark
        //             : colors.highlightLight,
        //         onTap: isModifying || isCancelling
        //             ? null
        //             : () async {
        //                 setState(() {
        //                   isCancelling = true;
        //                 });

        //                 try {
        //                   final String alertId = "${widget.alert.alId}";

        //                   await ref
        //                       .read(marketWatchProvider)
        //                       .fetchCancelAlert(alertId, context);

        //                   await ref
        //                       .read(marketWatchProvider)
        //                       .fetchPendingAlert(context);

        //                   if (mounted) Navigator.pop(context);
        //                 } catch (e) {
        //                   if (mounted) {
        //                     showResponsiveErrorMessage(
        //                         context,
        //                         "Failed to cancel alert: ${e.toString()}");
        //                   }
        //                 } finally {
        //                   if (mounted) {
        //                     setState(() {
        //                       isCancelling = false;
        //                     });
        //                   }
        //                 }
        //               },
        //         child: Center(
        //           child: isCancelling
        //               ? SizedBox(
        //                   height: 20,
        //                   width: 20,
        //                   child: CircularProgressIndicator(
        //                     strokeWidth: 2,
        //                     color: colors.colorWhite,
        //                   ),
        //                 )
        //               : TextWidget.subText(
        //                   text: "Cancel Alert",
        //                   theme: false,
        //                   color: theme.isDarkMode
        //                       ? colors.colorWhite
        //                       : colors.primaryLight,
        //                   fw: 2,
        //                 ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: colors.primaryLight,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const BeveledRectangleBorder(),
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.highlightDark
                    : colors.highlightLight,
                onTap: (isModifying ||
                        isCancelling ||
                        errorText.isNotEmpty ||
                        valueCtrl.text.isEmpty)
                    ? null
                    : () async {
                        setState(() {
                          isModifying = true;
                        });

                        try {
                          await ref.read(marketWatchProvider).fetchmodifyalert(
                            "${widget.alert.exch}",
                            "${widget.alert.tsym}",
                            modifiedValue,
                            "${widget.alert.aiT}",
                            "${widget.alert.alId}",
                            context,
                          );

                          await ref
                              .read(marketWatchProvider)
                              .fetchPendingAlert(context);

                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted) {
                            showResponsiveErrorMessage(
                                context,
                                "Failed to modify alert: ${e.toString()}");
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              isModifying = false;
                            });
                          }
                        }
                      },
                child: Center(
                  child: isModifying
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.colorWhite,
                          ),
                        )
                      : TextWidget.subText(
                          text: "Modify Alert",
                          theme: false,
                          color: colors.colorWhite,
                          fw: 2,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertDetailsSection(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _alertData("Type", widget.alert.aiT == "LTP_A"
            ? "LTP"
            : widget.alert.aiT == "LTP_B"
                ? "LTP"
                : widget.alert.aiT == "CH_PER_A"
                    ? "Perc.Change"
                    : "Perc.Change", theme),
        const SizedBox(height: 8),
        _alertDataCondition(theme),
        const SizedBox(height: 8),
        _alertData("Date&Time", formatDateTime(value: "${widget.alert.norentm}"), theme),
        const SizedBox(height: 16),
        _buildModifyValueField(theme),
      ],
    );
  }

  Widget _buildModifyValueField(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: "Modify Alert value",
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textSecondary
              : WebColors.textSecondary,
          fw: 1,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: CustomTextFormField(
            fillColor: theme.isDarkMode
                ? WebDarkColors.backgroundTertiary
                : WebColors.backgroundTertiary,
            textCtrl: valueCtrl,
            textAlign: TextAlign.start,
            inputFormate: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: TextInputType.number,
            hintText: "0",
            hintStyle: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: widget.alert.aiT == "CH_PER_A" ||
                    widget.alert.aiT == "CH_PER_B"
                ?                     Icon(
                      Icons.percent_outlined,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                      size: 18,
                    )
                  : SvgPicture.asset(
                      assets.ruppeIcon,
                      colorFilter: ColorFilter.mode(
                        theme.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                      fit: BoxFit.scaleDown),
            onChanged: (value) {
              Future.microtask(() {
                if (mounted) {
                  setState(() {
                    validateAlertValue(value);
                  });
                }
              });
            },
          ),
        ),
        if (errorText.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
            child: TextWidget.captionText(
              text: errorText,
              theme: false,
              color: colors.lossDark,
              fw: 0),
          ),
        ],
      ],
    );
  }

  Widget _alertDataCondition(ThemesProvider theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: "Condition",
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 1),
            Row(
              children: [
                TextWidget.subText(
                  text: widget.alert.aiT == "LTP_A"
                      ? "Above"
                      : widget.alert.aiT == "LTP_B"
                          ? "Below"
                          : widget.alert.aiT == "CH_PER_A"
                              ? "above"
                              : "Below",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1),
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
      ],
    );
  }

  Widget _alertData(String title1, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only( bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
            text: title1,
            theme: theme.isDarkMode,
            fw: 1,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight),
          TextWidget.subText(
            text: value,
            theme: theme.isDarkMode,
            fw: 1,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight),
        ],
      ),
    );
  }
}

