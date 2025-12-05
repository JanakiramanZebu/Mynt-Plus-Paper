import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';

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
              const SizedBox(height: 16),
              TextWidget.titleText(
                  align: TextAlign.right,
                  text: "Asset allocation and Holdings",
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 0),
              const SizedBox(height: 12),
              TextWidget.subText(
                  align: TextAlign.right,
                  text: "Equity allocation by Sector",
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 1),
              const SizedBox(height: 8),
              if (hasSectors) ...[
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: showMoreSectors
                      ? mfData.sectors!.length
                      : (mfData.sectors!.length > 5
                          ? 5
                          : mfData.sectors!.length),
                  itemBuilder: (BuildContext context, int index) {
                    final sector = mfData.sectors![index];
                    return progressBar(
                      sector.sectorRating ?? "",
                      sector.netAsset ?? "0.00",
                      theme.isDarkMode ? colors.profitDark : colors.profitLight,
                      theme,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                ),
                if (mfData.sectors!.length > 5)
                  TextButton(
                    onPressed: () {
                      ref
                          .read(showMoreSectorsProvider.notifier)
                          .update((state) => !state);
                    },
                    child: TextWidget.subText(
                        align: TextAlign.right,
                        text: showMoreSectors ? "Show Less" : "Show More",
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 2),
                  ),
              ],
              const SizedBox(height: 8),
              TextWidget.subText(
                  align: TextAlign.right,
                  text: "Top Stock Holdings",
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 1),
              const SizedBox(height: 10),
              if (hasHoldings) ...[
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: showMoreHoldings
                      ? mfData.holdings!.length
                      : (mfData.holdings!.length > 5
                          ? 5
                          : mfData.holdings!.length),
                  itemBuilder: (BuildContext context, int index) {
                    final holding = mfData.holdings![index];
                    return progressBar(
                      holding.holdings ?? "",
                      holding.netAsset ?? "0.00",
                      theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                      theme,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                ),
                if (mfData.holdings!.length > 5)
                  TextButton(
                    onPressed: () {
                      ref
                          .read(showMoreHoldingsProvider.notifier)
                          .update((state) => !state);
                    },
                    child: TextWidget.subText(
                        align: TextAlign.right,
                        text: showMoreHoldings ? "Show Less" : "Show More",
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 2),
                  ),
              ],
            ],
          ),
        ));
  }

  Column progressBar(
      String name, String val, Color color1, ThemesProvider theme) {
    final isDarkMode = theme.isDarkMode;
    // Safely parse the value
    final double percentage = double.tryParse(val) ?? 0.0;

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const SizedBox(height: 25),
        Expanded(
          child: TextWidget.subText(
              align: TextAlign.start,
              text: name,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 0),
        ),
        TextWidget.subText(
            align: TextAlign.start,
            text: "$val%",
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
      ]),
      const SizedBox(height: 10),
      LinearPercentIndicator(
        lineHeight: 10.0,
        barRadius: const Radius.circular(4),
        backgroundColor:  theme.isDarkMode
        ? colors.textSecondaryDark.withOpacity(0.3)
        : colors.textSecondaryLight.withOpacity(0.1),
        percent: (percentage / 100).clamp(0.0, 1.0),
        padding: EdgeInsets.zero,
        progressColor: theme.isDarkMode ? color1 : color1,
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
