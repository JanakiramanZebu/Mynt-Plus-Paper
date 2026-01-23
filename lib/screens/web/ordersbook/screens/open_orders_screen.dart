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
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/hover_actions_web.dart';

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
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 1; // Instrument column
    final isLastColumn = columnIndex == 10; // Status column

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
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 1; // Instrument column
    final isLastColumn = columnIndex == 10; // Status column

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

  // Helper method to get status color using shadcn theme
  String _formatTime(String time) {
    if (time.isEmpty || time == '0.00') return 'N/A';

    // Try using CellFormatters first (expects "HH:mm:ss dd-MM-yyyy" format)
    final formatted = CellFormatters.formatTime(time);
    if (formatted.isNotEmpty) {
      // Extract just the time part (hh:mm a) from "dd MMM yyyy, hh:mm a"
      final parts = formatted.split(', ');
      if (parts.length == 2) {
        return parts[1]; // Return "hh:mm a" part
      }
      return formatted;
    }

    // Fallback: If formatDateTime failed, try parsing as simple time string (HHMMSS or HHMM)
    try {
      if (time.length >= 6) {
        // Format: "HHMMSS" to "HH:MM:SS"
        final hours = time.substring(0, 2);
        final minutes = time.substring(2, 4);
        final seconds = time.substring(4, 6);
        return '$hours:$minutes:$seconds';
      } else if (time.length >= 4) {
        // Format: "HHMM" to "HH:MM"
        final hours = time.substring(0, 2);
        final minutes = time.substring(2, 4);
        return '$hours:$minutes';
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

  // Calculate minimum column widths dynamically based on header and data
  Map<int, double> _calculateMinWidths(
      List<OrderBookModel> orders, BuildContext context) {
    // Use fixed font size for measurement (table text is not responsive, only buttons are)
    final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
    const padding = 24.0; // Padding for cell content
    const sortIconWidth = 24.0; // Extra space for sort indicator icon

    final headers = [
      'Time',
      'Instrument',
      'Product',
      'Type',
      'Side',
      'Qty',
      'Avg price',
      'LTP',
      'Price',
      'Trigger price',
      'Status',
    ];
    final minWidths = <int, double>{};

    // Calculate width for each column
    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;

      // Measure header width and add space for sort icon
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth;

      // Measure widest value in this column (sample first 5 rows for performance)
      for (final order in orders.take(5)) {
        String cellText = '';
        switch (col) {
          case 0: // Time
            cellText = _formatTime(order.norentm ?? '0.00');
            break;
          case 1: // Instrument
            // For Instrument column, measure symbol + exchange separately
            // since exchange uses smaller font
            final symbol = (order.tsym ?? '').replaceAll("-EQ", "").trim();
            final exchange = order.exch ?? '';
            final exchangeText = exchange.isNotEmpty ? ' $exchange' : '';

            // Measure symbol with normal font (fixed 14px)
            final symbolWidth = _measureTextWidth(symbol, textStyle);

            // Measure exchange with smaller font (fixed 12px, matches rendering)
            final exchangeStyle =
                const TextStyle(fontSize: 12, fontFamily: 'Geist');
            final exchangeWidth = exchangeText.isNotEmpty
                ? _measureTextWidth(exchangeText, exchangeStyle)
                : 0.0;

            // Total width = symbol + exchange + 4px gap
            final totalWidth = symbolWidth +
                exchangeWidth +
                (exchangeText.isNotEmpty ? 4.0 : 0.0);
            if (totalWidth > maxWidth) {
              maxWidth = totalWidth;
            }
            // Skip normal cellWidth calculation for Instrument - already handled above
            continue;
          case 2: // Product
            cellText = order.sPrdtAli ?? order.prd ?? '';
            break;
          case 3: // Type (Price type)
            cellText = order.prctyp ?? '';
            break;
          case 4: // Side
            cellText = order.trantype == "S" ? "SELL" : "BUY";
            break;
          case 5: // Qty
            cellText = order.qty?.toString() ?? '0';
            break;
          case 6: // Avg price
            cellText = order.avgprc ?? '0.00';
            break;
          case 7: // LTP
            cellText = CellFormatters.getValidLTP(order);
            break;
          case 8: // Price
            cellText = CellFormatters.getValidPrice(order);
            break;
          case 9: // Trigger price
            cellText = (order.trgprc != null &&
                    order.trgprc != '0' &&
                    order.trgprc != '0.00')
                ? order.trgprc!
                : '0.00';
            break;
          case 10: // Status
            cellText = CellFormatters.getStatusText(order);
            break;
        }

        final cellWidth = _measureTextWidth(cellText, textStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      // For instrument column, no need to reserve space for buttons
      // Buttons will overlay on the right side, covering only half the text
      // Text can use full width, buttons appear on hover as overlay
      // Ensure minimum width to prevent excessive truncation
      if (headers[col] == 'Instrument') {
        const minInstrumentWidth = 150.0;
        maxWidth =
            maxWidth < minInstrumentWidth ? minInstrumentWidth : maxWidth;
      }

      // Set minimum width (max of header/data + padding)
      minWidths[col] = maxWidth + padding;
    }

    return minWidths;
  }

  // Helper method to measure text width dynamically
  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  List<OrderBookModel> _getSortedOrders(List<OrderBookModel> orders) {
    if (_sortColumnIndex == null) return orders;

    final sorted = List<OrderBookModel>.from(orders);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // Time
          comparison = (a.norentm ?? '').compareTo(b.norentm ?? '');
          break;
        case 1: // Instrument
          comparison = (a.tsym ?? '').compareTo(b.tsym ?? '');
          break;
        case 2: // Product
          comparison =
              (a.sPrdtAli ?? a.prd ?? '').compareTo(b.sPrdtAli ?? b.prd ?? '');
          break;
        case 3: // Type (Price type)
          comparison = (a.prctyp ?? '').compareTo(b.prctyp ?? '');
          break;
        case 4: // Side
          comparison = (a.trantype ?? '').compareTo(b.trantype ?? '');
          break;
        case 5: // Qty
          comparison = (int.tryParse(a.qty ?? '0') ?? 0)
              .compareTo(int.tryParse(b.qty ?? '0') ?? 0);
          break;
        case 6: // Avg price
          comparison = (double.tryParse(a.avgprc ?? '0') ?? 0)
              .compareTo(double.tryParse(b.avgprc ?? '0') ?? 0);
          break;
        case 7: // LTP
          comparison = (double.tryParse(a.ltp ?? '0') ?? 0)
              .compareTo(double.tryParse(b.ltp ?? '0') ?? 0);
          break;
        case 8: // Price
          comparison = (double.tryParse(a.prc ?? '0') ?? 0)
              .compareTo(double.tryParse(b.prc ?? '0') ?? 0);
          break;
        case 9: // Trigger price
          comparison = (double.tryParse(a.trgprc ?? '0') ?? 0)
              .compareTo(double.tryParse(b.trgprc ?? '0') ?? 0);
          break;
        case 10: // Status
          comparison = (CellFormatters.getStatusText(a))
              .compareTo(CellFormatters.getStatusText(b));
          break;
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
        return SizedBox(
          height: 400,
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

    // Build data rows
    final dataRows = <shadcn.TableRow>[];
    for (var i = 0; i < sortedOrders.length; i++) {
      final order = sortedOrders[i];
      final uniqueId =
          order.norenordno?.toString() ?? order.token?.toString() ?? '';
      final colorScheme = shadcn.Theme.of(context).colorScheme;

      dataRows.add(
        shadcn.TableRow(
          cells: [
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
            // PERFORMANCE FIX: Use ValueListenableBuilder for hover-dependent UI
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 1,
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
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 2,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                order.sPrdtAli ?? order.prd ?? '',
                style: _getTextStyle(context),
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 3,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                order.prctyp ?? '',
                style: _getTextStyle(context),
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 4,
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
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 5,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                order.qty?.toString() ?? '0',
                style: _getTextStyle(context),
              ),
            ),
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 6,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                order.avgprc ?? '0.00',
                style: _getTextStyle(context),
              ),
            ),
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 7,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: _OrderLTPCell(
                token: order.token ?? '',
                initialLtp: CellFormatters.getValidLTP(order),
              ),
            ),
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 8,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                CellFormatters.getValidPrice(order),
                style: _getTextStyle(context, color: MyntColors.primary),
              ),
            ),
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 9,
              alignRight: true,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Text(
                (order.trgprc != null &&
                        order.trgprc != '0' &&
                        order.trgprc != '0.00')
                    ? order.trgprc!
                    : '0.00',
                style: _getTextStyle(context),
              ),
            ),
            buildCellWithHover(
              rowIndex: i,
              columnIndex: 10,
              onTap: () => actionHandler.openOrderDetail(order),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(CellFormatters.getStatusText(order))
                      .withOpacity(0.12),
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
          ],
        ),
      );
    }

    // Return shadcn Table with proper structure
    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: shadcn.OutlinedContainer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate minimum widths dynamically based on actual content
              final minWidths = _calculateMinWidths(sortedOrders, context);

              // Available width
              final availableWidth = constraints.maxWidth;

              // Step 1: Start with minimum widths (content-based, no wasted space)
              final columnWidths = <int, double>{};
              for (int i = 0; i < 11; i++) {
                columnWidths[i] = minWidths[i] ?? 100.0;
              }

              // Step 2: Calculate total minimum width needed
              final totalMinWidth = columnWidths.values
                  .fold<double>(0.0, (sum, width) => sum + width);

              // Step 3: If there's extra space, distribute it proportionally
              // This prevents unnecessary horizontal scroll while using available space efficiently
              if (totalMinWidth < availableWidth) {
                final extraSpace = availableWidth - totalMinWidth;

                // Define which columns can grow and their growth priorities
                // Instrument gets more growth, text columns get medium, numeric get less
                const instrumentGrowthFactor =
                    2.0; // Instrument can grow 2x more than numeric
                const textGrowthFactor = 1.2;
                const numericGrowthFactor = 1.0;

                // Calculate growth factors for each column
                final growthFactors = <int, double>{};
                double totalGrowthFactor = 0.0;

                for (int i = 0; i < 11; i++) {
                  // Column 0: Time (numeric)
                  // Column 1: Instrument
                  // Columns 2, 3, 10: Text columns (Product, Type, Status)
                  // Rest: Numeric columns
                  if (i == 1) {
                    growthFactors[i] = instrumentGrowthFactor;
                    totalGrowthFactor += instrumentGrowthFactor;
                  } else if (i == 2 || i == 3 || i == 10) {
                    growthFactors[i] = textGrowthFactor;
                    totalGrowthFactor += textGrowthFactor;
                  } else {
                    growthFactors[i] = numericGrowthFactor;
                    totalGrowthFactor += numericGrowthFactor;
                  }
                }

                // Distribute extra space proportionally
                if (totalGrowthFactor > 0) {
                  for (int i = 0; i < 11; i++) {
                    if (growthFactors[i]! > 0) {
                      final extraForThisColumn =
                          (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                      columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                    }
                  }
                }
              }

              // Calculate total required width
              final totalRequiredWidth = columnWidths.values
                  .fold<double>(0.0, (sum, width) => sum + width);

              // If total width exceeds available width, enable horizontal scrolling
              final needsHorizontalScroll = totalRequiredWidth > availableWidth;

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
                      // Fixed Header (synced with horizontal scroll)
                      shadcn.Table(
                        columnWidths: {
                          0: shadcn.FixedTableSize(columnWidths[0]!),
                          1: shadcn.FixedTableSize(columnWidths[1]!),
                          2: shadcn.FixedTableSize(columnWidths[2]!),
                          3: shadcn.FixedTableSize(columnWidths[3]!),
                          4: shadcn.FixedTableSize(columnWidths[4]!),
                          5: shadcn.FixedTableSize(columnWidths[5]!),
                          6: shadcn.FixedTableSize(columnWidths[6]!),
                          7: shadcn.FixedTableSize(columnWidths[7]!),
                          8: shadcn.FixedTableSize(columnWidths[8]!),
                          9: shadcn.FixedTableSize(columnWidths[9]!),
                          10: shadcn.FixedTableSize(columnWidths[10]!),
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: [
                          shadcn.TableHeader(
                            cells: [
                              buildHeaderCell('Time', 0),
                              buildHeaderCell('Instrument', 1),
                              buildHeaderCell('Product', 2),
                              buildHeaderCell('Type', 3),
                              buildHeaderCell('Side', 4),
                              buildHeaderCell('Qty', 5, true),
                              buildHeaderCell('Avg price', 6, true),
                              buildHeaderCell('LTP', 7, true),
                              buildHeaderCell('Price', 8, true),
                              buildHeaderCell('Trigger price', 9, true),
                              buildHeaderCell('Status', 10),
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
                              dark: Colors.grey.withOpacity(0.1),
                              light: Colors.grey.withOpacity(0.1)),
                          thumbColor: resolveThemeColor(context,
                              dark: Colors.grey.withOpacity(0.3),
                              light: Colors.grey.withOpacity(0.3)),
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
                                0: shadcn.FixedTableSize(columnWidths[0]!),
                                1: shadcn.FixedTableSize(columnWidths[1]!),
                                2: shadcn.FixedTableSize(columnWidths[2]!),
                                3: shadcn.FixedTableSize(columnWidths[3]!),
                                4: shadcn.FixedTableSize(columnWidths[4]!),
                                5: shadcn.FixedTableSize(columnWidths[5]!),
                                6: shadcn.FixedTableSize(columnWidths[6]!),
                                7: shadcn.FixedTableSize(columnWidths[7]!),
                                8: shadcn.FixedTableSize(columnWidths[8]!),
                                9: shadcn.FixedTableSize(columnWidths[9]!),
                                10: shadcn.FixedTableSize(columnWidths[10]!),
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

              // Horizontal scroll wrapper (if needed)
              if (needsHorizontalScroll) {
                return RawScrollbar(
                  controller: widget.horizontalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  trackColor: resolveThemeColor(context,
                      dark: Colors.grey.withOpacity(0.1),
                      light: Colors.grey.withOpacity(0.1)),
                  thumbColor: resolveThemeColor(context,
                      dark: Colors.grey.withOpacity(0.3),
                      light: Colors.grey.withOpacity(0.3)),
                  thickness: 6,
                  radius: const Radius.circular(3),
                  interactive: true,
                  child: SingleChildScrollView(
                    controller: widget.horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalRequiredWidth,
                      child: buildTableContent(),
                    ),
                  ),
                );
              }

              return buildTableContent();
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
                        // Exchange (12px, 500, muted color)
                        if (order.exch != null && order.exch!.isNotEmpty)
                          TextSpan(
                            text: ' ${order.exch}',
                            style: MyntWebTextStyles.para(
                              context,
                              darkColor: MyntColors.textSecondaryDark,
                              lightColor: MyntColors.textSecondary,
                              fontWeight: MyntFonts.medium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Action buttons using HoverActionsContainer
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {}, // Empty handler to stop propagation
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: HoverActionsContainer(
                  isVisible: isHovered,
                  spacing: 6.0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  actions: [
                    if (isPending) ...[
                      _buildActionButton(
                        label: 'Modify',
                        isPrimary: true,
                        isProcessing: isProcessing && _isProcessingModify,
                        onPressed: isProcessing && _isProcessingModify
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
                      _buildActionButton(
                        label: 'Cancel',
                        isPrimary: false,
                        isProcessing: isProcessing && _isProcessingCancel,
                        onPressed: isProcessing && _isProcessingCancel
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
                      _buildActionButton(
                        label: 'Repeat',
                        isPrimary: true,
                        isProcessing: false,
                        onPressed: () => actionHandler.repeatOrder(order),
                      ),
                      if (order.status == "OPEN")
                        _buildActionButton(
                          label: 'Cancel',
                          isPrimary: false,
                          isProcessing: isProcessing && _isProcessingCancel,
                          onPressed: isProcessing && _isProcessingCancel
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

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    required bool isProcessing,
    required VoidCallback? onPressed,
  }) {
    final backgroundColor = isPrimary
        ? resolveThemeColor(
            context,
            dark: MyntColors.primaryDark,
            light: MyntColors.primary,
          )
        : resolveThemeColor(
            context,
            dark: MyntColors.errorDark,
            light: MyntColors.tertiary,
          );

    return SizedBox(
      height: 26,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                label,
                style: WebTextStyles.buttonXs(
                  isDarkTheme: Theme.of(context).brightness == Brightness.dark,
                  color: Colors.white,
                  fontWeight: MyntFonts.medium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Action button widget

// LTP Cell with WebSocket updates
class _OrderLTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;

  const _OrderLTPCell({
    required this.token,
    required this.initialLtp,
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

  @override
  Widget build(BuildContext context) {
    return Text(
      ltp,
      style: MyntWebTextStyles.tableCell(
        context,
        darkColor: MyntColors.textPrimaryDark,
        lightColor: MyntColors.textPrimary,
        fontWeight: MyntFonts.medium,
      ),
    );
  }
}
