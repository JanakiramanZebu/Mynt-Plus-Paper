import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'mf_holding_detail_screen_web.dart';

class MfHoldingsScreenWeb extends ConsumerStatefulWidget {
  final bool showSummaryCards;
  
  const MfHoldingsScreenWeb({
    super.key,
    this.showSummaryCards = true,
  });

  @override
  ConsumerState<MfHoldingsScreenWeb> createState() => _MfHoldingsScreenWebState();
}

class _MfHoldingsScreenWebState extends ConsumerState<MfHoldingsScreenWeb> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Fetch mutual fund holdings data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).fetchmfholdingnew();
    });
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
          // Action Bar
          _buildActionBar(theme, mfData),

          // Table
          _buildHoldingsTable(theme, mfData),
        ],
      ),
    );
  }

  Widget _buildActionBar(ThemesProvider theme, MFProvider mfData) {
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
                  hintText: 'Search mutual funds',
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
          // Refresh Button
          IconButton(
            onPressed: () async {
              await mfData.fetchmfholdingnew();
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

  Widget _buildHoldingsTable(ThemesProvider theme, MFProvider mfData) {
    final filteredHoldings = _getFilteredHoldings(mfData);

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
              label: _buildSortableColumnHeader('Fund Name', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Units', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Avg NAV', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Current NAV', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Invested', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Current Value', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('P&L', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('P&L %', theme),
              onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
            ),
          ],
          rows: filteredHoldings.map((holding) {
            return DataRow(
              onSelectChanged: (bool? selected) {
                _showHoldingDetail(holding);
              },
              cells: [
                DataCell(
                  Text(
                    holding.name ?? 'N/A',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    holding.avgQty ?? '0',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    holding.avgNav ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    holding.curNav ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    holding.investedValue ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
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
                ),
                DataCell(
                  Text(
                    holding.profitLoss ?? '0.00',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getValueColor(holding.profitLoss ?? '0.00', theme),
                      theme: false,
                      fw: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${holding.changeprofitLoss ?? '0.00'}%',
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: _getValueColor(holding.changeprofitLoss ?? '0.00', theme),
                      theme: false,
                      fw: 2,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
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
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (numValue < 0) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    }
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


  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}
