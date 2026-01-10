import 'dart:async';
import 'package:flutter/material.dart' show InkWell, Icons, VoidCallback, BorderRadius, Icon, BoxDecoration, TextPainter, TextSpan, TextStyle, TextDirection, GestureDetector, HitTestBehavior, Row, SizedBox, Text, Align, TextOverflow, Alignment, FontWeight, Container, SingleChildScrollView, Axis, Colors, LayoutBuilder, Center, BuildContext, Widget, ValueKey, Scrollbar, EdgeInsets, Color, IconData, MainAxisAlignment, MouseRegion, showDialog, ScrollController, Expanded, Column, WidgetsBinding, CircularProgressIndicator, Padding, Stack, LinearGradient, BoxConstraints, Clip, MediaQuery, Builder, Tooltip, Visibility, AnimatedOpacity;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/no_data_found.dart';
import 'mf_holding_detail_screen_web.dart';
import '../ordersbook/mf/redeem_bottom_sheet_web.dart';

// Shadcn Table for Mutual Funds Holdings
class MfTableExample extends ConsumerStatefulWidget {
  final String? searchQuery;
  
  const MfTableExample({super.key, this.searchQuery});

  @override
  ConsumerState<MfTableExample> createState() => _MfTableExampleState();
}

class _MfTableExampleState extends ConsumerState<MfTableExample> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int? _hoveredRowIndex;

  // Helper method to ensure Geist font is always applied
  TextStyle _geistTextStyle({Color? color, double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontFamily: 'Geist',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch mutual fund holdings data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).fetchmfholdingnew();
    });
  }

  // Builds a cell with hover detection that covers the entire cell including padding
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0; // Fund Name column
    final isLastColumn = columnIndex == 7; // P&L % column
    
    // Match the cell padding logic - Fund Name column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets cellPadding;
    if (isFirstColumn) {
      // Fund Name column - more left, minimal right (for overlay buttons)
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
    final isFirstColumn = columnIndex == 0; // Fund Name column
    final isLastColumn = columnIndex == 7; // P&L % column
    
    // Match the cell padding logic - Fund Name column has more left, minimal right
    // Last column mirrors this - minimal left, more right
    EdgeInsets headerPadding;
    if (isFirstColumn) {
      // Fund Name column - more left, minimal right
      headerPadding = const EdgeInsets.fromLTRB(16, 8, 4, 8);
    } else if (isLastColumn) {
      // Last column - minimal left, more right
      headerPadding = const EdgeInsets.fromLTRB(4, 8, 16, 8);
    } else {
      // Other columns - symmetric padding
      headerPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
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
  Map<int, double> _calculateMinWidths(List<dynamic> holdings, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0;
    const sortIconWidth = 24.0; // Extra space for sort indicator icon (16px icon + 4px gap + buffer)

    // Header texts
    final headers = [
      'Fund Name',
      'Units',
      'Avg NAV',
      'Current NAV',
      'Invested',
      'Current Value',
      'P&L',
      'P&L %',
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
        String cellText = '';

        switch (col) {
          case 0: // Fund Name
            cellText = holding.name ?? 'N/A';
            break;
          case 1: // Units
            cellText = holding.avgQty ?? '0';
            break;
          case 2: // Avg NAV
            cellText = holding.avgNav ?? '0.00';
            break;
          case 3: // Current NAV
            cellText = holding.curNav ?? '0.00';
            break;
          case 4: // Invested
            final invested = double.tryParse(holding.investedValue ?? '0') ?? 0.0;
            cellText = invested.toStringAsFixed(2);
            break;
          case 5: // Current Value
            final currentValue = double.tryParse(holding.currentValue ?? '0') ?? 0.0;
            cellText = currentValue.toStringAsFixed(2);
            break;
          case 6: // P&L
            cellText = holding.profitLoss ?? '0.00';
            break;
          case 7: // P&L %
            cellText = '${holding.changeprofitLoss ?? '0.00'}%';
            break;
        }

        final cellWidth = _measureTextWidth(cellText, textStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      // For Fund Name column, ensure minimum width to prevent excessive truncation
      if (headers[col] == 'Fund Name') {
        const minFundNameWidth = 150.0;
        maxWidth = maxWidth < minFundNameWidth ? minFundNameWidth : maxWidth;
      }

      // Set minimum width (max of header/data + padding)
      minWidths[col] = maxWidth + padding;
    }

    return minWidths;
  }

  // Helper method to build colored text for P&L values
  Widget _buildColoredText(String value) {
    final numValue = double.tryParse(value.replaceAll('%', '')) ?? 0.0;
    return Text(
      value,
      style: _geistTextStyle(color: _getValueColor(numValue)),
    );
  }

  // Handler: Show holding detail sheet
  void _showHoldingDetail(dynamic holding) {
    // Open sheet immediately without waiting
    shadcn.openSheet(
      context: context,
      builder: (context) => MfHoldingDetailScreenWeb(
        holding: holding,
      ),
      position: shadcn.OverlayPosition.end,
    );
  }

  // Handler: Redeem mutual fund
  Future<void> _handleRedeem(dynamic holding) async {
    final mfData = ref.read(mfProvider);
    // Set the holding data for redemption using the ISIN
    mfData.fetchmfholdsingpage(holding.iSIN ?? '');
    // Call the redeem evaluation function
    mfData.recdemevalu();
    // Show web redeem dialog
    showDialog(
      context: context,
      builder: (context) => const RedemptionBottomSheetWeb(),
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
    final buttonPadding = isVerySmallScreen 
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
        : (isSmallScreen 
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 8));
    final fontSize = isVerySmallScreen ? 10.0 : (isSmallScreen ? 11.0 : 12.0);
    final iconSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0);
    
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

  @override
  Widget build(BuildContext context) {
    final mfData = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);
    
    // Show loading indicator while fetching data
    if (mfData.holdstatload ?? false) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final holdings = mfData.mfholdingnew?.data ?? [];

    // Apply search filter if search query is provided
    var filteredHoldings = holdings;
    final searchQuery = widget.searchQuery?.toLowerCase().trim() ?? '';
    if (searchQuery.isNotEmpty) {
      filteredHoldings = holdings.where((holding) {
        final name = holding.name?.toLowerCase() ?? '';
        return name.contains(searchQuery);
      }).toList();
    }

    // Sort holdings based on selected column
    if (_sortColumnIndex != null) {
      filteredHoldings.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: // Fund Name
            comparison = (a.name ?? '').compareTo(b.name ?? '');
            break;
          case 1: // Units
            final aQty = double.tryParse(a.avgQty ?? '0') ?? 0;
            final bQty = double.tryParse(b.avgQty ?? '0') ?? 0;
            comparison = aQty.compareTo(bQty);
            break;
          case 2: // Avg NAV
            final aNav = double.tryParse(a.avgNav ?? '0') ?? 0;
            final bNav = double.tryParse(b.avgNav ?? '0') ?? 0;
            comparison = aNav.compareTo(bNav);
            break;
          case 3: // Current NAV
            final aCurNav = double.tryParse(a.curNav ?? '0') ?? 0;
            final bCurNav = double.tryParse(b.curNav ?? '0') ?? 0;
            comparison = aCurNav.compareTo(bCurNav);
            break;
          case 4: // Invested
            final aInvested = double.tryParse(a.investedValue ?? '0') ?? 0;
            final bInvested = double.tryParse(b.investedValue ?? '0') ?? 0;
            comparison = aInvested.compareTo(bInvested);
            break;
          case 5: // Current Value
            final aValue = double.tryParse(a.currentValue ?? '0') ?? 0;
            final bValue = double.tryParse(b.currentValue ?? '0') ?? 0;
            comparison = aValue.compareTo(bValue);
            break;
          case 6: // P&L
            final aPnL = double.tryParse(a.profitLoss ?? '0') ?? 0;
            final bPnL = double.tryParse(b.profitLoss ?? '0') ?? 0;
            comparison = aPnL.compareTo(bPnL);
            break;
          case 7: // P&L %
            final aPnLPercent = double.tryParse(a.changeprofitLoss ?? '0') ?? 0;
            final bPnLPercent = double.tryParse(b.changeprofitLoss ?? '0') ?? 0;
            comparison = aPnLPercent.compareTo(bPnLPercent);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    final displayHoldings = filteredHoldings;

    // Show NoDataFound if no results after filtering
    if (displayHoldings.isEmpty) {
      return shadcn.OutlinedContainer(
        child: NoDataFound(
          title: searchQuery.isNotEmpty 
              ? "No Mutual Funds Found" 
              : "No Mutual Funds",
          subtitle: searchQuery.isNotEmpty
              ? "No mutual funds match your search \"$searchQuery\"."
              : "You don't have any mutual fund holdings yet.",
          primaryEnabled: false,
          secondaryEnabled: false,
        ),
      );
    }

    return shadcn.OutlinedContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(displayHoldings, context);

          // Available width
          final availableWidth = constraints.maxWidth;
          
          // Step 1: Start with minimum widths (content-based, no wasted space)
          final columnWidths = <int, double>{};
          for (int i = 0; i < 8; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          // Step 2: Calculate total minimum width needed
          final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
          
          // Step 3: If there's extra space, distribute it proportionally
          // This prevents unnecessary horizontal scroll while using available space efficiently
          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;
            
            // Define which columns can grow and their growth priorities
            // Fund Name gets more growth, numeric columns get less
            const fundNameGrowthFactor = 2.0; // Fund Name can grow 2x more than numeric
            const numericGrowthFactor = 1.0;
            
            // Calculate growth factors for each column
            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;
            
            for (int i = 0; i < 8; i++) {
              if (i == 0) {
                // Column 0 is Fund Name
                growthFactors[i] = fundNameGrowthFactor;
                totalGrowthFactor += fundNameGrowthFactor;
              } else {
                // Columns 1-7 are numeric
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }
            
            // Distribute extra space proportionally
            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 8; i++) {
                if (growthFactors[i]! > 0) {
                  final extraForThisColumn = (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                  columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                }
              }
            }
          }

          // Calculate total required width
          final totalRequiredWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
          
          // Create scroll controllers for synchronized scrolling
          final horizontalScrollController = ScrollController();
          final verticalScrollController = ScrollController();

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
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Fund Name', 0),
                        buildHeaderCell('Units', 1, true),
                        buildHeaderCell('Avg NAV', 2, true),
                        buildHeaderCell('Current NAV', 3, true),
                        buildHeaderCell('Invested', 4, true),
                        buildHeaderCell('Current Value', 5, true),
                        buildHeaderCell('P&L', 6, true),
                        buildHeaderCell('P&L %', 7, true),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body (vertical scroll)
                Expanded(
                  child: Scrollbar(
                    controller: verticalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: verticalScrollController,
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
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(40),
                        rows: [
                          // Data Rows
                          ...displayHoldings.asMap().entries.map((entry) {
                            final index = entry.key;
                            final holding = entry.value;
                            final avgQty = double.tryParse(holding.avgQty ?? '0') ?? 0.0;
                            final isRowHovered = _hoveredRowIndex == index;

                            return shadcn.TableRow(
                              cells: [
                                // Fund Name with action button on hover - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 0,
                                  child: GestureDetector(
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Stack(
                                        clipBehavior: Clip.hardEdge,
                                        children: [
                                          // Fund name - full width, can be partially covered by buttons
                                          // Only truncate when hovered (buttons visible), otherwise show full text
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Tooltip(
                                              message: holding.name ?? 'N/A',
                                              child: Padding(
                                                padding: EdgeInsets.only(right: isRowHovered ? 8.0 : 0.0),
                                                child: Text(
                                                  holding.name ?? 'N/A',
                                                  overflow: isRowHovered ? TextOverflow.ellipsis : TextOverflow.visible,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  style: _geistTextStyle(
                                                    color: shadcn.Theme.of(context).colorScheme.foreground,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Action button - overlay on the right side, covering only half the text
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
                                                  final responsiveMaxWidth = isVerySmallScreen ? 100.0 : (isSmallScreen ? 120.0 : 150.0);
                                                  
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
                                                            if (avgQty > 0) {
                                                              return _buildHoverButton(
                                                                theme: theme,
                                                                label: 'Redeem',
                                                                onPressed: () => _handleRedeem(holding),
                                                                backgroundColor: theme.isDarkMode
                                                                    ? WebDarkColors.tertiary
                                                                    : WebColors.tertiary,
                                                                textColor: Colors.white,
                                                                context: buttonContext,
                                                              );
                                                            }
                                                            return const SizedBox.shrink();
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
                                // Units - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 1,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        holding.avgQty ?? '0',
                                        style: _geistTextStyle(
                                          color: shadcn.Theme.of(context).colorScheme.foreground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Avg NAV - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 2,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        holding.avgNav ?? '0.00',
                                        style: _geistTextStyle(
                                          color: shadcn.Theme.of(context).colorScheme.foreground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Current NAV - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 3,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        holding.curNav ?? '0.00',
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
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        (double.tryParse(holding.investedValue ?? '0') ?? 0.0).toStringAsFixed(2),
                                        style: _geistTextStyle(
                                          color: shadcn.Theme.of(context).colorScheme.foreground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Current Value - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 5,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        (double.tryParse(holding.currentValue ?? '0') ?? 0.0).toStringAsFixed(2),
                                        style: _geistTextStyle(
                                          color: shadcn.Theme.of(context).colorScheme.foreground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // P&L - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 6,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _buildColoredText(holding.profitLoss ?? '0.00'),
                                    ),
                                  ),
                                ),
                                // P&L % - Make clickable for row tap
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 7,
                                  alignRight: true,
                                  child: GestureDetector(
                                    onTap: () => _showHoldingDetail(holding),
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _buildColoredText('${holding.changeprofitLoss ?? '0.00'}%'),
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

          // Wrap with scrollbars - horizontal on the outside
          return Scrollbar(
            controller: horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalRequiredWidth,
                child: buildTableContent(),
              ),
            ),
          );
        },
      ),
    );
  }
}

