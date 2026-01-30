import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    final mfProvide = ref.watch(mfProvider);
    final mfData = mfProvide.factSheetDataModel?.data;

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
            const SizedBox(height: 24),

            // Three column layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left - Fund's overall asset allocation with chart
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                        width: 1,
                      ),
                    ),
                    child: _buildAssetAllocationSection(
                      context,
                      isDarkMode,
                      mfData,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Middle - Equity allocation by Sector
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                        width: 1,
                      ),
                    ),
                    child: _buildSectorSection(
                      context,
                      isDarkMode,
                      mfData,
                      hasSectors,
                      showMoreSectors,
                      ref,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right - Top Stock Holdings
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                        width: 1,
                      ),
                    ),
                    child: _buildHoldingsSection(
                      context,
                      isDarkMode,
                      mfData,
                      hasHoldings,
                      showMoreHoldings,
                      ref,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetAllocationSection(
    BuildContext context,
    bool isDarkMode,
    dynamic mfData,
  ) {
    // Get asset allocation data using correct property names
    final equity = double.tryParse(mfData.vEquity?.toString() ?? "0") ?? 0;
    final debt = double.tryParse(mfData.vDebt?.toString() ?? "0") ?? 0;
    final gold = double.tryParse(mfData.goldPercent?.toString() ?? "0") ?? 0;
    final globalEquity = double.tryParse(mfData.globalEquityPercent?.toString() ?? "0") ?? 0;
    // Calculate others as remainder
    final total = equity + debt + gold + globalEquity;
    final others = total > 0 ? (100 - total).clamp(0.0, 100.0) : 0.0;

    // Chart colors
    final List<Color> chartColors = [
      const Color(0xFF2E7D32), // Equity - Dark Green
      const Color(0xFF81C784), // Debt - Light Green
      const Color(0xFFFFD54F), // Gold - Yellow
      const Color(0xFFFFF9C4), // Global Equity - Light Yellow
      const Color(0xFFE0E0E0), // Others - Grey
    ];

    // Build chart data
    final List<ChartData> chartData = [];
    if (equity > 0) chartData.add(ChartData('Equity', equity, chartColors[0]));
    if (debt > 0) chartData.add(ChartData('Debt', debt, chartColors[1]));
    if (gold > 0) chartData.add(ChartData('Gold', gold, chartColors[2]));
    if (globalEquity > 0) chartData.add(ChartData('Global Equity', globalEquity, chartColors[3]));
    if (others > 0) chartData.add(ChartData('Others', others, chartColors[4]));

    // If no data, show placeholder
    if (chartData.isEmpty) {
      chartData.add(ChartData('No Data', 100, Colors.grey.shade300));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Fund's overall asset allocation",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Description
        Text(
          "Each fund is uniquely allocated to suit and match customer expectations based on the risk profile and return expectations.",
          style: MyntWebTextStyles.bodySmall(
            context,
            color: isDarkMode
                ? MyntColors.textSecondaryDark
                : MyntColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        // Sub title
        Text(
          "Fund asset allocation",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        // Donut Chart
        SizedBox(
          height: 200,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries>[
              DoughnutSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                pointColorMapper: (ChartData data, _) => data.color,
                innerRadius: '60%',
                radius: '100%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(context, isDarkMode, 'Equity', chartColors[0]),
            _buildLegendItem(context, isDarkMode, 'Debt', chartColors[1]),
            _buildLegendItem(context, isDarkMode, 'Gold', chartColors[2]),
            _buildLegendItem(context, isDarkMode, 'Global Equity', chartColors[3]),
            _buildLegendItem(context, isDarkMode, 'Others', chartColors[4]),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, bool isDarkMode, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: MyntWebTextStyles.caption(
            context,
            color: isDarkMode
                ? MyntColors.textSecondaryDark
                : MyntColors.textSecondary,
          ),
        ),
      ],
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
          "Fund's equity sector distribution",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Description
        Text(
          "Equity Sector refers to the allocation of the fund's investments across different sectors of the economy.",
          style: MyntWebTextStyles.bodySmall(
            context,
            color: isDarkMode
                ? MyntColors.textSecondaryDark
                : MyntColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        // Sub title
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  name,
                  style: MyntWebTextStyles.para(
                    context,
                    color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Text(
              "$val%",
              style: MyntWebTextStyles.caption(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Progress Bar
        LinearPercentIndicator(
          lineHeight: 6.0,
          barRadius: const Radius.circular(3),
          backgroundColor: isDarkMode
              ? colors.textSecondaryDark.withValues(alpha: 0.2)
              : colors.textSecondaryLight.withValues(alpha: 0.1),
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
          "Fund's top stock holdings",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Description
        Text(
          "The performance of the mutual fund is significantly influenced by the performance of its top stock holdings.",
          style: MyntWebTextStyles.bodySmall(
            context,
            color: isDarkMode
                ? MyntColors.textSecondaryDark
                : MyntColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        // Sub title
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  name,
                  style: MyntWebTextStyles.para(
                    context,
                    color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Text(
              "$val%",
              style: MyntWebTextStyles.caption(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Small Progress Bar (green)
        LinearPercentIndicator(
          lineHeight: 6.0,
          barRadius: const Radius.circular(3),
          backgroundColor: isDarkMode
              ? colors.textSecondaryDark.withValues(alpha: 0.2)
              : colors.textSecondaryLight.withValues(alpha: 0.1),
          percent: (percentage / 100).clamp(0.0, 1.0),
          padding: EdgeInsets.zero,
          progressColor: isDarkMode ? colors.profitDark : colors.profitLight,
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
