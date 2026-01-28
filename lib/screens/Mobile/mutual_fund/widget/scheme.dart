import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

class MFSchemeInfo extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFSchemeInfo({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final factSheetData = ref.watch(mfProvider).factSheetDataModel?.data;

    // Early return if essential data is missing
    if (factSheetData == null) {
      return const SizedBox();
    }

    final isDarkMode = theme.isDarkMode;

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Scheme Information",
              style: MyntWebTextStyles.title(
                context,
                color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Full width Scheme Information
            _buildSchemeInfoSection(context, isDarkMode, factSheetData),

            const SizedBox(height: 24),

            // Fund Manager Section (25% width)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: _buildFundManagerSection(context, isDarkMode, factSheetData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeInfoSection(BuildContext context, bool isDarkMode, dynamic factSheetData) {
    // Build investment objective description
    final schemeObjective = factSheetData.schObjective ?? '';
    final overview = factSheetData.overview ?? '';
    final investmentObjective = schemeObjective.isNotEmpty ? schemeObjective : overview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Investment Objective Title
        Text(
          "Investment Objective",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Investment Objective Description
        if (investmentObjective.isNotEmpty)
          ReadMoreText(
            investmentObjective,
            style: MyntWebTextStyles.para(
              context,
              color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
            ),
            trimLines: 4,
            trimMode: TrimMode.Line,
            trimCollapsedText: ' Read more',
            trimExpandedText: ' Read less',
            moreStyle: MyntWebTextStyles.para(
              context,
              color: MyntColors.primary,
              fontWeight: FontWeight.w500,
            ),
            lessStyle: MyntWebTextStyles.para(
              context,
              color: MyntColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),

        const SizedBox(height: 24),

        // Info Grid - Row 1
        Row(
          children: [
            _buildInfoItem(context, isDarkMode, "Launched", factSheetData.launchDate ?? "-"),
            _buildInfoItem(context, isDarkMode, "SIP Minimum", factSheetData.sipMinAmount ?? "-"),
            _buildInfoItem(context, isDarkMode, "Corpus (Cr.)", _formatCorpus(factSheetData.corpus)),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 1),
        const SizedBox(height: 16),

        // Info Grid - Row 2
        Row(
          children: [
            _buildInfoItem(context, isDarkMode, "Expense Ratio", "${factSheetData.expenseRatio ?? "-"}"),
            _buildInfoItem(context, isDarkMode, "Lumpsum Min.", factSheetData.purchaseMinAmount ?? "-"),
            _buildInfoItem(context, isDarkMode, "AMU (Cr.)", _formatAum(factSheetData.AUM)),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 1),
        const SizedBox(height: 16),

        // Info Grid - Row 3
        Row(
          children: [
            _buildInfoItem(context, isDarkMode, "Settlement type", "-"),
            _buildInfoItem(context, isDarkMode, "Lock-in", _formatExitLoad(factSheetData.exitLoad)),
            _buildInfoItem(context, isDarkMode, "Scheme type", factSheetData.category ?? "-"),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, bool isDarkMode, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.para(
              context,
              color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: MyntWebTextStyles.body(
              context,
              color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundManagerSection(BuildContext context, bool isDarkMode, dynamic factSheetData) {
    // Safely parse numbers
    final aum = double.tryParse(factSheetData.managerActiveFundsAumSum?.trim() ?? "0.00") ?? 0.00;
    final fundsManaged = (double.tryParse(factSheetData.managerNumberOfActiveFunds?.trim() ?? "0.0") ?? 0.0).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fund Manager Title
        Text(
          "Fund Manager",
          style: MyntWebTextStyles.body(
            context,
            color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Fund Manager Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Manager Image
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  "https://v3.mynt.in/mfapi/get-image/manager/${factSheetData.fundManager?.toLowerCase().trim() ?? "default"}.png",
                ),
                backgroundColor: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              ),
              const SizedBox(width: 12),
              // Manager Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factSheetData.fundManager ?? "N/A",
                      style: MyntWebTextStyles.body(
                        context,
                        color: isDarkMode ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${aum.toStringAsFixed(2)}",
                      style: MyntWebTextStyles.para(
                        context,
                        color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$fundsManaged funds managed",
                      style: MyntWebTextStyles.para(
                        context,
                        color: isDarkMode ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCorpus(String? corpus) {
    if (corpus == null || corpus.isEmpty) return "-";
    try {
      return double.parse(corpus).toStringAsFixed(0);
    } catch (e) {
      return corpus;
    }
  }

  String _formatAum(String? aum) {
    if (aum == null || aum.isEmpty) return "-";
    try {
      return double.parse(aum).toStringAsFixed(2);
    } catch (e) {
      return "-";
    }
  }

  String _formatExitLoad(String? exitLoad) {
    if (exitLoad == null || exitLoad.isEmpty || exitLoad == "null") return "-";
    return exitLoad;
  }
}
