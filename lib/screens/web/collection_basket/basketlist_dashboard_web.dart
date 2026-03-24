import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/sharedWidget/common_buttons_web.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;


class StrategyDashboardScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onCreateStrategy;
  final Function(Data strategyData)? onLoadStrategy;
  final Function(String strategyName, List<StrategyFund> funds)? onBacktestStrategy;

  const StrategyDashboardScreenWeb({
    super.key,
    this.onCreateStrategy,
    this.onLoadStrategy,
    this.onBacktestStrategy,
  });

  @override
  ConsumerState<StrategyDashboardScreenWeb> createState() =>
      _StrategyDashboardScreenState();
}

class _StrategyDashboardScreenState
    extends ConsumerState<StrategyDashboardScreenWeb> {
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
      ref.read(dashboardProvider).fetchbasketlist().then((_) {}).catchError((e) {
        if (mounted) {
          error(context, 'Failed to load strategies. Please try again.');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor),
      body: Consumer(builder: (context, ref, child) {
        final strategy = ref.watch(dashboardProvider);
        // Show loader only on first load (no data yet). On re-visits, data refreshes silently.
        if (strategy.isStrategyLoading && strategy.savedStrategies == null) {
          return Center(
            child: Container(
              color: resolveThemeColor(context,
                  dark: MyntColors.backgroundColorDark,
                  light: MyntColors.backgroundColor),
              child: MyntLoader.branded(),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: resolveThemeColor(context,
                        dark: MyntColors.listItemBgDark,
                        light: MyntColors.listItemBg),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'MF Strategy',
                    style: MyntWebTextStyles.title(context,
                        fontWeight: MyntFonts.semiBold,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildSavedStrategiesSection(context),
            ),
          ],
        );
      }),
    ); 
  }

  Widget _buildSavedStrategiesSection(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);
    final isEmpty = strategy.savedStrategies?.data?.isEmpty ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '',
                style: MyntWebTextStyles.title(context,
                    fontWeight: MyntFonts.medium,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary),
              ),
              Container(
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                      dark: MyntColors.secondary,
                      light: MyntColors.primary),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: Colors.white.withOpacity(0.1),
                    onTap: () => _navigateToStrategyCreation(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        'Create',
                         style: MyntWebTextStyles.buttonMd(
                          context,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isEmpty)
          Expanded(
            child: Center(
              child: _buildEmptyState(context),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStrategyCards(context, strategy.savedStrategies!.data!),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStrategyCards(BuildContext context, List<Data> strategies) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 500
                ? 2
                : 1;
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: strategies.map((strategyData) {
            return SizedBox(
              width: cardWidth,
              child: _StrategyCardWidget(
                strategyData: strategyData,
                onTap: () => _loadStrategyData(strategyData),
                onEdit: () => _loadStrategyData(strategyData),
                onDelete: () => _showDeleteConfirmation(strategyData),
                calculateAllocations: _calculateAllocationPercentages,
              ),
            );
          }).toList(),
        );
      },
    );
  }


  Widget _buildEmptyState(BuildContext context) {
    return const NoDataFoundWeb(
      title: 'No Strategies Yet',
      subtitle: "Let's Create One That Works for You",
      primaryEnabled: false,
      secondaryEnabled: false,
    );
  }

  Map<String, double> _calculateAllocationPercentages(Data strategyData) {
    final Map<String, double> allocations = {};

    if (strategyData.schemaValues != null) {
      for (var schema in strategyData.schemaValues!) {
        if (schema.percentage != null && schema.schemeType != null && schema.schemeType!.isNotEmpty) {
          final raw = schema.schemeType!.trim();
          // Normalize to title case so "FIXED INCOME" → "Fixed Income"
          final label = raw.split(' ').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
          allocations[label] = (allocations[label] ?? 0.0) + schema.percentage!;
        }
      }
    }

    return allocations;
  }


  Widget _buildInvestmentStrategiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Strategies',
          style: MyntWebTextStyles.title(context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ...investmentStrategies
            .map((strategy) => _buildInvestmentStrategyCard(strategy, context)),
      ],
    );
  }

  Widget _buildInvestmentStrategyCard(
      InvestmentStrategy strategy, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
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
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.divider),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy.name,
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.semiBold,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  strategy.subtitle,
                  style: MyntWebTextStyles.para(context,
                      fontWeight: MyntFonts.regular,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: strategy.funds
                      .map((fund) => _buildFundChip(fund, context))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFundChip(StrategyFund fund, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fund.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: fund.color.withOpacity(0.3),
        ),
      ),
      child: Text(
        '${fund.name} ${fund.percentage.toStringAsFixed(0)}%',
        style: MyntWebTextStyles.para(context,
            fontWeight: MyntFonts.regular,
            color: fund.color),
      ),
    );
  }


  void _navigateToStrategyCreation() {
    _showStrategyNameDialog();
  }

  void _showStrategyNameDialog() {
    final nameController = TextEditingController();
    final nameFocusNode = FocusNode();
    bool submitted = false;
    bool focusRequested = false;
    final existingNames = ref.read(dashboardProvider).savedStrategies?.basketNames
        ?.map((n) => n.toLowerCase().trim())
        .toSet() ?? <String>{};

    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String? nameError;
        // Only request focus once on first build, never after submission.
        if (!focusRequested) {
          focusRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!submitted) nameFocusNode.requestFocus();
          });
        }
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            void submit() {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                setDialogState(() => nameError = 'Please enter a strategy name');
                return;
              }
              if (existingNames.contains(name.toLowerCase())) {
                setDialogState(() => nameError = 'A strategy with this name already exists');
                return;
              }
              // Mark submitted BEFORE pop so any in-flight postFrameCallback skips requestFocus.
              submitted = true;
              Navigator.of(dialogContext).pop(name);
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: shadcn.Card(
                  borderRadius: BorderRadius.circular(8),
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 420,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: shadcn.Theme.of(ctx).colorScheme.border,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Create Strategy',
                                style: MyntWebTextStyles.title(
                                  ctx,
                                  color: resolveThemeColor(ctx,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                                  fontWeight: MyntFonts.medium,
                                ),
                              ),
                              MyntCloseButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Strategy Name',
                                style: MyntWebTextStyles.body(ctx,
                                    fontWeight: MyntFonts.semiBold,
                                    darkColor: MyntColors.textPrimaryDark,
                                    lightColor: MyntColors.textPrimary),
                              ),
                              const SizedBox(height: 10),
                              MyntFormTextField(
                                controller: nameController,
                                focusNode: nameFocusNode,
                                placeholder: 'Enter Strategy Name',
                                height: 40,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9 ]')),
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    if (newValue.text.isEmpty) return newValue;
                                    final capitalized =
                                        newValue.text[0].toUpperCase() +
                                            newValue.text.substring(1);
                                    return newValue.copyWith(text: capitalized);
                                  }),
                                ],
                                onChanged: (value) {
                                  final trimmed = value.trim();
                                  if (trimmed.isNotEmpty && existingNames.contains(trimmed.toLowerCase())) {
                                    setDialogState(() => nameError = 'A strategy with this name already exists');
                                  } else if (nameError != null) {
                                    setDialogState(() => nameError = null);
                                  }
                                },
                                onSubmitted: (_) => submit(),
                              ),
                              if (nameError != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  nameError!,
                                  style: MyntWebTextStyles.caption(ctx,
                                      fontWeight: MyntFonts.medium,
                                      color: resolveThemeColor(ctx,
                                          dark: MyntColors.errorDark,
                                          light: MyntColors.error)),
                                ),
                              ],
                              const SizedBox(height: 20),
                              MyntPrimaryButton(
                                label: 'Create',
                                isFullWidth: true,
                                onPressed: submit,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((name) {
      // .then() fires when Navigator.pop() is called, but the exit animation
      // is still running (~300ms). Delay dispose until after animation ends.
      Future.delayed(const Duration(milliseconds: 400), () {
        nameController.dispose();
        nameFocusNode.dispose();
      });
      if (name != null && name.isNotEmpty && mounted) {
        ref.read(dashboardProvider).clearStrategy();
        ref.read(dashboardProvider).setPendingStrategyName(name);
        ref.read(dashboardProvider).shocustomButton(false);
        widget.onCreateStrategy?.call();
      }
    });
  }

  void _navigateToBacktestWithPreloadedStrategy(
      String strategyName, List<StrategyFund> funds) async {
    try {
      ref.read(dashboardProvider).clearStrategy();
      ref.read(dashboardProvider).shocustomButton(true);
      final List<Map<String, dynamic>> realFundAllocations = [];
      final List<FundListModel> preloadedFunds = [];

      for (final fund in funds) {
        final realFundData = await ref
            .read(dashboardProvider)
            .getRealFundDataForCategory(fund.name);

        if (realFundData.isNotEmpty) {
          final realFund = realFundData.first;
          final schemeName = realFund['name'] as String? ?? fund.schemeName;
          realFundAllocations.add({
            'name': realFund['name'],
            'schema_name': schemeName,
            'percentage': fund.percentage,
            'schemeType': realFund['schemeType'],
            'isin': realFund['isin'],
            'amcCode': realFund['amcCode'],
          });

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
            schemeCode: realFund['schemeCode'] ?? '',
          ));
        } else {
          realFundAllocations.add({
            'name': fund.name,
            'schema_name': fund.schemeName,
            'percentage': fund.percentage,
            'schemeType': _getSchemeType(fund.name),
            'isin': '',
            'amcCode': '',
          });

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

      ref.read(dashboardProvider).preloadStrategyData(
        strategyName: strategyName,
        funds: preloadedFunds,
      );

      await ref.read(dashboardProvider).performBacktestWithAllocation(
            strategyName: strategyName,
            fundAllocations: realFundAllocations,
            years: 5,
            investmentAmount: 100000.0,
            compareSymbol: "NSE:NIFTYBEES-EQ",
          );

      widget.onBacktestStrategy?.call(strategyName, funds);
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

  Future<void> _loadStrategyData(Data strategyData) async {
    if (!mounted) return;
    ref.read(dashboardProvider).shocustomButton(false);
    await ref.read(dashboardProvider).loadStrategy(strategyData);
    if (!mounted) return;
    widget.onLoadStrategy?.call(strategyData);
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
    print('=== DELETE DIALOG ===');
    print('Strategy: ${strategyData.basketName}, uuid: ${strategyData.uuid}, name: ${strategyData.name}');
    print('Full data: ${strategyData.toJson()}');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: shadcn.Card(
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: shadcn.Theme.of(dialogContext).colorScheme.border,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delete Strategy',
                            style: MyntWebTextStyles.title(
                              dialogContext,
                              color: resolveThemeColor(dialogContext,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                              fontWeight: MyntFonts.medium,
                            ),
                          ),
                          MyntCloseButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Are you sure you want to delete "${strategyData.basketName ?? 'this strategy'}"?',
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.body(
                              dialogContext,
                              color: resolveThemeColor(dialogContext,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          MyntPrimaryButton(
                            label: 'Delete',
                            isFullWidth: true,
                            backgroundColor: resolveThemeColor(dialogContext,
                                dark: MyntColors.errorDark,
                                light: MyntColors.error),
                            onPressed: () {
                              ref.read(dashboardProvider).deleteStrategy(
                                  strategyData.uuid ?? '', dialogContext);
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Strategy Card Widget ──────────────────────────────────────────────────

class _StrategyCardWidget extends StatefulWidget {
  final Data strategyData;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Map<String, double> Function(Data) calculateAllocations;

  const _StrategyCardWidget({
    required this.strategyData,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.calculateAllocations,
  });

  @override
  State<_StrategyCardWidget> createState() => _StrategyCardWidgetState();
}

class _StrategyCardWidgetState extends State<_StrategyCardWidget> {
  Color _categoryColor(String type) {
    const palette = [
      Color(0xFF14B8A6), Color(0xFFF97316), Color(0xFFEC4899),
      Color(0xFF84CC16), Color(0xFF6366F1), Color(0xFFA855F7),
    ];
    switch (type.toLowerCase()) {
      case 'equity': return const Color(0xFF6366F1);
      case 'hybrid': return Colors.orange;
      case 'debt': return Colors.blue;
      case 'fixed income': return const Color(0xFF0EA5E9);
      case 'liquid': return const Color(0xFF06B6D4);
      case 'solution oriented': return const Color(0xFF8B5CF6);
      case 'index': return const Color(0xFF10B981);
      case 'fof':
      case 'fund of funds': return const Color(0xFFF59E0B);
      case 'elss': return const Color(0xFFEF4444);
      default: return palette[type.hashCode.abs() % palette.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    final allocations = widget.calculateAllocations(widget.strategyData);
    final allocationList = <_AllocationEntry>[];

    for (final entry in allocations.entries) {
      if (entry.value > 0) {
        allocationList.add(_AllocationEntry(entry.key, entry.value, _categoryColor(entry.key)));
      }
    }
    // Sort: Equity first, then by descending percentage
    allocationList.sort((a, b) {
      if (a.label == 'Equity') return -1;
      if (b.label == 'Equity') return 1;
      return b.percentage.compareTo(a.percentage);
    });

    // Accent color based on dominant allocation
    final dominant = allocationList.isNotEmpty ? allocationList.first : null;
    Color accent = dominant != null ? dominant.color : const Color(0xFF8B5CF6);

    final bool darkMode = isDarkMode(context);


    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkMode
                ? accent.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: darkMode
                  ? accent.withValues(alpha: 0.20)
                  : accent.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: stacked icon + name + menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stacked card icon effect
                  // SizedBox(
                  //   width: 64,
                  //   height: 56,
                  //   child: Stack(
                  //     children: [
                  //       // Back card
                  //       Positioned(
                  //         left: 0,
                  //         top: 10,
                  //         child: Transform.rotate(
                  //           angle: -0.18,
                  //           child: Container(
                  //             width: 44,
                  //             height: 44,
                  //             decoration: BoxDecoration(
                  //               color: accent.withValues(alpha: 0.18),
                  //               borderRadius: BorderRadius.circular(11),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       // Mid card
                  //       Positioned(
                  //         left: 8,
                  //         top: 5,
                  //         child: Transform.rotate(
                  //           angle: -0.09,
                  //           child: Container(
                  //             width: 44,
                  //             height: 44,
                  //             decoration: BoxDecoration(
                  //               color: accent.withValues(alpha: 0.35),
                  //               borderRadius: BorderRadius.circular(11),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       // Front card with icon
                  //       Positioned(
                  //         left: 16,
                  //         top: 0,
                  //         child: Container(
                  //           width: 44,
                  //           height: 44,
                  //           decoration: BoxDecoration(
                  //             color: accent,
                  //             borderRadius: BorderRadius.circular(11),
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: accent.withValues(alpha: 0.4),
                  //                 blurRadius: 8,
                  //                 offset: const Offset(0, 3),
                  //               ),
                  //             ],
                  //           ),
                  //           child: const Center(
                  //             child: Icon(
                  //               Icons.pie_chart_outline_rounded,
                  //               size: 22,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.strategyData.basketName ?? 'Unnamed Strategy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MyntWebTextStyles.title(
                            context,
                            darkColor: MyntColors.textPrimaryDark,
                            lightColor: MyntColors.textPrimary,
                            fontWeight: MyntFonts.semiBold,
                          ),
                        ), 
                        if (allocationList.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CustomPaint(
                                  painter: _DonutChartPainter(allocationList),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: allocationList.map((a) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: a.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${a.label} ${a.percentage.toStringAsFixed(0)}%',
                                          style: MyntWebTextStyles.para(
                                            context,
                                            fontWeight: MyntFonts.medium,
                                            darkColor: MyntColors.textSecondaryDark,
                                            lightColor: MyntColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildPopupMenu(context),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.divider),
              ),
              const SizedBox(height: 10),
              // Strategy meta (Inv. Amount & Period)
              _buildStrategyMeta(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyMeta() {
    final data = widget.strategyData;
    final perf = data.performanceMetrics;
    final hasPerf = perf != null && perf.xirr != null;

    final labelColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);
    final valueColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark,
        light: MyntColors.textPrimary);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark,
        light: MyntColors.divider);
    final gainColor = resolveThemeColor(context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit);
    final lossColor = resolveThemeColor(context,
        dark: MyntColors.lossDark,
        light: MyntColors.loss);

    final labelStyle = MyntWebTextStyles.para(context,
        fontWeight: MyntFonts.medium, color: labelColor);
    final valueStyle = MyntWebTextStyles.body(context,
        fontWeight: MyntFonts.semiBold, color: valueColor);

    // XIRR value and color
    final xirr = perf?.xirr ?? 0.0;
    final xirrColor = xirr >= 0 ? gainColor : lossColor;

    // Max Drawdown
    final maxDD = perf?.maxDrawdown ?? 0.0;

    // Min Investment from fund weights and minimum purchase amounts
    final minInvest = _calculateMinInvestment();

    return IntrinsicHeight(
      child: Row(
        children: [

           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Min. Invest', style: labelStyle),
                const SizedBox(height: 2),
                Text(
                  minInvest > 0 ? _formatAmount(minInvest) : '--',
                  style: valueStyle,
                ),
              ],
            ),
          ),
          VerticalDivider(width: 24, thickness: 1, color: dividerColor),

          // XIRR / Returns
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('XIRR', style: labelStyle),
                const SizedBox(height: 2),
                Text(
                  hasPerf ? '${xirr.toStringAsFixed(2)}%' : '--',
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.semiBold, color: hasPerf ? xirrColor : valueColor),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 24, thickness: 1, color: dividerColor),
          // Max Drawdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Max DD', style: labelStyle),
                const SizedBox(height: 2),
                Text(
                  hasPerf ? '${maxDD.toStringAsFixed(2)}%' : '--',
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.semiBold, color: hasPerf ? lossColor : valueColor),
                ),
              ],
            ),
          ),
          // Min. Investment
         
        ],
      ),
    );
  }

  double _calculateMinInvestment() {
    final schemas = widget.strategyData.schemaValues;
    if (schemas == null || schemas.isEmpty) return 0;

    double maxRequired = 0;
    for (var schema in schemas) {
      final pct = (schema.percentage ?? 0) / 100.0;
      final minPurchase = schema.minimumPurchaseAmount ?? 100.0;
      if (pct > 0) {
        // Total investment needed so this fund gets at least its minimum
        final required = minPurchase / pct;
        if (required > maxRequired) maxRequired = required;
      }
    }
    // Round up to nearest 100
    return (maxRequired / 100).ceil() * 100.0;
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildHoverAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: color.withValues(alpha: 0.15),
          highlightColor: color.withValues(alpha: 0.1),
          onTap: () {
            if (!mounted) return;
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Builder(
      builder: (buttonContext) {
        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: resolveThemeColor(context,
                dark: MyntColors.rippleDark,
                light: MyntColors.rippleLight),
            highlightColor: resolveThemeColor(context,
                dark: MyntColors.highlightDark,
                light: MyntColors.highlightLight),
            onTap: () => _showCardPopover(buttonContext),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.more_vert,
                size: 20,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCardPopover(BuildContext buttonContext) {
    shadcn.showPopover(
      context: buttonContext,
      alignment: Alignment.topLeft,
      offset: const Offset(0, 4),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(buttonContext).borderRadiusLg,
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(context).borderRadiusLg,
            boxShadow: isDarkMode(context)
                ? MyntShadows.dropdownDark
                : MyntShadows.dropdown,
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              width: 160,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPopoverItem(
                    context,
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    iconColor: resolveThemeColor(context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary),
                    textColor: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                    onTap: () {
                      shadcn.closeOverlay(context);
                      widget.onEdit();
                    },
                  ),
                  _buildPopoverItem(
                    context,
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    iconColor: resolveThemeColor(context,
                        dark: MyntColors.lossDark,
                        light: MyntColors.loss),
                    textColor: resolveThemeColor(context,
                        dark: MyntColors.lossDark,
                        light: MyntColors.loss),
                    onTap: () {
                      shadcn.closeOverlay(context);
                      widget.onDelete();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopoverItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        splashColor: resolveThemeColor(context,
            dark: MyntColors.rippleDark,
            light: MyntColors.rippleLight),
        highlightColor: resolveThemeColor(context,
            dark: MyntColors.highlightDark,
            light: MyntColors.highlightLight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 10),
              Text(label,
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.medium,
                      color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllocationEntry {
  final String label;
  final double percentage;
  final Color color;

  const _AllocationEntry(this.label, this.percentage, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_AllocationEntry> allocations;

  _DonutChartPainter(this.allocations);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 5.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -1.5708; // -π/2 (start from top)
    for (final a in allocations) {
      final sweepAngle = (a.percentage / 100) * 6.2832; // 2π
      final paint = Paint()
        ..color = a.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => false;
}


// Data models

class _AllocationBarPainter extends CustomPainter {
  final List<_AllocationEntry> allocations;

  _AllocationBarPainter(this.allocations);

  @override
  void paint(Canvas canvas, Size size) {
    final total = allocations.fold(0.0, (s, a) => s + a.percentage);
    double x = 0;

    for (int i = 0; i < allocations.length; i++) {
      final segWidth = (allocations[i].percentage / total) * size.width;
      final rect = Rect.fromLTWH(x, 0, segWidth, size.height);
      canvas.drawRect(rect, Paint()..color = allocations[i].color);
      x += segWidth;
    }
  }

  @override
  bool shouldRepaint(_AllocationBarPainter old) => old.allocations != allocations;
}

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
