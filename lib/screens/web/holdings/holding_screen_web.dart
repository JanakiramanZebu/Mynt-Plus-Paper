import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
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

class HoldingScreenWeb extends ConsumerStatefulWidget {
  final List<dynamic> listofHolding;
  const HoldingScreenWeb({super.key, required this.listofHolding});

  @override
  ConsumerState<HoldingScreenWeb> createState() => _HoldingScreenWebState();
}

class _HoldingScreenWebState extends ConsumerState<HoldingScreenWeb> {
  StreamSubscription? _socketSubscription;
  int _selectedTabIndex = 0; // 0 for Stocks, 1 for Mutual Funds
  String _searchQuery = '';
  String _mfSearchQuery = ''; // Search query for Mutual Funds tab
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  String? _hoveredRowToken; // Track which row is being hovered

  @override
  void initState() {
    super.initState();
    _setupSocketSubscription();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _tabScrollController.dispose();
    
    // Close WebSocket connection when screen is disposed
    try {
      ProviderScope.containerOf(context).read(websocketProvider).closeSocket(false);
    } catch (e) {
      // Context might not be available during disposal, ignore error
      print('WebSocket close error during disposal: $e');
    }
    
    super.dispose();
  }

  void _setupSocketSubscription() {
    Future.microtask(() {
      final websocket = ref.read(websocketProvider);

      _socketSubscription = websocket.socketDataStream.listen((socketDatas) {
        bool needsUpdate = false;

        for (var holding in widget.listofHolding) {
          if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
            final exchTsym = holding.exchTsym![0];
            if (socketDatas.containsKey(exchTsym.token)) {
              final socketData = socketDatas[exchTsym.token];
              final lp = socketData['lp']?.toString();
              if (lp != null && lp != "null" && lp != exchTsym.lp) {
                exchTsym.lp = lp;
                needsUpdate = true;
              }

              final pc = socketData['pc']?.toString();
              if (pc != null && pc != "null" && pc != exchTsym.perChange) {
                exchTsym.perChange = pc;
                needsUpdate = true;
              }
            }
          }
        }

        if (needsUpdate) {
          if (mounted) setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioData = ref.watch(portfolioProvider);
    final theme = ref.read(themeProvider);

    if (portfolioData.holdloader) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: () async {
            await portfolioData.fetchHoldings(context, "Refresh");
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards Section
                  _buildSummaryCards(theme, portfolioData, _selectedTabIndex),
                  const SizedBox(height: 24),
      
                  // Main Content Area
                  _buildMainContent(theme, portfolioData),
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
    final positiveCount = _getPositiveHoldingsCount(portfolioData);
    final negativeCount = _getNegativeHoldingsCount(portfolioData);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
       color: theme.isDarkMode ? WebDarkColors.backgroundSecondary : WebColors.backgroundSecondary.withOpacity(0.3),
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
                            color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
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
                            color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
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
        final positiveCount = _getPositiveMutualFundsCount(mfData);
        final negativeCount = _getNegativeMutualFundsCount(mfData);

        return Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? WebDarkColors.backgroundSecondary : WebColors.backgroundSecondary.withOpacity(0.3),
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
                      '${absReturnPercent}%',
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
            color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
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
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            ? WebColors.textPrimary :
             WebDarkColors.textPrimary,
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
          if (_selectedTabIndex == 0) ...[
            // Table for Stocks
            _buildHoldingsTable(theme, portfolioData),
          ] else if (_selectedTabIndex == 1) ...[
            // Mutual Funds Tab - Show MF Holdings Screen
            MfHoldingsScreenWeb(
              showSummaryCards: false,
              searchQuery: _mfSearchQuery,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabsAndActionBar(ThemesProvider theme, PortfolioProvider portfolioData) {
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
          _buildSegmentedControl(theme, portfolioData, stocksCount, mutualFundsCount),
          // Spacer to push action items to the right
          const Spacer(),
          // Search Bar - Show different search based on selected tab
          if (_selectedTabIndex == 0) ...[
            // Stocks tab search
            SizedBox(
              width: 400,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? WebDarkColors.inputBackground : WebColors.inputBackground,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode ? WebDarkColors.inputBorder : WebColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ] else if (_selectedTabIndex == 1) ...[
            // Mutual Funds tab search
            SizedBox(
              width: 400,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? WebDarkColors.inputBackground : WebColors.inputBackground,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode ? WebDarkColors.inputBorder : WebColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _mfSearchQuery = value),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
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

  Widget _buildSegmentedControl(ThemesProvider theme, PortfolioProvider portfolioData, int stocksCount, int mutualFundsCount) {
    final tabs = [
      'Stocks ($stocksCount)',
      'Mutual Funds ($mutualFundsCount)',
    ];

    return SizedBox(
      height: 45,
      child: Row(
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
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : (theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface),
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? WebFonts.bold : WebFonts.semiBold,
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
            color: theme.isDarkMode
                ? WebDarkColors.surface
                : WebColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.isDarkMode
                  ? WebDarkColors.border
                  : WebColors.border,
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
    final newOffset = (currentOffset - 200).clamp(
        0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollTabsRight() {
    if (!_tabScrollController.hasClients) return;

    final currentOffset = _tabScrollController.offset;
    final newOffset = (currentOffset + 200).clamp(
        0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildHoldingsTable(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    final filteredHoldings = _getFilteredHoldings(portfolioData);

    if (filteredHoldings.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          child: Scrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            radius: Radius.zero,
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(right: 16), // Space for vertical scrollbar
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DataTable(
                columnSpacing: 10,
                horizontalMargin: 0,
                showCheckboxColumn: false,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                headingRowHeight: 44,
                headingRowColor: WidgetStateProperty.all(Colors.transparent),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return (theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary)
                          .withOpacity(0.15);
                    }
                    if (states.contains(WidgetState.selected)) {
                      return (theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary)
                          .withOpacity(0.1);
                    }
                    return null;
                  },
                ),
                columns: [
                  DataColumn(
                    label: _buildSortableColumnHeader('Instrument', theme, 0),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Net Qty', theme, 1),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Avg Price', theme, 2),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('LTP', theme, 3),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Invested', theme, 4),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Current Value', theme, 5),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Day P&L', theme, 6),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Day %', theme, 7),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Overall P&L', theme, 8),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: _buildSortableColumnHeader('Overall %', theme, 9),
                    onSort: (columnIndex, ascending) =>
                        _onSortTable(columnIndex, ascending),
                  ),
                ],
                rows: filteredHoldings.map((holding) {
                  final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
                      ? holding.exchTsym![0]
                      : null;
                  final token = exchTsym?.token ?? '';
                  
                  return DataRow(
                    onSelectChanged: (bool? selected) {
                      _showHoldingDetail(holding);
                    },
                    cells: [
                      _buildInstrumentCellWithHover(holding, theme, token),
                      _buildCellWithHover(holding, theme, token, _buildNetQtyCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildAvgPriceCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildLTPCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildInvestedCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildCurrentValueCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildDayPnLCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildDayPercentCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildOverallPnLCell(holding, theme)),
                      _buildCellWithHover(holding, theme, token, _buildOverallPercentCell(holding, theme)),
                    ],
                  );
                }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataCell _buildInstrumentCellWithHover(dynamic holding, ThemesProvider theme, String token) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    if (exchTsym == null) return DataCell(
      Text(
        'N/A',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
        ),
      ),
    );

    final holdingToken = exchTsym.token ?? '';
    final isHovered = _hoveredRowToken == holdingToken;
    final displayText = '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}';

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = holdingToken),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Row(
            children: [
              // Text that takes at least 50% of width, leaves space for buttons
              Expanded(
                flex: isHovered ? 1 : 2, // When hovered, text takes less space but still visible
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
                      // Exit button for holdings with saleable quantity
                      if ((holding.saleableQty ?? 0) > 0) ...[
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
          ),
        ),
      ),
    );
  }

  DataCell _buildCellWithHover(dynamic holding, ThemesProvider theme, String token, DataCell cell) {
    // Wrap the cell's child with MouseRegion to detect hover anywhere on the row
    // Use SizedBox.expand to fill the entire cell area, not just the text content
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = token),
        onExit: (_) => setState(() => _hoveredRowToken = null),
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

    if (exchTsym == null) return DataCell(
      Text(
        'N/A',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
        ),
      ),
    );

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
        ),
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
        ),
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
        ),
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
        ),
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
        ),
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
        ),
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
        '${dayPercent}%',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(dayPercent, theme),
        ),
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
        ),
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
        '${overallPercent}%',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(overallPercent, theme),
        ),
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
    return '${totalChange.toStringAsFixed(2)}';
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
    return '${totalPnL.toStringAsFixed(2)}';
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

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      holdings = holdings.where((holding) {
        if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
          final exchTsym = holding.exchTsym![0];
          final symbol = exchTsym.tsym?.toLowerCase() ?? '';
          final exch = exchTsym.exch?.toLowerCase() ?? '';
          final searchLower = _searchQuery.toLowerCase();
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
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success; // Green
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error; // Red
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary; // Grey
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

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _sortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        // Reserve fixed space for sort indicator
        // Show custom icon when not sorted, DataTable will show its icon when sorted
        SizedBox(
          width: 20, // Fixed width to prevent layout shift
          height: 16,
          child: !isSorted 
              ? Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(), // Hide when sorted, DataTable will show its indicator
        ),
      ],
    );
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
            padding: isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
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

  Future<void> _handleChartTap(BuildContext context, dynamic holding, dynamic exchTsym) async {
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

  Future<void> _handlePlaceOrder(BuildContext context, dynamic holding, dynamic exchTsym, bool isBuy) async {
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
        showResponsiveWarningMessage(context, "Unable to fetch scrip information");
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
      showResponsiveWarningMessage(context, "Error placing order: ${e.toString()}");
    }
  }

  Future<void> _handleExitHolding(BuildContext context, dynamic holding, dynamic exchTsym) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      
      await scripData.fetchScripInfo(
        exchTsym.token ?? "",
        exchTsym.exch ?? "",
        context,
        true,
      );
      
      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(context, "Unable to fetch scrip information");
        return;
      }
      
      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: exchTsym.exch ?? "",
        tSym: exchTsym.tsym ?? "",
        isExit: true,
        token: exchTsym.token ?? "",
        transType: false,
        prd: holding.prd ?? "",
        lotSize: holding.saleableQty?.toString() ?? "1",
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
          "scripInfo": scripData.scripInfoModel!,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(context, "Error exiting holding: ${e.toString()}");
    }
  }

  Future<void> _handleAddHolding(BuildContext context, dynamic holding, dynamic exchTsym) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      
      await scripData.fetchScripInfo(
        exchTsym.token ?? "",
        exchTsym.exch ?? "",
        context,
        true,
      );
      
      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(context, "Unable to fetch scrip information");
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
      showResponsiveWarningMessage(context, "Error adding holding: ${e.toString()}");
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
