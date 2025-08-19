import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_back_btn.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _subSegments[_selectedSegment].length, vsync: this);
    _calculateCharges();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _brokerageController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _calculateCharges() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    final sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
    final brokerageRate = double.tryParse(_brokerageController.text) ?? 0;

    if (quantity <= 0 || buyPrice <= 0 || sellPrice <= 0) return;

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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: InkWell(
              onTap: () {
                // ledgerprovider.falseloader('calpnl');
      
                Navigator.pop(context);
              },
              child: const CustomBackBtn()),
          elevation: 0.2,
          title: TextWidget.titleText(
              text: "Brokerage Calculator",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 1),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputSection(),
                _buildSegmentSelector(),
                SizedBox(height: 16),
                _buildResultsSection(),
                _buildInfoSection(),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            fw: 0,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Quantity',
                  _quantityController,
                  Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Buy Price',
                  _buyPriceController,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  'Sell Price',
                  _sellPriceController,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildBrokerageTypeSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, IconData icon,
      {String? prefix}) {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 3,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: colors.searchBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateCharges(),
            decoration: InputDecoration(
                prefixIcon:
                    Icon(icon, color: colors.textPrimaryLight, size: 18),
                prefixText: prefix,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                hintText: 'Enter $label',
                hintStyle: TextWidget.textStyle(
                    fontSize: 12,
                    theme: theme.isDarkMode,
                    fw: 3,
                    color: colors.textSecondaryLight)),
          ),
        ),
      ],
    );
  }

  Widget _buildBrokerageTypeSelector() {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'Brokerage Type',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 3,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colors.searchBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.searchBg),
                ),
                child: TextField(
                  controller: _brokerageController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _calculateCharges(),
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                          _isPercentageBrokerage
                              ? Icons.percent
                              : Icons.currency_rupee,
                          color: colors.textPrimaryLight,
                          size: 16),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      hintText: 'Rate',
                      hintStyle: TextWidget.textStyle(
                          fontSize: 12,
                          theme: theme.isDarkMode,
                          fw: 3,
                          color: colors.textSecondaryLight)),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colors.searchBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.searchBg),
                ),
                child: Row(
                  children: [
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: 40,
                          height: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _isPercentageBrokerage
                                ? Colors.blue.withOpacity(0.4)
                                : Colors.grey[400],
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
                                    ? Colors.blue
                                    : Colors.grey[600],
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
                    TextWidget.paraText(
                      text: _isPercentageBrokerage ? 'Percentage' : 'Flat',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
                    ),
                  ],
                ),
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Main segment selector
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.searchBg),
            ),
            child: Row(
              children: _segments.asMap().entries.map((entry) {
                int index = entry.key;
                String segment = entry.value;
                bool isSelected = _selectedSegment == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSegment = index;
                        _tabController?.dispose();
                        _tabController = TabController(
                            length: _subSegments[index].length, vsync: this);
                      });
                      _calculateCharges();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          // color: isSelected ? colors.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected
                                  ? colors.primaryDark
                                  : colors.searchBg),
                        ),
                        child: Center(
                          child: TextWidget.paraText(
                            text: segment,
                            theme: theme.isDarkMode,
                            color: isSelected
                                ? colors.primaryDark
                                : colors.textSecondaryLight,
                            fw: isSelected ? 1 : 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sub-segment tabs
          if (_tabController != null)
            Container(
              height: 40,
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => _calculateCharges(),
                indicator: BoxDecoration(
                  // color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.primaryDark),
                ),
                labelColor: colors.primaryDark,
                unselectedLabelColor: colors.textSecondaryLight,
                labelStyle: TextWidget.textStyle(
                    fontSize: 12,
                    theme: theme.isDarkMode,
                    fw: 1,
                    color: colors.primaryDark),
                unselectedLabelStyle: TextWidget.textStyle(
                    fontSize: 12,
                    theme: theme.isDarkMode,
                    fw: 3,
                    color: colors.textSecondaryLight),
                tabs: _subSegments[_selectedSegment]
                    .map((subSegment) => Tab(text: subSegment))
                    .toList(),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                // color: _results['netProfit'] >= 0 ? colors.profitLight.withOpacity(0.1) : colors.lossDark.withOpacity(0.1),
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(5),
                //   topRight: Radius.circular(5),
                // ),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.subText(
                  text: 'Net Profit/Loss',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
                TextWidget.titleText(
                  text: '₹${_formatNumber(_results['netProfit'])}',
                  theme: theme.isDarkMode,
                  color: _results['netProfit'] >= 0
                      ? colors.profitLight
                      : colors.lossLight,
                  fw: 0,
                ),
              ],
            ),
          ),

          // Detailed breakdown
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                _buildResultRow('Turnover', _results['turnover']),
                _buildResultRow('Brokerage', _results['brokerage']),
                if (_results['stt'] > 0)
                  _buildResultRow('STT', _results['stt']),
                if (_results['ctt'] > 0)
                  _buildResultRow('CTT', _results['ctt']),
                _buildResultRow(
                    'Transaction Charges', _results['transactionCharges']),
                _buildResultRow('SEBI Charges', _results['sebiCharges']),
                _buildResultRow('GST', _results['gst']),
                _buildResultRow('Stamp Duty', _results['stampDuty']),
                Divider(height: 16),
                _buildResultRow('Total Charges', _results['totalCharges'],
                    isTotal: true),
                _buildResultRow('Breakeven Points', _results['breakEven'],
                    isBreakeven: true),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.paraText(
            text: label,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 3,
          ),
          TextWidget.paraText(
            text: isBreakeven
                ? '${_formatNumber(value)} pts'
                : '₹ ${_formatNumber(value)}',
            theme: theme.isDarkMode,
            color:
                isTotal ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 3,
          ),
        ],
      ),
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
