import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/common_buttons_web.dart';
import 'package:mynt_plus/sharedWidget/common_search_fields_web.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import 'basket_invest_dialog.dart';
import 'benchmark_backtest_web.dart';

class StrategyBuilderScreenV2 extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StrategyBuilderScreenV2({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<StrategyBuilderScreenV2> createState() =>
      _StrategyBuilderScreenV2State();
}

class _StrategyBuilderScreenV2State
    extends ConsumerState<StrategyBuilderScreenV2> {
  // Track which categories are expanded
  final Map<String, bool> _expandedCategories = {};
  final Map<String, FocusNode> _weightFocusNodes = {};
  late ScrollController _tableScrollController;
  bool _isBacktestLoading = false;
  bool _isInvestLoading = false;
  final GlobalKey _weightSchemeKey = GlobalKey();
  OverlayEntry? _weightSchemeOverlay;

  @override
  void initState() {
    super.initState();
    _tableScrollController = ScrollController();
    // Basketsearch is called lazily when user opens the search dialog
  }


  @override
  void dispose() {
    _tableScrollController.dispose();
    _removeWeightSchemeOverlay();
    for (final node in _weightFocusNodes.values) {
      node.dispose();
    }
    _weightFocusNodes.clear();
    super.dispose();
  }

  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
          backgroundColor: resolveThemeColor(context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor),
          body: Row(
            children: [
              // LEFT PANEL - Strategy Builder
              Expanded(
                flex: 1,
                child: _buildLeftPanel(strategy),
              ),
              // Divider + RIGHT PANEL — only when backtest results or loading
              if (strategy.analysisData != null || _isBacktestLoading) ...[
                Container(
                  width: 1,
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark,
                      light: MyntColors.divider),
                ),
                Expanded(
                  flex: 1,
                  child: _buildRightPanel(strategy),
                ),
              ],
            ],
          ),
      ),
    );
  }

  // ─── LEFT PANEL ───────────────────────────────────────────────────────

  Widget _buildLeftPanel(DashboardProvider strategy) {
    return Column(
      children: [
        // Header with search + action buttons
        _buildLeftHeader(strategy),
        // Content area - always show selected funds
        Expanded(
          child: strategy.selectedFunds.isEmpty
              ? Center(
                  child: NoDataFoundWeb(
                    title: 'No Funds',
                    subtitle: 'Search and add funds to build your strategy',
                    primaryEnabled: false,
                    secondaryEnabled: false,
                  ),
                )
              : _buildSelectedFundsTable(strategy),
        ),
      ],
    );
  }

  Widget _buildLeftHeader(DashboardProvider strategy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark,
                light: MyntColors.divider),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final isSplit = availableWidth < 800;

          // Row 1: Back arrow + Strategy name + (if not split: search + actions)
          final row1 = Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _handleBackNavigation(),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strategy.isEditingMode
                      ? strategy.strategyNameController.text
                      : strategy.pendingStrategyName.isNotEmpty
                          ? strategy.pendingStrategyName
                          : "New Strategy",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: MyntWebTextStyles.title(context,
                      fontWeight: MyntFonts.semiBold,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary),
                ),
              ),
              if (!isSplit) ...[
                const SizedBox(width: 12),
                if (availableWidth >= 900)
                  SizedBox(
                    width: availableWidth >= 1100 ? 350 : 250,
                    child: GestureDetector(
                      onTap: () => _showFundSearchDialog(),
                      child: AbsorbPointer(
                        child: MyntSearchTextField.withSmartClear(
                          controller: TextEditingController(),
                          placeholder: 'Search funds',
                          leadingIcon: assets.searchIcon,
                          enabled: false,
                        ),
                      ),
                    ),
                  )
                else
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showFundSearchDialog(),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ..._buildActionButtons(strategy),
              ],
            ],
          );

          if (!isSplit) return row1;

          // Row 2 (split only): Search + actions
          final row2 = Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showFundSearchDialog(),
                  child: AbsorbPointer(
                    child: MyntSearchTextField.withSmartClear(
                      controller: TextEditingController(),
                      placeholder: 'Search funds...',
                      leadingIcon: assets.searchIcon,
                      enabled: false,
                    ),
                  ),
                ),
              ),
              ..._buildActionButtons(strategy),
            ],
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row1,
              const SizedBox(height: 8),
              row2,
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildActionButtons(DashboardProvider strategy) {
    return [
      // Weighting Scheme dropdown
      if (strategy.selectedFunds.isNotEmpty) ...[
        const SizedBox(width: 8),
        _buildWeightSchemeDropdown(),
      ],
      if (!strategy.isEditingMode && strategy.selectedFunds.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: strategy.isStrategyValid
                  ? () => _showSaveStrategyDialog()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: resolveThemeColor(context,
                    dark: MyntColors.secondary,
                    light: MyntColors.primary),
                foregroundColor: Colors.white,
                disabledBackgroundColor: resolveThemeColor(context,
                    dark: MyntColors.secondary.withValues(alpha: 0.4),
                    light: MyntColors.primary.withValues(alpha: 0.4)),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save',
                style: MyntWebTextStyles.body(context,
                    fontWeight: MyntFonts.semiBold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      // Analyse button
      if (strategy.selectedFunds.isNotEmpty) ...[
        const SizedBox(width: 8),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              if (strategy.isStrategyValid) {
                strategy.stratergySavebackbutton(false);
                _handleAnalyseAction(context, popDialog: false);
              } else {
                error(context,
                    strategy.getStrategyValidationError() ??
                        'Please fix validation errors before proceeding');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: resolveThemeColor(context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary),
              overlayColor: resolveThemeColor(context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: resolveThemeColor(context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary),
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              'Backtest',
              style: MyntWebTextStyles.body(context,
                  fontWeight: MyntFonts.semiBold,
                  color: resolveThemeColor(context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary)),
            ),
          ),
        ),
      ],
      // Settings icon — investment preferences
     
      // Invest button
      if (strategy.selectedFunds.isNotEmpty && strategy.isEditingMode) ...[
        const SizedBox(width: 8),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: _isInvestLoading ? null : () async {
              if (strategy.isStrategyValid) {
                setState(() => _isInvestLoading = true);
                try {
                  if (strategy.hasStrategyChanged) {
                    await ref.read(dashboardProvider).updateStrategy(context);
                  }
                } finally {
                  if (mounted) setState(() => _isInvestLoading = false);
                }
                if (mounted) showBasketInvestDialog(context);
              } else {
                error(context,
                    strategy.getStrategyValidationError() ??
                        'Please fix validation errors before proceeding');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: resolveThemeColor(context,
                  dark: MyntColors.secondary,
                  light: MyntColors.primary),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: _isInvestLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Builder(builder: (_) {
                    double minTotal = 0;
                    for (final fund in strategy.selectedFunds) {
                      if (fund.percentage > 0) {
                        final needed = fund.minimumPurchaseAmount / (fund.percentage / 100);
                        if (needed > minTotal) minTotal = needed;
                      }
                    }
                    final minAmount = minTotal.ceil();
                    return Text(
                      minAmount > 0 ? 'Invest (₹$minAmount)' : 'Invest',
                      style: MyntWebTextStyles.body(context,
                          fontWeight: MyntFonts.semiBold,
                          color: Colors.white),
                    );
                  }),
          ),
        ),
      ],
       if (strategy.selectedFunds.isNotEmpty && strategy.isEditingMode) ...[
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            tooltip: 'Investment settings',
            onPressed: () => _showInvestmentDetailsDialog(context, settingsMode: true),
            icon: Icon(
              Icons.settings_outlined,
              size: 20,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
            ),
          ),
        ),
      ],
    ];
  }

  void _showFundSearchDialog() {
    final strategy = ref.read(dashboardProvider);
    strategy.searchController.clear();
    strategy.Basketsearch("");

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fund Search',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: _FundSearchDialogContent(
                onDone: () {
                  Navigator.of(ctx).pop();
                  setState(() {});
                },
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        ref.read(dashboardProvider).autoSaveFundChange(context);
      }
    });
  }

  // ─── SELECTED FUNDS TABLE (Single table with expandable groups) ─────────

  Widget _buildSelectedFundsTable(DashboardProvider strategy) {
    final grouped = strategy.groupedSelectedFunds;
    final dark = isDarkMode(context);
    final allFunds = strategy.selectedFunds;
    final isSplit = strategy.analysisData != null || _isBacktestLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 32; // 16px padding each side

        // ── Column width calculation (like holdings table) ──
        // Full: Fund Name, NAV, AUM, 1yr CAGR, Weight %, Lock, Delete
        // Split: Fund Name, Weight %, Lock, Delete (hide NAV, AUM & 1yr CAGR)
        final headers = isSplit
            ? ['Fund Name', 'Weight %', '', '']
            : ['Fund Name', 'NAV', 'AUM', '1yr CAGR', 'Weight %', '', ''];
        final colCount = headers.length;
        const textStyle = TextStyle(fontSize: 14);
        const padding = 24.0;
        const sortIconWidth = 0.0; // No sorting in this table

        final minWidths = <int, double>{};

        for (int col = 0; col < colCount; col++) {
          double maxWidth = 0.0;

          // Measure header width
          final headerWidth = _measureTextWidth(headers[col], textStyle);
          maxWidth = headerWidth + sortIconWidth;

          // Measure widest data value
          for (final fund in allFunds) {
            String cellText = '';
            if (isSplit) {
              switch (col) {
                case 0: cellText = fund.name; break;
                case 1: cellText = '100'; break; // Weight %
                case 2: cellText = ''; break; // lock icon
                case 3: cellText = ''; break; // delete icon
              }
            } else {
              switch (col) {
                case 0: cellText = fund.name; break;
                case 1: cellText = fund.nav > 0 ? '₹${fund.nav.toStringAsFixed(2)}' : '-'; break;
                case 2: cellText = fund.aum > 0 ? fund.aum.toStringAsFixed(2) : '-'; break;
                case 3: cellText = fund.fiveYearCAGR > 0 ? '${fund.fiveYearCAGR.toStringAsFixed(2)}%' : '-'; break;
                case 4: cellText = '100'; break; // max possible weight text
                case 5: cellText = ''; break; // lock icon
                case 6: cellText = ''; break; // delete icon
              }
            }
            final cellWidth = _measureTextWidth(cellText, textStyle);
            if (cellWidth > maxWidth) maxWidth = cellWidth;
          }

          // Absolute minimums for icon columns
          if (isSplit) {
            if (col == 2 || col == 3) maxWidth = maxWidth < 40 ? 40 : maxWidth; // icon cols
            if (col == 1) maxWidth = maxWidth < 80 ? 80 : maxWidth; // Weight
          } else {
            if (col == 5 || col == 6) maxWidth = maxWidth < 40 ? 40 : maxWidth; // icon cols
            if (col == 4) maxWidth = maxWidth < 80 ? 80 : maxWidth; // Weight
          }

          minWidths[col] = maxWidth + padding;
        }

        // Start with minimum widths
        final columnWidthValues = <int, double>{};
        for (int i = 0; i < colCount; i++) {
          columnWidthValues[i] = minWidths[i] ?? 80.0;
        }

        final totalMinWidth = columnWidthValues.values.fold<double>(0, (s, w) => s + w);

        if (totalMinWidth < availableWidth) {
          // Extra space - distribute proportionally
          final extraSpace = availableWidth - totalMinWidth;
          final growthFactors = isSplit
              ? <int, double>{0: 2.0, 1: 0.5, 2: 0.1, 3: 0.1}
              : <int, double>{0: 2.0, 1: 1.0, 2: 1.0, 3: 1.0, 4: 0.5, 5: 0.1, 6: 0.1};
          final totalGrowth = growthFactors.values.fold<double>(0, (s, v) => s + v);
          for (int i = 0; i < colCount; i++) {
            columnWidthValues[i] = columnWidthValues[i]! +
                (extraSpace * growthFactors[i]!) / totalGrowth;
          }
        } else if (totalMinWidth > availableWidth) {
          // Not enough space - shrink proportionally
          final excessWidth = totalMinWidth - availableWidth;
          final absoluteMinWidths = isSplit
              ? <int, double>{0: 140.0, 1: 80.0, 2: 40.0, 3: 40.0}
              : <int, double>{0: 140.0, 1: 70.0, 2: 70.0, 3: 65.0, 4: 80.0, 5: 40.0, 6: 40.0};
          final shrinkableAmounts = <int, double>{};
          double totalShrinkable = 0.0;
          for (int i = 0; i < colCount; i++) {
            final shrinkable = columnWidthValues[i]! - (absoluteMinWidths[i] ?? 40);
            shrinkableAmounts[i] = shrinkable > 0 ? shrinkable : 0;
            totalShrinkable += shrinkableAmounts[i]!;
          }
          if (totalShrinkable > 0) {
            final shrinkFactor = excessWidth < totalShrinkable
                ? excessWidth / totalShrinkable : 1.0;
            for (int i = 0; i < colCount; i++) {
              if (shrinkableAmounts[i]! > 0) {
                columnWidthValues[i] = columnWidthValues[i]! -
                    (shrinkableAmounts[i]! * shrinkFactor);
              }
            }
          }
        }

        final columnWidths = <int, shadcn.TableSize>{
          for (int i = 0; i < colCount; i++)
            i: shadcn.FixedTableSize(columnWidthValues[i]!),
        };

        // ── Build body rows (category headers + fund data) ──
        final List<shadcn.TableRow> bodyRows = [];

        for (final entry in grouped.entries) {
          final category = entry.key;
          final funds = entry.value;
          final categoryColor = _getTypeColor(category);
          final isExpanded = _expandedCategories[category] ?? true;
          final totalPercent =
              funds.fold<double>(0, (sum, f) => sum + f.percentage);

          final categoryBg = categoryColor.withOpacity(0.09);
          onTapCategory() {
            setState(() {
              _expandedCategories[category] = !isExpanded;
            });
          }

          // Category group header row
          bodyRows.add(shadcn.TableRow(
            cells: [
              shadcn.TableCell(
                child: GestureDetector(
                  onTap: onTapCategory,
                  child: Container(
                    color: categoryBg,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          color: categoryColor,
                          margin: const EdgeInsets.only(right: 10),
                        ),
                        Text(
                          category.toUpperCase(),
                          style: MyntWebTextStyles.tableHeader(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary,
                              fontWeight: MyntFonts.semiBold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${funds.length}',
                            style: MyntWebTextStyles.para(context,
                                fontWeight: MyntFonts.semiBold,
                                color: categoryColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${totalPercent.toStringAsFixed(0)}%)',
                          style: MyntWebTextStyles.tableHeader(context,
                              darkColor: MyntColors.textSecondaryDark,
                              lightColor: MyntColors.textSecondary,
                              fontWeight: MyntFonts.medium),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Empty cells for remaining columns (except first and last)
              for (int i = 0; i < colCount - 2; i++)
                shadcn.TableCell(
                  child: GestureDetector(
                    onTap: onTapCategory,
                    child: Container(color: categoryBg),
                  ),
                ),
              shadcn.TableCell(
                child: GestureDetector(
                  onTap: onTapCategory,
                  child: Container(
                    color: categoryBg,
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ));

          if (isExpanded) {
            for (final fund in funds) {
              bodyRows.add(shadcn.TableRow(
                cells: [
                  _buildDataCell(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: resolveThemeColor(context,
                              dark: MyntColors.backgroundColorDark,
                              light: MyntColors.backgroundColor),
                          child: ClipOval(
                            child: Image.network(
                              'https://v3.mynt.in/mfapi/static/images/mf/${fund.aMCCode ?? ""}.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.account_balance,
                                size: 14,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Tooltip(
                            message: fund.name,
                            preferBelow: true,
                            child: Text(
                              fund.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MyntWebTextStyles.tableCell(context,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                  fontWeight: MyntFonts.medium),
                            ),
                          ),
                        ),
                      ],
                    ),
                    alignRight: false,
                  ),
                  if (!isSplit)
                  _buildDataCell(
                    child: Text(
                      fund.nav > 0 ? '₹${fund.nav.toStringAsFixed(2)}' : '-',
                      style: MyntWebTextStyles.tableCell(context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.medium),
                    ),
                    alignRight: true,
                  ),
                  if (!isSplit)
                  _buildDataCell(
                    child: Text(
                      fund.aum > 0 ? fund.aum.toStringAsFixed(2) : '-',
                      style: MyntWebTextStyles.tableCell(context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.medium),
                    ),
                    alignRight: true,
                  ),
                  if (!isSplit)
                  _buildDataCell(
                    child: Text(
                      fund.fiveYearCAGR > 0
                          ? '${fund.fiveYearCAGR.toStringAsFixed(2)}%'
                          : '-',
                      style: MyntWebTextStyles.tableCell(context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.medium),
                    ),
                    alignRight: true,
                  ),
                  shadcn.TableCell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      alignment: Alignment.centerRight,
                      child: _buildWeightField(context, fund, strategy, dark),
                    ),
                  ),
                  // Units column - commented out: only shown in invest dialog where amount is known
                  // _buildDataCell(
                  //   child: Builder(builder: (context) {
                  //     final allocation = strategy.basketAllocations
                  //         .where((a) => a.fund.isin == fund.isin)
                  //         .firstOrNull;
                  //     final units = allocation?.estimatedUnits ?? 0;
                  //     return Text(
                  //       units > 0 ? units.toStringAsFixed(4) : '-',
                  //       style: MyntWebTextStyles.tableCell(context,
                  //           darkColor: units > 0
                  //               ? MyntColors.textPrimaryDark
                  //               : MyntColors.textSecondaryDark,
                  //           lightColor: units > 0
                  //               ? MyntColors.textPrimary
                  //               : MyntColors.textSecondary,
                  //           fontWeight: MyntFonts.medium),
                  //     );
                  //   }),
                  //   alignRight: true,
                  // ),
                  shadcn.TableCell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      alignment: Alignment.center,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => strategy.toggleFundLock(fund, context),
                        child: Icon(
                          fund.isLocked ? Icons.lock : Icons.lock_open,
                          color: strategy.selectedFunds.length == 1
                              ? resolveThemeColor(context,
                                      dark: MyntColors.textSecondaryDark,
                                      light: MyntColors.textSecondary)
                                  .withOpacity(0.3)
                              : fund.isLocked
                                  ? MyntColors.primary
                                  : resolveThemeColor(context,
                                      dark: MyntColors.textSecondaryDark,
                                      light: MyntColors.textSecondary),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  shadcn.TableCell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      alignment: Alignment.center,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          strategy.removeFundFromStrategy(fund);
                          showResponsiveWarning(context,
                              '${fund.name} deleted');
                        },
                        child: Icon(
                          Icons.delete_outline,
                          color: resolveThemeColor(context,
                              dark: MyntColors.lossDark,
                              light: MyntColors.loss),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ));
            }
          }
        }

        // ── Fixed Header + Scrollable Body (like holdings table) ──
        return Padding(
          padding: const EdgeInsets.all(16),
          child: shadcn.OutlinedContainer(
            clipBehavior: Clip.antiAlias,
            child: Column(
            children: [
              // Fixed Header
              shadcn.Table(
                columnWidths: columnWidths,
                defaultRowHeight: const shadcn.FixedTableSize(44),
                rows: [
                  shadcn.TableHeader(
                    cells: [
                      _buildHeaderCell('Fund Name', false),
                      if (!isSplit) _buildHeaderCell('NAV', true),
                      if (!isSplit) _buildHeaderCell('AUM', true),
                      if (!isSplit) _buildHeaderCell('1yr CAGR', true),
                      _buildHeaderCell('Weight %', true),
                      // _buildHeaderCell('Units', true), // Only shown in invest dialog
                      _buildHeaderCell('', true),
                      _buildHeaderCell('', true),
                    ],
                  ),
                ],
              ),
              // Scrollable Body
              Expanded(
                child: RawScrollbar(
                  controller: _tableScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  trackColor: resolveThemeColor(context,
                      dark: Colors.grey.withOpacity(0.1),
                      light: Colors.grey.withOpacity(0.1)),
                  thumbColor: resolveThemeColor(context,
                      dark: Colors.grey.withOpacity(0.3),
                      light: Colors.grey.withOpacity(0.3)),
                  thickness: 6,
                  radius: const Radius.circular(3),
                  interactive: true,
                  child: SingleChildScrollView(
                    controller: _tableScrollController,
                    child: shadcn.Table(
                      columnWidths: columnWidths,
                      defaultRowHeight: const shadcn.FixedTableSize(50),
                      rows: bodyRows,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  shadcn.TableCell _buildHeaderCell(String label, bool alignRight) {
    return shadcn.TableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          style: MyntWebTextStyles.tableHeader(context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary),
        ),
      ),
    );
  }

  shadcn.TableCell _buildDataCell({
    required Widget child,
    required bool alignRight,
  }) {
    return shadcn.TableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'equity':
        return const Color(0xFF6366F1); // Indigo
      case 'hybrid':
        return Colors.orange;
      case 'debt':
        return Colors.blue;
      case 'fixed income':
        return const Color(0xFF0EA5E9); // Sky blue
      case 'liquid':
        return const Color(0xFF06B6D4); // Cyan
      case 'solution oriented':
        return const Color(0xFF8B5CF6); // Violet
      case 'index':
        return const Color(0xFF10B981); // Emerald
      case 'fof':
      case 'fund of funds':
        return const Color(0xFFF59E0B); // Amber
      case 'elss':
        return const Color(0xFFEF4444); // Red
      default:
        // Pick from a palette based on string hash so any new type gets a distinct color
        const palette = [
          Color(0xFF14B8A6), // Teal
          Color(0xFFF97316), // Orange
          Color(0xFFEC4899), // Pink
          Color(0xFF84CC16), // Lime
          Color(0xFF6366F1), // Indigo
          Color(0xFFA855F7), // Purple
        ];
        return palette[type.hashCode.abs() % palette.length];
    }
  }

  Widget _buildWeightSchemeDropdown() {
    return GestureDetector(
      key: _weightSchemeKey,
      onTap: () => _showWeightSchemeOverlay(),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: resolveThemeColor(context,
              dark: MyntColors.transparent,
              light: const Color(0xffF1F3F8)),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.primary),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ref.watch(dashboardProvider).weightingScheme,
              style: MyntWebTextStyles.body(context,
                  fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textWhite,
                  lightColor: MyntColors.textBlack),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightSchemeOverlay() {
    _removeWeightSchemeOverlay();

    final renderBox =
        _weightSchemeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final isDark = isDarkMode(context);
    final bgColor = isDark ? MyntColors.overlayBgDark : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF444444)
        : const Color(0xFFE0E0E0);
    final primary = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);

    const options = ['Equi-Weighted', 'AUM Weighted', 'Custom Weighted'];

    _weightSchemeOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeWeightSchemeOverlay,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy + size.height + 4,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(6),
              color: bgColor,
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: options.map((option) {
                      final isSelected = option == ref.read(dashboardProvider).weightingScheme;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _removeWeightSchemeOverlay();
                            ref.read(dashboardProvider).updateWeightingScheme(option);
                            final s = ref.read(dashboardProvider);
                            if (option == 'Equi-Weighted') {
                              _applyEquiWeighted(s);
                            } else if (option == 'AUM Weighted') {
                              _applyMarketCapWeighted(s);
                            }
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  option,
                                  style: MyntWebTextStyles.body(context,
                                      fontWeight: isSelected
                                          ? MyntFonts.semiBold
                                          : MyntFonts.medium,
                                      color:
                                          isSelected ? primary : textColor),
                                ),
                                if (isSelected)
                                  Icon(Icons.check,
                                      size: 16, color: primary),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_weightSchemeOverlay!);
  }

  void _removeWeightSchemeOverlay() {
    _weightSchemeOverlay?.remove();
    _weightSchemeOverlay = null;
  }

  void _applyEquiWeighted(DashboardProvider strategy) {
    final funds = strategy.selectedFunds;
    if (funds.isEmpty) return;
    final equalPct = (100.0 / funds.length);
    for (int i = 0; i < funds.length; i++) {
      funds[i].isLocked = false;
      if (i == funds.length - 1) {
        // Last fund gets remainder to ensure total = 100
        final used = funds.take(i).fold(0.0, (s, f) => s + f.percentage);
        funds[i].percentage = (100.0 - used).roundToDouble();
      } else {
        funds[i].percentage = equalPct.roundToDouble();
      }
    }
    strategy.updateAllControllers();
  }

  void _applyMarketCapWeighted(DashboardProvider strategy) {
    final funds = strategy.selectedFunds;
    if (funds.isEmpty) return;
    final totalAum = funds.fold(0.0, (sum, f) => sum + f.aum);
    if (totalAum <= 0) {
      // Fallback to equi-weighted if no AUM data
      _applyEquiWeighted(strategy);
      ref.read(dashboardProvider).updateWeightingScheme('Equi-Weighted');
      return;
    }

    // Step 1: raw proportional weights, clamp min to 1% so no fund shows 0
    for (int i = 0; i < funds.length; i++) {
      funds[i].isLocked = false;
      final raw = (funds[i].aum / totalAum) * 100;
      funds[i].percentage = raw < 1.0 ? 1.0 : raw;
    }

    // Step 2: renormalize — clamping may have pushed total above 100
    final clampedTotal = funds.fold(0.0, (s, f) => s + f.percentage);
    for (int i = 0; i < funds.length; i++) {
      funds[i].percentage = (funds[i].percentage / clampedTotal) * 100;
    }

    // Step 3: round to integers (matching equi-weighted behaviour)
    for (int i = 0; i < funds.length; i++) {
      funds[i].percentage = funds[i].percentage.roundToDouble();
    }

    // Step 4: fix integer rounding diff on the largest fund
    final total = funds.fold(0.0, (s, f) => s + f.percentage);
    final diff = (100.0 - total).roundToDouble();
    if (diff != 0) {
      final largest = funds.reduce((a, b) => a.percentage >= b.percentage ? a : b);
      largest.percentage = (largest.percentage + diff).clamp(1.0, 100.0);
    }

    strategy.updateAllControllers();
  }

  Widget _buildWeightField(BuildContext context, FundListModel fund,
      DashboardProvider strategy, bool dark) {
    final controller = strategy.percentageControllers[fund.name] ??
        TextEditingController();

    void updateWeight(int delta) {
      final current = int.tryParse(controller.text) ?? 0;
      final newVal = (current + delta).clamp(1, 100);
      final newText = '$newVal';
      // Atomic update — sets text and selection in one operation so there is
      // no intermediate frame where the browser selection is visible.
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      strategy.updateFundPercentage(fund, newVal.toDouble());
      strategy.validatepercentage(context);
      if (ref.read(dashboardProvider).weightingScheme != 'Custom Weighted') {
        ref.read(dashboardProvider).updateWeightingScheme('Custom Weighted');
      }
    }

    // Get or create a persistent focus node for this fund
    final focusNode = _weightFocusNodes.putIfAbsent(
      fund.name,
      () => FocusNode(),
    );
    // Attach arrow key handler (safe to reassign each build)
    focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent || event is KeyRepeatEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          updateWeight(1);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          updateWeight(-1);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    final iconColor = dark ? MyntColors.primaryDark : MyntColors.primary;
    final borderColor = dark ? MyntColors.textSecondaryDark : MyntColors.primary;
    final bgColor = dark
        ? const Color(0xffB5C0CF).withValues(alpha: 0.15)
        : const Color(0xffF1F3F8);
    final textStyle = MyntWebTextStyles.body(context,
        fontWeight: MyntFonts.medium,
        darkColor: MyntColors.textPrimaryDark,
        lightColor: MyntColors.textPrimary);

    // Custom container: − and + are siblings to the TextField, not inside it.
    // This prevents tapping the buttons from focusing the TextField.
    return Container(
      height: 34,
      width: 110,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Minus button — opaque hit area, isolated from TextField
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => updateWeight(-1),
            child: SizedBox(
              width: 28,
              height: 34,
              child: Center(child: Icon(Icons.remove, size: 16, color: iconColor)),
            ),
          ),
          // Number input — only the middle area focuses the field
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.startsWith('0')) return oldValue;
                  return newValue;
                }),
              ],
              style: textStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value);
                if (intValue != null && intValue > 0 && intValue <= 100) {
                  strategy.updateFundPercentage(fund, intValue.toDouble());
                } else if (value.isEmpty) {
                  // User is mid-edit (clearing to retype) — don't update the model
                } else {
                  // intValue == 0 or invalid — ignore, keep current percentage
                }
                strategy.validatepercentage(context);
                if (ref.read(dashboardProvider).weightingScheme != 'Custom Weighted') {
                  ref.read(dashboardProvider).updateWeightingScheme('Custom Weighted');
                }
              },
            ),
          ),
          // Plus button — opaque hit area, isolated from TextField
          GestureDetector( 
            behavior: HitTestBehavior.opaque,
            onTap: () => updateWeight(1),
            child: SizedBox(
              width: 28,
              height: 34,
              child: Center(child: Icon(Icons.add, size: 16, color: iconColor)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── RIGHT PANEL ──────────────────────────────────────────────────────

  String _formatInvestAmount(double number) {
    if (number >= 10000000) return '${(number / 10000000).toStringAsFixed(1)}Cr';
    if (number >= 100000) return '${(number / 100000).toStringAsFixed(1)}L';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toStringAsFixed(0);
  }

  Widget _buildRightPanel(DashboardProvider strategy) {
    if (_isBacktestLoading) {
      return Center(child: MyntLoader.branded());
    }

    if (strategy.analysisData == null) {
      return const NoDataFoundWeb(
        title: 'Backtest Results',
        subtitle: 'Add funds and click Analyse to see results',
        primaryEnabled: false,
        secondaryEnabled: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                'Backtest Results',
                style: MyntWebTextStyles.bodyMedium(context, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),

                 RichText(
                text: TextSpan(
                  style: MyntWebTextStyles.para(context,
                      darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary),
                  children: [
                    const TextSpan(text: '( Invest. amt : '),
                    TextSpan(
                      text: '₹${_formatInvestAmount(double.tryParse(strategy.backtestAmount ?? strategy.investmentController.text) ?? 0)}',
                      style: MyntWebTextStyles.para(context,
                          fontWeight: MyntFonts.semiBold,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary),
                    ),
                    const TextSpan(text: '   Duration : '),
                    TextSpan(
                      text: strategy.backtestDuration ?? strategy.selectedDuration,
                      style: MyntWebTextStyles.para(context,
                          fontWeight: MyntFonts.semiBold,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary),
                    ),
                    const TextSpan(text: ' )'),
                  ],
                ),
              ),
              const Spacer(),
           
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ref.read(dashboardProvider).clearData();
                  setState(() => _isBacktestLoading = false);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: resolveThemeColor(context,
              dark: MyntColors.dividerDark, light: MyntColors.divider),
        ),
        // Backtest content
        const Expanded(
          child: BenchMarkBacktestScreenWeb(
            onBack: null,
            onCustomize: null,
          ),
        ),
      ],
    );
  }

  // ─── DIALOGS & NAVIGATION (same logic as old screen) ───────────────────

  void _handleBackNavigation() {
    final strategy = ref.read(dashboardProvider);
    if (strategy.isEditingMode && strategy.hasStrategyChanged) {
      _showUnsavedChangesDialog();
    } else {
      _navigateBack();
    }
  }

  void _navigateBack() {
    widget.onBack?.call();
  }

  Future<void> _showUnsavedChangesDialog() async {
    return showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: shadcn.Card(
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: shadcn.Theme.of(ctx).colorScheme.border,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unsaved Changes',
                            style: MyntWebTextStyles.title(
                              ctx,
                              color: resolveThemeColor(ctx,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                              fontWeight: MyntFonts.medium,
                            ),
                          ),
                          MyntCloseButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'You have unsaved changes. Do you want to save them before leaving?',
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.body(
                              ctx,
                              color: resolveThemeColor(ctx,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: MyntOutlinedButton(
                                    label: 'Discard',
                                    isFullWidth: true,
                                    textColor: resolveThemeColor(ctx,
                                        dark: MyntColors.textWhite,
                                        light: MyntColors.primary),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      _navigateBack();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: MyntPrimaryButton(
                                    label: 'Save',
                                    isFullWidth: true,
                                    onPressed: () async {
                                      final strategy =
                                          ref.read(dashboardProvider);
                                      strategy.stratergySavebackbutton(true);
                                      if (strategy.isEditingMode) {
                                        // Close dialog and navigate back first, then save in background
                                        Navigator.of(ctx).pop();
                                        _navigateBack();
                                        try {
                                          await strategy
                                              .updateStrategy(context);
                                        } catch (e) {}
                                      } else {
                                        Navigator.of(ctx).pop();
                                        _showSaveStrategyDialog(
                                            navigateBackAfterSave: true);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAnalyseAction(BuildContext dialogContext, {bool popDialog = true}) async {
    try {
      final strategy = ref.read(dashboardProvider);
      if (popDialog) Navigator.of(dialogContext).pop();
      if (!strategy.isEditingMode || strategy.hasStrategyChanged) {
        if (strategy.isEditingMode) {
          await strategy.updateStrategy(context);
        } else {
          _showSaveStrategyDialog(triggerBacktest: true);
          return;
        }
      }
      await _performBacktest(context);
    } catch (e) {}
  }

  Future<void> _performBacktest(BuildContext context) async {
    final strategy = ref.read(dashboardProvider);
    setState(() => _isBacktestLoading = true);
    try {
      await strategy.backtestAnalysis(
          uuid: strategy.editingStrategy?.data?.first.uuid ?? '');
      if (strategy.analysisData != null) {
        setState(() => _isBacktestLoading = false);
      } else {
        setState(() => _isBacktestLoading = false);
        if (mounted) {
          error(context, 'Failed to get backtest data. Please try again.');
        }
      }
    } catch (e) {
      setState(() => _isBacktestLoading = false);
      if (mounted) {
        error(context, 'Failed to start backtest. Please try again.');
      }
    }
  }

  void _showInvestmentDetailsDialog(BuildContext context, {bool settingsMode = false}) {
    // Snapshot originals so we can restore if user closes without clicking Set
    final strategy = ref.read(dashboardProvider);
    final originalAmount = settingsMode ? strategy.investmentController.text : null;
    final originalDuration = settingsMode ? strategy.selectedDuration : null;
    bool confirmed = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Investment Details',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Consumer(
                builder: (ctx, ref, child) {
                  final strategy = ref.watch(dashboardProvider);
                  final screenWidth = MediaQuery.of(ctx).size.width;
                  final dialogWidth =
                      screenWidth * 0.25 < 320 ? 320.0 : screenWidth * 0.25;

                  return shadcn.Card(
                    borderRadius: BorderRadius.circular(8),
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: dialogWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: shadcn.Theme.of(ctx).colorScheme.border,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  settingsMode ? 'Investment Settings' : 'Investment Details',
                                  style: MyntWebTextStyles.title(ctx,
                                      fontWeight: MyntFonts.medium,
                                      color: resolveThemeColor(ctx,
                                          dark: MyntColors.textPrimaryDark,
                                          light: MyntColors.textPrimary)),
                                ),
                                MyntCloseButton(
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Type',
                                  style: MyntWebTextStyles.body(ctx,
                                      fontWeight: MyntFonts.medium,
                                      darkColor: MyntColors.textPrimaryDark,
                                      lightColor: MyntColors.textPrimary),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: ['One-time']
                                      .map((type) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: _buildInvestmentTypeChip(
                                                type,
                                                strategy.selectedInvestmentType == type,
                                                ctx),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Initial amount',
                                  style: MyntWebTextStyles.body(ctx,
                                      fontWeight: MyntFonts.medium,
                                      darkColor: MyntColors.textPrimaryDark,
                                      lightColor: MyntColors.textPrimary),
                                ),
                                const SizedBox(height: 10),
                                MyntFormTextField(
                                  controller: strategy.investmentController,
                                  placeholder: '\u20B9  Enter amount',
                                  height: 40,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    strategy.validateInvestmentAmount(value);
                                  },
                                ),
                                if (strategy.investmentError != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    strategy.investmentError!,
                                    style: MyntWebTextStyles.caption(ctx,
                                        fontWeight: MyntFonts.medium,
                                        color: MyntColors.loss),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Text(
                                  'Over a duration of',
                                  style: MyntWebTextStyles.body(ctx,
                                      fontWeight: MyntFonts.medium,
                                      darkColor: MyntColors.textPrimaryDark,
                                      lightColor: MyntColors.textPrimary),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: ['1Y', '3Y', '5Y']
                                      .map((duration) => _buildDurationChip(
                                          duration,
                                          strategy.selectedDuration == duration,
                                          ctx))
                                      .toList(),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: MyntPrimaryButton(
                                    label: settingsMode ? 'Set' : strategy.backtestButtonText,
                                    isFullWidth: true,
                                    onPressed: () {
                                      if (settingsMode) {
                                        confirmed = true;
                                        Navigator.pop(ctx);
                                      } else if (strategy.isStrategyValid) {
                                        _handleAnalyseAction(ctx);
                                      } else {
                                        error(ctx,
                                            strategy.getStrategyValidationError() ??
                                                'Please fix validation errors before proceeding');
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // If settings mode and user closed without clicking Set, restore originals
      if (settingsMode && !confirmed && mounted) {
        final s = ref.read(dashboardProvider);
        s.investmentController.text = originalAmount!;
        s.updateDuration(originalDuration!);
      }
    });
  }

  Widget _buildInvestmentTypeChip(
      String text, bool isSelected, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          ref.read(dashboardProvider).updateInvestmentType(text);
        },
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            color: isSelected
                ? resolveThemeColor(context,
                    dark: colors.searchBgDark,
                    light: const Color(0xffF1F3F8))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Text(
              text,
              style: MyntWebTextStyles.body(context,
                  fontWeight: MyntFonts.semiBold,
                  color: isSelected
                      ? resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary)
                      : resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(
      String text, bool isSelected, BuildContext context) {
    final dark = isDarkMode(context);
    return TextButton(
      onPressed: () {
        ref.read(dashboardProvider).updateDuration(text);
        FocusScope.of(context).unfocus();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        backgroundColor: !dark
            ? isSelected
                ? const Color(0xffF1F3F8)
                : Colors.transparent
            : isSelected
                ? colors.darkGrey
                : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: isSelected
              ? BorderSide(color: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary), width: 1)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: MyntWebTextStyles.body(context,
            fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.regular,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary),
      ),
    );
  }

  void _showSaveStrategyDialog(
      {bool triggerBacktest = false,
      bool navigateBackAfterSave = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Save Strategy',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: _SaveStrategyDialogContent(
                isBackNavigation: navigateBackAfterSave,
                onSaved: () {
                  Navigator.of(ctx).pop();
                  if (navigateBackAfterSave) {
                    _navigateBack();
                  } else if (triggerBacktest) {
                    _performBacktest(context);
                  }
                },
                onBacktest: () {
                  Navigator.of(ctx).pop();
                  _performBacktest(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

}

// ─── SAVE STRATEGY DIALOG ──────────────────────────────────────────────────

class _SaveStrategyDialogContent extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  final VoidCallback? onBacktest;
  final bool isBackNavigation;

  const _SaveStrategyDialogContent({
    required this.onSaved,
    this.onBacktest,
    this.isBackNavigation = false,
  });

  @override
  ConsumerState<_SaveStrategyDialogContent> createState() =>
      _SaveStrategyDialogContentState();
}

class _SaveStrategyDialogContentState
    extends ConsumerState<_SaveStrategyDialogContent> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider).clearStrategyNameError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);
    final dark = isDarkMode(context);
    const dialogWidth = 380.0;

    return Container(
      width: dialogWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strategy.isEditingMode ? 'Update Strategy' : 'Save Strategy',
                  style: MyntWebTextStyles.title(context,
                      fontWeight: MyntFonts.semiBold,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary),
                ),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: dark
                            ? MyntColors.textSecondaryDark
                            : MyntColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strategy Name',
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.medium,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary),
                ),
                const SizedBox(height: 8),
                MyntFormTextField(
                  controller: strategy.strategyNameController,
                  placeholder: 'Enter strategy Name',
                  height: 40,
                  onChanged: (value) {
                    if (strategy.strategyNameError != null) {
                      strategy.clearStrategyNameError();
                    }
                  },
                ),
                if (strategy.strategyNameError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    strategy.strategyNameError!,
                    style: MyntWebTextStyles.caption(context,
                        fontWeight: MyntFonts.regular,
                        color: MyntColors.loss),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = strategy.strategyNameController.text.trim();
                      if (name.isEmpty) {
                        strategy.setStrategyNameError('Strategy name is required');
                        return;
                      }
                      if (name.length < 3) {
                        strategy.setStrategyNameError('Strategy name must be at least 3 characters');
                        return;
                      }
                      if (_isSaving) return;
                      setState(() => _isSaving = true);
                      try {
                        strategy.stratergySavebackbutton(true);
                        if (strategy.isEditingMode) {
                          await strategy.updateStrategy(context);
                          widget.onSaved();
                        } else {
                          await strategy.saveStrategy(name, context);
                          widget.onSaved();
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isSaving = false);
                          error(context,
                              'Failed to save strategy. Please try again.');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyntColors.primary,
                      disabledBackgroundColor:
                          MyntColors.textSecondary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                      strategy.isEditingMode ? 'Update' : 'Save',
                      style: MyntWebTextStyles.body(context,
                          fontWeight: MyntFonts.semiBold,
                          color: MyntColors.textWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FUND SEARCH DIALOG ──────────────────────────────────────────────────────

class _FundSearchDialogContent extends ConsumerStatefulWidget {
  final VoidCallback onDone;

  const _FundSearchDialogContent({required this.onDone});

  @override
  ConsumerState<_FundSearchDialogContent> createState() =>
      _FundSearchDialogContentState();
}

class _FundSearchDialogContentState
    extends ConsumerState<_FundSearchDialogContent> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FundListModel> _getFilteredFunds(DashboardProvider strategy) {
    List<FundListModel> funds = (strategy.basketSearchItems ?? [])
        .map((item) => FundListModel(
              name: item.name ?? "Unknown Scheme",
              schemeName: item.schemeName ?? "Unknown Scheme",
              type: item.type ?? '',
              fiveYearCAGR: double.tryParse(item.fIVEYEARDATA ?? "0") ?? 0.0,
              threeYearCAGR: double.tryParse(item.tHREEYEARDATA ?? "0") ?? 0.0,
              aum: double.tryParse(item.aUM ?? "0") ?? 0.0,
              sharpe: 0.0,
              aMCCode: item.aMCCode,
              isin: item.iSIN,
              schemeCode: item.schemeCode,
              minimumPurchaseAmount:
                  double.tryParse(item.minimumPurchaseAmount ?? "100") ?? 100.0,
              nav: double.tryParse(item.nETASSETVALUE ?? "0") ?? 0.0,
            ))
        .toList();

    return funds;
  }

  @override
  Widget build(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth * 0.35 < 450 ? 450.0 : screenWidth * 0.35;
    final funds = _getFilteredFunds(strategy);

    return shadcn.Card(
      borderRadius: BorderRadius.circular(8),
      padding: EdgeInsets.zero,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar + close button
            Container(
              padding: const EdgeInsets.only(
                  left: 16, right: 8, top: 16, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: MyntSearchTextField.withSmartClear(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      placeholder: 'Search funds...',
                      leadingIcon: assets.searchIcon,
                      autofocus: true,
                      onChanged: (value) {
                        strategy.Basketsearch(value);
                      },
                      onClear: () {
                        strategy.clearBasketSearchResults();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (strategy.selectedFunds.isNotEmpty)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          strategy.searchController.clear();
                          strategy.Basketsearch("");
                          widget.onDone();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Text(
                            'Done',
                            style: MyntWebTextStyles.body(context,
                                fontWeight: MyntFonts.semiBold,
                                color: MyntColors.primary),
                          ),
                        ),
                      ),
                    )
                  else
                    MyntCloseButton(
                      onPressed: () {
                        strategy.searchController.clear();
                        strategy.Basketsearch("");
                        widget.onDone();
                      },
                    ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: shadcn.Theme.of(context).colorScheme.border,
            ),
            // Results
            Expanded(
              child: funds.isEmpty
                  ? Center(
                      child: NoDataFoundWeb(
                        title: _searchController.text.isNotEmpty
                            ? 'No Results Found'
                            : 'Start Searching',
                        subtitle: _searchController.text.isNotEmpty
                            ? 'No funds match your search "${_searchController.text}".'
                            : 'Type to search for mutual funds.',
                        primaryEnabled: false,
                        secondaryEnabled: false,
                      ),
                    )
                  : ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: shadcn.Theme.of(context).colorScheme.border,
                      ),
                      itemCount: funds.length,
                      itemBuilder: (context, index) {
                        final fund = funds[index];
                        final isSelected = strategy.selectedFunds
                            .any((f) => f.name == fund.name);
                        return _buildSearchResultItem(
                            fund, isSelected, strategy);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchResultItem(
      FundListModel fund, bool isSelected, DashboardProvider strategy) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: resolveThemeColor(context,
            dark: MyntColors.primaryDark,
            light: MyntColors.primary).withValues(alpha: 0.08),
        onTap: () {
          if (isSelected) {
            strategy.removeFundFromStrategy(fund);
            showResponsiveWarning(
                context, '${fund.name} removed');
          } else {
            strategy.addFundToStrategy(fund);
            showResponsiveSuccess(
                context, '${fund.name} added');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: resolveThemeColor(context,
                    dark: MyntColors.backgroundColorDark,
                    light: MyntColors.backgroundColor),
                child: ClipOval(
                  child: Image.network(
                    "https://v3.mynt.in/mfapi/static/images/mf/${fund.aMCCode ?? ""}.png",
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.account_balance,
                        size: 18,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: MyntWebTextStyles.body(context,
                          fontWeight: MyntFonts.medium,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fund.type,
                      style: MyntWebTextStyles.para(context,
                          fontWeight: MyntFonts.medium,
                          darkColor: MyntColors.textSecondaryDark,
                          lightColor: MyntColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (isSelected) {
                      strategy.removeFundFromStrategy(fund);
                      showResponsiveWarning(
                          context, '${fund.name} removed');
                    } else {
                      strategy.addFundToStrategy(fund);
                      showResponsiveSuccess(
                          context, '${fund.name} added');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: SvgPicture.asset(
                      isSelected
                          ? assets.bookmarkIcon
                          : assets.bookmarkedIcon,
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                            : resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                        BlendMode.srcIn,
                      ),
                      height: 18,
                      width: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
