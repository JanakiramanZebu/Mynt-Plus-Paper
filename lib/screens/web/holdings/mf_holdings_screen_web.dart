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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards Section (only if showSummaryCards is true)
                if (widget.showSummaryCards) ...[
                  _buildSummaryCards(theme, mfData),
                  const SizedBox(height: 24),
                ],

                // Main Content Area
                _buildMainContent(theme, mfData),
              ],
            ),
          ),
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
        children: [
          // Action Bar - only show when standalone (with summary cards)
          if (widget.showSummaryCards) _buildActionBar(theme, mfData),

          // Table
          _buildHoldingsTable(theme, mfData),
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

  Widget _buildHoldingsTable(ThemesProvider theme, MFProvider mfData) {
    final filteredHoldings = _getFilteredHoldings(mfData);

    if (filteredHoldings.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: DataTable(
              columnSpacing: 10,
              showCheckboxColumn: false,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              horizontalMargin: 12,
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
                  label: _buildSortableColumnHeader('Fund Name', theme, 0),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildSortableColumnHeader('Units', theme, 1),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildSortableColumnHeader('Avg NAV', theme, 2),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildSortableColumnHeader('Current NAV', theme, 3),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildSortableColumnHeader('Invested', theme, 4),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildSortableColumnHeader('Current Value', theme, 5),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildSortableColumnHeader('P&L', theme, 6),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildSortableColumnHeader('P&L %', theme, 7),
                  onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                ),
              ],
              rows: filteredHoldings.map((holding) {
                final holdingId = holding.name ?? '';
                final token = holdingId;
                
                return DataRow(
                  onSelectChanged: (bool? selected) {
                    _showHoldingDetail(holding);
                  },
                  cells: [
                    _buildInstrumentCellWithHover(holding, theme, token),
                    _buildCellWithHover(holding, theme, token, _buildUnitsCell(holding, theme)),
                    _buildCellWithHover(holding, theme, token, _buildAvgNavCell(holding, theme)),
                    _buildCellWithHover(holding, theme, token, _buildCurrentNavCell(holding, theme)),
                    _buildCellWithHover(holding, theme, token, _buildInvestedCell(holding, theme)),
                    _buildCellWithHover(holding, theme, token, _buildCurrentValueCell(holding, theme)),
                    _buildCellWithHover(holding, theme, token, _buildPnLCell(holding, theme)),
                    _buildCellWithHover(holding, theme, token, _buildPnLPercentCell(holding, theme)),
                  ],
                );
              }).toList(),
            ),
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
                      style: WebTextStyles.custom(
                        fontSize: 13,
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: WebFonts.medium,
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

  DataCell _buildAvgNavCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.avgNav ?? '0.00',
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

  DataCell _buildCurrentNavCell(dynamic holding, ThemesProvider theme) {
    return DataCell(
      Text(
        holding.curNav ?? '0.00',
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
        holding.investedValue ?? '0.00',
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

  DataCell _buildPnLCell(dynamic holding, ThemesProvider theme) {
    final pnl = holding.profitLoss ?? '0.00';
    return DataCell(
      Text(
        pnl,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(pnl, theme),
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildPnLPercentCell(dynamic holding, ThemesProvider theme) {
    final pnlPercent = holding.changeprofitLoss ?? '0.00';
    return DataCell(
      Text(
        '${pnlPercent}%',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: _getValueColor(pnlPercent, theme),
          fontWeight: WebFonts.medium,
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

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}
