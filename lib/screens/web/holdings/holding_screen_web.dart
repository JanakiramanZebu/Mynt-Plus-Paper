import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/screens/web/holdings/hold_table.dart';
import 'package:mynt_plus/screens/web/holdings/mf_hold_table.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

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
  ConsumerState<_HoldingScreenContent> createState() =>
      _HoldingScreenContentState();
}

class _HoldingScreenContentState extends ConsumerState<_HoldingScreenContent> {
  int _selectedTabIndex = 0;
  final ValueNotifier<String> _selectedFilter =
      ValueNotifier<String>('All'); // Filter options: All, Stocks, Bonds
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
    _selectedFilter.dispose();

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
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
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
                  _buildSummaryCards(
                      context, theme, portfolioData, _selectedTabIndex),
                  const SizedBox(height: 20),

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

  Widget _buildSummaryCards(BuildContext context, ThemesProvider theme,
      PortfolioProvider portfolioData, int selectedTab) {
    if (selectedTab == 0) {
      // Stocks tab - show stocks summary
      return _buildStocksSummaryCards(context, theme, portfolioData);
    } else {
      // Mutual Funds tab - show mutual funds summary
      return _buildMutualFundsSummaryCards(theme);
    }
  }

  Widget _buildStocksSummaryCards(BuildContext context, ThemesProvider theme,
      PortfolioProvider portfolioData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Invested',
            value: _calculateInvested(portfolioData),
            valueColor: resolveThemeColor(
              context,
              dark: MyntColors.textPrimaryDark,
              light: MyntColors.textPrimary,
            ),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Current Value',
            value: _calculateStocksValue(portfolioData),
            valueColor: resolveThemeColor(
              context,
              dark: MyntColors.textPrimaryDark,
              light: MyntColors.textPrimary,
            ),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Profit/Loss',
            value: _calculateProfitLoss(portfolioData),
            percentage: _calculateProfitLossPercent(portfolioData),
            valueColor:
                getValueColor(context, _calculateProfitLoss(portfolioData)),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Day Change',
            value: _calculateDayChange(portfolioData),
            percentage: _calculateDayChangePercent(portfolioData),
            valueColor:
                getValueColor(context, _calculateDayChange(portfolioData)),
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    // IconData? icon,
    required String label,
    required String value,
    String? percentage,
    required Color valueColor,
    required ThemesProvider theme,
  }) {
    return shadcn.Theme(
        data: shadcn.Theme.of(context).copyWith(radius: () => 0.3),
        child: shadcn.Card(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Icon in circle
                // if (icon != null)
                //   Container(
                //     width: 45,
                //     height: 45,
                //     decoration: BoxDecoration(
                //       color: resolveThemeColor(
                //         context,
                //         dark: MyntColors.primaryDark,
                //         light: MyntColors.primary,
                //       ).withOpacity(0.1),
                //       shape: BoxShape.circle,
                //     ),
                //     child: Center(
                //       child: Icon(
                //         icon,
                //         size: 20,
                //         color: resolveThemeColor(
                //           context,
                //           dark: MyntColors.primaryDark,
                //           light: MyntColors.primary,
                //         ),
                //       ),
                //     ),
                //   ),
                const SizedBox(width: 1),
                // Label and value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: MyntWebTextStyles.bodySmall(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary,
                          ),
                          fontWeight: MyntFonts.medium,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              value,
                              style: MyntWebTextStyles.head(
                                context,
                                color: valueColor,
                                fontWeight: MyntFonts.medium,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (percentage != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '($percentage%)',
                              style: MyntWebTextStyles.bodySmall(
                                context,
                                color: valueColor,
                                fontWeight: MyntFonts.medium,
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
        ));
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
                // icon: Icons.account_balance_wallet_outlined,
                label: 'Invested',
                value: investedValue,
                valueColor: resolveThemeColor(
                  context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary,
                ),
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                // icon: Icons.pie_chart_outline,
                label: 'Current Value',
                value: currentValue,
                valueColor: resolveThemeColor(
                  context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary,
                ),
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                // icon: Icons.trending_up,
                label: 'Returns',
                value: absReturnValue,
                percentage: absReturnPercent,
                valueColor: getValueColor(context, absReturnValue),
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
                  return ValueListenableBuilder<String>(
                    valueListenable: _selectedFilter,
                    builder: (context, filterType, child) {
                      return TableExample1(
                        searchQuery: searchQuery,
                        filterType: filterType,
                      );
                    },
                  );
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
    // Calculate counts for tabs
    final stocksCount = widget.listofHolding.length;
    final mutualFundsCount =
        ref.read(mfProvider).mfholdingnew?.data?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Row(
        children: [
          // Custom chip-style tabs matching the design
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Equity tab
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (mounted && _selectedTabIndex != 0) {
                      setState(() {
                        _selectedTabIndex = 0;
                        _mfSearchController.clear();
                        _mfSearchQuery.value = '';
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 0
                          ? (theme.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: null, // ✅ no border
                    ),
                    child: Text(
                      'Equity ($stocksCount)',
                      style: MyntWebTextStyles.body(
                        context,
                        fontWeight: _selectedTabIndex == 0
                            ? MyntFonts.semiBold
                            : MyntFonts.medium,
                      ).copyWith(
                        color: _selectedTabIndex == 0
                            ? shadcn.Theme.of(context).colorScheme.foreground
                            : shadcn.Theme.of(context)
                                .colorScheme
                                .mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Mutual Fund tab
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (mounted && _selectedTabIndex != 1) {
                      setState(() {
                        _selectedTabIndex = 1;
                        _stocksSearchController.clear();
                        _searchQuery.value = '';
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 1
                          ? (theme.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: null,
                    ),
                    child: Text(
                      'Mutual Fund ($mutualFundsCount)',
                      style: MyntWebTextStyles.body(
                        context,
                        fontWeight: _selectedTabIndex == 1
                            ? MyntFonts.semiBold
                            : MyntFonts.medium,
                      ).copyWith(
                        color: _selectedTabIndex == 1
                            ? shadcn.Theme.of(context).colorScheme.foreground
                            : shadcn.Theme.of(context)
                                .colorScheme
                                .mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                    style: MyntWebTextStyles.body(context),
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

                        return shadcn.Theme(
                          data: shadcn.Theme.of(context).copyWith(
                            radius: () => 0.2,
                            colorScheme: () =>
                                shadcn.Theme.of(context).colorScheme.copyWith(
                                      border: () => Colors.transparent,
                                      ring: () => Colors.transparent,
                                    ),
                          ),
                          child: shadcn.TextField(
                            controller: _stocksSearchController,
                            placeholder: Text(
                              'Search on holdings',
                              style: MyntWebTextStyles.placeholder(context),
                            ),
                            features: features,
                          ),
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
                    style: MyntWebTextStyles.body(context),
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

                        return shadcn.Theme(
                          data: shadcn.Theme.of(context).copyWith(
                            colorScheme: () =>
                                shadcn.Theme.of(context).colorScheme.copyWith(
                                      border: () => Colors.transparent,
                                      ring: () => Colors.transparent,
                                    ),
                          ),
                          child: shadcn.TextField(
                            controller: _mfSearchController,
                            placeholder: Text(
                              'Search on mutual funds',
                              style: MyntWebTextStyles.placeholder(context),
                            ),
                            features: features,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // const SizedBox(width: 16),
          ],
          // Filter dropdown button
          const SizedBox(width: 12),
          _buildFilterButton(theme),
          // E-DIS button (only for Stocks tab)
          if (_selectedTabIndex == 0) ...[
            const SizedBox(width: 12),
            _buildEdisButton(theme, portfolioData),
          ],
          // Reload button
          const SizedBox(width: 12),
          _buildIconButton(
            icon: Icons.refresh,
            onPressed: () async {
              if (_selectedTabIndex == 0) {
                await portfolioData.fetchHoldings(context, "Refresh");
              } else {
                await ref.read(mfProvider).fetchmfholdingnew();
              }
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  // Icon button helper (for filter and reload buttons)
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemesProvider theme,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
          highlightColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: theme.isDarkMode
                    ? MyntColors.textWhite
                    : MyntColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // E-DIS button
  Widget _buildEdisButton(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement E-DIS functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: resolveThemeColor(
            context,
            dark: MyntColors.primaryDark,
            light: MyntColors.primary,
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
        ),
        child: Text(
          'E-DIS',
          style: MyntWebTextStyles.body(
            context,
            fontWeight: MyntFonts.semiBold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Filter dropdown button
  Widget _buildFilterButton(ThemesProvider theme) {
    return Builder(
      builder: (buttonContext) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _showFilterPopup(buttonContext, theme),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  assets.searchFilter,
                  width: 20,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.iconDark,
                    light: MyntColors.icon,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterPopup(BuildContext context, ThemesProvider theme) {
    shadcn.showPopover(
      context: context,
      alignment: Alignment.topCenter,
      offset: const Offset(0, 8),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(context).borderRadiusLg,
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(context).borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 160, // Adjusted width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterMenuItem('All', theme),
                  _buildFilterMenuItem('Stocks', theme),
                  _buildFilterMenuItem('Bonds', theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Filter menu item helper
  Widget _buildFilterMenuItem(String value, ThemesProvider theme) {
    return ValueListenableBuilder<String>(
      valueListenable: _selectedFilter,
      builder: (context, currentFilter, child) {
        final isSelected = currentFilter == value;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _selectedFilter.value = value;
              shadcn.closeOverlay(context);
            },
            splashColor: resolveThemeColor(
              context,
              dark: MyntColors.rippleDark,
              light: MyntColors.rippleLight,
            ),
            highlightColor: resolveThemeColor(
              context,
              dark: MyntColors.highlightDark,
              light: MyntColors.highlightLight,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected
                    ? resolveThemeColor(
                        context,
                        dark: MyntColors.primaryDark.withOpacity(0.12),
                        light:
                            const Color(0xFFE8F0FE), // Light blue like in image
                      )
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: MyntWebTextStyles.body(
                        context,
                        fontWeight:
                            isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                        color: isSelected
                            ? resolveThemeColor(
                                context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary,
                              )
                            : resolveThemeColor(
                                context,
                                dark: MyntColors.textPrimaryDark,
                                light: MyntColors.textPrimary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Color getValueColor(BuildContext context, String value) {
    final numValue = double.tryParse(value) ?? 0.0;

    if (numValue > 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );
    } else if (numValue < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.lossDark,
        light: MyntColors.loss,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textPrimaryDark,
        light: MyntColors.textPrimary,
      );
    }
  }

  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }

  Color _getStatValueColor(String value, ThemesProvider theme) {
    // Extract numeric value from string (remove any text like percentages)
    final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
    final numValue = double.tryParse(cleanValue) ?? 0.0;

    if (numValue > 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );
    } else if (numValue < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.lossDark,
        light: MyntColors.loss,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textPrimaryDark,
        light: MyntColors.textPrimary,
      );
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
      if (newLtp != null &&
          newLtp != ltp &&
          newLtp != '0.00' &&
          newLtp != 'null') {
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
      return resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );
    } else if (numValue < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.lossDark,
        light: MyntColors.loss,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      dayPnL,
      style: MyntWebTextStyles.bodySmall(
        context,
        color: _getValueColor(dayPnL, widget.theme),
        fontWeight: MyntFonts.medium,
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
      return resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );
    } else if (numValue < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.lossDark,
        light: MyntColors.loss,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$dayPercent%',
      style: MyntWebTextStyles.bodySmall(
        context,
        color: _getValueColor(dayPercent, widget.theme),
        fontWeight: MyntFonts.medium,
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
        final newPnL =
            ((ltp - widget.avgPrice) * widget.qty).toStringAsFixed(2);
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
      return resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );
    } else if (numValue < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.lossDark,
        light: MyntColors.loss,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      overallPnL,
      style: MyntWebTextStyles.bodySmall(
        context,
        color: _getValueColor(overallPnL, widget.theme),
        fontWeight: MyntFonts.medium,
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
  ConsumerState<_OverallPercentCell> createState() =>
      _OverallPercentCellState();
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
            ? (((ltp - widget.avgPrice) / widget.avgPrice) * 100)
                .toStringAsFixed(2)
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
      return resolveThemeColor(
        context,
        dark: MyntColors.profitDark,
        light: MyntColors.profit,
      );
    } else if (numValue < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.lossDark,
        light: MyntColors.loss,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$overallPercent%',
      style: MyntWebTextStyles.bodySmall(
        context,
        color: _getValueColor(overallPercent, widget.theme),
        fontWeight: MyntFonts.medium,
      ),
      textAlign: TextAlign.right,
    );
  }
}
