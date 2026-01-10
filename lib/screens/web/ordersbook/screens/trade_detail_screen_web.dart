import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../../models/order_book_model/trade_book_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/functions.dart';
import '../refactored/utils/cell_formatters.dart';

class TradeDetailScreenWeb extends ConsumerStatefulWidget {
  final TradeBookModel trade;
  final BuildContext? parentContext;
  
  const TradeDetailScreenWeb({
    super.key, 
    required this.trade,
    this.parentContext,
  });

  @override
  ConsumerState<TradeDetailScreenWeb> createState() => _TradeDetailScreenWebState();
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
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
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
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSymbolSection(theme),
                    ),
                    shadcn.TextButton(
                      density: shadcn.ButtonDensity.icon,
                      shape: shadcn.ButtonShape.circle,
                      size: shadcn.ButtonSize.normal,
                      child: const Icon(Icons.close),
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
                color: shadcn.Theme.of(context).colorScheme.border,
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
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final symbol = widget.trade.symbol?.replaceAll("-EQ", "") ?? widget.trade.tsym?.replaceAll("-EQ", "") ?? '';
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
                displayText.isNotEmpty ? displayText : (widget.trade.tsym ?? 'N/A'),
                style: WebTextStyles.dialogTitle(
                  isDarkTheme: theme.isDarkMode,
                  color: colorScheme.foreground,
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
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final buySell = widget.trade.trantype == "S" ? "Sell" : "Buy";
    final isSell = widget.trade.trantype == "S";
    final typeColor = isSell ? colorScheme.destructive : colorScheme.chart2;
    
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowOfInfoDataWithColor("Type", buySell, theme, typeColor),
          _rowOfInfoData(
            "Qty",
            widget.trade.flqty?.toString() ?? widget.trade.qty?.toString() ?? '0',
            theme,
          ),
          _rowOfInfoData(
            "Price",
            widget.trade.flprc?.toString() ?? widget.trade.avgprc?.toString() ?? '0.00',
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
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title1,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.regular,
              ),
            ),
            Text(
              value1,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _rowOfInfoDataWithColor(String title, String value, ThemesProvider theme, Color valueColor) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.regular,
              ),
            ),
            Text(
              value,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: valueColor,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

