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
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
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
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alert Details Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _buildAlertDetailsSection(theme),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Modify Value Field
                    _buildModifyValueField(theme),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
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
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(),
      child: InkWell(
        customBorder: RoundedRectangleBorder(),
        borderRadius: BorderRadius.circular(0),
        splashColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.1) : colors.primaryLight.withOpacity(0.1),
        highlightColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.2) : colors.primaryLight.withOpacity(0.2),
        onTap: () {
          // Can add chart navigation here if needed
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symbol and Exchange
            Row(
              children: [
                Text(
                  "${widget.alert.tsym?.replaceAll("-EQ", "") ?? ''}",
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "${widget.alert.exch}",
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Price and Change
            Row(
              children: [
                Text(
                  "${widget.alert.ltp != "null" ? widget.alert.ltp ?? widget.alert.close ?? 0.00 : '0.00'}",
                  style: WebTextStyles.title(
                    isDarkTheme: theme.isDarkMode,
                    color: (widget.alert.change == "null" || widget.alert.change == null) ||
                            widget.alert.change == "0.00"
                        ? theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight
                        : (widget.alert.change?.startsWith("-") == true || widget.alert.perChange?.startsWith("-") == true)
                            ? theme.isDarkMode
                                ? colors.lossDark
                                : colors.lossLight
                            : theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight,
                    fontWeight: WebFonts.medium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${(double.tryParse(widget.alert.change ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(widget.alert.perChange ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                    fontWeight: WebFonts.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    "Type",
                    widget.alert.aiT == "LTP_A"
                        ? "LTP"
                        : widget.alert.aiT == "LTP_B"
                            ? "LTP"
                            : widget.alert.aiT == "CH_PER_A"
                                ? "Perc.Change"
                                : "Perc.Change",
                    theme,
                  ),
                  _buildInfoRow(
                    "Condition",
                    _buildConditionWidget(theme),
                    theme,
                  ),
                  _buildInfoRow(
                    "Date & Time",
                    formatDateTime(value: "${widget.alert.norentm}"),
                    theme,
                  ),
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.isDarkMode
                  ? WebDarkColors.divider
                  : WebColors.divider,
            ),
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    "Target",
                    widget.alert.aiT == "CH_PER_A" || widget.alert.aiT == "CH_PER_B"
                        ? "%${widget.alert.d}"
                        : "${widget.alert.d}",
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionWidget(ThemesProvider theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.alert.aiT == "LTP_A"
              ? "Above"
              : widget.alert.aiT == "LTP_B"
                  ? "Below"
                  : widget.alert.aiT == "CH_PER_A"
                      ? "above"
                      : "Below",
          style: WebTextStyles.dialogContent(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Transform.rotate(
          angle: 55 * (3.14159 / 180),
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
                        : colors.darkred,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, dynamic value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
          ),
          value is Widget
              ? value
              : Text(
                  value.toString(),
                  style: WebTextStyles.dialogContent(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildModifyValueField(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Modify Alert value",
          style: WebTextStyles.formLabel(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
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
            style: WebTextStyles.formInput(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
            keyboardType: TextInputType.number,
            hintText: "0",
            hintStyle: WebTextStyles.helperText(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary,
            ),
            prefixIcon: widget.alert.aiT == "CH_PER_A" ||
                    widget.alert.aiT == "CH_PER_B"
                ? Icon(
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
          const SizedBox(height: 8),
          Text(
            errorText,
            style: WebTextStyles.helperText(
              isDarkTheme: theme.isDarkMode,
              color: WebDarkColors.error,
            ),
          ),
        ],
      ],
    );
  }

}

