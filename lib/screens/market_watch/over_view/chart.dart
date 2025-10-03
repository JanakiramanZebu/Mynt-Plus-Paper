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
    return Consumer(builder: (context, WidgetRef ref, _) {
      final funData = ref.watch(marketWatchProvider).fundamentalData!.shareholdings;
      final theme = ref.read(themeProvider);
      final selctedShareHold = ref.watch(marketWatchProvider).selctedShareHold;
      
      // Sort data in specific order: Jun 24, Sep 24, Dec 24, Mar 25, Jun 25
      final sortedData = _sortDataBySpecificOrder(funData!);
      return SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(  margin: const EdgeInsets.only(left: 24), 
          plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  isVisible: false,
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
                    dataSource: sortedData,
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
                        ? const Color.fromARGB(255, 36, 103, 16)
                        : selctedShareHold == "Foriegn Institution"
                            ? const Color(0xFF0E4372)
                            : selctedShareHold == "Other Domestic Institution"
                                ? const Color(0xFFD4A017)
                                : selctedShareHold == "Retail and Others"
                                    ? const Color(0xFF6A1B9A)
                                    : selctedShareHold == "Mutual Funds"
                                        ? const Color(0xFFff620f)
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

  // Sort data in specific order: Jun 24, Sep 24, Dec 24, Mar 25, Jun 25
  List<Shareholdings> _sortDataBySpecificOrder(List<Shareholdings> data) {
    // Define the desired order
    final orderMap = {
      'Jun 24': 1,
      'Sep 24': 2,
      'Dec 24': 3,
      'Mar 25': 4,
      'Jun 25': 5,
    };

    // Create a copy of the data and sort it
    final sortedData = List<Shareholdings>.from(data);
    
    sortedData.sort((a, b) {
      final aOrder = orderMap[a.convDate] ?? 999; // Default to end if not found
      final bOrder = orderMap[b.convDate] ?? 999;
      return aOrder.compareTo(bOrder);
    });

    return sortedData;
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
    return Consumer(builder: (context, WidgetRef ref, _) {
      final balanceSheetData =
          ref.watch(marketWatchProvider).selcteBalanceSheetFinType == "Standalone"
              ? ref.watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsStandalone!
                  .balanceSheet
              : ref.watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsConsolidated!
                  .balanceSheet;
      
      // Sort data by date (oldest first - Mar 21, Mar 22, Mar 23)
      final balanceSheet = List<BalanceSheet>.from(balanceSheetData!);
      balanceSheet.sort((a, b) {
        // Try to parse yearEndDate first, fallback to convDate if needed
        try {
          final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
          final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
          return dateA.compareTo(dateB); // Oldest first
        } catch (e) {
          // If parsing fails, use string comparison as fallback
          return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
        }
      });
      final theme = ref.read(themeProvider);
      return SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(   margin: const EdgeInsets.only(left: 24), 
          plotAreaBorderWidth: 0,
              // legend: Legend(
              //     textStyle: textStyle(
              //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              //         12,
              //         FontWeight.w400),
              //     isVisible: true,
              //     position: LegendPosition.bottom,
              //     image: const AssetImage('assets/img/bought.png'),
              //     overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  isVisible: false,
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
                  color: const Color(0xFF00BCD4), // Bright Cyan
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
                  color: const Color(0xFFE91E63), // Bright Pink
                  width: 0.4,
                
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
    return Consumer(builder: (context, WidgetRef ref, _) {
      final incomeSheetData =
          ref.watch(marketWatchProvider).selcteIncomeFinType == "Standalone"
              ? ref.watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsStandalone!
                  .incomeSheet
              : ref.watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsConsolidated!
                  .incomeSheet;
      
      // Sort data by date (oldest first - Mar 21, Mar 22, Mar 23)
      final incomeSheet = List<IncomeSheet>.from(incomeSheetData!);
      incomeSheet.sort((a, b) {
        // Try to parse yearEndDate first, fallback to convDate if needed
        try {
          final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
          final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
          return dateA.compareTo(dateB); // Oldest first
        } catch (e) {
          // If parsing fails, use string comparison as fallback
          return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
        }
      });
      final theme = ref.read(themeProvider);
      return SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(   margin: const EdgeInsets.only(left: 24),
          plotAreaBorderWidth: 0,
              // legend: Legend(
              //     textStyle: textStyle(
              //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              //         12,
              //         FontWeight.w400),
              //     isVisible: true,
              //     position: LegendPosition.bottom,
              //     image: const AssetImage('assets/img/bought.png'),
              //     overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  isVisible: false,
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
                    color: const Color(0xFF2196F3), // Bright Blue
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
                  color: const Color(0xFFF44336), // Bright Red
                  name: "Expenditure",
                  width: 0.4,
                 
                ),
                LineSeries(
                    isVisibleInLegend: true,
                    // isVisible: true,
                    enableTooltip: true,
                    legendItemText: "Profit After Tax",
                    legendIconType: LegendIconType.image,
                    dataSource: incomeSheet,
                    xValueMapper: (IncomeSheet data, _) => data.convDate,
                    yValueMapper: (IncomeSheet data, _) =>
                        double.parse(data.profitAfterTax!),
                    name: "Profit After Tax",
                    color: const Color(0xFFFFC107)), // Amber
              ]
              
              
              ));
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
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final cashflowSheetData =
          ref.watch(marketWatchProvider).selcteCashFlowFinType == "Standalone"
              ? ref.watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsStandalone!
                  .cashflowSheet
              : ref.watch(marketWatchProvider)
                  .fundamentalData!
                  .stockFinancialsConsolidated!
                  .cashflowSheet;
      
      // Sort data by date (oldest first - Mar 21, Mar 22, Mar 23)
      final cashflowSheet = List<CashflowSheet>.from(cashflowSheetData!);
      cashflowSheet.sort((a, b) {
        // Try to parse yearEndDate first, fallback to convDate if needed
        try {
          final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
          final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
          return dateA.compareTo(dateB); // Oldest first
        } catch (e) {
          // If parsing fails, use string comparison as fallback
          return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
        }
      });

      return SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: SfCartesianChart(    margin: const EdgeInsets.only(left: 24),
          plotAreaBorderWidth: 0,
              // legend: Legend(
              //     textStyle: textStyle(
              //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              //         12,
              //         FontWeight.w400),
              //     isVisible: true,
              //     position: LegendPosition.bottom,
              //     image: const AssetImage('assets/img/bought.png'),
              //     overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                labelStyle: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    10,
                    FontWeight.w500),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  isVisible: false,
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
                  color: const Color(0xFF03A9F4), // Bright Light Blue
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
                  color: const Color(0xFFFF6B35), // Bright Orange
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
                    color: const Color(0xFFE91E63), // Bright Pink
                    width: 0.4,
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
    return Consumer(builder: (context, WidgetRef ref, _) {
      final priceCompare = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);
      return SizedBox(
          height: 200,
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
                    // isVisible: true,
                    enableTooltip: true,
                    legendItemText: priceCompare.peersChartKeys.isNotEmpty?
                        priceCompare.peersChartKeys[0].toString().substring(4) : '',
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData1,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                      data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name: priceCompare.peersChartKeys.isNotEmpty?
                        priceCompare.peersChartKeys[0].toString().substring(4) : '',
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
                    // isVisible: true,
                    enableTooltip: true,
                    legendItemText: priceCompare.peersChartKeys.isNotEmpty ?
                        priceCompare.peersChartKeys[1].toString().substring(4) : '',
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData2,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                       data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name: priceCompare.peersChartKeys.isNotEmpty ?
                        priceCompare.peersChartKeys[1].toString().substring(4) : '',
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
                    // isVisible: true,
                    enableTooltip: true,
                    legendItemText: priceCompare.peersChartKeys.isNotEmpty ?
                        priceCompare.peersChartKeys[2].toString().substring(4) : '',
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData3,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                        data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name: "${priceCompare.peersChartKeys.isNotEmpty ? priceCompare.peersChartKeys[2] : ''}",
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
                    // isVisible: true,
                    enableTooltip: true,
                    legendItemText: priceCompare.peersChartKeys.isNotEmpty ?
                        priceCompare.peersChartKeys[3].toString().substring(4) : '',
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData4,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                       data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name: priceCompare.peersChartKeys.isNotEmpty ?
                        priceCompare.peersChartKeys[3].toString().substring(4) : '',
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
                    // isVisible: true,
                    enableTooltip: true,
                    legendItemText: priceCompare.peersChartKeys.isNotEmpty ?
                        priceCompare.peersChartKeys[4].toString().substring(4) : '',
                    legendIconType: LegendIconType.image,
                    dataSource: priceCompare.prcComChrtData5,
                    xValueMapper: (PrcComparisionChartData data, _) =>
                        data.yValue,
                    yValueMapper: (PrcComparisionChartData data, _) =>
                        data.xValue,
                    name: priceCompare.peersChartKeys.isNotEmpty ?
                        priceCompare.peersChartKeys[4].toString().substring(4) : '',
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
