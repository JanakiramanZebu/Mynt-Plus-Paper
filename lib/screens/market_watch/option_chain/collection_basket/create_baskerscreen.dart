import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/basket_backtest_analysisi.dart';
import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/collection_basket_list.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

class StrategyBuilderScreen extends ConsumerStatefulWidget {
  const StrategyBuilderScreen({super.key});

  @override
  ConsumerState<StrategyBuilderScreen> createState() =>
      _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends ConsumerState<StrategyBuilderScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final strategy = ref.watch(dashboardProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        appBar: AppBar(
          leadingWidth: 48,
          titleSpacing: 0,
          centerTitle: false,
          leading: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                  ? colors.splashColorDark
                  : colors.splashColorLight,
              highlightColor: theme.isDarkMode
                  ? colors.highlightDark
                  : colors.highlightLight,
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 18,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                ),
              ),
            ),
          ),
          elevation: 0.2,
          title: Row(
            children: [
              TextWidget.titleText(
                text: strategy.isEditingMode
                    ? "${strategy.strategyNameController.text}"
                    : "New Strategy",
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
              if (strategy.isEditingMode) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _showSaveStrategyDialog(),
                  child: Icon(Icons.edit, size: 18, color: colors.iconColor),
                ),
              ],
            ],
          ),
          // actions: [
          //   TextButton(
          //     onPressed: 
          //     child: TextWidget.subText(
          //       text: strategy.isEditingMode ? 'Update' : 'Save',
          //       theme: theme.isDarkMode,
          //       color: strategy.isStrategyValid
          //           ? colors.colorBlue
          //           : colors.textSecondaryLight,
          //       fw: 1,
          //     ),
          //   ),
          // ],
        ),
        body: SafeArea(
          child: strategy.isStrategyLoading
              ? Center(child: CircularLoaderImage())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Strategy Type Selection
                      Row(
                        children:
                            ['Buy and Hold', 'Rebalance', 'Risk Targeting']
                                .map((type) => Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: _buildStrategyTypeChip(
                                          type,
                                          strategy.selectedStrategyType == type,
                                          theme),
                                    ))
                                .toList(),
                      ),
                      const SizedBox(height: 20),

                      // Strategy Builder Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selected Funds List
                            ...strategy.selectedFunds.map(
                                (fund) => _buildStrategyFundItem(fund, theme)),

                            const Divider(height: 1),

                            // Add More Funds Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: theme.isDarkMode
                                    ? colors.splashColorDark
                                    : colors.splashColorLight,
                                highlightColor: theme.isDarkMode
                                    ? colors.highlightDark
                                    : colors.highlightLight,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FundSelectionScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: colors.colorBlue,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      TextWidget.subText(
                                        text: 'Add more funds',
                                        theme: theme.isDarkMode,
                                        color: colors.colorBlue,
                                        fw: 0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Total Percentage
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.colorBlue.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget.subText(
                                        text: 'Total',
                                        theme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fw: 1,
                                      ),
                                      Row(
                                        children: [
                                          TextWidget.subText(
                                            text:
                                                '${strategy.totalPercentage.round()}%',
                                            theme: theme.isDarkMode,
                                            color:
                                                strategy.totalPercentage == 100
                                                    ? colors.successLight
                                                    : colors.lossLight,
                                            fw: 1,
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            strategy.totalPercentage == 100
                                                ? Icons.check_circle
                                                : Icons.warning,
                                            size: 16,
                                            color:
                                                strategy.totalPercentage == 100
                                                    ? colors.successLight
                                                    : colors.lossLight,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (strategy.totalPercentage != 100) ...[
                                    const SizedBox(height: 8),
                                    TextWidget.captionText(
                                      text:
                                          'Total must equal 100% to save strategy',
                                      theme: theme.isDarkMode,
                                      color: colors.lossLight,
                                      fw: 0,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Investment Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.subText(
                              text: 'Investment Details',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 1,
                            ),
                            const SizedBox(height: 16),

                            // Investment Type
                            Row(
                              children: [
                                'One-time',
                              ]
                                  .map((type) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: _buildInvestmentTypeChip(
                                            type,
                                            strategy.selectedInvestmentType ==
                                                type,
                                            theme),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),

                            // Initial Amount
                            TextWidget.subText(
                              text: 'Initial amount',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 40,
                              child: TextFormField(
                                controller: strategy.investmentController,
                                style: TextWidget.textStyle(
                                  fontSize: 18,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  fw: 1,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}$'))
                                ],
                                decoration: InputDecoration(
                                  prefixText: '₹ ',
                                  prefixStyle: TextWidget.textStyle(
                                    fontSize: 18,
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 1,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                onChanged: (value) {
                               strategy.validateInvestmentAmount(value);
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Duration
                            TextWidget.subText(
                              text: 'Over a duration of',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                '1Y',
                                '3Y',
                                '5Y',
                                '10Y',
                              ]
                                  .map((duration) => _buildDurationChip(
                                      duration,
                                      strategy.selectedDuration == duration,
                                      theme))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Backtest Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: strategy.isStrategyValid
                              ? () => _handleBacktestAction(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.colorBlue,
                            disabledBackgroundColor:
                                colors.textSecondaryLight.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: TextWidget.subText(
                            text: strategy.backtestButtonText,
                            theme: theme.isDarkMode,
                            color: Colors.white,
                            fw: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStrategyTypeChip(
      String text, bool isSelected, ThemesProvider theme) {
    return GestureDetector(
      onTap: () {
        ref.read(dashboardProvider).updateStrategyType(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? colors.colorBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.colorBlue : colors.textSecondaryLight,
          ),
        ),
        child: TextWidget.subText(
          text: text,
          theme: theme.isDarkMode,
          color: isSelected
              ? Colors.white
              : (theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight),
          fw: isSelected ? 0 : 3,
        ),
      ),
    );
  }

  Widget _buildStrategyFundItem(FundListModel fund, ThemesProvider theme) {
    final strategy = ref.read(dashboardProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Fund Image
          CircleAvatar(
            radius: 20,
            backgroundColor:
                theme.isDarkMode ? colors.darkGrey : colors.colorGrey,
            child: CircleAvatar(
              radius: 18,
              backgroundColor:
                  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              child: ClipOval(
                child: Image.network(
                  "https://v3.mynt.in/mfapi/static/images/mf/${fund.aMCCode ?? ""}.png",
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      strategy.getFundTypeIcon(fund.type),
                      color: strategy.getFundTypeColor(fund.type,
                          isDarkMode: theme.isDarkMode),
                      size: 18,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Fund Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.subText(
                  text: _capitalizeEachWord(fund.name),
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: strategy
                            .getFundTypeColor(fund.type,
                                isDarkMode: theme.isDarkMode)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: strategy
                              .getFundTypeColor(fund.type,
                                  isDarkMode: theme.isDarkMode)
                              .withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: TextWidget.captionText(
                        text: fund.type.toUpperCase(),
                        theme: theme.isDarkMode,
                        color: strategy.getFundTypeColor(fund.type,
                            isDarkMode: theme.isDarkMode),
                        fw: 0,
                      ),
                    ),
                    if (fund.aum > 0) ...[
                      const SizedBox(width: 8),
                      TextWidget.captionText(
                        text: 'AUM: ₹${_formatAumValue(fund.aum)}',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Percentage - Editable
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: strategy.percentageControllers[fund.name],
              style: TextWidget.textStyle(
                fontSize: 14,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: '%',
                suffixStyle: TextWidget.textStyle(
                  fontSize: 12,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: colors.colorBlue,
                    width: 1.0,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                isDense: true,
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value);
                if (intValue != 0 &&
                    intValue != null &&
                    intValue >= 0 &&
                    intValue <= 100) {
                  strategy.updateFundPercentage(fund, intValue.toDouble());
                } else if (value.isEmpty) {
                  // strategy.updateFundPercentage(fund, fund.percentage);
                  strategy.updateFundPercentage(fund, 0);
                  return;
                } else {
                  // Reset to current value if invalid input
                  strategy.updateFundPercentage(fund, fund.percentage);
                }
              },
              onFieldSubmitted: (value) {
                final intValue = int.tryParse(value);
                if (intValue != null && intValue >= 0 && intValue <= 100) {
                  strategy.updateFundPercentage(fund, intValue.toDouble());
                } else {
                  // Reset to current value if invalid input
                  strategy.updateFundPercentage(fund, fund.percentage);
                }
              },
            ),
          ),

          // Remove Button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: theme.isDarkMode
                  ? colors.splashColorDark
                  : colors.splashColorLight,
              highlightColor: theme.isDarkMode
                  ? colors.highlightDark
                  : colors.highlightLight,
              onTap: () {
                strategy.removeFundFromStrategy(fund);
              },
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Icon(
                  Icons.remove_circle_outline,
                  size: 18,
                  color: colors.lossLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentTypeChip(
      String text, bool isSelected, ThemesProvider theme) {
    return GestureDetector(
      onTap: () {
        ref.read(dashboardProvider).updateInvestmentType(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.colorBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.colorBlue : colors.textSecondaryLight,
          ),
        ),
        child: TextWidget.subText(
          text: text,
          theme: theme.isDarkMode,
          color: isSelected
              ? Colors.white
              : (theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight),
          fw: isSelected ? 1 : 0,
        ),
      ),
    );
  }

  Widget _buildDurationChip(
      String text, bool isSelected, ThemesProvider theme) {
    return GestureDetector(
      onTap: () {
        ref.read(dashboardProvider).updateDuration(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.colorBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.colorBlue : colors.textSecondaryLight,
          ),
        ),
        child: TextWidget.subText(
          text: text,
          theme: theme.isDarkMode,
          color: isSelected
              ? Colors.white
              : (theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight),
          fw: isSelected ? 1 : 0,
        ),
      ),
    );
  }

  void _updateStrategy(BuildContext context) {
    ref.read(dashboardProvider).updateStrategy(context);
    // _showUpdateSuccessDialog();
  }

  void _handleBacktestAction(BuildContext context) async {
    final strategy = ref.read(dashboardProvider);
    
    try {
      // If it's a new strategy or values have changed, save/update first
      if (!strategy.isEditingMode || strategy.hasStrategyChanged) {
        if (strategy.isEditingMode) {
          // Update existing strategy
          await strategy.updateStrategy(context);
        } else {
          // Save new strategy - show dialog for name input
          _showSaveStrategyDialog();
          return; // Exit early as dialog will handle the rest
        }
      }
      
      // Proceed with backtest
      await _performBacktest(context);
      
    } catch (e) {
      error(context, 'Failed to process strategy. Please try again.');
    }
  }

  Future<void> _performBacktest(BuildContext context) async {
    final strategy = ref.read(dashboardProvider);
    
    try {
      // Handle backtest
      strategy.backtestAnalysis(
          uuid: strategy.editingStrategy?.data?.first.uuid ?? '');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BasketBacktestAnalysisScreen(),
        ),
      );
      
      successMessage(context, 'Backtest functionality will be implemented');
      
    } catch (e) {
      error(context, 'Failed to start backtest. Please try again.');
    }
  }

  void _showSaveStrategyDialog() {
    final theme = ref.read(themeProvider);
    final strategy = ref.read(dashboardProvider);
    setState(() {
      strategy.strategyNameController.text = "";
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        title: TextWidget.titleText(
          text: 'Save Strategy',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget.subText(
              text: 'Enter a name for your strategy',
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: strategy.strategyNameController,
              style: TextWidget.textStyle(
                fontSize: 16,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
              decoration: InputDecoration(
                hintText: 'Strategy name',
                hintStyle: TextWidget.textStyle(
                  fontSize: 16,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colors.colorBlue,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: TextWidget.subText(
              text: 'Cancel',
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
          TextButton(
            onPressed: () async {
              if (strategy.strategyNameController.text.trim().isNotEmpty) {
                try {
                  if (strategy.isEditingMode) {
                    setState(() {
                      strategy.editingStrategy?.data?.first.basketName =
                          strategy.strategyNameController.text.trim();
                    });
                    Navigator.of(context).pop();
                    // After updating, proceed with backtest
                    await _performBacktest(context);
                  } else {
                    await ref.read(dashboardProvider).saveStrategy(
                        strategy.strategyNameController.text.trim());
                    Navigator.of(context).pop();
                    // After saving, proceed with backtest
                    await _performBacktest(context);
                    Navigator.of(context).pop();
                  }

                  // _showSuccessDialog();
                } catch (e) {
                  Navigator.of(context).pop();
                  error(context, 'Failed to save strategy. Please try again.');
                }
              }
            },
            child: TextWidget.subText(
              text: 'Save',
              theme: theme.isDarkMode,
              color: colors.colorBlue,
              fw: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateSuccessDialog() {
    final theme = ref.read(themeProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        title: TextWidget.titleText(
          text: 'Strategy Updated',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        content: TextWidget.subText(
          text: 'Your investment strategy has been updated successfully.',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: TextWidget.subText(
              text: 'OK',
              theme: theme.isDarkMode,
              color: colors.colorBlue,
              fw: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final theme = ref.read(themeProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        title: TextWidget.titleText(
          text: 'Strategy Saved',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        content: TextWidget.subText(
          text: 'Your investment strategy has been saved successfully.',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: TextWidget.subText(
              text: 'OK',
              theme: theme.isDarkMode,
              color: colors.colorBlue,
              fw: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeEachWord(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatAumValue(double aum) {
    if (aum >= 10000000) {
      // 1 crore
      return '${(aum / 10000000).toStringAsFixed(1)}Cr';
    } else if (aum >= 100000) {
      // 1 lakh
      return '${(aum / 100000).toStringAsFixed(1)}L';
    } else if (aum >= 1000) {
      // 1 thousand
      return '${(aum / 1000).toStringAsFixed(1)}K';
    } else {
      return aum.toStringAsFixed(0);
    }
  }
}
