import 'dart:async';
import 'package:flutter/material.dart'
    show
        InkWell,
        Icons,
        VoidCallback,
        Icon,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        GestureDetector,
        HitTestBehavior,
        Row,
        SizedBox,
        Colors,
        Widget,
        BuildContext,
        Color,
        EdgeInsets,
        Alignment,
        MainAxisAlignment,
        TextOverflow,
        Axis,
        Container,
        MouseRegion,
        Expanded,
        Align,
        Text,
        ScrollController,
        SingleChildScrollView,
        Column,
        ValueKey,
        Padding,
        LayoutBuilder,
        CircularProgressIndicator,
        Center,
        BorderRadius,
        BoxDecoration,
        MainAxisSize,
        Dialog,
        Material,
        Navigator,
        TextButton,
        showDialog,
        RoundedRectangleBorder,
        TextAlign,
        Stack,
        LinearGradient,
        Clip,
        Tooltip,
        RichText,
        Positioned,
        BoxShadow,
        Offset,
        FontWeight,
        Radius,
        RawScrollbar,
        MediaQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn
    hide Colors, Tooltip;
import 'package:mynt_plus/models/order_book_model/gtt_order_book.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/utils/responsive_snackbar.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../refactored/utils/cell_formatters.dart';
import '../gtt_order_book_detail_screen_web.dart';
import '../modify_gtt_web.dart';

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
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int? _hoveredRowIndex;
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingOrderToken;

  // Scroll controllers - must be in state to persist across rebuilds
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final orderBook = ref
        .watch(orderProvider); // Changed to watch to rebuild on search changes

    // Get GTT orders (search or regular)
    // Only show search results if we're on the GTT Orders tab (index 3)
    final searchQuery = orderBook.orderSearchCtrl.text.trim();
    final isGttOrdersTab = orderBook.selectedTab == 3;
    final gttOrders = (searchQuery.isNotEmpty && isGttOrdersTab)
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
                Text('Loading GTT orders...',
                    style: TextStyle(color: Colors.grey)),
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
                title: searchQuery.isNotEmpty
                    ? "No GTT Orders Found"
                    : "No GTT Orders",
                subtitle: searchQuery.isNotEmpty
                    ? "No GTT orders match your search \"$searchQuery\"."
                    : "You don't have any GTT orders yet.",
                primaryEnabled: false,
                secondaryEnabled: false,
              ),
            ),
          ),
        );
      }
    }

    // Sort GTT orders
    final sortedOrders = _getSortedGttOrders(gttOrders);

    return shadcn.OutlinedContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(sortedOrders, context);

          // Available width
          final availableWidth = constraints.maxWidth;

          // Step 1: Start with minimum widths (content-based, no wasted space)
          final columnWidths = <int, double>{};
          for (int i = 0; i < 8; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          // Step 2: Calculate total minimum width needed
          final totalMinWidth = columnWidths.values
              .fold<double>(0.0, (sum, width) => sum + width);

          // Step 3: If there's extra space, distribute it proportionally
          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;

            const instrumentGrowthFactor =
                2.0; // Instrument can grow 2x more than numeric
            const textGrowthFactor = 1.2;
            const numericGrowthFactor = 1.0;

            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 8; i++) {
              if (i == 0) {
                // Instrument
                growthFactors[i] = instrumentGrowthFactor;
                totalGrowthFactor += instrumentGrowthFactor;
              } else if (i == 1 || i == 2 || i == 3 || i == 7) {
                // Product, Type, Side, Status
                growthFactors[i] = textGrowthFactor;
                totalGrowthFactor += textGrowthFactor;
              } else {
                // Qty, LTP, Trigger
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 8; i++) {
                if (growthFactors[i]! > 0) {
                  final extraForThisColumn =
                      (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                  columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                }
              }
            }
          }

          final totalRequiredWidth = columnWidths.values
              .fold<double>(0.0, (sum, width) => sum + width);
          final needsHorizontalScroll = totalRequiredWidth > availableWidth;

          Widget buildTableContent() {
            return Column(
              children: [
                // Fixed Header
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
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(50),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Instrument', 0),
                        buildHeaderCell('Product', 1),
                        buildHeaderCell('Type', 2),
                        buildHeaderCell('Side', 3),
                        buildHeaderCell('Qty', 4, true),
                        buildHeaderCell('LTP', 5, true),
                        buildHeaderCell('Trigger', 6, true),
                        buildHeaderCell('Status', 7),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body
                Expanded(
                  child: RawScrollbar(
                    controller: _verticalScrollController,
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
                      controller: _verticalScrollController,
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
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: sortedOrders.asMap().entries.map((entry) {
                          final index = entry.key;
                          final gttOrder = entry.value;
                          final isRowHovered = _hoveredRowIndex == index;

                          return shadcn.TableRow(
                            cells: [
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 0,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: _buildInstrumentCell(
                                    gttOrder, theme, isRowHovered),
                              ),
                              // Product
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 1,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: Text(
                                  gttOrder.placeOrderParams?.sPrdtAli ??
                                      gttOrder.prd ??
                                      '',
                                  style: _getTextStyle(context),
                                ),
                              ),
                              // Type (Price Type)
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 2,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: Text(
                                  gttOrder.prctyp ?? '',
                                  style: _getTextStyle(context),
                                ),
                              ),
                              // Side
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 3,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: Text(
                                  gttOrder.trantype == "B" ? "BUY" : "SELL",
                                  style: _getTextStyle(
                                    context,
                                    color: gttOrder.trantype == "B"
                                        ? resolveThemeColor(context,
                                            dark: MyntColors.profitDark,
                                            light: MyntColors.profit)
                                        : resolveThemeColor(context,
                                            dark: MyntColors.lossDark,
                                            light: MyntColors.loss),
                                  ),
                                ),
                              ),
                              // Qty
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 4,
                                alignRight: true,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: Text(
                                  (gttOrder.qty ?? 0).toString(),
                                  style: _getTextStyle(context),
                                ),
                              ),
                              // LTP
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 5,
                                alignRight: true,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: _buildLTPCell(gttOrder, theme),
                              ),
                              // Trigger
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 6,
                                alignRight: true,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: Text(
                                  gttOrder.d ?? '0.00',
                                  style: _getTextStyle(context),
                                ),
                              ),
                              // Status
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 7,
                                onTap: () => _showGttOrderDetail(gttOrder),
                                child: _buildStatusCell(gttOrder, theme),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (needsHorizontalScroll) {
            return RawScrollbar(
              controller: _horizontalScrollController,
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
                controller: _horizontalScrollController,
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
    );
  }

  // Builds a cell with hover detection
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0; // Instrument column
    final isLastColumn =
        columnIndex == 7; // Status column (updated for 8 columns)

    // Match the cell padding logic
    EdgeInsets cellPadding;
    if (isFirstColumn) {
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
        onEnter: (_) => setState(() => _hoveredRowIndex = rowIndex),
        onExit: (_) => setState(() => _hoveredRowIndex = null),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: cellPadding,
            alignment:
                alignRight ? Alignment.centerRight : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: _hoveredRowIndex == rowIndex
                  ? resolveThemeColor(
                      context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary,
                    ).withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // Builds a sortable header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0; // Instrument column
    final isLastColumn =
        columnIndex == 7; // Status column (updated for 8 columns)

    // Match the cell padding logic - Instrument column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets headerPadding;
    if (isFirstColumn) {
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

  // Calculate minimum column widths dynamically
  Map<int, double> _calculateMinWidths(
      List<GttOrderBookModel> gttOrders, BuildContext context) {
    // Use fixed font size for measurement (table text is not responsive, only buttons are)
    final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'Instrument',
      'Product',
      'Type',
      'Side',
      'Qty',
      'LTP',
      'Trigger',
      'Status',
    ];
    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth;

      for (final order in gttOrders.take(5)) {
        String cellText = '';
        switch (col) {
          case 0:
            final symbol = (order.tsym ?? '').replaceAll("-EQ", "").trim();
            final exchange = order.exch ?? '';
            final exchangeText = exchange.isNotEmpty ? ' $exchange' : '';
            final symbolWidth = _measureTextWidth(symbol, textStyle);
            final exchangeStyle =
                const TextStyle(fontSize: 12, fontFamily: 'Geist');
            final exchangeWidth = exchangeText.isNotEmpty
                ? _measureTextWidth(exchangeText, exchangeStyle)
                : 0.0;
            final totalWidth = symbolWidth +
                exchangeWidth +
                (exchangeText.isNotEmpty ? 4.0 : 0.0);
            if (totalWidth > maxWidth) {
              maxWidth = totalWidth;
            }
            continue;
          case 1:
            cellText = order.placeOrderParams?.sPrdtAli ?? order.prd ?? '';
            break;
          case 2:
            cellText = order.prctyp ?? '';
            break;
          case 3:
            cellText = order.trantype == "B" ? "BUY" : "SELL";
            break;
          case 4:
            cellText = (order.qty ?? 0).toString();
            break;
          case 5:
            cellText = CellFormatters.getValidLTPForGtt(order);
            break;
          case 6:
            cellText = order.d ?? '0.00';
            break;
          case 7:
            cellText = CellFormatters.getGttStatusText(
                order.gttOrderCurrentStatus?.toUpperCase() ?? '');
            break;
        }

        final cellWidth = _measureTextWidth(cellText, textStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      // For instrument column, ensure minimum width to prevent excessive truncation
      if (headers[col] == 'Instrument') {
        const minInstrumentWidth = 150.0;
        maxWidth =
            maxWidth < minInstrumentWidth ? minInstrumentWidth : maxWidth;
      }

      minWidths[col] = maxWidth + padding;
    }

    return minWidths;
  }

  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  List<GttOrderBookModel> _getSortedGttOrders(List<GttOrderBookModel> orders) {
    if (_sortColumnIndex == null) return orders;

    final sorted = List<GttOrderBookModel>.from(orders);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex!) {
        case 0: // Instrument - compare symbol first, then exchange
          final aSymbol = (a.tsym ?? '').replaceAll("-EQ", "").trim();
          final bSymbol = (b.tsym ?? '').replaceAll("-EQ", "").trim();
          comparison = aSymbol.compareTo(bSymbol);
          if (comparison == 0) {
            comparison = (a.exch ?? '').compareTo(b.exch ?? '');
          }
          break;
        case 1: // Product
          comparison = (a.placeOrderParams?.sPrdtAli ?? a.prd ?? '')
              .compareTo(b.placeOrderParams?.sPrdtAli ?? b.prd ?? '');
          break;
        case 2: // Type (Price type)
          comparison = (a.prctyp ?? '').compareTo(b.prctyp ?? '');
          break;
        case 3: // Side
          comparison = (a.trantype ?? '').compareTo(b.trantype ?? '');
          break;
        case 4: // Qty - numeric comparison
          comparison = (a.qty ?? 0).compareTo(b.qty ?? 0);
          break;
        case 5: // LTP - numeric comparison
          final aLtp = double.tryParse(a.ltp ?? '0') ?? 0.0;
          final bLtp = double.tryParse(b.ltp ?? '0') ?? 0.0;
          comparison = aLtp.compareTo(bLtp);
          break;
        case 6: // Trigger - numeric comparison
          final aTrigger = double.tryParse(a.d ?? '0') ?? 0.0;
          final bTrigger = double.tryParse(b.d ?? '0') ?? 0.0;
          comparison = aTrigger.compareTo(bTrigger);
          break;
        case 7: // Status
          comparison = (a.gttOrderCurrentStatus ?? '')
              .compareTo(b.gttOrderCurrentStatus ?? '');
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  Widget _buildInstrumentCell(
      GttOrderBookModel gttOrder, ThemesProvider theme, bool isRowHovered) {
    final status = gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
    final isPending = status == 'PENDING' || status == 'TRIGGER_PENDING';
    final uniqueId = '${gttOrder.alId ?? ''}_${gttOrder.tsym ?? ''}';
    final isProcessing = _processingOrderToken == uniqueId;
    // Format instrument: remove "-EQ" and show symbol + exchange separately
    final symbol = gttOrder.tsym ?? '';
    final displayText = symbol.replaceAll("-EQ", "").trim();

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Instrument name - full width, can be partially covered by buttons
        // Only truncate when hovered (buttons visible), otherwise show full text
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message:
                  '$displayText${gttOrder.exch != null && gttOrder.exch!.isNotEmpty ? ' ${gttOrder.exch}' : ''}',
              child: Padding(
                padding: EdgeInsets.only(right: isRowHovered ? 140.0 : 0.0),
                child: RichText(
                  overflow: isRowHovered
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
                      if (gttOrder.exch != null && gttOrder.exch!.isNotEmpty)
                        TextSpan(
                          text: ' ${gttOrder.exch}',
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
        // Action buttons - positioned at the right edge
        if (isRowHovered)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {}, // Empty handler to stop propagation
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  // Subtle background gradient for better button visibility
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      shadcn.Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.0),
                      shadcn.Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.95),
                      resolveThemeColor(context,
                          dark: MyntColors.backgroundColorDark,
                          light: MyntColors.backgroundColor),
                    ],
                    stops: const [0.0, 0.3, 0.5],
                  ),
                ),
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending) ...[
                        _buildHoverButton(
                          label: 'Modify',
                          onPressed: (isProcessing && _isProcessingModify)
                              ? null
                              : () async {
                                  setState(() {
                                    _processingOrderToken = uniqueId;
                                    _isProcessingModify = true;
                                  });
                                  await _handleModifyGttOrder(gttOrder);
                                  if (mounted) {
                                    setState(() {
                                      _isProcessingModify = false;
                                      _processingOrderToken = null;
                                    });
                                  }
                                },
                          backgroundColor: resolveThemeColor(context,
                              dark: MyntColors.primary,
                              light: MyntColors.primary),
                          textColor: Colors.white,
                          theme: theme,
                          context: context,
                        ),
                        const SizedBox(width: 6),
                        _buildHoverButton(
                          label: 'Cancel',
                          onPressed: (isProcessing && _isProcessingCancel)
                              ? null
                              : () async {
                                  setState(() {
                                    _processingOrderToken = uniqueId;
                                    _isProcessingCancel = true;
                                  });
                                  await _handleCancelGttOrder(gttOrder);
                                  if (mounted) {
                                    setState(() {
                                      _isProcessingCancel = false;
                                      _processingOrderToken = null;
                                    });
                                  }
                                },
                          backgroundColor: resolveThemeColor(context,
                              dark: MyntColors.loss, light: MyntColors.loss),
                          textColor: Colors.white,
                          theme: theme,
                          context: context,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHoverButton({
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    required ThemesProvider theme,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: MyntWebTextStyles.tableCell(
            context,
            color: textColor,
            darkColor: textColor,
            lightColor: textColor,
            fontWeight: MyntFonts.medium,
          ).copyWith(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildLTPCell(GttOrderBookModel gttOrder, ThemesProvider theme) {
    if (gttOrder.token == null || gttOrder.token!.isEmpty) {
      return Text(
        CellFormatters.getValidLTPForGtt(gttOrder),
        style: _getTextStyle(context),
      );
    } else {
      return _GttLTPCell(
        token: gttOrder.token!,
        initialLtp: CellFormatters.getValidLTPForGtt(gttOrder),
      );
    }
  }

  Widget _buildStatusCell(GttOrderBookModel gttOrder, ThemesProvider theme) {
    final status = gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
    final statusText = CellFormatters.getGttStatusText(status);

    // Use MyntColors for status
    Color statusColor;
    if (status == 'EXECUTED') {
      statusColor = resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (status == 'REJECTED' ||
        status == 'CANCELLED' ||
        status == 'CANCELED') {
      statusColor = resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (status == 'PENDING' || status == 'TRIGGER_PENDING') {
      statusColor = resolveThemeColor(context,
          dark: MyntColors.warning, light: MyntColors.warning);
    } else {
      statusColor = resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: MyntWebTextStyles.bodySmall(
          context,
          color: statusColor,
          fontWeight: MyntFonts.medium,
        ),
        overflow: TextOverflow.visible,
        softWrap: false,
      ),
    );
  }

  void _showGttOrderDetail(GttOrderBookModel gttOrder) {
    // Responsive width calculation
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final sheetWidth = screenWidth < 1300 ? screenWidth * 0.3 : 480.0;
        return Container(
          width: sheetWidth,
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: GttOrderBookDetailScreenWeb(
            gttOrder: gttOrder,
            parentContext: context,
          ),
        );
      },
      position: shadcn.OverlayPosition.end,
      barrierColor: Colors.transparent,
    );
  }

  Future<void> _handleCancelGttOrder(GttOrderBookModel gttOrder) async {
    // Show confirmation dialog first
    final shouldCancel = await _showCancelGttOrderDialog(gttOrder);

    if (shouldCancel != true) {
      return;
    }

    try {
      // Cancel the GTT order
      await ref
          .read(orderProvider)
          .cancelGttOrder(gttOrder.alId ?? '', context);

      // Refresh GTT order book after successful cancel
      await ref.read(orderProvider).fetchGTTOrderBook(context, "");

      if (mounted) {
        ResponsiveSnackBar.showSuccess(context, 'GTT Order Cancelled');
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to cancel GTT order: ${e.toString()}');
      }
    }
  }

  Future<bool?> _showCancelGttOrderDialog(
      GttOrderBookModel gttOrderData) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: colors.colorBlack, light: colors.colorWhite),
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            padding: const EdgeInsets.all(24), // Consistent padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button (Top Right)
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(false),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                  ),
                ),

                // Text Content
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Are you sure you want to \ncancel this ',
                    style: MyntWebTextStyles.title(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary),
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: 'GTT order?',
                        style: MyntWebTextStyles.title(
                          context,
                        ).copyWith(
                          fontWeight: FontWeight.w700, // Bold
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Button
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48, // Slightly taller button
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0037B7), // Primary Blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: MyntWebTextStyles.buttonMd(
                        context,
                        color: Colors.white,
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleModifyGttOrder(GttOrderBookModel gttOrder) async {
    try {
      // Fetch scrip info first
      await ref.read(marketWatchProvider).fetchScripInfo(
            "${gttOrder.token}",
            '${gttOrder.exch}',
            context,
            true,
          );

      if (!mounted) return;

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        ResponsiveSnackBar.showError(
            context, 'Unable to fetch scrip information');
        return;
      }

      // Show modify GTT order screen as draggable dialog
      ModifyGttWeb.showDraggable(
        context: context,
        gttOrderBook: gttOrder,
        scripInfo: scripInfo,
      );
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open modify GTT order: ${e.toString()}');
      }
    }
  }
}

// LTP Cell with WebSocket updates for GTT
class _GttLTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;

  const _GttLTPCell({required this.token, required this.initialLtp});

  @override
  ConsumerState<_GttLTPCell> createState() => _GttLTPCellState();
}

class _GttLTPCellState extends ConsumerState<_GttLTPCell> {
  late String ltp;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialLtp;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null &&
          newLtp != ltp &&
          newLtp != '0.00' &&
          newLtp != 'null') {
        setState(() => ltp = newLtp);
      }
    });
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
