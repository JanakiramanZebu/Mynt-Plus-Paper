import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/basket_backtest_analysisi.dart';
import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/collection_basket_list.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';

class StrategyBuilderScreen extends ConsumerStatefulWidget {
  const StrategyBuilderScreen({super.key});

  @override
  ConsumerState<StrategyBuilderScreen> createState() =>
      _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends ConsumerState<StrategyBuilderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider).Basketsearch("");
    });
  }

  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final strategy = ref.watch(dashboardProvider);

    return PopScope(
        canPop: false, // Prevent automatic back navigation
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return; // If system handled back, do nothing

          // Check if there are unsaved changes
          if (strategy.hasStrategyChanged) {
            await _showUnsavedChangesDialog();
          } else {
            Navigator.of(context).pop();
          }
        },
        child: GestureDetector(
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
                  onTap: () => _handleBackNavigation(),
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
                      child:
                          Icon(Icons.edit, size: 18, color: colors.iconColor),
                    ),
                  ],
                ],
              ),
              actions: [
                if (strategy.selectedFunds.isNotEmpty) ...[
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                          onTap: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 150));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FundSelectionScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                  ),
                ]
              ],
            ),
            body: SafeArea(
              child: strategy.isStrategyLoading
                  ? Center(child: CircularLoaderImage())
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Strategy Type Selection
                                SizedBox(
                                  height: 35,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: [
                                      'Buy and Hold',
                                    ].length,
                                    itemBuilder: (context, index) {
                                      final type = [
                                        'Buy and Hold',
                                      ][index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: _buildStrategyTypeChip(
                                          type,
                                          strategy.selectedStrategyType == type,
                                          theme,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Strategy Builder Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Show NoDataFound when no funds selected
                                    if (strategy.selectedFunds.isEmpty) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 40),
                                        child: Column(
                                          children: [
                                            SvgPicture.asset(assets.noDatafound,
                                                color: Color(0xff777777)),
                                            const SizedBox(height: 2),
                                            TextWidget.subText(
                                                text: "No Funds",
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 0,
                                                theme: theme.isDarkMode),
                                            const SizedBox(height: 16),
                                            TextWidget.subText(
                                              text:
                                                  'Start building your investment strategy',
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              fw: 0,
                                            ),
                                            const SizedBox(height: 8),
                                            TextWidget.captionText(
                                              text:
                                                  'Add funds to create a diversified portfolio',
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                      .withOpacity(0.7)
                                                  : colors.textSecondaryLight
                                                      .withOpacity(0.7),
                                              fw: 0,
                                            ),
                                            const SizedBox(height: 24),
                                            // Attractive CTA Button
                                            Container(
                                              // width: double.infinity,
                                              width: 150,
                                              height: 45,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const FundSelectionScreen(),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      theme.isDarkMode
                                                          ? colors.primaryDark
                                                          : colors.primaryLight,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      assets.addCircleIcon,
                                                      width: 20,
                                                      height: 20,
                                                      color: colors.colorWhite,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    TextWidget.subText(
                                                      text: 'Add Funds',
                                                      theme: theme.isDarkMode,
                                                      color: colors.colorWhite,
                                                      fw: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      // Selected Funds List
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            strategy.selectedFunds.length,
                                        separatorBuilder: (context, index) =>
                                            const ListDivider(),
                                        itemBuilder: (context, index) {
                                          final fund =
                                              strategy.selectedFunds[index];
                                          return _buildStrategyFundItem(
                                              fund, theme);
                                        },
                                      ),

                                      // Add More Funds Button
                                    ],

                                    // Total Percentage
                                    // if (strategy.selectedFunds.isNotEmpty) ...[
                                    //   Container(
                                    //     padding: const EdgeInsets.all(8),
                                    //     decoration: BoxDecoration(
                                    //       color: colors.colorBlue.withOpacity(0.05),

                                    //     ),
                                    //     child: Column(
                                    //       children: [
                                    //         Row(
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment.spaceBetween,
                                    //           children: [
                                    //             TextWidget.titleText(
                                    //               text: 'Total',
                                    //               theme: theme.isDarkMode,
                                    //               color: theme.isDarkMode
                                    //                   ? colors.textPrimaryDark
                                    //                   : colors.textPrimaryLight,
                                    //               fw: 1,
                                    //             ),
                                    //             Row(
                                    //               children: [
                                    //                 TextWidget.titleText(
                                    //                   text:
                                    //                       '${strategy.totalPercentage.round()}%',
                                    //                   theme: theme.isDarkMode,
                                    //                   color:
                                    //                       strategy.totalPercentage == 100
                                    //                           ? colors.successLight
                                    //                           : colors.lossLight,
                                    //                   fw: 1,
                                    //                 ),
                                    //                 // const SizedBox(width: 8),
                                    //                 // Icon(
                                    //                 //   strategy.totalPercentage == 100
                                    //                 //       ? Icons.check_circle
                                    //                 //       : Icons.warning,
                                    //                 //   size: 16,
                                    //                 //   color:
                                    //                 //       strategy.totalPercentage == 100
                                    //                 //           ? colors.successLight
                                    //                 //           : colors.lossLight,
                                    //                 // ),
                                    //               ],
                                    //             ),
                                    //           ],
                                    //         ),
                                    //         // if (strategy.totalPercentage != 100) ...[
                                    //         //   const SizedBox(height: 8),
                                    //         //   TextWidget.captionText(
                                    //         //     text: strategy.selectedFunds.any((fund) => fund.percentage == 0)
                                    //         //         ? 'All funds must have valid percentage values and total must equal 100%'
                                    //         //         : 'Total must equal 100% to save strategy',
                                    //         //     theme: theme.isDarkMode,
                                    //         //     color: colors.lossLight,
                                    //         //     fw: 0,
                                    //         //   ),
                                    //         // ],
                                    //         // if (strategy.totalPercentage == 100 &&
                                    //         //     strategy.selectedFunds.any((fund) => fund.percentage == 0)) ...[
                                    //         //   const SizedBox(height: 8),
                                    //         //   TextWidget.captionText(
                                    //         //     text:
                                    //         //         'All funds must have valid percentage values (greater than 0%)',
                                    //         //     theme: theme.isDarkMode,
                                    //         //     color: colors.lossLight,
                                    //         //     fw: 0,
                                    //         //   ),
                                    //         // ],
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (strategy.selectedFunds.isNotEmpty) ...[
                          // Continue Button - Show investment details bottom sheet
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: strategy.isStrategyValid
                                    ? () => _showInvestmentDetailsBottomSheet(
                                        context)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.colorBlue,
                                  disabledBackgroundColor: colors
                                      .textSecondaryLight
                                      .withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: TextWidget.subText(
                                  text: 'Continue',
                                  theme: theme.isDarkMode,
                                  color: Colors.white,
                                  fw: 2,
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
            ),
          ),
        ));
  }

  Widget _buildStrategyTypeChip(
      String text, bool isSelected, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
        highlightColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        onTap: () {
          ref.read(dashboardProvider).updateStrategyType(text);
        },
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.isDarkMode
                    ? colors.searchBgDark
                    : const Color(0xffF1F3F8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
          child: Center(
            child: TextWidget.subText(
              text: text,
              color: isSelected
                  ? theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight
                  : theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
              fw: isSelected ? 2 : 2,
              theme: !theme.isDarkMode,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyFundItem(FundListModel fund, ThemesProvider theme) {
    final strategy = ref.read(dashboardProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        children: [
          // Fund Image
          // CircleAvatar(
          //   radius: 18,
          //   backgroundColor:
          //       theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          //   child: ClipOval(
          //     child: Image.network(
          //       "https://v3.mynt.in/mfapi/static/images/mf/${fund.aMCCode ?? ""}.png",
          //       width: 36,
          //       height: 36,
          //       fit: BoxFit.cover,
          //       errorBuilder: (context, error, stackTrace) {
          //         return Icon(
          //           strategy.getFundTypeIcon(fund.type),
          //           color: strategy.getFundTypeColor(fund.type,
          //               isDarkMode: theme.isDarkMode),
          //           size: 18,
          //         );
          //       },
          //       loadingBuilder: (context, child, loadingProgress) {
          //         if (loadingProgress == null) return child;
          //         return SizedBox(
          //           width: 18,
          //           height: 18,
          //           child: CircularProgressIndicator(
          //             strokeWidth: 2,
          //             value: loadingProgress.expectedTotalBytes != null
          //                 ? loadingProgress.cumulativeBytesLoaded /
          //                     loadingProgress.expectedTotalBytes!
          //                 : null,
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 16),

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
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextWidget.paraText(
                      text: fund.type.toUpperCase(),
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                    if (fund.aum > 0) ...[
                      const SizedBox(width: 8),
                      TextWidget.paraText(
                        text: 'AUM ${_formatAumValue(fund.aum)}',
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
          const SizedBox(width: 8),

          // Percentage - Editable
          SizedBox(
            width: 70,
            child: TextFormField(
              controller: strategy.percentageControllers[fund.name],
              style: TextWidget.textStyle(
                fontSize: 16,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffF1F3F8),
                suffixText: '%',
                suffixStyle: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 2,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: colors.colorBlue,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: colors.colorBlue,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                isDense: true,
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value);
                if (intValue != null && intValue > 0 && intValue <= 100) {
                  strategy.updateFundPercentage(fund, intValue.toDouble());
                } else if (value.isEmpty) {
                  // Allow empty values but set percentage to 0 for validation
                  strategy.updateFundPercentage(fund, 0);
                } else if (intValue == 0) {
                  // Allow 0 percentage for validation
                  strategy.updateFundPercentage(fund, 0);
                } else {
                  // Reset to current value if invalid input
                  strategy.updateFundPercentage(fund, fund.percentage);
                }
                strategy.validatepercentage(context);
              },
              onFieldSubmitted: (value) {
                final intValue = int.tryParse(value);
                if (intValue != null && intValue > 0 && intValue <= 100) {
                  strategy.updateFundPercentage(fund, intValue.toDouble());
                } else if (value.isEmpty) {
                  // Allow empty values but set percentage to 0 for validation
                  strategy.updateFundPercentage(fund, 0);
                } else if (intValue == 0) {
                  // Allow 0 percentage for validation
                  strategy.updateFundPercentage(fund, 0);
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
                  Icons.delete_outlined,
                  color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                  size: 20,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
        highlightColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        onTap: () {
          ref.read(dashboardProvider).updateInvestmentType(text);
        },
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.isDarkMode
                    ? colors.searchBgDark
                    : const Color(0xffF1F3F8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
          child: Center(
            child: TextWidget.subText(
              text: text,
              color: isSelected
                  ? theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight
                  : theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
              fw: isSelected ? 2 : 2,
              theme: !theme.isDarkMode,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(
      String text, bool isSelected, ThemesProvider theme) {
    return TextButton(
      onPressed: () {
        ref.read(dashboardProvider).updateDuration(text);
        FocusScope.of(context).unfocus();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        backgroundColor: !theme.isDarkMode
            ? isSelected
                ? const Color(0xffF1F3F8)
                : Colors.transparent
            : isSelected
                ? colors.darkGrey
                : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: isSelected
              ?  BorderSide(
                  color: colors.primaryLight,
                  width: 1,
                )
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: TextWidget.textStyle(
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fontSize: 14,
          theme: theme.isDarkMode,
          fw: isSelected ? 2 : 0,
        ),
      ),
    );
  }

  void _updateStrategy(BuildContext context) {
    ref.read(dashboardProvider).updateStrategy(context);
    // _showUpdateSuccessDialog();
  }

  void _handleBackNavigation() async {
    final strategy = ref.read(dashboardProvider);

    // Check if there are unsaved changes
    if (strategy.hasStrategyChanged) {
      await _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showUnsavedChangesDialog() async {
    final theme = ref.read(themeProvider);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF1F3F8),
          titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          scrollable: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          actionsPadding:
              const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          title: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: TextButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 150));
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(0),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    elevation: 0.0,
                    minimumSize: const Size(0, 40),
                    side: BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextWidget.subText(
                    text:
                        "You have unsaved changes. Do you want to save them before leaving?",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                    align: TextAlign.center),
              ),
            ),
          ]),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back without saving
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 45), // width, height
                      side: BorderSide(
                          color: theme.isDarkMode
                              ? colors.lossDark
                              : colors.lossLight), // Outline border color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      //  backgroundColor: theme.isDarkMode ? colors.lossDark : colors.lossLight, // Transparent background
                    ),
                    child: TextWidget.subText(
                        text: "Discard",
                        color: theme.isDarkMode
                            ? colors.lossDark
                            : colors.lossLight,
                        theme: theme.isDarkMode,
                        fw: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final strategy = ref.read(dashboardProvider);
                      try {
                        if (strategy.isEditingMode) {
                          // Update existing strategy
                          await strategy.updateStrategy(context);
                          Navigator.of(context).pop(); // Close dialog
                          // Navigator.of(context).pop(); // Go back after saving
                        } else {
                          // Close the unsaved changes dialog first
                          Navigator.of(context).pop();
                          // Save new strategy - show name dialog first
                          _showSaveStrategyDialog(onSaved: () {
                            Navigator.of(context).pop(); // Go back after saving
                          });
                        }
                      } catch (e) {}
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 45), // width, height
                      side: BorderSide(
                          color:
                              colors.btnOutlinedBorder), // Outline border color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor:
                          colors.primaryDark, // Transparent background
                    ),
                    child: TextWidget.subText(
                        text: "Save",
                        color: colors.colorWhite,
                        theme: theme.isDarkMode,
                        fw: 2),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
      // error(context, 'Failed to process strategy. Please try again.');
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

  void _showSaveStrategyDialog({VoidCallback? onSaved}) {
    final theme = ref.read(themeProvider);
    final strategy = ref.read(dashboardProvider);
    // setState(() {
    //   strategy.strategyNameController.text = "";
    // });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.isDarkMode
            ? const Color(0xFF121212)
            : const Color(0xFFF1F3F8),
        titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        scrollable: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        actionsPadding:
            const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        title: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: TextButton(
                onPressed: () async {
                  await Future.delayed(const Duration(milliseconds: 150));
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  elevation: 0.0,
                  minimumSize: const Size(0, 40),
                  side: BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.subText(
                    text: 'Enter a name for your strategy',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  const SizedBox(height: 8),
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
                       fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                       filled: true,
                       hintText: 'Strategy name',
                       hintStyle: TextWidget.textStyle(
                         fontSize: 14,
                         theme: theme.isDarkMode,
                         color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                         fw: 0,
                       ),
                       contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                       enabledBorder: OutlineInputBorder(
                         borderSide: BorderSide(color: colors.colorBlue),
                         borderRadius: BorderRadius.circular(5)
                       ),
                       disabledBorder: InputBorder.none,
                       focusedBorder: OutlineInputBorder(
                         borderSide: BorderSide(color: colors.colorBlue),
                         borderRadius: BorderRadius.circular(5)
                       ),
                       border: OutlineInputBorder(
                         borderSide: BorderSide.none,
                         borderRadius: BorderRadius.circular(5)
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                if (strategy.strategyNameController.text.trim().isNotEmpty) {
                  try {
                    if (strategy.isEditingMode) {
                      Navigator.of(context).pop();
                      setState(() {
                        strategy.strategyNameController.text.trim();
                      });

                      // After updating, proceed with backtest
                      // await _performBacktest(context);
                    } else {
                      await ref.read(dashboardProvider).saveStrategy(
                          strategy.strategyNameController.text.trim());
                      Navigator.of(context).pop(); // Close the save dialog

                      if (strategy.isStrategyValid) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pop();
                      }
                      // await _performBacktest(context);
                    }
                    // _showSuccessDialog();
                  } catch (e) {
                    Navigator.of(context).pop();
                    error(
                        context, 'Failed to save strategy. Please try again.');
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 45), // width, height
                side: BorderSide(
                    color: colors.btnOutlinedBorder), // Outline border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: colors.primaryDark, // Transparent background
              ),
              child: TextWidget.subText(
                  text: "Save",
                  color: colors.colorWhite,
                  theme: theme.isDarkMode,
                  fw: 2),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvestmentDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final theme = ref.watch(themeProvider);
          final strategy = ref.watch(dashboardProvider);
          
          return Container(
        height: MediaQuery.of(context).size.height * 0.6,
       decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
           border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
          
           
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const CustomDragHandler(),

            // Header
            Padding(
                padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                    text: 'Investment Details',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1,
                  ),
                  Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150));
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(20),
                              splashColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.15),
                              highlightColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.08),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 22,
                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                ],
              ),
            ),

              // Divider(
              //         color: theme.isDarkMode
              //             ? colors.darkColorDivider
              //             : colors.colorDivider,
              //         height: 0,
              //       ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Investment Type
                    TextWidget.subText(
                      text: 'Type',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw:1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        'One-time',
                      ]
                          .map((type) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildInvestmentTypeChip(
                                    type,
                                    strategy.selectedInvestmentType == type,
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
                      fw: 1,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: strategy.investmentController,
                        style: TextWidget.textStyle(
                          fontSize: 16,
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 0,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}$'))
                        ],
                        decoration: InputDecoration(
                          fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                          filled: true,
                          prefixText: '₹ ',
                          prefixStyle: TextWidget.textStyle(
                            fontSize: 18,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 1,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.colorBlue),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.colorBlue),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)
                          ),
                        ),
                        onChanged: (value) {
                          strategy.validateInvestmentAmount(value);
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    // Investment amount validation error message
                    if (strategy.investmentError != null) ...[
                      const SizedBox(height: 8),
                      TextWidget.captionText(
                        text: strategy.investmentError!,
                        theme: theme.isDarkMode,
                        color: colors.lossLight,
                        fw: 0,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Duration
                    TextWidget.subText(
                      text: 'Over a duration of',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        '1Y',
                        '3Y',
                        '5Y',
                        '10Y',
                      ]
                          .map((duration) => _buildDurationChip(duration,
                              strategy.selectedDuration == duration, theme))
                          .toList(),
                    ),
                    const SizedBox(height: 32),

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
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: TextWidget.subText(
                          text: strategy.backtestButtonText,
                          theme: theme.isDarkMode,
                          color: Colors.white,
                          fw: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
        },
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
