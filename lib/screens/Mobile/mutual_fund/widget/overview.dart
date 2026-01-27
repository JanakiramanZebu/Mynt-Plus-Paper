import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../models/mf_model/mf_nav_graph_model.dart';
import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

class MFOverview extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFOverview({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfProvide = ref.watch(mfProvider);
    final navGraph = mfProvide.navGraph;
    final factSheetData = mfProvide.factSheetDataModel?.data;

    // Early return if essential data is missing
    if (factSheetData == null) {
      return const SizedBox();
    }

    final isDarkMode = theme.isDarkMode;

    // Safely create data source
    final List<NavGraphData> dataSource =
        mfProvide.singleloader == true ? [] : (navGraph?.data?.toList() ?? []);

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Fund Description Section
            _buildFundDescriptionSection(context, theme, mfProvide, factSheetData),

            const SizedBox(height: 24),

            // Trailing Returns Title
            Text(
              "Trailing Returns (%)",
              style: MyntWebTextStyles.title(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Benchmark indicator
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDarkMode ? colors.profitDark : colors.profitLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Benchmark",
                  style: MyntWebTextStyles.body(
                    context,
                    color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "(${factSheetData.benchmark ?? ""})",
                    style: MyntWebTextStyles.para(
                      context,
                      color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Returns Grid and Chart Row
            _buildReturnsAndChartSection(context, theme, mfProvide, dataSource, isDarkMode),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFundDescriptionSection(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mfProvide,
    dynamic factSheetData,
  ) {
    final isDarkMode = theme.isDarkMode;

    // Build fund name with category
    final fundName = factSheetData.name ?? mfStockData.schemeName ?? 'Unknown Fund';
    final category = mfStockData.type ?? factSheetData.category ?? '';
    final displayTitle = category.isNotEmpty ? "$fundName - $category" : fundName;

    // Build description paragraph
    final managerName = factSheetData.fundManager ?? 'N/A';
    final launchDate = factSheetData.launchDate ?? 'N/A';
    final currentNav = factSheetData.currentNAV ?? '0';
    final navDate = factSheetData.navDate ?? 'N/A';
    final aum = _formatAum(factSheetData.AUM);
    final minPurchase = factSheetData.purchaseMinAmount ?? '0';
    final minSip = factSheetData.sipMinAmount ?? '0';
    final expenseRatio = factSheetData.expenseRatio ?? '0';
    final riskLevel = factSheetData.risk ?? '0';
    final benchmark = factSheetData.benchmark ?? 'N/A';
    final oneYear = factSheetData.d1Year ?? '0';
    final threeYear = factSheetData.d3Year ?? '0';
    final fiveYear = factSheetData.d5Year ?? '0';
    final tenYear = factSheetData.d10Year ?? '0';

    final description = "The $fundName is managed by $managerName. Launched on $launchDate, "
        "the fund has a current NAV of ₹$currentNav as of $navDate. "
        "It has an AUM of ₹$aum Crores, with a minimum investment of ₹$minPurchase for purchase and ₹$minSip for SIP. "
        "The expense ratio is $expenseRatio% with a risk level of $riskLevel. "
        "The benchmark is $benchmark. "
        "Returns are $oneYear% for 1 year, $threeYear% for 3 years, $fiveYear% for 5 years, and $tenYear% for 10 years.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fund Title with Category
        Text(
          displayTitle,
          style: MyntWebTextStyles.title(
            context,
            color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        // Fund Description
        Text(
          description,
          style: MyntWebTextStyles.para(
            context,
            color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildReturnsAndChartSection(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mfProvide,
    List<NavGraphData> dataSource,
    bool isDarkMode,
  ) {
    // Create tooltip behavior for chart
    final interactiveTooltip = InteractiveTooltip(
      enable: true,
      format: 'Nav : point.y',
      borderColor: colors.colorBlue,
      textStyle: const TextStyle(color: Colors.white),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Returns Grid (Left Side - 30%)
        Expanded(
          flex: 3,
          child: _buildReturnsGrid(context, theme, mfProvide, isDarkMode),
        ),
        const SizedBox(width: 16),
        // Chart (Right Side - 70%)
        Expanded(
          flex: 7,
          child: _buildChartSection(context, isDarkMode, dataSource, interactiveTooltip, mfProvide),
        ),
      ],
    );
  }

  Widget _buildReturnsGrid(
    BuildContext context,
    ThemesProvider theme,
    MFProvider mfProvide,
    bool isDarkMode,
  ) {
    if (mfProvide.mfReturnsGridview.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No returns data available",
            style: MyntWebTextStyles.body(
              context,
              color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: List.generate(mfProvide.mfReturnsGridview.length, (index) {
        final item = mfProvide.mfReturnsGridview[index];
        final value = item['value']?.toString() ?? "0";
        final isNegative = value.startsWith("-");
        final returnValue = item['return']?.toString() ?? "0";
        final isReturnNegative = returnValue.startsWith("-");
        final durName = item['durName']?.toString() ?? "";

        return Container(
          decoration: BoxDecoration(
            color: isNegative
                ? (isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1))
                : (isDarkMode ? colors.profitDark.withOpacity(0.1) : colors.profitLight.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fund Value
              Text(
                "$value%",
                style: MyntWebTextStyles.body(
                  context,
                  color: isNegative
                      ? (isDarkMode ? MyntColors.lossDark : MyntColors.loss)
                      : (isDarkMode ? MyntColors.profitDark : MyntColors.profit),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Duration Name
              Text(
                durName,
                style: MyntWebTextStyles.para(
                  context,
                  color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // Benchmark Value (bottom section)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isReturnNegative
                      ? (isDarkMode ? colors.lossDark.withOpacity(0.3) : colors.lossLight.withOpacity(0.2))
                      : (isDarkMode ? colors.profitDark.withOpacity(0.3) : colors.profitLight.withOpacity(0.2)),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Text(
                  "$returnValue%",
                  textAlign: TextAlign.center,
                  style: MyntWebTextStyles.para(
                    context,
                    color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    bool isDarkMode,
    List<NavGraphData> dataSource,
    InteractiveTooltip interactiveTooltip,
    MFProvider mfProvide,
  ) {
    // Get the last NAV value for display
    final lastNav = dataSource.isNotEmpty ? dataSource.last.nav?.toStringAsFixed(3) ?? '--' : '--';
    final lastDate = dataSource.isNotEmpty ? _formatChartDate(dataSource.last.navDate) : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Chart Container
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: isDarkMode ? colors.colorBlack : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              SfCartesianChart(
                margin: const EdgeInsets.all(8),
                backgroundColor: isDarkMode ? colors.colorBlack : Colors.white,
                borderWidth: 0,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  isVisible: false,
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  tooltipSettings: interactiveTooltip,
                  tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                ),
                series: <CartesianSeries<NavGraphData, String>>[
                  LineSeries<NavGraphData, String>(
                    name: "Historical NAV",
                    color: colors.colorBlue,
                    width: 2,
                    dataSource: dataSource,
                    xValueMapper: (NavGraphData data, _) {
                      if (data.navDate == null) return "";
                      return data.navDate!.length > 14
                          ? data.navDate!.substring(0, data.navDate!.length - 14)
                          : data.navDate!;
                    },
                    yValueMapper: (NavGraphData data, _) => data.nav,
                  ),
                ],
              ),
              // NAV Display overlay (bottom right)
              // Positioned(
              //   bottom: 8,
              //   right: 8,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              //     decoration: BoxDecoration(
              //       color: isDarkMode ? colors.colorBlack.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              //       borderRadius: BorderRadius.circular(6),
              //       border: Border.all(
              //         color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              //       ),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.end,
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text(
              //           lastDate,
              //           style: MyntWebTextStyles.para(
              //             context,
              //             color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
              //           ),
              //         ),
              //         const SizedBox(height: 2),
              //         Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Container(
              //               width: 8,
              //               height: 8,
              //               decoration: BoxDecoration(
              //                 color: colors.colorBlue,
              //                 shape: BoxShape.circle,
              //               ),
              //             ),
              //             const SizedBox(width: 6),
              //             Text(
              //               "Nav : $lastNav",
              //               style: MyntWebTextStyles.body(
              //                 context,
              //                 color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatChartDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    try {
      // Parse date string and format it
      // Assuming format like "2024-02-13" or similar
      final parts = dateStr.split(' ')[0].split('-');
      if (parts.length >= 3) {
        return "${parts[0]}-${parts[1]}-${parts[2]}";
      }
      return dateStr.split(' ')[0];
    } catch (e) {
      return dateStr.split(' ')[0];
    }
  }

  String _formatAum(String? aum) {
    if (aum == null || aum.isEmpty) return "0.00";
    try {
      return double.parse(aum).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }
}
