import 'dart:async';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/snack_bar.dart';

class OptChainCallList extends StatelessWidget {
  final List<OptionValues>? callData;
  final bool isCallUp;
  final SwipeActionController? swipe;
  final bool showPriceView;

  const OptChainCallList({
    super.key,
    this.callData,
    this.swipe,
    required this.isCallUp,
    required this.showPriceView,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isCallUp,
      itemCount: callData?.length ?? 0,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (context, index) {
        final option = callData![index];
        return _OptionChainCallRow(
          key: ValueKey('call-${option.token}'),
          option: option,
          swipe: swipe,
          index: index,
          showPriceView: showPriceView,
        );
      },
    );
  }
}

class _OptionChainCallRow extends StatefulWidget {
  final OptionValues option;
  final SwipeActionController? swipe;
  final int index;
  final bool showPriceView;

  const _OptionChainCallRow({
    Key? key,
    required this.option,
    this.swipe,
    required this.index,
    required this.showPriceView,
  }) : super(key: key);

  @override
  _OptionChainCallRowState createState() => _OptionChainCallRowState();
}

class _OptionChainCallRowState extends State<_OptionChainCallRow> {
  // Cache the data locally to avoid rebuilds when parent rebuilds
  late String _lp;
  late String _perChange;
  late String _oiLack;
  late String _oiPerChng;
  StreamSubscription? _subscription;
  bool _isListenerSetup = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current values
    _lp = widget.option.lp ?? widget.option.close ?? "0.00";
    _perChange = widget.option.perChange ?? "0.00";
    _oiLack = widget.option.oiLack ?? "0.00";
    _oiPerChng = widget.option.oiPerChng ?? "0.00";

    // Don't set up the listener in initState - moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only set up the listener once
    if (!_isListenerSetup) {
      _setupSocketListener();
      _isListenerSetup = true;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupSocketListener() {
    // Get the stream of data
    final provider = ProviderScope.containerOf(context).read(websocketProvider);

    // Only subscribe to changes for THIS token
    _subscription = provider.socketDataStream.listen((socketData) {
      if (!mounted) return;

      // Only process if this token's data changed
      if (socketData.containsKey(widget.option.token)) {
        final data = socketData[widget.option.token];
        if (data == null) return;

        // Debug: Log socket updates for this token
        // print("=== CALL SOCKET UPDATE ===");
        // print("Token: ${widget.option.token}");
        // print("Socket LTP: ${data['lp']}");
        // print("Socket PC: ${data['pc']}");
        // print("Current _lp: $_lp");
        // print("Current _perChange: $_perChange");
        // print("==========================");

        // Check if values actually changed before updating state
        bool needsUpdate = false;

        final newLp = data['lp']?.toString();
        if (newLp != null &&
            newLp != _lp &&
            newLp != "null" &&
            newLp != "0" &&
            newLp != "0.0") {
          _lp = newLp;
          needsUpdate = true;
        }

        final newPc = data['pc']?.toString();
        if (newPc != null &&
            newPc != _perChange &&
            newPc != "null" &&
            newPc != "0" &&
            newPc != "0.0") {
          _perChange = newPc;
          needsUpdate = true;
        }

        // Calculate OI values only if needed
        final oi = double.tryParse("${data['oi']}");
        if (oi != null && oi > 0) {
          final newOiLack = (oi / 100000).toStringAsFixed(2);
          if (newOiLack != _oiLack) {
            _oiLack = newOiLack;
            needsUpdate = true;
          }

          final poi = double.tryParse("${data['poi'] ?? 0.00}") ?? 0.0;
          final newOiPerChng = ((poi / oi) * 100).toStringAsFixed(2);
          if (newOiPerChng != _oiPerChng) {
            _oiPerChng = newOiPerChng;
            needsUpdate = true;
          }
        }

        // Only rebuild if data actually changed
        if (needsUpdate) {
          setState(() {});
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
            title: "SELL",
            color: Color(theme.isDarkMode ? 0xfffbbbb6 : 0xfffee8e7),
            style: _getActionStyle(colors.darkred),
            onTap: (handler) async {
              await placeOrderInput(scripData, context, widget.option, false);
              handler(false);
            },
          ),
        ],
        trailingActions: [
          SwipeAction(
            performsFirstActionWithFullSwipe: true,
            title: "BUY",
            color: Color(theme.isDarkMode ? 0xffcaedc4 : 0xffedf9eb),
            style: _getActionStyle(colors.ltpgreen),
            onTap: (handler) async {
              await placeOrderInput(scripData, context, widget.option, true);
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
                : _handleTap(context, widget.option)
          },
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: widget.showPriceView
                ? _buildPriceData(theme)
                : _buildOIData(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildOIData(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          _oiLack,
          style: _getTextStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,_oiPerChng),
        ),
        const SizedBox(height: 3),
        Text(
          "(${_oiPerChng == "NaN" ? "0.00" : _oiPerChng}%)",
          style: _getPercentageStyle(_oiPerChng),
        ),
      ],
    );
  }

  Widget _buildPriceData(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          _lp,
          style: _getTextStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,_perChange),
        ),
        const SizedBox(height: 3),
        Text(
          "(${_perChange}%)",
          style: _getPercentageStyle(_perChange),
        ),
      ],
    );
  }

  void _symbolenotFound(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(warningMessage(context, "Scrip Not founded"));
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
    Navigator.pop(context);
    await scripData.calldepthApis(context, depthArgs, "");
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

  static TextStyle _getTextStyle(Color color, String perChange) {
    // return _textStyleCache.putIfAbsent(
    //   color,
      // () {
        Color color = colors.textSecondaryLight;
        if (perChange != "0.00") {
          color = perChange.startsWith("-") ? colors.error : colors.profitLight;
        }
        return TextWidget.textStyle(fontSize: 14, color: color, theme: false,);
      // },
    // );
  }

  static TextStyle _getPercentageStyle(String? value) {
    final key = value ?? "0.00";
    // return _percentageStyleCache.putIfAbsent(
    //   key,
    //   () {
        Color color = colors.textSecondaryLight;
        // if (value != null && value != "0.00") {
        //   color = value.startsWith("-") ? colors.darkred : colors.ltpgreen;
        // } 
        return TextWidget.textStyle(
            fontSize: 12, color: color, theme: false, );
    //   },
    // );
  }
}

Future<void> placeOrderInput(
  MarketWatchProvider scripInfo,
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
  OrderScreenArgs orderArgs = OrderScreenArgs(
    exchange: depthData.exch.toString(),
    tSym: depthData.tsym.toString(),
    isExit: false,
    token: depthData.token.toString(),
    transType: transType,
    lotSize: depthData.ls,
    ltp: "${depthData.lp ?? depthData.close ?? 0.00}",
    perChange: depthData.perChange ?? "0.00",
    orderTpye: '',
    holdQty: '',
    isModify: false,
    raw: {},
  );
  Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
    "orderArg": orderArgs,
    "scripInfo": container.read(marketWatchProvider).scripInfoModel!,
    "isBskt": "",
  });
}
