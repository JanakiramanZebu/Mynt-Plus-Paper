import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../../provider/ledger_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../sharedWidget/scroll_to_load_mixin.dart';
import '../../../../utils/rupee_convert_format.dart';

class TaxPnlScreenWeb extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const TaxPnlScreenWeb({super.key, this.onBack});

  @override
  ConsumerState<TaxPnlScreenWeb> createState() => _TaxPnlScreenWebState();
}

class _TaxPnlScreenWebState extends ConsumerState<TaxPnlScreenWeb>
    with SingleTickerProviderStateMixin, ScrollToLoadMixin {
  @override
  ScrollController get tableScrollController => _scrollController;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Expandable section state for equities
  final Map<String, bool> _expandedSections = {
    'ASSETS': false,
    'LIABILITIES': false,
    'SHORT TERM': false,
    'TRADING': false,
    'LONG TERM': false,
  };
  final ValueNotifier<String?> _hoveredRowKey = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    initScrollToLoad();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(ledgerProvider).taxpnlExTabchange(_tabController.index);
        resetDisplayCount();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ledger = ref.read(ledgerProvider);
      ledger.getYearlistTaxpnl();
      ledger.fetchtaxpnleqdata(context, ledger.yearforTaxpnl);
      ledger.chargesforeqtaxpnl(context, ledger.yearforTaxpnl);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    disposeScrollToLoad();
    _scrollController.dispose();
    _hoveredRowKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ledger = ref.watch(ledgerProvider);
    ref.watch(themeProvider);

    return SizedBox.expand(
      child: Container(
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, ledger),
            // const Divider(height: 1),
            // Summary cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSummaryCards(context, ledger),
            ),
            const SizedBox(height: 16),
            // Tabs
            _buildTabBar(context),
            // const Divider(height: 1),
            // Tab content
            Expanded(
              child: ledger.reportsloading || ledger.taxderloading
                  ? Center(child: MyntLoader.simple())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEquitiesTab(context, ledger),
                        _buildDerivativesTab(context, ledger),
                        _buildCommodityTab(context, ledger),
                        _buildCurrencyTab(context, ledger),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, LDProvider ledger) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          if (widget.onBack != null) ...[
            CustomBackBtn(onBack: widget.onBack),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tax P&L',
                  style: MyntWebTextStyles.title(context,
                      fontWeight: FontWeight.w600)),
              // const SizedBox(height: 2),
              // Text('Tax P&L Data',
              //     style: MyntWebTextStyles.caption(context,
              //         darkColor: MyntColors.textSecondaryDark,
              //         lightColor: MyntColors.textSecondary)),
            ],
          ),
          const Spacer(),
          // Download button
          _buildDownloadButton(context, ledger),
          const SizedBox(width: 12),
          // Year picker
          _buildYearPicker(context, ledger),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, LDProvider ledger) {
    return SizedBox(
      width: 40,
      height: 40,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (!ledger.taxpnlloading) {
            _showDownloadDialog(context, ledger);
          }
        },
        child: Center(
          child: ledger.taxpnlloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : SvgPicture.asset(
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
    );
  }

  void _showDownloadDialog(BuildContext context, LDProvider ledger) {
    final now = DateTime.now();
    final currentFY = now.month >= 4 ? now.year : now.year - 1;
    int selectedYear = ledger.yearforTaxpnl;
    String selectedFormat = 'PDF';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final primaryColor = resolveThemeColor(context,
                dark: MyntColors.primaryDark, light: MyntColors.primary);
            final textColor = resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary);
            final secondaryColor = resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary);

            final fromMonth = 'Apr $selectedYear';
            final toMonth = 'Mar ${selectedYear + 1}';

            return Dialog(
               backgroundColor: resolveThemeColor(context,
              dark: MyntColors.cardDark, light: MyntColors.card),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial Year label
                    Text('Financial Year',
                        style: MyntWebTextStyles.title(context,
                            color: secondaryColor,
                            fontWeight: MyntFonts.medium)),
                    const SizedBox(height: 8),
                    // Year selector with arrows
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (selectedYear > currentFY - 4) {
                                setDialogState(
                                    () => selectedYear = selectedYear - 1);
                              }
                            },
                            child: Icon(Icons.chevron_left,
                                size: 22, color: textColor),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$fromMonth - $toMonth',
                                style: MyntWebTextStyles.body(context,
                                    color: textColor,
                                    fontWeight: MyntFonts.semiBold),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (selectedYear < currentFY) {
                                setDialogState(
                                    () => selectedYear = selectedYear + 1);
                              }
                            },
                            child: Icon(Icons.chevron_right,
                                size: 22, color: textColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // PDF / Excel radio with icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // PDF option
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setDialogState(() => selectedFormat = 'PDF'),
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: [
                                Icon(Icons.picture_as_pdf,
                                    size: 40,
                                    color: selectedFormat == 'PDF'
                                        ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
                                        : secondaryColor),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: 'PDF',
                                      groupValue: selectedFormat,
                                      onChanged: (v) => setDialogState(
                                          () => selectedFormat = v!),
                                      activeColor: primaryColor,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Text('PDF',
                                        style: MyntWebTextStyles.bodySmall(
                                            context,
                                            color: textColor,
                                            fontWeight: MyntFonts.medium)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Excel option
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setDialogState(() => selectedFormat = 'EXCEL'),
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: [
                                Icon(Icons.table_chart,
                                    size: 40,
                                    color: selectedFormat == 'EXCEL'
                                        ? resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success)
                                        : secondaryColor),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: 'EXCEL',
                                      groupValue: selectedFormat,
                                      onChanged: (v) => setDialogState(
                                          () => selectedFormat = v!),
                                      activeColor: primaryColor,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Text('Excel',
                                        style: MyntWebTextStyles.bodySmall(
                                            context,
                                            color: textColor,
                                            fontWeight: MyntFonts.medium)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Download button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          ledger.downloadTaxPnlForWeb(
                              context, selectedYear, selectedFormat);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text('Download',
                            style: MyntWebTextStyles.bodySmall(context,
                                color: Colors.white,
                                fontWeight: MyntFonts.semiBold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildYearPicker(BuildContext context, LDProvider ledger) {
    return Builder(
      builder: (buttonContext) {
        return InkWell(
          onTap: () => _showYearPopover(buttonContext, ledger),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                Icon(Icons.calendar_today,
                    size: 16,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary)),
                const SizedBox(width: 8),
                Text(
                  '${ledger.yearforTaxpnl}',
                  style: MyntWebTextStyles.bodySmall(context,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                      fontWeight: MyntFonts.medium),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down,
                    size: 18,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showYearPopover(BuildContext buttonContext, LDProvider ledger) {
    // Generate year list: current FY year back 4 years
    final now = DateTime.now();
    final currentFY = now.month >= 4 ? now.year : now.year - 1;
    final years = List.generate(5, (i) => currentFY - i);

    shadcn.showPopover(
      context: buttonContext,
      alignment: Alignment.topCenter,
      offset: const Offset(0, 8),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(context).borderRadiusLg,
      ),
      builder: (popoverContext) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(context).borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: years.map((year) {
                  final isSelected = ledger.yearforTaxpnl == year;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ledger.fetchtaxpnleqdata(context, year);
                        ledger.chargesforeqtaxpnl(context, year);
                        shadcn.closeOverlay(popoverContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Text(
                          '$year',
                          style: MyntWebTextStyles.bodySmall(context,
                              color: isSelected
                                  ? resolveThemeColor(context,
                                      dark: MyntColors.primaryDark,
                                      light: MyntColors.primary)
                                  : resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                              fontWeight: isSelected
                                  ? MyntFonts.semiBold
                                  : MyntFonts.regular),
                        ),
                      ),
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

  // ─── Summary Cards ───────────────────────────────────────────────────

  Widget _buildSummaryCards(BuildContext context, LDProvider ledger) {
    final eqDetails = ledger.taxpnleq?.data?.details;
    final detailsMap = ledger.taxpnldercomcur?.details;

    // Equity net = trading + delivery_sell - delivery_buy + charges_total
    double equityNet = 0;
    {
      final trading = _parseDoubleDyn(eqDetails?['trading']);
      final deliverySell = _parseDoubleDyn(eqDetails?['delivery_sell']);
      final deliveryBuy = _parseDoubleDyn(eqDetails?['delivery_buy']);
      final segval = _parseDouble(ledger.taxpnleqCharge?.total);
      equityNet = trading + deliverySell - deliveryBuy + segval;
    }

    // Derivative net from details.der_total.der_total_value
    double derNet = 0;
    if (detailsMap?['der_total'] is Map) {
      derNet = _parseDoubleDyn(detailsMap!['der_total']['der_total_value']);
    }

    // Commodity net from details.com_total.com_total_value
    double comNet = 0;
    if (detailsMap?['com_total'] is Map) {
      comNet = _parseDoubleDyn(detailsMap!['com_total']['com_total_value']);
    }

    // Currency net from details.curr_total.curr_total_value
    double curNet = 0;
    if (detailsMap?['curr_total'] is Map) {
      curNet = _parseDoubleDyn(detailsMap!['curr_total']['curr_total_value']);
    }

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
            _summaryCard(
              context: context,
              label: 'Equity Net',
              value: equityNet,
              onTap: () => _showBifurcationDialog(context, ledger, 'Equity'),
            ),
            _summaryCard(
              context: context,
              label: 'Derivative Net',
              value: derNet,
              onTap: () =>
                  _showBifurcationDialog(context, ledger, 'Derivatives'),
            ),
            _summaryCard(
              context: context,
              label: 'Commodity Net',
              value: comNet,
              onTap: () =>
                  _showBifurcationDialog(context, ledger, 'Commodity'),
            ),
            _summaryCard(
              context: context,
              label: 'Currency Net',
              value: curNet,
              onTap: () =>
                  _showBifurcationDialog(context, ledger, 'Currency'),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required BuildContext context,
    required String label,
    required double value,
    required VoidCallback onTap,
  }) {
    final valueColor = value == 0
        ? resolveThemeColor(context,
            dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)
        : value < 0
            ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
            : resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: shadcn.Theme(
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: MyntWebTextStyles.bodySmall(
                                  context,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                                  fontWeight: MyntFonts.medium,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                size: 10,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          value.toStringAsFixed(2).toIndianRupee(),
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
        ),
      ),
    );
  }

  // ─── Bifurcation Dialog ─────────────────────────────────────────────

  void _showBifurcationDialog(
      BuildContext context, LDProvider ledger, String segment) {
    final rows = <MapEntry<String, double>>[];
    double total = 0;

    if (segment == 'Equity') {
      // P&L breakdown from details
      final details = ledger.taxpnleq?.data?.details;
      final deliverySell = _parseDoubleDyn(details?['delivery_sell']);
      final deliveryBuy = _parseDoubleDyn(details?['delivery_buy']);
      final trading = _parseDoubleDyn(details?['trading']);
      rows.add(MapEntry('EQUITY DELIVERY SELL', deliverySell));
      rows.add(MapEntry('EQUITY DELIVERY BUY', -deliveryBuy));
      rows.add(MapEntry('EQUITY TRADING', trading));
      // Charges from taxpnleqCharge
      final charges = ledger.taxpnleqCharge;
      final segval = _parseDouble(charges?.total);
      if (charges?.eq != null) {
        for (final c in charges!.eq!) {
          final amt = _parseDouble(c.nOTPROFIT);
          rows.add(MapEntry(c.sCRIPSYMBOL ?? '', amt));
        }
      }
      // Total = trading + delivery_sell - delivery_buy + charges_total
      total = trading + deliverySell - deliveryBuy + segval;
    } else {
      // Derivatives / Commodity / Currency
      final detailsMap = ledger.taxpnldercomcur?.details;
      final chargesData = ledger.taxpnldercomcur?.data?.charges;

      String prefix = '';
      List<Map<String, dynamic>>? chargesList;
      Map<String, dynamic>? segTotal;

      if (segment == 'Derivatives') {
        prefix = 'der';
        chargesList = chargesData?.derCharges;
        segTotal = detailsMap?['der_total'] is Map
            ? Map<String, dynamic>.from(detailsMap!['der_total'])
            : null;
      } else if (segment == 'Commodity') {
        prefix = 'com';
        chargesList = chargesData?.commCharges;
        segTotal = detailsMap?['com_total'] is Map
            ? Map<String, dynamic>.from(detailsMap!['com_total'])
            : null;
      } else if (segment == 'Currency') {
        prefix = 'curr';
        chargesList = chargesData?.curCharges;
        segTotal = detailsMap?['curr_total'] is Map
            ? Map<String, dynamic>.from(detailsMap!['curr_total'])
            : null;
      }

      if (segTotal != null) {
        final booked = _parseDoubleDyn(segTotal['${prefix}_total_booked']);
        final futOpen = _parseDoubleDyn(segTotal['${prefix}_fut_open_val']);
        final seOpen = _parseDoubleDyn(segTotal['${prefix}_se_open']);
        final buOpen = _parseDoubleDyn(segTotal['${prefix}_bu_open']);
        rows.add(MapEntry('BOOKED POSITION', booked));
        rows.add(MapEntry('FUTURE OPEN POSITION', futOpen));
        rows.add(MapEntry('OPTION SELL OPEN POSITION', seOpen));
        rows.add(MapEntry('OPTION OPEN BUY POSITION', buOpen));
      }
      // Charges
      if (chargesList != null) {
        for (final c in chargesList) {
          final amt = _parseDoubleDyn(c['NETAMT']);
          rows.add(MapEntry(c['SCRIP_SYMBOL']?.toString() ?? '', amt));
        }
      }
      // Reversed option sell open position
      if (segTotal != null) {
        final seOpen = _parseDoubleDyn(segTotal['${prefix}_se_open']);
        rows.add(MapEntry('REVERSED OPTION SELL OPEN POSITION', -seOpen));
      }
      // Total from details
      if (segTotal != null) {
        total = _parseDoubleDyn(segTotal['${prefix}_total_value']);
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        final secondaryColor = resolveThemeColor(context,
            dark: MyntColors.textSecondaryDark,
            light: MyntColors.textSecondary);
        final borderColor = resolveThemeColor(context,
            dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);

        return Dialog(
          backgroundColor: resolveThemeColor(context,
              dark: MyntColors.cardDark, light: MyntColors.card),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      Text('Bifurcation of Bill',
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
                                child: Text('Particulars',
                                    style: MyntWebTextStyles.para(context,
                                        darkColor: MyntColors.textSecondaryDark,
                                        lightColor: MyntColors.textSecondary,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(segment,
                                    textAlign: TextAlign.right,
                                    style: MyntWebTextStyles.para(context,
                                        darkColor: MyntColors.textSecondaryDark,
                                        lightColor: MyntColors.textSecondary,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                        // Rows
                        if (rows.isEmpty)
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
                              itemCount: rows.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1, color: borderColor),
                              itemBuilder: (context, index) {
                                final row = rows[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(row.key,
                                            style: MyntWebTextStyles.body(context,
                                                darkColor: MyntColors.textPrimaryDark,
                                                lightColor: MyntColors.textPrimary,
                                                fontWeight: MyntFonts.medium)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            '${row.value < 0 ? '- ' : ''}${row.value.abs().toStringAsFixed(2)}',
                                            textAlign: TextAlign.right,
                                            style: MyntWebTextStyles.body(context,
                                                darkColor: MyntColors.textPrimaryDark,
                                                lightColor: MyntColors.textPrimary,
                                                fontWeight: MyntFonts.medium)),
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
                                    '${total < 0 ? '- ' : ''}${total.abs().toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: MyntWebTextStyles.body(context,
                                        darkColor: total < 0
                                            ? MyntColors.lossDark
                                            : total > 0
                                                ? MyntColors.profitDark
                                                : MyntColors.textPrimaryDark,
                                        lightColor: total < 0
                                            ? MyntColors.loss
                                            : total > 0
                                                ? MyntColors.profit
                                                : MyntColors.textPrimary,
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

  double _parseDoubleDyn(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  // ─── Tab Bar ─────────────────────────────────────────────────────────

  Widget _buildTabBar(BuildContext context) {
    final tabLabels = ['Equity', 'Derivatives', 'Commodity', 'Currency'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: tabLabels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _tabController.index == index;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tabController.animateTo(index);
                });
                ref.read(ledgerProvider).taxpnlExTabchange(index);
              },
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
                  label,
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

  // ─── Equities Tab ────────────────────────────────────────────────────

  Widget _buildEquitiesTab(BuildContext context, LDProvider ledger) {
    final eqData = ledger.taxpnleq?.data;
    if (eqData == null) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    final sections = <_SectionData>[];
    if (eqData.aSSETS != null && eqData.aSSETS!.isNotEmpty) {
      sections.add(_SectionData('ASSETS', eqData.aSSETS!, isEquity: true));
    }
    if (eqData.lIABILITIES != null && eqData.lIABILITIES!.isNotEmpty) {
      sections.add(_SectionData('LIABILITIES', eqData.lIABILITIES!, isEquity: true));
    }
    if (eqData.sHORTTERM != null && eqData.sHORTTERM!.isNotEmpty) {
      sections.add(_SectionData('SHORT TERM', eqData.sHORTTERM!, isEquity: true));
    }
    if (eqData.tRADING != null && eqData.tRADING!.isNotEmpty) {
      sections.add(_SectionData('TRADING', eqData.tRADING!, isEquity: true));
    }
    // LONG TERM - check if there's longterm data in assets with LONG_TERM > 0
    // The API doesn't have a separate LONGTERM array, so we show it if longterm_Total != 0
    if (_parseDouble(eqData.longtermTotal) != 0) {
      // Long term items are inside ASSETS with LONG_TERM field
      sections.add(_SectionData('LONG TERM', [], isEquity: true));
    }

    if (sections.isEmpty) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    return _buildExpandableSections(context, sections);
  }

  // ─── Derivatives Tab ─────────────────────────────────────────────────

  Widget _buildDerivativesTab(BuildContext context, LDProvider ledger) {
    final derData = ledger.taxpnldercomcur?.data?.derivatives;
    if (derData == null) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    final sections = <_SectionData>[];
    if (derData.derFutBooked != null && derData.derFutBooked!.isNotEmpty) {
      sections.add(_SectionData('FUTURE CLOSED', derData.derFutBooked!));
    }
    if (derData.derFutOpen != null && derData.derFutOpen!.isNotEmpty) {
      sections.add(_SectionData('FUTURE OPEN', derData.derFutOpen!));
    }
    if (derData.derOptBooked != null && derData.derOptBooked!.isNotEmpty) {
      sections.add(_SectionData('OPTION CLOSED', derData.derOptBooked!));
    }
    if (derData.derOptOpen != null && derData.derOptOpen!.isNotEmpty) {
      sections.add(_SectionData('OPTION OPEN', derData.derOptOpen!));
    }

    if (sections.isEmpty) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    return _buildExpandableSections(context, sections);
  }

  // ─── Commodity Tab ───────────────────────────────────────────────────

  Widget _buildCommodityTab(BuildContext context, LDProvider ledger) {
    final comData = ledger.taxpnldercomcur?.data?.commodity;
    if (comData == null) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    final sections = <_SectionData>[];
    if (comData.comFutBooked != null && comData.comFutBooked!.isNotEmpty) {
      sections.add(_SectionData('FUTURE CLOSED', comData.comFutBooked!));
    }
    if (comData.comFutOpen != null && comData.comFutOpen!.isNotEmpty) {
      sections.add(_SectionData('FUTURE OPEN', comData.comFutOpen!));
    }
    if (comData.comOptBooked != null && comData.comOptBooked!.isNotEmpty) {
      sections.add(_SectionData('OPTION CLOSED', comData.comOptBooked!));
    }
    if (comData.comOptOpen != null && comData.comOptOpen!.isNotEmpty) {
      sections.add(_SectionData('OPTION OPEN', comData.comOptOpen!));
    }

    if (sections.isEmpty) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    return _buildExpandableSections(context, sections);
  }

  // ─── Currency Tab ────────────────────────────────────────────────────

  Widget _buildCurrencyTab(BuildContext context, LDProvider ledger) {
    final curData = ledger.taxpnldercomcur?.data?.currency;
    if (curData == null) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    final sections = <_SectionData>[];
    if (curData.currFutBooked != null && curData.currFutBooked!.isNotEmpty) {
      sections.add(_SectionData('FUTURE CLOSED', curData.currFutBooked!));
    }
    if (curData.currFutOpen != null && curData.currFutOpen!.isNotEmpty) {
      sections.add(_SectionData('FUTURE OPEN', curData.currFutOpen!));
    }
    if (curData.currOptBooked != null && curData.currOptBooked!.isNotEmpty) {
      sections.add(_SectionData('OPTION CLOSED', curData.currOptBooked!));
    }
    if (curData.currOptOpen != null && curData.currOptOpen!.isNotEmpty) {
      sections.add(_SectionData('OPTION OPEN', curData.currOptOpen!));
    }

    if (sections.isEmpty) {
      return const Center(child: NoDataFound(secondaryEnabled: false));
    }

    return _buildExpandableSections(context, sections);
  }

  // ─── Expandable Sections with Table ──────────────────────────────────

  Widget _buildExpandableSections(
      BuildContext context, List<_SectionData> sections) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          // Symbol + BuyQty + BuyRate(amt) + SellQty + SellRate(amt) + NetQty + NetRate(amt) + ClosePrice + P&L
          final columnWidths = {
            0: shadcn.FixedTableSize(totalWidth * 0.18), // Symbol
            1: shadcn.FixedTableSize(totalWidth * 0.08), // Buy Qty
            2: shadcn.FixedTableSize(totalWidth * 0.12), // Buy Rate + Amt
            3: shadcn.FixedTableSize(totalWidth * 0.08), // Sell Qty
            4: shadcn.FixedTableSize(totalWidth * 0.12), // Sell Rate + Amt
            5: shadcn.FixedTableSize(totalWidth * 0.08), // Net Qty
            6: shadcn.FixedTableSize(totalWidth * 0.12), // Net Rate + Amt
            7: shadcn.FixedTableSize(totalWidth * 0.10), // Close Price
            8: shadcn.FixedTableSize(totalWidth * 0.12), // P&L
          };

          return shadcn.OutlinedContainer(
            child: Column(
              children: [
                // Table header
                shadcn.Table(
                  defaultRowHeight: const shadcn.FixedTableSize(44),
                  columnWidths: columnWidths,
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        _buildHeaderCell('Symbol'),
                        _buildHeaderCell('Buy Qty', alignRight: true),
                        _buildHeaderCell('Buy Rate', alignRight: true),
                        _buildHeaderCell('Sell Qty', alignRight: true),
                        _buildHeaderCell('Sell Rate', alignRight: true),
                        _buildHeaderCell('Net Qty', alignRight: true),
                        _buildHeaderCell('Net Rate', alignRight: true),
                        _buildHeaderCell('Close Price', alignRight: true),
                        _buildHeaderCell('P&L', alignRight: true),
                      ],
                    ),
                  ],
                ),
                // Expandable sections
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return _buildExpandableSection(
                          context, section, columnWidths);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, _SectionData section,
      Map<int, shadcn.TableSize> columnWidths) {
    final isExpanded = _expandedSections[section.title] ?? false;

    return Column(
      children: [
         Divider(
            height: 1,
            thickness: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark,
                light: MyntColors.divider),
          ),
        // Section header (expandable)
        InkWell(
          onTap: () {
            setState(() {
              _expandedSections[section.title] = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: isDarkMode(context)
                ? MyntColors.transparent : MyntColors.overlayBg,
            child: Row(
              children: [
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Text(
                  section.title,
                  style: MyntWebTextStyles.bodySmall(context,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                      fontWeight: MyntFonts.semiBold),
                ),
                const Spacer(),
                Text(
                  '${section.data.length} items',
                  style: MyntWebTextStyles.caption(context,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        // Expanded data rows
        if (isExpanded && section.data.isNotEmpty)
          shadcn.Table(
            defaultRowHeight: const shadcn.FixedTableSize(64),
            columnWidths: columnWidths,
            rows: takeDisplayed(section.data).asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return _buildDataRow(context, section.title, i, item, section.isEquity);
            }).toList(),
          ),
        if (isExpanded && section.data.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No data available',
                style: MyntWebTextStyles.bodySmall(context,
                    darkColor: MyntColors.textSecondaryDark,
                    lightColor: MyntColors.textSecondary)),
          ),
      ],
    );
  }

  shadcn.TableRow _buildDataRow(BuildContext context, String sectionTitle,
      int index, dynamic item, bool isEquity) {
    String symbol, buyQty, buyRate, buyAmt, sellQty, sellRate, sellAmt, netQty, netRate, netAmount, closePrice, pnl;

    if (item is Map<String, dynamic>) {
      symbol = (item['SCRIP_NAMEDATA']?.toString().isNotEmpty == true ? item['SCRIP_NAMEDATA'].toString() : null) ?? item['SCRIP_NAME']?.toString() ?? item['SCRIP_SYMBOL']?.toString() ?? '';
      buyQty = _formatQtyNum(item['BUYQTY']);
      buyRate = _formatNum(item['BUYRATE']);
      buyAmt = _formatNum(item['BUY_AMT']);
      sellQty = _formatQtyNum(item['SALEQTY']);
      sellRate = _formatNum(item['SALERATE']);
      sellAmt = _formatNum(item['SALE_AMT']);
      netQty = _formatQtyNum(item['NETQTY']);
      netRate = _formatNum(item['NETRATE']);
      netAmount = _formatNum(item['NET_AMOUNT']);
      closePrice = _formatNum(item['CL_PRICE']);
      pnl = _formatNum(item['NOTIONAL_NET']);
    } else {
      try {
        symbol = (item.sCRIPNAMEDATA?.isNotEmpty == true ? item.sCRIPNAMEDATA : null) ?? item.sCRIPNAME?.toString() ?? '';
        buyQty = _formatQtyStr(item.bUYQTY);
        buyRate = _formatStr(item.bUYRATE);
        buyAmt = _formatStr(item.bUYAMT);
        sellQty = _formatQtyStr(item.sALEQTY);
        sellRate = _formatStr(item.sALERATE);
        sellAmt = _formatStr(item.sALEAMT);
        netQty = _formatQtyStr(item.nETQTY);
        netRate = _formatStr(item.nETRATE);
        netAmount = _formatStr(item.nETAMOUNT);
        closePrice = _formatStr(item.closingPrice);
        pnl = _formatStr(item.pLAMT);
      } catch (_) {
        symbol = '--';
        buyRate = buyAmt = sellRate = sellAmt = netRate = netAmount = closePrice = pnl = '0.00';
        buyQty = sellQty = netQty = '0';
      }
    }

    final pnlValue = double.tryParse(pnl) ?? 0;
    final pnlColor = pnlValue == 0
        ? resolveThemeColor(context,
            dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)
        : pnlValue < 0
            ? resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.error)
            : resolveThemeColor(context, dark: MyntColors.successDark, light: MyntColors.success);

    final rowKey = '${sectionTitle}_${index}_$symbol';

    return shadcn.TableRow(
      cells: [
        _buildDataCell(
          rowKey: rowKey,
          child: Tooltip(
            message: symbol.isNotEmpty ? symbol : '--',
            child: Text(symbol.isNotEmpty ? symbol : '--',
                style: _cellStyle(context), overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
        ),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Text(buyQty, style: _cellStyle(context))),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(buyRate, style: _cellStyle(context)),
                Text(buyAmt, style: MyntWebTextStyles.caption(context,
                    darkColor: MyntColors.textSecondaryDark, lightColor: MyntColors.textSecondary)),
              ],
            )),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Text(sellQty, style: _cellStyle(context))),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(sellRate, style: _cellStyle(context)),
                Text(sellAmt, style: MyntWebTextStyles.caption(context,
                    darkColor: MyntColors.textSecondaryDark, lightColor: MyntColors.textSecondary)),
              ],
            )),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Text(netQty, style: _cellStyle(context))),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(netRate, style: _cellStyle(context)),
                Text(netAmount, style: MyntWebTextStyles.caption(context,
                    darkColor: MyntColors.textSecondaryDark, lightColor: MyntColors.textSecondary)),
              ],
            )),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Text(closePrice, style: _cellStyle(context))),
        _buildDataCell(
            rowKey: rowKey, alignRight: true,
            child: Text(pnl, style: _cellStyle(context, color: pnlColor))),
      ],
    );
  }

  // ─── Table Cell Helpers ────────────────────────────────────────────

  shadcn.TableCell _buildHeaderCell(String label, {bool alignRight = false}) {
    return shadcn.TableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(label, style: _headerStyle(context)),
      ),
    );
  }

  shadcn.TableCell _buildDataCell({
    required String rowKey,
    required Widget child,
    bool alignRight = false,
  }) {
    return shadcn.TableCell(
      child: MouseRegion(
        onEnter: (_) => _hoveredRowKey.value = rowKey,
        onExit: (_) => _hoveredRowKey.value = null,
        child: ValueListenableBuilder<String?>(
          valueListenable: _hoveredRowKey,
          builder: (context, hoveredKey, _) {
            final isHovered = hoveredKey == rowKey;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: isHovered
                  ? resolveThemeColor(context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary)
                      .withValues(alpha: 0.06)
                  : null,
              alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
              child: child,
            );
          },
        ),
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    return MyntWebTextStyles.tableHeader(
      context,
      darkColor: MyntColors.textSecondaryDark,
      lightColor: MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  TextStyle _cellStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableCell(
      context,
      color: color,
      darkColor: color ?? MyntColors.textPrimaryDark,
      lightColor: color ?? MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  double _parseDouble(String? val) {
    if (val == null || val.isEmpty) return 0;
    return double.tryParse(val) ?? 0;
  }

  String _formatNum(dynamic val) {
    if (val == null) return '0.00';
    final d = double.tryParse(val.toString()) ?? 0;
    return d.toStringAsFixed(2);
  }

  String _formatStr(String? val) {
    if (val == null || val.isEmpty) return '0.00';
    final d = double.tryParse(val) ?? 0;
    return d.toStringAsFixed(2);
  }

  String _formatQtyNum(dynamic val) {
    if (val == null) return '0';
    final d = double.tryParse(val.toString()) ?? 0;
    return d.toStringAsFixed(0);
  }

  String _formatQtyStr(String? val) {
    if (val == null || val.isEmpty) return '0';
    final d = double.tryParse(val) ?? 0;
    return d.toStringAsFixed(0);
  }
}

class _SectionData {
  final String title;
  final List<dynamic> data;
  final bool isEquity;

  _SectionData(this.title, this.data, {this.isEquity = false});
}
