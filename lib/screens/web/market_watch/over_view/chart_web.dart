import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

class FBalSheetChartWeb extends StatefulWidget {
  const FBalSheetChartWeb({super.key});
  @override
  FBalSheetChartWebState createState() => FBalSheetChartWebState();
}

class FBalSheetChartWebState extends State<FBalSheetChartWeb> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(
      enable: true,
      duration: 1000,
      animationDuration: 200,
      shouldAlwaysShow: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final finType = ref.watch(marketWatchProvider.select((p) => p.selcteBalanceSheetFinType));
      final fundamentalData = ref.watch(marketWatchProvider.select((p) => p.fundamentalData));
      final balanceSheetData = finType == "Standalone"
          ? fundamentalData?.stockFinancialsStandalone?.balanceSheet
          : fundamentalData?.stockFinancialsConsolidated?.balanceSheet;

      final balanceSheet = List<BalanceSheet>.from(balanceSheetData!);
      balanceSheet.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
          final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
          return dateA.compareTo(dateB);
        } catch (e) {
          return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
        }
      });
      final theme = ref.read(themeProvider);
      return SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(
          margin: const EdgeInsets.only(left: 24),
          plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(
                    fontFamily: MyntFonts.fontFamily,
                    fontSize: MyntFonts.caption,
                    fontWeight: MyntFonts.medium,
                    color: theme.isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  isVisible: false,
                  labelStyle: TextStyle(
                      fontFamily: MyntFonts.fontFamily,
                      fontSize: MyntFonts.para,
                      fontWeight: MyntFonts.medium,
                      color: theme.isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary),
                  majorGridLines: const MajorGridLines(width: 0)),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<BalanceSheet, String>>[
                ColumnSeries(
                  name: "Assets",
                  isVisibleInLegend: true,
                  legendItemText: "Assets",
                  enableTooltip: true,
                  dataSource: balanceSheet,
                  xValueMapper: (BalanceSheet data, _) => data.convDate,
                  yValueMapper: (BalanceSheet data, _) =>
                      double.parse(data.totalAssets!),
                  color: const Color(0xFF00BCD4),
                  width: 0.4,
                ),
                ColumnSeries(
                  isVisibleInLegend: true,
                  enableTooltip: true,
                  name: "Liabilities",
                  legendItemText: "Liabilities",
                  dataSource: balanceSheet,
                  xValueMapper: (BalanceSheet data, _) => data.convDate,
                  yValueMapper: (BalanceSheet data, _) =>
                      double.parse(data.totalLiabilities!),
                  color: const Color(0xFFE91E63),
                  width: 0.4,
                )
              ]));
    });
  }

}

class FIncomeChartWeb extends StatefulWidget {
  const FIncomeChartWeb({super.key});
  @override
  FIncomeChartWebState createState() => FIncomeChartWebState();
}

class FIncomeChartWebState extends State<FIncomeChartWeb> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(
      enable: true,
      duration: 2000,
      animationDuration: 200,
      shouldAlwaysShow: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final finType = ref.watch(marketWatchProvider.select((p) => p.selcteIncomeFinType));
      final fundamentalData = ref.watch(marketWatchProvider.select((p) => p.fundamentalData));
      final incomeSheetData = finType == "Standalone"
          ? fundamentalData?.stockFinancialsStandalone?.incomeSheet
          : fundamentalData?.stockFinancialsConsolidated?.incomeSheet;

      final incomeSheet = List<IncomeSheet>.from(incomeSheetData!);
      incomeSheet.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
          final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
          return dateA.compareTo(dateB);
        } catch (e) {
          return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
        }
      });
      final theme = ref.read(themeProvider);
      return SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(
          margin: const EdgeInsets.only(left: 24),
          plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(
                    fontFamily: MyntFonts.fontFamily,
                    fontSize: MyntFonts.caption,
                    fontWeight: MyntFonts.medium,
                    color: theme.isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  isVisible: false,
                  labelStyle: TextStyle(
                      fontFamily: MyntFonts.fontFamily,
                      fontSize: MyntFonts.para,
                      fontWeight: MyntFonts.medium,
                      color: theme.isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary),
                  majorGridLines: const MajorGridLines(width: 0)),

              tooltipBehavior: _tooltip,
              series: <CartesianSeries<IncomeSheet, String>>[
                ColumnSeries(
                    isVisibleInLegend: true,
                    legendItemText: "Revenue",
                    enableTooltip: true,
                    dataSource: incomeSheet,
                    xValueMapper: (IncomeSheet data, _) => data.convDate,
                    yValueMapper: (IncomeSheet data, _) =>
                        double.parse(data.revenue!),
                    color: const Color(0xFF2196F3),
                    name: "Revenue",
                    width: 0.4,
                   ),
                ColumnSeries(
                  isVisibleInLegend: true,
                  enableTooltip: true,
                  legendItemText: "Expenditure",
                  dataSource: incomeSheet,
                  xValueMapper: (IncomeSheet data, _) => data.convDate,
                  yValueMapper: (IncomeSheet data, _) =>
                      double.parse(data.expenditure!),
                  color: const Color(0xFFF44336),
                  name: "Expenditure",
                  width: 0.4,
                ),
                LineSeries(
                    isVisibleInLegend: true,
                    enableTooltip: true,
                    legendItemText: "Profit After Tax",
                    legendIconType: LegendIconType.image,
                    dataSource: incomeSheet,
                    xValueMapper: (IncomeSheet data, _) => data.convDate,
                    yValueMapper: (IncomeSheet data, _) =>
                        double.parse(data.profitAfterTax!),
                    name: "Profit After Tax",
                    color: const Color(0xFFFFC107)),
              ]));
    });
  }

}

class FCashFlowChartWeb extends StatefulWidget {
  const FCashFlowChartWeb({super.key});
  @override
  FCashFlowChartWebState createState() => FCashFlowChartWebState();
}

class FCashFlowChartWebState extends State<FCashFlowChartWeb> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(
      enable: true,
      duration: 2000,
      animationDuration: 200,
      shouldAlwaysShow: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final finType = ref.watch(marketWatchProvider.select((p) => p.selcteCashFlowFinType));
      final fundamentalData = ref.watch(marketWatchProvider.select((p) => p.fundamentalData));
      final cashflowSheetData = finType == "Standalone"
          ? fundamentalData?.stockFinancialsStandalone?.cashflowSheet
          : fundamentalData?.stockFinancialsConsolidated?.cashflowSheet;

      final cashflowSheet = List<CashflowSheet>.from(cashflowSheetData!);
      cashflowSheet.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
          final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
          return dateA.compareTo(dateB);
        } catch (e) {
          return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
        }
      });

      return SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(
          margin: const EdgeInsets.only(left: 24),
          plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(
                    fontFamily: MyntFonts.fontFamily,
                    fontSize: MyntFonts.caption,
                    fontWeight: MyntFonts.medium,
                    color: theme.isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  isVisible: false,
                  labelStyle: TextStyle(
                      fontFamily: MyntFonts.fontFamily,
                      fontSize: MyntFonts.para,
                      fontWeight: MyntFonts.medium,
                      color: theme.isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary),
                  majorGridLines: const MajorGridLines(width: 0)),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<CashflowSheet, String>>[
                ColumnSeries(
                  name: "Operating",
                  isVisibleInLegend: true,
                  legendItemText: "Operating",
                  enableTooltip: true,
                  dataSource: cashflowSheet,
                  xValueMapper: (CashflowSheet data, _) => data.convDate,
                  yValueMapper: (CashflowSheet data, _) =>
                      double.parse(data.cashFromOperatingActivities!),
                  color: const Color(0xFF03A9F4),
                  width: 0.4,
                ),
                ColumnSeries(
                  name: "Investing",
                  isVisibleInLegend: true,
                  enableTooltip: true,
                  legendItemText: "Investing",
                  dataSource: cashflowSheet,
                  xValueMapper: (CashflowSheet data, _) => data.convDate,
                  yValueMapper: (CashflowSheet data, _) =>
                      double.parse(data.cashFlowFromInvestingActivities!),
                  color: const Color(0xFFFF6B35),
                  width: 0.4,
                ),
                ColumnSeries(
                    name: "Financing",
                    isVisibleInLegend: true,
                    enableTooltip: true,
                    legendItemText: "Financing",
                    dataSource: cashflowSheet,
                    xValueMapper: (CashflowSheet data, _) => data.convDate,
                    yValueMapper: (CashflowSheet data, _) =>
                        double.parse(data.cashFromFinancingActivities!),
                    color: const Color(0xFFE91E63),
                    width: 0.4,
                   )
              ]));
    });
  }

}
