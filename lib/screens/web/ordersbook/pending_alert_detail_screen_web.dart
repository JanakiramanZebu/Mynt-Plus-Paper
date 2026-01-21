import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../../../res/res.dart';

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

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button (fixed)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSymbolSection(theme),
                    ),
                    MyntCloseButton(
                      onPressed: () {
                        shadcn.closeSheet(context);
                      },
                    ),
                  ],
                ),
              ),
              // Border divider
              Container(
                height: 1,
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action Buttons
                        _buildActionButtons(theme),
                        // Details Section
                        _buildAlertDetailsSection(theme),
                        const SizedBox(height: 16),
                        // Modify Value Field
                        _buildModifyValueField(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
            Flexible(
              child: Text(
                widget.alert.tsym?.replaceAll("-EQ", "") ?? '',
                style: MyntWebTextStyles.title(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${widget.alert.exch}",
              style: MyntWebTextStyles.title(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
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
              style: MyntWebTextStyles.title(
                context,
                color: (widget.alert.change == "null" ||
                            widget.alert.change == null) ||
                        widget.alert.change == "0.00"
                    ? resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary)
                    : (widget.alert.change?.startsWith("-") == true ||
                            widget.alert.perChange?.startsWith("-") == true)
                        ? resolveThemeColor(context,
                            dark: MyntColors.lossDark, light: MyntColors.loss)
                        : resolveThemeColor(context,
                            dark: MyntColors.profitDark,
                            light: MyntColors.profit),
                fontWeight: MyntFonts.medium,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${(double.tryParse(widget.alert.change ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(widget.alert.perChange ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              "Modify Alert",
              true,
              theme,
              (isModifying ||
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

                        if (mounted) shadcn.closeSheet(context);
                      } catch (e) {
                        if (mounted) {
                          showResponsiveErrorMessage(context,
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
              isLoading: isModifying,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              "Cancel Alert",
              false,
              theme,
              (isModifying || isCancelling)
                  ? null
                  : () async {
                      final shouldCancel = await _showCancelAlertDialog(theme);
                      if (shouldCancel != true) {
                        return;
                      }

                      setState(() {
                        isCancelling = true;
                      });

                      try {
                        final String alertId = "${widget.alert.alId}";
                        await ref
                            .read(marketWatchProvider)
                            .fetchCancelAlert(alertId, context);
                        await ref
                            .read(marketWatchProvider)
                            .fetchPendingAlert(context);

                        if (mounted) shadcn.closeSheet(context);
                      } catch (e) {
                        if (mounted) {
                          showResponsiveErrorMessage(context,
                              "Failed to cancel alert: ${e.toString()}");
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isCancelling = false;
                          });
                        }
                      }
                    },
              isLoading: isCancelling,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    bool isPrimary,
    ThemesProvider theme,
    VoidCallback? onPressed, {
    bool isLoading = false,
  }) {
    if (isPrimary) {
      return MyntPrimaryButton(
        label: text,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: true,
      );
    } else {
      return MyntOutlinedButton(
        label: text,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: true,
      );
    }
  }

  Widget _buildAlertDetailsSection(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowOfInfoData(
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
          _rowOfInfoData(
            "Condition",
            _buildConditionWidget(theme),
            theme,
          ),
          _rowOfInfoData(
            "Target",
            widget.alert.aiT == "CH_PER_A" || widget.alert.aiT == "CH_PER_B"
                ? "%${widget.alert.d}"
                : "${widget.alert.d}",
            theme,
          ),
          _rowOfInfoData(
            "LTP",
            "${widget.alert.ltp ?? widget.alert.close ?? '0.00'}",
            theme,
          ),
          _rowOfInfoData(
            "Date & Time",
            formatDateTime(value: "${widget.alert.norentm}"),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _rowOfInfoData(String label, dynamic value, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.bodySmall(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
              fontWeight: MyntFonts.regular,
            ),
          ),
          value is Widget
              ? value
              : Text(
                  value.toString(),
                  style: MyntWebTextStyles.bodySmall(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                    fontWeight: MyntFonts.medium,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildConditionWidget(ThemesProvider theme) {
    final isAbove =
        widget.alert.aiT == "LTP_A" || widget.alert.aiT == "CH_PER_A";
    final conditionColor = isAbove
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isAbove ? "Above" : "Below",
          style: MyntWebTextStyles.bodySmall(
            context,
            color: resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary),
            fontWeight: MyntFonts.medium,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          isAbove ? Icons.arrow_upward : Icons.arrow_downward,
          size: 18,
          color: conditionColor,
        ),
      ],
    );
  }

  Widget _buildModifyValueField(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Modify Alert value",
          style: MyntWebTextStyles.bodySmall(
            context,
            color: resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary),
            fontWeight: MyntFonts.medium,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: CustomTextFormField(
            fillColor: resolveThemeColor(context,
                dark: MyntColors.searchBgDark, light: MyntColors.searchBg),
            textCtrl: valueCtrl,
            textAlign: TextAlign.start,
            inputFormate: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: MyntWebTextStyles.tableCell(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
            ),
            keyboardType: TextInputType.number,
            hintText: "0",
            hintStyle: MyntWebTextStyles.bodySmall(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
            ),
            prefixIcon:
                widget.alert.aiT == "CH_PER_A" || widget.alert.aiT == "CH_PER_B"
                    ? Icon(
                        Icons.percent_outlined,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                        size: 18,
                      )
                    : SvgPicture.asset(assets.ruppeIcon,
                        colorFilter: ColorFilter.mode(
                          theme.isDarkMode
                              ? MyntColors.textSecondaryDark
                              : MyntColors.textSecondary,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.scaleDown),
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  validateAlertValue(value);
                });
              }
            },
          ),
        ),
        if (errorText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            errorText,
            style: MyntWebTextStyles.bodySmall(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.lossDark, light: MyntColors.loss),
            ),
          ),
        ],
      ],
    );
  }

  Future<bool?> _showCancelAlertDialog(ThemesProvider theme) async {
    final symbol = widget.alert.tsym?.replaceAll("-EQ", "") ?? '';
    final exchange = widget.alert.exch ?? '';
    final displayText = exchange.isNotEmpty ? '$symbol $exchange' : symbol;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: resolveThemeColor(dialogContext,
                  dark: const Color(0xFF0F172A), light: Colors.white),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: resolveThemeColor(dialogContext,
                            dark: MyntColors.dividerDark,
                            light: MyntColors.divider),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cancel Alert',
                        style: MyntWebTextStyles.title(
                          dialogContext,
                          color: resolveThemeColor(dialogContext,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary),
                        ),
                      ),
                      MyntCloseButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ],
                  ),
                ),
                // Content area
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Are you sure you want to cancel this alert?',
                              textAlign: TextAlign.center,
                              style: MyntWebTextStyles.head(
                                dialogContext,
                                color: resolveThemeColor(dialogContext,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            displayText,
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.bodySmall(
                              dialogContext,
                              color: resolveThemeColor(dialogContext,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: MyntPrimaryButton(
                            label: 'Yes, Cancel',
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
