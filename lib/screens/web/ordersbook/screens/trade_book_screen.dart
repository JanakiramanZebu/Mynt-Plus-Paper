import 'package:flutter/material.dart'
    hide DataTable, DataColumn, DataRow, DataCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:mynt_plus/models/order_book_model/trade_book_model.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../refactored/utils/cell_formatters.dart';
import 'trade_detail_screen_web.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

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
  int? _sortColumnIndex;
  bool _sortAscending = true;
  // ignore: unused_field
  int? _hoveredRowIndex;

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

    // Get trades (search or regular)
    // Only show search results if we're on the Trade Book tab (index 2)
    final searchQuery = orderBook.orderSearchCtrl.text.trim();
    final isTradeBookTab = orderBook.selectedTab == 2;
    final trades = (searchQuery.isNotEmpty && isTradeBookTab)
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
        return SizedBox(
          height: 400,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: NoDataFound(
                title: searchQuery.isNotEmpty ? "No Trades Found" : "No Trades",
                subtitle: searchQuery.isNotEmpty
                    ? "No trades match your search \"$searchQuery\"."
                    : "You don't have any trades yet.",
                primaryEnabled: false,
                secondaryEnabled: false,
              ),
            ),
          ),
        );
      }
    }

    // Sort trades
    final sortedTrades = _getSortedTrades(trades);

    return shadcn.OutlinedContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(sortedTrades, context);

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
          // This prevents unnecessary horizontal scroll while using available space efficiently
          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;

            // Define which columns can grow and their growth priorities
            const instrumentGrowthFactor =
                2.0; // Instrument can grow 2x more than numeric
            const textGrowthFactor = 1.2;
            const numericGrowthFactor = 1.0;

            // Calculate growth factors for each column
            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 8; i++) {
              // Column 0: Time (numeric)
              // Column 1: Instrument
              // Columns 2, 3, 7: Text columns (Product, Type, Order no)
              // Rest: Numeric columns
              if (i == 1) {
                growthFactors[i] = instrumentGrowthFactor;
                totalGrowthFactor += instrumentGrowthFactor;
              } else if (i == 2 || i == 3 || i == 7) {
                growthFactors[i] = textGrowthFactor;
                totalGrowthFactor += textGrowthFactor;
              } else {
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            // Distribute extra space proportionally
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

          // Calculate total required width
          final totalRequiredWidth = columnWidths.values
              .fold<double>(0.0, (sum, width) => sum + width);

          // If total width exceeds available width, enable horizontal scrolling
          final needsHorizontalScroll = totalRequiredWidth > availableWidth;

          // Build table content
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
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Time', 0),
                        buildHeaderCell('Instrument', 1),
                        buildHeaderCell('Product/Type', 2),
                        buildHeaderCell('Type', 3),
                        buildHeaderCell('Qty', 4, true),
                        buildHeaderCell('Price', 5, true),
                        buildHeaderCell('Trade value', 6, true),
                        buildHeaderCell('Order no', 7, true),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body
                Expanded(
                  child: Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
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
                        defaultRowHeight: const shadcn.FixedTableSize(40),
                        rows: sortedTrades.asMap().entries.map((entry) {
                          final index = entry.key;
                          final trade = entry.value;

                          return shadcn.TableRow(
                            cells: [
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 0,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildTextCell(
                                  _formatTime(trade.norentm ?? 'N/A'),
                                  theme,
                                  Alignment.centerLeft,
                                  allowOverflow:
                                      true, // Show full time without truncation
                                ),
                              ),
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 1,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildInstrumentCell(trade, theme),
                              ),
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 2,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildTextCell(
                                  _formatProductType(trade),
                                  theme,
                                  Alignment.centerLeft,
                                ),
                              ),
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 3,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildTextCell(
                                  trade.trantype == "S" ? "SELL" : "BUY",
                                  theme,
                                  Alignment.centerLeft,
                                  color: trade.trantype == "S"
                                      ? resolveThemeColor(context,
                                          dark: MyntColors.lossDark,
                                          light: MyntColors.loss)
                                      : resolveThemeColor(context,
                                          dark: MyntColors.profitDark,
                                          light: MyntColors.profit),
                                ),
                              ),
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 4,
                                alignRight: true,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildTextCell(
                                  trade.qty?.toString() ?? 'N/A',
                                  theme,
                                  Alignment.centerRight,
                                ),
                              ),
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 5,
                                alignRight: true,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildTextCell(
                                  trade.avgprc?.toString() ?? 'N/A',
                                  theme,
                                  Alignment.centerRight,
                                ),
                              ),
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 6,
                                alignRight: true,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildTextCell(
                                  CellFormatters.calculateTradeValue(trade),
                                  theme,
                                  Alignment.centerRight,
                                ),
                              ),
                              buildCellWithHover(
                                rowIndex: index,
                                columnIndex: 7,
                                alignRight: true,
                                onTap: () => _showTradeDetail(trade),
                                child: _buildTextCell(
                                  trade.norenordno?.toString() ?? 'N/A',
                                  theme,
                                  Alignment.centerRight,
                                  allowOverflow:
                                      true, // Show full order number without truncation
                                ),
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

          // Horizontal scroll wrapper (if needed)
          if (needsHorizontalScroll) {
            return Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
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
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 1; // Instrument column
    final isLastColumn = columnIndex == 7; // Order no column

    // Match the cell padding logic - Instrument column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets cellPadding;
    if (isFirstColumn) {
      // First column - symmetric padding
      cellPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isInstrumentColumn) {
      // Instrument column - more left, minimal right
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
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: cellPadding,
            alignment: alignRight ? Alignment.topRight : null,
            child: child,
          ),
        ),
      ),
    );
  }

  // Builds a sortable header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0; // Time column
    final isInstrumentColumn = columnIndex == 1; // Instrument column
    final isLastColumn = columnIndex == 7; // Order no column

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

  String _formatTime(String time) {
    if (time.isEmpty || time == '0.00' || time == 'N/A') return 'N/A';

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
      List<TradeBookModel> trades, BuildContext context) {
    // Use fixed font size for measurement (table text is not responsive, only buttons are)
    final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'Time',
      'Instrument',
      'Product/Type',
      'Type',
      'Qty',
      'Price',
      'Trade value',
      'Order no',
    ];
    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth;

      for (final trade in trades.take(5)) {
        String cellText = '';
        switch (col) {
          case 0:
            cellText = _formatTime(trade.norentm ?? 'N/A');
            break;
          case 1:
            // For Instrument column, measure symbol + exchange separately
            // since exchange uses smaller font
            final displayText = CellFormatters.formatTradeInstrumentText(trade);
            final exchange = trade.exch ?? '';
            final exchangeText = exchange.isNotEmpty ? ' $exchange' : '';

            // Measure symbol with normal font
            final symbolWidth = _measureTextWidth(displayText, textStyle);

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
          case 2:
            cellText = _formatProductType(trade);
            break;
          case 3:
            cellText = trade.trantype == "S" ? "SELL" : "BUY";
            break;
          case 4:
            cellText = trade.qty?.toString() ?? 'N/A';
            break;
          case 5:
            cellText = trade.avgprc?.toString() ?? 'N/A';
            break;
          case 6:
            cellText = CellFormatters.calculateTradeValue(trade);
            break;
          case 7:
            cellText = trade.norenordno?.toString() ?? 'N/A';
            break;
        }

        final cellWidth = _measureTextWidth(cellText, textStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      // Ensure minimum widths to prevent truncation for important columns
      if (headers[col] == 'Instrument') {
        const minInstrumentWidth = 150.0;
        maxWidth =
            maxWidth < minInstrumentWidth ? minInstrumentWidth : maxWidth;
      } else if (headers[col] == 'Time') {
        // Ensure Time column has enough width to show full time (e.g., "12:57 PM" or "11:14 AM")
        const minTimeWidth = 90.0;
        maxWidth = maxWidth < minTimeWidth ? minTimeWidth : maxWidth;
      } else if (headers[col] == 'Order no') {
        // Ensure Order number column has enough width to show full order number
        const minOrderNoWidth = 120.0;
        maxWidth = maxWidth < minOrderNoWidth ? minOrderNoWidth : maxWidth;
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

  List<TradeBookModel> _getSortedTrades(List<TradeBookModel> trades) {
    if (_sortColumnIndex == null) return trades;

    final sorted = List<TradeBookModel>.from(trades);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex!) {
        case 0: // Time
          comparison = (a.norentm ?? '').compareTo(b.norentm ?? '');
          break;
        case 1: // Instrument
          comparison = CellFormatters.formatTradeInstrumentText(a)
              .compareTo(CellFormatters.formatTradeInstrumentText(b));
          break;
        case 2: // Product
          comparison = _formatProductType(a).compareTo(_formatProductType(b));
          break;
        case 3: // Type
          comparison = (a.trantype ?? '').compareTo(b.trantype ?? '');
          break;
        case 4: // Qty
          comparison = (int.tryParse(a.qty ?? '0') ?? 0)
              .compareTo(int.tryParse(b.qty ?? '0') ?? 0);
          break;
        case 5: // Price
          comparison = (double.tryParse(a.avgprc ?? '0') ?? 0)
              .compareTo(double.tryParse(b.avgprc ?? '0') ?? 0);
          break;
        case 6: // Trade value
          final aValue = (double.tryParse(a.avgprc ?? '0') ?? 0) *
              (int.tryParse(a.qty ?? '0') ?? 0);
          final bValue = (double.tryParse(b.avgprc ?? '0') ?? 0) *
              (int.tryParse(b.qty ?? '0') ?? 0);
          comparison = aValue.compareTo(bValue);
          break;
        case 7: // Order no
          comparison = (a.norenordno ?? '').compareTo(b.norenordno ?? '');
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  Widget _buildInstrumentCell(TradeBookModel trade, ThemesProvider theme) {
    // Format instrument using CellFormatters to include strike price and expiry date
    final displayText = CellFormatters.formatTradeInstrumentText(trade);
    final exchange = trade.exch ?? '';

    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        text: TextSpan(
          children: [
            // Symbol with strike price (normal color, fixed 14px)
            TextSpan(
              text: displayText.isNotEmpty ? displayText : 'N/A',
              style: _getTextStyle(context),
            ),
            // Exchange (mutedForeground color, smaller font, fixed 12px)
            if (exchange.isNotEmpty)
              TextSpan(
                text: ' $exchange',
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
    );
  }

  String _formatProductType(TradeBookModel trade) {
    final product = trade.sPrdtAli ?? trade.prd ?? '';
    final priceType = trade.prctyp ?? '';

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

  Widget _buildTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
    bool allowOverflow = false, // If true, show full text without truncation
  }) {
    return Align(
      alignment: alignment,
      child: Text(
        text,
        style: _getTextStyle(context, color: color),
        maxLines: 1,
        overflow: allowOverflow ? TextOverflow.visible : TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }

  // Show trade detail using shadcn sheet
  void _showTradeDetail(TradeBookModel trade) {
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final sheetWidth = screenWidth < 1500 ? screenWidth * 0.3 : 480.0;
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
          child: TradeDetailScreenWeb(
            trade: trade,
            parentContext: context,
          ),
        );
      },
      position: shadcn.OverlayPosition.end,
      barrierColor: Colors.transparent,
    );
  }
}
