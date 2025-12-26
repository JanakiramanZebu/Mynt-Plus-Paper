import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/screens/web/holdings/holding_detail_screen_web.dart';
import 'package:mynt_plus/screens/web/holdings/mf_holdings_screen_web.dart';

import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/ledger_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../sharedWidget/snack_bar.dart';
import '../../../../routes/route_names.dart';

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
  int _selectedTabIndex = 0; // 0 for Stocks, 1 for Mutual Funds
  // ✅ Use ValueNotifier for search queries to avoid rebuilding entire widget
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<String> _mfSearchQuery = ValueNotifier<String>('');
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // ✅ Use ValueNotifier instead of setState to avoid rebuilding entire widget
  final ValueNotifier<String?> _hoveredRowToken = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    // ✅ REMOVED: _setupSocketSubscription()
    // Isolated cell widgets handle socket updates directly
    // No need for parent widget to listen to socket at all
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _tabScrollController.dispose();
    _hoveredRowToken.dispose();
    _hoveredColumnIndex.dispose();
    _searchQuery.dispose(); // ✅ Dispose search query ValueNotifier
    _mfSearchQuery.dispose(); // ✅ Dispose MF search query ValueNotifier

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL FIX: Only watch holdloader to prevent unnecessary rebuilds
    // Using select() ensures we only rebuild when loading state changes
    final isLoading = ref.watch(portfolioProvider.select((p) => p.holdloader));
    final theme = ref.read(themeProvider);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ Access portfolioData without watching to avoid rebuilds
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
                  _buildSummaryCards(theme, portfolioData, _selectedTabIndex),
                  const SizedBox(height: 24),

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
      ThemesProvider theme, PortfolioProvider portfolioData, int selectedTab) {
    if (selectedTab == 0) {
      // Stocks tab - show stocks summary
      return _buildStocksSummaryCards(theme, portfolioData);
    } else {
      // Mutual Funds tab - show mutual funds summary
      return _buildMutualFundsSummaryCards(theme);
    }
  }

  Widget _buildStocksSummaryCards(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    // final positiveCount = _getPositiveHoldingsCount(portfolioData);
    // final negativeCount = _getNegativeHoldingsCount(portfolioData);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? WebDarkColors.backgroundSecondary
            : WebColors.backgroundSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          width: 1,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Profit/Loss',
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.semiBold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _calculateProfitLoss(portfolioData),
                              style: WebTextStyles.head(
                                isDarkTheme: theme.isDarkMode,
                                color: _getValueColor(
                                    _calculateProfitLoss(portfolioData), theme),
                                fontWeight: WebFonts.bold,
                              ),
                            ),
                            Text(
                              ' (${_calculateProfitLossPercent(portfolioData)}%)',
                              style: WebTextStyles.head(
                                isDarkTheme: theme.isDarkMode,
                                color: _getValueColor(
                                    _calculateProfitLossPercent(portfolioData),
                                    theme),
                                fontWeight: WebFonts.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Stocks Value',
                  _calculateStocksValue(portfolioData),
                  _getStatValueColor(
                      _calculateStocksValue(portfolioData), theme),
                  theme,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Day Change',
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.semiBold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _calculateDayChange(portfolioData),
                              style: WebTextStyles.head(
                                isDarkTheme: theme.isDarkMode,
                                color: _getValueColor(
                                    _calculateDayChange(portfolioData), theme),
                                fontWeight: WebFonts.bold,
                              ),
                            ),
                            Text(
                              ' (${_calculateDayChangePercent(portfolioData)}%)',
                              style: WebTextStyles.head(
                                isDarkTheme: theme.isDarkMode,
                                color: _getValueColor(
                                    _calculateDayChangePercent(portfolioData),
                                    theme),
                                fontWeight: WebFonts.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Invested',
                  _calculateInvested(portfolioData),
                  _getStatValueColor(_calculateInvested(portfolioData), theme),
                  theme,
                ),
              ),
              // _buildDivider(theme),
            ],
          ),
          // const SizedBox(height: 20),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     const SizedBox(width: 20),
          //     _buildPositionChip(
          //         '$positiveCount Positive', theme.isDarkMode ? WebDarkColors.success : WebColors.success, theme),
          //     const SizedBox(width: 12),
          //     _buildPositionChip('$negativeCount Negative', theme.isDarkMode ? WebDarkColors.error : WebColors.error, theme),
          //   ],
          // ),
        ],
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

        // Calculate positive and negative mutual fund counts
        // final positiveCount = _getPositiveMutualFundsCount(mfData);
        // final negativeCount = _getNegativeMutualFundsCount(mfData);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? WebDarkColors.backgroundSecondary
                : WebColors.backgroundSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
              width: 1,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 10,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Invested',
                      investedValue,
                      _getStatValueColor(investedValue, theme),
                      theme,
                    ),
                  ),
                  _buildDivider(theme),
                  Expanded(
                    child: _buildStatItem(
                      'Current Value',
                      currentValue,
                      _getStatValueColor(currentValue, theme),
                      theme,
                    ),
                  ),
                  _buildDivider(theme),
                  Expanded(
                    child: _buildStatItem(
                      'Returns',
                      absReturnValue,
                      _getValueColor(absReturnValue, theme),
                      theme,
                    ),
                  ),
                  _buildDivider(theme),
                  Expanded(
                    child: _buildStatItem(
                      'Percentage',
                      '$absReturnPercent%',
                      _getValueColor(absReturnPercent, theme),
                      theme,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     const SizedBox(width: 20),
              //     _buildPositionChip(
              //         '$positiveCount Positive', theme.isDarkMode ? WebDarkColors.success : WebColors.success, theme),
              //     const SizedBox(width: 12),
              //     _buildPositionChip(
              //         '$negativeCount Negative', theme.isDarkMode ? WebDarkColors.error : WebColors.error, theme),
              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, Color valueColor, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
            fontWeight: WebFonts.semiBold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: WebTextStyles.head(
            isDarkTheme: theme.isDarkMode,
            color: valueColor,
            fontWeight: WebFonts.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemesProvider theme) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
    );
  }

  Widget _buildPositionChip(String text, Color color, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: WebTextStyles.sub(
          isDarkTheme: theme.isDarkMode,
          color: color,
          fontWeight: WebFonts.semiBold,
        ),
      ),
    );
  }

  Widget _buildMainContent(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? WebColors.textPrimary
            : WebDarkColors.textPrimary,
        // borderRadius: BorderRadius.circular(8),
        // border: Border.all(
        //   color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs and Action Bar in same row
          _buildTabsAndActionBar(theme, portfolioData),
          const SizedBox(height: 16),
          // Content based on selected tab
          Expanded(
            child: _selectedTabIndex == 0
                ? // Table for Stocks - Use parent ScrollControllers
                  _buildHoldingsTable(theme, portfolioData)
                : // Mutual Funds Tab - Child has its own ScrollControllers
                  // Don't use parent ScrollControllers to avoid conflicts
                  ValueListenableBuilder<String>(
                    valueListenable: _mfSearchQuery,
                    builder: (context, searchQuery, child) {
                      return MfHoldingsScreenWeb(
                        showSummaryCards: false,
                        searchQuery: searchQuery,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndActionBar(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    final stocksCount = _getStocksCount(portfolioData);
    final mutualFundsCount = _getMutualFundsCount(portfolioData);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          // Segmented Control Tabs on the left
          _buildSegmentedControl(
              theme, portfolioData, stocksCount, mutualFundsCount),
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
                  child: Container(
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.inputBackground
                      : WebColors.inputBackground,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode
                        ? WebDarkColors.inputBorder
                        : WebColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  onChanged: (value) => _searchQuery.value = value, // ✅ Use ValueNotifier instead of setState
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search holdings',
                    hintStyle: WebTextStyles.formInput(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        assets.searchIcon,
                        color: theme.isDarkMode
                            ? WebDarkColors.iconSecondary
                            : WebColors.iconSecondary,
                        fit: BoxFit.scaleDown,
                        width: 18,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            );
              },
            ),
            const SizedBox(width: 16),
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
                  child: Container(
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.inputBackground
                      : WebColors.inputBackground,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode
                        ? WebDarkColors.inputBorder
                        : WebColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  onChanged: (value) => _mfSearchQuery.value = value, // ✅ Use ValueNotifier instead of setState
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search mutual funds',
                    hintStyle: WebTextStyles.formInput(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        assets.searchIcon,
                        color: theme.isDarkMode
                            ? WebDarkColors.iconSecondary
                            : WebColors.iconSecondary,
                        fit: BoxFit.scaleDown,
                        width: 18,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            );
              },
            ),
            const SizedBox(width: 16),
          ],
          // Refresh Button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(.15)
                  : Colors.black.withOpacity(.15),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(.08)
                  : Colors.black.withOpacity(.08),
              onTap: () async {
                if (_selectedTabIndex == 0) {
                  await portfolioData.fetchHoldings(context, "Refresh");
                } else {
                  await ref.read(mfProvider).fetchmfholdingnew();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.refresh,
                  size: 20,
                  color: theme.isDarkMode
                      ? WebDarkColors.iconSecondary
                      : WebColors.iconSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(ThemesProvider theme,
      PortfolioProvider portfolioData, int stocksCount, int mutualFundsCount) {
    final tabs = [
      'Stocks ($stocksCount)',
      'Mutual Funds ($mutualFundsCount)',
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
          // Left arrow button
          // _buildTabArrowButton(
          //   icon: Icons.chevron_left,
          //   onPressed: () => _scrollTabsLeft(),
          //   theme: theme,
          // ),
          // const SizedBox(width: 5),
          // Tabs scrollable area
          SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int index = 0; index < tabs.length; index++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildSegmentedTab(
                      tabs[index],
                      index,
                      _selectedTabIndex == index,
                      false,
                      theme,
                    ),
                  ),
              ],
            ),
          ),
          // const SizedBox(width: 5),
          // Right arrow button
          // _buildTabArrowButton(
          //   icon: Icons.chevron_right,
          //   onPressed: () => _scrollTabsRight(),
          //   theme: theme,
          // ),
        ],
    );
  }

  Widget _buildSegmentedTab(
    String title,
    int index,
    bool isSelected,
    bool isLast,
    ThemesProvider theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemesProvider theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.isDarkMode ? WebDarkColors.border : WebColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: theme.isDarkMode
                  ? WebDarkColors.iconSecondary
                  : WebColors.iconSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _scrollTabsLeft() {
    if (!_tabScrollController.hasClients) return;

    final currentOffset = _tabScrollController.offset;
    final newOffset = (currentOffset - 200)
        .clamp(0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollTabsRight() {
    if (!_tabScrollController.hasClients) return;

    final currentOffset = _tabScrollController.offset;
    final newOffset = (currentOffset + 200)
        .clamp(0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // Responsive breakpoints
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  // Helper method to get responsive column configuration
  Map<String, dynamic> _getResponsiveHoldingColumns(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: Show only essential columns
      return {
        'headers': ['Instrument', 'Net Qty', 'LTP', 'Day P&L', 'Overall P&L'],
        'columnFlex': {
          'Instrument': 4,
          'Net Qty': 2,
          'LTP': 2,
          'Day P&L': 2,
          'Overall P&L': 2,
        },
        'columnMinWidth': {
          'Instrument': 280,
          'Net Qty': 120,
          'LTP': 110,
          'Day P&L': 130,
          'Overall P&L': 140,
        },
      };
    } else if (screenWidth < _tabletBreakpoint) {
      // Tablet: Show most columns
      return {
        'headers': ['Instrument', 'Net Qty', 'Avg Price', 'LTP', 'Current Value', 'Day P&L', 'Overall P&L'],
        'columnFlex': {
          'Instrument': 4,
          'Net Qty': 1,
          'Avg Price': 2,
          'LTP': 1,
          'Current Value': 2,
          'Day P&L': 2,
          'Overall P&L': 2,
        },
        'columnMinWidth': {
          'Instrument': 280,
          'Net Qty': 110,
          'Avg Price': 120,
          'LTP': 100,
          'Current Value': 165,
          'Day P&L': 120,
          'Overall P&L': 155,
        },
      };
    } else if (screenWidth < _desktopBreakpoint) {
      // Small Desktop: Show more columns
      return {
        'headers': ['Instrument', 'Net Qty', 'Avg Price', 'LTP', 'Invested', 'Current Value', 'Day P&L', 'Overall P&L', 'Overall %'],
        'columnFlex': {
          'Instrument': 4,
          'Net Qty': 1,
          'Avg Price': 2,
          'LTP': 1,
          'Invested': 2,
          'Current Value': 2,
          'Day P&L': 2,
          'Overall P&L': 2,
          'Overall %': 1,
        },
        'columnMinWidth': {
          'Instrument': 280,
          'Net Qty': 110,
          'Avg Price': 120,
          'LTP': 100,
          'Invested': 120,
          'Current Value': 165,
          'Day P&L': 120,
          'Overall P&L': 155,
          'Overall %': 110,
        },
      };
    } else {
      // Large Desktop: Full columns with optimal widths
      return {
        'headers': ['Instrument', 'Net Qty', 'Avg Price', 'LTP', 'Invested', 'Current Value', 'Day P&L', 'Day %', 'Overall P&L', 'Overall %'],
        'columnFlex': {
          'Instrument': 4,
          'Net Qty': 1,
          'Avg Price': 2,
          'LTP': 1,
          'Invested': 2,
          'Current Value': 2,
          'Day P&L': 2,
          'Day %': 1,
          'Overall P&L': 2,
          'Overall %': 1,
        },
        'columnMinWidth': {
          'Instrument': 300,
          'Net Qty': 120,
          'Avg Price': 130,
          'LTP': 110,
          'Invested': 130,
          'Current Value': 220,
          'Day P&L': 150,
          'Day %': 110,
          'Overall P&L': 165,
          'Overall %': 120,
        },
      };
    }
  }

  Widget _buildHoldingsTable(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    // ✅ Use ValueListenableBuilder to only rebuild table when search query changes
    return ValueListenableBuilder<String>(
      valueListenable: _selectedTabIndex == 0 ? _searchQuery : _mfSearchQuery,
      builder: (context, searchQuery, child) {
        final filteredHoldings = _getFilteredHoldings(portfolioData);

        if (filteredHoldings.isEmpty) {
          return const SizedBox(
            height: 400,
            child: Center(child: NoDataFound()),
          );
        }
        
        return _buildTableContent(theme, portfolioData, filteredHoldings);
      },
    );
  }

  Widget _buildTableContent(
      ThemesProvider theme, PortfolioProvider portfolioData, List<dynamic> filteredHoldings) {

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height: screen height minus all UI elements
        final screenHeight = MediaQuery.of(context).size.height;
        const padding = 32.0; // Top and bottom padding (16 * 2)
        const headerHeight = 120.0; // Summary cards height
        const tabsAndSearchHeight = 100.0; // Tabs and search bar
        const spacing = 24.0 + 16.0; // Spacing between sections
        const bottomMargin = 20.0; // Bottom margin
        final tableHeight =
            screenHeight - padding - headerHeight - tabsAndSearchHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveHoldingColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            height: calculatedHeight.toDouble(),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: theme.isDarkMode
                  ? WebDarkColors.background
                  : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  // Make both scrollbars always visible
                  thumbVisibility: WidgetStateProperty.all(true),
                  trackVisibility: WidgetStateProperty.all(true),
                  
                  // Consistent thickness for both horizontal and vertical
                  thickness: WidgetStateProperty.all(6.0),
                  crossAxisMargin: 0.0, // Remove margin to align scrollbars properly
                  mainAxisMargin: 0.0,
                  
                  // Consistent radius
                  radius: const Radius.circular(3),
                  
                  // Consistent colors for both scrollbars
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  
                  // Ensure consistent behavior for both directions
                  trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0, // Minimum thumb length for both scrollbars
                ),
              ),
              child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 1200, // Increased to accommodate wider columns
              sortColumnIndex: null, // Disable DataTable2's sort indicators
              sortAscending: true,
              fixedLeftColumns: 1, // Fix the first column (Instrument)
              fixedColumnsColor: theme.isDarkMode 
                  ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                  : WebColors.backgroundSecondary.withOpacity(0.8),
              showBottomBorder: true,
              horizontalScrollController: _horizontalScrollController,
              scrollController: _verticalScrollController,
              // Make scrollbars always visible
              showCheckboxColumn: false,
              headingRowColor: WidgetStateProperty.all(
                theme.isDarkMode
                    ? WebDarkColors.primary
                    : WebColors.primary.withOpacity(0.05),
              ),
              headingTextStyle: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
              dataTextStyle: WebTextStyles.custom(
                fontSize: 13,
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
                fontWeight: WebFonts.medium,
              ),
                  border: TableBorder(
                    top: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                      width: 1,
                    ),
                    horizontalInside: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                      width: 1,
                    ),
                    // Remove vertical lines by not setting left, right, and verticalInside
                  ),
              columns: _buildDataTable2Columns(headers, columnMinWidth, theme, screenWidth),
              rows: _buildDataTable2Rows(filteredHoldings, headers, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  int _getColumnIndexForHeader(String header) {
    switch (header) {
      case 'Instrument': return 0;
      case 'Net Qty': return 1;
      case 'Avg Price': return 2;
      case 'LTP': return 3;
      case 'Invested': return 4;
      case 'Current Value': return 5;
      case 'Day P&L': return 6;
      case 'Day %': return 7;
      case 'Overall P&L': return 8;
      case 'Overall %': return 9;
      default: return -1;
    }
  }


  // Helper method to determine column alignment based on content type
  bool _isNumericColumn(String header) {
    return header != 'Instrument'; // All columns except Instrument contain numeric data
  }


  Widget _buildSortableHeaderContent(String header, bool isNumeric, ThemesProvider theme, int columnIndex) {
    final isCurrentlySorted = _sortColumnIndex == columnIndex;
    
    // Determine which icon to show
    IconData sortIcon;
    if (isCurrentlySorted) {
      sortIcon = _sortAscending ? Icons.arrow_upward : Icons.arrow_downward;
    } else {
      sortIcon = Icons.unfold_more;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  header,
                  style: WebTextStyles.tableHeader(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                  ),
                  textAlign: isNumeric ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                sortIcon,
                size: 16,
                color: isCurrentlySorted
                    ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                    : (theme.isDarkMode
                        ? WebDarkColors.textSecondary.withOpacity(0.6)
                        : WebColors.textSecondary.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ],
      );
  }

  List<DataColumn2> _buildDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
    double screenWidth,
  ) {
    // Responsive Instrument column width based on screen size
    double instrumentWidth;
    if (screenWidth >= _desktopBreakpoint) {
      instrumentWidth = 300.0;
    } else if (screenWidth >= _tabletBreakpoint) {
      instrumentWidth = 280.0;
    } else if (screenWidth >= _mobileBreakpoint) {
      instrumentWidth = 250.0;
    } else {
      instrumentWidth = 200.0;
    }

    return headers.map((header) {
      final columnIndex = _getColumnIndexForHeader(header);
      final isNumeric = _isNumericColumn(header);

      return DataColumn2(
        label: SizedBox.expand(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => _hoveredColumnIndex.value = columnIndex,
            onExit: (_) => _hoveredColumnIndex.value = null,
            child: Tooltip(
              message: 'Sort by $header',
              child: GestureDetector(
                onTap: () => _onManualSort(columnIndex),
                behavior: HitTestBehavior.opaque,
                child: ValueListenableBuilder<int?>(
                  valueListenable: _hoveredColumnIndex,
                  builder: (context, hoveredIndex, child) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: hoveredIndex == columnIndex
                            ? (theme.isDarkMode
                                ? WebDarkColors.primary.withOpacity(0.1)
                                : WebColors.primary.withOpacity(0.05))
                            : Colors.transparent,
                      ),
                      alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                      child: _buildSortableHeaderContent(header, isNumeric, theme, columnIndex),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        size: header == 'Instrument' ? ColumnSize.L : ColumnSize.S,
        fixedWidth: header == 'Instrument' ? instrumentWidth : null,
        onSort: null, // Disable DataTable2's onSort
      );
    }).toList();
  }

  List<DataRow2> _buildDataTable2Rows(
    List<dynamic> holdings,
    List<String> headers,
    ThemesProvider theme,
  ) {
    return holdings.asMap().entries.map((entry) {
      final index = entry.key;
      final holding = entry.value;
      final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
          ? holding.exchTsym![0]
          : null;
      final token = exchTsym?.token ?? '';
      final uniqueId = '$token$index';
      // final isHovered = _hoveredRowToken == uniqueId;

      return DataRow2(
        onTap: () => _showHoldingDetail(holding),
        color: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered) || _hoveredRowToken.value == uniqueId) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return Colors.transparent;
        }),
        cells: headers.map((header) {
          final isNumeric = _isNumericColumn(header);
          return DataCell(
            MouseRegion(
              onEnter: (_) => _hoveredRowToken.value = uniqueId,
              onExit: (_) => _hoveredRowToken.value = null,
              child: SizedBox.expand(
                child: Container(
                  alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: _buildStreamCellContent(header, holding, theme, exchTsym, uniqueId, token),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  // Optimized cell content using isolated widgets for dynamic data
  // Only the specific cell widgets rebuild, not the entire DataTable2
  Widget _buildStreamCellContent(
    String column,
    dynamic holding,
    ThemesProvider theme,
    dynamic exchTsym,
    String uniqueId,
    String token,
  ) {
    // Static columns - render once, never rebuild
    switch (column) {
      case 'Instrument':
        return _buildInstrumentCellContent(holding, theme, exchTsym, uniqueId);

      case 'Net Qty':
        final qty = holding.currentQty ?? 0;
        final qtyText = qty > 0 ? '+$qty' : '$qty';
        return Text(
          qtyText,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getQtyColor(qty, theme),
            fontWeight: WebFonts.medium,
          ),
          textAlign: TextAlign.right,
        );

      case 'Avg Price':
        final avgPrc = holding.avgPrc != null && holding.avgPrc!.isNotEmpty
            ? holding.avgPrc!
            : '0.00';
        return Text(avgPrc, textAlign: TextAlign.right);

      case 'Invested':
        return Text(holding.invested ?? '0.00', textAlign: TextAlign.right);

      // Dynamic columns - use isolated widgets that manage their own state
      // Each widget only rebuilds itself, not the table
      case 'LTP':
        if (token.isEmpty) {
          return Text(exchTsym?.lp ?? '0.00', textAlign: TextAlign.right);
        }
        return _LTPCell(
          token: token,
          initialLtp: exchTsym?.lp ?? '0.00',
        );

      case 'Current Value':
        if (token.isEmpty) {
          return Text(holding.currentValue ?? '0.00', textAlign: TextAlign.right);
        }
        return _CurrentValueCell(
          token: token,
          qty: holding.currentQty ?? 0,
          initialValue: holding.currentValue ?? '0.00',
        );

      case 'Day P&L':
        if (token.isEmpty) {
          return _buildDataTable2CellContent(column, holding, theme, exchTsym, uniqueId);
        }
        return _DayPnLCell(
          token: token,
          initialValue: exchTsym?.oneDayChg ?? '0.00',
          theme: theme,
        );

      case 'Day %':
        if (token.isEmpty) {
          return _buildDataTable2CellContent(column, holding, theme, exchTsym, uniqueId);
        }
        return _DayPercentCell(
          token: token,
          initialValue: exchTsym?.perChange ?? '0.00',
          theme: theme,
        );

      case 'Overall P&L':
        if (token.isEmpty) {
          return _buildDataTable2CellContent(column, holding, theme, exchTsym, uniqueId);
        }
        return _OverallPnLCell(
          token: token,
          qty: holding.currentQty ?? 0,
          avgPrice: double.tryParse(holding.avgPrc ?? '0') ?? 0.0,
          initialValue: exchTsym?.profitNloss ?? '0.00',
          theme: theme,
        );

      case 'Overall %':
        if (token.isEmpty) {
          return _buildDataTable2CellContent(column, holding, theme, exchTsym, uniqueId);
        }
        return _OverallPercentCell(
          token: token,
          avgPrice: double.tryParse(holding.avgPrc ?? '0') ?? 0.0,
          initialValue: exchTsym?.pNlChng ?? '0.00',
          theme: theme,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // Fallback method for cells without socket data
  Widget _buildDataTable2CellContent(
    String column,
    dynamic holding,
    ThemesProvider theme,
    dynamic exchTsym,
    String uniqueId,
  ) {
    switch (column) {
      case 'Instrument':
        return _buildInstrumentCellContent(holding, theme, exchTsym, uniqueId);
      case 'Net Qty':
        final qty = holding.currentQty ?? 0;
        final qtyText = qty > 0 ? '+$qty' : '$qty';
        return Text(
          qtyText,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getQtyColor(qty, theme),
            fontWeight: WebFonts.medium,
          ),
          textAlign: TextAlign.right,
        );
      case 'Avg Price':
        final avgPrc = holding.avgPrc != null && holding.avgPrc!.isNotEmpty
            ? holding.avgPrc!
            : '0.00';
        return Text(avgPrc, textAlign: TextAlign.right);
      case 'LTP':
        return Text(exchTsym?.lp ?? '0.00', textAlign: TextAlign.right);
      case 'Invested':
        return Text(holding.invested ?? '0.00', textAlign: TextAlign.right);
      case 'Current Value':
        return Text(holding.currentValue ?? '0.00', textAlign: TextAlign.right);
      case 'Day P&L':
        final dayPnL = exchTsym?.oneDayChg ?? '0.00';
        return Text(
          dayPnL,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getValueColor(dayPnL, theme),
            fontWeight: WebFonts.medium,
          ),
          textAlign: TextAlign.right,
        );
      case 'Day %':
        final dayPercent = exchTsym?.perChange ?? '0.00';
        return Text(
          '$dayPercent%',
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getValueColor(dayPercent, theme),
            fontWeight: WebFonts.medium,
          ),
          textAlign: TextAlign.right,
        );
      case 'Overall P&L':
        final overallPnL = exchTsym?.profitNloss ?? '0.00';
        return Text(
          overallPnL,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getValueColor(overallPnL, theme),
            fontWeight: WebFonts.medium,
          ),
          textAlign: TextAlign.right,
        );
      case 'Overall %':
        final overallPercent = exchTsym?.pNlChng ?? '0.00';
        return Text(
          '$overallPercent%',
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getValueColor(overallPercent, theme),
            fontWeight: WebFonts.medium,
          ),
          textAlign: TextAlign.right,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInstrumentCellContent(
    dynamic holding,
    ThemesProvider theme,
    dynamic exchTsym,
    String uniqueId,
  ) {
    if (exchTsym == null) {
      return const Text('N/A');
    }

    final displayText = '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}';

    // ✅ Use ValueListenableBuilder to avoid rebuilding entire table on hover
    return ValueListenableBuilder<String?>(
      valueListenable: _hoveredRowToken,
      builder: (context, hoveredToken, child) {
        final rowIsHovered = hoveredToken == uniqueId;

        return Row(
          children: [
            Expanded(
              flex: rowIsHovered ? 1 : 2,
          child: Tooltip(
            message: displayText,
            child: Text(
              displayText,
              style: WebTextStyles.custom(
                fontSize: 13,
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
                fontWeight: WebFonts.medium,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Action buttons fade in on hover
        IgnorePointer(
          ignoring: !rowIsHovered,
          child: AnimatedOpacity(
            opacity: rowIsHovered ? 1 : 0,
            duration: const Duration(milliseconds: 140),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((holding.currentQty ?? 0) > 0) ...[
                  _buildHoverButton(
                    label: 'Add',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                    onPressed: () async {
                      await _handleAddHolding(context, holding, exchTsym);
                    },
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                ],
                // Show Exit button for all holdings with positive quantity
                // The exit handler will validate saleableQty when clicked
                if ((holding.currentQty ?? 0) > 0) ...[
                  _buildHoverButton(
                    label: 'Exit',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.tertiary
                        : WebColors.tertiary,
                    onPressed: () async {
                      await _handleExitHolding(context, holding, exchTsym);
                    },
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                ],
                _buildHoverButton(
                  icon: Icons.bar_chart,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  borderRadius: 5.0,
                  onPressed: () async {
                    await _handleChartTap(context, holding, exchTsym);
                  },
                  theme: theme,
                ),
                const SizedBox(width: 6),
                _buildHoverButton(
                  label: 'Pledge',
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  borderRadius: 5.0,
                  onPressed: () {
                    _handlePledgeUnpledge(context);
                  },
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
      },
    );
  }

  DataCell _buildInstrumentDataCell(
    dynamic holding,
    ThemesProvider theme,
    dynamic exchTsym,
    String uniqueId,
  ) {
    if (exchTsym == null) {
      return const DataCell(Text('N/A'));
    }

    final displayText = '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}';
    final rowIsHovered = _hoveredRowToken == uniqueId;
    
    return DataCell(
      Row(
        children: [
          Expanded(
            flex: rowIsHovered ? 1 : 2,
            child: Tooltip(
              message: displayText,
              child: Text(
                displayText,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Action buttons fade in on hover
          IgnorePointer(
            ignoring: !rowIsHovered,
            child: AnimatedOpacity(
              opacity: rowIsHovered ? 1 : 0,
              duration: const Duration(milliseconds: 140),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((holding.currentQty ?? 0) > 0) ...[
                    _buildHoverButton(
                      label: 'Add',
                      color: Colors.white,
                      backgroundColor: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                      onPressed: () async {
                        await _handleAddHolding(context, holding, exchTsym);
                      },
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                  ],
                  // Show Exit button for all holdings with positive quantity
                  // The exit handler will validate saleableQty when clicked
                  if ((holding.currentQty ?? 0) > 0) ...[
                    _buildHoverButton(
                      label: 'Exit',
                      color: Colors.white,
                      backgroundColor: theme.isDarkMode
                          ? WebDarkColors.tertiary
                          : WebColors.tertiary,
                      onPressed: () async {
                        await _handleExitHolding(context, holding, exchTsym);
                      },
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                  ],
                  _buildHoverButton(
                    icon: Icons.bar_chart,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    borderRadius: 5.0,
                    onPressed: () async {
                      await _handleChartTap(context, holding, exchTsym);
                    },
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildHoverButton(
                    label: 'Pledge',
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    borderRadius: 5.0,
                    onPressed: () {
                      _handlePledgeUnpledge(context);
                    },
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }





  DataCell _buildInstrumentCellWithHover(
      dynamic holding, ThemesProvider theme, String token) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    if (exchTsym == null) {
      return DataCell(
        Text(
          'N/A',
          style: WebTextStyles.tableDataCompact(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
      );
    }

    final holdingToken = exchTsym.token ?? '';
    final displayText = '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}';

    return DataCell(
      MouseRegion(
        onEnter: (_) => _hoveredRowToken.value = holdingToken,
        onExit: (_) => _hoveredRowToken.value = null,
        child: SizedBox.expand(
          child: ValueListenableBuilder<String?>(
            valueListenable: _hoveredRowToken,
            builder: (context, hoveredToken, child) {
              final isHovered = hoveredToken == holdingToken;

              return Row(
                children: [
                  // Text that takes at least 50% of width, leaves space for buttons
                  Expanded(
                    flex: isHovered
                        ? 1
                        : 2, // When hovered, text takes less space but still visible
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Tooltip(
                        message: displayText,
                        child: Text(
                          displayText,
                          style: WebTextStyles.tableDataCompact(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  // Buttons on the right side - fade in/out
                  IgnorePointer(
                    ignoring: !isHovered,
                    child: AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((holding.currentQty ?? 0) > 0) ...[
                        _buildHoverButton(
                          label: 'Add',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          onPressed: () async {
                            await _handleAddHolding(context, holding, exchTsym);
                          },
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Exit button for all holdings with positive quantity
                      // The exit handler will validate saleableQty when clicked
                      if ((holding.currentQty ?? 0) > 0) ...[
                        _buildHoverButton(
                          label: 'Exit',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.tertiary
                              : WebColors.tertiary,
                          onPressed: () async {
                            await _handleExitHolding(
                                context, holding, exchTsym);
                          },
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Chart button
                      _buildHoverButton(
                        icon: Icons.bar_chart,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        borderRadius: 5.0,
                        onPressed: () async {
                          await _handleChartTap(context, holding, exchTsym);
                        },
                        theme: theme,
                      ),
                      const SizedBox(width: 6),
                      // Pledge button
                      _buildHoverButton(
                        label: 'Pledge',
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        borderRadius: 5.0,
                        onPressed: () {
                          _handlePledgeUnpledge(context);
                        },
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
            },
          ),
        ),
      ),
    );
  }

  DataCell _buildCellWithHover(
      dynamic holding, ThemesProvider theme, String token, DataCell cell) {
    // Wrap the cell's child with MouseRegion to detect hover anywhere on the row
    // Use SizedBox.expand to fill the entire cell area, not just the text content
    return DataCell(
      MouseRegion(
        onEnter: (_) => _hoveredRowToken.value = token,
        onExit: (_) => _hoveredRowToken.value = null,
        child: SizedBox.expand(
          child: Align(
            alignment: Alignment.centerRight,
            child: cell.child,
          ),
        ),
      ),
    );
  }

  DataCell _buildInstrumentCell(dynamic holding, ThemesProvider theme) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    if (exchTsym == null) {
      return DataCell(
        Text(
          'N/A',
          style: WebTextStyles.tableDataCompact(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
      );
    }

    return DataCell(
      Text(
        '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataCell _buildNetQtyCell(dynamic holding, ThemesProvider theme) {
    final qty = holding.currentQty ?? 0;
    final qtyText = qty > 0 ? '+$qty' : '$qty';

    return DataCell(
      Text(
        qtyText,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getQtyColor(qty, theme),
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildAvgPriceCell(dynamic holding, ThemesProvider theme) {
    final avgPrc = holding.avgPrc != null && holding.avgPrc!.isNotEmpty
        ? holding.avgPrc!
        : null;

    return DataCell(
      Text(
        avgPrc ?? '0.00',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildLTPCell(dynamic holding, ThemesProvider theme) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    return DataCell(
      Text(
        exchTsym?.lp ?? '0.00',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildInvestedCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.invested ?? '0.00',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildCurrentValueCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.currentValue ?? '0.00',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildDayPnLCell(dynamic holding, ThemesProvider theme) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    final dayPnL = exchTsym?.oneDayChg ?? '0.00';

    return DataCell(
      Text(
        dayPnL,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(dayPnL, theme),
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildDayPercentCell(dynamic holding, ThemesProvider theme) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    final dayPercent = exchTsym?.perChange ?? '0.00';

    return DataCell(
      Text(
        '$dayPercent%',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(dayPercent, theme),
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildOverallPnLCell(dynamic holding, ThemesProvider theme) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    final overallPnL = exchTsym?.profitNloss ?? '0.00';

    return DataCell(
      Text(
        overallPnL,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(overallPnL, theme),
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _buildOverallPercentCell(dynamic holding, ThemesProvider theme) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    final overallPercent = exchTsym?.pNlChng ?? '0.00';

    return DataCell(
      Text(
        '$overallPercent%',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(overallPercent, theme),
        ).copyWith(fontWeight: FontWeight.w600),
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

  int _getMutualFundsCount(PortfolioProvider portfolioData) {
    return ref.watch(mfProvider).mfholdingnew?.data?.length ?? 0;
  }

  int _getPositiveHoldingsCount(PortfolioProvider portfolioData) {
    int count = 0;
    for (var holding in widget.listofHolding) {
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final exchTsym = holding.exchTsym![0];
        if (exchTsym.profitNloss != null) {
          final pnl = double.tryParse(exchTsym.profitNloss) ?? 0.0;
          if (pnl > 0) count++;
        }
      }
    }
    return count;
  }

  int _getNegativeHoldingsCount(PortfolioProvider portfolioData) {
    int count = 0;
    for (var holding in widget.listofHolding) {
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final exchTsym = holding.exchTsym![0];
        if (exchTsym.profitNloss != null) {
          final pnl = double.tryParse(exchTsym.profitNloss) ?? 0.0;
          if (pnl < 0) count++;
        }
      }
    }
    return count;
  }

  List<dynamic> _getFilteredHoldings(PortfolioProvider portfolioData) {
    List<dynamic> holdings = _selectedTabIndex == 0
        ? widget.listofHolding
            .where((holding) =>
                holding.sPrdtAli == 'CNC' ||
                holding.sPrdtAli == 'MIS' ||
                holding.sPrdtAli == 'NRML')
            .toList()
        : widget.listofHolding
            .where((holding) => holding.sPrdtAli == 'MF')
            .toList();

    // Apply search filter - use ValueNotifier value
    final searchQuery = _selectedTabIndex == 0 ? _searchQuery.value : _mfSearchQuery.value;
    if (searchQuery.isNotEmpty) {
      holdings = holdings.where((holding) {
        if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
          final exchTsym = holding.exchTsym![0];
          final symbol = exchTsym.tsym?.toLowerCase() ?? '';
          final exch = exchTsym.exch?.toLowerCase() ?? '';
          final searchLower = searchQuery.toLowerCase();
          return symbol.contains(searchLower) || exch.contains(searchLower);
        }
        return false;
      }).toList();
    }

    // Apply sorting
    if (_sortColumnIndex != null) {
      holdings.sort((a, b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Instrument
            final aExchTsym =
                a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
            final bExchTsym =
                b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;
            final aSymbol = aExchTsym?.tsym ?? '';
            final bSymbol = bExchTsym?.tsym ?? '';
            comparison = aSymbol.compareTo(bSymbol);
            break;
          case 1: // Net Qty
            final aQty = int.tryParse(a.currentQty?.toString() ?? '0') ?? 0;
            final bQty = int.tryParse(b.currentQty?.toString() ?? '0') ?? 0;
            comparison = aQty.compareTo(bQty);
            break;
          case 2: // Avg Price
            final aExchTsym =
                a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
            final bExchTsym =
                b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;
            final aPrice = double.tryParse(aExchTsym?.close ?? '0') ?? 0;
            final bPrice = double.tryParse(bExchTsym?.close ?? '0') ?? 0;
            comparison = aPrice.compareTo(bPrice);
            break;
          case 3: // LTP
            final aExchTsym =
                a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
            final bExchTsym =
                b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;
            final aLtp = double.tryParse(aExchTsym?.lp ?? '0') ?? 0;
            final bLtp = double.tryParse(bExchTsym?.lp ?? '0') ?? 0;
            comparison = aLtp.compareTo(bLtp);
            break;
          case 4: // Invested
            final aInvested = double.tryParse(a.invested ?? '0') ?? 0;
            final bInvested = double.tryParse(b.invested ?? '0') ?? 0;
            comparison = aInvested.compareTo(bInvested);
            break;
          case 5: // Current Value
            final aValue = double.tryParse(a.currentValue ?? '0') ?? 0;
            final bValue = double.tryParse(b.currentValue ?? '0') ?? 0;
            comparison = aValue.compareTo(bValue);
            break;
          case 6: // Day P&L
            final aExchTsym =
                a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
            final bExchTsym =
                b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;
            final aDayPnL = double.tryParse(aExchTsym?.oneDayChg ?? '0') ?? 0;
            final bDayPnL = double.tryParse(bExchTsym?.oneDayChg ?? '0') ?? 0;
            comparison = aDayPnL.compareTo(bDayPnL);
            break;
          case 7: // Day %
            final aExchTsym =
                a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
            final bExchTsym =
                b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;
            final aDayPercent =
                double.tryParse(aExchTsym?.perChange ?? '0') ?? 0;
            final bDayPercent =
                double.tryParse(bExchTsym?.perChange ?? '0') ?? 0;
            comparison = aDayPercent.compareTo(bDayPercent);
            break;
          case 8: // Overall P&L
            final aExchTsym =
                a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
            final bExchTsym =
                b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;
            final aOverallPnL =
                double.tryParse(aExchTsym?.profitNloss ?? '0') ?? 0;
            final bOverallPnL =
                double.tryParse(bExchTsym?.profitNloss ?? '0') ?? 0;
            comparison = aOverallPnL.compareTo(bOverallPnL);
            break;
          case 9: // Overall %
            final aExchTsym =
                a.exchTsym?.isNotEmpty == true ? a.exchTsym![0] : null;
            final bExchTsym =
                b.exchTsym?.isNotEmpty == true ? b.exchTsym![0] : null;
            final aOverallPercent =
                double.tryParse(aExchTsym?.pNlChng ?? '0') ?? 0;
            final bOverallPercent =
                double.tryParse(bExchTsym?.pNlChng ?? '0') ?? 0;
            comparison = aOverallPercent.compareTo(bOverallPercent);
            break;
        }

        return _sortAscending ? comparison : -comparison;
      });
    }

    return holdings;
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode
          ? WebDarkColors.success
          : WebColors.success; // Green
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error; // Red
    } else {
      return theme.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary; // Grey
    }
  }

  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }

  int _getPositiveMutualFundsCount(MFProvider mfData) {
    int count = 0;
    final holdings = mfData.mfholdingnew?.data ?? [];
    for (var holding in holdings) {
      final pnl = double.tryParse(holding.profitLoss ?? '0') ?? 0.0;
      if (pnl > 0) count++;
    }
    return count;
  }

  int _getNegativeMutualFundsCount(MFProvider mfData) {
    int count = 0;
    final holdings = mfData.mfholdingnew?.data ?? [];
    for (var holding in holdings) {
      final pnl = double.tryParse(holding.profitLoss ?? '0') ?? 0.0;
      if (pnl < 0) count++;
    }
    return count;
  }

  Color _getQtyColor(int qty, ThemesProvider theme) {
    if (qty > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (qty < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    }
  }

  bool _shouldShowLockIcon(dynamic holding) {
    if (holding.brkcolqty == null) return false;
    final qty = double.tryParse(holding.brkcolqty) ?? 0.0;
    return qty > 0;
  }

  void _showHoldingDetail(dynamic holding) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    if (exchTsym == null) return;

    showDialog(
      context: context,
      builder: (context) => HoldingDetailScreenWeb(
        holding: holding,
        exchTsym: exchTsym,
      ),
    );
  }

  void _onManualSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        // Same column clicked - toggle sort direction
        _sortAscending = !_sortAscending;
      } else {
        // Different column clicked - set as new sort column with ascending
      _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }


  Color _getStatValueColor(String value, ThemesProvider theme) {
    // Extract numeric value from string (remove any text like percentages)
    final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
    final numValue = double.tryParse(cleanValue) ?? 0.0;

    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    }
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    double? iconWeight,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final isLongLabel = label != null && label.length > 1;
    final borderRadiusValue = borderRadius ?? 5.0;
    return SizedBox(
      width: isLongLabel ? null : 25,
      height: 25,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            padding:
                isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1.3,
                    )
                  : null,
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      size: 16,
                      color: color,
                      weight: iconWeight ?? 400,
                    )
                  : Text(
                      label ?? "",
                      style: WebTextStyles.buttonXs(
                        isDarkTheme: theme.isDarkMode,
                        color: color,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChartTap(
      BuildContext context, dynamic holding, dynamic exchTsym) async {
    final scripData = ref.read(marketWatchProvider);

    await scripData.fetchScripQuoteIndex(
      exchTsym.token ?? "",
      exchTsym.exch ?? "",
      context,
    );
    final quots = scripData.getQuotes;
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch?.toString() ?? "",
        token: quots.token?.toString() ?? "",
        tsym: quots.tsym?.toString() ?? "",
        instname: quots.instname?.toString() ?? "",
        symbol: quots.symbol?.toString() ?? "",
        expDate: quots.expDate?.toString() ?? "",
        option: quots.option?.toString() ?? "",
      );
      scripData.scripdepthsize(false);
      await scripData.calldepthApis(context, depthArgs, "");
    }
  }

  Future<void> _handlePlaceOrder(BuildContext context, dynamic holding,
      dynamic exchTsym, bool isBuy) async {
    try {
      final scripData = ref.read(marketWatchProvider);

      // Fetch scrip info first
      await scripData.fetchScripInfo(
        exchTsym.token ?? "",
        exchTsym.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final scripInfo = scripData.scripInfoModel!;
      final lotSize = scripInfo.ls?.toString() ?? "1";

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: exchTsym.exch ?? "",
        tSym: exchTsym.tsym ?? "",
        isExit: false,
        token: exchTsym.token ?? "",
        transType: isBuy,
        lotSize: lotSize,
        ltp: exchTsym.lp ?? "0.00",
        perChange: exchTsym.perChange ?? "0.00",
        orderTpye: '',
        holdQty: holding.currentQty?.toString() ?? '',
        isModify: false,
        raw: {},
      );

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(
          context, "Error placing order: ${e.toString()}");
    }
  }

  Future<void> _handleExitHolding(
      BuildContext context, dynamic holding, dynamic exchTsym) async {
    try {
      // Check if there's saleable quantity before proceeding
      if (holding.saleableQty == null || holding.saleableQty == 0) {
        showResponsiveWarningMessage(
          context,
          'You are unable to exit because there are no sellable quantity.',
        );
        return;
      }

      final scripData = ref.read(marketWatchProvider);

      await scripData.fetchScripInfo(
        exchTsym.token ?? "",
        exchTsym.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final scripInfo = scripData.scripInfoModel!;
      final lotSize = exchTsym.ls?.toString() ?? scripInfo.ls?.toString() ?? "1";

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: exchTsym.exch ?? "",
        tSym: exchTsym.tsym ?? "",
        isExit: true,
        token: '',
        transType: false,
        prd: holding.prd ?? "",
        lotSize: lotSize,
        ltp: exchTsym.lp ?? "0.00",
        perChange: exchTsym.perChange ?? "0.00",
        orderTpye: holding.sPrdtAli ?? '',
        holdQty: holding.saleableQty?.toString() ?? '',
        isModify: false,
        raw: {},
      );

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(
          context, "Error exiting holding: ${e.toString()}");
    }
  }

  Future<void> _handleAddHolding(
      BuildContext context, dynamic holding, dynamic exchTsym) async {
    try {
      final scripData = ref.read(marketWatchProvider);

      await scripData.fetchScripInfo(
        exchTsym.token ?? "",
        exchTsym.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: exchTsym.exch ?? "",
        tSym: exchTsym.tsym ?? "",
        isExit: false,
        token: exchTsym.token ?? "",
        transType: true,
        prd: holding.prd ?? "",
        lotSize: lotSize,
        ltp: exchTsym.lp ?? "0.00",
        perChange: exchTsym.perChange ?? "0.00",
        orderTpye: holding.sPrdtAli ?? '',
        holdQty: holding.currentQty?.toString() ?? '',
        isModify: false,
        raw: {},
      );

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripData.scripInfoModel!,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(
          context, "Error adding holding: ${e.toString()}");
    }
  }

  void _handlePledgeUnpledge(BuildContext context) async {
    final ledgerdate = ref.read(ledgerProvider);
    if (ledgerdate.pledgeandunpledge == null) {
      await ledgerdate.getCurrentDate("pandu");
      
      ledgerdate.fetchpledgeandunpledge(context);
    }
    Navigator.pushNamed(context, Routes.pledgeandun, arguments: "DDDDD");
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
