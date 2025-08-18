import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/res.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/stocks_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../models/marketwatch_model/search_scrip_model.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_text_form_field.dart';
import '../../../../utils/no_emoji_inputformatter.dart';

class MarginCalculatorScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MarginCalculatorScreen> createState() =>
      _MarginCalculatorScreenState();
}

class _MarginCalculatorScreenState
    extends ConsumerState<MarginCalculatorScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // State variables
  bool _isLoading = false;
  ScripValue? _selectedContract;
  String _transactionType = 'B'; // B for Buy, S for Sell
  int _quantity = 0;
  int _defaultQuantity = 0;

  // Portfolio data
  List<PortfolioItem> _portfolioItems = [];
  MarginData _combinedMargin = MarginData();
  double _marginBenefits = 0.0;
  double _benefitPercentage = 0.0;

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
              text: "F&O Margin Calculator",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 1),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // _buildHeaderSection(),
              _buildInputSection(),
              _buildMarginDisplaySection(),
              const SizedBox(height: 16),
              _buildPortfolioSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'F&O Margin (Span) Calculator',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Estimate the margin requirements for your trades with precision using this handy tool.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    final theme = ref.watch(themeProvider);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      // margin: EdgeInsets.all(16),
      // padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.titleText(
            text: 'Contract Details',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
          ),
          const SizedBox(height: 16),
          _buildSymbolSearch(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuantityInput(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTransactionTypeSelector(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: _portfolioItems.isEmpty ? (){} : _resetAll,
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                        ),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))),
                    child: TextWidget.subText(
                      text: 'Reset',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight,
                      fw: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: _canAddContract() && !_isLoading ? _addContract : (){},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        backgroundColor: colors.colorBlue,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5)))),
                    child: TextWidget.subText(
                      text: 'Add',
                      theme: theme.isDarkMode,
                      color: colors.colorWhite,
                      fw: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSearch() {
    final theme = ref.watch(themeProvider);
    final stocksProvider = ref.watch(stocksProvide);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'Symbol',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: colors.searchBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextWidget.textStyle(
                fontSize: 14, theme: theme.isDarkMode, fw: 1),
            keyboardType: TextInputType.text,
            inputFormatters: [
              UpperCaseTextFormatter(),
              NoEmojiInputFormatter(),
              FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
            ],
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(assets.searchIcon,
                    color: colors.textPrimaryLight,
                    fit: BoxFit.scaleDown,
                    width: 20),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.highlightDark
                            : colors.highlightLight,
                        onTap: () {
                          _searchController.clear();
                          ref.read(stocksProvide).clearSearchResults();
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _selectedContract = null;
                          });
                        },
                        child: SvgPicture.asset(assets.removeIcon,
                            fit: BoxFit.scaleDown, width: 20),
                      ),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              disabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              hintText: 'Search contract',
              hintStyle: TextWidget.textStyle(
                  fontSize: 12,
                  theme: theme.isDarkMode,
                  fw: 3,
                  color: colors.textSecondaryLight),
            ),
          ),
        ),

        // Search Results
        if (stocksProvider.searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: colors.searchBg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stocksProvider.searchResults.length > 5
                  ? 5
                  : stocksProvider.searchResults.length,
              itemBuilder: (context, index) {
                final contract = stocksProvider.searchResults[index];
                return ListTile(
                  title: TextWidget.subText(
                    text: contract.tsym ?? contract.symbol ?? 'Unknown',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  subtitle: Row(
                    children: [
                      TextWidget.subText(
                        text: contract.exch ?? 'NSE',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 3,
                      ),
                      SizedBox(width: 8),
                      TextWidget.paraText(
                        text: contract.instname ?? 'FUT',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 3,
                      ),
                      if (contract.ls != null) ...[
                        SizedBox(width: 8),
                        TextWidget.paraText(
                          text: 'Lot: ${contract.ls}',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 3,
                        ),
                      ],
                    ],
                  ),
                  onTap: () => _selectContract(contract),
                );
              },
            ),
          )
        else if (stocksProvider.searchError != null)
          TextWidget.paraText(
            text: stocksProvider.searchError!,
            theme: theme.isDarkMode,
            color: colors.loss,
            fw: 3,
          ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'Quantity',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: colors.searchBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setState(() {
                _quantity = int.tryParse(value) ?? 0;
              });
              if (_selectedContract != null && _quantity > 0) {
                _fetchSpanForCurrentSelection();
              }
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.inventory_2_outlined,
                color: colors.textPrimaryLight,
                size: 18,
              ),
              hintText: 'Enter quantity',
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              disabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              contentPadding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              hintStyle: TextWidget.textStyle(
                  fontSize: 12,
                  theme: theme.isDarkMode,
                  fw: 3,
                  color: colors.textSecondaryLight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSelector() {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'Transaction Type',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _transactionType = 'B');
                  if (_selectedContract != null && _quantity > 0) {
                    _fetchSpanForCurrentSelection();
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: _transactionType == 'B'
                        ? (theme.isDarkMode
                            ? colors.primaryDark.withOpacity(0.1)
                            : colors.primaryLight.withOpacity(0.1))
                        : colors.searchBg,
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(
                    //   color: _transactionType == 'B'
                    //       ? (theme.isDarkMode
                    //           ? colors.primaryDark
                    //           : colors.primaryLight)
                    //       : colors.searchBg,
                    //   width: 2,
                    // ),
                  ),
                  alignment: Alignment.center,
                  child: TextWidget.subText(
                    text: 'Buy',
                    theme: theme.isDarkMode,
                    color: _transactionType == 'B'
                        ? (theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight)
                        : colors.textSecondaryLight,
                    fw: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Sell button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _transactionType = 'S');
                  if (_selectedContract != null && _quantity > 0) {
                    _fetchSpanForCurrentSelection();
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: _transactionType == 'S'
                        ? colors.loss.withOpacity(0.1)
                        : colors.searchBg,
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(
                    //   color: _transactionType == 'S'
                    //       ? colors.loss
                    //       : colors.searchBg,
                    //   width: 2,
                    // ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sell',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _transactionType == 'S'
                          ? colors.loss
                          : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarginDisplaySection() {
    final theme = ref.watch(themeProvider);
    return Container(
      // margin: EdgeInsets.all(16),
      // padding: EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: 'Combined Margin Requirements',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: colors.textSecondaryLight, size: 20,),
                onPressed: _calculateCombinedMargin,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Margin Cards
          Row(
            children: [
              Expanded(
                child: _buildMarginCard(
                  'SPAN',
                  _combinedMargin.span,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMarginCard(
                  'Exposure',
                  _combinedMargin.exposure,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMarginCard(
                  'Total Margin',
                  _combinedMargin.total,
                  Colors.grey[600]!,
                ),
              ),
            ],
          ),

          if (_portfolioItems.length > 1) ...[
            const SizedBox(height: 20),
              TextWidget.subText(
                text: 'Margin Benefits: ₹${_marginBenefits.toStringAsFixed(2)}',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            
            const SizedBox(height: 12),
            _buildBenefitsProgressBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildMarginCard(String title, double amount, Color color) {
    final theme = ref.watch(themeProvider);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          TextWidget.paraText(
            text: title,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 3,
            textOverflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          TextWidget.paraText(
            text: '₹${amount.toStringAsFixed(2)}',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: colors.searchBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _benefitPercentage / 100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    final theme = ref.watch(themeProvider);
    if (_portfolioItems.isEmpty) {
      return Container(
        // margin: EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
         
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 40,
                color: colors.iconColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              TextWidget.subText(
                text: 'No Contracts Added',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
              const SizedBox(height: 8),
              TextWidget.paraText(
                text: 'Add contracts to see margin requirements',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      // margin: EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.colorWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.subText(
                  text: 'Portfolio Overview',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
                TextWidget.subText(
                  text: '${_portfolioItems.length} Contract${_portfolioItems.length > 1 ? 's' : ''}',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _portfolioItems.length,
            separatorBuilder: (context, index) =>  Divider(color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight , height: 1,),
            itemBuilder: (context, index) {
              final item = _portfolioItems[index];
              return ListTile(
                // contentPadding:
                //     EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.transactionType == 'B'
                        ? colors.profit.withOpacity(0.1)
                        : colors.loss.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextWidget.paraText(
                    text: item.transactionType == 'B' ? 'BUY' : 'SELL',
                    theme: theme.isDarkMode,
                    color: item.transactionType == 'B'
                        ? colors.profit
                        : colors.loss,
                    fw: 0,
                  ),
                ),
                title: TextWidget.subText(
                  text: item.symbol,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
                subtitle: Row(
                  children: [
                    TextWidget.paraText(
                      text: item.exchange,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
                    ),
                    // TextWidget.subText(
                    //   text: ' • ',
                    //   theme: theme.isDarkMode,
                    //   color: theme.isDarkMode
                    //       ? colors.textSecondaryDark
                    //       : colors.textSecondaryLight,
                    //   fw: 0,
                    // ),
                    TextWidget.paraText(
                      text: '  Qty: ${item.quantity}',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                          TextWidget.subText(
                          text: '₹${item.totalMargin.toStringAsFixed(0)}',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 0,
                        ),
                        // TextWidget.subText(
                        //   text: 'Total',
                        //   theme: theme.isDarkMode,
                        //   color: theme.isDarkMode
                        //       ? colors.textSecondaryDark
                        //       : colors.textSecondaryLight,
                        //   fw: 0,
                        // ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colors.loss),
                      onPressed: () => _removeContract(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Methods
  void _onSearchChanged(String value) {
    if (value.length >= 2) {
      ref.read(stocksProvide).searchScrip(value);
    } else {
      ref.read(stocksProvide).clearSearchResults();
    }
  }

  void _selectContract(ScripValue contract) {
    setState(() {
      _selectedContract = contract;
      _searchController.text = contract.tsym ?? contract.symbol ?? '';
      _defaultQuantity = int.tryParse(contract.ls ?? '1') ?? 1;
      _quantity = _defaultQuantity;
      _quantityController.text = _quantity.toString();
      ref.read(stocksProvide).clearSearchResults();
      FocusScope.of(context).unfocus();
    });

  
  }

  bool _canAddContract() {
    return _selectedContract != null && _quantity > 0;
  }

  void _addContract() {
    if (_canAddContract()) {
      _fetchSpanForCurrentSelection();
    }
  }

  Future<void> _fetchSpanForCurrentSelection() async {
    if (_selectedContract == null || _quantity <= 0) return;
    setState(() { _isLoading = true; });

    final resp = await ref.read(stocksProvide).calculateSpanForSelection(
      scrip: _selectedContract!,
      quantity: _quantity,
      transactionType: _transactionType,
    );
    if (resp != null && resp.stat == 'Ok') {
      final spanMargin = resp.spanValue;
      final exposureMargin = resp.expoValue;

      final portfolioItem = PortfolioItem(
        symbol: _selectedContract!.tsym ?? _selectedContract!.symbol ?? 'Unknown',
        exchange: _selectedContract!.exch ?? 'NSE',
        quantity: _quantity,
        transactionType: _transactionType,
        spanMargin: spanMargin,
        exposureMargin: exposureMargin,
        totalMargin: spanMargin + exposureMargin,
      );

      setState(() {
        _portfolioItems.add(portfolioItem);
        _clearInputs();
      });
      _calculateCombinedMargin();
    }
    setState(() { _isLoading = false; });
  }

  void _removeContract(int index) {
    setState(() {
      _portfolioItems.removeAt(index);
    });
    _calculateCombinedMargin();
  }

  void _resetAll() {
    setState(() {
      _portfolioItems.clear();
      _combinedMargin = MarginData();
      _marginBenefits = 0.0;
      _benefitPercentage = 0.0;
    });
    _clearInputs();
  }

  void _clearInputs() {
    _searchController.clear();
    _quantityController.clear();
    ref.read(stocksProvide).clearSearchResults();
    setState(() {
      _selectedContract = null;
      _quantity = 0;
      _transactionType = 'B';
    });
  }

  void _calculateCombinedMargin() {
    if (_portfolioItems.isEmpty) {
      setState(() {
        _combinedMargin = MarginData();
        _marginBenefits = 0.0;
        _benefitPercentage = 0.0;
      });
      return;
    }

    final totalSpan = _portfolioItems.fold(0.0, (sum, item) => sum + item.spanMargin);
    final totalExposure = _portfolioItems.fold(0.0, (sum, item) => sum + item.exposureMargin);
    final total = totalSpan + totalExposure;

    setState(() {
      _combinedMargin = MarginData(
        span: totalSpan,
        exposure: totalExposure,
        total: total,
      );
      _marginBenefits = 0.0;
      _benefitPercentage = 0.0;
    });
  }
}

// Data Models

class PortfolioItem {
  final String symbol;
  final String exchange;
  final int quantity;
  final String transactionType;
  final double spanMargin;
  final double exposureMargin;
  final double totalMargin;

  PortfolioItem({
    required this.symbol,
    required this.exchange,
    required this.quantity,
    required this.transactionType,
    required this.spanMargin,
    required this.exposureMargin,
    required this.totalMargin,
  });
}

class MarginData {
  final double span;
  final double exposure;
  final double total;

  MarginData({
    this.span = 0.0,
    this.exposure = 0.0,
    this.total = 0.0,
  });
}
