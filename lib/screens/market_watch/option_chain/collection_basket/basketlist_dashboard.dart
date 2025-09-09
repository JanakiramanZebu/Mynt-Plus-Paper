import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';

class StrategyDashboardScreen extends ConsumerStatefulWidget {
  const StrategyDashboardScreen({super.key});

  @override
  ConsumerState<StrategyDashboardScreen> createState() => _StrategyDashboardScreenState();
}

class _StrategyDashboardScreenState extends ConsumerState<StrategyDashboardScreen> {

  // Sample investment strategies data
  final List<InvestmentStrategy> investmentStrategies = [
    InvestmentStrategy(
      name: 'Aggressive (90-10)',
      subtitle: 'An equity-heavy portfolio for those chasing higher returns and willing to embrace volatility.',
      description: 'A time-tested option for investors seeking stability',
      funds: [
        StrategyFund(name: 'Equity', percentage: 90.0, color: Colors.green),
        StrategyFund(name: 'Debt', percentage: 10.0, color: Colors.blue),
      ],
      isFirstTime: false,
    ),
    InvestmentStrategy(
      name: 'The Popular Balanced (60-40)',
      subtitle: 'The classic "core" portfolio — designed to deliver moderate growth while protecting on the downside.',
      description: 'A time-tested choice for stable investing',
      funds: [
        StrategyFund(name: 'Equity', percentage: 60.0, color: Colors.green),
        StrategyFund(name: 'Debt', percentage: 40.0, color: Colors.blue),
      ],
      isFirstTime: true,
    ),
    InvestmentStrategy(
      name: 'Equal-Weight (25/25/25/25)',
      subtitle: 'Straightforward diversification — four asset classes with equal allocation.',
      description: 'Built for steady, risk-conscious investors',
      funds: [
        StrategyFund(name: 'Equity', percentage: 25.0, color: Colors.green),
        StrategyFund(name: 'Debt', percentage: 25.0, color: Colors.blue),
        StrategyFund(name: 'Hybrid', percentage: 25.0, color: Colors.orange),
        StrategyFund(name: 'Commodities', percentage: 25.0, color: Colors.purple),
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
          padding: const EdgeInsets.all(16),
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
        TextWidget.titleText(
          text: 'My Saved Strategies',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 16),
        
        if (strategy.savedStrategies?.data?.isEmpty ?? false)
          // Empty state with create button
          _buildEmptyState(theme)
        else
          // Show saved strategies
          Column(
            children: [
              _buildCreateNewButton(theme),
              const SizedBox(height: 12),
              ...strategy.savedStrategies?.data?.map((savedStrategy) => _buildSavedStrategyCard(savedStrategy, theme)) ?? [],
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.2)
              : colors.textSecondaryLight.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colors.colorBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              size: 32,
              color: colors.colorBlue,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToStrategyCreation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.colorBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: TextWidget.subText(
              text: 'Create Now',
              theme: theme.isDarkMode,
              color: Colors.white,
              fw: 1,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.2)
              : colors.textSecondaryLight.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _loadStrategyData(strategyData),
        borderRadius: BorderRadius.circular(12),
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
                        fw: 1,
                      ),
                      const SizedBox(height: 4),
                      TextWidget.captionText(
                        text: '${strategyData.years ?? 0} years • ${strategyData.investmentDetails ?? 'N/A'} • ₹${strategyData.investAmount?.toString() ?? '0'}',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                      ),
                      if (strategyData.datetime != null) ...[
                        const SizedBox(height: 4),
                        TextWidget.captionText(
                          text: 'Created: ${_formatDateTime(strategyData.datetime!)}',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark.withOpacity(0.7)
                              : colors.textSecondaryLight.withOpacity(0.7),
                          fw: 0,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                  onSelected: (value) => _handleMenuAction(value, strategyData),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
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
    return InkWell(
      onTap: () => _navigateToStrategyCreation(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.colorBlue.withOpacity(0.3),
          ),
        ),
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
              text: 'Create New Strategy',
              theme: theme.isDarkMode,
              color: colors.colorBlue,
              fw: 1,
            ),
          ],
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
        
        ...investmentStrategies.map((strategy) => _buildInvestmentStrategyCard(strategy, theme)),
      ],
    );
  }

  Widget _buildInvestmentStrategyCard(InvestmentStrategy strategy, ThemesProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.isDarkMode
                ? colors.colorBlack.withOpacity(0.1)
                : colors.textSecondaryLight.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (strategy.isFirstTime)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.colorBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: colors.colorBlue,
                      ),
                      const SizedBox(width: 4),
                      TextWidget.captionText(
                        text: strategy.description,
                        theme: theme.isDarkMode,
                        color: colors.colorBlue,
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
            fw: 1,
          ),
          if (strategy.isFirstTime)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextWidget.captionText(
                text: '(First time in Indian context)',
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
            children: strategy.funds.map((fund) => _buildFundChip(fund, theme)).toList(),
          ),
          const SizedBox(height: 16),
          
          // View strategy button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _navigateToBacktestWithAllocation(strategy.name, strategy.funds),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.colorBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget.subText(
                    text: 'View Strategy Backtest',
                    theme: theme.isDarkMode,
                    color: colors.colorBlue,
                    fw: 1,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: colors.colorBlue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundChip(StrategyFund fund, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fund.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fund.color.withOpacity(0.3),
        ),
      ),
      child: TextWidget.captionText(
        text: '${fund.name} ${fund.percentage.toStringAsFixed(0)}%',
        theme: theme.isDarkMode,
        color: fund.color,
        fw: 1,
      ),
    );
  }

  void _navigateToStrategyCreation() {
    // Clear any existing strategy data before creating new one
    ref.read(dashboardProvider).clearStrategy();
    Navigator.pushNamed(context, Routes.createBasketStrategy);
  }

  void _navigateToBacktestWithAllocation(String strategyName, List<StrategyFund> funds) async {
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
        final realFundData = await ref.read(dashboardProvider).getRealFundDataForCategory(fund.name);
        
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
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        title: TextWidget.titleText(
          text: 'Delete Strategy',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        content: TextWidget.subText(
          text: 'Are you sure you want to delete "${strategyData.basketName ?? 'this strategy'}"? This action cannot be undone.',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
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
            onPressed: () {
              ref.read(dashboardProvider).deleteStrategy(strategyData.uuid ?? '', context);
              Navigator.of(context).pop();
            },
            child: TextWidget.subText(
              text: 'Delete',
              theme: theme.isDarkMode,
              color: colors.lossLight,
              fw: 1,
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