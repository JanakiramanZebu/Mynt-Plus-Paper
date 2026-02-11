import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'dart:html' as html;
import '../market_watch/tv_chart/chart_iframe_guard.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MarginDetailsDialogWeb extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  const MarginDetailsDialogWeb({super.key, this.onClose});

  @override
  ConsumerState<MarginDetailsDialogWeb> createState() => _MarginDetailsDialogWebState();
}

class _MarginDetailsDialogWebState extends ConsumerState<MarginDetailsDialogWeb> {
  // Directly disable all chart iframes and reset cursor (like chart's onExit)
  void _disableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'none';
          // Reset cursor style to prevent cursor bleeding
          iframe.style.cursor = 'default';
        }
      }
      // Also reset cursor on document body to ensure it's reset globally
      html.document.body?.style.cursor = 'default';
    } catch (e) {
      debugPrint('Error disabling iframes: $e');
    }
  }

  void _enableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'auto';
          iframe.style.cursor = '';
        }
      }
      html.document.body?.style.cursor = '';
    } catch (e) {
      debugPrint('Error enabling iframes: $e');
    }
  }

  @override
  void dispose() {
    ChartIframeGuard.release();
    _enableAllChartIframes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderMargin = ref.watch(orderProvider).orderMarginModel;
    final orderBrokerage = ref.watch(orderProvider).getBrokerageModel;
    final clientFundDetail = ref.watch(fundProvider).fundDetailModel;

    return Dialog(
      backgroundColor: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: PointerInterceptor(
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          onEnter: (_) {
            ChartIframeGuard.acquire();
            _disableAllChartIframes();
          },
          onHover: (_) {
            _disableAllChartIframes();
          },
          onExit: (_) {
            ChartIframeGuard.release();
            _enableAllChartIframes();
          },
          child: Listener(
            onPointerMove: (_) {
              _disableAllChartIframes();
            },
            child: GestureDetector(
              onTap: () {}, // Prevent tap from propagating to background
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: resolveThemeColor(context,
                                  dark: MyntColors.dividerDark,
                                  light: MyntColors.divider),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Margin',
                              style: MyntWebTextStyles.title(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                  fontWeight: MyntFonts.bold),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  if (widget.onClose != null) {
                                    widget.onClose!();
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: resolveThemeColor(context,
                                        dark: MyntColors.textSecondaryDark,
                                        light: MyntColors.textSecondary),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _sectionCard(
                                context: context,
                                title: 'Summary',
                                child: Column(
                                  children: [
                                    _kvRow(
                                      context,
                                      'Required',
                                      '${orderMargin?.ordermargin ?? 0.00}',
                                    ),
                                    const SizedBox(height: 12),
                                    _kvRow(
                                      context,
                                      'Balance',
                                      '${clientFundDetail?.avlMrg ?? 0.00}',
                                    ),
                                    if (orderMargin?.remarks ==
                                        'Insufficient Balance')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Remarks',
                                              style: MyntWebTextStyles.bodySmall(
                                                  context,
                                                  darkColor: MyntColors
                                                      .textSecondaryDark,
                                                  lightColor:
                                                      MyntColors.textSecondary,
                                                  fontWeight: MyntFonts.medium),
                                            ),
                                            Flexible(
                                              child: Text(
                                                orderMargin?.remarks ?? '',
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    MyntWebTextStyles.bodySmall(
                                                        context,
                                                        darkColor:
                                                            MyntColors.lossDark,
                                                        lightColor:
                                                            MyntColors.error,
                                                        fontWeight:
                                                            MyntFonts.bold),
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
                                  title: 'Approx Charges',
                                  child: Column(
                                    children: [
                                      _kvRow(context, 'Brokerage Amt',
                                          '${orderBrokerage.brkageAmt ?? 0.00}'),
                                      const Divider(height: 20),
                                      _kvRow(context, 'STT total',
                                          '${orderBrokerage.sttAmt ?? 0.00}'),
                                      const Divider(height: 20),
                                      _kvRow(context, 'Exchange charges',
                                          '${orderBrokerage.exchChrg ?? 0.00}'),
                                      const Divider(height: 20),
                                      _kvRow(context, 'SEBI charges',
                                          '${orderBrokerage.sebiChrg ?? 0.00}'),
                                      const Divider(height: 20),
                                      _kvRow(context, 'Stamp duty',
                                          '${orderBrokerage.stampDuty ?? 0.00}'),
                                      const Divider(height: 20),
                                      _kvRow(context, 'Clearing charges',
                                          '${orderBrokerage.clrChrg ?? 0.00}'),
                                      const Divider(height: 20),
                                      _kvRow(context, 'GST',
                                          '${orderBrokerage.gst ?? 0.00}'),
                                      const SizedBox(height: 12),
                                      Text(
                                        'View exact charges in contract note at the end of the day',
                                        textAlign: TextAlign.center,
                                        style: MyntWebTextStyles.para(context,
                                            darkColor:
                                                MyntColors.textSecondaryDark,
                                            lightColor:
                                                MyntColors.textSecondary,
                                            fontWeight: MyntFonts.medium),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                _sectionCard(
                                  context: context,
                                  title: 'Approx Charges',
                                  child: Text(
                                    'Get your brokerage details updated. Reach out to our support.',
                                    style: MyntWebTextStyles.para(context,
                                        darkColor: MyntColors.textSecondaryDark,
                                        lightColor: MyntColors.textSecondary,
                                        fontWeight: MyntFonts.medium),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: resolveThemeColor(context,
                dark: MyntColors.listItemBgDark, light: MyntColors.listItemBg)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: resolveThemeColor(context,
              dark: MyntColors.dividerDark, light: MyntColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MyntWebTextStyles.bodySmall(context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _kvRow(BuildContext context, String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: MyntWebTextStyles.bodySmall(context,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary,
              fontWeight: MyntFonts.medium),
        ),
        Text(
          v,
          textAlign: TextAlign.right,
          style: MyntWebTextStyles.bodySmall(context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: MyntFonts.medium),
        ),
      ],
    );
  }
}
