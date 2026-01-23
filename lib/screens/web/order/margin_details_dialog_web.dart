import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/res/web_colors.dart';

class MarginDetailsDialogWeb extends ConsumerWidget {
  final VoidCallback? onClose;
  const MarginDetailsDialogWeb({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final orderMargin = ref.watch(orderProvider).orderMarginModel;
    final orderBrokerage = ref.watch(orderProvider).getBrokerageModel;
    final clientFundDetail = ref.watch(fundProvider).fundDetailModel;

    return Dialog(
      backgroundColor:
          theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          width: 520,
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    Text(
                      'Order Margin',
                      style: WebTextStyles.dialogTitle(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                      ).copyWith(fontWeight: WebFonts.bold),
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          if (onClose != null) {
                            onClose!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sectionCard(
                        context: context,
                        theme: theme,
                        title: 'Summary',
                        child: Column(
                          children: [
                            _kvRow(
                              theme,
                              'Required',
                              '${orderMargin?.ordermargin ?? 0.00}',
                            ),
                            const SizedBox(height: 12),
                            _kvRow(
                              theme,
                              'Balance',
                              '${clientFundDetail?.avlMrg ?? 0.00}',
                            ),
                            if (orderMargin?.remarks == 'Insufficient Balance')
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Remarks',
                                      style: WebTextStyles.bodySmall(
                                        isDarkTheme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.textSecondary
                                            : WebColors.textSecondary,
                                        fontWeight: WebFonts.medium,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        orderMargin?.remarks ?? '',
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                        style: WebTextStyles.bodySmall(
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.error
                                              : WebColors.error,
                                          fontWeight: WebFonts.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (orderBrokerage != null &&
                          orderBrokerage.emsg !=
                              'Error Occurred : Invalid order details/brokerage plan not set')
                        _sectionCard(
                          context: context,
                          theme: theme,
                          title: 'Approx Charges',
                          child: Column(
                            children: [
                              _kvRow(theme, 'Brokerage Amt',
                                  '${orderBrokerage.brkageAmt?? 0.00}'),
                              const Divider(height: 20),
                              _kvRow(theme, 'STT total',
                                  '${orderBrokerage.sttAmt?? 0.00}'),
                              const Divider(height: 20),
                              _kvRow(theme, 'Exchange charges',
                                  '${orderBrokerage.exchChrg?? 0.00}'),
                              const Divider(height: 20),
                              _kvRow(theme, 'SEBI charges',
                                  '${orderBrokerage.sebiChrg?? 0.00}'),
                              const Divider(height: 20),
                              _kvRow(theme, 'Stamp duty',
                                  '${orderBrokerage.stampDuty?? 0.00}'),
                              const Divider(height: 20),
                              _kvRow(theme, 'Clearing charges',
                                  '${orderBrokerage.clrChrg?? 0.00}'),
                              const Divider(height: 20),
                              _kvRow(theme, 'GST', '${orderBrokerage.gst?? 0.00}'),
                              const SizedBox(height: 12),
                              Text(
                                'View exact charges in contract note at the end of the day',
                                textAlign: TextAlign.center,
                                style: WebTextStyles.para(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textSecondary
                                      : WebColors.textSecondary,
                                  fontWeight: WebFonts.medium,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _sectionCard(
                          context: context,
                          theme: theme,
                          title: 'Approx Charges',
                          child: Text(
                            'Get your brokerage details updated. Reach out to our support.',
                            style: WebTextStyles.para(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary,
                              fontWeight: WebFonts.medium,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required ThemesProvider theme,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? WebDarkColors.backgroundTertiary.withOpacity(0.5)
            : WebColors.backgroundTertiary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color:
              theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: WebFonts.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _kvRow(ThemesProvider theme, String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
            fontWeight: WebFonts.medium,
          ),
        ),
        Text(
          v,
          textAlign: TextAlign.right,
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.medium,
          ),
        ),
      ],
    );
  }
}


