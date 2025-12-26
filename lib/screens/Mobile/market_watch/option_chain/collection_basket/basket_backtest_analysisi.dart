import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basket_backtest_analysis_model.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';

import '../../../../../provider/dashboard_provider.dart';

class BasketBacktestAnalysisScreen extends ConsumerStatefulWidget {
  const BasketBacktestAnalysisScreen({super.key});

  @override
  ConsumerState<BasketBacktestAnalysisScreen> createState() => _BasketBacktestAnalysisScreenState();
}

class _BasketBacktestAnalysisScreenState extends ConsumerState<BasketBacktestAnalysisScreen>
    with TickerProviderStateMixin {
  // Performance chart tooltip state
  FlSpot? performanceTouchedSpot;
  bool showPerformanceTooltip = false;
  Timer? _hidePerformanceTooltipTimer;
  
  // Benchmark chart tooltip state
  FlSpot? benchmarkTouchedSpot;
  bool showBenchmarkTooltip = false;
  Timer? _hideBenchmarkTooltipTimer;
  
  // Inflation chart tooltip state
  FlSpot? inflationTouchedSpot;
  bool showInflationTooltip = false;
  Timer? _hideInflationTooltipTimer;
  
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  
  // Tab controller
  late TabController _tabController;
  int selectedTab = 0;
  
  final tablistitems = [
    {
      "title": "Returns",
      "index": 0,
    },
    {
      "title": "Benchmark Analysis",
      "index": 1,
    },
    {
      "title": "Inflation Adjustment",
      "index": 2,
    },
    {
      "title": "Tax Implications",
      "index": 3,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
    selectedTab = 0;
    
    _tabController.animation!.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (selectedTab != newIndex) {
        setState(() {
          selectedTab = newIndex;
        });
        _scrollToActiveTab(newIndex);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll to active tab after the widget is built
      _scrollToActiveTab(selectedTab);
    });
  }

  @override
  void dispose() {
    _hidePerformanceTooltipTimer?.cancel();
    _hideBenchmarkTooltipTimer?.cancel();
    _hideInflationTooltipTimer?.cancel();
    _scrollController.dispose();
    _tabScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final strategy = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
              Navigator.pop(context);
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
          text: "Backtest Analysis 1",
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        actions: [
          // Customize Strategy Button
          if (strategy.showcustomButton)
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
               borderRadius: BorderRadius.circular(5),
                  splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                  onTap: () => _navigateToCustomizeStrategy(),
                  child: Container(
                         padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       
                        TextWidget.subText(
                          text: 'Customize',
                          theme: theme.isDarkMode,
                          color: colors.colorBlue,
                          fw: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            if (strategy.isStrategyLoading) {
              return Center(
                child: Container(
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  child: const CircularLoaderImage(),
                ),
              );
            }

            if (strategy.analysisData == null) {
              return const Center(
                child: NoDataFound(),
              );
            }

            final data = strategy.analysisData!;
            return _buildTabbedLayout(data, theme);
          },
        ),
      ),
    );
  }

  Widget _buildTabbedLayout(PortfolioAnalysisModel data, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
                width: 0,
              ),
            ),
          ),
          child: SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                tablistitems.length,
                (tab) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    highlightColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.01)
                        : Colors.black.withOpacity(0.01),
                    onTap: () {
                      setState(() {
                        selectedTab = tab;
                      });
                      _tabController.animateTo(tab);
                      if (_tabController.index != tab) {
                        _tabController.index = tab;
                      }
                      _scrollToActiveTab(tab);
                    },
                    child: _tabConstruct(
                        tablistitems[tab]['title'].toString(), theme, tab),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Disable horizontal swiping
            children: [
              _buildOverallReturnsTab(data, theme),
              _buildBenchmarkTab(data, theme),
              _buildInflationTab(data, theme),
              _buildTaxTab(data, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabConstruct(String title, ThemesProvider theme, int tab) {
    final isActive = selectedTab == tab;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextWidget.subText(
            text: title,
            color: isActive
                ? theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight
                : theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
            textOverflow: TextOverflow.visible,
            maxLines: 1,
            theme: theme.isDarkMode,
            fw: isActive ? 2 : 2,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 2,
          width: isActive ? _getTabIndicatorWidth(title) : 0,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: colors.colorBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  double _getTabIndicatorWidth(String title) {
    // Calculate approximate width based on text length
    // This is a rough estimation - you might want to use TextPainter for exact measurement
    final baseWidth = title.length * 8.0; // Approximate 8 pixels per character
    const minWidth = 60.0; // Minimum width
    const maxWidth = 200.0; // Maximum width
    return baseWidth.clamp(minWidth, maxWidth);
  }

  void _scrollToActiveTab(int tabIndex) {
    if (!_tabScrollController.hasClients) return;
    
    // Calculate the approximate position of the tab
    double tabPosition = 0.0;
    for (int i = 0; i < tabIndex; i++) {
      final title = tablistitems[i]['title'].toString();
      tabPosition += _getTabIndicatorWidth(title) + 32; // 32 for padding
    }
    
    // Get screen width to calculate center position
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = _getTabIndicatorWidth(tablistitems[tabIndex]['title'].toString());
    
    // Calculate the scroll position to center the tab
    final targetPosition = tabPosition + (tabWidth / 2) - (screenWidth / 2);
    
    // Ensure we don't scroll beyond bounds
    final maxScroll = _tabScrollController.position.maxScrollExtent;
    final scrollPosition = targetPosition.clamp(0.0, maxScroll);
    
    // Animate to the calculated position
    _tabScrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemesProvider theme,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
        highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  void _shareAnalysis() {
    // TODO: Implement share functionality
  }

  void _showMoreOptions() {
    // TODO: Implement more options menu
  }

  void _navigateToCustomizeStrategy() {
    // Navigate to create strategy screen with preloaded data
    Navigator.pushNamed(context, Routes.createBasketStrategy);
  }

  void _saveStrategy() {
    // Save the current strategy to custom list
    final strategy = ref.read(dashboardProvider);
    final strategyName = strategy.strategyNameController.text.isNotEmpty 
        ? strategy.strategyNameController.text 
        : 'Custom Strategy';
    ref.read(dashboardProvider).saveStrategy(strategyName, context);
  }

  // Tab content methods
  Widget _buildOverallReturnsTab(PortfolioAnalysisModel data, ThemesProvider theme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 16),
                _buildPerformanceChart(data),
                const SizedBox(height: 16),
                _buildModernPortfolioSummary(data.total, theme),
                const SizedBox(height: 16),
                // _buildQuickStatsCards(data, theme),
                // const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenchmarkTab(PortfolioAnalysisModel data, ThemesProvider theme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBenchmarkAnalysis(data),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInflationTab(PortfolioAnalysisModel data, ThemesProvider theme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInflationAdjustment(data),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxTab(PortfolioAnalysisModel data, ThemesProvider theme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaxImplications(data),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernPortfolioSummary(PortfolioTotal data, ThemesProvider theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          _buildDataRow('Invested', '${data.investmentAmount}', theme),
          _buildDataRow('Current', '${data.currentValue}', theme),

          _buildDataRow('Gain', '${data.gain} (${((data.gain / data.investmentAmount) * 100).toStringAsFixed(2)}%)', theme, color : theme.isDarkMode ? colors.profitDark : colors.profitLight),
          _buildDataRow('XIRR', '${data.xirr.toStringAsFixed(2)}%', theme),
          _buildDataRow('Sharpe Ratio', data.sharpeRatio.toStringAsFixed(2), theme),
          _buildDataRow('Max Drawdown', '${data.maxDrawdown.toStringAsFixed(2)}%', theme, color : theme.isDarkMode ? colors.lossDark : colors.lossLight),
          _buildDataRow('Volatility', '${data.volatility.toStringAsFixed(2)}%', theme ,color : theme.isDarkMode ? colors.lossDark : colors.lossLight),
        ],
      ),
    );
  }

  Widget _buildDataRow(String name, String value, ThemesProvider theme, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: name,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
              ),
              TextWidget.subText(
                text: value,
                theme: false,
                color: color ?? (theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight),
                fw: 0,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            thickness: 0,
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          )
        ],
      ),
    );
  }

  Widget _buildThreeColumnDataRow(String metric, String yourValue, String benchmarkValue, ThemesProvider theme, {Color? yourColor, Color? benchmarkColor, bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              // Metric name (40% width)
              Expanded(
                flex: 4,
                child: isHeader 
                  ? TextWidget.subText(
                      text: metric,
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                      align: TextAlign.start,
                    )
                  : TextWidget.subText(
                      text: metric,
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                      align: TextAlign.start,
                    ),
              ),
              // Your Strategy value (30% width)
              Expanded(
                flex: 3,
                child: isHeader
                  ? TextWidget.subText(
                      text: yourValue,
                      theme: false,
                      color: yourColor ?? (theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight),
                      fw: 1,
                      align: TextAlign.center,
                    )
                  : TextWidget.subText(
                      text: yourValue,
                      theme: false,
                      color: yourColor ?? (theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight),
                      fw: 0,
                      align: TextAlign.center,
                    ),
              ),
              // NIFTYBEES value (30% width)
              Expanded(
                flex: 3,
                child: isHeader
                  ? TextWidget.subText(
                      text: benchmarkValue,
                      theme: false,
                      color: benchmarkColor ?? (theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight),
                      fw: 1,
                      align: TextAlign.center,
                    )
                  : TextWidget.subText(
                      text: benchmarkValue,
                      theme: false,
                      color: benchmarkColor ?? (theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight),
                      fw: 0,
                      align: TextAlign.center,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            thickness: 0,
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          )
        ],
      ),
    );
  }


  Widget _buildPerformanceMetric(String label, String value, Color valueColor, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        TextWidget.subText(
          text: value,
          theme: theme.isDarkMode,
          color: valueColor,
          fw: 1,
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  Widget _buildMetricCard(String label, String value, ThemesProvider theme, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 3,
        ),
        const SizedBox(height: 4),
        TextWidget.subText(
          text: value,
          theme: theme.isDarkMode,
          color: valueColor ?? (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
          fw: 1,
        ),
      ],
    );
  }

  // Widget _buildQuickStatsCards(PortfolioAnalysisModel data, ThemesProvider theme) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         TextWidget.subText(
  //           text: 'Risk Metrics',
  //           theme: theme.isDarkMode,
  //           color: theme.isDarkMode
  //               ? colors.textPrimaryDark
  //               : colors.textPrimaryLight,
  //           fw: 1,
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildStatsCard(
  //                 'Sharpe Ratio',
  //                 data.total.sharpeRatio.toStringAsFixed(2),
  //                 theme,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: _buildStatsCard(
  //                 'Volatility',
  //                 '${data.total.volatility.toStringAsFixed(2)}%',
  //                 theme,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: _buildStatsCard(
  //                 'Max Drawdown',
  //                 '${data.total.maxDrawdown.toStringAsFixed(2)}%',
  //                 theme,
  //                 valueColor: data.total.maxDrawdown < 0 
  //                   ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
  //                   : null,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatsCard(String label, String value, ThemesProvider theme, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode 
          ? colors.textSecondaryDark.withOpacity(0.05)
          : colors.textSecondaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextWidget.paraText(
                  text: label,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextWidget.subText(
            text: value,
            theme: theme.isDarkMode,
            color: valueColor ?? (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
            fw: 1,
          ),
        ],
      ),
    );
  }


  Widget _buildPerformanceChart(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    List<FlSpot> totalSpots = [];
    List<FlSpot> equitySpots = [];
    List<FlSpot> debtSpots = [];
    List<FlSpot> hybridSpots = [];
    
    // Generate spots from chart data and calculate cumulative values for stacking
    for (int i = 0; i < data.total.chartData.length; i++) {
      totalSpots.add(FlSpot(i.toDouble(), data.total.chartData[i] / 1000));
      
      // Calculate individual component values
      double debtValue = 0;
      double hybridValue = 0;
      double equityValue = 0;
      
      if (data.debt.isNotEmpty && i < data.debt[0].chartData.length) {
        debtValue = data.debt[0].chartData[i] / 1000;
      }
      if (data.hybrid.isNotEmpty && i < data.hybrid[0].chartData.length) {
        hybridValue = data.hybrid[0].chartData[i] / 1000;
      }
      if (data.equity.isNotEmpty && i < data.equity[0].chartData.length) {
        equityValue = data.equity[0].chartData[i] / 1000;
      }
      
      // For stacked area chart, we need cumulative values
      // Debt starts from 0, Hybrid starts from debt value, Equity starts from debt + hybrid
      debtSpots.add(FlSpot(i.toDouble(), debtValue));
      hybridSpots.add(FlSpot(i.toDouble(), debtValue + hybridValue));
      equitySpots.add(FlSpot(i.toDouble(), debtValue + hybridValue + equityValue));
    }

    // Generate month labels from actual dateTime data
    final months = _generateMonthLabelsFromDateTime(data.total.dateTime);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 20),
           Row(
            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               // Chart title and info
             
               // Empty space for tooltip when not showing
               if (!showPerformanceTooltip || performanceTouchedSpot == null)
                 const SizedBox(width: 200), // Reserve space for tooltip
             ],
           ),
          //  const SizedBox(height: 16),
           SizedBox(
             height: 350,
             width: double.infinity,
             child: Padding(
               padding: const EdgeInsets.only(bottom: 8.0),
               child: Stack(
                 children: [
                 LineChart(
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
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < totalSpots.length) {
                          final dataIndex = value.toInt();
                          final totalPoints = totalSpots.length;
                          final labelInterval =
                              (totalPoints / 6).ceil().clamp(1, totalPoints);

                          if (value.toInt() == 0 ||
                              value.toInt() == totalSpots.length - 1 ||
                              value.toInt() % labelInterval == 0) {
                            final monthLabel = _getMonthLabelForIndex(dataIndex, data.total.dateTime, months);
                            if (monthLabel.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextWidget.captionText(
                                  text: monthLabel,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 1,
                                ),
                              );
                            }
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (totalSpots.length - 1).toDouble(),
                minY: _getMinYValue([data.total.chartData] + 
                  (data.equity.isNotEmpty ? [data.equity[0].chartData] : []) + 
                  (data.debt.isNotEmpty ? [data.debt[0].chartData] : []) + 
                  (data.hybrid.isNotEmpty ? [data.hybrid[0].chartData] : [])),
                // Add consistent padding for all charts
                clipData: const FlClipData.all(),
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
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: barData.color ?? const Color(0xFF3B82F6),
                          strokeWidth: 2,
                          dashArray: [5, 5],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: barData.color ?? const Color(0xFF3B82F6),
                              strokeWidth: 3,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  handleBuiltInTouches: true,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    // Handle different touch events
                  if (event is FlTapUpEvent ||
                        event is FlPanUpdateEvent ||
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent ||
                        event is FlLongPressStart ||
                        event is FlLongPressEnd ||
                        event is FlLongPressMoveUpdate ||
                        event is FlPanEndEvent) {
                      
                      if (touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final index = spot.x.toInt();

                       if (index >= 0 && index < totalSpots.length) {
                          setState(() {
                            performanceTouchedSpot = FlSpot(index.toDouble(), 0);
                            showPerformanceTooltip = true;
                          });

                          // Only set auto-hide timer for tap events, not for continuous interactions
                          if (event is FlTapUpEvent || event is FlPanEndEvent || event is FlLongPressEnd) {
                            _hidePerformanceTooltipTimer?.cancel();
                            _hidePerformanceTooltipTimer = Timer(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  showPerformanceTooltip = false;
                                  performanceTouchedSpot = null;
                                });
                              }
                            });
                          } else {
                            // For continuous touch events (pan, long press move), cancel existing timer
                            // but don't set a new one to avoid interference
                            _hidePerformanceTooltipTimer?.cancel();
                          }
                        }
                      }
                    } else if (event is FlPanEndEvent || event is FlTapCancelEvent) {
                      // Handle touch end/cancel events
                      _hidePerformanceTooltipTimer?.cancel();
                      _hidePerformanceTooltipTimer = Timer(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            showPerformanceTooltip = false;
                            performanceTouchedSpot = null;
                          });
                        }
                      });
                    }
                  },
                ),
                lineBarsData: [
                  // Debt line (olive green) - base layer
                  if (debtSpots.isNotEmpty)
                    LineChartBarData(
                      spots: debtSpots,
                      isCurved: true,
                      color: const Color(0xFF9CAF88), // Olive green
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF9CAF88).withOpacity(0.3),
                      ),
                    ),
                  // Hybrid line (red) - middle layer
                  if (hybridSpots.isNotEmpty)
                    LineChartBarData(
                      spots: hybridSpots,
                      isCurved: true,
                      color: const Color(0xFFE57373), // Light red
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFE57373).withOpacity(0.3),
                      ),
                    ),
                  // Equity line (green) - top layer
                  if (equitySpots.isNotEmpty)
                    LineChartBarData(
                      spots: equitySpots,
                      isCurved: true,
                      color: const Color(0xFF4CAF50), // Green
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            ),
                 // Custom tooltip positioned as overlay
                 if (showPerformanceTooltip && performanceTouchedSpot != null)
                   Positioned(
                     left: 0,
                     top: 0,
                     child: IgnorePointer(
                       child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                           final index = performanceTouchedSpot!.x.toInt();
                           if (index >= 0 && index < totalSpots.length) {
                             // Get the month label for this data point
                             final monthLabel = _getMonthLabelForIndex(index, data.total.dateTime, months);
                             return Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 TextWidget.subText(
                                   text: monthLabel,
                                   theme: theme.isDarkMode,
                                   color: theme.isDarkMode
                                       ? colors.textPrimaryDark
                                       : colors.textPrimaryLight,
                                   fw: 1,
                                 ),
                                 const SizedBox(height: 4),
                                 // Calculate individual component values for tooltip
                                 if (data.debt.isNotEmpty && index < data.debt[0].chartData.length)
                                   TextWidget.paraText(
                                     text: 'Debt ${(data.debt[0].chartData[index] / 1000).toStringAsFixed(2)}K',
                                     theme: theme.isDarkMode,
                                     color: const Color(0xFF9CAF88), // Olive green
                                     fw: 0,
                                   ),
                                 if (data.debt.isNotEmpty && data.hybrid.isNotEmpty && index < data.hybrid[0].chartData.length)
                                   const SizedBox(height: 4),
                                 if (data.hybrid.isNotEmpty && index < data.hybrid[0].chartData.length)
                                   TextWidget.paraText(
                                     text: 'Hybrid ${(data.hybrid[0].chartData[index] / 1000).toStringAsFixed(2)}K',
                                     theme: theme.isDarkMode,
                                     color: const Color(0xFFE57373), // Light red
                                     fw: 0,
                                   ),
                                 if (data.hybrid.isNotEmpty && data.equity.isNotEmpty && index < data.equity[0].chartData.length)
                                   const SizedBox(height: 4),
                                 if (data.equity.isNotEmpty && index < data.equity[0].chartData.length)
                                   TextWidget.paraText(
                                     text: 'Equity ${(data.equity[0].chartData[index] / 1000).toStringAsFixed(2)}K',
                                     theme: theme.isDarkMode,
                                     color: const Color(0xFF4CAF50), // Green
                                     fw: 0,
                                   ),
                                 if ((data.equity.isNotEmpty || data.debt.isNotEmpty || data.hybrid.isNotEmpty) && index < totalSpots.length)
                                   const SizedBox(height: 4),
                                 if (index < totalSpots.length)
                                   TextWidget.paraText(
                                     text: 'Total ${totalSpots[index].y.toStringAsFixed(2)}K',
                                     theme: theme.isDarkMode,
                                     color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                     fw: 1,
                                   ),
                               ],
                             );
                           }
                           return const SizedBox.shrink();
                         },
                       ),
                      ),
                    ),
                  ),
                 ],
               ),
             ),
           ),
          // Legend and info - Updated for stacked area chart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (data.debt.isNotEmpty)
                _buildChartLegend('Debt', const Color(0xFF9CAF88)), // Olive green
              if (data.debt.isNotEmpty && data.hybrid.isNotEmpty)
                const SizedBox(width: 20),
              if (data.hybrid.isNotEmpty)
                _buildChartLegend('Hybrid', const Color(0xFFE57373)), // Light red
              if (data.hybrid.isNotEmpty && data.equity.isNotEmpty)
                const SizedBox(width: 20),
              if (data.equity.isNotEmpty)
                _buildChartLegend('Equity', const Color(0xFF4CAF50)), // Green
            ],
          ),
        ],
      ),
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
        const SizedBox(width: 6),
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

  Widget _buildLegendItem(String label, String value, Color color) {
    final theme = ref.watch(themeProvider);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget.captionText(
              text: label,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
            TextWidget.paraText(
              text: value,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        ),
      ],
    );
  }

 


  Widget _buildBenchmarkAnalysis(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    // Calculate the difference in XIRR for comparison
    final xirrDifference = data.total.xirr - data.benchmark.xirr;
    
    // Generate dynamic month labels for benchmark chart
    final months = _generateMonthLabelsFromDateTime(data.total.dateTime);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.titleText(
                text: '${xirrDifference.toStringAsFixed(2)}% ${xirrDifference >= 0 ? 'higher' : 'lower'}',
                theme: theme.isDarkMode,
                color: xirrDifference >= 0 
                  ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
                  : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
                fw: 1,
              ),
              // Custom tooltip positioned above chart
              
            ],
          ),
          
          const SizedBox(height: 4),
          TextWidget.paraText(
            text: 'annualised return (XIRR) compared to ${data.benchmark.schemeName}',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 3,
          ),
          const SizedBox(height: 4),
          // Empty space for tooltip when not showing
          if (!showBenchmarkTooltip || benchmarkTouchedSpot == null)
            const SizedBox(width: 200), // Reserve space for tooltip
          // const SizedBox(height: 20),
          // Benchmark comparison chart
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Stack(
                children: [
                  LineChart(
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
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < data.total.chartData.length) {
                              final dataIndex = value.toInt();
                              final totalPoints = data.total.chartData.length;
                              final labelInterval =
                                  (totalPoints / 6).ceil().clamp(1, totalPoints);

                              if (value.toInt() == 0 ||
                                  value.toInt() == data.total.chartData.length - 1 ||
                                  value.toInt() % labelInterval == 0) {
                                final monthLabel = _getMonthLabelForIndex(dataIndex, data.total.dateTime, months);
                                if (monthLabel.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: TextWidget.captionText(
                                      text: monthLabel,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 1,
                                    ),
                                  );
                                }
                              }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (data.total.chartData.length - 1).toDouble(),
                    minY: _getMinYValue([data.total.chartData, data.benchmark.chartData]),
                    // Add consistent padding for all charts
                    clipData: const FlClipData.all(),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((spot) => null).toList();
                        },
                      ),
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: barData.color ?? const Color(0xFF3B82F6),
                              strokeWidth: 2,
                              dashArray: [5, 5],
                            ),
                            FlDotData(
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: barData.color ?? const Color(0xFF3B82F6),
                                  strokeWidth: 3,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                      handleBuiltInTouches: true,
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                       if (event is FlTapUpEvent ||
                        event is FlPanUpdateEvent ||
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent ||
                        event is FlLongPressStart ||
                        event is FlLongPressEnd ||
                        event is FlLongPressMoveUpdate ||
                        event is FlPanEndEvent) {
                      
                      if (touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                            final spot = touchResponse.lineBarSpots!.first;
                            final index = spot.x.toInt();

                           if (index >= 0 && index < data.total.chartData.length) {
                          setState(() {
                            benchmarkTouchedSpot = FlSpot(index.toDouble(), 0);
                            showBenchmarkTooltip = true;
                          });

                          // Only set auto-hide timer for tap events, not for continuous interactions
                          if (event is FlTapUpEvent || event is FlPanEndEvent || event is FlLongPressEnd) {
                            _hideBenchmarkTooltipTimer?.cancel();
                            _hideBenchmarkTooltipTimer = Timer(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  showBenchmarkTooltip = false;
                                  benchmarkTouchedSpot = null;
                                });
                              }
                            });
                          } else {
                            // For continuous touch events (pan, long press move), cancel existing timer
                            // but don't set a new one to avoid interference
                            _hideBenchmarkTooltipTimer?.cancel();
                          }
                        }
                      }
                    } else if (event is FlPanEndEvent || event is FlTapCancelEvent) {
                      // Handle touch end/cancel events
                      _hideBenchmarkTooltipTimer?.cancel();
                      _hideBenchmarkTooltipTimer = Timer(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            showBenchmarkTooltip = false;
                            benchmarkTouchedSpot = null;
                          });
                        }
                      });
                    }
                      },
                    ),
                    lineBarsData: [
                      // Benchmark (blue)
                      LineChartBarData(
                        spots: data.benchmark.chartData.asMap().entries.map((e) => 
                          FlSpot(e.key.toDouble(), e.value / 1000)
                        ).toList(),
                        isCurved: true,
                        color: const Color(0xFF3B82F6),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                      // Your Strategy (green)
                      LineChartBarData(
                        spots: data.total.chartData.asMap().entries.map((e) => 
                          FlSpot(e.key.toDouble(), e.value / 1000)
                        ).toList(),
                        isCurved: true,
                        color: const Color(0xFF10B981),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
                // Custom tooltip positioned as overlay
                if (showBenchmarkTooltip && benchmarkTouchedSpot != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                            final index = benchmarkTouchedSpot!.x.toInt();
                            if (index >= 0 && index < data.total.chartData.length) {
                              final monthLabel = _getMonthLabelForIndex(index, data.total.dateTime, months);
                              final benchmarkSpots = data.benchmark.chartData.asMap().entries.map((e) => 
                                FlSpot(e.key.toDouble(), e.value / 1000)
                              ).toList();
                              final strategySpots = data.total.chartData.asMap().entries.map((e) => 
                                FlSpot(e.key.toDouble(), e.value / 1000)
                              ).toList();
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextWidget.subText(
                                    text: monthLabel,
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  if (index < benchmarkSpots.length)
                                    TextWidget.paraText(
                                      text: '${data.benchmark.schemeName} ${benchmarkSpots[index].y.toStringAsFixed(2)}K',
                                      theme: theme.isDarkMode,
                                      color: const Color(0xFF3B82F6),
                                      fw: 0,
                                    ),
                                  const SizedBox(height: 4),
                                  if (index < strategySpots.length)
                                    TextWidget.paraText(
                                      text: 'Your Strategy ${strategySpots[index].y.toStringAsFixed(2)}K',
                                      theme: theme.isDarkMode,
                                      color: const Color(0xFF10B981),
                                      fw: 0,
                                    ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Benchmark', const Color(0xFF3B82F6)),
              const SizedBox(width: 20),
              _buildChartLegend('Your Strategy', const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 16),
          // Comparison table
          _buildComparisonTable(data),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // Static header row
          _buildThreeColumnDataRow(
            'Metric', 
            'Your Strategy', 
            'NIFTYBEES', 
            theme,
            yourColor: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            benchmarkColor: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            isHeader: true,
          ),
          // Current row
          _buildThreeColumnDataRow(
            'Current', 
            _formatNumber(data.total.currentValue), 
            _formatNumber(data.benchmark.currentValue), 
            theme,
          ),
          // Gain row
          _buildThreeColumnDataRow(
            'Gain', 
            _formatNumber(data.total.gain), 
            _formatNumber(data.benchmark.gain), 
            theme,
            yourColor: data.total.gain >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
            benchmarkColor: data.benchmark.gain >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
          ),
          // Sharpe Ratio row
          _buildThreeColumnDataRow(
            'Sharpe Ratio', 
            data.total.sharpeRatio.toStringAsFixed(2), 
            data.benchmark.sharpeRatio.toStringAsFixed(2), 
            theme,
          ),
          // Max Drawdown row
          _buildThreeColumnDataRow(
            'Max Drawdown', 
            '${data.total.maxDrawdown.toStringAsFixed(2)}%', 
            '${data.benchmark.maxDrawdown.toStringAsFixed(2)}%', 
            theme,
            yourColor: theme.isDarkMode ? colors.lossDark : colors.lossLight,
            benchmarkColor: theme.isDarkMode ? colors.lossDark : colors.lossLight,
          ),
          // XIRR row
          _buildThreeColumnDataRow(
            'XIRR', 
            '${data.total.xirr.toStringAsFixed(2)}%', 
            '${data.benchmark.xirr.toStringAsFixed(2)}%', 
            theme,
            yourColor: data.total.xirr >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
            benchmarkColor: data.benchmark.xirr >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, ThemesProvider theme, TextAlign align) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: TextWidget.subText(
        text: text,
        theme: theme.isDarkMode,
        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
        fw: 0,
        align: align,
      ),
    );
  }

  Widget _buildTableDataCell(String text, ThemesProvider theme, Color? textColor, TextAlign align) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: TextWidget.paraText(
        text: text,
        theme: theme.isDarkMode,
        color: textColor ?? (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
        fw: 0,
        align: align,
      ),
    );
  }

  Widget _buildComparisonRow(String name, String finalValue, String gain, String sharpe, String drawdown, String xirr, Color color) {
    final theme = ref.watch(themeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode 
              ? colors.textSecondaryDark.withOpacity(0.1)
              : colors.textSecondaryLight.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
                const SizedBox(width: 5),
                Flexible(
                  child: TextWidget.paraText(
                    text: name,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: finalValue,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: gain,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: sharpe,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: drawdown,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: xirr,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernComparisonRow(String name, String finalValue, String gain, String sharpe, String drawdown, String xirr, Color color, ThemesProvider theme, bool isFirst) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        // color: isFirst 
        //   ? (theme.isDarkMode 
        //       ? color.withOpacity(0.1)
        //       : color.withOpacity(0.05))
        //   : null,
        borderRadius: isFirst 
          ? const BorderRadius.vertical(bottom: Radius.circular(12))
          : null,
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Strategy name with colored dot
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: TextWidget.paraText(
                    text: name,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
                    align: TextAlign.start,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Final Value
          Expanded(
            flex: 3,
            child: TextWidget.paraText(
              text: finalValue,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          // Gain
          Expanded(
            flex: 3,
            child: TextWidget.paraText(
              text: gain,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
              align: TextAlign.start,
            ),
          ),
          // Sharpe Ratio
          Expanded(
            flex: 1,
            child: TextWidget.paraText(
              text: sharpe,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
              align: TextAlign.start,
            ),
          ),
          // Max Drawdown
          Expanded(
            flex: 2,
            child: TextWidget.paraText(
              text: drawdown,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
              fw: 3,
              align: TextAlign.center,
            ),
          ),
          // XIRR
          Expanded(
            flex: 2,
            child: TextWidget.paraText(
              text: xirr,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.profitDark : colors.profitLight,
              fw: 3,
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInflationAdjustment(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    // Generate dynamic month labels for inflation chart
    final months = _generateMonthLabelsFromDateTime(data.total.dateTime);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          // Empty space for tooltip when not showing
          if (!showInflationTooltip || inflationTouchedSpot == null)
            const SizedBox(width: 200), // Reserve space for tooltip
          // const SizedBox(height: 10),
          // Chart showing inflation adjustment
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Stack(
                children: [
                  LineChart(
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
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.total.chartData.length) {
                          final dataIndex = value.toInt();
                          final totalPoints = data.total.chartData.length;
                          final labelInterval =
                              (totalPoints / 6).ceil().clamp(1, totalPoints);

                          if (value.toInt() == 0 ||
                              value.toInt() == data.total.chartData.length - 1 ||
                              value.toInt() % labelInterval == 0) {
                            final monthLabel = _getMonthLabelForIndex(dataIndex, data.total.dateTime, months);
                            if (monthLabel.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextWidget.captionText(
                                  text: monthLabel,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 1,
                                ),
                              );
                            }
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.total.chartData.length - 1).toDouble(),
                minY: _getMinYValue([data.total.chartData]),
                // Add consistent padding for all charts
                clipData: const FlClipData.all(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((spot) => null).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: barData.color ?? const Color(0xFF3B82F6),
                          strokeWidth: 2,
                          dashArray: [5, 5],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: barData.color ?? const Color(0xFF3B82F6),
                              strokeWidth: 3,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  handleBuiltInTouches: true,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent ||
                        event is FlPanUpdateEvent ||
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent ||
                        event is FlLongPressStart ||
                        event is FlLongPressEnd ||
                        event is FlLongPressMoveUpdate ||
                        event is FlPanEndEvent) {
                      
                      if (touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final index = spot.x.toInt();

                      if (index >= 0 && index < data.total.chartData.length) {
                          setState(() {
                            inflationTouchedSpot = FlSpot(index.toDouble(), 0);
                            showInflationTooltip = true;
                          });

                          // Only set auto-hide timer for tap events, not for continuous interactions
                          if (event is FlTapUpEvent || event is FlPanEndEvent || event is FlLongPressEnd) {
                            _hideInflationTooltipTimer?.cancel();
                            _hideInflationTooltipTimer = Timer(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  showInflationTooltip = false;
                                  inflationTouchedSpot = null;
                                });
                              }
                            });
                          } else {
                            // For continuous touch events (pan, long press move), cancel existing timer
                            // but don't set a new one to avoid interference
                            _hideInflationTooltipTimer?.cancel();
                          }
                        }
                      }
                    } else if (event is FlPanEndEvent || event is FlTapCancelEvent) {
                      // Handle touch end/cancel events
                      _hideInflationTooltipTimer?.cancel();
                      _hideInflationTooltipTimer = Timer(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            showInflationTooltip = false;
                            inflationTouchedSpot = null;
                          });
                        }
                      });
                    }
                  },
                ),
                lineBarsData: [
                  // Original performance (blue)
                  LineChartBarData(
                    spots: data.total.chartData.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value / 1000)
                    ).toList(),
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                  // Inflation adjusted (purple) - calculated using proper inflation adjustment
                  LineChartBarData(
                    spots: data.total.chartData.asMap().entries.map((e) {
                      // Calculate inflation adjusted value using the ratio from API data
                      // The API already provides the correct inflation adjusted final value
                      final originalValue = e.value;
                      final inflationAdjustmentRatio = data.inflationAdjusted.finalValue / data.total.currentValue;
                      final inflationAdjustedValue = originalValue * inflationAdjustmentRatio;
                      return FlSpot(e.key.toDouble(), inflationAdjustedValue / 1000);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF8B5CF6),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
                ),
                // Custom tooltip positioned as overlay
                if (showInflationTooltip && inflationTouchedSpot != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                            final index = inflationTouchedSpot!.x.toInt();
                            if (index >= 0 && index < data.total.chartData.length) {
                              final monthLabel = _getMonthLabelForIndex(index, data.total.dateTime, months);
                              final originalSpots = data.total.chartData.asMap().entries.map((e) => 
                                FlSpot(e.key.toDouble(), e.value / 1000)
                              ).toList();
                              final inflationAdjustedSpots = data.total.chartData.asMap().entries.map((e) {
                                final originalValue = e.value;
                                final inflationAdjustmentRatio = data.inflationAdjusted.finalValue / data.total.currentValue;
                                final inflationAdjustedValue = originalValue * inflationAdjustmentRatio;
                                return FlSpot(e.key.toDouble(), inflationAdjustedValue / 1000);
                              }).toList();
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextWidget.subText(
                                    text: monthLabel,
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  if (index < originalSpots.length)
                                    TextWidget.paraText(
                                      text: 'Original ${originalSpots[index].y.toStringAsFixed(2)}K',
                                      theme: theme.isDarkMode,
                                      color: const Color(0xFF3B82F6),
                                      fw: 0,
                                    ),
                                  const SizedBox(height: 4),
                                  if (index < inflationAdjustedSpots.length)
                                    TextWidget.paraText(
                                      text: 'Inflation Adjusted ${inflationAdjustedSpots[index].y.toStringAsFixed(2)}K',
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Original', const Color(0xFF3B82F6)),
              const SizedBox(width: 20),
              _buildChartLegend('Inflation Adjusted', const Color(0xFF8B5CF6)),
            ],
          ),
          const SizedBox(height: 16),
          // XIRR Comparison in card format
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                // XIRR Comparison Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode 
                        ? colors.primaryDark.withOpacity(0.05)
                        : colors.primaryLight.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.isDarkMode 
                          ? colors.textSecondaryDark.withOpacity(0.1)
                          : colors.primaryDark.withOpacity(0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Original XIRR
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.paraText(
                              text: 'Original XIRR',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode 
                                  ? colors.textSecondaryDark 
                                  : colors.textSecondaryLight,
                              fw: 0,
                            ),
                            const SizedBox(height: 6),
                            TextWidget.titleText(
                              text: '${data.total.xirr.toStringAsFixed(2)}%',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode 
                                  ? colors.textPrimaryDark 
                                  : colors.textPrimaryLight,
                              fw: 1,
                            ),
                          ],
                        ),
                      ),
                     
                      // Inflation Adjusted XIRR
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.paraText(
                              text: 'Inflation Adjusted XIRR',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode 
                                  ? colors.textSecondaryDark 
                                  : colors.textSecondaryLight,
                              fw: 0,
                            ),
                            const SizedBox(height: 4),
                            TextWidget.titleText(
                              text: '${data.inflationAdjusted.xirr.toStringAsFixed(2)}%',
                              theme: theme.isDarkMode,
                              color: data.inflationAdjusted.xirr < data.total.xirr
                                  ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
                                  : (theme.isDarkMode ? colors.profitDark : colors.profitLight),
                              fw: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Inflation adjusted comparison table
          _buildInflationComparisonTable(data),
        ],
      ),
    );
  }

  Widget _buildInflationComparisonTable(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // Static header row
          _buildThreeColumnDataRow(
            'Metric', 
            'Original', 
            'Inflation Adjusted', 
            theme,
            yourColor: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            benchmarkColor: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            isHeader: true,
          ),
          // Current row
          _buildThreeColumnDataRow(
            'Current', 
            _formatNumber(data.total.currentValue), 
            _formatNumber(data.inflationAdjusted.finalValue), 
            theme,
          ),
          // Gain row
          _buildThreeColumnDataRow(
            'Gain', 
            _formatNumber(data.total.gain), 
            _formatNumber(data.inflationAdjusted.gain), 
            theme,
            yourColor: data.total.gain >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
            benchmarkColor: data.inflationAdjusted.gain >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
          ),
          // Sharpe Ratio row
          _buildThreeColumnDataRow(
            'Sharpe Ratio', 
            data.total.sharpeRatio.toStringAsFixed(2), 
            data.inflationAdjusted.sharpeRatio.toStringAsFixed(2), 
            theme,
          ),
          // Max Drawdown row
          _buildThreeColumnDataRow(
            'Max Drawdown', 
            '${data.total.maxDrawdown.toStringAsFixed(2)}%', 
            '${data.inflationAdjusted.maxDrawdown.toStringAsFixed(2)}%', 
            theme,
            yourColor: theme.isDarkMode ? colors.lossDark : colors.lossLight,
            benchmarkColor: theme.isDarkMode ? colors.lossDark : colors.lossLight,
          ),
          // XIRR row
          _buildThreeColumnDataRow(
            'XIRR', 
            '${data.total.xirr.toStringAsFixed(2)}%', 
            '${data.inflationAdjusted.xirr.toStringAsFixed(2)}%', 
            theme,
            yourColor: data.total.xirr >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
            benchmarkColor: data.inflationAdjusted.xirr >= 0 
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxImplications(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    final totalGains = data.total.gain;
    final equityTax = data.taxDetails.equity.tax;
    final debtTax = data.taxDetails.debt.tax;
    final hybridTax = data.taxDetails.hybrid.tax;
    final totalTax = equityTax + debtTax + hybridTax;
    final postTaxGains = totalGains - totalTax;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          // Tax calculation formula
          Container(
              padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode 
                        ? colors.primaryDark.withOpacity(0.05)
                        : colors.primaryLight.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.isDarkMode 
                          ? colors.textSecondaryDark.withOpacity(0.1)
                          : colors.primaryDark.withOpacity(0.7),
                    ),
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildModernTaxComponent('Total Gains', '$totalGains', theme.isDarkMode ? colors.profitDark : colors.profitLight, theme),
                Icon(Icons.remove, 
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  size: 16,
                ),
                _buildModernTaxComponent('Total Tax', '$totalTax', theme.isDarkMode ? colors.lossDark : colors.lossLight, theme),
                Icon(Icons.drag_handle, 
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  size: 16,
                ),
                _buildModernTaxComponent('Post Tax Gains', '$postTaxGains', theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight, theme),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tax summary in card format
          // Container(
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          //     borderRadius: BorderRadius.circular(5),
          //   ),
          //   child: Column(
          //     children: [
          //       _buildDataRow('Total Gains', '${totalGains}', theme, 
          //         color: theme.isDarkMode ? colors.profitDark : colors.profitLight),
          //       _buildDataRow('Total Tax', '${totalTax}', theme, 
          //         color: theme.isDarkMode ? colors.lossDark : colors.lossLight),
          //       _buildDataRow('Post Tax Gains', '${postTaxGains}', theme, 
          //         color: theme.isDarkMode ? colors.profitDark : colors.profitLight),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 16),
          // Tax breakdown in card format
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                _buildDataRow('Short Term Capital Gains Tax', '$equityTax', theme,  color: theme.isDarkMode ? colors.profitDark : colors.profitLight),
                
                _buildDataRow('Long Term Capital Gains Tax', '$debtTax', theme, 
                  color: theme.isDarkMode ? colors.profitDark : colors.profitLight),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextWidget.captionText(
            text: '*calculated using 30% tax slab',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildTaxComponent(String label, String value, Color color) {
    final theme = ref.watch(themeProvider);
    
    return Column(
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 4),
        TextWidget.subText(
          text: value,
          theme: theme.isDarkMode,
          color: color,
          fw: 1,
        ),
      ],
    );
  }

  Widget _buildModernTaxComponent(String label, String value, Color color, ThemesProvider theme) {
    return Column(
      children: [
        TextWidget.subText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 8),
        TextWidget.subText(
          text: value,
          theme: theme.isDarkMode,
          color: color,
          fw: 0,
        ),
      ],
    );
  }

  Widget _buildModernTaxBreakdown(String label, String value, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode 
          ? colors.textSecondaryDark.withOpacity(0.05)
          : colors.textSecondaryLight.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.captionText(
            text: label,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
          ),
          const SizedBox(height: 8),
          TextWidget.paraText(
            text: value,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBreakdown(String label, String value) {
    final theme = ref.watch(themeProvider);
    
    return Column(
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 4),
        TextWidget.subText(
          text: value,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 0,
        ),
      ],
    );
  }



  // Helper method to generate month labels from actual dateTime data
  List<String> _generateMonthLabelsFromDateTime(List<String> dateTimeList) {
    if (dateTimeList.isEmpty) return [];
    
    final months = <String>[];
    final Set<String> uniqueMonths = {};
    
    // Parse dates and extract unique months
    for (String dateStr in dateTimeList) {
      try {
        final date = DateTime.parse(dateStr);
        final monthAbbr = _getMonthAbbreviation(date.month);
        final year = date.year.toString().substring(2);
        final monthYear = '$monthAbbr $year';
        
        if (!uniqueMonths.contains(monthYear)) {
          uniqueMonths.add(monthYear);
          months.add(monthYear);
        }
      } catch (e) {
        print('Error parsing date: $dateStr, error: $e');
        continue;
      }
    }
    
    // Sort months chronologically
    months.sort((a, b) {
      final dateA = _parseMonthYear(a);
      final dateB = _parseMonthYear(b);
      return dateA.compareTo(dateB);
    });
    
    // For large datasets, limit to reasonable number of labels for readability
    if (months.length > 12) {
      // Show every 2-3 months for better readability
      final step = (months.length / 8).ceil().clamp(1, 3);
      final filteredMonths = <String>[];
      for (int i = 0; i < months.length; i += step) {
        filteredMonths.add(months[i]);
      }
      // Always include the last month
      if (months.isNotEmpty && !filteredMonths.contains(months.last)) {
        filteredMonths.add(months.last);
      }
      return filteredMonths;
    }
    
    return months;
  }

  // Helper method to parse month year string back to DateTime for sorting
  DateTime _parseMonthYear(String monthYear) {
    final parts = monthYear.split(' ');
    if (parts.length != 2) return DateTime.now();
    
    final monthAbbr = parts[0];
    final year = '20${parts[1]}'; // Assuming 20xx format
    
    final monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    
    final month = monthMap[monthAbbr] ?? 1;
    return DateTime(int.parse(year), month);
  }

  // Helper method to get month label for a specific data point index
  String _getMonthLabelForIndex(int index, List<String> dateTimeList, List<String> months) {
    if (index < 0 || index >= dateTimeList.length || months.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateTimeList[index]);
      final monthAbbr = _getMonthAbbreviation(date.month);
      final year = date.year.toString().substring(2);
      final monthYear = '$monthAbbr $year';
      
      // Find the closest month in our months list
      for (String month in months) {
        if (month == monthYear) {
          return month;
        }
      }
      
      // If exact match not found, find the closest month by date
      final currentDate = DateTime.parse(dateTimeList[index]);
      String closestMonth = '';
      DateTime? closestDate;
      
      for (String month in months) {
        try {
          final monthDate = _parseMonthYear(month);
          if (closestDate == null || 
              (currentDate.difference(monthDate).abs() < currentDate.difference(closestDate).abs())) {
            closestDate = monthDate;
            closestMonth = month;
          }
        } catch (e) {
          continue;
        }
      }
      
      return closestMonth.isNotEmpty ? closestMonth : monthYear;
    } catch (e) {
      return '';
    }
  }

  // Helper method to get month abbreviation
  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }


  // Helper method to get current date
  String _getCurrentDate() {
    final now = DateTime.now();
    final day = now.day;
    final monthAbbr = _getMonthAbbreviation(now.month);
    final year = now.year;
    return '$day${_getOrdinalSuffix(day)} $monthAbbr $year';
  }

  // Helper method to get ordinal suffix for day
  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  // Helper method to get investment start date
  String _getInvestmentStartDate(int chartDataLength) {
    final startDate = DateTime.now().subtract(Duration(days: chartDataLength));
    final day = startDate.day;
    final monthAbbr = _getMonthAbbreviation(startDate.month);
    final year = startDate.year;
    return '${day.toString().padLeft(2, '0')} $monthAbbr $year';
  }

  // Helper method to format date for tooltip
  String _formatDate(String monthYear) {
    try {
      // If it's already in "MMM YY" format, return as is
      if (monthYear.contains(' ')) {
        return monthYear;
      }
      // If it's a full date string, parse it
      final date = DateTime.parse(monthYear);
      final month = _getMonthAbbreviation(date.month);
      final year = date.year.toString().substring(2);
      return '$month $year';
    } catch (e) {
      return monthYear;
    }
  }

  // Helper method to calculate minimum Y value for charts - start from actual minimum
  double _getMinYValue(List<List<double>> chartDataLists) {
    if (chartDataLists.isEmpty) return 0;
    
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    
    for (var chartData in chartDataLists) {
      if (chartData.isNotEmpty) {
        final localMin = chartData.reduce((a, b) => a < b ? a : b);
        final localMax = chartData.reduce((a, b) => a > b ? a : b);
        if (localMin < minValue) {
          minValue = localMin;
        }
        if (localMax > maxValue) {
          maxValue = localMax;
        }
      }
    }
    
    // Convert to thousands (like the chart data)
    final minYInThousands = minValue / 1000;
    final maxYInThousands = maxValue / 1000;
    
    // Calculate the range
    final range = maxYInThousands - minYInThousands;
    
    // Add 10% padding below the minimum value for better visualization
    // But ensure it doesn't go below 0 for positive values
    final padding = range * 0.1;
    final adjustedMinY = (minYInThousands - padding).clamp(0.0, minYInThousands);
    
    print('📊 Chart range: ${minYInThousands.toStringAsFixed(1)}K to ${maxYInThousands.toStringAsFixed(1)}K');
    print('📊 Chart will start from: ${adjustedMinY.toStringAsFixed(1)}K (with 10% padding)');
    
    return adjustedMinY;
  }
}
