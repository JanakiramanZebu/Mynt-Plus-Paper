import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/thems.dart';
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
  final TextEditingController _brokerageController =
      TextEditingController(text: '0.03');

  // State variables
  int _selectedSegment = 0;
  bool _isPercentageBrokerage = true;
  TabController? _tabController;

  // Calculation results
  Map<String, dynamic> _results = {};

  final List<String> _segments = ['Equity', 'F&O', 'Currency', 'Commodity'];
  final List<List<String>> _subSegments = [
    ['Intraday', 'Delivery'],
    ['Futures', 'Options'],
    ['Futures', 'Options'],
    ['Non-Agri', 'Agri', 'Options']
  ];

  // Bottom sheet controllers
  final TextEditingController _bottomSheetQuantityController = TextEditingController();
  final TextEditingController _bottomSheetBuyPriceController = TextEditingController();
  final TextEditingController _bottomSheetSellPriceController = TextEditingController();

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
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _brokerageController.dispose();
    _tabController?.dispose();
    _bottomSheetQuantityController.dispose();
    _bottomSheetBuyPriceController.dispose();
    _bottomSheetSellPriceController.dispose();
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
                        await Future.delayed(
                            const Duration(milliseconds: 150));
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
                        backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
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
            fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
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
            prefixIcon: Icon(
              icon,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              size: 20,
            ),
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
    final brokerageRa = double.tryParse(_brokerageController.text) ?? 0;

    double brokerageRate =
        (sellPrice == 0 || buyPrice == 0) ? brokerageRa : brokerageRa * 2;

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
    double brokerage = _isPercentageBrokerage
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
    return Container(
      // margin: EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Trade Details',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          ),
          const SizedBox(height: 16),
           _buildBrokerageTypeSelector(),
          const SizedBox(height: 8),

          
          // Current Values Display Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.subText(
                    text: 'Values',
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
                      onTap: _showEditValuesBottomSheet,
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 0),
              Row(
                children: [
                  Expanded(
                    child: _buildValueDisplay(
                      'Quantity',
                      _quantityController.text,
                      Icons.inventory_2_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildValueDisplay(
                      'Buy Price',
                      '${_buyPriceController.text}',
                      Icons.trending_up,
                    ),
                  ),
                  const SizedBox(height: 16),
              Expanded(
                child: _buildValueDisplay(
                  'Sell Price',
                  '${_sellPriceController.text}',
                  Icons.trending_down,
                ),
              ),
                ],
              ),
              
            ],
          ),
        ],
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
            Expanded(
              child: TextWidget.subText(
                text: ' Brokerage',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1, 
              ),
            ),
            Expanded(
              child: TextWidget.subText(
                text: ' Brokerage Type',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode
                      ? colors.darkGrey
                      : const Color(0xffF1F3F8),
                  textCtrl: _brokerageController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormate: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => _calculateCharges(),
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
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                    fw: 0,
                  ),
                  textAlign: TextAlign.start,
                  prefixIcon: Icon(
                      _isPercentageBrokerage
                          ? Icons.percent
                          : Icons.currency_rupee,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      size: 16),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   TextWidget.subText(
                    text: _isPercentageBrokerage ? 'Percentage' : 'Flat',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPercentageBrokerage = !_isPercentageBrokerage;
                        _brokerageController.text =
                            _isPercentageBrokerage ? '0.03' : '20';
                      });
                      _calculateCharges();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 40,
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _isPercentageBrokerage
                              ? colors.colorBlue.withOpacity(0.25)
                              : (theme.isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          alignment: _isPercentageBrokerage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _isPercentageBrokerage
                                  ? colors.colorBlue
                                  : Colors.grey[500],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                 
                ],
              ),
            ),
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
          // Main segment selector
          Container(
            height: 35,
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _segments.length,
              itemBuilder: (context, index) {
                final segment = _segments[index];
                final isSelected = _selectedSegment == index;

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
                        setState(() {
                          _selectedSegment = index;
                          _tabController?.dispose();
                          _tabController = TabController(
                              length: _subSegments[index].length, vsync: this);
                        });
                        _calculateCharges();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.isDarkMode ? colors.searchBgDark : const Color(0xffF1F3F8)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 0),
                        child: Center(
                          child: TextWidget.subText(
                            text: segment,
                            color: isSelected
                                ? theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight
                                : theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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

          // Sub-segment tabs
          if (_tabController != null)
            Container(
              height: 35,
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
                                ? theme.isDarkMode ? colors.searchBgDark : const Color(0xffF1F3F8)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 0),
                          child: Center(
                            child: TextWidget.subText(
                              text: subSegment,
                              color: isSelected
                                  ? theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight
                                  : theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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
                _buildResultRow('Turnover', _results['turnover']),

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
                      TextWidget.subText(text: 'Zebu Charges', theme: theme.isDarkMode, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, fw: 1,),
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
                      TextWidget.subText(text: 'Statutory Charges', theme: theme.isDarkMode, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, fw: 1,),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.titleText(
                  text: 'Net Profit/Loss',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
                TextWidget.titleText(
                  text: '${_formatNumber(_results['netProfit'])}',
                  theme: theme.isDarkMode,
                  color: _results['netProfit'] >= 0
                      ? theme.isDarkMode ? colors.profitDark : colors.profitLight
                      : theme.isDarkMode ? colors.lossDark : colors.lossLight,
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
              color:
                  isTotal ? colors.textSecondaryDark : colors.textSecondaryLight,
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
