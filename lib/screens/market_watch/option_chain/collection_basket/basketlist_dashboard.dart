import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';

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
        StrategyFund(name: 'Equity', percentage: 90.0, color: Colors.green),
        StrategyFund(name: 'Debt', percentage: 10.0, color: Colors.blue),
      ],
      isFirstTime: false,
    ),
    InvestmentStrategy(
      name: 'The Popular Balanced (60-40)',
      subtitle:
          'The classic "core" portfolio — designed to deliver moderate growth while protecting on the downside.',
      description: 'A time-tested choice for stable investing',
      funds: [
        StrategyFund(name: 'Equity', percentage: 60.0, color: Colors.green),
        StrategyFund(name: 'Debt', percentage: 40.0, color: Colors.blue),
      ],
      isFirstTime: true,
    ),
    InvestmentStrategy(
      name: 'Equal-Weight (25/25/25/25)',
      subtitle:
          'Straightforward diversification — four asset classes with equal allocation.',
      description: 'Built for steady, risk-conscious investors',
      funds: [
        StrategyFund(name: 'Equity', percentage: 25.0, color: Colors.green),
        StrategyFund(name: 'Debt', percentage: 25.0, color: Colors.blue),
        StrategyFund(name: 'Hybrid', percentage: 25.0, color: Colors.orange),
        StrategyFund(
            name: 'Commodities', percentage: 25.0, color: Colors.purple),
      ],
      isFirstTime: true,
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
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: theme.isDarkMode
                ? colors.splashColorDark
                : colors.splashColorLight,
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Saved Strategies Section
              _buildSavedStrategiesSection(theme),
              const SizedBox(height: 24),

              // Investment Strategies Section
              _buildInvestmentStrategiesSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedStrategiesSection(ThemesProvider theme) {
    final strategy = ref.watch(dashboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.titleText(
              text: 'My Saved Strategies',
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 1,
            ),
              _buildCreateNewButton(theme),

          ],
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
          SvgPicture.asset(assets.noDatafound, color: Color(0xff777777)),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToStrategyCreation(),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: TextWidget.subText(
              text: 'Create Now',
              theme: theme.isDarkMode,
              color: colors.colorWhite,
              fw: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedStrategyCard(Data strategyData, ThemesProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: theme.isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.2)
              : colors.textSecondaryLight.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _loadStrategyData(strategyData),
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                        text: strategyData.basketName ?? 'Unnamed Strategy',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 2,
                      ),
                      const SizedBox(height: 8),
                      TextWidget.paraText(
                        text:
                            '${strategyData.years ?? 0} years • ${strategyData.investmentDetails ?? 'N/A'} • ₹${strategyData.investAmount?.toString() ?? '0'}',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                      ),
                      if (strategyData.datetime != null) ...[
                        const SizedBox(height: 4),
                        TextWidget.paraText(
                          text:
                              'Created: ${_formatDateTime(strategyData.datetime!)}',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color:
                      theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                  onSelected: (value) => _handleMenuAction(value, strategyData),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        value: 'edit',
                        child: TextWidget.paraText(
                          text: 'Edit',
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          fw: 0,
                        )),
                    PopupMenuItem(
                        value: 'delete',
                        child: TextWidget.paraText(
                          text: 'Delete',
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          fw: 0,
                        )),
                  ],
                ),
              ],
            ),
            //   if (strategyData.schemaValues != null && strategyData.schemaValues!.isNotEmpty) ...[
            //     const SizedBox(height: 12),
            //     TextWidget.captionText(
            //       text: 'Fund Allocation:',
            //       theme: theme.isDarkMode,
            //       color: theme.isDarkMode
            //           ? colors.textSecondaryDark
            //           : colors.textSecondaryLight,
            //       fw: 1,
            //     ),
            //     const SizedBox(height: 8),
            //     Wrap(
            //       spacing: 8,
            //       runSpacing: 4,
            //       children: strategyData.schemaValues!.map((schema) => _buildSchemaChip(schema, theme)).toList(),
            //     ),
            //   ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewButton(ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToStrategyCreation(),
        borderRadius: BorderRadius.circular(5),
        splashColor: theme.isDarkMode
            ? colors.splashColorDark
            : colors.splashColorLight,
        highlightColor: theme.isDarkMode
            ? colors.splashColorDark
            : colors.splashColorLight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: colors.colorBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              TextWidget.subText(
                text: 'New Strategy',
                theme: theme.isDarkMode,
                color: colors.colorBlue,
                fw: 2,
              ),
            ],
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
          onTap: () => _navigateToBacktestWithAllocation(
              strategy.name, strategy.funds),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (strategy.isFirstTime)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.pending.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: colors.pending,
                        ),
                        const SizedBox(width: 4),
                        TextWidget.captionText(
                          text: strategy.description,
                          theme: theme.isDarkMode,
                          color: colors.pending,
                          fw: 0,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
      
            // Strategy name and subtitle
            TextWidget.subText(
              text: strategy.name,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 2,
            ),
            if (strategy.isFirstTime)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextWidget.captionText(
                  text: 'First time in Indian context',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ),
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

  void _navigateToStrategyCreation() {
    ref.read(dashboardProvider).clearStrategy();
    Navigator.pushNamed(context, Routes.createBasketStrategy);
  }

  void _navigateToBacktestWithAllocation(
      String strategyName, List<StrategyFund> funds) async {
    try {
      // Clear any existing strategy data
      ref.read(dashboardProvider).clearStrategy();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch real fund data for each category
      final List<Map<String, dynamic>> realFundAllocations = [];

      for (final fund in funds) {
        // Get real fund data for this category
        final realFundData = await ref
            .read(dashboardProvider)
            .getRealFundDataForCategory(fund.name);

        if (realFundData.isNotEmpty) {
          final realFund = realFundData.first;
          realFundAllocations.add({
            'name': realFund['name'],
            'percentage': fund.percentage,
            'schemeType': realFund['schemeType'],
            'isin': realFund['isin'],
            'amcCode': realFund['amcCode'],
          });
        } else {
          // Fallback to original data if real data fetch fails
          realFundAllocations.add({
            'name': fund.name,
            'percentage': fund.percentage,
            'schemeType': _getSchemeType(fund.name),
          });
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Perform backtest with real fund data
      await ref.read(dashboardProvider).performBacktestWithAllocation(
            strategyName: strategyName,
            fundAllocations: realFundAllocations,
            years: 5, // Default duration
            investmentAmount: 100000.0, // Default investment amount
            compareSymbol: "NSE:NIFTYBEES-EQ", // Default benchmark
          );

      // Navigate directly to backtest analysis
      Navigator.pushNamed(context, Routes.basketBacktestAnalysis);
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load backtest data: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    ref.read(dashboardProvider).loadStrategy(strategyData);
    Navigator.pushNamed(context, Routes.createBasketStrategy);
  }

  void _handleMenuAction(String action, Data strategyData) {
    switch (action) {
      case 'edit':
        _loadStrategyData(strategyData);
        break;
      case 'delete':
        _showDeleteConfirmation(strategyData);
        break;
    }
  }

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
  final bool isFirstTime;

  InvestmentStrategy({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.funds,
    required this.isFirstTime,
  });
}

class StrategyFund {
  final String name;
  final double percentage;
  final Color color;

  StrategyFund({
    required this.name,
    required this.percentage,
    required this.color,
  });
}
