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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider).factSheetDataModel?.data;
    
    // Early return if data is null
    if (mfData == null) {
      return const SizedBox();
    }

    // Access state only once
    final showMoreSectors = ref.watch(showMoreSectorsProvider);
    final showMoreHoldings = ref.watch(showMoreHoldingsProvider);
    final isDarkMode = theme.isDarkMode;
    
    // Check for null or empty lists
    final hasSectors = mfData.sectors != null && mfData.sectors!.isNotEmpty;
    final hasHoldings = mfData.holdings != null && mfData.holdings!.isNotEmpty;

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Asset allocation and Holdings",
              style: textStyle(
                isDarkMode ? colors.colorWhite : colors.colorBlack,
                18,
                FontWeight.w600
              )
            ),
            const SizedBox(height: 7),
            Text(
              "Equity allocation by Sector",
              style: textStyle(const Color(0xff666666), 16, FontWeight.w600)
            ),
            const SizedBox(height: 17),
            
            if (hasSectors) ...[
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: showMoreSectors
                  ? mfData.sectors!.length
                  : (mfData.sectors!.length > 5 ? 5 : mfData.sectors!.length),
                itemBuilder: (BuildContext context, int index) {
                  final sector = mfData.sectors![index];
                  return progressBar(
                    sector.sectorRating ?? "",
                    sector.netAsset ?? "0.00",
                    const Color(0xff2e8564),
                    theme,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 18),
              ),
              
              if (mfData.sectors!.length > 5)
                TextButton(
                  onPressed: () {
                    ref.read(showMoreSectorsProvider.notifier).update((state) => !state);
                  },
                  child: Text(
                    showMoreSectors ? "Show Less" : "Show More",
                    style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                  ),
                ),
            ],
         
            const SizedBox(height: 28),
            Text(
              "Top Stock Holdings",
              style: textStyle(
                isDarkMode ? colors.colorWhite : colors.colorBlack,
                17,
                FontWeight.w600
              )
            ),
            const SizedBox(height: 10),
            
            if (hasHoldings) ...[
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: showMoreHoldings
                  ? mfData.holdings!.length
                  : (mfData.holdings!.length > 5 ? 5 : mfData.holdings!.length),
                itemBuilder: (BuildContext context, int index) {
                  final holding = mfData.holdings![index];
                  return progressBar(
                    holding.holdings ?? "",
                    holding.netAsset ?? "0.00",
                    const Color(0xff7cd36f),
                    theme,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
              ),
              
              if (mfData.holdings!.length > 5)
                TextButton(
                  onPressed: () {
                    ref.read(showMoreHoldingsProvider.notifier).update((state) => !state);
                  },
                  child: Text(
                    showMoreHoldings ? "Show Less" : "Show More",
                    style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                  ),
                ),
            ],
          ],
        ),
      )
    );
  }

  Column progressBar(String name, String val, Color color1, ThemesProvider theme) {
    final isDarkMode = theme.isDarkMode;
    // Safely parse the value
    final double percentage = double.tryParse(val) ?? 0.0;
    
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const SizedBox(height: 25),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: textStyle(
              isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500
            )
          ),
        ),
        Text(
          "$val%",
          style: textStyle(
            isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500
          )
        )
      ]),
      const SizedBox(height: 10),
      LinearPercentIndicator(
        lineHeight: 10.0,
        barRadius: const Radius.circular(4),
        backgroundColor: color1.withOpacity(.3),
        percent: (percentage / 100).clamp(0.0, 1.0),
        padding: EdgeInsets.zero,
        progressColor: color1,
      )
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
