import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class MFAllocation extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFAllocation({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider).factSheetDataModel!.data!;
    final showMoreSectors = watch(showMoreSectorsProvider).state;
    final showMoreHoldings = watch(showMoreHoldingsProvider).state;

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
          const SizedBox(height: 20),
          Text("Asset allocation and Holdings",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  18,
                  FontWeight.w600)),
          const SizedBox(height: 7),
          Text("Equity allocation by Sector",
              style: textStyle(const Color(0xff666666), 16, FontWeight.w600)),
          const SizedBox(height: 17),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: showMoreSectors
                ? mfData.sectors!.length
                : (mfData.sectors!.length > 5 ? 5 : mfData.sectors!.length),
            itemBuilder: (BuildContext context, int index) {
              return progressBar(
                "${mfData.sectors![index].sectorRating}",
                mfData.sectors![index].netAsset ?? "0.00",
                const Color(0xff2e8564),
                theme,
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 18);
            },
          ),
          if (mfData.sectors!.length > 5)
            TextButton(
              onPressed: () {
                context.read(showMoreSectorsProvider).state =
                    !showMoreSectors;
              },
              child: Text(
                showMoreSectors ? "Show Less" : "Show More",
                style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
              ),
            ),
         
          const SizedBox(height: 28),
          Text("Top Stock Holdings",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  17,
                  FontWeight.w600)),
          const SizedBox(height: 10),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: showMoreHoldings
                ? mfData.holdings!.length
                : (mfData.holdings!.length > 5 ? 5 : mfData.holdings!.length),
            itemBuilder: (BuildContext context, int index) {
              return progressBar(
                "${mfData.holdings![index].holdings}",
                mfData.holdings![index].netAsset ?? "0.00",
                const Color(0xff7cd36f),
                theme,
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 10);
            },
          ),
          if (mfData.holdings!.length > 5)
            TextButton(
              onPressed: () {
                context.read(showMoreHoldingsProvider).state =
                    !showMoreHoldings;
              },
              child: Text(
                showMoreHoldings ? "Show Less" : "Show More",
                style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Column progressBar(
      String name, String val, Color color1, ThemesProvider theme) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    const SizedBox(height: 25),
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
      const SizedBox(height: 10),
      LinearPercentIndicator(
          lineHeight: 10.0,
          barRadius: const Radius.circular(4),
          backgroundColor: color1.withOpacity(.3),
          percent: (double.parse(val) / 100).isNegative
              ? 0.00
              : double.parse(val) / 100,
          padding: EdgeInsets.zero,
          progressColor: color1)
    ]);
  }
}

final showMoreSectorsProvider = StateProvider<bool>((ref) => false);
final showMoreHoldingsProvider = StateProvider<bool>((ref) => false);

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
