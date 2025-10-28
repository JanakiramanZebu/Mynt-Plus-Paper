import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../provider/thems.dart';
import '../../../../../provider/mf_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';

class RedemptionBottomSheetWeb extends ConsumerStatefulWidget {
  const RedemptionBottomSheetWeb({super.key});

  @override
  ConsumerState<RedemptionBottomSheetWeb> createState() => _RedemptionBottomSheetWebState();
}

class _RedemptionBottomSheetWebState extends ConsumerState<RedemptionBottomSheetWeb> {
  final TextEditingController _redemptionQtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial value to current units
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mfData = ref.read(mfProvider);
      if (mfData.holssinglelist?.isNotEmpty == true) {
        _redemptionQtyController.text = mfData.holssinglelist![0]?.avgQty ?? '0';
      }
    });
  }

  @override
  void dispose() {
    _redemptionQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final mfData = ref.watch(mfProvider);

    final holding = mfData.holssinglelist?.isNotEmpty == true ? mfData.holssinglelist![0] : null;

    if (holding == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
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
            _buildHeader(theme),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fund Name
                    _buildFundName(holding, theme),
                    const SizedBox(height: 24),
                    
                    // Redemption Form
                    _buildRedemptionForm(holding, theme, mfData),
                    const SizedBox(height: 24),
                    
                    // Fund Details
                    // _buildFundDetails(holding, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
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
            'Redeem Mutual Fund',
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

  Widget _buildFundName(dynamic holding, ThemesProvider theme) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "MF",
              style: TextWidget.textStyle(
                fontSize: 12,
                theme: false,
                color: colors.colorWhite,
                fw: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionForm(dynamic holding, ThemesProvider theme, MFProvider mfData) {
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
            'Redemption Details',
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          const SizedBox(height: 16),
          
          // Redemption Quantity Input
          Text(
            'Redemption Quantity',
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _redemptionQtyController,
            keyboardType: TextInputType.number,
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 2,
            ),
            decoration: InputDecoration(
              hintText: 'Enter quantity to redeem',
              hintStyle: TextWidget.textStyle(
                fontSize: 14,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                fw: 1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colors.primaryLight,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Available Units Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Units:',
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 2,
                ),
              ),
              Text(
                holding.avgQty ?? '0',
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Redeem Button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryLight,
                foregroundColor: colors.colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _handleRedemption(holding, mfData);
              },
              child: Text(
                'Redeem',
                style: TextWidget.textStyle(
                  fontSize: 16,
                  theme: false,
                  color: colors.colorWhite,
                  fw: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildFundDetails(dynamic holding, ThemesProvider theme) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Fund Details',
  //           style: TextWidget.textStyle(
  //             fontSize: 16,
  //             theme: theme.isDarkMode,
  //             color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
  //             fw: 3,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         _buildInfoRow('ISIN', holding.iSIN ?? 'N/A', theme),
  //         _buildInfoRow('Folio Number', holding.foliono ?? 'N/A', theme),
  //         _buildInfoRow('Units', holding.avgQty ?? '0', theme),
  //         _buildInfoRow('Average NAV', holding.avgNav ?? '0.00', theme),
  //         _buildInfoRow('Current NAV', holding.curNav ?? '0.00', theme),
  //         _buildInfoRow('Invested Value', holding.investedValue ?? '0.00', theme),
  //         _buildInfoRow('Current Value', holding.currentValue ?? '0.00', theme),
  //         _buildInfoRow(
  //           'Profit/Loss', 
  //           holding.profitLoss ?? '0.00', 
  //           theme,
  //           valueColor: _getValueColor(holding.profitLoss ?? '0.00', theme),
  //         ),
  //         _buildInfoRow(
  //           'Profit/Loss %', 
  //           '${holding.changeprofitLoss ?? '0.00'}%', 
  //           theme,
  //           valueColor: _getValueColor(holding.changeprofitLoss ?? '0.00', theme),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  void _handleRedemption(dynamic holding, MFProvider mfData) {
    final redemptionQty = _redemptionQtyController.text.trim();
    
    if (redemptionQty.isEmpty) {
      _showErrorDialog('Please enter redemption quantity');
      return;
    }

    final qty = double.tryParse(redemptionQty);
    final availableQty = double.tryParse(holding.avgQty ?? '0') ?? 0;

    if (qty == null || qty <= 0) {
      _showErrorDialog('Please enter a valid quantity');
      return;
    }

    if (qty > availableQty) {
      _showErrorDialog('Redemption quantity cannot exceed available units');
      return;
    }

    // Set redemption quantity in provider
    mfData.redemptionQty.text = redemptionQty;
    
    // Call redemption validation and process
    try {
      final minRedemptionQty = holding.minRedemptionQty;
      final netUnits = holding.avgQty;
      final navStr = holding.avgNav;

      if (mfData.checkRedemption(redemptionQty, minRedemptionQty, netUnits, navStr)) {
        final schemeCode = holding.sCHEMECODE ?? 'DefaultScheme';
        mfData.mfRedemption(context, schemeCode, redemptionQty);
      } else {
        _showErrorDialog('Please check the data you have provided');
      }
    } catch (e) {
      _showErrorDialog('Error processing redemption: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
