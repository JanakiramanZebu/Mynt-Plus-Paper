import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../provider/ledger_provider.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../sharedWidget/no_data_found.dart';

void showChargesDialog(
  BuildContext context, {
  required WidgetRef ref,
}) {
  final segment = ref.read(ledgerProvider).selectedSegment;

  showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: _ChargesDialogContent(segment: segment),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog content
// ─────────────────────────────────────────────────────────────────────────────

class _ChargesDialogContent extends ConsumerWidget {
  final String segment;

  const _ChargesDialogContent({required this.segment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lp = ref.watch(ledgerProvider);
    final totalCharges = lp.calenderpnlAllData?.totalCharges ?? 0.0;
    final charge = lp.currentCalendarCharge;
    final isLoading = lp.calendarChargesLoading;

    final bgColor = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);
    final secCol = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Charges and Taxes',
                    style: MyntWebTextStyles.title(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                        fontWeight: MyntFonts.semiBold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: secCol),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          // ── Body ──────────────────────────────────────────────────────
          Flexible(
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: MyntLoader.simple()),
                  )
                : charge == null || (charge.expenses?.isEmpty ?? true)
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                            child: NoDataFound(secondaryEnabled: false)),
                      )
                    : SingleChildScrollView(
                        child: _buildList(
                          context,
                          totalCharges,
                          charge.expenses!,
                          dividerColor,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    double totalCharges,
    List expenses,
    Color dividerColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Total row
        _buildRow(
          context,
          label: 'Total',
          amount: totalCharges,
          isBold: true,
        ),
        Divider(height: 1, thickness: 1, color: dividerColor),
        // Charge type rows
        ...expenses.map((e) {
          final label = e.sCRIPSYMBOL ?? '—';
          final amount = double.tryParse(e.nOTPROFIT ?? '0') ?? 0.0;
          return _buildRow(context, label: label, amount: amount);
        }),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required double amount,
    bool isBold = false,
  }) {
    final weight = isBold ? MyntFonts.semiBold : null;
    final amtColor = amount < 0
        ? resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.body(context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: weight),
          ),
          Text(
            _fmtAmt(amount),
            style: MyntWebTextStyles.body(context,
                darkColor: amtColor ?? MyntColors.textPrimaryDark,
                lightColor: amtColor ?? MyntColors.textPrimary,
                fontWeight: weight),
          ),
        ],
      ),
    );
  }

  String _fmtAmt(double value) {
    final prefix = value < 0 ? '-₹' : '₹';
    return '$prefix${NumberFormat('#,##,##0.00', 'en_IN').format(value.abs())}';
  }
}
