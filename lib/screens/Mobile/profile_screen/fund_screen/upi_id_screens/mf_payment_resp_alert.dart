import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/mf_provider.dart';

import '../../../../../provider/thems.dart';
import '../../../../../res/mynt_web_color_styles.dart';
import '../../../../../res/mynt_web_text_styles.dart';

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
            final condval = widget.conditionval ?? '';
            final data = widget.upiData;

            return Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: resolveThemeColor(context,
                    dark: MyntColors.backgroundColorDark,
                    light: MyntColors.backgroundColor),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark, light: MyntColors.divider),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status icon + info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: _buildStatusContent(
                        context, theme, mfpro, condval, data),
                  ),

                  // Detail rows
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child:
                        _buildDetails(context, theme, mfpro, condval, data),
                  ),

                  const SizedBox(height: 8),

                  // Footer button
                  _buildFooter(context, theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, ThemesProvider theme,
      MFProvider mfpro, String condval, Map<String, dynamic>? data) {
    final IconData icon;
    final Color iconColor;
    final String title;
    final String? subtitle;
    final String? amount;
    final String? datetime;

    if (condval == 'timeout') {
      icon = Icons.cancel_rounded;
      iconColor = resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
      title = 'Request timeout';
      subtitle = data?["status"] == "PAYMENT COMPLETED"
          ? "Transaction Success"
          : "Transaction fail";
      amount =
          "₹${data?["OrderVal"] ?? data?["InstallmentAmount"]}";
      datetime = "${data?["datetime"]}";
    } else if (condval == 'reinitiateerror' ||
        (condval.isNotEmpty && condval != 'timeout')) {
      icon = Icons.cancel_rounded;
      iconColor = resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
      title = 'Payment Not Initiated';
      subtitle = 'Payment initiate fail';
      amount = null;
      datetime = null;
    } else {
      // Default — actual payment response
      final status = data?["status"] ?? '';
      final isSuccess =
          status == "PAYMENT COMPLETED" || status == "REGISTERED";
      final isProcessing = status == "PAYMENT PROCESSING";

      icon = isSuccess
          ? Icons.check_circle_rounded
          : isProcessing
              ? Icons.schedule
              : Icons.cancel_rounded;
      iconColor = isSuccess
          ? resolveThemeColor(context,
              dark: MyntColors.profitDark, light: MyntColors.profit)
          : isProcessing
              ? resolveThemeColor(context,
                  dark: MyntColors.warningDark, light: MyntColors.warning)
              : resolveThemeColor(context,
                  dark: MyntColors.lossDark, light: MyntColors.loss);
      title = status;
      subtitle = mfpro.mfOrderTpye != 'SIP'
          ? (isSuccess
              ? "Transaction Success"
              : isProcessing
                  ? "Transaction pending"
                  : "Transaction fail")
          : null;
      amount =
          "₹${data?["OrderVal"] ?? data?["InstallmentAmount"]}";
      datetime = "${data?["datetime"]}";
    }

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 56),
        const SizedBox(height: 16),
        Text(
          title,
          style: MyntWebTextStyles.title(
            context,
            fontWeight: MyntFonts.semiBold,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: MyntWebTextStyles.para(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (amount != null) ...[
          const SizedBox(height: 12),
          Text(
            amount,
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.bold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ).copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
        ],
        if (datetime != null) ...[
          const SizedBox(height: 8),
          Text(
            datetime,
            style: MyntWebTextStyles.para(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, ThemesProvider theme,
      MFProvider mfpro, String condval, Map<String, dynamic>? data) {
    final rows = <MapEntry<String, String>>[];

    if (condval == 'timeout') {
      final orderId = data?["OrderId"];
      if (orderId != null && orderId != 'null' && orderId != '') {
        rows.add(MapEntry("Order ID", "$orderId"));
      } else {
        rows.add(MapEntry("TransNo", "${data?["TransNo"]}"));
      }
      rows.add(
          MapEntry("UPI Transaction ID", "${data?["TransNo"]}"));
      rows.add(MapEntry("Status Description",
          "Request Timeout reinitiate from orderbook"));
    } else if (condval == 'reinitiateerror') {
      rows.add(MapEntry("Payment type", "${data?["type"]}"));
      rows.add(MapEntry("Status Description",
          "${data?['responsestring'] ?? data?['emsg']}"));
    } else if (condval.isNotEmpty && condval != 'timeout') {
      rows.add(MapEntry("Status Description", condval));
    } else {
      // Default payment response
      if (mfpro.mfOrderTpye != 'SIP') {
        rows.add(MapEntry("Order ID", "${data?["OrderId"]}"));
      } else {
        rows.add(MapEntry("TransNo",
            "${data?["OrderId"] ?? data?["TransNo"]}"));
      }
      rows.add(
          MapEntry("UPI Transaction ID", "${data?["TransNo"]}"));
      rows.add(
          MapEntry("Status Description", "${data?['Remarks']}"));
    }

    return Column(
      children: rows
          .map((entry) => _dataRow(context, entry.key, entry.value))
          .toList(),
    );
  }

  Widget _dataRow(BuildContext context, String label, String value) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.medium,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: resolveThemeColor(context,
              dark: MyntColors.dividerDark, light: MyntColors.divider),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: resolveThemeColor(context,
                dark: MyntColors.secondary, light: MyntColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: Text(
            'Done',
            style: MyntWebTextStyles.bodySmall(
              context,
              fontWeight: MyntFonts.semiBold,
              color: MyntColors.backgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
