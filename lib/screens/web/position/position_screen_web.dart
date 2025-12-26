import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:mynt_plus/screens/web/position/exit_all_positions_dialog_web.dart';
import 'package:mynt_plus/screens/web/position/position_detail_screen_web.dart';
import 'package:mynt_plus/screens/web/position/convert_position_dialogue_web.dart';

import '../../../../models/portfolio_model/position_book_model.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
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
  int _selectedTabIndex = 0; // 0 for Positions, 1 for All Positions
  // ✅ Use ValueNotifier for search query to avoid rebuilding entire widget
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final String _selectedFilter = 'All';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  // ✅ Use ValueNotifier instead of setState to avoid rebuilding entire widget
  final ValueNotifier<String?> _hoveredRowToken = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL FIX: Only watch posloader to prevent unnecessary rebuilds
    // Using select() ensures we only rebuild when loading state changes
    final isLoading = ref.watch(portfolioProvider.select((p) => p.posloader));
    final theme = ref.read(themeProvider);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ Access positionBook without watching to avoid rebuilds
    final positionBook = ref.read(portfolioProvider);

    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards Section (includes Trade Positions)
                _buildSummaryCards(theme, positionBook),
                const SizedBox(height: 24),

                // Main Content Area - Expanded to take remaining space
                Expanded(
                  child: _buildMainContent(theme, positionBook),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
      ThemesProvider theme, PortfolioProvider positionBook) {
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
          // Main stats row
          Row(
            children: [
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
                  'MTM',
                  positionBook.totMtM,
                  _getValueColor(positionBook.totMtM, theme),
                  theme,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Trade Value',
                  _calculateTradeValue(positionBook),
                  theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                  theme,
                ),
              ),
              // _buildDivider(theme),
              // Expanded(
              //   child: _buildStatItem(
              //     'Open Position',
              //     _calculateOpenPosition(positionBook),
              //     _getValueColor(_calculateOpenPosition(positionBook), theme),
              //     theme,
              //   ),
              // ),
            ],
          ),
          // const SizedBox(height: 20),
          // // Trade Positions section
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     // Text(
          //     //   'Trade Positions',
          //     //   style: WebTextStyles.title(
          //     //     isDarkTheme: theme.isDarkMode,
          //     //     color: const Color(0xFF374151), // Dark grey
          //     //     fontWeight: WebFonts.semiBold,
          //     //   ),
          //     // ),
          //     const SizedBox(width: 20),
          //     _buildPositionChip(
          //         '$positiveCount Positive', theme.isDarkMode ? WebDarkColors.success : WebColors.success, theme),
          //     const SizedBox(width: 12),
          //     _buildPositionChip(
          //         '$negativeCount Negative', theme.isDarkMode ? WebDarkColors.error : WebColors.error, theme),
          //     const SizedBox(width: 12),
          //     _buildPositionChip(
          //         '$closedCount Closed', theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary, theme),
          //   ],
          // ),
        ],
      ),
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
      ThemesProvider theme, PortfolioProvider positionBook) {
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
          _buildTabsAndActionBar(theme, positionBook),
          const SizedBox(height: 16),
          // Table - Expanded to take remaining space
          Expanded(
            child: _buildPositionsTable(theme, positionBook),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndActionBar(
      ThemesProvider theme, PortfolioProvider positionBook) {
    final openPositionsCount = _getOpenPositionsCount(positionBook);

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
          _buildSegmentedControl(theme, positionBook, openPositionsCount),
          // Spacer to push action items to the right
          const Spacer(),
          // Search Bar
          SizedBox(
            width: 400,
            child: Container(
              height: 40,
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
                  hintText: 'Search positions',
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
          // Exit All Button
          Builder(
            builder: (context) {
              final openPositions = positionBook.openPosition ?? [];
              final nonZeroPositions =
                  openPositions.where((p) => p.qty != "0").toList();

              // Count only selected positions
              final selectedPositions = nonZeroPositions
                  .where((p) => p.isExitSelection == true)
                  .toList();
              final selectedCount = selectedPositions.length;

              // Button should be enabled if there are positions to exit
              final buttonEnabled =
                  selectedCount > 0 || nonZeroPositions.isNotEmpty;

              return ElevatedButton(
                onPressed: buttonEnabled ? () => _exitAllPositions() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonEnabled
                      ? (theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  selectedCount == 0
                      ? 'Exit All'
                      : (selectedCount == 1
                          ? 'Exit (1)'
                          : 'Exit ($selectedCount)'),
                  style: WebTextStyles.buttonMd(
                    isDarkTheme: theme.isDarkMode,
                    color: Colors.white,
                    fontWeight: WebFonts.medium,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
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
                await positionBook.fetchPositionBook(context, false);
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

  Widget _buildTabs(ThemesProvider theme, PortfolioProvider positionBook) {
    final openPositionsCount = _getOpenPositionsCount(positionBook);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
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

  Widget _buildSegmentedControl(ThemesProvider theme,
      PortfolioProvider positionBook, int openPositionsCount) {
    final tabs = [
      'Positions ($openPositionsCount)',
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
                    color: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
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
                : (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary),
            fontWeight: isSelected ? WebFonts.semiBold : WebFonts.medium,
            letterSpacing: 0.0,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(ThemesProvider theme, PortfolioProvider positionBook) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Search Bar
          SizedBox(
            width: 400,
            child: Container(
              height: 40,
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
                ).copyWith(fontWeight: WebFonts.bold),
                decoration: InputDecoration(
                  hintText: '',
                  hintStyle: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textSecondary
                        : WebColors.textSecondary,
                  ).copyWith(fontWeight: WebFonts.bold),
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

          // Exit All Button
          Builder(
            builder: (context) {
              final openPositions = positionBook.openPosition ?? [];
              final nonZeroPositions =
                  openPositions.where((p) => p.qty != "0").toList();

              // Count only selected positions
              final selectedPositions = nonZeroPositions
                  .where((p) => p.isExitSelection == true)
                  .toList();
              final selectedCount = selectedPositions.length;

              // Button should be enabled if there are positions to exit
              final buttonEnabled =
                  selectedCount > 0 || nonZeroPositions.isNotEmpty;

              return ElevatedButton(
                onPressed: buttonEnabled ? () => _exitAllPositions() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonEnabled
                      ? (theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  selectedCount == 0
                      ? 'Exit All'
                      : (selectedCount == 1
                          ? 'Exit (1)'
                          : 'Exit ($selectedCount)'),
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: Colors.white,
                    fontWeight: WebFonts.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),

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
                await positionBook.fetchPositionBook(context, false);
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
        ],
      ),
    );
  }

  // Responsive breakpoints
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  // Helper method to get responsive column configuration
  Map<String, dynamic> _getResponsivePositionColumns(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: Show only essential columns
      return {
        'headers': ['Select', 'Instrument', 'Qty', 'LTP', 'P&L'],
        'columnMinWidth': {
          'Select': 60,
          'Instrument': 250,
          'Qty': 90,
          'LTP': 100,
          'P&L': 110,
        },
      };
    } else if (screenWidth < _tabletBreakpoint) {
      // Tablet: Show most columns
      return {
        'headers': ['Select', 'Instrument', 'Product', 'Qty', 'LTP', 'P&L', 'MTM'],
        'columnMinWidth': {
          'Select': 60,
          'Instrument': 250,
          'Product': 130,
          'Qty': 80,
          'LTP': 100,
          'P&L': 110,
          'MTM': 110,
        },
      };
    } else if (screenWidth < _desktopBreakpoint) {
      // Small Desktop: Show more columns
      return {
        'headers': ['Select', 'Instrument', 'Product', 'Qty', 'Act Avg Price', 'LTP', 'P&L', 'MTM', 'Avg Price'],
        'columnMinWidth': {
          'Select': 60,
          'Instrument': 250,
          'Product': 130,
          'Qty': 80,
          'Act Avg Price': 140,
          'LTP': 100,
          'P&L': 110,
          'MTM': 110,
          'Avg Price': 110,
        },
      };
    } else {
      // Large Desktop: Full columns with optimal widths
      return {
        'headers': ['Select', 'Instrument', 'Product', 'Qty', 'Act Avg Price', 'LTP', 'P&L', 'MTM', 'Avg Price', 'Buy Qty', 'Sell Qty', 'Buy Avg', 'Sell Avg'],
        'columnMinWidth': {
          'Select': 60,
          'Instrument': 300,
          'Product': 130,
          'Qty': 80,
          'Act Avg Price': 140,
          'LTP': 100,
          'P&L': 110,
          'MTM': 110,
          'Avg Price': 130,
          'Buy Qty': 95,
          'Sell Qty': 95,
          'Buy Avg': 111,
          'Sell Avg': 105,
        },
      };
    }
  }

  Widget _buildPositionsTable(
      ThemesProvider theme, PortfolioProvider positionBook) {
    // ✅ CRITICAL: Watch position list to rebuild when positions are added/removed
    // Use select() to only rebuild when the list reference changes, not on every provider update
    final currentPositions = ref.watch(portfolioProvider.select((p) => p.allPostionList));
    
    // ✅ Use ValueListenableBuilder to only rebuild table when search query changes
    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, searchQuery, child) {
        // ✅ Use current positions from provider instead of widget.listofPosition
        // This ensures table updates when positions are added/removed
        final positionsToUse = currentPositions.isNotEmpty ? currentPositions : widget.listofPosition;
        final filteredPositions = _getFilteredPositionsFromList(positionsToUse);

        if (filteredPositions.isEmpty) {
          return const Center(child: NoDataFound());
        }
        
        return _buildTableContent(theme, positionBook, filteredPositions);
      },
    );
  }
  
  // ✅ Helper method that works with a list instead of provider
  List<PositionBookModel> _getFilteredPositionsFromList(List<PositionBookModel> positions) {
    List<PositionBookModel> filtered = positions.toList();

    // Apply search filter - use ValueNotifier value
    final searchQuery = _searchQuery.value;
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((position) {
        final symbol = position.symbol?.toLowerCase() ?? '';
        final exch = position.exch?.toLowerCase() ?? '';
        final searchLower = searchQuery.toLowerCase();
        return symbol.contains(searchLower) || exch.contains(searchLower);
      }).toList();
    }

    // Apply product filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((position) {
        return position.sPrdtAli == _selectedFilter;
      }).toList();
    }

    // Apply sorting
    if (_sortColumnIndex != null) {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 1: // Instrument
            comparison = '${a.symbol ?? ''} ${a.exch ?? ''}'
                .compareTo('${b.symbol ?? ''} ${b.exch ?? ''}');
            break;
          case 2: // Product
            comparison = (a.sPrdtAli ?? '').compareTo(b.sPrdtAli ?? '');
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
          case 7: // MTM
            comparison = (double.tryParse(a.mTm ?? '0') ?? 0)
                .compareTo(double.tryParse(b.mTm ?? '0') ?? 0);
            break;
          case 8: // Avg Price
            comparison = (double.tryParse(a.avgPrc ?? '0') ?? 0)
                .compareTo(double.tryParse(b.avgPrc ?? '0') ?? 0);
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

    return filtered;
  }

  Widget _buildTableContent(
      ThemesProvider theme, PortfolioProvider positionBook, List<PositionBookModel> filteredPositions) {

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
        final responsiveConfig = _getResponsivePositionColumns(screenWidth);
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
              child: RepaintBoundary(
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 1800, // Increased to accommodate wider columns
                  sortColumnIndex: null, // Disable DataTable2's built-in sorting
                  sortAscending: _sortAscending,
                  fixedLeftColumns: 2, // Fix the first two columns (Select and Instrument)
                  fixedColumnsColor: theme.isDarkMode 
                      ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                      : WebColors.backgroundSecondary.withOpacity(0.8),
                  showBottomBorder: true,
                  horizontalScrollController: _horizontalScrollController,
                  scrollController: _verticalScrollController,
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
                  columns: _buildDataTable2Columns(headers, columnMinWidth, theme, positionBook, filteredPositions),
                  rows: _buildDataTable2Rows(filteredPositions, headers, theme, positionBook),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isNumericColumn(String header) {
    return header != 'Select' && header != 'Instrument'; // All columns except Select and Instrument contain numeric data
  }

  int _getColumnIndexForHeader(String header) {
    switch (header) {
      case 'Select': return 0;
      case 'Instrument': return 1;
      case 'Product': return 2;
      case 'Qty': return 3;
      case 'Act Avg Price': return 4;
      case 'LTP': return 5;
      case 'P&L': return 6;
      case 'MTM': return 7;
      case 'Avg Price': return 8;
      case 'Buy Qty': return 9;
      case 'Sell Qty': return 10;
      case 'Buy Avg': return 11;
      case 'Sell Avg': return 12;
      default: return -1;
    }
  }

  List<DataColumn2> _buildDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
    PortfolioProvider positionBook,
    List<PositionBookModel> filteredPositions,
  ) {
    return headers.map((header) {
      final columnIndex = _getColumnIndexForHeader(header);
      final isNumeric = _isNumericColumn(header);
      
      // Special handling for fixed columns (Select and Instrument)
      final isSelect = header == 'Select';
      final isInstrument = header == 'Instrument';
      final isActAvgPrice = header == 'Act Avg Price';
      
      // Get the min width for this column, or use default
      final minWidth = columnMinWidth[header];
      
      return DataColumn2(
        label: isSelect ? _buildPositionHeaderWidget(
          header,
          columnIndex,
          theme,
          positionBook,
          filteredPositions,
        ) : SizedBox.expand(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => _hoveredColumnIndex.value = columnIndex,
            onExit: (_) => _hoveredColumnIndex.value = null,
            child: Tooltip(
              message: 'Sort by $header',
              child: GestureDetector(
                onTap: () => _onSortTable(columnIndex),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isActAvgPrice ? 6.0 : 8.0, 
                        vertical: 12.0
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  header,
                                  style: WebTextStyles.tableHeader(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                  ),
                                  textAlign: isNumeric ? TextAlign.right : TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 16, // Fixed width for the icon
                                  child: _buildSortIcon(columnIndex, theme),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        size: isInstrument ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isSelect ? 60.0 : (isInstrument ? 300.0 : (isActAvgPrice && minWidth != null ? minWidth : null)),
        onSort: null, // Disable DataTable2's default sort
      );
    }).toList();
  }

  List<DataRow2> _buildDataTable2Rows(
    List<PositionBookModel> positions,
    List<String> headers,
    ThemesProvider theme,
    PortfolioProvider positionBook,
  ) {
    return positions.map((position) {
      final isClosed = _isPositionClosed(position);
      final uniqueId =
          '${position.token ?? ''}_${position.exch ?? ''}_${position.prd ?? ''}_${position.tsym ?? ''}';

      // ✅ CRITICAL FIX: Wrap row in ValueListenableBuilder to prevent all rows from rebuilding on hover
      // Only the hovered row rebuilds, not the entire table
      return DataRow2(
        key: ValueKey(uniqueId), // Add key for better widget identity
        color: WidgetStateProperty.resolveWith((states) {
          // ✅ Use states.contains(WidgetState.hovered) for built-in hover detection
          // Remove direct _hoveredRowToken.value access to prevent rebuilds
          if (states.contains(WidgetState.hovered)) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return Colors.transparent;
        }),
        cells: headers.map((header) {
          return _buildDataTable2Cell(
            header,
            position,
            theme,
            isClosed,
            uniqueId,
            positionBook,
          );
        }).toList(),
        onTap: () => _showPositionDetail(position),
      );
    }).toList();
  }

  DataCell _buildDataTable2Cell(
    String column,
    PositionBookModel position,
    ThemesProvider theme,
    bool isClosed,
    String uniqueId,
    PortfolioProvider positionBook,
  ) {
    Widget cellContent;
    final isNumeric = _isNumericColumn(column);
    final alignment = isNumeric ? Alignment.centerRight : Alignment.centerLeft;
    
    switch (column) {
      case 'Select':
        cellContent = _buildPositionCheckboxCell(position, theme, isClosed, positionBook);
        break;
      case 'Instrument':
        cellContent = _buildInstrumentCellContent(
          position,
          theme,
          isClosed,
          positionBook,
          uniqueId,
        );
        break;
      case 'Product':
        cellContent = _buildPositionTextCell(
          position.sPrdtAli ?? 'N/A',
          theme,
          alignment,
          color: _getPositionTextColor(position, theme),
        );
        break;
      case 'Qty':
        cellContent = _buildPositionTextCell(
          _formatQty(position.qty ?? '0'),
          theme,
          alignment,
          color: isClosed ? Colors.grey : _getQtyColor(position.qty ?? '0', theme),
        );
        break;
      case 'Act Avg Price':
        cellContent = _buildPositionTextCell(
          position.avgPrc ?? '0.00',
          theme,
          alignment,
          color: _getPositionTextColor(position, theme),
        );
        break;
      // Dynamic columns - use isolated widgets that manage their own state
      // Each widget only rebuilds itself, not the table
      case 'LTP':
        if (position.token == null || position.token!.isEmpty) {
          cellContent = _buildPositionTextCell(
            position.lp ?? '0.00',
            theme,
            alignment,
            color: _getPositionTextColor(position, theme),
          );
        } else {
          cellContent = _LTPCell(
            token: position.token!,
            initialLtp: position.lp ?? '0.00',
          );
        }
        break;
      case 'P&L':
        if (position.token == null || position.token!.isEmpty) {
          cellContent = _buildPositionTextCell(
            position.profitNloss ?? '0.00',
            theme,
            alignment,
            color: isClosed
                ? Colors.grey
                : _getValueColor(position.profitNloss ?? '0.00', theme),
          );
        } else {
          final qty = int.tryParse(position.qty ?? '0') ?? 0;
          final avgPrice = double.tryParse(position.avgPrc ?? '0') ?? 0.0;
          cellContent = _PnLCell(
            token: position.token!,
            qty: qty,
            avgPrice: avgPrice,
            initialValue: position.profitNloss ?? '0.00',
            theme: theme,
            isClosed: isClosed,
          );
        }
        break;
      case 'MTM':
        if (position.token == null || position.token!.isEmpty) {
          cellContent = _buildPositionTextCell(
            position.mTm ?? '0.00',
            theme,
            alignment,
            color: isClosed
                ? Colors.grey
                : _getValueColor(position.mTm ?? '0.00', theme),
          );
        } else {
          final qty = int.tryParse(position.qty ?? '0') ?? 0;
          final avgPrice = double.tryParse(position.avgPrc ?? '0') ?? 0.0;
          cellContent = _MTMCell(
            token: position.token!,
            qty: qty,
            avgPrice: avgPrice,
            initialValue: position.mTm ?? '0.00',
            theme: theme,
            isClosed: isClosed,
          );
        }
        break;
      case 'Avg Price':
        cellContent = _buildPositionTextCell(
          position.avgPrc ?? '0.00',
          theme,
          alignment,
          color: _getPositionTextColor(position, theme),
        );
        break;
      case 'Buy Qty':
        cellContent = _buildPositionTextCell(
          position.daybuyqty ?? '0',
          theme,
          alignment,
          color: _getPositionTextColor(position, theme),
        );
        break;
      case 'Sell Qty':
        cellContent = _buildPositionTextCell(
          position.daysellqty ?? '0',
          theme,
          alignment,
          color: _getPositionTextColor(position, theme),
        );
        break;
      case 'Buy Avg':
        cellContent = _buildPositionTextCell(
          position.daybuyavgprc ?? '0.00',
          theme,
          alignment,
          color: _getPositionTextColor(position, theme),
        );
        break;
      case 'Sell Avg':
        cellContent = _buildPositionTextCell(
          position.daysellavgprc ?? '0.00',
          theme,
          alignment,
          color: _getPositionTextColor(position, theme),
        );
        break;
      default:
        cellContent = const SizedBox.shrink();
    }

    // Wrap with MouseRegion to detect hover anywhere on the cell
    return DataCell(
      MouseRegion(
        onEnter: (_) => _hoveredRowToken.value = uniqueId,
        onExit: (_) => _hoveredRowToken.value = null,
        child: SizedBox.expand(
          child: Container(
            alignment: alignment,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: cellContent,
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentCellContent(
    PositionBookModel position,
    ThemesProvider theme,
    bool isClosed,
    PortfolioProvider positionBook,
    String uniqueId,
  ) {
    final displayText =
        '${position.symbol ?? ''} ${position.exch ?? ''} ${position.expDate ?? ''} ${position.option ?? ''}';

    // ✅ Use ValueListenableBuilder to avoid rebuilding entire table on hover
    return ValueListenableBuilder<String?>(
      valueListenable: _hoveredRowToken,
      builder: (context, hoveredToken, child) {
        final rowIsHovered = hoveredToken == uniqueId;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: rowIsHovered ? 1 : 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: displayText,
                  child: Text(
                    displayText,
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: _getPositionTextColor(position, theme),
                      fontWeight: WebFonts.medium,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
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
                    if (!isClosed &&
                        position.qty != "0" &&
                        position.sPrdtAli != "BO" &&
                        position.sPrdtAli != "CO" &&
                        !positionBook.isDay) ...[
                      _buildHoverButton(
                        label: 'Add',
                        color: Colors.white,
                        backgroundColor: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        onPressed: () async {
                          await _handleAddPosition(context, position);
                        },
                        theme: theme,
                      ),
                      const SizedBox(width: 6),
                      _buildHoverButton(
                        label: 'Exit',
                        color: Colors.white,
                        backgroundColor: theme.isDarkMode
                            ? WebDarkColors.tertiary
                            : WebColors.tertiary,
                        onPressed: () async {
                          await _handleExitPosition(context, position);
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
                        await _handleChartTap(context, position);
                      },
                      theme: theme,
                    ),
                    if (!isClosed && position.qty != "0") ...[
                      const SizedBox(width: 6),
                      _buildHoverButton(
                        icon: Icons.swap_horiz,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        borderRadius: 5.0,
                        iconWeight: 700,
                        onPressed: () {
                          _handleConvertPosition(context, position);
                        },
                        theme: theme,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionHeaderWidget(
    String label,
    int columnIndex,
    ThemesProvider theme,
    PortfolioProvider positionBook,
    List<PositionBookModel> filteredPositions,
  ) {
    // Special case for Select column (checkbox)
    if (label == 'Select') {
      // ✅ Watch provider state instead of using setState
      return Consumer(
        builder: (context, ref, child) {
          final isExitAllPosition = ref.watch(portfolioProvider.select((p) => p.isExitAllPosition));
          return InkWell(
            onTap: filteredPositions.isNotEmpty
                ? () {
                    positionBook.selectExitAllPosition(!isExitAllPosition);
                  }
                : null,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    checkboxTheme: CheckboxThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary.withOpacity(0.5)
                            : WebColors.textPrimary.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Checkbox(
                    value: isExitAllPosition,
                    onChanged: filteredPositions.isNotEmpty
                        ? (bool? value) {
                            positionBook.selectExitAllPosition(value ?? false);
                          }
                        : null,
                    activeColor: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Sortable header for other columns
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
        // Sort icon - show unfold_more when not sorted, reserve space when sorted
        if (columnIndex > 0)
          _buildSortIcon(columnIndex, theme),
      ],
    );
  }

  Widget _buildSortIcon(int columnIndex, ThemesProvider theme) {
    IconData icon;
    Color color;

    if (_sortColumnIndex == columnIndex) {
      // Column is currently sorted
      icon = _sortAscending ? Icons.arrow_upward : Icons.arrow_downward;
      color = theme.isDarkMode ? WebDarkColors.primary : WebColors.primary;
    } else {
      // Column is not sorted
      icon = Icons.unfold_more;
      color = theme.isDarkMode
          ? WebDarkColors.iconSecondary.withOpacity(0.6)
          : WebColors.iconSecondary.withOpacity(0.6);
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }


  Widget _buildPositionCheckboxCell(
    PositionBookModel position,
    ThemesProvider theme,
    bool isClosed,
    PortfolioProvider positionBook,
  ) {
    // ✅ Use Consumer to watch only the specific position's selection state
    return Consumer(
      builder: (context, ref, child) {
        // Find the position index and watch its selection state
        final openPositions = ref.watch(portfolioProvider.select((p) => p.openPosition ?? []));
        final positionIndex = openPositions.indexWhere((p) => p.token == position.token);
        final isSelected = positionIndex >= 0 
            ? (openPositions[positionIndex].isExitSelection ?? false)
            : (position.isExitSelection ?? false);
        
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                checkboxTheme: CheckboxThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary.withOpacity(0.5)
                        : WebColors.textPrimary.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
              child: Checkbox(
                value: isSelected,
                onChanged: isClosed
                    ? null
                    : (bool? value) {
                        if (positionIndex >= 0) {
                          positionBook.selectExitPosition(positionIndex);
                        }
                      },
                activeColor: theme.isDarkMode
                    ? WebDarkColors.primary
                    : WebColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Text(
          text,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: color ??
                (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary),
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
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

  // ✅ REMOVED: Old _getFilteredPositions method - replaced with _getFilteredPositionsFromList
  // This ensures we use the watched position list from provider for real-time updates

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

  Color _getQtyColor(String qty, ThemesProvider theme) {
    final numQty = int.tryParse(qty) ?? 0;
    if (numQty > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numQty < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
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

  Color _getPositionTextColor(
      PositionBookModel position, ThemesProvider theme) {
    if (_isPositionClosed(position)) {
      return theme.isDarkMode
          ? WebDarkColors.textSecondary.withOpacity(0.6)
          : WebColors.textSecondary.withOpacity(0.6);
    }
    return theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary;
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
          selectedIndices:
              selectedPositions.map((p) => openPositions.indexOf(p)).toList(),
        ),
      );
    }
  }

  void _onSortTable(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        // If the same column is tapped, toggle the sort order
        _sortAscending = !_sortAscending;
      } else {
        // If a new column is tapped, sort it ascending by default
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  void _showPositionDetail(PositionBookModel position) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
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

  bool _isInWatchlist(PositionBookModel position, ThemesProvider theme) {
    try {
      final scripData = ref.read(marketWatchProvider);
      final scrips = scripData.scrips;
      final scripToken = "${position.exch ?? ''}|${position.token ?? ''}";
      return scrips
          .any((scrip) => "${scrip['exch']}|${scrip['token']}" == scripToken);
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleChartTap(
      BuildContext context, PositionBookModel position) async {
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

  Future<void> _handlePlaceOrder(
      BuildContext context, PositionBookModel position, bool isBuy) async {
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
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
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
      showResponsiveWarningMessage(
          context, "Error placing order: ${e.toString()}");
    }
  }

  Future<void> _handleExitPosition(
      BuildContext context, PositionBookModel position) async {
    try {
      final scripData = ref.read(marketWatchProvider);

      await scripData.fetchScripInfo(
        position.token ?? "",
        position.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final netQty = int.tryParse(position.netqty ?? "0") ?? 0;
      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: position.exch ?? "",
        tSym: position.tsym ?? "",
        isExit: true,
        token: position.token ?? "",
        transType: netQty < 0 ? true : false,
        prd: position.prd ?? "",
        lotSize: position.netqty ?? "",
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
          "scripInfo": scripData.scripInfoModel!,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(
          context, "Error exiting position: ${e.toString()}");
    }
  }

  Future<void> _handleAddPosition(
      BuildContext context, PositionBookModel position) async {
    try {
      final scripData = ref.read(marketWatchProvider);

      await scripData.fetchScripInfo(
        position.token ?? "",
        position.exch ?? "",
        context,
        true,
      );

      if (scripData.scripInfoModel == null) {
        showResponsiveWarningMessage(
            context, "Unable to fetch scrip information");
        return;
      }

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";
      final netQty = int.tryParse(position.netqty ?? "0") ?? 0;

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: position.exch ?? "",
        tSym: position.tsym ?? "",
        isExit: false,
        token: position.token ?? "",
        transType: netQty < 0 ? false : true,
        prd: position.prd ?? "",
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
          "scripInfo": scripData.scripInfoModel!,
          "isBskt": "",
        },
      );
    } catch (e) {
      showResponsiveWarningMessage(
          context, "Error adding position: ${e.toString()}");
    }
  }

  void _handleConvertPosition(
      BuildContext context, PositionBookModel position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConvertPositionDialogueWeb(convertPosition: position);
      },
    );
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

// Isolated widget for P&L
class _PnLCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final double avgPrice;
  final String initialValue;
  final ThemesProvider theme;
  final bool isClosed;

  const _PnLCell({
    required this.token,
    required this.qty,
    required this.avgPrice,
    required this.initialValue,
    required this.theme,
    required this.isClosed,
  });

  @override
  ConsumerState<_PnLCell> createState() => _PnLCellState();
}

class _PnLCellState extends ConsumerState<_PnLCell> {
  late String pnl;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    pnl = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        // Simplified P&L calculation: (LTP - avgPrice) * qty
        final newPnL = ((ltp - widget.avgPrice) * widget.qty).toStringAsFixed(2);
        if (newPnL != pnl) {
          setState(() => pnl = newPnL);
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
      pnl,
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: widget.isClosed
            ? Colors.grey
            : _getValueColor(pnl, widget.theme),
        fontWeight: WebFonts.medium,
      ),
      textAlign: TextAlign.right,
    );
  }
}

// Isolated widget for MTM
class _MTMCell extends ConsumerStatefulWidget {
  final String token;
  final int qty;
  final double avgPrice;
  final String initialValue;
  final ThemesProvider theme;
  final bool isClosed;

  const _MTMCell({
    required this.token,
    required this.qty,
    required this.avgPrice,
    required this.initialValue,
    required this.theme,
    required this.isClosed,
  });

  @override
  ConsumerState<_MTMCell> createState() => _MTMCellState();
}

class _MTMCellState extends ConsumerState<_MTMCell> {
  late String mtm;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    mtm = widget.initialValue;

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted || !data.containsKey(widget.token)) return;

      final newLtp = data[widget.token]['lp']?.toString();
      if (newLtp != null && newLtp != '0.00' && newLtp != 'null') {
        final ltp = double.tryParse(newLtp) ?? 0.0;
        // Simplified MTM calculation: (LTP - avgPrice) * qty
        final newMtm = ((ltp - widget.avgPrice) * widget.qty).toStringAsFixed(2);
        if (newMtm != mtm) {
          setState(() => mtm = newMtm);
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
      mtm,
      style: WebTextStyles.custom(
        fontSize: 13,
        isDarkTheme: widget.theme.isDarkMode,
        color: widget.isClosed
            ? Colors.grey
            : _getValueColor(mtm, widget.theme),
        fontWeight: WebFonts.medium,
      ),
      textAlign: TextAlign.right,
    );
  }
}
