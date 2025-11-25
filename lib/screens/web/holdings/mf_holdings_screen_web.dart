import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'mf_holding_detail_screen_web.dart';
import '../ordersbook/mf/redeem_bottom_sheet_web.dart';

class MfHoldingsScreenWeb extends ConsumerStatefulWidget {
  final bool showSummaryCards;
  final String? searchQuery;
  
  const MfHoldingsScreenWeb({
    super.key,
    this.showSummaryCards = true,
    this.searchQuery,
  });

  @override
  ConsumerState<MfHoldingsScreenWeb> createState() => _MfHoldingsScreenWebState();
}

class _MfHoldingsScreenWebState extends ConsumerState<MfHoldingsScreenWeb> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  String? _hoveredRowToken; // Track which row is being hovered

  @override
  void initState() {
    super.initState();
    // Use search query from parent if provided
    if (widget.searchQuery != null) {
      _searchQuery = widget.searchQuery!;
    }
    // Fetch mutual fund holdings data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).fetchmfholdingnew();
    });
  }

  @override
  void didUpdateWidget(MfHoldingsScreenWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update search query when parent changes it
    if (widget.searchQuery != oldWidget.searchQuery) {
      setState(() {
        _searchQuery = widget.searchQuery ?? '';
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mfData = ref.watch(mfProvider);
    final theme = ref.read(themeProvider);

    if (mfData.holdstatload ?? false) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async {
          await mfData.fetchmfholdingnew();
        },
        child: widget.showSummaryCards
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary Cards Section
                    _buildSummaryCards(theme, mfData),
                    const SizedBox(height: 24),
                    // Main Content Area - Expanded to fill remaining space
                    Expanded(
                      child: _buildMainContent(theme, mfData),
                    ),
                  ],
                ),
              )
            : SizedBox.expand(
                child: _buildMainContent(theme, mfData),
              ),
      ),
    );
  }


  Widget _buildSummaryCards(ThemesProvider theme, MFProvider mfData) {
    final summary = mfData.mfholdingnew?.summary;
    final investedValue = _formatValue(summary?.invested);
    final currentValue = _formatValue(summary?.currentValue);
    final absReturnValue = _formatValue(summary?.absReturnValue);
    final absReturnPercent = _formatValue(summary?.absReturnPercent?.toString());

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

  Widget _buildMainContent(ThemesProvider theme, MFProvider mfData) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar - only show when standalone (with summary cards)
          if (widget.showSummaryCards) _buildActionBar(theme, mfData),

          // Table - Expanded to fill remaining space
          Expanded(
            child: _buildHoldingsTable(theme, mfData),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(ThemesProvider theme, MFProvider mfData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
        ),
      ),
      child: const Row(
        children: [
          // Spacer to push search and refresh to the right
         
          SizedBox(width: 8),
        ],
      ),
    );
  }

  // Responsive breakpoints
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;

  // Helper method to get responsive column configuration
  Map<String, dynamic> _getResponsiveMfHoldingColumns(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: Show only essential columns
      return {
        'headers': ['Fund Name', 'Units', 'Current NAV', 'P&L', 'P&L %'],
        'columnFlex': {
          'Fund Name': 4,
          'Units': 2,
          'Current NAV': 2,
          'P&L': 2,
          'P&L %': 1,
        },
        'columnMinWidth': {
          'Fund Name': 220,
          'Units': 90,
          'Current NAV': 110,
          'P&L': 100,
          'P&L %': 90,
        },
      };
    } else if (screenWidth < _tabletBreakpoint) {
      // Tablet: Show most columns
      return {
        'headers': ['Fund Name', 'Units', 'Avg NAV', 'Current NAV', 'Current Value', 'P&L', 'P&L %'],
        'columnFlex': {
          'Fund Name': 4,
          'Units': 1,
          'Avg NAV': 2,
          'Current NAV': 2,
          'Current Value': 2,
          'P&L': 2,
          'P&L %': 1,
        },
        'columnMinWidth': {
          'Fund Name': 220,
          'Units': 85,
          'Avg NAV': 95,
          'Current NAV': 110,
          'Current Value': 115,
          'P&L': 100,
          'P&L %': 90,
        },
      };
    } else {
      // Desktop: Full columns with optimal widths
      return {
        'headers': ['Fund Name', 'Units', 'Avg NAV', 'Current NAV', 'Invested', 'Current Value', 'P&L', 'P&L %'],
        'columnFlex': {
          'Fund Name': 4,
          'Units': 1,
          'Avg NAV': 2,
          'Current NAV': 2,
          'Invested': 2,
          'Current Value': 2,
          'P&L': 2,
          'P&L %': 1,
        },
        'columnMinWidth': {
          'Fund Name': 250,
          'Units': 90,
          'Avg NAV': 100,
          'Current NAV': 115,
          'Invested': 105,
          'Current Value': 120,
          'P&L': 100,
          'P&L %': 95,
        },
      };
    }
  }

  Widget _buildHoldingsTable(ThemesProvider theme, MFProvider mfData) {
    final filteredHoldings = _getFilteredHoldings(mfData);

    if (filteredHoldings.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = widget.showSummaryCards ? 32.0 : 0.0; // Top and bottom padding
        final headerHeight = widget.showSummaryCards ? 120.0 : 0.0; // Summary cards height
        final actionBarHeight = widget.showSummaryCards ? 60.0 : 0.0; // Action bar height
        final spacing = widget.showSummaryCards ? 24.0 : 0.0; // Spacing between sections
        final bottomMargin = 20.0; // Bottom margin
        final tableHeight =
            screenHeight - padding - headerHeight - actionBarHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveMfHoldingColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnFlex = Map<String, int>.from(responsiveConfig['columnFlex'] as Map);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
        // Calculate total minimum width
        final totalMinWidth =
            columnMinWidth.values.fold<double>(0.0, (a, b) => a + b);
        // Determine whether horizontal scroll is needed
        final needHorizontalScroll = constraints.maxWidth < totalMinWidth;

        // Build the Column (header + body)
        final tableColumn = Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Sticky header (fixed) ---
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                      width: 1,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              child: needHorizontalScroll
                  ? IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: headers.map((label) {
                          final flex = columnFlex[label] ?? 1;
                          final minW = columnMinWidth[label] ?? 80.0;
                          final columnIndex = _getColumnIndexForHeader(label);

                          return _buildMfHoldingColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildMfHoldingHeaderWidget(
                              label, 
                              columnIndex, 
                              theme, 
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      children: headers.map((label) {
                        final flex = columnFlex[label] ?? 1;
                        final minW = columnMinWidth[label] ?? 80.0;
                        final columnIndex = _getColumnIndexForHeader(label);

                        return _buildMfHoldingColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildMfHoldingHeaderWidget(
                            label, 
                            columnIndex, 
                            theme, 
                          ),
                        );
                      }).toList(),
                    ),
            ),

              // --- Scrollable body (vertical) ---
              Expanded(
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  radius: Radius.zero,
                  child: _buildMfHoldingBodyList(
                    theme,
                    filteredHoldings,
                    headers,
                    columnFlex,
                    columnMinWidth,
                    totalMinWidth: totalMinWidth,
                    needHorizontalScroll: needHorizontalScroll,
                  ),
                ),
              ),
            ],
          ),
        );

        // If horizontal scroll needed, wrap the entire column inside SingleChildScrollView
        if (needHorizontalScroll) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
            child: SizedBox(
              width: constraints.maxWidth,
              height: calculatedHeight.toDouble(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: SizedBox(
                  width: totalMinWidth,
                  child: tableColumn,
                ),
              ),
            ),
          );
        }

        // else (no horizontal scroll)
        return Padding(
          padding: const EdgeInsets.only(right: 0.0, bottom: 20.0),
          child: SizedBox(
            width: constraints.maxWidth,
            height: calculatedHeight.toDouble(),
            child: tableColumn,
          ),
        );
      },
    );
  }

  int _getColumnIndexForHeader(String header) {
    switch (header) {
      case 'Fund Name': return 0;
      case 'Units': return 1;
      case 'Avg NAV': return 2;
      case 'Current NAV': return 3;
      case 'Invested': return 4;
      case 'Current Value': return 5;
      case 'P&L': return 6;
      case 'P&L %': return 7;
      default: return -1;
    }
  }

  Widget _buildMfHoldingHeaderWidget(
    String label,
    int columnIndex,
    ThemesProvider theme,
  ) {
    return InkWell(
      onTap: () => _onSortTable(columnIndex, !_sortAscending),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6),
              child: Text(
                label,
                style: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          // Sort icon
          if (_sortColumnIndex == columnIndex)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.iconPrimary
                    : WebColors.iconPrimary,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(
                Icons.unfold_more,
                size: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.iconSecondary
                    : WebColors.iconSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMfHoldingColumnCell({
    required bool needHorizontalScroll,
    required int flex,
    required double minW,
    required Widget child,
  }) {
    if (needHorizontalScroll) {
      return SizedBox(
        width: minW,
        child: child,
      );
    }

    return Expanded(
      flex: flex,
      child: SizedBox(
        width: minW,
        child: child,
      ),
    );
  }

  Widget _buildMfHoldingBodyList(
    ThemesProvider theme,
    List<dynamic> holdings,
    List<String> headers,
    Map<String, int> columnFlex,
    Map<String, double> columnMinWidth, {
    required double totalMinWidth,
    required bool needHorizontalScroll,
  }) {
    return ListView.builder(
      controller: _verticalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: holdings.length,
      itemBuilder: (context, index) {
        final holding = holdings[index];
        final holdingId = holding.name ?? '';
        final uniqueId = '$holdingId$index';
        final isHovered = _hoveredRowToken == uniqueId;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
          onExit: (_) => setState(() => _hoveredRowToken = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showHoldingDetail(holding),
            child: Container(
              decoration: BoxDecoration(
                color: isHovered
                    ? (theme.isDarkMode
                        ? WebDarkColors.primary.withOpacity(0.06)
                        : WebColors.primary.withOpacity(0.10))
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: needHorizontalScroll
                  ? IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: headers.map((label) {
                          final flex = columnFlex[label] ?? 1;
                          final minW = columnMinWidth[label] ?? 80.0;
                          return _buildMfHoldingColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildMfHoldingCellWidget(
                              label,
                              holding,
                              theme,
                              isHovered,
                              needHorizontalScroll: needHorizontalScroll,
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      children: headers.map((label) {
                        final flex = columnFlex[label] ?? 1;
                        final minW = columnMinWidth[label] ?? 80.0;
                        return _buildMfHoldingColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildMfHoldingCellWidget(
                            label,
                            holding,
                            theme,
                            isHovered,
                            needHorizontalScroll: needHorizontalScroll,
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMfHoldingCellWidget(
    String column,
    dynamic holding,
    ThemesProvider theme,
    bool isHovered, {
    required bool needHorizontalScroll,
  }) {
    switch (column) {
      case 'Fund Name':
        return _buildMfHoldingInstrumentWidget(
          holding,
          theme,
          isHovered,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Units':
        return _buildMfHoldingTextCell(
          holding.avgQty ?? '0',
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Avg NAV':
        return _buildMfHoldingTextCell(
          holding.avgNav ?? '0.00',
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Current NAV':
        return _buildMfHoldingTextCell(
          holding.curNav ?? '0.00',
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Invested':
        return _buildMfHoldingTextCell(
          holding.investedValue ?? '0.00',
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Current Value':
        return _buildMfHoldingTextCell(
          holding.currentValue ?? '0.00',
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'P&L':
        final pnl = holding.profitLoss ?? '0.00';
        return _buildMfHoldingTextCell(
          pnl,
          theme,
          Alignment.centerRight,
          color: _getValueColor(pnl, theme),
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'P&L %':
        final pnlPercent = holding.changeprofitLoss ?? '0.00';
        return _buildMfHoldingTextCell(
          '${pnlPercent}%',
          theme,
          Alignment.centerRight,
          color: _getValueColor(pnlPercent, theme),
          needHorizontalScroll: needHorizontalScroll,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMfHoldingInstrumentWidget(
    dynamic holding,
    ThemesProvider theme,
    bool isHovered, {
    required bool needHorizontalScroll,
  }) {
    final holdingName = holding.name ?? 'N/A';
    final avgQty = double.tryParse(holding.avgQty ?? '0') ?? 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: isHovered ? 1 : 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: holdingName,
              waitDuration: const Duration(milliseconds: 500),
              child: Text(
                holdingName,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
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
          ignoring: !isHovered,
          child: AnimatedOpacity(
            opacity: isHovered ? 1 : 0,
            duration: const Duration(milliseconds: 140),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Redeem button - only show if holding has units
                if (avgQty > 0) ...[
                  _buildHoverButton(
                    label: 'Redeem',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.error
                        : WebColors.error,
                    onPressed: () async {
                      await _handleRedeem(context, holding);
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
  }

  Widget _buildMfHoldingTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
    bool needHorizontalScroll = false,
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

  DataCell _buildInstrumentCellWithHover(dynamic holding, ThemesProvider theme, String token) {
    final holdingName = holding.name ?? 'N/A';
    final isHovered = _hoveredRowToken == token;
    final avgQty = double.tryParse(holding.avgQty ?? '0') ?? 0.0;

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
                    message: holdingName,
                    waitDuration: const Duration(milliseconds: 500),
                    child: Text(
                      holdingName,
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
                      // Redeem button - only show if holding has units
                      if (avgQty > 0) ...[
                        _buildHoverButton(
                          label: 'Redeem',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.error
                              : WebColors.error,
                          onPressed: () async {
                            await _handleRedeem(context, holding);
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

  DataCell _buildCellWithHover(dynamic holding, ThemesProvider theme, String token, DataCell cell, {Alignment alignment = Alignment.centerRight}) {
    // Wrap the cell's child with MouseRegion to detect hover anywhere on the row
    // Use SizedBox.expand to fill the entire cell area, not just the text content
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = token),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment, // Right align for numbers, left align for text
            child: cell.child,
          ),
        ),
      ),
    );
  }

  DataCell _buildUnitsCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.avgQty ?? '0',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildAvgNavCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.avgNav ?? '0.00',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildCurrentNavCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.curNav ?? '0.00',
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
        holding.investedValue ?? '0.00',
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

  DataCell _buildPnLCell(dynamic holding, ThemesProvider theme) {
    final pnl = holding.profitLoss ?? '0.00';
    return DataCell(
      Text(
        pnl,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(pnl, theme),
        ),
      ),
    );
  }

  DataCell _buildPnLPercentCell(dynamic holding, ThemesProvider theme) {
    final pnlPercent = holding.changeprofitLoss ?? '0.00';
    return DataCell(
      Text(
        '${pnlPercent}%',
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(pnlPercent, theme),
        ),
      ),
    );
  }

  List<dynamic> _getFilteredHoldings(MFProvider mfData) {
    List<dynamic> holdings = mfData.mfholdingnew?.data ?? [];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      holdings = holdings.where((holding) {
        final name = holding.name?.toLowerCase() ?? '';
        final searchLower = _searchQuery.toLowerCase();
        return name.contains(searchLower);
      }).toList();
    }

    // Apply sorting
    if (_sortColumnIndex != null) {
      holdings.sort((a, b) {
        int comparison = 0;
        
        switch (_sortColumnIndex) {
          case 0: // Fund Name
            comparison = (a.name ?? '').compareTo(b.name ?? '');
            break;
          case 1: // Units
            final aQty = double.tryParse(a.avgQty ?? '0') ?? 0;
            final bQty = double.tryParse(b.avgQty ?? '0') ?? 0;
            comparison = aQty.compareTo(bQty);
            break;
          case 2: // Avg NAV
            final aNav = double.tryParse(a.avgNav ?? '0') ?? 0;
            final bNav = double.tryParse(b.avgNav ?? '0') ?? 0;
            comparison = aNav.compareTo(bNav);
            break;
          case 3: // Current NAV
            final aCurNav = double.tryParse(a.curNav ?? '0') ?? 0;
            final bCurNav = double.tryParse(b.curNav ?? '0') ?? 0;
            comparison = aCurNav.compareTo(bCurNav);
            break;
          case 4: // Invested
            final aInvested = double.tryParse(a.investedValue ?? '0') ?? 0;
            final bInvested = double.tryParse(b.investedValue ?? '0') ?? 0;
            comparison = aInvested.compareTo(bInvested);
            break;
          case 5: // Current Value
            final aValue = double.tryParse(a.currentValue ?? '0') ?? 0;
            final bValue = double.tryParse(b.currentValue ?? '0') ?? 0;
            comparison = aValue.compareTo(bValue);
            break;
          case 6: // P&L
            final aPnL = double.tryParse(a.profitLoss ?? '0') ?? 0;
            final bPnL = double.tryParse(b.profitLoss ?? '0') ?? 0;
            comparison = aPnL.compareTo(bPnL);
            break;
          case 7: // P&L %
            final aPnLPercent = double.tryParse(a.changeprofitLoss ?? '0') ?? 0;
            final bPnLPercent = double.tryParse(b.changeprofitLoss ?? '0') ?? 0;
            comparison = aPnLPercent.compareTo(bPnLPercent);
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

  Color _getStatValueColor(String value, ThemesProvider theme) {
    // Extract numeric value from string (remove any text like percentages)
    final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
    final numValue = double.tryParse(cleanValue) ?? 0.0;

    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success; // Green
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error; // Red
    } else {
      return theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary; // Grey
    }
  }

  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }

  void _showHoldingDetail(dynamic holding) {
     showDialog(
      context: context,
      builder: (context) => MfHoldingDetailScreenWeb(
        holding: holding,
      ),
    );
  }

  Future<void> _handleRedeem(BuildContext context, dynamic holding) async {
    final mfData = ref.read(mfProvider);
    // Set the holding data for redemption using the ISIN
    mfData.fetchmfholdsingpage(holding.iSIN ?? '');
    // Call the redeem evaluation function
    mfData.recdemevalu();
    // Show web redeem dialog
    showDialog(
      context: context,
      builder: (context) => const RedemptionBottomSheetWeb(),
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
                        fontWeight: WebFonts.medium,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}
