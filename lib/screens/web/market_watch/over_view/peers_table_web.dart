import 'dart:ui';
import 'package:flutter/material.dart'
    show
        InkWell,
        Icons,
        Icon,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        Row,
        MainAxisSize,
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
        LayoutBuilder,
        ValueKey,
        ValueNotifier,
        ValueListenableBuilder,
        RawScrollbar,
        Radius;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

/// Peers Comparison Table using shadcn table format
/// Shows stock and peers data with all metrics in columns
class PeersTableWeb extends ConsumerStatefulWidget {
  const PeersTableWeb({super.key});

  @override
  ConsumerState<PeersTableWeb> createState() => _PeersTableWebState();
}

class _PeersTableWebState extends ConsumerState<PeersTableWeb> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  // PERFORMANCE FIX: Use ValueNotifier for hover instead of setState
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

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
    _hoveredRowIndex.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // Standardized text style helpers
  TextStyle _getTextStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? MyntColors.textSecondaryDark,
      lightColor: color ?? MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  // Builds a cell with hover detection
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    bool isCurrentStock = false,
  }) {
    // Add extra horizontal padding for first and last columns
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 8;

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
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          child: child,
          builder: (context, hoveredIndex, cachedChild) {
            final isRowHovered = hoveredIndex == rowIndex;

            // Background color logic:
            // 1. Current stock gets a distinct background (always)
            // 2. Hover adds additional highlight
            Color? backgroundColor;
            if (isCurrentStock) {
              if (isRowHovered) {
                backgroundColor = resolveThemeColor(context,
                    dark: MyntColors.primaryDark.withValues(alpha: 0.15),
                    light: MyntColors.primary.withValues(alpha: 0.15));
              } else {
                backgroundColor = resolveThemeColor(context,
                    dark: MyntColors.primary.withValues(alpha: 0.10),
                    light: MyntColors.primary.withValues(alpha: 0.10));
              }
            } else if (isRowHovered) {
              backgroundColor = resolveThemeColor(context,
                  dark: MyntColors.primaryDark.withValues(alpha: 0.05),
                  light: MyntColors.primary.withValues(alpha: 0.05));
            }

            return Container(
              padding: cellPadding,
              color: backgroundColor,
              alignment: alignRight ? Alignment.topRight : null,
              child: cachedChild,
            );
          },
        ),
      ),
    );
  }


  // Builds a sortable header cell with sort indicator
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 8;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 6, 8, 6);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 6, 16, 6);
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
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
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
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
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

  // Helper method to clean symbol (remove exchange prefix and -EQ suffix)
  String _cleanSymbol(String? symbol) {
    if (symbol == null) return 'N/A';
    String cleaned = symbol.contains(':') ? symbol.split(':')[1] : symbol;
    return cleaned.replaceAll('-EQ', '');
  }

  // Helper method to format numbers
  String _formatValue(String? value) {
    if (value == null || value == 'null' || value == 'N/A') return 'N/A';
    final numValue = double.tryParse(value);
    if (numValue == null) return value;

    // Format with 2 decimal places for values with decimals
    if (numValue % 1 != 0) {
      return numValue.toStringAsFixed(2);
    }
    return numValue.toInt().toString();
  }

  // Helper method to format market cap
  String _formatMarketCap(String? marketCap) {
    if (marketCap == null || marketCap == 'null') return 'N/A';
    double value = double.tryParse(marketCap.replaceAll(',', '')) ?? 0;
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)}L Cr';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K Cr';
    } else {
      return '${value.toStringAsFixed(0)} Cr';
    }
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

  // Calculate minimum column widths dynamically based on header and data
  Map<int, double> _calculateMinWidths(
      List<Stock> allStocks, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'Symbol',
      'LTP',
      'Mkt Cap',
      'PE',
      'PB',
      'ROCE',
      'EV/EBITDA',
      'D/E',
      'Div Yield',
    ];

    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;

      // Measure header width
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth;

      // Measure widest value in this column
      for (final stock in allStocks) {
        String cellText = '';

        switch (col) {
          case 0: // Symbol
            cellText = _cleanSymbol(stock.sYMBOL);
            break;
          case 1: // LTP
            cellText = _formatValue(stock.ltp);
            break;
          case 2: // Market Cap
            cellText = _formatMarketCap(stock.marketCap);
            break;
          case 3: // PE
            cellText = _formatValue(stock.pe);
            break;
          case 4: // PB
            cellText = _formatValue(stock.priceBookValue);
            break;
          case 5: // ROCE
            cellText = '${_formatValue(stock.rocePercent)}%';
            break;
          case 6: // EV/EBITDA
            cellText = _formatValue(stock.evEbitda);
            break;
          case 7: // D/E
            cellText = _formatValue(stock.debtToEquity);
            break;
          case 8: // Div Yield
            cellText = '${_formatValue(stock.dividendYieldPercent)}%';
            break;
        }

        final cellWidth = _measureTextWidth(cellText, textStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      // Set minimum width
      minWidths[col] = maxWidth + padding;
    }

    return minWidths;
  }

  @override
  Widget build(BuildContext context) {
    final marketWatch = ref.watch(marketWatchProvider);

    // Combine stock and peers data - stock first, then peers
    final stockList = marketWatch.fundamentalData?.peersComparison?.stock ?? [];
    final peersList = marketWatch.fundamentalData?.peersComparison?.peers ?? [];

    // Ensure current stock appears first
    final allStocks = [...stockList, ...peersList];

    if (allStocks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort stocks based on selected column
    if (_sortColumnIndex != null) {
      allStocks.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: // Symbol
            comparison = _cleanSymbol(a.sYMBOL).compareTo(_cleanSymbol(b.sYMBOL));
            break;
          case 1: // LTP
            final ltpA = double.tryParse(a.ltp ?? '0') ?? 0.0;
            final ltpB = double.tryParse(b.ltp ?? '0') ?? 0.0;
            comparison = ltpA.compareTo(ltpB);
            break;
          case 2: // Market Cap
            final mcA = double.tryParse(a.marketCap?.replaceAll(',', '') ?? '0') ?? 0.0;
            final mcB = double.tryParse(b.marketCap?.replaceAll(',', '') ?? '0') ?? 0.0;
            comparison = mcA.compareTo(mcB);
            break;
          case 3: // PE
            final peA = double.tryParse(a.pe ?? '0') ?? 0.0;
            final peB = double.tryParse(b.pe ?? '0') ?? 0.0;
            comparison = peA.compareTo(peB);
            break;
          case 4: // PB
            final pbA = double.tryParse(a.priceBookValue ?? '0') ?? 0.0;
            final pbB = double.tryParse(b.priceBookValue ?? '0') ?? 0.0;
            comparison = pbA.compareTo(pbB);
            break;
          case 5: // ROCE
            final roceA = double.tryParse(a.rocePercent ?? '0') ?? 0.0;
            final roceB = double.tryParse(b.rocePercent ?? '0') ?? 0.0;
            comparison = roceA.compareTo(roceB);
            break;
          case 6: // EV/EBITDA
            final evA = double.tryParse(a.evEbitda ?? '0') ?? 0.0;
            final evB = double.tryParse(b.evEbitda ?? '0') ?? 0.0;
            comparison = evA.compareTo(evB);
            break;
          case 7: // D/E
            final deA = double.tryParse(a.debtToEquity ?? '0') ?? 0.0;
            final deB = double.tryParse(b.debtToEquity ?? '0') ?? 0.0;
            comparison = deA.compareTo(deB);
            break;
          case 8: // Div Yield
            final divA = double.tryParse(a.dividendYieldPercent ?? '0') ?? 0.0;
            final divB = double.tryParse(b.dividendYieldPercent ?? '0') ?? 0.0;
            comparison = divA.compareTo(divB);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    return shadcn.OutlinedContainer(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically
          final minWidths = _calculateMinWidths(allStocks, context);

          final availableWidth = constraints.maxWidth;

          // Start with minimum widths
          final columnWidths = <int, double>{};
          for (int i = 0; i < 9; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          // Calculate total minimum width needed
          final totalMinWidth = columnWidths.values
              .fold<double>(0.0, (sum, width) => sum + width);

          // Handle width adjustment
          if (totalMinWidth < availableWidth) {
            // Extra space available - distribute it proportionally
            final extraSpace = availableWidth - totalMinWidth;

            // Symbol gets more growth, numeric columns get standard growth
            const symbolGrowthFactor = 2.0;
            const numericGrowthFactor = 1.0;

            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 9; i++) {
              if (i == 0) {
                growthFactors[i] = symbolGrowthFactor;
                totalGrowthFactor += symbolGrowthFactor;
              } else {
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            // Distribute extra space
            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 9; i++) {
                final extraForThisColumn =
                    (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                columnWidths[i] = columnWidths[i]! + extraForThisColumn;
              }
            }
          } else if (totalMinWidth > availableWidth) {
            // Not enough space - shrink columns proportionally
            final excessWidth = totalMinWidth - availableWidth;

            final absoluteMinWidths = <int, double>{
              0: 100.0, // Symbol
              1: 60.0,  // LTP
              2: 80.0,  // Mkt Cap
              3: 50.0,  // PE
              4: 50.0,  // PB
              5: 60.0,  // ROCE
              6: 80.0,  // EV/EBITDA
              7: 50.0,  // D/E
              8: 70.0,  // Div Yield
            };

            final shrinkableAmounts = <int, double>{};
            double totalShrinkable = 0.0;

            for (int i = 0; i < 9; i++) {
              final currentWidth = columnWidths[i]!;
              final absoluteMin = absoluteMinWidths[i] ?? 50.0;
              final shrinkable = currentWidth - absoluteMin;
              if (shrinkable > 0) {
                shrinkableAmounts[i] = shrinkable;
                totalShrinkable += shrinkable;
              } else {
                shrinkableAmounts[i] = 0.0;
              }
            }

            if (totalShrinkable > 0) {
              final shrinkFactor = excessWidth < totalShrinkable
                  ? excessWidth / totalShrinkable
                  : 1.0;

              for (int i = 0; i < 9; i++) {
                if (shrinkableAmounts[i]! > 0) {
                  final shrinkAmount = shrinkableAmounts[i]! * shrinkFactor;
                  columnWidths[i] = columnWidths[i]! - shrinkAmount;
                }
              }
            }
          }

          final totalRequiredWidth = columnWidths.values
              .fold<double>(0.0, (sum, width) => sum + width);

          final needsHorizontalScroll = totalRequiredWidth > availableWidth;

          // Build table content
          Widget buildTableContent() {
            return Column(
              mainAxisSize: MainAxisSize.min,
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
                    8: shadcn.FixedTableSize(columnWidths[8]!),
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(50),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Symbol', 0),
                        buildHeaderCell('LTP', 1, true),
                        buildHeaderCell('Mkt Cap', 2, true),
                        buildHeaderCell('PE', 3, true),
                        buildHeaderCell('PB', 4, true),
                        buildHeaderCell('ROCE', 5, true),
                        buildHeaderCell('EV/EBITDA', 6, true),
                        buildHeaderCell('D/E', 7, true),
                        buildHeaderCell('Div Yield', 8, true),
                      ],
                    ),
                  ],
                ),
                // Table Body - No scroll, let it expand naturally
                shadcn.Table(
                        key: ValueKey('peers_table_${_sortColumnIndex}_$_sortAscending'),
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
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: [
                          // Data Rows
                          ...allStocks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stock = entry.value;

                            // Check if this is the current stock (from stockList)
                            final isCurrentStock = stockList.contains(stock);

                            return shadcn.TableRow(
                              cells: [
                                // Symbol
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 0,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _cleanSymbol(stock.sYMBOL),
                                      style: _getTextStyle(context).copyWith(
                                        fontWeight: MyntFonts.medium,
                                        color: isCurrentStock
                                            ? resolveThemeColor(context,
                                                dark: MyntColors.textPrimaryDark,
                                                light: MyntColors.textPrimary)
                                            : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // LTP
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 1,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatValue(stock.ltp),
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                                // Market Cap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 2,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatMarketCap(stock.marketCap),
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                                // PE
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 3,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatValue(stock.pe),
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                                // PB
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 4,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatValue(stock.priceBookValue),
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                                // ROCE
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 5,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${_formatValue(stock.rocePercent)}%',
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                                // EV/EBITDA
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 6,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatValue(stock.evEbitda),
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                                // D/E
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 7,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatValue(stock.debtToEquity),
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                                // Div Yield
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 8,
                                  alignRight: true,
                                  isCurrentStock: isCurrentStock,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${_formatValue(stock.dividendYieldPercent)}%',
                                      style: _getTextStyle(context),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                ),
              ],
            );
          }

          // Wrap in horizontal scroll if needed
          if (needsHorizontalScroll) {
            return RawScrollbar(
              controller: _horizontalScrollController,
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
}
