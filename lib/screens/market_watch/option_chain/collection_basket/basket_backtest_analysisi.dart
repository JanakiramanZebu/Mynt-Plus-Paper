import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basket_backtest_analysis_model.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';

import '../../../../provider/dashboard_provider.dart';
import '../../../../sharedWidget/custom_back_btn.dart';

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
        leading: const CustomBackBtn(),
        title: TextWidget.titleText(
          text: "Basket Backtest Analysis",
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 1,
        ),
        // actions: [
        //   // Action buttons similar to portfolio analysis
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         _buildActionButton(
        //           icon: Icons.share_outlined,
        //           onTap: () => _shareAnalysis(),
        //           theme: theme,
        //         ),
        //         const SizedBox(width: 8),
        //         _buildActionButton(
        //           icon: Icons.more_vert,
        //           onTap: () => _showMoreOptions(),
        //           theme: theme,
        //         ),
        //       ],
        //     ),
        //   ),
        // ],
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
                const SizedBox(height: 16),
                _buildTransactionsTable(data),
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

  Widget _buildModernPortfolioSummary(PortfolioTotal data, ThemesProvider theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
       
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.isDarkMode 
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    text: 'Final Value',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 8),
                  TextWidget.titleText(
                    text: '${data.currentValue}',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: data.gain >= 0 
                        ? (theme.isDarkMode ? colors.profitDark.withOpacity(0.2) : colors.profitLight.withOpacity(0.2))
                        : (theme.isDarkMode ? colors.lossDark.withOpacity(0.2) : colors.lossLight.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextWidget.paraText(
                      text: '${data.gainPerc}%',
                      theme: theme.isDarkMode,
                      color: data.gain >= 0 
                        ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
                        : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
                      fw: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextWidget.captionText(
                    text: 'Total Return',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fw: 0,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode 
          ? colors.textSecondaryDark.withOpacity(0.05)
          : colors.textSecondaryLight.withOpacity(0.05),
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
          TextWidget.captionText(
            text: label,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 0,
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
    return Row(
      children: [
        Expanded(
          child: _buildStatsCard(
            'Sharpe Ratio',
            data.total.sharpeRatio.toStringAsFixed(2),
            Icons.trending_up,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatsCard(
            'Volatility',
            '${data.total.volatility.toStringAsFixed(2)}%',
            Icons.speed,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatsCard(
            'Max Drawdown',
            '${data.total.maxDrawdown.toStringAsFixed(2)}%',
            Icons.trending_down,
            theme,
            valueColor: data.total.maxDrawdown < 0 
              ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
              : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String label, String value, IconData icon, ThemesProvider theme, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextWidget.captionText(
                  text: label,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 0,
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
                '₹${data.currentValue}',
                theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              ),
              _buildMetricColumn(
                'Invested Amount', 
                '₹${data.investmentAmount}',
                theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
              _buildMetricColumn(
                'Gain', 
                '₹${data.gain} (${data.gainPerc}%)',
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
                  _buildReturnMetric('XIRR', '${data.xirr.toStringAsFixed(2)}%', data.xirr >= 0 ? theme.isDarkMode ? colors.profitDark : colors.profitLight : theme.isDarkMode ? colors.lossDark : colors.lossLight),
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

    // Generate dynamic month labels based on chart data length
    final months = _generateMonthLabels(data.total.chartData.length);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // borderRadius: BorderRadius.circular(16),
        // border: Border.all(
        //   color: theme.isDarkMode 
        //     ? colors.textSecondaryDark.withOpacity(0.1)
        //     : colors.textSecondaryLight.withOpacity(0.1),
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: theme.isDarkMode 
        //       ? Colors.black.withOpacity(0.2)
        //       : Colors.grey.withOpacity(0.1),
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
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
              
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.isDarkMode 
                      ? colors.textSecondaryDark.withOpacity(0.1)
                      : colors.textSecondaryLight.withOpacity(0.1),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = (value / (totalSpots.length / months.length)).round();
                        if (index >= 0 && index < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextWidget.captionText(
                              text: months[index],
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                              fw: 0,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Equity line (modern blue)
                  if (equitySpots.isNotEmpty)
                    LineChartBarData(
                      spots: equitySpots,
                      isCurved: true,
                      color: const Color(0xFF3B82F6),
                      barWidth: 0,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                      ),
                    ),
                  // Debt line (modern purple)
                  if (debtSpots.isNotEmpty)
                    LineChartBarData(
                      spots: debtSpots,
                      isCurved: true,
                      color: const Color(0xFF8B5CF6),
                      barWidth: 0,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      ),
                    ),
                  // Total portfolio line (modern green)
                  LineChartBarData(
                    spots: totalSpots,
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    shadow: Shadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
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
                 
                  const SizedBox(height: 4),
                  TextWidget.subText(
                    text: 'Total: ₹${data.total.currentValue }',
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
                        _buildLegendItem('Equity', '₹${data.equity[0].currentValue }', const Color(0xFF3B82F6)),
                      const SizedBox(width: 16),
                      if (data.debt.isNotEmpty)
                        _buildLegendItem('Hybrid', '₹${data.debt[0].currentValue }', const Color(0xFF8B5CF6)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Asset class performance table
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
    
    // Generate dynamic month labels for benchmark chart
    final months = _generateMonthLabels(data.total.chartData.length);
    
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
            '₹${data.total.currentValue }',
            '₹${data.total.gain }',
            data.total.sharpeRatio.toStringAsFixed(1),
            '${data.total.maxDrawdown.toStringAsFixed(2)}%',
            '${data.total.xirr.toStringAsFixed(2)}%',
            Colors.green,
          ),
          // Benchmark row
          _buildComparisonRow(
            data.benchmark.schemeName, 
            '₹${data.benchmark.currentValue }',
            '₹${data.benchmark.gain }',
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
    
    // Generate dynamic month labels for inflation chart
    final months = _generateMonthLabels(data.total.chartData.length);
    
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
              _buildTaxComponent('Total Gains', '₹${totalGains }', Colors.green),
              Icon(Icons.remove, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
              _buildTaxComponent('Total Tax', '₹${totalTax }', Colors.red),
              Icon(Icons.drag_handle, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
              _buildTaxComponent('Post Tax Gains', '₹${postTaxGains }', Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          // Tax breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTaxBreakdown('Short Term Capital Gains Tax', '₹${equityTax }'),
              _buildTaxBreakdown('Long Term Capital Gains Tax', '₹${debtTax }'),
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

  // Widget _buildAssetAllocation(PortfolioAnalysisModel data) {
  //   final theme = ref.watch(themeProvider);
    
  //   // Calculate percentages based on actual data
  //   final equityPercentage = data.equity.isNotEmpty 
  //     ? (data.equity[0].currentValue / data.total.currentValue) * 100
  //     : 0.0;
  //   final debtPercentage = data.debt.isNotEmpty 
  //     ? (data.debt[0].currentValue / data.total.currentValue) * 100
  //     : 0.0;
    
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: theme.isDarkMode 
  //           ? colors.textSecondaryDark.withOpacity(0.1)
  //           : colors.textSecondaryLight.withOpacity(0.1),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: theme.isDarkMode 
  //             ? Colors.black.withOpacity(0.2)
  //             : Colors.grey.withOpacity(0.1),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         TextWidget.subText(
  //           text: 'Asset Allocation',
  //           theme: theme.isDarkMode,
  //           color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
  //           fw: 1,
  //         ),
  //         const SizedBox(height: 20),
  //         // Pie chart showing allocation
  //         SizedBox(
  //           height: 200,
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: PieChart(
  //                   PieChartData(
  //                     sections: [
  //                       if (equityPercentage > 0)
  //                         PieChartSectionData(
  //                           value: equityPercentage,
  //                           title: '${equityPercentage.toStringAsFixed(0)}%',
  //                           color: const Color(0xFF3B82F6),
  //                           radius: 80,
  //                           titleStyle: TextWidget.textStyle(
  //                             theme: false,
  //                             color: Colors.white,
  //                             fontSize: 14,
  //                             fw: 2,
  //                           ),
  //                         ),
  //                       if (debtPercentage > 0)
  //                         PieChartSectionData(
  //                           value: debtPercentage,
  //                           title: '${debtPercentage.toStringAsFixed(0)}%',
  //                           color: const Color(0xFF8B5CF6),
  //                           radius: 80,
  //                           titleStyle: TextWidget.textStyle(
  //                             theme: false,
  //                             color: Colors.white,
  //                             fontSize: 14,
  //                             fw: 2,
  //                           ),
  //                         ),
  //                     ],
  //                     centerSpaceRadius: 40,
  //                     sectionsSpace: 2,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 20),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   if (equityPercentage > 0)
  //                     _buildAllocationLegend('Equity', '${equityPercentage.toStringAsFixed(0)}%', const Color(0xFF3B82F6)),
  //                   if (equityPercentage > 0 && debtPercentage > 0)
  //                     const SizedBox(height: 12),
  //                   if (debtPercentage > 0)
  //                     _buildAllocationLegend('Debt', '${debtPercentage.toStringAsFixed(0)}%', const Color(0xFF8B5CF6)),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
    
    // Create transactions based on actual funds from API data
    List<Map<String, String>> transactions = [];
    
    if (data.equity.isNotEmpty) {
      final equityFund = data.equity[0];
      final units = (equityFund.investmentAmount / (equityFund.chartData.isNotEmpty ? equityFund.chartData[0] : 1)).toStringAsFixed(3);
      final nav = equityFund.chartData.isNotEmpty ? equityFund.chartData[0].toStringAsFixed(4) : '0.0000';
      
      transactions.add({
        'fund': equityFund.schemaName,
        'date': _getInvestmentStartDate(data.total.chartData.length),
        'type': 'Buy',
        'units': units,
        'nav': nav
      });
    }
    
    if (data.debt.isNotEmpty) {
      final debtFund = data.debt[0];
      final units = (debtFund.investmentAmount / (debtFund.chartData.isNotEmpty ? debtFund.chartData[0] : 1)).toStringAsFixed(3);
      final nav = debtFund.chartData.isNotEmpty ? debtFund.chartData[0].toStringAsFixed(4) : '0.0000';
      
      transactions.add({
        'fund': debtFund.schemaName,
        'date': _getInvestmentStartDate(data.total.chartData.length),
        'type': 'Buy',
        'units': units,
        'nav': nav
      });
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.textSecondaryLight.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.isDarkMode 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextWidget.captionText(
                text: type,
                theme: false,
                color: const Color(0xFF10B981),
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
}