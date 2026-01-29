// import 'dart:async'; // COMMENTED OUT - not used currently
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
// import 'package:mynt_plus/provider/websocket_provider.dart'; // COMMENTED OUT - not used currently
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/hover_actions_web.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../refactored/services/order_action_handler.dart';
// import '../refactored/utils/cell_formatters.dart'; // COMMENTED OUT - not used currently

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
  ConsumerState<ExecutedOrdersScreen> createState() =>
      _ExecutedOrdersScreenState();
}

class _ExecutedOrdersScreenState extends ConsumerState<ExecutedOrdersScreen> {
  // PERFORMANCE FIX: Use ValueNotifier for hover instead of setState
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);
  int? _sortColumnIndex;
  bool _sortAscending = true;
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

  // Column definitions - 7 columns matching the image
  // Headers: Time | Type | Instrument | Product | Qty. | Avg. price | Status
  final List<String> _columns = [
    'Time',        // 0
    'Type',        // 1 - BUY/SELL (trantype)
    'Instrument',  // 2
    'Product',     // 3
    'Qty.',        // 4
    'Avg. price',  // 5
    'Status',      // 6
  ];

  // Old column definitions (commented out)
  // final List<String> _columnsOld = [
  //   'Time',
  //   'Instrument',
  //   'Product',
  //   'Type',          // prctyp - LMT/MKT etc
  //   'Side',          // BUY/SELL
  //   'Qty',
  //   'Avg price',
  //   'LTP',
  //   'Price',
  //   'Trigger price',
  //   'Status',
  // ];

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
            child: MyntLoader.centered(message: 'Loading orders...'),
          ),
        );
      } else {
        return SizedBox.expand(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: NoDataFound(
                title: searchQuery.isNotEmpty ? "No Orders Found" : "No Orders",
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
              // Calculate equal column widths for 7 columns
              final availableWidth = constraints.maxWidth;
              final columnCount = 7;
              final equalWidth = availableWidth / columnCount;

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
                      // Fixed Header
                      shadcn.Table(
                        columnWidths: {
                          0: shadcn.FixedTableSize(equalWidth),
                          1: shadcn.FixedTableSize(equalWidth),
                          2: shadcn.FixedTableSize(equalWidth),
                          3: shadcn.FixedTableSize(equalWidth),
                          4: shadcn.FixedTableSize(equalWidth),
                          5: shadcn.FixedTableSize(equalWidth),
                          6: shadcn.FixedTableSize(equalWidth),
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: [
                          shadcn.TableHeader(
                            cells: [
                              buildHeaderCell('Time', 0),
                              buildHeaderCell('Type', 1),
                              buildHeaderCell('Instrument', 2),
                              buildHeaderCell('Product', 3,true),
                              buildHeaderCell('Qty.', 4,true),
                              buildHeaderCell('Avg. price', 5,true),
                              buildHeaderCell('Status', 6,true),
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
                                0: shadcn.FixedTableSize(equalWidth),
                                1: shadcn.FixedTableSize(equalWidth),
                                2: shadcn.FixedTableSize(equalWidth),
                                3: shadcn.FixedTableSize(equalWidth),
                                4: shadcn.FixedTableSize(equalWidth),
                                5: shadcn.FixedTableSize(equalWidth),
                                6: shadcn.FixedTableSize(equalWidth),
                              },
                              defaultRowHeight: const shadcn.FixedTableSize(50),
                              rows: [
                                // Data Rows
                                ...sortedOrders.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final order = entry.value;
                                  final uniqueId =
                                      order.norenordno?.toString() ??
                                          order.token?.toString() ??
                                          '';
                                  final actionHandler = OrderActionHandler(
                                      ref: ref, context: context);

                                  return shadcn.TableRow(
                                    cells: [
                                      // Time (with seconds)
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 0,
                                        onTap: () => actionHandler
                                            .openOrderDetail(order),
                                        child: Text(
                                          _formatTime(order.norentm ?? '0.00'),
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                      // Type (BUY/SELL)
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 1,
                                        onTap: () => actionHandler
                                            .openOrderDetail(order),
                                        child: Text(
                                          order.trantype == "S"
                                              ? "SELL"
                                              : "BUY",
                                          style: _getTextStyle(
                                            context,
                                            color: order.trantype == "S"
                                                ? resolveThemeColor(context,
                                                    dark: MyntColors.lossDark,
                                                    light: MyntColors.loss)
                                                : resolveThemeColor(context,
                                                    dark: MyntColors.profitDark,
                                                    light: MyntColors.profit),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                      // Instrument with action buttons on hover
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 2,
                                        onTap: () => actionHandler
                                            .openOrderDetail(order),
                                        child: ValueListenableBuilder<int?>(
                                          valueListenable: _hoveredRowIndex,
                                          builder: (context, hoveredIndex, _) {
                                            final isRowHovered =
                                                hoveredIndex == index;
                                            return Stack(
                                              clipBehavior: Clip.hardEdge,
                                              children: [
                                                Positioned.fill(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Tooltip(
                                                      message:
                                                          '${_formatInstrumentText(order)}${order.exch != null && order.exch!.isNotEmpty ? ' ${order.exch}' : ''}',
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right:
                                                                    isRowHovered
                                                                        ? 90.0
                                                                        : 0.0),
                                                        child: RichText(
                                                          overflow: isRowHovered
                                                              ? TextOverflow
                                                                  .ellipsis
                                                              : TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    _formatInstrumentText(
                                                                        order),
                                                                style:
                                                                    _getTextStyle(
                                                                        context),
                                                              ),
                                                              if (order.exch !=
                                                                      null &&
                                                                  order.exch!
                                                                      .isNotEmpty)
                                                                TextSpan(
                                                                  text:
                                                                      ' ${order.exch}',
                                                                  style: MyntWebTextStyles
                                                                      .para(
                                                                    context,
                                                                    darkColor:
                                                                        MyntColors
                                                                            .textSecondaryDark,
                                                                    lightColor:
                                                                        MyntColors
                                                                            .textSecondary,
                                                                    fontWeight:
                                                                        MyntFonts
                                                                            .medium,
                                                                  ).copyWith(
                                                                      fontSize:
                                                                          10),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (isRowHovered)
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    bottom: 0,
                                                    child: GestureDetector(
                                                      onTap: () {},
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 12),
                                                        alignment: Alignment
                                                            .centerRight,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              shadcn.Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .background
                                                                  .withValues(
                                                                      alpha:
                                                                          0.0),
                                                              shadcn.Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .background
                                                                  .withValues(
                                                                      alpha:
                                                                          0.95),
                                                            ],
                                                          ),
                                                        ),
                                                        child:
                                                            HoverActionsContainer(
                                                          isVisible:
                                                              isRowHovered,
                                                          actions:
                                                              _buildActionButtons(
                                                            order,
                                                            uniqueId,
                                                            actionHandler,
                                                            theme,
                                                            context,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      // Product
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 3,
                                        alignRight: true,
                                        onTap: () => actionHandler
                                            .openOrderDetail(order),
                                        child: Text(
                                          order.sPrdtAli ?? order.prd ?? '',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                      // Qty.
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 4,
                                        alignRight: true,
                                        onTap: () => actionHandler
                                            .openOrderDetail(order),
                                        child: Text(
                                          _formatQty(order),
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Avg. price
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 5,
                                        alignRight: true,
                                        onTap: () => actionHandler
                                            .openOrderDetail(order),
                                        child: Text(
                                          order.avgprc ?? '0.00',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Status
                                      buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 6,
                                        alignRight: true,
                                        onTap: () => actionHandler
                                            .openOrderDetail(order),
                                        child: Tooltip(
                                          message: (order.rejreason != null &&
                                                  order.rejreason!.isNotEmpty)
                                              ? order.rejreason!
                                              : _getStatusText(order),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      _getStatusText(order),
                                                      context)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _getStatusText(order)
                                                  .toUpperCase(),
                                              style:
                                                  MyntWebTextStyles.bodySmall(
                                                context,
                                                color: _getStatusColor(
                                                    _getStatusText(order),
                                                    context),
                                                fontWeight: MyntFonts.medium,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // COMMENTED OUT COLUMNS:
                                      // // Type (Price type) - LMT/MKT etc
                                      // buildCellWithHover(
                                      //   rowIndex: index,
                                      //   columnIndex: 3,
                                      //   onTap: () => actionHandler.openOrderDetail(order),
                                      //   child: Text(
                                      //     order.prctyp ?? '',
                                      //     style: _getTextStyle(context),
                                      //     overflow: TextOverflow.visible,
                                      //     softWrap: false,
                                      //   ),
                                      // ),
                                      // // LTP
                                      // buildCellWithHover(
                                      //   rowIndex: index,
                                      //   columnIndex: 7,
                                      //   alignRight: true,
                                      //   onTap: () => actionHandler.openOrderDetail(order),
                                      //   child: _OrderBookLTPCell(
                                      //     token: order.token ?? '',
                                      //     initialLtp: _getValidLTP(order),
                                      //     order: order,
                                      //   ),
                                      // ),
                                      // // Price
                                      // buildCellWithHover(
                                      //   rowIndex: index,
                                      //   columnIndex: 8,
                                      //   alignRight: true,
                                      //   onTap: () => actionHandler.openOrderDetail(order),
                                      //   child: Text(
                                      //     _getValidPrice(order),
                                      //     style: _getTextStyle(context),
                                      //   ),
                                      // ),
                                      // // Trigger price
                                      // buildCellWithHover(
                                      //   rowIndex: index,
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
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 2; // Instrument column
    final isLastColumn = columnIndex == 6; // Status column

    // Match the cell padding logic
    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isInstrumentColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 4, 8);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(4, 8, 16, 8);
    } else {
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
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredIndex, _) {
            final isRowHovered = hoveredIndex == rowIndex;
            return GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: cellPadding,
                alignment:
                    alignRight ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: isRowHovered
                      ? resolveThemeColor(
                          context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary,
                        ).withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }

  // Builds a sortable header cell with sort indicator (matches holdings pattern)
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 2; // Instrument column
    final isLastColumn = columnIndex == 6; // Status column

    // Match the cell padding logic
    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
    } else if (isInstrumentColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 6, 4, 6);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(4, 6, 16, 6);
    } else {
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
          // decoration: BoxDecoration(
          //   color: resolveThemeColor(
          //     context,
          //     dark: Colors.white.withOpacity(0.04),
          //     light: Colors.black.withOpacity(0.03),
          //   ),
          // ),
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

  List<Widget> _buildActionButtons(
    OrderBookModel order,
    String uniqueId,
    OrderActionHandler actionHandler,
    ThemesProvider theme,
    BuildContext context,
  ) {
    final isProcessing = _processingOrderToken == uniqueId;
    final isPending = order.status == "PENDING" ||
        order.status == "OPEN" ||
        order.status == "TRIGGER_PENDING";

    if (isPending) {
      return [
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
        ),
      ];
    } else {
      return [
        HoverActionButton(
          label: 'Repeat',
          size: 54,
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
            size: 54,
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
          ),
      ];
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
        case 1: // Type (BUY/SELL)
          comparison = (a.trantype ?? '').compareTo(b.trantype ?? '');
          break;
        case 2: // Instrument
          comparison =
              (_formatInstrumentText(a)).compareTo(_formatInstrumentText(b));
          break;
        case 3: // Product
          comparison =
              (a.sPrdtAli ?? a.prd ?? '').compareTo(b.sPrdtAli ?? b.prd ?? '');
          break;
        case 4: // Qty
          comparison = (int.tryParse(a.qty ?? '0') ?? 0)
              .compareTo(int.tryParse(b.qty ?? '0') ?? 0);
          break;
        case 5: // Avg price
          comparison = (double.tryParse(a.avgprc ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.avgprc ?? '0') ?? 0.0);
          break;
        case 6: // Status
          comparison = (a.status ?? '').compareTo(b.status ?? '');
          break;
        // COMMENTED OUT - Old column sorting
        // case 7: // LTP
        //   comparison = (double.tryParse(a.ltp ?? '0') ?? 0.0)
        //       .compareTo(double.tryParse(b.ltp ?? '0') ?? 0.0);
        //   break;
        // case 8: // Price
        //   final priceA = double.tryParse(a.prc ?? '0') ?? 0.0;
        //   final priceB = double.tryParse(b.prc ?? '0') ?? 0.0;
        //   comparison = priceA.compareTo(priceB);
        //   break;
        // case 9: // Trigger price
        //   final triggerA = double.tryParse(a.trgprc ?? '0') ?? 0.0;
        //   final triggerB = double.tryParse(b.trgprc ?? '0') ?? 0.0;
        //   comparison = triggerA.compareTo(triggerB);
        //   break;
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

  // Format Qty as "filledQty / totalQty" like in image (0/1)
  String _formatQty(OrderBookModel order) {
    final filledQty = order.fillshares ?? '0';
    final totalQty = order.qty ?? '0';
    return '$filledQty / $totalQty';
  }

  // COMMENTED OUT - Kept for reference
  // String _getValidLTP(OrderBookModel order) {
  //   if (order.ltp != null && order.ltp != '0' && order.ltp != '0.00') {
  //     return order.ltp!;
  //   }
  //   return '0.00';
  // }

  // COMMENTED OUT - Kept for reference
  // String _getValidPrice(OrderBookModel order) {
  //   if (order.prc != null && order.prc != '0' && order.prc != '0.00') {
  //     return order.prc!;
  //   }
  //   return '0.00';
  // }

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

  // Format time with seconds (e.g., "11:18:07")
  String _formatTime(String time) {
    if (time.isEmpty || time == '0.00') return 'N/A';

    // Try parsing "HH:mm:ss dd-MM-yyyy" format (API format) with seconds
    try {
      if (time.contains(':') && time.contains('-')) {
        // Format: "HH:mm:ss dd-MM-yyyy"
        final timePart = time.split(' ')[0]; // Get "HH:mm:ss"
        return timePart; // Return time with seconds as-is
      }
    } catch (e) {
      // Continue to fallback
    }

    // Fallback: Try parsing as simple time string (HHMMSS or HHMM)
    try {
      if (time.length >= 6 && !time.contains(':')) {
        // Format: "HHMMSS" to "HH:MM:SS"
        final hours = time.substring(0, 2);
        final minutes = time.substring(2, 4);
        final seconds = time.substring(4, 6);
        return '$hours:$minutes:$seconds';
      } else if (time.length >= 4 && !time.contains(':')) {
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

  Color _getStatusColor(String statusText, BuildContext context) {
    switch (statusText.toUpperCase()) {
      case 'EXECUTED':
      case 'COMPLETE':
        return resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);
      case 'REJECTED':
      case 'CANCELLED':
      case 'CANCELED':
        return resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
      case 'OPEN':
      case 'PENDING':
      case 'TRIGGER PENDING':
        return resolveThemeColor(context,
            dark: MyntColors.warning, light: MyntColors.warning);
      default:
        return resolveThemeColor(context,
            dark: MyntColors.textSecondaryDark,
            light: MyntColors.textSecondary);
    }
  }
}

// Live LTP cell widget - COMMENTED OUT (not used in current view)
// class _OrderBookLTPCell extends ConsumerStatefulWidget {
//   final String token;
//   final String initialLtp;
//   final OrderBookModel order;

//   const _OrderBookLTPCell({
//     required this.token,
//     required this.initialLtp,
//     required this.order,
//   });

//   @override
//   ConsumerState<_OrderBookLTPCell> createState() => _OrderBookLTPCellState();
// }

// class _OrderBookLTPCellState extends ConsumerState<_OrderBookLTPCell> {
//   late String ltp;
//   StreamSubscription? _subscription;

//   @override
//   void initState() {
//     super.initState();
//     ltp = widget.initialLtp;

//     if (widget.token.isNotEmpty) {
//       _subscription =
//           ref.read(websocketProvider).socketDataStream.listen((data) {
//         if (!mounted || !data.containsKey(widget.token)) return;

//         final newLtp = data[widget.token]['lp']?.toString();
//         if (newLtp != null &&
//             newLtp != ltp &&
//             newLtp != '0.00' &&
//             newLtp != 'null') {
//           setState(() => ltp = newLtp);
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       ltp,
//       style: MyntWebTextStyles.tableCell(
//         context,
//         darkColor: MyntColors.textPrimaryDark,
//         lightColor: MyntColors.textPrimary,
//         fontWeight: MyntFonts.medium,
//       ),
//     );
//   }
// }
