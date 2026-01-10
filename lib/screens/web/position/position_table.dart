import 'dart:async';
import 'package:flutter/material.dart' show InkWell, Icons, VoidCallback, BorderRadius, Icon, BoxDecoration, TextPainter, TextSpan, TextStyle, TextDirection, GestureDetector, HitTestBehavior, Row, MainAxisSize, SizedBox, Colors, Widget, BuildContext, Color, EdgeInsets, Alignment, MainAxisAlignment, TextOverflow, Axis, FontWeight, Container, MouseRegion, Expanded, Align, Text, AnimatedOpacity, ScrollController, SingleChildScrollView, Scrollbar, Column, ValueKey, IconData, Padding, LayoutBuilder, showDialog, RichText, Stack, LinearGradient, BoxConstraints, Clip, MediaQuery, Builder, Tooltip, Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../utils/responsive_navigation.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import 'position_detail_screen_web.dart';
import 'convert_position_dialogue_web.dart';

// Shadcn Table for Positions with WebSocket updates
class PositionTable extends ConsumerStatefulWidget {
  final String? searchQuery;
  
  const PositionTable({super.key, this.searchQuery});

  @override
  ConsumerState<PositionTable> createState() => _PositionTableState();
}

class _PositionTableState extends ConsumerState<PositionTable> {
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

  // Helper method to format instrument display text (without exchange - exchange shown separately)
  String _formatInstrumentText(PositionBookModel position) {
    // Use tsym directly if available (remove -EQ, but don't include exchange - it's shown separately)
    if (position.tsym != null && position.tsym!.isNotEmpty) {
      return position.tsym!.replaceAll("-EQ", "").trim();
    }
    
    // Fallback: build from components if tsym is not available
    final symbol = (position.symbol ?? '').replaceAll("-EQ", "").trim();
    final expDate = position.expDate ?? '';
    final option = position.option ?? '';
    
    // Build display text: symbol + expDate + option (no exchange - shown separately in UI)
    String displayText = symbol;
    if (expDate.isNotEmpty) {
      displayText += expDate;
    }
    if (option.isNotEmpty) {
      displayText += option;
    }
    return displayText;
  }

  // Builds a cell with hover detection
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0; // Select checkbox column
    final isInstrumentColumn = columnIndex == 1; // Instrument column
    final isLastColumn = columnIndex == 12;
    
    // Match the cell padding logic - Instrument column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    // Select column (checkbox) uses symmetric padding
    EdgeInsets cellPadding;
    if (isFirstColumn) {
      // Select column - symmetric padding for checkbox
      cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
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

  // Helper method to get theme-aware colors for positive/negative/neutral values
  Color _getValueColor(double value, BuildContext context) {
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
  shadcn.TableCell buildHeaderCell(String label, int columnIndex, ThemesProvider theme, [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0; // Select checkbox column
    final isInstrumentColumn = columnIndex == 1; // Instrument column
    final isLastColumn = columnIndex == 12;
    
    // Match the cell padding logic - Instrument column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    // Select column (checkbox) uses symmetric padding
    EdgeInsets headerPadding;
    if (isFirstColumn) {
      // Select column - symmetric padding for checkbox
      headerPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
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
                style: _geistTextStyle(),
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


  // Get column index for header
  int _getColumnIndexForHeader(String header) {
    switch (header) {
      case 'Select': return 0;
      case 'Instrument': return 1;
      case 'Product': return 2;
      case 'Qty': return 3;
      case 'Act Avg Price': return 4;
      case 'LTP': return 5;
      case 'P&L': return 6;
      case 'MTM': return 7;
      case 'Avg Price': return 8;
      case 'Buy Qty': return 9;
      case 'Sell Qty': return 10;
      case 'Buy Avg': return 11;
      case 'Sell Avg': return 12;
      default: return -1;
    }
  }

  // Check if column is numeric
  bool _isNumericColumn(String header) {
    return header != 'Select' && header != 'Instrument' && header != 'Product';
  }

  // Format quantity
  String _formatQty(String qty) {
    final numQty = int.tryParse(qty) ?? 0;
    return numQty > 0 ? '+$qty' : qty;
  }

  // Check if position is closed
  bool _isPositionClosed(PositionBookModel position) {
    final qty = int.tryParse(position.qty ?? '0') ?? 0;
    return qty == 0;
  }

  // Get position text color
  // Get quantity color
  Color _getQtyColor(String qty, BuildContext context) {
    final numQty = int.tryParse(qty) ?? 0;
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    if (numQty > 0) {
      return colorScheme.chart2;
    } else if (numQty < 0) {
      return colorScheme.destructive;
    } else {
      return colorScheme.mutedForeground;
    }
  }

  // Filter and sort positions
  List<PositionBookModel> _getFilteredPositions(List<PositionBookModel> positions) {
    List<PositionBookModel> filtered = positions.toList();

    // Apply search filter
    final searchQuery = widget.searchQuery?.toLowerCase().trim() ?? '';
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((position) {
        final symbol = position.symbol?.toLowerCase() ?? '';
        final exch = position.exch?.toLowerCase() ?? '';
        return symbol.contains(searchQuery) || exch.contains(searchQuery);
      }).toList();
    }

    // Apply sorting
    if (_sortColumnIndex != null) {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 1: // Instrument
            comparison = '${a.symbol ?? ''} ${a.exch ?? ''}'
                .compareTo('${b.symbol ?? ''} ${b.exch ?? ''}');
            break;
          case 2: // Product
            comparison = (a.sPrdtAli ?? '').compareTo(b.sPrdtAli ?? '');
            break;
          case 3: // Qty
            comparison = (int.tryParse(a.qty ?? '0') ?? 0)
                .compareTo(int.tryParse(b.qty ?? '0') ?? 0);
            break;
          case 4: // Act Avg Price
            comparison = (double.tryParse(a.avgPrc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.avgPrc ?? '0') ?? 0);
            break;
          case 5: // LTP
            comparison = (double.tryParse(a.lp ?? '0') ?? 0)
                .compareTo(double.tryParse(b.lp ?? '0') ?? 0);
            break;
          case 6: // P&L
            comparison = (double.tryParse(a.profitNloss ?? '0') ?? 0)
                .compareTo(double.tryParse(b.profitNloss ?? '0') ?? 0);
            break;
          case 7: // MTM
            comparison = (double.tryParse(a.mTm ?? '0') ?? 0)
                .compareTo(double.tryParse(b.mTm ?? '0') ?? 0);
            break;
          case 8: // Avg Price
            comparison = (double.tryParse(a.avgPrc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.avgPrc ?? '0') ?? 0);
            break;
          case 9: // Buy Qty
            comparison = (int.tryParse(a.daybuyqty ?? '0') ?? 0)
                .compareTo(int.tryParse(b.daybuyqty ?? '0') ?? 0);
            break;
          case 10: // Sell Qty
            comparison = (int.tryParse(a.daysellqty ?? '0') ?? 0)
                .compareTo(int.tryParse(b.daysellqty ?? '0') ?? 0);
            break;
          case 11: // Buy Avg
            comparison = (double.tryParse(a.daybuyavgprc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.daybuyavgprc ?? '0') ?? 0);
            break;
          case 12: // Sell Avg
            comparison = (double.tryParse(a.daysellavgprc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.daysellavgprc ?? '0') ?? 0);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
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
  Map<int, double> _calculateMinWidths(List<PositionBookModel> positions, BuildContext context) {
    // Use fixed font size for measurement (table text is not responsive, only buttons are)
    final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
    const padding = 24.0;
    const sortIconWidth = 24.0;

    // Header texts - ALL columns always shown (like holdings table)
    final headers = [
      'Select',
      'Instrument',
      'Product',
      'Qty',
      'Act Avg Price',
      'LTP',
      'P&L',
      'MTM',
      'Avg Price',
      'Buy Qty',
      'Sell Qty',
      'Buy Avg',
      'Sell Avg',
    ];

    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;
      final header = headers[col];
      
      // Special handling for Select column (checkbox)
      if (header == 'Select') {
        // Checkbox size (18px) + padding on both sides (12px each) + safety margin = 70px minimum
        minWidths[col] = 70.0;
        continue;
      }
      
      // Measure header width and add space for sort icon
      final headerWidth = _measureTextWidth(header, textStyle);
      maxWidth = headerWidth + sortIconWidth;

      // Measure widest value in this column
      for (final position in positions) {
        String cellText = '';
        
        switch (header) {
          case 'Instrument':
            // For Instrument column, measure symbol + exchange separately
            // since exchange uses smaller font
            final symbolText = _formatInstrumentText(position);
            final exchangeText = (position.exch != null && position.exch!.isNotEmpty && 
                (position.expDate == null || position.expDate!.isEmpty)) 
                ? ' ${position.exch}' 
                : '';
            
            // Measure symbol with normal font
            final symbolWidth = _measureTextWidth(symbolText, textStyle);
            
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
          case 'Product':
            cellText = position.sPrdtAli ?? 'N/A';
            break;
          case 'Qty':
            cellText = _formatQty(position.qty ?? '0');
            break;
          case 'Act Avg Price':
            cellText = position.avgPrc ?? '0.00';
            break;
          case 'LTP':
            cellText = position.lp ?? '0.00';
            break;
          case 'P&L':
            cellText = position.profitNloss ?? '0.00';
            break;
          case 'MTM':
            cellText = position.mTm ?? '0.00';
            break;
          case 'Avg Price':
            cellText = position.avgPrc ?? '0.00';
            break;
          case 'Buy Qty':
            cellText = position.daybuyqty ?? '0';
            break;
          case 'Sell Qty':
            cellText = position.daysellqty ?? '0';
            break;
          case 'Buy Avg':
            cellText = position.daybuyavgprc ?? '0.00';
            break;
          case 'Sell Avg':
            cellText = position.daysellavgprc ?? '0.00';
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
      if (header == 'Instrument') {
        const minInstrumentWidth = 150.0;
        maxWidth = maxWidth < minInstrumentWidth ? minInstrumentWidth : maxWidth;
      }

      minWidths[col] = maxWidth + padding;
    }

    return minWidths;
  }

  @override
  Widget build(BuildContext context) {
    final portfolioData = ref.watch(portfolioProvider);
    final positions = portfolioData.allPostionList.isNotEmpty 
        ? portfolioData.allPostionList 
        : portfolioData.openPosition ?? [];
    final theme = ref.read(themeProvider);
    final positionBook = ref.read(portfolioProvider);

    // Filter and sort positions
    final filteredPositions = _getFilteredPositions(positions);

    if (filteredPositions.isEmpty) {
      return shadcn.OutlinedContainer(
        child: NoDataFound(
          title: widget.searchQuery?.isNotEmpty == true 
              ? "No Positions Found" 
              : "No Positions",
          subtitle: widget.searchQuery?.isNotEmpty == true
              ? "No positions match your search \"${widget.searchQuery}\"."
              : "You don't have any positions yet.",
          primaryEnabled: false,
          secondaryEnabled: false,
        ),
      );
    }

    // Define ALL columns always (like holdings table)
    final headers = [
      'Select',
      'Instrument',
      'Product',
      'Qty',
      'Act Avg Price',
      'LTP',
      'P&L',
      'MTM',
      'Avg Price',
      'Buy Qty',
      'Sell Qty',
      'Buy Avg',
      'Sell Avg',
    ];

    return shadcn.OutlinedContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(filteredPositions, context);

          // Available width
          final availableWidth = constraints.maxWidth;
          
          // Step 1: Start with minimum widths (content-based, no wasted space)
          final columnWidths = <int, double>{};
          for (int i = 0; i < headers.length; i++) {
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
            const instrumentGrowthFactor = 2.0; // Instrument can grow 2x more than numeric
            const numericGrowthFactor = 1.0;
            
            // Calculate growth factors for each column
            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;
            
            for (int i = 0; i < headers.length; i++) {
              final header = headers[i];
              if (header == 'Select') {
                // Select column doesn't grow (checkbox needs fixed space)
                growthFactors[i] = 0.0;
              } else if (header == 'Instrument') {
                growthFactors[i] = instrumentGrowthFactor;
                totalGrowthFactor += instrumentGrowthFactor;
              } else {
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }
            
            // Distribute extra space proportionally
            if (totalGrowthFactor > 0) {
              for (int i = 0; i < headers.length; i++) {
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
            return Column(
              children: [
                // Fixed Header (synced with horizontal scroll)
                shadcn.Table(
                  columnWidths: columnWidths.map((index, width) {
                    return MapEntry(index, shadcn.FixedTableSize(width));
                  }),
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: headers.map((header) {
                        final columnIndex = _getColumnIndexForHeader(header);
                        final isNumeric = _isNumericColumn(header);
                        
                        // Special handling for Select column
                        if (header == 'Select') {
                          return _buildSelectHeaderCell(theme, positionBook, filteredPositions);
                        }
                        
                        return buildHeaderCell(header, columnIndex, theme, isNumeric);
                      }).toList(),
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
                        columnWidths: columnWidths.map((index, width) {
                          return MapEntry(index, shadcn.FixedTableSize(width));
                        }),
                        defaultRowHeight: const shadcn.FixedTableSize(40),
                        rows: filteredPositions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final position = entry.value;
                          final isClosed = _isPositionClosed(position);
                          final isRowHovered = _hoveredRowIndex == index;

                          return shadcn.TableRow(
                            cells: headers.map((header) {
                              final columnIndex = _getColumnIndexForHeader(header);
                              final isNumeric = _isNumericColumn(header);
                              
                              // Make cells clickable except Select (checkbox) and Instrument (has buttons)
                              final isClickable = header != 'Select' && header != 'Instrument';
                              
                              return buildCellWithHover(
                                rowIndex: index,
                                columnIndex: columnIndex,
                                alignRight: isNumeric,
                                child: isClickable
                                    ? GestureDetector(
                                        onTap: () => _showPositionDetail(position),
                                        behavior: HitTestBehavior.opaque,
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: _buildCellContent(
                                            context,
                                            header,
                                            position,
                                            theme,
                                            isClosed,
                                            isRowHovered,
                                            positionBook,
                                          ),
                                        ),
                                      )
                                    : _buildCellContent(
                                        context,
                                        header,
                                        position,
                                        theme,
                                        isClosed,
                                        isRowHovered,
                                        positionBook,
                                      ),
                              );
                            }).toList(),
                          );
                        }).toList(),
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

  // Build select header cell with checkbox
  shadcn.TableCell _buildSelectHeaderCell(
    ThemesProvider theme,
    PortfolioProvider positionBook,
    List<PositionBookModel> filteredPositions,
  ) {
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
      child: Consumer(
        builder: (context, ref, child) {
          final isExitAllPosition = ref.watch(portfolioProvider.select((p) => p.isExitAllPosition));
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            alignment: Alignment.centerLeft,
            child: shadcn.Checkbox(
              state: isExitAllPosition
                  ? shadcn.CheckboxState.checked
                  : shadcn.CheckboxState.unchecked,
              onChanged: filteredPositions.isNotEmpty
                  ? (state) {
                      positionBook.selectExitAllPosition(
                          state == shadcn.CheckboxState.checked);
                    }
                  : null,
              enabled: filteredPositions.isNotEmpty,
              activeColor: theme.isDarkMode
                  ? WebDarkColors.primary
                  : WebColors.primary,
              borderRadius: BorderRadius.circular(4),
              size: 18,
            ),
          );
        },
      ),
    );
  }

  // Build cell content based on column
  Widget _buildCellContent(
    BuildContext context,
    String header,
    PositionBookModel position,
    ThemesProvider theme,
    bool isClosed,
    bool isRowHovered,
    PortfolioProvider positionBook,
  ) {
    final isNumeric = _isNumericColumn(header);
    final alignment = isNumeric ? Alignment.centerRight : Alignment.centerLeft;
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final textColor = isClosed 
        ? colorScheme.mutedForeground 
        : colorScheme.foreground;

    switch (header) {
      case 'Select':
        return _buildCheckboxCell(position, theme, isClosed, positionBook);
      case 'Instrument':
        return _buildInstrumentCell(context, position, theme, isClosed, isRowHovered, positionBook);
      case 'Product':
        return Align(
          alignment: alignment,
          child: Text(
            position.sPrdtAli ?? 'N/A',
            style: _geistTextStyle(
              color: textColor,
            ),
          ),
        );
      case 'Qty':
        return Align(
          alignment: alignment,
          child: Text(
            _formatQty(position.qty ?? '0'),
            style: _geistTextStyle(
              color: isClosed ? colorScheme.mutedForeground : _getQtyColor(position.qty ?? '0', context),
            ),
          ),
        );
      case 'Act Avg Price':
        return Align(
          alignment: alignment,
          child: Text(
            position.avgPrc ?? '0.00',
            style: _geistTextStyle(
              color: textColor,
            ),
          ),
        );
      case 'LTP':
        if (position.token == null || position.token!.isEmpty) {
          return Align(
            alignment: alignment,
            child: Text(
              position.lp ?? '0.00',
              style: _geistTextStyle(
                color: textColor,
              ),
            ),
          );
        } else {
          return Align(
            alignment: alignment,
            child: _LTPCell(
              token: position.token!,
              initialLtp: position.lp ?? '0.00',
            ),
          );
        }
      case 'P&L':
        if (position.token == null || position.token!.isEmpty) {
          return Align(
            alignment: alignment,
            child: Text(
              position.profitNloss ?? '0.00',
              style: _geistTextStyle(
                color: isClosed
                    ? colorScheme.mutedForeground
                    : _getValueColor(double.tryParse(position.profitNloss ?? '0') ?? 0.0, context),
              ),
            ),
          );
        } else {
          final qty = int.tryParse(position.qty ?? '0') ?? 0;
          final avgPrice = double.tryParse(position.avgPrc ?? '0') ?? 0.0;
          return Align(
            alignment: alignment,
            child: _PnLCell(
              token: position.token!,
              qty: qty,
              avgPrice: avgPrice,
              initialValue: position.profitNloss ?? '0.00',
              isClosed: isClosed,
            ),
          );
        }
      case 'MTM':
        if (position.token == null || position.token!.isEmpty) {
          return Align(
            alignment: alignment,
            child: Text(
              position.mTm ?? '0.00',
              style: _geistTextStyle(
                color: isClosed
                    ? colorScheme.mutedForeground
                    : _getValueColor(double.tryParse(position.mTm ?? '0') ?? 0.0, context),
              ),
            ),
          );
        } else {
          final qty = int.tryParse(position.qty ?? '0') ?? 0;
          final avgPrice = double.tryParse(position.avgPrc ?? '0') ?? 0.0;
          return Align(
            alignment: alignment,
            child: _MTMCell(
              token: position.token!,
              qty: qty,
              avgPrice: avgPrice,
              initialValue: position.mTm ?? '0.00',
              isClosed: isClosed,
            ),
          );
        }
      case 'Avg Price':
        return Align(
          alignment: alignment,
          child: Text(
            position.avgPrc ?? '0.00',
            style: _geistTextStyle(
              color: textColor,
            ),
          ),
        );
      case 'Buy Qty':
        return Align(
          alignment: alignment,
          child: Text(
            position.daybuyqty ?? '0',
            style: _geistTextStyle(
              color: textColor,
            ),
          ),
        );
      case 'Sell Qty':
        return Align(
          alignment: alignment,
          child: Text(
            position.daysellqty ?? '0',
            style: _geistTextStyle(
              color: textColor,
            ),
          ),
        );
      case 'Buy Avg':
        return Align(
          alignment: alignment,
          child: Text(
            position.daybuyavgprc ?? '0.00',
            style: _geistTextStyle(
              color: textColor,
            ),
          ),
        );
      case 'Sell Avg':
        return Align(
          alignment: alignment,
          child: Text(
            position.daysellavgprc ?? '0.00',
            style: _geistTextStyle(
              color: textColor,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Build checkbox cell
  Widget _buildCheckboxCell(
    PositionBookModel position,
    ThemesProvider theme,
    bool isClosed,
    PortfolioProvider positionBook,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final openPositions = ref.watch(portfolioProvider.select((p) => p.openPosition ?? []));
        final positionIndex = openPositions.indexWhere((p) => p.token == position.token);
        final isSelected = positionIndex >= 0 
            ? (openPositions[positionIndex].isExitSelection ?? false)
            : (position.isExitSelection ?? false);
        
        return Align(
          alignment: Alignment.centerLeft,
          child: shadcn.Checkbox(
            state: isSelected
                ? shadcn.CheckboxState.checked
                : shadcn.CheckboxState.unchecked,
            onChanged: isClosed
                ? null
                : (state) {
                    if (positionIndex >= 0) {
                      positionBook.selectExitPosition(positionIndex);
                    }
                  },
            enabled: !isClosed,
            activeColor: theme.isDarkMode
                ? WebDarkColors.primary
                : WebColors.primary,
            borderRadius: BorderRadius.circular(4),
            size: 18,
          ),
        );
      },
    );
  }

  // Build instrument cell with hover actions
  Widget _buildInstrumentCell(
    BuildContext context,
    PositionBookModel position,
    ThemesProvider theme,
    bool isClosed,
    bool isRowHovered,
    PortfolioProvider positionBook,
  ) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final textColor = isClosed 
        ? colorScheme.mutedForeground 
        : colorScheme.foreground;

    return GestureDetector(
      onTap: () => _showPositionDetail(position),
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
                message: '${_formatInstrumentText(position)}${position.exch != null && position.exch!.isNotEmpty && (position.expDate == null || position.expDate!.isEmpty) ? ' ${position.exch}' : ''}',
                child: Padding(
                  padding: EdgeInsets.only(right: isRowHovered ? 8.0 : 0.0),
                  child: RichText(
                    overflow: isRowHovered ? TextOverflow.ellipsis : TextOverflow.visible,
                    maxLines: 1,
                    softWrap: false,
                    text: TextSpan(
                      children: [
                        // Symbol/Instrument (from tsym or built from components, fixed 14px)
                        TextSpan(
                          text: _formatInstrumentText(position),
                          style: _geistTextStyle(
                            color: textColor,
                            fontSize: 14.0,
                          ),
                        ),
                        // Exchange (mutedForeground color, smaller font, fixed 12px) - show for equity stocks
                        if (position.exch != null && position.exch!.isNotEmpty && 
                            (position.expDate == null || position.expDate!.isEmpty))
                          TextSpan(
                            text: ' ${position.exch}',
                            style: _geistTextStyle(
                              color: colorScheme.mutedForeground,
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
                                colorScheme.background.withOpacity(0.0),
                                colorScheme.background.withOpacity(0.95),
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
                                  if (!isClosed &&
                                      position.qty != "0" &&
                                      position.sPrdtAli != "BO" &&
                                      position.sPrdtAli != "CO" &&
                                      !positionBook.isDay) ...[
                                    _buildHoverButton(
                                      context: buttonContext,
                                      theme: theme,
                                      label: 'Add',
                                      onPressed: () => _handleAddPosition(position),
                                      backgroundColor: theme.isDarkMode
                                          ? WebDarkColors.primary
                                          : WebColors.primary,
                                      textColor: Colors.white,
                                    ),
                                    SizedBox(width: buttonSpacing),
                                    _buildHoverButton(
                                      context: buttonContext,
                                      theme: theme,
                                      label: 'Exit',
                                      onPressed: () => _handleExitPosition(position),
                                      backgroundColor: theme.isDarkMode
                                          ? WebDarkColors.tertiary
                                          : WebColors.tertiary,
                                      textColor: Colors.white,
                                    ),
                                    SizedBox(width: buttonSpacing),
                                  ],
                                  _buildHoverButton(
                                    context: buttonContext,
                                    theme: theme,
                                    icon: Icons.bar_chart,
                                    onPressed: () => _handleChartTap(position),
                                    backgroundColor: Colors.white,
                                    iconColor: Colors.black,
                                  ),
                                  if (!isClosed && position.qty != "0") ...[
                                    SizedBox(width: buttonSpacing),
                                    _buildHoverButton(
                                      context: buttonContext,
                                      theme: theme,
                                      icon: Icons.swap_horiz,
                                      onPressed: () => _handleConvertPosition(position),
                                      backgroundColor: Colors.white,
                                      iconColor: Colors.black,
                                    ),
                                  ],
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
    );
  }

  // Build hover button
  Widget _buildHoverButton({
    required BuildContext context,
    required ThemesProvider theme,
    String? label,
    IconData? icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
  }) {
    final borderRadiusValue = 5.0;
    final isDark = theme.isDarkMode;
    
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
                color: iconColor ?? (isDark 
                    ? shadcn.Theme.of(context).colorScheme.foreground
                    : shadcn.Theme.of(context).colorScheme.foreground),
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
                    color: textColor ?? (isDark
                        ? shadcn.Theme.of(context).colorScheme.foreground
                        : shadcn.Theme.of(context).colorScheme.foreground),
                        fontWeight: WebFonts.bold,
                  ).copyWith(fontSize: fontSize),
                ),
              ),
            ),
    );
  }

  // Show position detail - Using shadcn.openSheet like holdings
  void _showPositionDetail(PositionBookModel position) {
    // Save parent context to pass to sheet
    final parentCtx = context;
    
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) => PositionDetailScreenWeb(
        positionList: position,
        parentContext: parentCtx, // Pass parent context for navigation
      ),
      position: shadcn.OverlayPosition.end,
    );
  }

  // Handle chart tap
  Future<void> _handleChartTap(PositionBookModel position) async {
    final scripData = ref.read(marketWatchProvider);
    await scripData.fetchScripQuoteIndex(
      position.token ?? "",
      position.exch ?? "",
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

  // Handle exit position
  Future<void> _handleExitPosition(PositionBookModel position) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      await scripData.fetchScripInfo(
        position.token ?? "",
        position.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final netQty = int.tryParse(position.netqty ?? "0") ?? 0;
      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: position.exch ?? "",
        tSym: position.tsym ?? "",
        isExit: true,
        token: position.token ?? "",
        transType: netQty < 0 ? true : false,
        prd: position.prd ?? "",
        lotSize: position.netqty ?? "",
        ltp: position.lp ?? "0.00",
        perChange: position.perChange ?? "0.00",
        orderTpye: '',
        holdQty: position.netqty ?? '',
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
          context, "Error exiting position: ${e.toString()}");
    }
  }

  // Handle add position
  Future<void> _handleAddPosition(PositionBookModel position) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      await scripData.fetchScripInfo(
        position.token ?? "",
        position.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";
      final netQty = int.tryParse(position.netqty ?? "0") ?? 0;

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: position.exch ?? "",
        tSym: position.tsym ?? "",
        isExit: false,
        token: position.token ?? "",
        transType: netQty < 0 ? false : true,
        prd: position.prd ?? "",
        lotSize: lotSize,
        ltp: position.lp ?? "0.00",
        perChange: position.perChange ?? "0.00",
        orderTpye: '',
        holdQty: position.netqty ?? '',
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
          context, "Error adding position: ${e.toString()}");
    }
  }

  // Handle convert position
  void _handleConvertPosition(PositionBookModel position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConvertPositionDialogueWeb(convertPosition: position);
      },
    );
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
      style: const TextStyle(fontFamily: 'Geist'),
    );
  }
}

/// P&L Cell with WebSocket updates
class _PnLCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final double avgPrice;
  final String initialValue;
  final bool isClosed;

  const _PnLCell({
    required this.token,
    required this.qty,
    required this.avgPrice,
    required this.initialValue,
    required this.isClosed,
  });

  @override
  ConsumerState<_PnLCell> createState() => _PnLCellState();
}

class _PnLCellState extends ConsumerState<_PnLCell> {
  late String pnl;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    pnl = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        final newPnL = ((ltp - widget.avgPrice) * widget.qty).toStringAsFixed(2);
        if (newPnL != pnl) {
          setState(() => pnl = newPnL);
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
    } else if (numValue < 0) {
      return colorScheme.destructive;
    } else {
      return colorScheme.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      pnl,
      style: TextStyle(
        fontFamily: 'Geist',
        color: widget.isClosed
            ? Colors.grey
            : _getValueColor(pnl, context),
      ),
    );
  }
}

/// MTM Cell with WebSocket updates
class _MTMCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final double avgPrice;
  final String initialValue;
  final bool isClosed;

  const _MTMCell({
    required this.token,
    required this.qty,
    required this.avgPrice,
    required this.initialValue,
    required this.isClosed,
  });

  @override
  ConsumerState<_MTMCell> createState() => _MTMCellState();
}

class _MTMCellState extends ConsumerState<_MTMCell> {
  late String mtm;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    mtm = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        final newMtm = ((ltp - widget.avgPrice) * widget.qty).toStringAsFixed(2);
        if (newMtm != mtm) {
          setState(() => mtm = newMtm);
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
    } else if (numValue < 0) {
      return colorScheme.destructive;
    } else {
      return colorScheme.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      mtm,
      style: TextStyle(
        fontFamily: 'Geist',
        color: widget.isClosed
            ? Colors.grey
            : _getValueColor(mtm, context),
      ),
    );
  }
}

