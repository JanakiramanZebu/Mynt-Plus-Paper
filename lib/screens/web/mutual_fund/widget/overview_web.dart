import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../models/mf_model/mf_nav_graph_model.dart';
import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

class MFOverviewWeb extends ConsumerWidget {
  final MutualFundList mfStockData;
  final String? fundName;
  final String? fundCategory;
  final String? fundImage;

  const MFOverviewWeb({
    super.key,
    required this.mfStockData,
    this.fundName,
    this.fundCategory,
    this.fundImage,
  });

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
    final List<NavGraphData> dataSource = navGraph?.data?.toList() ?? [];

    return Container(
      // color: isDarkMode ? Colors.black : Colors.white,
      color: isDarkMode ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          // color: isDarkMode ? colors.colorBlack : Colors.white,
          color: isDarkMode ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section (Fund Name & Category + Stats + Description)
            if (fundName != null) ...[
              // Title row with fund info and stats
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  children: [
                    // Fund Icon
                    if (fundImage != null && fundImage!.isNotEmpty)
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            fundImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.account_balance,
                              color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    // Fund Name & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$fundName - ${fundCategory ?? 'Equity'}",
                            style: MyntWebTextStyles.title(
                              context,
                              color: isDarkMode
                                  ? MyntColors.textPrimaryDark
                                  : MyntColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Stats on right side of header
                    Row(
                      children: [
                        _buildHeaderStat(context, isDarkMode, "NAV", "₹${factSheetData.currentNAV ?? '0'}"),
                        const SizedBox(width: 48),
                        _buildHeaderStat(context, isDarkMode, "AUM (Cr)", "₹${_formatAum(factSheetData.AUM)}"),
                        const SizedBox(width: 48),
                        _buildHeaderStat(context, isDarkMode, "Min. Inv", "₹${factSheetData.purchaseMinAmount ?? '0'}"),
                        const SizedBox(width: 48),
                        _buildHeaderStat(context, isDarkMode, "Expense", "${factSheetData.expenseRatio ?? '0'}%"),
                      ],
                    ),
                  ],
                ),
              ),
              // Full width Divider
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              ),
              // Fund Description
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Text(
                  _buildFundDescription(factSheetData, mfProvide),
                  style: MyntWebTextStyles.para(
                    context,
                    color: isDarkMode
                        ? MyntColors.textSecondaryDark
                        : MyntColors.textSecondary,
                  ).copyWith(height: 1.6),
                ),
              ),
            ],
            // Main content area
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Side - Chart (60%)
                  Expanded(
                    flex: 6,
                    child: _buildChartSection(context, isDarkMode, dataSource, mfProvide),
                  ),
                  // Right Side - Info Panel (40%)
                  Expanded(
                    flex: 4,
                    child: _buildStatsPanel(context, isDarkMode, factSheetData, mfProvide),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    bool isDarkMode,
    List<NavGraphData> dataSource,
    MFProvider mfProvide,
  ) {
    final interactiveTooltip = InteractiveTooltip(
      enable: true,
      format: 'NAV : point.y',
      borderColor:  resolveThemeColor(context, dark: MyntColors.primaryDark,light: MyntColors.primary),
      textStyle: TextStyle(color: resolveThemeColor(context, dark: MyntColors.textPrimary, light: MyntColors.textPrimaryDark)),
    );

    return SfCartesianChart(
      margin: const EdgeInsets.all(12),
      // backgroundColor: isDarkMode ? colors.colorBlack : Colors.white,
      backgroundColor: isDarkMode ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
      borderWidth: 0,
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        isVisible: false,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
      ),
      primaryYAxis: NumericAxis(
        isVisible: true,
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: isDarkMode
              ? colors.darkColorDivider.withValues(alpha: 0.3)
              : colors.colorDivider.withValues(alpha: 0.5),
          dashArray: const [4, 4],
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          fontSize: 11,
          color: isDarkMode
              ? MyntColors.textSecondaryDark
              : MyntColors.textSecondary,
        ),
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: interactiveTooltip,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        lineColor: colors.colorBlue.withValues(alpha: 0.5),
        lineWidth: 1,
      ),
      series: <CartesianSeries<NavGraphData, String>>[
        AreaSeries<NavGraphData, String>(
          name: "Historical NAV",
          color: colors.colorBlue.withValues(alpha: 0.1),
          borderColor:  resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
          borderWidth: 2,
          dataSource: dataSource,
          xValueMapper: (NavGraphData data, _) {
            if (data.navDate == null) return "";
            return _formatChartDate(data.navDate);
          },
          yValueMapper: (NavGraphData data, _) => data.nav,
        ),
      ],
    );
  }

  Widget _buildStatsPanel(
    BuildContext context,
    bool isDarkMode,
    dynamic factSheetData,
    MFProvider mfProvide,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Returns Grid (3x2)
          _buildReturnsGrid(context, isDarkMode, mfProvide, factSheetData),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, bool isDarkMode, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MyntWebTextStyles.bodySmall(
            context,
            color: isDarkMode
                ? MyntColors.textSecondaryDark
                : MyntColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReturnsGrid(BuildContext context, bool isDarkMode, MFProvider mfProvide, dynamic factSheetData) {
    if (mfProvide.mfReturnsGridview.isEmpty) {
      return const SizedBox();
    }

    final benchmark = factSheetData?.benchmark ?? 'Benchmark';
    final returns = mfProvide.mfReturnsGridview.length > 6
        ? mfProvide.mfReturnsGridview.sublist(0, 6)
        : mfProvide.mfReturnsGridview;

    // Split into 2 rows of 3
    final firstRow = returns.length >= 3 ? returns.sublist(0, 3) : returns;
    final secondRow = returns.length > 3 ? returns.sublist(3) : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Returns heading
        Text(
          "Trailing Returns (%)",
          style: MyntWebTextStyles.bodyMedium(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Benchmark indicator
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isDarkMode ? MyntColors.profitDark : MyntColors.profit,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Benchmark ($benchmark)",
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: isDarkMode
                      ? MyntColors.textSecondaryDark
                      : MyntColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // First row
        Row(
          children: firstRow.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final item = entry.value;
            final value = item['value']?.toString() ?? "0";
            final benchmarkValue = item['return']?.toString() ?? "0";
            final isNegative = value.startsWith("-");
            final durName = item['durName']?.toString() ?? "";
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < firstRow.length - 1 ? 12 : 0),
                child: _buildReturnItem(context, isDarkMode, value, durName, isNegative, benchmarkValue),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Second row
        if (secondRow.isNotEmpty)
          Row(
            children: secondRow.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final item = entry.value;
              final value = item['value']?.toString() ?? "0";
              final benchmarkValue = item['return']?.toString() ?? "0";
              final isNegative = value.startsWith("-");
              final durName = item['durName']?.toString() ?? "";
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < secondRow.length - 1 ? 12 : 0),
                  child: _buildReturnItem(context, isDarkMode, value, durName, isNegative, benchmarkValue),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReturnItem(BuildContext context, bool isDarkMode, String value, String durName, bool isNegative, String benchmarkValue) {
    // Background colors based on positive/negative - matching reference image
    // Top card: More saturated color
    final bgColor = isNegative
        ? (isDarkMode ? const Color(0xFF3D2A2A) : const Color(0xFFFFD9D9))
        : (isDarkMode ? const Color(0xFF2A3D2A) : const Color(0xFFD4F5D4));

    // Bottom card: Much lighter, almost white with tint
    final benchmarkBgColor = isNegative
        ? (isDarkMode ? const Color(0xFF2D2222) : const Color(0xFFFFF0F0))
        : (isDarkMode ? const Color(0xFF223322) : const Color(0xFFEAFAEA));

    final textColor = isNegative
        ? (isDarkMode ? MyntColors.lossDark : MyntColors.loss)
        : (isDarkMode ? MyntColors.profitDark : MyntColors.profit);

    return Column(
      children: [
        // Fund return card (top)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$value%",
                style: MyntWebTextStyles.body(
                  context,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                durName,
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: isDarkMode
                      ? MyntColors.textSecondaryDark
                      : MyntColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Benchmark return card (bottom)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: benchmarkBgColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Text(
            "$benchmarkValue%",
            style: MyntWebTextStyles.bodySmall(
              context,
              color: isDarkMode
                  ? MyntColors.textSecondaryDark
                  : MyntColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _buildFundDescription(dynamic factSheetData, MFProvider mfProvide) {
    final fundManager = factSheetData.fundManager ?? 'N/A';
    final launchDate = factSheetData.launchDate ?? 'N/A';
    final currentNAV = factSheetData.currentNAV ?? '0';
    final navDate = factSheetData.navDate ?? 'N/A';
    final aum = _formatAum(factSheetData.AUM);
    final minPurchase = factSheetData.purchaseMinAmount ?? '0';
    final minSip = factSheetData.sipMinAmount ?? '0';
    final expenseRatio = factSheetData.expenseRatio ?? '0';
    final risk = factSheetData.risk ?? '0';
    final benchmark = factSheetData.benchmark ?? 'N/A';

    // Build returns string from mfReturnsGridview
    String returnsStr = '';
    if (mfProvide.mfReturnsGridview.isNotEmpty) {
      final returnsList = mfProvide.mfReturnsGridview.map((item) {
        final value = item['value']?.toString() ?? '0';
        final durName = item['durName']?.toString() ?? '';
        return '$value% for $durName';
      }).toList();
      if (returnsList.isNotEmpty) {
        returnsStr = ' Returns are ${returnsList.join(', ')}.';
      }
    }

    return 'The fund is managed by $fundManager. Launched on $launchDate, the fund has a current NAV of ₹$currentNAV as of $navDate. It has an AUM of ₹$aum Crores, with a minimum investment of ₹$minPurchase for purchase and ₹$minSip for SIP. The expense ratio is $expenseRatio% with a risk level of $risk. The benchmark is $benchmark.$returnsStr';
  }

  String _formatChartDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final parts = dateStr.split(' ')[0].split('-');
      if (parts.length >= 3) {
        // Return short format: DD/MM
        return "${parts[2]}/${parts[1]}";
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
