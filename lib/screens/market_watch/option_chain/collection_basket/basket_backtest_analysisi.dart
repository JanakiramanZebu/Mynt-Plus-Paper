import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/explore_model/basket_backtest_analysis_model.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';

import '../../../../provider/dashboard_provider.dart';

class BasketBacktestAnalysisScreen extends ConsumerStatefulWidget {
  const BasketBacktestAnalysisScreen({super.key});

  @override
  ConsumerState<BasketBacktestAnalysisScreen> createState() => _BasketBacktestAnalysisScreenState();
}

class _BasketBacktestAnalysisScreenState extends ConsumerState<BasketBacktestAnalysisScreen> {
  FlSpot? touchedSpot;
  bool showTooltip = false;
  Timer? _hideTooltipTimer;
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
    _hideTooltipTimer?.cancel();
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
        elevation: 0.2,
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
            highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 18,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
            ),
          ),
        ),
        title: TextWidget.titleText(
          text: "Basket Backtest Analysis",
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 1,
        ),
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            if (strategy.isStrategyLoading) {
              return Center(
                  child: Container(
                    color: Colors.white,
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
            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPortfolioSummary(data.total),
                  const SizedBox(height: 24),
                  _buildPerformanceChart(data),
                  const SizedBox(height: 24),
                  _buildBenchmarkAnalysis(data),
                  const SizedBox(height: 24),
                  _buildInflationAdjustment(data),
                  const SizedBox(height: 24),
                  _buildTaxImplications(data),
                  const SizedBox(height: 24),
                  _buildAssetAllocation(data),
                  const SizedBox(height: 24),
                  _buildTransactionsTable(data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortfolioSummary(PortfolioTotal data) {
    final theme = ref.watch(themeProvider);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with main metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn(
                'Final Value', 
                '₹${(data.currentValue / 100000).toStringAsFixed(2)}L',
                theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              ),
              _buildMetricColumn(
                'Invested Amount', 
                '₹${(data.investmentAmount / 100000).toStringAsFixed(2)}L',
                theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
              _buildMetricColumn(
                'Gain', 
                '₹${(data.gain / 1000).toStringAsFixed(0)}K (${data.gainPerc.toStringAsFixed(2)}%)',
                data.gain >= 0 
                  ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
                  : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bottom row with performance metrics
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.subText(
                    text: 'Return',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 3,
                  ),
                  const SizedBox(height: 8),
                  _buildReturnMetric('XIRR', '${data.xirr.toStringAsFixed(2)}%', Colors.green),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextWidget.subText(
                    text: 'Risk',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 3,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRiskMetric('Sharpe Ratio', data.sharpeRatio.toStringAsFixed(2)),
                      const SizedBox(width: 20),
                      _buildRiskMetric('Max Drawdown', '${data.maxDrawdown.toStringAsFixed(2)}%'),
                      const SizedBox(width: 20),
                      _buildRiskMetric('Volatility', '${data.volatility.toStringAsFixed(2)}%'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color valueColor) {
    final theme = ref.watch(themeProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          color: valueColor,
          fw: 1,
        ),
      ],
    );
  }

  Widget _buildReturnMetric(String label, String value, Color color) {
    final theme = ref.watch(themeProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 4),
        TextWidget.titleText(
          text: value,
          theme: theme.isDarkMode,
          color: color,
          fw: 0,
        ),
      ],
    );
  }

  Widget _buildRiskMetric(String label, String value) {
    final theme = ref.watch(themeProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          color: value.startsWith('-') 
            ? Colors.red 
            : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
          fw: 0,
        ),
      ],
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: 'Portfolio Performance',
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 1,
              ),
              TextWidget.paraText(
                text: '175 L',
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                fw: 0,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Sep 22', 'Dec 22', 'Feb 23', 'May 23', 'Jul 23', 'Sep 23', 'Dec 23'];
                        int index = (value / (totalSpots.length / months.length)).round();
                        if (index >= 0 && index < months.length) {
                          return TextWidget.captionText(
                            text: months[index],
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                            fw: 0,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Equity line (green area)
                  if (equitySpots.isNotEmpty)
                    LineChartBarData(
                      spots: equitySpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 0,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                  // Debt line (pink area)
                  if (debtSpots.isNotEmpty)
                    LineChartBarData(
                      spots: debtSpots,
                      isCurved: true,
                      color: Colors.pink,
                      barWidth: 0,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.pink.withOpacity(0.3),
                      ),
                    ),
                  // Total portfolio line (dark outline)
                  LineChartBarData(
                    spots: totalSpots,
                    isCurved: true,
                    color: Colors.black,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.paraText(
                    text: '29th Oct 2024',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 4),
                  TextWidget.subText(
                    text: 'Total: ₹${(data.total.currentValue / 100000).toStringAsFixed(2)}L',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (data.equity.isNotEmpty)
                        _buildLegendItem('Equity', '₹${(data.equity[0].currentValue / 100000).toStringAsFixed(2)}L', Colors.green),
                      const SizedBox(width: 16),
                      if (data.debt.isNotEmpty)
                        _buildLegendItem('Hybrid', '₹${(data.debt[0].currentValue / 100000).toStringAsFixed(2)}L', Colors.pink),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Asset class performance table
          _buildAssetClassTable(data),
        ],
      ),
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

  Widget _buildAssetClassTable(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.isDarkMode 
              ? colors.textSecondaryDark.withOpacity(0.05)
              : colors.textSecondaryLight.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextWidget.subText(
                  text: 'Asset Class',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),
              Expanded(
                child: TextWidget.subText(
                  text: 'Return',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),
              Expanded(
                child: TextWidget.subText(
                  text: 'Sharpe Ratio',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),
              Expanded(
                child: TextWidget.subText(
                  text: 'Max Drawdown',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),
              Expanded(
                child: TextWidget.subText(
                  text: 'XIRR',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),
            ],
          ),
        ),
        // Equity row
        if (data.equity.isNotEmpty)
          _buildAssetClassRow(
            'Equity', 
            '₹${(data.equity[0].gain / 1000).toStringAsFixed(0)}K', 
            data.equity[0].sharpeRatio.toStringAsFixed(2), 
            '${data.equity[0].maxDrawdown.toStringAsFixed(2)}%', 
            '${data.equity[0].xirr.toStringAsFixed(2)}%',
            Colors.green,
          ),
        // Debt row
        if (data.debt.isNotEmpty)
          _buildAssetClassRow(
            'Hybrid', 
            '₹${(data.debt[0].gain / 1000).toStringAsFixed(0)}K', 
            data.debt[0].sharpeRatio.toStringAsFixed(2), 
            '${data.debt[0].maxDrawdown.toStringAsFixed(2)}%', 
            '${data.debt[0].xirr.toStringAsFixed(2)}%',
            Colors.pink,
          ),
      ],
    );
  }

  Widget _buildAssetClassRow(String assetClass, String returns, String sharpe, String drawdown, String xirr, Color color) {
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
                const SizedBox(width: 8),
                TextWidget.subText(
                  text: assetClass,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 0,
                ),
              ],
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: returns,
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

  Widget _buildBenchmarkAnalysis(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    // Calculate the difference in XIRR for comparison
    final xirrDifference = data.total.xirr - data.benchmark.xirr;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
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
            children: [
              TextWidget.titleText(
                text: '${xirrDifference.toStringAsFixed(2)}% ${xirrDifference >= 0 ? 'higher' : 'lower'}',
                theme: theme.isDarkMode,
                color: xirrDifference >= 0 ? Colors.green : Colors.red,
                fw: 1,
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextWidget.paraText(
            text: 'annualised return (XIRR) compared to ${data.benchmark.schemeName}',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
          ),
          const SizedBox(height: 20),
          // Benchmark comparison chart
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Sep 22', 'Dec 22', 'Feb 23', 'Apr 23', 'Jun 23', 'Aug 23', 'Oct 23', 'Dec 23', 'Feb 24'];
                        int index = (value / (data.total.chartData.length / months.length)).round();
                        if (index >= 0 && index < months.length) {
                          return TextWidget.captionText(
                            text: months[index],
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                            fw: 0,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Benchmark (blue)
                  LineChartBarData(
                    spots: data.benchmark.chartData.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value / 1000)
                    ).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  // Your Strategy (green)
                  LineChartBarData(
                    spots: data.total.chartData.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value / 1000)
                    ).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
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
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                ? colors.textSecondaryDark.withOpacity(0.05)
                : colors.textSecondaryLight.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Final Value',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Gain',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Sharpe Ratio',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Max Drawdown',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'XIRR',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
              ],
            ),
          ),
          // Your Strategy row
          _buildComparisonRow(
            'Your Strategy', 
            '₹${(data.total.currentValue / 100000).toStringAsFixed(2)}L',
            '₹${(data.total.gain / 1000).toStringAsFixed(0)}K',
            data.total.sharpeRatio.toStringAsFixed(1),
            '${data.total.maxDrawdown.toStringAsFixed(2)}%',
            '${data.total.xirr.toStringAsFixed(2)}%',
            Colors.green,
          ),
          // Benchmark row
          _buildComparisonRow(
            data.benchmark.schemeName, 
            '₹${(data.benchmark.currentValue / 100000).toStringAsFixed(2)}L',
            '₹${(data.benchmark.gain / 1000).toStringAsFixed(0)}K',
            data.benchmark.sharpeRatio.toStringAsFixed(1),
            '${data.benchmark.maxDrawdown.toStringAsFixed(2)}%',
            '${data.benchmark.xirr.toStringAsFixed(2)}%',
            Colors.blue,
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
                const SizedBox(width: 8),
                Flexible(
                  child: TextWidget.subText(
                    text: name,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
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

  Widget _buildInflationAdjustment(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
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
          const SizedBox(height: 20),
          // Chart showing inflation adjustment
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Sep 22', 'Dec 22', 'Apr 23', 'Jun 23', 'Aug 23', 'Oct 23', 'Dec 23', 'Feb 24', 'May 24', 'Jul 24', 'Sep 25'];
                        int index = (value / (data.total.chartData.length / months.length)).round();
                        if (index >= 0 && index < months.length) {
                          return TextWidget.captionText(
                            text: months[index],
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                            fw: 0,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Original performance (blue)
                  LineChartBarData(
                    spots: data.total.chartData.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value / 1000)
                    ).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  // Inflation adjusted (purple) - simulated based on final value
                  LineChartBarData(
                    spots: data.total.chartData.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), (e.value * (data.inflationAdjusted.finalValue / data.total.currentValue)) / 1000)
                    ).toList(),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Before vs After comparison
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  TextWidget.subText(
                    text: 'before',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 4),
                  TextWidget.titleText(
                    text: '${data.total.xirr.toStringAsFixed(2)} %',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ],
              ),
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
                    text: 'vs',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ],
              ),
              Column(
                children: [
                  TextWidget.subText(
                    text: 'after',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 4),
                  TextWidget.titleText(
                    text: '${data.inflationAdjusted.xirr.toStringAsFixed(2)} %',
                    theme: theme.isDarkMode,
                    color: Colors.red,
                    fw: 1,
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
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                ? colors.textSecondaryDark.withOpacity(0.05)
                : colors.textSecondaryLight.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Final Value',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Gain',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Sharpe Ratio',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Max Drawdown',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'XIRR',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
              ],
            ),
          ),
          // Your Strategy row
          _buildComparisonRow(
            'Your Strategy', 
            '₹${(data.total.currentValue / 100000).toStringAsFixed(2)}L',
            '₹${(data.total.gain / 1000).toStringAsFixed(0)}K',
            data.total.sharpeRatio.toStringAsFixed(1),
            '${data.total.maxDrawdown.toStringAsFixed(2)}%',
            '${data.total.xirr.toStringAsFixed(2)}%',
            Colors.blue,
          ),
          // Inflation Adjusted row
          _buildComparisonRow(
            'Inflation Adjusted', 
            '₹${(data.inflationAdjusted.finalValue / 100000).toStringAsFixed(2)}L',
            '₹${(data.inflationAdjusted.gain / 1000).toStringAsFixed(0)}K',
            data.inflationAdjusted.sharpeRatio.toStringAsFixed(1),
            '${data.inflationAdjusted.maxDrawdown.toStringAsFixed(2)}%',
            '${data.inflationAdjusted.xirr.toStringAsFixed(2)}%',
            Colors.purple,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Tax Implications',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 1,
          ),
          const SizedBox(height: 20),
          // Tax calculation formula
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTaxComponent('Total Gains', '₹${(totalGains / 1000).toStringAsFixed(0)}K', Colors.green),
              Icon(Icons.remove, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
              _buildTaxComponent('Total Tax', '₹${(totalTax / 1000).toStringAsFixed(0)}K', Colors.red),
              Icon(Icons.drag_handle, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
              _buildTaxComponent('Post Tax Gains', '₹${(postTaxGains / 1000).toStringAsFixed(0)}K', Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          // Tax breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTaxBreakdown('Short Term Capital Gains Tax', '₹${(equityTax / 1000).toStringAsFixed(0)}K'),
              _buildTaxBreakdown('Long Term Capital Gains Tax', '₹${(debtTax / 1000).toStringAsFixed(0)}K'),
            ],
          ),
          const SizedBox(height: 8),
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

  Widget _buildAssetAllocation(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    // Calculate percentages based on actual data
    final equityPercentage = data.equity.isNotEmpty 
      ? (data.equity[0].currentValue / data.total.currentValue) * 100
      : 0.0;
    final debtPercentage = data.debt.isNotEmpty 
      ? (data.debt[0].currentValue / data.total.currentValue) * 100
      : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Asset Allocation',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 1,
          ),
          const SizedBox(height: 20),
          // Pie chart showing allocation
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (equityPercentage > 0)
                          PieChartSectionData(
                            value: equityPercentage,
                            title: '${equityPercentage.toStringAsFixed(0)}%',
                            color: Colors.green,
                            radius: 80,
                            titleStyle: TextWidget.textStyle(
                              theme: false,
                              color: Colors.white,
                              fontSize: 14,
                              fw: 2,
                            ),
                          ),
                        if (debtPercentage > 0)
                          PieChartSectionData(
                            value: debtPercentage,
                            title: '${debtPercentage.toStringAsFixed(0)}%',
                            color: Colors.pink,
                            radius: 80,
                            titleStyle: TextWidget.textStyle(
                              theme: false,
                              color: Colors.white,
                              fontSize: 14,
                              fw: 2,
                            ),
                          ),
                      ],
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (equityPercentage > 0)
                      _buildAllocationLegend('Equity', '${equityPercentage.toStringAsFixed(0)}%', Colors.green),
                    if (equityPercentage > 0 && debtPercentage > 0)
                      const SizedBox(height: 12),
                    if (debtPercentage > 0)
                      _buildAllocationLegend('Debt', '${debtPercentage.toStringAsFixed(0)}%', Colors.pink),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationLegend(String label, String percentage, Color color) {
    final theme = ref.watch(themeProvider);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        TextWidget.subText(
          text: '$label: $percentage',
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 0,
        ),
      ],
    );
  }

  Widget _buildTransactionsTable(PortfolioAnalysisModel data) {
    final theme = ref.watch(themeProvider);
    
    // Create sample transactions based on actual funds
    List<Map<String, String>> transactions = [];
    
    if (data.equity.isNotEmpty) {
      transactions.add({
        'fund': data.equity[0].schemaName,
        'date': '06 Sep 2022',
        'type': 'Buy',
        'units': '171.889',
        'nav': '191.8638'
      });
    }
    
    if (data.debt.isNotEmpty) {
      transactions.add({
        'fund': data.debt[0].schemaName,
        'date': '06 Sep 2022',
        'type': 'Buy',
        'units': '683.92',
        'nav': '48.2512'
      });
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Transactions',
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 1,
          ),
          const SizedBox(height: 20),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                ? colors.textSecondaryDark.withOpacity(0.05)
                : colors.textSecondaryLight.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextWidget.subText(
                    text: 'Fund',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Date',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Type',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'Units',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
                Expanded(
                  child: TextWidget.subText(
                    text: 'NAV',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ),
              ],
            ),
          ),
          // Transaction rows
          ...transactions.map((transaction) => _buildTransactionRow(
            transaction['fund']!,
            transaction['date']!,
            transaction['type']!,
            transaction['units']!,
            transaction['nav']!,
          )),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String fund, String date, String type, String units, String nav) {
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
            flex: 3,
            child: TextWidget.paraText(
              text: fund,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 0,
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: date,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextWidget.captionText(
                text: type,
                theme: false,
                color: Colors.green,
                fw: 1,
              ),
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: units,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          Expanded(
            child: TextWidget.paraText(
              text: nav,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
        ],
      ),
    );
  }
}