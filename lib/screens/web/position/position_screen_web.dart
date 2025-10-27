import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../models/portfolio_model/position_book_model.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/no_data_found.dart';

class PositionScreenWeb extends ConsumerStatefulWidget {
  final List<PositionBookModel> listofPosition;
  const PositionScreenWeb({super.key, required this.listofPosition});

  @override
  ConsumerState<PositionScreenWeb> createState() => _PositionScreenWebState();
}

class _PositionScreenWebState extends ConsumerState<PositionScreenWeb> {
  StreamSubscription? _socketSubscription;
  int _selectedTabIndex = 0; // 0 for Positions, 1 for All Positions
  final Set<int> _selectedPositions = <int>{};
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
      final positionBook = ref.read(portfolioProvider);

      _socketSubscription = websocket.socketDataStream.listen((socketDatas) {
        bool needsUpdate = false;

        for (var position in widget.listofPosition) {
          if (socketDatas.containsKey(position.token)) {
            final socketData = socketDatas[position.token];
            final lp = socketData['lp']?.toString();
            if (lp != null && lp != "null" && lp != position.lp) {
              position.lp = lp;
              needsUpdate = true;
            }

            final pc = socketData['pc']?.toString();
            if (pc != null && pc != "null" && pc != position.perChange) {
              position.perChange = pc;
              needsUpdate = true;
            }
          }
        }

        if (needsUpdate) {
          positionBook.positionCal(positionBook.isDay);
          if (mounted) setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
        final positionBook = ref.watch(portfolioProvider);
        final theme = ref.read(themeProvider);

        if (positionBook.posloader) {
          return const Center(child: CircularProgressIndicator());
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: RefreshIndicator(
            onRefresh: () async {
              await positionBook.fetchPositionBook(context, false);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Summary Cards Section (includes Trade Positions)
                _buildSummaryCards(theme, positionBook),
                const SizedBox(height: 24),
                
                // Main Content Area
                _buildMainContent(theme, positionBook),
              ],
            ),
              ),
            ),
          ),
    );
  }

  Widget _buildSummaryCards(ThemesProvider theme, PortfolioProvider positionBook) {
    final positiveCount = _getPositivePositionsCount(positionBook);
    final negativeCount = _getNegativePositionsCount(positionBook);
    final closedCount = _getClosedPositionsCount(positionBook);

    return Container(
      padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  'MTM',
                  positionBook.totUnRealMtm,
                  _getValueColor(positionBook.totUnRealMtm, theme),
                  theme,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Profit/Loss',
                  positionBook.totPnL,
                  _getValueColor(positionBook.totPnL, theme),
                  theme,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Trade Value',
                  _calculateTradeValue(positionBook),
                  Colors.black,
                  theme,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Open Position',
                  _calculateOpenPosition(positionBook),
                  _getValueColor(_calculateOpenPosition(positionBook), theme),
                  theme,
                            ),
                          ),
                      ],
                    ),
          const SizedBox(height: 20),
          // Trade Positions section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
              // Text(
              //   'Trade Positions',
              //   style: TextWidget.textStyle(
              //     fontSize: 16,
              //     color: const Color(0xFF374151), // Dark grey
              //                   theme: false,
              //                   fw: 2,
              //                 ),
              //               ),
              const SizedBox(width: 20),
              _buildPositionChip('$positiveCount Positive', const Color(0xFF10B981), theme),
              const SizedBox(width: 12),
              _buildPositionChip('$negativeCount Negative', const Color(0xFFEF4444), theme),
              const SizedBox(width: 12),
              _buildPositionChip('$closedCount Closed', const Color(0xFF6B7280), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextWidget.subText(
          text: label,
          theme: false,
          color: const Color(0xFF6B7280), // Dark grey
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextWidget.textStyle(
          fontSize: 14,
          color: color,
          theme: false,
          fw: 2,
          ),
        ),
      );
  }

  Widget _buildMainContent(ThemesProvider theme, PortfolioProvider positionBook) {
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
          _buildTabs(theme, positionBook),
          
          // Action Bar
          _buildActionBar(theme, positionBook),
          
          // Table
          _buildPositionsTable(theme, positionBook),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemesProvider theme, PortfolioProvider positionBook) {
    final openPositionsCount = _getOpenPositionsCount(positionBook);

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
          _buildTab('Positions ($openPositionsCount)', 0, theme),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, ThemesProvider theme) {
    final isSelected = _selectedTabIndex == index;
    
    return GestureDetector(
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
    );
  }

  Widget _buildActionBar(ThemesProvider theme, PortfolioProvider positionBook) {
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
                  hintText: 'Search',
                hintStyle: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  theme: theme.isDarkMode,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      assets.searchIcon,
                      color:
                        theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      fit: BoxFit.scaleDown,
                      width: 18,
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
          
          // Exit All Button
          ElevatedButton(
            onPressed: _selectedPositions.isNotEmpty ? () => _exitAllPositions() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              _selectedPositions.isNotEmpty 
                  ? 'Exit (${_selectedPositions.length})' 
                  : 'Exit All',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          
          // Refresh Button
          IconButton(
            onPressed: () async {
              await positionBook.fetchPositionBook(context, false);
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

  Widget _buildPositionsTable(ThemesProvider theme, PortfolioProvider positionBook) {
    final filteredPositions = _getFilteredPositions(positionBook);
    
    if (filteredPositions.isEmpty) {
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
            label: Checkbox(
              value: _selectedPositions.length == filteredPositions.length && filteredPositions.isNotEmpty,
              onChanged: filteredPositions.isNotEmpty ? (bool? value) {
          setState(() {
                  if (value == true) {
                    _selectedPositions.addAll(List.generate(filteredPositions.length, (index) => index));
                  } else {
                    _selectedPositions.clear();
                  }
                });
              } : null,
            ),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Product', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Instrument', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Qty', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Act Avg Price', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('LTP', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('P&L', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Avg Price', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('MTM', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Buy Qty', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Sell Qty', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Buy Avg', theme),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Sell Avg', theme),
          ),
        ],
        rows: filteredPositions.asMap().entries.map((entry) {
          final index = entry.key;
          final position = entry.value;
          
          return DataRow(
            selected: _selectedPositions.contains(index),
            cells: [
              DataCell(Checkbox(
                value: _selectedPositions.contains(index),
                onChanged: (bool? value) {
                setState(() {
                    if (value == true) {
                      _selectedPositions.add(index);
                    } else {
                      _selectedPositions.remove(index);
                    }
                  });
                },
              )),
              DataCell(Text(
                position.sPrdtAli ?? 'N/A',
            style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
            ),
              )),
              DataCell(Text(
                '${position.symbol ?? ''} ${position.exch ?? ''}',
            style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
            ),
              )),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getQtyColor(position.qty ?? '0', theme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatQty(position.qty ?? '0'),
            style: TextWidget.textStyle(
              fontSize: 12,
                    color: _getQtyColor(position.qty ?? '0', theme),
                    theme: false,
                    fw: 2,
                  ),
                ),
              )),
              DataCell(Text(
                position.avgPrc ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              )),
              DataCell(Text(
                position.lp ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              )),
              DataCell(Text(
                position.profitNloss ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: _getValueColor(position.profitNloss ?? '0.00', theme),
                  theme: false,
                  fw: 2,
                ),
              )),
              DataCell(Text(
                position.avgPrc ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              )),
              DataCell(Text(
                position.mTm ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: _getValueColor(position.mTm ?? '0.00', theme),
                  theme: false,
                  fw: 2,
                ),
              )),
              DataCell(Text(
                position.daybuyqty ?? '0',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              )),
              DataCell(Text(
                position.daysellqty ?? '0',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              )),
              DataCell(Text(
                position.daybuyavgprc ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              )),
              DataCell(Text(
                position.daysellavgprc ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
              )),
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

  // Helper methods
  String _calculateTradeValue(PortfolioProvider positionBook) {
    double totalValue = 0.0;
    for (var position in widget.listofPosition) {
      final qty = double.tryParse(position.qty ?? '0') ?? 0;
      final lp = double.tryParse(position.lp ?? '0') ?? 0;
      // Use absolute value of quantity for trade value calculation
      totalValue += qty.abs() * lp;
    }
    return totalValue.toStringAsFixed(2);
  }

  String _calculateOpenPosition(PortfolioProvider positionBook) {
    int openCount = 0;
    for (var position in widget.listofPosition) {
      final qty = int.tryParse(position.qty ?? '0') ?? 0;
      if (qty != 0) openCount++;
    }
    return openCount.toString();
  }

  int _getOpenPositionsCount(PortfolioProvider positionBook) {
    int count = 0;
    for (var position in widget.listofPosition) {
      final qty = int.tryParse(position.qty ?? '0') ?? 0;
      if (qty != 0) count++;
    }
    return count;
  }

  int _getPositivePositionsCount(PortfolioProvider positionBook) {
    int count = 0;
    for (var position in widget.listofPosition) {
      final pnl = double.tryParse(position.profitNloss ?? '0') ?? 0;
      if (pnl > 0) count++;
    }
    return count;
  }

  int _getNegativePositionsCount(PortfolioProvider positionBook) {
    int count = 0;
    for (var position in widget.listofPosition) {
      final pnl = double.tryParse(position.profitNloss ?? '0') ?? 0;
      if (pnl < 0) count++;
    }
    return count;
  }

  int _getClosedPositionsCount(PortfolioProvider positionBook) {
    int count = 0;
    for (var position in widget.listofPosition) {
      final qty = int.tryParse(position.qty ?? '0') ?? 0;
      if (qty == 0) count++;
    }
    return count;
  }

  List<PositionBookModel> _getFilteredPositions(PortfolioProvider positionBook) {
    // Only show open positions (non-zero quantity)
    List<PositionBookModel> positions = widget.listofPosition.where((p) => (int.tryParse(p.qty ?? '0') ?? 0) != 0).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      positions = positions.where((position) {
        final symbol = position.symbol?.toLowerCase() ?? '';
        final exch = position.exch?.toLowerCase() ?? '';
        final searchLower = _searchQuery.toLowerCase();
        return symbol.contains(searchLower) || exch.contains(searchLower);
      }).toList();
    }

    // Apply product filter
    if (_selectedFilter != 'All') {
      positions = positions.where((position) {
        return position.sPrdtAli == _selectedFilter;
      }).toList();
    }

    return positions;
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return const Color(0xFF10B981); // Green
    } else if (numValue < 0) {
      return const Color(0xFFEF4444); // Red
    } else {
      return const Color(0xFF6B7280); // Grey
    }
  }

  Color _getQtyColor(String qty, ThemesProvider theme) {
    final numQty = int.tryParse(qty) ?? 0;
    if (numQty > 0) {
      return Colors.green;
    } else if (numQty < 0) {
      return Colors.red;
    } else {
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  String _formatQty(String qty) {
    final numQty = int.tryParse(qty) ?? 0;
    return numQty > 0 ? '+$qty' : qty;
  }

  void _exitAllPositions() {
    // Implement exit all positions logic
    // This would typically show a confirmation dialog and then call the API
  }
}