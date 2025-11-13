import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/thems.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../ordersbook/mf/redeem_bottom_sheet_web.dart';

class MfHoldingDetailScreenWeb extends ConsumerWidget {
  final dynamic holding;
  
  const MfHoldingDetailScreenWeb({
    super.key,
    required this.holding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    holding.name ?? 'N/A',
                    style: WebTextStyles.dialogTitle(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.15)
                          : Colors.black.withOpacity(.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.08)
                          : Colors.black.withOpacity(.08),
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: theme.isDarkMode
                              ? WebDarkColors.iconSecondary
                              : WebColors.iconSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Returns Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _buildReturnsSection(theme),
                    ),
                    
                    // Details Section
                    _buildDetailsSection(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildRedeemButton(ThemesProvider theme, WidgetRef ref, BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
            side: BorderSide(
              color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            final mfData = ref.read(mfProvider);
            // Set the holding data for redemption using the ISIN
            mfData.fetchmfholdsingpage(holding.iSIN ?? '');
            // Call the redeem evaluation function
            mfData.recdemevalu();
            Navigator.of(context).pop();
            // Show web redeem dialog
            showDialog(
              context: context,
              builder: (context) => const RedemptionBottomSheetWeb(),
            );
          },
          child: Text(
            'Redeem',
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: false,
              color: colors.primaryLight,
              fw: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnsSection(ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "Returns",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                fontWeight: WebFonts.medium,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${holding.profitLoss ?? "0.00"}",
              style: WebTextStyles.head(
                isDarkTheme: theme.isDarkMode,
                color: _getValueColor(holding.profitLoss ?? '0.00', theme),
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemesProvider theme) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Units", holding.avgQty ?? '0', theme),
                  _buildInfoRow("Avg Price", holding.avgNav ?? '0.00', theme),
                  _buildInfoRow("NAV", holding.curNav ?? '0.00', theme),
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.isDarkMode
                  ? WebDarkColors.divider
                  : WebColors.divider,
            ),
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Pledged Units", "0", theme), // This might need to be added to the data model
                  _buildInfoRow("Current Value", holding.currentValue ?? '0.00', theme),
                  _buildInfoRow("Invested", holding.investedValue ?? '0.00', theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, ThemesProvider theme, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
          Text(
            value,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: valueColor ?? (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (numValue < 0) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    }
  }
}
