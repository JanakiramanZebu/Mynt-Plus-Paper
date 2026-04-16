import 'package:flutter/material.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';

class IPOFinancialChart extends StatefulWidget {
  final List<dynamic> data;
  final ThemesProvider theme;
  const IPOFinancialChart({
    super.key,
    required this.data,
    required this.theme,
  });

  @override
  State<IPOFinancialChart> createState() => _IPOFinancialChartState();
}

class _IPOFinancialChartState extends State<IPOFinancialChart> {
  @override
  Widget build(BuildContext context) {
    // Data source
    final List<IPOFinancialData> data = [
      IPOFinancialData(
        period: widget.data[0]['Period Ended'],
        assets:
            widget.data[0]['Assets'] == "" || widget.data[0]['Assets'] == null
                ? 0
                : double.parse(widget.data[0]['Assets']),
        netWorth: widget.data[0]['Net Worth'] == "" ||
                widget.data[0]['Net Worth'] == null
            ? 0
            : double.parse(widget.data[0]['Net Worth']),
        revenue: double.parse(widget.data[0]['Revenue']),
        borrowing: widget.data[0]['Total Borrowing'] == "" ||
                widget.data[0]['Total Borrowing'] == null
            ? 0
            : double.parse(
                widget.data[0]['Total Borrowing'] ?? double.parse("0")),
      ),
      IPOFinancialData(
        period: widget.data[1]['Period Ended'],
        assets:
            widget.data[1]['Assets'] == "" || widget.data[1]['Assets'] == null
                ? 0
                : double.parse(widget.data[1]['Assets']),
        netWorth: widget.data[1]['Net Worth'] == "" ||
                widget.data[1]['Net Worth'] == null
            ? 0
            : double.parse(widget.data[1]['Net Worth']),
        revenue: double.parse(widget.data[1]['Revenue']),
        borrowing: widget.data[1]['Total Borrowing'] == "" ||
                widget.data[1]['Total Borrowing'] == null
            ? 0
            : double.parse(
                widget.data[1]['Total Borrowing'] ?? double.parse("0")),
      ),
      IPOFinancialData(
        period: widget.data[2]['Period Ended'],
        assets:
            widget.data[2]['Assets'] == "" || widget.data[2]['Assets'] == null
                ? 0
                : double.parse(widget.data[2]['Assets']),
        netWorth: widget.data[2]['Net Worth'] == "" ||
                widget.data[2]['Net Worth'] == null
            ? 0
            : double.parse(widget.data[2]['Net Worth']),
        revenue: widget.data[2]['Revenue'] == "" || widget.data[2]['Revenue'] == null
                ? 0
                : double.parse(widget.data[2]['Revenue']),
        borrowing: widget.data[2]['Total Borrowing'] == "" ||
                widget.data[2]['Total Borrowing'] == null
            ? 0
            : double.parse(
                widget.data[2]['Total Borrowing'] ?? double.parse("0")),
      ),
      IPOFinancialData(
        period: widget.data[3]['Period Ended'],
        assets:
            widget.data[3]['Assets'] == "" || widget.data[3]['Assets'] == null
                ? 0
                : double.parse(widget.data[3]['Assets']),
        netWorth: widget.data[3]['Net Worth'] == "" ||
                widget.data[3]['Net Worth'] == null
            ? 0
            : double.parse(widget.data[3]['Net Worth']),
        revenue:
            widget.data[3]['Revenue'] == "" || widget.data[3]['Revenue'] == null
                ? 0
                : double.parse(widget.data[3]['Revenue']),
        borrowing: widget.data[3]['Total Borrowing'] == "" ||
                widget.data[3]['Total Borrowing'] == null
            ? 0
            : double.parse(
                widget.data[3]['Total Borrowing'] ?? double.parse("0")),
      ),
    ];

    return SizedBox(
      height: 320,
      width: MediaQuery.of(context).size.width,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: textStyle(
              widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              10,
              0),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: textStyle(
              widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              12,
              0),
          majorGridLines: const MajorGridLines(width: 0), // Remove grid lines
        ),
        // title: ChartTitle(text: 'IPO Financial Data Over Periods'),
        legend: Legend(
            textStyle: textStyle(
                widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                12,
                3),
            isVisible: true,
            position: LegendPosition.bottom,
            overflowMode: LegendItemOverflowMode.wrap),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          // Assets
          ColumnSeries<IPOFinancialData, String>(
            dataSource: data,
            xValueMapper: (IPOFinancialData data, _) => data.period,
            yValueMapper: (IPOFinancialData data, _) => data.assets,
            name: 'Assets',
            color: const Color(0xff148564),
          ),
          // Net Worth
          ColumnSeries<IPOFinancialData, String>(
            dataSource: data,
            xValueMapper: (IPOFinancialData data, _) => data.period,
            yValueMapper: (IPOFinancialData data, _) => data.netWorth,
            name: 'Net Worth',
            color: const Color(0xff7CD36E),
          ),
          // Revenue
          ColumnSeries<IPOFinancialData, String>(
              dataSource: data,
              xValueMapper: (IPOFinancialData data, _) => data.period,
              yValueMapper: (IPOFinancialData data, _) => data.revenue,
              name: 'Revenue',
              color: const Color(0xffF9CD6C)),
          // Total Borrowing
          ColumnSeries<IPOFinancialData, String>(
              dataSource: data,
              xValueMapper: (IPOFinancialData data, _) => data.period,
              yValueMapper: (IPOFinancialData data, _) => data.borrowing,
              name: 'Total Borrowing',
              color: const Color(0xffFDEBC4)),
        ],
      ),
    );
  }
}

class IPOFinancialData {
  final String period;
  final double assets;
  final double netWorth;
  final double revenue;
  final double borrowing;

  IPOFinancialData({
    required this.period,
    required this.assets,
    required this.netWorth,
    required this.revenue,
    required this.borrowing,
  });
}
