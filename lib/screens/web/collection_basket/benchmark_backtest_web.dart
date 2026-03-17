import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mynt_plus/models/explore_model/basket_backtest_analysis_model.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../provider/dashboard_provider.dart';
import '../../../../sharedWidget/mynt_loader.dart';

class BenchMarkBacktestScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCustomize;

  const BenchMarkBacktestScreenWeb({
    super.key,
    this.onBack,
    this.onCustomize,
  });

  @override
  ConsumerState<BenchMarkBacktestScreenWeb> createState() =>
      _BenchMarkBacktestScreenState();
}

class _BenchMarkBacktestScreenState
    extends ConsumerState<BenchMarkBacktestScreenWeb> {
  @override
  Widget build(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor),
      body: Consumer(
        builder: (context, ref, child) {
          if (strategy.isStrategyLoading) {
            return Center(
              child: Container(
                color: resolveThemeColor(context,
                    dark: MyntColors.backgroundColorDark,
                    light: MyntColors.backgroundColor),
                child: MyntLoader.branded(),
              ),
            );
          }

          if (strategy.analysisData == null) {
            return const Center(
              child: NoDataFound(),
            );
          }

          final data = strategy.analysisData!;
          final xirrDifference = data.total.xirr - data.benchmark.xirr;

          // Build chart data points
          final int chartLength = data.total.chartData.length;
          final chartPoints = List.generate(chartLength, (index) {
            DateTime dateTime;
            try {
              dateTime = DateTime.parse(data.total.dateTime[index]);
            } catch (e) {
              dateTime = DateTime.now();
            }
            final benchmarkVal = index < data.benchmark.chartData.length
                ? data.benchmark.chartData[index] / 1000
                : 0.0;
            final strategyVal = data.total.chartData[index] / 1000;
            return _BacktestChartPoint(dateTime, benchmarkVal, strategyVal);
          });

          // Dynamic x-axis interval - calculated inside LayoutBuilder below
          String xAxisDateFormat = 'MMM yy';
          int totalMonths = 0;
          if (chartPoints.length >= 2) {
            totalMonths = (chartPoints.last.date.year - chartPoints.first.date.year) * 12 +
                (chartPoints.last.date.month - chartPoints.first.date.month);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customize button row
                if (strategy.showcustomButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () => _navigateToCustomizeStrategy(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Customize',
                                style: MyntWebTextStyles.body(context,
                                    fontWeight: MyntFonts.semiBold,
                                    color: MyntColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: resolveThemeColor(context,
                          dark: MyntColors.backgroundColorDark,
                          light: MyntColors.backgroundColor),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: resolveThemeColor(context,
                            dark: MyntColors.dividerDark,
                            light: MyntColors.divider),
                        width: 1,
                      ),
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annualised return (XIRR) compared to ${_toTitleCase(data.benchmark.schemeName)}',
                        style: MyntWebTextStyles.para(context,
                            fontWeight: MyntFonts.medium,
                            darkColor: MyntColors.textSecondaryDark,
                            lightColor: MyntColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${xirrDifference.toStringAsFixed(2)}% ${xirrDifference >= 0 ? 'higher' : 'lower'}',
                            style: MyntWebTextStyles.head(context,
                                fontWeight: MyntFonts.semiBold,
                                color: xirrDifference >= 0
                                    ? resolveThemeColor(context,
                                        dark: MyntColors.profitDark,
                                        light: MyntColors.profit)
                                    : resolveThemeColor(context,
                                        dark: MyntColors.lossDark,
                                        light: MyntColors.loss)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate interval based on actual chart container width
                          final chartWidth = constraints.maxWidth;
                          int xAxisInterval = 2;
                          if (totalMonths <= 6) {
                            xAxisInterval = chartWidth < 500 ? 2 : 1;
                          } else if (totalMonths <= 12) {
                            xAxisInterval = chartWidth < 500 ? 3 : 2;
                          } else if (totalMonths <= 24) {
                            xAxisInterval = chartWidth < 500 ? 5 : 3;
                          } else if (totalMonths <= 36) {
                            xAxisInterval = chartWidth < 500 ? 8 : 4;
                          } else {
                            xAxisInterval = chartWidth < 500 ? 12 : 6;
                          }
                          return SizedBox(
                        height: 350,
                        width: double.infinity,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          primaryXAxis: DateTimeAxis(
                            isVisible: true,
                            majorGridLines: const MajorGridLines(width: 0),
                            axisLine: const AxisLine(width: 0),
                            labelStyle: MyntWebTextStyles.caption(
                              context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                              fontWeight: FontWeight.w400,
                            ),
                            labelRotation: 0,
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            intervalType: DateTimeIntervalType.months,
                            interval: xAxisInterval.toDouble(),
                            dateFormat: DateFormat(xAxisDateFormat),
                            minimum: chartPoints.isNotEmpty ? chartPoints.first.date : null,
                            maximum: chartPoints.isNotEmpty
                                ? DateTime(chartPoints.last.date.year, chartPoints.last.date.month + 1, 1)
                                : null,
                          ),
                          primaryYAxis: const NumericAxis(
                            isVisible: false,
                            majorGridLines: MajorGridLines(width: 0),
                          ),
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            activationMode: ActivationMode.singleTap,
                            tooltipPosition: TooltipPosition.auto,
                            canShowMarker: true,
                            shouldAlwaysShow: false,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.listItemBgDark,
                              light: MyntColors.backgroundColor,
                            ),
                            borderColor: resolveThemeColor(
                              context,
                              dark: MyntColors.dividerDark,
                              light: MyntColors.divider,
                            ),
                            borderWidth: 1,
                            textStyle: MyntWebTextStyles.para(
                              context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                              fontWeight: FontWeight.w500,
                            ),
                            builder: (dynamic d, dynamic point, dynamic series,
                                int pointIndex, int seriesIndex) {
                              if (pointIndex >= chartPoints.length) {
                                return const SizedBox.shrink();
                              }
                              final cp = chartPoints[pointIndex];
                              final dateLabel = DateFormat('dd/MM/yyyy').format(cp.date);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: resolveThemeColor(
                                    context,
                                    dark: MyntColors.listItemBgDark,
                                    light: MyntColors.backgroundColor,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: resolveThemeColor(
                                      context,
                                      dark: MyntColors.dividerDark,
                                      light: MyntColors.divider,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateLabel,
                                      style: MyntWebTextStyles.caption(
                                        context,
                                        color: resolveThemeColor(context,
                                            dark: MyntColors.textSecondaryDark,
                                            light: MyntColors.textSecondary),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_toTitleCase(data.benchmark.schemeName)}: ',
                                          style: MyntWebTextStyles.para(
                                            context,
                                            color: resolveThemeColor(context,
                                                dark: MyntColors.textPrimaryDark,
                                                light: MyntColors.textPrimary),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${cp.benchmark.toStringAsFixed(2)}K',
                                          style: MyntWebTextStyles.para(
                                            context,
                                            color: resolveThemeColor(context,
                                                dark: MyntColors.textPrimaryDark,
                                                light: MyntColors.textPrimary),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Your Strategy: ',
                                          style: MyntWebTextStyles.para(
                                            context,
                                            color: resolveThemeColor(context,
                                                dark: MyntColors.textPrimaryDark,
                                                light: MyntColors.textPrimary),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${cp.strategy.toStringAsFixed(2)}K',
                                          style: MyntWebTextStyles.para(
                                            context,
                                            color: resolveThemeColor(context,
                                                dark: MyntColors.textPrimaryDark,
                                                light: MyntColors.textPrimary),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          trackballBehavior: TrackballBehavior(
                            enable: true,
                            activationMode: ActivationMode.singleTap,
                            lineType: TrackballLineType.vertical,
                            lineColor: resolveThemeColor(
                              context,
                              dark: const Color(0xFF9CA3AF),
                              light: const Color(0xFF6B7280),
                            ),
                            lineDashArray: const <double>[4, 4],
                            lineWidth: 1,
                            tooltipSettings:
                                const InteractiveTooltip(enable: false),
                            hideDelay: 2000,
                            markerSettings: TrackballMarkerSettings(
                              markerVisibility:
                                  TrackballVisibilityMode.visible,
                              height: 10,
                              width: 10,
                              borderWidth: 2,
                              borderColor: resolveThemeColor(
                                context,
                                dark: Colors.white,
                                light: const Color(0xFF1F2937),
                              ),
                            ),
                            tooltipDisplayMode:
                                TrackballDisplayMode.groupAllPoints,
                            builder: (BuildContext context,
                                TrackballDetails trackballDetails) {
                              final groupingDetails =
                                  trackballDetails.groupingModeInfo;
                              if (groupingDetails == null ||
                                  groupingDetails.points.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final pointIndex = groupingDetails
                                      .currentPointIndices.isNotEmpty
                                  ? groupingDetails.currentPointIndices.first
                                  : 0;
                              if (pointIndex >= chartPoints.length) {
                                return const SizedBox.shrink();
                              }
                              final cp = chartPoints[pointIndex];
                              final dateLabel =
                                  DateFormat('dd/MM/yyyy').format(cp.date);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: resolveThemeColor(
                                    this.context,
                                    dark: MyntColors.listItemBgDark,
                                    light: MyntColors.backgroundColor,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: resolveThemeColor(
                                      this.context,
                                      dark: MyntColors.dividerDark,
                                      light: MyntColors.divider,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateLabel,
                                      style: MyntWebTextStyles.caption(
                                        this.context,
                                        color: resolveThemeColor(
                                            this.context,
                                            dark: MyntColors
                                                .textSecondaryDark,
                                            light:
                                                MyntColors.textSecondary),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_toTitleCase(data.benchmark.schemeName)}: ',
                                          style: MyntWebTextStyles.para(
                                            this.context,
                                            color: resolveThemeColor(
                                                this.context,
                                                dark: MyntColors
                                                    .textPrimaryDark,
                                                light: MyntColors
                                                    .textPrimary),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${cp.benchmark.toStringAsFixed(2)}K',
                                          style: MyntWebTextStyles.para(
                                            this.context,
                                            color: resolveThemeColor(this.context,
                                                dark: MyntColors.textPrimaryDark,
                                                light: MyntColors.textPrimary),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Your Strategy: ',
                                          style: MyntWebTextStyles.para(
                                            this.context,
                                            color: resolveThemeColor(
                                                this.context,
                                                dark: MyntColors
                                                    .textPrimaryDark,
                                                light: MyntColors
                                                    .textPrimary),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${cp.strategy.toStringAsFixed(2)}K',
                                          style: MyntWebTextStyles.para(
                                            this.context,
                                            color: resolveThemeColor(this.context,
                                                dark: MyntColors.textPrimaryDark,
                                                light: MyntColors.textPrimary),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          series: <CartesianSeries>[
                            SplineSeries<_BacktestChartPoint, DateTime>(
                              dataSource: chartPoints,
                              xValueMapper:
                                  (_BacktestChartPoint d, _) => d.date,
                              yValueMapper:
                                  (_BacktestChartPoint d, _) => d.benchmark,
                              name: _toTitleCase(_toTitleCase(data.benchmark.schemeName)),
                              color: const Color(0xFF6366F1),
                              width: 1.5,
                              markerSettings: const MarkerSettings(
                                isVisible: false,
                              ),
                              enableTooltip: true,
                            ),
                            SplineSeries<_BacktestChartPoint, DateTime>(
                              dataSource: chartPoints,
                              xValueMapper:
                                  (_BacktestChartPoint d, _) => d.date,
                              yValueMapper:
                                  (_BacktestChartPoint d, _) => d.strategy,
                              name: 'Your Strategy',
                              color: const Color(0xFFF59E0B),
                              width: 1.5,
                              markerSettings: const MarkerSettings(
                                isVisible: false,
                              ),
                              enableTooltip: true,
                            ),
                          ],
                          ),
                        );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildChartLegend(
                                _toTitleCase(data.benchmark.schemeName), const Color(0xFF6366F1)),
                            const SizedBox(width: 20),
                            _buildChartLegend(
                                'Your Strategy', const Color(0xFFF59E0B)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Returns section (Key Indicators style - single card)
                      _buildSectionContainer(
                        context,
                        title: 'Returns',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIndicatorRow(
                              context,
                              'INVESTED',
                              _formatNumber(data.total.investmentAmount),
                              'CURRENT',
                              _formatNumber(data.total.currentValue),
                              'GAIN',
                              _formatNumber(data.total.gain),
                              valueColor3: _getPnlColor(data.total.gain),
                            ),
                            const SizedBox(height: 14),
                            _buildIndicatorRow(
                              context,
                              'XIRR',
                              '${data.total.xirr}',
                              'SHARPE RATIO',
                              '${data.total.sharpeRatio}',
                              '',
                              '',
                              valueColor1: _getPnlColor(data.total.xirr),
                            ),
                            const SizedBox(height: 20),
                            // Risk sub-section
                            _buildSubSectionHeader('Risk'),
                            const SizedBox(height: 12),
                            _buildIndicatorRow(
                              context,
                              'MAX DRAWDOWN',
                              '${data.total.maxDrawdown}',
                              'VOLATILITY',
                              '${data.total.volatility}',
                              '',
                              '',
                              valueColor1: resolveThemeColor(context,
                                  dark: MyntColors.lossDark,
                                  light: MyntColors.loss),
                              valueColor2: resolveThemeColor(context,
                                  dark: MyntColors.lossDark,
                                  light: MyntColors.loss),
                            ),
                            const SizedBox(height: 20),
                            // Inflation sub-section
                            _buildSubSectionHeader('Inflation'),
                            const SizedBox(height: 12),
                            _buildIndicatorRow(
                              context,
                              'ORIGINAL XIRR',
                              '${data.total.xirr}%',
                              'INFLATION ADJUSTED XIRR',
                              '${data.inflationAdjusted.xirr}%',
                              '',
                              '',
                              valueColor1: _getPnlColor(data.total.xirr),
                              valueColor2: _getPnlColor(data.inflationAdjusted.xirr),
                            ),
                            const SizedBox(height: 20),
                            // Tax sub-section
                            _buildSubSectionHeader('Tax Implications'),
                            const SizedBox(height: 12),
                            _buildTaxContent(data, context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Benchmark Comparison',
                        style: MyntWebTextStyles.body(context,
                            fontWeight: MyntFonts.semiBold,
                            darkColor: MyntColors.textPrimaryDark,
                            lightColor: MyntColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      _buildBenchmarkComparisonTable(data, context),
                      const SizedBox(height: 16),

                      Text(
                        'Inflation Comparison',
                        style: MyntWebTextStyles.body(context,
                            fontWeight: MyntFonts.semiBold,
                            darkColor: MyntColors.textPrimaryDark,
                            lightColor: MyntColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      _buildInflationComparisonTable(data, context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolveThemeColor(context, dark: MyntColors.dividerDark, light: MyntColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MyntWebTextStyles.body(context,
                fontWeight: MyntFonts.semiBold,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildVerticalSeparator(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: resolveThemeColor(context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary)
          .withOpacity(isDarkMode(context) ? 0.2 : 0.3),
    );
  }

  Widget _buildMetricItem(
      String label, String value, Color color, BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: MyntWebTextStyles.para(context,
              fontWeight: MyntFonts.medium,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: MyntWebTextStyles.body(context,
              fontWeight: MyntFonts.medium, color: color),
        ),
      ],
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Text(
      title,
      style: MyntWebTextStyles.body(context,
          fontWeight: MyntFonts.semiBold,
          darkColor: MyntColors.textPrimaryDark,
          lightColor: MyntColors.textPrimary),
    );
  }

  Widget _buildIndicatorRow(
    BuildContext context,
    String title1, String value1,
    String title2, String value2,
    String title3, String value3, {
    Color? valueColor1,
    Color? valueColor2,
    Color? valueColor3,
  }) {
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);
    final labelColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final defaultValueColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);

    Widget buildItem(String title, String value, {Color? color}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: MyntWebTextStyles.para(context, color: labelColor),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: MyntWebTextStyles.body(context,
                  fontWeight: MyntFonts.medium,
                  color: color ?? defaultValueColor),
            ),
            const SizedBox(height: 2),
            Divider(color: dividerColor),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildItem(title1, value1, color: valueColor1),
        if (title2.isNotEmpty) ...[
          const SizedBox(width: 18),
          buildItem(title2, value2, color: valueColor2),
        ],
        const SizedBox(width: 18),
        if (title3.isNotEmpty)
          buildItem(title3, value3, color: valueColor3)
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildBenchmarkComparisonTable(
      PortfolioAnalysisModel data, BuildContext context) {
    final defaultColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);

    final benchmarkRows = [
      _ComparisonRow(
        metric: 'Current',
        yourValue: _formatNumber(data.total.currentValue),
        otherValue: _formatNumber(data.benchmark.currentValue),
        yourColor: defaultColor,
        otherColor: defaultColor,
      ),
      _ComparisonRow(
        metric: 'Gain',
        yourValue: _formatNumber(data.total.gain),
        otherValue: _formatNumber(data.benchmark.gain),
        yourColor: _getPnlColor(data.total.gain),
        otherColor: _getPnlColor(data.benchmark.gain),
      ),
      _ComparisonRow(
        metric: 'Sharpe Ratio',
        yourValue: data.total.sharpeRatio.toStringAsFixed(2),
        otherValue: data.benchmark.sharpeRatio.toStringAsFixed(2),
        yourColor: defaultColor,
        otherColor: defaultColor,
      ),
      _ComparisonRow(
        metric: 'Max Drawdown',
        yourValue: '${data.total.maxDrawdown.toStringAsFixed(2)}%',
        otherValue: '${data.benchmark.maxDrawdown.toStringAsFixed(2)}%',
        yourColor: resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss),
        otherColor: resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss),
      ),
      _ComparisonRow(
        metric: 'XIRR',
        yourValue: '${data.total.xirr.toStringAsFixed(2)}%',
        otherValue: '${data.benchmark.xirr.toStringAsFixed(2)}%',
        yourColor: _getPnlColor(data.total.xirr),
        otherColor: _getPnlColor(data.benchmark.xirr),
      ),
    ];

    return _buildShadcnComparisonTable(
      context: context,
      col1Header: 'Metric',
      col2Header: 'Your Strategy',
      col3Header: _toTitleCase(data.benchmark.schemeName),
      rows: benchmarkRows,
    );
  }

  Widget _buildInflationComparisonTable(
      PortfolioAnalysisModel data, BuildContext context) {
    final defaultColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);

    final inflationRows = [
      _ComparisonRow(
        metric: 'Final Value',
        yourValue: _formatNumber(data.total.currentValue),
        otherValue: _formatNumber(data.inflationAdjusted.finalValue),
        yourColor: defaultColor,
        otherColor: defaultColor,
      ),
      _ComparisonRow(
        metric: 'Gain',
        yourValue: _formatNumber(data.total.gain),
        otherValue: _formatNumber(data.inflationAdjusted.gain),
        yourColor: _getPnlColor(data.total.gain),
        otherColor: _getPnlColor(data.inflationAdjusted.gain),
      ),
      _ComparisonRow(
        metric: 'Sharpe Ratio',
        yourValue: data.total.sharpeRatio.toStringAsFixed(2),
        otherValue: data.inflationAdjusted.sharpeRatio.toStringAsFixed(2),
        yourColor: defaultColor,
        otherColor: defaultColor,
      ),
      _ComparisonRow(
        metric: 'Max Drawdown',
        yourValue: '${data.total.maxDrawdown.toStringAsFixed(2)}%',
        otherValue: '${data.inflationAdjusted.maxDrawdown.toStringAsFixed(2)}%',
        yourColor: resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss),
        otherColor: resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss),
      ),
      _ComparisonRow(
        metric: 'XIRR',
        yourValue: '${data.total.xirr.toStringAsFixed(2)}%',
        otherValue: '${data.inflationAdjusted.xirr.toStringAsFixed(2)}%',
        yourColor: _getPnlColor(data.total.xirr),
        otherColor: _getPnlColor(data.inflationAdjusted.xirr),
      ),
    ];

    return _buildShadcnComparisonTable(
      context: context,
      col1Header: 'Metric',
      col2Header: 'Original',
      col3Header: 'Inflation Adjusted',
      rows: inflationRows,
    );
  }

  Color _getPnlColor(double value) {
    if (value >= 0) {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    }
    return resolveThemeColor(context,
        dark: MyntColors.lossDark, light: MyntColors.loss);
  }

  // Shared shadcn table builder for 3-column comparison tables
  Widget _buildShadcnComparisonTable({
    required BuildContext context,
    required String col1Header,
    required String col2Header,
    required String col3Header,
    required List<_ComparisonRow> rows,
  }) {
    const noBorder = shadcn.TableCellTheme(
      border: shadcn.WidgetStatePropertyAll(
        shadcn.Border(
          top: shadcn.BorderSide.none,
          bottom: shadcn.BorderSide.none,
          left: shadcn.BorderSide.none,
          right: shadcn.BorderSide.none,
        ),
      ),
    );

    final headerColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final headerStyle = MyntWebTextStyles.tableHeader(
      context,
      darkColor: headerColor,
      lightColor: headerColor,
      fontWeight: MyntFonts.semiBold,
    );
    final metricStyle = MyntWebTextStyles.tableCell(
      context,
      darkColor: MyntColors.textSecondaryDark,
      lightColor: MyntColors.textSecondary,
      fontWeight: MyntFonts.medium,
    );

    shadcn.TableCell cell(Widget child, {bool alignRight = false}) {
      return shadcn.TableCell(
        theme: noBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      );
    }

    return shadcn.OutlinedContainer(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final col1Width = totalWidth * 0.4;
          final col2Width = totalWidth * 0.3;
          final col3Width = totalWidth * 0.3;

          return shadcn.Table(
            columnWidths: {
              0: shadcn.FixedTableSize(col1Width),
              1: shadcn.FixedTableSize(col2Width),
              2: shadcn.FixedTableSize(col3Width),
            },
            defaultRowHeight: const shadcn.FixedTableSize(48),
            rows: [
              // Header row
              shadcn.TableHeader(
                cells: [
                  cell(Text(col1Header, style: headerStyle)),
                  cell(Text(col2Header, style: headerStyle), alignRight: true),
                  cell(Text(col3Header, style: headerStyle), alignRight: true),
                ],
              ),
              // Data rows
              for (final row in rows)
                shadcn.TableRow(
                  cells: [
                    cell(Text(row.metric, style: metricStyle)),
                    cell(
                      Text(
                        row.yourValue,
                        style: MyntWebTextStyles.tableCell(
                          context,
                          color: row.yourColor,
                          darkColor: row.yourColor,
                          lightColor: row.yourColor,
                          fontWeight: MyntFonts.medium,
                        ),
                      ),
                      alignRight: true,
                    ),
                    cell(
                      Text(
                        row.otherValue,
                        style: MyntWebTextStyles.tableCell(
                          context,
                          color: row.otherColor,
                          darkColor: row.otherColor,
                          lightColor: row.otherColor,
                          fontWeight: MyntFonts.medium,
                        ),
                      ),
                      alignRight: true,
                    ),
                  ],
                ),
            ],
          );
        },
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

  Widget _buildTaxContent(
      PortfolioAnalysisModel data, BuildContext context) {
    final totalGains = data.total.gain;
    final equityTax = data.taxDetails.equity.tax;
    final debtTax = data.taxDetails.debt.tax;
    final hybridTax = data.taxDetails.hybrid.tax;
    final totalTax = equityTax + debtTax + hybridTax;
    final postTaxGains = totalGains - totalTax;

    return Column(
      children: [
        _buildIndicatorRow(
          context,
          'GAIN',
          _formatNumber(totalGains),
          'TAX',
          _formatNumber(totalTax),
          'POST TAX',
          _formatNumber(postTaxGains),
          valueColor1: _getPnlColor(totalGains),
          valueColor2: resolveThemeColor(context,
              dark: MyntColors.lossDark, light: MyntColors.loss),
        ),
        const SizedBox(height: 14),
        _buildIndicatorRow(
          context,
          'SHORT TERM GAIN TAX',
          '${data.taxDetails.equity.tax}',
          'LONG TERM GAIN TAX',
          '${data.taxDetails.debt.tax}',
          '',
          '',
          valueColor1: _getPnlColor(data.taxDetails.equity.tax),
          valueColor2: _getPnlColor(data.taxDetails.debt.tax),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '*calculated using 30% tax slab',
              style: MyntWebTextStyles.caption(context,
                  fontWeight: MyntFonts.regular,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _navigateToCustomizeStrategy() {
    widget.onCustomize?.call();
  }

  void _saveStrategy() {
    final strategy = ref.read(dashboardProvider);
    final strategyName = strategy.strategyNameController.text.isNotEmpty
        ? strategy.strategyNameController.text
        : 'Custom Strategy';
    ref.read(dashboardProvider).saveStrategy(strategyName, context);
  }

  Widget _buildChartLegend(String label, Color color) {
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
        Text(
          label,
          style: MyntWebTextStyles.body(context,
              fontWeight: MyntFonts.medium,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
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
            Text(
              label,
              style: MyntWebTextStyles.caption(context,
                  fontWeight: MyntFonts.regular,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary),
            ),
            Text(
              value,
              style: MyntWebTextStyles.para(context,
                  fontWeight: MyntFonts.regular,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }


}

class _ComparisonRow {
  final String metric;
  final String yourValue;
  final String otherValue;
  final Color yourColor;
  final Color otherColor;

  const _ComparisonRow({
    required this.metric,
    required this.yourValue,
    required this.otherValue,
    required this.yourColor,
    required this.otherColor,
  });
}

class _BacktestChartPoint {
  final DateTime date;
  final double benchmark;
  final double strategy;

  _BacktestChartPoint(this.date, this.benchmark, this.strategy);
}
