import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/dashboard_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/cust_text_formfield.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';

class BrokerageCalculatorScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<BrokerageCalculatorScreen> createState() =>
      _BrokerageCalculatorScreenState();
}

class _BrokerageCalculatorScreenState
    extends ConsumerState<BrokerageCalculatorScreen>
    with TickerProviderStateMixin {
  // Controllers for input fields
  final TextEditingController _quantityController =
      TextEditingController(text: '100');
  final TextEditingController _buyPriceController =
      TextEditingController(text: '499');
  final TextEditingController _sellPriceController =
      TextEditingController(text: '501');
  final TextEditingController _brokerageTypeController =
      TextEditingController(text: 'Percentage');

  // State variables
  int _selectedSegment = 0;
  TabController? _tabController;
  final ScrollController _segmentScrollController = ScrollController();
  
  // Focus node for brokerage field
  final FocusNode _brokerageFocusNode = FocusNode();

  // Calculation results
  Map<String, dynamic> _results = {};

  final List<String> _segments = ['Equity', 'F&O', 'Currency', 'Commodity'];
  final List<List<String>> _subSegments = [
    ['Intraday', 'Delivery'],
    ['Futures', 'Options'],
    ['Futures', 'Options'],
    ['Non-Agri', 'Agri', 'Options']
  ];


  final TextEditingController _bottomSheetQuantityController =
      TextEditingController();
  final TextEditingController _bottomSheetBuyPriceController =
      TextEditingController();
  final TextEditingController _bottomSheetSellPriceController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _subSegments[_selectedSegment].length, vsync: this);
    _calculateCharges();

    // Initialize bottom sheet controllers with current values
    _bottomSheetQuantityController.text = _quantityController.text;
    _bottomSheetBuyPriceController.text = _buyPriceController.text;
    _bottomSheetSellPriceController.text = _sellPriceController.text;

    // Initialize brokerage type controller
    _brokerageTypeController.text =
        ref.read(dashboardProvider).brokerageTypeText;
    
    // Add focus listener to handle cursor blinking issue
    _brokerageFocusNode.addListener(() {
      if (!_brokerageFocusNode.hasFocus) {
        // Clear selection when field loses focus to prevent cursor blinking
        ref.read(dashboardProvider).brokerageController.selection = 
            TextSelection.collapsed(offset: ref.read(dashboardProvider).brokerageController.text.length);
      }
    });
    
    // Ensure the first tab is visible on initialization
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToActiveTab(0);
    // });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _brokerageTypeController.dispose();
    _tabController?.dispose();
    _segmentScrollController.dispose();
    _bottomSheetQuantityController.dispose();
    _bottomSheetBuyPriceController.dispose(); 
    _bottomSheetSellPriceController.dispose();
    _brokerageFocusNode.dispose();
    super.dispose();
  }

  // Bottom Sheet Methods
  void _showEditValuesBottomSheet() {
    // Update bottom sheet controllers with current values
    _bottomSheetQuantityController.text = _quantityController.text;
    _bottomSheetBuyPriceController.text = _buyPriceController.text;
    _bottomSheetSellPriceController.text = _sellPriceController.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildEditValuesBottomSheet(),
      ),
    );
  }

  Widget _buildEditValuesBottomSheet() {
    final theme = ref.watch(themeProvider);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          border: Border(
            top: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            left: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            right: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const CustomDragHandler(),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                    text: "Edit Trade Details",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1,
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildBottomSheetInputField(
                    'Quantity',
                    _bottomSheetQuantityController,
                    Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildBottomSheetInputField(
                    'Buy Price',
                    _bottomSheetBuyPriceController,
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 16),
                  _buildBottomSheetInputField(
                    'Sell Price',
                    _bottomSheetSellPriceController,
                    Icons.trending_down,
                  ),
                  const SizedBox(height: 32),
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => _updateValuesFromBottomSheet(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: TextWidget.subText(
                        text: 'Calculate',
                        theme: theme.isDarkMode,
                        color: colors.colorWhite,
                        fw: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetInputField(
      String label, TextEditingController controller, IconData icon) {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: CustomTextFormField(
            fillColor:
                theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
            textCtrl: controller,
            keyboardType: TextInputType.number,
            inputFormate: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            hintText: "Enter $label",
            hintStyle: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
            style: TextWidget.textStyle(
              fontSize: 16,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 0,
            ),
            textAlign: TextAlign.start,
            // prefixIcon: Icon(
            //   icon,
            //   color: theme.isDarkMode
            //       ? colors.textSecondaryDark
            //       : colors.textSecondaryLight,
            //   size: 20,
            // ),
          ),
        ),
      ],
    );
  }

  void _updateValuesFromBottomSheet() {
    // Update main controllers with bottom sheet values
    _quantityController.text = _bottomSheetQuantityController.text;
    _buyPriceController.text = _bottomSheetBuyPriceController.text;
    _sellPriceController.text = _bottomSheetSellPriceController.text;

    // Recalculate charges
    _calculateCharges();

    // Close bottom sheet
    Navigator.pop(context);
  }

  void _calculateCharges() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    final sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
    final brokerageRa = double.tryParse(ref.read(dashboardProvider).brokerageController.text) ?? 0;

double brokerageRate = (sellPrice == 0 || buyPrice == 0)
    ? brokerageRa
    : brokerageRa * 2;

    // if (quantity <= 0 || buyPrice <= 0 || sellPrice <= 0) return;

    final turnover = (buyPrice + sellPrice) * quantity;

    // Calculate based on segment and sub-segment
    Map<String, double> charges = _getChargesForSegment(
        _selectedSegment,
        _tabController?.index ?? 0,
        quantity,
        buyPrice,
        sellPrice,
        turnover,
        brokerageRate);

    setState(() {
      _results = charges;
    });
  }

  Map<String, double> _getChargesForSegment(
      int segment,
      int subSegment,
      double quantity,
      double buyPrice,
      double sellPrice,
      double turnover,
      double brokerageRate) {
    double brokerage = ref.read(dashboardProvider).isPercentageBrokerage
        ? (turnover * brokerageRate) / 100
        : brokerageRate;

    double stt = 0, ctt = 0, transactionCharges = 0, stampDuty = 0;

    switch (segment) {
      case 0: // Equity
        if (subSegment == 0) {
          // Intraday
          stt = (sellPrice * quantity * 0.025) / 100;
          transactionCharges = (turnover * 0.00297) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        } else {
          // Delivery
          stt = (turnover * 0.1) / 100;
          transactionCharges = (turnover * 0.00297) / 100;
          stampDuty = (buyPrice * quantity * 0.015) / 100;
        }
        break;
      case 1: // F&O
        if (subSegment == 0) {
          // Futures
          stt = (sellPrice * quantity * 0.02) / 100;
          transactionCharges = (turnover * 0.00173) / 100;
          stampDuty = (buyPrice * quantity * 0.002) / 100;
        } else {
          // Options
          stt = (sellPrice * quantity * 0.1) / 100;
          transactionCharges = (turnover * 0.035) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        }
        break;
      case 2: // Currency
        transactionCharges = subSegment == 0
            ? (turnover * 0.00035) / 100
            : (turnover * 0.03110) / 100;
        stampDuty = (buyPrice * quantity * 0.0001) / 100;
        break;
      case 3: // Commodity
        if (subSegment == 0) {
          // Non-Agri
          ctt = (sellPrice * quantity * 0.01) / 100;
          transactionCharges = (turnover * 0.0021) / 100;
          stampDuty = (buyPrice * quantity * 0.002) / 100;
        } else if (subSegment == 1) {
          // Agri
          transactionCharges = (turnover * 0.0021) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        } else {
          // Options
          ctt = (sellPrice * quantity * 0.041) / 100;
          transactionCharges = (turnover * 0.04180) / 100;
          stampDuty = (buyPrice * quantity * 0.003) / 100;
        }
        break;
    }

    double sebiCharges = (turnover * 0.0001) / 100;
    double gst = ((brokerage + transactionCharges + sebiCharges) * 18) / 100;
    double totalTaxes =
        brokerage + stt + ctt + transactionCharges + sebiCharges + gst;
    double totalCharges = totalTaxes + stampDuty;
    double netProfit =
        (sellPrice * quantity) - (buyPrice * quantity) - totalCharges;
    double breakEven = totalCharges / quantity;

    return {
      'turnover': turnover,
      'brokerage': brokerage,
      'stt': stt,
      'ctt': ctt,
      'transactionCharges': transactionCharges,
      'sebiCharges': sebiCharges,
      'gst': gst,
      'stampDuty': stampDuty,
      'totalCharges': totalCharges,
      'netProfit': netProfit,
      'breakEven': breakEven,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        appBar: AppBar(
          leadingWidth: 48,
          titleSpacing: 0,
          centerTitle: false,
          leading: CustomBackBtn(),
          elevation: 0.2,
          title: TextWidget.titleText(
              text: "Brokerage Calculator",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 1),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputSection(),
                _buildSegmentSelector(),
                // SizedBox(height: 16),
                _buildResultsSection(),
                // _buildInfoSection(),
              ],
            ),
          ),
        ),

      ),
    );
  }

  Widget _buildInputSection() {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First level tabs at the top
        _buildFirstLevelTabs(theme),
        const SizedBox(height: 10),        
        Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextWidget.titleText(
              //   text: 'Trade Details',
              //   theme: theme.isDarkMode,
              //   color: theme.isDarkMode
              //       ? colors.textPrimaryDark
              //       : colors.textPrimaryLight,
              //   fw: 0,
              // ),
              //   const SizedBox(height: 16),
        _buildBrokerageTypeSelector(),
            ],
          ),
        ),
      
        // const SizedBox(height: 8),
    
        // Current Values Display Section
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     TextWidget.subText(
        //       text: 'Values',
        //       theme: theme.isDarkMode,
        //       color: theme.isDarkMode
        //           ? colors.textPrimaryDark
        //           : colors.textPrimaryLight,
        //       fw: 1,
        //     ),
        //     const SizedBox(height: 16),
        //     Row(
        //       children: [
        //         Expanded(
        //           child: _buildValueDisplay(
        //             'Quantity',
        //             _quantityController.text,
        //             Icons.inventory_2_outlined,
        //           ),
        //         ),
        //         Expanded(
        //           child: _buildValueDisplay(
        //             'Buy Price',
        //             '${_buyPriceController.text}',
        //             Icons.trending_up,
        //           ),
        //         ),
        //         const SizedBox(height: 16),
        //         Expanded(
        //           child: _buildValueDisplay(
        //             'Sell Price',
        //             '${_sellPriceController.text}',
        //             Icons.trending_down,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildFirstLevelTabs(ThemesProvider theme) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            width: 0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        controller: _segmentScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            _segments.length,
            (index) => Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: theme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                highlightColor: theme.isDarkMode
                    ? Colors.white.withOpacity(0.01)
                    : Colors.black.withOpacity(0.01),
                                  onTap: () {
                    setState(() {
                      _selectedSegment = index;
                      _tabController?.dispose();
                      _tabController = TabController(
                          length: _subSegments[index].length, vsync: this);
                    });
                    // Scroll to the active tab to ensure it's visible
                    // WidgetsBinding.instance.addPostFrameCallback((_) {
                    //   _scrollToActiveTab(index);
                    // });
                    _calculateCharges();
                  },
                child: _buildSegmentTab(_segments[index], theme, index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueDisplay(String label, String value, IconData icon) {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.paraText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: value,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrokerageTypeSelector() {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextWidget.subText(
              text: ' Brokerage',
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 1,
            ),
            TextWidget.paraText(
              text: ref.read(dashboardProvider).brokerageTypeText == 'Percentage' ? ' (Percentage)' : ' (Flat)',
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode
                      ? colors.darkGrey
                      : const Color(0xffF1F3F8),
                  textCtrl: ref.read(dashboardProvider).brokerageController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormate: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (value) {
                    if (value.contains('..')) {
                      final newValue = value.replaceAll('..', '.');
                      ref.read(dashboardProvider).brokerageController.text = newValue;
                      ref.read(dashboardProvider).brokerageController.selection = 
                          TextSelection.collapsed(offset: newValue.length);
                      return;
                    }
                    _calculateCharges();
                  },
                  hintText: "Rate",
                  hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  style: TextWidget.textStyle(
                    fontSize: 16,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                  ),
                  textAlign: TextAlign.start,
                  prefixIcon: Icon(
                      ref.read(dashboardProvider).brokerageTypeText == 'Percentage'
                          ? Icons.percent
                          : Icons.currency_rupee,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      size: 20),
                        suffixIcon: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      onTap: () {
                        setState(() {
                          // Toggle brokerage type using provider method
                          final currentType = ref.read(dashboardProvider).isPercentageBrokerage;
                          ref.read(dashboardProvider).updateBrokerageType(!currentType);
                          _brokerageTypeController.text =
                              ref.read(dashboardProvider).brokerageTypeText;
                        });
                        _calculateCharges();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          assets.switchIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // SizedBox(width: 16),
            // Expanded(
            //   child: SizedBox(
            //     height: 45,
            //     child: CustomTextFormField(
            //       fillColor: theme.isDarkMode
            //           ? colors.darkGrey
            //           : const Color(0xffF1F3F8),
            //       textCtrl: _brokerageTypeController,
            //       isReadable: true,
            //       hintText: "Type",
            //       hintStyle: TextWidget.textStyle(
            //         fontSize: 14,
            //         theme: theme.isDarkMode,
            //         color: theme.isDarkMode
            //             ? colors.textSecondaryDark
            //             : colors.textSecondaryLight,
            //         fw: 0,
            //       ),
            //       style: TextWidget.textStyle(
            //         fontSize: 16,
            //         color: theme.isDarkMode
            //             ? colors.textPrimaryDark
            //             : colors.textPrimaryLight,
            //         theme: theme.isDarkMode,
            //         fw: 0,
            //       ),
            //       textAlign: TextAlign.start,
            //       suffixIcon: Material(
            //         color: Colors.transparent,
            //         shape: const CircleBorder(),
            //         child: InkWell(
            //           customBorder: const CircleBorder(),
            //           splashColor: theme.isDarkMode
            //               ? colors.splashColorDark
            //               : colors.splashColorLight,
            //           highlightColor: theme.isDarkMode
            //               ? colors.highlightDark
            //               : colors.highlightLight,
            //           onTap: () {
            //             setState(() {
            //               _isPercentageBrokerage = !_isPercentageBrokerage;
            //               _brokerageTypeController.text =
            //                   _isPercentageBrokerage ? 'Percentage' : 'Flat';
            //               _brokerageController.text =
            //                   _isPercentageBrokerage ? '0.03' : '20';
            //             });
            //             _calculateCharges();
            //           },
            //           child: Padding(
            //             padding: EdgeInsets.all(12.0),
            //             child: SvgPicture.asset(
            //               assets.switchIcon,
            //               fit: BoxFit.contain,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentSelector() {
    final theme = ref.watch(themeProvider);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Column(
        children: [
          // Sub-segment tabs only
          if (_tabController != null)
            Container(
              height: 35,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _subSegments[_selectedSegment].length,
                itemBuilder: (context, index) {
                  final subSegment = _subSegments[_selectedSegment][index];
                  final isSelected = _tabController?.index == index;

                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.15),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08),
                        onTap: () {
                          _tabController?.animateTo(index);
                          _calculateCharges();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.isDarkMode
                                    ? colors.searchBgDark
                                    : const Color(0xffF1F3F8)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.only(
                              left: 14, right: 14, top: 0, bottom: 0),
                          child: Center(
                            child: TextWidget.subText(
                              text: subSegment,
                              color: isSelected
                                  ? theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              fw: isSelected ? 2 : 0,
                              theme: !theme.isDarkMode,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(String title, ThemesProvider theme, int tab) {
    final isActive = _selectedSegment == tab;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: TextWidget.subText(
            text: title,
            color: isActive
                ? theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight
                : theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
            textOverflow: TextOverflow.ellipsis,
            maxLines: 1,
            theme: theme.isDarkMode,
            fw: isActive ? 2 : 0,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 2,
          width: isActive ? 82 : 0,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: colors.colorBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // void _scrollToActiveTab(int index) {
  //   if (_segmentScrollController.hasClients) {
  //     // Calculate the position to scroll to
  //     final itemWidth = MediaQuery.of(context).size.width * 0.25; // Width of each tab
  //     final screenWidth = MediaQuery.of(context).size.width;
  //     final scrollPosition = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
      
  //     // Ensure scroll position is within bounds
  //     final maxScroll = _segmentScrollController.position.maxScrollExtent;
  //     final finalScrollPosition = scrollPosition.clamp(0.0, maxScroll);
      
  //     _segmentScrollController.animateTo(
  //       finalScrollPosition,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }

  Widget _buildResultsSection() {
    final theme = ref.watch(themeProvider);
    if (_results.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // Net Profit Header

          // Detailed breakdown
          Container(
            // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            child: Column(
              children: [
                                 _buildResultRowWithEdit('Turnover', _results['turnover']),

                const SizedBox(height: 8),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    // borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget.subText(
                        text: 'Zebu Charges',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 1,
                      ),
                    ],
                  ),
                ),

                _buildResultRow('Brokerage', _results['brokerage']),
                const SizedBox(height: 8),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    // borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget.subText(
                        text: 'Statutory Charges',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 1,
                      ),
                    ],
                  ),
                ),

                if (_results['stt'] > 0)
                  _buildResultRow('STT', _results['stt']),
                if (_results['ctt'] > 0)
                  _buildResultRow('CTT', _results['ctt']),
                _buildResultRow(
                    'Transaction Charges', _results['transactionCharges']),
                _buildResultRow('GST', _results['gst']),

                _buildResultRow('SEBI Charges', _results['sebiCharges']),

                _buildResultRow('Stamp Duty', _results['stampDuty']),
                // Divider(height: 16),
                _buildResultRow('Total Charges', _results['totalCharges'],
                    isTotal: true),
                _buildResultRow('Breakeven Points', _results['breakEven'],
                    isBreakeven: true),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              // color: _results['netProfit'] >= 0 ? colors.profitLight.withOpacity(0.1) : colors.lossDark.withOpacity(0.1),
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(5),
              //   topRight: Radius.circular(5),
              // ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget.headText(
                  text: 'Net Profit/Loss',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
                const SizedBox(width: 8),
                TextWidget.headText(
                  text: '${_formatNumber(_results['netProfit'])}',
                  theme: theme.isDarkMode,
                  color: _results['netProfit'] >= 0
                      ? theme.isDarkMode
                          ? colors.profitDark
                          : colors.profitLight
                      : theme.isDarkMode
                          ? colors.lossDark
                          : colors.lossLight,
                  fw: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double value,
      {bool isTotal = false, bool isBreakeven = false}) {
    final theme = ref.watch(themeProvider);
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: label,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
            TextWidget.subText(
              text: isBreakeven
                  ? '${_formatNumber(value)} pts'
                  : ' ${_formatNumber(value)}',
              theme: theme.isDarkMode,
              color: isTotal
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }

  Widget _buildResultRowWithEdit(String label, double value) {
    final theme = ref.watch(themeProvider);
    return Column(
      children: [
        // const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TextWidget.subText(
                  text: label,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _showEditValuesBottomSheet,
                    borderRadius: BorderRadius.circular(20),
                    splashColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.15),
                    highlightColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.edit,
                        size: 18,
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextWidget.subText(
              text: ' ${_formatNumber(value)}',
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }

  Widget _buildInfoSection() {
    final theme = ref.watch(themeProvider);
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: colors.textPrimaryLight, size: 18),
              SizedBox(width: 8),
              TextWidget.subText(
                text: 'Important Notes',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 3,
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• STT will be higher in case of option exercised\n'
            '• Option Brokerage per lot, single side is ₹50\n'
            '• All charges are calculated as per current regulations\n'
            '• Actual charges may vary based on exchange notifications',
            style: TextWidget.textStyle(
              theme: theme.isDarkMode,
              fontSize: 12,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              height: 1.4,
              fw: 3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number.abs() >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)} Cr';
    } else if (number.abs() >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)} L';
    } else {
      return number.toStringAsFixed(2);
    }
  }
}
