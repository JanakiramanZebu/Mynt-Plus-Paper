import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';
import '../../../../provider/dashboard_provider.dart';
import '../../../../models/explore_model/portfolioanalisys_models.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider).getPortfolioAnalysis();
    });
  }

  Timer? _hideTooltipTimer;

  @override
  void dispose() {
    _hideTooltipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final portfolio = ref.watch(dashboardProvider);
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
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
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
            text: "Portfolio Dashboard",
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
    );
  }

  Widget _buildDashboardContentWithStickyHeader(PortfolioResponse data) {
    final theme = ref.watch(themeProvider);

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(
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
          // Sticky Header for Top Stocks
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: _StickyHeaderDelegate(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.titleText(
                      text: 'Top Stocks',
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: _buildTopStocksScrollableList(data.topStocks),
    );
  }

  Widget _buildTopStocksScrollableList(List<TopStocks> topStocks) {
    final theme = ref.watch(themeProvider);

    if (topStocks.isEmpty) return const SizedBox.shrink();

    final validFundamentals = topStocks.toList();

    return Container(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  TextWidget.titleText(
                    text: 'Portfolio Summary',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
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
                                ? colors.successDark
                                : colors.successLight,
                    fw: 1,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.colorBlack.withOpacity(0.95)
                        : colors.colorWhite.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark.withOpacity(0.3)
                          : colors.textSecondaryLight.withOpacity(0.3),
                      width: 1,
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
                            TextWidget.paraText(
                              text: _formatDate(chartData.dates[index]),
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 3,
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
                          final labelInterval = (totalPoints / 6)
                              .ceil()
                              .clamp(1, totalPoints);

                          if (value.toInt() == 0 ||
                              value.toInt() == investedSpots.length - 1 ||
                              value.toInt() % labelInterval == 0) {
                            final dateString = chartData.dates[dataIndex];

                            try {
                              final date = DateTime.parse(dateString);
                              final month = portfolio
                                  .getMonthAbbreviation(date.month);
                              final year =
                                  date.year.toString().substring(2);

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
                                  fw: 3,
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
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    // Handle different touch events
                    if (event is FlTapUpEvent || 
                        event is FlPanUpdateEvent || 
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent) {
                      
                      if (touchResponse != null && touchResponse.lineBarSpots != null) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final index = spot.x.toInt();
                        
                        if (index >= 0 && index < chartData.dates.length) {
                          setState(() {
                            touchedSpot = FlSpot(index.toDouble(), 0);
                            showTooltip = true;
                          });
                          
                          // Auto-hide tooltip after 2 seconds
                          _hideTooltipTimer?.cancel();
                          _hideTooltipTimer = Timer(const Duration(seconds: 2), () {
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
          fw: 3,
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
              TextWidget.titleText(
                text: 'Account Allocation',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
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
      padding: const EdgeInsets.all(16),
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
                  fw: 3,
                ),
                const SizedBox(height: 4),
                TextWidget.captionText(
                  text: '${percentage.toStringAsFixed(2)}% of portfolio',
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 3,
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
              TextWidget.titleText(
                text: 'Market Cap Allocation',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
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
              TextWidget.titleText(
                text: 'Sector Allocation',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
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
  }) {
    final theme = ref.watch(themeProvider);
    final performanceColor =
        ref.watch(dashboardProvider).getMarketCapColor(marketCapType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextWidget.subText(
                  text: sector,
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextWidget.paraText(
                  text: '${marketCapType}',
                  theme: false,
                  color: performanceColor,
                  fw: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: '${exch}',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
              TextWidget.subText(
                text: '${allocationPercent.toStringAsFixed(2)}%',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Value and Allocation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: '₹ ${value.toStringAsFixed(2)}',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
              TextWidget.subText(
                text: '${qty}',
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
            ],
          ),
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
            child: TextWidget.paraText(
              text: marketCapType,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          TextWidget.paraText(
            text: '${percentage.toStringAsFixed(2)}%',
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 3,
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
                left: entry == entries.first ? Radius.circular(8) : Radius.zero,
                right: entry == entries.last ? Radius.circular(8) : Radius.zero,
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
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          TextWidget.paraText(
            text: '${percentage.toStringAsFixed(2)}%',
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 3,
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
}

// Sticky Header Delegate Class
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
