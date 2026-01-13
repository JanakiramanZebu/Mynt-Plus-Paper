// Futures screen with shadcn.Table implementation
// Converted from DataTable2 to shadcn.Table pattern following hold_table.dart

import 'package:flutter/material.dart'
    show
        InkWell,
        Icons,
        VoidCallback,
        BorderRadius,
        Icon,
        BoxDecoration,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        GestureDetector,
        HitTestBehavior,
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
        FontWeight,
        Container,
        MouseRegion,
        Expanded,
        Align,
        Text,
        AnimatedOpacity,
        ScrollController,
        SingleChildScrollView,
        Scrollbar,
        Column,
        LayoutBuilder,
        ValueKey,
        IconData,
        Padding,
        Tooltip,
        RichText,
        Stack,
        LinearGradient,
        BoxConstraints,
        Clip,
        MediaQuery,
        Builder,
        Visibility,
        Navigator,
        Center,
        ColorFilter,
        BlendMode,
        StreamBuilder;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/res.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../../../utils/responsive_snackbar.dart';

class FutureScreenWeb extends ConsumerStatefulWidget {
  const FutureScreenWeb({super.key});

  @override
  ConsumerState<FutureScreenWeb> createState() => _FutureScreenWebState();
}

class _FutureScreenWebState extends ConsumerState<FutureScreenWeb> {
  int? _hoveredRowIndex;
  bool _isNavigating = false;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Scroll controllers
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
  TextStyle _geistTextStyle(
      {Color? color, double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontFamily: 'Geist',
      color: color,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight,
    );
  }

  // Builds a bordered cell
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
        alignment: alignRight ? Alignment.centerRight : null,
        child: child,
      ),
    );
  }

  // Builds a cell with hover detection
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 2;

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
        child: Container(
          padding: cellPadding,
          alignment: alignRight ? Alignment.centerRight : null,
          child: child,
        ),
      ),
    );
  }

  // Builds a sortable header cell with sort indicator
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 2;

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
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              if (alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              Text(
                label,
                style: _geistTextStyle(
                  color: shadcn.Theme.of(context).colorScheme.foreground,
                  fontWeight: FontWeight.w500,
                ),
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
  Map<int, double> _calculateMinWidths(
      List<dynamic> futures, BuildContext context) {
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = ['Symbol', 'LTP', '%Change'];
    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;

      final headerWidth = _measureTextWidth(headers[col], const TextStyle());
      maxWidth = headerWidth + sortIconWidth;

      for (final future in futures) {
        String cellText = '';

        switch (col) {
          case 0: // Symbol
            cellText = future.tsym?.toString() ?? '';
            break;
          case 1: // LTP
            cellText = future.ltp ?? future.close ?? '0.00';
            break;
          case 2: // %Change
            cellText =
                '${_getChangeValue(future)} (${_getPerChangeValue(future)}%)';
            break;
        }

        final cellWidth = _measureTextWidth(cellText, const TextStyle());
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      // Symbol column needs extra space for action buttons
      if (col == 0) {
        minWidths[col] = maxWidth + padding + 180; // Extra for buttons
      } else {
        minWidths[col] = maxWidth + padding;
      }
    }

    return minWidths;
  }

  @override
  Widget build(BuildContext context) {
    final future = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);

    if (future.fut == null || future.fut!.isEmpty) {
      return Center(
        child: Text(
          "No futures data available",
          style: _geistTextStyle(
            color: shadcn.Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
      );
    }

    // Sort futures based on selected column
    List<dynamic> sortedFutures = List.from(future.fut!);
    if (_sortColumnIndex != null) {
      sortedFutures.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: // Symbol
            comparison =
                (a.tsym?.toString() ?? '').compareTo(b.tsym?.toString() ?? '');
            break;
          case 1: // LTP
            final ltpA = double.tryParse(a.ltp ?? a.close ?? '0') ?? 0.0;
            final ltpB = double.tryParse(b.ltp ?? b.close ?? '0') ?? 0.0;
            comparison = ltpA.compareTo(ltpB);
            break;
          case 2: // %Change
            final changeA = double.tryParse(a.perChange ?? '0') ?? 0.0;
            final changeB = double.tryParse(b.perChange ?? '0') ?? 0.0;
            comparison = changeA.compareTo(changeB);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};

        return shadcn.OutlinedContainer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate minimum widths dynamically
              final minWidths = _calculateMinWidths(sortedFutures, context);

              // Available width
              final availableWidth = constraints.maxWidth;

              // Start with minimum widths
              final columnWidths = <int, double>{};
              for (int i = 0; i < 3; i++) {
                columnWidths[i] = minWidths[i] ?? 100.0;
              }

              // Calculate total minimum width needed
              final totalMinWidth = columnWidths.values
                  .fold<double>(0.0, (sum, width) => sum + width);

              // If there's extra space, distribute it proportionally
              if (totalMinWidth < availableWidth) {
                final extraSpace = availableWidth - totalMinWidth;

                const symbolGrowthFactor = 2.0;
                const numericGrowthFactor = 1.0;

                final growthFactors = <int, double>{};
                double totalGrowthFactor = 0.0;

                for (int i = 0; i < 3; i++) {
                  if (i == 0) {
                    growthFactors[i] = symbolGrowthFactor;
                    totalGrowthFactor += symbolGrowthFactor;
                  } else {
                    growthFactors[i] = numericGrowthFactor;
                    totalGrowthFactor += numericGrowthFactor;
                  }
                }

                if (totalGrowthFactor > 0) {
                  for (int i = 0; i < 3; i++) {
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
                      },
                      defaultRowHeight: const shadcn.FixedTableSize(40),
                      rows: [
                        shadcn.TableHeader(
                          cells: [
                            buildHeaderCell('Symbol', 0),
                            buildHeaderCell('LTP', 1, true),
                            buildHeaderCell('%Change', 2, true),
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
                                'futures_table_${_sortColumnIndex}_$_sortAscending'),
                            columnWidths: {
                              0: shadcn.FixedTableSize(columnWidths[0]!),
                              1: shadcn.FixedTableSize(columnWidths[1]!),
                              2: shadcn.FixedTableSize(columnWidths[2]!),
                            },
                            defaultRowHeight: const shadcn.FixedTableSize(40),
                            rows: [
                              // Data Rows
                              ...sortedFutures.asMap().entries.map((entry) {
                                final index = entry.key;
                                var displayData = entry.value;
                                final tokenKey = displayData.token?.toString();

                                // Update with socket data if available
                                if (tokenKey != null &&
                                    socketDatas.containsKey(tokenKey)) {
                                  final socketData = socketDatas[tokenKey];

                                  final lp = socketData['lp']?.toString() ??
                                      socketData['ltp']?.toString() ??
                                      socketData['last_price']?.toString();
                                  if (lp != null &&
                                      lp != "null" &&
                                      lp != "0" &&
                                      lp != "0.00" &&
                                      lp.isNotEmpty) {
                                    try {
                                      final ltpValue = double.parse(lp);
                                      if (ltpValue > 0) {
                                        displayData.ltp = lp;
                                      }
                                    } catch (e) {
                                      // Keep original value
                                    }
                                  }

                                  final chng = socketData['chng']?.toString() ??
                                      socketData['change']?.toString();
                                  if (chng != null &&
                                      chng != "null" &&
                                      chng.isNotEmpty) {
                                    try {
                                      displayData.change = chng;
                                    } catch (e) {}
                                  }

                                  final pc = socketData['pc']?.toString() ??
                                      socketData['per_change']?.toString();
                                  if (pc != null &&
                                      pc != "null" &&
                                      pc.isNotEmpty) {
                                    try {
                                      displayData.perChange = pc;
                                    } catch (e) {}
                                  }
                                }

                                final isRowHovered = _hoveredRowIndex == index;
                                final displayText =
                                    displayData.tsym?.toString() ?? '';

                                return shadcn.TableRow(
                                  cells: [
                                    // Symbol cell with action buttons on hover
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 0,
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Stack(
                                          clipBehavior: Clip.hardEdge,
                                          children: [
                                            // Symbol name
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Tooltip(
                                                message: displayText,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: isRowHovered
                                                          ? 8.0
                                                          : 0.0),
                                                  child: Text(
                                                    displayText,
                                                    style: _geistTextStyle(
                                                      color: shadcn.Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .foreground,
                                                    ),
                                                    overflow: isRowHovered
                                                        ? TextOverflow.ellipsis
                                                        : TextOverflow.visible,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Action buttons on hover
                                            Visibility(
                                              visible: isRowHovered,
                                              maintainSize: false,
                                              maintainAnimation: false,
                                              maintainState: false,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AnimatedOpacity(
                                                  opacity: isRowHovered ? 1 : 0,
                                                  duration: const Duration(
                                                      milliseconds: 140),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                        colors: [
                                                          shadcn.Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .background
                                                              .withOpacity(0.0),
                                                          shadcn.Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .background
                                                              .withOpacity(
                                                                  0.95),
                                                        ],
                                                      ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: _buildActionButtons(
                                                        context,
                                                        displayData,
                                                        future,
                                                        theme,
                                                        isRowHovered),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // LTP cell
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 1,
                                      alignRight: true,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          displayData.ltp != null &&
                                                  displayData.ltp != "null"
                                              ? "${displayData.ltp}"
                                              : displayData.close != null &&
                                                      displayData.close !=
                                                          "null"
                                                  ? "${displayData.close}"
                                                  : '0.00',
                                          style: _geistTextStyle(
                                            color: _getPriceColor(
                                                displayData, theme),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // %Change cell
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 2,
                                      alignRight: true,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${_getChangeValue(displayData)} (${_getPerChangeValue(displayData)}%)",
                                          style: _geistTextStyle(
                                            color: _getChangeColor(
                                                displayData, theme),
                                            fontWeight: FontWeight.w500,
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
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    dynamic displayData,
    MarketWatchProvider future,
    ThemesProvider theme,
    bool isHovered,
  ) {
    // Determine if scrip already exists in current watchlist
    final String key = "${displayData.exch}|${displayData.token}";
    final bool isInWatchlist = ref
        .read(marketWatchProvider)
        .scrips
        .any((e) => "${e['exch']}|${e['token']}" == key);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Buy Button
        _buildHoverButton(
          label: 'B',
          color: Colors.white,
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
          onPressed: () async {
            try {
              await _placeOrderInput(context, displayData, true, future);
            } catch (e) {
              print('Buy button error: $e');
            }
          },
          theme: theme,
        ),
        const SizedBox(width: 6),
        // Sell Button
        _buildHoverButton(
          label: 'S',
          color: Colors.white,
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary,
          onPressed: () async {
            try {
              await _placeOrderInput(context, displayData, false, future);
            } catch (e) {
              print('Sell button error: $e');
            }
          },
          theme: theme,
        ),
        const SizedBox(width: 6),
        // Chart Button
        _buildHoverButton(
          icon: Icons.bar_chart,
          color: Colors.black,
          backgroundColor: Colors.white,
          borderRadius: 5.0,
          onPressed: () {
            Navigator.pop(context);
            ref
                .read(marketWatchProvider)
                .calldepthApis(context, displayData, "");
          },
          theme: theme,
        ),
        const SizedBox(width: 6),
        // Save Button (Add to watchlist)
        _buildHoverButton(
          svgIcon: isInWatchlist ? assets.bookmarkIcon : assets.bookmarkedIcon,
          color: isInWatchlist
              ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
              : (theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary),
          backgroundColor: Colors.white,
          borderRadius: 5.0,
          onPressed: () async {
            final bool add = !isInWatchlist;
            final success = await future.addDelMarketScrip(
              future.wlName,
              key,
              context,
              add,
              true,
              false,
              false,
            );
            if (success && mounted) {
              if (add) {
                ResponsiveSnackBar.showSuccess(
                    context, 'Added to ${future.wlName}');
              } else {
                ResponsiveSnackBar.showInfo(
                    context, 'Removed from ${future.wlName}');
              }
              setState(() {});
            }
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    String? svgIcon,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final isLongLabel = label != null && label.length > 1;
    final borderRadiusValue = borderRadius ?? 5.0;
    return SizedBox(
      width: isLongLabel ? null : 25,
      height: 25,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadiusValue),
        onTap: onPressed,
        child: Container(
          padding:
              isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadiusValue),
            border: borderColor != null
                ? shadcn.Border.all(
                    color: borderColor,
                    width: 1.3,
                  )
                : null,
          ),
          child: Center(
            child: svgIcon != null
                ? SvgPicture.asset(
                    svgIcon,
                    height: 16,
                    width: 16,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  )
                : icon != null
                    ? Icon(
                        icon,
                        size: 16,
                        color: color,
                        weight: 400,
                      )
                    : Text(
                        label ?? "",
                        style: WebTextStyles.buttonXs(
                          isDarkTheme: theme.isDarkMode,
                          color: color,
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  String _getChangeValue(dynamic displayData) {
    final change = displayData.change?.toString();
    if (change != null && change != "null" && change.isNotEmpty) {
      return (double.tryParse(change)?.toStringAsFixed(2) ?? "0.00");
    }
    return "0.00";
  }

  String _getPerChangeValue(dynamic displayData) {
    final perChange = displayData.perChange?.toString();
    if (perChange != null && perChange != "null" && perChange.isNotEmpty) {
      return (double.tryParse(perChange)?.toStringAsFixed(2) ?? "0.00");
    }
    return "0.00";
  }

  Color _getPriceColor(dynamic displayData, ThemesProvider theme) {
    final change = displayData.change?.toString() ?? "0.00";
    final perChange = displayData.perChange?.toString() ?? "0.00";

    if (change.startsWith("-") || perChange.startsWith('-')) {
      return theme.isDarkMode ? WebDarkColors.loss : WebColors.loss;
    } else if (change == "null" ||
        perChange == "null" ||
        change == "0.00" ||
        perChange == "0.00") {
      return shadcn.Theme.of(context).colorScheme.foreground;
    } else {
      return theme.isDarkMode ? WebDarkColors.profit : WebColors.profit;
    }
  }

  Color _getChangeColor(dynamic displayData, ThemesProvider theme) {
    final change = displayData.change?.toString() ?? "0.00";
    final perChange = displayData.perChange?.toString() ?? "0.00";

    if (change.startsWith("-") || perChange.startsWith('-')) {
      return theme.isDarkMode ? WebDarkColors.loss : WebColors.loss;
    } else if (change == "null" ||
        perChange == "null" ||
        change == "0.00" ||
        perChange == "0.00") {
      return shadcn.Theme.of(context).colorScheme.mutedForeground;
    } else {
      return theme.isDarkMode ? WebDarkColors.profit : WebColors.profit;
    }
  }

  // Helper method to safely parse numeric values
  String _safeParseNumeric(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;

    String stringValue = value.toString().trim();

    if (stringValue.isEmpty ||
        stringValue == 'null' ||
        stringValue == '0.0' ||
        stringValue == '0' ||
        stringValue == 'NaN' ||
        stringValue == 'Infinity') {
      return defaultValue;
    }

    try {
      double.parse(stringValue);
      return stringValue;
    } catch (e) {
      try {
        int.parse(stringValue);
        return stringValue;
      } catch (e) {
        return defaultValue;
      }
    }
  }

  // Helper method to safely parse lot size
  String _safeParseLotSize(
      dynamic scripInfoLs, dynamic depthDataLs, String defaultValue) {
    String scripInfoValue = _safeParseNumeric(scripInfoLs, "");
    if (scripInfoValue.isNotEmpty && scripInfoValue != defaultValue) {
      return scripInfoValue;
    }

    String depthDataValue = _safeParseNumeric(depthDataLs, "");
    if (depthDataValue.isNotEmpty && depthDataValue != defaultValue) {
      return depthDataValue;
    }

    return defaultValue;
  }

  Future<void> _placeOrderInput(BuildContext ctx, dynamic displayData,
      bool transType, MarketWatchProvider future) async {
    try {
      if (_isNavigating) return;

      setState(() {
        _isNavigating = true;
      });

      await ref.read(marketWatchProvider).fetchScripInfo(
          displayData.token?.toString() ?? "",
          displayData.exch?.toString() ?? "",
          context,
          true);

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        throw Exception('Failed to load scrip information');
      }

      final depthData = ref.read(marketWatchProvider).getQuotes ?? GetQuotes();

      final lotSize = _safeParseLotSize(depthData.ls, scripInfo.ls, "1");

      final safeLtp = _safeParseNumeric(
          displayData.ltp ?? displayData.close ?? depthData.lp, "0.00");
      final safePerChange =
          _safeParseNumeric(displayData.perChange ?? depthData.pc, "0.00");

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: displayData.exch?.toString() ?? "",
        tSym: displayData.tsym?.toString() ?? "",
        isExit: false,
        token: displayData.token?.toString() ?? "",
        transType: transType,
        lotSize: lotSize,
        ltp: safeLtp,
        perChange: safePerChange,
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {},
      );

      await Future.delayed(const Duration(milliseconds: 150));

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": ""
        },
      );
    } catch (e) {
      print('Place order error: $e');
      print('Display data: ${displayData.toJson()}');
      if (mounted) {
        ResponsiveSnackBar.showError(
          context,
          'Error placing order: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isNavigating = false;
            });
          }
        });
      }
    }
  }
}
