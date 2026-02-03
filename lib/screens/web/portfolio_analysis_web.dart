import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cross_file/cross_file.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import '../../../../models/explore_model/portfolioanalisys_models.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../locator/preference.dart';
import '../../../../sharedWidget/common_search_fields_web.dart';
import '../../../../sharedWidget/common_buttons_web.dart';

class PortfolioDashboardScreen extends ConsumerStatefulWidget {
  const PortfolioDashboardScreen({super.key});

  @override
  ConsumerState<PortfolioDashboardScreen> createState() =>
      _PortfolioDashboardScreenState();
}

class _PortfolioDashboardScreenState
    extends ConsumerState<PortfolioDashboardScreen> with TickerProviderStateMixin {
  FlSpot? touchedSpot;
  bool showTooltip = false;
  // Heatmap interaction state
  final GlobalKey _heatmapKey = GlobalKey();
  List<Rect> _heatmapRects = [];
  List<TopStocks> _heatmapHoldingsShown = [];
  OverlayEntry? _heatmapOverlay;
  int? _selectedHeatmapIndex;
  late TabController tabCtrl;

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  // Holdings table sort state
  int? _tableSortColumnIndex;
  bool _tableSortAscending = true;

  // Holdings table hover state (for row highlight)
  final ValueNotifier<int?> _tableHoveredRowIndex = ValueNotifier<int?>(null);

  // Scroll controller for table body
  final ScrollController _tableScrollController = ScrollController();
  
  // RepaintBoundary for share capture - each section
  final GlobalKey _shareBoundaryKey = GlobalKey(); // For body wrapper
  final GlobalKey _portfolioSummaryKey = GlobalKey();
  final GlobalKey _marketCapSectionKey = GlobalKey();
  final GlobalKey _heatmapSectionKey = GlobalKey();
  
  // Key for summary screen capture
  final GlobalKey _summaryScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dashboardProvider).getPortfolioAnalysis();
        // Add listener to detect when search text is cleared (e.g., by shadcn clear button)
        ref.read(dashboardProvider).portfolioSearchController.addListener(_onSearchTextChanged);
    });

  }

  // Listener to handle search text changes (including clear button)
  void _onSearchTextChanged() {
    final dashboardState = ref.read(dashboardProvider);
    final text = dashboardState.portfolioSearchController.text.trim();
    if (text.isEmpty) {
      // Clear search results when text is empty
      dashboardState.clearPortfolioSearch();
    }
  }

  Timer? _hideTooltipTimer;

  @override
  void dispose() {
    _hideTooltipTimer?.cancel();
    // Remove search controller listener
    try {
      ref.read(dashboardProvider).portfolioSearchController.removeListener(_onSearchTextChanged);
    } catch (_) {}
    _scrollController.dispose();
    _tableScrollController.dispose();
    _tableHoveredRowIndex.dispose();
    tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final portfolio = ref.watch(dashboardProvider);
    return Scaffold(
      backgroundColor: resolveThemeColor(
        context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor,
      ),
      body: SafeArea(
          child: RepaintBoundary(
            key: _shareBoundaryKey,
            child: Consumer(
              builder: (context, ref, child) {
                if (portfolio.isPortfolioLoading == true) {
                  return Center(
                    child: MyntLoader.centered(
                      showLogo: true,
                      size: MyntLoaderSize.large,
                    ),
                  );
                }
                if (portfolio.portfolioAnalysis == null &&
                    portfolio.isPortfolioLoading == false) {
                  return const Center(
                    child: NoDataFound(
                      secondaryEnabled: false,
                    ),
                  );
                }

                return _buildDashboardContentWithStickyHeader(
                    ref.watch(dashboardProvider).portfolioAnalysis!);
              },
            ),
          )),
    );
  }

  Future<void> _captureAndShareScreenshot(BuildContext context) async {
    try {
      // Get portfolio data
      final portfolio = ref.read(dashboardProvider);
      final portfolioData = portfolio.portfolioAnalysis;
      if (portfolioData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No portfolio data available')),
          );
        }
        return;
      }

      // Show summary screen in dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: RepaintBoundary(
            key: _summaryScreenKey,
            child: _buildSummaryScreen(portfolioData),
          ),
        ),
      );

      // Wait for the summary screen to render
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture the summary screen
      final summaryBoundary = _summaryScreenKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (summaryBoundary == null) {
        Navigator.pop(context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture summary screen')),
          );
        }
        return;
      }

      final uiImage = await summaryBoundary.toImage(pixelRatio: 3.0);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      
      // Close dialog
      Navigator.pop(context);

      if (byteData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process screenshot')),
          );
        }
        return;
      }

      // Save image
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'portfolio_summary_$timestamp.png';
      final filePath = path.join(directory.path, fileName);
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(byteData.buffer.asUint8List());

      // Share the image
      if (context.mounted) {
        final pref = Preferences();
        final clientId = pref.clientId ?? '';
        final currentDate = DateTime.now().toString().split(' ')[0];
        final shareText = "My Holdings Portfolio Summary - $currentDate \n\nDownload Full PDF Report: https://rekycbe.mynt.in/report/portfolio_pdf?cc=$clientId ";
        await Share.shareXFiles(
          [XFile(filePath)],
          text: shareText,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing screenshot: $e')),
        );
      }
    }
  }

  Widget _buildSummaryScreen(PortfolioResponse data) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.5;
    final pref = Preferences();
    final clientName = pref.clientName ?? '';
    
    return Container(
      width: screenWidth,
      height: screenHeight,
      color: resolveThemeColor(
        context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor,
      ),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Align(
                alignment: Alignment.topRight,
                 child: SvgPicture.asset(
                          "assets/icon/Mynt New logo.svg",
                          color: const Color(0xff0037B7),
                          width: 80,
                          fit: BoxFit.contain,
                        ),
               ),
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (clientName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$clientName',
                      style: MyntWebTextStyles.title(
                        context,
                        color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              // XIRR Chart
              if (data.chartData != null) ...[
                _buildInvestmentChart(data.chartData!, data),
                const SizedBox(height: 40),
              ],
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContentWithStickyHeader(PortfolioResponse data) {
    final theme = ref.watch(themeProvider);
    final dashboardState = ref.watch(dashboardProvider);

    // Get filtered holdings based on selected filters
    final filteredHoldings = dashboardState.getFilteredHoldings(data.topStocks);

    // When there's search text, use search results. Otherwise use filtered list
    final searchText = dashboardState.portfolioSearchController.text.trim();
    final itemsToDisplay = searchText.isNotEmpty
        ? dashboardState.portfolioSearchItems
        : filteredHoldings;

    // Apply gainer/loser quick filter only at UI layer, without touching base filters
    List<TopStocks> displayList = itemsToDisplay;
    if (dashboardState.selectedPnLSignFilter == 'gainers') {
      displayList = displayList
          .where((h) => (h.pnlPercent ?? 0).toDouble() > 0)
          .toList()
        ..sort((a, b) => (b.pnlPercent ?? 0).compareTo(a.pnlPercent ?? 0)); // Descending
    } else if (dashboardState.selectedPnLSignFilter == 'losers') {
      displayList = displayList
          .where((h) => (h.pnlPercent ?? 0).toDouble() < 0)
          .toList()
        ..sort((a, b) => (a.pnlPercent ?? 0).compareTo(b.pnlPercent ?? 0)); // Ascending
    }

    final validFundamentals = displayList.toList();

    return CustomScrollView(
      physics: ClampingScrollPhysics(),
      controller: _scrollController,
      slivers: [
        // Main content section
        SliverToBoxAdapter(
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portfolio Summary Section
                  if (data.chartData != null)
                    RepaintBoundary(
                      key: _portfolioSummaryKey,
                      child: Container(
                        color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
                        child: _buildInvestmentChart(data.chartData!, data),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Market Cap/Sector/Asset Allocation Section
                    RepaintBoundary(
                      key: _marketCapSectionKey,
                      child: Container(
                        color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
                        child: Column(
                          children: [
                          SizedBox(
                            height: 30,
                            child: TabBar(
                            controller: tabCtrl,
                            tabAlignment: TabAlignment.start,
                            isScrollable: true,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorColor: colors.colorWhite,
                            indicator: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.searchBgDark
                                  : const Color(0xffF1F3F8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            unselectedLabelColor: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                            labelStyle: MyntWebTextStyles.body(
                                context,
                                fontWeight: FontWeight.w600,
                                color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)),
                            unselectedLabelStyle: MyntWebTextStyles.body(
                                context,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondaryLight),
                            // labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                            tabs: const [
                              Tab(text: "Market Cap"),
                              Tab(text: "Sector"),
                              Tab(text: "Asset Allocation"),
                            ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 250,
                            child: TabBarView(
                              controller: tabCtrl,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildChartsSection(data),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildSectorAllocationTable(data.sectorAllocation),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildAccountAllocation(data.accountAllocation , theme.isDarkMode),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  // Heatmap Section
                  RepaintBoundary(
                    key: _heatmapSectionKey,
                    child: Container(
                      color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
                      child: _buildHeatMap(data.topStocks),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // SizedBox(height: 16),
                  // _buildAccountAllocation(data.accountAllocation , theme.isDarkMode),
                  // SizedBox(height: 16),
                  // _buildChartsSection(data),
                  // SizedBox(height: 16),
                  // _buildSectorAllocationTable(data.sectorAllocation),
                  // SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        // Search and Filter Section (matching Holdings UI)
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
            color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
            child: _buildSearchAndFilterRow(theme),
          ),
        ),
        // Holdings list
        _buildHoldingsSliverList(
            validFundamentals, theme, dashboardState, searchText),
        // Add bottom padding for better spacing
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 30),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }

  /// Search and Filter Row matching Holdings UI
  Widget _buildSearchAndFilterRow(ThemesProvider theme) {
    final dashboardState = ref.watch(dashboardProvider);
    final isDark = theme.isDarkMode;

    // Build Gainer/Loser chip
    Widget buildChip({
      required String label,
      required String value,
      required Color activeColor,
    }) {
      final bool isActive = dashboardState.selectedPnLSignFilter == value;
      final Color bg = isActive
          ? (isDark ? activeColor.withValues(alpha: 0.2) : activeColor.withValues(alpha: 0.15))
          : Colors.transparent;
      final Color border = isActive
          ? activeColor
          : (isDark ? colors.textSecondaryDark.withValues(alpha: 0.3) : colors.textSecondaryLight.withValues(alpha: 0.3));
      final Color textColor = isActive
          ? (resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary))
          : (resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary));

      return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          dashboardState.setPnLSignFilter(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: border, width: 1),
          ),
          child: Text(
            label,
            style: MyntWebTextStyles.para(
              context,
              color: textColor,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Build filter icon button (matching holdings)
    Widget buildFilterButton() {
      return Builder(
        builder: (buttonContext) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showFilterBottomSheet(buttonContext, theme),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    assets.searchFilter,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      resolveThemeColor(
                        context,
                        dark: MyntColors.iconDark,
                        light: MyntColors.icon,
                      ),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Calculate search width based on screen size (like Holdings)
    final screenWidth = MediaQuery.of(context).size.width;
    double searchWidth;
    if (screenWidth >= 1200) {
      searchWidth = 300;
    } else if (screenWidth >= 800) {
      searchWidth = 250;
    } else {
      searchWidth = 200;
    }

    return Row(
      children: [
        // Holdings title on left
        Text(
          'Holdings',
          style: MyntWebTextStyles.title(
            context,
            color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
            fontWeight: FontWeight.w600,
          ),
        ),
        // Spacer to push search to right
        const Spacer(),
        // Search bar (fixed width like Holdings)
        SizedBox(
          width: searchWidth,
          child: MyntSearchTextField.withSmartClear(
            controller: dashboardState.portfolioSearchController,
            placeholder: 'Search on holdings',
            leadingIcon: assets.searchIcon,
            onChanged: (value) {
              final baseList = dashboardState.getFilteredHoldings(
                  dashboardState.portfolioAnalysis?.topStocks ?? []);
              dashboardState.searchPortfolioHoldings(value, baseList);
            },
            onClear: () {
              dashboardState.clearPortfolioSearch();
            },
          ),
        ),
        const SizedBox(width: 12),
        // Filter button
        buildFilterButton(),
        const SizedBox(width: 8),
        // Gainers chip
        buildChip(
          label: 'Gainers',
          value: 'gainers',
          activeColor: colors.successLight,
        ),
        const SizedBox(width: 8),
        // Losers chip
        buildChip(
          label: 'Losers',
          value: 'losers',
          activeColor: colors.lossLight,
        ),
      ],
    );
  }

  Widget _buildHoldingsSliverList(List<TopStocks> validFundamentals,
      ThemesProvider theme, dynamic dashboardState, String searchText) {
    // Always show table with headers, pass empty flag for NoDataFound inside table
    return _buildHoldingsSliverTable(validFundamentals);
  }

  // Sliver-based table that scrolls with the main content
  Widget _buildHoldingsSliverTable(List<TopStocks> holdings) {
    // Table header style
    TextStyle getHeaderStyle(BuildContext context) {
      return MyntWebTextStyles.tableHeader(
        context,
        darkColor: MyntColors.textSecondaryDark,
        lightColor: MyntColors.textSecondary,
        fontWeight: FontWeight.w600,
      );
    }

    // Table cell style
    TextStyle getCellStyle(BuildContext context, {Color? color}) {
      return MyntWebTextStyles.tableCell(
        context,
        color: color,
        darkColor: color ?? MyntColors.textPrimaryDark,
        lightColor: color ?? MyntColors.textPrimary,
        fontWeight: FontWeight.w500,
      );
    }

    // Get color for P&L values
    Color getValueColor(double value) {
      if (value > 0) {
        return resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);
      }
      if (value < 0) {
        return resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
      }
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }

    // Sort handler
    void onSort(int columnIndex) {
      setState(() {
        if (_tableSortColumnIndex == columnIndex) {
          _tableSortAscending = !_tableSortAscending;
        } else {
          _tableSortColumnIndex = columnIndex;
          _tableSortAscending = true;
        }
      });
    }

    // Sort holdings based on selected column
    // Capture values in local variables for closure (Dart type promotion doesn't work across closures for instance variables)
    final sortColumnIndex = _tableSortColumnIndex;
    final sortAscending = _tableSortAscending;

    List<TopStocks> sortedHoldings = List.from(holdings);
    if (sortColumnIndex != null) {
      sortedHoldings.sort((a, b) {
        int comparison = 0;
        switch (sortColumnIndex) {
          case 0: // Stock Name
            comparison = (a.name ?? '').compareTo(b.name ?? '');
            break;
          case 1: // Qty
            final qtyA = double.tryParse(a.qty ?? '0') ?? 0;
            final qtyB = double.tryParse(b.qty ?? '0') ?? 0;
            comparison = qtyA.compareTo(qtyB);
            break;
          case 2: // Invested
            comparison = (a.inverstedAmount ?? 0).compareTo(b.inverstedAmount ?? 0);
            break;
          case 3: // Allocation
            comparison = (a.allocationPercent ?? 0).compareTo(b.allocationPercent ?? 0);
            break;
          case 4: // P&L %
            comparison = (a.pnlPercent ?? 0).compareTo(b.pnlPercent ?? 0);
            break;
        }
        return sortAscending ? comparison : -comparison;
      });
    }

    // Build header cell with sorting (like hold_table.dart)
    shadcn.TableCell buildHeaderCell(String label, int columnIndex, [bool alignRight = false]) {
      final isFirstColumn = columnIndex == 0;
      final isLastColumn = columnIndex == 4;

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
          onTap: () => onSort(columnIndex),
          child: Container(
            padding: headerPadding,
            alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (alignRight && _tableSortColumnIndex == columnIndex)
                  Icon(
                    _tableSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                if (alignRight && _tableSortColumnIndex == columnIndex)
                  const SizedBox(width: 4),
                Text(label, style: getHeaderStyle(context)),
                if (!alignRight && _tableSortColumnIndex == columnIndex)
                  const SizedBox(width: 4),
                if (!alignRight && _tableSortColumnIndex == columnIndex)
                  Icon(
                    _tableSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
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

    // Build cell with hover detection (like hold_table.dart)
    shadcn.TableCell buildCellWithHover({
      required Widget child,
      required int rowIndex,
      required int columnIndex,
      bool alignRight = false,
      TopStocks? holding,
    }) {
      final isFirstColumn = columnIndex == 0;
      final isLastColumn = columnIndex == 4;

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
          onEnter: (_) => _tableHoveredRowIndex.value = rowIndex,
          onExit: (_) => _tableHoveredRowIndex.value = null,
          child: ValueListenableBuilder<int?>(
            valueListenable: _tableHoveredRowIndex,
            child: child,
            builder: (context, hoveredIndex, cachedChild) {
              final isRowHovered = hoveredIndex == rowIndex;

              final container = Container(
                padding: cellPadding,
                color: isRowHovered
                    ? resolveThemeColor(context,
                        dark: MyntColors.primary.withValues(alpha: 0.08),
                        light: MyntColors.primary.withValues(alpha: 0.08))
                    : null,
                alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
                child: cachedChild,
              );

              // Wrap with GestureDetector for row tap when holding data is provided
              if (holding != null) {
                return GestureDetector(
                  onTap: () async {
                    final marketWatch = ref.read(marketWatchProvider);

                    if (!_isMarketDepthAvailable(
                        holding.exch ?? '', holding.zebuToken ?? '', holding.tsym ?? '')) {
                      warningMessage(context, 'Details not available for this holding');
                      return;
                    }

                    try {
                      final depthArgs = <String, dynamic>{
                        'exch': holding.exch.toString(),
                        'token': holding.zebuToken.toString(),
                        'tsym': holding.tsym.toString().split(':').last,
                        'instname': '',
                        'symbol': holding.tsym.toString(),
                        'expDate': '',
                        'option': '',
                      };

                      if (depthArgs['exch'] == 'null' ||
                          depthArgs['token'] == 'null' ||
                          depthArgs['tsym'] == 'null' ||
                          depthArgs['exch'].isEmpty ||
                          depthArgs['token'].isEmpty ||
                          depthArgs['tsym'].isEmpty) {
                        warningMessage(context, 'Details not available for this item');
                        return;
                      }

                      marketWatch.calldepthApis(context, depthArgs, "");
                      marketWatch.scripdepthsize(false);
                    } catch (e) {
                      error(context, 'Unable to load details. Please try again.');
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: container,
                );
              }
              return container;
            },
          ),
        ),
      );
    }

    // Fixed table height
    const double tableHeight = 600;

    return SliverMainAxisGroup(
      slivers: [
        // Table container using shadcn.OutlinedContainer (matches hold_table.dart)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: tableHeight,
              child: shadcn.OutlinedContainer(
                child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate column widths based on available width (flex proportions: 3:2:2:2:2 = 11 total)
                  final totalFlex = 11.0;
                  final availableWidth = constraints.maxWidth;
                  final unitWidth = availableWidth / totalFlex;

                  final columnWidths = {
                    0: shadcn.FixedTableSize(unitWidth * 3), // Stock Name (flex 3)
                    1: shadcn.FixedTableSize(unitWidth * 2), // Qty (flex 2)
                    2: shadcn.FixedTableSize(unitWidth * 2), // Invested (flex 2)
                    3: shadcn.FixedTableSize(unitWidth * 2), // Allocation (flex 2)
                    4: shadcn.FixedTableSize(unitWidth * 2), // P&L % (flex 2)
                  };

                  // Check if no data
                  if (sortedHoldings.isEmpty) {
                    return Column(
                      children: [
                        // Header Row (always show)
                        shadcn.Table(
                          columnWidths: columnWidths,
                          defaultRowHeight: const shadcn.FixedTableSize(50),
                          rows: [
                            shadcn.TableHeader(
                              cells: [
                                buildHeaderCell('Stock Name', 0),
                                buildHeaderCell('Qty', 1, true),
                                buildHeaderCell('Invested', 2, true),
                                buildHeaderCell('Allocation', 3, true),
                                buildHeaderCell('P&L %', 4, true),
                              ],
                            ),
                          ],
                        ),
                        // No Data Found inside table body area
                        Expanded(
                          child: Center(
                            child: const NoDataFound(
                              secondaryEnabled: false,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Table with fixed header and scrollable body
                  return Column(
                    children: [
                      // Fixed Header
                      shadcn.Table(
                        columnWidths: columnWidths,
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: [
                          shadcn.TableHeader(
                            cells: [
                              buildHeaderCell('Stock Name', 0),
                              buildHeaderCell('Qty', 1, true),
                              buildHeaderCell('Invested', 2, true),
                              buildHeaderCell('Allocation', 3, true),
                              buildHeaderCell('P&L %', 4, true),
                            ],
                          ),
                        ],
                      ),
                      // Scrollable Body
                      Expanded(
                        child: RawScrollbar(
                          controller: _tableScrollController,
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
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              controller: _tableScrollController,
                              child: shadcn.Table(
                              key: ValueKey('table_${_tableSortColumnIndex}_$_tableSortAscending'),
                              columnWidths: columnWidths,
                              defaultRowHeight: const shadcn.FixedTableSize(50),
                              rows: [
                                // Data Rows
                                ...sortedHoldings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final holding = entry.value;
                    final pnlColor = getValueColor(holding.pnlPercent ?? 0);

                    return shadcn.TableRow(
                      cells: [
                        // Stock Name with Exchange (inline)
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 0,
                          holding: holding,
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: holding.name ?? '',
                                  style: getCellStyle(context),
                                ),
                                if (holding.exch != null && holding.exch!.isNotEmpty)
                                  TextSpan(
                                    text: ' ${holding.exch}',
                                    style: MyntWebTextStyles.para(
                                      context,
                                      darkColor: MyntColors.textSecondaryDark,
                                      lightColor: MyntColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ).copyWith(fontSize: 10),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Qty
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 1,
                          alignRight: true,
                          holding: holding,
                          child: Text(
                            holding.qty?.split('.')[0] ?? '0',
                            style: getCellStyle(context),
                          ),
                        ),
                        // Invested
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 2,
                          alignRight: true,
                          holding: holding,
                          child: Text(
                            (holding.inverstedAmount ?? 0).toStringAsFixed(2),
                            style: getCellStyle(context),
                          ),
                        ),
                        // Allocation %
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 3,
                          alignRight: true,
                          holding: holding,
                          child: Text(
                            '${(holding.allocationPercent ?? 0).toStringAsFixed(2)}%',
                            style: getCellStyle(context),
                          ),
                        ),
                        // P&L %
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 4,
                          alignRight: true,
                          holding: holding,
                          child: Text(
                            '${(holding.pnlPercent ?? 0).toStringAsFixed(2)}%',
                            style: getCellStyle(context, color: pnlColor),
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
        ),
      ],
    );
                },
              ),
            ),
          ),
        ),
      ),
      ],
    );
  }

  Widget _buildInvestmentChart(ChartData chartData, PortfolioResponse data) {
    final theme = ref.watch(themeProvider);
    final portfolio = ref.watch(dashboardProvider);
    if (chartData.dates.isEmpty) return const SizedBox.shrink();

    // Use all data points for better representation
    List<FlSpot> investedSpots = [];
    List<FlSpot> currentSpots = [];

    for (int i = 0; i < chartData.dates.length; i++) {
      investedSpots.add(FlSpot(i.toDouble(),
          chartData.totalInvestedValue[i] / 1000)); // Convert to thousands
      currentSpots
          .add(FlSpot(i.toDouble(), chartData.totalCurrentValue[i] / 1000));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Summary',
                      style: MyntWebTextStyles.title(
                        context,
                        color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${data.xirrResult.toStringAsFixed(2)}%',
                      style: MyntWebTextStyles.title(
                        context,
                        color: data.xirrResult.toStringAsFixed(2).startsWith("-")
                            ? resolveThemeColor(context, dark: MyntColors.lossDark, light: MyntColors.loss)
                            : data.xirrResult == 0
                                ? MyntColors.textSecondary
                                : resolveThemeColor(context, dark: MyntColors.profitDark, light: MyntColors.profit),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'XIRR Return',
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                // Custom tooltip positioned above chart
                if (showTooltip && touchedSpot != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark.withOpacity(0.2)
                          : colors.textSecondaryLight.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.4)
                            : colors.textSecondaryLight.withOpacity(0.2),
                        width: 0,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final index = touchedSpot!.x.toInt();
                        if (index >= 0 &&
                            index < investedSpots.length &&
                            index < currentSpots.length &&
                            index < chartData.dates.length) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDate(chartData.dates[index]),
                                style: MyntWebTextStyles.bodySmall(
                                  context,
                                  color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Invested: ${investedSpots[index].y.toStringAsFixed(2)}K',
                                style: MyntWebTextStyles.para(
                                  context,
                                  color: const Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Current: ${currentSpots[index].y.toStringAsFixed(2)}K',
                                style: MyntWebTextStyles.para(
                                  context,
                                  color: const Color(0xFF8B5CF6),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: false,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Color(0xFFE5E7EB),
                      strokeWidth: 0.1,
                      dashArray: [1, 1],
                    ),
                    horizontalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < investedSpots.length) {
                            final dataIndex = value
                                .toInt()
                                .clamp(0, chartData.dates.length - 1);
                            final totalPoints = investedSpots.length;
                            final labelInterval =
                                (totalPoints / 6).ceil().clamp(1, totalPoints);

                            if (value.toInt() == 0 ||
                                value.toInt() == investedSpots.length - 1 ||
                                value.toInt() % labelInterval == 0) {
                              final dateString = chartData.dates[dataIndex];

                              try {
                                final date = DateTime.parse(dateString);
                                final month =
                                    portfolio.getMonthAbbreviation(date.month);
                                final year = date.year.toString().substring(2);

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: value.toInt() == 0 ? 20 : 0,
                                    right: value.toInt() ==
                                            investedSpots.length - 1
                                        ? 20
                                        : 0,
                                  ),
                                  child: Text(
                                    '$month $year',
                                    style: MyntWebTextStyles.caption(
                                      context,
                                      color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                return const Text('');
                              }
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (chartData.dates.length - 1).toDouble(),
                  minY: 0,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      // CRITICAL FIX: Return null items for each touched spot
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        // Return null for each touched spot to hide default tooltips
                        // but maintain the same count to avoid the error
                        return touchedBarSpots.map((spot) => null).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      // Handle different touch events
                      if (event is FlTapUpEvent ||
                          event is FlPanUpdateEvent ||
                          event is FlPanStartEvent ||
                          event is FlTapDownEvent) {
                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null) {
                          final spot = touchResponse.lineBarSpots!.first;
                          final index = spot.x.toInt();

                          if (index >= 0 && index < chartData.dates.length) {
                            setState(() {
                              touchedSpot = FlSpot(index.toDouble(), 0);
                              showTooltip = true;
                            });

                            // Auto-hide tooltip after 2 seconds
                            _hideTooltipTimer?.cancel();
                            _hideTooltipTimer =
                                Timer(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  showTooltip = false;
                                  touchedSpot = null;
                                });
                              }
                            });
                          }
                        }
                      }
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: investedSpots,
                      isCurved: true,
                      color: const Color(0xFF3B82F6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: currentSpots,
                      isCurved: true,
                      color: const Color(0xFF8B5CF6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegend('Invested', Color(0xFF3B82F6)),
            const SizedBox(width: 20),
            _buildChartLegend('Current', Color(0xFF8B5CF6)),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    final theme = ref.watch(themeProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: MyntWebTextStyles.para(
            context,
            color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountAllocation(Map<String, double> allocation , bool isDarkMode) {
    final theme = ref.watch(themeProvider);
    final portfolio = ref.watch(dashboardProvider);
    if (allocation.isEmpty) return const SizedBox.shrink();

    final sortedEntries = allocation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color:  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     TextWidget.subText(
          //       text: 'Asset Allocation',
          //       theme: false,
          //       color: theme.isDarkMode
          //           ? colors.textPrimaryDark
          //           : colors.textPrimaryLight,
          //       fw: 1,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          ...sortedEntries
              .map((entry) => _buildAccountTypeCard(
                    entry.key,
                    entry.value,
                    portfolio.getAccountTypeColor(entry.key),
                    portfolio.getAccountTypeIcon(entry.key),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard(
      String accountType, double percentage, Color color, IconData icon) {
    final theme = ref.watch(themeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
         color:  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountType,
                  style: MyntWebTextStyles.bodySmall(
                    context,
                    color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // const SizedBox(height: 8),
                // TextWidget.paraText(
                //   text: '${percentage.toStringAsFixed(2)}% of portfolio',
                //   theme: false,
                //   color: theme.isDarkMode
                //       ? colors.textSecondaryDark
                //       : colors.textSecondaryLight,
                //   fw: 0,
                // ),
              ],
            ),
          ),
          // Percentage Display
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: MyntWebTextStyles.bodySmall(
              context,
              color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textPrimary),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatMap(List<TopStocks> holdings) {
    final theme = ref.watch(themeProvider);
    final dashboardState = ref.watch(dashboardProvider);
    
    // Get filtered holdings based on selected filters
    final filteredHoldings = dashboardState.getFilteredHoldings(holdings);
    
    if (filteredHoldings.isEmpty) return const SizedBox.shrink();
    
    // Calculate performance ranges for color coding
    final pnlPercentages = filteredHoldings
        .where((holding) => holding.pnlPercent != null)
        .map((holding) => holding.pnlPercent!)
        .toList();
    
    if (pnlPercentages.isEmpty) return const SizedBox.shrink();
    
    final maxGain = pnlPercentages.reduce((a, b) => a > b ? a : b);
    final maxLoss = pnlPercentages.reduce((a, b) => a < b ? a : b);
    final maxAbs = [maxGain.abs(), maxLoss.abs()].reduce((a, b) => a > b ? a : b);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Heatmap',
                style: MyntWebTextStyles.title(
                  context,
                  color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  _buildHeatmapLegend(maxLoss, maxGain, theme),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHeatmapGrid(filteredHoldings, maxAbs, theme),
          const SizedBox(height: 12),
          _buildHeatmapStats(filteredHoldings, theme),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(List<TopStocks> holdings, double maxAbs, ThemesProvider theme) {
    // Calculate sizing values using absolute invested amount
    final pnlValues = holdings
        .map((holding) => (holding.inverstedAmount ?? 0).abs())
        .toList();
    
    if (pnlValues.isEmpty) return const SizedBox.shrink();
    
    double totalPnlValue = pnlValues.fold(0.0, (sum, value) => sum + value);
    // Fallback: if all values are zero, assign equal weight to avoid zero area
    if (totalPnlValue == 0 && pnlValues.isNotEmpty) {
      totalPnlValue = pnlValues.length.toDouble();
      for (int i = 0; i < pnlValues.length; i++) {
        pnlValues[i] = 1.0;
      }
    }
    
    // Sort holdings by absolute invested amount (descending) for better treemap layout
    final sortedHoldings = List<TopStocks>.from(holdings)
      ..sort((a, b) => (b.inverstedAmount ?? 0).abs().compareTo((a.inverstedAmount ?? 0).abs()));
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 0; // Account for padding
          // Adapt height when there are many tiles
          final int count = sortedHoldings.length;
          const double baseHeight = 280.0;
          final int extraRows = (count / 50).ceil();
          final double availableHeight = (baseHeight + (extraRows * 40)).clamp(280.0, 450.0);
          
          _heatmapHoldingsShown = sortedHoldings; // keep mapping order
          
          return GestureDetector(
            onTapDown: (details) => _onHeatmapTap(details.localPosition),
            child: SizedBox(
              key: _heatmapKey,
              width: availableWidth,
              height: availableHeight,
              child: CustomPaint(
                size: Size(availableWidth, availableHeight),
                painter: TreemapPainter(
                  holdings: sortedHoldings,
                  totalPnlValue: totalPnlValue,
                  maxAbs: maxAbs,
                  theme: theme,
                  containerWidth: availableWidth,
                  containerHeight: availableHeight,
                  selectedIndex: _selectedHeatmapIndex,
                  onLayout: (rects) {
                    _heatmapRects = rects;
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onHeatmapTap(Offset localPosition) {
    if (_heatmapRects.isEmpty || _heatmapHoldingsShown.isEmpty) return;
    for (int i = 0; i < _heatmapRects.length && i < _heatmapHoldingsShown.length; i++) {
      // Slightly deflate to avoid edge ambiguity and improve hit-testing at borders
      final rect = _heatmapRects[i].deflate(0.5);
      if (rect.contains(localPosition)) {
        setState(() {
          _selectedHeatmapIndex = i;
        });
        _showHeatmapTooltipForRect(rect, _heatmapHoldingsShown[i]);
        // Clear highlight after a short delay
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted && _selectedHeatmapIndex == i) {
            setState(() {
              _selectedHeatmapIndex = null;
            });
          }
        });
        break;
      }
    }
  }

  void _showHeatmapTooltipForRect(Rect tileRect, TopStocks holding) {
    final theme = ref.watch(themeProvider);
    _heatmapOverlay?.remove();
    _heatmapOverlay = null;

    final renderBox = _heatmapKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox;

    // Prefer positioning near the tile's center to avoid clipping at edges
    final tileCenterGlobal = renderBox.localToGlobal(tileRect.center);
    Offset overlayOffset = overlayBox.globalToLocal(tileCenterGlobal);

    final Color bg = Colors.white;

    // Compute clamped position so tooltip stays on screen
    const double tipMaxWidth = 220;
    const double tipApproxHeight = 88; // rough height; layout will be close
    final double minX = 8;
    final double minY = 8;
    final double maxX = overlayBox.size.width - tipMaxWidth - 8;
    final double maxY = overlayBox.size.height - tipApproxHeight - 8;
    final double left = overlayOffset.dx.clamp(minX, maxX);
    final double top = (overlayOffset.dy - 40).clamp(minY, maxY); // offset a bit upward

    _heatmapOverlay = OverlayEntry(
      builder: (ctx) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(maxWidth: 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (holding.tsym ?? holding.name ?? 'N/A').replaceAll('-EQ', ''),
                  style: MyntWebTextStyles.bodySmall(
                    context,
                    color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Invested: ₹${(holding.inverstedAmount ?? 0).toStringAsFixed(0)}',
                  style: MyntWebTextStyles.para(
                    context,
                    color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // Text(
                //   'Current: ₹${(holding.currentPrice ?? 0).toStringAsFixed(2)}',
                //   style: const TextStyle(fontSize: 12, color: Colors.black87),
                // ),
                Text(
                  'P&L: ₹${(holding.pnl ?? 0).toStringAsFixed(0)}  (${(holding.pnlPercent ?? 0).toStringAsFixed(2)}%)',
                  style: MyntWebTextStyles.para(
                    context,
                    color: (holding.pnlPercent ?? 0) > 0
                        ? resolveThemeColor(context, dark: MyntColors.profitDark, light: MyntColors.profit)
                        : (holding.pnlPercent ?? 0) == 0
                            ? resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary)
                            : resolveThemeColor(context, dark: MyntColors.lossDark, light: MyntColors.loss),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_heatmapOverlay!);

    Future.delayed(const Duration(seconds: 2), () {
      _heatmapOverlay?.remove();
      _heatmapOverlay = null;
    });
  }

  // Widget _buildHeatmapItem(TopStocks holding, double maxAbs, ThemesProvider theme, {double tileSize = 60.0}) {
  //   final pnlPercent = holding.pnlPercent ?? 0.0;
  //   final pnl = holding.pnl ?? 0.0;
    
  //   // Calculate color intensity based on performance
  //   Color backgroundColor;
  //   Color textColor;
    
  //   if (pnlPercent == 0) {
  //     backgroundColor = const Color(0xFFF8F9FA);
  //     textColor = const Color(0xFF6C757D);
  //   } else if (pnlPercent > 0) {
  //     // Positive performance - green gradient
  //     final intensity = (pnlPercent / maxAbs).clamp(0.0, 1.0);
  //     backgroundColor = Color.lerp(
  //       const Color(0xFFE8F5E8),
  //       const Color(0xFF28A745),
  //       intensity,
  //     )!;
  //     textColor = intensity > 0.4 ? Colors.white : const Color(0xFF155724);
  //   } else {
  //     // Negative performance - red gradient
  //     final intensity = (pnlPercent.abs() / maxAbs).clamp(0.0, 1.0);
  //     backgroundColor = Color.lerp(
  //       const Color(0xFFFFEBEE),
  //       const Color(0xFFDC3545),
  //       intensity,
  //     )!;
  //     textColor = intensity > 0.4 ? Colors.white : const Color(0xFF721C24);
  //   }
    
  //   // Calculate text size based on tile size
  //   final fontSize = (tileSize * 0.08).clamp(6.0, 10.0);
  //   final symbolFontSize = (tileSize * 0.16).clamp(9.0, 16.0);
    
  //   return Tooltip(
  //     message: '${holding.name}\nCurrent: ₹${(holding.currentPrice ?? 0).toStringAsFixed(2)}\nP&L: ₹${pnl.toStringAsFixed(2)}\nReturn: ${pnlPercent.toStringAsFixed(2)}%',
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     textStyle: TextWidget.textStyle(
  //       color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
  //       theme: theme.isDarkMode,
  //       fontSize: 12,
  //       fw: 0,
  //     ),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: backgroundColor,
  //         borderRadius: BorderRadius.circular(2),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           // Stock symbol/name
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 3),
  //             child: TextWidget.captionText(
  //               text: _truncateText(holding.tsym ?? 'N/A', tileSize > 60 ? 10 : 6),
  //               theme: theme.isDarkMode,
  //               color: textColor,
  //               fw: 1,
  //               maxLines: 1,
  //               textOverflow: TextOverflow.ellipsis,
  //               align: TextAlign.center,
  //             ),
  //           ),
  //           if (tileSize > 35) ...[
  //             const SizedBox(height: 2),
  //             // P&L percentage
  //             TextWidget.paraText(
  //               text: '${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
  //               theme: theme.isDarkMode,
  //               color: textColor,
  //               fw: 2,
  //               align: TextAlign.center,
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }


  Widget _buildHeatmapLegend(double maxLoss, double maxGain, ThemesProvider theme) {
    // Match heatmap card palette: red-light -> neutral -> green-light
    final redLight = Color(0xFFDC3545).withOpacity(0.1);   // same as negative light
    final neutral = Color(0xFFF8F9FA);   // neutral/zero
    final greenLight = Color(0xFF28A745).withOpacity(0.1); // same as positive light

    return Container(
      height: 24,
      width: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [redLight, neutral, greenLight],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${maxLoss.toStringAsFixed(1)}%',
              style: MyntWebTextStyles.caption(
                context,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${maxGain.toStringAsFixed(1)}%',
              style: MyntWebTextStyles.caption(
                context,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapStats(List<TopStocks> holdings, ThemesProvider theme) {
    final positiveCount = holdings.where((h) => (h.pnlPercent ?? 0) > 0).length;
    final negativeCount = holdings.where((h) => (h.pnlPercent ?? 0) < 0).length;
    final neutralCount = holdings.where((h) => (h.pnlPercent ?? 0) == 0).length;
    
    // final avgPnlPercent = holdings.isNotEmpty 
    //     ? holdings.fold(0.0, (sum, h) => sum + (h.pnlPercent ?? 0)) / holdings.length
    //     : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.05)
            : colors.textSecondaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Gainers', positiveCount, theme.isDarkMode ? colors.profitDark : colors.profitLight, theme),
          _buildStatItem('Losers', negativeCount, theme.isDarkMode ? colors.lossDark : colors.lossLight, theme),
          _buildStatItem('Neutral', neutralCount, theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, theme),
          // _buildStatItem('Avg Return', avgPnlPercent, resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary), theme, isPercentage: true),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value, Color color, ThemesProvider theme, {bool isPercentage = false}) {
    return Column(
      children: [
        Text(
          isPercentage
              ? '${(value as double).toStringAsFixed(1)}%'
              : value.toString(),
          style: MyntWebTextStyles.para(
            context,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: MyntWebTextStyles.para(
            context,
            color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 1)}...';
  }

  Widget _buildChartsSection(PortfolioResponse data) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildMarketCapChart(
            data.marketCapAllocation), // Market cap allocation chart
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMarketCapChart(Map<String, double> allocation) {
    final portfolio = ref.watch(dashboardProvider);
    final theme = ref.watch(themeProvider);
    if (allocation.isEmpty) return const SizedBox.shrink();

    // Order market cap types by priority: large cap, mid cap, small cap
    final orderedMarketCaps = <String>['Large Cap', 'Mid Cap', 'Small Cap'];
    final displayAllocation = <String, double>{};

    // Add market caps in the specified order if they exist
    for (final capType in orderedMarketCaps) {
      if (allocation.containsKey(capType)) {
        displayAllocation[capType] = allocation[capType]!;
      }
    }

    // Add any other market cap types that weren't in the ordered list
    final otherMarketCaps = allocation.entries
        .where((entry) => !orderedMarketCaps.contains(entry.key))
        .toList();

    // Calculate "Others" percentage for non-standard market cap types
    double othersPercentage = 0;
    if (otherMarketCaps.isNotEmpty) {
      othersPercentage =
          otherMarketCaps.fold(0.0, (sum, entry) => sum + entry.value);
    }

    if (othersPercentage > 0) {
      displayAllocation['Others'] = othersPercentage;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     TextWidget.subText(
          //       text: 'Market Cap',
          //       theme: false,
          //       color: theme.isDarkMode
          //           ? colors.textPrimaryDark
          //           : colors.textPrimaryLight,
          //       fw: 1,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          Row(
            children: [
              // Donut Chart
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: displayAllocation.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value,
                          title: '${entry.value.toStringAsFixed(1)}%',
                          color:
                              portfolio.getMarketCapAllocationColor(entry.key),
                          radius: 50,
                          titleStyle: MyntWebTextStyles.para(
                            context,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 35,
                      sectionsSpace: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: displayAllocation.entries
                      .map((entry) => _buildMarketCapLegend(
                          entry.key,
                          entry.value,
                          portfolio.getMarketCapAllocationColor(entry.key)))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectorAllocationTable(Map<String, double> allocation) {
    final theme = ref.watch(themeProvider);
    if (allocation.isEmpty) return const SizedBox.shrink();

    final top10Entries = allocation.entries.take(10).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     TextWidget.subText(
          //       text: 'Sector',
          //       theme: false,
          //       color: theme.isDarkMode
          //           ? colors.textPrimaryDark
          //           : colors.textPrimaryLight,
          //       fw: 1,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          // Horizontal Stacked Bar Chart
          SizedBox(
            height: 30,
            width: double.infinity,
            child: _buildHorizontalStackedBar(top10Entries),
          ),
          const SizedBox(height: 12),
          // Two-column Legend
          _buildTwoColumnLegend(top10Entries),
        ],
      ),
    );
  }


  // Custom legend for market cap allocation
  Widget _buildMarketCapLegend(
      String marketCapType, double percentage, Color color) {
    final theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              marketCapType,
              style: MyntWebTextStyles.para(
                context,
                color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(2)}%',
            style: MyntWebTextStyles.para(
              context,
              color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal stacked bar chart for sector allocation
  Widget _buildHorizontalStackedBar(List<MapEntry<String, double>> entries) {
    final portfolio = ref.watch(dashboardProvider);
    return Row(
      children: entries.map((entry) {
        return Expanded(
          flex: (entry.value * 100).round(),
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: portfolio.getSectorAllocationColor(entry.key),
              borderRadius: BorderRadius.horizontal(
                left: entry == entries.first ? Radius.circular(5) : Radius.zero,
                right: entry == entries.last ? Radius.circular(5) : Radius.zero,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Two-column legend for sector allocation
  Widget _buildTwoColumnLegend(List<MapEntry<String, double>> entries) {
    final portfolio = ref.watch(dashboardProvider);
    final leftColumn = entries.take((entries.length / 2).ceil()).toList();
    final rightColumn = entries.skip((entries.length / 2).ceil()).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: leftColumn
                .map((entry) => _buildLegendItem(entry.key, entry.value,
                    portfolio.getSectorAllocationColor(entry.key)))
                .toList(),
          ),
        ),
        const SizedBox(width: 20),
        // Right Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightColumn
                .map((entry) => _buildLegendItem(entry.key, entry.value,
                    portfolio.getSectorAllocationColor(entry.key)))
                .toList(),
          ),
        ),
      ],
    );
  }

  // Individual legend item
  Widget _buildLegendItem(String sector, double percentage, Color color) {
    final theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sector,
              style: MyntWebTextStyles.para(
                context,
                color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(2)}%',
            style: MyntWebTextStyles.para(
              context,
              color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format date for tooltip
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final portfolio = ref.read(dashboardProvider);
      final month = portfolio.getMonthAbbreviation(date.month);
      final year = date.year.toString();
      return '$month $year';
    } catch (e) {
      return dateString;
    }
  }

  // Show filter dialog
  void _showFilterBottomSheet(BuildContext context, ThemesProvider theme) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: resolveThemeColor(
        context,
        dark: MyntColors.modalBarrierDark,
        light: MyntColors.modalBarrierLight,
      ),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: StatefulBuilder(
            builder: (context, setModalState) =>
                _buildFilterBottomSheet(theme, setModalState),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // Build filter dialog content
  Widget _buildFilterBottomSheet(
      ThemesProvider theme, StateSetter setModalState) {
    final portfolio = ref.read(dashboardProvider);
    final data = portfolio.portfolioAnalysis;

    if (data == null) return const SizedBox.shrink();

    // Local state for pending filter selections (initialized once)
    // Using a map to store local state that persists across rebuilds
    final localState = _filterLocalState;

    // Initialize local state if not already done
    if (!localState.containsKey('initialized')) {
      localState['initialized'] = true;
      localState['showAll'] = portfolio.showAll;
      localState['selectedAccountTypes'] = Set<String>.from(portfolio.selectedAccountTypes);
      localState['selectedMarketCaps'] = Set<String>.from(portfolio.selectedMarketCaps);
      localState['selectedSectors'] = Set<String>.from(portfolio.selectedSectors);
    }

    return shadcn.Card(
      borderRadius: BorderRadius.circular(8),
      padding: EdgeInsets.zero,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: shadcn.Theme.of(context).colorScheme.border,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Holdings',
                    style: MyntWebTextStyles.title(
                      context,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary,
                      ),
                    ),
                  ),
                  MyntCloseButton(
                    onPressed: () {
                      _filterLocalState.clear(); // Clear local state on close
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Filter Sections
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Common "All" Filter
                          _buildFilterSection(
                            theme,
                            '',
                            ['All'],
                            'all',
                            setModalState,
                            localState,
                          ),
                          const SizedBox(height: 20),

                          // Segmentation Filters
                          if (data.accountAllocation.isNotEmpty) ...[
                            _buildFilterSection(
                              theme,
                              'Segmentation',
                              data.accountAllocation.keys.toList(),
                              'accountType',
                              setModalState,
                              localState,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Market Cap Filters
                          if (data.marketCapAllocation.isNotEmpty) ...[
                            _buildFilterSection(
                              theme,
                              'Market Cap',
                              data.marketCapAllocation.keys.toList(),
                              'marketCap',
                              setModalState,
                              localState,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Sector Filters
                          if (data.sectorAllocation.isNotEmpty) ...[
                            _buildFilterSection(
                              theme,
                              'Sector',
                              data.sectorAllocation.keys.toList(),
                              'sector',
                              setModalState,
                              localState,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Buttons Row
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: shadcn.Theme.of(context).colorScheme.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Clear Filters Button
                  Expanded(
                    child: MyntOutlinedButton(
                      label: 'Clear',
                      onPressed: () {
                        // Clear local state selections
                        setModalState(() {
                          localState['showAll'] = true;
                          (localState['selectedAccountTypes'] as Set<String>).clear();
                          (localState['selectedMarketCaps'] as Set<String>).clear();
                          (localState['selectedSectors'] as Set<String>).clear();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply Button
                  Expanded(
                    child: MyntPrimaryButton(
                      label: 'Apply',
                      onPressed: () {
                        // Apply local state to provider
                        final provider = ref.read(dashboardProvider);
                        provider.applyFilters(
                          showAll: localState['showAll'] as bool,
                          accountTypes: localState['selectedAccountTypes'] as Set<String>,
                          marketCaps: localState['selectedMarketCaps'] as Set<String>,
                          sectors: localState['selectedSectors'] as Set<String>,
                        );
                        _filterLocalState.clear(); // Clear local state
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Local state map for filter dialog (persists across rebuilds within dialog)
  final Map<String, dynamic> _filterLocalState = {};

  // Build individual filter section
  Widget _buildFilterSection(
    ThemesProvider theme,
    String title,
    List<String> options,
    String filterType,
    StateSetter setModalState,
    Map<String, dynamic> localState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title - only show if title is provided
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: MyntWebTextStyles.bodySmall(
              context,
              color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Filter Options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map((option) => _buildFilterChip(
                    theme,
                    option,
                    filterType,
                    setModalState,
                    localState,
                  ))
              .toList(),
        ),
      ],
    );
  }

  // Build individual filter chip styled like order preference screen
  Widget _buildFilterChip(
    ThemesProvider theme,
    String label,
    String filterType,
    StateSetter setModalState,
    Map<String, dynamic> localState,
  ) {
    bool isSelected = false;

    // Check selection from local state
    switch (filterType) {
      case 'all':
        isSelected = localState['showAll'] as bool? ?? true;
        break;
      case 'accountType':
        isSelected = (localState['selectedAccountTypes'] as Set<String>?)?.contains(label) ?? false;
        break;
      case 'marketCap':
        isSelected = (localState['selectedMarketCaps'] as Set<String>?)?.contains(label) ?? false;
        break;
      case 'sector':
        isSelected = (localState['selectedSectors'] as Set<String>?)?.contains(label) ?? false;
        break;
    }

    return TextButton(
      onPressed: () {
        setModalState(() {
          switch (filterType) {
            case 'all':
              final currentShowAll = localState['showAll'] as bool? ?? true;
              if (currentShowAll) {
                // Turning off "All" - do nothing special
                localState['showAll'] = false;
              } else {
                // Turning on "All" - clear all other selections
                localState['showAll'] = true;
                (localState['selectedAccountTypes'] as Set<String>?)?.clear();
                (localState['selectedMarketCaps'] as Set<String>?)?.clear();
                (localState['selectedSectors'] as Set<String>?)?.clear();
              }
              break;
            case 'accountType':
              final accountTypes = localState['selectedAccountTypes'] as Set<String>?;
              if (accountTypes != null) {
                if (accountTypes.contains(label)) {
                  accountTypes.remove(label);
                } else {
                  accountTypes.add(label);
                  localState['showAll'] = false; // Turn off "All" when selecting specific filter
                }
              }
              break;
            case 'marketCap':
              final marketCaps = localState['selectedMarketCaps'] as Set<String>?;
              if (marketCaps != null) {
                if (marketCaps.contains(label)) {
                  marketCaps.remove(label);
                } else {
                  marketCaps.add(label);
                  localState['showAll'] = false; // Turn off "All" when selecting specific filter
                }
              }
              break;
            case 'sector':
              final sectors = localState['selectedSectors'] as Set<String>?;
              if (sectors != null) {
                if (sectors.contains(label)) {
                  sectors.remove(label);
                } else {
                  sectors.add(label);
                  localState['showAll'] = false; // Turn off "All" when selecting specific filter
                }
              }
              break;
          }
        });
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        backgroundColor: !theme.isDarkMode
            ? (isSelected ? const Color(0xffF1F3F8) : Colors.transparent)
            : (isSelected ? colors.darkGrey : Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: isSelected
              ? BorderSide(
                  color: theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight,
                  width: 1,
                )
              : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        style: MyntWebTextStyles.body(
          context,
          color: isSelected
              ? resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)
              : resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  // Helper method to check if market depth details are available
  bool _isMarketDepthAvailable(String? exch, String? token, String? tsym) {
    // Only check for basic null/empty values
    if (exch == null || token == null || tsym == null) {
      return false;
    }

    // Check for empty strings
    if (exch.trim().isEmpty || token.trim().isEmpty || tsym.trim().isEmpty) {
      return false;
    }

    // Check for "null" strings (common API issue)
    if (exch.toLowerCase() == 'null' ||
        token.toLowerCase() == 'null' ||
        tsym.toLowerCase() == 'null') {
      return false;
    }

    // Allow everything else - let the details page handle invalid data
    return true;
  }
}

// Treemap Painter for efficient space packing
class TreemapPainter extends CustomPainter {
  final List<TopStocks> holdings;
  final double totalPnlValue;
  final double maxAbs;
  final ThemesProvider theme;
  final double containerWidth;
  final double containerHeight;
  final void Function(List<Rect>)? onLayout;
  final int? selectedIndex;

  TreemapPainter({
    required this.holdings,
    required this.totalPnlValue,
    required this.maxAbs,
    required this.theme,
    required this.containerWidth,
    required this.containerHeight,
    this.onLayout,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (holdings.isEmpty) return;

    // Calculate treemap rectangles using squarified algorithm
    final rectangles = _calculateTreemapRectangles();
    if (onLayout != null) onLayout!(rectangles);
    
    // Draw each rectangle
    for (int i = 0; i < rectangles.length && i < holdings.length; i++) {
      final rect = rectangles[i];
      final holding = holdings[i];
      _drawTreemapTile(canvas, rect, holding, isSelected: selectedIndex == i);
    }
  }

  List<Rect> _calculateTreemapRectangles() {
    final rectangles = <Rect>[];
    // Use absolute invested amount as the sizing value
    final values = holdings.map((h) => (h.inverstedAmount ?? 0).abs()).toList();
    
    if (values.isEmpty) return rectangles;
    
    // Use squarified treemap algorithm for better aspect ratios
    _squarify(values, 0, 0, containerWidth, containerHeight, rectangles);
    
    return rectangles;
  }

  void _squarify(List<double> values, double x, double y, double width, double height, List<Rect> rectangles) {
    if (values.isEmpty) return;
    
    if (values.length == 1) {
      rectangles.add(Rect.fromLTWH(x, y, width, height));
      return;
    }
    
    // Calculate the best split point
    double bestRatio = double.infinity;
    int bestSplit = 1;
    
    for (int i = 1; i <= values.length; i++) {
      final group1 = values.sublist(0, i);
      final group2 = values.sublist(i);
      
      if (group2.isEmpty) break;
      
      final ratio1 = _calculateAspectRatio(group1, width, height);
      final ratio2 = _calculateAspectRatio(group2, width, height);
      final maxRatio = ratio1 > ratio2 ? ratio1 : ratio2;
      
      if (maxRatio < bestRatio) {
        bestRatio = maxRatio;
        bestSplit = i;
      }
    }
    
    // Split the area
    final group1 = values.sublist(0, bestSplit);
    final group2 = values.sublist(bestSplit);
    
    final sum1 = group1.fold(0.0, (a, b) => a + b);
    final sum2 = group2.fold(0.0, (a, b) => a + b);
    final totalSum = sum1 + sum2;
    
    if (width > height) {
      // Split horizontally
      final width1 = (sum1 / totalSum) * width;
      final width2 = width - width1;
      
      _squarify(group1, x, y, width1, height, rectangles);
      _squarify(group2, x + width1, y, width2, height, rectangles);
    } else {
      // Split vertically
      final height1 = (sum1 / totalSum) * height;
      final height2 = height - height1;
      
      _squarify(group1, x, y, width, height1, rectangles);
      _squarify(group2, x, y + height1, width, height2, rectangles);
    }
  }

  double _calculateAspectRatio(List<double> values, double width, double height) {
    final sum = values.fold(0.0, (a, b) => a + b);
    if (sum == 0) return 1.0;
    
    final area = width * height;
    final valueArea = (sum / totalPnlValue) * area;
    
    if (width > height) {
      final rectWidth = valueArea / height;
      return (rectWidth / height).abs();
    } else {
      final rectHeight = valueArea / width;
      return (width / rectHeight).abs();
    }
  }

  void _drawTreemapTile(Canvas canvas, Rect rect, TopStocks holding, {bool isSelected = false}) {
    final pnlPercent = holding.pnlPercent ?? 0.0;
    
    // Calculate color based on performance
    Color backgroundColor;
    Color textColor;
    
    if (pnlPercent == 0) {
      backgroundColor = const Color(0xFFF8F9FA);
      textColor = const Color(0xFF6C757D);
    } else if (pnlPercent > 0) {
      final intensity = (pnlPercent / maxAbs).clamp(0.0, 1.0);
      backgroundColor = Color.lerp(
        const Color(0xFFE8F5E8),
        const Color(0xFF28A745),
        intensity,
      )!;
      textColor = intensity > 0.4 ? Colors.white : const Color(0xFF155724);
    } else {
      final intensity = (pnlPercent.abs() / maxAbs).clamp(0.0, 1.0);
      backgroundColor = Color.lerp(
        const Color(0xFFFFEBEE),
        const Color(0xFFDC3545),
        intensity,
      )!;
      textColor = intensity > 0.4 ? Colors.white : const Color(0xFF721C24);
    }
    
    // Draw rectangle
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
    canvas.drawRRect(rrect, paint);

    // Selection highlight (brief tap animation via thicker border)
    if (isSelected) {
      final borderPaint = Paint()
        ..color = colors.kColorAccentBlack
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(rrect, borderPaint);
    }
    
    // Draw text; allow much smaller tiles as well
    if (rect.width > 16 && rect.height > 12) {
      _drawText(canvas, rect, holding, textColor);
    }
  }

  void _drawText(Canvas canvas, Rect rect, TopStocks holding, Color textColor) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Stock symbol - fixed font size 12 (or 10 for very small tiles),
    // single line with ellipsis. For very small tiles show only a single word.
    String symbol = (holding.tsym?.replaceAll('-EQ', '') ?? 'N/A');
    if (rect.width < 50 || rect.height < 28) {
      symbol = _singleWord(symbol);
    }
    final symbolStyle = TextStyle(
      fontSize: rect.width < 50 || rect.height < 28 ? 8 : 12,
      fontWeight: FontWeight.w500,
      color: textColor,
    );
    
    final symbolPainter = TextPainter(
      text: TextSpan(text: symbol, style: symbolStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );
    symbolPainter.layout(maxWidth: rect.width - 4); // Leave 2px margin on each side
    final symbolOffset = Offset(
      rect.left + (rect.width - symbolPainter.width) / 2,
      rect.top + (rect.height - symbolPainter.height) / 2 - 8,
    );
    symbolPainter.paint(canvas, symbolOffset);
    
    // P&L percentage - only if there's enough space
    if (rect.height > 20 && rect.width > 24) {
      final pnlPercent = holding.pnlPercent ?? 0.0;
      final percentageText = '${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%';
      final percentageStyle = TextStyle(
        fontSize: rect.width < 50 || rect.height < 28 ? 8 : 10,
        fontWeight: FontWeight.w500,
        color: textColor,
      );
      
      textPainter.text = TextSpan(text: percentageText, style: percentageStyle);
      textPainter.layout(maxWidth: rect.width - 4);
      
      // Only draw if percentage text fits
      if (textPainter.width <= rect.width - 4) {
        final percentageOffset = Offset(
          rect.left + (rect.width - textPainter.width) / 2,
          rect.top + (rect.height - textPainter.height) / 2 + 8,
        );
        
        textPainter.paint(canvas, percentageOffset);
      }
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    if (maxLength <= 3) return text.substring(0, maxLength);
    return '${text.substring(0, maxLength - 3)}...';
  }

  String _singleWord(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return cleaned;
    // Prefer first word; if there's no space, take the first 4-6 chars
    final firstSpace = cleaned.indexOf(' ');
    if (firstSpace > 0) {
      return cleaned.substring(0, firstSpace);
    }
    return cleaned.length > 6 ? cleaned.substring(0, 6) : cleaned;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
