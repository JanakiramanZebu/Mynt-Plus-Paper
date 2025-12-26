import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';

import '../../../../../models/trading_personality_model.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';

class StrategyDashboardScreen extends ConsumerStatefulWidget {
  const StrategyDashboardScreen({super.key});

  @override
  ConsumerState<StrategyDashboardScreen> createState() =>
      _StrategyDashboardScreenState();
}

class _StrategyDashboardScreenState
    extends ConsumerState<StrategyDashboardScreen> {
  // Sample investment strategies data
  final List<InvestmentStrategy> investmentStrategies = [
    InvestmentStrategy(
      name: 'Aggressive (90-10)',
      subtitle:
          'An equity-heavy portfolio for those chasing higher returns and willing to embrace volatility.',
      description: 'A time-tested option for investors seeking stability',
      funds: [
        StrategyFund(name: 'Equity', schemeName: 'Equity', percentage: 90.0, color: Colors.green),
        StrategyFund(name: 'Debt', schemeName: 'Debt', percentage: 10.0, color: Colors.blue),
      ],
    ),
    InvestmentStrategy(
      name: 'The Popular Balanced (60-40)',
      subtitle:
          'The classic "core" portfolio — designed to deliver moderate growth while protecting on the downside.',
      description: 'A time-tested choice for stable investing',
      funds: [
        StrategyFund(name: 'Equity', schemeName: 'Equity', percentage: 60.0, color: Colors.green),
        StrategyFund(name: 'Debt', schemeName: 'Debt', percentage: 40.0, color: Colors.blue),
      ],
    ),
    InvestmentStrategy(
      name: 'Equal-Weight (25/25/50)',
      subtitle:
          'Straightforward diversification — four asset classes with equal allocation.',
      description: 'Built for steady, risk-conscious investors',
      funds: [
        StrategyFund(name: 'Equity', schemeName: 'Equity', percentage: 25.0, color: Colors.green),
        StrategyFund(name: 'Debt', schemeName: 'Debt', percentage: 25.0, color: Colors.blue),
        StrategyFund(name: 'Hybrid', schemeName: 'Hybrid', percentage: 50.0, color: Colors.orange),      
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider).fetchbasketlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        centerTitle: false,
        leading: const CustomBackBtn(),
        elevation: 0.2,
        title: TextWidget.titleText(
          text: "Investment Strategies",
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
      ),
      body: SafeArea(
        child: Consumer(builder: (context, ref, child) {
          final strategy = ref.watch(dashboardProvider);
          if (strategy.isStrategyLoading) {
            return Center(
              child: Container(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                child: const CircularLoaderImage(),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // My Saved Strategies Section
                _buildSavedStrategiesSection(theme),
                const SizedBox(height: 24),
                // Investment Strategies Section
                _buildInvestmentStrategiesSection(theme),
                // Add bottom padding to prevent content from being hidden behind FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final theme = ref.watch(themeProvider);
          return _buildCreateNewButton(theme);
        },
      ),
    );
  }

  Widget _buildSavedStrategiesSection(ThemesProvider theme) {
    final strategy = ref.watch(dashboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.titleText(
          text: 'My Saved Strategies',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 16),
        if (strategy.savedStrategies?.data?.isEmpty ?? true)
          // Empty state with create button
          _buildEmptyState(theme)
        else
          // Show saved strategies
          Column(
            children: [
              const SizedBox(height: 12),
              ...strategy.savedStrategies?.data?.map((savedStrategy) =>
                      _buildSavedStrategyCard(savedStrategy, theme)) ??
                  [],
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState(ThemesProvider theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Container(
          //   width: 60,
          //   height: 60,
          //   decoration: BoxDecoration(
          //     color: colors.colorBlue.withOpacity(0.1),
          //     shape: BoxShape.circle,
          //   ),
          //   child: Icon(
          //     Icons.add,
          //     size: 32,
          //     color: colors.colorBlue,
          //   ),
          // ),
          // const SizedBox(height: 16),
          SvgPicture.asset(assets.noDatafound, color: const Color(0xff777777)),
          const SizedBox(height: 2),
          TextWidget.subText(
              text: "No Strategies Yet — Let’s Create One That Works for You",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
              align: TextAlign.center,
              lineHeight: 1.5,
              theme: theme.isDarkMode),
          // const SizedBox(height: 16),
          // TextWidget.subText(
          //   text: 'Start building your investment strategy',
          //   theme: theme.isDarkMode,
          //   color: theme.isDarkMode
          //       ? colors.textSecondaryDark
          //       : colors.textSecondaryLight,
          //   fw: 0,
          // ),
          // const SizedBox(height: 16),
          // ElevatedButton(
          //   onPressed: () => _navigateToStrategyCreation(),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor:
          //         theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //   ),
          //   child: TextWidget.subText(
          //     text: 'Create Now',
          //     theme: theme.isDarkMode,
          //     color: colors.colorWhite,
          //     fw: 2,
          //   ),
          // ),
        ],
      ),
    );
  }

  // Helper method to calculate allocation percentages
  Map<String, double> _calculateAllocationPercentages(Data strategyData) {
    Map<String, double> allocations = {
      'Equity': 0.0,
      'Debt': 0.0,
      'Hybrid': 0.0,
    };

    if (strategyData.schemaValues != null) {
      for (var schema in strategyData.schemaValues!) {
        if (schema.percentage != null && schema.schemeType != null) {
          String type = schema.schemeType!.toUpperCase();
          if (type == 'EQUITY') {
            allocations['Equity'] = allocations['Equity']! + schema.percentage!;
          } else if (type == 'DEBT') {
            allocations['Debt'] = allocations['Debt']! + schema.percentage!;
          } else if (type == 'HYBRID') {
            allocations['Hybrid'] = allocations['Hybrid']! + schema.percentage!;
          }
        }
      }
    }

    return allocations;
  }

  Widget _buildSavedStrategyCard(Data strategyData, ThemesProvider theme) {
    final strategy = ref.read(dashboardProvider);
    final planetType = strategy.getPersonalityFromInvestmentDetails(strategyData.investmentDetails);
    final planet = TradingPersonalities.getPersonality(planetType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.2)
              : colors.textSecondaryLight.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _loadStrategyData(strategyData),
        // onLongPress: () => _showDeleteConfirmation(strategyData),
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Strategy Name with Planet Avatar
            Row(
              children: [
                // Planet Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        planet.primaryColor,
                        planet.secondaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: planet.primaryColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      planet.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Strategy Name
                Expanded(
                  child: TextWidget.subText(
                    text: strategyData.basketName ?? 'Unnamed Strategy',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 2,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Invested Amount and Years on same line
            Row(
                    children: [
                      Expanded(
                        child: _buildModernTaxComponent(
                            'Daily change',
                            '0.00%',
                            theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight,
                            theme),
                      ),
                      // Vertical separator between Current and Invested
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.2)
                            : colors.textSecondaryLight
                                .withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildModernTaxComponent(
                            'Returns',
                            '0.00%',
                            theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight,
                            theme),
                      ),
                    ],
                  ),
            
            // const SizedBox(height: 12),
            
            // // Allocation chips and date in a row
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     // Left side: Allocation chips
                
                
                
            //   ],
            // ),
          ],
        ),
      ),
    );
  }


   Widget _buildModernTaxComponent(
      String label, String value, Color color, ThemesProvider theme) {
    return Column(
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        TextWidget.subText(
          text: value,
          theme: theme.isDarkMode,
          color: color,
          fw: 1,
        ),
      ],
    );
  }

  Widget _buildCreateNewButton(ThemesProvider theme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.colorBlue,
        boxShadow: [
          BoxShadow(
            color: colors.colorBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          onTap: () => _navigateToStrategyCreation(),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentStrategiesSection(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.titleText(
          text: 'Investment Strategies',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 16),
        ...investmentStrategies
            .map((strategy) => _buildInvestmentStrategyCard(strategy, theme)),
      ],
    );
  }

  Widget _buildInvestmentStrategyCard(
      InvestmentStrategy strategy, ThemesProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () =>
              _navigateToBacktestWithPreloadedStrategy(strategy.name, strategy.funds),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with badge
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     if (strategy.isFirstTime)
                //       Container(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 8, vertical: 4),
                //         decoration: BoxDecoration(
                //           color: colors.pending.withOpacity(0.1),
                //           borderRadius: BorderRadius.circular(5),
                //         ),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Icon(
                //               Icons.info_outline,
                //               size: 14,
                //               color: colors.pending,
                //             ),
                //             const SizedBox(width: 4),
                //             TextWidget.captionText(
                //               text: strategy.description,
                //               theme: theme.isDarkMode,
                //               color: colors.pending,
                //               fw: 0,
                //             ),
                //           ],
                //         ),
                //       ),
                //   ],
                // ),
                // const SizedBox(height: 12),

                // Strategy name and subtitle
                TextWidget.subText(
                  text: strategy.name,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 2,
                ),
                // if (strategy.isFirstTime)
                //   Container(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     margin: const EdgeInsets.only(top: 4),
                //     decoration: BoxDecoration(
                //       color: theme.isDarkMode
                //           ? colors.darkColorDivider
                //           : colors.colorDivider,
                //       borderRadius: BorderRadius.circular(5),
                //     ),
                //     child: TextWidget.captionText(
                //       text: 'First time in Indian context',
                //       theme: theme.isDarkMode,
                //       color: theme.isDarkMode
                //           ? colors.textSecondaryDark
                //           : colors.textSecondaryLight,
                //       fw: 0,
                //     ),
                //   ),
                const SizedBox(height: 8),

                TextWidget.paraText(
                  text: strategy.subtitle,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
                const SizedBox(height: 16),

                // Fund allocation chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: strategy.funds
                      .map((fund) => _buildFundChip(fund, theme))
                      .toList(),
                ),
                // const SizedBox(height: 16),

                // // View strategy button
                // SizedBox(
                //   width: double.infinity,
                //   height: 45,
                //   child: OutlinedButton(
                //     onPressed: () => _navigateToBacktestWithAllocation(
                //         strategy.name, strategy.funds),
                //     style: OutlinedButton.styleFrom(
                //       side: BorderSide(color: colors.colorBlue),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(5),
                //       ),
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //       backgroundColor:
                //           theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         TextWidget.subText(
                //           text: 'View Strategy Backtest',
                //           theme: theme.isDarkMode,
                //           color: colors.colorWhite,
                //           fw: 2,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFundChip(StrategyFund fund, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fund.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: fund.color.withOpacity(0.3),
        ),
      ),
      child: TextWidget.paraText(
        text: '${fund.name} ${fund.percentage.toStringAsFixed(0)}%',
        theme: theme.isDarkMode,
        color: fund.color,
        fw: 0,
      ),
    );
  }

  Widget _buildAllocationChips(Data strategyData, ThemesProvider theme) {
    final allocations = _calculateAllocationPercentages(strategyData);
    
    // Filter out allocations with 0% and create chips
    List<Widget> chips = [];
    
    if (allocations['Equity']! > 0) {
      chips.add(_buildAllocationChip('Equity', allocations['Equity']!, Colors.green, theme));
    }
    if (allocations['Debt']! > 0) {
      chips.add(_buildAllocationChip('Debt', allocations['Debt']!, Colors.blue, theme));
    }
    if (allocations['Hybrid']! > 0) {
      chips.add(_buildAllocationChip('Hybrid', allocations['Hybrid']!, Colors.orange, theme));
    }
    
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildAllocationChip(String name, double percentage, Color color, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: TextWidget.paraText(
        text: '$name ${percentage.toStringAsFixed(0)}%',
        theme: theme.isDarkMode,
        color: color,
        fw: 0,
      ),
    );
  }

  void _navigateToStrategyCreation() {
    ref.read(dashboardProvider).clearStrategy();
    ref.read(dashboardProvider).shocustomButton(false);
    Navigator.pushNamed(context, Routes.createBasketStrategy);
  }


  // New method to navigate to backtest with preloaded strategy data
  void _navigateToBacktestWithPreloadedStrategy(
      String strategyName, List<StrategyFund> funds) async {
    try {
      // Clear any existing strategy data
      ref.read(dashboardProvider).clearStrategy();
      ref.read(dashboardProvider).shocustomButton(true);
      // Fetch real fund data for each category and perform backtest
      final List<Map<String, dynamic>> realFundAllocations = [];
      final List<FundListModel> preloadedFunds = [];

      for (final fund in funds) {
        final realFundData = await ref
            .read(dashboardProvider)
            .getRealFundDataForCategory(fund.name);

        if (realFundData.isNotEmpty) {
          final realFund = realFundData.first;
          // Use 'name' instead of 'Scheme_Name' as that's what getRealFundDataForCategory returns
          final schemeName = realFund['name'] as String? ?? fund.schemeName;
          realFundAllocations.add({
            'name': realFund['name'],
            'schema_name': schemeName, // Use correct key name for API
            'percentage': fund.percentage,
            'schemeType': realFund['schemeType'],
            'isin': realFund['isin'],
            'amcCode': realFund['amcCode'],
          });

          // Create FundListModel with real fund data for preloading
          preloadedFunds.add(FundListModel(
            name: realFund['name'],
            schemeName: schemeName,
            type: realFund['schemeType'],
            fiveYearCAGR: realFund['fiveYearCAGR']?.toDouble() ?? 0.0,
            threeYearCAGR: realFund['threeYearCAGR']?.toDouble() ?? 0.0,
            aum: realFund['aum']?.toDouble() ?? 0.0,
            sharpe: realFund['sharpe']?.toDouble() ?? 0.0,
            percentage: fund.percentage,
            isin: realFund['isin'] ?? '',
            aMCCode: realFund['amcCode'] ?? '',
          ));
        } else {
          // Fallback to original data if real data fetch fails
          realFundAllocations.add({
            'name': fund.name,
            'schema_name': fund.schemeName, // Use correct key name for API
            'percentage': fund.percentage,
            'schemeType': _getSchemeType(fund.name),
            'isin': '',
            'amcCode': '',
          });

          // Create fallback FundListModel
          preloadedFunds.add(FundListModel(
            name: fund.name,
            schemeName: fund.schemeName,
            type: _getSchemeType(fund.name),
            fiveYearCAGR: 0.0,
            threeYearCAGR: 0.0,
            aum: 0.0,
            sharpe: 0.0,
            percentage: fund.percentage,
            isin: '',
            aMCCode: '',
          ));
        }
      }

      // Preload strategy data with real fund data
      ref.read(dashboardProvider).preloadStrategyData(
        strategyName: strategyName,
        funds: preloadedFunds,
      );

      // Perform backtest with real fund data
      await ref.read(dashboardProvider).performBacktestWithAllocation(
            strategyName: strategyName,
            fundAllocations: realFundAllocations,
            years: 5, 
            investmentAmount: 100000.0,
            compareSymbol: "NSE:NIFTYBEES-EQ", 
          );

      // Navigate directly to backtest analysis
      Navigator.pushNamed(context, Routes.benchmarkBacktestAnalysis);
    } catch (e) {
      print('Error navigating to backtest: $e');
    }
  }


  String _getSchemeType(String fundName) {
    switch (fundName.toLowerCase()) {
      case 'equity':
        return 'EQUITY';
      case 'debt':
        return 'DEBT';
      case 'hybrid':
        return 'HYBRID';
      case 'commodities':
        return 'COMMODITIES';
      default:
        return 'EQUITY';
    }
  }

  void _loadStrategyData(Data strategyData) {
    ref.read(dashboardProvider).shocustomButton(false);
    ref.read(dashboardProvider).loadStrategy(strategyData);
    Navigator.pushNamed(context, Routes.createBasketStrategy);
  }

  // void _handleMenuAction(String action, Data strategyData) {
  //   switch (action) {
  //     case 'edit':
  //       _loadStrategyData(strategyData);
  //       break;
  //     case 'delete':
  //       _showDeleteConfirmation(strategyData);
  //       break;
  //   }
  // }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }

  void _showDeleteConfirmation(Data strategyData) {
    final theme = ref.read(themeProvider);
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
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextWidget.subText(
                    text:
                        'Are you sure you want to delete "${strategyData.basketName ?? 'this strategy'}"? This action cannot be undone.',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                    align: TextAlign.center),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref
                    .read(dashboardProvider)
                    .deleteStrategy(strategyData.uuid ?? '', context);
                Navigator.of(context).pop();
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
                  text: "Delete",
                  color: colors.colorWhite,
                  theme: theme.isDarkMode,
                  fw: 2),
            ),
          ),
        ],
      ),
    );
  }
}

// Data models

class InvestmentStrategy {
  final String name;
  final String subtitle;
  final String description;
  final List<StrategyFund> funds;

  InvestmentStrategy({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.funds,
  });
}

class StrategyFund {
  final String name;
  final String schemeName;
  final double percentage;
  final Color color;

  StrategyFund({
    required this.name,
    required this.schemeName,
    required this.percentage,
    required this.color,
  });
}
