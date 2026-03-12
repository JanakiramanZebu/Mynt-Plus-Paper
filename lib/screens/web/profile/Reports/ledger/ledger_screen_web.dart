// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart' hide Table, TableRow, TableCell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../../provider/ledger_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../res/mynt_web_color_styles.dart';
import '../../../../../sharedWidget/common_search_fields_web.dart';
import '../../../../../sharedWidget/mynt_loader.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';
import '../../../../../sharedWidget/no_data_found.dart';
import '../../../../../sharedWidget/scroll_to_load_mixin.dart';
import '../../../../../sharedWidget/functions.dart';
import '../../../../Mobile/desk_reports/bottom_sheets/ledger_filter.dart';
import '../../../../../utils/rupee_convert_format.dart';


class LedgerScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const LedgerScreenWeb({super.key, this.onBack});

  @override
  ConsumerState<LedgerScreenWeb> createState() => _LedgerScreenWebState();
}

class _LedgerScreenWebState extends ConsumerState<LedgerScreenWeb>
    with ScrollToLoadMixin {
  @override
  ScrollController get tableScrollController => _tableScrollController;
  final ScrollController _tableScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

  // Sorting state
  int? _sortColumnIndex;
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
    // Initialize calendar months: left = start of current FY, right = current month
    final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
    _leftMonth = DateTime(fyStartYear, 4);
    _rightMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);

    final ledgerprovider = ref.read(ledgerProvider);
    if (ledgerprovider.selectedFilters.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ledgerProvider).applyLedgerMultiFilter(
            context, ref.read(ledgerProvider).selectedFilters.toList());
      });
    }
  }

  @override
  void dispose() {
    _removeDatePickerOverlay();
    disposeScrollToLoad();
    _tableScrollController.dispose();
    _horizontalScrollController.dispose();
    _searchController.dispose();
    _hoveredRowIndex.dispose();
    super.dispose();
  }

  void _removeDatePickerOverlay() {
    _datePickerOverlay?.remove();
    _datePickerOverlay = null;
    if (_showDatePicker) {
      setState(() => _showDatePicker = false);
    }
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
                _buildSummaryCards(context, theme, ledgerprovider),
                const SizedBox(height: 16),
                _buildToolbar(context, theme, ledgerprovider),
                const SizedBox(height: 16),
                Expanded(
                  child: ledgerprovider.ledgerloading
                      ? Center(child: MyntLoader.simple())
                      : _buildLedgerTable(context, theme, ledgerprovider),
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
          'Ledger',
          style: MyntWebTextStyles.title(context, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ─── Summary Cards ───────────────────────────────────────────────────

  Widget _buildSummaryCards(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    final data = ledgerprovider.ledgerAllData;
    final openingBalance = data?.openingBalance ?? '0.00';
    final totalDebit = data?.drAmt ?? '0.00';
    final totalCredit = data?.crAmt ?? '0.00';
    final closingBalance = data?.closingBalance ?? '0.00';

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800 ? 4 : 2;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 115,
          ),
          children: [
            _buildStatCard(
              label: 'Opening Balance',
              value: _formatAmount(openingBalance),
              valueColor: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
              theme: theme,
            ),
            _buildStatCard(
              label: 'Total Debit',
              value: _formatAmount(totalDebit),
              valueColor: resolveThemeColor(context,
                  dark: MyntColors.lossDark,
                  light: MyntColors.loss),
              theme: theme,
            ),
            _buildStatCard(
              label: 'Total Credit',
              value: _formatAmount(totalCredit),
              valueColor: resolveThemeColor(context,
                  dark: MyntColors.profitDark,
                  light: MyntColors.profit),
              theme: theme,
            ),
            _buildStatCard(
              label: 'Closing Balance',
              value: _formatAmount(closingBalance),
              valueColor: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
              theme: theme,
            ),
          ],
        );
      },
    );
  }

  String _formatAmount(String value) {
    if (value == 'null' || value.isEmpty) return '0.00';
    final parsed = double.tryParse(value);
    if (parsed == null) return '0.00';
    return parsed.toStringAsFixed(2).toIndianRupee();
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
    required ThemesProvider theme,
  }) {
    return shadcn.Theme(
      data: shadcn.Theme.of(context).copyWith(radius: () => 0.3),
      child: shadcn.Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const SizedBox(width: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary),
                        fontWeight: MyntFonts.medium,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: MyntWebTextStyles.head(
                        context,
                        color: valueColor,
                        fontWeight: MyntFonts.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Toolbar ─────────────────────────────────────────────────────────

  Widget _buildToolbar(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    return Row(
      children: [
        const Spacer(),
  _buildBillMarginToggle(theme, ledgerprovider),
        const SizedBox(width: 12),
        // Date Range Picker
        _buildDateRangeButton(theme, ledgerprovider),
        const SizedBox(width: 12),

  
        // Search
        SizedBox(
          width: 220,
          height: 36,
          child: MyntSearchTextField(
            controller: _searchController,
            placeholder: 'Search ledger',
            leadingIcon: 'assets/icon/search.svg',
            onChanged: (value) {
              ledgerprovider.searchLedgerType(value);
              setState(() {
                displayedItemCount = ScrollToLoadMixin.itemsPerPage;
              });
            },
          ),
        ),
        const SizedBox(width: 8),

        // Bill Margin Toggle
    

        // Filter button (popover pattern from position_screen_web)
        Builder(
          builder: (buttonContext) {
            return SizedBox(
              width: 40,
              height: 40,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showFilterPopover(buttonContext, theme, ledgerprovider),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        assets.searchFilter,
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
        const SizedBox(width: 8),

        // Download button
        SizedBox(
          width: 40,
          height: 40,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) =>
                    _downloadDialog(context, theme, ledgerprovider),
              );
            },
            child: Center(
              child: SvgPicture.asset(
                assets.downloadIcon,
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
      ],
    );
  }

  // ─── Bill Margin Toggle ──────────────────────────────────────────────

  Widget _buildBillMarginToggle(ThemesProvider theme, LDProvider ledgerprovider) {
    final isYes = ledgerprovider.includeBillMargin;
    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark,
        light: MyntColors.textPrimary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bill Margin :',
          style: MyntWebTextStyles.body(context,
              color: secondaryColor, fontWeight: MyntFonts.medium),
        ),
        const SizedBox(width: 6),
        Text(
          'Yes',
          style: MyntWebTextStyles.body(context,
              color: isYes ? primaryColor : secondaryColor,
              fontWeight: isYes ? MyntFonts.semiBold : MyntFonts.medium),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            final newVal = !isYes;
            ledgerprovider.setIncludeBillMargin(newVal);
            ledgerprovider.fetchLegerData(
                context,
                ledgerprovider.startDate,
                ledgerprovider.endDate,
                newVal);
            setState(() => displayedItemCount = ScrollToLoadMixin.itemsPerPage);
          },
          child: Container(
            width: 36,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: !isYes
                  ? resolveThemeColor(context,
                      dark: MyntColors.secondary, light: MyntColors.primary)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: !isYes ? 18 : 2,
                  top: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'No',
          style: MyntWebTextStyles.body(context,
              color: !isYes ? primaryColor : secondaryColor,
              fontWeight: !isYes ? MyntFonts.semiBold : MyntFonts.medium),
        ),
      ],
    );
  }

  // ─── Date Range Picker ───────────────────────────────────────────────

  Widget _buildDateRangeButton(ThemesProvider theme, LDProvider ledgerprovider) {
    final dateText = '${ledgerprovider.startDate}_to_${ledgerprovider.endDate}';

    return InkWell(
      key: _datePickerButtonKey,
      borderRadius: BorderRadius.circular(8),
      onTap: () => _toggleDatePicker(theme, ledgerprovider),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
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
              dateText,
              style: MyntWebTextStyles.bodySmall(context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                  fontWeight: MyntFonts.medium),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDatePicker(ThemesProvider theme, LDProvider ledgerprovider) {
    if (_showDatePicker) {
      _removeDatePickerOverlay();
      return;
    }

    // Parse current dates to initialize temp selection
    _tempStartDate = _parseDate(ledgerprovider.startDate);
    _tempEndDate = _parseDate(ledgerprovider.endDate);
    if (_tempStartDate != null) {
      _leftMonth = DateTime(_tempStartDate!.year, _tempStartDate!.month);
    }
    if (_tempEndDate != null) {
      _rightMonth = DateTime(_tempEndDate!.year, _tempEndDate!.month);
    }
    // Ensure right is after left
    if (!_rightMonth.isAfter(_leftMonth)) {
      _rightMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);
    }

    setState(() => _showDatePicker = true);

    // Get button position for overlay placement
    final RenderBox renderBox =
        _datePickerButtonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPos = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    _datePickerOverlay = OverlayEntry(
      builder: (context) => _DatePickerOverlay(
        buttonOffset: Offset(buttonPos.dx, buttonPos.dy + buttonSize.height + 8),
        theme: theme,
        ledgerprovider: ledgerprovider,
        leftMonth: _leftMonth,
        rightMonth: _rightMonth,
        tempStartDate: _tempStartDate,
        tempEndDate: _tempEndDate,
        onClose: () => _removeDatePickerOverlay(),
        onApply: (start, end) {
          final startStr =
              '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
          final endStr =
              '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
          ledgerprovider.fetchLegerData(
              context, startStr, endStr, ledgerprovider.includeBillMargin);
          setState(() => displayedItemCount = ScrollToLoadMixin.itemsPerPage);
          _removeDatePickerOverlay();
        },
        onQuickSelect: (preset) {
          _handleQuickSelect(preset, ledgerprovider);
          _removeDatePickerOverlay();
        },
      ),
    );

    Overlay.of(context).insert(_datePickerOverlay!);
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

  void _handleQuickSelect(String preset, LDProvider ledgerprovider) {
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
        // Year presets like "2023", "2022", "2021"
        final year = int.tryParse(preset);
        if (year != null) {
          // Financial year starting from April of that year
          start = DateTime(year, 4, 1);
          end = DateTime(year + 1, 3, 31);
        } else {
          return;
        }
    }

    final startStr =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final endStr =
        '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
    ledgerprovider.fetchLegerData(
        context, startStr, endStr, ledgerprovider.includeBillMargin);
    setState(() => displayedItemCount = ScrollToLoadMixin.itemsPerPage);
  }

  // ─── Filter Popover ────────────────────────────────────────────────

  void _showFilterPopover(
      BuildContext buttonContext, ThemesProvider theme, LDProvider ledgerprovider) {
    ledgerprovider.setfilterpage = 'ledger';

    final filters = <(String, List<SingingCharacter>)>[
      ('All', [SingingCharacter.receipt, SingingCharacter.payment, SingingCharacter.journal, SingingCharacter.systemjournal, SingingCharacter.billmargin]),
      ('Receipt', [SingingCharacter.receipt]),
      ('Payment', [SingingCharacter.payment]),
      ('Journal', [SingingCharacter.journal]),
      ('System Journal', [SingingCharacter.systemjournal]),
      ('Bill Margin', [SingingCharacter.billmargin]),
    ];

    // Determine current selection label
    String currentLabel = 'All';
    final selected = ledgerprovider.selectedFilters;
    if (selected.length == 1) {
      final single = selected.first;
      final match = filters.where((f) => f.$2.length == 1 && f.$2.first == single);
      if (match.isNotEmpty) currentLabel = match.first.$1;
    } else if (selected.length < 5) {
      currentLabel = 'All'; // fallback
    }

    shadcn.showPopover(
      context: buttonContext,
      alignment: Alignment.topCenter,
      offset: const Offset(0, 8),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(buttonContext).borderRadiusLg,
      ),
      builder: (popoverContext) {
        return Container(
          width: 180,
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
              final label = f.$1;
              final filterValues = f.$2;
              final isSelected = currentLabel == label;
              return InkWell(
                onTap: () {
                  ledgerprovider.applyLedgerMultiFilter(context, filterValues);
                  setState(() => displayedItemCount = ScrollToLoadMixin.itemsPerPage);
                  shadcn.closeOverlay(popoverContext);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          label,
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

  // ─── Ledger Table ────────────────────────────────────────────────────

  Widget _buildLedgerTable(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    final fullStat = ledgerprovider.ledgerAllData?.fullStat;
    final bool hasData = fullStat != null && fullStat.isNotEmpty;

    // Apply sorting
    final sortedList = hasData ? List.from(fullStat) : [];
    if (sortedList.isNotEmpty && _sortColumnIndex != null) {
      sortedList.sort((a, b) {
        int compareResult = 0;
        switch (_sortColumnIndex) {
          case 0: // Date
            compareResult =
                (a.vOUCHERDATE ?? '').compareTo(b.vOUCHERDATE ?? '');
            break;
          case 1: // Exchange
            compareResult = (a.cOCD ?? '').compareTo(b.cOCD ?? '');
            break;
          case 2: // Type
            compareResult = (a.tYPE ?? '').compareTo(b.tYPE ?? '');
            break;
          case 3: // Details
            compareResult =
                (a.nARRATION ?? '').compareTo(b.nARRATION ?? '');
            break;
          case 4: // Debit
            compareResult = (double.tryParse(a.dRAMT ?? '0') ?? 0)
                .compareTo(double.tryParse(b.dRAMT ?? '0') ?? 0);
            break;
          case 5: // Credit
            compareResult = (double.tryParse(a.cRAMT ?? '0') ?? 0)
                .compareTo(double.tryParse(b.cRAMT ?? '0') ?? 0);
            break;
          case 6: // Net Amount
            compareResult = (double.tryParse(a.nETAMT ?? '0') ?? 0)
                .compareTo(double.tryParse(b.nETAMT ?? '0') ?? 0);
            break;
        }
        return _sortAscending ? compareResult : -compareResult;
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double dateWidth = totalWidth * 0.12;
        final double exchWidth = totalWidth * 0.10;
        final double typeWidth = totalWidth * 0.10;
        final double debitWidth = totalWidth * 0.15;
        final double creditWidth = totalWidth * 0.15;
        final double netWidth = totalWidth * 0.15;
        final double detailsWidth = totalWidth * 0.23;

        final columnWidths = {
          0: shadcn.FixedTableSize(dateWidth),
          1: shadcn.FixedTableSize(exchWidth),
          2: shadcn.FixedTableSize(typeWidth),
          3: shadcn.FixedTableSize(detailsWidth),
          4: shadcn.FixedTableSize(debitWidth),
          5: shadcn.FixedTableSize(creditWidth),
          6: shadcn.FixedTableSize(netWidth),
        };

        return shadcn.OutlinedContainer(
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
                      defaultRowHeight: const shadcn.FixedTableSize(50),
                      columnWidths: columnWidths,
                      rows: [
                        shadcn.TableHeader(
                          cells: [
                            _buildHeaderCell('Date', 0),
                            _buildHeaderCell('Exchange', 1),
                            _buildHeaderCell('Type', 2),
                            _buildHeaderCell('Details', 3),
                            _buildHeaderCell('Debit', 4, true),
                            _buildHeaderCell('Credit', 5, true),
                            _buildHeaderCell('Net Amount', 6, true),
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
                                    const shadcn.FixedTableSize(55),
                                columnWidths: columnWidths,
                                rows: sortedList
                                    .take(displayedItemCount)
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return _buildDataRow(
                                      index, item, ledgerprovider, theme);
                                }).toList(),
                              ),
                            )
                          : Center(
                              child: NoDataFound(secondaryEnabled: false)),
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

  shadcn.TableCell _buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 6;

    EdgeInsets headerPadding;
    if (isFirstColumn) {
      headerPadding = const EdgeInsets.fromLTRB(16, 0, 8, 0);
    } else if (isLastColumn) {
      headerPadding = const EdgeInsets.fromLTRB(8, 0, 16, 0);
    } else {
      headerPadding = const EdgeInsets.symmetric(horizontal: 6);
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
              if (alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              Text(label, style: _getHeaderStyle(context)),
              if (!alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
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

  shadcn.TableRow _buildDataRow(
      int index, dynamic item, LDProvider ledgerprovider, ThemesProvider theme) {
    final isBillEntry = item.tYPE == 'Bill' && item.bill == 'Yes';
    final debitAmt = double.tryParse(item.dRAMT ?? '0') ?? 0;
    final creditAmt = double.tryParse(item.cRAMT ?? '0') ?? 0;

    void onBillTap() async {
      if (!isBillEntry) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: MyntLoader.simple()),
      );
      await ledgerprovider.fetchBillDetails(
        context,
        item.sETTLEMENTNO ?? '',
        item.mKTTYPE ?? '',
        item.cOCD ?? '',
        dateFormatChangeForLedger(item.vOUCHERDATE ?? ''),
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        _showBillDialog(context, theme);
      }
    }

    return shadcn.TableRow(
      cells: [
        // Date
        _buildCellWithHover(
          child: Text(
            dateFormatChangeForLedger(item.vOUCHERDATE?.toString() ?? ''),
            style: _getTextStyle(context),
          ),
          rowIndex: index,
          columnIndex: 0,
          onTap: isBillEntry ? onBillTap : null,
        ),
        // Exchange
        _buildCellWithHover(
          child: Text(item.cOCD ?? '', style: _getTextStyle(context)),
          rowIndex: index,
          columnIndex: 1,
          onTap: isBillEntry ? onBillTap : null,
        ),
        // Type
        _buildCellWithHover(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.tYPE ?? '', style: _getTextStyle(context)),
              if (item.billMargin == 'Yes') ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: resolveThemeColor(context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MARGIN',
                    style: MyntWebTextStyles.caption(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
          rowIndex: index,
          columnIndex: 2,
          onTap: isBillEntry ? onBillTap : null,
        ),
        // Details / Narration
        _buildCellWithHover(
          child: Tooltip(
            message: item.nARRATION ?? '',
            child: item.nARRATION != null && item.nARRATION != ''
                ? RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: item.nARRATION,
                      style: _getTextStyle(context),
                      children: [
                        if (item.bILLNO != null && item.bILLNO.toString().length >= 4)
                          TextSpan(
                            text: ' - (${item.bILLNO.toString().substring(item.bILLNO.toString().length - 4)})',
                            style: _getTextStyle(context,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.primaryDark,
                                    light: MyntColors.primary)),
                          ),
                      ],
                    ),
                  )
                : Text('-', style: _getTextStyle(context)),
          ),
          rowIndex: index,
          columnIndex: 3,
          onTap: isBillEntry ? onBillTap : null,
        ),
        // Debit
        _buildCellWithHover(
          child: Text(
            debitAmt != 0 ? debitAmt.toStringAsFixed(2) : '-',
            style: _getTextStyle(context,
                color: debitAmt != 0 ?   resolveThemeColor(context,
                  dark: MyntColors.lossDark,
                  light: MyntColors.loss) : null),
          ),
          rowIndex: index,
          columnIndex: 4,
          alignRight: true,
          onTap: isBillEntry ? onBillTap : null,
        ),
        // Credit
        _buildCellWithHover(
          child: Text(
            creditAmt != 0 ? creditAmt.toStringAsFixed(2) : '-',
            style: _getTextStyle(context,
                color: creditAmt != 0 ? resolveThemeColor(context,
                  dark: MyntColors.profitDark,
                  light: MyntColors.profit) : null),
          ),
          rowIndex: index,
          columnIndex: 5,
          alignRight: true,
          onTap: isBillEntry ? onBillTap : null,
        ),
        // Net Amount
        _buildCellWithHover(
          child: Text(
            (double.tryParse(item.nETAMT ?? '0') ?? 0).toStringAsFixed(2),
            style: _getTextStyle(context),
          ),
          rowIndex: index,
          columnIndex: 6,
          alignRight: true,
          onTap: isBillEntry ? onBillTap : null,
        ),
      ],
    );
  }

  shadcn.TableCell _buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    VoidCallback? onTap,
    bool alignRight = false,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 6;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 12, 12, 12);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(12, 12, 16, 12);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
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

  // ─── Bottom Sheets ───────────────────────────────────────────────────

  void _showBillDialog(BuildContext context, ThemesProvider theme) {
    final ledgerdata = ref.read(ledgerProvider);
    final billData = ledgerdata.ledgerBillData;
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);
    final transactionCount = billData?.transactions?.length ?? 0;

    // Calculate total from transactions
    double total = 0;
    if (billData?.transactions != null) {
      for (var item in billData!.transactions!) {
        total += double.tryParse(item.nETAMT ?? '0') ?? 0;
      }
    }

    final billSearchController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.6).clamp(900.0, 1200.0);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Filter transactions by search
            final filteredTransactions = billData?.transactions?.where((item) {
              if (searchQuery.isEmpty) return true;
              return (item.sCRIPNAME ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
            }).toList();

            return Dialog(
              backgroundColor:
                  theme.isDarkMode ? MyntColors.dialogDark : MyntColors.dialog,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: dialogWidth,
                height: 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bills and Taxes',
                                  style: MyntWebTextStyles.title(context,
                                      color: primaryColor,
                                      fontWeight: MyntFonts.semiBold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bills and Taxes Details About the bill',
                                  style: MyntWebTextStyles.bodySmall(context,
                                      color: secondaryColor),
                                ),
                              ],
                            ),
                          ),
                          // Transaction count
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$transactionCount Transactions',
                              style: MyntWebTextStyles.body(context,
                                  color: primaryColor,
                                  fontWeight: MyntFonts.medium),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Search field
                          SizedBox(
                            width: 200,
                            height: 36,
                            child: MyntSearchTextField(
                              controller: billSearchController,
                              placeholder: 'Search',
                              leadingIcon: 'assets/icon/search.svg',
                              onChanged: (value) {
                                setDialogState(() => searchQuery = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              billSearchController.dispose();
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close_rounded,
                                size: 20, color: secondaryColor),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: dividerColor),
                    const SizedBox(height: 12),
                    // Content
                    if (billData?.expenses == null &&
                        billData?.transactions == null)
                      const Expanded(
                          child: Center(child: Text('No data available')))
                    else
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Expense cards - horizontal scrollable
                              if (billData?.expenses != null &&
                                  billData!.expenses!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    for (int i = 0;
                                        i < billData.expenses!.length;
                                        i++) ...[
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                color: dividerColor),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                (billData.expenses![i]
                                                            .sCRIPNAME ??
                                                        '')
                                                    .toUpperCase(),
                                                style: MyntWebTextStyles
                                                    .bodySmall(context,
                                                        color: primaryColor,
                                                        fontWeight: MyntFonts
                                                            .semiBold),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Divider(
                                                  height: 1,
                                                  color: dividerColor),
                                              const SizedBox(height: 6),
                                              Text(
                                                billData.expenses![i]
                                                        .nETAMT ??
                                                    '0',
                                                style: MyntWebTextStyles
                                                    .bodySmall(context,
                                                        color: primaryColor,
                                                        fontWeight: MyntFonts
                                                            .medium),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (i <
                                          billData.expenses!.length - 1)
                                        const SizedBox(width: 12),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              // Transactions table
                              if (filteredTransactions != null &&
                                  filteredTransactions.isNotEmpty) ...[
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double tableWidth = constraints.maxWidth;
                                      final double scripWidth = tableWidth * 0.22;
                                      final double colWidth = (tableWidth - scripWidth) / 8;

                                      final billColumnWidths = {
                                        0: shadcn.FixedTableSize(scripWidth),
                                        1: shadcn.FixedTableSize(colWidth),
                                        2: shadcn.FixedTableSize(colWidth),
                                        3: shadcn.FixedTableSize(colWidth),
                                        4: shadcn.FixedTableSize(colWidth),
                                        5: shadcn.FixedTableSize(colWidth),
                                        6: shadcn.FixedTableSize(colWidth),
                                        7: shadcn.FixedTableSize(colWidth),
                                        8: shadcn.FixedTableSize(colWidth),
                                      };

                                      shadcn.TableCell billHeaderCell(String label, [bool alignRight = false]) {
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
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Text(label, style: _getHeaderStyle(context)),
                                          ),
                                        );
                                      }

                                      shadcn.TableCell billDataCell(String? value, [bool alignRight = false]) {
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
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Text(
                                              value != null && double.tryParse(value) != null
                                                  ? double.parse(value).toStringAsFixed(2)
                                                  : value ?? '-',
                                              style: _getTextStyle(context),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      }

                                      return shadcn.OutlinedContainer(
                                        child: Column(
                                          children: [
                                            // Fixed Header
                                            shadcn.Table(
                                              defaultRowHeight: const shadcn.FixedTableSize(50),
                                              columnWidths: billColumnWidths,
                                              rows: [
                                                shadcn.TableHeader(
                                                  cells: [
                                                    billHeaderCell('Scrip'),
                                                    billHeaderCell('BQty', true),
                                                    billHeaderCell('BRate', true),
                                                    billHeaderCell('BAmount', true),
                                                    billHeaderCell('SQty', true),
                                                    billHeaderCell('SRate', true),
                                                    billHeaderCell('SAmount', true),
                                                    billHeaderCell('NQty', true),
                                                    billHeaderCell('NAmt', true),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // Scrollable Body
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: shadcn.Table(
                                                  defaultRowHeight: const shadcn.FixedTableSize(52),
                                                  columnWidths: billColumnWidths,
                                                  rows: filteredTransactions
                                                      .map((item) {
                                                    return shadcn.TableRow(
                                                      cells: [
                                                        billDataCell(item.sCRIPNAME),
                                                        billDataCell(item.bQTY, true),
                                                        billDataCell(item.bRATE, true),
                                                        billDataCell(item.bAMT, true),
                                                        billDataCell(item.sQTY, true),
                                                        billDataCell(item.sRATE, true),
                                                        billDataCell(item.sAMT, true),
                                                        billDataCell(item.nETQTY, true),
                                                        billDataCell(item.nETAMT, true),
                                                      ],
                                                    );
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
                              ],
                            ],
                          ),
                        ),
                      ),
                    // Total footer
                    if (billData?.transactions != null &&
                        billData!.transactions!.isNotEmpty) ...[
                      Divider(height: 1, color: dividerColor),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Total : ${total.toStringAsFixed(2)}',
                            style: MyntWebTextStyles.body(context,
                                color: total < 0
                                    ? resolveThemeColor(context,
                                        dark: MyntColors.lossDark,
                                        light: MyntColors.loss)
                                    : resolveThemeColor(context,
                                        dark: MyntColors.profitDark,
                                        light: MyntColors.profit),
                                fontWeight: MyntFonts.semiBold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _downloadDialog(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    return Dialog(
      backgroundColor: theme.isDarkMode ? MyntColors.dialogDark : MyntColors.dialog,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Download as',
                    style: MyntWebTextStyles.title(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary),
                      fontWeight: MyntFonts.semiBold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pop(context);
                  String currentDate =
                      DateFormat("dd/MM/yyyy").format(DateTime.now());
                  ledgerprovider.pdfdownloadforledger(
                    context,
                    ledgerprovider.ledgerAllData?.toJson() ?? {},
                    ledgerprovider.ledgerAllData?.drAmt ?? '0.00',
                    ledgerprovider.ledgerAllData?.crAmt ?? '0.00',
                    ledgerprovider.ledgerAllData?.openingBalance ?? '0.00',
                    ledgerprovider.ledgerAllData?.closingBalance ?? '0.00',
                    ledgerprovider.startDate,
                    currentDate,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        assets.pdfIcon,
                        height: 44,
                        width: 44,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download,
                              size: 14,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary)),
                          const SizedBox(width: 4),
                          Text(
                            'PDF',
                            style: MyntWebTextStyles.bodySmall(
                              context,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
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
}

// ─── Date Picker Overlay ─────────────────────────────────────────────

class _DatePickerOverlay extends StatefulWidget {
  final Offset buttonOffset;
  final ThemesProvider theme;
  final LDProvider ledgerprovider;
  final DateTime leftMonth;
  final DateTime rightMonth;
  final DateTime? tempStartDate;
  final DateTime? tempEndDate;
  final VoidCallback onClose;
  final void Function(DateTime start, DateTime end) onApply;
  final void Function(String preset) onQuickSelect;

  const _DatePickerOverlay({
    required this.buttonOffset,
    required this.theme,
    required this.ledgerprovider,
    required this.leftMonth,
    required this.rightMonth,
    required this.tempStartDate,
    required this.tempEndDate,
    required this.onClose,
    required this.onApply,
    required this.onQuickSelect,
  });

  @override
  State<_DatePickerOverlay> createState() => _DatePickerOverlayState();
}

class _DatePickerOverlayState extends State<_DatePickerOverlay> {
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
        // Tap outside to close
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Calendar popup
        Positioned(
          left: widget.buttonOffset.dx,
          top: widget.buttonOffset.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: widget.theme.isDarkMode
                ? colors.colorBlack
                : colors.colorWhite,
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
                  // Two calendars side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildMonthCalendar(_leftMonth, true)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildMonthCalendar(_rightMonth, false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quick presets
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
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month header with navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (isLeft) {
                    _leftMonth =
                        DateTime(_leftMonth.year, _leftMonth.month - 1);
                    _rightMonth =
                        DateTime(_leftMonth.year, _leftMonth.month + 1);
                  } else {
                    _rightMonth =
                        DateTime(_rightMonth.year, _rightMonth.month - 1);
                    _leftMonth =
                        DateTime(_rightMonth.year, _rightMonth.month - 1);
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
                    _leftMonth =
                        DateTime(_leftMonth.year, _leftMonth.month + 1);
                    _rightMonth =
                        DateTime(_leftMonth.year, _leftMonth.month + 1);
                  } else {
                    _rightMonth =
                        DateTime(_rightMonth.year, _rightMonth.month + 1);
                    _leftMonth =
                        DateTime(_rightMonth.year, _rightMonth.month - 1);
                  }
                });
              },
              child:
                  Icon(Icons.chevron_right, size: 20, color: secondaryColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Weekday headers
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
        // Day cells
        ...List.generate(6, (week) {
          return Row(
            children: List.generate(7, (day) {
              final dayNum = week * 7 + day - firstDayWeekday + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }
              final date = DateTime(month.year, month.month, dayNum);
              final isToday = _isSameDay(date, DateTime.now());
              final isStart =
                  _startDate != null && _isSameDay(date, _startDate!);
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
                        // Auto apply when both dates selected
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

// ─── Ledger Filter Popover ───────────────────────────────────────────

