import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../../provider/ledger_provider.dart';
import '../../../provider/thems.dart';

void main() {
  runApp(MaterialApp(home: Scaffold(body: BarChartWidget())));
}

class BarChartWidget extends StatefulWidget {
  @override
  _BarChartWidgetState createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int? touchedGroupIndex;
  List<List<double>> barData = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tooltipTextStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    double chartHeight = MediaQuery.of(context).size.height * 0.4;

    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      
      final ledgerprovider = watch(ledgerProvider);
    final textColor = theme.isDarkMode
                                    ? Colors.white
                                    : Colors.black;

      // if (ledgerprovider.activeTabTaxPnl == 0) {
        barData = [
          [
            (ledgerprovider.taxpnleq?.data?.assetsTotal != null &&
                    ledgerprovider.taxpnleq!.data!.assetsTotal!.isNotEmpty)
                ? double.parse(ledgerprovider.taxpnleq!.data!.assetsTotal!)
                : 0.00,
          ],
          [
            (ledgerprovider.taxpnleq?.data?.longtermTotal != null &&
                    ledgerprovider.taxpnleq!.data!.longtermTotal!.isNotEmpty)
                ? double.parse(ledgerprovider.taxpnleq!.data!.longtermTotal!)
                : 0.00,
            (ledgerprovider.taxpnleq?.data?.shortermTotal != null &&
                    ledgerprovider.taxpnleq!.data!.shortermTotal!.isNotEmpty)
                ? double.parse(ledgerprovider.taxpnleq!.data!.shortermTotal!)
                : 0.00,
         
          ],
          [
            (ledgerprovider.taxpnldercomcur?.data?.derivatives != null &&
                    ledgerprovider
                            .taxpnldercomcur?.data?.derivatives?.derFutPnl !=
                        null)
                ? double.parse(ledgerprovider
                    .taxpnldercomcur!.data!.derivatives!.derFutPnl!)
                : 0.00,
            (ledgerprovider.taxpnldercomcur?.data?.derivatives != null &&
                    ledgerprovider
                            .taxpnldercomcur?.data?.derivatives?.derOptPnl !=
                        null)
                ? double.parse(ledgerprovider
                    .taxpnldercomcur!.data!.derivatives!.derOptPnl!)
                : 0.00,
          ],
          [
            (ledgerprovider.taxpnldercomcur?.data?.commodity != null &&
                    ledgerprovider
                            .taxpnldercomcur?.data?.commodity?.commFutPnl !=
                        null)
                ? double.parse(ledgerprovider
                    .taxpnldercomcur!.data!.commodity!.commFutPnl!)
                : 0.00,
            (ledgerprovider.taxpnldercomcur?.data?.commodity != null &&
                    ledgerprovider
                            .taxpnldercomcur?.data?.commodity?.commOptPnl !=
                        null)
                ? double.parse(ledgerprovider
                    .taxpnldercomcur!.data!.commodity!.commOptPnl!)
                : 0.00,
          ],
          [
            (ledgerprovider.taxpnldercomcur?.data?.currency != null &&
                    ledgerprovider
                            .taxpnldercomcur?.data?.currency?.currFutPnl !=
                        null)
                ? double.parse(
                    ledgerprovider.taxpnldercomcur!.data!.currency!.currFutPnl!)
                : 0.00,
            (ledgerprovider.taxpnldercomcur?.data?.currency != null &&
                    ledgerprovider
                            .taxpnldercomcur?.data?.currency?.currOptPnl !=
                        null)
                ? double.parse(
                    ledgerprovider.taxpnldercomcur!.data!.currency!.currOptPnl!)
                : 0.00,
          ],
        ];
      // } 
      // else if (ledgerprovider.activeTabTaxPnl == 1) {
      //   barData = [
      //     [
      //          (ledgerprovider.taxpnleq?.data?.tradingTurnover != null &&
      //               ledgerprovider.taxpnleq!.data!.tradingTurnover!.isNotEmpty)
      //           ? double.parse(ledgerprovider.taxpnleq!.data!.tradingTurnover!)
      //           : 0.00,
      //     ],
      //     [
      //       (ledgerprovider.taxpnldercomcur?.data?.derivatives != null &&
      //               ledgerprovider
      //                       .taxpnldercomcur?.data?.derivatives?.derFutTo !=
      //                   null)
      //           ? double.parse(ledgerprovider
      //               .taxpnldercomcur!.data!.derivatives!.derFutTo!)
      //           : 0.00,
      //       (ledgerprovider.taxpnldercomcur?.data?.derivatives != null &&
      //               ledgerprovider
      //                       .taxpnldercomcur?.data?.derivatives?.derOptTo !=
      //                   null)
      //           ? double.parse(ledgerprovider
      //               .taxpnldercomcur!.data!.derivatives!.derOptTo!)
      //           : 0.00,
      //     ],
      //     [
      //       (ledgerprovider.taxpnldercomcur?.data?.commodity != null &&
      //               ledgerprovider
      //                       .taxpnldercomcur?.data?.commodity?.commFutTo !=
      //                   null)
      //           ? double.parse(
      //               ledgerprovider.taxpnldercomcur!.data!.commodity!.commFutTo!)
      //           : 0.00,
      //       (ledgerprovider.taxpnldercomcur?.data?.commodity != null &&
      //               ledgerprovider
      //                       .taxpnldercomcur?.data?.commodity?.commOptTo !=
      //                   null)
      //           ? double.parse(
      //               ledgerprovider.taxpnldercomcur!.data!.commodity!.commOptTo!)
      //           : 0.00,
      //     ],
      //     [
      //       (ledgerprovider.taxpnldercomcur?.data?.currency != null &&
      //               ledgerprovider.taxpnldercomcur?.data?.currency?.currFutTo !=
      //                   null)
      //           ? double.parse(
      //               ledgerprovider.taxpnldercomcur!.data!.currency!.currFutTo!)
      //           : 0.00,
      //       (ledgerprovider.taxpnldercomcur?.data?.currency != null &&
      //               ledgerprovider.taxpnldercomcur?.data?.currency?.currOptTo !=
      //                   null)
      //           ? double.parse(
      //               ledgerprovider.taxpnldercomcur!.data!.currency!.currOptTo!)
      //           : 0.00,
      //     ],
      //   ];
      // } else if (ledgerprovider.activeTabTaxPnl == 2) {
      //   barData = [
      //     [
      //       ledgerprovider.taxpnleqCharge!.total != 'null' &&
      //               ledgerprovider.taxpnleqCharge!.total!.isNotEmpty
      //           ? double.parse(ledgerprovider.taxpnleqCharge!.total!)
      //           : 0.00,
      //     ],
      //     [
      //       (ledgerprovider.taxpnldercomcur?.data?.charges?.derChargesTotal != null)
      //           ? double.parse(
      //               ledgerprovider.taxpnldercomcur!.data!.charges!.derChargesTotal!)
      //           : 0.00,
      //     ],
      //     [
      //       (ledgerprovider.taxpnldercomcur?.data?.charges?.commChargesTotal != null)
      //           ? double.parse(
      //               ledgerprovider.taxpnldercomcur!.data!.charges!.commChargesTotal!)
      //           : 0.00,
      //     ],
      //     [
      //       (ledgerprovider.taxpnldercomcur?.data?.charges?.curChargesTotal != null)
      //           ? double.parse(
      //               ledgerprovider.taxpnldercomcur!.data!.charges!.curChargesTotal!)
      //           : 0.00,
      //     ]
      //   ];
      // }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: chartHeight,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0 , right: 16.0,bottom: 32.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      direction: TooltipDirection.bottom,
                      tooltipBgColor: Colors.black87,
                      tooltipRoundedRadius: 8, 
                      tooltipPadding: const EdgeInsets.all( 8.0),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (touchedGroupIndex != groupIndex) return null;
                        final items = barData[groupIndex];
                        return BarTooltipItem(
                          items.asMap().entries.map((entry) {
                            final value = entry.value;
                            return '• ₹${value.toStringAsFixed(1)}\n';
                          }).join(),
                          tooltipTextStyle, 
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (event.isInterestedForInteractions &&
                          response != null &&
                          response.spot != null) {
                        setState(() {
                          touchedGroupIndex =
                              response.spot!.touchedBarGroupIndex;
                        });
                      } else {
                        setState(() {
                          touchedGroupIndex = null;
                        });
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 70,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final title = 
                          // switch (ledgerprovider.activeTabTaxPnl) {
                            // 0 => 
                            ['Asserts', 'Equity', 'FNO', 'Com', 'Cur'];
                            // 1 => ['Trading','FNO', 'Com', 'Cur'],
                            // 2 => ['Equity', 'FNO', 'Com', 'Cur'],
                            // _ => []
                          // };
                          return value.toInt() < title.length
                              ? Padding(
                                padding: const EdgeInsets.only(top : 8.0),
                                child: Text(
                                    title[value.toInt()],
                                    style: textStyle(
                                theme.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                12,
                                FontWeight.w500),
                                  ),
                              )
                              : Container();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    verticalInterval: 1000,
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.5),
                      strokeWidth: value == 0 ? 2 : 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(barData.length, (index) {
                    return makeStackedBar(index, barData[index]);
                  }),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  BarChartGroupData makeStackedBar(int x, List<double> values) {
    double runningTotal = 0;
    final colors = [
      Colors.black,
      const Color.fromARGB(255, 46, 144, 224),
      Colors.green
    ];

    final stacks = values.map((val) {
      final stackItem = BarChartRodStackItem(
        runningTotal,
        runningTotal + val,
        val < 0 ? Colors.red : colors[values.indexOf(val) % colors.length],
      );
      runningTotal += val;
      return stackItem;
    }).toList();

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: runningTotal,
          rodStackItems: stacks,
          width: 35,
          borderRadius: BorderRadius.circular(0),
        ),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0] : [],
    );
  }
}
