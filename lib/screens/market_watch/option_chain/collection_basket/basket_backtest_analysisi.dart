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

import '../../../../provider/dashboard_provider.dart';

class BasketBacktestAnalysisScreen extends ConsumerStatefulWidget {
  const BasketBacktestAnalysisScreen({super.key});

  @override
  ConsumerState<BasketBacktestAnalysisScreen> createState() => _BasketBacktestAnalysisScreenState();
}

class _BasketBacktestAnalysisScreenState extends ConsumerState<BasketBacktestAnalysisScreen> {
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

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Load your portfolio analysis data here
    // });
  }

  @override
  void dispose() {
    _hidePerformanceTooltipTimer?.cancel();
    _hideBenchmarkTooltipTimer?.cancel();
    _hideInflationTooltipTimer?.cancel();
    _scrollController.dispose();
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
          text: "Basket Backtest Analysis",
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.transparent,
              shape: const RoundedRectangleBorder(),
              child: InkWell(
                customBorder: const RoundedRectangleBorder(),
                splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                onTap: () => _navigateToCustomizeStrategy(),
                borderRadius: BorderRadius.circular(5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: colors.colorBlue,
                    ),
                    const SizedBox(width: 4),
                    TextWidget.paraText(
                      text: 'Customize',
                      theme: theme.isDarkMode,
                      color: colors.colorBlue,
                      fw: 1,
                    ),
                  ],
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
            return _buildModernLayout(data, theme);
          },
        ),
      ),
    );
  }

  Widget _buildModernLayout(PortfolioAnalysisModel data, ThemesProvider theme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Main content section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernPortfolioSummary(data.total, theme),
                const SizedBox(height: 16),
                _buildPerformanceChart(data),
                const SizedBox(height: 16),
                _buildQuickStatsCards(data, theme),
                const SizedBox(height: 16),
                _buildBenchmarkAnalysis(data),
                const SizedBox(height: 16),
                
                _buildInflationAdjustment(data),
                const SizedBox(height: 16),
                _buildTaxImplications(data),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildModernPortfolioSummary(PortfolioTotal data, ThemesProvider theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
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
                    text: '${data.xirr.toStringAsFixed(2)}%',
                    theme: theme.isDarkMode,
                    color: data.xirr.toStringAsFixed(2).startsWith("-")
                        ? theme.isDarkMode
                            ? colors.lossDark
                            : colors.lossLight
                        : data.xirr == 0
                            ? colors.textSecondaryLight
                            : theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight,
                    fw: 1,
                  ),
                  const SizedBox(height: 4),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextWidget.titleText(
                    text: '₹${data.currentValue}',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 4),
                  TextWidget.subText(
                    text: 'Final Value',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 3,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Invested',
                  '₹${data.investmentAmount}',
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Gain',
                  '₹${data.gain}',
                  theme,
                  valueColor: data.gain >= 0 
                    ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
                    : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'XIRR',
                  '${data.xirr.toStringAsFixed(2)}%',
                  theme,
                  valueColor: data.xirr >= 0 
                    ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
                    : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, ThemesProvider theme, {Color? valueColor}) {
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
      ),
    );
  }

  Widget _buildQuickStatsCards(PortfolioAnalysisModel data, ThemesProvider theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Risk Metrics',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  'Sharpe Ratio',
                  data.total.sharpeRatio.toStringAsFixed(2),
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Volatility',
                  '${data.total.volatility.toStringAsFixed(2)}%',
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Max Drawdown',
                  '${data.total.maxDrawdown.toStringAsFixed(2)}%',
                  theme,
                  valueColor: data.total.maxDrawdown < 0 
                    ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
                    : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
    
    // Generate spots from chart data
    for (int i = 0; i < data.total.chartData.length; i++) {
      totalSpots.add(FlSpot(i.toDouble(), data.total.chartData[i] / 1000));
      if (data.equity.isNotEmpty && i < data.equity[0].chartData.length) {
        equitySpots.add(FlSpot(i.toDouble(), data.equity[0].chartData[i] / 1000));
      }
      if (data.debt.isNotEmpty && i < data.debt[0].chartData.length) {
        debtSpots.add(FlSpot(i.toDouble(), data.debt[0].chartData[i] / 1000));
      }
    }

    // Generate dynamic month labels based on chart data length
    final months = _generateMonthLabels(data.total.chartData.length);

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.subText(
                    text: 'Overall Returns',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ],
              ),
              // Custom tooltip positioned above chart
              if (showPerformanceTooltip && performanceTouchedSpot != null)
                Container(
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
                        // Calculate the month index safely
                        final monthIndex = (index * months.length / totalSpots.length).floor().clamp(0, months.length - 1);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWidget.subText(
                              text: _formatDate(months[monthIndex]),
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 1,
                            ),
                            const SizedBox(height: 4),
                            if (equitySpots.isNotEmpty && index < equitySpots.length)
                              TextWidget.paraText(
                                text: 'Equity: ${equitySpots[index].y.toStringAsFixed(2)}K',
                                theme: theme.isDarkMode,
                                color: const Color(0xFF3B82F6),
                                fw: 1,
                              ),
                            if (equitySpots.isNotEmpty && debtSpots.isNotEmpty && index < debtSpots.length)
                              const SizedBox(height: 2),
                            if (debtSpots.isNotEmpty && index < debtSpots.length)
                              TextWidget.paraText(
                                text: 'Hybrid: ${debtSpots[index].y.toStringAsFixed(2)}K',
                                theme: theme.isDarkMode,
                                color: const Color(0xFF8B5CF6),
                                fw: 1,
                              ),
                            if ((equitySpots.isNotEmpty || debtSpots.isNotEmpty) && index < totalSpots.length)
                              const SizedBox(height: 2),
                            if (index < totalSpots.length)
                              TextWidget.paraText(
                                text: 'Total: ${totalSpots[index].y.toStringAsFixed(2)}K',
                                theme: theme.isDarkMode,
                                color: const Color(0xFF10B981),
                                fw: 1,
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
          const SizedBox(height: 20),
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
                        if (value.toInt() < totalSpots.length) {
                          final dataIndex = value
                              .toInt()
                              .clamp(0, months.length - 1);
                          final totalPoints = totalSpots.length;
                          final labelInterval =
                              (totalPoints / 6).ceil().clamp(1, totalPoints);

                          if (value.toInt() == 0 ||
                              value.toInt() == totalSpots.length - 1 ||
                              value.toInt() % labelInterval == 0) {
                            if (dataIndex >= 0 && dataIndex < months.length) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: value.toInt() == 0 ? 20 : 0,
                                  right: value.toInt() ==
                                          totalSpots.length - 1
                                      ? 20
                                      : 0,
                                ),
                                child: TextWidget.captionText(
                                  text: months[dataIndex],
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
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (totalSpots.length - 1).toDouble(),
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
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    // Handle different touch events
                    if (event is FlTapUpEvent ||
                        event is FlPanUpdateEvent ||
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent) {
                      if (touchResponse != null && touchResponse.lineBarSpots != null) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final index = spot.x.toInt();

                        if (index >= 0 && index < totalSpots.length) {
                          setState(() {
                            performanceTouchedSpot = FlSpot(index.toDouble(), 0);
                            showPerformanceTooltip = true;
                          });

                          // Auto-hide tooltip after 2 seconds
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
                      }
                    }
                  },
                ),
                lineBarsData: [
                  // Equity line (modern blue)
                  if (equitySpots.isNotEmpty)
                    LineChartBarData(
                      spots: equitySpots,
                      isCurved: true,
                      color: const Color(0xFF3B82F6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  // Debt line (modern purple)
                  if (debtSpots.isNotEmpty)
                    LineChartBarData(
                      spots: debtSpots,
                      isCurved: true,
                      color: const Color(0xFF8B5CF6),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  // Total portfolio line (modern green)
                  LineChartBarData(
                    spots: totalSpots,
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend and info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (data.equity.isNotEmpty)
                _buildChartLegend('Equity', const Color(0xFF3B82F6)),
              if (data.equity.isNotEmpty && data.debt.isNotEmpty)
                const SizedBox(width: 20),
              if (data.debt.isNotEmpty)
                _buildChartLegend('Hybrid', const Color(0xFF8B5CF6)),
              const SizedBox(width: 20),
              _buildChartLegend('Total', const Color(0xFF10B981)),
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
    final months = _generateMonthLabels(data.total.chartData.length);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Benchmark Analysis',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 1,
          ),
          const SizedBox(height: 16),
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
          if (showBenchmarkTooltip && benchmarkTouchedSpot != null)...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
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
                            // Calculate the month index safely
                            final monthIndex = (index * months.length / data.total.chartData.length).floor().clamp(0, months.length - 1);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWidget.subText(
                                  text: _formatDate(months[monthIndex]),
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  fw: 1,
                                ),
                                const SizedBox(height: 4),
                                TextWidget.paraText(
                                  text: 'Benchmark: ${(data.benchmark.chartData[index] / 1000).toStringAsFixed(2)}K',
                                  theme: theme.isDarkMode,
                                  color: const Color(0xFF3B82F6),
                                  fw: 1,
                                ),
                                const SizedBox(height: 2),
                                TextWidget.paraText(
                                  text: 'Your Strategy: ${(data.total.chartData[index] / 1000).toStringAsFixed(2)}K',
                                  theme: theme.isDarkMode,
                                  color: const Color(0xFF10B981),
                                  fw: 1,
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
          ]else...[
            const SizedBox(height: 40),
          ],
          const SizedBox(height: 20),
          // Benchmark comparison chart
          SizedBox(
            height: 200,
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
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.total.chartData.length) {
                          final dataIndex = value
                              .toInt()
                              .clamp(0, months.length - 1);
                          final totalPoints = data.total.chartData.length;
                          final labelInterval =
                              (totalPoints / 6).ceil().clamp(1, totalPoints);

                          if (value.toInt() == 0 ||
                              value.toInt() == data.total.chartData.length - 1 ||
                              value.toInt() % labelInterval == 0) {
                            if (dataIndex >= 0 && dataIndex < months.length) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: value.toInt() == 0 ? 20 : 0,
                                  right: value.toInt() ==
                                          data.total.chartData.length - 1
                                      ? 20
                                      : 0,
                                ),
                                child: TextWidget.captionText(
                                  text: months[dataIndex],
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
                minY: 0,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((spot) => null).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (event is FlTapUpEvent ||
                        event is FlPanUpdateEvent ||
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent) {
                      if (touchResponse != null && touchResponse.lineBarSpots != null) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final index = spot.x.toInt();

                        if (index >= 0 && index < data.total.chartData.length) {
                          setState(() {
                            benchmarkTouchedSpot = FlSpot(index.toDouble(), 0);
                            showBenchmarkTooltip = true;
                          });

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
                      }
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
                    dotData: FlDotData(show: false),
                  ),
                  // Your Strategy (green)
                  LineChartBarData(
                    spots: data.total.chartData.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value / 1000)
                    ).toList(),
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 2,
                    dotData: FlDotData(show: false),
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
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                ? colors.textSecondaryDark.withOpacity(0.1)
                : colors.textSecondaryLight.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: TextWidget.paraText(
                    text: 'Strategy',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                    align: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Final Value',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Gain',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Sharpe',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Max DD',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'XIRR',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                    align: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          // Your Strategy row
          _buildModernComparisonRow(
            'Your Strategy', 
            '₹${data.total.currentValue}',
            '₹${data.total.gain}',
            data.total.sharpeRatio.toStringAsFixed(1),
            '${data.total.maxDrawdown.toStringAsFixed(2)}%',
            '${data.total.xirr.toStringAsFixed(2)}%',
            const Color(0xFF10B981),
            theme,
            true,
          ),
          // Divider
          Container(
            height: 1,
            color: theme.isDarkMode 
              ? colors.textSecondaryDark.withOpacity(0.1)
              : colors.textSecondaryLight.withOpacity(0.1),
          ),
          // Benchmark row
          _buildModernComparisonRow(
            data.benchmark.schemeName, 
            '₹${data.benchmark.currentValue}',
            '₹${data.benchmark.gain}',
            data.benchmark.sharpeRatio.toStringAsFixed(1),
            '${data.benchmark.maxDrawdown.toStringAsFixed(2)}%',
            '${data.benchmark.xirr.toStringAsFixed(2)}%',
            const Color(0xFF3B82F6),
            theme,
            false,
          ),
        ],
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
    final months = _generateMonthLabels(data.total.chartData.length);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Inflation Adjustment',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 1,
          ),
           if (showInflationTooltip && inflationTouchedSpot != null)...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
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
                            // Calculate the month index safely
                            final monthIndex = (index * months.length / data.total.chartData.length).floor().clamp(0, months.length - 1);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWidget.subText(
                                  text: _formatDate(months[monthIndex]),
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  fw: 1,
                                ),
                                const SizedBox(height: 4),
                                TextWidget.paraText(
                                  text: 'Original: ${(data.total.chartData[index] / 1000).toStringAsFixed(2)}K',
                                  theme: theme.isDarkMode,
                                  color: const Color(0xFF3B82F6),
                                  fw: 1,
                                ),
                                const SizedBox(height: 2),
                                TextWidget.paraText(
                                  text: 'Inflation Adjusted: ${(() {
                                    final originalValue = data.total.chartData[index];
                                    final inflationAdjustmentRatio = data.inflationAdjusted.finalValue / data.total.currentValue;
                                    final inflationAdjustedValue = originalValue * inflationAdjustmentRatio;
                                    return (inflationAdjustedValue / 1000).toStringAsFixed(2);
                                  })()}K',
                                  theme: theme.isDarkMode,
                                  color: const Color(0xFF8B5CF6),
                                  fw: 1,
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
           ]else...[
            const SizedBox(height: 50),
          ],
          // const SizedBox(height: 10),
          // Chart showing inflation adjustment
          SizedBox(
            height: 200,
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
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.total.chartData.length) {
                          final dataIndex = value
                              .toInt()
                              .clamp(0, months.length - 1);
                          final totalPoints = data.total.chartData.length;
                          final labelInterval =
                              (totalPoints / 6).ceil().clamp(1, totalPoints);

                          if (value.toInt() == 0 ||
                              value.toInt() == data.total.chartData.length - 1 ||
                              value.toInt() % labelInterval == 0) {
                            if (dataIndex >= 0 && dataIndex < months.length) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: value.toInt() == 0 ? 20 : 0,
                                  right: value.toInt() ==
                                          data.total.chartData.length - 1
                                      ? 20
                                      : 0,
                                ),
                                child: TextWidget.captionText(
                                  text: months[dataIndex],
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
                minY: 0,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((spot) => null).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (event is FlTapUpEvent ||
                        event is FlPanUpdateEvent ||
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent) {
                      if (touchResponse != null && touchResponse.lineBarSpots != null) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final index = spot.x.toInt();

                        if (index >= 0 && index < data.total.chartData.length) {
                          setState(() {
                            inflationTouchedSpot = FlSpot(index.toDouble(), 0);
                            showInflationTooltip = true;
                          });

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
                      }
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
                    dotData: FlDotData(show: false),
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
                    dotData: FlDotData(show: false),
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
          // Before vs After comparison
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  TextWidget.subText(
                    text: 'Original XIRR',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 4),
                  TextWidget.subText(
                    text: '${data.total.xirr.toStringAsFixed(2)}%',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
                  ),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                children: [
                  TextWidget.subText(
                    text: 'Inflation Adjusted XIRR',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 4),
                  TextWidget.subText(
                    text: '${data.inflationAdjusted.xirr.toStringAsFixed(2)}%',
                    theme: theme.isDarkMode,
                    color: data.inflationAdjusted.xirr < data.total.xirr
                        ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
                        : (theme.isDarkMode ? colors.profitDark : colors.profitLight),
                    fw: 0,
                  ),
                ],
              ),
            ],
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
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
       
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                ? colors.textSecondaryDark.withOpacity(0.1)
                : colors.textSecondaryLight.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextWidget.paraText(
                    text: 'Strategy',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 1,
                    align: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Final Value',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 1,
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Gain',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 1,
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Sharpe',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 1,
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'Max DD',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 1,
                    align: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextWidget.paraText(
                    text: 'XIRR',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 1,
                    align: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          // Original row
          _buildModernComparisonRow(
            'Original', 
            '₹${data.total.currentValue}',
            '₹${data.total.gain}',
            data.total.sharpeRatio.toStringAsFixed(1),
            '${data.total.maxDrawdown.toStringAsFixed(2)}%',
            '${data.total.xirr.toStringAsFixed(2)}%',
            const Color(0xFF3B82F6),
            theme,
            true,
          ),
          // Divider
          Container(
            height: 1,
            color: theme.isDarkMode 
              ? colors.textSecondaryDark.withOpacity(0.1)
              : colors.textSecondaryLight.withOpacity(0.1),
          ),
          // Inflation Adjusted row
          _buildModernComparisonRow(
            'Inflation Adjusted', 
            '₹${data.inflationAdjusted.finalValue}',
            '₹${data.inflationAdjusted.gain}',
            data.inflationAdjusted.sharpeRatio.toStringAsFixed(1),
            '${data.inflationAdjusted.maxDrawdown.toStringAsFixed(2)}%',
            '${data.inflationAdjusted.xirr.toStringAsFixed(2)}%',
            const Color(0xFF8B5CF6),
            theme,
            false,
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
    final totalTax = equityTax + debtTax;
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
          TextWidget.subText(
            text: 'Tax Implications',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 0,
          ),
          const SizedBox(height: 24),
          // Tax calculation formula
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
             
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.isDarkMode 
                  ? colors.textSecondaryDark.withOpacity(0.1)
                  : colors.textSecondaryLight.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildModernTaxComponent('Total Gains', '₹${totalGains}', theme.isDarkMode ? colors.profitDark : colors.profitLight, theme),
                Icon(Icons.remove, 
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  size: 16,
                ),
                _buildModernTaxComponent('Total Tax', '₹${totalTax}', theme.isDarkMode ? colors.lossDark : colors.lossLight, theme),
                Icon(Icons.drag_handle, 
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  size: 16,
                ),
                _buildModernTaxComponent('Post Tax Gains', '₹${postTaxGains}', theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight, theme),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tax breakdown
          Row(
            children: [
              Expanded(
                child: _buildModernTaxBreakdown('Short Term Capital Gains Tax', '₹${(equityTax / 1000).toStringAsFixed(0)}K', theme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernTaxBreakdown('Long Term Capital Gains Tax', '₹${(debtTax / 1000).toStringAsFixed(0)}K', theme),
              ),
            ],
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
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        TextWidget.paraText(
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



  // Helper method to generate dynamic month labels based on chart data length
  List<String> _generateMonthLabels(int chartDataLength) {
    if (chartDataLength == 0) return [];
    
    // Calculate the number of months based on data points
    // Assuming daily data, we'll show monthly intervals
    final monthsToShow = (chartDataLength / 30).ceil().clamp(3, 12); // Show 3-12 months
    final months = <String>[];
    
    // Start from a base date (assuming investment started 2+ years ago)
    final startDate = DateTime.now().subtract(Duration(days: chartDataLength));
    
    // Generate month labels
    for (int i = 0; i < monthsToShow; i++) {
      final monthDate = startDate.add(Duration(days: (chartDataLength / monthsToShow * i).round()));
      final monthAbbr = _getMonthAbbreviation(monthDate.month);
      final year = monthDate.year.toString().substring(2);
      months.add('$monthAbbr $year');
    }
    
    return months;
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
    return '${day}${_getOrdinalSuffix(day)} $monthAbbr $year';
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
}