import 'dart:async';
import 'package:flutter/material.dart'
    hide DataTable, DataColumn, DataRow, DataCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
// import 'package:mynt_plus/res/global_font_web.dart'; // Commented out - unused
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/hover_actions_web.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';

import '../refactored/services/order_action_handler.dart';
import '../refactored/utils/cell_formatters.dart';

/// Open Orders tab using shadcn DataTable
class OpenOrdersScreen extends ConsumerStatefulWidget {
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;

  const OpenOrdersScreen({
    super.key,
    required this.horizontalScrollController,
    required this.verticalScrollController,
  });

  @override
  ConsumerState<OpenOrdersScreen> createState() => _OpenOrdersScreenState();
}

class _OpenOrdersScreenState extends ConsumerState<OpenOrdersScreen> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  // PERFORMANCE FIX: Use ValueNotifier for hover instead of setState
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingOrderToken;
  Offset _modifyDialogPosition = const Offset(100, 100);

  @override
  void dispose() {
    _hoveredRowIndex.dispose();
    super.dispose();
  }

  // Helper method to get appropriate text style for table cells
  // 14px, weight 500, MyntColors for text
  TextStyle _getTextStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  // Helper method for header text style
  // 14px, weight 600, MyntColors for text
  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? MyntColors.textSecondaryDark,
      lightColor: color ?? MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  // Builds a cell with hover detection (matches holdings pattern)
  // 8 columns: Time, Type, Instrument, Product, Qty., LTP, Price, Status
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 2; // Instrument column (index 2 now)
    final isLastColumn = columnIndex == 7; // Status column (index 7 now)

    // Match the cell padding logic - Instrument column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets cellPadding;
    if (isFirstColumn) {
      // First column - symmetric padding
      cellPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isInstrumentColumn) {
      // Instrument column - more left, minimal right (for overlay buttons)
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 4, 8);
    } else if (isLastColumn) {
      // Last column - minimal left, more right
      cellPadding = const EdgeInsets.fromLTRB(4, 8, 16, 8);
    } else {
      // Other columns - symmetric padding
      cellPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    }

    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: ValueListenableBuilder<int?>(
        valueListenable: _hoveredRowIndex,
        builder: (context, hoveredIndex, _) {
          final isHovered = hoveredIndex == rowIndex;
          return MouseRegion(
            onEnter: (_) => _hoveredRowIndex.value = rowIndex,
            onExit: (_) => _hoveredRowIndex.value = null,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: cellPadding,
                alignment:
                    alignRight ? Alignment.centerRight : Alignment.centerLeft,
                // Watchlist-style hover background
                color: isHovered
                    ? resolveThemeColor(
                        context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary,
                      ).withValues(alpha: 0.08)
                    : Colors.transparent,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds a sortable header cell
  // 8 columns: Time, Type, Instrument, Product, Qty., LTP, Price, Status
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 2; // Instrument column (index 2 now)
    final isLastColumn = columnIndex == 7; // Status column (index 7 now)

    // Match the cell padding logic - Instrument column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets headerPadding;
    if (isFirstColumn) {
      // First column - symmetric padding
      headerPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
    } else if (isInstrumentColumn) {
      // Instrument column - more left, minimal right
      headerPadding = const EdgeInsets.fromLTRB(16, 6, 4, 6);
    } else if (isLastColumn) {
      // Last column - minimal left, more right
      headerPadding = const EdgeInsets.fromLTRB(4, 6, 16, 6);
    } else {
      // Other columns - symmetric padding
      headerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6);
    }

    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _onSort(columnIndex),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: headerPadding,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: Colors.white.withOpacity(0.04),
              light: Colors.black.withOpacity(0.03),
            ),
          ),
          child: Row(
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              if (alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              Text(
                label,
                style: _getHeaderStyle(context),
              ),
              if (!alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              if (!alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  // Helper method to format time with seconds (HH:mm:ss)
  String _formatTime(String time) {
    if (time.isEmpty || time == '0.00') return 'N/A';

    try {
      // Check if time is in "HH:mm:ss dd-MM-yyyy" format
      if (time.contains(':') && time.contains('-')) {
        final timePart = time.split(' ')[0]; // Get "HH:mm:ss" part
        return timePart; // Returns time with seconds
      }

      // Fallback: If time is in "HHMMSS" or "HHMM" format
      if (time.length >= 6) {
        // Format: "HHMMSS" to "HH:MM:SS"
        final hours = time.substring(0, 2);
        final minutes = time.substring(2, 4);
        final seconds = time.substring(4, 6);
        return '$hours:$minutes:$seconds';
      } else if (time.length >= 4) {
        // Format: "HHMM" to "HH:MM:00"
        final hours = time.substring(0, 2);
        final minutes = time.substring(2, 4);
        return '$hours:$minutes:00';
      }
    } catch (e) {
      // If parsing fails, return as is
    }

    return time;
  }

  Color _getStatusColor(String status) {
    final statusUpper = status.toUpperCase();

    if (statusUpper.contains('COMPLETE') || statusUpper.contains('FILLED')) {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (statusUpper.contains('REJECT') ||
        statusUpper.contains('CANCEL')) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (statusUpper.contains('PENDING') ||
        statusUpper.contains('OPEN')) {
      return resolveThemeColor(context,
          dark: MyntColors.warning, light: MyntColors.warning);
    }
    return resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
  }

  // Commented out - using equal width columns now
  // // Calculate minimum column widths dynamically based on header and data
  // // 8 columns: Time, Type, Instrument, Product, Qty., LTP, Price, Status
  // Map<int, double> _calculateMinWidths(
  //     List<OrderBookModel> orders, BuildContext context) {
  //   // Use fixed font size for measurement (table text is not responsive, only buttons are)
  //   final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
  //   const padding = 24.0; // Padding for cell content
  //   const sortIconWidth = 24.0; // Extra space for sort indicator icon
  //
  //   // 8 columns: Time, Type, Instrument, Product, Qty., LTP, Price, Status
  //   final headers = [
  //     'Time',
  //     'Type',
  //     'Instrument',
  //     'Product',
  //     'Qty.',
  //     'LTP',
  //     'Price',
  //     'Status',
  //   ];
  //   final minWidths = <int, double>{};
  //
  //   // Calculate width for each column
  //   for (int col = 0; col < headers.length; col++) {
  //     double maxWidth = 0.0;
  //
  //     // Measure header width and add space for sort icon
  //     final headerWidth = _measureTextWidth(headers[col], textStyle);
  //     maxWidth = headerWidth + sortIconWidth;
  //
  //     // Measure widest value in this column (sample first 5 rows for performance)
  //     for (final order in orders.take(5)) {
  //       String cellText = '';
  //       switch (col) {
  //         case 0: // Time
  //           cellText = _formatTime(order.norentm ?? '0.00');
  //           break;
  //         case 1: // Type (BUY/SELL)
  //           cellText = order.trantype == "S" ? "SELL" : "BUY";
  //           break;
  //         case 2: // Instrument
  //           final symbol = (order.tsym ?? '').replaceAll("-EQ", "").trim();
  //           final exchange = order.exch ?? '';
  //           final exchangeText = exchange.isNotEmpty ? ' $exchange' : '';
  //           final symbolWidth = _measureTextWidth(symbol, textStyle);
  //           final exchangeStyle =
  //               const TextStyle(fontSize: 10, fontFamily: 'Geist');
  //           final exchangeWidth = exchangeText.isNotEmpty
  //               ? _measureTextWidth(exchangeText, exchangeStyle)
  //               : 0.0;
  //           final totalWidth = symbolWidth +
  //               exchangeWidth +
  //               (exchangeText.isNotEmpty ? 4.0 : 0.0);
  //           if (totalWidth > maxWidth) {
  //             maxWidth = totalWidth;
  //           }
  //           continue;
  //         case 3: // Product
  //           cellText = order.sPrdtAli ?? order.prd ?? '';
  //           break;
  //         case 4: // Qty.
  //           cellText = order.qty?.toString() ?? '0';
  //           break;
  //         case 5: // LTP
  //           cellText = CellFormatters.getValidLTP(order);
  //           break;
  //         case 6: // Price
  //           cellText = CellFormatters.getValidPrice(order);
  //           break;
  //         case 7: // Status
  //           cellText = CellFormatters.getStatusText(order);
  //           break;
  //       }
  //
  //       final cellWidth = _measureTextWidth(cellText, textStyle);
  //       if (cellWidth > maxWidth) {
  //         maxWidth = cellWidth;
  //       }
  //     }
  //
  //     if (headers[col] == 'Instrument') {
  //       const minInstrumentWidth = 150.0;
  //       maxWidth =
  //           maxWidth < minInstrumentWidth ? minInstrumentWidth : maxWidth;
  //     }
  //
  //     minWidths[col] = maxWidth + padding;
  //   }
  //
  //   return minWidths;
  // }
  //
  // // Helper method to measure text width dynamically
  // double _measureTextWidth(String text, TextStyle style) {
  //   final textPainter = TextPainter(
  //     text: TextSpan(text: text, style: style),
  //     textDirection: TextDirection.ltr,
  //     maxLines: 1,
  //   );
  //   textPainter.layout();
  //   return textPainter.width;
  // }

  // Sort orders based on 8 columns: Time, Type, Instrument, Product, Qty., LTP, Price, Status
  List<OrderBookModel> _getSortedOrders(List<OrderBookModel> orders) {
    if (_sortColumnIndex == null) return orders;

    final sorted = List<OrderBookModel>.from(orders);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // Time
          comparison = (a.norentm ?? '').compareTo(b.norentm ?? '');
          break;
        case 1: // Type (BUY/SELL)
          comparison = (a.trantype ?? '').compareTo(b.trantype ?? '');
          break;
        case 2: // Instrument
          comparison = (a.tsym ?? '').compareTo(b.tsym ?? '');
          break;
        case 3: // Product
          comparison =
              (a.sPrdtAli ?? a.prd ?? '').compareTo(b.sPrdtAli ?? b.prd ?? '');
          break;
        case 4: // Qty.
          comparison = (int.tryParse(a.qty ?? '0') ?? 0)
              .compareTo(int.tryParse(b.qty ?? '0') ?? 0);
          break;
        case 5: // LTP
          comparison = (double.tryParse(a.ltp ?? '0') ?? 0)
              .compareTo(double.tryParse(b.ltp ?? '0') ?? 0);
          break;
        case 6: // Price
          comparison = (double.tryParse(a.prc ?? '0') ?? 0)
              .compareTo(double.tryParse(b.prc ?? '0') ?? 0);
          break;
        case 7: // Status
          comparison = (CellFormatters.getStatusText(a))
              .compareTo(CellFormatters.getStatusText(b));
          break;
        // Old column cases (commented out):
        // case 3: // Type (Price type)
        //   comparison = (a.prctyp ?? '').compareTo(b.prctyp ?? '');
        //   break;
        // case 6: // Avg price
        //   comparison = (double.tryParse(a.avgprc ?? '0') ?? 0)
        //       .compareTo(double.tryParse(b.avgprc ?? '0') ?? 0);
        //   break;
        // case 9: // Trigger price
        //   comparison = (double.tryParse(a.trgprc ?? '0') ?? 0)
        //       .compareTo(double.tryParse(b.trgprc ?? '0') ?? 0);
        //   break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final orderBook = ref.watch(orderProvider);

    // Get orders (search or regular)
    // Only show search results if we're on the Open Orders tab (index 0)
    final searchQuery = orderBook.orderSearchCtrl.text.trim();
    final isOpenOrdersTab = orderBook.selectedTab == 0;
    final orders = (searchQuery.isNotEmpty && isOpenOrdersTab)
        ? (orderBook.orderSearchItem ?? [])
        : (orderBook.openOrder ?? []);

    // Show loading or empty state
    if (orders.isEmpty) {
      if (orderBook.loading) {
        return SizedBox(
          height: 400,
          child: Center(
            child: MyntLoader.centered(message: 'Loading orders...'),
          ),
        );
      } else {
        return SizedBox(
          // height: 400,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: NoDataFound(
                title: searchQuery.isNotEmpty ? "No Orders Found" : "No Orders",
                subtitle: searchQuery.isNotEmpty
                    ? "No orders match your search \"$searchQuery\"."
                    : "You don't have any open orders yet.",
                primaryEnabled: false,
                secondaryEnabled: false,
              ),
            ),
          ),
        );
      }
    }

    final sortedOrders = _getSortedOrders(orders);
    final actionHandler = OrderActionHandler(ref: ref, context: context);

    // Build data rows - 8 columns: Time, Type, Instrument, Product, Qty., LTP, Price, Status
    final dataRows = <shadcn.TableRow>[];
    for (var i = 0; i < sortedOrders.length; i++) {
      final order = sortedOrders[i];
      final uniqueId =
          order.norenordno?.toString() ?? order.token?.toString() ?? '';
      // final colorScheme = shadcn.Theme.of(context).colorScheme; // Commented out - unused

      dataRows.add(
        shadcn.TableRow(
          cells: [
            // Column 0: Time
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 0,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                _formatTime(order.norentm ?? '0.00'),
                style: _getTextStyle(context),
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
            // Column 1: Type (BUY/SELL)
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 1,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                order.trantype == "S" ? "SELL" : "BUY",
                style: _getTextStyle(
                  context,
                  color: order.trantype == "S"
                      ? resolveThemeColor(context,
                          dark: MyntColors.lossDark, light: MyntColors.loss)
                      : resolveThemeColor(context,
                          dark: MyntColors.profitDark,
                          light: MyntColors.profit),
                ),
              ),
            ),
            // Column 2: Instrument - PERFORMANCE FIX: Use ValueListenableBuilder for hover-dependent UI
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 2,
              child: ValueListenableBuilder<int?>(
                valueListenable: _hoveredRowIndex,
                builder: (context, hoveredIndex, _) {
                  final isHovered = hoveredIndex == i;
                  return GestureDetector(
                    onTap: () => actionHandler.openOrderDetail(order),
                    behavior: HitTestBehavior.opaque,
                    child: _buildInstrumentCell(
                        order, theme, uniqueId, actionHandler, isHovered),
                  );
                },
              ),
            ),
            // Column 3: Product
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 3,
               alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                order.sPrdtAli ?? order.prd ?? '',
                style: _getTextStyle(context),
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
            // Column 4: Qty.
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 4,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                order.qty?.toString() ?? '0',
                style: _getTextStyle(context),
              ),
            ),
            // Column 5: LTP (with dynamic colors based on order price)
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 5,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: _OrderLTPCell(
                token: order.token ?? '',
                initialLtp: CellFormatters.getValidLTP(order),
                trantype: order.trantype ?? 'B',
                orderPrice: order.prc ?? '0',
              ),
            ),
            // Column 6: Price
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 6,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                CellFormatters.getValidPrice(order),
                style: _getTextStyle(
                  context,
                  color: order.trantype == "S"
                      ? resolveThemeColor(context,
                          dark: MyntColors.lossDark, light: MyntColors.loss)
                      : resolveThemeColor(context,
                          dark: MyntColors.profitDark,
                          light: MyntColors.profit),
                ),
              ),
            ),
            // Column 7: Status (aligned right)
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 7,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(CellFormatters.getStatusText(order))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  CellFormatters.getStatusText(order).toUpperCase(),
                  style: MyntWebTextStyles.para(
                    context,
                    color: _getStatusColor(CellFormatters.getStatusText(order)),
                    fontWeight: MyntFonts.medium,
                  ),
                ),
              ),
            ),
            // Old columns (commented out):
            // buildCellWithHover(
            //   rowIndex: i,
            //   columnIndex: 3,
            //   onTap: () => actionHandler.openOrderDetail(order),
            //   child: Text(
            //     order.prctyp ?? '',
            //     style: _getTextStyle(context),
            //     overflow: TextOverflow.visible,
            //     softWrap: false,
            //   ),
            // ),
            // buildCellWithHover(
            //   rowIndex: i,
            //   columnIndex: 6,
            //   alignRight: true,
            //   onTap: () => actionHandler.openOrderDetail(order),
            //   child: Text(
            //     order.avgprc ?? '0.00',
            //     style: _getTextStyle(context),
            //   ),
            // ),
            // buildCellWithHover(
            //   rowIndex: i,
            //   columnIndex: 9,
            //   alignRight: true,
            //   onTap: () => actionHandler.openOrderDetail(order),
            //   child: Text(
            //     (order.trgprc != null &&
            //             order.trgprc != '0' &&
            //             order.trgprc != '0.00')
            //         ? order.trgprc!
            //         : '0.00',
            //     style: _getTextStyle(context),
            //   ),
            // ),
          ],
        ),
      );
    }

    // Return shadcn Table with proper structure
    // 8 columns: Time, Type, Instrument, Product, Qty., LTP, Price, Status
    return SizedBox.expand(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: shadcn.OutlinedContainer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Available width
              final availableWidth = constraints.maxWidth;

              // Equal width for all 8 columns
              final equalWidth = availableWidth / 8;

              // Old dynamic width calculation (commented out):
              // final minWidths = _calculateMinWidths(sortedOrders, context);
              // final columnWidths = <int, double>{};
              // for (int i = 0; i < 11; i++) {
              //   columnWidths[i] = minWidths[i] ?? 100.0;
              // }
              // ... proportional distribution logic ...

              // Build table content
              Widget buildTableContent() {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: constraints.maxHeight.isFinite &&
                            constraints.maxHeight > 0
                        ? constraints.maxHeight
                        : double.infinity,
                  ),
                  child: Column(
                    children: [
                      // Fixed Header - 8 columns with equal width
                      shadcn.Table(
                        columnWidths: {
                          0: shadcn.FixedTableSize(equalWidth),
                          1: shadcn.FixedTableSize(equalWidth),
                          2: shadcn.FixedTableSize(equalWidth),
                          3: shadcn.FixedTableSize(equalWidth),
                          4: shadcn.FixedTableSize(equalWidth),
                          5: shadcn.FixedTableSize(equalWidth),
                          6: shadcn.FixedTableSize(equalWidth),
                          7: shadcn.FixedTableSize(equalWidth),
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: [
                          shadcn.TableHeader(
                            cells: [
                              buildHeaderCell('Time', 0),
                              buildHeaderCell('Type', 1),
                              buildHeaderCell('Instrument', 2),
                              buildHeaderCell('Product', 3,true),
                              buildHeaderCell('Qty.', 4, true),
                              buildHeaderCell('LTP', 5, true),
                              buildHeaderCell('Price', 6, true),
                              buildHeaderCell('Status', 7, true),
                              // Old headers (commented out):
                              // buildHeaderCell('Side', 4),
                              // buildHeaderCell('Avg price', 6, true),
                              // buildHeaderCell('Trigger price', 9, true),
                            ],
                          ),
                        ],
                      ),
                      // Scrollable Body (vertical scroll)
                      Expanded(
                        child: RawScrollbar(
                          controller: widget.verticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          trackColor: resolveThemeColor(context,
                              dark: Colors.grey.withValues(alpha: 0.1),
                              light: Colors.grey.withValues(alpha: 0.1)),
                          thumbColor: resolveThemeColor(context,
                              dark: Colors.grey.withValues(alpha: 0.3),
                              light: Colors.grey.withValues(alpha: 0.3)),
                          thickness: 6,
                          radius: const Radius.circular(3),
                          interactive: true,
                          child: SingleChildScrollView(
                            controller: widget.verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: shadcn.Table(
                              key: ValueKey(
                                  'table_${_sortColumnIndex}_$_sortAscending'),
                              columnWidths: {
                                0: shadcn.FixedTableSize(equalWidth),
                                1: shadcn.FixedTableSize(equalWidth),
                                2: shadcn.FixedTableSize(equalWidth),
                                3: shadcn.FixedTableSize(equalWidth),
                                4: shadcn.FixedTableSize(equalWidth),
                                5: shadcn.FixedTableSize(equalWidth),
                                6: shadcn.FixedTableSize(equalWidth),
                                7: shadcn.FixedTableSize(equalWidth),
                              },
                              defaultRowHeight: const shadcn.FixedTableSize(50),
                              rows: dataRows,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // No horizontal scroll needed with equal width columns
              return buildTableContent();

              // Old horizontal scroll wrapper (commented out):
              // final totalRequiredWidth = columnWidths.values
              //     .fold<double>(0.0, (sum, width) => sum + width);
              // final needsHorizontalScroll = totalRequiredWidth > availableWidth;
              // if (needsHorizontalScroll) {
              //   return RawScrollbar(
              //     controller: widget.horizontalScrollController,
              //     thumbVisibility: true,
              //     trackVisibility: true,
              //     trackColor: resolveThemeColor(context,
              //         dark: Colors.grey.withValues(alpha: 0.1),
              //         light: Colors.grey.withValues(alpha: 0.1)),
              //     thumbColor: resolveThemeColor(context,
              //         dark: Colors.grey.withValues(alpha: 0.3),
              //         light: Colors.grey.withValues(alpha: 0.3)),
              //     thickness: 6,
              //     radius: const Radius.circular(3),
              //     interactive: true,
              //     child: SingleChildScrollView(
              //       controller: widget.horizontalScrollController,
              //       scrollDirection: Axis.horizontal,
              //       child: SizedBox(
              //         width: totalRequiredWidth,
              //         child: buildTableContent(),
              //       ),
              //     ),
              //   );
              // }
            },
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
    bool isHovered,
  ) {
    final isProcessing = _processingOrderToken == uniqueId;
    final isPending = order.status == "PENDING" ||
        order.status == "OPEN" ||
        order.status == "TRIGGER_PENDING";

    // Format instrument: remove "-EQ" and don't include exchange
    final symbol = order.tsym ?? '';
    final displayText = symbol.replaceAll("-EQ", "").trim();

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Instrument name - full width, can be partially covered by buttons
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message:
                    '$displayText${order.exch != null && order.exch!.isNotEmpty ? ' ${order.exch}' : ''}',
                child: Padding(
                  padding: EdgeInsets.only(right: isHovered ? 140.0 : 0.0),
                  child: RichText(
                    overflow: isHovered
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
                    maxLines: 1,
                    softWrap: false,
                    text: TextSpan(
                      children: [
                        // Symbol (14px, 500)
                        TextSpan(
                          text: displayText,
                          style: _getTextStyle(context),
                        ),
                        // Exchange (10px, 500, muted color) - matching positions table style
                        if (order.exch != null && order.exch!.isNotEmpty)
                          TextSpan(
                            text: ' ${order.exch}',
                            style: MyntWebTextStyles.para(
                              context,
                              darkColor: MyntColors.textSecondaryDark,
                              lightColor: MyntColors.textSecondary,
                              fontWeight: MyntFonts.medium,
                            ).copyWith(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Action buttons using HoverActionsContainer with gradient background
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {}, // Empty handler to stop propagation
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: isHovered
                      ? LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            shadcn.Theme.of(context)
                                .colorScheme
                                .background
                                .withValues(alpha: 0.0),
                            shadcn.Theme.of(context)
                                .colorScheme
                                .background
                                .withValues(alpha: 0.95),
                          ],
                        )
                      : null,
                ),
                child: HoverActionsContainer(
                  isVisible: isHovered,
                  actions: [
                    if (isPending) ...[
                      HoverActionButton(
                        label: 'Modify',
                        size: 44,
                        borderRadius: 5,
                        color: Colors.white,
                        backgroundColor: resolveThemeColor(
                          context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary,
                        ),
                        borderColor: resolveThemeColor(
                          context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary,
                        ),
                        onPressed: (isProcessing && _isProcessingModify)
                            ? null
                            : () async {
                                setState(() {
                                  _processingOrderToken = uniqueId;
                                });
                                await actionHandler.modifyOrder(
                                  order,
                                  onProcessingStateChanged: (processing) {
                                    setState(() {
                                      _isProcessingModify = processing;
                                      if (!processing)
                                        _processingOrderToken = null;
                                    });
                                  },
                                  modifyDialogPosition: _modifyDialogPosition,
                                  onPositionChanged: (pos) {
                                    _modifyDialogPosition = pos;
                                  },
                                );
                              },
                      ),
                      HoverActionButton(
                        label: 'Cancel',
                        size: 44,
                        borderRadius: 5,
                        color: Colors.white,
                        backgroundColor: resolveThemeColor(
                          context,
                          dark: MyntColors.tertiary,
                          light: MyntColors.tertiary,
                        ),
                        borderColor: resolveThemeColor(
                          context,
                          dark: MyntColors.tertiary,
                          light: MyntColors.tertiary,
                        ),
                        onPressed: (isProcessing && _isProcessingCancel)
                            ? null
                            : () async {
                                setState(() {
                                  _processingOrderToken = uniqueId;
                                });
                                await actionHandler.cancelOrder(
                                  order,
                                  onProcessingStateChanged: (processing) {
                                    setState(() {
                                      _isProcessingCancel = processing;
                                      if (!processing)
                                        _processingOrderToken = null;
                                    });
                                  },
                                );
                              },
                      ),
                    ] else ...[
                      HoverActionButton(
                        label: 'Repeat',
                        size: 44,
                        borderRadius: 5,
                        color: Colors.white,
                        backgroundColor: resolveThemeColor(
                          context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary,
                        ),
                        borderColor: resolveThemeColor(
                          context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary,
                        ),
                        onPressed: () => actionHandler.repeatOrder(order),
                      ),
                      if (order.status == "OPEN")
                        HoverActionButton(
                          label: 'Cancel',
                          size: 44,
                          borderRadius: 5,
                          color: Colors.white,
                          backgroundColor: resolveThemeColor(
                            context,
                            dark: MyntColors.tertiary,
                            light: MyntColors.tertiary,
                          ),
                          borderColor: resolveThemeColor(
                            context,
                            dark: MyntColors.tertiary,
                            light: MyntColors.tertiary,
                          ),
                          onPressed: (isProcessing && _isProcessingCancel)
                              ? null
                              : () async {
                                  setState(() {
                                    _processingOrderToken = uniqueId;
                                  });
                                  await actionHandler.cancelOrder(
                                    order,
                                    onProcessingStateChanged: (processing) {
                                      setState(() {
                                        _isProcessingCancel = processing;
                                        if (!processing)
                                          _processingOrderToken = null;
                                      });
                                    },
                                  );
                                },
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// Action button widget

// LTP Cell with WebSocket updates and dynamic colors
class _OrderLTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;
  final String trantype; // "B" for BUY, "S" for SELL
  final String orderPrice; // Order price for comparison

  const _OrderLTPCell({
    required this.token,
    required this.initialLtp,
    required this.trantype,
    required this.orderPrice,
  });

  @override
  ConsumerState<_OrderLTPCell> createState() => _OrderLTPCellState();
}

class _OrderLTPCellState extends ConsumerState<_OrderLTPCell> {
  late String ltp;
  StreamSubscription? _subscription;
  bool _didSetupSubscription = false;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialLtp;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didSetupSubscription && widget.token.isNotEmpty) {
      _didSetupSubscription = true;

      Future.microtask(() {
        if (!mounted) return;

        _subscription =
            ref.read(websocketProvider).socketDataStream.listen((data) {
          if (!mounted || !data.containsKey(widget.token)) return;

          final newLtp = data[widget.token]['lp']?.toString();
          if (newLtp != null &&
              newLtp != ltp &&
              newLtp != '0.00' &&
              newLtp != 'null') {
            setState(() => ltp = newLtp);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Get dynamic color based on LTP vs order price
  Color _getLtpColor(BuildContext context) {
    final ltpValue = double.tryParse(ltp) ?? 0.0;
    final priceValue = double.tryParse(widget.orderPrice) ?? 0.0;

    // If price is 0 or MKT order, use default color
    if (priceValue == 0.0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.textPrimaryDark,
        light: MyntColors.textPrimary,
      );
    }

    // For BUY orders: Green if LTP >= price (favorable), Red if LTP < price
    // For SELL orders: Green if LTP <= price (favorable), Red if LTP > price
    final isBuy = widget.trantype != "S";

    if (isBuy) {
      // BUY: LTP >= price is good (green), LTP < price is bad (red)
      if (ltpValue >= priceValue) {
        return resolveThemeColor(
          context,
          dark: MyntColors.profitDark,
          light: MyntColors.profit,
        );
      } else {
        return resolveThemeColor(
          context,
          dark: MyntColors.lossDark,
          light: MyntColors.loss,
        );
      }
    } else {
      // SELL: LTP <= price is good (green), LTP > price is bad (red)
      if (ltpValue <= priceValue) {
        return resolveThemeColor(
          context,
          dark: MyntColors.profitDark,
          light: MyntColors.profit,
        );
      } else {
        return resolveThemeColor(
          context,
          dark: MyntColors.lossDark,
          light: MyntColors.loss,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      ltp,
      style: MyntWebTextStyles.tableCell(
        context,
        color: _getLtpColor(context),
        fontWeight: MyntFonts.medium,
      ),
    );
  }
}
