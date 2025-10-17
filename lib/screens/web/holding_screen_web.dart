import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class HoldingScreenWeb extends ConsumerStatefulWidget {
  final List<dynamic> listofHolding;
  const HoldingScreenWeb({super.key, required this.listofHolding});

  @override
  ConsumerState<HoldingScreenWeb> createState() => _HoldingScreenWebState();
}

class _HoldingScreenWebState extends ConsumerState<HoldingScreenWeb> {
  StreamSubscription? _socketSubscription;
  int _selectedTabIndex = 0; // 0 for Stocks, 1 for Mutual Funds
  final Set<int> _selectedHoldings = <int>{};
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
        _setupSocketSubscription();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
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
                _buildSummaryCards(theme, portfolioData),
                const SizedBox(height: 24),
                
                // Stock Position Summary
                _buildStockPositionSummary(theme, portfolioData),
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

  Widget _buildSummaryCards(ThemesProvider theme, PortfolioProvider portfolioData) {
    return Row(
          children: [
        Expanded(
          child: _buildSummaryCard(
            'Stocks Value',
            _calculateStocksValue(portfolioData),
            theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Day Change',
            _calculateDayChange(portfolioData),
            _getValueColor(_calculateDayChange(portfolioData), theme),
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Invested',
            _calculateInvested(portfolioData),
            theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Profit/Loss',
            _calculateProfitLoss(portfolioData),
            _getValueColor(_calculateProfitLoss(portfolioData), theme),
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color valueColor, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
        ),
          const SizedBox(height: 8),
        TextWidget.headText(
          text: value,
          theme: false,
          color: valueColor,
          fw: 2,
        ),
                            ],
                          ),
    );
  }

  Widget _buildStockPositionSummary(ThemesProvider theme, PortfolioProvider portfolioData) {
    final positiveCount = _getPositiveHoldingsCount(portfolioData);
    final negativeCount = _getNegativeHoldingsCount(portfolioData);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
            'Stock Position',
                              style: TextWidget.textStyle(
              fontSize: 16,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPositionChip('$positiveCount Positive', Colors.green, theme),
              const SizedBox(width: 12),
              _buildPositionChip('$negativeCount Negative', Colors.red, theme),
            ],
          ),
        ],
      ),
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

  Widget _buildMainContent(ThemesProvider theme, PortfolioProvider portfolioData) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          // Tabs
          _buildTabs(theme, portfolioData),
          
          // Action Bar
          _buildActionBar(theme, portfolioData),
          
          // Table
          _buildHoldingsTable(theme, portfolioData),
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
                ? (theme.isDarkMode ? colors.primaryDark : colors.primaryLight)
                : Colors.transparent,
            border: isSelected 
                ? Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                      width: 2,
                    ),
                  )
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextWidget.textStyle(
              fontSize: 14,
              color: isSelected 
                  ? Colors.white
                  : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
              theme: false,
              fw: isSelected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(ThemesProvider theme, PortfolioProvider portfolioData) {
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
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
                decoration: InputDecoration(
                  hintText: 'Search on holdings',
                  hintStyle: TextWidget.textStyle(
                    fontSize: 12,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                  ),
                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      assets.searchIcon,
                      colorFilter: ColorFilter.mode(
                        theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        BlendMode.srcIn,
                      ),
                                      width: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Filter Dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                items: ['All', 'CNC', 'MIS', 'NRML'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedFilter = newValue!);
                },
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
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                  ),
                                ),
                            ],
                          ),
    );
  }

  Widget _buildHoldingsTable(ThemesProvider theme, PortfolioProvider portfolioData) {
    final filteredHoldings = _getFilteredHoldings(portfolioData);
    
    if (filteredHoldings.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        ),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.1);
            }
            return null;
          },
        ),
        columns: [
          DataColumn(
            label: _buildSortableColumnHeader('Instrument', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Net Qty', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Avg Price', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('LTP', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Invested', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Current Value', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Day P&L', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Day %', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Overall P&L', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Overall %', theme),
          ),
        ],
        rows: filteredHoldings.asMap().entries.map((entry) {
          final index = entry.key;
          final holding = entry.value;
          
          return DataRow(
            selected: _selectedHoldings.contains(index),
            onSelectChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  _selectedHoldings.add(index);
                                    } else {
                  _selectedHoldings.remove(index);
                                    }
                                  });
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
    );
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
                                    style: TextWidget.textStyle(
            fontSize: 12,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              theme: theme.isDarkMode,
            fw: 2,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.unfold_more,
          size: 16,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
        ),
      ],
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
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
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
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${holding.currentQty ?? 0}',
                    style: TextWidget.textStyle(
                      fontSize: 10,
                      color: Colors.blue,
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
    final exchTsym = holding.exchTsym != null && holding.exchTsym!.isNotEmpty 
        ? holding.exchTsym![0] 
        : null;
    
    return DataCell(
      Text(
        exchTsym?.close ?? '0.00',
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
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
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
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
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
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
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
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
    return '${totalChange.toStringAsFixed(2)}(${_calculateDayChangePercent(portfolioData)}%)';
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
    return '${totalPnL.toStringAsFixed(2)}(${_calculateProfitLossPercent(portfolioData)}%)';
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
    return widget.listofHolding.where((holding) => 
        holding.sPrdtAli == 'CNC' || holding.sPrdtAli == 'MIS' || holding.sPrdtAli == 'NRML'
    ).length;
  }

  int _getMutualFundsCount(PortfolioProvider portfolioData) {
    return widget.listofHolding.where((holding) => 
        holding.sPrdtAli == 'MF'
    ).length;
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
        ? widget.listofHolding.where((holding) => 
            holding.sPrdtAli == 'CNC' || holding.sPrdtAli == 'MIS' || holding.sPrdtAli == 'NRML'
          ).toList()
        : widget.listofHolding.where((holding) => 
            holding.sPrdtAli == 'MF'
          ).toList();

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

    // Apply product filter
    if (_selectedFilter != 'All') {
      holdings = holdings.where((holding) {
        return holding.sPrdtAli == _selectedFilter;
      }).toList();
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
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  Color _getQtyColor(int qty, ThemesProvider theme) {
    if (qty > 0) {
      return Colors.green;
    } else if (qty < 0) {
      return Colors.red;
    } else {
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  bool _shouldShowLockIcon(dynamic holding) {
    // Show lock icon for specific holdings based on business logic
    // This can be customized based on your requirements
    return holding.currentQty != null && holding.currentQty! > 0;
  }
}