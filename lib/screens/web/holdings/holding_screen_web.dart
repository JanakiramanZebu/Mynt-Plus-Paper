import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/screens/web/holdings/holding_detail_screen_web.dart';
import 'package:mynt_plus/screens/web/holdings/mf_holdings_screen_web.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
  String? _hoveredRowToken; // Track which row is being hovered
  PlutoGridStateManager? _plutoStateManager;
  final Map<int, dynamic> _rowIndexToHolding = {}; // Map row index to holdings

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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
        children: [
          SizedBox(height: 8),
          // Main stats row
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
                            fontWeight: WebFonts.bold,
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
                            fontWeight: WebFonts.bold,
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 20),
              _buildPositionChip(
                  '$positiveCount Positive', theme.isDarkMode ? WebDarkColors.success : WebColors.success, theme),
              const SizedBox(width: 12),
              _buildPositionChip('$negativeCount Negative', theme.isDarkMode ? WebDarkColors.error : WebColors.error, theme),
            ],
          ),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
            children: [
              SizedBox(height: 8),
              // Main stats row
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 20),
                  _buildPositionChip(
                      '$positiveCount Positive', theme.isDarkMode ? WebDarkColors.success : WebColors.success, theme),
                  const SizedBox(width: 12),
                  _buildPositionChip(
                      '$negativeCount Negative', theme.isDarkMode ? WebDarkColors.error : WebColors.error, theme),
                ],
              ),
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
            fontWeight: WebFonts.bold,
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
                  style: WebTextStyles.custom(
                    fontSize: 13,
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                        fontWeight: WebFonts.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search holdings',
                    hintStyle: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                      fontWeight: WebFonts.bold,
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
                  style: WebTextStyles.custom(
                    fontSize: 13,
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                    fontWeight: WebFonts.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search mutual funds',
                    hintStyle: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                      fontWeight: WebFonts.bold,
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

    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode 
            ? WebDarkColors.inputBackground 
            : WebColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? WebDarkColors.inputBorder : WebColors.inputBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final isLast = index == tabs.length - 1;
          
          return _buildSegmentedTab(
            tabs[index],
            index,
            isSelected,
            isLast,
            theme,
          );
        }),
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
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: isSelected
                    ? WebDarkColors.textPrimary
                    : (theme.isDarkMode 
                        ? WebDarkColors.textSecondary 
                        : WebColors.textSecondary),
                fontWeight: isSelected ? WebFonts.semiBold : WebFonts.medium,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
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

    // Calculate table height based on screen size (60% of available height)
    final screenHeight = MediaQuery.of(context).size.height;
    final tableHeight = screenHeight * 0.6;

    // Create columns configuration
    final columns = [
      PlutoColumn(
        title: 'Instrument',
        field: 'instrument',
        type: PlutoColumnType.text(),
        width: 380,
        enableSorting: true,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          // Use cell value for display (this is sorted correctly)
          final cellValue = rendererContext.cell.value.toString();
          
          // Get the row to access all cell values for matching
          final row = rendererContext.row;
          
          // Find holding by matching multiple cell values to ensure correct match after sorting
          final holding = _rowIndexToHolding.values.firstWhere(
            (h) {
              final exchTsym = h.exchTsym != null && h.exchTsym!.isNotEmpty ? h.exchTsym![0] : null;
              if (exchTsym == null) return false;
              
              // Match instrument text
              final holdingText = '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}'.trim();
              final cellText = cellValue.trim();
              if (holdingText != cellText && !(holdingText.isEmpty && cellText == 'N/A')) {
                return false;
              }
              
              // Also match overall P&L to ensure unique match
              final holdingPnL = double.tryParse(exchTsym.profitNloss ?? '0.00') ?? 0.0;
              final rowPnLCell = row.cells['overallPnL']?.value;
              final rowPnL = rowPnLCell is num ? rowPnLCell : double.tryParse(rowPnLCell?.toString() ?? '0.00') ?? 0.0;
              
              return (holdingPnL - rowPnL).abs() < 0.01;
            },
            orElse: () => null,
          );
          
          if (holding == null) {
            // Fallback to default cell value if holding not found
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                cellValue,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
              ),
            );
          }
          
          final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
              ? holding.exchTsym![0]
              : null;
          
          if (exchTsym == null) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                cellValue,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
              ),
            );
          }
          
          final holdingToken = exchTsym.token ?? '';
          final isHovered = _hoveredRowToken == holdingToken;
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = holdingToken),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text that shows half when hovered - use cell value for display
                Flexible(
                  child: AnimatedOpacity(
                    opacity: isHovered ? 0.7 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    child: Tooltip(
                      message: cellValue,
                      child: Text(
                        cellValue,
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
                ),
                // Buttons that appear on hover
                AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((holding.currentQty ?? 0) > 0) ...[
                        const SizedBox(width: 6),
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
                      ],
                      if ((holding.saleableQty ?? 0) > 0) ...[
                        const SizedBox(width: 6),
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
                      ],
                      const SizedBox(width: 6),
                      _buildHoverButton(
                        icon: Icons.bar_chart,
                        color: theme.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
                        borderColor: theme.isDarkMode
                            ? WebDarkColors.inputBorder
                            : WebColors.inputBorder,
                        borderRadius: 5.0,
                        onPressed: () async {
                          await _handleChartTap(context, holding, exchTsym);
                        },
                        theme: theme,
                      ),
                      const SizedBox(width: 6),
                      _buildHoverButton(
                        label: 'Pledge',
                        color: theme.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
                        borderColor: theme.isDarkMode
                            ? WebDarkColors.inputBorder
                            : WebColors.inputBorder,
                        borderRadius: 5.0,
                        onPressed: () {
                          _handlePledgeUnpledge(context);
                        },
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Net Qty',
        field: 'netQty',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 120,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          if (holding == null) {
            // Fallback to default cell value if holding not found
            return Align(
              alignment: Alignment.centerRight,
              child: Text(
                rendererContext.cell.value.toString(),
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
              ),
            );
          }
          
          final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
              ? holding.exchTsym![0]
              : null;
          final token = exchTsym?.token ?? '';
          
          final qty = holding.currentQty ?? 0;
          // Get cell value (should be numeric for sorting)
          final cellValue = rendererContext.cell.value;
          final displayQty = cellValue is int ? cellValue : qty;
          final displayQtyText = displayQty > 0 ? '+$displayQty' : '$displayQty';
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getQtyColor(displayQty, theme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  displayQtyText,
                  style: WebTextStyles.custom(
                    fontSize: 13,
                    isDarkTheme: theme.isDarkMode,
                    color: _getQtyColor(displayQty, theme),
                    fontWeight: WebFonts.medium,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Avg Price',
        field: 'avgPrice',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 120,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          final token = holding?.exchTsym?[0]?.token ?? '';
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                rendererContext.cell.value.toString(),
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'LTP',
        field: 'ltp',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 120,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          final token = holding?.exchTsym?[0]?.token ?? '';
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                rendererContext.cell.value.toString(),
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Invested',
        field: 'invested',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 120,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          final token = holding?.exchTsym?[0]?.token ?? '';
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                rendererContext.cell.value.toString(),
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Current Value',
        field: 'currentValue',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 140,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          final token = holding?.exchTsym?[0]?.token ?? '';
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                rendererContext.cell.value.toString(),
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Day P&L',
        field: 'dayPnL',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 120,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          final exchTsym = holding?.exchTsym?[0];
          final dayPnL = exchTsym?.oneDayChg ?? '0.00';
          final token = exchTsym?.token ?? '';
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                dayPnL,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: _getValueColor(dayPnL, theme),
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Day %',
        field: 'dayPercent',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 100,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          final exchTsym = holding?.exchTsym?[0];
          final dayPercent = exchTsym?.perChange ?? '0.00';
          final token = exchTsym?.token ?? '';
          // Get cell value (should be numeric for sorting)
          final cellValue = rendererContext.cell.value;
          final percentValue = cellValue is num ? cellValue : double.tryParse(dayPercent) ?? 0.0;
          final percentString = percentValue.toStringAsFixed(2);
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${percentString}%',
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: _getValueColor(percentString, theme),
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Overall P&L',
        field: 'overallPnL',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 130,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          // Use cell value for display (this is sorted correctly)
          final cellValue = rendererContext.cell.value;
          final overallPnL = cellValue is num ? cellValue.toStringAsFixed(2) : cellValue.toString();
          
          // Get the row to access all cell values for matching
          final row = rendererContext.row;
          
          // Find holding by matching multiple cell values to ensure correct match after sorting
          final holding = _rowIndexToHolding.values.firstWhere(
            (h) {
              final exchTsym = h.exchTsym != null && h.exchTsym!.isNotEmpty ? h.exchTsym![0] : null;
              if (exchTsym == null) return false;
              
              // Match overall P&L value
              final holdingPnL = double.tryParse(exchTsym.profitNloss ?? '0.00') ?? 0.0;
              final cellPnL = cellValue is num ? cellValue : double.tryParse(overallPnL) ?? 0.0;
              if ((holdingPnL - cellPnL).abs() >= 0.01) return false;
              
              // Also match instrument to ensure unique match
              final holdingText = '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}'.trim();
              final rowInstrumentCell = row.cells['instrument']?.value?.toString() ?? '';
              
              return holdingText == rowInstrumentCell.trim() || (holdingText.isEmpty && rowInstrumentCell == 'N/A');
            },
            orElse: () => null,
          );
          
          final exchTsym = holding?.exchTsym?[0];
          final token = exchTsym?.token ?? '';
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                overallPnL,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: _getValueColor(overallPnL, theme),
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Overall %',
        field: 'overallPercent',
        type: PlutoColumnType.number(), // Use number type for proper numeric sorting
        width: 110,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        enableContextMenu: false,
        enableColumnDrag: false,
        enableRowDrag: false,
        renderer: (rendererContext) {
          final rowIndex = rendererContext.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          final exchTsym = holding?.exchTsym?[0];
          final overallPercent = exchTsym?.pNlChng ?? '0.00';
          final token = exchTsym?.token ?? '';
          // Get cell value (should be numeric for sorting)
          final cellValue = rendererContext.cell.value;
          final percentValue = cellValue is num ? cellValue : double.tryParse(overallPercent) ?? 0.0;
          final percentString = percentValue.toStringAsFixed(2);
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowToken = token),
            onExit: (_) => setState(() => _hoveredRowToken = null),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${percentString}%',
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: _getValueColor(percentString, theme),
                  fontWeight: WebFonts.medium,
                ),
              ),
            ),
          );
        },
      ),
    ];

    // Clear previous row mappings
    _rowIndexToHolding.clear();
    
    // Create rows data - store holdings by row reference for lookup
    final rows = filteredHoldings.asMap().entries.map((entry) {
      final index = entry.key;
      final holding = entry.value;
      final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
          ? holding.exchTsym![0]
          : null;
      
      final qty = holding.currentQty ?? 0;
      
      final row = PlutoRow(
        cells: {
          'instrument': PlutoCell(value: '${exchTsym?.tsym ?? ''} ${exchTsym?.exch ?? ''}'.trim().isEmpty ? 'N/A' : '${exchTsym?.tsym ?? ''} ${exchTsym?.exch ?? ''}'),
          'netQty': PlutoCell(value: qty), // Store numeric value for proper sorting
          'avgPrice': PlutoCell(value: double.tryParse(holding.avgPrc ?? '0.00') ?? 0.0),
          'ltp': PlutoCell(value: double.tryParse(exchTsym?.lp ?? '0.00') ?? 0.0),
          'invested': PlutoCell(value: double.tryParse(holding.invested ?? '0.00') ?? 0.0),
          'currentValue': PlutoCell(value: double.tryParse(holding.currentValue ?? '0.00') ?? 0.0),
          'dayPnL': PlutoCell(value: double.tryParse(exchTsym?.oneDayChg ?? '0.00') ?? 0.0),
          'dayPercent': PlutoCell(value: double.tryParse(exchTsym?.perChange ?? '0.00') ?? 0.0), // Store numeric value, format in renderer
          'overallPnL': PlutoCell(value: double.tryParse(exchTsym?.profitNloss ?? '0.00') ?? 0.0),
          'overallPercent': PlutoCell(value: double.tryParse(exchTsym?.pNlChng ?? '0.00') ?? 0.0), // Store numeric value, format in renderer
        },
      );
      
      // Store holding reference by index (will be re-mapped after sorting if needed)
      _rowIndexToHolding[index] = holding;
      
      return row;
    }).toList();

    return SizedBox(
      height: tableHeight,
      child: PlutoGrid(
        columns: columns,
        rows: rows,
          configuration: PlutoGridConfiguration(
          columnSize: const PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.none,
            resizeMode: PlutoResizeMode.normal,
          ),
          scrollbar: const PlutoGridScrollbarConfig(
            isAlwaysShown: true,
          ),
          style: PlutoGridStyleConfig(
            activatedColor: Colors.transparent,
            activatedBorderColor: Colors.transparent,
            gridBorderColor: Colors.transparent,
            rowColor: Colors.transparent,
            evenRowColor: Colors.transparent,
            oddRowColor: Colors.transparent,
            checkedColor: Colors.transparent,
            columnTextStyle: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: WebFonts.bold,
            ),
            cellTextStyle: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: WebFonts.medium,
            ),
            defaultCellPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            rowHeight: 44,
            columnHeight: 44,
            iconColor: theme.isDarkMode
                ? WebDarkColors.iconSecondary
                : WebColors.iconSecondary,
            enableCellBorderVertical: false,
            enableCellBorderHorizontal: true,
            enableColumnBorderVertical: false, // Removes header vertical lines
            enableColumnBorderHorizontal: true, // Keeps header bottom line
            borderColor: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
        ),
        onLoaded: (PlutoGridOnLoadedEvent event) {
          _plutoStateManager = event.stateManager;
          // Auto-expand columns based on content (except Instrument which is fixed)
          _updateColumnWidths(event.stateManager, rows);
        },
        onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
          // Show holding detail when row is double-tapped
          final rowIndex = event.rowIdx;
          final holding = _rowIndexToHolding[rowIndex];
          if (holding != null) {
            _showHoldingDetail(holding);
          }
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          // Handle cell changes if needed
        },
      ),
    );
  }

  void _updateColumnWidths(PlutoGridStateManager stateManager, List<PlutoRow> rows) {
    if (rows.isEmpty) return;
    
    // Text style for measurement
    final textStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Column fields (excluding 'instrument' which is fixed)
    final columnFields = ['netQty', 'avgPrice', 'ltp', 'invested', 'currentValue', 
                          'dayPnL', 'dayPercent', 'overallPnL', 'overallPercent'];
    
    // Calculate max width for each column
    final Map<String, double> maxWidths = {};
    
    for (final field in columnFields) {
      double maxWidth = 0;
      
      // Measure header text
      textPainter.text = TextSpan(text: _getColumnTitle(field), style: textStyle);
      textPainter.layout();
      maxWidth = textPainter.width;
      
      // Measure all cell values
      for (final row in rows) {
        final cell = row.cells[field];
        if (cell != null) {
          final cellValue = cell.value.toString();
          textPainter.text = TextSpan(text: cellValue, style: textStyle);
          textPainter.layout();
          final cellWidth = textPainter.width;
          if (cellWidth > maxWidth) {
            maxWidth = cellWidth;
          }
        }
      }
      
      // Add padding (horizontal padding * 2 + some extra space)
      maxWidths[field] = maxWidth + 40; // 20px padding on each side + buffer
    }
    
    // Update column widths (skip Instrument column which is fixed)
    Future.microtask(() {
      for (final column in stateManager.columns) {
        if (column.field != 'instrument' && maxWidths.containsKey(column.field)) {
          final newWidth = maxWidths[column.field]!;
          final minWidth = _getColumnMinWidth(column.field);
          if (newWidth > minWidth) {
            stateManager.resizeColumn(column, newWidth);
          }
        }
      }
    });
  }
  
  String _getColumnTitle(String field) {
    switch (field) {
      case 'netQty': return 'Net Qty';
      case 'avgPrice': return 'Avg Price';
      case 'ltp': return 'LTP';
      case 'invested': return 'Invested';
      case 'currentValue': return 'Current Value';
      case 'dayPnL': return 'Day P&L';
      case 'dayPercent': return 'Day %';
      case 'overallPnL': return 'Overall P&L';
      case 'overallPercent': return 'Overall %';
      default: return field;
    }
  }
  
  double _getColumnMinWidth(String field) {
    switch (field) {
      case 'netQty': return 120;
      case 'avgPrice': return 120;
      case 'ltp': return 120;
      case 'invested': return 120;
      case 'currentValue': return 140;
      case 'dayPnL': return 120;
      case 'dayPercent': return 100;
      case 'overallPnL': return 130;
      case 'overallPercent': return 110;
      default: return 100;
    }
  }

  DataCell _buildInstrumentCellWithHover(dynamic holding, ThemesProvider theme, String token) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    if (exchTsym == null) return DataCell(
      Text(
        'N/A',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );

    final holdingToken = exchTsym.token ?? '';
    final isHovered = _hoveredRowToken == holdingToken;

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = holdingToken),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text that shows half when hovered
                Flexible(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    constraints: BoxConstraints(
                      maxWidth: isHovered ? 120 : double.infinity,
                    ),
                    child: Tooltip(
                      message: '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}',
                      child: AnimatedOpacity(
                        opacity: isHovered ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: Text(
                          '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}',
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
                  ),
                ),
                // Buttons that appear on hover
                AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        if ((holding.currentQty ?? 0) > 0) ...[
                          const SizedBox(width: 6),
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
                        ],
                       
                        // Exit and Add buttons for holdings with quantity
                        if ((holding.saleableQty ?? 0) > 0) ...[
                          const SizedBox(width: 6),
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
                        ],
                       
                        // Pledge/Unpledge button
                        const SizedBox(width: 6),
                         _buildHoverButton(
                          icon: Icons.bar_chart,
                          color: theme.isDarkMode
                              ? WebDarkColors.textSecondary
                              : WebColors.textSecondary,
                          borderColor: theme.isDarkMode
                              ? WebDarkColors.inputBorder
                              : WebColors.inputBorder,
                          borderRadius: 5.0,
                          onPressed: () async {
                            await _handleChartTap(context, holding, exchTsym);
                          },
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                        _buildHoverButton(
                          label: 'Pledge',
                          color: theme.isDarkMode
                              ? WebDarkColors.textSecondary
                              : WebColors.textSecondary,
                          borderColor: theme.isDarkMode
                              ? WebDarkColors.inputBorder
                              : WebColors.inputBorder,
                          borderRadius: 5.0,
                          onPressed: () {
                            _handlePledgeUnpledge(context);
                          },
                          theme: theme,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );

    return DataCell(
      Text(
        '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}',
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
    );
  }

  DataCell _buildNetQtyCell(dynamic holding, ThemesProvider theme) {
    final qty = holding.currentQty ?? 0;
    final qtyText = qty > 0 ? '+$qty' : '$qty';

    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getQtyColor(qty, theme).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          qtyText,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getQtyColor(qty, theme),
            fontWeight: WebFonts.medium,
          ),
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildInvestedCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.invested ?? '0.00',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildCurrentValueCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.currentValue ?? '0.00',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(dayPnL, theme),
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(dayPercent, theme),
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(overallPnL, theme),
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(overallPercent, theme),
          fontWeight: WebFonts.medium,
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
      if (_sortColumnIndex == columnIndex) {
        // Toggle ascending/descending if clicking the same column
        _sortAscending = !_sortAscending;
      } else {
        // Set new column and default to ascending
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      }
    });
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _sortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.bold,
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
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final isLongLabel = label != null && label.length > 1;
    final borderRadiusValue = borderRadius ?? 5.0;
    return SizedBox(
      width: isLongLabel ? null : 28,
      height: 28,
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
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      size: 16,
                      color: color,
                    )
                  : Text(
                      label ?? "",
                      style: WebTextStyles.custom(
                        fontSize: 11,
                        isDarkTheme: theme.isDarkMode,
                        color: color,
                        fontWeight: FontWeight.w600,
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
