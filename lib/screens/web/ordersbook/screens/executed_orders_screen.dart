import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/common_buttons_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../refactored/services/order_action_handler.dart';
import '../refactored/utils/cell_formatters.dart';

/// Separate screen widget for Executed Orders tab
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
  int? _hoveredRowIndex;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingOrderToken;
  Offset _modifyDialogPosition = const Offset(100, 100);

  // Helper method to get appropriate text style from MyntWebTextStyles
  TextStyle _getTextStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
    );
  }

  // Helper method for header text style
  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
    );
  }

  // Column definitions
  final List<String> _columns = [
    'Time',
    'Instrument',
    'Product/Type',
    'Type',
    'Qty',
    'Avg price',
    'LTP',
    'Price',
    'Trigger price',
    'Order value',
    'Status',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final orderBook = ref.watch(orderProvider);
    
    // Get executed orders (search or regular)
    // Only show search results if we're on the Executed Orders tab (index 1)
    final searchQuery = orderBook.orderSearchCtrl.text.trim();
    final isExecutedOrdersTab = orderBook.selectedTab == 1;
    final orders = (searchQuery.isNotEmpty && isExecutedOrdersTab)
        ? (orderBook.orderSearchItem ?? [])
        : (orderBook.executedOrder ?? []);

    // Show loading or empty state
    if (orders.isEmpty) {
      if (orderBook.loading) {
        return SizedBox.expand(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Loading orders...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      } else {
        return SizedBox.expand(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: NoDataFound(
                title: searchQuery.isNotEmpty 
                    ? "No Orders Found" 
                    : "No Orders",
                subtitle: searchQuery.isNotEmpty
                    ? "No executed orders match your search \"$searchQuery\"."
                    : "You don't have any executed orders yet.",
                primaryEnabled: false,
                secondaryEnabled: false,
              ),
            ),
          ),
        );
      }
    }

    // Sort orders
    final sortedOrders = _getSortedOrders(orders);

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
          final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
          
          // Step 3: If there's extra space, distribute it proportionally
          // This prevents unnecessary horizontal scroll while using available space efficiently
          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;
            
            // Define which columns can grow and their growth priorities
            // Instrument gets more growth, text columns get medium, numeric get less
            const instrumentGrowthFactor = 2.0; // Instrument can grow 2x more than numeric
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
                  final extraForThisColumn = (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                  columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                }
              }
            }
          }

          // Calculate total required width
          final totalRequiredWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
          
          // If total width exceeds available width, enable horizontal scrolling
          final needsHorizontalScroll = totalRequiredWidth > availableWidth;

          // Build table content
          Widget buildTableContent() {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: constraints.maxHeight.isFinite && constraints.maxHeight > 0
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
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Time', 0),
                        buildHeaderCell('Instrument', 1),
                        buildHeaderCell('Product/Type', 2),
                        buildHeaderCell('Type', 3),
                        buildHeaderCell('Qty', 4, true),
                        buildHeaderCell('Avg price', 5, true),
                        buildHeaderCell('LTP', 6, true),
                        buildHeaderCell('Price', 7, true),
                        buildHeaderCell('Trigger price', 8, true),
                        buildHeaderCell('Order value', 9, true),
                        buildHeaderCell('Status', 10),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body (vertical scroll)
                Expanded(
                  child: Scrollbar(
                    controller: widget.verticalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: widget.verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: shadcn.Table(
                        key: ValueKey('table_${_sortColumnIndex}_$_sortAscending'),
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
                        defaultRowHeight: const shadcn.FixedTableSize(40),
                        rows: [
                          // Data Rows
                          ...sortedOrders.asMap().entries.map((entry) {
                            final index = entry.key;
                            final order = entry.value;
                            final uniqueId = order.norenordno?.toString() ?? order.token?.toString() ?? '';
                            final isRowHovered = _hoveredRowIndex == index;
                            final actionHandler = OrderActionHandler(ref: ref, context: context);

                            return shadcn.TableRow(
                              cells: [
                                // Time - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 0,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _formatTime(order.norentm ?? '0.00'),
                                        style: _getTextStyle(context),
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ),
                                // Instrument with action buttons on hover - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 1,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Stack(
                                        clipBehavior: Clip.hardEdge,
                                        children: [
                                          // Instrument name - full width, can be partially covered by buttons
                                          // Only truncate when hovered (buttons visible), otherwise show full text
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Tooltip(
                                              message: '${_formatInstrumentText(order)}${order.exch != null && order.exch!.isNotEmpty ? ' ${order.exch}' : ''}',
                                              child: Padding(
                                                padding: EdgeInsets.only(right: isRowHovered ? 8.0 : 0.0),
                                                child: RichText(
                                                  overflow: isRowHovered ? TextOverflow.ellipsis : TextOverflow.visible,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  text: TextSpan(
                                                    children: [
                                                      // Symbol (normal color)
                                                      TextSpan(
                                                        text: _formatInstrumentText(order),
                                                        style: MyntWebTextStyles.body(
                                                          context,
                                                          color: shadcn.Theme.of(context).colorScheme.foreground,
                                                        ),
                                                      ),
                                                      // Exchange (mutedForeground color, smaller font)
                                                      if (order.exch != null && order.exch!.isNotEmpty)
                                                        TextSpan(
                                                          text: ' ${order.exch}',
                                                          style: MyntWebTextStyles.para(
                                                            context,
                                                            color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Action buttons - overlay on the right side, covering only half the text
                                          // Use Visibility to ensure buttons don't take space when not hovered
                                          Visibility(
                                            visible: isRowHovered,
                                            maintainSize: false,
                                            maintainAnimation: false,
                                            maintainState: false,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  // Responsive max width based on screen size
                                                  final screenWidth = MediaQuery.of(context).size.width;
                                                  final isSmallScreen = screenWidth < 768;
                                                  final isVerySmallScreen = screenWidth < 480;
                                                  final responsiveMaxWidth = isVerySmallScreen ? 120.0 : (isSmallScreen ? 160.0 : 200.0);
                                                  
                                                  // Use available width, but cap at responsive max to prevent overflow
                                                  final maxButtonWidth = constraints.maxWidth.clamp(0.0, responsiveMaxWidth);
                                                  return GestureDetector(
                                                    onTap: () {}, // Empty handler to stop propagation
                                                    behavior: HitTestBehavior.opaque,
                                                    child: AnimatedOpacity(
                                                      opacity: isRowHovered ? 1 : 0,
                                                      duration: const Duration(milliseconds: 140),
                                                      child: Container(
                                                        constraints: BoxConstraints(maxWidth: maxButtonWidth),
                                                        decoration: BoxDecoration(
                                                          // Subtle background gradient for better button visibility
                                                          gradient: LinearGradient(
                                                            begin: Alignment.centerLeft,
                                                            end: Alignment.centerRight,
                                                            colors: [
                                                              shadcn.Theme.of(context).colorScheme.background.withOpacity(0.0),
                                                              shadcn.Theme.of(context).colorScheme.background.withOpacity(0.95),
                                                            ],
                                                          ),
                                                        ),
                                                        padding: const EdgeInsets.only(left: 8),
                                                        child: Builder(
                                                          builder: (buttonContext) {
                                                            final screenWidth = MediaQuery.of(buttonContext).size.width;
                                                            final isSmallScreen = screenWidth < 768;
                                                            final buttonSpacing = isSmallScreen ? 4.0 : 6.0;
                                                            
                                                            return Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                ..._buildActionButtons(order, uniqueId, isRowHovered, actionHandler, theme, buttonContext, buttonSpacing),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Product - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 2,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _formatProductType(order),
                                        style: _getTextStyle(context),
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ),
                                // Type - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 3,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        order.trantype == "S" ? "SELL" : "BUY",
                                        style: _getTextStyle(
                                          context,
                                          color: order.trantype == "S"
                                              ? shadcn.Theme.of(context).colorScheme.destructive
                                              : shadcn.Theme.of(context).colorScheme.chart2,
                                        ),
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ),
                                // Qty - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 4,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        order.qty?.toString() ?? '0',
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                  ),
                                ),
                                // Avg price - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 5,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        order.avgprc ?? '0.00',
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                  ),
                                ),
                                // LTP - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 6,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _OrderBookLTPCell(
                                        token: order.token ?? '',
                                        initialLtp: _getValidLTP(order),
                                        order: order,
                                      ),
                                    ),
                                  ),
                                ),
                                // Price - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 7,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _getValidPrice(order),
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                  ),
                                ),
                                // Trigger price - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 8,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        (order.trgprc != null && order.trgprc != '0' && order.trgprc != '0.00')
                                            ? order.trgprc!
                                            : '0.00',
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                  ),
                                ),
                                // Order value - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 9,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _calculateOrderValue(order),
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                  ),
                                ),
                                // Status - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 10,
                                  child: GestureDetector(
                                    onTap: () => actionHandler.openOrderDetail(order),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _getStatusText(order),
                                        style: _getTextStyle(
                                          context,
                                          color: _getStatusColor(_getStatusText(order), context),
                                        ),
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
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
            return Scrollbar(
              controller: widget.horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
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

  // Builds a cell with hover detection (matches holdings pattern)
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
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
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowIndex = rowIndex),
        onExit: (_) => setState(() => _hoveredRowIndex = null),
        child: Container(
          padding: cellPadding,
          alignment: alignRight ? Alignment.topRight : null,
          child: child,
        ),
      ),
    );
  }

  // Builds a sortable header cell with sort indicator (matches holdings pattern)
  shadcn.TableCell buildHeaderCell(String label, int columnIndex, [bool alignRight = false]) {
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
          padding: headerPadding,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              if (alignRight && _sortColumnIndex == columnIndex) const SizedBox(width: 4),
              Text(
                label,
                style: _getHeaderStyle(context),
              ),
              if (!alignRight && _sortColumnIndex == columnIndex) const SizedBox(width: 4),
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

  // Calculate minimum column widths dynamically based on header and data
  Map<int, double> _calculateMinWidths(List<OrderBookModel> orders, BuildContext context) {
    // Use fixed font size for measurement (table text is not responsive, only buttons are)
    final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
    const padding = 24.0; // Padding for cell content
    const sortIconWidth = 24.0; // Extra space for sort indicator icon

    final headers = _columns;
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
            final symbol = _formatInstrumentText(order);
            final exchange = order.exch ?? '';
            final exchangeText = exchange.isNotEmpty ? ' $exchange' : '';
            
            // Measure symbol with normal font
            final symbolWidth = _measureTextWidth(symbol, textStyle);
            
            // Measure exchange with smaller font (fixed 12px, matches rendering)
            final exchangeStyle = const TextStyle(fontSize: 12, fontFamily: 'Geist');
            final exchangeWidth = exchangeText.isNotEmpty 
                ? _measureTextWidth(exchangeText, exchangeStyle) 
                : 0.0;
            
            // Total width = symbol + exchange + 4px gap
            final totalWidth = symbolWidth + exchangeWidth + (exchangeText.isNotEmpty ? 4.0 : 0.0);
            if (totalWidth > maxWidth) {
              maxWidth = totalWidth;
            }
            // Skip normal cellWidth calculation for Instrument - already handled above
            continue;
          case 2: // Product
            cellText = _formatProductType(order);
            break;
          case 3: // Type
            cellText = order.trantype == "S" ? "SELL" : "BUY";
            break;
          case 4: // Qty
            cellText = order.qty?.toString() ?? '0';
            break;
          case 5: // Avg price
            cellText = order.avgprc ?? '0.00';
            break;
          case 6: // LTP
            cellText = _getValidLTP(order);
            break;
          case 7: // Price
            cellText = _getValidPrice(order);
            break;
          case 8: // Trigger price
            cellText = (order.trgprc != null && order.trgprc != '0' && order.trgprc != '0.00')
                ? order.trgprc!
                : '0.00';
            break;
          case 9: // Order value
            cellText = _calculateOrderValue(order);
            break;
          case 10: // Status
            cellText = _getStatusText(order);
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
      if (col == 1) {
        const minInstrumentWidth = 150.0;
        maxWidth = maxWidth < minInstrumentWidth ? minInstrumentWidth : maxWidth;
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

  List<Widget> _buildActionButtons(
    OrderBookModel order,
    String uniqueId,
    bool isRowHovered,
    OrderActionHandler actionHandler,
    ThemesProvider theme,
    BuildContext context,
    double buttonSpacing,
  ) {
    final isProcessing = _processingOrderToken == uniqueId;
    final isPending = order.status == "PENDING" ||
        order.status == "OPEN" ||
        order.status == "TRIGGER_PENDING";

    if (isPending) {
      return [
        _buildHoverButton(
          label: 'Cancel',
          backgroundColor: MyntColors.tertiary,
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
                        if (!processing) _processingOrderToken = null;
                      });
                    },
                  );
                },
          context: context,
        ),
        SizedBox(width: buttonSpacing),
        _buildHoverButton(
          label: 'Modify',
          backgroundColor: resolveThemeColor(
            context,
            dark: MyntColors.primaryDark,
            light: MyntColors.primary,
          ),
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
                        if (!processing) _processingOrderToken = null;
                      });
                    },
                    modifyDialogPosition: _modifyDialogPosition,
                    onPositionChanged: (pos) {
                      _modifyDialogPosition = pos;
                    },
                  );
                },
          context: context,
        ),
      ];
    } else {
      return [
        _buildHoverButton(
          label: 'Repeat',
          backgroundColor: resolveThemeColor(
            context,
            dark: MyntColors.primaryDark,
            light: MyntColors.primary,
          ),
          onPressed: () => actionHandler.repeatOrder(order),
          context: context,
        ),
        if (order.status == "OPEN") ...[
          SizedBox(width: buttonSpacing),
          _buildHoverButton(
            label: 'Cancel',
            backgroundColor: resolveThemeColor(
              context,
              dark: MyntColors.lossDark,
              light: MyntColors.loss,
            ),
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
                          if (!processing) _processingOrderToken = null;
                        });
                      },
                    );
                  },
            context: context,
          ),
        ],
      ];
    }
  }

  Widget _buildHoverButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    required BuildContext context,
  }) {
    // Detect screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768;
    final buttonSize = isSmallScreen ? MyntButtonSize.small : MyntButtonSize.small;

    // Determine button type based on color
    final isTertiary = backgroundColor == MyntColors.tertiary ||
        backgroundColor == MyntColors.lossDark ||
        backgroundColor == MyntColors.loss;

    if (isTertiary) {
      return MyntTertiaryButton(
        label: label,
        onPressed: onPressed,
        size: buttonSize,
      );
    } else {
      return MyntPrimaryButton(
        label: label,
        onPressed: onPressed,
        size: buttonSize,
      );
    }
  }

  List<OrderBookModel> _getSortedOrders(List<OrderBookModel> orders) {
    if (_sortColumnIndex == null) return orders;

    final sorted = List<OrderBookModel>.from(orders);
    
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex!) {
        case 0: // Time
          comparison = (a.norentm ?? '').compareTo(b.norentm ?? '');
          break;
        case 1: // Instrument
          comparison = (_formatInstrumentText(a)).compareTo(_formatInstrumentText(b));
          break;
        case 2: // Product
          comparison = _formatProductType(a).compareTo(_formatProductType(b));
          break;
        case 3: // Type
          comparison = (a.trantype ?? '').compareTo(b.trantype ?? '');
          break;
        case 4: // Qty
          comparison = (int.tryParse(a.qty ?? '0') ?? 0).compareTo(int.tryParse(b.qty ?? '0') ?? 0);
          break;
        case 5: // Avg price
          comparison = (double.tryParse(a.avgprc ?? '0') ?? 0.0).compareTo(double.tryParse(b.avgprc ?? '0') ?? 0.0);
          break;
        case 6: // LTP
          comparison = (double.tryParse(a.ltp ?? '0') ?? 0.0).compareTo(double.tryParse(b.ltp ?? '0') ?? 0.0);
          break;
        case 7: // Price
          final priceA = double.tryParse(a.prc ?? '0') ?? 0.0;
          final priceB = double.tryParse(b.prc ?? '0') ?? 0.0;
          comparison = priceA.compareTo(priceB);
          break;
        case 8: // Trigger price
          final triggerA = double.tryParse(a.trgprc ?? '0') ?? 0.0;
          final triggerB = double.tryParse(b.trgprc ?? '0') ?? 0.0;
          comparison = triggerA.compareTo(triggerB);
          break;
        case 9: // Order value
          final valueA = _calculateOrderValueDouble(a);
          final valueB = _calculateOrderValueDouble(b);
          comparison = valueA.compareTo(valueB);
          break;
        case 10: // Status
          comparison = (a.status ?? '').compareTo(b.status ?? '');
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  String _formatInstrumentText(OrderBookModel order) {
    if (order.tsym != null && order.tsym!.isNotEmpty) {
      // Remove "-EQ" suffix and don't include exchange
      return order.tsym!.replaceAll("-EQ", "").trim();
    } else if (order.dname != null && order.dname!.isNotEmpty) {
      return order.dname!.replaceAll("-EQ", "").trim();
    }
    return 'N/A';
  }

  String _formatProductType(OrderBookModel order) {
    final product = order.sPrdtAli ?? order.prd ?? '';
    final priceType = order.prctyp ?? '';
    
    if (product.isEmpty && priceType.isEmpty) {
      return 'N/A';
    } else if (product.isEmpty) {
      return priceType;
    } else if (priceType.isEmpty) {
      return product;
    } else {
      return '$product / $priceType';
    }
  }

  String _getValidLTP(OrderBookModel order) {
    if (order.ltp != null && order.ltp != '0' && order.ltp != '0.00') {
      return order.ltp!;
    }
    return '0.00';
  }

  String _getValidPrice(OrderBookModel order) {
    if (order.prc != null && order.prc != '0' && order.prc != '0.00') {
      return order.prc!;
    }
    return '0.00';
  }

  String _calculateOrderValue(OrderBookModel order) {
    final qty = int.tryParse(order.qty ?? '0') ?? 0;
    final avgPrice = double.tryParse(order.avgprc ?? '0') ?? 0.0;
    final value = qty * avgPrice;
    return value.toStringAsFixed(2);
  }

  double _calculateOrderValueDouble(OrderBookModel order) {
    final qty = int.tryParse(order.qty ?? '0') ?? 0;
    final avgPrice = double.tryParse(order.avgprc ?? '0') ?? 0.0;
    return qty * avgPrice;
  }

  String _getStatusText(OrderBookModel order) {
    if (order.status == null) return 'N/A';
    
    final status = order.status!.toUpperCase();
    if (status == 'COMPLETE') return 'Executed';
    if (status == 'REJECTED') return 'Rejected';
    if (status == 'CANCELED' || status == 'CANCELLED') return 'Cancelled';
    if (status == 'OPEN') return 'Open';
    if (status == 'PENDING') return 'Pending';
    if (status == 'TRIGGER_PENDING') return 'Trigger Pending';
    
    return order.status!;
  }

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

  Color _getStatusColor(String statusText, BuildContext context) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    
    switch (statusText.toUpperCase()) {
      case 'EXECUTED':
      case 'COMPLETE':
        return colorScheme.chart2;
      case 'REJECTED':
      case 'CANCELLED':
      case 'CANCELED':
        return colorScheme.destructive;
      case 'OPEN':
      case 'PENDING':
      case 'TRIGGER PENDING':
        return colorScheme.chart1;
      default:
        return colorScheme.mutedForeground;
    }
  }

}

// Live LTP cell widget
class _OrderBookLTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;
  final OrderBookModel order;

  const _OrderBookLTPCell({
    required this.token,
    required this.initialLtp,
    required this.order,
  });

  @override
  ConsumerState<_OrderBookLTPCell> createState() => _OrderBookLTPCellState();
}

class _OrderBookLTPCellState extends ConsumerState<_OrderBookLTPCell> {
  late String ltp;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialLtp;

    if (widget.token.isNotEmpty) {
      _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
        if (!mounted || !data.containsKey(widget.token)) return;

        final newLtp = data[widget.token]['lp']?.toString();
        if (newLtp != null && newLtp != ltp && newLtp != '0.00' && newLtp != 'null') {
          setState(() => ltp = newLtp);
        }
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
      style: MyntWebTextStyles.tableCell(context),
    );
  }
}
