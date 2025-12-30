import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:mynt_plus/models/order_book_model/trade_book_model.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../refactored/widgets/base_order_table.dart';
import '../refactored/widgets/sortable_column_header.dart';
import '../refactored/models/sort_config.dart';
import '../refactored/models/table_column_config.dart';
import '../refactored/utils/column_utils.dart';
import '../refactored/utils/cell_formatters.dart';
import '../refactored/utils/sorting_utils.dart';
import '../refactored/services/order_action_handler.dart';

/// Separate screen widget for Trade Book tab
class TradeBookScreen extends ConsumerStatefulWidget {
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;

  const TradeBookScreen({
    super.key,
    required this.horizontalScrollController,
    required this.verticalScrollController,
  });

  @override
  ConsumerState<TradeBookScreen> createState() => _TradeBookScreenState();
}

class _TradeBookScreenState extends ConsumerState<TradeBookScreen> {
  final ValueNotifier<String?> _hoveredRowToken = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);
  SortConfig _sortConfig = const SortConfig();

  @override
  void dispose() {
    _hoveredRowToken.dispose();
    _hoveredColumnIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final orderBook = ref.read(orderProvider);
    
    // Get trades (search or regular)
    final trades = orderBook.orderSearchCtrl.text.isNotEmpty
        ? (orderBook.tradeBooksearch ?? [])
        : (orderBook.tradeBook ?? []);

    // Show loading or empty state
    if (trades.isEmpty) {
      if (orderBook.loading) {
        return const SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading trades...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox(
          height: 400,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: NoDataFound(),
            ),
          ),
        );
      }
    }

    // Get column configuration
    final screenWidth = MediaQuery.of(context).size.width;
    final columnConfig = TableColumnConfig.tradeBook(screenWidth);
    final headers = columnConfig.headers;

    // Build columns
    final columns = _buildColumns(headers, theme);
    
    // Build rows
    final rows = _buildRows(trades, headers, theme);

    return BaseOrderTable(
      columns: columns,
      rows: rows,
      horizontalScrollController: widget.horizontalScrollController,
      verticalScrollController: widget.verticalScrollController,
      fixedLeftColumns: 1,
      minWidth: 1200,
      theme: theme,
    );
  }

  List<DataColumn2> _buildColumns(List<String> headers, ThemesProvider theme) {
    return headers.map((header) {
      final columnIndex = ColumnUtils.getTradeBookColumnIndex(header);
      final isNumeric = ColumnUtils.isNumericColumn(header, 'trade');
      final isInstrument = header == 'Instrument';
      final isTime = header == 'Time';

      return DataColumn2(
        label: SortableColumnHeader(
          header: header,
          columnIndex: columnIndex,
          sortConfig: _sortConfig,
          hoveredColumnIndex: _hoveredColumnIndex,
          onSort: () => setState(() {
            _sortConfig = _sortConfig.toggleSort(columnIndex);
          }),
          theme: theme,
          isNumeric: isNumeric,
        ),
        size: isInstrument ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isInstrument ? 300.0 : (isTime ? 220.0 : null),
        onSort: null,
      );
    }).toList();
  }

  List<DataRow2> _buildRows(
    List<TradeBookModel> trades,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = SortingUtils.sortTrades(trades, _sortConfig);
    final actionHandler = OrderActionHandler(ref: ref, context: context);

    return sorted.map((trade) {
      final token = trade.token ?? '';
      final index = sorted.indexOf(trade);
      final uniqueId = '$token$index';

      return DataRow2(
        color: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              _hoveredRowToken.value == uniqueId) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return Colors.transparent;
        }),
        cells: headers.map((header) {
          return _buildCell(header, trade, theme, uniqueId, actionHandler);
        }).toList(),
        onTap: () => actionHandler.openTradeDetail(trade),
      );
    }).toList();
  }

  DataCell _buildCell(
    String column,
    TradeBookModel trade,
    ThemesProvider theme,
    String uniqueId,
    OrderActionHandler actionHandler,
  ) {
    Widget cellContent;
    final isNumeric = ColumnUtils.isNumericColumn(column, 'trade');
    final alignment = isNumeric ? Alignment.centerRight : Alignment.centerLeft;

    switch (column) {
      case 'Instrument':
        cellContent = _buildInstrumentCell(trade, theme, uniqueId);
        break;
      case 'Product':
        cellContent = _buildTextCell(
          trade.sPrdtAli ?? 'N/A',
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Type':
        final buySell = trade.trantype == "S" ? "SELL" : "BUY";
        final textColor = trade.trantype == "S"
            ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
            : (theme.isDarkMode ? colors.profitDark : colors.profitLight);
        cellContent = _buildTextCell(
          buySell,
          theme,
          Alignment.centerLeft,
          color: textColor,
        );
        break;
      case 'Qty':
        cellContent = _buildTextCell(
          trade.qty?.toString() ?? 'N/A',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Price':
        cellContent = _buildTextCell(
          trade.avgprc?.toString() ?? 'N/A',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Trade value':
        cellContent = _buildTextCell(
          CellFormatters.calculateTradeValue(trade),
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Order no':
        cellContent = _buildTextCell(
          trade.norenordno?.toString() ?? 'N/A',
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Time':
        final time = trade.norentm != null ? trade.norentm! : 'N/A';
        cellContent = _buildTextCell(
          CellFormatters.formatTime(time),
          theme,
          Alignment.centerRight,
        );
        break;
      default:
        cellContent = const SizedBox.shrink();
    }

    return DataCell(
      MouseRegion(
        onEnter: (_) => _hoveredRowToken.value = uniqueId,
        onExit: (_) => _hoveredRowToken.value = null,
        child: SizedBox.expand(
          child: Container(
            alignment: alignment,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: cellContent,
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentCell(
    TradeBookModel trade,
    ThemesProvider theme,
    String uniqueId,
  ) {
    final displayText = CellFormatters.formatTradeInstrumentText(trade);

    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: displayText,
        child: Text(
          displayText,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textSecondary,
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Text(
          text,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: color ??
                (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textSecondary),
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}

