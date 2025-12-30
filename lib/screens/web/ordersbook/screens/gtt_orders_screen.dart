import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:mynt_plus/models/order_book_model/gtt_order_book.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../refactored/widgets/base_order_table.dart';
import '../refactored/widgets/sortable_column_header.dart';
import '../refactored/widgets/cells/ltp_cell.dart';
import '../refactored/widgets/cells/action_button.dart';
import '../refactored/models/sort_config.dart';
import '../refactored/models/table_column_config.dart';
import '../refactored/utils/column_utils.dart';
import '../refactored/utils/cell_formatters.dart';
import '../refactored/utils/sorting_utils.dart';
import '../refactored/services/order_action_handler.dart';

/// Separate screen widget for GTT Orders tab
class GttOrdersScreen extends ConsumerStatefulWidget {
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;

  const GttOrdersScreen({
    super.key,
    required this.horizontalScrollController,
    required this.verticalScrollController,
  });

  @override
  ConsumerState<GttOrdersScreen> createState() => _GttOrdersScreenState();
}

class _GttOrdersScreenState extends ConsumerState<GttOrdersScreen> {
  final ValueNotifier<String?> _hoveredRowToken = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);
  SortConfig _sortConfig = const SortConfig();
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingOrderToken;

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
    
    // Get GTT orders (search or regular)
    final gttOrders = orderBook.orderSearchCtrl.text.isNotEmpty
        ? (orderBook.gttOrderBookSearch ?? [])
        : (orderBook.gttOrderBookModel ?? []);

    // Show loading or empty state
    if (gttOrders.isEmpty) {
      if (orderBook.loading) {
        return const SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading GTT orders...', style: TextStyle(color: Colors.grey)),
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
    final columnConfig = TableColumnConfig.gttOrders(screenWidth);
    final headers = columnConfig.headers;

    // Build columns
    final columns = _buildColumns(headers, theme);
    
    // Build rows
    final rows = _buildRows(gttOrders, headers, theme);

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
      final columnIndex = ColumnUtils.getGttColumnIndex(header);
      final isNumeric = ColumnUtils.isNumericColumn(header, 'gtt');
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
    List<GttOrderBookModel> gttOrders,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = SortingUtils.sortGttOrders(gttOrders, _sortConfig);
    final actionHandler = OrderActionHandler(ref: ref, context: context);

    return sorted.map((gttOrder) {
      final uniqueId = '${gttOrder.alId ?? ''}_${gttOrder.tsym ?? ''}';

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
          return _buildCell(header, gttOrder, theme, uniqueId, actionHandler);
        }).toList(),
        onTap: () => actionHandler.openGttOrderDetail(gttOrder),
      );
    }).toList();
  }

  DataCell _buildCell(
    String column,
    GttOrderBookModel gttOrder,
    ThemesProvider theme,
    String uniqueId,
    OrderActionHandler actionHandler,
  ) {
    Widget cellContent;
    final isNumeric = ColumnUtils.isNumericColumn(column, 'gtt');
    final alignment = isNumeric ? Alignment.centerRight : Alignment.centerLeft;

    switch (column) {
      case 'Instrument':
        cellContent = _buildInstrumentCell(gttOrder, theme, uniqueId, actionHandler);
        break;
      case 'Product':
        cellContent = _buildTextCell(
          gttOrder.placeOrderParams?.sPrdtAli ?? 'N/A',
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Type':
        final isBuy = gttOrder.trantype == "B";
        final buttonColor = isBuy
            ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
            : (theme.isDarkMode ? colors.lossDark : colors.lossLight);
        cellContent = _buildTextCell(
          isBuy ? "BUY" : "SELL",
          theme,
          Alignment.centerLeft,
          color: buttonColor,
        );
        break;
      case 'Qty':
        cellContent = _buildTextCell(
          gttOrder.qty?.toString() ?? '0',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'LTP':
        if (gttOrder.token == null || gttOrder.token!.isEmpty) {
          cellContent = _buildTextCell(
            CellFormatters.getValidLTPForGtt(gttOrder),
            theme,
            Alignment.centerRight,
          );
        } else {
          cellContent = GttLTPCell(
            token: gttOrder.token!,
            initialLtp: CellFormatters.getValidLTPForGtt(gttOrder),
            gttOrder: gttOrder,
            theme: theme,
          );
        }
        break;
      case 'Trigger':
        cellContent = _buildTextCell(
          gttOrder.d ?? '0.00',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Status':
        final status = gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
        final statusColor = CellFormatters.getGttStatusColor(status, theme);
        cellContent = _buildTextCell(
          CellFormatters.getGttStatusText(status),
          theme,
          Alignment.centerLeft,
          color: statusColor,
        );
        break;
      case 'Time':
        final time = gttOrder.norentm != null ? gttOrder.norentm! : '';
        cellContent = _buildTextCell(
          time.isNotEmpty ? CellFormatters.formatTime(time) : '',
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
    GttOrderBookModel gttOrder,
    ThemesProvider theme,
    String uniqueId,
    OrderActionHandler actionHandler,
  ) {
    final isProcessing = _processingOrderToken == uniqueId;
    final status = gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
    final isPending = status == 'PENDING' || status == 'TRIGGER_PENDING';

    final displayText = CellFormatters.formatGttInstrumentText(gttOrder);

    return ValueListenableBuilder<String?>(
      valueListenable: _hoveredRowToken,
      builder: (context, hoveredToken, child) {
        final rowIsHovered = hoveredToken == uniqueId;

        return Row(
          children: [
            // ✅ Instrument name - always visible, never compressed
            Expanded(
              child: Align(
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
                          : WebColors.textPrimary,
                      fontWeight: WebFonts.medium,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            // ✅ Action buttons - appear on hover, stay within bounds
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: rowIsHovered ? null : 0,
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !rowIsHovered,
                child: AnimatedOpacity(
                  opacity: rowIsHovered ? 1 : 0,
                  duration: const Duration(milliseconds: 140),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      if (isPending) ...[
                        ActionButton(
                          label: 'Cancel',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.error
                              : WebColors.error,
                          onPressed: isProcessing && _isProcessingCancel
                              ? null
                              : () async {
                                  _processingOrderToken = uniqueId;
                                  await actionHandler.cancelGttOrder(
                                    gttOrder,
                                    onProcessingStateChanged: (processing) {
                                      setState(() {
                                        _isProcessingCancel = processing;
                                        if (!processing) _processingOrderToken = null;
                                      });
                                    },
                                  );
                                },
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                        ActionButton(
                          label: 'Modify',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          onPressed: isProcessing && _isProcessingModify
                              ? null
                              : () async {
                                  _processingOrderToken = uniqueId;
                                  await actionHandler.modifyGttOrder(
                                    gttOrder,
                                    onProcessingStateChanged: (processing) {
                                      setState(() {
                                        _isProcessingModify = processing;
                                        if (!processing) _processingOrderToken = null;
                                      });
                                    },
                                  );
                                },
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                    : WebColors.textPrimary),
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

