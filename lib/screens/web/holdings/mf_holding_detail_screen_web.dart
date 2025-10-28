import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/thems.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
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
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(theme, context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fund Name Section
                    _buildFundNameSection(theme),
                    const SizedBox(height: 24),
                    
                    // Redeem Button
                    _buildRedeemButton(theme, ref, context),
                    const SizedBox(height: 24),
                    
                    // Returns Section
                    _buildReturnsSection(theme),
                    const SizedBox(height: 24),
                    
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

  Widget _buildHeader(ThemesProvider theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mutual Fund Details',
            style: TextWidget.textStyle(
              fontSize: 18,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundNameSection(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              holding.name ?? 'N/A',
              style: TextWidget.textStyle(
                fontSize: 20,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 3,
              ),
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Returns",
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 3,
            ),
          ),
          Text(
            "${holding.profitLoss ?? "0.00"} (${holding.changeprofitLoss ?? '0.00'}%)",
            style: TextWidget.textStyle(
              fontSize: 18,
              theme: false,
              color: _getValueColor(holding.profitLoss ?? '0.00', theme),
              fw: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Details',
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Units", holding.avgQty ?? '0', theme),
          _buildInfoRow("Avg Price", holding.avgNav ?? '0.00', theme),
          _buildInfoRow("NAV", holding.curNav ?? '0.00', theme),
          _buildInfoRow("Pledged Units", "0", theme), // This might need to be added to the data model
          _buildInfoRow("Current", holding.currentValue ?? '0.00', theme),
          _buildInfoRow("Invested", holding.investedValue ?? '0.00', theme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, ThemesProvider theme, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: false,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 2,
            ),
          ),
          Text(
            value,
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: false,
              color: valueColor ?? (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
              fw: 2,
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
