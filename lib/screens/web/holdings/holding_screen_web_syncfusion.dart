import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/screens/web/holdings/mf_holdings_screen_web.dart';

import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/no_data_found.dart';

class HoldingScreenWebSyncfusion extends ConsumerWidget {
  final List<dynamic> listofHolding;
  const HoldingScreenWebSyncfusion({super.key, required this.listofHolding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<String> _mfSearchQuery = ValueNotifier<String>('');
  final ScrollController _tabScrollController = ScrollController();

  late HoldingsDataSource _holdingsDataSource;
  final DataGridController _dataGridController = DataGridController();

  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _holdingsDataSource = HoldingsDataSource(
      holdings: widget.listofHolding,
      theme: ref.read(themeProvider),
      context: context,
      ref: ref,
    );

    // 🔥 CRITICAL: Setup socket subscription for real-time updates
    // This is the KEY to performance - only affected cells rebuild!
    _setupSocketSubscription();
  }

  void _setupSocketSubscription() {
    final socketProvider = ref.read(websocketProvider);

    // Listen to socket data stream
    _socketSubscription = socketProvider.socketDataStream.listen((Map socketData) {
      if (!mounted) return;

      // Iterate through socket data to find matching holdings
      socketData.forEach((token, data) {
        // Find the row index for this token
        final holdings = _holdingsDataSource.holdings;
        for (int i = 0; i < holdings.length; i++) {
          final holding = holdings[i];
          final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
              ? holding.exchTsym![0]
              : null;

          if (exchTsym?.token == token) {
            // Update the holding data with new socket values
            final newLtp = data['lp']?.toString();
            final newChng = data['chng']?.toString();
            final newPc = data['pc']?.toString();

            bool hasChanged = false;

            if (newLtp != null && newLtp != '0.00' && newLtp != 'null' && newLtp != exchTsym.lp) {
              exchTsym.lp = newLtp;
              hasChanged = true;
            }

            if (newChng != null && newChng != 'null') {
              // Update one day change if available
              hasChanged = true;
            }

            if (newPc != null && newPc != 'null' && newPc != exchTsym.pc) {
              exchTsym.pc = newPc;
              hasChanged = true;
            }

            // 🔥 THIS IS THE MAGIC! 🔥
            // Notify ONLY this specific row to update
            // This means ONLY the cells in this row rebuild, NOT the entire table!
            if (hasChanged) {
              _holdingsDataSource.updateDataSource(
                rowColumnIndex: RowColumnIndex(i, -1), // -1 means update entire row
              );
            }
            break;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _searchQuery.dispose();
    _mfSearchQuery.dispose();
    _dataGridController.dispose();
    _socketSubscription?.cancel();
    super.dispose();
  }

  List<dynamic> _getFilteredHoldings() {
    final searchTerm = _searchQuery.value.toLowerCase();
    if (searchTerm.isEmpty) {
      return widget.listofHolding;
    }

    return widget.listofHolding.where((holding) {
      final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
          ? holding.exchTsym![0]
          : null;
      final tsym = exchTsym?.tsym?.toLowerCase() ?? '';
      final exch = exchTsym?.exch?.toLowerCase() ?? '';
      return tsym.contains(searchTerm) || exch.contains(searchTerm);
    }).toList();
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
        color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
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

                  // Main Content Area
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
      return _buildStocksSummaryCards(theme, portfolioData);
    } else {
      return _buildMutualFundsSummaryCards(theme);
    }
  }

  Widget _buildStocksSummaryCards(
      ThemesProvider theme, PortfolioProvider portfolioData) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? WebDarkColors.backgroundSecondary
            : WebColors.backgroundSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Profit/Loss',
              _calculateProfitLoss(portfolioData),
              _getValueColor(_calculateProfitLoss(portfolioData), theme),
              theme,
            ),
          ),
          _buildDivider(theme),
          Expanded(
            child: _buildStatItem(
              'Stocks Value',
              _calculateStocksValue(portfolioData),
              _getStatValueColor(_calculateStocksValue(portfolioData), theme),
              theme,
            ),
          ),
          _buildDivider(theme),
          Expanded(
            child: _buildStatItem(
              'Day Change',
              _calculateDayChange(portfolioData),
              _getValueColor(_calculateDayChange(portfolioData), theme),
              theme,
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
        final absReturnPercent = _formatValue(summary?.absReturnPercent?.toString());

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? WebDarkColors.backgroundSecondary
                : WebColors.backgroundSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
              width: 1,
            ),
          ),
          child: Row(
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
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor, ThemesProvider theme) {
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

  Widget _buildMainContent(ThemesProvider theme, PortfolioProvider portfolioData) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabsAndActionBar(theme, portfolioData),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildHoldingsTable(theme, portfolioData)
                : ValueListenableBuilder<String>(
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

  Widget _buildTabsAndActionBar(ThemesProvider theme, PortfolioProvider portfolioData) {
    final stocksCount = _getStocksCount();
    final mutualFundsCount = _getMutualFundsCount();

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
          _buildSegmentedControl(theme, portfolioData, stocksCount, mutualFundsCount),
          const Spacer(),
          if (_selectedTabIndex == 0) ...[
            _buildSearchField(theme, _searchQuery, 'Search holdings'),
            const SizedBox(width: 16),
          ] else if (_selectedTabIndex == 1) ...[
            _buildSearchField(theme, _mfSearchQuery, 'Search mutual funds'),
            const SizedBox(width: 16),
          ],
          _buildRefreshButton(theme, portfolioData),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemesProvider theme, ValueNotifier<String> query, String hint) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
              onChanged: (value) => query.value = value,
              style: WebTextStyles.formInput(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textSecondary,
              ),
              decoration: InputDecoration(
                hintText: hint,
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
                    colorFilter: ColorFilter.mode(
                      theme.isDarkMode
                          ? WebDarkColors.iconSecondary
                          : WebColors.iconSecondary,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.scaleDown,
                    width: 18,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefreshButton(ThemesProvider theme, PortfolioProvider portfolioData) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
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
    );
  }

  Widget _buildSegmentedControl(
      ThemesProvider theme, PortfolioProvider portfolioData, int stocksCount, int mutualFundsCount) {
    final tabs = [
      'Stocks ($stocksCount)',
      'Mutual Funds ($mutualFundsCount)',
    ];

    return SingleChildScrollView(
      controller: _tabScrollController,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < tabs.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildSegmentedTab(tabs[index], index, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab(String title, int index, ThemesProvider theme) {
    final isSelected = _selectedTabIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                  : (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary),
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
                  ? (theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary)
                  : (theme.isDarkMode ? WebDarkColors.navItem : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoldingsTable(ThemesProvider theme, PortfolioProvider portfolioData) {
    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, searchQuery, child) {
        final filteredHoldings = _getFilteredHoldings();

        if (filteredHoldings.isEmpty) {
          return const SizedBox(
            height: 400,
            child: Center(child: NoDataFound()),
          );
        }

        // Update data source with filtered holdings
        _holdingsDataSource = HoldingsDataSource(
          holdings: filteredHoldings,
          theme: theme,
          context: context,
          ref: ref,
        );

        return _buildSyncfusionDataGrid(theme, filteredHoldings);
      },
    );
  }

  Widget _buildSyncfusionDataGrid(ThemesProvider theme, List<dynamic> holdings) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive column configurations
    final responsiveConfig = _getResponsiveHoldingColumns(screenWidth);
    final headers = List<String>.from(responsiveConfig['headers'] as List);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
      ),
      child: SfDataGrid(
        source: _holdingsDataSource,
        controller: _dataGridController,

        // 🔥 CRITICAL: Fixed first column stays visible during horizontal scroll
        frozenColumnsCount: 1,

        // Column configuration
        columns: _buildGridColumns(headers, theme, screenWidth),

        // Row configuration
        rowHeight: 50,
        headerRowHeight: 56,

        // Styling - only horizontal lines (like your original)
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,

        // Selection
        selectionMode: SelectionMode.single,
        navigationMode: GridNavigationMode.cell,

        // 🔥 CRITICAL: Sorting enabled
        allowSorting: true,
        sortingGestureType: SortingGestureType.tap,

        // Performance settings
        columnWidthMode: ColumnWidthMode.fill,

        // Scrolling
        verticalScrollPhysics: const AlwaysScrollableScrollPhysics(),
        horizontalScrollPhysics: const AlwaysScrollableScrollPhysics(),

        // Row height callback
        onQueryRowHeight: (details) => 50,
      ),
    );
  }

  List<GridColumn> _buildGridColumns(List<String> headers, ThemesProvider theme, double screenWidth) {
    return headers.map((header) {
      final isNumeric = header != 'Instrument';

      return GridColumn(
        columnName: header,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? WebDarkColors.primary
                : WebColors.primary.withValues(alpha: 0.05),
          ),
          child: Text(
            header,
            style: WebTextStyles.tableHeader(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textSecondary,
            ),
            textAlign: isNumeric ? TextAlign.right : TextAlign.left,
          ),
        ),
        width: _getColumnWidth(header, screenWidth),
        allowSorting: true,
      );
    }).toList();
  }

  double _getColumnWidth(String header, double screenWidth) {
    if (header == 'Instrument') {
      if (screenWidth >= 1440) return 300;
      if (screenWidth >= 1024) return 280;
      if (screenWidth >= 768) return 250;
      return 200;
    }
    return double.nan; // Auto-size for other columns
  }

  Map<String, dynamic> _getResponsiveHoldingColumns(double screenWidth) {
    if (screenWidth < 768) {
      return {
        'headers': ['Instrument', 'Net Qty', 'LTP', 'Day P&L', 'Overall P&L'],
      };
    } else if (screenWidth < 1024) {
      return {
        'headers': ['Instrument', 'Net Qty', 'Avg Price', 'LTP', 'Current Value', 'Day P&L', 'Overall P&L'],
      };
    } else if (screenWidth < 1440) {
      return {
        'headers': ['Instrument', 'Net Qty', 'Avg Price', 'LTP', 'Invested', 'Current Value', 'Day P&L', 'Overall P&L', 'Overall %'],
      };
    } else {
      return {
        'headers': ['Instrument', 'Net Qty', 'Avg Price', 'LTP', 'Invested', 'Current Value', 'Day P&L', 'Day %', 'Overall P&L', 'Overall %'],
      };
    }
  }

  // Helper methods for summary cards
  String _calculateProfitLoss(PortfolioProvider portfolioData) {
    return portfolioData.totalPnlHolding.toStringAsFixed(2);
  }

  String _calculateStocksValue(PortfolioProvider portfolioData) {
    return portfolioData.totalCurrentVal.toStringAsFixed(2);
  }

  String _calculateDayChange(PortfolioProvider portfolioData) {
    return portfolioData.oneDayChng.toStringAsFixed(2);
  }

  String _calculateInvested(PortfolioProvider portfolioData) {
    return portfolioData.totInvesHold;
  }

  String _formatValue(dynamic value) {
    if (value == null) return '0.00';
    return value.toString();
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    }
    return theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary;
  }

  Color _getStatValueColor(String value, ThemesProvider theme) {
    return theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary;
  }

  int _getStocksCount() {
    return widget.listofHolding.length;
  }

  int _getMutualFundsCount() {
    final mfData = ref.read(mfProvider);
    return mfData.mfholdingnew?.data?.length ?? 0;
  }
}

// =====================================================
// SYNCFUSION DATA SOURCE - THE KEY TO PERFORMANCE!
// =====================================================
class HoldingsDataSource extends DataGridSource {
  List<dynamic> holdings;
  final ThemesProvider theme;
  final BuildContext context;
  final WidgetRef ref;

  HoldingsDataSource({
    required this.holdings,
    required this.theme,
    required this.context,
    required this.ref,
  });

  @override
  List<DataGridRow> get rows => holdings.map<DataGridRow>((holding) {
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
        ? holding.exchTsym![0]
        : null;

    return DataGridRow(cells: [
      DataGridCell<dynamic>(columnName: 'Instrument', value: holding),
      DataGridCell<String>(columnName: 'Net Qty', value: holding.currentQty?.toString() ?? '0'),
      DataGridCell<String>(columnName: 'Avg Price', value: holding.avgPrc ?? '0.00'),
      DataGridCell<String>(columnName: 'LTP', value: exchTsym?.lp ?? '0.00'),
      DataGridCell<String>(columnName: 'Invested', value: holding.invested ?? '0.00'),
      DataGridCell<String>(columnName: 'Current Value', value: holding.currentValue ?? '0.00'),
      DataGridCell<String>(columnName: 'Day P&L', value: exchTsym?.oneDayChg ?? '0.00'),
      DataGridCell<String>(columnName: 'Day %', value: exchTsym?.perChange ?? '0.00'),
      DataGridCell<String>(columnName: 'Overall P&L', value: exchTsym?.profitNloss ?? '0.00'),
      DataGridCell<String>(columnName: 'Overall %', value: exchTsym?.pNlChng ?? '0.00'),
    ]);
  }).toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        final columnName = cell.columnName;
        final isNumeric = columnName != 'Instrument';
        final alignment = isNumeric ? Alignment.centerRight : Alignment.centerLeft;

        // Special handling for Instrument column
        if (columnName == 'Instrument') {
          final holding = cell.value;
          final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty
              ? holding.exchTsym![0]
              : null;

          return Container(
            alignment: alignment,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${exchTsym?.tsym ?? ''} ${exchTsym?.exch ?? ''}',
              style: WebTextStyles.custom(
                fontSize: 13,
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary,
                fontWeight: WebFonts.medium,
              ),
            ),
          );
        }

        // Numeric columns with color coding
        final value = cell.value.toString();
        Color textColor;

        if (columnName == 'Day P&L' || columnName == 'Day %' ||
            columnName == 'Overall P&L' || columnName == 'Overall %') {
          final numValue = double.tryParse(value) ?? 0.0;
          if (numValue > 0) {
            textColor = theme.isDarkMode ? WebDarkColors.success : WebColors.success;
          } else if (numValue < 0) {
            textColor = theme.isDarkMode ? WebDarkColors.error : WebColors.error;
          } else {
            textColor = theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary;
          }
        } else if (columnName == 'Net Qty') {
          final qty = int.tryParse(value) ?? 0;
          if (qty > 0) {
            textColor = theme.isDarkMode ? WebDarkColors.success : WebColors.success;
          } else if (qty < 0) {
            textColor = theme.isDarkMode ? WebDarkColors.error : WebColors.error;
          } else {
            textColor = theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary;
          }
        } else {
          textColor = theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary;
        }

        return Container(
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            columnName == 'Day %' || columnName == 'Overall %' ? '$value%' : value,
            style: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: textColor,
              fontWeight: WebFonts.medium,
            ),
            textAlign: isNumeric ? TextAlign.right : TextAlign.left,
          ),
        );
      }).toList(),
    );
  }

  // 🔥 THIS IS THE KEY METHOD FOR PERFORMANCE!
  // Call this to update ONLY specific cells without rebuilding entire table
  void updateDataSource({RowColumnIndex? rowColumnIndex}) {
    if (rowColumnIndex != null) {
      // Update only specific row/cell - THIS IS THE MAGIC!
      // Only the affected cells rebuild, not the entire table!
      notifyDataSourceListeners(rowColumnIndex: rowColumnIndex);
    } else {
      // Update entire data source (use sparingly)
      notifyListeners();
    }
  }
}
