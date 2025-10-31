import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/screens/web/position/exit_all_positions_dialog_web.dart';
import 'package:mynt_plus/screens/web/position/position_detail_screen_web.dart';

import '../../../../models/portfolio_model/position_book_model.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../sharedWidget/snack_bar.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../utils/responsive_navigation.dart';

class PositionScreenWeb extends ConsumerStatefulWidget {
  final List<PositionBookModel> listofPosition;
  const PositionScreenWeb({super.key, required this.listofPosition});

  @override
  ConsumerState<PositionScreenWeb> createState() => _PositionScreenWebState();
}

class _PositionScreenWebState extends ConsumerState<PositionScreenWeb> {
  StreamSubscription? _socketSubscription;
  int _selectedTabIndex = 0; // 0 for Positions, 1 for All Positions
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _hoveredRowToken; // Track which row is being hovered
  // Approximate heights used to map pointer position to row index
  static const double _headerRowHeight = 56.0;
  static const double _dataRowHeight = 52.0;

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

  Widget _buildSummaryCards(
      ThemesProvider theme, PortfolioProvider positionBook) {
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
                  positionBook.totMtM,
                  _getValueColor(positionBook.totMtM, theme),
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
                  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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
              _buildPositionChip(
                  '$positiveCount Positive', theme.isDarkMode ? colors.profitDark : colors.profitLight, theme),
              const SizedBox(width: 12),
              _buildPositionChip(
                  '$negativeCount Negative', theme.isDarkMode ? colors.lossDark : colors.lossLight, theme),
              const SizedBox(width: 12),
              _buildPositionChip(
                  '$closedCount Closed', theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, theme),
            ],
          ),
        ],
      ),
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

  Widget _buildMainContent(
      ThemesProvider theme, PortfolioProvider positionBook) {
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
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
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
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
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

          // Exit All Button
          Builder(
            builder: (context) {
              final openPositions = positionBook.openPosition ?? [];
              final nonZeroPositions = openPositions.where((p) => p.qty != "0").toList();
              
              // Count only selected positions
              final selectedPositions = nonZeroPositions
                  .where((p) => p.isExitSelection == true)
                  .toList();
              final selectedCount = selectedPositions.length;
              
              // Button should be enabled if there are positions to exit
              final buttonEnabled = selectedCount > 0 || nonZeroPositions.isNotEmpty;
              
              return ElevatedButton(
                onPressed: buttonEnabled ? () => _exitAllPositions() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonEnabled
                      ? (theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: TextWidget.subText(
                  text: selectedCount == 0
                      ? 'Exit All'
                      : (selectedCount == 1
                          ? 'Exit (1)'
                          : 'Exit ($selectedCount)'),
                  theme: false,
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  fw: 2,
                ),
              );
            },
          ),
          const SizedBox(width: 16),

          // Refresh Button
          IconButton(
            onPressed: () async {
              await positionBook.fetchPositionBook(context, false);
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

  Widget _buildPositionsTable(
      ThemesProvider theme, PortfolioProvider positionBook) {
    final filteredPositions = _getFilteredPositions(positionBook);

    if (filteredPositions.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: MouseRegion(
          onExit: (_) {
            if (_hoveredRowToken != null) setState(() => _hoveredRowToken = null);
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IntrinsicWidth(
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
              label: Builder(
                builder: (context) {
                  final theme = ref.read(themeProvider);
                  return Checkbox(
                    value: positionBook.isExitAllPosition,
                    onChanged: filteredPositions.isNotEmpty
                        ? (bool? value) {
                            positionBook.selectExitAllPosition(value ?? false);
                            setState(() {}); // Trigger rebuild to update button count
                          }
                        : null,
                    activeColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  );
                },
              ),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Product', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Instrument', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Qty', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Act Avg Price', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('LTP', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('P&L', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Avg Price', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('MTM', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Buy Qty', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Sell Qty', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Buy Avg', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Sell Avg', theme),
              onSort: (columnIndex, ascending) =>
                  _onSortTable(columnIndex, ascending),
            ),
          ],
          rows: filteredPositions.map((position) {
            final isClosed = _isPositionClosed(position);
            final positionToken = position.token ?? '';
            
            return DataRow(
              onSelectChanged: (bool? selected) {
                _showPositionDetail(position);
              },
              cells: [
                DataCell(
                  GestureDetector(
                    onTap: isClosed ? null : () {
                      // Find the position in the open positions list
                      final openPositions = positionBook.openPosition ?? [];
                      for (int i = 0; i < openPositions.length; i++) {
                        if (openPositions[i].token == position.token) {
                          positionBook.selectExitPosition(i);
                          setState(() {}); // Trigger rebuild to update button count
                          break;
                        }
                      }
                    },
                    child: Checkbox(
                      value: position.isExitSelection ?? false,
                      onChanged: null, // Disable default checkbox behavior
                      activeColor: isClosed 
                          ? Colors.grey 
                          : (theme.isDarkMode ? colors.primaryDark : colors.primaryLight),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.sPrdtAli ?? 'N/A',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${position.symbol ?? ''} ${position.exch ?? ''} ${position.expDate ?? ''} ${position.option ?? ''}',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
               
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isClosed 
                          ? Colors.grey.withOpacity(0.1)
                          : _getQtyColor(position.qty ?? '0', theme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatQty(position.qty ?? '0'),
                      style: TextWidget.textStyle(
                        fontSize: 12,
                        color: isClosed 
                            ? Colors.grey
                            : _getQtyColor(position.qty ?? '0', theme),
                        theme: false,
                        fw: 2,
                      ),
                    ),
                  ),
                ),
                DataCell(
                 (_hoveredRowToken != positionToken) ? Text(
                    position.avgPrc ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ):
                  MouseRegion(
                  onEnter: (_) => setState(() => _hoveredRowToken = positionToken),
                  onExit: (_) {
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted && _hoveredRowToken == positionToken) {
                        setState(() => _hoveredRowToken = null);
                      }
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: _hoveredRowToken == positionToken ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 120),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHoverButton(
                          label: 'B',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          onPressed: () async {
                            await _handlePlaceOrder(context, position, true);
                          },
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                        _buildHoverButton(
                          label: 'S',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.tertiary
                              : WebColors.tertiary,
                          onPressed: () async {
                            await _handlePlaceOrder(context, position, false);
                          },
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                        _buildHoverButton(
                          icon: Icons.bar_chart,
                          color: theme.isDarkMode
                              ? WebDarkColors.textSecondary
                              : WebColors.textSecondary,
                          onPressed: () async {
                            await _handleChartTap(context, position);
                          },
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ),
                ),
                DataCell(
                  Text(
                    position.lp ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.profitNloss ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: isClosed 
                          ? Colors.grey
                          : _getValueColor(position.profitNloss ?? '0.00', theme),
                      theme: false,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.avgPrc ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.mTm ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: isClosed 
                          ? Colors.grey
                          : _getValueColor(position.mTm ?? '0.00', theme),
                      theme: false,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.daybuyqty ?? '0',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.daysellqty ?? '0',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.daybuyavgprc ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    position.daysellavgprc ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getPositionTextColor(position, theme),
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
              // Actions cell shown only when row is hovered
              
              ],
            );
          }).toList(),
            ),
                  ),
            // Transparent overlay to detect hover anywhere per row
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerHover: (event) {
                      final dy = event.localPosition.dy;
                      final yAfterHeader = dy - _headerRowHeight;
                      if (yAfterHeader < 0) {
                        if (_hoveredRowToken != null) {
                          setState(() => _hoveredRowToken = null);
                        }
                        return;
                      }
                      final index = (yAfterHeader / _dataRowHeight).floor();
                      if (index >= 0 && index < filteredPositions.length) {
                        final token = filteredPositions[index].token ?? '';
                        if (_hoveredRowToken != token) {
                          setState(() => _hoveredRowToken = token);
                        }
                      } else {
                        if (_hoveredRowToken != null) {
                          setState(() => _hoveredRowToken = null);
                        }
                      }
                    },
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme) {
    return Text(
      label,
      style: TextWidget.textStyle(
        fontSize: 12,
        color: theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        theme: theme.isDarkMode,
        fw: 2,
      ),
    );
  }

  // Helper methods
  String _calculateTradeValue(PortfolioProvider positionBook) {
    double totalValue = 0.0;
    for (var position in widget.listofPosition) {
      final qty = double.tryParse(position.qty ?? '0') ?? 0;
      final prc = double.tryParse(position.avgPrc ?? '0') ?? 0;
      // Use absolute value of quantity for trade value calculation
      totalValue += qty.abs() * prc;
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

  List<PositionBookModel> _getFilteredPositions(
      PortfolioProvider positionBook) {
    // Show all positions (both open and closed)
    List<PositionBookModel> positions = widget.listofPosition.toList();

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

    // Apply sorting
    if (_sortColumnIndex != null) {
      positions.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 1: // Product
            comparison = (a.sPrdtAli ?? '').compareTo(b.sPrdtAli ?? '');
            break;
          case 2: // Instrument
            comparison = '${a.symbol ?? ''} ${a.exch ?? ''}'
                .compareTo('${b.symbol ?? ''} ${b.exch ?? ''}');
            break;
          case 3: // Qty
            comparison = (int.tryParse(a.qty ?? '0') ?? 0)
                .compareTo(int.tryParse(b.qty ?? '0') ?? 0);
            break;
          case 4: // Act Avg Price
            comparison = (double.tryParse(a.avgPrc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.avgPrc ?? '0') ?? 0);
            break;
          case 5: // LTP
            comparison = (double.tryParse(a.lp ?? '0') ?? 0)
                .compareTo(double.tryParse(b.lp ?? '0') ?? 0);
            break;
          case 6: // P&L
            comparison = (double.tryParse(a.profitNloss ?? '0') ?? 0)
                .compareTo(double.tryParse(b.profitNloss ?? '0') ?? 0);
            break;
          case 7: // Avg Price
            comparison = (double.tryParse(a.avgPrc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.avgPrc ?? '0') ?? 0);
            break;
          case 8: // MTM
            comparison = (double.tryParse(a.mTm ?? '0') ?? 0)
                .compareTo(double.tryParse(b.mTm ?? '0') ?? 0);
            break;
          case 9: // Buy Qty
            comparison = (int.tryParse(a.daybuyqty ?? '0') ?? 0)
                .compareTo(int.tryParse(b.daybuyqty ?? '0') ?? 0);
            break;
          case 10: // Sell Qty
            comparison = (int.tryParse(a.daysellqty ?? '0') ?? 0)
                .compareTo(int.tryParse(b.daysellqty ?? '0') ?? 0);
            break;
          case 11: // Buy Avg
            comparison = (double.tryParse(a.daybuyavgprc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.daybuyavgprc ?? '0') ?? 0);
            break;
          case 12: // Sell Avg
            comparison = (double.tryParse(a.daysellavgprc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.daysellavgprc ?? '0') ?? 0);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    return positions;
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight; // Green
    } else if (numValue < 0) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight; // Red
    } else {
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight; // Grey
    }
  }

  Color _getQtyColor(String qty, ThemesProvider theme) {
    final numQty = int.tryParse(qty) ?? 0;
    if (numQty > 0) {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (numQty < 0) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  String _formatQty(String qty) {
    final numQty = int.tryParse(qty) ?? 0;
    return numQty > 0 ? '+$qty' : qty;
  }

  bool _isPositionClosed(PositionBookModel position) {
    final qty = int.tryParse(position.qty ?? '0') ?? 0;
    return qty == 0;
  }

  Color _getPositionTextColor(PositionBookModel position, ThemesProvider theme) {
    if (_isPositionClosed(position)) {
      return theme.isDarkMode 
          ? colors.textSecondaryDark.withOpacity(0.6)
          : colors.textSecondaryLight.withOpacity(0.6);
    }
    return theme.isDarkMode
        ? colors.textPrimaryDark
        : colors.textPrimaryLight;
  }

  void _exitAllPositions() {
    final positionBook = ref.read(portfolioProvider);
    final openPositions = positionBook.openPosition ?? [];

    // Get selected positions from portfolio provider
    final selectedPositions = openPositions
        .where((p) => p.isExitSelection == true && p.qty != "0")
        .toList();

    if (selectedPositions.isEmpty) {
      // If no positions are selected, show all positions for exit
      final allPositions = openPositions.where((p) => p.qty != "0").toList();
      
      if (allPositions.isEmpty) {
        // No positions to exit
        return;
      }
      
      showDialog(
        context: context,
        builder: (context) => ExitAllPositionsDialogWeb(
          selectedPositions: allPositions,
          selectedIndices: List.generate(allPositions.length, (index) => index),
        ),
      );
    } else {
      // Show only selected positions for exit
      showDialog(
        context: context,
        builder: (context) => ExitAllPositionsDialogWeb(
          selectedPositions: selectedPositions,
          selectedIndices: selectedPositions
              .map((p) => openPositions.indexOf(p))
              .toList(),
        ),
      );
    }
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _showPositionDetail(PositionBookModel position) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: PositionDetailScreenWeb(positionList: position),
        );
      },
    );
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      size: 14,
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

  bool _isInWatchlist(PositionBookModel position, ThemesProvider theme) {
    try {
      final scripData = ref.read(marketWatchProvider);
      final scrips = scripData.scrips;
      final scripToken = "${position.exch ?? ''}|${position.token ?? ''}";
      return scrips.any((scrip) => 
        "${scrip['exch']}|${scrip['token']}" == scripToken
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleChartTap(BuildContext context, PositionBookModel position) async {
    final scripData = ref.read(marketWatchProvider);
    
    await scripData.fetchScripQuoteIndex(
      position.token ?? "",
      position.exch ?? "",
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

  Future<void> _handlePlaceOrder(BuildContext context, PositionBookModel position, bool isBuy) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      
      // Fetch scrip info first
      await scripData.fetchScripInfo(
        position.token ?? "",
        position.exch ?? "",
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
        exchange: position.exch ?? "",
        tSym: position.tsym ?? position.symbol ?? "",
        isExit: false,
        token: position.token ?? "",
        transType: isBuy,
        lotSize: lotSize,
        ltp: position.lp ?? "0.00",
        perChange: position.perChange ?? "0.00",
        orderTpye: '',
        holdQty: position.netqty ?? '',
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
}
