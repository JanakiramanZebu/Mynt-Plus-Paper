import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/screens/web/holdings/hold_table.dart';
import 'package:mynt_plus/screens/web/holdings/mf_hold_table.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../res/global_font_web.dart' hide WebTextStyles;

class HoldingScreenWeb extends ConsumerWidget {
  final List<dynamic> listofHolding;
  const HoldingScreenWeb({super.key, required this.listofHolding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch loading state
    final isLoading = ref.watch(portfolioProvider.select((p) => p.holdloader));

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _HoldingScreenContent(listofHolding: listofHolding);
  }
}

class _HoldingScreenContent extends ConsumerStatefulWidget {
  final List<dynamic> listofHolding;
  const _HoldingScreenContent({required this.listofHolding});

  @override
  ConsumerState<_HoldingScreenContent> createState() => _HoldingScreenContentState();
}


class _HoldingScreenContentState extends ConsumerState<_HoldingScreenContent> {
  int _selectedTabIndex = 0; 
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<String> _mfSearchQuery = ValueNotifier<String>('');
  final TextEditingController _stocksSearchController = TextEditingController();
  final TextEditingController _mfSearchController = TextEditingController();

  final ValueNotifier<String?> _hoveredRowToken = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    
    // Sync controllers with ValueNotifiers
    _stocksSearchController.addListener(() {
      if (_stocksSearchController.text != _searchQuery.value) {
        _searchQuery.value = _stocksSearchController.text;
      }
    });
    
    _mfSearchController.addListener(() {
      if (_mfSearchController.text != _mfSearchQuery.value) {
        _mfSearchQuery.value = _mfSearchController.text;
      }
    });
  }

  @override
  void dispose() {
    _hoveredRowToken.dispose();
    _hoveredColumnIndex.dispose();
    _searchQuery.dispose(); 
    _mfSearchQuery.dispose(); 
    _stocksSearchController.dispose(); 
    _mfSearchController.dispose(); 

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(portfolioProvider.select((p) => p.holdloader));
    final theme = ref.read(themeProvider);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final portfolioData = ref.read(portfolioProvider);

    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: RefreshIndicator(
            onRefresh: () async {
              await portfolioData.fetchHoldings(context, "Refresh");
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Summary Cards Section
                  // _buildSummaryCards(context, theme, portfolioData, _selectedTabIndex),
                  // const SizedBox(height: 24),

                  // Main Content Area - Expanded to fill remaining space
                  Expanded(
                    child: _buildMainContent(theme, portfolioData),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
      BuildContext context, ThemesProvider theme, PortfolioProvider portfolioData, int selectedTab) {
    if (selectedTab == 0) {
      // Stocks tab - show stocks summary
      return _buildStocksSummaryCards(context, theme, portfolioData);
    } else {
      // Mutual Funds tab - show mutual funds summary
      return _buildMutualFundsSummaryCards(theme);
    }
  }

  Widget _buildStocksSummaryCards(
      BuildContext context, ThemesProvider theme, PortfolioProvider portfolioData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Profit/Loss',
            value: _calculateProfitLoss(portfolioData),
            percentage: _calculateProfitLossPercent(portfolioData),
            valueColor: getValueColor(context, _calculateProfitLoss(portfolioData)),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pie_chart_outline,
            label: 'Stocks Value',
            value: _calculateStocksValue(portfolioData),
            valueColor: _getStatValueColor(_calculateStocksValue(portfolioData), theme),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_outlined,
            label: 'Day Change',
            value: _calculateDayChange(portfolioData),
            percentage: _calculateDayChangePercent(portfolioData),
            valueColor: getValueColor(context, _calculateDayChange(portfolioData)),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Invested',
            value: _calculateInvested(portfolioData),
            valueColor: _getStatValueColor(_calculateInvested(portfolioData), theme),
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    String? percentage,
    required Color valueColor,
    required ThemesProvider theme,
  }) {
    return shadcn.Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Icon in circle
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: WebTextStyles.sub(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                      fontWeight: WebFonts.medium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: WebTextStyles.head(
                            isDarkTheme: theme.isDarkMode,
                            color: valueColor,
                            fontWeight: WebFonts.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (percentage != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '($percentage%)',
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: valueColor,
                            fontWeight: WebFonts.medium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMutualFundsSummaryCards(ThemesProvider theme) {
    return Consumer(
      builder: (context, ref, _) {
        final mfData = ref.watch(mfProvider);
        final summary = mfData.mfholdingnew?.summary;
        final investedValue = _formatValue(summary?.invested);
        final currentValue = _formatValue(summary?.currentValue);
        final absReturnValue = _formatValue(summary?.absReturnValue);
        final absReturnPercent =
            _formatValue(summary?.absReturnPercent?.toString());

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'Returns',
                value: absReturnValue,
                percentage: absReturnPercent,
                valueColor: getValueColor(context, absReturnValue),
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pie_chart_outline,
                label: 'Current Value',
                value: currentValue,
                valueColor: _getStatValueColor(currentValue, theme),
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Invested',
                value: investedValue,
                valueColor: _getStatValueColor(investedValue, theme),
                theme: theme,
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildMainContent(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs and Action Bar in same row
        _buildTabsAndActionBar(theme, portfolioData),
        const SizedBox(height: 16),
        // Content based on selected tab - Using IndexedStack for better performance
        Expanded(
          child: IndexedStack(
            index: _selectedTabIndex,
            children: [
              // Stocks tab - Using TableExample1 from hold_table.dart with search
              ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (context, searchQuery, child) {
                  return TableExample1(searchQuery: searchQuery);
                },
              ),
              // Mutual Funds tab - Using MfTableExample from mf_hold_table.dart with search
              ValueListenableBuilder<String>(
                valueListenable: _mfSearchQuery,
                builder: (context, searchQuery, child) {
                  return MfTableExample(searchQuery: searchQuery);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabsAndActionBar(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    // Calculate counts without watching providers to avoid rebuilds on tab switch
    final stocksCount = _getStocksCount(portfolioData);
    // Use ref.read instead of ref.watch to prevent rebuilds when switching tabs
    final mutualFundsCount = ref.read(mfProvider).mfholdingnew?.data?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Row(
        children: [
          // Shadcn TabList on the left - Direct implementation for better responsiveness
          // Wrap with shadcn.Theme to use custom primary color for active tab
          Builder(
            builder: (context) {
              final currentTheme = shadcn.Theme.of(context);
              final isDark = theme.isDarkMode;
              // Create a new ColorScheme based on the default, but with custom primary color
              final baseColorScheme = isDark 
                  ? shadcn.ColorSchemes.darkDefaultColor
                  : shadcn.ColorSchemes.lightDefaultColor;
              
              // Create custom ColorScheme with theme-appropriate primary color
              final primaryColor = theme.isDarkMode 
                  ? WebDarkColors.primary 
                  : WebColors.primary;
              final customColorScheme = baseColorScheme.copyWith(
                primary: () => primaryColor,
              );
              
              return shadcn.Theme(
                data: shadcn.ThemeData(
                  colorScheme: customColorScheme,
                  radius: currentTheme.radius,
                ),
                child: shadcn.TabList(
                  index: _selectedTabIndex,
                  onChanged: (value) {
                    // Update state immediately without any delays or async operations
                    if (mounted && _selectedTabIndex != value) {
                      setState(() {
                        _selectedTabIndex = value;
                        // Clear the search query when switching tabs
                        if (value == 0) {
                          _mfSearchController.clear();
                          _mfSearchQuery.value = '';
                        } else {
                          _stocksSearchController.clear();
                          _searchQuery.value = '';
                        }
                      });
                    }
                  },
                  children: [
                    shadcn.TabItem(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'Geist',
                          color: _selectedTabIndex == 0
                              ? (theme.isDarkMode 
                                  ? WebDarkColors.primary 
                                  : WebColors.primary)
                              : customColorScheme.mutedForeground,
                          fontWeight: WebFonts.bold,
                        ),
                        child: Text(
                          'Stocks ($stocksCount)',
                        ),
                      ),
                    ),
                    shadcn.TabItem(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'Geist',
                          color: _selectedTabIndex == 1
                              ? (theme.isDarkMode 
                                  ? WebDarkColors.primary 
                                  : WebColors.primary)
                              : customColorScheme.mutedForeground,
                          fontWeight: WebFonts.bold,
                        ),
                        child: Text(
                          'Mutual Funds ($mutualFundsCount)',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Spacer to push action items to the right
          const Spacer(),
          // Search Bar - Show different search based on selected tab
          if (_selectedTabIndex == 0) ...[
            // Stocks tab search
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive search bar width
                final screenWidth = MediaQuery.of(context).size.width;
                double searchWidth;
                if (screenWidth >= 1200) {
                  searchWidth = 400;
                } else if (screenWidth >= 800) {
                  searchWidth = 300;
                } else {
                  searchWidth = 200;
                }

                return SizedBox(
                  height: 40,
                  width: searchWidth,
                  child: DefaultTextStyle(
                    style: const TextStyle(fontFamily: 'Geist'),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _searchQuery,
                      builder: (context, searchValue, child) {
                        final features = <shadcn.InputFeature>[
                          shadcn.InputFeature.leading(
                            SvgPicture.asset(
                              assets.searchIcon,
                              color: shadcn.Theme.of(context)
                                  .colorScheme
                                  .mutedForeground,
                              fit: BoxFit.scaleDown,
                              width: 18,
                            ),
                          ),
                        ];

                        // Add clear button if there's text
                        if (searchValue.isNotEmpty) {
                          features.add(
                            shadcn.InputFeature.trailing(
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      _stocksSearchController.clear();
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: shadcn.Theme.of(context)
                                            .colorScheme
                                            .mutedForeground,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return shadcn.TextField(
                          controller: _stocksSearchController,
                          placeholder: Text(
                            'Search holdings',
                            style: const TextStyle(fontFamily: 'Geist'),
                          ),
                          features: features,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // const SizedBox(width: 16),
          ] else if (_selectedTabIndex == 1) ...[
            // Mutual Funds tab search
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive search bar width
                final screenWidth = MediaQuery.of(context).size.width;
                double searchWidth;
                if (screenWidth >= 1200) {
                  searchWidth = 400;
                } else if (screenWidth >= 800) {
                  searchWidth = 300;
                } else {
                  searchWidth = 200;
                }

                return SizedBox(
                  height: 40,
                  width: searchWidth,
                  child: DefaultTextStyle(
                    style: const TextStyle(fontFamily: 'Geist'),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _mfSearchQuery,
                      builder: (context, searchValue, child) {
                        final features = <shadcn.InputFeature>[
                          shadcn.InputFeature.leading(
                            SvgPicture.asset(
                              assets.searchIcon,
                              color: shadcn.Theme.of(context)
                                  .colorScheme
                                  .mutedForeground,
                              fit: BoxFit.scaleDown,
                              width: 18,
                            ),
                          ),
                        ];

                        // Add clear button if there's text
                        if (searchValue.isNotEmpty) {
                          features.add(
                            shadcn.InputFeature.trailing(
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      _mfSearchController.clear();
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: shadcn.Theme.of(context)
                                            .colorScheme
                                            .mutedForeground,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return shadcn.TextField(
                          controller: _mfSearchController,
                          placeholder: Text(
                            'Search mutual funds',
                            style: const TextStyle(fontFamily: 'Geist'),
                          ),
                          features: features,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // const SizedBox(width: 16),
          ],
          // Refresh Button
          // Material(
          //   color: Colors.transparent,
          //   shape: const CircleBorder(),
          //   child: InkWell(
          //     customBorder: const CircleBorder(),
          //     splashColor: theme.isDarkMode
          //         ? Colors.white.withOpacity(.15)
          //         : Colors.black.withOpacity(.15),
          //     highlightColor: theme.isDarkMode
          //         ? Colors.white.withOpacity(.08)
          //         : Colors.black.withOpacity(.08),
          //     onTap: () async {
          //       if (_selectedTabIndex == 0) {
          //         await portfolioData.fetchHoldings(context, "Refresh");
          //       } else {
          //         await ref.read(mfProvider).fetchmfholdingnew();
          //       }
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.all(6),
          //       child: Icon(
          //         Icons.refresh,
          //         size: 20,
          //         color: theme.isDarkMode
          //             ? WebDarkColors.iconSecondary
          //             : WebColors.iconSecondary,
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 8),
        ],
      ),
    );
  }





  // Helper methods
  String _calculateStocksValue(PortfolioProvider portfolioData) {
    double totalValue = 0.0;
    for (var holding in widget.listofHolding) {
      if (holding.currentValue != null) {
        totalValue += double.tryParse(holding.currentValue) ?? 0.0;
      }
    }
    return totalValue.toStringAsFixed(2);
  }

  String _calculateDayChange(PortfolioProvider portfolioData) {
    double totalChange = 0.0;
    for (var holding in widget.listofHolding) {
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final exchTsym = holding.exchTsym![0];
        if (exchTsym.oneDayChg != null) {
          totalChange += double.tryParse(exchTsym.oneDayChg) ?? 0.0;
        }
      }
    }
    return totalChange.toStringAsFixed(2);
  }

  String _calculateDayChangePercent(PortfolioProvider portfolioData) {
    double totalValue = 0.0;
    double totalChange = 0.0;

    for (var holding in widget.listofHolding) {
      if (holding.currentValue != null) {
        totalValue += double.tryParse(holding.currentValue) ?? 0.0;
      }
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final exchTsym = holding.exchTsym![0];
        if (exchTsym.oneDayChg != null) {
          totalChange += double.tryParse(exchTsym.oneDayChg) ?? 0.0;
        }
      }
    }

    if (totalValue > 0) {
      return ((totalChange / totalValue) * 100).toStringAsFixed(2);
    }
    return '0.00';
  }

  String _calculateInvested(PortfolioProvider portfolioData) {
    double totalInvested = 0.0;
    for (var holding in widget.listofHolding) {
      if (holding.invested != null) {
        totalInvested += double.tryParse(holding.invested) ?? 0.0;
      }
    }
    return totalInvested.toStringAsFixed(2);
  }

  String _calculateProfitLoss(PortfolioProvider portfolioData) {
    double totalPnL = 0.0;
    for (var holding in widget.listofHolding) {
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final exchTsym = holding.exchTsym![0];
        if (exchTsym.profitNloss != null) {
          totalPnL += double.tryParse(exchTsym.profitNloss) ?? 0.0;
        }
      }
    }
    return totalPnL.toStringAsFixed(2);
  }

  String _calculateProfitLossPercent(PortfolioProvider portfolioData) {
    double totalInvested = 0.0;
    double totalPnL = 0.0;

    for (var holding in widget.listofHolding) {
      if (holding.invested != null) {
        totalInvested += double.tryParse(holding.invested) ?? 0.0;
      }
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final exchTsym = holding.exchTsym![0];
        if (exchTsym.profitNloss != null) {
          totalPnL += double.tryParse(exchTsym.profitNloss) ?? 0.0;
        }
      }
    }

    if (totalInvested > 0) {
      return ((totalPnL / totalInvested) * 100).toStringAsFixed(2);
    }
    return '0.00';
  }

  int _getStocksCount(PortfolioProvider portfolioData) {
    return widget.listofHolding.length;
  }




  Color getValueColor(BuildContext context, String value) {
    final numValue = double.tryParse(value) ?? 0.0;
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    if (numValue > 0) {
      return colorScheme.chart2;
    } else if (numValue < 0) {
      return colorScheme.destructive;
    } else {
      return colorScheme.mutedForeground;
    }
  }


  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }




  Color _getStatValueColor(String value, ThemesProvider theme) {
    // Extract numeric value from string (remove any text like percentages)
    final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
    final numValue = double.tryParse(cleanValue) ?? 0.0;
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    if (numValue > 0) {  //greater
      return colorScheme.chart2;
    } else if (numValue < 0) {
      return colorScheme.destructive;
    } else {
      return colorScheme.mutedForeground;
    }
  }

}

// Isolated widget for LTP - only this rebuilds when LTP changes
class _LTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;

  const _LTPCell({required this.token, required this.initialLtp});

  @override
  ConsumerState<_LTPCell> createState() => _LTPCellState();
}

class _LTPCellState extends ConsumerState<_LTPCell> {
  late String ltp;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialLtp;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != ltp && newLtp != '0.00' && newLtp != 'null') {
        setState(() => ltp = newLtp);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(ltp, textAlign: TextAlign.right);
  }
}

// Isolated widget for Current Value
class _CurrentValueCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final String initialValue;

  const _CurrentValueCell({
    required this.token,
    required this.qty,
    required this.initialValue,
  });

  @override
  ConsumerState<_CurrentValueCell> createState() => _CurrentValueCellState();
}

class _CurrentValueCellState extends ConsumerState<_CurrentValueCell> {
  late String currentValue;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        final newValue = (ltp * widget.qty).toStringAsFixed(2);
        if (newValue != currentValue) {
          setState(() => currentValue = newValue);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(currentValue, textAlign: TextAlign.right);
  }
}

// Isolated widget for Day P&L
class _DayPnLCell extends ConsumerStatefulWidget {
  final String token;
  final String initialValue;
  final ThemesProvider theme;

  const _DayPnLCell({
    required this.token,
    required this.initialValue,
    required this.theme,
  });

  @override
  ConsumerState<_DayPnLCell> createState() => _DayPnLCellState();
}

class _DayPnLCellState extends ConsumerState<_DayPnLCell> {
  late String dayPnL;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    dayPnL = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newValue = data[widget.token]['chng']?.toString();
      if (newValue != null && newValue != dayPnL && newValue != 'null') {
        setState(() => dayPnL = newValue);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      dayPnL,
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: _getValueColor(dayPnL, widget.theme),
        fontWeight: WebFonts.medium,
      ),
      textAlign: TextAlign.right,
    );
  }
}

// Isolated widget for Day %
class _DayPercentCell extends ConsumerStatefulWidget {
  final String token;
  final String initialValue;
  final ThemesProvider theme;

  const _DayPercentCell({
    required this.token,
    required this.initialValue,
    required this.theme,
  });

  @override
  ConsumerState<_DayPercentCell> createState() => _DayPercentCellState();
}

class _DayPercentCellState extends ConsumerState<_DayPercentCell> {
  late String dayPercent;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    dayPercent = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newValue = data[widget.token]['pc']?.toString();
      if (newValue != null && newValue != dayPercent && newValue != 'null') {
        setState(() => dayPercent = newValue);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$dayPercent%',
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: _getValueColor(dayPercent, widget.theme),
        fontWeight: WebFonts.medium,
      ),
      textAlign: TextAlign.right,
    );
  }
}

// Isolated widget for Overall P&L
class _OverallPnLCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final double avgPrice;
  final String initialValue;
  final ThemesProvider theme;

  const _OverallPnLCell({
    required this.token,
    required this.qty,
    required this.avgPrice,
    required this.initialValue,
    required this.theme,
  });

  @override
  ConsumerState<_OverallPnLCell> createState() => _OverallPnLCellState();
}

class _OverallPnLCellState extends ConsumerState<_OverallPnLCell> {
  late String overallPnL;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    overallPnL = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        final newPnL = ((ltp - widget.avgPrice) * widget.qty).toStringAsFixed(2);
        if (newPnL != overallPnL) {
          setState(() => overallPnL = newPnL);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      overallPnL,
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: _getValueColor(overallPnL, widget.theme),
        fontWeight: WebFonts.medium,
      ),
      textAlign: TextAlign.right,
    );
  }
}

// Isolated widget for Overall %
class _OverallPercentCell extends ConsumerStatefulWidget {
  final String token;
  final double avgPrice;
  final String initialValue;
  final ThemesProvider theme;

  const _OverallPercentCell({
    required this.token,
    required this.avgPrice,
    required this.initialValue,
    required this.theme,
  });

  @override
  ConsumerState<_OverallPercentCell> createState() => _OverallPercentCellState();
}

class _OverallPercentCellState extends ConsumerState<_OverallPercentCell> {
  late String overallPercent;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    overallPercent = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        final newPercent = widget.avgPrice > 0
            ? (((ltp - widget.avgPrice) / widget.avgPrice) * 100).toStringAsFixed(2)
            : '0.00';
        if (newPercent != overallPercent) {
          setState(() => overallPercent = newPercent);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$overallPercent%',
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: _getValueColor(overallPercent, widget.theme),
        fontWeight: WebFonts.medium,
      ),
      textAlign: TextAlign.right,
    );
  }
}
