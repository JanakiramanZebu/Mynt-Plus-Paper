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
import 'mf_sip_details_screen.dart';
import '../../../sharedWidget/common_search_fields_web.dart';

class MFSipdetScreen extends ConsumerStatefulWidget {
  const MFSipdetScreen({super.key});

  @override
  ConsumerState<MFSipdetScreen> createState() => _MFSipdetScreenState();
}

class _MFSipdetScreenState extends ConsumerState<MFSipdetScreen>
    with SingleTickerProviderStateMixin {
  // Tab state
  late TabController _tabController;
  final tablistitems = [
    {"title": "Active SIP's", "index": 0},
    {"title": "SIP Order Book", "index": 1}
  ];

  // Active SIPs sorting state
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Order book sorting state
  int? _orderBookSortColumnIndex;
  bool _orderBookSortAscending = true;

  // Scroll controllers for Active SIPs
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  // Scroll controllers for Order Book
  final ScrollController _orderBookVerticalScrollController = ScrollController();
  final ScrollController _orderBookHorizontalScrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _searchController.clear();
        setState(() {});
      }
    });
    // Auto-load SIP data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).fetchmfsipnotlivelist();
      ref.read(mfProvider).fetchmfsiplist();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _orderBookVerticalScrollController.dispose();
    _orderBookHorizontalScrollController.dispose();
    _searchController.dispose();
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

    return Column(
      children: [
        // Tab Bar and Search Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Tabs
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
                    labelStyle: MyntWebTextStyles.body(
                      context,
                      fontWeight: MyntFonts.semiBold,
                    ).copyWith(
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ),
                    unselectedLabelStyle: MyntWebTextStyles.body(
                      context,
                      fontWeight: MyntFonts.medium,
                    ).copyWith(
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                    unselectedLabelColor: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    tabs: tablistitems.asMap().entries.map((entry) {
                      final tabData = entry.value;
                      return Tab(
                        text: tabData['title'].toString(),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Search
              SizedBox(
                width: 300,
                height: 40,
                child: MyntSearchTextField(
                  controller: _searchController,
                  placeholder: 'Search SIPs',
                  leadingIcon: 'assets/icon/search.svg',
                  onChanged: (value) {
                    // Implement search logic
                  },
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: MyntLoaderOverlay(
            isLoading: mfData.bestmfloader ?? false,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await mfData.fetchmfsiplist();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildActiveSipsTable(context, theme, mfData),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () async {
                    await mfData.fetchmfsipnotlivelist();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSipOrderBookTable(context, theme, mfData),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== ACTIVE SIPs TABLE ====================
  Widget _buildActiveSipsTable(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mfData,
  ) {
    final sipOrders = mfData.mfsiporderlist?.data ?? [];
    final sortedOrders = _sortColumnIndex != null ? _getSortedOrders(sipOrders) : sipOrders;

    return shadcn.OutlinedContainer(
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minWidths = _calculateMinWidths(sortedOrders, context);
          final availableWidth = constraints.maxWidth;

          final columnWidths = <int, double>{};
          for (int i = 0; i < 6; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);

          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;
            const schemeGrowthFactor = 2.5;
            const numericGrowthFactor = 1.0;

            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 6; i++) {
              if (i == 0) {
                growthFactors[i] = schemeGrowthFactor;
                totalGrowthFactor += schemeGrowthFactor;
              } else {
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 6; i++) {
                if (growthFactors[i]! > 0) {
                  final extraForThisColumn = (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                  columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                }
              }
            }
          }

          final totalRequiredWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
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
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(50),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        _buildHeaderCell('Scheme', 0, false, false),
                        _buildHeaderCell('SIP Reg No', 1, true, false),
                        _buildHeaderCell('Amount', 2, true, false),
                        _buildHeaderCell('Frequency', 3, false, false),
                        _buildHeaderCell('Next Installment', 4, true, false),
                        _buildHeaderCell('Status', 5, false, false),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body
                Expanded(
                  child: sortedOrders.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: const Center(
                                child: NoDataFound(
                                  title: "No Active SIPs Found",
                                  subtitle: "There's nothing here yet. Start a SIP to see it here.",
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
                              key: ValueKey('active_table_${_sortColumnIndex}_$_sortAscending'),
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
                                ...sortedOrders.asMap().entries.map((entry) {
                                  final rowIndex = entry.key;
                                  final item = entry.value;

                                  return shadcn.TableRow(
                                    cells: [
                                      // Scheme
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 0,
                                        isOrderBook: false,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          item.name ?? 'N/A',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                      // SIP Reg No
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 1,
                                        alignRight: true,
                                        isOrderBook: false,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          item.sIPRegnNo ?? '-',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Amount
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 2,
                                        alignRight: true,
                                        isOrderBook: false,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          "₹${item.installmentAmount ?? 'N/A'}",
                                          style: _getTextStyle(context),
                                        ),
                                      ),
                                      // Frequency
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 3,
                                        isOrderBook: false,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          item.frequencyType ?? '-',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Next Installment
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 4,
                                        alignRight: true,
                                        isOrderBook: false,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          item.NextSIPDate ?? '-',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Status
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 5,
                                        isOrderBook: false,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(item.status, theme).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getStatusText(item.status).toUpperCase(),
                                            style: MyntWebTextStyles.bodySmall(
                                              context,
                                              color: _getStatusColor(item.status, theme),
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

  // ==================== SIP ORDER BOOK TABLE ====================
  Widget _buildSipOrderBookTable(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mfData,
  ) {
    final sipOrders = mfData.mfnotlivesiporderlist?.data ?? [];
    final sortedOrders = _orderBookSortColumnIndex != null
        ? _getSortedOrderBookOrders(sipOrders)
        : sipOrders;

    return shadcn.OutlinedContainer(
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minWidths = _calculateOrderBookMinWidths(sortedOrders, context);
          final availableWidth = constraints.maxWidth;

          final columnWidths = <int, double>{};
          for (int i = 0; i < 9; i++) {
            columnWidths[i] = minWidths[i] ?? 100.0;
          }

          final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);

          if (totalMinWidth < availableWidth) {
            final extraSpace = availableWidth - totalMinWidth;
            const fundNameGrowthFactor = 2.5;
            const numericGrowthFactor = 1.0;

            final growthFactors = <int, double>{};
            double totalGrowthFactor = 0.0;

            for (int i = 0; i < 9; i++) {
              if (i == 4) {
                growthFactors[i] = fundNameGrowthFactor;
                totalGrowthFactor += fundNameGrowthFactor;
              } else {
                growthFactors[i] = numericGrowthFactor;
                totalGrowthFactor += numericGrowthFactor;
              }
            }

            if (totalGrowthFactor > 0) {
              for (int i = 0; i < 9; i++) {
                if (growthFactors[i]! > 0) {
                  final extraForThisColumn = (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                  columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                }
              }
            }
          }

          final totalRequiredWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
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
                    8: shadcn.FixedTableSize(columnWidths[8]!),
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(50),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        _buildHeaderCell('SIP Register Date', 0, false, true),
                        _buildHeaderCell('Start Date', 1, false, true),
                        _buildHeaderCell('End Date', 2, false, true),
                        _buildHeaderCell('Next SIP Date', 3, false, true),
                        _buildHeaderCell('Fund name', 4, false, true),
                        _buildHeaderCell('Frequency Type', 5, false, true),
                        _buildHeaderCell('Installment amt', 6, true, true),
                        _buildHeaderCell('SIP Register No.', 7, false, true),
                        _buildHeaderCell('Status', 8, false, true),
                      ],
                    ),
                  ],
                ),
                // Scrollable Body
                Expanded(
                  child: sortedOrders.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: const Center(
                                child: NoDataFound(
                                  title: "No SIP Orders Found",
                                  subtitle: "There's nothing here yet.",
                                  secondaryEnabled: false,
                                ),
                              ),
                            ),
                          ),
                        )
                      : RawScrollbar(
                          controller: _orderBookVerticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          trackColor: Colors.grey.withValues(alpha: 0.1),
                          thumbColor: Colors.grey.withValues(alpha: 0.3),
                          thickness: 6,
                          radius: const Radius.circular(3),
                          interactive: true,
                          child: SingleChildScrollView(
                            controller: _orderBookVerticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: shadcn.Table(
                              key: ValueKey('orderbook_table_${_orderBookSortColumnIndex}_$_orderBookSortAscending'),
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
                                ...sortedOrders.asMap().entries.map((entry) {
                                  final rowIndex = entry.key;
                                  final item = entry.value;

                                  return shadcn.TableRow(
                                    cells: [
                                      // SIP Register Date
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 0,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          _formatDate(item.sIPRegnDate ?? '-'),
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Start Date
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 1,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          _formatDate(item.startDate ?? '-'),
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // End Date
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 2,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          _formatDate(item.endDate ?? '-'),
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Next SIP Date
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 3,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          _formatDate(item.NextSIPDate ?? '-'),
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Fund name
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 4,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          item.name ?? 'Unknown Scheme',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                      // Frequency Type
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 5,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          item.frequencyType ?? '-',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Installment amt
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 6,
                                        alignRight: true,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          "₹${item.installmentAmount ?? 'N/A'}",
                                          style: _getTextStyle(context),
                                        ),
                                      ),
                                      // SIP Register No.
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 7,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Text(
                                          item.sIPRegnNo ?? '-',
                                          style: _getTextStyle(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Status
                                      _buildCellWithHover(
                                        rowIndex: rowIndex,
                                        columnIndex: 8,
                                        isOrderBook: true,
                                        onTap: () => _showSipDetail(mfData, item, context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(item.status, theme).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getStatusText(item.status).toUpperCase(),
                                            style: MyntWebTextStyles.bodySmall(
                                              context,
                                              color: _getStatusColor(item.status, theme),
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

          if (needsHorizontalScroll) {
            return RawScrollbar(
              controller: _orderBookHorizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              trackColor: Colors.grey.withValues(alpha: 0.1),
              thumbColor: Colors.grey.withValues(alpha: 0.3),
              thickness: 6,
              radius: const Radius.circular(3),
              interactive: true,
              child: SingleChildScrollView(
                controller: _orderBookHorizontalScrollController,
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

  // ==================== COMMON CELL & HEADER BUILDERS ====================

  shadcn.TableCell _buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    bool isOrderBook = false,
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = isOrderBook ? columnIndex == 8 : columnIndex == 5;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 6, 10, 6);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(10, 6, 16, 6);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
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

  shadcn.TableCell _buildHeaderCell(String label, int columnIndex, bool alignRight, bool isOrderBook) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = isOrderBook ? columnIndex == 8 : columnIndex == 5;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 6, 8, 6);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 6, 16, 6);
    } else {
      headerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6);
    }

    final sortColumnIndex = isOrderBook ? _orderBookSortColumnIndex : _sortColumnIndex;
    final sortAscending = isOrderBook ? _orderBookSortAscending : _sortAscending;

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
        onTap: () => isOrderBook ? _onOrderBookSort(columnIndex) : _onSort(columnIndex),
        child: Container(
          padding: headerPadding,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && sortColumnIndex == columnIndex)
                Icon(
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: MyntColors.textSecondaryDark,
                ),
              if (alignRight && sortColumnIndex == columnIndex) const SizedBox(width: 4),
              Text(
                label,
                style: _getHeaderStyle(context),
              ),
              if (!alignRight && sortColumnIndex == columnIndex) const SizedBox(width: 4),
              if (!alignRight && sortColumnIndex == columnIndex)
                Icon(
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: MyntColors.textSecondaryDark,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SORTING ====================

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

  void _onOrderBookSort(int columnIndex) {
    setState(() {
      if (_orderBookSortColumnIndex == columnIndex) {
        _orderBookSortAscending = !_orderBookSortAscending;
      } else {
        _orderBookSortColumnIndex = columnIndex;
        _orderBookSortAscending = true;
      }
    });
  }

  // Active SIPs column widths
  Map<int, double> _calculateMinWidths(List orders, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = ['Scheme', 'SIP Reg No', 'Amount', 'Frequency', 'Next Installment', 'Status'];
    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = _measureTextWidth(headers[col], textStyle) + sortIconWidth;

      for (final order in orders.take(5)) {
        String cellText = '';
        switch (col) {
          case 0:
            cellText = order.name ?? 'N/A';
            break;
          case 1:
            cellText = order.sIPRegnNo ?? '-';
            break;
          case 2:
            cellText = "₹${order.installmentAmount ?? 'N/A'}";
            break;
          case 3:
            cellText = order.frequencyType ?? '-';
            break;
          case 4:
            cellText = order.NextSIPDate ?? '-';
            break;
          case 5:
            cellText = _getStatusText(order.status);
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

  // Order Book column widths
  Map<int, double> _calculateOrderBookMinWidths(List orders, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'SIP Register Date',
      'Start Date',
      'End Date',
      'Next SIP Date',
      'Fund name',
      'Frequency Type',
      'Installment amt',
      'SIP Register No.',
      'Status',
    ];

    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = _measureTextWidth(headers[col], textStyle) + sortIconWidth;

      for (final order in orders.take(5)) {
        String cellText = '';
        switch (col) {
          case 0:
            cellText = _formatDate(order.sIPRegnDate ?? '-');
            break;
          case 1:
            cellText = _formatDate(order.startDate ?? '-');
            break;
          case 2:
            cellText = _formatDate(order.endDate ?? '-');
            break;
          case 3:
            cellText = _formatDate(order.NextSIPDate ?? '-');
            break;
          case 4:
            cellText = order.name ?? 'Unknown Scheme';
            break;
          case 5:
            cellText = order.frequencyType ?? '-';
            break;
          case 6:
            cellText = "₹${order.installmentAmount ?? 'N/A'}";
            break;
          case 7:
            cellText = order.sIPRegnNo ?? '-';
            break;
          case 8:
            cellText = _getStatusText(order.status);
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
        case 0: // Scheme
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 1: // SIP Reg No
          comparison = (a.sIPRegnNo ?? '').compareTo(b.sIPRegnNo ?? '');
          break;
        case 2: // Amount
          comparison = (double.tryParse(a.installmentAmount ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.installmentAmount ?? '0') ?? 0.0);
          break;
        case 3: // Frequency
          comparison = (a.frequencyType ?? '').compareTo(b.frequencyType ?? '');
          break;
        case 4: // Next Installment
          comparison = (a.NextSIPDate ?? '').compareTo(b.NextSIPDate ?? '');
          break;
        case 5: // Status
          comparison = (a.status ?? '').compareTo(b.status ?? '');
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  List _getSortedOrderBookOrders(List orders) {
    if (_orderBookSortColumnIndex == null) return orders;

    final sorted = List.from(orders);
    sorted.sort((a, b) {
      int comparison = 0;

      switch (_orderBookSortColumnIndex!) {
        case 0: // SIP Register Date
          comparison = (a.sIPRegnDate ?? '').compareTo(b.sIPRegnDate ?? '');
          break;
        case 1: // Start Date
          comparison = (a.startDate ?? '').compareTo(b.startDate ?? '');
          break;
        case 2: // End Date
          comparison = (a.endDate ?? '').compareTo(b.endDate ?? '');
          break;
        case 3: // Next SIP Date
          comparison = (a.NextSIPDate ?? '').compareTo(b.NextSIPDate ?? '');
          break;
        case 4: // Fund name
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 5: // Frequency Type
          comparison = (a.frequencyType ?? '').compareTo(b.frequencyType ?? '');
          break;
        case 6: // Installment amt
          comparison = (double.tryParse(a.installmentAmount ?? '0') ?? 0.0)
              .compareTo(double.tryParse(b.installmentAmount ?? '0') ?? 0.0);
          break;
        case 7: // SIP Register No.
          comparison = (a.sIPRegnNo ?? '').compareTo(b.sIPRegnNo ?? '');
          break;
        case 8: // Status
          comparison = (a.status ?? '').compareTo(b.status ?? '');
          break;
      }

      return _orderBookSortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  // ==================== HELPERS ====================

  void _showSipDetail(MFProvider mfData, dynamic item, BuildContext context) async {
    final sIPRegnNo = item.sIPRegnNo;

    if (sIPRegnNo != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: MyntLoader(size: MyntLoaderSize.large),
        ),
      );

      try {
        await mfData.fetchMFSipData(item.iSIN, item.schemeCode);
        mfData.clearPauseError();

        if (context.mounted) Navigator.pop(context);

        if (context.mounted) {
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
                    child: mfSipdetScren(data: item),
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
      } catch (e) {
        if (context.mounted) Navigator.pop(context);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load SIP details: ${e.toString()}")),
          );
        }
      }
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty || date == "-") return "-";
    return date;
  }

  String _getStatusText(String? status) {
    if (status == "ACTIVE") return "LIVE";
    return status?.toUpperCase() ?? "UNKNOWN";
  }

  Color _getStatusColor(String? status, ThemesProvider theme) {
    if (status == "ACTIVE") {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    }
    return theme.isDarkMode ? colors.lossDark : colors.lossLight;
  }
}
