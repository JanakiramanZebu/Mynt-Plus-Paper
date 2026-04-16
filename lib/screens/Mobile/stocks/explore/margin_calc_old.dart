import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/res.dart';
import '../../../../../provider/thems.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../models/marketwatch_model/search_scrip_model.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';
import '../../../../../sharedWidget/cust_text_formfield.dart';
import '../../../../../sharedWidget/custom_text_form_field.dart';
import '../../../../../sharedWidget/list_divider.dart';

import '../../../../../utils/no_emoji_inputformatter.dart';

class MarginCalculatorScreen extends ConsumerStatefulWidget {
  const MarginCalculatorScreen({super.key});

  @override
  ConsumerState<MarginCalculatorScreen> createState() =>
      _MarginCalculatorScreenState();
}

class _MarginCalculatorScreenState
    extends ConsumerState<MarginCalculatorScreen> {
  // Bottom sheet controllers  
  final TextEditingController _bottomSheetSearchController = TextEditingController();
  final TextEditingController _bottomSheetQuantityController = TextEditingController();

  // State variables
  bool _isLoading = false;

  // Bottom sheet state variables
  ScripValue? _bottomSheetSelectedContract;
  String _bottomSheetTransactionType = 'B';
  int _bottomSheetQuantity = 0;

  // Portfolio data
  final List<PortfolioItem> _portfolioItems = [];
  MarginData _combinedMargin = MarginData();
  double _marginBenefits = 0.0;
  double _benefitPercentage = 0.0;

  @override
  void dispose() {
    _bottomSheetSearchController.dispose();
    _bottomSheetQuantityController.dispose();
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
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        appBar: AppBar(
          leadingWidth: 48,
          titleSpacing: 0,
          centerTitle: false,
          leading: const CustomBackBtn(),
          elevation: 0.2,
          title: TextWidget.titleText(
              text: "F&O Margin Calculator",
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
                // _buildHeaderSection(),
                _buildMarginDisplaySection(),
                const SizedBox(height: 16),
                _buildPortfolioSection(),
                const SizedBox(height: 80), // Add space for FAB
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddContractBottomSheet,
          backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
          child: Icon(
            Icons.add,
            color: colors.colorWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'F&O Margin (Span) Calculator',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
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









  Widget _buildMarginDisplaySection() {
    final theme = ref.watch(themeProvider);
    return Container(
      // margin: EdgeInsets.all(16),
      // padding: EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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

              Row(
                children: [
                  if (_portfolioItems.isNotEmpty)
                Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _resetAll,
                        borderRadius: BorderRadius.circular(20),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.clear_all,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _calculateCombinedMargin,
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                  Icons.refresh,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  size: 20,
                ),
                        ),
                      ),
                  ),
                ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
           Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              // const SizedBox(height: 12),
              TextWidget.paraText(
                text: title,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
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
                fw: 3,
              ),
            ],
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
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              SvgPicture.asset(assets.noDatafound, color: const Color(0xff777777)),
              const SizedBox(height: 2),
              TextWidget.subText(
                  text: 'No Contracts Added',
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                  theme: theme.isDarkMode),
              const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? colors.darkGrey
                      : const Color(0xffF1F3F8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextWidget.paraText(
                  text:
                      '${_portfolioItems.length} Contract${_portfolioItems.length > 1 ? 's' : ''}',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ),
            ],
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _portfolioItems.length,
            separatorBuilder: (context, index) => const ListDivider(),
            itemBuilder: (context, index) {
              final item = _portfolioItems[index];
              return ListTile(
                // contentPadding:
                //     EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                contentPadding:
                    const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextWidget.subText(
                    text: item.symbol,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 3,
                  ),
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
                      text: '  QTY ${item.quantity}',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
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
                          text: item.totalMargin.toStringAsFixed(0),
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 3,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.transactionType == 'B'
                                ? colors.profit.withOpacity(0.1)
                                : colors.loss.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextWidget.paraText(
                            text: item.transactionType == 'B' ? 'BUY' : 'SELL',
                            theme: theme.isDarkMode,
                            color: item.transactionType == 'B'
                                ? colors.profit
                                : colors.loss,
                            fw: 3,
                          ),
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
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => _removeContract(index),
                        borderRadius: BorderRadius.circular(20),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete_outlined,
                            color: theme.isDarkMode
                                ? colors.lossDark
                                : colors.lossLight,
                            size: 20,
                          ),
                        ),
                      ),
                    )
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

    final totalSpan =
        _portfolioItems.fold(0.0, (sum, item) => sum + item.spanMargin);
    final totalExposure =
        _portfolioItems.fold(0.0, (sum, item) => sum + item.exposureMargin);
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

  // Bottom Sheet Methods
  void _showAddContractBottomSheet() {
    _resetBottomSheetInputs();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddContractBottomSheet(),
    );
  }

  Widget _buildAddContractBottomSheet() {
    final theme = ref.watch(themeProvider);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
             decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
           border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
      
           
          ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.isDarkMode 
                          ? colors.textSecondaryDark 
                          : colors.textSecondaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.titleText(
                          text: "Add Contract",
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setBottomSheetState) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildBottomSheetSymbolSearch(setBottomSheetState),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildBottomSheetQuantityInput(setBottomSheetState),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildBottomSheetTransactionTypeSelector(setBottomSheetState),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              // Add Button
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _canAddBottomSheetContract() && !_isLoading 
                                      ? () => _addBottomSheetContract(context) 
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.colorBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: colors.colorWhite,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : TextWidget.subText(
                                          text: 'Add Contract',
                                          theme: theme.isDarkMode,
                                          color: colors.colorWhite,
                                          fw: 2,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSheetSymbolSearch(StateSetter setBottomSheetState) {
    final theme = ref.watch(themeProvider);

    return Consumer(
      builder: (context, ref, child) {
        final stocksProvider = ref.watch(stocksProvide);
        
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'Symbol',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset(
                assets.searchIcon,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _bottomSheetSearchController,
                  onChanged: (value) => _onBottomSheetSearchChanged(value, setBottomSheetState),
                  style: TextWidget.textStyle(
                    fontSize: 16,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    NoEmojiInputFormatter(),
                    FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
                  ],
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Search contract",
                    hintStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      color:(theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),fw: 0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                  ),
                ),
              ),
              if (_bottomSheetSearchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        _bottomSheetSearchController.clear();
      ref.read(stocksProvide).clearSearchResults();
                        setBottomSheetState(() {
                          _bottomSheetSelectedContract = null;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          assets.removeIcon,
                          width: 20,
                          height: 20,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Search Results
        if (stocksProvider.searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stocksProvider.searchResults.length > 5
                  ? 5
                  : stocksProvider.searchResults.length,
              itemBuilder: (context, index) {
                final contract = stocksProvider.searchResults[index];
                return Material(
                  color: Colors.transparent,
                  // shape: const CircleBorder(),
                  child: InkWell(
                     onTap: () => _selectBottomSheetContract(contract, setBottomSheetState),
                      splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextWidget.subText(
                          text: contract.tsym ?? contract.symbol ?? 'Unknown',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 3,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          TextWidget.paraText(
                            text: contract.exch ?? 'NSE',
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            fw: 3,
                          ),
                          const SizedBox(width: 8),
                          TextWidget.paraText(
                            text: contract.instname ?? 'FUT',
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            fw: 3,
                          ),
                          if (contract.ls != null) ...[
                            const SizedBox(width: 8),
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
                     
                    ),
                  ),
                );
              },
            ),
          )
        else if (stocksProvider.searchError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextWidget.paraText(
              text: stocksProvider.searchError!,
              theme: theme.isDarkMode,
              color: colors.loss,
              fw: 3,
            ),
          ),
      ],
    );
      },
    );
  }

  Widget _buildBottomSheetQuantityInput(StateSetter setBottomSheetState) {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'Quantity',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: CustomTextFormField(
            fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
            textCtrl: _bottomSheetQuantityController,
            keyboardType: TextInputType.number,
            inputFormate: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setBottomSheetState(() {
                _bottomSheetQuantity = int.tryParse(value) ?? 0;
              });
            },
            hintText: "Enter quantity",
            hintStyle: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),fw: 0,
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
              Icons.inventory_2_outlined,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetTransactionTypeSelector(StateSetter setBottomSheetState) {
    final theme = ref.watch(themeProvider);
    final transactionTypes = ['Buy', 'Sell'];
    final transactionValues = ['B', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'Transaction Type',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () {
                  setBottomSheetState(() {
                    _bottomSheetTransactionType = transactionValues[index];
                  });
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  backgroundColor: _bottomSheetTransactionType != transactionValues[index]
                      ? (theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8))
                      : transactionValues[index] == 'S'
                          ? colors.loss  // Red for Sell
                          : (theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight), // Blue for Buy
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                child: TextWidget.subText(
                  text: transactionTypes[index],
                  color: _bottomSheetTransactionType != transactionValues[index]
                      ? (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight)
                      : colors.colorWhite, // White text for both selected Buy and Sell
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: _bottomSheetTransactionType == transactionValues[index] ? 1 : 0,
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 8);
            },
            itemCount: transactionTypes.length,
          ),
        ),
      ],
    );
  }

  // Bottom Sheet Helper Methods
  void _onBottomSheetSearchChanged(String value, StateSetter setBottomSheetState) {
    if (value.length >= 2) {
      ref.read(stocksProvide).searchScrip(value);
    } else {
      ref.read(stocksProvide).clearSearchResults();
    }
  }

  void _selectBottomSheetContract(ScripValue contract, StateSetter setBottomSheetState) {
    setBottomSheetState(() {
      _bottomSheetSelectedContract = contract;
      _bottomSheetSearchController.text = contract.tsym ?? contract.symbol ?? '';
      final defaultQuantity = int.tryParse(contract.ls ?? '1') ?? 1;
      _bottomSheetQuantity = defaultQuantity;
      _bottomSheetQuantityController.text = _bottomSheetQuantity.toString();
      ref.read(stocksProvide).clearSearchResults();
    });
  }

  bool _canAddBottomSheetContract() {
    return _bottomSheetSelectedContract != null && _bottomSheetQuantity > 0;
  }

  void _addBottomSheetContract(BuildContext context) async {
    if (_canAddBottomSheetContract()) {
    setState(() {
      _isLoading = true;
    });

    final resp = await ref.read(stocksProvide).calculateSpanForSelection(
            scrip: _bottomSheetSelectedContract!,
            quantity: _bottomSheetQuantity,
            transactionType: _bottomSheetTransactionType,
          );

    if (resp != null && resp.stat == 'Ok') {
      final spanMargin = resp.spanValue;
      final exposureMargin = resp.expoValue;

      final portfolioItem = PortfolioItem(
          symbol: _bottomSheetSelectedContract!.tsym ?? 
                  _bottomSheetSelectedContract!.symbol ?? 'Unknown',
          exchange: _bottomSheetSelectedContract!.exch ?? 'NSE',
          quantity: _bottomSheetQuantity,
          transactionType: _bottomSheetTransactionType,
        spanMargin: spanMargin,
        exposureMargin: exposureMargin,
        totalMargin: spanMargin + exposureMargin,
      );

      setState(() {
        _portfolioItems.add(portfolioItem);
      });
      _calculateCombinedMargin();
        
        // Close bottom sheet
        Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }
  }

  void _resetBottomSheetInputs() {
    _bottomSheetSearchController.clear();
    _bottomSheetQuantityController.clear();
    ref.read(stocksProvide).clearSearchResults();
    setState(() {
      _bottomSheetSelectedContract = null;
      _bottomSheetQuantity = 0;
      _bottomSheetTransactionType = 'B';
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
