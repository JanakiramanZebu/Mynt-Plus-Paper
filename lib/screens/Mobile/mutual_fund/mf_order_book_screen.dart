import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_hold_new_screen.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
// import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../sharedWidget/common_search_fields_web.dart';

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/mynt_loader.dart';
import '../../../utils/responsive_snackbar.dart';
import 'order_single_page.dart';

class MfOrderBookScreen extends ConsumerStatefulWidget {
  const MfOrderBookScreen({super.key});
  @override
  ConsumerState<MfOrderBookScreen> createState() => _MfOrderBookScreen();
}

class _MfOrderBookScreen extends ConsumerState<MfOrderBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tablistitems = [
    {"title": "Holdings", "index": 0},
    {"title": "Orders", "index": 1}
  ];
  final inProgressStatuses = {
    "PAYMENT NOT INITIATED",
    "MODIFIED",
    "PAYMENT INITATED",
    "PAYMENT INIT",
    "PAYMENT COMPLETED",
    "CANCEL ERROR",
    "WAIT FOR ALLOTMENT",
    "MODIFY REJECTED",
    "PAYMENT REJECTED"
  };

  // State for table hover and sorting
  // int? _hoveredRowIndex;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();

  // Scroll controllers for Orders table
  final ScrollController _ordersVerticalScrollController = ScrollController();
  final ScrollController _ordersHorizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).fetchMfOrderbook(context);
    });
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _searchController.clear();
        ref.read(mfProvider).mfOrderBookSearch("");
        ref.read(mfProvider).mfHoldingSearch("", context);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ordersVerticalScrollController.dispose();
    _ordersHorizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mforderbook = ref.watch(mfProvider);
      return Stack(
        children: [
          MyntLoaderOverlay(
            isLoading: mforderbook.bestmfloader == true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                  child: Row(
                    children: [
                      // Tabs on the left
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: TabBar(
                            controller: _tabController,
                            tabAlignment: TabAlignment.start,
                            isScrollable: true,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.searchBgDark
                                  : const Color(0xffF1F3F8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            unselectedLabelColor: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            labelStyle: TextWidget.textStyle(
                                fontSize: 14,
                                theme: false,
                                fw: 2,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight),
                            unselectedLabelStyle: TextWidget.textStyle(
                                fontSize: 14,
                                theme: false,
                                fw: 3,
                                color: colors.textSecondaryLight),
                            tabs: tablistitems.asMap().entries.map((entry) {
                              final tabData = entry.value;
                              return Tab(
                                text: tabData['title'].toString(),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Search bar and refresh button on the right
                      const SizedBox(width: 16),
                      Container(
                        width: 300,
                        height: 45,
                        child: MyntSearchTextField(
                          controller: _searchController,
                          placeholder: _tabController.index == 0
                              ? 'Search on holdings'
                              : 'Search on orders',
                          leadingIcon: 'assets/icon/search.svg',
                          onChanged: (value) {
                            if (_tabController.index == 0) {
                              // Update Holdings Search
                              ref
                                  .read(mfProvider)
                                  .mfHoldingSearchController
                                  .text = value;
                              ref
                                  .read(mfProvider)
                                  .mfHoldingSearch(value, context);
                            } else {
                              // Update Orders Search
                              ref.read(mfProvider).mfOrderBookSearch(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 45,
                        height: 45,
                        // decoration: BoxDecoration(
                        //   color: theme.isDarkMode
                        //       ? colors.searchBgDark
                        //       : colors.searchBg,
                        //   borderRadius: BorderRadius.circular(8),
                        //   border: Border.all(
                        //     color: theme.isDarkMode
                        //         ? colors.darkColorDivider
                        //         : colors.colorDivider,
                        //     width: 1,
                        //   ),
                        // ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.refresh,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            size: 20,
                          ),
                          onPressed: () async {
                            if (_tabController.index == 0) {
                              // Refresh Holdings
                              await mforderbook.fetchmfholdingnew();
                            } else {
                              // Refresh Orders
                              await mforderbook.fetchMfOrderbook(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      const MfHoldNewScreen(),
                      _buildOrdersTab(mforderbook, theme, context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      // );
    });
  }

  Widget _buildOrdersTab(
      MFProvider mforderbook, ThemesProvider theme, BuildContext context) {
    if (mforderbook.mfOrderbookfilter == "All" &&
        mforderbook.mflumpsumorderbook?.data != null &&
        mforderbook.mflumpsumorderbook?.stat != "Not Ok") {
      final orders = _searchController.text.isNotEmpty
          ? (mforderbook.mfOrderSearch ?? [])
          : (mforderbook.mflumpsumorderbook?.data ?? []);

      if (orders.isEmpty) {
        return const Center(
          child: NoDataFound(
            title: "No Orders Found",
            subtitle:
                "There's nothing here yet. Buy some funds to see them here.",
            primaryEnabled: false,
            secondaryEnabled: false,
          ),
        );
      }

      return MyntLoaderOverlay(
        isLoading: mforderbook.mforderloader,
        child: RefreshIndicator(
          onRefresh: () async {
            await mforderbook.fetchMfOrderbook(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildOrdersTable(context, theme, mforderbook, orders),
          ),
        ),
      );
    }

    return const Center(
      child: NoDataFound(
        title: "No Orders Found",
        subtitle: "There's nothing here yet. Buy some funds to see them here.",
        primaryEnabled: false,
        secondaryEnabled: false,
      ),
    );
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

  Widget _buildOrdersTable(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mforderbook,
    List orders,
  ) {
    // Sort orders if sort is active
    final sortedOrders =
        _sortColumnIndex != null ? _getSortedOrders(orders) : orders;

    return shadcn.OutlinedContainer(
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate minimum widths dynamically based on actual content
          final minWidths = _calculateMinWidths(sortedOrders, context);

          // Available width
          final availableWidth = constraints.maxWidth;

          // Step 1: Start with minimum widths
          final columnWidths = <int, double>{};
          for (int i = 0; i < 6; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          // Step 2: Calculate total minimum width needed
          final totalMinWidth = columnWidths.values
              .fold<double>(0.0, (sum, width) => sum + width);

          // Step 3: If there's extra space, distribute it proportionally
          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;

            // Define growth factors
            const fundNameGrowthFactor = 2.5;
            const numericGrowthFactor = 1.0;

            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 6; i++) {
              if (i == 1) {
                // Fund name column
                growthFactors[i] = fundNameGrowthFactor;
                totalGrowthFactor += fundNameGrowthFactor;
              } else {
                // Other columns
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            // Distribute extra space proportionally
            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 6; i++) {
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
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(50),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        buildHeaderCell('Date', 0),
                        buildHeaderCell('Fund name', 1),
                        buildHeaderCell('Folio no.', 2),
                        buildHeaderCell('Invest amt', 3, true),
                        buildHeaderCell('Transaction Type', 4, false, true),
                        buildHeaderCell('Status', 5),
                      ],
                    ),
                  ],
                ),

                // Scrollable Body
                Expanded(
                  child: RawScrollbar(
                    controller: _ordersVerticalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    trackColor: Colors.grey.withValues(alpha: 0.1),
                    thumbColor: Colors.grey.withValues(alpha: 0.3),
                    thickness: 6,
                    radius: const Radius.circular(3),
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _ordersVerticalScrollController,
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
                        },
                        defaultRowHeight: const shadcn.FixedTableSize(60),
                        rows: [
                          // Data Rows
                          ...sortedOrders.asMap().entries.map((entry) {
                            final rowIndex = entry.key;
                            final orderData = entry.value;

                            return shadcn.TableRow(
                              cells: [
                                // Date
                                buildCellWithHover(
                                  rowIndex: rowIndex,
                                  columnIndex: 0,
                                  onTap: () => _showOrderDetail(
                                      mforderbook, orderData, theme, context),
                                  child: Text(
                                    _formatDate(orderData.datetime ?? "-"),
                                    style: _getTextStyle(context),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                // Fund name (with Lumpsum tag)
                                buildCellWithHover(
                                  rowIndex: rowIndex,
                                  columnIndex: 1,
                                  onTap: () => _showOrderDetail(
                                      mforderbook, orderData, theme, context),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        orderData.name ?? "Unknown Fund",
                                        style: _getTextStyle(context),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Lumpsum",
                                        style: MyntWebTextStyles.bodySmall(
                                          context,
                                          color: theme.isDarkMode
                                              ? MyntColors.textSecondaryDark
                                              : MyntColors.textSecondary,
                                          fontWeight: MyntFonts.regular,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Folio no.
                                buildCellWithHover(
                                  rowIndex: rowIndex,
                                  columnIndex: 2,
                                  onTap: () => _showOrderDetail(
                                      mforderbook, orderData, theme, context),
                                  child: Text(
                                    _getFolio(orderData),
                                    style: _getTextStyle(context),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                // Invest amt
                                buildCellWithHover(
                                  rowIndex: rowIndex,
                                  columnIndex: 3,
                                  alignRight: true,
                                  onTap: () => _showOrderDetail(
                                      mforderbook, orderData, theme, context),
                                  child: Text(
                                    "₹${_formatAmount(orderData.orderVal)}",
                                    style: _getTextStyle(context),
                                  ),
                                ),
                                // Transaction Type (P badge)
                                buildCellWithHover(
                                  rowIndex: rowIndex,
                                  columnIndex: 4,
                                  alignCenter: true,
                                  onTap: () => _showOrderDetail(
                                      mforderbook, orderData, theme, context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: orderData.buySell == "P"
                                          ? theme.isDarkMode
                                              ? colors.profitDark
                                                  .withValues(alpha: 0.1)
                                              : colors.profitLight
                                                  .withValues(alpha: 0.1)
                                          : theme.isDarkMode
                                              ? colors.lossDark
                                                  .withValues(alpha: 0.1)
                                              : colors.lossLight
                                                  .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      orderData.buySell ?? "-",
                                      style: MyntWebTextStyles.bodySmall(
                                        context,
                                        color: orderData.buySell == "P"
                                            ? theme.isDarkMode
                                                ? colors.profitDark
                                                : colors.profitLight
                                            : theme.isDarkMode
                                                ? colors.lossDark
                                                : colors.lossLight,
                                        fontWeight: MyntFonts.medium,
                                      ),
                                    ),
                                  ),
                                ),
                                // Status
                                buildCellWithHover(
                                  rowIndex: rowIndex,
                                  columnIndex: 5,
                                  onTap: () => _showOrderDetail(
                                      mforderbook, orderData, theme, context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                              orderData.status, theme)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getListStatusText(orderData.status)
                                          .toUpperCase(),
                                      style: MyntWebTextStyles.bodySmall(
                                        context,
                                        color: _getStatusColor(
                                            orderData.status, theme),
                                        fontWeight: MyntFonts.medium,
                                      ),
                                      overflow: TextOverflow.visible,
                                      softWrap: false,
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
              controller: _ordersHorizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              trackColor: Colors.grey.withValues(alpha: 0.1),
              thumbColor: Colors.grey.withValues(alpha: 0.3),
              thickness: 6,
              radius: const Radius.circular(3),
              interactive: true,
              child: SingleChildScrollView(
                controller: _ordersHorizontalScrollController,
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
    bool alignCenter = false,
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 5;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 6, 10, 6);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(10, 6, 16, 6);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    }

    Alignment cellAlignment;
    if (alignCenter) {
      cellAlignment = Alignment.center;
    } else if (alignRight) {
      cellAlignment = Alignment.centerRight;
    } else {
      cellAlignment = Alignment.centerLeft;
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
          alignment: cellAlignment,
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
      [bool alignRight = false, bool alignCenter = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 5;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 6, 8, 6);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 6, 16, 6);
    } else {
      headerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6);
    }

    Alignment headerAlignment;
    MainAxisAlignment rowAlignment;
    if (alignCenter) {
      headerAlignment = Alignment.center;
      rowAlignment = MainAxisAlignment.center;
    } else if (alignRight) {
      headerAlignment = Alignment.centerRight;
      rowAlignment = MainAxisAlignment.end;
    } else {
      headerAlignment = Alignment.centerLeft;
      rowAlignment = MainAxisAlignment.start;
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
          alignment: headerAlignment,
          child: Row(
            mainAxisAlignment: rowAlignment,
            mainAxisSize: MainAxisSize.min,
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
  Map<int, double> _calculateMinWidths(List orders, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'Date',
      'Fund name',
      'Folio no.',
      'Invest amt',
      'Transaction Type',
      'Status',
    ];

    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth =
          _measureTextWidth(headers[col], textStyle) + sortIconWidth;

      for (final order in orders.take(5)) {
        String cellText = '';
        switch (col) {
          case 0:
            cellText = _formatDate(order.datetime ?? '-');
            break;
          case 1:
            cellText = order.name ?? 'Unknown Fund';
            break;
          case 2:
            cellText = order.foliono ?? '-';
            break;
          case 3:
            cellText = "₹${_formatAmount(order.orderVal)}";
            break;
          case 4:
            cellText = order.buySell ?? '-';
            break;
          case 5:
            cellText = _getListStatusText(order.status);
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

  List _getSortedOrders(List orders) {
    if (_sortColumnIndex == null) return orders;

    final sorted = List.from(orders);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_sortColumnIndex!) {
        case 0: // Date
          comparison = (a.datetime ?? '').compareTo(b.datetime ?? '');
          break;
        case 1: // Fund name
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 2: // Folio no.
          comparison = (a.foliono ?? '').compareTo(b.foliono ?? '');
          break;
        case 3: // Invest amt
          comparison = (double.tryParse(a.orderVal ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.orderVal ?? '0') ?? 0.0);
          break;
        case 4: // Transaction Type
          comparison = (a.buySell ?? '').compareTo(b.buySell ?? '');
          break;
        case 5: // Status
          comparison = (a.status ?? '').compareTo(b.status ?? '');
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  void _showOrderDetail(MFProvider mforderbook, dynamic orderData,
      ThemesProvider theme, BuildContext context) async {
    mforderbook.loaderfun();
    await mforderbook.fetchorderdetails(orderData.orderId ?? "");

    if (mforderbook.mforderdet?.stat == "Ok") {
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
                width: MediaQuery.of(dialogContext).size.width >= 1100
                    ? MediaQuery.of(dialogContext).size.width * 0.25
                    : MediaQuery.of(dialogContext).size.width * 0.90,
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
                child: const mforderdetscreen(),
              ),
            ),
          );
        },
        transitionBuilder:
            (dialogContext, animation, secondaryAnimation, child) {
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
    } else {
      ResponsiveSnackBar.show(
          context: context,
          message:
              mforderbook.mforderdet?.emsg ?? 'Error loading order details',
          type: SnackBarType.warning);
    }
  }

  String _formatDate(String datetime) {
    if (datetime.isEmpty || datetime == "-") return "-";
    // Expected format: "09/10/2025 00:25:57"
    try {
      final parts = datetime.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; // Return just the date part
      }
      return datetime;
    } catch (e) {
      return datetime;
    }
  }

  Color _getStatusColor(String? status, ThemesProvider theme) {
    if (status == "ALLOCATED") {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (status == "REJECTED" ||
        status == "CANCELLED" ||
        status == "PAYMENT DECLINED") {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else if (inProgressStatuses.contains(status)) {
      return colors.pending;
    }
    return colors.pending;
  }

  String _getListStatusText(String? status) {
    if (status == "ALLOCATED") return 'ALLOCATED';
    if (status == "REJECTED") return 'REJECTED';
    if (status == "CANCELLED") return 'CANCELLED';
    if (status == "PAYMENT DECLINED") return 'PAYMENT DECLINED';
    if (inProgressStatuses.contains(status)) return 'IN PROGRESS';

    return status ?? 'Unknown';
  }

  String _getFolio(dynamic orderData) {
    // Check fields in order of priority based on API response
    final dPFolio = orderData.dPFolioNo;
    final folioNo = orderData.folioNo;
    final foliono = orderData.foliono;

    if (dPFolio != null && dPFolio != "null" && dPFolio.trim().isNotEmpty) {
      return dPFolio;
    }
    if (folioNo != null && folioNo != "null" && folioNo.trim().isNotEmpty) {
      return folioNo;
    }
    if (foliono != null && foliono != "null" && foliono.trim().isNotEmpty) {
      return foliono;
    }
    return "-";
  }

  String _formatAmount(String? amount) {
    if (amount == null || amount.isEmpty) return '0.00';
    final value = double.tryParse(amount) ?? 0.0;
    return value.toStringAsFixed(2);
  }
}





// Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(right: 1.0),
//                         child: SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.4,
//                           child: 
//                           TextWidget.subText(
//                                                     align: TextAlign.start,
//                                                     text: orderData.schemename ?? "Unknown Fund",
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textPrimaryDark:
//                                                          colors.textPrimaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                           
//                         ),
//                       ),
//                     ),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         SvgPicture.asset(
//                           _getStatusIcon(orderData.status),
//                           width: 20,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4.0),
//                          child:   TextWidget.paraText(
//                                                     align: TextAlign.start,
//                                                     text: _getStatusText(orderData.status),
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textPrimaryDark:
//                                                          colors.textPrimaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                          
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: orderData.buySell == "P"
//                             ? const Color(0xFFE5F5EA)
//                             : const Color(0xFFFFC7C7),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 4,
//                         vertical: 2
//                       ),
//                       child: Text(
//                         orderData.buySell ?? "-",
//                         style: textStyle(
//                           orderData.buySell == "P"
//                               ? const Color(0xFF42A833)
//                               : const Color(0xFFF33E4B),
//                           10,
//                           FontWeight.w400,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     TextWidget.paraText(
//                                                     align: TextAlign.start,
//                                                     text: "${orderData.ordertype == 'NRM' ? 'One-Time' : 'SIP'}",
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textSecondaryDark:
//                                                           colors.textSecondaryLight 
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                     
//                     const SizedBox(width: 8),
//                     Text(
//                       orderData.dateTime ?? "-",
//                       style: textStyle(
//                         theme.isDarkMode
//                             ? colors.colorWhite
//                             : colors.colorBlack,
//                         10,
//                         FontWeight.w400
//                       ),
//                     ),
//                     const Spacer(),
//                     TextWidget.paraText(
//                                                     align: TextAlign.right,
//                                                     text:  _formatAmount(orderData.amount),
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textSecondaryDark:
//                                                          colors.textSecondaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                    
//                   ],
//                 ),
//               ],
//             ),
//           ),