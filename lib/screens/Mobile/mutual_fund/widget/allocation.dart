import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Title
            Text(
              "Asset allocation and Holdings",
              style: MyntWebTextStyles.title(
                context,
                color: isDarkMode
                    ? MyntColors.textPrimaryDark
                    : MyntColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Two column layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Side - Equity allocation by Sector (50%)
                Expanded(
                  child: _buildSectorSection(
                    context,
                    isDarkMode,
                    mfData,
                    hasSectors,
                    showMoreSectors,
                    ref,
                  ),
                ),
                const SizedBox(width: 32),
                // Right Side - Top Stock Holdings (50%)
                Expanded(
                  child: _buildHoldingsSection(
                    context,
                    isDarkMode,
                    mfData,
                    hasHoldings,
                    showMoreHoldings,
                    ref,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorSection(
    BuildContext context,
    bool isDarkMode,
    dynamic mfData,
    bool hasSectors,
    bool showMoreSectors,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Equity allocation by Sector",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Sector List
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
              return _buildSectorProgressBar(
                context,
                isDarkMode,
                sector.sectorRating ?? "",
                sector.netAsset ?? "0.00",
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 20),
          ),
          if (mfData.sectors!.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InkWell(
                onTap: () {
                  ref.read(showMoreSectorsProvider.notifier).update((state) => !state);
                },
                child: Text(
                  showMoreSectors ? "Show Less" : "Show More",
                  style: MyntWebTextStyles.body(
                    context,
                    color: MyntColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSectorProgressBar(
    BuildContext context,
    bool isDarkMode,
    String name,
    String val,
  ) {
    final double percentage = double.tryParse(val) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Value Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: MyntWebTextStyles.para(
                  context,
                  color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "$val%",
              style: MyntWebTextStyles.para(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress Bar
        LinearPercentIndicator(
          lineHeight: 8.0,
          barRadius: const Radius.circular(4),
          backgroundColor: isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.2)
              : colors.textSecondaryLight.withOpacity(0.1),
          percent: (percentage / 100).clamp(0.0, 1.0),
          padding: EdgeInsets.zero,
          progressColor: isDarkMode ? colors.profitDark : colors.profitLight,
        ),
      ],
    );
  }

  Widget _buildHoldingsSection(
    BuildContext context,
    bool isDarkMode,
    dynamic mfData,
    bool hasHoldings,
    bool showMoreHoldings,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Top Stock Holdings",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Holdings List
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
              return _buildHoldingItem(
                context,
                isDarkMode,
                holding.holdings ?? "",
                holding.netAsset ?? "0.00",
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 20),
          ),
          if (mfData.holdings!.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InkWell(
                onTap: () {
                  ref.read(showMoreHoldingsProvider.notifier).update((state) => !state);
                },
                child: Text(
                  showMoreHoldings ? "Show Less" : "Show More",
                  style: MyntWebTextStyles.body(
                    context,
                    color: MyntColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildHoldingItem(
    BuildContext context,
    bool isDarkMode,
    String name,
    String val,
  ) {
    final double percentage = double.tryParse(val) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Value Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: MyntWebTextStyles.para(
                  context,
                  color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "$val%",
              style: MyntWebTextStyles.para(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Small Progress Bar (blue)
        LinearPercentIndicator(
          lineHeight: 8.0,
          barRadius: const Radius.circular(4),
          backgroundColor: isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.2)
              : colors.textSecondaryLight.withOpacity(0.1),
          percent: (percentage / 100).clamp(0.0, 1.0),
          padding: EdgeInsets.zero,
          progressColor: isDarkMode ? colors.primaryDark : colors.primaryLight,
        ),
      ],
    );
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
