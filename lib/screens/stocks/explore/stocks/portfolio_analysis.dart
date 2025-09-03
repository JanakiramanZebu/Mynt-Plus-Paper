import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../../provider/dashboard_provider.dart';
import '../../../../models/explore_model/portfolioanalisys_models.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../sharedWidget/no_data_found.dart';

class PortfolioDashboardScreen extends ConsumerStatefulWidget {
  const PortfolioDashboardScreen({super.key});

  @override
  ConsumerState<PortfolioDashboardScreen> createState() =>
      _PortfolioDashboardScreenState();
}

class _PortfolioDashboardScreenState
    extends ConsumerState<PortfolioDashboardScreen> {
  FlSpot? touchedSpot;
  bool showTooltip = false;

  // Search focus management
  final FocusNode _searchFocusNode = FocusNode();

  // Scroll state management for elevation
  bool _hasScrolled = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(dashboardProvider).portfolioAnalysis == null) {
        ref.read(dashboardProvider).getPortfolioAnalysis();
      }
    });

    // Listen to scroll changes for elevation effect
    _scrollController.addListener(() {
      // Get the height of content above sticky header
      final RenderBox? contentBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      final contentHeightAboveHeader = contentBox?.size.height ?? 400.0;

      final hasScrolled = _scrollController.offset > contentHeightAboveHeader;
      if (hasScrolled != _hasScrolled) {
        setState(() {
          _hasScrolled = hasScrolled;
        });
      }
    });
  }

  Timer? _hideTooltipTimer;

  @override
  void dispose() {
    _hideTooltipTimer?.cancel();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final portfolio = ref.watch(dashboardProvider);
    return WillPopScope(
      onWillPop: () async {
        // Navigate back first, then hide search
        final dashboardState = ref.read(dashboardProvider);
        if (dashboardState.showPortfolioSearch) {
          dashboardState.showPortfolioAnalysisSearch(false);
          _searchFocusNode.unfocus();
        }
        return true; // Always allow back navigation
      },
      child: Scaffold(
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        appBar: AppBar(
          leadingWidth: 48,
          titleSpacing: 0,
          centerTitle: false,
          leading: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                  ? colors.splashColorDark
                  : colors.splashColorLight,
              highlightColor: theme.isDarkMode
                  ? colors.highlightDark
                  : colors.highlightLight,
              onTap: () {
                // Navigate back first, then hide search
                Navigator.pop(context);
                final dashboardState = ref.read(dashboardProvider);
                if (dashboardState.showPortfolioSearch) {
                  dashboardState.showPortfolioAnalysisSearch(false);
                  _searchFocusNode.unfocus();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 18,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                ),
              ),
            ),
          ),
          elevation: 0.2,
          title: TextWidget.titleText(
              text: "Portfolio Analysis",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 1),
        ),
        body: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              if (portfolio.isPortfolioLoading == true) {
                return Center(
                  child: Container(
                    color: Colors.white,
                    child: CircularLoaderImage(),
                  ),
                );
              }
              if (portfolio.portfolioAnalysis == null &&
                  portfolio.isPortfolioLoading == false) {
                return const Center(
                  child: NoDataFound(),
                );
              }

              return _buildDashboardContentWithStickyHeader(
                  ref.watch(dashboardProvider).portfolioAnalysis!);
            },
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

    // When search is active and there's search text, use search results
    // Otherwise use filtered list
    final searchText = dashboardState.portfolioSearchController.text.trim();
    final itemsToDisplay =
        (dashboardState.showPortfolioSearch && searchText.isNotEmpty)
            ? dashboardState.portfolioSearchItems
            : filteredHoldings;
    final validFundamentals = itemsToDisplay.toList();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Main content section
        SliverToBoxAdapter(
          child: Container(
            key: _contentKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.chartData != null)
                    _buildInvestmentChart(data.chartData!, data),
                  SizedBox(height: 16),
                  _buildAccountAllocation(data.accountAllocation),
                  SizedBox(height: 16),
                  _buildChartsSection(data),
                  SizedBox(height: 16),
                  _buildSectorAllocationTable(data.sectorAllocation),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        // Sticky Header for Top Stocks
        SliverPersistentHeader(
          pinned: true,
          floating: true,
          delegate: _StickyHeaderDelegate(
            showSearch: dashboardState.showPortfolioSearch,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                boxShadow: _hasScrolled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget.subText(
                        text: 'Holdings',
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 1,
                      ),
                      // Filter Icon
                    ],
                  ),
                  SizedBox(height: 12),
                  // Search and Filter Section
                  _buildSearchAndFilterSection(theme),
                  // Search Bar (shown when search is active)
                  _buildSearchBar(theme),
                ],
              ),
            ),
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

  Widget _buildSearchAndFilterSection(ThemesProvider theme) {
    final portfolioState = ref.watch(dashboardProvider);
    // Hide the search and filter section when search is active
    if (portfolioState.showPortfolioSearch) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Search and Filter Row
        SizedBox(
          height: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Search and Filter buttons
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      // Search Button
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 150),
                                () {
                              portfolioState.showPortfolioAnalysisSearch(true);
                              // Focus the search field after search appears
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (mounted) {
                                  FocusScope.of(context)
                                      .requestFocus(_searchFocusNode);
                                }
                              });
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              assets.searchIcon,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              width: 20,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),

                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                          onTap: () {
                            _showFilterBottomSheet(context, theme);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              assets.filterLinesDark,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              width: 20,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side: Action buttons (can be customized later)
                Row(
                  children: [
                    // Placeholder for future action buttons
                    Container(
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemesProvider theme) {
    final dashboardState = ref.watch(dashboardProvider);
    if (!dashboardState.showPortfolioSearch) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: SizedBox(
        height: 40,
        child: TextFormField(
          autofocus:
              false, // Don't auto-focus to prevent focus when returning to screen
          focusNode: _searchFocusNode,
          controller: dashboardState.portfolioSearchController,
          style: TextWidget.textStyle(
            fontSize: 16,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
          ),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: "Search holdings",
            hintStyle: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
              fw: 0,
            ),
            fillColor: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
            filled: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                assets.searchIcon,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fit: BoxFit.scaleDown,
                width: 20,
              ),
            ),
            suffixIcon: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.highlightDark
                    : colors.highlightLight,
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 150), () {
                    dashboardState.clearPortfolioSearch();
                    if (dashboardState.portfolioSearchController.text.isEmpty) {
                      dashboardState.showPortfolioAnalysisSearch(false);
                    }
                    // Unfocus the search field when clearing
                    _searchFocusNode.unfocus();
                  });
                },
                child: SvgPicture.asset(
                  assets.removeIcon,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fit: BoxFit.scaleDown,
                  width: 20,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            disabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onChanged: (value) {
            final baseList = dashboardState.getFilteredHoldings(
                dashboardState.portfolioAnalysis?.topStocks ?? []);
            dashboardState.searchPortfolioHoldings(value, baseList);
            // Don't automatically close search when text is empty
            // Search will only close when clear button is clicked
          },
          onFieldSubmitted: (value) {
            print('Search submitted: $value');
          },
        ),
      ),
    );
  }

  Widget _buildHoldingsSliverList(List<TopStocks> validFundamentals,
      ThemesProvider theme, dynamic dashboardState, String searchText) {
    // Show "No Data Found" when search is active with text but no results
    if (dashboardState.showPortfolioSearch &&
        searchText.isNotEmpty &&
        validFundamentals.isEmpty) {
      return SliverFillRemaining(
        child: Container(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          child: const Center(
            child: NoDataFound(),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) {
            return ListDivider();
          }
          final itemIndex = index ~/ 2;
          if (itemIndex >= validFundamentals.length) {
            return null;
          }
          final entry = validFundamentals[itemIndex];
          return _buildSectorPerformanceItem(
            sector: entry.name ?? '',
            value: entry.inverstedAmount ?? 0,
            marketCapType: entry.marketCapType ?? '',
            allocationPercent: entry.allocationPercent ?? 0,
            qty: entry.qty ?? '',
            exch: entry.exch ?? '',
            token: entry.zebuToken ?? '',
            tsym: entry.tsym ?? '',
          );
        },
        childCount:
            validFundamentals.isEmpty ? 0 : (validFundamentals.length * 2) - 1,
      ),
    );
  }

  Widget _buildTopStocksScrollableList(List<TopStocks> topStocks) {
    final theme = ref.watch(themeProvider);
    final dashboardState = ref.watch(dashboardProvider);

    // Get filtered holdings based on selected filters
    final filteredHoldings = dashboardState.getFilteredHoldings(topStocks);

    // When search is active and there's search text, use search results
    // Otherwise use filtered list
    final searchText = dashboardState.portfolioSearchController.text.trim();
    final itemsToDisplay =
        (dashboardState.showPortfolioSearch && searchText.isNotEmpty)
            ? dashboardState.portfolioSearchItems
            : filteredHoldings;
    final validFundamentals = itemsToDisplay.toList();
    // Show "No Data Found" when search is active with text but no results
    if (dashboardState.showPortfolioSearch &&
        searchText.isNotEmpty &&
        validFundamentals.isEmpty) {
      return Container(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        child: const Center(
          child: NoDataFound(),
        ),
      );
    }

    return Container(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      child: ListView.separated(
        // padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => ListDivider(),
        itemCount: validFundamentals.length,
        itemBuilder: (context, index) {
          final entry = validFundamentals[index];
          return _buildSectorPerformanceItem(
            sector: entry.name ?? '',
            value: entry.inverstedAmount ?? 0,
            marketCapType: entry.marketCapType ?? '',
            allocationPercent: entry.allocationPercent ?? 0,
            qty: entry.qty ?? '',
            exch: entry.exch ?? '',
            token: entry.zebuToken ?? '',
            tsym: entry.tsym ?? '',
          );
        },
      ),
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
                    TextWidget.subText(
                      text: 'Portfolio Summary',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                    const SizedBox(height: 12),
                    TextWidget.titleText(
                      text: '${data.xirrResult.toStringAsFixed(2)}%',
                      theme: theme.isDarkMode,
                      color: data.xirrResult.toStringAsFixed(2).startsWith("-")
                          ? theme.isDarkMode
                              ? colors.lossDark
                              : colors.lossLight
                          : data.xirrResult == 0
                              ? colors.textSecondaryLight
                              : theme.isDarkMode
                                  ? colors.profitDark
                                  : colors.profitLight,
                      fw: 0,
                    ),
                    SizedBox(height: 4),
                    TextWidget.subText(
                      text: 'XIRR Return',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
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
                          ? colors.textSecondaryDark.withOpacity(0.03)
                          : colors.textSecondaryLight.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.2)
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
                              TextWidget.subText(
                                text: _formatDate(chartData.dates[index]),
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0,
                              ),
                              const SizedBox(height: 4),
                              TextWidget.paraText(
                                text:
                                    'Invested: ${investedSpots[index].y.toStringAsFixed(2)}K',
                                theme: theme.isDarkMode,
                                color: const Color(0xFF3B82F6),
                                fw: 0,
                              ),
                              const SizedBox(height: 2),
                              TextWidget.paraText(
                                text:
                                    'Current: ${currentSpots[index].y.toStringAsFixed(2)}K',
                                theme: theme.isDarkMode,
                                color: const Color(0xFF8B5CF6),
                                fw: 0,
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
                                  child: TextWidget.captionText(
                                    text: '$month $year',
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fw: 0,
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
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      ),
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
        TextWidget.paraText(
          text: label,
          theme: false,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
      ],
    );
  }

  Widget _buildAccountAllocation(Map<String, double> allocation) {
    final theme = ref.watch(themeProvider);
    final portfolio = ref.watch(dashboardProvider);
    if (allocation.isEmpty) return const SizedBox.shrink();

    final sortedEntries = allocation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: 'Segmentation',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        color: colors.colorWhite,
        borderRadius: BorderRadius.circular(8),
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
                TextWidget.subText(
                  text: accountType,
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
                const SizedBox(height: 8),
                TextWidget.paraText(
                  text: '${percentage.toStringAsFixed(2)}% of portfolio',
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ],
            ),
          ),
          // Percentage Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextWidget.subText(
              text: '${percentage.toStringAsFixed(1)}%',
              theme: false,
              color: color,
              fw: 0,
            ),
          ),
        ],
      ),
    );
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: 'Market Cap',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                          titleStyle: TextWidget.textStyle(
                            theme: false,
                            color: Colors.white,
                            fontSize: 12,
                            fw: 2,
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

    final sortedEntries = allocation.entries.take(10).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: 'Sector',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal Stacked Bar Chart
          SizedBox(
            height: 30,
            width: double.infinity,
            child: _buildHorizontalStackedBar(sortedEntries),
          ),
          const SizedBox(height: 12),
          // Two-column Legend
          _buildTwoColumnLegend(sortedEntries),
        ],
      ),
    );
  }

  Widget _buildSectorPerformanceItem({
    required String sector,
    required String marketCapType,
    required double allocationPercent,
    required double value,
    required String qty,
    required String exch,
    required String token,
    required String tsym,
  }) {
    final theme = ref.watch(themeProvider);

    final isTappable = _isMarketDepthAvailable(exch, token, tsym);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor:
            theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
        highlightColor:
            theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
        onTap: () async {
          final marketWatch = ref.read(marketWatchProvider);

          // Check if market depth details are available
          if (!isTappable) {
            warningMessage(context, 'Details not available for this holding');
            return;
          }

          try {
            final depthArgs = <String, dynamic>{
              'exch': exch.toString(),
              'token': token.toString(),
              'tsym': tsym.toString().split(':').last,
              'instname': '',
              'symbol': tsym.toString(),
              'expDate': '',
              'option': '',
            };

            // Additional validation of the data being passed
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
            // Handle any unexpected errors
            error(context, 'Unable to load details. Please try again.');
          }
        },
        child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            dense: false,
            title: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextWidget.subText(
                  text: sector,
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextWidget.paraText(
                text: 'INV ${value.toStringAsFixed(2)}',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
              ),
            ),
            trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: TextWidget.subText(
                      text: '${allocationPercent.toStringAsFixed(2)}%',
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextWidget.paraText(
                      text: 'QTY ${qty.split('.')[0]}',
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ),
                ])),
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
            child: TextWidget.paraText(
              text: marketCapType,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ),
          TextWidget.paraText(
            text: '${percentage.toStringAsFixed(2)}%',
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
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
            child: TextWidget.paraText(
              text: sector,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          TextWidget.paraText(
            text: '${percentage.toStringAsFixed(2)}%',
            theme: false,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0,
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

  // Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context, ThemesProvider theme) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) =>
            _buildFilterBottomSheet(theme, setModalState),
      ),
    ).then((_) {
      // Filters are applied automatically through the provider
    });
  }

  // Build filter bottom sheet content
  Widget _buildFilterBottomSheet(
      ThemesProvider theme, StateSetter setModalState) {
    final portfolio = ref.watch(dashboardProvider);
    final data = portfolio.portfolioAnalysis;

    if (data == null) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        // padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          border: Border(
            top: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            left: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            right: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                    text: 'Filter Holdings',
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1,
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              height: 0,
            ),
            const SizedBox(height: 20),

            // Filter Sections
            Expanded(
              child: SingleChildScrollView(
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
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Clear Filters Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(dashboardProvider).clearAllFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                              .withOpacity(0.6)
                                                          : colors.btnBg,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: theme.isDarkMode
                            ? null
                            : BorderSide(color: colors.primaryLight, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: const Size(0, 45),
                      ),
                      child: TextWidget.subText(
                        text: 'Clear All',
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.primaryLight,
                        fw: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.isDarkMode
                            ? colors.colorBlue
                            : colors.colorBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(0, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: TextWidget.subText(
                        text: 'Apply Filters',
                        theme: false,
                        color: colors.colorWhite,
                        fw: 2,
                      ),
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

  // Build individual filter section
  Widget _buildFilterSection(
    ThemesProvider theme,
    String title,
    List<String> options,
    String filterType,
    StateSetter setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title - only show if title is provided
        if (title.isNotEmpty) ...[
          TextWidget.subText(
            text: title,
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textSecondaryLight,
            fw: 1,
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
  ) {
    final dashboardState = ref.watch(dashboardProvider);
    bool isSelected = false;

    switch (filterType) {
      case 'all':
        isSelected = dashboardState.showAll;
        break;
      case 'accountType':
        isSelected = dashboardState.isAccountTypeSelected(label);
        break;
      case 'marketCap':
        isSelected = dashboardState.isMarketCapSelected(label);
        break;
      case 'sector':
        isSelected = dashboardState.isSectorSelected(label);
        break;
    }

    return TextButton(
      onPressed: () {
        switch (filterType) {
          case 'all':
            if (isSelected) {
              ref.read(dashboardProvider).updateShowAll(false);
            } else {
              ref.read(dashboardProvider).updateShowAll(true);
            }
            break;
          case 'accountType':
            ref.read(dashboardProvider).toggleAccountType(label);
            break;
          case 'marketCap':
            ref.read(dashboardProvider).toggleMarketCap(label);
            break;
          case 'sector':
            ref.read(dashboardProvider).toggleSector(label);
            break;
        }
        setModalState(() {}); // Trigger rebuild of modal
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
        style: TextWidget.textStyle(
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fontSize: 14,
          theme: theme.isDarkMode,
          fw: isSelected ? 2 : 0,
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

// Sticky Header Delegate Class
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool showSearch;

  _StickyHeaderDelegate({required this.child, required this.showSearch});

  @override
  double get minExtent => 100.0; // Dynamic height based on search state

  @override
  double get maxExtent => 100.0; // Dynamic height based on search state

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Rebuild when search state changes
  }
}
