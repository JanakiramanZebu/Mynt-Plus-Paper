import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../../../sharedWidget/snack_bar.dart';
// import 'basket_selection_bottom_sheet.dart';

class OptChainPutList extends StatelessWidget {
  final List<OptionValues>? putData;
  final bool isPutUp;
  final SwipeActionController? swipe;
  final bool showPriceView;
  final bool isBasketMode;

  const OptChainPutList({
    super.key,
    this.putData,
    this.swipe,
    required this.isPutUp,
    required this.showPriceView,
    required this.isBasketMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isPutUp,
      itemCount: putData?.length ?? 0,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (context, index) {
        final option = putData![index];
        return _OptionChainPutRow(
          key: ValueKey('put-${option.token}'),
          option: option,
          swipe: swipe,
          index: index,
          showPriceView: showPriceView,
          isBasketMode: isBasketMode,
        );
      },
    );
  }
}

class _OptionChainPutRow extends StatefulWidget {
  final OptionValues option;
  final SwipeActionController? swipe;
  final int index;
  final bool showPriceView;
  final bool isBasketMode;

  const _OptionChainPutRow({
    Key? key,
    required this.option,
    this.swipe,
    required this.index,
    required this.showPriceView,
    required this.isBasketMode,
  }) : super(key: key);

  @override
  _OptionChainPutRowState createState() => _OptionChainPutRowState();
}

class _OptionChainPutRowState extends State<_OptionChainPutRow> {
  // Cache the data locally to avoid rebuilds when parent rebuilds
  late String _lp;
  late String _perChange;
  late String _oiLack;
  late String _oiPerChng;
  late double _currentOI;
  StreamSubscription? _subscription;

  static double _globalMaxOI = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize with option model data first (context not available for websocket yet)
    _lp = widget.option.lp ?? widget.option.close ?? "0.00";
    _perChange = widget.option.perChange ?? "0.00";
    _oiLack = widget.option.oiLack ?? "0.00";
    _oiPerChng = widget.option.oiPerChng ?? "0.00";
    _currentOI = double.tryParse(widget.option.oi ?? "0") ?? 0.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if current option is in the basket

    // Now context is available - check for existing websocket data and update if needed
    try {
      final provider = ProviderScope.containerOf(context).read(websocketProvider);
      final socketData = provider.socketDatas;
      final existingData = socketData[widget.option.token];
      
      if (existingData != null) {
        // Update with websocket data if available
        final newLp = existingData['lp']?.toString();
        final newPc = existingData['pc']?.toString();
        final newOI = double.tryParse("${existingData['oi']}") ?? 0.0;
        
        if (newLp != null && newLp != "null") _lp = newLp;
        if (newPc != null && newPc != "null") _perChange = newPc;
        if (newOI >= 0) {
          _currentOI = newOI;
          _oiLack = (_currentOI / 100000).toStringAsFixed(2);
          
          // Calculate OI percentage change
          final poi = double.tryParse("${existingData['poi'] ?? 0.00}") ?? 0.0;
          if (poi > 0) {
            _oiPerChng = (((_currentOI - poi) / poi) * 100).toStringAsFixed(2);
          } else if (_currentOI > 0) {
            _oiPerChng = "100.00";
          } else {
            _oiPerChng = "0.00";
          }
        }

        // Update global max OI if current OI is greater
        if (_currentOI > _globalMaxOI) {
          _globalMaxOI = _currentOI;
        }

        // if (kDebugMode) {
        //   print("=== PUT WEBSOCKET SYNC ===");
        //   print("Token: ${widget.option.token}");
        //   print("Updated from WebSocket - LTP: $_lp, PC: $_perChange, OI: $_currentOI");
        //   print("==========================");
        // }
        
        // Update UI with websocket data
        setState(() {});
      }
    } catch (e) {
      // If provider access fails, just use option model data
      // if (kDebugMode) {
      //   print("=== PUT INIT FALLBACK ===");
      //   print("Token: ${widget.option.token}");
      //   print("Using Option Model - LTP: $_lp, PC: $_perChange, OI: $_currentOI");
      //   print("=========================");
      // }
    }

    // Always re-setup the listener to ensure fresh data flow
    _setupSocketListener();
  }


  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupSocketListener() {
    // Cancel existing subscription first
    _subscription?.cancel();
    
    // Get the stream of data
    final provider = ProviderScope.containerOf(context).read(websocketProvider);

    // Always subscribe to changes for THIS token
    _subscription = provider.socketDataStream.listen((socketData) {
      if (!mounted) return;

      // Only process if this token's data exists
      if (socketData.containsKey(widget.option.token)) {
        final data = socketData[widget.option.token];
        if (data == null) return;

        // Always update values when websocket data comes in (remove restrictive checks)
        bool needsUpdate = false;

        final newLp = data['lp']?.toString();
        if (newLp != null && newLp != "null" && newLp != _lp) {
          _lp = newLp;
          needsUpdate = true;
        }

        final newPc = data['pc']?.toString();
        if (newPc != null && newPc != "null" && newPc != _perChange) {
          _perChange = newPc;
          needsUpdate = true;
        }

        // Calculate OI values only if needed
        final oi = double.tryParse("${data['oi']}");
        if (oi != null && oi >= 0) { // Allow 0 values
          // Update current OI value
          if (oi != _currentOI) {
            _currentOI = oi;
            needsUpdate = true;
            
            // Update GLOBAL max OI if current OI is greater
            if (_currentOI > _globalMaxOI) {
              _globalMaxOI = _currentOI;
            }
          }
          
          final newOiLack = (oi / 100000).toStringAsFixed(2);
          if (newOiLack != _oiLack) {
            _oiLack = newOiLack;
            needsUpdate = true;
          }

          final poi = double.tryParse("${data['poi'] ?? 0.00}") ?? 0.0;
          String newOiPerChng = "0.00";
          
          // Safe calculation to avoid division by zero - same logic as call list
          if (poi > 0) {
            newOiPerChng = (((oi - poi) / poi) * 100).toStringAsFixed(2);
          } else if (oi > 0) {
            // If previous OI was 0 but current OI exists, show as 100% increase
            newOiPerChng = "100.00";
          }
          
          if (newOiPerChng != _oiPerChng && newOiPerChng != "NaN") {
            _oiPerChng = newOiPerChng;
            needsUpdate = true;
          }
        }

        // Always rebuild if we have any data update
        if (needsUpdate) {
          // if (kDebugMode) {
            // print("=== PUT DATA UPDATE ===");
            // print("Token: ${widget.option.token}");
            // print("LTP: $_lp, PC: $_perChange, OI: $_currentOI");
            // print("=======================");
          // }
          setState(() {});
          
          // Also check basket state periodically
              }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scripData =
        ProviderScope.containerOf(context).read(marketWatchProvider);
    final theme = ProviderScope.containerOf(context).read(themeProvider);

    return RepaintBoundary(
      child: SwipeActionCell(
        isDraggable: widget.option.tsym!.contains("|||") ? false : true,
        fullSwipeFactor: 0.7,
        controller: widget.swipe,
        index: widget.index,
        key: ValueKey(widget.option.token),
        leadingActions: [
          SwipeAction(
            performsFirstActionWithFullSwipe: true,
            title: "BUY",
            color: Color(theme.isDarkMode ? 0xffcaedc4 : 0xffedf9eb),
            style: _getActionStyle(colors.ltpgreen),
            onTap: (handler) async {
              await placeOrderInput(context, widget.option, true);
              handler(false);
            },
          ),
        ],
        trailingActions: [
          SwipeAction(
            performsFirstActionWithFullSwipe: true,
            title: "SELL",
            color: Color(theme.isDarkMode ? 0xfffbbbb6 : 0xfffee8e7),
            style: _getActionStyle(colors.darkred),
            onTap: (handler) async {
              await placeOrderInput(context, widget.option, false);
              handler(false);
            },
          ),
        ],
        child: InkWell(
          onLongPress: () => {
            widget.option.tsym!.contains("|||")
                ? _symbolenotFound(context)
                : _handleLongPress(context, widget.option)
          },
          onTap: () => {
            widget.option.tsym!.contains("|||")
                ? _symbolenotFound(context)
                : widget.isBasketMode 
                  ? _handleBasketModeTap(context, widget.option)
                  : _handleTap(context, widget.option)
          },
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: widget.showPriceView
                ? _buildPriceData(theme)
                : _buildOIData(theme),
          ),
        ),
      ),
    );
  }

Widget _buildPriceData(ThemesProvider theme) {
  // Calculate line width percentage based on current OI relative to GLOBAL max OI
  double lineWidthPercentage = 0.0;
  
  if (_currentOI > 0 && _globalMaxOI > 0) {
    // Calculate line width percentage based on current OI relative to GLOBAL max OI
    lineWidthPercentage = (_currentOI / _globalMaxOI).clamp(0.0, 1.0);
  }

  return Container(
    height: 55,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _lp,
          style: _getTextStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack, _perChange, theme),
        ),
        const SizedBox(height: 3),
        Text(
          "(${_perChange}%)",
          style: _getPercentageStyle(_perChange, theme),
        ),
        const SizedBox(height: 2),
        // Dynamic width line based on OI (right-aligned for puts)
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 1.5,
            width: MediaQuery.of(context).size.width * 0.25 * lineWidthPercentage,
            decoration: BoxDecoration(
              color: colors.error,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildOIData(ThemesProvider theme) {
  // Calculate line width percentage based on current OI relative to GLOBAL max OI
  double lineWidthPercentage = 0.0;
  
  if (_currentOI > 0 && _globalMaxOI > 0) {
    // Calculate line width percentage based on current OI relative to GLOBAL max OI
    lineWidthPercentage = (_currentOI / _globalMaxOI).clamp(0.0, 1.0);
  }

  return Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _oiLack,
          style: _getTextStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack, _oiPerChng, theme),
        ),
        const SizedBox(height: 3),
        Text(
          "(${_oiPerChng == "NaN" ? "0.00" : _oiPerChng}%)",
          style: _getPercentageStyle(_oiPerChng, theme),
        ),
        const SizedBox(height: 2),
        // Dynamic width line based on OI (right-aligned for puts)
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 1.5,
            width: MediaQuery.of(context).size.width * 0.25 * lineWidthPercentage,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    ),
  );
}

  void _symbolenotFound(BuildContext context) {
    showResponsiveWarningMessage(context, "Scrip Not founded");
  }

  void _handleLongPress(BuildContext context, OptionValues option) {
    final provider = ProviderScope.containerOf(context);
    final scripData = provider.read(marketWatchProvider);

    if (scripData.isPreDefWLs == "Yes") {
      Fluttertoast.showToast(
        msg: "This is a pre-defined watchlist that cannot be Added!",
        timeInSecForIosWeb: 2,
        backgroundColor: colors.colorBlack,
        textColor: colors.colorWhite,
        fontSize: 14.0,
      );
    } else {
      provider.read(websocketProvider).establishConnection(
            channelInput: "${option.exch}|${option.token}",
            task: "t",
            context: context,
          );
      scripData.addDelMarketScrip(
        scripData.wlName,
        "${option.exch}|${option.token}",
        context,
        true,
        true,
        false,
        true,
      );
    }
  }

  Future<void> _handleTap(BuildContext context, OptionValues option) async {
    final provider = ProviderScope.containerOf(context);
    final scripData = provider.read(marketWatchProvider);

    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;
    DepthInputArgs depthArgs = DepthInputArgs(
      exch: quots!.exch.toString(),
      token: quots.token.toString(),
      tsym: quots.tsym.toString(),
      instname: quots.instname.toString(),
      symbol: quots.symbol.toString(),
      expDate: quots.expDate.toString(),
      option: quots.option.toString(),
    );
    // Navigator.pop(context);
    await scripData.calldepthApis(context, depthArgs, "");
  }

  Future<void> _handleBasketModeTap(BuildContext context, OptionValues option) async {
    final provider = ProviderScope.containerOf(context);
    final scripData = provider.read(marketWatchProvider);
    final orderProv = provider.read(orderProvider);

    // Check if a basket is selected
    if (orderProv.selectedBsktName.isEmpty) {
      showResponsiveErrorMessage(context, "Please select a basket");
      return;
    }

    // Preserve current symbol context before basket operations
    scripData.preserveContextForBasket();

    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;
    
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch.toString(),
        token: quots.token.toString(),
        tsym: quots.tsym.toString(),
        instname: quots.instname.toString(),
        symbol: quots.symbol.toString(),
        expDate: quots.expDate.toString(),
        option: quots.option.toString(),
      );
      
      await scripData.calldepthApis(context, depthArgs, "BasketMode");

      // Restore original symbol context after basket operations
      scripData.restoreContextFromBasket();
    }
  }

  static final Map<Color, TextStyle> _actionStyleCache = {};
  static final Map<Color, TextStyle> _textStyleCache = {};
  static final Map<String, TextStyle> _percentageStyleCache = {};

  static TextStyle _getActionStyle(Color color) {
    return _actionStyleCache.putIfAbsent(
      color,
      () =>
          TextWidget.textStyle(fontSize: 18, color: color, theme: false, fw: 1),
    );
  }

  static TextStyle _getTextStyle(Color color, String perChange, ThemesProvider theme) {
    // return _textStyleCache.putIfAbsent(
    //   color,
      // () {
      Color color = colors.textSecondaryLight;
        if (perChange != null && perChange != "0.00") {
          color = perChange.startsWith("-") ?  theme.isDarkMode ? colors.lossDark : colors.lossLight : theme.isDarkMode ? colors.profitDark : colors.profitLight;
        }
          return TextWidget.textStyle(fontSize: 14, color: color, theme: false, );
    
  }
    // );
  // }

  static TextStyle _getPercentageStyle(String? value, ThemesProvider theme) {
    final key = value ?? "0.00";
    // return _percentageStyleCache.putIfAbsent(
    //   key,
    //   () {
        Color color = theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
        // if (value != null && value != "0.00") {
        //   color = value.startsWith("-") ? colors.darkred : colors.ltpgreen;
        // }
        return TextWidget.textStyle(
            fontSize: 12, color: color, theme: false,);
  }
}

Future<void> placeOrderInput(
  BuildContext context,
  OptionValues depthData,
  bool transType,
) async {
  // Obtain a WidgetRef from the context
  final container = ProviderScope.containerOf(context);

  await container.read(marketWatchProvider).fetchScripInfo(
        depthData.token.toString(),
        depthData.exch.toString(),
        context,
        true,
      );
  
  // **FIX: Use lot size from scripInfoModel if option data doesn't have it**
  final lotSize = depthData.ls?.isNotEmpty == true 
      ? depthData.ls 
      : container.read(marketWatchProvider).scripInfoModel?.ls.toString();
  
  OrderScreenArgs orderArgs = OrderScreenArgs(
    exchange: depthData.exch.toString(),
    tSym: depthData.tsym.toString(),
    isExit: false,
    token: depthData.token.toString(),
    transType: transType,
    lotSize: lotSize,
    ltp: "${depthData.lp ?? depthData.close ?? 0.00}",
    perChange: depthData.perChange ?? "0.00",
    orderTpye: '',
    holdQty: '',
    isModify: false,
    raw: {},
  );
  ResponsiveNavigation.toPlaceOrderScreen(
    context: context,
    arguments: {
      "orderArg": orderArgs,
      "scripInfo": container.read(marketWatchProvider).scripInfoModel!,
      "isBskt": "",
    },
  );
}
