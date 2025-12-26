import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
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

/// Separate screen widget for Executed Orders tab
/// Reuses Open Orders screen logic but with different data source
class ExecutedOrdersScreen extends ConsumerStatefulWidget {
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;

  const ExecutedOrdersScreen({
    super.key,
    required this.horizontalScrollController,
    required this.verticalScrollController,
  });

  @override
  ConsumerState<ExecutedOrdersScreen> createState() => _ExecutedOrdersScreenState();
}

class _ExecutedOrdersScreenState extends ConsumerState<ExecutedOrdersScreen> {
  final ValueNotifier<String?> _hoveredRowToken = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);
  SortConfig _sortConfig = const SortConfig();
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingOrderToken;
  Offset _modifyDialogPosition = const Offset(100, 100);

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
    
    // Get executed orders (search or regular)
    final orders = orderBook.orderSearchCtrl.text.isNotEmpty
        ? (orderBook.orderSearchItem ?? [])
        : (orderBook.executedOrder ?? []);

    // Show loading or empty state
    if (orders.isEmpty) {
      if (orderBook.loading) {
        return const SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading orders...', style: TextStyle(color: Colors.grey)),
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
    final columnConfig = TableColumnConfig.orderBook(screenWidth);
    final headers = columnConfig.headers;

    // Build columns
    final columns = _buildColumns(headers, theme);
    
    // Build rows
    final rows = _buildRows(orders, headers, theme);

    return BaseOrderTable(
      columns: columns,
      rows: rows,
      horizontalScrollController: widget.horizontalScrollController,
      verticalScrollController: widget.verticalScrollController,
      fixedLeftColumns: 1,
      minWidth: 1840,
      theme: theme,
    );
  }

  List<DataColumn2> _buildColumns(List<String> headers, ThemesProvider theme) {
    return headers.map((header) {
      final columnIndex = ColumnUtils.getOrderBookColumnIndex(header);
      final isNumeric = ColumnUtils.isNumericColumn(header, 'order');
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
    List<OrderBookModel> orders,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = SortingUtils.sortOrders(orders, _sortConfig);
    final actionHandler = OrderActionHandler(ref: ref, context: context);

    return sorted.map((order) {
      final uniqueId = order.norenordno?.toString() ??
          order.token?.toString() ??
          '';

      return DataRow2(
        color: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered) ||
              _hoveredRowToken.value == uniqueId) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return Colors.transparent;
        }),
        cells: headers.map((header) {
          return _buildCell(header, order, theme, uniqueId, actionHandler);
        }).toList(),
        onTap: () => actionHandler.openOrderDetail(order),
      );
    }).toList();
  }

  DataCell _buildCell(
    String column,
    OrderBookModel order,
    ThemesProvider theme,
    String uniqueId,
    OrderActionHandler actionHandler,
  ) {
    Widget cellContent;
    final isNumeric = ColumnUtils.isNumericColumn(column, 'order');
    final alignment = isNumeric ? Alignment.centerRight : Alignment.centerLeft;

    switch (column) {
      case 'Instrument':
        cellContent = _buildInstrumentCell(order, theme, uniqueId, actionHandler);
        break;
      case 'Product':
        cellContent = _buildTextCell(
          order.sPrdtAli ?? order.prd ?? 'N/A',
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Type':
        final buySell = order.trantype == "S" ? "SELL" : "BUY";
        final buttonColor = order.trantype == "S"
            ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
            : (theme.isDarkMode ? colors.profitDark : colors.profitLight);
        cellContent = _buildTextCell(buySell, theme, Alignment.centerLeft,
            color: buttonColor);
        break;
      case 'Qty':
        cellContent = _buildTextCell(
          order.qty?.toString() ?? '0',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Avg price':
        cellContent = _buildTextCell(
          order.avgprc ?? '0.00',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'LTP':
        if (order.token == null || order.token!.isEmpty) {
          cellContent = _buildTextCell(
            CellFormatters.getValidLTP(order),
            theme,
            Alignment.centerRight,
          );
        } else {
          cellContent = OrderBookLTPCell(
            token: order.token!,
            initialLtp: CellFormatters.getValidLTP(order),
            order: order,
            theme: theme,
          );
        }
        break;
      case 'Price':
        cellContent = _buildTextCell(
          CellFormatters.getValidPrice(order),
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Trigger price':
        final triggerPrice = (order.trgprc != null &&
                order.trgprc != '0' &&
                order.trgprc != '0.00')
            ? order.trgprc!
            : '0.00';
        cellContent = _buildTextCell(triggerPrice, theme, Alignment.centerRight);
        break;
      case 'Order value':
        cellContent = _buildTextCell(
          CellFormatters.calculateOrderValue(order),
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Status':
        final statusText = CellFormatters.getStatusText(order);
        final statusColor = CellFormatters.getStatusColor(statusText, theme);
        cellContent = _buildTextCell(
          statusText,
          theme,
          Alignment.centerLeft,
          color: statusColor,
        );
        break;
      case 'Time':
        final time = order.norentm != null ? order.norentm! : '0.00';
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
    OrderBookModel order,
    ThemesProvider theme,
    String uniqueId,
    OrderActionHandler actionHandler,
  ) {
    final isProcessing = _processingOrderToken == uniqueId;
    final isPending = order.status == "PENDING" ||
        order.status == "OPEN" ||
        order.status == "TRIGGER_PENDING";

    final displayText = CellFormatters.formatInstrumentText(order);

    return ValueListenableBuilder<String?>(
      valueListenable: _hoveredRowToken,
      builder: (context, hoveredToken, child) {
        final rowIsHovered = hoveredToken == uniqueId;

        return Row(
          children: [
            Expanded(
              flex: rowIsHovered ? 1 : 2,
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
            IgnorePointer(
              ignoring: !rowIsHovered,
              child: AnimatedOpacity(
                opacity: rowIsHovered ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                await actionHandler.cancelOrder(
                                  order,
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
                                await actionHandler.modifyOrder(
                                  order,
                                  onProcessingStateChanged: (processing) {
                                    setState(() {
                                      _isProcessingModify = processing;
                                      if (!processing) _processingOrderToken = null;
                                    });
                                  },
                                  modifyDialogPosition: _modifyDialogPosition,
                                  onPositionChanged: (pos) {
                                    _modifyDialogPosition = pos;
                                  },
                                );
                              },
                        theme: theme,
                      ),
                    ] else ...[
                      ActionButton(
                        label: 'Repeat',
                        color: Colors.white,
                        backgroundColor: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        onPressed: () => actionHandler.repeatOrder(order),
                        theme: theme,
                      ),
                      if (order.status == "OPEN") ...[
                        const SizedBox(width: 6),
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
                                  await actionHandler.cancelOrder(
                                    order,
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
                      ],
                    ],
                  ],
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

