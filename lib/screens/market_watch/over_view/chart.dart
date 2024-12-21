import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class ShareHoldChart extends StatefulWidget {
  const ShareHoldChart({super.key});
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<ShareHoldChart> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true, color: Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final funData = watch(marketWatchProvider).fundamentalData!.shareholdings;
      final theme = context.read(themeProvider);
      final selctedShareHold = watch(marketWatchProvider).selctedShareHold;
      return SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(  margin: const EdgeInsets.symmetric(horizontal: 0),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  labelStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w500),
                  majorGridLines: const MajorGridLines(width: 0),
                  minimum: 0,
                  maximum: 100),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<Shareholdings, String>>[
                ColumnSeries(
                    name: selctedShareHold,
                    enableTooltip: true,
                    dataSource: funData!,
                    xValueMapper: (Shareholdings data, _) => data.convDate,
                    yValueMapper: (Shareholdings data, _) => selctedShareHold ==
                            "Promoter Holding"
                        ? double.parse(data.promoters!)
                        : selctedShareHold == "Foriegin Institution"
                            ? double.parse(data.fiiFpi!)
                            : selctedShareHold == "Other Domestic Institution"
                                ? double.parse(data.dii!)
                                : selctedShareHold == "Retail and Others"
                                    ? double.parse(data.retailAndOthers!)
                                    : selctedShareHold == "Mutual Funds"
                                        ? double.parse(data.mutualFunds!)
                                        : double.parse(data.fiiFpi!),
                    color: selctedShareHold == "Promoter Holding"
                        ? const Color(0xff2e8564)
                        : selctedShareHold == "Foriegin Institution"
                            ? const Color(0xff7cd36f)
                            : selctedShareHold == "Other Domestic Institution"
                                ? const Color(0xfff7cd6c)
                                : selctedShareHold == "Retail and Others"
                                    ? const Color(0XFFfbebc4)
                                    : selctedShareHold == "Mutual Funds"
                                        ? const Color(0XFFdedede)
                                        : const Color(0xfff7cd6c),
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            13,
                            FontWeight.w500)))
              ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class FBalSheetCahrt extends StatefulWidget {
  const FBalSheetCahrt({super.key});
  @override
  FBalSheetCahrtState createState() => FBalSheetCahrtState();
}

class FBalSheetCahrtState extends State<FBalSheetCahrt> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true, color: Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final balanceSheet =
          watch(marketWatchProvider).selcteFinType == "Standalone"
              ? watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsStandalone!
                  .balanceSheet
              : watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsConsolidated!
                  .balanceSheet;
      final theme = context.read(themeProvider);
      return SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(   margin: const EdgeInsets.symmetric(horizontal: 0),
              legend: Legend(
                  textStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w400),
                  isVisible: true,
                  position: LegendPosition.bottom,
                  image: const AssetImage('assets/img/bought.png'),
                  overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  labelStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w500),
                  majorGridLines: const MajorGridLines(width: 0)),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<BalanceSheet, String>>[
                ColumnSeries(
                  name: "Assets",
                  isVisibleInLegend: true,
                  legendItemText: "Assets",
                  enableTooltip: true,
                  dataSource: balanceSheet!,
                  xValueMapper: (BalanceSheet data, _) => data.convDate,
                  yValueMapper: (BalanceSheet data, _) =>
                      double.parse(data.totalAssets!),
                  color: const Color(0xff2e8564),
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
                  color: const Color(0xff7cd36f),
                )
              ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class FIncomeChart extends StatefulWidget {
  const FIncomeChart({super.key});
  @override
  FIncomeChartState createState() => FIncomeChartState();
}

class FIncomeChartState extends State<FIncomeChart> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true, color: Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final incomeSheet =
          watch(marketWatchProvider).selcteFinType == "Standalone"
              ? watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsStandalone!
                  .incomeSheet
              : watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsConsolidated!
                  .incomeSheet;
      final theme = context.read(themeProvider);
      return SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(   margin: const EdgeInsets.symmetric(horizontal: 0),
              legend: Legend(
                  textStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w400),
                  isVisible: true,
                  position: LegendPosition.bottom,
                  image: const AssetImage('assets/img/bought.png'),
                  overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  labelStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w500),
                  majorGridLines: const MajorGridLines(width: 0)),
              
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<IncomeSheet, String>>[
                ColumnSeries(
                    isVisibleInLegend: true,
                    legendItemText: "Revenue",
                    enableTooltip: true,
                    dataSource: incomeSheet!,
                    xValueMapper: (IncomeSheet data, _) => data.convDate,
                    yValueMapper: (IncomeSheet data, _) =>
                        double.parse(data.revenue!),
                    color: const Color(0xff2e8564),
                    name: "Revenue"),
                ColumnSeries(
                  isVisibleInLegend: true,
                  enableTooltip: true,
                  legendItemText: "Expenditure",
                  dataSource: incomeSheet,
                  xValueMapper: (IncomeSheet data, _) => data.convDate,
                  yValueMapper: (IncomeSheet data, _) =>
                      double.parse(data.expenditure!),
                  color: const Color(0xff7cd36f),
                  name: "Expenditure",
                ),
                LineSeries(
                    isVisibleInLegend: true,
                    isVisible: true,
                    enableTooltip: true,
                    legendItemText: "Profit After Tax",
                    legendIconType: LegendIconType.image,
                    dataSource: incomeSheet,
                    xValueMapper: (IncomeSheet data, _) => data.convDate,
                    yValueMapper: (IncomeSheet data, _) =>
                        double.parse(data.profitAfterTax!),
                    name: "Profit After Tax",
                    color: const Color(0xfff7cd6c)),
              ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class FCashFlowChart extends StatefulWidget {
  const FCashFlowChart({super.key});
  @override
  FCashFlowChartState createState() => FCashFlowChartState();
}

class FCashFlowChartState extends State<FCashFlowChart> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true, color: Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = context.read(themeProvider);
      final cashflowSheet =
          watch(marketWatchProvider).selcteFinType == "Standalone"
              ? watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsStandalone!
                  .cashflowSheet
              : watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsConsolidated!
                  .cashflowSheet;

      return SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(    margin: const EdgeInsets.symmetric(horizontal: 0),
              legend: Legend(
                  textStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w400),
                  isVisible: true,
                  position: LegendPosition.bottom,
                  image: const AssetImage('assets/img/bought.png'),
                  overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  labelStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w500),
                  majorGridLines: const MajorGridLines(width: 0)),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<CashflowSheet, String>>[
                ColumnSeries(
                  name: "Operating",
                  isVisibleInLegend: true,
                  legendItemText: "Operating",
                  enableTooltip: true,
                  dataSource: cashflowSheet!,
                  xValueMapper: (CashflowSheet data, _) => data.convDate,
                  yValueMapper: (CashflowSheet data, _) =>
                      double.parse(data.cashFromOperatingActivities!),
                  color: const Color(0xff2e8564),
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
                  color: const Color(0xff7cd36f),
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
                    color: const Color(0xfff7cd6c)),
              ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class PriceComChart extends StatefulWidget {
  const PriceComChart({super.key});
  @override
  PriceComChartState createState() => PriceComChartState();
}

class PriceComChartState extends State<PriceComChart> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true, color: Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final priceCompare = watch(marketWatchProvider);
      final theme = context.read(themeProvider);
      return SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(   margin: const EdgeInsets.symmetric(horizontal: 0),
              legend: Legend(
                  textStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w400),
                  isVisible: true,
                  image: const AssetImage('assets/img/bought.png'),
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  labelStyle: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w500),
                  majorGridLines: const MajorGridLines(width: 0)),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<PrcComparisionChartData, String>>[
                if (priceCompare.prcComChrtData1.isNotEmpty)
                  AreaSeries(
                    borderColor: const Color(0xff2e8564),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xff2e8564),
                          const Color(0xff2e8564).withOpacity(.2)
                        ],
                        stops: const [
                          0.1,
                          1
                        ]),
                    isVisibleInLegend: true,
                    isVisible: true,
                    enableTooltip: true,
                    legendItemText:
                        priceCompare.peersChartKeys[0].toString().substring(4),
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData1,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                      data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name:
                        priceCompare.peersChartKeys[0].toString().substring(4),
                  ),
                if (priceCompare.prcComChrtData2.isNotEmpty)
                  AreaSeries(
                    borderColor: const Color(0xff7cd36f),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xff7cd36f),
                          const Color(0xff7cd36f).withOpacity(.2)
                        ],
                        stops: const [
                          0.1,
                          1
                        ]),
                    isVisibleInLegend: true,
                    isVisible: true,
                    enableTooltip: true,
                    legendItemText:
                        priceCompare.peersChartKeys[1].toString().substring(4),
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData2,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                       data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name:
                        priceCompare.peersChartKeys[1].toString().substring(4),
                  ),
                if (priceCompare.prcComChrtData3.isNotEmpty)
                  AreaSeries(
                    borderColor: const Color(0XFFfbebc4),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0XFFfbebc4),
                          const Color(0XFFfbebc4).withOpacity(.2)
                        ],
                        stops: const [
                          0.1,
                          1
                        ]),
                    isVisibleInLegend: true,
                    isVisible: true,
                    enableTooltip: true,
                    legendItemText:
                        priceCompare.peersChartKeys[2].toString().substring(4),
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData3,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                        data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name: "${priceCompare.peersChartKeys[2]}",
                  ),
                if (priceCompare.prcComChrtData4.isNotEmpty)
                  AreaSeries(
                    borderColor: const Color(0XFFfbebc4),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0XFFfbebc4),
                          const Color(0XFFfbebc4).withOpacity(.2)
                        ],
                        stops: const [
                          0.1,
                          1
                        ]),
                    isVisibleInLegend: true,
                    isVisible: true,
                    enableTooltip: true,
                    legendItemText:
                        priceCompare.peersChartKeys[3].toString().substring(4),
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData4,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                       data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name:
                        priceCompare.peersChartKeys[3].toString().substring(4),
                  ),
                if (priceCompare.prcComChrtData5.isNotEmpty)
                  AreaSeries(
                    borderColor: const Color(0XFFdedede),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0XFFdedede),
                          const Color(0XFFdedede).withOpacity(.2)
                        ],
                        stops: const [
                          0.1,
                          1
                        ]),
                    isVisibleInLegend: true,
                    isVisible: true,
                    enableTooltip: true,
                    legendItemText:
                        priceCompare.peersChartKeys[4].toString().substring(4),
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData5,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                        data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name:
                        priceCompare.peersChartKeys[4].toString().substring(4),
                  ),
              ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
