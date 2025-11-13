import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
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
  StreamSubscription? _socketSubscription;
  int _selectedTabIndex = 0; // 0 for Positions, 1 for All Positions
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _hoveredRowToken; // Track which row is being hovered
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

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

    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
        child: GestureDetector(
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
                  theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
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
            color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
            fontWeight: WebFonts.regular,
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
          _buildTabsAndActionBar(theme, positionBook),
          const SizedBox(height: 16),
          // Table
          _buildPositionsTable(theme, positionBook),
        ],
      ),
    );
  }

  Widget _buildTabsAndActionBar(ThemesProvider theme, PortfolioProvider positionBook) {
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

  Widget _buildSegmentedControl(ThemesProvider theme, PortfolioProvider positionBook, int openPositionsCount) {
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
              fontWeight:  isSelected ? FontWeight.w700 : FontWeight.w600,
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
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Search Bar
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

  Widget _buildPositionsTable(
      ThemesProvider theme, PortfolioProvider positionBook) {
    final filteredPositions = _getFilteredPositions(positionBook);

    if (filteredPositions.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
      //   ),
      //   borderRadius: BorderRadius.circular(8),
      // ),
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
            child: Column(
              children: [
                Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  radius: Radius.zero,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16), // Space at top of horizontal scrollbar
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
                          .withOpacity(0.05);
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
            label: Builder(
              builder: (context) {
                final theme = ref.read(themeProvider);
                return Theme(
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
                    value: positionBook.isExitAllPosition,
                    onChanged: filteredPositions.isNotEmpty
                        ? (bool? value) {
                            positionBook.selectExitAllPosition(value ?? false);
                            setState(() {}); // Trigger rebuild to update button count
                          }
                        : null,
                    activeColor: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                  ),
                );
              },
            ),
          ),
          // Reordered: Instrument first (like order book)
          DataColumn(
            label: _buildSortableColumnHeader('Instrument', theme, 1),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Product', theme, 2),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Qty', theme, 3),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Act Avg Price', theme, 4),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('LTP', theme, 5),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('P&L', theme, 6),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('MTM', theme, 7),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Avg Price', theme, 8),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Buy Qty', theme, 9),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Sell Qty', theme, 10),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Buy Avg', theme, 11),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Sell Avg', theme, 12),
            onSort: (columnIndex, ascending) =>
                _onSortTable(columnIndex, ascending),
          ),
                ],
                rows: filteredPositions.asMap().entries.map((entry) {
          final index = entry.key;
          final position = entry.value;
          final isClosed = _isPositionClosed(position);
          // Create unique identifier for each position row (combine token, exchange, product, and index)
          final uniqueId = '${position.token ?? ''}_${position.exch ?? ''}_${position.prd ?? ''}_${position.tsym ?? ''}_$index';
          
          return DataRow(
            onSelectChanged: (bool? selected) {
              _showPositionDetail(position);
            },
            cells: [
              // Checkbox - left aligned
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Theme(
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
                    value: position.isExitSelection ?? false,
                    onChanged: isClosed ? null : (bool? value) {
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
                    activeColor: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                  ),
                ),
              ), alignment: Alignment.centerLeft),
              // Instrument - text (left aligned)
              _buildInstrumentCellWithHover(position, theme, uniqueId, positionBook),
              // Product - text (left aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.sPrdtAli ?? 'N/A',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerLeft),
              // Qty - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  _formatQty(position.qty ?? '0'),
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: isClosed 
                        ? Colors.grey
                        : _getQtyColor(position.qty ?? '0', theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // Act Avg Price - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.avgPrc ?? '0.00',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // LTP - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.lp ?? '0.00',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // P&L - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.profitNloss ?? '0.00',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: isClosed 
                        ? Colors.grey
                        : _getValueColor(position.profitNloss ?? '0.00', theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // MTM - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.mTm ?? '0.00',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: isClosed 
                        ? Colors.grey
                        : _getValueColor(position.mTm ?? '0.00', theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // Avg Price - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.avgPrc ?? '0.00',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // Buy Qty - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.daybuyqty ?? '0',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // Sell Qty - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.daysellqty ?? '0',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // Buy Avg - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.daybuyavgprc ?? '0.00',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
              // Sell Avg - numeric (right aligned)
              _buildCellWithHover(position, theme, uniqueId, DataCell(
                Text(
                  position.daysellavgprc ?? '0.00',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ), alignment: Alignment.centerRight),
            ],
          );
        }).toList(),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
    
  }

  DataCell _buildCellWithHover(PositionBookModel position, ThemesProvider theme, String token, DataCell cell, {Alignment alignment = Alignment.centerRight}) {
    // Wrap the cell's child with MouseRegion to detect hover anywhere on the row
    // Use SizedBox.expand to fill the entire cell area, not just the text content
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = token),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment, // Align content based on parameter
            child: cell.child,
          ),
        ),
      ),
    );
  }

  DataCell _buildInstrumentCellWithHover(PositionBookModel position, ThemesProvider theme, String token, PortfolioProvider positionBook) {
    final isClosed = _isPositionClosed(position);
    final isHovered = _hoveredRowToken == token;
    final displayText = '${position.symbol ?? ''} ${position.exch ?? ''} ${position.expDate ?? ''} ${position.option ?? ''}';

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = token),
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
                        color: _getPositionTextColor(position, theme),
                      ),
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 1,
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
                      // Add and Exit buttons for open positions
                      if (!isClosed && position.qty != "0" && position.sPrdtAli != "BO" && position.sPrdtAli != "CO" && !positionBook.isDay) ...[
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
                      // Chart button
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
                          await _handleChartTap(context, position);
                        },
                        theme: theme,
                      ),
                      // Convert Position button for open positions
                      if (!isClosed && position.qty != "0") ...[
                        const SizedBox(width: 6),
                        _buildHoverButton(
                          icon: Icons.swap_horiz,
                          color: theme.isDarkMode
                              ? WebDarkColors.textSecondary
                              : WebColors.textSecondary,
                          borderColor: theme.isDarkMode
                              ? WebDarkColors.inputBorder
                              : WebColors.inputBorder,
                          borderRadius: 5.0,
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
          ),
        ),
      ),
    );
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
          case 1: // Instrument (new order: Instrument is now column 1)
            comparison = '${a.symbol ?? ''} ${a.exch ?? ''}'
                .compareTo('${b.symbol ?? ''} ${b.exch ?? ''}');
            break;
          case 2: // Product (new order: Product is now column 2)
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
          case 7: // MTM (new order: MTM is now column 7)
            comparison = (double.tryParse(a.mTm ?? '0') ?? 0)
                .compareTo(double.tryParse(b.mTm ?? '0') ?? 0);
            break;
          case 8: // Avg Price (new order: Avg Price is now column 8)
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

    return positions;
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

  Color _getQtyColor(String qty, ThemesProvider theme) {
    final numQty = int.tryParse(qty) ?? 0;
    if (numQty > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numQty < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
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
          ? WebDarkColors.textSecondary.withOpacity(0.6)
          : WebColors.textSecondary.withOpacity(0.6);
    }
    return theme.isDarkMode
        ? WebDarkColors.textPrimary
        : WebColors.textPrimary;
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
         backgroundColor: WebColors.surface,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),),
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
                      style: WebTextStyles.buttonXs(
                        isDarkTheme: theme.isDarkMode,
                        color: color,
                        fontWeight: WebFonts.medium,
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

  Future<void> _handleExitPosition(BuildContext context, PositionBookModel position) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      
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
      showResponsiveWarningMessage(context, "Error exiting position: ${e.toString()}");
    }
  }

  Future<void> _handleAddPosition(BuildContext context, PositionBookModel position) async {
    try {
      final scripData = ref.read(marketWatchProvider);
      
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
      showResponsiveWarningMessage(context, "Error adding position: ${e.toString()}");
    }
  }

  void _handleConvertPosition(BuildContext context, PositionBookModel position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConvertPositionDialogueWeb(convertPosition: position);
      },
    );
  }
}
