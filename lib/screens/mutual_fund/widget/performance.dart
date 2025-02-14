import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/mf_model/mf_factsheet_graph.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class MFPerformance extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFPerformance({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider);
    // final navGraph = watch(mfProvider).navGraph;
    final mfProvide = watch(mfProvider);
    if(mfData.sheetGraph!.data!.isNotEmpty) {
      
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Cumulative Performance of Last 3 Years",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            "Cumulative Performance breakdown of ${mfProvide.factSheetDataModel!.data!.fundName} information",
            style: textStyle(const Color(0xff666666), 13, FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Container(
              margin: const EdgeInsets.only(top: 14, bottom: 12),
              height: 320,
              width: MediaQuery.of(context).size.width,
              child: SfCartesianChart(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  primaryXAxis: CategoryAxis(
                    labelStyle: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        10,
                        FontWeight.w500),
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap),
                  tooltipBehavior:
                      TooltipBehavior(enable: true, color: Colors.transparent),
                  series: <CartesianSeries<SheetGraphData, String>>[
                    AreaSeries(
                      name: 'Scheme Returns',
                      color: colors.darkGrey.withOpacity(.1),
                      isVisibleInLegend: true,
                      isVisible: true,
                      enableTooltip: true,
                      borderColor: const Color(0xff1e53e5),
                      borderWidth: 3,
                      legendIconType: LegendIconType.circle,
                      dataSource: mfData.sheetGraph!.data!,
                      xValueMapper: (SheetGraphData data, _) => data.navDate!,
                      yValueMapper: (SheetGraphData data, _) =>
                          double.parse(data.schReturns ?? "0.00"),
                    ),
                    AreaSeries(
                      name: 'Benchmark Returns',
                      color: colors.darkGrey.withOpacity(.3),
                      isVisibleInLegend: true,
                      isVisible: true,
                      enableTooltip: true,
                      borderColor: const Color(0xffD86F10),
                      borderWidth: 3,
                      legendIconType: LegendIconType.image,
                      dataSource: mfData.sheetGraph!.data!,
                      xValueMapper: (SheetGraphData data, _) => data.navDate!,
                      yValueMapper: (SheetGraphData data, _) =>
                          double.parse(data.benchmarkReturns ?? "0.00"),
                    ),
                  ])),
        ],
      ),
    );
    
    } else {
      
      return Container();
    
    }
    
  }


  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      String title3, String value3, ThemesProvider theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title1,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value1,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600)),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title2,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(
                  value2,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title3,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value3,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600)),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ]))
        ]);
  }
}
