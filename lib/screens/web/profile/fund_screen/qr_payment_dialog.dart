import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';

class QrPaymentDialog extends ConsumerStatefulWidget {
  const QrPaymentDialog({super.key});

  @override
  ConsumerState<QrPaymentDialog> createState() => _QrPaymentDialogState();
}

class _QrPaymentDialogState extends ConsumerState<QrPaymentDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fund = ref.read(transcationProvider);
      fund.startQrStatusPolling(context, onStatusUpdate: (status) {
        if (!mounted) return;
        Navigator.of(context).pop(status);
      });
    });
  }

  @override
  void dispose() {
    // Stop polling when dialog is dismissed
    ref.read(transcationProvider).stopQrStatusPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(transcationProvider);
    final isDark = theme.isDarkMode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? colors.colorBlack : colors.colorWhite,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget.titleText(
              text: "Scan QR code with any UPI app",
              color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: isDark,
              fw: 1,
            ),
            const SizedBox(height: 8),
            // UPI apps icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUpiAppIcon('GPay', Icons.g_mobiledata_rounded),
                const SizedBox(width: 16),
                _buildUpiAppIcon('PhonePe', Icons.phone_android),
                const SizedBox(width: 16),
                _buildUpiAppIcon('Paytm', Icons.account_balance_wallet),
                const SizedBox(width: 16),
                _buildUpiAppIcon('More', Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 16),
            // QR Code Image
            if (fund.qrCodeUrl != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? colors.textSecondaryDark.withOpacity(0.3)
                        : colors.colorDivider,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.network(
                  fund.qrCodeUrl!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark
                              ? colors.primaryDark
                              : colors.primaryLight,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: isDark
                                    ? colors.lossDark
                                    : colors.lossLight,
                                size: 32),
                            const SizedBox(height: 8),
                            TextWidget.captionText(
                              text: "Failed to load QR code",
                              theme: isDark,
                              color: isDark
                                  ? colors.lossDark
                                  : colors.lossLight,
                              fw: 0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Amount
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Pay ",
                    style: TextWidget.textStyle(
                      fontSize: 14,
                      theme: isDark,
                      color: isDark
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ),
                  TextSpan(
                    text:
                        "₹${fund.indentUpiResponse?.data?.amount ?? fund.amount.text}",
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      theme: isDark,
                      color: isDark
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Polling indicator
            if (fund.qrPolling)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark
                            ? colors.primaryDark
                            : colors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextWidget.captionText(
                      text: "Waiting for payment...",
                      theme: isDark,
                      color: isDark
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  fund.stopQrStatusPolling();
                  // Check status one final time
                  final result = await fund.checkQrStatusOnce();
                  if (mounted) {
                    Navigator.of(context)
                        .pop(result?.data?.status ?? 'CANCELLED');
                  }
                },
                child: TextWidget.subText(
                  text: "Cancel Transaction",
                  theme: isDark,
                  color: isDark
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiAppIcon(String label, IconData icon) {
    final theme = ref.watch(themeProvider);
    final isDark = theme.isDarkMode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
