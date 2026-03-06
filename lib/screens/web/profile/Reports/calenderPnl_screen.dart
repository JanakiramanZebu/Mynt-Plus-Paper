// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../models/desk_reports_model/calender_pnl_model.dart';
import '../../../../provider/ledger_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../sharedWidget/no_data_found.dart';

class CalenderpnlScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const CalenderpnlScreen({super.key, this.onBack});

  @override
  ConsumerState<CalenderpnlScreen> createState() => _CalenderpnlScreenState();
}

class _CalenderpnlScreenState extends ConsumerState<CalenderpnlScreen> {
  bool _isInitialized = false;
  int _selectedSegmentIndex = 0;

  // Expandable date rows
  final Set<DateTime> _expandedDates = {};

  // Hover tracking for table rows
  final ValueNotifier<String?> _hoveredRowKey = ValueNotifier<String?>(null);

  // Date picker state
  bool _showDatePickerPopup = false;
  late DateTime _startDate;
  late DateTime _endDate;
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;
  late DateTime _leftMonth;
  late DateTime _rightMonth;
  String _dateValidationMsg = '';

  @override
  void initState() {
    super.initState();
    // Initialize dates from provider
    final lp = ref.read(ledgerProvider);
    _startDate = lp.startTaxDate;
    _endDate = lp.endTaxDate;
    _rightMonth = DateTime(_endDate.year, _endDate.month);
    _leftMonth = DateTime(_startDate.year, _startDate.month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    if (!_isInitialized) {
      final ledgerprovider = ref.read(ledgerProvider);
      if (!ledgerprovider.hasDataForAllSegments) {
        ledgerprovider.fetchDataForAllSegmentsIfEmpty(
          context,
          ledgerprovider.startDate,
          ledgerprovider.today,
        );
      }
      // Sync selected segment index
      final idx = ledgerprovider.availableSegments
          .indexOf(ledgerprovider.selectedSegment);
      if (idx >= 0) _selectedSegmentIndex = idx;
      _isInitialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ledgerprovider = ref.read(ledgerProvider);
    if (_isInitialized) {
      if (!ledgerprovider.hasDataForSegment(ledgerprovider.selectedSegment)) {
        ledgerprovider.fetchcalenderpnldata(
          context,
          ledgerprovider.startDate,
          ledgerprovider.today,
          ledgerprovider.selectedSegment,
        );
      } else {
        ledgerprovider.refreshCurrentSegmentUI();
      }
    }
  }

  @override
  void dispose() {
    _hoveredRowKey.dispose();
    super.dispose();
  }

  void _toggleDatePicker() {
    setState(() {
      if (!_showDatePickerPopup) {
        _tempStartDate = _startDate;
        _tempEndDate = _endDate;
        _dateValidationMsg = '';
        _rightMonth = DateTime(_endDate.year, _endDate.month);
        _leftMonth = DateTime(_startDate.year, _startDate.month);
      }
      _showDatePickerPopup = !_showDatePickerPopup;
    });
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_tempStartDate == null || _tempEndDate != null) {
        _tempStartDate = date;
        _tempEndDate = null;
        _dateValidationMsg = '';
      } else {
        DateTime start = _tempStartDate!;
        DateTime end = date;
        if (end.isBefore(start)) {
          final temp = start;
          start = end;
          end = temp;
        }
        _dateValidationMsg = '';
        _tempStartDate = start;
        _tempEndDate = end;
        _startDate = start;
        _endDate = end;
        _showDatePickerPopup = false;
        _expandedDates.clear();
        _applyDateRange();
      }
    });
  }

  void _applyFYPreset(int startYear) {
    setState(() {
      _startDate = DateTime(startYear, 4, 1);
      _endDate = DateTime(startYear + 1, 3, 31);
      _showDatePickerPopup = false;
      _expandedDates.clear();
    });
    _applyDateRange();
  }

  void _applyQuickDate(int days) {
    setState(() {
      _endDate = DateTime.now();
      _startDate = _endDate.subtract(Duration(days: days));
      _showDatePickerPopup = false;
      _expandedDates.clear();
    });
    _applyDateRange();
  }

  void _applyDateRange() {
    final lp = ref.read(ledgerProvider);
    final from = DateFormat('dd/MM/yyyy').format(_startDate);
    final to = DateFormat('dd/MM/yyyy').format(_endDate);

    // Update provider dates
    lp.startTaxDate = _startDate;
    lp.endTaxDate = _endDate;
    lp.formattedStartDate = from;
    lp.formattedendDate = to;

    // Clear existing data and refetch
    lp.clearCalendarPnLData();
    lp.calendarProvider();
    lp.fetchDataForAllSegmentsIfEmpty(context, lp.startDate, lp.today);
  }

  void _onSegmentTap(int index, LDProvider ledgerprovider) {
    final selectedSegment = ledgerprovider.availableSegments[index];
    setState(() {
      _selectedSegmentIndex = index;
      _expandedDates.clear();
    });
    ledgerprovider.switchToSegment(
      context,
      selectedSegment,
      ledgerprovider.formattedStartDate,
      ledgerprovider.formattedendDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerprovider = ref.watch(ledgerProvider);
    final theme = ref.watch(themeProvider);
    final isLoading = ledgerprovider
            .isCalendarPnlLoadingForSegment(ledgerprovider.selectedSegment) ||
        (ledgerprovider.calenderpnlAllData == null &&
            !ledgerprovider
                .hasDataForSegment(ledgerprovider.selectedSegment));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, ledgerprovider),
            Expanded(
              child: Stack(
                children: [
                  MyntLoaderOverlay(
                    isLoading: isLoading,
                    child: ledgerprovider.calenderpnlAllData == null &&
                            !isLoading
                        ? const Center(
                            child: NoDataFound(secondaryEnabled: false))
                        : _buildBody(context, theme, ledgerprovider),
                  ),
                  // Date picker overlay
                  if (_showDatePickerPopup) ...[
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _showDatePickerPopup = false),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    _buildDatePickerOverlay(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    final dateStr =
        '${DateFormat('dd/MM/yyyy').format(_startDate)}_to_${DateFormat('dd/MM/yyyy').format(_endDate)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CustomBackBtn(onBack: widget.onBack),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'P&L Summary',
              style: MyntWebTextStyles.head(context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          // Date range button
          InkWell(
            onTap: _toggleDatePicker,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: resolveThemeColor(context,
                      dark: MyntColors.cardBorderDark,
                      light: MyntColors.cardBorder),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: MyntWebTextStyles.para(context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    final data = ledgerprovider.calenderpnlAllData;
    final bool isCommodity = ledgerprovider.selectedSegment == "Commodity";

    // Build sorted dates
    List<DateTime> sortedDates;
    if (isCommodity && data?.dateWise != null) {
      sortedDates = (data!.dateWise as Map)
          .keys
          .map((dateStr) => DateTime.parse(dateStr))
          .where((date) =>
              !date.isBefore(ledgerprovider.startTaxDate) &&
              !date.isAfter(ledgerprovider.endTaxDate))
          .toList()
        ..sort((a, b) => b.compareTo(a));
    } else {
      sortedDates = ledgerprovider.grouped.keys
          .where((date) =>
              !date.isBefore(ledgerprovider.startTaxDate) &&
              !date.isAfter(ledgerprovider.endTaxDate))
          .toList()
        ..sort((a, b) => b.compareTo(a));
    }

    final double netValue = (data?.realized ?? 0.0) - (data?.totalCharges ?? 0.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segment tabs
          _buildSegmentTabs(context, ledgerprovider),
          const SizedBox(height: 12),
          // Summary cards
          _buildSummaryCards(context, data, netValue),
          const SizedBox(height: 16),
          // Calendar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WebCalendarTabs(
              heatmapData: ledgerprovider.heatmapData,
              monthlyPnL: isCommodity
                  ? _buildMonthlyPnLForCommodity(ledgerprovider)
                  : ledgerprovider.monthlyPnL,
              isMonthly: ledgerprovider.isMonthly,
              startFY: ledgerprovider.startTaxDate,
              endFY: ledgerprovider.endTaxDate,
              selectedMonth: ledgerprovider.selectedMonth,
              onTabChanged: (isMonthly) => ledgerprovider.setTab(isMonthly),
              onMonthSelected: (month) {
                ledgerprovider.setSelectedMonth(month);
                ledgerprovider.setTab(false);
              },
              onMonthChanged: (month) =>
                  ledgerprovider.setSelectedMonth(month),
            ),
          ),
          const SizedBox(height: 16),
          // Date-wise list with expandable rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDateWiseSection(
                context, sortedDates, ledgerprovider, isCommodity),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Segment Tabs ---
  Widget _buildSegmentTabs(BuildContext context, LDProvider ledgerprovider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ledgerprovider.availableSegments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final isSelected = index == _selectedSegmentIndex;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _onSegmentTap(index, ledgerprovider),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isSelected
                      ? (isDarkMode(context)
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05))
                      : Colors.transparent,
                ),
                child: Text(
                  segment,
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight:
                        isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                  ).copyWith(
                    color: isSelected
                        ? shadcn.Theme.of(context).colorScheme.foreground
                        : shadcn.Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Summary Cards ---
  Widget _buildSummaryCards(
      BuildContext context, CalenderpnlModel? data, double netValue) {
    final realized = data?.realized ?? 0.0;
    final unrealized = data?.unrealized ?? 0.0;
    final charges = data?.totalCharges ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
              child: _buildSummaryCard(
                  context, 'Realised P&L', realized, _getPnlColor(context, realized))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard(context, 'Unrealised P&L', unrealized,
                  _getPnlColor(context, unrealized))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard(context, 'Charges & Taxes', charges,
                  resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard(
                  context, 'Net Realised P&L', netValue, _getPnlColor(context, netValue))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, double value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolveThemeColor(context,
              dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder),
        ),
        color: resolveThemeColor(
            context, dark: MyntColors.cardDark, light: MyntColors.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MyntWebTextStyles.para(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(value),
            style: MyntWebTextStyles.title(context,
                darkColor: valueColor,
                lightColor: valueColor,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- Date-wise Section ---
  Widget _buildDateWiseSection(BuildContext context, List<DateTime> sortedDates,
      LDProvider ledgerprovider, bool isCommodity) {
    if (sortedDates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 30),
          child: NoDataFound(secondaryEnabled: false),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final columnWidths = {
          0: shadcn.FixedTableSize(totalWidth * 0.60), // Arrow + Date + Count
          1: shadcn.FixedTableSize(totalWidth * 0.40), // P&L
        };

        // Build rows data
        final List<_DateRowData> dateRows = sortedDates.map((dateKey) {
          List<TradeData> tradesForDate;
          double totalRealisedPnl;

          if (isCommodity) {
            final dateStr =
                "${dateKey.year}-${dateKey.month.toString().padLeft(2, '0')}-${dateKey.day.toString().padLeft(2, '0')}";
            final dateData = (ledgerprovider.calenderpnlAllData!.dateWise
                as Map)[dateStr];
            tradesForDate = dateData != null && dateData['trades'] != null
                ? (dateData['trades'] as List)
                    .map((trade) => TradeData.fromCommodityJson(trade))
                    .toList()
                : [];
            totalRealisedPnl =
                dateData?['realised_pnl']?.toDouble() ?? 0.0;
          } else {
            tradesForDate = ledgerprovider.grouped[dateKey] ?? [];
            totalRealisedPnl = tradesForDate.fold(
              0.0,
              (sum, item) =>
                  sum + (double.tryParse(item.realisedpnl ?? '0') ?? 0.0),
            );
          }

          final dateString =
              '${dateKey.day.toString().padLeft(2, '0')} ${_monthName(dateKey.month)} ${dateKey.year}';
          final isExpanded = _expandedDates.contains(dateKey);

          return _DateRowData(
            dateKey: dateKey,
            tradesForDate: tradesForDate,
            totalRealisedPnl: totalRealisedPnl,
            dateString: dateString,
            isExpanded: isExpanded,
          );
        }).toList();

        return shadcn.OutlinedContainer(
          child: Column(
            children: [
              // Header row as shadcn Table
              shadcn.Table(
                defaultRowHeight: const shadcn.FixedTableSize(44),
                columnWidths: columnWidths,
                rows: [
                  shadcn.TableHeader(
                    cells: [
                      _buildDateSectionHeaderCell('Date Wise P&L'),
                      _buildDateSectionHeaderCell(
                          '${sortedDates.length} Days',
                          alignRight: true,
                          isSecondary: true),
                    ],
                  ),
                ],
              ),
              // Data rows
              ...dateRows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;

                return Column(
                  children: [
                    // Date row as shadcn Table
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (row.isExpanded) {
                            _expandedDates.remove(row.dateKey);
                          } else {
                            _expandedDates.add(row.dateKey);
                          }
                        });
                      },
                      child: shadcn.Table(
                        defaultRowHeight: const shadcn.FixedTableSize(44),
                        columnWidths: columnWidths,
                        rows: [
                          shadcn.TableRow(
                            cells: [
                              _buildDateRowCell(
                                rowIndex: index,
                                child: Row(
                                  children: [
                                    Icon(
                                      row.isExpanded
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_right,
                                      size: 20,
                                      color: resolveThemeColor(context,
                                          dark: MyntColors.textSecondaryDark,
                                          light: MyntColors.textSecondary),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      row.dateString,
                                      style: MyntWebTextStyles.body(context,
                                          darkColor: MyntColors.textPrimaryDark,
                                          lightColor: MyntColors.textPrimary,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: resolveThemeColor(context,
                                                dark: MyntColors.textSecondaryDark,
                                                light: MyntColors.textSecondary)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${row.tradesForDate.length}',
                                        style: MyntWebTextStyles.caption(context,
                                            darkColor: MyntColors.textSecondaryDark,
                                            lightColor: MyntColors.textSecondary,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildDateRowCell(
                                rowIndex: index,
                                alignRight: true,
                                child: Text(
                                  _formatAmount(row.totalRealisedPnl),
                                  style: MyntWebTextStyles.body(context,
                                      darkColor: _getPnlColor(
                                          context, row.totalRealisedPnl),
                                      lightColor: _getPnlColor(
                                          context, row.totalRealisedPnl),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Expanded trade table
                    if (row.isExpanded && row.tradesForDate.isNotEmpty)
                      _buildTradeTable(context, row.tradesForDate),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // --- Date section header cell ---
  shadcn.TableCell _buildDateSectionHeaderCell(String label,
      {bool alignRight = false, bool isSecondary = false}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          style: isSecondary
              ? MyntWebTextStyles.para(context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary)
              : MyntWebTextStyles.body(context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // --- Date row cell with hover ---
  shadcn.TableCell _buildDateRowCell({
    required int rowIndex,
    required Widget child,
    bool alignRight = false,
  }) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  // --- Date Picker Overlay ---
  Widget _buildDatePickerOverlay(BuildContext context) {
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final secondaryTextColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final cardColor = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);

    // Generate FY presets
    final now = DateTime.now();
    final currentFYStart = now.month < 4 ? now.year - 1 : now.year;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: cardColor,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Two calendars side by side
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarMonth(
                      context,
                      _leftMonth,
                      primaryColor,
                      textColor,
                      secondaryTextColor,
                      onPrev: () {
                        setState(() {
                          _leftMonth = DateTime(
                              _leftMonth.year, _leftMonth.month - 1);
                          _rightMonth = DateTime(
                              _leftMonth.year, _leftMonth.month + 1);
                        });
                      },
                      onNext: () {
                        setState(() {
                          _leftMonth = DateTime(
                              _leftMonth.year, _leftMonth.month + 1);
                          _rightMonth = DateTime(
                              _leftMonth.year, _leftMonth.month + 1);
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildCalendarMonth(
                      context,
                      _rightMonth,
                      primaryColor,
                      textColor,
                      secondaryTextColor,
                      onPrev: () {
                        setState(() {
                          _rightMonth = DateTime(
                              _rightMonth.year, _rightMonth.month - 1);
                          _leftMonth = DateTime(
                              _rightMonth.year, _rightMonth.month - 1);
                        });
                      },
                      onNext: () {
                        setState(() {
                          _rightMonth = DateTime(
                              _rightMonth.year, _rightMonth.month + 1);
                          _leftMonth = DateTime(
                              _rightMonth.year, _rightMonth.month - 1);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Quick presets
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip('Last 7 days', () => _applyQuickDate(7)),
                    _buildPresetChip(
                        'Last 30 days', () => _applyQuickDate(30)),
                    _buildPresetChip(
                        'Current FY', () => _applyFYPreset(currentFYStart)),
                    _buildPresetChip(
                        'Last FY', () => _applyFYPreset(currentFYStart - 1)),
                    // Year presets going back
                    for (int y = currentFYStart - 2; y >= currentFYStart - 4; y--)
                      _buildPresetChip('$y', () => _applyFYPreset(y)),
                  ],
                ),
                if (_dateValidationMsg.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _dateValidationMsg,
                    style: MyntWebTextStyles.para(context,
                        darkColor: MyntColors.lossDark,
                        lightColor: MyntColors.loss),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: resolveThemeColor(context,
                dark: MyntColors.cardBorderDark,
                light: MyntColors.cardBorder),
          ),
        ),
        child: Text(
          label,
          style: MyntWebTextStyles.para(context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCalendarMonth(
    BuildContext context,
    DateTime month,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor, {
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    final monthName = DateFormat('MMMM yyyy').format(month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final today = DateTime.now();
    final dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return SizedBox(
      width: 260,
      child: Column(
        children: [
          // Month header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onPrev,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.chevron_left,
                      size: 20, color: secondaryTextColor),
                ),
              ),
              Text(
                monthName,
                style: MyntWebTextStyles.body(context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                    fontWeight: FontWeight.w600),
              ),
              InkWell(
                onTap: onNext,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.chevron_right,
                      size: 20, color: secondaryTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayHeaders
                .map((d) => SizedBox(
                      width: 34,
                      child: Center(
                        child: Text(d,
                            style: MyntWebTextStyles.para(context,
                                darkColor: MyntColors.textSecondaryDark,
                                lightColor: MyntColors.textSecondary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Day grid
          ...List.generate(6, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNum =
                    weekIndex * 7 + dayIndex - firstWeekday + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const SizedBox(width: 34, height: 34);
                }

                final date =
                    DateTime(month.year, month.month, dayNum);
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isFuture = date.isAfter(today);
                final isStart = _tempStartDate != null &&
                    _isSameDay(date, _tempStartDate!);
                final isEnd = _tempEndDate != null &&
                    _isSameDay(date, _tempEndDate!);
                final isInRange = _tempStartDate != null &&
                    _tempEndDate != null &&
                    date.isAfter(_tempStartDate!
                        .subtract(const Duration(days: 1))) &&
                    date.isBefore(
                        _tempEndDate!.add(const Duration(days: 1)));

                Color? bgColor;
                Color dayTextColor = textColor;

                if (isStart || isEnd) {
                  bgColor = primaryColor;
                  dayTextColor = Colors.white;
                } else if (isInRange) {
                  bgColor = primaryColor.withValues(alpha: 0.1);
                }

                if (isFuture) {
                  dayTextColor =
                      secondaryTextColor.withValues(alpha: 0.4);
                }

                return GestureDetector(
                  onTap: isFuture ? null : () => _onDateTap(date),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: (isStart || isEnd)
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius: (isStart || isEnd)
                          ? null
                          : BorderRadius.zero,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isToday ? FontWeight.w700 : FontWeight.w400,
                        color: dayTextColor,
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // --- Trade Table (shadcn) ---
  Widget _buildTradeTable(BuildContext context, List<TradeData> trades) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        // 8 columns: Symbol, Buy Qty, Buy Rate, Sell Qty, Sell Rate, Net Qty, Close Price, Realised P&L
        final double symbolWidth = totalWidth * 0.22;
        final double buyQtyWidth = totalWidth * 0.10;
        final double buyRateWidth = totalWidth * 0.11;
        final double sellQtyWidth = totalWidth * 0.10;
        final double sellRateWidth = totalWidth * 0.11;
        final double netQtyWidth = totalWidth * 0.10;
        final double closePriceWidth = totalWidth * 0.12;
        final double realisedWidth = totalWidth * 0.14;

        final columnWidths = {
          0: shadcn.FixedTableSize(symbolWidth),
          1: shadcn.FixedTableSize(buyQtyWidth),
          2: shadcn.FixedTableSize(buyRateWidth),
          3: shadcn.FixedTableSize(sellQtyWidth),
          4: shadcn.FixedTableSize(sellRateWidth),
          5: shadcn.FixedTableSize(netQtyWidth),
          6: shadcn.FixedTableSize(closePriceWidth),
          7: shadcn.FixedTableSize(realisedWidth),
        };

        return Container(
          color: resolveThemeColor(context,
              dark: MyntColors.cardDark, light: MyntColors.cardHover),
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
          child: shadcn.Table(
            defaultRowHeight: const shadcn.FixedTableSize(42),
            columnWidths: columnWidths,
            rows: [
              // Header
              shadcn.TableHeader(
                cells: [
                  _buildTableHeaderCell('Symbol'),
                  _buildTableHeaderCell('Buy Qty', alignRight: true),
                  _buildTableHeaderCell('Buy Rate', alignRight: true),
                  _buildTableHeaderCell('Sell Qty', alignRight: true),
                  _buildTableHeaderCell('Sell Rate', alignRight: true),
                  _buildTableHeaderCell('Net Qty', alignRight: true),
                  _buildTableHeaderCell('Close Price', alignRight: true),
                  _buildTableHeaderCell('Realised P&L', alignRight: true),
                ],
              ),
              // Data rows
              ...trades.asMap().entries.map((entry) {
                final index = entry.key;
                final trade = entry.value;
                final symbol = (trade.sCRIPSYMBOL ?? '')
                    .replaceFirst(RegExp(r'^\d+\s+'), '');
                final realisedPnl =
                    double.tryParse(trade.realisedpnl ?? '0') ?? 0.0;
                final rowKey = '${trade.tRADEDATE}_${index}_$symbol';

                return shadcn.TableRow(
                  cells: [
                    _buildTableDataCell(
                      rowKey: rowKey,
                      child: Text(
                        symbol.isNotEmpty ? symbol : '--',
                        style: _getTextStyle(context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    _buildTableDataCell(
                      rowKey: rowKey,
                      alignRight: true,
                      child: Text(
                        trade.safeBuyQty.toString(),
                        style: _getTextStyle(context),
                      ),
                    ),
                    _buildTableDataCell(
                      rowKey: rowKey,
                      alignRight: true,
                      child: Text(
                        _formatPrice(trade.bRATE),
                        style: _getTextStyle(context),
                      ),
                    ),
                    _buildTableDataCell(
                      rowKey: rowKey,
                      alignRight: true,
                      child: Text(
                        trade.safeSellQty.toString(),
                        style: _getTextStyle(context),
                      ),
                    ),
                    _buildTableDataCell(
                      rowKey: rowKey,
                      alignRight: true,
                      child: Text(
                        _formatPrice(trade.sRATE),
                        style: _getTextStyle(context),
                      ),
                    ),
                    _buildTableDataCell(
                      rowKey: rowKey,
                      alignRight: true,
                      child: Text(
                        trade.safeNetQty.toString(),
                        style: _getTextStyle(context),
                      ),
                    ),
                    _buildTableDataCell(
                      rowKey: rowKey,
                      alignRight: true,
                      child: Text(
                        _formatPrice(trade.cLOSINGPRICE),
                        style: _getTextStyle(context),
                      ),
                    ),
                    _buildTableDataCell(
                      rowKey: rowKey,
                      alignRight: true,
                      child: Text(
                        _formatAmount(realisedPnl),
                        style: _getTextStyle(context,
                            color: _getPnlColor(context, realisedPnl)),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // --- Table cell helpers ---
  shadcn.TableCell _buildTableHeaderCell(String label,
      {bool alignRight = false}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(label, style: _getHeaderStyle(context)),
      ),
    );
  }

  shadcn.TableCell _buildTableDataCell({
    required String rowKey,
    required Widget child,
    bool alignRight = false,
  }) {
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
        onEnter: (_) => _hoveredRowKey.value = rowKey,
        onExit: (_) => _hoveredRowKey.value = null,
        child: ValueListenableBuilder<String?>(
          valueListenable: _hoveredRowKey,
          builder: (context, hoveredKey, _) {
            final isHovered = hoveredKey == rowKey;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: isHovered
                  ? resolveThemeColor(context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary)
                      .withValues(alpha: 0.06)
                  : null,
              alignment: alignRight ? Alignment.centerRight : null,
              child: child,
            );
          },
        ),
      ),
    );
  }

  // --- Style helpers ---
  TextStyle _getTextStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  TextStyle _getHeaderStyle(BuildContext context) {
    return MyntWebTextStyles.tableHeader(
      context,
      darkColor: MyntColors.textSecondaryDark,
      lightColor: MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  Color _getPnlColor(BuildContext context, double value) {
    if (value > 0) {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (value < 0) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    }
    return resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
  }

  String _formatAmount(double value) {
    final prefix = value < 0 ? '-₹' : '₹';
    return '$prefix${NumberFormat('#,##,##0.00', 'en_IN').format(value.abs())}';
  }

  String _formatPrice(String? price) {
    if (price == null || price.isEmpty) return '0.00';
    try {
      return double.parse(price).toStringAsFixed(2);
    } catch (e) {
      return price;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// --- Commodity monthly PnL builder ---
Map<String, double> _buildMonthlyPnLForCommodity(LDProvider provider) {
  final Map<String, double> monthlyPnL = {};
  if (provider.calenderpnlAllData?.dateWise != null) {
    (provider.calenderpnlAllData!.dateWise as Map).forEach((dateStr, dateData) {
      try {
        final date = DateTime.parse(dateStr);
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        final pnl = dateData['realised_pnl']?.toDouble() ?? 0.0;
        monthlyPnL[key] = (monthlyPnL[key] ?? 0.0) + pnl;
      } catch (e) {
        // Skip invalid dates
      }
    });
  }
  return monthlyPnL;
}

// ============================================================
// Web Calendar Tabs (Monthly Grid + Daily Heatmap)
// ============================================================
class _WebCalendarTabs extends StatefulWidget {
  final Map<DateTime, double> heatmapData;
  final Map<String, double> monthlyPnL;
  final bool isMonthly;
  final DateTime startFY;
  final DateTime endFY;
  final DateTime selectedMonth;
  final ValueChanged<bool> onTabChanged;
  final ValueChanged<DateTime> onMonthSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _WebCalendarTabs({
    required this.heatmapData,
    required this.monthlyPnL,
    required this.isMonthly,
    required this.startFY,
    required this.endFY,
    required this.selectedMonth,
    required this.onTabChanged,
    required this.onMonthSelected,
    required this.onMonthChanged,
  });

  @override
  State<_WebCalendarTabs> createState() => _WebCalendarTabsState();
}

class _WebCalendarTabsState extends State<_WebCalendarTabs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolveThemeColor(context,
              dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder),
        ),
        color: resolveThemeColor(
            context, dark: MyntColors.cardDark, light: MyntColors.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly / Daily toggle
          Row(
            children: [
              _buildTabButton('Monthly', widget.isMonthly),
              const SizedBox(width: 8),
              _buildTabButton('Daily', !widget.isMonthly),
            ],
          ),
          const SizedBox(height: 16),
          // Calendar content
          if (widget.isMonthly)
            _buildMonthlyGrid(context)
          else
            _WebDailyCalendar(
              heatmapData: widget.heatmapData,
              startDate: widget.startFY,
              endDate: widget.endFY,
              currentMonth: widget.selectedMonth,
              onMonthChanged: widget.onMonthChanged,
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return InkWell(
      onTap: () => widget.onTabChanged(label == 'Monthly'),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isActive
              ? resolveThemeColor(context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary)
                  .withValues(alpha: 0.1)
              : null,
        ),
        child: Text(
          label,
          style: MyntWebTextStyles.para(
            context,
            darkColor: isActive
                ? MyntColors.primaryDark
                : MyntColors.textSecondaryDark,
            lightColor:
                isActive ? MyntColors.primary : MyntColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyGrid(BuildContext context) {
    // Generate 12 months from startFY to endFY
    final months = <DateTime>[];
    DateTime current = DateTime(widget.startFY.year, widget.startFY.month, 1);
    while (!current.isAfter(widget.endFY)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }

    // 4 columns per row
    final rows = <List<DateTime>>[];
    for (int i = 0; i < months.length; i += 4) {
      final endIndex = (i + 4 > months.length) ? months.length : (i + 4);
      rows.add(months.sublist(i, endIndex));
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              ...row.map((monthDate) {
                return Expanded(
                  child: _buildMonthCard(context, monthDate),
                );
              }),
              // Fill remaining slots
              ...List.generate(
                4 - row.length,
                (_) => const Expanded(child: SizedBox()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthCard(BuildContext context, DateTime monthDate) {
    final key =
        "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}";
    final double? monthValue = widget.monthlyPnL[key];

    final numval =
        (monthValue == null || monthValue == 0) ? "-" : monthValue.toStringAsFixed(2);
    var displayText = numval != "-"
        ? NumberFormat.compactCurrency(
            decimalDigits: 2, locale: 'en_IN', symbol: '')
            .format(double.parse(numval))
        : '-';
    if (displayText.contains("T")) {
      displayText = displayText.replaceAll("T", "K");
    }

    final monthAbbrs = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final monthName = monthAbbrs[monthDate.month - 1];

    Color valueColor;
    if (monthValue == null || monthValue == 0) {
      valueColor = resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    } else {
      valueColor = monthValue < 0
          ? resolveThemeColor(
              context, dark: MyntColors.lossDark, light: MyntColors.loss)
          : resolveThemeColor(
              context, dark: MyntColors.profitDark, light: MyntColors.profit);
    }

    return GestureDetector(
      onTap: () => widget.onMonthSelected(monthDate),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: resolveThemeColor(context,
              dark: MyntColors.cardHoverDark, light: MyntColors.cardHover),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              monthName,
              style: MyntWebTextStyles.para(context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              displayText,
              style: MyntWebTextStyles.para(context,
                  darkColor: valueColor,
                  lightColor: valueColor,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Web Daily Calendar (Heatmap)
// ============================================================
// GitHub-style contribution heatmap for the full financial year
class _WebDailyCalendar extends StatelessWidget {
  final Map<DateTime, double> heatmapData;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime currentMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const _WebDailyCalendar({
    required this.heatmapData,
    required this.startDate,
    required this.endDate,
    required this.currentMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Build all weeks from startDate to endDate
    // Align to Monday of the week containing startDate
    final firstMonday = startDate.subtract(
        Duration(days: (startDate.weekday - 1) % 7));
    final lastSunday = endDate.add(
        Duration(days: (7 - endDate.weekday) % 7));

    // Build week columns (each column = 1 week, 7 rows for Mon-Sun)
    final weeks = <List<DateTime?>>[];
    DateTime current = firstMonday;
    while (!current.isAfter(lastSunday)) {
      final week = <DateTime?>[];
      for (int d = 0; d < 7; d++) {
        final day = current.add(Duration(days: d));
        if (day.isBefore(startDate) || day.isAfter(endDate)) {
          week.add(null);
        } else {
          week.add(day);
        }
      }
      weeks.add(week);
      current = current.add(const Duration(days: 7));
    }

    // Group weeks by month
    final monthGroups = <_MonthGroup>[];
    int? currentMonthVal;
    int? currentYear;
    List<List<DateTime?>> currentGroup = [];

    for (final week in weeks) {
      final firstDate =
          week.firstWhere((d) => d != null, orElse: () => null);
      if (firstDate != null &&
          (firstDate.month != currentMonthVal ||
              firstDate.year != currentYear)) {
        if (currentGroup.isNotEmpty) {
          monthGroups.add(_MonthGroup(
            month: currentMonthVal!,
            year: currentYear!,
            weeks: List.from(currentGroup),
          ));
        }
        currentMonthVal = firstDate.month;
        currentYear = firstDate.year;
        currentGroup = [week];
      } else {
        currentGroup.add(week);
      }
    }
    if (currentGroup.isNotEmpty && currentMonthVal != null) {
      monthGroups.add(_MonthGroup(
        month: currentMonthVal,
        year: currentYear!,
        weeks: List.from(currentGroup),
      ));
    }

    const double dayLabelWidth = 36;
    const double monthGap = 6;
    final dayLabels = ['Mon', '', 'Wed', '', 'Fri', '', ''];

    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final emptyColor = resolveThemeColor(context,
        dark: MyntColors.cardHoverDark, light: MyntColors.cardHover);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fill 100% width
        // Total width = dayLabels + sum(month groups) + gaps between months
        final totalWeeks = weeks.length;
        final totalMonthGaps = (monthGroups.length - 1) * monthGap;
        final availableWidth =
            constraints.maxWidth - dayLabelWidth - totalMonthGaps;
        final cellStep = availableWidth / totalWeeks;
        final cellGap = (cellStep * 0.18).clamp(2.0, 4.0);
        final cellSize = cellStep - cellGap;

        Widget buildCell(DateTime? date) {
          if (date == null) {
            return SizedBox(
              width: cellStep,
              height: cellSize + cellGap,
            );
          }

          final value =
              heatmapData[DateTime(date.year, date.month, date.day)];
          final today = DateTime.now();
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          Color bgColor;
          if (value == null) {
            bgColor = emptyColor;
          } else if (value < 0) {
            final intensity = _getIntensity(value.abs());
            bgColor = resolveThemeColor(context,
                    dark: MyntColors.lossDark, light: MyntColors.loss)
                .withValues(alpha: intensity);
          } else {
            final intensity = _getIntensity(value.abs());
            bgColor = resolveThemeColor(context,
                    dark: MyntColors.profitDark, light: MyntColors.profit)
                .withValues(alpha: intensity);
          }

          return Tooltip(
            message:
                '${DateFormat('dd MMM yyyy').format(date)}: ${value != null ? '₹${value.toStringAsFixed(2)}' : 'No trades'}',
            child: Container(
              width: cellSize,
              height: cellSize,
              margin: EdgeInsets.only(
                  bottom: cellGap, right: cellGap),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(3),
                border: isToday
                    ? Border.all(
                        color: resolveThemeColor(context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary),
                        width: 1.5,
                      )
                    : null,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heatmap grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day-of-week labels (Mon, Wed, Fri)
                SizedBox(
                  width: dayLabelWidth,
                  child: Column(
                    children: List.generate(7, (dayIndex) {
                      return Container(
                        height: cellSize + cellGap,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          dayLabels[dayIndex],
                          style: TextStyle(
                            fontFamily: MyntFonts.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: secondaryColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Month groups with gaps between them
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int m = 0; m < monthGroups.length; m++) ...[
                        // Month group
                        Expanded(
                          flex: monthGroups[m].weeks.length,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                monthGroups[m].weeks.map((weekDays) {
                              return Column(
                                children: weekDays
                                    .map((date) => buildCell(date))
                                    .toList(),
                              );
                            }).toList(),
                          ),
                        ),
                        // Gap between months
                        if (m < monthGroups.length - 1)
                          SizedBox(width: monthGap),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Month labels below the grid — centered under each group
            Row(
              children: [
                SizedBox(width: dayLabelWidth),
                Expanded(
                  child: Row(
                    children: [
                      for (int m = 0; m < monthGroups.length; m++) ...[
                        Expanded(
                          flex: monthGroups[m].weeks.length,
                          child: Center(
                            child: Text(
                              _monthAbbr(monthGroups[m].month),
                              style: TextStyle(
                                fontFamily: MyntFonts.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: secondaryColor,
                              ),
                            ),
                          ),
                        ),
                        if (m < monthGroups.length - 1)
                          SizedBox(width: monthGap),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Normalize intensity between 0.15 and 0.8 based on value
  double _getIntensity(double absValue) {
    if (absValue <= 0) return 0.15;
    if (absValue >= 10000) return 0.8;
    // Log scale for better distribution
    return 0.15 + (0.65 * (absValue / 10000).clamp(0.0, 1.0));
  }

  String _monthAbbr(int month) {
    const abbrs = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return abbrs[month - 1];
  }
}

class _MonthGroup {
  final int month;
  final int year;
  final List<List<DateTime?>> weeks;
  const _MonthGroup({
    required this.month,
    required this.year,
    required this.weeks,
  });
}

class _DateRowData {
  final DateTime dateKey;
  final List<TradeData> tradesForDate;
  final double totalRealisedPnl;
  final String dateString;
  final bool isExpanded;

  const _DateRowData({
    required this.dateKey,
    required this.tradesForDate,
    required this.totalRealisedPnl,
    required this.dateString,
    required this.isExpanded,
  });
}
