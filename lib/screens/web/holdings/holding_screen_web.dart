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
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/no_data_found.dart';

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
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _setupSocketSubscription();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    
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

    return GestureDetector(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.kColorLightGreyDarkTheme
            : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main stats row
          Row(
            children: [
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
                        TextWidget.subText(
                          text: 'Day Change',
                          theme: false,
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, // Dark grey
                          fw: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextWidget.headText(
                              text: _calculateDayChange(portfolioData),
                              theme: false,
                              color: _getValueColor(
                                  _calculateDayChange(portfolioData), theme),
                              fw: 2,
                            ),
                            TextWidget.headText(
                              text:
                                  ' (${_calculateDayChangePercent(portfolioData)}%)',
                              theme: false,
                              color: _getValueColor(
                                  _calculateDayChangePercent(portfolioData),
                                  theme),
                              fw: 2,
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
              _buildDivider(theme),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextWidget.subText(
                          text: 'Profit/Loss',
                          theme: false,
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, // Dark grey
                          fw: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextWidget.headText(
                              text: _calculateProfitLoss(portfolioData),
                              theme: false,
                              color: _getValueColor(
                                  _calculateProfitLoss(portfolioData), theme),
                              fw: 2,
                            ),
                            TextWidget.headText(
                              text:
                                  ' (${_calculateProfitLossPercent(portfolioData)}%)',
                              theme: false,
                              color: _getValueColor(
                                  _calculateProfitLossPercent(portfolioData),
                                  theme),
                              fw: 2,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPositionChip(
                  '$positiveCount Positive', theme.isDarkMode ? colors.profitDark : colors.profitLight, theme),
              const SizedBox(width: 12),
              _buildPositionChip('$negativeCount Negative', theme.isDarkMode ? colors.lossDark : colors.lossLight, theme),
              const SizedBox(width: 35),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? colors.kColorLightGreyDarkTheme
                : colors.kColorLightGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
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
                  _buildPositionChip(
                      '$positiveCount Positive', theme.isDarkMode ? colors.profitDark : colors.profitLight, theme),
                  const SizedBox(width: 12),
                  _buildPositionChip(
                      '$negativeCount Negative', theme.isDarkMode ? colors.lossDark : colors.lossLight, theme),
                  const SizedBox(width: 35),
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
        TextWidget.subText(
          text: label,
          theme: false,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, // Dark grey
          fw: 2,
        ),
        const SizedBox(height: 8),
        TextWidget.headText(
          text: value,
          theme: false,
          color: valueColor,
          fw: 2,
        ),
      ],
    );
  }

  Widget _buildDivider(ThemesProvider theme) {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFE5E7EB), // Light grey divider
    );
  }

  Widget _buildPositionChip(String text, Color color, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: color,
          theme: false,
          fw: 2,
        ),
      ),
    );
  }

  Widget _buildMainContent(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.kColorLightGreyDarkTheme
            : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          // Tabs
          _buildTabs(theme, portfolioData),

          // Content based on selected tab
          if (_selectedTabIndex == 0) ...[
            // Action Bar for Stocks
            _buildActionBar(theme, portfolioData),
            // Table for Stocks
            _buildHoldingsTable(theme, portfolioData),
          ] else if (_selectedTabIndex == 1) ...[
            // Mutual Funds Tab - Show MF Holdings Screen
            const MfHoldingsScreenWeb(showSummaryCards: false),
          ],
        ],
      ),
    );
  }

  Widget _buildTabs(ThemesProvider theme, PortfolioProvider portfolioData) {
    final stocksCount = _getStocksCount(portfolioData);
    final mutualFundsCount = _getMutualFundsCount(portfolioData);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTab('Stocks ($stocksCount)', 0, theme),
          _buildTab('Mutual Funds ($mutualFundsCount)', 1, theme),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, ThemesProvider theme) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: isSelected 
                ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                : Colors.transparent,
            border: isSelected
                ? Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                      width: 2,
                    ),
                  )
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: isSelected 
                  ? WebDarkColors.textPrimary
                  : (theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary),
              fontWeight: isSelected ? WebFonts.semiBold : WebFonts.medium,
              letterSpacing: 0.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextWidget.textStyle(
                  fontSize: 14,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
                decoration: InputDecoration(
                  hintText: 'Search on holdings',
                  hintStyle: TextWidget.textStyle(
                    fontSize: 12,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      assets.searchIcon,
                      fit: BoxFit.scaleDown,
                      colorFilter: ColorFilter.mode(
                        theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        BlendMode.srcIn,
                      ),
                      width: 20,
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

          // Refresh Button
          IconButton(
            onPressed: () async {
              await portfolioData.fetchHoldings(context, "Refresh");
            },
            icon: Icon(
              Icons.refresh,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
            ),
          ),
        ],
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: DataTable(
          showCheckboxColumn: false,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor: WidgetStateProperty.all(
            theme.isDarkMode
                ? colors.kColorLightGreyDarkTheme
                : colors.kColorLightGrey,
          ),
          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return (theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight)
                    .withOpacity(0.1);
              }
              return null;
            },
          ),
          columns: [
            DataColumn(
              label: _buildSortableColumnHeader('Instrument', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Net Qty', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Avg Price', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('LTP', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Invested', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Current Value', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Day P&L', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Day %', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Overall P&L', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Overall %', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
          ],
          rows: filteredHoldings.map((holding) {
            return DataRow(
              onSelectChanged: (bool? selected) {
                _showHoldingDetail(holding);
              },
              cells: [
                _buildInstrumentCell(holding, theme),
                _buildNetQtyCell(holding, theme),
                _buildAvgPriceCell(holding, theme),
                _buildLTPCell(holding, theme),
                _buildInvestedCell(holding, theme),
                _buildCurrentValueCell(holding, theme),
                _buildDayPnLCell(holding, theme),
                _buildDayPercentCell(holding, theme),
                _buildOverallPnLCell(holding, theme),
                _buildOverallPercentCell(holding, theme),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataCell _buildInstrumentCell(dynamic holding, ThemesProvider theme) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    if (exchTsym == null) return const DataCell(Text('N/A'));

    return DataCell(
      Row(
        children: [
          Text(
            '${exchTsym.tsym ?? ''} ${exchTsym.exch ?? ''}',
            style: TextWidget.textStyle(
              fontSize: 12,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 2,
            ),
          ),
          if (_shouldShowLockIcon(holding)) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 12,
                    color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${holding.brkcolqty ?? 0}',
                    style: TextWidget.textStyle(
                      fontSize: 10,
                      color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                      theme: false,
                      fw: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
          style: TextWidget.textStyle(
            fontSize: 12,
            color: _getQtyColor(qty, theme),
            theme: false,
            fw: 2,
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildInvestedCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.invested ?? '0.00',
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildCurrentValueCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.currentValue ?? '0.00',
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: _getValueColor(dayPnL, theme),
          theme: false,
          fw: 2,
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: _getValueColor(dayPercent, theme),
          theme: false,
          fw: 2,
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: _getValueColor(overallPnL, theme),
          theme: false,
          fw: 2,
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: _getValueColor(overallPercent, theme),
          theme: false,
          fw: 2,
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
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (numValue < 0) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
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
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (qty < 0) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
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

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextWidget.textStyle(
            fontSize: 12,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 2,
          ),
        ),
      ],
    );
  }

  Color _getStatValueColor(String value, ThemesProvider theme) {
    // Extract numeric value from string (remove any text like percentages)
    final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
    final numValue = double.tryParse(cleanValue) ?? 0.0;

    if (numValue > 0) {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (numValue < 0) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      return theme.isDarkMode
          ? colors.textPrimaryDark
          : colors.textPrimaryLight;
    }
  }
}
