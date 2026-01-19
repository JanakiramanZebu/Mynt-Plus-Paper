import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../../models/order_book_model/trade_book_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/functions.dart';
import '../refactored/utils/cell_formatters.dart';
import '../../../../sharedWidget/common_buttons_web.dart';

class TradeDetailScreenWeb extends ConsumerStatefulWidget {
  final TradeBookModel trade;
  final BuildContext? parentContext;

  const TradeDetailScreenWeb({
    super.key,
    required this.trade,
    this.parentContext,
  });

  @override
  ConsumerState<TradeDetailScreenWeb> createState() =>
      _TradeDetailScreenWebState();
}

class _TradeDetailScreenWebState extends ConsumerState<TradeDetailScreenWeb> {
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
                        // Details Section
                        _buildDetailsSection(theme),
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
    final symbol = widget.trade.symbol?.replaceAll("-EQ", "") ??
        widget.trade.tsym?.replaceAll("-EQ", "") ??
        '';
    final expDate = widget.trade.expDate ?? '';
    final option = widget.trade.option ?? '';
    final displayText = '$symbol $expDate $option'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symbol
        Row(
          children: [
            Flexible(
              child: Text(
                displayText.isNotEmpty
                    ? displayText
                    : (widget.trade.tsym ?? 'N/A'),
                style: MyntWebTextStyles.title(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Price (using avgprc as trade price)
        Row(
          children: [
            Text(
              widget.trade.avgprc?.toString() ?? '0.00',
              style: MyntWebTextStyles.title(
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

  Widget _buildDetailsSection(ThemesProvider theme) {
    final buySell = widget.trade.trantype == "S" ? "Sell" : "Buy";
    final isSell = widget.trade.trantype == "S";
    final typeColor = isSell
        ? resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss)
        : resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowOfInfoDataWithColor("Type", buySell, theme, typeColor),
          _rowOfInfoData(
            "Qty",
            widget.trade.flqty?.toString() ??
                widget.trade.qty?.toString() ??
                '0',
            theme,
          ),
          _rowOfInfoData(
            "Price",
            widget.trade.flprc?.toString() ??
                widget.trade.avgprc?.toString() ??
                '0.00',
            theme,
          ),
          _rowOfInfoData(
            "Trade Value",
            CellFormatters.calculateTradeValue(widget.trade),
            theme,
          ),
          _rowOfInfoData(
            "Product / Type",
            "${widget.trade.sPrdtAli ?? '-'} / ${widget.trade.prctyp ?? '-'}",
            theme,
          ),
          _rowOfInfoData(
            "Order No",
            widget.trade.norenordno?.toString() ?? '-',
            theme,
          ),
          _rowOfInfoData(
            "Fill ID",
            widget.trade.flid?.toString() ?? '-',
            theme,
          ),
          _rowOfInfoData(
            "Date & Time",
            formatDateTime(value: widget.trade.norentm ?? '-'),
            theme,
          ),
          _rowOfInfoData(
            "Status",
            widget.trade.stat ?? '-',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title1,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
                fontWeight: MyntFonts.regular,
              ),
            ),
            Text(
              value1,
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _rowOfInfoDataWithColor(
      String title, String value, ThemesProvider theme, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
                fontWeight: MyntFonts.regular,
              ),
            ),
            Text(
              value,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: valueColor,
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
