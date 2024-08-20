import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../profile_screen/fund_screen/secure_fund.dart';

class MFAllocation extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFAllocation({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider).factSheetDataModel!.data!;

    final List<ChartData> donutChart = [
      if (mfData.vEquity != "0")
        ChartData('Equity', double.parse(mfData.vEquity ?? "0.00"),
            const Color(0xff2e8564)),
      if (mfData.vDebt != "0")
        ChartData('Debt', double.parse(mfData.vDebt ?? "0.00"),
            const Color(0xff7cd36f)),
      if (mfData.goldPercent != "0")
        ChartData('Gold', double.parse(mfData.goldPercent ?? "0.00"),
            const Color(0xfff7cd6c)),
      if (mfData.globalEquityPercent != "0")
        ChartData(
            'Global Equity',
            double.parse(mfData.globalEquityPercent ?? "0.00"),
            const Color(0XFFfbebc4)),
      if (mfData.vOther != "0")
        ChartData('Others', double.parse(mfData.vOther ?? "0.00"),
            const Color(0XFFdedede))
    ];
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text("Asset allocation and Holdings",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      16,
                      FontWeight.w500)),
              const SizedBox(height: 8),
              Text("Fund's overall asset allocation",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                "Each fund is uniquely allocated to suit and match customer expectations based on the risk profile and return expectations.",
                style: textStyle(const Color(0xff666666), 13, FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text("Fund asset allocation",
                  style:
                      textStyle(const Color(0xff666666), 14, FontWeight.w600)),
              const SizedBox(height: 16),
              SfCircularChart(
                  legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap),
                  series: [
                    DoughnutSeries<ChartData, String>(
                        radius: "130",
                        dataSource: donutChart,
                        legendIconType: LegendIconType.circle,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelMapper: (ChartData data, _) => "${data.y}%",
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            textStyle: textStyle(
                                colors.colorBlack, 12, FontWeight.w600)),
                        innerRadius: "60%"),
                  ]),
              Text("Fund's equity sector distribution",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                "Equity Sector refers to the allocation of the fund's investments across different sectors of the economy.",
                style: textStyle(const Color(0xff666666), 13, FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text("Equity allocation by Sector",
                  style:
                      textStyle(const Color(0xff666666), 14, FontWeight.w600)),
              const SizedBox(height: 12),
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    mfData.sectors!.length > 10 ? 10 : mfData.sectors!.length,
                itemBuilder: (BuildContext context, int index) {
                  return progressBar(
                      "${mfData.sectors![index].sectorRating}",
                      mfData.sectors![index].netAsset ?? "0.00",
                      const Color(0xff2e8564),
                      theme);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
              ),
              const SizedBox(height: 16),
              Text("Fund's top stock holdings",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                "The performance of the mutual fund is significantly influenced by the performance of its top stock holdings.",
                style: textStyle(const Color(0xff666666), 13, FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text("Top Stock Holdings",
                  style:
                      textStyle(const Color(0xff666666), 14, FontWeight.w600)),
              const SizedBox(height: 12),
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    mfData.holdings!.length > 10 ? 10 : mfData.holdings!.length,
                itemBuilder: (BuildContext context, int index) {
                  return progressBar(
                      "${mfData.holdings![index].holdings}",
                      mfData.holdings![index].netAsset ?? "0.00",
                      const Color(0xff7cd36f),
                      theme);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
              )
            ]));
  }

  Column progressBar(
      String name, String val, Color color1, ThemesProvider theme) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(name,
              overflow: TextOverflow.ellipsis,
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500)),
        ),
        Text("$val%",
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500))
      ]),
      const SizedBox(height: 6),
      LinearPercentIndicator(
          lineHeight: 10.0,
          barRadius: const Radius.circular(4),
          backgroundColor: color1.withOpacity(.3),
          percent:( double.parse(val) / 100).isNegative?0.00:double.parse(val) / 100,
          padding: EdgeInsets.zero,
          progressColor: color1)
    ]);
  }
}
