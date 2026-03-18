// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../provider/ledger_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/common_search_fields_web.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../sharedWidget/scroll_to_load_mixin.dart';
import '../../../../utils/rupee_convert_format.dart';
import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../models/desk_reports_model/pnl_model.dart';
import '../../../../models/desk_reports_model/pnl_summary_model.dart';
import 'notional_pnl_download_helper.dart';

class NotionalPnlScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const NotionalPnlScreenWeb({super.key, this.onBack});

  @override
  ConsumerState<NotionalPnlScreenWeb> createState() =>
      _NotionalPnlScreenWebState();
}

class _NotionalPnlScreenWebState extends ConsumerState<NotionalPnlScreenWeb>
    with ScrollToLoadMixin {
  @override
  ScrollController get tableScrollController => _tableScrollController;
  final ScrollController _tableScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _withOpen = true;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Date range picker state
  bool _showDatePicker = false;
  late DateTime _leftMonth;
  late DateTime _rightMonth;
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;
  final GlobalKey _datePickerButtonKey = GlobalKey();
  OverlayEntry? _datePickerOverlay;

  @override
  void initState() {
    super.initState();
    initScrollToLoad();
    final now = DateTime.now();
    final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
    _leftMonth = DateTime(fyStartYear, 4);
    _rightMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _removeDatePickerOverlay();
    disposeScrollToLoad();
    _tableScrollController.dispose();
    _horizontalScrollController.dispose();
    _hoveredRowIndex.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _removeDatePickerOverlay() {
    _datePickerOverlay?.remove();
    _datePickerOverlay = null;
    if (_showDatePicker) {
      setState(() => _showDatePicker = false);
    }
  }

  void _toggleDatePicker(ThemesProvider theme, LDProvider ledger) {
    if (_showDatePicker) {
      _removeDatePickerOverlay();
      return;
    }

    final startStr = ledger.startDate.isNotEmpty ? ledger.startDate : _getDefaultStartDate();
    final endStr = ledger.today.isNotEmpty ? ledger.today : _getDefaultEndDate();
    _tempStartDate = _parseDate(startStr);
    _tempEndDate = _parseDate(endStr);
    if (_tempStartDate != null) {
      _leftMonth = DateTime(_tempStartDate!.year, _tempStartDate!.month);
    }
    if (_tempEndDate != null) {
      _rightMonth = DateTime(_tempEndDate!.year, _tempEndDate!.month);
    }
    if (!_rightMonth.isAfter(_leftMonth)) {
      _rightMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);
    }

    final keyContext = _datePickerButtonKey.currentContext;
    if (keyContext == null) return;

    setState(() => _showDatePicker = true);

    final RenderBox renderBox =
        keyContext.findRenderObject() as RenderBox;
    final buttonPos = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    _datePickerOverlay = OverlayEntry(
      builder: (context) => _PnlDatePickerOverlay(
        buttonOffset: Offset(buttonPos.dx, buttonPos.dy + buttonSize.height + 8),
        theme: theme,
        leftMonth: _leftMonth,
        rightMonth: _rightMonth,
        tempStartDate: _tempStartDate,
        tempEndDate: _tempEndDate,
        onClose: () => _removeDatePickerOverlay(),
        onApply: (start, end) {
          final fmt = DateFormat('dd/MM/yyyy');
          ledger.startDate = fmt.format(start);
          ledger.today = fmt.format(end);
          _fetchData();
          _removeDatePickerOverlay();
        },
        onQuickSelect: (preset) {
          _handleQuickSelect(preset, ledger);
          _removeDatePickerOverlay();
        },
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_datePickerOverlay!);
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}
    return null;
  }

  void _handleQuickSelect(String preset, LDProvider ledger) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (preset) {
      case 'Last 7 days':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'Last 30 days':
        start = now.subtract(const Duration(days: 30));
        break;
      case 'Current FY':
        final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
        start = DateTime(fyStartYear, 4, 1);
        end = DateTime(fyStartYear + 1, 3, 31);
        if (end.isAfter(now)) end = now;
        break;
      case 'Last FY':
        final fyStartYear = now.month >= 4 ? now.year - 1 : now.year - 2;
        start = DateTime(fyStartYear, 4, 1);
        end = DateTime(fyStartYear + 1, 3, 31);
        break;
      default:
        final year = int.tryParse(preset);
        if (year != null) {
          start = DateTime(year, 4, 1);
          end = DateTime(year + 1, 3, 31);
        } else {
          return;
        }
    }

    final fmt = DateFormat('dd/MM/yyyy');
    ledger.startDate = fmt.format(start);
    ledger.today = fmt.format(end);
    _fetchData();
  }

  void _fetchData() {
    resetDisplayCount();
    final ledger = ref.read(ledgerProvider);
    ledger.fetchpnldata(
      context,
      ledger.startDate.isNotEmpty ? ledger.startDate : _getDefaultStartDate(),
      ledger.today.isNotEmpty ? ledger.today : _getDefaultEndDate(),
      _withOpen,
    );
  }

  String _getDefaultStartDate() {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    return '01/04/$startYear';
  }

  String _getDefaultEndDate() {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy').format(now);
  }

  double _parseDbl(String? val) {
    if (val == null) return 0;
    return double.tryParse(val) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);
    final ledger = ref.watch(ledgerProvider);
    final pnlData = ledger.pnlAllData;
    final isLoading = ledger.pnlloading;

    return Scaffold(
      backgroundColor: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ledger, pnlData),
          if (isLoading)
            Expanded(child: Center(child: MyntLoader.simple()))
          else if (pnlData == null ||
              (pnlData.transactions == null || pnlData.transactions!.isEmpty))
            Expanded(child: Center(child: NoDataFound(secondaryEnabled: false)))
          else
            Expanded(child: _buildBody(context, pnlData, ledger)),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, LDProvider ledger, PnlModel? pnlData) {
    final transactions = pnlData?.transactions ?? [];
    final filtered = _getFilteredTransactions(transactions);
    final symbolCount = filtered.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              if (widget.onBack != null) ...[
                CustomBackBtn(onBack: widget.onBack),
                const SizedBox(width: 8),],
              if (widget.onBack != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notional P&L',
                      style: MyntWebTextStyles.title(context,
                          fontWeight: MyntFonts.semiBold,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary))),
                  // const SizedBox(height: 2),
                  // Text('Notional P&L of your trades.',
                  //     style: MyntWebTextStyles.caption(context,
                  //         color: resolveThemeColor(context,
                  //             dark: MyntColors.textSecondaryDark,
                  //             light: MyntColors.textSecondary))),
                ],
              ),
              const Spacer(),
              // Symbol count
              Text('$symbolCount Symbols',
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.semiBold,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary))),
              const SizedBox(width: 16),
              // Download button
              PopupMenuButton<String>(
                icon: Icon(Icons.download,
                    size: 20,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Download',
                color: resolveThemeColor(context,
                    dark: MyntColors.cardDark, light: MyntColors.card),
                onSelected: (value) {
                  final transactions = pnlData?.transactions ?? [];
                  final filteredTransactions = _getFilteredTransactions(transactions);

                  if (filteredTransactions.isEmpty || pnlData == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No data to download')),
                    );
                    return;
                  }

                  final pref = locator<Preferences>();
                  final clientId = pref.clientId ?? '';
                  final clientName = pref.clientName ?? '';
                  final dateRange =
                      '${ledger.startDate.isNotEmpty ? ledger.startDate : _getDefaultStartDate()} to ${ledger.today.isNotEmpty ? ledger.today : _getDefaultEndDate()}';

                  if (value == 'pdf') {
                    NotionalPnlDownloadHelper.downloadPdf(
                      transactions: filteredTransactions,
                      pnlData: pnlData,
                      clientId: clientId,
                      clientName: clientName,
                      dateRange: dateRange,
                    );
                  } else if (value == 'excel') {
                    NotionalPnlDownloadHelper.downloadExcel(
                      transactions: filteredTransactions,
                      pnlData: pnlData,
                      clientId: clientId,
                      clientName: clientName,
                      dateRange: dateRange,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 18, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text('Download PDF',
                            style: TextStyle(
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                            )),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excel',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, size: 18, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text('Download Excel',
                            style: TextStyle(
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Date range
              InkWell(
                key: _datePickerButtonKey,
                onTap: () => _toggleDatePicker(ref.read(themeProvider), ledger),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: resolveThemeColor(context,
                            dark: MyntColors.dividerDark,
                            light: MyntColors.divider)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16,
                          color: resolveThemeColor(context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary)),
                      const SizedBox(width: 8),
                      Text(
                          '${ledger.startDate.isNotEmpty ? ledger.startDate : _getDefaultStartDate()}_to_${ledger.today.isNotEmpty ? ledger.today : _getDefaultEndDate()}',
                          style: MyntWebTextStyles.bodySmall(context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                              fontWeight: MyntFonts.medium)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Search
              SizedBox(
                width: 220,
                height: 36,
                child: MyntSearchTextField(
                  controller: _searchController,
                  placeholder: 'Search',
                  leadingIcon: 'assets/icon/search.svg',
                  onChanged: (val) => setState(() {
                    _searchQuery = val;
                    displayedItemCount = ScrollToLoadMixin.itemsPerPage;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              // Filter button
              Builder(
                builder: (buttonContext) {
                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showFilterPopover(buttonContext),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icon/search-filter.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showFilterPopover(BuildContext buttonContext) {
    final filters = ['All', 'NSE_CASH', 'BSE_CASH', 'NSE_FNO', /* 'COMM', */ 'CDS'];
    shadcn.showPopover(
      context: buttonContext,
      alignment: Alignment.bottomCenter,
      offset: const Offset(0, 8),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(buttonContext).borderRadiusLg,
      ),
      builder: (popoverContext) {
        return Container(
          width: 160,
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: filters.map((f) {
              final isSelected = _selectedFilter == f;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = f;
                    displayedItemCount = ScrollToLoadMixin.itemsPerPage;
                  });
                  shadcn.closeOverlay(popoverContext);
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: isSelected
                      ? resolveThemeColor(context,
                              dark: MyntColors.primaryDark,
                              light: MyntColors.primary)
                          .withValues(alpha: 0.1)
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          f,
                          style: MyntWebTextStyles.bodySmall(context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary),
                              fontWeight: isSelected
                                  ? MyntFonts.semiBold
                                  : MyntFonts.medium),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check,
                            size: 16,
                            color: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ─── Body ────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, PnlModel pnlData, LDProvider ledger) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards
          _buildStatCards(context, pnlData),
          const SizedBox(height: 12),
          // With open balance checkbox
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _withOpen,
                  onChanged: (val) {
                    setState(() {
                      _withOpen = val ?? true;
                      displayedItemCount = ScrollToLoadMixin.itemsPerPage;
                    });
                    _fetchData();
                  },
                  activeColor: resolveThemeColor(context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text('With open balance',
                  style: MyntWebTextStyles.bodySmall(context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary))),
              const Spacer(),
              Text('* Buy rate and Sell rate is inclusive of brokerage',
                  style: MyntWebTextStyles.bodyMedium(context,
                      color: resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error), fontWeight: MyntFonts.medium)),
            ],
          ),
          const SizedBox(height: 12),
          // Table
          Expanded(child: _buildTable(context, pnlData)),
        ],
      ),
    );
  }

  // ─── Stat Cards ──────────────────────────────────────────────────────

  Widget _buildStatCards(BuildContext context, PnlModel pnlData) {
    final transactions = pnlData.transactions ?? [];
    final expenses = pnlData.expenses ?? [];

    // Calculate segment totals
    double equityTotal = 0;
    double fnoTotal = 0;
    // double commodityTotal = 0;
    double currencyTotal = 0;

    for (final t in transactions) {
      final pnl = _parseDbl(t.nOTPROFIT);
      final code = t.companyCode ?? '';
      if (code == 'NSE_CASH' || code == 'BSE_CASH') {
        equityTotal += pnl;
      } else if (code == 'NSE_FNO' || code == 'BSE_FNO') {
        fnoTotal += pnl;
      // } else if (code == 'COMM') {
      //   commodityTotal += pnl;
      } else if (code == 'CDS') {
        currencyTotal += pnl;
      }
    }

    double chargesTotal = 0;
    for (final e in expenses) {
      chargesTotal += _parseDbl(e.nOTPROFIT);
    }

    final netNotional = _parseDbl(pnlData.netPnl);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 5 : 3;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 110,
          ),
          children: [
            _statCard(context, 'Net Notional', netNotional),
            _statCard(context, 'Equity', equityTotal),
            _statCard(context, 'FNO', fnoTotal),
            // _statCard(context, 'Commodity', commodityTotal),
            _statCard(context, 'Currency', currencyTotal),
            _statCard(context, 'All Charges & taxes', chargesTotal,
                isCharges: true),
          ],
        );
      },
    );
  }

  Widget _statCard(BuildContext context, String label, double value,
      {bool isCharges = false}) {
    final valueColor = value == 0
        ? resolveThemeColor(context,
            dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)
        : value < 0
            ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
            : resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success);

    return MouseRegion(
      cursor: isCharges ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isCharges
            ? () => _showChargesDialog(context)
            : null,
        child: shadcn.Theme(
          data: shadcn.Theme.of(context).copyWith(radius: () => 0.3),
          child: shadcn.Card(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(label,
                            style: MyntWebTextStyles.bodySmall(context,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary),
                                fontWeight: MyntFonts.medium)),
                      ),
                      if (isCharges)
                        Icon(Icons.arrow_forward_ios,
                            size: 10,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(value.toStringAsFixed(2).toIndianRupee(),
                      style: MyntWebTextStyles.head(context,
                          color: valueColor, fontWeight: MyntFonts.medium)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Table ───────────────────────────────────────────────────────────

  List<Transactions> _getFilteredTransactions(List<Transactions> transactions) {
    var filtered = transactions;

    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((t) => t.companyCode == _selectedFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toUpperCase();
      filtered = filtered
          .where((t) =>
              (t.sCRIPSYMBOL ?? '').toUpperCase().contains(q))
          .toList();
    }

    // Sort
    filtered.sort((a, b) {
      dynamic aVal, bVal;
      switch (_sortColumnIndex) {
        case 0:
          aVal = (a.sCRIPSYMBOL ?? '').toUpperCase();
          bVal = (b.sCRIPSYMBOL ?? '').toUpperCase();
          break;
        case 1:
          aVal = _parseDbl(a.bUYQUANTITY);
          bVal = _parseDbl(b.bUYQUANTITY);
          break;
        case 2:
          aVal = _parseDbl(a.bUYRATE);
          bVal = _parseDbl(b.bUYRATE);
          break;
        case 3:
          aVal = _parseDbl(a.sALEQUANTITY);
          bVal = _parseDbl(b.sALEQUANTITY);
          break;
        case 4:
          aVal = _parseDbl(a.sALERATE);
          bVal = _parseDbl(b.sALERATE);
          break;
        case 5:
          aVal = _parseDbl(a.nETQUANTITY);
          bVal = _parseDbl(b.nETQUANTITY);
          break;
        case 6:
          aVal = _parseDbl(a.nETRATE);
          bVal = _parseDbl(b.nETRATE);
          break;
        case 7:
          aVal = _parseDbl(a.cLOSINGPRICE);
          bVal = _parseDbl(b.cLOSINGPRICE);
          break;
        case 8:
          aVal = _parseDbl(a.nOTPROFIT);
          bVal = _parseDbl(b.nOTPROFIT);
          break;
        default:
          aVal = (a.sCRIPSYMBOL ?? '');
          bVal = (b.sCRIPSYMBOL ?? '');
      }
      final cmp = Comparable.compare(aVal as Comparable, bVal as Comparable);
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
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

  Widget _buildTable(BuildContext context, PnlModel pnlData) {
    final transactions = pnlData.transactions ?? [];
    final filtered = _getFilteredTransactions(transactions);

    if (filtered.isEmpty) {
      return Center(child: NoDataFound(secondaryEnabled: false));
    }

    final headers = [
      'Symbol',
      'Buy Qty',
      'Buy Rate',
      'Sell Qty',
      'Sell Rate',
      'Net Qty',
      'Net Rate',
      'Close price',
      'Notional',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Symbol gets more space for long derivative names
        // Symbol gets more space for long derivative names (22%)
        // Rate+Amount columns (2-line) get 11%, Qty columns get 7%
        // Total: 22+7+11+7+11+7+11+10+14 = 100%
        final columnWidths = <int, shadcn.TableSize>{
          0: shadcn.FixedTableSize(availableWidth * 0.22), // Symbol
          1: shadcn.FixedTableSize(availableWidth * 0.07), // Buy Qty
          2: shadcn.FixedTableSize(availableWidth * 0.11), // Buy Rate + Amt
          3: shadcn.FixedTableSize(availableWidth * 0.07), // Sell Qty
          4: shadcn.FixedTableSize(availableWidth * 0.11), // Sell Rate + Amt
          5: shadcn.FixedTableSize(availableWidth * 0.07), // Net Qty
          6: shadcn.FixedTableSize(availableWidth * 0.11), // Net Rate + Amt
          7: shadcn.FixedTableSize(availableWidth * 0.10), // Close Price
          8: shadcn.FixedTableSize(availableWidth * 0.14), // Notional
        };

        return shadcn.OutlinedContainer(
          child: Column(
            children: [
              // Header
              shadcn.Table(
                defaultRowHeight: const shadcn.FixedTableSize(44),
                columnWidths: columnWidths,
                rows: [
                  shadcn.TableHeader(
                    cells: headers
                        .asMap()
                        .entries
                        .map((e) =>
                            _buildHeaderCell(e.value, e.key, e.key > 0))
                        .toList(),
                  ),
                ],
              ),
              // Data rows
              Expanded(
                child: SingleChildScrollView(
                  controller: _tableScrollController,
                  child: shadcn.Table(
                    defaultRowHeight: const shadcn.FixedTableSize(55),
                    columnWidths: columnWidths,
                    rows: takeDisplayed(filtered).asMap().entries.map((entry) {
                      return _buildDataRow(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ),
              // // Totals footer
              // _buildTotalsFooter(context, filtered),
            ],
          ),
        );
      },
    );
  }

  shadcn.TableCell _buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirst = columnIndex == 0;
    final isLast = columnIndex == 8;

    EdgeInsets padding;
    if (isFirst) {
      padding = const EdgeInsets.fromLTRB(16, 0, 8, 0);
    } else if (isLast) {
      padding = const EdgeInsets.fromLTRB(8, 0, 16, 0);
    } else {
      padding = const EdgeInsets.symmetric(horizontal: 6);
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
          padding: padding,
          alignment:
              alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              if (alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 2),
              Text(label, style: _getHeaderStyle(context)),
              if (!alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 2),
              if (!alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
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

  shadcn.TableRow _buildDataRow(int index, Transactions t) {
    final buyQty = _parseDbl(t.bUYQUANTITY);
    final buyRate = _parseDbl(t.bUYRATE);
    final buyAmt = _parseDbl(t.bUYAMOUNT);
    final sellQty = _parseDbl(t.sALEQUANTITY);
    final sellRate = _parseDbl(t.sALERATE);
    final sellAmt = _parseDbl(t.sALEAMOUNT);
    final netQty = _parseDbl(t.nETQUANTITY);
    final netRate = _parseDbl(t.nETRATE);
    final netAmt = _parseDbl(t.nETAMOUNT);
    final closePrice = _parseDbl(t.cLOSINGPRICE);
    final notional = _parseDbl(t.nOTPROFIT);
    final openQty = _parseDbl(t.openQUANTITY);
    final openAmt = _parseDbl(t.openAMOUNT);

    return shadcn.TableRow(
      cells: [
        // Symbol
        _buildCell(
          child: InkWell(
            onTap: () => _showDetailedPnlDialog(context, t),
            child: Row(
              children: [
                Flexible(
                  child: Text(t.sCRIPSYMBOL ?? '',
                      style: _getTextStyle(context, fontWeight: MyntFonts.semiBold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ),
                if (openQty != 0) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message: 'Open Quantity',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_formatQty(openQty)} @${_formatRate(openAmt)}',
                        style: MyntWebTextStyles.bodySmall(context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary),
                            fontWeight: MyntFonts.medium),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(Icons.play_arrow,
                    size: 12,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary)),
              ],
            ),
          ),
          rowIndex: index,
          columnIndex: 0,
        ),
        // Buy Qty
        _buildCell(
          child: Text(_formatQty(buyQty), style: _getTextStyle(context), softWrap: false, overflow: TextOverflow.ellipsis),
          rowIndex: index,
          columnIndex: 1,
          alignRight: true,
        ),
        // Buy Rate (rate + amount)
        _buildCell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatRate(buyRate), style: _getTextStyle(context), softWrap: false, overflow: TextOverflow.ellipsis),
              Text(_formatRate(buyAmt),
                  softWrap: false, overflow: TextOverflow.ellipsis,
                  style: MyntWebTextStyles.caption(context,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary)),
            ],
          ),
          rowIndex: index,
          columnIndex: 2,
          alignRight: true,
        ),
        // Sell Qty
        _buildCell(
          child: Text(_formatQty(sellQty), style: _getTextStyle(context), softWrap: false, overflow: TextOverflow.ellipsis),
          rowIndex: index,
          columnIndex: 3,
          alignRight: true,
        ),
        // Sell Rate (rate + amount)
        _buildCell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatRate(sellRate), style: _getTextStyle(context), softWrap: false, overflow: TextOverflow.ellipsis),
              Text(_formatRate(sellAmt),
                  softWrap: false, overflow: TextOverflow.ellipsis,
                  style: MyntWebTextStyles.caption(context,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary)),
            ],
          ),
          rowIndex: index,
          columnIndex: 4,
          alignRight: true,
        ),
        // Net Qty
        _buildCell(
          child: Text(_formatQty(netQty), style: _getTextStyle(context), softWrap: false, overflow: TextOverflow.ellipsis),
          rowIndex: index,
          columnIndex: 5,
          alignRight: true,
        ),
        // Net Rate (rate + amount)
        _buildCell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatRate(netRate), style: _getTextStyle(context), softWrap: false, overflow: TextOverflow.ellipsis),
              Text(_formatRate(netAmt),
                  softWrap: false, overflow: TextOverflow.ellipsis,
                  style: MyntWebTextStyles.caption(context,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary)),
            ],
          ),
          rowIndex: index,
          columnIndex: 6,
          alignRight: true,
        ),
        // Close Price
        _buildCell(
          child: Text(_formatRate(closePrice), style: _getTextStyle(context), softWrap: false, overflow: TextOverflow.ellipsis),
          rowIndex: index,
          columnIndex: 7,
          alignRight: true,
        ),
        // Notional
        _buildCell(
          child: Text(
            _formatRate(notional),
            softWrap: false, overflow: TextOverflow.ellipsis,
            style: _getTextStyle(context,
                color: notional < 0
                    ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
                    : notional > 0
                        ? resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success)
                        : null),
          ),
          rowIndex: index,
          columnIndex: 8,
          alignRight: true,
        ),
      ],
    );
  }

  shadcn.TableCell _buildCell({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
  }) {
    final isFirst = columnIndex == 0;
    final isLast = columnIndex == 8;

    EdgeInsets cellPadding;
    if (isFirst) {
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 8, 8);
    } else if (isLast) {
      cellPadding = const EdgeInsets.fromLTRB(8, 8, 16, 8);
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
            final isHovered = hoveredIndex == rowIndex;
            return Container(
              padding: cellPadding,
              alignment:
                  alignRight ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: isHovered
                    ? resolveThemeColor(context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary)
                        .withValues(alpha: 0.04)
                    : null,
                border: Border(
                  bottom: BorderSide(
                    color: resolveThemeColor(context,
                            dark: MyntColors.dividerDark,
                            light: MyntColors.divider)
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  // ─── Totals Footer ─────────────────────────────────────────────────

  Widget _buildTotalsFooter(BuildContext context, List<Transactions> filtered) {
    double totalBuyQty = 0;
    double totalBuyAmt = 0;
    double totalSellQty = 0;
    double totalSellAmt = 0;

    for (final t in filtered) {
      totalBuyQty += _parseDbl(t.bUYQUANTITY);
      totalBuyAmt += _parseDbl(t.bUYAMOUNT);
      totalSellQty += _parseDbl(t.sALEQUANTITY);
      totalSellAmt += _parseDbl(t.sALEAMOUNT);
    }

    final totalBuyRate = totalBuyQty > 0 ? totalBuyAmt / totalBuyQty : 0.0;
    final totalSellRate = totalSellQty > 0 ? totalSellAmt / totalSellQty : 0.0;
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
          Text(
            'Total Buy:  ${totalBuyQty.toStringAsFixed(0)} @ ${totalBuyRate.toStringAsFixed(4)} = ${totalBuyAmt.toStringAsFixed(4)}',
            style: MyntWebTextStyles.bodySmall(context,
                fontWeight: MyntFonts.medium),
          ),
          const Spacer(),
          Text(
            'Total Sell :  ${totalSellQty.toStringAsFixed(0)} @ ${totalSellRate.toStringAsFixed(4)} = ${totalSellAmt.toStringAsFixed(4)}',
            style: MyntWebTextStyles.bodySmall(context,
                fontWeight: MyntFonts.medium),
          ),
          const Spacer(),
          Text(
            'Net : ${netTotal.toStringAsFixed(4)}',
            style: MyntWebTextStyles.bodySmall(context,
                fontWeight: MyntFonts.semiBold,
                color: netTotal >= 0
                    ? resolveThemeColor(context,
                        dark: MyntColors.successDark, light: MyntColors.success)
                    : resolveThemeColor(context,
                        dark: MyntColors.errorDark, light: MyntColors.error)),
          ),
        ],
      ),
    );
  }

  // ─── Charges Dialog ─────────────────────────────────────────────────

  void _showChargesDialog(BuildContext context) {
    final ledger = ref.read(ledgerProvider);
    final pnlData = ledger.pnlAllData;
    final expenses = pnlData?.expenses ?? [];

    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);

    double totalCharges = 0;
    for (final e in expenses) {
      totalCharges += _parseDbl(e.nOTPROFIT);
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: resolveThemeColor(context,
              dark: MyntColors.cardDark, light: MyntColors.card),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Text('All Charges & Taxes',
                          style: MyntWebTextStyles.head(context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.close,
                              size: 24, color: secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // Table header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: borderColor)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text('Charge Type',
                                    style: MyntWebTextStyles.para(context,
                                        darkColor:
                                            MyntColors.textSecondaryDark,
                                        lightColor: MyntColors.textSecondary,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Amount',
                                    textAlign: TextAlign.right,
                                    style: MyntWebTextStyles.para(context,
                                        darkColor:
                                            MyntColors.textSecondaryDark,
                                        lightColor: MyntColors.textSecondary,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                        // Rows
                        if (expenses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text('No data available',
                                style: MyntWebTextStyles.body(context,
                                    color: secondaryColor)),
                          )
                        else
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 450),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: expenses.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1, color: borderColor),
                              itemBuilder: (context, index) {
                                final e = expenses[index];
                                final profit = _parseDbl(e.nOTPROFIT);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                            e.sCRIPSYMBOL ?? '',
                                            style: MyntWebTextStyles.body(
                                                context,
                                                darkColor: MyntColors
                                                    .textPrimaryDark,
                                                lightColor:
                                                    MyntColors.textPrimary,
                                                fontWeight:
                                                    MyntFonts.medium)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            '${profit < 0 ? '- ' : ''}${profit.abs().toStringAsFixed(2)}',
                                            textAlign: TextAlign.right,
                                            style: MyntWebTextStyles.body(
                                                context,
                                                color: profit < 0
                                                    ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
                                                    : profit > 0
                                                        ? resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success)
                                                        : textColor,
                                                fontWeight:
                                                    MyntFonts.medium)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        // Total row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: borderColor)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text('Total',
                                    style: MyntWebTextStyles.body(context,
                                        darkColor: MyntColors.textPrimaryDark,
                                        lightColor: MyntColors.textPrimary,
                                        fontWeight: MyntFonts.semiBold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                    '${totalCharges < 0 ? '- ' : ''}${totalCharges.abs().toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: MyntWebTextStyles.body(context,
                                        color: totalCharges < 0
                                            ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
                                            : totalCharges > 0
                                                ? resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success)
                                                : textColor,
                                        fontWeight: MyntFonts.semiBold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Detailed P&L Dialog ─────────────────────────────────────────────

  void _showDetailedPnlDialog(BuildContext context, Transactions t) {
    final ledger = ref.read(ledgerProvider);
    final from = ledger.startDate.isNotEmpty
        ? ledger.startDate
        : _getDefaultStartDate();
    final to = ledger.today.isNotEmpty ? ledger.today : _getDefaultEndDate();
    final script = t.sCRIPSYMBOL ?? '';
    final cocd = t.companyCode ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return _DetailedPnlDialog(
          script: script,
          cocd: cocd,
          from: from,
          to: to,
          ledger: ledger,
          parentContext: context,
        );
      },
    );
  }

  // ─── Download Dialog ─────────────────────────────────────────────────

  void _showDownloadDialog(BuildContext context, LDProvider ledger) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Download Notional P&L',
                    style: MyntWebTextStyles.body(context,
                        fontWeight: MyntFonts.semiBold,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary))),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _downloadOption(context, 'PDF', Icons.picture_as_pdf, () {
                      Navigator.pop(ctx);
                      // Download uses pdfdownloadforpnl with specific params
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _downloadOption(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 40, color: resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download,
                    size: 14,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary)),
                const SizedBox(width: 4),
                Text(label,
                    style: MyntWebTextStyles.bodySmall(context,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  String _formatQty(double val) => val.toStringAsFixed(0);

  String _formatRate(double val) => val.toStringAsFixed(2);

  TextStyle _getTextStyle(BuildContext context,
      {Color? color, FontWeight? fontWeight}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: fontWeight ?? MyntFonts.medium,
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
}

// ─── Detailed P&L Dialog Widget ───────────────────────────────────────

class _DetailedPnlDialog extends StatefulWidget {
  final String script;
  final String cocd;
  final String from;
  final String to;
  final LDProvider ledger;
  final BuildContext parentContext;

  const _DetailedPnlDialog({
    required this.script,
    required this.cocd,
    required this.from,
    required this.to,
    required this.ledger,
    required this.parentContext,
  });

  @override
  State<_DetailedPnlDialog> createState() => _DetailedPnlDialogState();
}

class _DetailedPnlDialogState extends State<_DetailedPnlDialog> {
  bool _loading = true;
  PnlSummaryModel? _data;
  String _searchQuery = '';
  final TextEditingController _dialogSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  @override
  void dispose() {
    _dialogSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    try {
      final result = await widget.ledger.api
          .getPnlSummary(widget.script, widget.cocd, widget.from, widget.to);
      if (mounted) {
        setState(() {
          _data = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  double _parseDbl(String? val) {
    if (val == null) return 0;
    return double.tryParse(val) ?? 0;
  }

  String _formatRate(double val) => val.toStringAsFixed(2);

  String _formatQty(double val) => val.toStringAsFixed(0);

  List<Data> _getFiltered() {
    final all = _data?.data ?? [];
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toUpperCase();
    return all
        .where((d) => (d.tRADEDATE ?? '').toUpperCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFiltered();

    // Calculate total P&L
    double totalPnl = 0;
    for (final d in (_data?.data ?? [])) {
      totalPnl += _parseDbl(d.nETAMT);
    }

    return Dialog(
      backgroundColor: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 1100,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detailed P&L',
                          style: MyntWebTextStyles.body(context,
                              fontWeight: MyntFonts.semiBold,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary))),
                      const SizedBox(height: 2),
                      Text(widget.script,
                          style: MyntWebTextStyles.caption(context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary))),
                    ],
                  ),
                ),
                // Search
                SizedBox(
                  width: 220,
                  height: 36,
                  child: MyntSearchTextField(
                    controller: _dialogSearchController,
                    placeholder: 'Search',
                    leadingIcon: 'assets/icon/search.svg',
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close,
                      size: 20,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Table
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (filtered.isEmpty)
              Expanded(child: Center(child: NoDataFound(secondaryEnabled: false)))
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final dateW = w * 0.14;
                    final colW = (w - dateW) / 7;
                    final columnWidths = <int, shadcn.TableSize>{
                      0: shadcn.FixedTableSize(dateW),
                      for (int i = 1; i < 8; i++)
                        i: shadcn.FixedTableSize(colW),
                    };

                    return shadcn.OutlinedContainer(
                      child: Column(
                        children: [
                          // Header
                          shadcn.Table(
                            defaultRowHeight:
                                const shadcn.FixedTableSize(44),
                            columnWidths: columnWidths,
                            rows: [
                              shadcn.TableHeader(
                                cells: [
                                  _headerCell('Trade Date', false),
                                  _headerCell('Buy Qty', true),
                                  _headerCell('Buy Rate', true),
                                  _headerCell('Sell Qty', true),
                                  _headerCell('Sell Rate', true),
                                  _headerCell('Net Qty', true),
                                  _headerCell('Net Rate', true),
                                  _headerCell('Notional', true),
                                ],
                              ),
                            ],
                          ),
                          // Data
                          Expanded(
                            child: SingleChildScrollView(
                              child: shadcn.Table(
                                defaultRowHeight:
                                    const shadcn.FixedTableSize(55),
                                columnWidths: columnWidths,
                                rows: filtered.map((d) {
                                  final buyQty = _parseDbl(d.bQTY);
                                  final buyRate = _parseDbl(d.bRATE);
                                  final buyAmt = _parseDbl(d.bAMT);
                                  final sellQty = _parseDbl(d.sQTY);
                                  final sellRate = _parseDbl(d.sRATE);
                                  final sellAmt = _parseDbl(d.sAMT);
                                  final netQty = _parseDbl(d.nETQTY);
                                  final netRate = _parseDbl(d.nRATE);
                                  final netAmt = _parseDbl(d.nETAMT);

                                  return shadcn.TableRow(cells: [
                                    _dataCell(
                                        Text(d.tRADEDATE ?? '',
                                            style: _textStyle(context)),
                                        false),
                                    _dataCell(
                                        Text(_formatQty(buyQty),
                                            style: _textStyle(context)),
                                        true),
                                    _dataCell(
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(_formatRate(buyRate),
                                                style: _textStyle(context)),
                                            Text(_formatRate(buyAmt),
                                                style: MyntWebTextStyles
                                                    .caption(context,
                                                        darkColor: MyntColors
                                                                .textSecondaryDark,
                                                        lightColor: MyntColors
                                                                .textSecondary)),
                                          ],
                                        ),
                                        true),
                                    _dataCell(
                                        Text(_formatQty(sellQty),
                                            style: _textStyle(context)),
                                        true),
                                    _dataCell(
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(_formatRate(sellRate),
                                                style: _textStyle(context)),
                                            Text(_formatRate(sellAmt),
                                                style: MyntWebTextStyles
                                                    .caption(context,
                                                        darkColor: MyntColors
                                                                .textSecondaryDark,
                                                        lightColor: MyntColors
                                                                .textSecondary)),
                                          ],
                                        ),
                                        true),
                                    _dataCell(
                                        Text(_formatQty(netQty),
                                            style: _textStyle(context)),
                                        true),
                                    _dataCell(
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(_formatRate(netRate),
                                                style: _textStyle(context)),
                                            Text(_formatRate(netAmt),
                                                style: MyntWebTextStyles
                                                    .caption(context,
                                                        darkColor: MyntColors
                                                                .textSecondaryDark,
                                                        lightColor: MyntColors
                                                                .textSecondary)),
                                          ],
                                        ),
                                        true),
                                    _dataCell(
                                        Text(
                                          _formatRate(netAmt),
                                          style: _textStyle(context,
                                              color: netAmt < 0
                                                  ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
                                                  : netAmt > 0
                                                      ? resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success)
                                                      : null),
                                        ),
                                        true),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            // P&L footer
            if (!_loading && filtered.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'P&L: ',
                          style: MyntWebTextStyles.body(context,
                              fontWeight: MyntFonts.semiBold,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary)),
                        ),
                        TextSpan(
                          text: _formatRate(totalPnl),
                          style: MyntWebTextStyles.body(context,
                              fontWeight: MyntFonts.semiBold,
                              color: totalPnl < 0
                                  ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
                                  : totalPnl > 0
                                      ? resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success)
                                      : resolveThemeColor(context,
                                          dark: MyntColors.textPrimaryDark,
                                          light: MyntColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  shadcn.TableCell _headerCell(String label, bool alignRight) {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(label,
            style: MyntWebTextStyles.tableHeader(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary,
                fontWeight: MyntFonts.semiBold)),
      ),
    );
  }

  shadcn.TableCell _dataCell(Widget child, bool alignRight) {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark, light: MyntColors.divider)
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  TextStyle _textStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }
}

// ─── Date Picker Overlay (matches ledger page) ─────────────────────────

class _PnlDatePickerOverlay extends StatefulWidget {
  final Offset buttonOffset;
  final ThemesProvider theme;
  final DateTime leftMonth;
  final DateTime rightMonth;
  final DateTime? tempStartDate;
  final DateTime? tempEndDate;
  final VoidCallback onClose;
  final void Function(DateTime start, DateTime end) onApply;
  final void Function(String preset) onQuickSelect;

  const _PnlDatePickerOverlay({
    required this.buttonOffset,
    required this.theme,
    required this.leftMonth,
    required this.rightMonth,
    required this.tempStartDate,
    required this.tempEndDate,
    required this.onClose,
    required this.onApply,
    required this.onQuickSelect,
  });

  @override
  State<_PnlDatePickerOverlay> createState() => _PnlDatePickerOverlayState();
}

class _PnlDatePickerOverlayState extends State<_PnlDatePickerOverlay> {
  late DateTime _leftMonth;
  late DateTime _rightMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _selectingEnd = false;

  static const _quickPresets = [
    'Last 7 days',
    'Last 30 days',
    'Current FY',
    'Last FY',
    '2023',
    '2022',
    '2021',
  ];

  @override
  void initState() {
    super.initState();
    _leftMonth = widget.leftMonth;
    _rightMonth = widget.rightMonth;
    _startDate = widget.tempStartDate;
    _endDate = widget.tempEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: widget.buttonOffset.dx,
          top: widget.buttonOffset.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: resolveThemeColor(context,
                dark: MyntColors.backgroundColorDark,
                light: MyntColors.backgroundColor),
            child: Container(
              width: 620,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark,
                      light: MyntColors.divider),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMonthCalendar(_leftMonth, true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMonthCalendar(_rightMonth, false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickPresets.map((preset) {
                      return InkWell(
                        onTap: () => widget.onQuickSelect(preset),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: resolveThemeColor(context,
                                  dark: MyntColors.dividerDark,
                                  light: MyntColors.divider),
                            ),
                          ),
                          child: Text(
                            preset,
                            style: MyntWebTextStyles.bodySmall(context,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textPrimaryDark,
                                    light: MyntColors.textPrimary),
                                fontWeight: MyntFonts.medium),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthCalendar(DateTime month, bool isLeft) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final monthName = DateFormat('MMMM yyyy').format(month);

    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (isLeft) {
                    _leftMonth = DateTime(_leftMonth.year, _leftMonth.month - 1);
                    _rightMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);
                  } else {
                    _rightMonth = DateTime(_rightMonth.year, _rightMonth.month - 1);
                    _leftMonth = DateTime(_rightMonth.year, _rightMonth.month - 1);
                  }
                });
              },
              child: Icon(Icons.chevron_left, size: 20, color: secondaryColor),
            ),
            Text(monthName,
                style: MyntWebTextStyles.body(context,
                    color: textColor, fontWeight: MyntFonts.semiBold)),
            InkWell(
              onTap: () {
                setState(() {
                  if (isLeft) {
                    _leftMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);
                    _rightMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);
                  } else {
                    _rightMonth = DateTime(_rightMonth.year, _rightMonth.month + 1);
                    _leftMonth = DateTime(_rightMonth.year, _rightMonth.month - 1);
                  }
                });
              },
              child: Icon(Icons.chevron_right, size: 20, color: secondaryColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: MyntWebTextStyles.caption(context,
                              color: secondaryColor)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        ...List.generate(6, (week) {
          return Row(
            children: List.generate(7, (day) {
              final dayNum = week * 7 + day - firstDayWeekday + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }
              final date = DateTime(month.year, month.month, dayNum);
              final isToday = _isSameDay(date, DateTime.now());
              final isStart = _startDate != null && _isSameDay(date, _startDate!);
              final isEnd = _endDate != null && _isSameDay(date, _endDate!);
              final isInRange = _startDate != null &&
                  _endDate != null &&
                  date.isAfter(_startDate!) &&
                  date.isBefore(_endDate!);
              final isSelected = isStart || isEnd;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!_selectingEnd || _startDate == null) {
                        _startDate = date;
                        _endDate = null;
                        _selectingEnd = true;
                      } else {
                        if (date.isBefore(_startDate!)) {
                          _endDate = _startDate;
                          _startDate = date;
                        } else {
                          _endDate = date;
                        }
                        _selectingEnd = false;
                        widget.onApply(_startDate!, _endDate!);
                      }
                    });
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : isInRange
                              ? primaryColor.withValues(alpha: 0.1)
                              : null,
                      shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: MyntWebTextStyles.bodySmall(
                          context,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? primaryColor
                                  : textColor,
                          fontWeight: isToday || isSelected
                              ? MyntFonts.semiBold
                              : MyntFonts.medium,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
