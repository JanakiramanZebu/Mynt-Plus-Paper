// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../provider/ledger_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../sharedWidget/scroll_to_load_mixin.dart';
import '../../../../models/desk_reports_model/contract_note_model.dart';

class ContractNoteScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const ContractNoteScreenWeb({super.key, this.onBack});

  @override
  ConsumerState<ContractNoteScreenWeb> createState() =>
      _ContractNoteScreenWebState();
}

class _ContractNoteScreenWebState extends ConsumerState<ContractNoteScreenWeb>
    with ScrollToLoadMixin {
  final ScrollController _tableScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

  @override
  ScrollController get tableScrollController => _tableScrollController;

  // Sorting state
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Calendar state
  late DateTime _calendarMonth;
  DateTime? _selectedDate;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    initScrollToLoad();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    _calendarMonth = DateTime(yesterday.year, yesterday.month);
    _selectedDate = yesterday;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ledgerprovider = ref.read(ledgerProvider);
      final dateStr =
          '${yesterday.day.toString().padLeft(2, '0')}/${yesterday.month.toString().padLeft(2, '0')}/${yesterday.year}';
      ledgerprovider.fetchContractNote(dateStr, dateStr);
    });
  }

  @override
  void dispose() {
    disposeScrollToLoad();
    _tableScrollController.dispose();
    _horizontalScrollController.dispose();
    _hoveredRowIndex.dispose();
    super.dispose();
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

  // Text style helpers
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

  void _onDateTap(DateTime date, LDProvider ledgerprovider) {
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    setState(() {
      _selectedDate = date;
      displayedItemCount = ScrollToLoadMixin.itemsPerPage;
      _showCalendar = false;
    });
    ledgerprovider.fetchContractNote(dateStr, dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final ledgerprovider = ref.watch(ledgerProvider);
    final theme = ref.watch(themeProvider);

    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.onBack != null) ...[
                  _buildHeaderBar(context, theme),
                  const SizedBox(height: 12),
                ],
                _buildToolbar(context, theme, ledgerprovider),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    children: [
                      // Trade table (full width always)
                      Positioned.fill(
                        child: ledgerprovider.isContractNoteLoading
                            ? Center(child: MyntLoader.simple())
                            : _buildTradeTable(
                                context, theme, ledgerprovider),
                      ),
                      // Calendar overlay (right) — only when toggled
                      if (_showCalendar)
                        Positioned(
                          top: 0,
                          right: 0,
                          width: 300,
                          child: Container(
                            decoration: BoxDecoration(
                              color: resolveThemeColor(context,
                                  dark: MyntColors.backgroundColorDark,
                                  light: MyntColors.backgroundColor),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                  offset: const Offset(-4, 0),
                                ),
                              ],
                              border: Border.all(
                                color: resolveThemeColor(context,
                                    dark: MyntColors.dividerDark,
                                    light: MyntColors.divider),
                              ),
                            ),
                            child: _buildCalendar(
                               context, theme, ledgerprovider),
                          ),
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
  }

  // ─── Header Bar ─────────────────────────────────────────────────────

  Widget _buildHeaderBar(BuildContext context, ThemesProvider theme) {
    return Row(
      children: [
        CustomBackBtn(onBack: widget.onBack),
        const SizedBox(width: 8),
        Text(
          'Contract Note',
          style:
              MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ─── Toolbar ─────────────────────────────────────────────────────────

  Widget _buildToolbar(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    return Row(
      children: [
        const Spacer(),
        // Date picker button — click to toggle calendar
        InkWell(
          onTap: () {
            setState(() => _showCalendar = !_showCalendar);
            if (_showCalendar) {
              ledgerprovider.fetchContractDocuments(
                  _calendarMonth.year, _calendarMonth.month);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: resolveThemeColor(context,
                    dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: MyntWebTextStyles.bodySmall(context,
                      fontWeight: MyntFonts.medium),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Download button
        if (_selectedDate != null)
          SizedBox(
            width: 40,
            height: 40,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _handleDownload(ledgerprovider),
              child: Center(
                child: Icon(
                  Icons.download_rounded,
                  size: 20,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildFilterToggle(ThemesProvider theme, LDProvider ledgerprovider) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: ledgerprovider.contractFilterOptions.map((filter) {
  //       final isSelected =
  //           ledgerprovider.selectedContractFilter == filter;
  //       String displayName = filter == 'CN'
  //           ? 'MCX'
  //           : (filter == 'Contract' ? 'Combine' : filter);
  //       return MouseRegion(
  //         cursor: SystemMouseCursors.click,
  //         child: GestureDetector(
  //           onTap: () {
  //             ledgerprovider.setContractFilter(filter);
  //           },
  //           child: Container(
  //             margin: const EdgeInsets.only(right: 8),
  //             padding:
  //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //             decoration: BoxDecoration(
  //               color: isSelected
  //                   ? (theme.isDarkMode
  //                       ? Colors.white.withValues(alpha: 0.1)
  //                       : Colors.black.withValues(alpha: 0.05))
  //                   : Colors.transparent,
  //               borderRadius: BorderRadius.circular(6),
  //             ),
  //             child: Text(
  //               displayName,
  //               style: MyntWebTextStyles.body(
  //                 context,
  //                 fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
  //               ).copyWith(
  //                 color: isSelected
  //                     ? shadcn.Theme.of(context).colorScheme.foreground
  //                     : shadcn.Theme.of(context).colorScheme.mutedForeground,
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  void _handleDownload(LDProvider ledgerprovider) {
    if (_selectedDate == null) return;
    final docs = ledgerprovider.contractDocumentDetails[_selectedDate!] ?? [];
    // final selectedType = ledgerprovider.selectedContractFilter;
    final doc = docs.cast<DocumentDetail?>().firstWhere(
          (d) => d != null && d.docType == 'Contract',
          orElse: () => null,
        );
    if (doc != null) {
      ledgerprovider.pdfdownloadfunction(context, doc.recno, doc.docFileName);
    }
  }

  // ─── Trade Table ─────────────────────────────────────────────────────

  Widget _buildTradeTable(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    final contractData = ledgerprovider.contractNoteModel?.data;
    final allTrades = contractData?.common ?? [];

    // Filter by selected filter type
    // final selectedFilter = ledgerprovider.selectedContractFilter;
    // final trades = selectedFilter == 'CN'
    //     ? allTrades.where((t) => (t.tradeExchange ?? '').toUpperCase().contains('MCX')).toList()
    //     : allTrades; // 'Contract' = Combine (show all)
    final trades = allTrades;

    // Sorting
    List<ContractNoteTrade> sortedTrades = List.from(trades);
    if (_sortColumnIndex != null) {
      sortedTrades.sort((a, b) {
        int compareResult = 0;
        switch (_sortColumnIndex) {
          case 0: // Symbol
            compareResult = (a.scripSymbol ?? '')
                .compareTo(b.scripSymbol ?? '');
            break;
          case 1: // Exchange
            compareResult = (a.tradeExchange ?? '')
                .compareTo(b.tradeExchange ?? '');
            break;
          case 4: // B/S
            compareResult =
                (a.buySale ?? '').compareTo(b.buySale ?? '');
            break;
          case 5: // Qty
            compareResult =
                (double.tryParse(a.quantity ?? '0') ?? 0)
                    .compareTo(double.tryParse(b.quantity ?? '0') ?? 0);
            break;
          case 6: // Gross Rate
            final aRate = double.tryParse(
                    a.buySale == 'BUY' ? (a.buyPrice ?? '0') : (a.sellPrice ?? '0')) ??
                0;
            final bRate = double.tryParse(
                    b.buySale == 'BUY' ? (b.buyPrice ?? '0') : (b.sellPrice ?? '0')) ??
                0;
            compareResult = aRate.compareTo(bRate);
            break;
          case 7: // Brokerage
            compareResult =
                (double.tryParse(a.tradeBrokerage ?? '0') ?? 0)
                    .compareTo(
                        double.tryParse(b.tradeBrokerage ?? '0') ?? 0);
            break;
          case 9: // Net Total
            final aAmt = double.tryParse(
                    a.buySale == 'BUY' ? (a.buyAmount ?? '0') : (a.sellAmount ?? '0')) ??
                0;
            final bAmt = double.tryParse(
                    b.buySale == 'BUY' ? (b.buyAmount ?? '0') : (b.sellAmount ?? '0')) ??
                0;
            compareResult = aAmt.compareTo(bAmt);
            break;
        }
        return _sortAscending ? compareResult : -compareResult;
      });
    }

    final bool hasData = sortedTrades.isNotEmpty;

    if (_selectedDate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 48,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary)),
            const SizedBox(height: 12),
            Text(
              'Select a date from the calendar to view contract notes',
              style: MyntWebTextStyles.bodySmall(context,
                  fontWeight: MyntFonts.medium),
            ),
          ],
        ),
      );
    }

    // Check settlement from Data level first, then top-level model
    final settlementData = (contractData?.settlement != null && contractData!.settlement!.isNotEmpty)
        ? contractData.settlement!
        : ledgerprovider.contractNoteModel?.settlement;
    final hasSettlement = settlementData != null && settlementData.isNotEmpty;

    return Column(
      children: [
        // Trade table
        Expanded(
          flex: hasSettlement ? 3 : 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              final double col0 = totalWidth * 0.10; // Symbol
              final double col1 = totalWidth * 0.05; // Exchange
              final double col2 = totalWidth * 0.14; // Order No
              final double col3 = totalWidth * 0.10; // Trade No
              final double col4 = totalWidth * 0.04; // B/S
              final double col5 = totalWidth * 0.05; // Qty
              final double col6 = totalWidth * 0.12; // Gross Rate
              final double col7 = totalWidth * 0.10; // Brokerage
              final double col8 = totalWidth * 0.15; // Net Rate
              final double col9 = totalWidth * 0.15; // Net Total

              final columnWidths = {
                0: shadcn.FixedTableSize(col0),
                1: shadcn.FixedTableSize(col1),
                2: shadcn.FixedTableSize(col2),
                3: shadcn.FixedTableSize(col3),
                4: shadcn.FixedTableSize(col4),
                5: shadcn.FixedTableSize(col5),
                6: shadcn.FixedTableSize(col6),
                7: shadcn.FixedTableSize(col7),
                8: shadcn.FixedTableSize(col8),
                9: shadcn.FixedTableSize(col9),
              };

              return Padding(
                padding: const EdgeInsets.only(right: 0),
                child: shadcn.OutlinedContainer(
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: false,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: Column(
                          children: [
                            // Fixed Header
                            shadcn.Table(
                              defaultRowHeight:
                                  const shadcn.FixedTableSize(50),
                              columnWidths: columnWidths,
                              rows: [
                                shadcn.TableHeader(
                                  cells: [
                                    _buildHeaderCell('Script', 0),
                                    _buildHeaderCell('Exch', 1),
                                    _buildHeaderCell('Order No', 2),
                                    _buildHeaderCell('Trade No', 3),
                                    _buildHeaderCell('B/S', 4),
                                    _buildHeaderCell('Qty', 5, true),
                                    _buildHeaderCell('Gross Rate', 6, true),
                                    _buildHeaderCell('Brokerage', 7, true),
                                    _buildHeaderCell('Net Rate', 8, true),
                                    _buildHeaderCell('Net Total', 9, true),
                                  ],
                                ),
                              ],
                            ),
                            // Scrollable Body
                            Expanded(
                              child: hasData
                                  ? SingleChildScrollView(
                                      controller: _tableScrollController,
                                      child: shadcn.Table(
                                        defaultRowHeight:
                                            const shadcn.FixedTableSize(50),
                                        columnWidths: columnWidths,
                                        rows: sortedTrades
                                            .take(displayedItemCount)
                                            .toList()
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final item = entry.value;
                                          final isBuy =
                                              item.buySale == 'BUY';

                                          return shadcn.TableRow(
                                            cells: [
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 0,
                                                totalColumns: 10,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    Text(
                                                      item.scripSymbol ??
                                                          '',
                                                      style: _getTextStyle(
                                                          context),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                    ),
                                                    if (item.instrumentType !=
                                                            null &&
                                                        item.instrumentType!
                                                            .isNotEmpty)
                                                      Text(
                                                        '${item.instrumentType}${item.strikePrice != null && item.strikePrice != '0' ? ' ${item.strikePrice} ${item.optionType ?? ''}' : ''}',
                                                        style: MyntWebTextStyles
                                                            .caption(
                                                          context,
                                                          color: resolveThemeColor(
                                                              context,
                                                              dark: MyntColors
                                                                  .textSecondaryDark,
                                                              light: MyntColors
                                                                  .textSecondary),
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 1,
                                                totalColumns: 10,
                                                child: Text(
                                                  item.tradeExchange ?? '',
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 2,
                                                totalColumns: 10,
                                                child: Text(
                                                  item.orderNumber ?? '',
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 3,
                                                totalColumns: 10,
                                                child: Text(
                                                  item.tradeNumber ?? '',
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 4,
                                                totalColumns: 10,
                                                child: Text(
                                                  item.buySale ?? '',
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: _getTextStyle(
                                                    context,
                                                    color: isBuy
                                                        ? resolveThemeColor(
                                                            context,
                                                            dark: MyntColors
                                                                .profitDark,
                                                            light: MyntColors
                                                                .profit)
                                                        : resolveThemeColor(
                                                            context,
                                                            dark: MyntColors
                                                                .lossDark,
                                                            light: MyntColors
                                                                .loss),
                                                  ),
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 5,
                                                totalColumns: 10,
                                                alignRight: true,
                                                child: Text(
                                                  (double.tryParse(item.quantity ?? '0') ?? 0).toStringAsFixed(0),
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 6,
                                                totalColumns: 10,
                                                alignRight: true,
                                                child: Text(
                                                  isBuy
                                                      ? (item.buyPrice ?? '')
                                                      : (item.sellPrice ?? ''),
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 7,
                                                totalColumns: 10,
                                                alignRight: true,
                                                child: Text(
                                                  item.tradeBrokerage ?? '',
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 8,
                                                totalColumns: 10,
                                                alignRight: true,
                                                child: Text(
                                                  isBuy
                                                      ? (item.netBuyPrice ?? '')
                                                      : (item.netSellPrice ?? ''),
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildCellWithHover(
                                                rowIndex: index,
                                                columnIndex: 9,
                                                totalColumns: 10,
                                                alignRight: true,
                                                child: Text(
                                                  isBuy
                                                      ? (item.buyAmount ?? '')
                                                      : (item.sellAmount ?? ''),
                                                  style: _getTextStyle(context),
                                                  softWrap: false,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : const Center(child: NoDataFound()),
                            ),
                            // Bottom summary bar inside table
                            if (hasData && contractData?.net != null && contractData!.net!.isNotEmpty)
                              _buildBottomSummaryBar(context, contractData.net!),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Settlement table below trade table
        if (hasSettlement)
          ...[
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: _buildSettlementTable(context, settlementData),
              ),
            ),
          ],
      ],
    );
  }

  // ─── Settlement Table ──────────────────────────────────────────────────

  Widget _buildSettlementTable(
      BuildContext context, Map<String, List<ContractNoteSettlement>> settlementData) {
    final exchanges = settlementData.keys.toList();

    // Settlement row definitions: label → field getter
    final rows = <MapEntry<String, String Function(ContractNoteSettlement)>>[
      MapEntry('Pay In/Pay Out Obligation', (s) => s.payinout ?? '0'),
      MapEntry('Taxable Value Of Supply (Brokerage)', (s) => s.brokerage ?? '0'),
      MapEntry('Taxable Value Of Supply (Tot)', (s) => s.tot ?? '0'),
      MapEntry('CGST* RATE:9% AMOUNT (RS.)', (s) => s.cgst ?? '0'),
      MapEntry('SGST* RATE:9% AMOUNT (RS.)', (s) => s.sgst ?? '0'),
      MapEntry('Net Amount Receivable/Payable By Client', (s) => s.netAmt ?? '0'),
    ];

    return shadcn.OutlinedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Settlement',
              style: MyntWebTextStyles.body(context,
                  fontWeight: MyntFonts.semiBold),
            ),
          ),
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: resolveThemeColor(context,
                      dark: MyntColors.cardBorderDark,
                      light: MyntColors.cardBorder),
                ),
                top: BorderSide(
                  color: resolveThemeColor(context,
                      dark: MyntColors.cardBorderDark,
                      light: MyntColors.cardBorder),
                ),
              ),
              color: resolveThemeColor(context,
                  dark: MyntColors.cardDark, light: const Color(0xFFF6F8FA)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: _getHeaderStyle(context),
                  ),
                ),
                ...exchanges.map((ex) => Expanded(
                      flex: 2,
                      child: Text(
                        ex,
                        textAlign: TextAlign.right,
                        style: _getHeaderStyle(context),
                      ),
                    )),
              ],
            ),
          ),
          // Data rows
          ...rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final row = entry.value;
            final isAlternate = idx.isEven;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isAlternate
                    ? Colors.transparent
                    : resolveThemeColor(context,
                        dark: MyntColors.cardDark.withValues(alpha: 0.5),
                        light: const Color(0xFFF9FAFB)),
                border: Border(
                  bottom: BorderSide(
                    color: resolveThemeColor(context,
                        dark: MyntColors.cardBorderDark.withValues(alpha: 0.5),
                        light: MyntColors.cardBorder.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.key,
                      style: _getTextStyle(context),
                    ),
                  ),
                  ...exchanges.map((ex) {
                    final settlements = settlementData[ex] ?? [];
                    final value = settlements.isNotEmpty
                        ? row.value(settlements.first)
                        : '0';
                    return Expanded(
                      flex: 2,
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: _getTextStyle(context),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Bottom Summary Bar ───────────────────────────────────────────────

  Widget _buildBottomSummaryBar(
      BuildContext context, Map<String, List<ContractNoteNet>> netData) {
    // Aggregate totals across all scrips
    double totalBuyQty = 0;
    double totalBuyAmt = 0;
    double totalSellQty = 0;
    double totalSellAmt = 0;
    double totalBuyRate = 0;
    double totalSellRate = 0;

    for (final entry in netData.values) {
      for (final net in entry) {
        totalBuyQty += double.tryParse(net.buyQuantity ?? '0') ?? 0;
        totalBuyAmt += double.tryParse(net.buyAmount ?? '0') ?? 0;
        totalSellQty += double.tryParse(net.sellQuantity ?? '0') ?? 0;
        totalSellAmt += double.tryParse(net.sellAmount ?? '0') ?? 0;
      }
    }

    totalBuyRate = totalBuyQty > 0 ? totalBuyAmt / totalBuyQty : 0;
    totalSellRate = totalSellQty > 0 ? totalSellAmt / totalSellQty : 0;
    final netTotal = totalSellAmt - totalBuyAmt;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder),
          ),
        ),
        color: resolveThemeColor(context,
            dark: MyntColors.cardDark, light: const Color(0xFFF6F8FA)),
      ),
      child: Row(
        children: [
          // Total Buy
          Text(
            'Total Buy:  ${totalBuyQty.toStringAsFixed(0)} @ ${totalBuyRate.toStringAsFixed(4)} = ${totalBuyAmt.toStringAsFixed(4)}',
            style: MyntWebTextStyles.bodySmall(context,
                fontWeight: MyntFonts.medium),
          ),
          const Spacer(),
          // Total Sell
          Text(
            'Total Sell :  ${totalSellQty.toStringAsFixed(0)} @ ${totalSellRate.toStringAsFixed(4)} = ${totalSellAmt.toStringAsFixed(4)}',
            style: MyntWebTextStyles.bodySmall(context,
                fontWeight: MyntFonts.medium),
          ),
          const Spacer(),
          // Net
          Text(
            'Net : ${netTotal.toStringAsFixed(4)}',
            style: MyntWebTextStyles.bodySmall(context,
                fontWeight: MyntFonts.semiBold,
                color: netTotal >= 0
                    ? resolveThemeColor(context,
                        dark: MyntColors.profitDark, light: MyntColors.profit)
                    : resolveThemeColor(context,
                        dark: MyntColors.lossDark, light: MyntColors.loss)),
          ),
        ],
      ),
    );
  }

  // ─── Right Panel (Calendar) ──────────────────────────────────────────

  // Widget _buildRightPanel(
  //     BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         _buildCalendar(context, theme, ledgerprovider),
  //       ],
  //     ),
  //   );
  // }

  // ─── Calendar ─────────────────────────────────────────────────────────

  Widget _buildCalendar(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    final daysToDisplay = _buildMonthDays(_calendarMonth);
    final weeks = _chunkDays(daysToDisplay, 7);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolveThemeColor(context,
              dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder),
        ),
        color: resolveThemeColor(context,
            dark: MyntColors.cardDark, light: MyntColors.card),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(
                        _calendarMonth.year, _calendarMonth.month - 1, 1);
                  });
                  ledgerprovider.fetchContractDocuments(
                      _calendarMonth.year, _calendarMonth.month);
                },
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_calendarMonth),
                style: MyntWebTextStyles.bodySmall(context,
                    fontWeight: MyntFonts.semiBold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(
                        _calendarMonth.year, _calendarMonth.month + 1, 1);
                  });
                  ledgerprovider.fetchContractDocuments(
                      _calendarMonth.year, _calendarMonth.month);
                },
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((d) => SizedBox(
                      width: 34,
                      child: Center(
                        child: Text(
                          d,
                          style: MyntWebTextStyles.caption(
                            context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                            fontWeight: MyntFonts.semiBold,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          if (ledgerprovider.isContractCalendarLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            ...weeks.map((week) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: week
                        .map((day) =>
                            _buildDayBox(context, day, ledgerprovider))
                        .toList(),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildDayBox(
      BuildContext context, DateTime date, LDProvider ledgerprovider) {
    final docs = ledgerprovider.contractDocumentDetails[date] ?? [];
    final hasDoc = docs.isNotEmpty;
    final isOutsideMonth = date.month != _calendarMonth.month;
    final isSelected = _selectedDate != null &&
        _selectedDate!.year == date.year &&
        _selectedDate!.month == date.month &&
        _selectedDate!.day == date.day;

    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);

    Color bgColor;
    Color textColor;
    Border? border;
    if (isSelected) {
      bgColor = primaryColor;
      textColor = Colors.white;
    } else if (isOutsideMonth) {
      bgColor = Colors.transparent;
      textColor = resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark.withValues(alpha: 0.3),
          light: MyntColors.textSecondary.withValues(alpha: 0.3));
    } else if (hasDoc) {
      bgColor = primaryColor.withValues(alpha: 0.15);
      textColor = primaryColor;
      border = Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5);
    } else {
      bgColor = Colors.transparent;
      textColor = resolveThemeColor(context,
          dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    }

    return MouseRegion(
      cursor: !isOutsideMonth ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
      onTap: !isOutsideMonth
          ? () => _onDateTap(date, ledgerprovider)
          : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: border,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: MyntWebTextStyles.caption(
                  context,
                  color: textColor,
                  fontWeight:
                      (isSelected || hasDoc) ? MyntFonts.semiBold : MyntFonts.medium,
                ),
              ),
            ),
            if (hasDoc && !isOutsideMonth && !isSelected)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
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


  // ─── Table Cell Helpers ───────────────────────────────────────────────

  shadcn.TableCell _buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    required int totalColumns,
    VoidCallback? onTap,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == totalColumns - 1;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 12, 8);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(12, 8, 16, 8);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
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
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary)
                        .withValues(alpha: 0.08)
                    : null,
                alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }

  shadcn.TableCell _buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 9;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 0, 8, 0);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 0, 16, 0);
    } else {
      headerPadding =
          const EdgeInsets.symmetric(horizontal: 6, vertical: 0);
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
          alignment:
              alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: alignRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              if (alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              Text(
                label,
                style: _getHeaderStyle(context),
              ),
              if (!alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              if (!alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
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

  // ─── Calendar Helpers ─────────────────────────────────────────────────

  List<DateTime> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final days = <DateTime>[];

    final firstWeekday = firstDay.weekday;
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    final lastWeekday = lastDay.weekday;
    for (int i = 1; i <= 7 - lastWeekday; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }

    return days;
  }

  List<List<DateTime>> _chunkDays(List<DateTime> days, int chunkSize) {
    final chunks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += chunkSize) {
      final endIndex =
          (i + chunkSize > days.length) ? days.length : (i + chunkSize);
      chunks.add(days.sublist(i, endIndex));
    }
    return chunks;
  }
}
