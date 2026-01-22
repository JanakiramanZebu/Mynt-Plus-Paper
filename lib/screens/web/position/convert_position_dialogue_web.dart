import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../models/portfolio_model/position_convertion_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../market_watch/tv_chart/chart_iframe_guard.dart';

class ConvertPositionDialogueWeb extends ConsumerStatefulWidget {
  final PositionBookModel convertPosition;
  const ConvertPositionDialogueWeb({super.key, required this.convertPosition});

  @override
  ConsumerState<ConvertPositionDialogueWeb> createState() =>
      _ConvertPositionDialogueWebState();
}

class _ConvertPositionDialogueWebState
    extends ConsumerState<ConvertPositionDialogueWeb> {
  late TextEditingController qty;
  late TextEditingController maxQty;

  @override
  void initState() {
    super.initState();
    // Disable chart iframe pointer events when dialog opens
    _disableAllChartIframes();

    maxQty = TextEditingController(
        text: widget.convertPosition.netqty!.replaceAll("-", ""));
    qty = TextEditingController(text: maxQty.text);
    int lotSize = int.parse("${widget.convertPosition.ls ?? 0}");

    if (widget.convertPosition.exch == "MCX") {
      maxQty.text = (int.parse(maxQty.text) ~/ lotSize).toString();
    }

    if (widget.convertPosition.exch == "MCX") {
      qty.text = (int.parse(qty.text) ~/ lotSize).toString();
    }
  }

  @override
  void dispose() {
    qty.dispose();
    maxQty.dispose();
    // Re-enable chart iframe pointer events when dialog closes
    ChartIframeGuard.release();
    _enableAllChartIframes();
    super.dispose();
  }

  // Disable all chart iframes to allow dialog interaction
  void _disableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'none';
          iframe.style.cursor = 'default';
        }
      }
      html.document.body?.style.cursor = 'default';
    } catch (e) {
      debugPrint('Error disabling iframes: $e');
    }
  }

  // Re-enable all chart iframes
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
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Center(
      child: Container(
        width: 380,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: resolveThemeColor(context,
              dark: MyntColors.listItemBgDark, light: MyntColors.textWhite),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            _buildHeader(context),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Order Type Section
                      _buildOrderTypeSection(context),
                      const SizedBox(height: 20),

                      // Quantity Section
                      _buildQuantitySection(context, theme),
                      const SizedBox(height: 24),

                      // Convert Position Button
                      _buildConvertButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "${widget.convertPosition.symbol} ${widget.convertPosition.option ?? ''} ${widget.convertPosition.exch}",
              style: MyntWebTextStyles.title(
                context,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary,
                ),
                fontWeight: MyntFonts.medium,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          shadcn.IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            variance: shadcn.ButtonVariance.ghost,
            size: shadcn.ButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSection(BuildContext context) {
    final targetProduct = _getTargetProduct();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Type",
          style: MyntWebTextStyles.body(
            context,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Current product (NRML/MIS/CNC)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.listItemBgDark,
                  light: MyntColors.listItemBg,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "${widget.convertPosition.sPrdtAli}",
                style: MyntWebTextStyles.body(
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

            // Arrow icon
            SvgPicture.asset(
              assets.rightarrow,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
              width: 18,
              height: 18,
            ),

            // Target product
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                targetProduct,
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySection(BuildContext context, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quantity (${widget.convertPosition.ls})",
          style: MyntWebTextStyles.body(
            context,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: shadcn.TextField(
            controller: qty,
            placeholder: const Text("0"),
            textAlign: TextAlign.left,
            style: MyntWebTextStyles.body(
              context,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary,
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                int number = int.tryParse(qty.text) ?? 0;
                if (number > 999999) {
                  qty.text = qty.text.substring(0, 6);
                }
                String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (newValue != value) {
                  qty.text = newValue;
                  qty.selection = TextSelection.fromPosition(
                    TextPosition(offset: newValue.length),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConvertButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: MyntPrimaryButton(
        label: "Convert Position",
        isFullWidth: true,
        onPressed: () async {
          if (qty.text.isEmpty || qty.text == "0") {
            showResponsiveWarningMessage(
                context,
                qty.text.isEmpty
                    ? 'Quantity can not be empty'
                    : "Quantity can not be 0");
          } else if (int.parse(qty.text) > int.parse(maxQty.text)) {
            setState(() {
              qty.text = maxQty.text;
            });
            showResponsiveWarningMessage(
                context, 'Quantity can not be greater than Max Quantity');
          } else {
            PositionConvertionInput positionConvertionInput =
                PositionConvertionInput(
                    exch: "${widget.convertPosition.exch}",
                    postype: "DAY",
                    prd: _getTargetProductCode(),
                    prevprd: "${widget.convertPosition.prd}",
                    qty: widget.convertPosition.exch == 'MCX'
                        ? (int.parse(qty.text) *
                                int.parse(widget.convertPosition.ls.toString()))
                            .toInt()
                            .toString()
                        : qty.text,
                    trantype: widget.convertPosition.netqty!.startsWith('-')
                        ? "S"
                        : "B",
                    tsym: "${widget.convertPosition.tsym}");
            ref
                .read(portfolioProvider)
                .fetchPositionConverstion(positionConvertionInput, context);
          }
        },
      ),
    );
  }

  String _getTargetProduct() {
    if (widget.convertPosition.sPrdtAli == "MIS" &&
        (widget.convertPosition.exch == "NSE" ||
            widget.convertPosition.exch == "BSE")) {
      return "CNC";
    } else if (widget.convertPosition.sPrdtAli == "MIS") {
      return "NRML";
    } else if (widget.convertPosition.sPrdtAli == "CNC") {
      return "MIS";
    } else {
      return "MIS";
    }
  }

  String _getTargetProductCode() {
    if (widget.convertPosition.sPrdtAli == "MIS" &&
        (widget.convertPosition.exch == "NSE" ||
            widget.convertPosition.exch == "BSE")) {
      return "C";
    } else if (widget.convertPosition.sPrdtAli == "MIS") {
      return "M";
    } else if (widget.convertPosition.sPrdtAli == "CNC") {
      return "I";
    } else {
      return "I";
    }
  }
}
