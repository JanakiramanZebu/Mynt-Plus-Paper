import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../models/order_book_model/sip_place_order.dart';
import '../../../models/marketwatch_model/search_scrip_new_model.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/res.dart';
import '../../../utils/responsive_snackbar.dart';

class CreateSipDialogWeb extends ConsumerStatefulWidget {
  const CreateSipDialogWeb({super.key});

  @override
  ConsumerState<CreateSipDialogWeb> createState() => _CreateSipDialogWebState();
}

class _CreateSipDialogWebState extends ConsumerState<CreateSipDialogWeb> {
  final TextEditingController _sipNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noOfSipsController = TextEditingController(text: '');

  DateTime? _startDate;
  String _selectedFrequency = '1'; // Weekly by default

  final List<SipScripItem> _addedScrips = [];
  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounceTimer;

  final List<String> _frequencies = ['Daily', 'Weekly', 'Fortnightly', 'Monthly'];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _sipNameController.dispose();
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

  Future<void> _selectStartDate() async {
    try {
      final isDark = ref.read(themeProvider).isDarkMode;
      final now = DateTime.now();
      final initialDate = _startDate != null && !_startDate!.isBefore(now) ? _startDate! : now;
      final primary = isDark ? MyntColors.primaryDark : MyntColors.primary;
      final bg = isDark ? MyntColors.cardDark : MyntColors.card;
      final text = isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary;

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
        useRootNavigator: true, // Important for showing in sheet overlay

        builder: (dialogContext, child) => Theme(
          data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: primary,
              onPrimary: Colors.white,
              surface: bg,
              onSurface: text,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: bg,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: primary,
              headerForegroundColor: Colors.white,
              dividerColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ),
          child: child!,
        ),
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
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.length < 2) {
      ref.read(marketWatchProvider).searchClear();
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Show loading indicator immediately
    setState(() => _isSearching = true);

    // Debounce the actual search by 400ms
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchScrips(query);
    });
  }

  Future<void> _searchScrips(String query) async {
    try {
      // Use 'EQ' segment for equity stocks (SIP only supports equity)
      // Pass NSE and BSE exchanges directly to API filter
      await ref.read(marketWatchProvider).fetchSearchScrip(
            searchText: query,
            context: context,
            segment: 'EQ',
            option: false,
            exchanges: ['NSE', 'BSE'],
          );
      // Get results directly after fetch completes
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
    if (_addedScrips.any((s) => s.scrip.token == scrip.token)) {
      ResponsiveSnackBar.showWarning(context, '${scrip.tsym} is already added');
      return;
    }

    setState(() {
      _addedScrips.add(SipScripItem(
        scrip: scrip,
        investBy: 'Qty',
        qtyController: TextEditingController(text: '1'),
        amountController: TextEditingController(),
      ));
      // Clear search results to close dropdown
      _searchResults = [];
    });

    // Subscribe to WebSocket touchline for LTP
    ref.read(websocketProvider).establishConnection(
      channelInput: '${scrip.exch}|${scrip.token}',
      task: 't',
      context: context,
    );

    // Clear search field and provider
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

  Future<void> _createSip() async {
    // Validation
    if (_sipNameController.text.trim().isEmpty) {
      ResponsiveSnackBar.showWarning(context, 'Please enter SIP name');
      return;
    }
    if (_startDate == null) {
      ResponsiveSnackBar.showWarning(context, 'Please select start date');
      return;
    }
    if (_noOfSipsController.text.isEmpty || int.tryParse(_noOfSipsController.text) == null) {
      ResponsiveSnackBar.showWarning(context, 'Please enter valid number of SIPs');
      return;
    }
    if (_addedScrips.isEmpty) {
      ResponsiveSnackBar.showWarning(context, 'Please add at least one stock');
      return;
    }

    // Validate qty/amount values
    for (var item in _addedScrips) {
      final isQtyMode = item.investBy == 'Qty';
      final value = isQtyMode ? item.qtyController.text.trim() : item.amountController.text.trim();
      if (value.isEmpty) {
        final fieldName = isQtyMode ? 'quantity' : 'amount';
        ResponsiveSnackBar.showWarning(context, 'Please enter valid $fieldName for ${item.scrip.tsym}');
        return;
      }
      if (isQtyMode) {
        final qty = int.tryParse(value);
        if (qty == null || qty <= 0) {
          ResponsiveSnackBar.showWarning(context, 'Please enter valid quantity for ${item.scrip.tsym}');
          return;
        }
      } else {
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          ResponsiveSnackBar.showWarning(context, 'Please enter valid amount for ${item.scrip.tsym}');
          return;
        }
        // Validate amount is at least LTP (need at least 1 share worth)
        final ltp = double.tryParse(
          ref.read(websocketProvider).getBestLTP(item.scrip.token ?? '', '0'),
        ) ?? 0;
        if (ltp > 0 && amount < ltp) {
          ResponsiveSnackBar.showWarning(
            context, 'Amount must be at least LTP (${ltp.toStringAsFixed(2)}) for ${item.scrip.tsym}');
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      final regDate = _sipdateformat(DateTime.now());
      final startDate = _sipdateformat(_startDate!);

      final scrips = _addedScrips.map((item) {
        final isQtyMode = item.investBy == 'Qty';
        return SipScripInput(
          exch: item.scrip.exch ?? 'NSE',
          tsym: item.scrip.tsym ?? '',
          prd: 'C', // CNC for SIP
          token: item.scrip.token ?? '',
          qty: isQtyMode ? item.qtyController.text : '',
          sipType: isQtyMode ? 'qty' : 'prc',
          prc: isQtyMode ? null : item.amountController.text,
        );
      }).toList();

      final sipInput = SipBasketInput(
        regdate: regDate,
        startdate: startDate,
        frequency: _selectedFrequency,
        endperiod: _noOfSipsController.text,
        sipname: _sipNameController.text.trim(),
        scrips: scrips,
      );

      final result = await ref.read(orderProvider).placeSipBasketOrder(sipInput, context);

      if (result != null && result.reqStatus == 'OK') {
        if (mounted) {
          Navigator.of(context).pop();
          ResponsiveSnackBar.showSuccess(context, 'SIP created successfully');
        }
      } else {
        if (mounted) {
          ResponsiveSnackBar.showError(context, result?.emsg ?? 'Failed to create SIP');
        }
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to create SIP: $e');
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

    final showDropdown = _searchResults.isNotEmpty && _searchController.text.length >= 2;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolveThemeColor(context,
              dark: MyntColors.dividerDark, light: MyntColors.divider),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
        children: [
          // Header
          _buildHeader(context, theme),

        // Content
        Expanded(
          child: SingleChildScrollView(
           physics: showDropdown ? const NeverScrollableScrollPhysics() : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SIP Configuration
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
                    '${_addedScrips.length} stock${_addedScrips.length > 1 ? 's' : ''} added',
                    style: MyntWebTextStyles.bodySmall(
                      context,
                      fontWeight: MyntFonts.medium,
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
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemesProvider theme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Create SIP',
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              size: 20,
              color: resolveThemeColor(context,
                  dark: MyntColors.iconSecondaryDark,
                  light: MyntColors.iconSecondary),
            ),
            splashRadius: 20,
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
          style: MyntWebTextStyles.bodySmall(
            context,
            fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textSecondaryDark,
            lightColor: MyntColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: TextField(
            controller: _sipNameController,
            style: MyntWebTextStyles.body(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: resolveThemeColor(context,
                dark: MyntColors.inputBgDark, light: const Color(0xfff5f5f5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              hintText: 'Enter SIP name',
              hintStyle: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode(context)
                        ? MyntColors.primaryDark
                        : MyntColors.primary),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode(context)
                        ? MyntColors.primaryDark
                        : MyntColors.primary),
                borderRadius: BorderRadius.circular(5),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
            ],
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
                style: MyntWebTextStyles.bodySmall(
                  context,
                  fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _selectStartDate,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: resolveThemeColor(context,
                        dark: MyntColors.inputBgDark,
                        light: const Color(0xfff5f5f5)),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDarkMode(context)
                          ? MyntColors.primaryDark
                          : MyntColors.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
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
                                    light: MyntColors.textSecondary),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Frequency
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequency',
                style: MyntWebTextStyles.bodySmall(
                  context,
                  fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                      dark: MyntColors.inputBgDark,
                      light: const Color(0xfff5f5f5)),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isDarkMode(context)
                        ? MyntColors.primaryDark
                        : MyntColors.primary,
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
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                    dropdownColor: resolveThemeColor(context,
                        dark: MyntColors.dialogDark, light: MyntColors.dialog),
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
          style: MyntWebTextStyles.bodySmall(
            context,
            fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textSecondaryDark,
            lightColor: MyntColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          width: 140,
          child: TextField(
            controller: _noOfSipsController,
            keyboardType: TextInputType.number,
            style: MyntWebTextStyles.body(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: resolveThemeColor(context,
                  dark: MyntColors.inputBgDark,
                  light: const Color(0xfff5f5f5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              hintText: 'e.g. 12',
              hintStyle: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode(context)
                        ? MyntColors.primaryDark
                        : MyntColors.primary),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDarkMode(context)
                        ? MyntColors.primaryDark
                        : MyntColors.primary),
                borderRadius: BorderRadius.circular(5),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, ThemesProvider theme) {
    final showDropdown = _searchResults.isNotEmpty && _searchController.text.length >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Stocks',
          style: MyntWebTextStyles.bodySmall(
            context,
            fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textSecondaryDark,
            lightColor: MyntColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        // Search Field with dropdown
        SizedBox(
          height: showDropdown ? 240 : 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Search Input Field
              SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchController,
                  style: MyntWebTextStyles.body(
                    context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: resolveThemeColor(context,
                        dark: MyntColors.inputBgDark,
                        light: const Color(0xfff5f5f5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    hintText: 'Search equity stocks...',
                    hintStyle: MyntWebTextStyles.body(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                    suffixIcon: _isSearching
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.primaryDark,
                                    light: MyntColors.primary),
                              ),
                            ),
                          )
                        : _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(marketWatchProvider).searchClear();
                                  setState(() {
                                    _searchResults = [];
                                    _isSearching = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textSecondaryDark,
                                      light: MyntColors.textSecondary),
                                ),
                              )
                            : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDarkMode(context)
                              ? MyntColors.primaryDark
                              : MyntColors.primary),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDarkMode(context)
                              ? MyntColors.primaryDark
                              : MyntColors.primary),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: _onSearchChanged,
                ),
              ),
              // Search Results Dropdown
              if (showDropdown)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: resolveThemeColor(context,
                            dark: MyntColors.overlayBgDark, light: MyntColors.overlayBg),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: resolveThemeColor(context,
                              dark: MyntColors.borderMutedDark, light: MyntColors.borderMuted),
                        ),
                        boxShadow: isDarkMode(context)
                            ? MyntShadows.dropdownDark
                            : MyntShadows.dropdown,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 1,
                            color: resolveThemeColor(context,
                                dark: MyntColors.dividerDark, light: MyntColors.divider),
                          ),
                          itemBuilder: (context, index) {
                            final scrip = _searchResults[index];
                            final symbolName = scrip.symbol?.isNotEmpty == true
                                ? scrip.symbol!
                                : (scrip.tsym?.replaceAll('-EQ', '') ?? '');
                            return InkWell(
                              onTap: () => _addScrip(scrip),
                              hoverColor: resolveThemeColor(context,
                                  dark: MyntColors.inputBgDark, light: MyntColors.inputBg),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            symbolName,
                                            style: MyntWebTextStyles.body(
                                              context,
                                              fontWeight: MyntFonts.medium,
                                              darkColor: MyntColors.textPrimaryDark,
                                              lightColor: MyntColors.textPrimary,
                                            ),
                                          ),
                                          if (scrip.cname?.isNotEmpty == true)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                scrip.cname!,
                                                style: MyntWebTextStyles.caption(
                                                  context,
                                                  color: resolveThemeColor(context,
                                                      dark: MyntColors.textTertiaryDark,
                                                      light: MyntColors.textTertiary),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: resolveThemeColor(context,
                                              dark: MyntColors.primaryDark,
                                              light: MyntColors.primary)
                                          .withValues(alpha: 0.1),
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
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: resolveThemeColor(context,
                    dark: MyntColors.textTertiaryDark,
                    light: MyntColors.textTertiary),
              ),
              const SizedBox(height: 10),
              Text(
                'No stocks added',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.medium,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Search and add stocks to your SIP',
                style: MyntWebTextStyles.caption(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textTertiaryDark,
                      light: MyntColors.textTertiary),
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
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: resolveThemeColor(context,
            dark: MyntColors.dividerDark, light: MyntColors.divider),
      ),
      itemBuilder: (context, index) {
        final item = _addedScrips[index];
        return _buildScripCard(context, theme, wsProvider, item, index);
      },
    );
  }

  Widget _buildScripCard(BuildContext context, ThemesProvider theme, WebSocketProvider wsProvider, SipScripItem item, int index) {
    // Get symbol name - use symbol field or parse from tsym, strip any suffix after hyphen
    final rawSymbol = item.scrip.symbol?.isNotEmpty == true
        ? item.scrip.symbol!
        : (item.scrip.tsym ?? '');
    final symbolName = rawSymbol.contains('-') ? rawSymbol.split('-').first : rawSymbol;
    final isQtyMode = item.investBy == 'Qty';
    final liveLtp = wsProvider.getBestLTP(item.scrip.token ?? '', '0');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Row(
        children: [
          // Stock name + exchange badge + LTP (takes available space)
          Expanded(
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
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        item.scrip.exch ?? '',
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
                  const SizedBox(height: 3),
                  Text(
                    'LTP: $liveLtp',
                    style: MyntWebTextStyles.caption(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textTertiaryDark,
                          light: MyntColors.textTertiary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right side controls - fixed width for consistent alignment
          SizedBox(
            width: 200,
            child: Row(
              children: [
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
          const SizedBox(width: 6),
          // Qty/Amt label (compact, 3-letter)
          SizedBox(
            width: 28,
            child: Text(
              isQtyMode ? 'Qty' : 'Amt',
              style: MyntWebTextStyles.caption(
                context,
                fontWeight: MyntFonts.medium,
                 color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Input field (takes remaining space)
          Expanded(
                  child: SizedBox(
              height: 34,
              child: TextField(
                controller: isQtyMode ? item.qtyController : item.amountController,
                keyboardType: TextInputType.number,
                inputFormatters: isQtyMode
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                style: MyntWebTextStyles.bodySmall(
                  context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
                      textAlign: TextAlign.center,
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
                      dark: MyntColors.inputBgDark, light: MyntColors.inputBg),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                        border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: resolveThemeColor(context,
                                dark: MyntColors.borderMutedDark, light: MyntColors.borderMuted),
                          ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: resolveThemeColor(context,
                                dark: MyntColors.borderMutedDark, light: MyntColors.borderMuted),
                          ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: resolveThemeColor(context,
                          dark: MyntColors.primaryDark, light: MyntColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
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
                            dark: MyntColors.errorDark, light: MyntColors.error),
                                    ),
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

  Widget _buildFooter(BuildContext context, ThemesProvider theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Info text bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
                width: 1,
              ),
            ),
          ),
          child: Text(
            'SIP will be placed at 9:30 AM on due date. If market holiday, order placed on next trading day.',
            style: MyntWebTextStyles.caption(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors.textTertiaryDark,
                  light: MyntColors.textTertiary),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Action buttons row
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Stock count info
              Text(
                '${_addedScrips.length} stock${_addedScrips.length != 1 ? 's' : ''} added',
                style: MyntWebTextStyles.bodySmall(
                  context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Create SIP Button
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: _isLoading || _addedScrips.isEmpty ? null : _createSip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.isDarkMode
                        ? MyntColors.secondary
                        : MyntColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 0,
                    disabledBackgroundColor: resolveThemeColor(context,
                        dark: MyntColors.borderMutedDark,
                        light: MyntColors.borderMuted),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Create SIP',
                          style: MyntWebTextStyles.bodySmall(
                            context,
                            fontWeight: MyntFonts.semiBold,
                            color: MyntColors.backgroundColor,
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
}

/// Helper class to hold scrip item data
class SipScripItem {
  final ScripNewValue scrip;
  String investBy;
  final TextEditingController qtyController;
  final TextEditingController amountController;

  SipScripItem({
    required this.scrip,
    required this.investBy,
    required this.qtyController,
    required this.amountController,
  });
}
