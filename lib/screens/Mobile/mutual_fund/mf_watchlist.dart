// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
// import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/mynt_loader.dart';
import '../../../utils/responsive_snackbar.dart';
import '../../../sharedWidget/no_data_found.dart';
import 'mf_order_screen.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import 'mf_search_popup.dart';

class MFWatchlistScreen extends ConsumerStatefulWidget {
  final Function(MutualFundList mfData)? onFundTap;

  const MFWatchlistScreen({super.key, this.onFundTap});

  @override
  ConsumerState<MFWatchlistScreen> createState() => _MFWatchlistScreenState();
}

class _MFWatchlistScreenState extends ConsumerState<MFWatchlistScreen> {
  TextEditingController searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  String searchQuery = "";

  // Sorting state
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch watchlist data on first load
      ref.read(mfProvider).fetchMFWatchlist("", "", context, true, "");
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _hoveredRowIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    // Get watchlist data
    final watchlist = mfData.mfWatchlist?.toList() ?? [];

    // Filter list based on search query
    final filteredList = watchlist.where((item) {
      final name =
          (item.mfsearchnamename ?? item.schemeName ?? '').toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    // Sort list
    if (_sortColumnIndex != null) {
      filteredList.sort((a, b) {
        int compareResult = 0;
        switch (_sortColumnIndex) {
          case 0: // Name
            compareResult =
                (a.mfsearchnamename ?? '').compareTo(b.mfsearchnamename ?? '');
            break;
          case 1: // AUM (Assuming field name aUM matches model)
            compareResult = (double.tryParse(a.aUM ?? '0') ?? 0)
                .compareTo(double.tryParse(b.aUM ?? '0') ?? 0);
            break;
          case 2: // 1Y
            compareResult = (double.tryParse(a.oneYearData ?? '0') ?? 0)
                .compareTo(double.tryParse(b.oneYearData ?? '0') ?? 0);
            break;
          case 3: // 3Y
            compareResult = (double.tryParse(a.tHREEYEARDATA ?? '0') ?? 0)
                .compareTo(double.tryParse(b.tHREEYEARDATA ?? '0') ?? 0);
            break;
          case 4: // Min Invest
            compareResult =
                (double.tryParse(a.minimumPurchaseAmount ?? '0') ?? 0)
                    .compareTo(
                        double.tryParse(b.minimumPurchaseAmount ?? '0') ?? 0);
            break;
        }
        return _sortAscending ? compareResult : -compareResult;
      });
    }

    return MyntLoaderOverlay(
      isLoading: mfData.bestmfloader ?? false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(theme),
          Expanded(
            child:
                _buildTableWithHeader(filteredList, theme, mfData, searchQuery),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemesProvider theme) {
    return Container(
      width: double.infinity,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? MyntColors.searchBgDark : MyntColors.searchBg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const MFSearchPopup(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 21,
                color: theme.isDarkMode
                    ? MyntColors.textSecondaryDark
                    : MyntColors.textSecondary,
              ),
              const SizedBox(
                  width: 8), // Common search field usually has 8-12 gap
              Text(
                "Search & Add",
                style: MyntWebTextStyles.placeholder(
                  context,
                  color: theme.isDarkMode
                      ? MyntColors.textSecondaryDark
                      : MyntColors.textSecondary,
                  fontWeight: MyntFonts.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableWithHeader(List<dynamic> data, ThemesProvider theme,
      MFProvider mf, String searchQuery) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: shadcn.OutlinedContainer(
        child: LayoutBuilder(builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          final double fundNameWidth = totalWidth * 0.40;
          final double otherColumnWidth = totalWidth * 0.15;

          return Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: false, // matches mf_all_best_funds
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: totalWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed Header Table
                    shadcn.Table(
                      defaultRowHeight: const shadcn.FixedTableSize(50),
                      columnWidths: {
                        0: shadcn.FixedTableSize(fundNameWidth),
                        1: shadcn.FixedTableSize(otherColumnWidth), // AUM
                        2: shadcn.FixedTableSize(otherColumnWidth), // 1Y
                        3: shadcn.FixedTableSize(otherColumnWidth), // 3Y
                        4: shadcn.FixedTableSize(
                            otherColumnWidth), // Min Invest
                      },
                      rows: [
                        shadcn.TableHeader(
                          cells: [
                            buildHeaderCell('Fund name', 0),
                            buildHeaderCell('AUM', 1, true),
                            buildHeaderCell('1yr CAGR', 2, true),
                            buildHeaderCell('3yr CAGR', 3, true),
                            buildHeaderCell('Min. Invest', 4, true),
                          ],
                        ),
                      ],
                    ),
                    // Scrollable Body Table
                    if (data.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          child: shadcn.Table(
                            defaultRowHeight:
                                const shadcn.FixedTableSize(60), // Data height
                            columnWidths: {
                              0: shadcn.FixedTableSize(fundNameWidth),
                              1: shadcn.FixedTableSize(otherColumnWidth), // AUM
                              2: shadcn.FixedTableSize(otherColumnWidth), // 1Y
                              3: shadcn.FixedTableSize(otherColumnWidth), // 3Y
                              4: shadcn.FixedTableSize(
                                  otherColumnWidth), // Min Invest
                            },
                            rows: [
                              ...data.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;

                                return shadcn.TableRow(
                                  cells: [
                                    // Fund Name
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 0,
                                      onTap: () => _openFundDetails(item, mf),
                                      child:
                                          _buildFundNameCell(item, index, mf),
                                    ),
                                    // AUM
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 1,
                                      alignRight: true,
                                      onTap: () => _openFundDetails(item, mf),
                                      child: Text(
                                        _formatAUM(item.aUM),
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                    // 1yr
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 2,
                                      alignRight: true,
                                      onTap: () => _openFundDetails(item, mf),
                                      child: Text(
                                        _formatReturns(item.oneYearData),
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                    // 3yr
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 3,
                                      alignRight: true,
                                      onTap: () => _openFundDetails(item, mf),
                                      child: Text(
                                        _formatReturns(item.tHREEYEARDATA),
                                        style: _getTextStyle(context,
                                            color: _getReturnColor(
                                                context, item.tHREEYEARDATA)),
                                      ),
                                    ),
                                    // Min Invest
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 4,
                                      alignRight: true,
                                      onTap: () => _openFundDetails(item, mf),
                                      child: Text(
                                        '₹${item.minimumPurchaseAmount ?? '500.00'}',
                                        style: _getTextStyle(context),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    if (data.isEmpty)
                      Expanded(
                        child: Center(
                          child: NoDataFound(
                            title: "No Funds Found",
                            subtitle: searchQuery.isNotEmpty
                                ? "No funds match your search"
                                : "Add your favorite funds to your watchlist",
                            primaryEnabled: false,
                            secondaryEnabled: false,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTable(List<dynamic> data, ThemesProvider theme, MFProvider mf) {
    return LayoutBuilder(builder: (context, constraints) {
      final double totalWidth = constraints.maxWidth - 32;
      final double fundNameWidth = totalWidth * 0.40;
      final double otherColumnWidth = totalWidth * 0.15;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 32),
              child: shadcn.Table(
                defaultRowHeight: const shadcn.FixedTableSize(50),
                columnWidths: {
                  0: shadcn.FixedTableSize(fundNameWidth),
                  1: shadcn.FixedTableSize(otherColumnWidth), // AUM
                  2: shadcn.FixedTableSize(otherColumnWidth), // 1Y
                  3: shadcn.FixedTableSize(otherColumnWidth), // 3Y
                  4: shadcn.FixedTableSize(otherColumnWidth), // Min Invest
                },
                rows: [
                  shadcn.TableHeader(
                    cells: [
                      buildHeaderCell('Fund name', 0),
                      buildHeaderCell('AUM', 1, true),
                      buildHeaderCell('1yr CAGR', 2, true),
                      buildHeaderCell('3yr CAGR', 3, true),
                      buildHeaderCell('Min. Invest', 4, true),
                    ],
                  ),
                  ...data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return shadcn.TableRow(
                      cells: [
                        // Fund Name
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 0,
                          onTap: () => _openFundDetails(item, mf),
                          child: _buildFundNameCell(item, index, mf),
                        ),
                        // AUM
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 1,
                          alignRight: true,
                          onTap: () => _openFundDetails(item, mf),
                          child: Text(
                            _formatAUM(item.aUM),
                            style: _getTextStyle(context),
                          ),
                        ),
                        // 1yr
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 2,
                          alignRight: true,
                          onTap: () => _openFundDetails(item, mf),
                          child: Text(
                            _formatReturns(item.oneYearData),
                            style: _getTextStyle(context),
                          ),
                        ),
                        // 3yr
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 3,
                          alignRight: true,
                          onTap: () => _openFundDetails(item, mf),
                          child: Text(
                            _formatReturns(item.tHREEYEARDATA),
                            style: _getTextStyle(context,
                                color: _getReturnColor(
                                    context, item.tHREEYEARDATA)),
                          ),
                        ),
                        // Min Invest
                        buildCellWithHover(
                          rowIndex: index,
                          columnIndex: 4,
                          alignRight: true,
                          onTap: () => _openFundDetails(item, mf),
                          child: Text(
                            '₹${item.minimumPurchaseAmount ?? '500.00'}',
                            style: _getTextStyle(context),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFundNameCell(dynamic item, int index, MFProvider mf) {
    final amcCode = item.aMCCode ?? "default";

    return ValueListenableBuilder<int?>(
      valueListenable: _hoveredRowIndex,
      builder: (context, hoveredIndex, _) {
        final isHovered = hoveredIndex == index;
        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      item.mfsearchnamename ?? item.schemeName ?? '--',
                      style: _getTextStyle(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  Row(
                    children: [
                      _buildTag(item.type ?? 'Equity'),
                      // _buildTag(item.schemeType ?? ''),
                    ],
                  ),
                ],
              ),
            ),
            if (isHovered) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                      dark: MyntColors.searchBgDark,
                      light: MyntColors.backgroundColor),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: MyntShadows.card,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton('One-time', const Color(0xff0037B7),
                        () => _handleOrder(item, 'One-time', mf),
                        filled: true),
                    const SizedBox(width: 6),
                    _buildActionButton('SIP', const Color(0xff0037B7),
                        () => _handleOrder(item, 'SIP', mf),
                        filled: true),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () async {
                        final isin = item.iSIN;
                        if (isin != null) {
                          await mf.fetchMFWatchlist(
                            isin,
                            "delete",
                            context,
                            true,
                            "watch",
                          );
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: resolveThemeColor(context,
                                  dark: Colors.grey.withOpacity(0.2),
                                  light: Colors.grey.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(4)),
                          child: Icon(Icons.close,
                              size: 16,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary))),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTag(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical:
              2), // Remove horizontal padding if bg is gone? kept minimal.
      decoration: BoxDecoration(
        // color: Colors.transparent, // Background removed
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: MyntWebTextStyles.para(context,
            darkColor: MyntColors.textSecondaryDark,
            lightColor: MyntColors.textSecondary),
      ),
    );
  }

  // ... (Helper methods copy-pasted/adapted from mf_all_best_funds.dart)
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    VoidCallback? onTap,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 4;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 4, 8);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(4, 8, 16, 8);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    }

    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: ValueListenableBuilder<int?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredIndex, _) {
            final isRowHovered = hoveredIndex == rowIndex;
            return GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: cellPadding,
                color: isRowHovered
                    ? resolveThemeColor(context,
                        dark: MyntColors.primary.withValues(alpha: 0.08),
                        light: MyntColors.primary.withValues(alpha: 0.08))
                    : null,
                alignment: alignRight ? Alignment.topRight : null,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }

  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 4;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 6, 8, 6);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 6, 16, 6);
    } else {
      headerPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6);
    }

    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _onSort(columnIndex),
        child: Container(
          padding: headerPadding,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              Text(
                label,
                style: _getHeaderStyle(context),
              ),
              if (!alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  TextStyle _getTextStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? MyntColors.textSecondaryDark,
      lightColor: color ?? MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  String _formatReturns(String? returns) {
    if (returns == null || returns.isEmpty || returns == "0.0") {
      return "0.00%";
    }
    return "$returns%";
  }

  String _formatAUM(String? aum) {
    if (aum == null || aum.isEmpty) return "--";
    try {
      double value = double.tryParse(aum) ?? 0;
      return value.toStringAsFixed(2);
    } catch (e) {
      return aum;
    }
  }

  Color _getReturnColor(BuildContext context, String? returns) {
    if (returns == null || returns.isEmpty) {
      return Colors.grey;
    }
    try {
      final value = double.parse(returns);
      if (value > 0) {
        return resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);
      }
      if (value < 0) {
        return resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap,
      {bool filled = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          border: filled ? null : Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleOrder(
      dynamic item, String orderType, MFProvider mf) async {
    // Show loader while fetching dependencies
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: MyntLoader(size: MyntLoaderSize.large)),
    );

    try {
      // Fetch bank details
      await ref.read(transcationProvider).fetchfundbank(context);

      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loader

      final isin = item.iSIN;
      final schemeCode = item.schemeCode;

      // Set up SIP if applicable
      if (item.sIPFLAG == "Y" && isin != null && schemeCode != null) {
        mf.invertfun(isin, schemeCode, context);
      }

      // Pre-fill amount based on order type
      if (orderType == "One-time") {
        String amt = item.minimumPurchaseAmount ?? "0";
        mf.invAmt.text = amt.split('.').first;
      } else {
        String amt = item.minimumPurchaseAmount ?? "0";
        mf.installmentAmt.text = amt.split('.').first;
      }

      // Convert item to MutualFundList
      Map<String, dynamic> jsonData = item.toJson();
      // Ensure fSchemeName is set from name if not present
      if (jsonData['f_scheme_name'] == null &&
          (jsonData['name'] != null || jsonData['mfsearchnamename'] != null)) {
        jsonData['f_scheme_name'] =
            jsonData['name'] ?? jsonData['mfsearchnamename'];
      }
      MutualFundList mfItem = MutualFundList.fromJson(jsonData);

      if (context.mounted) {
        mf.chngOrderType(orderType);
        mf.orderchangetitle(orderType);

        // Get screen dimensions
        final screenSize = MediaQuery.of(context).size;
        final dialogWidth = screenSize.width * 0.25; // 25% width
        final dialogHeight = screenSize.height * 0.60; // 60% height

        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MFOrderScreen(mfData: mfItem),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loader if still showing
        ResponsiveSnackBar.show(
            context: context,
            message: "Error: ${e.toString()}",
            type: SnackBarType.error);
      }
    }
  }

  void _openFundDetails(dynamic item, MFProvider mf) async {
    try {
      final isin = item.iSIN;
      if (isin != null) {
        mf.loaderfun();
        await mf.fetchFactSheet(isin);
        mf.fetchmatchisan(isin);

        // Navigate to full page instead of side sheet
        if (mf.factSheetDataModel?.stat != "Not Ok") {
          Map<String, dynamic> jsonData = item.toJson();
          if (jsonData['f_scheme_name'] == null &&
              (jsonData['name'] != null ||
                  jsonData['mfsearchnamename'] != null)) {
            jsonData['f_scheme_name'] =
                jsonData['name'] ?? jsonData['mfsearchnamename'];
          }
          MutualFundList bInstance = MutualFundList.fromJson(jsonData);

          // Use callback if provided (web panel navigation), otherwise use full page navigation
          if (widget.onFundTap != null) {
            widget.onFundTap!(bInstance);
          } else {
            // Navigate to full page using root navigator
            Navigator.of(context, rootNavigator: true).pushNamed(
              Routes.mfStockDetail,
              arguments: bInstance,
            );
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }
}
