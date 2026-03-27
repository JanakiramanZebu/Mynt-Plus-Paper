import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';
import '../../../../../res/mynt_web_color_styles.dart';
import '../../../../../res/mynt_web_text_styles.dart';


class RazorpayFailedUi extends StatefulWidget {
  final String amount;
  final String? upiAddress;
  final String? orderId;
  final String? upiTransactionId;
  final String? statusDescription;
  final String? status;
  const RazorpayFailedUi({
    super.key,
    required this.amount,
    this.upiAddress,
    this.orderId,
    this.upiTransactionId,
    this.statusDescription,
    this.status,
  });

  @override
  State<RazorpayFailedUi> createState() => _RazorpayFailedUiState();
}

class _RazorpayFailedUiState extends State<RazorpayFailedUi> {
  String time = '';

  @override
  void initState() {
    time = convDateWithTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
      },
      child: Consumer(
        builder: (context, ref, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: resolveThemeColor(
                context,
                dark: MyntColors.cardDark,
                light: MyntColors.card,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon + Status
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel_rounded,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.errorDark,
                          light: MyntColors.error,
                        ),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.status ?? "REJECTED",
                        style: MyntWebTextStyles.title(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.errorDark,
                            light: MyntColors.error,
                          ),
                          fontWeight: MyntFonts.semiBold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Transaction fail",
                        style: MyntWebTextStyles.bodySmall(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "₹${widget.amount}",
                        style: MyntWebTextStyles.head(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary,
                          ),
                          fontWeight: MyntFonts.semiBold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        time,
                        style: MyntWebTextStyles.bodySmall(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const ListDivider(),

                // Details
                if (widget.upiAddress != null && widget.upiAddress!.isNotEmpty) ...[
                  _dataRow(context, "UPI Address", widget.upiAddress!),
                  const ListDivider(),
                ],
                if (widget.orderId != null && widget.orderId!.isNotEmpty) ...[
                  _dataRow(context, "Order ID", widget.orderId!),
                  const ListDivider(),
                ],
                if (widget.upiTransactionId != null && widget.upiTransactionId!.isNotEmpty) ...[
                  _dataRow(context, "UPI Transaction ID", widget.upiTransactionId!),
                  const ListDivider(),
                ],
                _dataRow(
                  context,
                  "Status Description",
                  widget.statusDescription ?? "Transaction fail",
                ),
                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      final fund = ref.read(transcationProvider);
                      fund.amount.clear();
                      fund.textFiledonChange('');
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: resolveThemeColor(
                        context,
                        dark: MyntColors.secondary,
                        light: MyntColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: MyntWebTextStyles.body(
                        context,
                        color: Colors.white,
                        fontWeight: MyntFonts.semiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.bodySmall(
              context,
              fontWeight: MyntFonts.medium,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: MyntWebTextStyles.bodySmall(
                context,
                fontWeight: MyntFonts.semiBold,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
