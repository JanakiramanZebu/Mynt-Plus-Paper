import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basket_backtest_analysis_model.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../../../provider/dashboard_provider.dart';
import '../../../../../routes/route_names.dart';
import '../../../../../sharedWidget/splash_loader.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';

class BenchMarkBacktestScreen extends ConsumerStatefulWidget {
  const BenchMarkBacktestScreen({super.key});

  @override
  ConsumerState<BenchMarkBacktestScreen> createState() =>
      _BenchMarkBacktestScreenState();
}

class _BenchMarkBacktestScreenState
    extends ConsumerState<BenchMarkBacktestScreen> {
  // Benchmark chart tooltip state
  FlSpot? benchmarkTouchedSpot;
  bool showBenchmarkTooltip = false;
  Timer? _hideBenchmarkTooltipTimer;

  @override
  void dispose() {
    _hideBenchmarkTooltipTimer?.cancel();
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
        leading: const CustomBackBtn(),
        elevation: 0.2,
        title: TextWidget.titleText(
          text: "Backtest Analysis",
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
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
            
            // Calculate XIRR difference
            final xirrDifference = data.total.xirr - data.benchmark.xirr;
            
            // Generate dynamic month labels for benchmark chart
            final months = _generateMonthLabelsFromDateTime(data.total.dateTime);
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         TextWidget.paraText(
                    text:
                        'Annualised return (XIRR) compared to ${data.benchmark.schemeName}',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 3,
                  ),
                  const SizedBox(height: 8),
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget.headText(
                        text:
                            '${xirrDifference.toStringAsFixed(2)}% ${xirrDifference >= 0 ? 'higher' : 'lower'}',
                        theme: theme.isDarkMode,
                        color: xirrDifference >= 0
                            ? (theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight)
                            : (theme.isDarkMode
                                ? colors.lossDark
                                : colors.lossLight),
                        fw: 1,
                      ),
                      // Custom tooltip positioned above chart
                    ],
                  ),
            
                  // Empty space for tooltip when not showing
                  if (!showBenchmarkTooltip || benchmarkTouchedSpot == null)
                    const SizedBox(width: 200), // Reserve space for tooltip
                  // const SizedBox(height: 20),
                  // Benchmark comparison chart
                  SizedBox(
                    height: 350,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              drawHorizontalLine: false,
                              getDrawingHorizontalLine: (value) =>
                                  const FlLine(
                                color: Color(0xFFE5E7EB),
                                strokeWidth: 0.1,
                                dashArray: [1, 1],
                              ),
                              horizontalInterval: 1,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() <
                                        data.total.chartData.length) {
                                      final dataIndex = value.toInt();
                                      final totalPoints =
                                          data.total.chartData.length;
                                      final labelInterval =
                                          (totalPoints / 6)
                                              .ceil()
                                              .clamp(1, totalPoints);
                    
                                      if (value.toInt() == 0 ||
                                          value.toInt() ==
                                              data.total.chartData.length -
                                                  1 ||
                                          value.toInt() % labelInterval ==
                                              0) {
                                        final monthLabel =
                                            _getMonthLabelForIndex(
                                                dataIndex,
                                                data.total.dateTime,
                                                months);
                                        if (monthLabel.isNotEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0),
                                            child: TextWidget.captionText(
                                              text: monthLabel,
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors
                                                      .textSecondaryLight,
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
                            maxX: (data.total.chartData.length - 1)
                                .toDouble(),
                            minY: _getMinYValue([
                              data.total.chartData,
                              data.benchmark.chartData
                            ]),
                            // Add consistent padding for all charts
                            clipData: const FlClipData.all(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems:
                                    (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots
                                      .map((spot) => null)
                                      .toList();
                                },
                              ),
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((spotIndex) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: barData.color ??
                                          const Color(0xFF3B82F6),
                                      strokeWidth: 2,
                                      dashArray: [5, 5],
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 6,
                                          color: barData.color ??
                                              const Color(0xFF3B82F6),
                                          strokeWidth: 3,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                  );
                                }).toList();
                              },
                              handleBuiltInTouches: true,
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? touchResponse) {
                                if (event is FlTapUpEvent ||
                                    event is FlPanUpdateEvent ||
                                    event is FlPanStartEvent ||
                                    event is FlTapDownEvent ||
                                    event is FlLongPressStart ||
                                    event is FlLongPressEnd ||
                                    event is FlLongPressMoveUpdate ||
                                    event is FlPanEndEvent) {
                                  if (touchResponse != null &&
                                      touchResponse.lineBarSpots != null &&
                                      touchResponse
                                          .lineBarSpots!.isNotEmpty) {
                                    final spot =
                                        touchResponse.lineBarSpots!.first;
                                    final index = spot.x.toInt();
                    
                                    if (index >= 0 &&
                                        index <
                                            data.total.chartData.length) {
                                      setState(() {
                                        benchmarkTouchedSpot =
                                            FlSpot(index.toDouble(), 0);
                                        showBenchmarkTooltip = true;
                                      });
                    
                                      // Only set auto-hide timer for tap events, not for continuous interactions
                                      if (event is FlTapUpEvent ||
                                          event is FlPanEndEvent ||
                                          event is FlLongPressEnd) {
                                        _hideBenchmarkTooltipTimer
                                            ?.cancel();
                                        _hideBenchmarkTooltipTimer = Timer(
                                            const Duration(seconds: 2), () {
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
                                        _hideBenchmarkTooltipTimer
                                            ?.cancel();
                                      }
                                    }
                                  }
                                } else if (event is FlPanEndEvent ||
                                    event is FlTapCancelEvent) {
                                  // Handle touch end/cancel events
                                  _hideBenchmarkTooltipTimer?.cancel();
                                  _hideBenchmarkTooltipTimer =
                                      Timer(const Duration(seconds: 2), () {
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
                                spots: data.benchmark.chartData
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(
                                        e.key.toDouble(), e.value / 1000))
                                    .toList(),
                                isCurved: true,
                                color: const Color(0xFF3B82F6),
                                barWidth: 2,
                                dotData: const FlDotData(show: false),
                              ),
                              // Your Strategy (green)
                              LineChartBarData(
                                spots: data.total.chartData
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(
                                        e.key.toDouble(), e.value / 1000))
                                    .toList(),
                                isCurved: true,
                                color: const Color(0xFF10B981),
                                barWidth: 2,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                        // Custom tooltip positioned as overlay
                        if (showBenchmarkTooltip &&
                            benchmarkTouchedSpot != null)
                          Positioned(
                            left: 0,
                            top: 10,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                          .withOpacity(0.2)
                                      : colors.textSecondaryLight
                                          .withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.4)
                                        : colors.textSecondaryLight
                                            .withOpacity(0.2),
                                    width: 0,
                                  ),
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final index =
                                        benchmarkTouchedSpot!.x.toInt();
                                    if (index >= 0 &&
                                        index <
                                            data.total.chartData.length) {
                                      final monthLabel =
                                          _getMonthLabelForIndex(index,
                                              data.total.dateTime, months);
                                      final benchmarkSpots = data
                                          .benchmark.chartData
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(
                                              e.key.toDouble(),
                                              e.value / 1000))
                                          .toList();
                                      final strategySpots = data
                                          .total.chartData
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(
                                              e.key.toDouble(),
                                              e.value / 1000))
                                          .toList();
                    
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              text:
                                                  '${data.benchmark.schemeName} ${benchmarkSpots[index].y.toStringAsFixed(2)}K',
                                              theme: theme.isDarkMode,
                                              color:
                                                  const Color(0xFF3B82F6),
                                              fw: 0,
                                            ),
                                          const SizedBox(height: 4),
                                          if (index < strategySpots.length)
                                            TextWidget.paraText(
                                              text:
                                                  'Your Strategy ${strategySpots[index].y.toStringAsFixed(2)}K',
                                              theme: theme.isDarkMode,
                                              color:
                                                  const Color(0xFF10B981),
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
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChartLegend('NIFTYBEES', const Color(0xFF3B82F6)),
                      const SizedBox(width: 20),
                      _buildChartLegend(
                          'Your Strategy', const Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 16),

                      ],
                    ),
                  ),
                 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // color: theme.isDarkMode
                      //     ? colors.primaryDark.withOpacity(0.05)
                      //     : colors.primaryLight.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.isDarkMode
                            ? colors.primaryDark.withOpacity(0.7)
                            : colors.primaryDark.withOpacity(0.7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget.subText(
                          text: 'Returns',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Current',
                                  '${strategy.analysisData!.total.currentValue}',
                                  theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme),
                            ),
                            // Vertical separator between Current and Invested
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark.withOpacity(0.2)
                                  : colors.textSecondaryLight
                                      .withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Invested',
                                  '${strategy.analysisData!.total.investmentAmount}',
                                  theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Gain',
                                  '${strategy.analysisData!.total.gain}',
                                  theme.isDarkMode
                                      ? colors.profitDark
                                      : colors.profitLight,
                                  theme),
                            ),
                            // Vertical separator between Gain and XIRR
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark.withOpacity(0.2)
                                  : colors.textSecondaryLight
                                      .withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'XIRR',
                                  '${strategy.analysisData!.total.xirr}',
                                  theme.isDarkMode
                                      ? colors.profitDark
                                      : colors.profitLight,
                                  theme),
                            ),
                            // Vertical separator between XIRR and Sharpe Ratio
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark.withOpacity(0.2)
                                  : colors.textSecondaryLight
                                      .withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Sharpe Ratio',
                                  '${strategy.analysisData!.total.sharpeRatio}',
                                  theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
            
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // color: theme.isDarkMode
                      //     ? colors.primaryDark.withOpacity(0.05)
                      //     : colors.primaryLight.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.isDarkMode
                            ? colors.primaryDark.withOpacity(0.7)
                            : colors.primaryDark.withOpacity(0.7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Risk heading
                        TextWidget.subText(
                          text: 'Risk',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Max Drawdown',
                                  '${strategy.analysisData!.total.maxDrawdown}',
                                  theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight,
                                  theme),
                            ),
                            // Vertical separator between Max Drawdown and Volatility
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark.withOpacity(0.2)
                                  : colors.textSecondaryLight
                                      .withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Volatility',
                                  '${strategy.analysisData!.total.volatility}',
                                  theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight,
                                  theme),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
            
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // color: theme.isDarkMode
                      //     ? colors.primaryDark.withOpacity(0.05)
                      //     : colors.primaryLight.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.isDarkMode
                            ? colors.primaryDark.withOpacity(0.7)
                            : colors.primaryDark.withOpacity(0.7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Risk heading
                        TextWidget.subText(
                          text: 'Inflation',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Original XIRR',
                                  '${strategy.analysisData!.total.xirr}%',
                                  theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight,
                                  theme),
                            ),
                            // Vertical separator between Max Drawdown and Volatility
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark.withOpacity(0.2)
                                  : colors.textSecondaryLight
                                      .withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildModernTaxComponent(
                                  'Inflation Adjusted XIRR',
                                  '${strategy.analysisData!.inflationAdjusted.xirr}%',
                                  theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight,
                                  theme),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTaxImplications(strategy.analysisData!),
                  const SizedBox(height: 16),
            
                  TextWidget.subText(
                    text: 'Benchmark Comparison',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 2,
                  ),
                  const SizedBox(height: 8),
            
                  _buildBenchmarkComparisonTable(strategy.analysisData!),
                  const SizedBox(height: 16),
                  TextWidget.subText(
                    text: 'Inflation Comparison',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 2,
                  ),
                  const SizedBox(height: 8),
                  _buildInflationComparisonTable(strategy.analysisData!),
                  const SizedBox(height: 16),
                      
                    ],
                  ) ,
                )



                 
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBenchmarkComparisonTable(PortfolioAnalysisModel data) {
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
            data.benchmark.schemeName,
            theme,
            yourColor: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            benchmarkColor: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
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
            benchmarkColor:
                theme.isDarkMode ? colors.lossDark : colors.lossLight,
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
            yourColor: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            benchmarkColor: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            isHeader: true,
          ),
          // Final Value row
          _buildThreeColumnDataRow(
            'Final Value',
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
            benchmarkColor:
                theme.isDarkMode ? colors.lossDark : colors.lossLight,
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

  String _formatNumber(double number) {
    if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  Widget _buildThreeColumnDataRow(String metric, String yourValue,
      String benchmarkValue, ThemesProvider theme,
      {Color? yourColor, Color? benchmarkColor, bool isHeader = false}) {
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
                        color: yourColor ??
                            (theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight),
                        fw: 1,
                        align: TextAlign.center,
                      )
                    : TextWidget.subText(
                        text: yourValue,
                        theme: false,
                        color: yourColor ??
                            (theme.isDarkMode
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
                        color: benchmarkColor ??
                            (theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight),
                        fw: 1,
                        align: TextAlign.center,
                      )
                    : TextWidget.subText(
                        text: benchmarkValue,
                        theme: false,
                        color: benchmarkColor ??
                            (theme.isDarkMode
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.isDarkMode
                    ? colors.primaryDark.withOpacity(0.7)
                    : colors.primaryDark.withOpacity(0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.subText(
                  text: 'Tax Implications',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildModernTaxComponent(
                        'Gain',
                        '$totalGains',
                        theme.isDarkMode
                            ? colors.profitDark
                            : colors.profitLight,
                        theme),
                    Icon(
                      Icons.remove,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      size: 16,
                    ),
                    _buildModernTaxComponent(
                        'Tax',
                        '$totalTax',
                        theme.isDarkMode ? colors.lossDark : colors.lossLight,
                        theme),
                    Icon(
                      Icons.drag_handle,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      size: 16,
                    ),
                    _buildModernTaxComponent(
                        'Post Tax',
                        '$postTaxGains',
                        theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme),
                  ],
                ),
                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernTaxComponent(
                          'Short Term Gain Tax',
                          '${data.taxDetails.equity.tax}',
                          theme.isDarkMode
                              ? colors.profitDark
                              : colors.profitLight,
                          theme),
                    ),
                    // Vertical separator between Short Term and Long Term
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark.withOpacity(0.2)
                          : colors.textSecondaryLight.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildModernTaxComponent(
                          'Long Term Gain Tax',
                          '${data.taxDetails.debt.tax}',
                          theme.isDarkMode
                              ? colors.profitDark
                              : colors.profitLight,
                          theme),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextWidget.captionText(
                      text: '*calculated using 30% tax slab',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ],
                ),
                // const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTaxComponent(
      String label, String value, Color color, ThemesProvider theme) {
    return Column(
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        TextWidget.subText(
          text: value,
          theme: theme.isDarkMode,
          color: color,
          fw: 1,
        ),
      ],
    );
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

  Widget _buildPerformanceMetric(
      String label, String value, Color valueColor, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
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
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
            TextWidget.paraText(
              text: value,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to generate month labels from DateTime list
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
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };

    final month = monthMap[monthAbbr] ?? 1;
    return DateTime(int.parse(year), month);
  }

  // Helper method to get month label for a specific data point index
  String _getMonthLabelForIndex(
      int index, List<String> dateTimeList, List<String> months) {
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
              (currentDate.difference(monthDate).abs() <
                  currentDate.difference(closestDate).abs())) {
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
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
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
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
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
    final adjustedMinY =
        (minYInThousands - padding).clamp(0.0, minYInThousands);

    return adjustedMinY;
  }
}
