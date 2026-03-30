import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      // final fund = ref.read(transcationProvider);
                      // fund.amount.clear();
                      // fund.textFiledonChange('');
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

}
