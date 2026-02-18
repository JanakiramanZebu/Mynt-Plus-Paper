import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../models/order_book_model/sip_place_order.dart';
import '../../../models/order_book_model/sip_order_book.dart';
import '../../../models/marketwatch_model/search_scrip_new_model.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../utils/responsive_snackbar.dart';

class ModifySipDialogWeb extends ConsumerStatefulWidget {
  final SipDetails sipDetails;

  const ModifySipDialogWeb({super.key, required this.sipDetails});

  @override
  ConsumerState<ModifySipDialogWeb> createState() => _ModifySipDialogWebState();
}

class _ModifySipDialogWebState extends ConsumerState<ModifySipDialogWeb> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noOfSipsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _originalStartDate;
  String _selectedFrequency = '1';
  String _sipName = '';

  final List<_ModifySipScripItem> _addedScrips = [];
  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounceTimer;

  final List<String> _frequencies = [
    'Daily',
    'Weekly',
    'Fortnightly',
    'Monthly'
  ];

  @override
  void initState() {
    super.initState();
    _populateFromSipDetails();
    _subscribeExistingScrips();
  }

  void _subscribeExistingScrips() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (var item in _addedScrips) {
        ref.read(websocketProvider).establishConnection(
          channelInput: '${item.exch}|${item.token}',
          task: 't',
          context: context,
        );
      }
    });
  }

  void _populateFromSipDetails() {
    final sip = widget.sipDetails;

    _sipName = sip.sipName ?? '';
    _selectedFrequency = sip.frequency ?? '1';
    _noOfSipsController.text = sip.endPeriod ?? '';

    // Parse start date using manual substring (same approach as duedateformate)
    if (sip.startDate != null && sip.startDate!.isNotEmpty) {
      try {
        final dateStr = sip.startDate!;
        if (dateStr.length == 8) {
          // ddMMyyyy format (e.g., "24022026")
          final day = int.parse(dateStr.substring(0, 2));
          final month = int.parse(dateStr.substring(2, 4));
          final year = int.parse(dateStr.substring(4));
          _startDate = DateTime(year, month, day);
        } else if (dateStr.length == 10) {
          // dd-MM-yyyy format (e.g., "24-02-2026")
          final day = int.parse(dateStr.substring(0, 2));
          final month = int.parse(dateStr.substring(3, 5));
          final year = int.parse(dateStr.substring(6));
          _startDate = DateTime(year, month, day);
        }
        _originalStartDate = _startDate;
      } catch (_) {}
    }

    // Pre-populate existing scrips
    if (sip.scrips != null) {
      for (var scrip in sip.scrips!) {
        final isQtyMode = scrip.sipType != 'prc';
        _addedScrips.add(_ModifySipScripItem(
          token: scrip.token ?? '',
          exch: scrip.exch ?? 'NSE',
          tsym: scrip.tsym ?? '',
          prd: scrip.prd ?? 'C',
          investBy: isQtyMode ? 'Qty' : 'Amount',
          qtyController: TextEditingController(text: scrip.qty ?? ''),
          amountController: TextEditingController(text: scrip.prc ?? ''),
          isExisting: true,
          fallbackLtp: scrip.ltp ?? '0',
        ));
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _noOfSipsController.dispose();
    for (var item in _addedScrips) {
      item.qtyController.dispose();
      item.amountController.dispose();
    }
    super.dispose();
  }

  String _getFrequencyValue(String frequency) {
    switch (frequency) {
      case 'Daily':
        return '0';
      case 'Weekly':
        return '1';
      case 'Fortnightly':
        return '2';
      case 'Monthly':
        return '3';
      default:
        return '1';
    }
  }

  String _getFrequencyLabel(String value) {
    switch (value) {
      case '0':
        return 'Daily';
      case '1':
        return 'Weekly';
      case '2':
        return 'Fortnightly';
      case '3':
        return 'Monthly';
      default:
        return 'Weekly';
    }
  }

  bool get _isStartDatePassed {
    if (_originalStartDate == null) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return _originalStartDate!.isBefore(todayDate);
  }

  Future<void> _selectStartDate() async {
    // If start date has already passed, do not allow modification
    if (_isStartDatePassed) return;

    try {
      final theme = ref.read(themeProvider);
      final now = DateTime.now();
      // Allow selecting from original start date onward
      final firstDate = _originalStartDate ?? now;
      final initialDate = _startDate != null && !_startDate!.isBefore(firstDate)
          ? _startDate!
          : firstDate;

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: now.add(const Duration(days: 365)),
        useRootNavigator: true,
        builder: (dialogContext, child) {
          return Theme(
            data: theme.isDarkMode
                ? ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: MyntColors.primaryDark,
                      surface: MyntColors.cardDark,
                      onSurface: MyntColors.textPrimaryDark,
                    ),
                  )
                : ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: MyntColors.primary,
                      surface: MyntColors.card,
                      onSurface: MyntColors.textPrimary,
                    ),
                  ),
            child: child!,
          );
        },
      );
      if (picked != null && mounted) {
        setState(() {
          _startDate = picked;
        });
      }
    } catch (e) {
      debugPrint('Date picker error: $e');
    }
  }

  List<ScripNewValue> _searchResults = [];

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < 2) {
      ref.read(marketWatchProvider).searchClear();
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchScrips(query);
    });
  }

  Future<void> _searchScrips(String query) async {
    try {
      await ref.read(marketWatchProvider).fetchSearchScrip(
            searchText: query,
            context: context,
            segment: 'EQ',
            option: false,
            exchanges: ['NSE', 'BSE'],
          );
      if (mounted) {
        setState(() {
          _searchResults = ref.read(marketWatchProvider).allSearchScrip ?? [];
        });
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _addScrip(ScripNewValue scrip) {
    // Check if already added
    if (_addedScrips.any((s) => s.token == scrip.token)) {
      ResponsiveSnackBar.showWarning(
          context, '${scrip.tsym} is already added');
      return;
    }

    setState(() {
      _addedScrips.add(_ModifySipScripItem(
        token: scrip.token ?? '',
        exch: scrip.exch ?? 'NSE',
        tsym: scrip.tsym ?? '',
        prd: 'C',
        investBy: 'Qty',
        qtyController: TextEditingController(text: '1'),
        amountController: TextEditingController(),
        isExisting: false,
      ));
      _searchResults = [];
    });

    // Subscribe to WebSocket touchline for LTP
    ref.read(websocketProvider).establishConnection(
      channelInput: '${scrip.exch}|${scrip.token}',
      task: 't',
      context: context,
    );

    _searchController.clear();
    ref.read(marketWatchProvider).searchClear();
  }

  void _removeScrip(int index) {
    setState(() {
      _addedScrips[index].qtyController.dispose();
      _addedScrips[index].amountController.dispose();
      _addedScrips.removeAt(index);
    });
  }

  Future<void> _modifySip() async {
    // Validation - only validate start date if SIP hasn't started yet
    if (!_isStartDatePassed && _startDate == null) {
      ResponsiveSnackBar.showWarning(context, 'Please select start date');
      return;
    }
    if (_noOfSipsController.text.isEmpty ||
        int.tryParse(_noOfSipsController.text) == null ||
        int.parse(_noOfSipsController.text) <= 0) {
      ResponsiveSnackBar.showWarning(
          context, 'Please enter valid number of SIPs');
      return;
    }
    if (_addedScrips.isEmpty) {
      ResponsiveSnackBar.showWarning(
          context, 'At least one stock must be in the basket');
      return;
    }

    // Validate qty/amount values
    for (var item in _addedScrips) {
      final isQtyMode = item.investBy == 'Qty';
      final value = isQtyMode
          ? item.qtyController.text.trim()
          : item.amountController.text.trim();
      if (value.isEmpty) {
        final fieldName = isQtyMode ? 'quantity' : 'amount';
        ResponsiveSnackBar.showWarning(
            context, 'Please enter valid $fieldName for ${item.tsym}');
        return;
      }
      if (isQtyMode) {
        final qty = int.tryParse(value);
        if (qty == null || qty <= 0) {
          ResponsiveSnackBar.showWarning(
              context, 'Please enter valid quantity for ${item.tsym}');
          return;
        }
      } else {
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          ResponsiveSnackBar.showWarning(
              context, 'Please enter valid amount for ${item.tsym}');
          return;
        }
        // Validate amount is at least LTP (need at least 1 share worth)
        final ltp = double.tryParse(
          ref.read(websocketProvider).getBestLTP(item.token, item.fallbackLtp),
        ) ?? 0;
        if (ltp > 0 && amount < ltp) {
          ResponsiveSnackBar.showWarning(
            context, 'Amount must be at least LTP (${ltp.toStringAsFixed(2)}) for ${item.tsym}');
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      // Don't send start_date if SIP has already started
      final startDate = _isStartDatePassed ? null : _sipdateformat(_startDate!);
      final internal = widget.sipDetails.internal;

      final scrips = _addedScrips.map((item) {
        final isQtyMode = item.investBy == 'Qty';
        return SipScripInput(
          exch: item.exch,
          tsym: item.tsym,
          prd: item.prd,
          token: item.token,
          qty: isQtyMode ? item.qtyController.text : '',
          sipType: isQtyMode ? 'qty' : 'prc',
          prc: isQtyMode ? null : item.amountController.text,
        );
      }).toList();

      final modifyInput = ModifySipInput(
        regdate: widget.sipDetails.regDate ?? '',
        startdate: startDate,
        frequency: _selectedFrequency,
        endperiod: _noOfSipsController.text,
        sipname: _sipName,
        prevExecutedate: internal?.prevExecDate ?? '0',
        duedate: internal?.dueDate ?? '',
        exedate: internal?.execDate ?? '',
        period: internal?.period ?? '0',
        active: internal?.active ?? 'true',
        sipId: internal?.sipId ?? '',
        scrips: scrips,
      );

      final result = await ref
          .read(orderProvider)
          .modifySipBasketOrder(context, modifyInput);

      if (result != null && result.reqStatus == 'OK') {
        if (mounted) {
          Navigator.of(context).pop();
          ResponsiveSnackBar.showSuccess(
              context, 'SIP modified successfully');
        }
      } else {
        if (mounted) {
          final errorMsg = result?.rejreason ?? result?.emsg ?? 'Failed to modify SIP';
          ResponsiveSnackBar.showError(context, errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to modify SIP: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _sipdateformat(DateTime date) {
    return DateFormat('ddMMyyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final wsProvider = ref.watch(websocketProvider);

    return Column(
      children: [
        // Header
        _buildHeader(context, theme),
        const ListDivider(),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SIP Name (read-only)
                _buildSipNameField(context, theme),
                const SizedBox(height: 16),
                _buildDateAndFrequencyRow(context, theme),
                const SizedBox(height: 16),
                _buildNoOfSipsField(context, theme),
                const SizedBox(height: 24),

                // Search Section
                _buildSearchSection(context, theme),
                const SizedBox(height: 16),

                // Added Scrips List
                if (_addedScrips.isNotEmpty) ...[
                  Text(
                    '${_addedScrips.length} stock${_addedScrips.length > 1 ? 's' : ''} in basket',
                    style: MyntWebTextStyles.body(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _buildScripsList(context, theme, wsProvider),
              ],
            ),
          ),
        ),

        // Footer
        _buildFooter(context, theme),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Modify SIP',
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(.15)
                  : Colors.black.withOpacity(.15),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(.08)
                  : Colors.black.withOpacity(.08),
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: resolveThemeColor(context,
                      dark: MyntColors.iconDark, light: MyntColors.icon),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSipNameField(BuildContext context, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIP Name',
          style: MyntWebTextStyles.bodyMedium(
            context,
            fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: 0.6,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: MyntColors.inputBgDark, light: MyntColors.inputBg),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              _sipName,
              style: MyntWebTextStyles.body(
                context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndFrequencyRow(BuildContext context, ThemesProvider theme) {
    return Row(
      children: [
        // Start Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date',
                style: MyntWebTextStyles.bodyMedium(
                  context,
                  fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: _isStartDatePassed ? 0.6 : 1.0,
                child: InkWell(
                onTap: _isStartDatePassed ? null : _selectStartDate,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: resolveThemeColor(context,
                        dark: MyntColors.inputBgDark,
                        light: MyntColors.inputBg),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _isStartDatePassed
                          ? resolveThemeColor(context,
                              dark: MyntColors.dividerDark, light: MyntColors.divider)
                          : resolveThemeColor(context,
                              dark: MyntColors.primaryDark, light: MyntColors.primary),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate != null
                            ? DateFormat('dd-MM-yyyy').format(_startDate!)
                            : 'Select date',
                        style: MyntWebTextStyles.body(
                          context,
                          color: _startDate != null
                              ? resolveThemeColor(context,
                                  dark: MyntColors.textPrimaryDark,
                                  light: MyntColors.textPrimary)
                              : resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary).withValues(alpha: 0.4),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: resolveThemeColor(context,
                            dark: MyntColors.iconDark, light: MyntColors.icon),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Frequency
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequency',
                style: MyntWebTextStyles.bodyMedium(
                  context,
                  fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                      dark: MyntColors.inputBgDark,
                      light: MyntColors.inputBg),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: resolveThemeColor(context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _getFrequencyLabel(_selectedFrequency),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: resolveThemeColor(context,
                          dark: MyntColors.iconDark, light: MyntColors.icon),
                    ),
                    dropdownColor: resolveThemeColor(context,
                        dark: MyntColors.cardDark, light: MyntColors.card),
                    items: _frequencies.map((freq) {
                      return DropdownMenuItem(
                        value: freq,
                        child: Text(
                          freq,
                          style: MyntWebTextStyles.body(
                            context,
                            darkColor: MyntColors.textPrimaryDark,
                            lightColor: MyntColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFrequency = _getFrequencyValue(value);
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoOfSipsField(BuildContext context, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of SIPs',
          style: MyntWebTextStyles.bodyMedium(
            context,
            fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          width: 120,
          child: CustomTextFormField(
            fillColor: resolveThemeColor(context,
                dark: MyntColors.inputBgDark, light: MyntColors.inputBg),
            hintText: '',
            hintStyle: MyntWebTextStyles.bodySmall(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
            ),
            keyboardType: TextInputType.number,
            style: MyntWebTextStyles.body(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
            textCtrl: _noOfSipsController,
            textAlign: TextAlign.start,
            inputFormate: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, ThemesProvider theme) {
    final showDropdown =
        _searchResults.isNotEmpty && _searchController.text.length >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Stocks',
          style: MyntWebTextStyles.bodyMedium(
            context,
            fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: showDropdown ? 244 : 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Search Input Field
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                      dark: MyntColors.inputBgDark,
                      light: MyntColors.inputBg),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: resolveThemeColor(context,
                        dark: MyntColors.dividerDark,
                        light: MyntColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.search,
                        size: 20,
                        color: resolveThemeColor(context,
                            dark: MyntColors.iconDark, light: MyntColors.icon),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: MyntWebTextStyles.body(
                          context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search equity stocks...',
                          hintStyle: MyntWebTextStyles.body(
                            context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary).withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
              // Search Results Dropdown
              if (showDropdown)
                Positioned(
                  top: 44,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: resolveThemeColor(context,
                            dark: MyntColors.cardDark,
                            light: MyntColors.card),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: resolveThemeColor(context,
                              dark: MyntColors.dividerDark,
                              light: MyntColors.divider),
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const ListDivider(),
                        itemBuilder: (context, index) {
                          final scrip = _searchResults[index];
                          final symbolName =
                              scrip.symbol?.isNotEmpty == true
                                  ? scrip.symbol!
                                  : (scrip.tsym?.replaceAll('-EQ', '') ?? '');
                          return InkWell(
                            onTap: () => _addScrip(scrip),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          symbolName,
                                          style: MyntWebTextStyles.body(
                                            context,
                                            fontWeight: MyntFonts.medium,
                                            darkColor:
                                                MyntColors.textPrimaryDark,
                                            lightColor:
                                                MyntColors.textPrimary,
                                          ),
                                        ),
                                        if (scrip.cname?.isNotEmpty == true)
                                          Text(
                                            scrip.cname!,
                                            style:
                                                MyntWebTextStyles.caption(
                                              context,
                                              color: resolveThemeColor(
                                                  context,
                                                  dark: MyntColors
                                                      .textSecondaryDark,
                                                  light: MyntColors
                                                      .textSecondary),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: resolveThemeColor(context,
                                              dark: MyntColors.primaryDark,
                                              light: MyntColors.primary)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      scrip.exch ?? '',
                                      style: MyntWebTextStyles.caption(
                                        context,
                                        color: resolveThemeColor(context,
                                            dark: MyntColors.primaryDark,
                                            light: MyntColors.primary),
                                      ),
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
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScripsList(BuildContext context, ThemesProvider theme, WebSocketProvider wsProvider) {
    if (_addedScrips.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                'No stocks in basket',
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _addedScrips.length,
      separatorBuilder: (_, __) => const ListDivider(),
      itemBuilder: (context, index) {
        final item = _addedScrips[index];
        return _buildScripCard(context, theme, wsProvider, item, index);
      },
    );
  }

  Widget _buildScripCard(BuildContext context, ThemesProvider theme,
      WebSocketProvider wsProvider, _ModifySipScripItem item, int index) {
    final rawSymbol = item.tsym;
    final symbolName =
        rawSymbol.contains('-') ? rawSymbol.split('-').first : rawSymbol;
    final isQtyMode = item.investBy == 'Qty';
    final liveLtp = wsProvider.getBestLTP(item.token, item.fallbackLtp);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Stock name + exchange badge + LTP (takes available space)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        symbolName,
                        style: MyntWebTextStyles.body(
                          context,
                          fontWeight: MyntFonts.medium,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        item.exch,
                        style: MyntWebTextStyles.caption(
                          context,
                          color: resolveThemeColor(context,
                              dark: MyntColors.primaryDark, light: MyntColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                if (liveLtp != '0' && liveLtp != '0.00') ...[
                  const SizedBox(height: 2),
                  Text(
                    'LTP: $liveLtp',
                    style: MyntWebTextStyles.caption(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Switch icon (compact)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  item.investBy = isQtyMode ? 'Amount' : 'Qty';
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  assets.switchIcon,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    resolveThemeColor(context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Qty/Amt label (compact, 3-letter)
          SizedBox(
            width: 28,
            child: Text(
              isQtyMode ? 'Qty' : 'Amt',
              style: MyntWebTextStyles.bodySmall(
                context,
                fontWeight: MyntFonts.medium,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Input field (takes remaining space)
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 34,
              child: TextField(
                controller:
                    isQtyMode ? item.qtyController : item.amountController,
                keyboardType: TextInputType.number,
                inputFormatters: isQtyMode
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                      ],
                style: MyntWebTextStyles.bodySmall(
                  context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: isQtyMode ? '1' : '0.00',
                  hintStyle: MyntWebTextStyles.bodySmall(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary).withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: resolveThemeColor(context,
                      dark: MyntColors.inputBgDark,
                      light: MyntColors.inputBg),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: resolveThemeColor(context,
                          dark: MyntColors.dividerDark,
                          light: MyntColors.divider),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: resolveThemeColor(context,
                          dark: MyntColors.dividerDark,
                          light: MyntColors.divider),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: resolveThemeColor(context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Delete button (compact)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeScrip(index),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: resolveThemeColor(context,
                      dark: MyntColors.lossDark, light: MyntColors.loss),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'SIP will be placed at 9:30 AM on due date. If market holiday, order placed on next trading day.',
            style: MyntWebTextStyles.caption(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed:
                  _isLoading || _addedScrips.isEmpty ? null : _modifySip,
              style: ElevatedButton.styleFrom(
                backgroundColor: _addedScrips.isEmpty
                    ? Colors.grey
                    : resolveThemeColor(context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Modify SIP',
                      style: MyntWebTextStyles.buttonMd(
                        context,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to hold scrip item data for modify dialog
class _ModifySipScripItem {
  final String token;
  final String exch;
  final String tsym;
  final String prd;
  String investBy;
  final TextEditingController qtyController;
  final TextEditingController amountController;
  final bool isExisting;
  final String fallbackLtp;

  _ModifySipScripItem({
    required this.token,
    required this.exch,
    required this.tsym,
    required this.prd,
    required this.investBy,
    required this.qtyController,
    required this.amountController,
    this.isExisting = false,
    this.fallbackLtp = '0',
  });
}
