import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/snack_bar.dart';

class OptChainPutList extends StatelessWidget {
  final List<OptionValues>? putData;
  final bool isPutUp;
  final SwipeActionController? swipe;

  const OptChainPutList({
    super.key,
    this.putData,
    this.swipe,
    required this.isPutUp,
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
        );
      },
    );
  }
}

class _OptionChainPutRow extends StatefulWidget {
  final OptionValues option;
  final SwipeActionController? swipe;
  final int index;

  const _OptionChainPutRow({
    Key? key,
    required this.option,
    this.swipe,
    required this.index,
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
  StreamSubscription? _subscription;
  bool _isListenerSetup = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current values from API data first
    _lp = widget.option.lp ?? widget.option.close ?? "0.00";
    _perChange = widget.option.perChange ?? "0.00";
    _oiLack = widget.option.oiLack ?? "0.00";
    _oiPerChng = widget.option.oiPerChng ?? "0.00";

    // Debug: Print initialization values
    print("=== PUT OPTION INIT DEBUG ===");
    print("Token: ${widget.option.token}");
    print("TSYM: ${widget.option.tsym}");
    print("API LTP: ${widget.option.lp}");
    print("API Close: ${widget.option.close}");
    print("Initialized _lp: $_lp");
    print("Initialized _perChange: $_perChange");
    print("=============================");

    // Don't set up the listener in initState - moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only set up the listener once
    if (!_isListenerSetup) {
      _initializeWithSocketData();
      _setupSocketListener();
      _isListenerSetup = true;
    }
  }

  void _initializeWithSocketData() {
    // Try to get current socket data for this token
    final provider = ProviderScope.containerOf(context).read(websocketProvider);
    final socketDatas = provider.socketDatas;
    
    if (socketDatas.containsKey(widget.option.token)) {
      final data = socketDatas[widget.option.token];
      if (data != null) {
        // Override with socket data if available and valid
        final socketLp = data['lp']?.toString();
        if (socketLp != null && socketLp != "null" && socketLp.isNotEmpty) {
          _lp = socketLp;
        }
        
        final socketPc = data['pc']?.toString();
        if (socketPc != null && socketPc != "null" && socketPc.isNotEmpty) {
          _perChange = socketPc;
        }
        
        print("=== PUT INIT WITH SOCKET ===");
        print("Token: ${widget.option.token}");
        print("Updated _lp: $_lp");
        print("Updated _perChange: $_perChange");
        print("===========================");
      }
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
        print("=== PUT SOCKET UPDATE ===");
        print("Token: ${widget.option.token}");
        print("Socket LTP: ${data['lp']}");
        print("Socket PC: ${data['pc']}");
        print("Current _lp: $_lp");
        print("Current _perChange: $_perChange");
        print("==========================");

        // Check if values actually changed before updating state
        bool needsUpdate = false;

        final newLp = data['lp']?.toString();
        if (newLp != null &&
            newLp != _lp &&
            newLp != "null" &&
            newLp.isNotEmpty) {
          _lp = newLp;
          needsUpdate = true;
          print("PUT LTP Updated: $_lp");
        }

        final newPc = data['pc']?.toString();
        if (newPc != null &&
            newPc != _perChange &&
            newPc != "null" &&
            newPc.isNotEmpty) {
          _perChange = newPc;
          needsUpdate = true;
          print("PUT PC Updated: $_perChange");
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
                : _handleTap(context, widget.option)
          },
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildPriceData(theme),
                ),
                _buildOIData(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceData(ThemesProvider theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _lp,
          style: _getTextStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
        ),
        const SizedBox(height: 3),
        Text(
          "(${_perChange}%)",
          style: _getPercentageStyle(_perChange),
        ),
      ],
    );
  }

  Widget _buildOIData(ThemesProvider theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _oiLack,
          style: _getTextStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
        ),
        const SizedBox(height: 3),
        Text(
          "(${_oiPerChng == "NaN" ? "0.00" : _oiPerChng}%)",
          style: _getPercentageStyle(_oiPerChng),
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
      () => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ).copyWith(color: color),
    );
  }

  static TextStyle _getTextStyle(Color color) {
    return _textStyleCache.putIfAbsent(
      color,
      () => const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ).copyWith(color: color),
    );
  }

  static TextStyle _getPercentageStyle(String? value) {
    final key = value ?? "0.00";
    return _percentageStyleCache.putIfAbsent(
      key,
      () {
        Color color = colors.ltpgrey;
        if (value != null && value != "0.00") {
          color = value.startsWith("-") ? colors.darkred : colors.ltpgreen;
        }
        return const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ).copyWith(color: color);
      },
    );
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
