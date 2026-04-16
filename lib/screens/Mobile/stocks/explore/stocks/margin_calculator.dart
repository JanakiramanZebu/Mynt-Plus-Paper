import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/res.dart';
import '../../../../../provider/thems.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../models/marketwatch_model/search_scrip_model.dart';
import '../../../../../models/span_calc_model.dart';
import '../../../../../sharedWidget/cust_text_formfield.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';
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
  final TextEditingController _bottomSheetSearchController =
      TextEditingController();
  final TextEditingController _bottomSheetQuantityController =
      TextEditingController();
  final FocusNode _bottomSheetSearchFocusNode = FocusNode();

  // State variables
  bool _isLoading = false;

  // Bottom sheet state variables
  ScripValue? _bottomSheetSelectedContract;
  String _bottomSheetTransactionType = 'B';
  int _bottomSheetQuantity = 0;
  String? _errorMessage;
  String? _errorMessageqty;

  @override
  void dispose() {
    _bottomSheetSearchController.dispose();
    _bottomSheetQuantityController.dispose();
    _bottomSheetSearchFocusNode.dispose();
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
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // _buildHeaderSection(),
                _buildMarginDisplaySection(),
                // const SizedBox(height: 16),
                _buildPortfolioSection(),
                // const SizedBox(height: 0), // Add space for FAB
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 150,
          height: 45,
          child: FloatingActionButton.extended(
            onPressed: _showAddContractBottomSheet,
            backgroundColor:
                theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
            label: TextWidget.subText(
              text: 'Add Symbol',
              theme: theme.isDarkMode,
              color: colors.colorWhite ,
              fw: 2,
            ),
             shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5), // change radius
  ),
            icon: const Icon(Icons.add, color: Colors.white),
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

  // Bottom Sheet Methods
  void _showAddContractBottomSheet() {
    _resetBottomSheetInputs();
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
        child: _buildAddContractBottomSheet(),
      ),
    ).then((_) {
      // Unfocus when bottom sheet is closed
      _bottomSheetSearchFocusNode.unfocus();
    });
    
    // Request focus after a short delay to ensure the bottom sheet is fully built
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _bottomSheetSearchFocusNode.requestFocus();
      }
    });
  }

  Widget _buildAddContractBottomSheet() {
    final theme = ref.watch(themeProvider);
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setBottomSheetState) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildBottomSheetSymbolSearch(setBottomSheetState),
                            // const SizedBox(height: 8),
                            if (_errorMessage != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextWidget.captionText(
                                  text: _errorMessage!,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight,
                                  fw: 0,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildBottomSheetTransactionTypeSelector(
                                          setBottomSheetState),
                                      // Transaction type doesn't need error messages
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildBottomSheetQuantityInput(
                                          setBottomSheetState),
                                      if (_errorMessageqty != null) ...[
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextWidget.captionText(
                                            text: _errorMessageqty!,
                                            theme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? colors.lossDark
                                                : colors.lossLight,
                                            fw: 0,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Add Button
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: !_isLoading
                                    ? () => _addBottomSheetContract(
                                        context, setBottomSheetState)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                                  disabledBackgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
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
              fw: 1,
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
                      focusNode: _bottomSheetSearchFocusNode,
                      onChanged: (value) => _onBottomSheetSearchChanged(
                          value, setBottomSheetState),
                      style: TextWidget.textStyle(
                        fontSize: 16,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        NoEmojiInputFormatter(),
                        FilteringTextInputFormatter.deny(
                            RegExp('[π£•₹€℅™∆√¶/.,]'))
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
                          color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                          fw: 0,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 15),
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
            if (stocksProvider.searchResults.isNotEmpty )
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color:
                      theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
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
                      child: InkWell(
                        onTap: () => _selectBottomSheetContract(
                            contract, setBottomSheetState),
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
                              text:
                                  contract.tsym ?? contract.symbol ?? 'Unknown',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
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
                                fw: 0,
                              ),
                              const SizedBox(width: 8),
                              TextWidget.paraText(
                                text: contract.instname ?? 'FUT',
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                fw: 0,
                              ),
                              if (contract.ls != null) ...[
                                const SizedBox(width: 8),
                                TextWidget.paraText(
                                  text: 'LOT ${contract.ls}',
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 0,
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
                  fw: 0,
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
          fw: 1,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: CustomTextFormField(
            isReadable: true,
            fillColor:
                theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
            textCtrl: _bottomSheetQuantityController,
            keyboardType: TextInputType.number,
            inputFormate: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setBottomSheetState(() {
                _bottomSheetQuantity = int.tryParse(value) ?? 0;
                _errorMessage = null; // Clear error when quantity is changed
                _errorMessageqty = null;
              });
            },
            // hintText: "Enter quantity",
            // hintStyle: TextWidget.textStyle(
            //   fontSize: 14,
            //   theme: theme.isDarkMode,
            //   color: theme.isDarkMode
            //       ? colors.textSecondaryDark
            //       : colors.textSecondaryLight,
            //   fw: 0,
            // ),
            style: TextWidget.textStyle(
              fontSize: 16,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 0,
            ),
            textAlign: TextAlign.center,
            prefixIcon: Material(
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
                  print(
                      'Minus button tapped - Current quantity: $_bottomSheetQuantity');
                  setBottomSheetState(() {
                    if (_bottomSheetSelectedContract != null) {
                      final lotSize = int.tryParse(
                              _bottomSheetSelectedContract!.ls ?? '1') ??
                          1;
                      print('Contract selected, lot size: $lotSize');
                      final newQty = _bottomSheetQuantity - lotSize;
                      if (newQty >= 0) {
                        _bottomSheetQuantity = newQty;
                        _bottomSheetQuantityController.text =
                            _bottomSheetQuantity.toString();
                        print(
                            'New quantity after decrease: $_bottomSheetQuantity');
                      }
                    } else {
                      print('No contract selected, decreasing by 1');
                      // If no contract selected, decrease by 1
                      if (_bottomSheetQuantity > 0) {
                        _bottomSheetQuantity -= 1;
                        _bottomSheetQuantityController.text =
                            _bottomSheetQuantity.toString();
                        print(
                            'New quantity after decrease: $_bottomSheetQuantity');
                      }
                    }
                  });
                },
                child: SvgPicture.asset(
                  theme.isDarkMode ? assets.darkCMinus : assets.minusIcon,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            suffixIcon: Material(
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
                  print(
                      'Plus button tapped - Current quantity: $_bottomSheetQuantity');
                  setBottomSheetState(() {
                    if (_bottomSheetSelectedContract != null) {
                      final lotSize = int.tryParse(
                              _bottomSheetSelectedContract!.ls ?? '1') ??
                          1;
                      print('Contract selected, lot size: $lotSize');
                      _bottomSheetQuantity += lotSize;
                      _bottomSheetQuantityController.text =
                          _bottomSheetQuantity.toString();
                      print(
                          'New quantity after increase: $_bottomSheetQuantity');
                    } else {
                      print('No contract selected, increasing by 1');
                      // If no contract selected, increase by 1
                      _bottomSheetQuantity += 1;
                      _bottomSheetQuantityController.text =
                          _bottomSheetQuantity.toString();
                      print(
                          'New quantity after increase: $_bottomSheetQuantity');
                    }
                  });
                },
                child: SvgPicture.asset(
                  theme.isDarkMode ? assets.darkAdd : assets.addIcon,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetTransactionTypeSelector(
      StateSetter setBottomSheetState) {
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
          fw: 1,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  backgroundColor:
                      _bottomSheetTransactionType != transactionValues[index]
                          ? (theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8))
                          : transactionValues[index] == 'S'
                              ? colors.loss // Red for Sell
                              : (theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight), // Blue for Buy
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                child: TextWidget.subText(
                  text: transactionTypes[index],
                  color: _bottomSheetTransactionType != transactionValues[index]
                      ? (theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight)
                      : colors
                          .colorWhite, // White text for both selected Buy and Sell
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: _bottomSheetTransactionType == transactionValues[index]
                      ? 1
                      : 0,
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
  void _onBottomSheetSearchChanged(
      String value, StateSetter setBottomSheetState) {
    if (value.length >= 2) {
      ref.read(stocksProvide).searchScrip(value);
    } else {
      ref.read(stocksProvide).clearSearchResults();
    }
  }

  void _selectBottomSheetContract(
      ScripValue contract, StateSetter setBottomSheetState) {
    setBottomSheetState(() {
      _bottomSheetSelectedContract = contract;
      _bottomSheetSearchController.text =
          contract.tsym ?? contract.symbol ?? '';
      final defaultQuantity = int.tryParse(contract.ls ?? '1') ?? 1;
      _bottomSheetQuantity = defaultQuantity;
      _bottomSheetQuantityController.text = _bottomSheetQuantity.toString();
      ref.read(stocksProvide).clearSearchResults();
      _errorMessage = null;
      _errorMessageqty = null;
    });
  }

  bool _canAddBottomSheetContract() {
    return _bottomSheetSelectedContract != null && _bottomSheetQuantity > 0;
  }

  void _addBottomSheetContract(
      BuildContext context, StateSetter setBottomSheetState) async {
    setBottomSheetState(() {
      _errorMessage = null;
      _errorMessageqty = null;
    });

    bool hasErrors = false;

    // Validate contract selection
    if (_bottomSheetSelectedContract == null) {
      setBottomSheetState(() {
        _errorMessage = "Select a contract";
      });
      hasErrors = true;
    }

    // Validate quantity
    if (_bottomSheetQuantity <= 0) {
      setBottomSheetState(() {
        _errorMessageqty = "Enter a valid quantity";
      });
      hasErrors = true;
    }

    // Check if same contract already exists (only if contract is selected)
    if (_bottomSheetSelectedContract != null) {
      final existingContract = ref.read(stocksProvide).marginCalculatorContractExists(
        _bottomSheetSelectedContract!.token ?? '',
        _bottomSheetSelectedContract!.exch ?? '',
      );

      if (existingContract) {
        setBottomSheetState(() {
          _errorMessage = "You can't add the same contract twice";
        });
        hasErrors = true;
      }
    }

    // Return early if there are validation errors
    if (hasErrors) {
      return;
    }

    setBottomSheetState(() {
      _isLoading = true;
    });

    // Enforce lot-size multiples like the web (ceil to nearest lot)
    final int defaultQuantity =
        int.tryParse(_bottomSheetSelectedContract!.ls ?? '1') ?? 1;
    final int lotSize = defaultQuantity > 0 ? defaultQuantity : 1;
    final int adjustedQty =
        ((_bottomSheetQuantity + lotSize - 1) ~/ lotSize) * lotSize;
    if (adjustedQty != _bottomSheetQuantity) {
      setBottomSheetState(() {
        _bottomSheetQuantity = adjustedQty;
        _bottomSheetQuantityController.text = _bottomSheetQuantity.toString();
      });
    }

    final resp = await ref.read(stocksProvide).calculateSpanForSelection(
          scrip: _bottomSheetSelectedContract!,
          quantity: _bottomSheetQuantity,
          transactionType: _bottomSheetTransactionType,
        );

    if (resp != null && resp.stat == 'Ok') {
      final spanMargin = resp.spanValue;
      final exposureMargin = resp.expoValue;

      final portfolioItem = MarginCalculatorPortfolioItem(
        scrip: _bottomSheetSelectedContract!,
        symbol: _bottomSheetSelectedContract!.tsym ??
            _bottomSheetSelectedContract!.symbol ??
            'Unknown',
        exchange: _bottomSheetSelectedContract!.exch ?? 'NSE',
        quantity: _bottomSheetQuantity,
        transactionType: _bottomSheetTransactionType,
        spanMargin: spanMargin,
        exposureMargin: exposureMargin,
        totalMargin:
            double.parse((spanMargin + exposureMargin).toStringAsFixed(2)),
      );

      ref.read(stocksProvide).addMarginCalculatorContract(portfolioItem);
      await _calculateCombinedMargin();

      // Close bottom sheet
      Navigator.pop(context);
    }

    setBottomSheetState(() {
      _isLoading = false;
    });
  }

  void _resetBottomSheetInputs() {
    _bottomSheetSearchController.clear();
    _bottomSheetQuantityController.clear();
    ref.read(stocksProvide).clearSearchResults();
    setState(() {
      _bottomSheetSelectedContract = null;
      _bottomSheetQuantity = 0;
      _bottomSheetTransactionType = 'B';
      _errorMessage = null;
      _errorMessageqty = null;
    });
  }

  Widget _buildMarginDisplaySection() {
    final theme = ref.watch(themeProvider);
    final stocksProvider = ref.watch(stocksProvide);
    return Container(
      // margin: EdgeInsets.all(16),
      // padding: EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Material(
          //           color: Colors.transparent,
          //           shape: const CircleBorder(),
          //           child: InkWell(
          //             onTap: () => _portfolioItems.isEmpty ? (){} : _resetAll,
          //             borderRadius: BorderRadius.circular(20),
          //             splashColor: theme.isDarkMode
          //                 ? colors.splashColorDark
          //                 : colors.splashColorLight,
          //             highlightColor: theme.isDarkMode
          //                 ? colors.splashColorDark
          //                 : colors.splashColorLight,
          //             child: Padding(
          //               padding: const EdgeInsets.all(8),
          //               child: Icon(
          //                 Icons.restart_alt,
          //                 color: theme.isDarkMode
          //                     ? colors.textSecondaryDark
          //                     : colors.textSecondaryLight,
          //                 size: 20,
          //               ),
          //             ),
          //           ),
          //         ),

          //         const SizedBox(width: 10),
          //           Material(
          //       color: Colors.transparent,
          //       shape: const CircleBorder(),
          //       child: InkWell(
          //         onTap: () async {
          //   await _calculateCombinedMargin();
          // },
          //         borderRadius: BorderRadius.circular(20),
          //         splashColor: theme.isDarkMode
          //             ? colors.splashColorDark
          //             : colors.splashColorLight,
          //         highlightColor: theme.isDarkMode
          //             ? colors.splashColorDark
          //             : colors.splashColorLight,
          //         child: Padding(
          //           padding: const EdgeInsets.all(8),
          //           child: Icon(
          //             Icons.refresh,
          //             color: theme.isDarkMode
          //                 ? colors.textSecondaryDark
          //                 : colors.textSecondaryLight,
          //             size: 20,
          //           ),
          //         ),
          //       ),
          //     )
          //   ],
          // ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextWidget.subText(
                        text: 'Total Margin',
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                        theme: false),
                    const SizedBox(height: 8),
                    Text(
                      stocksProvider.marginCalculatorCombinedMargin.total.toString(),
                      style: TextWidget.textStyle(
                        fontSize: 18,
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable Margin Breakdown Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Column(
              children: [
                                 Material(
                   color: Colors.transparent,
                   child: InkWell(
                                       onTap: () {
                     ref.read(stocksProvide).toggleMarginBreakdownExpansion();
                   },
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.highlightDark
                        : colors.highlightLight,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           SvgPicture.asset(assets.breakup,
                                  width: 14, height: 14, color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,),
                              const SizedBox(width: 6),
                          // const SizedBox(width: 6),
                          TextWidget.subText(
                            text: "Margin Breakdown",
                            theme: false,
                            fw: 2,
                            color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            stocksProvider.isMarginBreakdownExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Expandable margin breakdown content
                if (stocksProvider.isMarginBreakdownExpanded) ...[
                  const SizedBox(height: 16),
                  _buildMarginBreakdownContent(),
                ],
              ],
            ),
          ),

          // const SizedBox(height: 10),

          if (stocksProvider.marginCalculatorPortfolio.length > 1) ...[
            // const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.subText(
                  text:
                      'Margin Benefits: ${stocksProvider.marginCalculatorBenefits.toStringAsFixed(2)}',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Material(
                      //   color: Colors.transparent,
                      //   shape: const CircleBorder(),
                      //   child: InkWell(
                      //     onTap: () =>
                      //         _portfolioItems.isEmpty ? () {} : _resetAll,
                      //     borderRadius: BorderRadius.circular(20),
                      //     splashColor: theme.isDarkMode
                      //         ? colors.splashColorDark
                      //         : colors.splashColorLight,
                      //     highlightColor: theme.isDarkMode
                      //         ? colors.splashColorDark
                      //         : colors.splashColorLight,
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8),
                      //       child: Icon(
                      //         Icons.restart_alt,
                      //         color: theme.isDarkMode
                      //             ? colors.textSecondaryDark
                      //             : colors.textSecondaryLight,
                      //         size: 20,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 10),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () async {
                            await _calculateCombinedMargin();
                          },
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
                      )
                    ],
                  ),
                ),
              ],
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
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // 👈 keeps texts closer
        children: [
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
          const SizedBox(height: 4), // 🔹 reduced spacing
          TextWidget.subText(
            text: '₹${amount.toStringAsFixed(2)}',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          ),
        ],
      ),
    );
  }

   Widget data(String name, String value, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: name,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
            TextWidget.subText(
              text: value,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
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


  Widget _buildBenefitsProgressBar() {
    final theme = ref.watch(themeProvider);
    final stocksProvider = ref.watch(stocksProvide);
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(
        value: stocksProvider.marginCalculatorBenefitPercentage / 100,
        backgroundColor: theme.isDarkMode
            ? colors.textSecondaryDark.withOpacity(0.3)
            : colors.textSecondaryLight.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
        ),
        minHeight: 25,
      ),
    );
  }

  Widget _buildPortfolioSection() {
    final theme = ref.watch(themeProvider);
    final stocksProvider = ref.watch(stocksProvide);
    if (stocksProvider.marginCalculatorPortfolio.isEmpty) {
      return Container(
        // margin: EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          // borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              SvgPicture.asset(assets.noDatafound, color: const Color(0xff777777)),
              const SizedBox(height: 2),
              TextWidget.subText(
                  text: 'No Contract',
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                  theme: theme.isDarkMode),
              // const SizedBox(height: 4),
              // TextWidget.paraText(
              //   text: 'Add contracts to see margin requirements',
              //   theme: theme.isDarkMode,
              //   color: theme.isDarkMode
              //       ? colors.textSecondaryDark
              //       : colors.textSecondaryLight,
              //   fw: 3,
              // ),
            ],
          ),
        ),
      );
    }

    return Container(
      // margin: EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                fw: 1,
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
                      '${stocksProvider.marginCalculatorPortfolio.length} Contract${stocksProvider.marginCalculatorPortfolio.length > 1 ? 's' : ''}',
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
            itemCount: stocksProvider.marginCalculatorPortfolio.length,
            separatorBuilder: (context, index) => const ListDivider(),
            itemBuilder: (context, index) {
              final item = stocksProvider.marginCalculatorPortfolio[index];
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
                    fw: 0,
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
                      fw: 0,
                    ),
                    const SizedBox(width: 6),
                    // TextWidget.subText(
                    //   text: ' • ',
                    //   theme: theme.isDarkMode,
                    //   color: theme.isDarkMode
                    //       ? colors.textSecondaryDark
                    //       : colors.textSecondaryLight,
                    //   fw: 0,
                    // ),
                    TextWidget.paraText(
                      text: 'QTY ${item.quantity}',
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
                          text: item.totalMargin.toStringAsFixed(0),
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 0,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.transactionType == 'B'
                                ? theme.isDarkMode ? colors.profitDark.withOpacity(0.1) : colors.profitLight.withOpacity(0.1)
                                : theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextWidget.paraText(
                            text: item.transactionType == 'B' ? 'BUY' : 'SELL',
                            theme: theme.isDarkMode,
                            color: item.transactionType == 'B'
                                ? theme.isDarkMode ? colors.profitDark : colors.profitLight
                                : theme.isDarkMode ? colors.lossDark : colors.lossLight,
                            fw: 0,
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
  void _removeContract(int index) async {
    ref.read(stocksProvide).removeMarginCalculatorContract(index);
    await _calculateCombinedMargin();
  }

  void _resetAll() {
    ref.read(stocksProvide).clearMarginCalculatorPortfolio();
    setState(() {
      _errorMessage = null;
      _errorMessageqty = null;
    });
  }

  void _clearInputs() {
    _bottomSheetSearchController.clear();
    _bottomSheetQuantityController.clear();
    ref.read(stocksProvide).clearSearchResults();
    setState(() {
      _bottomSheetSelectedContract = null;
      _bottomSheetQuantity = 0;
      _bottomSheetTransactionType = 'B';
      _errorMessage = null;
      _errorMessageqty = null;
    });
  }

  Future<void> _calculateCombinedMargin() async {
    final stocksProvider = ref.read(stocksProvide);
    final portfolioItems = stocksProvider.marginCalculatorPortfolio;

    if (portfolioItems.isEmpty) {
      stocksProvider.updateMarginCalculatorCombinedData(
        combinedMargin: MarginCalculatorData(),
        benefits: 0.0,
        benefitPercentage: 0.0,
      );
      return;
    }

    // If only one item, combined equals single and no benefit
    if (portfolioItems.length == 1) {
      final single = portfolioItems.first;
      stocksProvider.updateMarginCalculatorCombinedData(
        combinedMargin: MarginCalculatorData(
          span: single.spanMargin,
          exposure: single.exposureMargin,
          total: single.totalMargin,
        ),
        benefits: 0.0,
        benefitPercentage: 0.0,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Build span positions for all items and request combined span
    final provider = ref.read(stocksProvide);
    final futures = portfolioItems.map((item) => provider.buildSpanPosition(
          scrip: item.scrip,
          quantity: item.quantity,
          transactionType: item.transactionType,
        ));

    final positionsList = await Future.wait(futures);
    final positions = positionsList.whereType<SpanCalcPositionItem>().toList();

    if (positions.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final combinedResp = await provider.calculateSpanForPositions(positions);
    final sumIndividual =
        portfolioItems.fold(0.0, (sum, item) => sum + item.totalMargin);

    if (combinedResp != null && combinedResp.stat == 'Ok') {
      final combinedSpan =
          double.parse(combinedResp.spanValue.toStringAsFixed(2));
      final combinedExpo =
          double.parse(combinedResp.expoValue.toStringAsFixed(2));
      final combinedTotal =
          double.parse((combinedSpan + combinedExpo).toStringAsFixed(2));

      // Mirror web logic conditions
      if (portfolioItems.length > 1 && combinedExpo > 0 && combinedTotal > 0) {
        final benefits =
            double.parse((sumIndividual - combinedTotal).toStringAsFixed(2));

        // Match web: this.perc = Math.round((100 * this.doughnuts[0]) / (this.doughnuts[0] + this.doughnuts[1]))
        // where doughnuts[0] = benefits, doughnuts[1] = combinedTotal
        final roundedPercent = (benefits + combinedTotal) > 0
            ? (100.0 * benefits) / (benefits + combinedTotal)
            : 0.0;

        stocksProvider.updateMarginCalculatorCombinedData(
          combinedMargin: MarginCalculatorData(
            span: combinedSpan,
            exposure: combinedExpo,
            total: combinedTotal,
          ),
          benefits: benefits > 0 ? benefits : 0.0,
          benefitPercentage:
              roundedPercent.isFinite ? roundedPercent.roundToDouble() : 0.0,
        );
      } else {
        stocksProvider.updateMarginCalculatorCombinedData(
          combinedMargin: MarginCalculatorData(
            span: combinedSpan,
            exposure: combinedExpo,
            total: combinedTotal,
          ),
          benefits: 0.0,
          benefitPercentage: 0.0,
        );
      }
    } else {
      // Fallback to summed margins if API failed
      final totalSpan =
          portfolioItems.fold(0.0, (sum, item) => sum + item.spanMargin);
      final totalExposure =
          portfolioItems.fold(0.0, (sum, item) => sum + item.exposureMargin);
      final total = totalSpan + totalExposure;

      stocksProvider.updateMarginCalculatorCombinedData(
        combinedMargin: MarginCalculatorData(
          span: totalSpan, 
          exposure: totalExposure, 
          total: total
        ),
        benefits: 0.0,
        benefitPercentage: 0.0,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildMarginBreakdownContent() {
    final theme = ref.watch(themeProvider);
    final stocksProvider = ref.watch(stocksProvide);
    return  Container(
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Available cash
         
          // Margin used
          data(
            'Span',
            "${stocksProvider.marginCalculatorCombinedMargin.span}",
            theme,
          ),
          // Withdrawable amount
          data(
             'Exposure',
            "${stocksProvider.marginCalculatorCombinedMargin.exposure}",
            theme,
          ),
        ],
      ),
    );
    
  }
}
