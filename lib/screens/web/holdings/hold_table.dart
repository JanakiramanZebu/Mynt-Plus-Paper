import 'dart:async';
import 'package:flutter/material.dart' show InkWell, Icons, VoidCallback, BorderRadius, Icon, BoxDecoration, TextPainter, TextSpan, TextStyle, TextDirection, GestureDetector, HitTestBehavior, Row, MainAxisSize, SizedBox, Colors, Widget, BuildContext, Color, EdgeInsets, Alignment, MainAxisAlignment, TextOverflow, Axis, FontWeight, Container, MouseRegion, Expanded, Align, Text, AnimatedOpacity, ScrollController, SingleChildScrollView, Scrollbar, Column, LayoutBuilder, ValueKey, IconData, Padding, Tooltip, RichText, Stack, LinearGradient, BoxConstraints, Clip, MediaQuery, Builder, Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../provider/portfolio_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/market_watch_provider.dart';
  import '../../../provider/thems.dart';
    import '../../../res/web_colors.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../utils/responsive_navigation.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import 'holding_detail_screen_web.dart';

// Table Example 1 with real Holdings data and WebSocket LTP updates
// This demonstrates the simplest Shadcn table implementation with live data

class TableExample1 extends ConsumerStatefulWidget {
  final String? searchQuery;
  
  const TableExample1({super.key, this.searchQuery});

  @override
  ConsumerState<TableExample1> createState() => _TableExample1State();
}

class _TableExample1State extends ConsumerState<TableExample1> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
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

  // Helper method to ensure Geist font is always applied
  TextStyle _geistTextStyle({Color? color, double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontFamily: 'Geist',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  // Builds a bordered cell; amounts can be right-aligned by passing true.
  shadcn.TableCell buildCell(Widget child, [bool alignRight = false]) {
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
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: alignRight ? Alignment.topRight : null,
        child: child,
      ),
    );
  }

  // Builds a cell with hover detection that covers the entire cell including padding
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    // Add extra horizontal padding for first and last columns
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 9;
    
    // For first column (Instrument), use more left padding, minimal right padding
    // For last column, use minimal left padding, more right padding (mirror of first)
    // For other columns, use minimal padding
    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 4, 8); // More left, minimal right
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(4, 8, 16, 8); // Minimal left, more right
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
        child: Container(
          padding: cellPadding,
          alignment: alignRight ? Alignment.topRight : null,
          child: child,
        ),
      ),
    );
  }

  // Helper method to get theme-aware colors for positive/negative/neutral values
  Color _getValueColor(double value) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    if (value > 0) {
      return colorScheme.chart2;
    }
    if (value < 0) {
      return colorScheme.destructive;
    }
    return colorScheme.mutedForeground;
  }

  // Builds a sortable header cell with sort indicator
  shadcn.TableCell buildHeaderCell(String label, int columnIndex, [bool alignRight = false]) {
    // Add extra horizontal padding for first and last columns
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 9;
    
    // Match the cell padding logic - first column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 6, 8, 6); // More left, minimal right
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 6, 16, 6); // Minimal left, more right
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
                style: _geistTextStyle(
                  color: shadcn.Theme.of(context).colorScheme.foreground,
                ),
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

  // Helper method to format instrument display text (remove -EQ and show exchange)
  String _formatInstrumentText(dynamic exchTsym) {
    if (exchTsym == null) return 'N/A';
    final symbol = (exchTsym.tsym ?? '').replaceAll("-EQ", "").trim();
    final exchange = exchTsym.exch ?? '';
    return exchange.isNotEmpty ? '$symbol $exchange' : symbol;
  }

  // Helper method to measure text width dynamically
  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _geistTextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  // Calculate minimum column widths dynamically based on header and data
  Map<int, double> _calculateMinWidths(List<dynamic> holdings, BuildContext context) {
    // Use default text style for measurement
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0; // Padding for cell content (8px on each side + some extra)
    const sortIconWidth = 24.0; // Extra space for sort indicator icon (16px icon + 4px gap + buffer)

    // Header texts
    final headers = [
      'Instrument',
      'Net Qty',
      'Avg Price',
      'LTP',
      'Invested',
      'Current Value',
      'Day P&L',
      'Day %',
      'Overall P&L',
      'Overall %',
    ];

    final minWidths = <int, double>{};

    // Calculate width for each column
    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;

      // Measure header width and add space for sort icon
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth; // Add extra space for sort indicator

      // Measure widest value in this column
      for (final holding in holdings) {
        final exchTsym = holding.exchTsym?.isNotEmpty == true ? holding.exchTsym![0] : null;
        String cellText = '';

        switch (col) {
          case 0: // Instrument
            cellText = _formatInstrumentText(exchTsym);
            break;
          case 1: // Net Qty
            final qty = holding.currentQty ?? 0;
            cellText = qty > 0 ? '+$qty' : '$qty';
            break;
          case 2: // Avg Price
            cellText = holding.avgPrc ?? '0.00';
            break;
          case 3: // LTP
            cellText = exchTsym?.lp ?? '0.00';
            break;
          case 4: // Invested
            cellText = holding.invested ?? '0.00';
            break;
          case 5: // Current Value
            cellText = holding.currentValue ?? '0.00';
            break;
          case 6: // Day P&L
            cellText = exchTsym?.oneDayChg ?? '0.00';
            break;
          case 7: // Day %
            cellText = exchTsym?.perChange ?? '0.00';
            break;
          case 8: // Overall P&L
            cellText = exchTsym?.profitNloss ?? '0.00';
            break;
          case 9: // Overall %
            cellText = exchTsym?.pNlChng ?? '0.00';
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

      // Set minimum width (max of header/data + padding)
      minWidths[col] = maxWidth + padding;
    }

    return minWidths;
  }

  @override
  Widget build(BuildContext context) {
    final portfolioData = ref.watch(portfolioProvider);
    final holdings = portfolioData.holdingsModel ?? [];

    // Filter to show only stock holdings (not mutual funds)
    var stockHoldings = holdings.where((holding) {
      final exchTsym = holding.exchTsym?.isNotEmpty == true ? holding.exchTsym![0] : null;
      return exchTsym != null && exchTsym.exch != 'MF';
    }).toList();

    // Apply search filter if search query is provided
    final searchQuery = widget.searchQuery?.toLowerCase().trim() ?? '';
    if (searchQuery.isNotEmpty) {
      stockHoldings = stockHoldings.where((holding) {
        if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
          final exchTsym = holding.exchTsym![0];
          final symbol = exchTsym.tsym?.toLowerCase() ?? '';
          return symbol.contains(searchQuery);
        }
        return false;
      }).toList();
    }

    // Sort holdings based on selected column
    if (_sortColumnIndex != null) {
      stockHoldings.sort((a, b) {
        final exchTsymA = a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
        final exchTsymB = b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;

        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: // Instrument
            comparison = _formatInstrumentText(exchTsymA).compareTo(_formatInstrumentText(exchTsymB));
            break;
          case 1: // Net Qty
            comparison = (a.currentQty ?? 0).compareTo(b.currentQty ?? 0);
            break;
          case 2: // Avg Price
            final avgPriceA = double.tryParse(a.avgPrc ?? '0') ?? 0.0;
            final avgPriceB = double.tryParse(b.avgPrc ?? '0') ?? 0.0;
            comparison = avgPriceA.compareTo(avgPriceB);
            break;
          case 3: // LTP
            final ltpA = double.tryParse(exchTsymA?.lp ?? '0') ?? 0.0;
            final ltpB = double.tryParse(exchTsymB?.lp ?? '0') ?? 0.0;
            comparison = ltpA.compareTo(ltpB);
            break;
          case 4: // Invested
            final investedA = double.tryParse(a.invested ?? '0') ?? 0.0;
            final investedB = double.tryParse(b.invested ?? '0') ?? 0.0;
            comparison = investedA.compareTo(investedB);
            break;
          case 5: // Current Value
            final currentValueA = double.tryParse(a.currentValue ?? '0') ?? 0.0;
            final currentValueB = double.tryParse(b.currentValue ?? '0') ?? 0.0;
            comparison = currentValueA.compareTo(currentValueB);
            break;
          case 6: // Day P&L
            final dayPnlA = double.tryParse(exchTsymA?.oneDayChg ?? '0') ?? 0.0;
            final dayPnlB = double.tryParse(exchTsymB?.oneDayChg ?? '0') ?? 0.0;
            comparison = dayPnlA.compareTo(dayPnlB);
            break;
          case 7: // Day %
            final dayPercentA = double.tryParse(exchTsymA?.perChange ?? '0') ?? 0.0;
            final dayPercentB = double.tryParse(exchTsymB?.perChange ?? '0') ?? 0.0;
            comparison = dayPercentA.compareTo(dayPercentB);
            break;
          case 8: // Overall P&L
            final pnlA = double.tryParse(exchTsymA?.profitNloss ?? '0') ?? 0.0;
            final pnlB = double.tryParse(exchTsymB?.profitNloss ?? '0') ?? 0.0;
            comparison = pnlA.compareTo(pnlB);
            break;
          case 9: // Overall %
            final overallPercentA = double.tryParse(exchTsymA?.pNlChng ?? '0') ?? 0.0;
            final overallPercentB = double.tryParse(exchTsymB?.pNlChng ?? '0') ?? 0.0;
            comparison = overallPercentA.compareTo(overallPercentB);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    // Show all holdings
    final displayHoldings = stockHoldings;

    // Show NoDataFound if no results after filtering
    if (displayHoldings.isEmpty) {
      return shadcn.OutlinedContainer(
        child: NoDataFound(
          title: searchQuery.isNotEmpty 
              ? "No Stocks Found" 
              : "No Stocks",
          subtitle: searchQuery.isNotEmpty
              ? "No stocks match your search \"$searchQuery\"."
              : "You don't have any stock holdings yet.",
          primaryEnabled: false,
          secondaryEnabled: false,
        ),
      );
    }

    final theme = ref.watch(themeProvider);

    return shadcn.OutlinedContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(displayHoldings, context);

          // Available width
          final availableWidth = constraints.maxWidth;
          
          // Step 1: Start with minimum widths (content-based, no wasted space)
          final columnWidths = <int, double>{};
          for (int i = 0; i < 10; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          // Step 2: Calculate total minimum width needed
          final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
          
          // Step 3: If there's extra space, distribute it proportionally
          // This prevents unnecessary horizontal scroll while using available space efficiently
          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;
            
            // Define which columns can grow and their growth priorities
            // Instrument gets more growth, numeric columns get less
            // Net Qty (col 1) should not grow much - it has small content
            const instrumentGrowthFactor = 2.0; // Instrument can grow 2x more than numeric
            const numericGrowthFactor = 1.0;
            const smallColumnGrowthFactor = 0.1; // Net Qty should grow minimally
            
            // Calculate growth factors for each column
            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;
            
            for (int i = 0; i < 10; i++) {
              if (i == 0) {
                // Column 0 is Instrument
                growthFactors[i] = instrumentGrowthFactor;
                totalGrowthFactor += instrumentGrowthFactor;
              } else if (i == 1) {
                // Column 1 is Net Qty - small content, minimal growth
                growthFactors[i] = smallColumnGrowthFactor;
                totalGrowthFactor += smallColumnGrowthFactor;
              } else {
                // Columns 2-9 are numeric
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }
            
            // Distribute extra space proportionally
            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 10; i++) {
                if (growthFactors[i]! > 0) {
                  final extraForThisColumn = (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                  columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                }
              }
            }
          }
          
          // Step 4: Set maximum width for Net Qty column to prevent it from being too wide
          // Net Qty has small content, so cap it at a reasonable max width
          if (columnWidths[1] != null && columnWidths[1]! > 120) {
            columnWidths[1] = 120.0; // Max width for Net Qty column
          }

          // Calculate total required width
          final totalRequiredWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
          
          // If total width exceeds available width, enable horizontal scrolling
          final needsHorizontalScroll = totalRequiredWidth > availableWidth;

          // Build table content
          Widget buildTableContent() {
            return Column(
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
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Instrument', 0),
                        buildHeaderCell('Net Qty', 1, true),
                        buildHeaderCell('Avg Price', 2, true),
                        buildHeaderCell('LTP', 3, true),
                        buildHeaderCell('Invested', 4, true),
                        buildHeaderCell('Current Value', 5, true),
                        buildHeaderCell('Day P&L', 6, true),
                        buildHeaderCell('Day %', 7, true),
                        buildHeaderCell('Overall P&L', 8, true),
                        buildHeaderCell('Overall %', 9, true),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body (vertical scroll)
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
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    // Data Rows
                    ...displayHoldings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final holding = entry.value;
                      final exchTsym = holding.exchTsym?.isNotEmpty == true ? holding.exchTsym![0] : null;
                      final token = exchTsym?.token ?? '';
                      final qty = holding.currentQty ?? 0;
                      final avgPrice = double.tryParse(holding.avgPrc ?? '0') ?? 0.0;
                      final isRowHovered = _hoveredRowIndex == index;

                      return shadcn.TableRow(
                        cells: [
                          // Instrument with action buttons on hover - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 0,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
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
                                        message: '${(exchTsym?.tsym ?? 'N/A').replaceAll("-EQ", "").trim()}${exchTsym?.exch != null && exchTsym!.exch!.isNotEmpty ? ' ${exchTsym.exch}' : ''}',
                                        child: Padding(
                                          padding: EdgeInsets.only(right: isRowHovered ? 8.0 : 0.0),
                                          child: RichText(
                                            overflow: isRowHovered ? TextOverflow.ellipsis : TextOverflow.visible,
                                            maxLines: 1,
                                            softWrap: false,
                                            text: TextSpan(
                                              children: [
                                                // Symbol (normal color, without -EQ, fixed 14px)
                                                TextSpan(
                                                  text: (exchTsym?.tsym ?? 'N/A').replaceAll("-EQ", "").trim(),
                                                  style: _geistTextStyle(
                                                    color: shadcn.Theme.of(context).colorScheme.foreground,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                                // Exchange (mutedForeground color, smaller font, fixed 12px)
                                                if (exchTsym?.exch != null && exchTsym!.exch!.isNotEmpty)
                                                  TextSpan(
                                                    text: ' ${exchTsym.exch}',
                                                    style: _geistTextStyle(
                                                      color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                                                      fontSize: 12.0,
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
                                                          if (qty > 0) ...{
                                                            _buildHoverButton(
                                                              theme: theme,
                                                              label: 'Add',
                                                              onPressed: () => _handleAddHolding(holding, exchTsym),
                                                              backgroundColor: theme.isDarkMode
                                                                  ? WebDarkColors.primary
                                                                  : WebColors.primary,
                                                              textColor: Colors.white,
                                                              context: buttonContext,
                                                            ),
                                                            SizedBox(width: buttonSpacing),
                                                          },
                                                          if (qty > 0) ...{
                                                            _buildHoverButton(
                                                              theme: theme,
                                                              label: 'Exit',
                                                              onPressed: () => _handleExitHolding(holding, exchTsym),
                                                              backgroundColor: theme.isDarkMode
                                                                  ? WebDarkColors.tertiary
                                                                  : WebColors.tertiary,
                                                              textColor: Colors.white,
                                                              context: buttonContext,
                                                            ),
                                                            SizedBox(width: buttonSpacing),
                                                          },
                                                          _buildHoverButton(
                                                            theme: theme,
                                                            icon: Icons.bar_chart,
                                                            onPressed: () => _handleChartTap(holding, exchTsym),
                                                            backgroundColor: Colors.white,
                                                            iconColor: Colors.black,
                                                            context: buttonContext,
                                                          ),
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
                          // Net Qty - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 1,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  qty > 0 ? '$qty' : '$qty',
                                  style: _geistTextStyle(
                                    color: shadcn.Theme.of(context).colorScheme.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Avg Price - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 2,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  holding.avgPrc ?? '0.00',
                                  style: _geistTextStyle(
                                    color: shadcn.Theme.of(context).colorScheme.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // LTP - with WebSocket updates - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 3,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: token.isNotEmpty
                                    ? _LTPCell(
                                        token: token,
                                        initialLtp: exchTsym?.lp ?? '0.00',
                                      )
                                    : Text(
                                        exchTsym?.lp ?? '0.00',
                                        style: _geistTextStyle(
                                          color: shadcn.Theme.of(context).colorScheme.foreground,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          // Invested - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 4,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  holding.invested ?? '0.00',
                                  style: _geistTextStyle(
                                    color: shadcn.Theme.of(context).colorScheme.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Current Value - with WebSocket updates - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 5,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: token.isNotEmpty
                                    ? _CurrentValueCell(
                                        token: token,
                                        qty: qty,
                                        initialValue: holding.currentValue ?? '0.00',
                                      )
                                    : Text(
                                        holding.currentValue ?? '0.00',
                                        style: _geistTextStyle(
                                          color: shadcn.Theme.of(context).colorScheme.foreground,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          // Day P&L - with WebSocket updates - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 6,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: token.isNotEmpty
                                    ? _DayPnLCell(
                                        token: token,
                                        initialValue: exchTsym?.oneDayChg ?? '0.00',
                                      )
                                    : _buildColoredText(exchTsym?.oneDayChg ?? '0.00'),
                              ),
                            ),
                          ),
                          // Day % - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 7,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: token.isNotEmpty
                                    ? _DayPercentCell(
                                        token: token,
                                        initialValue: exchTsym?.perChange ?? '0.00',
                                      )
                                    : _buildColoredText(exchTsym?.perChange ?? '0.00'),
                              ),
                            ),
                          ),
                          // Overall P&L - with WebSocket updates - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 8,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: token.isNotEmpty
                                    ? _OverallPnLCell(
                                        token: token,
                                        qty: qty,
                                        avgPrice: avgPrice,
                                        initialValue: exchTsym?.profitNloss ?? '0.00',
                                      )
                                    : _buildColoredText(exchTsym?.profitNloss ?? '0.00'),
                              ),
                            ),
                          ),
                          // Overall % - Make clickable for row tap
                          buildCellWithHover(
                            rowIndex: index,
                            columnIndex: 9,
                            alignRight: true,
                            child: GestureDetector(
                              onTap: () => _showHoldingDetail(holding, exchTsym),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: token.isNotEmpty
                                    ? _OverallPercentCell(
                                        token: token,
                                        qty: qty,
                                        avgPrice: avgPrice,
                                        initialValue: exchTsym?.pNlChng ?? '0.00',
                                      )
                                    : _buildColoredText(exchTsym?.pNlChng ?? '0.00'),
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
          );
        }

          // Wrap in horizontal scroll if needed
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
          } else {
            return buildTableContent();
          }
        },
      ),
    );
  }

  Widget _buildColoredText(String value) {
    final numValue = double.tryParse(value.replaceAll('%', '')) ?? 0.0;
    final color = _getValueColor(numValue);

    return Text(
      value,
      style: _geistTextStyle(color: color),
    );
  }

  Widget _buildHoverButton({
    required ThemesProvider theme,
    String? label,
    IconData? icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    required BuildContext context,
  }) {
    final borderRadiusValue = 5.0;
    
    // Detect screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768; // Tablet breakpoint
    final isVerySmallScreen = screenWidth < 480; // Mobile breakpoint
    
    // Responsive sizes
    final iconSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0);
    final buttonPadding = isVerySmallScreen 
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
        : (isSmallScreen 
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 8));
    final fontSize = isVerySmallScreen ? 10.0 : (isSmallScreen ? 11.0 : 12.0);
    
    // Use Container only for background color, shadcn handles size/shape
    return Container(
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadiusValue),
            )
          : null,
      child: icon != null
          ? shadcn.IconButton(
              size: shadcn.ButtonSize.small,
              density: shadcn.ButtonDensity.dense,
              variance: shadcn.ButtonVariance.ghost,
              onPressed: onPressed,
              shape: shadcn.ButtonShape.rectangle,
              icon: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.white,
              ),
            )
          : shadcn.TextButton(
              size: shadcn.ButtonSize.small,
              density: shadcn.ButtonDensity.dense,
              onPressed: onPressed,
              shape: shadcn.ButtonShape.rectangle,
              child: Padding(
                padding: buttonPadding,
                child: Text(
                  label ?? "",
                  style: WebTextStyles.buttonSm(
                    isDarkTheme: theme.isDarkMode,
                    color: textColor ?? Colors.white,
                    fontWeight: WebFonts.bold,
                  ).copyWith(fontSize: fontSize),
                ),
              ),
            ),
    );
  }

  // Handler: Add holding (Buy more)
  Future<void> _handleAddHolding(dynamic holding, dynamic exchTsym) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      await scripData.fetchScripInfo(
        exchTsym.token ?? "",
        exchTsym.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: exchTsym.exch ?? "",
        tSym: exchTsym.tsym ?? "",
        isExit: false,
        token: exchTsym.token ?? "",
        transType: true,
        prd: holding.prd ?? "",
        lotSize: lotSize,
        ltp: exchTsym.lp ?? "0.00",
        perChange: exchTsym.perChange ?? "0.00",
        orderTpye: holding.sPrdtAli ?? '',
        holdQty: holding.currentQty?.toString() ?? '',
        isModify: false,
        raw: {},
      );

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripData.scripInfoModel!,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(
          context, "Error adding holding: ${e.toString()}");
    }
  }

  // Handler: Exit holding (Sell)
  Future<void> _handleExitHolding(dynamic holding, dynamic exchTsym) async {
    try {
      if (holding.saleableQty == null || holding.saleableQty == 0) {
        showResponsiveWarningMessage(
          context,
          'You are unable to exit because there are no sellable quantity.',
        );
        return;
      }

      final scripData = ref.read(marketWatchProvider);
      await scripData.fetchScripInfo(
        exchTsym.token ?? "",
        exchTsym.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: exchTsym.exch ?? "",
        tSym: exchTsym.tsym ?? "",
        isExit: true,
        token: exchTsym.token ?? "",
        transType: false,
        prd: holding.prd ?? "",
        lotSize: lotSize,
        ltp: exchTsym.lp ?? "0.00",
        perChange: exchTsym.perChange ?? "0.00",
        orderTpye: holding.sPrdtAli ?? '',
        holdQty: holding.currentQty?.toString() ?? '',
        isModify: false,
        raw: {},
      );

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripData.scripInfoModel!,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(
          context, "Error exiting holding: ${e.toString()}");
    }
  }

  // Handler: Show holding detail sheet
  void _showHoldingDetail(dynamic holding, dynamic exchTsym) {
    if (exchTsym == null) return;

    // Save parent context to pass to sheet
    final parentCtx = context;
    
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) => HoldingDetailScreenWeb(
        holding: holding,
        exchTsym: exchTsym,
        parentContext: parentCtx, // Pass parent context for navigation
      ),
      position: shadcn.OverlayPosition.end,
    );
  }

  // Handler: Chart tap (Show market depth)
  Future<void> _handleChartTap(dynamic holding, dynamic exchTsym) async {
    final scripData = ref.read(marketWatchProvider);
    await scripData.fetchScripQuoteIndex(
      exchTsym.token ?? "",
      exchTsym.exch ?? "",
      context,
    );

    final quots = scripData.getQuotes;
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch?.toString() ?? "",
        token: quots.token?.toString() ?? "",
        tsym: quots.tsym?.toString() ?? "",
        instname: quots.instname?.toString() ?? "",
        symbol: quots.symbol?.toString() ?? "",
        expDate: quots.expDate?.toString() ?? "",
        option: quots.option?.toString() ?? "",
      );
      scripData.scripdepthsize(false);
      await scripData.calldepthApis(context, depthArgs, "");
    }
  }
}

// ==================== WEBSOCKET CELLS ====================

/// LTP Cell with WebSocket updates
class _LTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;

  const _LTPCell({required this.token, required this.initialLtp});

  @override
  ConsumerState<_LTPCell> createState() => _LTPCellState();
}

class _LTPCellState extends ConsumerState<_LTPCell> {
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
      style: TextStyle(
        fontFamily: 'Geist',
        color: shadcn.Theme.of(context).colorScheme.foreground,
      ),
    );
  }
}

/// Current Value Cell with WebSocket updates
class _CurrentValueCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final String initialValue;

  const _CurrentValueCell({
    required this.token,
    required this.qty,
    required this.initialValue,
  });

  @override
  ConsumerState<_CurrentValueCell> createState() => _CurrentValueCellState();
}

class _CurrentValueCellState extends ConsumerState<_CurrentValueCell> {
  late String currentValue;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        final newValue = (ltp * widget.qty).toStringAsFixed(2);
        if (newValue != currentValue) {
          setState(() => currentValue = newValue);
        }
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
      currentValue,
      style: TextStyle(
        fontFamily: 'Geist',
        color: shadcn.Theme.of(context).colorScheme.foreground,
      ),
    );
  }
}

/// Overall P&L Cell with WebSocket updates
class _OverallPnLCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final double avgPrice;
  final String initialValue;

  const _OverallPnLCell({
    required this.token,
    required this.qty,
    required this.avgPrice,
    required this.initialValue,
  });

  @override
  ConsumerState<_OverallPnLCell> createState() => _OverallPnLCellState();
}

class _OverallPnLCellState extends ConsumerState<_OverallPnLCell> {
  late String overallPnL;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    overallPnL = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        final newPnL =
            ((ltp - widget.avgPrice) * widget.qty).toStringAsFixed(2);
        if (newPnL != overallPnL) {
          setState(() => overallPnL = newPnL);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, BuildContext context) {
    final numValue = double.tryParse(value) ?? 0.0;
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    if (numValue > 0) {
      return colorScheme.chart2;
    }
    if (numValue < 0) {
      return colorScheme.destructive;
    }
    return colorScheme.mutedForeground;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      overallPnL,
      style: TextStyle(
        fontFamily: 'Geist',
        color: _getValueColor(overallPnL, context),
      ),
    );
  }
}

/// Day P&L Cell with WebSocket updates
class _DayPnLCell extends ConsumerStatefulWidget {
  final String token;
  final String initialValue;

  const _DayPnLCell({
    required this.token,
    required this.initialValue,
  });

  @override
  ConsumerState<_DayPnLCell> createState() => _DayPnLCellState();
}

class _DayPnLCellState extends ConsumerState<_DayPnLCell> {
  late String dayPnL;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    dayPnL = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newDayPnL = data[widget.token]['oneDayChg']?.toString();
      if (newDayPnL != null && newDayPnL != dayPnL && newDayPnL != 'null') {
        setState(() => dayPnL = newDayPnL);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, BuildContext context) {
    final numValue = double.tryParse(value) ?? 0.0;
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    if (numValue > 0) {
      return colorScheme.chart2;
    }
    if (numValue < 0) {
      return colorScheme.destructive;
    }
    return colorScheme.mutedForeground;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      dayPnL,
      style: TextStyle(
        fontFamily: 'Geist',
        color: _getValueColor(dayPnL, context),
      ),
    );
  }
}

/// Day % Cell with WebSocket updates
class _DayPercentCell extends ConsumerStatefulWidget {
  final String token;
  final String initialValue;

  const _DayPercentCell({
    required this.token,
    required this.initialValue,
  });

  @override
  ConsumerState<_DayPercentCell> createState() => _DayPercentCellState();
}

class _DayPercentCellState extends ConsumerState<_DayPercentCell> {
  late String dayPercent;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    dayPercent = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newDayPercent = data[widget.token]['perChange']?.toString();
      if (newDayPercent != null && newDayPercent != dayPercent && newDayPercent != 'null') {
        setState(() => dayPercent = newDayPercent);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, BuildContext context) {
    final numValue = double.tryParse(value.replaceAll('%', '')) ?? 0.0;
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    if (numValue > 0) {
      return colorScheme.chart2;
    }
    if (numValue < 0) {
      return colorScheme.destructive;
    }
    return colorScheme.mutedForeground;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      dayPercent,
      style: TextStyle(
        fontFamily: 'Geist',
        color: _getValueColor(dayPercent, context),
      ),
    );
  }
}

/// Overall % Cell with WebSocket updates
class _OverallPercentCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final double avgPrice;
  final String initialValue;

  const _OverallPercentCell({
    required this.token,
    required this.qty,
    required this.avgPrice,
    required this.initialValue,
  });

  @override
  ConsumerState<_OverallPercentCell> createState() => _OverallPercentCellState();
}

class _OverallPercentCellState extends ConsumerState<_OverallPercentCell> {
  late String overallPercent;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    overallPercent = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newPercent = data[widget.token]['pNlChng']?.toString();
      if (newPercent != null && newPercent != overallPercent && newPercent != 'null') {
        setState(() => overallPercent = newPercent);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, BuildContext context) {
    final numValue = double.tryParse(value.replaceAll('%', '')) ?? 0.0;
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    if (numValue > 0) {
      return colorScheme.chart2;
    }
    if (numValue < 0) {
      return colorScheme.destructive;
    }
    return colorScheme.mutedForeground;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      overallPercent,
      style: TextStyle(
        fontFamily: 'Geist',
        color: _getValueColor(overallPercent, context),
      ),
    );
  }
}
