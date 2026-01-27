import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import 'mf_hold_singlepage.dart';

class MfHoldNewScreen extends ConsumerStatefulWidget {
  const MfHoldNewScreen({super.key});

  @override
  ConsumerState<MfHoldNewScreen> createState() => _MfHoldNewScreenState();
}

class _MfHoldNewScreenState extends ConsumerState<MfHoldNewScreen> {
  // int? _hoveredRowIndex;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).fetchmfholdingnew();
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // Helper method to get appropriate text style for table cells
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
    final mfData = ref.watch(mfProvider);
    final showSearch = mfData.showMfHoldingSearch;
    final searchText = mfData.mfHoldingSearchController.text;

    // Get the appropriate list based on search state
    final items = showSearch && searchText.isNotEmpty
        ? (mfData.mfHoldingSearchItems ?? [])
        : (mfData.mfholdingnew?.data ?? []);

    // Check if user has any holdings data at all (kept for reference or remove if strictly unused, but for now just fix the compilation error)
    // final hasHoldingsData = mfData.mfholdingnew?.data != null && mfData.mfholdingnew!.data!.isNotEmpty;

    return Scaffold(
      // backgroundColor: theme.isDarkMode
      //     ? const Color(0xFF121212)
      //     : const Color(0xFFF5F5F5),
      body: MyntLoaderOverlay(
        isLoading: mfData.holdstatload ?? false,
        child: RefreshIndicator(
          onRefresh: () async {
            await mfData.fetchmfholdingnew();
          },
          child: Column(
            children: [
              // Summary Cards - Horizontal row of 3 cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Current Value Card
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        "Current Value",
                        mfData.mfholdingnew?.summary?.currentValue ?? "0.00",
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Invested Card
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        "Invested",
                        _formatValue(mfData.mfholdingnew?.summary?.invested),
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Profit/Loss Card
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        "Profit/Loss",
                        "${_formatValue(mfData.mfholdingnew?.summary?.absReturnValue)} (${_formatValue(mfData.mfholdingnew?.summary?.absReturnPercent?.toString())}%)",
                        theme,
                        valueColor: _getColorBasedOnValue(
                          mfData.mfholdingnew?.summary?.absReturnValue,
                          theme,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTableContent(context, theme, mfData, items),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build summary card widget
  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    ThemesProvider theme, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode
              ? colors.darkColorDivider
              : colors.colorDivider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.paraText(
            text: title,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 0,
          ),
          const SizedBox(height: 8),
          TextWidget.titleText(
            text: value,
            color: valueColor ??
                (theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight),
            theme: theme.isDarkMode,
            fw: 1,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Build table content using shadcn table
  Widget _buildTableContent(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mfData,
    List items,
  ) {
    // Sort items if sort is active
    final sortedItems = _sortColumnIndex != null ? _getSortedItems(items) : items;

    return shadcn.OutlinedContainer(
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(sortedItems, context);

          // Available width
          final availableWidth = constraints.maxWidth;

          // Step 1: Start with minimum widths
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

            // Define growth factors
            const instrumentGrowthFactor = 2.0;
            const numericGrowthFactor = 1.0;

            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 8; i++) {
              if (i == 0) {
                // Instrument column
                growthFactors[i] = instrumentGrowthFactor;
                totalGrowthFactor += instrumentGrowthFactor;
              } else {
                // Numeric columns
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
                        buildHeaderCell('Instrument', 0),
                        buildHeaderCell('Qty', 1, true),
                        buildHeaderCell('Avg NAV', 2, true),
                        buildHeaderCell('NAV', 3, true),
                        buildHeaderCell('Invested', 4, true),
                        buildHeaderCell('Current Value', 5, true),
                        buildHeaderCell('Overall P&L', 6, true),
                        buildHeaderCell('Overall %', 7, true),
                      ],
                    ),
                  ],
                ),

                // Scrollable Body
                Expanded(
                  child: sortedItems.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: NoDataFound(
                                  title: (mfData.mfholdingnew?.data != null &&
                                          mfData.mfholdingnew!.data!.isNotEmpty)
                                      ? "No results found"
                                      : "There's nothing here yet.",
                                  subtitle: (mfData.mfholdingnew?.data != null &&
                                          mfData.mfholdingnew!.data!.isNotEmpty)
                                      ? "Try adjusting your search"
                                      : "Buy some funds to see them here.",
                                  primaryEnabled: false,
                                  secondaryEnabled: false,
                                ),
                              ),
                            ),
                          ),
                        )
                      : RawScrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          trackColor: Colors.grey.withValues(alpha: 0.1),
                          thumbColor: Colors.grey.withValues(alpha: 0.3),
                          thickness: 6,
                          radius: const Radius.circular(3),
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
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(70),
                        rows: [
                          // Data Rows
                          ...sortedItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;

                            return shadcn.TableRow(
                              cells: [
                                // Instrument
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 0,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    item.name ?? "Unknown Fund",
                                    style: _getTextStyle(context),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                // Qty
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 1,
                                  alignRight: true,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    (double.tryParse(item.avgQty ?? '0') ?? 0.0)
                                        .toStringAsFixed(4),
                                    style: _getTextStyle(context),
                                  ),
                                ),
                                // Avg NAV
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 2,
                                  alignRight: true,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    (double.tryParse(item.avgNav ?? '0') ?? 0.0)
                                        .toStringAsFixed(4),
                                    style: _getTextStyle(context),
                                  ),
                                ),
                                // NAV
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 3,
                                  alignRight: true,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    (double.tryParse(item.curNav ?? '0') ?? 0.0)
                                        .toStringAsFixed(4),
                                    style: _getTextStyle(context),
                                  ),
                                ),
                                // Invested
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 4,
                                  alignRight: true,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    (double.tryParse(item.investedValue ?? '0') ?? 0.0)
                                        .toStringAsFixed(2),
                                    style: _getTextStyle(context),
                                  ),
                                ),
                                // Current Value
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 5,
                                  alignRight: true,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    (double.tryParse(item.currentValue ?? '0') ?? 0.0)
                                        .toStringAsFixed(2),
                                    style: _getTextStyle(context),
                                  ),
                                ),
                                // Overall P&L
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 6,
                                  alignRight: true,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    (double.tryParse(item.profitLoss ?? '0') ?? 0.0)
                                        .toStringAsFixed(2),
                                    style: _getTextStyle(
                                      context,
                                      color: _getColorBasedOnValue(
                                        item.profitLoss?.toString(),
                                        theme,
                                      ),
                                    ),
                                  ),
                                ),
                                // Overall %
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 7,
                                  alignRight: true,
                                  onTap: () => _showHoldingDetail(mfData, item),
                                  child: Text(
                                    "${(double.tryParse(item.changeprofitLoss?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}%",
                                    style: _getTextStyle(
                                      context,
                                      color: _getColorBasedOnValue(
                                        item.changeprofitLoss?.toString(),
                                        theme,
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
            );
          }

          // Horizontal scroll wrapper (if needed)
          if (needsHorizontalScroll) {
            return RawScrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              trackColor: Colors.grey.withValues(alpha: 0.1),
              thumbColor: Colors.grey.withValues(alpha: 0.3),
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

  // Build cell with hover
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 7;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 12, 12, 12);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(12, 12, 16, 12);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: cellPadding,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: child,
        ),
      ),
    );
  }

  // Build header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 7;

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
                  color: MyntColors.textSecondaryDark,
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
                  color: MyntColors.textSecondaryDark,
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

  // Calculate minimum column widths
  Map<int, double> _calculateMinWidths(List items, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'Instrument',
      'Qty',
      'Avg NAV',
      'NAV',
      'Invested',
      'Current Value',
      'Overall P&L',
      'Overall %',
    ];

    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = _measureTextWidth(headers[col], textStyle) + sortIconWidth;

      for (final item in items.take(5)) {
        String cellText = '';
        switch (col) {
          case 0:
            cellText = item.name ?? 'Unknown Fund';
            break;
          case 1:
            cellText = (double.tryParse(item.avgQty ?? '0') ?? 0.0).toStringAsFixed(4);
            break;
          case 2:
            cellText = (double.tryParse(item.avgNav ?? '0') ?? 0.0).toStringAsFixed(4);
            break;
          case 3:
            cellText = (double.tryParse(item.curNav ?? '0') ?? 0.0).toStringAsFixed(4);
            break;
          case 4:
            cellText = (double.tryParse(item.investedValue ?? '0') ?? 0.0).toStringAsFixed(2);
            break;
          case 5:
            cellText = (double.tryParse(item.currentValue ?? '0') ?? 0.0).toStringAsFixed(2);
            break;
          case 6:
            cellText = (double.tryParse(item.profitLoss ?? '0') ?? 0.0).toStringAsFixed(2);
            break;
          case 7:
            cellText = "${(double.tryParse(item.changeprofitLoss?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}%";
            break;
        }

        final cellWidth = _measureTextWidth(cellText, textStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
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

  List _getSortedItems(List items) {
    if (_sortColumnIndex == null) return items;

    final sorted = List.from(items);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex!) {
        case 0: // Instrument
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 1: // Qty
          comparison = (double.tryParse(a.avgQty ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.avgQty ?? '0') ?? 0.0);
          break;
        case 2: // Avg NAV
          comparison = (double.tryParse(a.avgNav ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.avgNav ?? '0') ?? 0.0);
          break;
        case 3: // NAV
          comparison = (double.tryParse(a.curNav ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.curNav ?? '0') ?? 0.0);
          break;
        case 4: // Invested
          comparison = (double.tryParse(a.investedValue ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.investedValue ?? '0') ?? 0.0);
          break;
        case 5: // Current Value
          comparison = (double.tryParse(a.currentValue ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.currentValue ?? '0') ?? 0.0);
          break;
        case 6: // Overall P&L
          comparison = (double.tryParse(a.profitLoss ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.profitLoss ?? '0') ?? 0.0);
          break;
        case 7: // Overall %
          comparison = (double.tryParse(a.changeprofitLoss?.toString() ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.changeprofitLoss?.toString() ?? '0') ?? 0.0);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  void _showHoldingDetail(MFProvider mfData, dynamic item) {
    if (item.iSIN != null) {
      mfData.fetchmfholdsingpage("${item.iSIN}");
      
      // Show as right side panel
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.25,
                height: MediaQuery.of(dialogContext).size.height,
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: const mfholdsinlepage(),
              ),
            ),
          );
        },
        transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
    }
  }

  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }

  Color _getColorBasedOnValue(String? valueStr, ThemesProvider theme) {
    final value = double.tryParse(valueStr ?? "0") ?? 0;
    return value >= 0
        ? theme.isDarkMode
            ? colors.profitDark
            : colors.profitLight
        : theme.isDarkMode
            ? colors.lossDark
            : colors.lossLight;
  }
}
