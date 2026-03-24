import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

class MFSchemeInfoWeb extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFSchemeInfoWeb({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfProvide = ref.watch(mfProvider);
    final factSheetData = mfProvide.factSheetDataModel?.data;

    // Early return if essential data is missing
    if (factSheetData == null) {
      return const SizedBox();
    }

    final isDarkMode = theme.isDarkMode;

    // Build investment objective description
    final schemeObjective = factSheetData.schObjective ?? '';
    final overview = factSheetData.overview ?? '';
    final investmentObjective =
        schemeObjective.isNotEmpty ? schemeObjective : overview;

    return Container(
      // color: isDarkMode ? Colors.black : Colors.white,
      color: isDarkMode ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Two column layout: Left (title, objective, description) | Right (fund manager card)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left half - Scheme Information content
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Scheme Information",
                        style: MyntWebTextStyles.title(
                          context,
                          color: isDarkMode
                              ? MyntColors.textPrimaryDark
                              : MyntColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Investment Objective Title
                      Text(
                        "Investment Objective",
                        style: MyntWebTextStyles.body(
                          context,
                          color: isDarkMode
                              ? MyntColors.textPrimaryDark
                              : MyntColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Investment Objective Description
                      if (investmentObjective.isNotEmpty)
                        ReadMoreText(
                          investmentObjective,
                          style: MyntWebTextStyles.para(
                            context,
                            color: isDarkMode
                                ? MyntColors.textSecondaryDark
                                : MyntColors.textSecondary,
                          ).copyWith(height: 1.6),
                          trimLines: 4,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: ' Read more',
                          trimExpandedText: ' Read less',
                          moreStyle: MyntWebTextStyles.para(
                            context,
                            color: isDarkMode ? MyntColors.primaryDark : MyntColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          lessStyle: MyntWebTextStyles.para(
                            context,
                            color: isDarkMode ? MyntColors.primaryDark : MyntColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Right half - Fund Manager Card and Riskometer side by side (same height)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fund Manager label
                      Text(
                        "Fund Manager",
                        style: MyntWebTextStyles.body(
                          context,
                          color: isDarkMode
                              ? MyntColors.textPrimaryDark
                              : MyntColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Cards Row with same height
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Fund Manager Card
                            Expanded(
                              child: _buildFundManagerCardContent(context, isDarkMode, factSheetData),
                            ),
                            const SizedBox(width: 16),
                            // Riskometer Card
                            Expanded(
                              child: _buildRiskometerContent(context, isDarkMode, factSheetData.risk),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scheme Profile Section
            _buildSchemeProfileSection(context, isDarkMode, factSheetData),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.centerLeft,
              child: Divider(color: isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 1),
            ),
            const SizedBox(height: 16),

            // General Section (with Equity Cap Allocation on right)
            _buildGeneralSection(context, isDarkMode, factSheetData),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.centerLeft,
              child: Divider(color: isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 1),
            ),
            const SizedBox(height: 16),

            // Composition Section
            _buildCompositionSection(context, isDarkMode, factSheetData),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.centerLeft,
              child: Divider(color: isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 1),
            ),
            const SizedBox(height: 16),

            // Volatility Measures Section
            _buildVolatilitySection(context, isDarkMode, factSheetData),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Scheme Profile Section - 4 column matrix
  Widget _buildSchemeProfileSection(
      BuildContext context, bool isDarkMode, dynamic factSheetData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Scheme Profile",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // 4 column row: Corpus, Current Nav, 52W Low, 52W High
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(context, isDarkMode, "Corpus (Cr.)",
                _formatCorpus(factSheetData.corpus)),
            _buildInfoItem(context, isDarkMode, "Current Nav",
                _formatNav(factSheetData.currentNAV)),
            _buildInfoItem(context, isDarkMode, "52W Low",
                "₹${_formatNav(factSheetData.weekLow)}"),
            _buildInfoItem(context, isDarkMode, "52W High",
                "₹${_formatNav(factSheetData.weekHigh)}"),
          ],
        ),
      ],
    );
  }

  // Riskometer Card Content (without label)
  Widget _buildRiskometerContent(BuildContext context, bool isDarkMode, String? riskLevel) {
    // Determine which SVG to use based on risk level
    int riskIndex = _getRiskIndex(riskLevel);
    bool isHighRisk = riskIndex >= 3;
    String riskDisplayText = _getRiskDisplayText(riskLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? colors.darkColorDivider : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            isHighRisk ? assets.highRisk : assets.lowRisk,
            height: 48,
            width: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "RISK METER",
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: isDarkMode
                      ? MyntColors.textSecondaryDark
                      : MyntColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                riskDisplayText,
                style: MyntWebTextStyles.body(
                  context,
                  color: isHighRisk
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C55E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Get display text for risk level
  String _getRiskDisplayText(String? riskLevel) {
    if (riskLevel == null || riskLevel.isEmpty) return "-";
    final normalizedRisk = riskLevel.toLowerCase().trim();

    // Handle text-based risk levels
    if (normalizedRisk.contains('very high')) return "Very High";
    if (normalizedRisk.contains('moderately high')) return "Moderately High";
    if (normalizedRisk.contains('high')) return "High";
    if (normalizedRisk.contains('moderately low')) return "Moderately Low";
    if (normalizedRisk.contains('moderate')) return "Moderate";
    if (normalizedRisk.contains('low')) return "Low";

    // Handle numeric risk levels (1-6 scale)
    final numericRisk = int.tryParse(normalizedRisk);
    if (numericRisk != null) {
      switch (numericRisk) {
        case 1:
          return "Low";
        case 2:
          return "Moderately Low";
        case 3:
          return "Moderate";
        case 4:
          return "Moderately High";
        case 5:
          return "High";
        case 6:
          return "Very High";
        default:
          return "-";
      }
    }

    return riskLevel;
  }

  int _getRiskIndex(String? riskLevel) {
    if (riskLevel == null || riskLevel.isEmpty) return -1;
    final normalizedRisk = riskLevel.toLowerCase().trim();

    // Handle text-based risk levels
    if (normalizedRisk.contains('very high')) return 5;
    if (normalizedRisk.contains('high') && !normalizedRisk.contains('moderately')) return 4;
    if (normalizedRisk.contains('moderately high')) return 3;
    if (normalizedRisk.contains('moderate') && !normalizedRisk.contains('moderately')) return 2;
    if (normalizedRisk.contains('moderately low')) return 1;
    if (normalizedRisk.contains('low') && !normalizedRisk.contains('moderately')) return 0;

    // Handle numeric risk levels (1-6 scale maps to index 0-5)
    final numericRisk = int.tryParse(normalizedRisk);
    if (numericRisk != null && numericRisk >= 1 && numericRisk <= 6) {
      return numericRisk - 1; // Convert 1-6 to 0-5 index
    }

    return -1;
  }

  // General Section - 4 column matrix (Exit Load, Expense Ratio, Large Cap, Mid Cap)
  Widget _buildGeneralSection(
      BuildContext context, bool isDarkMode, dynamic factSheetData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "General",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // 4 column row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(context, isDarkMode, "Exit Load",
                _formatExitLoad(factSheetData.exitLoad)),
            _buildInfoItem(context, isDarkMode, "Expense Ratio",
                "${factSheetData.expenseRatio ?? "-"}"),
            _buildInfoItem(context, isDarkMode, "Large Cap (%)",
                _formatCapValue(factSheetData.largeCap)),
            _buildInfoItem(context, isDarkMode, "Mid Cap (%)",
                _formatCapValue(factSheetData.midCap)),
          ],
        ),
      ],
    );
  }

  // Composition Section - 4 column matrix
  Widget _buildCompositionSection(
      BuildContext context, bool isDarkMode, dynamic factSheetData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Composition (%)",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // 4 column row: Equity, Debt, Global Equity, Others
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(context, isDarkMode, "Equity",
                _formatPercentValue(factSheetData.vEquity)),
            _buildInfoItem(context, isDarkMode, "Debt",
                _formatPercentValue(factSheetData.vDebt)),
            _buildInfoItem(context, isDarkMode, "Global Equity",
                _formatPercentValue(factSheetData.globalEquityPercent)),
            _buildInfoItem(context, isDarkMode, "Others",
                _formatPercentValue(factSheetData.vOther)),
          ],
        ),
      ],
    );
  }

  // Volatility Measures Section - 4 column matrix
  Widget _buildVolatilitySection(
      BuildContext context, bool isDarkMode, dynamic factSheetData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Volatility Measures",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode
                ? MyntColors.textPrimaryDark
                : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // Row 1 - 4 columns: Alpha, Sharpe Ratio, Mean, Beta
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(context, isDarkMode, "Alpha",
                _formatVolatilityValue(factSheetData.alpha)),
            _buildInfoItem(context, isDarkMode, "Sharpe Ratio",
                _formatVolatilityValue(factSheetData.sharpRatio)),
            _buildInfoItem(context, isDarkMode, "Mean",
                _formatVolatilityValue(factSheetData.mean)),
            _buildInfoItem(context, isDarkMode, "Beta",
                _formatVolatilityValue(factSheetData.beta)),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2 - 4 columns: Std. Deviation, YTM, Modified Duration, Average Maturity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(context, isDarkMode, "Std. Deviation",
                _formatVolatilityValue(factSheetData.standardDev)),
            _buildInfoItem(context, isDarkMode, "YTM",
                _formatVolatilityValue(factSheetData.ytm)),
            _buildInfoItem(context, isDarkMode, "Modified Duration",
                _formatVolatilityValue(factSheetData.modifiedDuration)),
            _buildInfoItem(context, isDarkMode, "Average Maturity",
                _formatVolatilityValue(factSheetData.avgMat)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(
      BuildContext context, bool isDarkMode, String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: MyntWebTextStyles.para(
                context,
                color: isDarkMode
                    ? MyntColors.textSecondaryDark
                    : MyntColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: MyntWebTextStyles.body(
                context,
                color: isDarkMode
                    ? MyntColors.textPrimaryDark
                    : MyntColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fund Manager Card Content (without label)
  Widget _buildFundManagerCardContent(
      BuildContext context, bool isDarkMode, dynamic factSheetData) {
    final aum = double.tryParse(
            factSheetData.managerActiveFundsAumSum?.trim() ?? "0.00") ??
        0.00;
    final fundsManaged = (double.tryParse(
                factSheetData.managerNumberOfActiveFunds?.trim() ?? "0.0") ??
            0.0)
        .ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              "https://v3.mynt.in/mfapi/get-image/manager/${factSheetData.fundManager?.toLowerCase().replaceAll(' ', '') ?? "default"}.png",
            ),
            backgroundColor:
                isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                factSheetData.fundManager ?? "N/A",
                style: MyntWebTextStyles.body(
                  context,
                  color: isDarkMode
                      ? MyntColors.textPrimaryDark
                      : MyntColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹${aum.toStringAsFixed(2)}",
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: isDarkMode
                      ? MyntColors.textPrimaryDark
                      : MyntColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "$fundsManaged funds managed",
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: isDarkMode
                      ? MyntColors.textSecondaryDark
                      : MyntColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCorpus(String? corpus) {
    if (corpus == null || corpus.isEmpty || corpus == "null") return "-";
    try {
      return double.parse(corpus).toStringAsFixed(0);
    } catch (e) {
      return corpus;
    }
  }

  String _formatExitLoad(String? exitLoad) {
    if (exitLoad == null || exitLoad.isEmpty || exitLoad == "null") return "-";
    return exitLoad;
  }

  String _formatNav(String? nav) {
    if (nav == null || nav.isEmpty || nav == "null") return "-";
    try {
      return double.parse(nav).toStringAsFixed(4);
    } catch (e) {
      return nav;
    }
  }

  String _formatPercentValue(String? value) {
    if (value == null || value.isEmpty || value == "null" || value == "0" || value == "0.0") {
      return "N/A";
    }
    try {
      final numValue = double.parse(value);
      if (numValue == 0) return "N/A";
      return numValue.toStringAsFixed(2);
    } catch (e) {
      return value;
    }
  }

  String _formatVolatilityValue(String? value) {
    if (value == null || value.isEmpty || value == "null") return "-";
    try {
      final numValue = double.parse(value);
      if (numValue == 0) return "-";
      return numValue.toStringAsFixed(2);
    } catch (e) {
      return value;
    }
  }

  String _formatCapValue(String? value) {
    if (value == null || value.isEmpty || value == "null") return "-";
    try {
      final numValue = double.parse(value);
      if (numValue == 0) return "-";
      return numValue.toStringAsFixed(2);
    } catch (e) {
      return value;
    }
  }
}
