import 'dart:async';

import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../locator/constant.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
 
import '../../../res/res.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../routes/route_names.dart';
import '../../../utils/responsive_navigation.dart';
import '../../web/order/quick_order_screen_web.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../Mobile/market_watch/futures/future_screen.dart';
import '../../Mobile/market_watch/over_view/funtamental_data_widget.dart';
import 'set_alert_web.dart';

class ScripDepthInfoWeb extends ConsumerStatefulWidget {
  final DepthInputArgs wlValue;
  final String isBasket;

  const ScripDepthInfoWeb({
    super.key,
    required this.wlValue,
    required this.isBasket,
  });

  @override
  ConsumerState<ScripDepthInfoWeb> createState() => _ScripDepthInfoWebState();
}

class _ScripDepthInfoWebState extends ConsumerState<ScripDepthInfoWeb>
    with AutomaticKeepAliveClientMixin {
  // IMPORTANT: initSize must always be >= 0.29 to satisfy DraggableScrollableSheet constraint
  // minChildSize = 0.28, so initialChildSize must be >= minChildSize
  // For Overview state, initSize is calculated dynamically to show only the header section
  double initSize = 0.95;
  ChartArgs? chartArgs;
  String regtoken = "";
  bool _isDisposed = false;
  

  // Cache for text styles
  static final Map<String, TextStyle> _textStyleCache = {};
  static final Map<String, TextStyle> _titleStyleCache = {};
  static final Map<String, TextStyle> _valueStyleCache = {};

  @override
  bool get wantKeepAlive => true; // Keep the state alive when navigating

  // Memoized text styles
  TextStyle _getTextStyle(Color color, double size, [int? fw]) {
    final key = '${color.value}_${size}_${fw ?? "null"}';
    return _textStyleCache.putIfAbsent(
      key,
      () => WebTextStyles.custom(
        fontSize: size,
        isDarkTheme: true,
        color: color,
        fontWeight: fw == 0
            ? WebFonts.regular
            : fw == 1
                ? WebFonts.medium
                : fw == 2
                    ? WebFonts.semiBold
                    : fw == 3
                        ? WebFonts.bold
                        : WebFonts.regular,
        letterSpacing: 0.0,
      ),
    );
  }

  TextStyle _getTitleStyle(Color color) {
    final key = '${color.value}_title';
    return _titleStyleCache.putIfAbsent(
      key,
      () => WebTextStyles.para(
        isDarkTheme: true,
        color: color,
        fontWeight: WebFonts.regular,
        letterSpacing: 0.0,
      ),
    );
  }

  TextStyle _getValueStyle(Color color) {
    final key = '${color.value}_value';
    return _valueStyleCache.putIfAbsent(
      key,
      () => WebTextStyles.sub(
        isDarkTheme: true,
        color: color,
        fontWeight: WebFonts.regular,
        letterSpacing: 0.0,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    regtoken = widget.wlValue.token;
    _initializeSize();

    // Initialize state in a microtask to avoid build/layout conflicts
    Future.microtask(() {
      if (!_isDisposed) {
        ref.read(marketWatchProvider).chngDephBtn("Overview");

        // Reset futures expansion state when opening a new scrip
        if (ref.read(marketWatchProvider).isFuturesExpanded) {
          ref.read(marketWatchProvider).toggleFuturesExpansion();
        }

        FirebaseAnalytics.instance.logScreenView(
          screenName: 'Stock details',
          screenClass: 'ScripDepthInfo',
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant ScripDepthInfoWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the selected scrip changes, update token and reset relevant state
    if (oldWidget.wlValue.token != widget.wlValue.token ||
        oldWidget.wlValue.exch != widget.wlValue.exch) {
      regtoken = widget.wlValue.token;
      // Ensure Overview state and safe initial size for the new scrip
      Future.microtask(() async {
        if (!_isDisposed) {
          await ref.read(marketWatchProvider).chngDephBtn("Overview");
          setState(() {
            initSize = _getSafeInitialSize(0.35);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Helper method to calculate safe initial size
  double _getSafeInitialSize(double desiredSize) {
    // Ensure minSize is always > minChildSize (0.28) with proper buffer
    double minSize = 0.29;
    double safeSize = desiredSize < minSize ? minSize : desiredSize;

    // Double-check that the result is safe for DraggableScrollableSheet
    if (safeSize < 0.29) {
      safeSize = 0.29;
    }

    return safeSize;
  }

  // Calculate dynamic initial size based on content height
  double _calculateDynamicInitialSize(BuildContext context) {
    if (ref.read(marketWatchProvider).actDeptBtn != "Overview" ||
        ref.read(marketWatchProvider).scripsize == true) {
      return 0.75;
    }

    // Calculate the height needed for the header section (up to Chart and Options buttons)
    // This includes: CustomDragHandler + symbol info + buy/sell buttons + Chart/Options buttons
    double headerHeight = 0;

    // CustomDragHandler height
    headerHeight += 24; // Approximate height of drag handler

    // Symbol info section height
    headerHeight += 80; // Symbol text + price + change info

    // Buy/Sell buttons height
    headerHeight += 45; // Button height

    // Dividers
    headerHeight += 32; // Two dividers

    // Chart/Options buttons section
    headerHeight += 52; // Buttons with padding

    // Additional padding and margins
    headerHeight += 32; // Extra padding

    // Convert to screen height percentage
    double screenHeight = MediaQuery.of(context).size.height;
    double initialSize = headerHeight / screenHeight;

    // Ensure it's within bounds
    initialSize = initialSize.clamp(0.29, 0.99);

    return initialSize;
  }

  void _initializeSize() {
    setState(() {
      // For non-Overview states, use larger size
      if (ref.read(marketWatchProvider).actDeptBtn != "Overview" ||
          ref.read(marketWatchProvider).scripsize == true) {
        initSize = 0.75;
      } else {
        // For Overview state, we'll calculate this dynamically in build method
        // based on the actual content height of the header section
        initSize = 0.35; // This will be overridden in build method
      }

      // Ensure initSize is never less than minChildSize + buffer
      if (initSize < 0.29) {
        initSize = 0.29;
      }

      chartArgs = ChartArgs(
        exch: widget.wlValue.exch,
        tsym: widget.wlValue.tsym,
        token: widget.wlValue.token,
      );
    });
  }

  // Preprocess depth data
  void _processDepthData(GetQuotes depthData, Map<String, dynamic> socketData) {
    depthData.ap = "${socketData['ap']}";
    depthData.lp = "${socketData['lp']}";
    depthData.pc = "${socketData['pc']}";
    depthData.o = "${socketData['o']}";
    depthData.l = "${socketData['l']}";
    depthData.c = "${socketData['c']}";
    depthData.chng = "${socketData['chng']}";
    depthData.h = "${socketData['h']}";
    depthData.poi = "${socketData['poi']}";
    depthData.v = "${socketData['v']}";
    depthData.toi = "${socketData['toi']}";
    depthData.sp1 = "${socketData['sp1']}";
    depthData.sp2 = "${socketData['sp2']}";
    depthData.sp3 = "${socketData['sp3']}";
    depthData.sp4 = "${socketData['sp4']}";
    depthData.sp5 = "${socketData['sp5']}";
    depthData.bp1 = "${socketData['bp1']}";
    depthData.bp2 = "${socketData['bp2']}";
    depthData.bp3 = "${socketData['bp3']}";
    depthData.bp4 = "${socketData['bp4']}";
    depthData.bp5 = "${socketData['bp5']}";
    depthData.sq1 = "${socketData['sq1']}";
    depthData.sq2 = "${socketData['sq2']}";
    depthData.sq3 = "${socketData['sq3']}";
    depthData.sq4 = "${socketData['sq4']}";
    depthData.sq5 = "${socketData['sq5']}";
    depthData.bq1 = "${socketData['bq1']}";
    depthData.bq2 = "${socketData['bq2']}";
    depthData.bq3 = "${socketData['bq3']}";
    depthData.bq4 = "${socketData['bq4']}";
    depthData.bq5 = "${socketData['bq5']}";
    depthData.tbq = "${socketData['tbq']}";
    depthData.tsq = "${socketData['tsq']}";
    depthData.wk52H = "${socketData['52h']}";
    depthData.wk52L = "${socketData['52l']}";
    depthData.lc = "${socketData['lc']}";
    depthData.uc = "${socketData['uc']}";
    depthData.ltq = "${socketData['ltq']}";
    depthData.ltt = "${socketData['ltt']}";
    depthData.ft = "${socketData['ft']}";
  }

  // Memoized row builder
  Widget _buildInfoRow(String title1, String value1, String title2,
      String value2, ThemesProvider theme) {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title1, style: _getTitleStyle(WebDarkColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value1,
                style: _getValueStyle(theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary)),
            const SizedBox(height: 4),
            Divider(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider)
          ],
        ),
      ),
      const SizedBox(width: 24),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title2, style: _getTitleStyle(WebDarkColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value2,
                style: _getValueStyle(theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary)),
            const SizedBox(height: 4),
            Divider(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider)
          ],
        ),
      )
    ]);
  }

  //new ui

  Widget _buildInfoRow1(
      String title1,
      String value1,
      String title2,
      String value2,
      String title3,
      String value3,
      String title4,
      String value4,
      ThemesProvider theme) {
    // Helper function to build a column or empty space
    Widget buildColumn(String title, String value, bool isEmpty) {
      if (isEmpty) {
        return Expanded(child: SizedBox.shrink());
      }
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: _getTitleStyle(theme.isDarkMode
                    ? WebDarkColors.textSecondary
                    : WebColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value,
                style: _getValueStyle(theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary)),
            const SizedBox(height: 4),
            Divider(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider)
          ],
        ),
      );
    }

    // Check if columns are empty
    bool isCol1Empty = title1.isEmpty && value1.isEmpty;
    bool isCol2Empty = title2.isEmpty && value2.isEmpty;
    bool isCol3Empty = title3.isEmpty && value3.isEmpty;
    bool isCol4Empty = title4.isEmpty && value4.isEmpty;

    List<Widget> columns = [];

    // Add non-empty columns with appropriate spacing
    if (!isCol1Empty) {
      columns.add(buildColumn(title1, value1, false));
      if (!isCol2Empty || !isCol3Empty || !isCol4Empty) {
        columns.add(const SizedBox(width: 12));
      }
    }

    if (!isCol2Empty) {
      columns.add(buildColumn(title2, value2, false));
      if (!isCol3Empty || !isCol4Empty) {
        columns.add(const SizedBox(width: 12));
      }
    }

    if (!isCol3Empty) {
      columns.add(buildColumn(title3, value3, false));
      if (!isCol4Empty) {
        columns.add(const SizedBox(width: 12));
      }
    }

    if (!isCol4Empty) {
      columns.add(buildColumn(title4, value4, false));
    }

    return Row(children: columns);
  }

  // Memoized depth percentage builder
  Widget _buildDepthPercentage(String qty, String price, bool isBuy,
      MarketWatchProvider scripInfo, ThemesProvider theme) {
    final maxQty = isBuy ? scripInfo.maxBuyQty : scripInfo.maxSellQty;
    final barPercentage =
        (((int.tryParse(qty) ?? 0) / maxQty) * 100 / 100).clamp(0.0, 1.0);
    final color = isBuy ? WebDarkColors.success : WebDarkColors.error;

    return Stack(children: [
      Transform.flip(
        flipX: !isBuy,
        child: LinearPercentIndicator(
          lineHeight: 20.0,
          backgroundColor:
              !theme.isDarkMode ? WebColors.surface : WebDarkColors.surface,
          percent: barPercentage,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          progressColor: color.withOpacity(.2),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 1.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              " ${qty != "null" ? qty : '0'} ",
              style: _getTextStyle(
                  theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  13,
                  0),
            ),
            Text(
              " ${price != "null" ? price : '0.00'} ",
              style: _getTextStyle(
                  theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  13,
                  0),
            ),
          ],
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RepaintBoundary(
      child: PopScope(
          canPop: true, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return; // If system handled back, do nothing

            await ref.read(marketWatchProvider).chngDephBtn("Overview");

            // Initialize and cancel the timer
            ConstantName.charttimer =
                Timer.periodic(const Duration(milliseconds: 0), (timer) {});
            ConstantName.charttimer!.cancel();

            await ref
                .read(marketWatchProvider)
                .requestWSOptChain(context: context, isSubscribe: false);

            await ref.read(websocketProvider).establishConnection(
                  channelInput:
                      "${widget.wlValue.exch}|${widget.wlValue.token}",
                  task: "ud",
                  context: context,
                );

            if (ref.read(marketWatchProvider).actDeptBtn == "Chart") {
              // Additional logic if needed
            }

            Navigator.of(context).pop(); // Proceed with back navigation
          },
          child: SafeArea(
            child: Consumer(builder: (context, WidgetRef ref, _) {
              final depthData = ref.watch(marketWatchProvider).getQuotes!;
              final scripInfo = ref.watch(marketWatchProvider);
              final theme = ref.read(themeProvider);
              

              return StreamBuilder<Map>(
                  stream: ref.watch(websocketProvider).socketDataStream,
                  builder: (context, snapshot) {
                    final socketDatas = snapshot.data ?? {};

                    // Update depth data with WebSocket data if available
                    if (socketDatas.containsKey(regtoken)) {
                      _processDepthData(depthData, socketDatas[regtoken]);

                      if (scripInfo.actDeptBtn == "Overview") {
                        if ((depthData.exch == "NSE" ||
                                depthData.exch == "BSE") &&
                            (depthData.instname != "UNDIND")) {
                          scripInfo.techDataCalc("${depthData.lp}");
                        }
                        if (widget.wlValue.instname != "UNDIND" &&
                            widget.wlValue.instname != "COM") {
                          scripInfo.scripQtyCal();
                        }
                      }
                    }

                    // Calculate dynamic initial size for Overview state
                    if (scripInfo.actDeptBtn == "Overview") {
                      initSize = _calculateDynamicInitialSize(context);
                    }

                    // Ensure initSize is safe before building DraggableScrollableSheet
                    if (initSize < 0.29) {
                      initSize = 0.29;
                    }
                    return Scaffold(
                      body: Container(
                        decoration: BoxDecoration(
                               color: theme.isDarkMode
                              ? WebDarkColors.background
                              : WebColors.background,                        

                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.zero,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      
                                              Container(),
                                              /*
                                      Symbol and price section (temporarily commented)
                                      Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                            color: theme.isDarkMode
                                                ? WebDarkColors.background
                                                : WebColors.background,
                                            boxShadow: _hasScrolled
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 14),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          // ... symbol, info icon, ltp, change ...
                                                        ])),
                                      */
                              
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16),
                                                child: Column(children: [
                                                  // Row(
                                                  //     mainAxisAlignment:
                                                  //         MainAxisAlignment
                                                  //             .spaceBetween,
                                                  //     children: [
                                                  //       Row(children: [
                                                  //         // CustomExchBadge(
                                                  //         //     exch: widget
                                                  //         //         .wlValue
                                                  //         //         .exch),
                                                  //         // Text(
                                                  //         //     "  ${widget.wlValue.expDate}",
                                                  //         //     style: textStyle(
                                                  //         //         !theme.isDarkMode
                                                  //         //             ? colors
                                                  //         //                 .colorBlack
                                                  //         //             : colors
                                                  //         //                 .colorWhite,
                                                  //         //         12,
                                                  //         //         FontWeight
                                                  //         //             .w600)),
                                                  //         // SizedBox(
                                                  //         //   width: 4,
                                                  //         // ),
                                                  //         TextWidget.paraText(
                                                  //             text: "${(double.tryParse(depthData.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(depthData.pc ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                                                  //             color:  !theme.isDarkMode
                                                  //                     ? colors
                                                  //                         .colorBlack
                                                  //                     : colors
                                                  //                         .colorWhite,
                                                  //             theme: theme.isDarkMode,
                                                  //             fw: 3)
                                                  //       ]),
                                                  //     ]),
                                                  /*
                                                    if (!scripInfo.scripDepthloader &&
                                                        widget.wlValue.instname !=
                                                            "UNDIND" &&
                                                        widget.wlValue.instname !=
                                                            "COM")
                                                      scripInfo.actDeptBtn ==
                                                              "Set Alert"
                                                          ? Container()
                                                          : Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal: 0,
                                                                      vertical: 16),
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                        child:
                                                                            InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        await placeOrderInput(
                                                                            scripInfo,
                                                                            context,
                                                                            depthData,
                                                                            true);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height: 45,
                                                                        decoration: BoxDecoration(
                                                                            color: theme.isDarkMode
                                                                                ? WebDarkColors
                                                                                    .primary
                                                                                : WebColors
                                                                                    .primary,
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                                    5)),
                                                                        child: Center(
                                                                            child: Text(
                                                                                "Buy",
                                                                                style: WebTextStyles.sub(
                                                                                    isDarkTheme: theme.isDarkMode,
                                                                                    color: WebDarkColors.textPrimary,
                                                                                    fontWeight: WebFonts.semiBold,
                                                                                    letterSpacing: 0.0))),
                                                                      ),
                                                                    )),
                                                                    const SizedBox(
                                                                        width: 16),
                                                                    Expanded(
                                                                      child: InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            await placeOrderInput(
                                                                                scripInfo,
                                                                                context,
                                                                                depthData,
                                                                                false);
                                                                          },
                                                                          child: Container(
                                                                              height:
                                                                                  45,
                                                                              decoration: BoxDecoration(
                                                                                  color: WebDarkColors
                                                                                      .error,
                                                                                  borderRadius: BorderRadius.circular(
                                                                                      5)),
                                                                              child: Center(
                                                                                  child:
                                                                                      Text("Sell", style: WebTextStyles.sub(isDarkTheme: theme.isDarkMode, color: WebDarkColors.textPrimary, fontWeight: WebFonts.semiBold, letterSpacing: 0.0))))),
                                                                    ),
                                                                  ])),
                              
                                                    if (!scripInfo.scripDepthloader &&
                                                        widget.wlValue.instname !=
                                                            "UNDIND" &&
                                                        widget.wlValue.instname !=
                                                            "COM")
                                                      const ListDivider(),
                                                    if (!scripInfo.scripDepthloader &&
                                                        widget.wlValue.instname !=
                                                            "UNDIND" &&
                                                        widget.wlValue.instname !=
                                                            "COM")
                                                      const ListDivider(),
                                                    */
                                                  // Chart button above tabs - Now in Column layout
                                                  // Container(
                                                  //     padding: const EdgeInsets
                                                  //         .symmetric(
                                                  //         horizontal: 14,
                                                  //         vertical: 8),
                                                  //     child: Column(
                                                  //         crossAxisAlignment:
                                                  //             CrossAxisAlignment
                                                  //                 .stretch,
                                                  //         children: [
                              
                                                  //           if (scripInfo
                                                  //               .getOptionawait(
                                                  //                   widget.wlValue
                                                  //                       .exch,
                                                  //                   widget.wlValue
                                                  //                       .token))
                                                  //             const SizedBox(
                                                  //                 height: 8),
                              
                                                  //           // Future Button (conditional)
                                                  //           if (scripInfo
                                                  //               .getOptionawait(
                                                  //                   widget.wlValue
                                                  //                       .exch,
                                                  //                   widget.wlValue
                                                  //                       .token))
                                                  //             InkWell(
                                                  //               onTap: () async {
                                                  //                 scripInfo
                                                  //                     .singlePageloader(
                                                  //                         true);
                              
                                                  //                 await scripInfo.requestWSFut(
                                                  //                     context:
                                                  //                         context,
                                                  //                     isSubscribe:
                                                  //                         true);
                              
                                                  //                 if (mounted) {
                                                  //                   await Navigator
                                                  //                       .pushNamed(
                                                  //                           context,
                                                  //                           Routes
                                                  //                               .futureScreen,
                                                  //                           arguments: {
                                                  //                         "depthdata":
                                                  //                             depthData,
                                                  //                         "wlvalue":
                                                  //                             widget
                                                  //                                 .wlValue
                                                  //                       });
                                                  //                 }
                              
                                                  //                 scripInfo
                                                  //                     .singlePageloader(
                                                  //                         false);
                                                  //               },
                                                  //               child: Container(
                                                  //                 height: 36,
                                                  //                 decoration: BoxDecoration(
                                                  //                     color: theme
                                                  //                             .isDarkMode
                                                  //                         ? const Color(
                                                  //                                 0xffB5C0CF)
                                                  //                             .withOpacity(
                                                  //                                 .15)
                                                  //                         : const Color(
                                                  //                             0xffF1F3F8),
                                                  //                     borderRadius:
                                                  //                         BorderRadius
                                                  //                             .circular(
                                                  //                                 8)),
                                                  //                 child: Row(
                                                  //                   mainAxisAlignment:
                                                  //                       MainAxisAlignment
                                                  //                           .center,
                                                  //                   children: [
                                                  //                     SvgPicture
                                                  //                         .asset(
                                                  //                       assets
                                                  //                           .optChainIcon,
                                                  //                       color: theme.isDarkMode
                                                  //                           ? colors
                                                  //                               .colorWhite
                                                  //                           : colors
                                                  //                               .colorBlack,
                                                  //                       width: 16,
                                                  //                       height: 16,
                                                  //                     ),
                                                  //                     const SizedBox(
                                                  //                         width: 6),
                                                  //                     Text(
                                                  //                       "Future",
                                                  //                       style: textStyle(
                                                  //                           theme.isDarkMode
                                                  //                               ? colors
                                                  //                                   .colorWhite
                                                  //                               : colors
                                                  //                                   .colorBlack,
                                                  //                           13,
                                                  //                           FontWeight
                                                  //                               .w500),
                                                  //                     ),
                                                  //                   ],
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                              
                                                  //           if (scripInfo
                                                  //               .getOptionawait(
                                                  //                   widget.wlValue
                                                  //                       .exch,
                                                  //                   widget.wlValue
                                                  //                       .token))
                                                  //             const SizedBox(
                                                  //                 height: 8),
                              
                                                  //           // Fundamental Button (conditional)
                                                  //           if (widget.wlValue
                                                  //                       .exch ==
                                                  //                   'NSE' ||
                                                  //               widget.wlValue
                                                  //                       .exch ==
                                                  //                   'BSE')
                                                  //             InkWell(
                                                  //               onTap: () async {
                                                  //                 if (_isDisposed)
                                                  //                   return;
                              
                                                  //                 scripInfo
                                                  //                     .singlePageloader(
                                                  //                         true);
                              
                                                  //                 try {
                                                  //                   // Pre-fetch data before navigation
                                                  //                   if (scripInfo
                                                  //                               .fundamentalData ==
                                                  //                           null ||
                                                  //                       scripInfo
                                                  //                               .fundamentalData
                                                  //                               ?.msg ==
                                                  //                           "no data found") {
                                                  //                     await scripInfo
                                                  //                         .fetchFundamentalData(
                                                  //                             tradeSym:
                                                  //                                 "${widget.wlValue.exch}:${widget.wlValue.tsym}");
                                                  //                   }
                              
                                                  //                   if (!mounted)
                                                  //                     return;
                              
                                                  //                   if (scripInfo
                                                  //                               .fundamentalData !=
                                                  //                           null &&
                                                  //                       scripInfo
                                                  //                               .fundamentalData
                                                  //                               ?.msg !=
                                                  //                           "no data found") {
                                                  //                     // Reset state before navigation
                                                  //                     await scripInfo
                                                  //                         .chngDephBtn(
                                                  //                             "Overview");
                              
                                                  //                     await Navigator
                                                  //                         .pushNamed(
                                                  //                       context,
                                                  //                       Routes
                                                  //                           .fundamentalDetail,
                                                  //                       arguments: {
                                                  //                         "wlValue":
                                                  //                             widget
                                                  //                                 .wlValue,
                                                  //                         "depthData":
                                                  //                             depthData,
                                                  //                       },
                                                  //                     );
                              
                                                  //                     // Reset state after navigation
                                                  //                     if (mounted &&
                                                  //                         !_isDisposed) {
                                                  //                       await scripInfo
                                                  //                           .chngDephBtn(
                                                  //                               "Overview");
                                                  //                     }
                                                  //                   } else {
                                                  //                     if (!mounted)
                                                  //                       return;
                                                  //                     ScaffoldMessenger.of(
                                                  //                             context)
                                                  //                         .showSnackBar(
                                                  //                       const SnackBar(
                                                  //                         content: Text(
                                                  //                             'No fundamental data available'),
                                                  //                         duration: Duration(
                                                  //                             seconds:
                                                  //                                 2),
                                                  //                       ),
                                                  //                     );
                                                  //                   }
                                                  //                 } finally {
                                                  //                   if (mounted &&
                                                  //                       !_isDisposed) {
                                                  //                     scripInfo
                                                  //                         .singlePageloader(
                                                  //                             false);
                                                  //                   }
                                                  //                 }
                                                  //               },
                                                  //               child: Container(
                                                  //                 height: 36,
                                                  //                 decoration: BoxDecoration(
                                                  //                     color: theme
                                                  //                             .isDarkMode
                                                  //                         ? const Color(
                                                  //                                 0xffB5C0CF)
                                                  //                             .withOpacity(
                                                  //                                 .15)
                                                  //                         : const Color(
                                                  //                             0xffF1F3F8),
                                                  //                     borderRadius:
                                                  //                         BorderRadius
                                                  //                             .circular(
                                                  //                                 8)),
                                                  //                 child: Row(
                                                  //                   mainAxisAlignment:
                                                  //                       MainAxisAlignment
                                                  //                           .center,
                                                  //                   children: [
                                                  //                     SvgPicture
                                                  //                         .asset(
                                                  //                       assets
                                                  //                           .dInfo,
                                                  //                       color: theme.isDarkMode
                                                  //                           ? colors
                                                  //                               .colorWhite
                                                  //                           : colors
                                                  //                               .colorBlack,
                                                  //                       width: 16,
                                                  //                       height: 16,
                                                  //                     ),
                                                  //                     const SizedBox(
                                                  //                         width: 6),
                                                  //                     Text(
                                                  //                       "Fundamental",
                                                  //                       style: textStyle(
                                                  //                           theme.isDarkMode
                                                  //                               ? colors
                                                  //                                   .colorWhite
                                                  //                               : colors
                                                  //                                   .colorBlack,
                                                  //                           13,
                                                  //                           FontWeight
                                                  //                               .w500),
                                                  //                     ),
                                                  //                   ],
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                              
                                                  //           if (widget.wlValue
                                                  //                       .exch ==
                                                  //                   'NSE' ||
                                                  //               widget.wlValue
                                                  //                       .exch ==
                                                  //                   'BSE')
                                                  //             const SizedBox(
                                                  //                 height: 8),
                              
                                                  //           // Set Alert Button
                                                  //         ])),
                              
                                                  // const SizedBox(height: 8),
                                                  // Container(
                                                  //     padding: const EdgeInsets.only(
                                                  //         left: 14, top: 8, bottom: 8),
                                                  //     height: 52,
                                                  //     decoration: BoxDecoration(
                                                  //         border: Border(
                                                  //             bottom: BorderSide(
                                                  //                 color: theme.isDarkMode
                                                  //                     ? colors
                                                  //                         .darkColorDivider
                                                  //                     : colors.colorDivider,
                                                  //                 width: 0),
                                                  //             top: BorderSide(
                                                  //                 color: theme.isDarkMode
                                                  //                     ? colors
                                                  //                         .darkColorDivider
                                                  //                     : colors.colorDivider,
                                                  //                 width: 0))),
                                                  //     child: ListView.separated(
                                                  //         scrollDirection: Axis.horizontal,
                                                  //         itemCount:
                                                  //             scripInfo.depthBtns.length,
                                                  //         itemBuilder: (BuildContext context,
                                                  //             int index) {
                                                  //           return ElevatedButton(
                                                  //               onPressed: () async {
                                                  //                 scripInfo
                                                  //                     .singlePageloader(true);
                              
                                                  //                 setState(() {
                                                  //                   initSize =
                                                  //                       scripInfo.depthBtns[
                                                  //                               index]
                                                  //                           [
                                                  //                           'btnName'] ==
                                                  //                       "Chart"
                                                  //                   ? .40
                                                  //                   : .99;
                              
                                                  //                   scripInfo.chngDephBtn(
                                                  //                       scripInfo.depthBtns[
                                                  //                               index]
                                                  //                           [
                                                  //                           'btnName']);
                                                  //                 });
                              
                                                  //                 if (scripInfo.depthBtns[
                                                  //                         index]['btnName'] ==
                                                  //                     "Chart") {
                                                  //                   Navigator.pop(context);
                              
                                                  //                   if (currentRouteName ==
                                                  //                       Routes.searchScrip) {
                                                  //                     scripInfo
                                                  //                         .requestMWScrip(
                                                  //                             context:
                                                  //                                 context,
                                                  //                             isSubscribe:
                                                  //                                 true);
                                                  //                     scripInfo.searchClear();
                                                  //                     scripInfo
                                                  //                         .setpageName("");
                                                  //                     Navigator.pop(context);
                                                  //                     currentRouteName =
                                                  //                         'homeScreen';
                                                  //                   }
                              
                                                  //                   userProfile
                                                  //                       .setChartdialog(true);
                              
                                                  //                   scripInfo.setChartScript(
                                                  //                       widget.wlValue.exch,
                                                  //                       widget.wlValue.token,
                                                  //                       widget.wlValue.tsym);
                                                  //                 } else if (scripInfo
                                                  //                             .depthBtns[
                                                  //                         index]['btnName'] ==
                                                  //                     "Option") {
                                                  //                   scripInfo
                                                  //                       .singlePageloader(
                                                  //                           true);
                              
                                                  //                   // First set up the option script data
                                                  //                   scripInfo.setOptionScript(
                                                  //                       context,
                                                  //                       widget.wlValue.exch,
                                                  //                       widget.wlValue.token,
                                                  //                       widget.wlValue.tsym);
                              
                                                  //                   // Wait a small amount of time to ensure data is processed
                                                  //                   await Future.delayed(const Duration(milliseconds: 100));
                              
                                                  //                   // Then navigate to the option chain screen
                                                  //                   if (mounted) {
                                                  //                   Navigator.pop(context);
                                                  //                   Navigator.pushNamed(
                                                  //                       context,
                                                  //                       Routes.optionChain,
                                                  //                       arguments:
                                                  //                           widget.wlValue);
                                                  //                   }
                                                  //                 } else if (scripInfo
                                                  //                             .depthBtns[
                                                  //                         index]['btnName'] ==
                                                  //                     "Future") {
                                                  //                   await scripInfo
                                                  //                       .requestWSFut(
                                                  //                           context: context,
                                                  //                           isSubscribe:
                                                  //                               true);
                                                  //                 } else if (scripInfo
                                                  //                         .actDeptBtn ==
                                                  //                     "Overview") {
                                                  //                   await ref.watch(
                                                  //                           websocketProvider)
                                                  //                       .establishConnection(
                                                  //                           channelInput:
                                                  //                               "${depthData.exch}|${depthData.token}",
                                                  //                           task: "d",
                                                  //                           context: context);
                                                  //                 } else if (scripInfo
                                                  //                         .actDeptBtn ==
                                                  //                     "Fundamental") {
                                                  //                   scripInfo.chngshareHold(
                                                  //                       "Promoter Holding");
                                                  //                 }
                              
                                                  //                 scripInfo.singlePageloader(
                                                  //                     false);
                                                  //               },
                                                  //               style:
                                                  //                   ElevatedButton.styleFrom(
                                                  //                       elevation: 0,
                                                  //                       padding: const EdgeInsets.symmetric(
                                                  //                           horizontal: 12,
                                                  //                           vertical: 0),
                                                  //                       backgroundColor: theme
                                                  //                               .isDarkMode
                                                  //                           ? scripInfo.actDeptBtn ==
                                                  //                                   scripInfo.depthBtns[index][
                                                  //                                       'btnName']
                                                  //                               ? colors
                                                  //                                   .colorbluegrey
                                                  //                               : const Color(
                                                  //                                       0xffB5C0CF)
                                                  //                                   .withOpacity(
                                                  //                                       .15)
                                                  //                           : scripInfo.actDeptBtn ==
                                                  //                                   scripInfo.depthBtns[index]
                                                  //                                       [
                                                  //                                       'btnName']
                                                  //                               ? const Color(
                                                  //                                   0xff000000)
                                                  //                               : const Color(
                                                  //                                   0xffF1F3F8),
                                                  //                       shape:
                                                  //                           const StadiumBorder()),
                                                  //               child: Row(children: [
                                                  //                 SvgPicture.asset(
                                                  //                   "${scripInfo.depthBtns[index]['imgPath']}",
                                                  //                   color: theme.isDarkMode
                                                  //                       ? Color(scripInfo
                                                  //                                   .actDeptBtn ==
                                                  //                               scripInfo.depthBtns[index]
                                                  //                                   [
                                                  //                                   'btnName']
                                                  //                           ? 0xff000000
                                                  //                           : 0xffffffff)
                                                  //                       : Color(scripInfo
                                                  //                                   .actDeptBtn ==
                                                  //                               scripInfo.depthBtns[index]
                                                  //                                   [
                                                  //                                   'btnName']
                                                  //                           ? 0xffffffff
                                                  //                           : 0xff000000),
                                                  //                 ),
                                                  //                 const SizedBox(width: 8),
                                                  //                 TextWidget.paraText(
                                                  //                     text: "${scripInfo.depthBtns[index]['btnName']}",
                                                  //                     color: theme.isDarkMode
                                                  //                             ? Color(scripInfo.actDeptBtn == scripInfo.depthBtns[index]['btnName']
                                                  //                                 ? 0xff000000
                                                  //                                 : 0xffffffff)
                                                  //                             : Color(scripInfo.actDeptBtn == scripInfo.depthBtns[index]['btnName']
                                                  //                                 ? 0xffffffff
                                                  //                                 : 0xff000000),
                                                  //                     theme: theme.isDarkMode,
                                                  //                     fw: 1)
                                                  //               ]));
                                                  //         },
                                                  //         separatorBuilder:
                                                  //             (BuildContext context,
                                                  //                 int index) {
                                                  //           return const SizedBox(width: 10);
                                                  //         })),
                                                ]),
                                              ),
                                            
                                    if (scripInfo.scripDepthloader)
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 120),
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    SizedBox.shrink(),
                                    /*
                                      Chart and Options buttons row (temporarily commented)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, bottom: 16),
                                        child: Row(
                                          children: [
                                            // Chart button ...
                                            // Options button ...
                                          ],
                                        ),
                                      ),
                                      */
                                    if (scripInfo.actDeptBtn == "Overview") ...[
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 2),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 4),
                              
                                                // Old 2-column layout - commented out
                                                // _buildInfoRow(
                                                //     "Open",
                                                //     "${depthData.o != "null" ? depthData.o ?? 0.00 : '0.00'}",
                                                //     "Close",
                                                //     "${depthData.c != "null" ? depthData.c ?? 0.00 : '0.00'}",
                                                //     theme),
                              
                                                // New 4-column layout
                                                _buildInfoRow1(
                                                    "Open",
                                                    "${depthData.o != "null" ? depthData.o ?? 0.00 : '0.00'}",
                                                    "High",
                                                    "${depthData.h != "null" ? depthData.h ?? 0.00 : '0.00'}",
                                                    "Low",
                                                    "${depthData.l != "null" ? depthData.l ?? 0.00 : '0.00'}",
                                                    "P.Close",
                                                    "${depthData.c != "null" ? depthData.c ?? 0.00 : '0.00'}",
                                                    theme),
                                                const SizedBox(height: 4),
                                                // Low-High section commented out since now included in 4-column layout above
                                                // if (depthData.l != "null" &&
                                                //     depthData.h !=
                                                //         "null" &&
                                                //     double.parse(depthData
                                                //             .h
                                                //             .toString()) >
                                                //         0 &&
                                                //     depthData.l !=
                                                //         depthData
                                                //             .h) ...[
                                                //   Text("Low - High",
                                                //       style: textStyle(
                                                //           const Color(
                                                //               0xff666666),
                                                //           12,
                                                //           FontWeight
                                                //               .w500)),
                                                //   const SizedBox(
                                                //       height: 4),
                                                //   lowHighBar(
                                                //       "${depthData.l ?? 0.00}",
                                                //       "${depthData.h ?? 0.00}",
                                                //       "${depthData.lp ?? depthData.c ?? 0.00}",
                                                //       theme),
                                                //   const SizedBox(
                                                //       height: 2),
                                                //   Divider(
                                                //       color: theme.isDarkMode
                                                //           ? colors
                                                //               .darkColorDivider
                                                //           : colors
                                                //               .colorDivider),
                                                // ] else ...[
                                                //   _buildInfoRow(
                                                //       "Low",
                                                //       "${depthData.l}",
                                                //       "High",
                                                //       "${depthData.h}",
                                                //       theme),
                                                // ],
                              
                                                // Keep the Low-High bar for visual representation
                                                // if (depthData.l != "null" &&
                                                //     depthData.h !=
                                                //         "null" &&
                                                //     double.parse(depthData
                                                //             .h
                                                //             .toString()) >
                                                //         0 &&
                                                //     depthData.l !=
                                                //         depthData
                                                //             .h) ...[
                                                //   Text("Low - High",
                                                //       style: textStyle(
                                                //           const Color(
                                                //               0xff666666),
                                                //           12,
                                                //           FontWeight
                                                //               .w500)),
                                                //   const SizedBox(
                                                //       height: 4),
                                                //   lowHighBar(
                                                //       "${depthData.l ?? 0.00}",
                                                //       "${depthData.h ?? 0.00}",
                                                //       "${depthData.lp ?? depthData.c ?? 0.00}",
                                                //       theme),
                                                //   const SizedBox(
                                                //       height: 2),
                                                //   Divider(
                                                //       color: theme.isDarkMode
                                                //           ? colors
                                                //               .darkColorDivider
                                                //           : colors
                                                //               .colorDivider),
                                                // ],
                                                // Removed old 52 WEEKS HIGH-LOW and DAILY PRICE RANGE section since it's now above
                                                if (widget.wlValue.instname !=
                                                        "UNDIND" &&
                                                    widget.wlValue.instname !=
                                                        "COM") ...[
                                                  // Center(
                                                  //   child: TextWidget.titleText(
                                                  //       text:
                                                  //           "Market Depth",
                                                  //       theme: theme
                                                  //           .isDarkMode,
                                                  //       fw: 1),
                                                  // ),
                                                  // const SizedBox(
                                                  //     height:
                                                  //         10),
                                                  Row(children: [
                                                    Expanded(
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Quantity",
                                                                  style: WebTextStyles
                                                                      .para(
                                                                    isDarkTheme: theme
                                                                        .isDarkMode,
                                                                    color: theme
                                                                            .isDarkMode
                                                                        ? WebDarkColors
                                                                            .textSecondary
                                                                        : WebColors
                                                                            .textSecondary,
                                                                    fontWeight:
                                                                        WebFonts
                                                                            .regular,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "Bid",
                                                                  style: WebTextStyles
                                                                      .para(
                                                                    isDarkTheme: theme
                                                                        .isDarkMode,
                                                                    color:
                                                                        WebDarkColors
                                                                            .secondary,
                                                                    fontWeight:
                                                                        WebFonts
                                                                            .regular,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                )
                                                              ]),
                                                          const SizedBox(height: 10),
                                                          _buildBidDepthPercentage(
                                                              "${depthData.bq1 ?? 0}",
                                                              "${depthData.bp1 ?? 0.00}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildBidDepthPercentage(
                                                              "${depthData.bq2 ?? 0}",
                                                              "${depthData.bp2 ?? 0.00}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildBidDepthPercentage(
                                                              "${depthData.bq3 ?? 0}",
                                                              "${depthData.bp3 ?? 0.00}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildBidDepthPercentage(
                                                              "${depthData.bq4 ?? 0}",
                                                              "${depthData.bp4 ?? 0.00}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildBidDepthPercentage(
                                                              "${depthData.bq5 ?? 0}",
                                                              "${depthData.bp5 ?? 0.00}",
                                                              scripInfo,
                                                              theme)
                                                        ])),
                                                    const SizedBox(width: 20),
                                                    Expanded(
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Ask",
                                                                  style: WebTextStyles
                                                                      .para(
                                                                    isDarkTheme: theme
                                                                        .isDarkMode,
                                                                    color: theme
                                                                            .isDarkMode
                                                                        ? WebDarkColors
                                                                            .error
                                                                        : WebColors
                                                                            .error,
                                                                    fontWeight:
                                                                        WebFonts
                                                                            .regular,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "Quantity",
                                                                  style: WebTextStyles
                                                                      .para(
                                                                    isDarkTheme: theme
                                                                        .isDarkMode,
                                                                    color: theme
                                                                            .isDarkMode
                                                                        ? WebDarkColors
                                                                            .textSecondary
                                                                        : WebColors
                                                                            .textSecondary,
                                                                    fontWeight:
                                                                        WebFonts
                                                                            .regular,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                )
                                                              ]),
                                                          const SizedBox(height: 10),
                                                          _buildAskDepthPercentage(
                                                              "${depthData.sp1 ?? 0.00}",
                                                              "${depthData.sq1 ?? 0}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildAskDepthPercentage(
                                                              "${depthData.sp2 ?? 0.00}",
                                                              "${depthData.sq2 ?? 0}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildAskDepthPercentage(
                                                              "${depthData.sp3 ?? 0.00}",
                                                              "${depthData.sq3 ?? 0}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildAskDepthPercentage(
                                                              "${depthData.sp4 ?? 0.00}",
                                                              "${depthData.sq4 ?? 0}",
                                                              scripInfo,
                                                              theme),
                                                          const SizedBox(height: 6),
                                                          _buildAskDepthPercentage(
                                                              "${depthData.sp5 ?? 0.00}",
                                                              "${depthData.sq5 ?? 0}",
                                                              scripInfo,
                                                              theme)
                                                        ]))
                                                  ]),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "${depthData.tbq != "null" ? depthData.tbq ?? 0 : '0'}",
                                                              style:
                                                                  WebTextStyles.sub(
                                                                isDarkTheme:
                                                                    theme.isDarkMode,
                                                                color: theme
                                                                        .isDarkMode
                                                                    ? WebDarkColors
                                                                        .textSecondary
                                                                    : WebColors
                                                                        .textSecondary,
                                                                fontWeight:
                                                                    WebFonts.regular,
                                                                letterSpacing: 0.0,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "(${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%)",
                                                              style:
                                                                  WebTextStyles.para(
                                                                isDarkTheme:
                                                                    theme.isDarkMode,
                                                                color: theme
                                                                        .isDarkMode
                                                                    ? WebDarkColors
                                                                        .textSecondary
                                                                    : WebColors
                                                                        .textSecondary,
                                                                fontWeight:
                                                                    WebFonts.regular,
                                                                letterSpacing: 0.0,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "(${scripInfo.totSellQtyPer.toStringAsFixed(2)}%)",
                                                              style:
                                                                  WebTextStyles.para(
                                                                isDarkTheme:
                                                                    theme.isDarkMode,
                                                                color: theme
                                                                        .isDarkMode
                                                                    ? WebDarkColors
                                                                        .textSecondary
                                                                    : WebColors
                                                                        .textSecondary,
                                                                fontWeight:
                                                                    WebFonts.regular,
                                                                letterSpacing: 0.0,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "${depthData.tsq != "null" ? depthData.tsq ?? 0 : '0'}",
                                                              style:
                                                                  WebTextStyles.sub(
                                                                isDarkTheme:
                                                                    theme.isDarkMode,
                                                                color: theme
                                                                        .isDarkMode
                                                                    ? WebDarkColors
                                                                        .textSecondary
                                                                    : WebColors
                                                                        .textSecondary,
                                                                fontWeight:
                                                                    WebFonts.regular,
                                                                letterSpacing: 0.0,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ]),
                              
                                                  (scripInfo.totBuyQtyPer
                                                                  .toStringAsFixed(
                                                                      2) ==
                                                              "0.00" &&
                                                          scripInfo.totSellQtyPer
                                                                  .toStringAsFixed(
                                                                      2) ==
                                                              "0.00")
                                                      ? const SizedBox()
                                                      : Column(
                                                          children: [
                                                            const SizedBox(
                                                                height: 10),
                                                            LinearPercentIndicator(
                              
                                                                // leading: Text(
                                                                //     "${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%",
                                                                //     style: textStyle(
                                                                //         theme.isDarkMode
                                                                //             ? colors
                                                                //                 .colorWhite
                                                                //             : colors
                                                                //                 .colorBlack,
                                                                //         14,
                                                                //         FontWeight
                                                                //             .w500)),
                                                                // trailing: Text(
                                                                //     "${scripInfo.totSellQtyPer.toStringAsFixed(2)}%",
                                                                //     style: textStyle(
                                                                //         theme.isDarkMode
                                                                //             ? colors
                                                                //                 .colorWhite
                                                                //             : colors
                                                                //                 .colorBlack,
                                                                //         14,
                                                                //         FontWeight
                                                                //             .w500)),
                                                                lineHeight: 5.0,
                                                                barRadius: const Radius
                                                                    .circular(
                                                                    4.0), // Half of lineHeight for capsule shape
                                                                backgroundColor: (scripInfo
                                                                                .totBuyQtyPer
                                                                                .toStringAsFixed(
                                                                                    2) ==
                                                                            "0.00" &&
                                                                        scripInfo
                                                                                .totSellQtyPer
                                                                                .toStringAsFixed(
                                                                                    2) ==
                                                                            "0.00")
                                                                    ? theme.isDarkMode
                                                                        ? WebDarkColors
                                                                            .textSecondary
                                                                        : WebColors
                                                                            .textSecondary
                                                                    : theme.isDarkMode
                                                                        ? WebDarkColors
                                                                            .error
                                                                        : WebColors
                                                                            .error,
                                                                percent: scripInfo
                                                                    .totBuyQtyPerChng,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal: 0),
                                                                progressColor: theme
                                                                        .isDarkMode
                                                                    ? WebDarkColors
                                                                        .primary
                                                                    : WebColors.primary),
                                                            const SizedBox(
                                                                height: 16),
                                                          ],
                                                        ),
                                                ],
                                                const SizedBox(height: 4),
                                                if ((widget.wlValue.instname !=
                                                        "UNDIND" &&
                                                    widget.wlValue.instname !=
                                                        "COM")) ...[
                                                  // 52 Weeks and Daily Price Range section
                              
                                                  // Original Avg Price, Volume and Circuit sections
                                                  data(
                                                      "Avg Price",
                                                      "${depthData.ap ?? 0.00}",
                                                      theme),
                                                  data(
                                                      "Volume",
                                                      "${depthData.v != "null" ? depthData.v ?? 0.00 : '0'}",
                                                      theme),
                                                  if (depthData.seg != "EQT") ...[
                                                    data(
                                                        "Open Interest - OI",
                                                        "${depthData.oi != "null" ? depthData.oi ?? 0.00 : '0'}",
                                                        theme),
                                                    data(
                                                        "Change in OI",
                                                        "${depthData.poi != "null" ? depthData.poi ?? 0.00 : '0'}",
                                                        theme),
                                                  ],
                                                  data(
                                                      "LTQ",
                                                      "${depthData.ltq != "null" ? depthData.ltq ?? 0.00 : '0'}",
                                                      theme),
                                                  data(
                                                      "LTT",
                                                      depthData.ltt != "null"
                                                          ? depthData.ltt ?? "--"
                                                          : "--",
                                                      theme),
                                                  data(
                                                      "52 Weeks High-Low",
                                                      "${(depthData.wk52H != "null" && depthData.wk52H != null) ? depthData.wk52H : 0.00} - ${(depthData.wk52L != "null" && depthData.wk52L != null) ? depthData.wk52L : 0.00}",
                                                      theme),
                                                  data(
                                                      "DPR",
                                                      "${depthData.uc != "null" ? depthData.uc ?? 0.00 : '0.00'} - ${depthData.lc != "null" ? depthData.lc ?? 0.00 : '0.00'}",
                                                      theme),
                                                  // if (depthData
                                                  //         .seg !=
                                                  //     "EQT") ...[
                                                  //   _buildInfoRow(
                                                  //       "Open Interest (OI)",
                                                  //       "${depthData.oi != "null" ? depthData.oi ?? 0.00 : '0'}",
                                                  //       "Change in OI",
                                                  //       "${depthData.poi != "null" ? depthData.poi ?? 0.00 : '0'}",
                                                  //       theme),
                                                  //   const SizedBox(
                                                  //       height:
                                                  //           4),
                                                  // ],
                                                  if (scripInfo.returnsGridview
                                                      .isNotEmpty) ...[
                                                    // TextWidget.titleText(
                                                    //     text:
                                                    //         "Returns",
                                                    //     theme: theme
                                                    //         .isDarkMode,
                                                    //     fw: 1),
                                                    const SizedBox(height: 16),
                                                    GridView.count(
                                                        crossAxisCount: 3,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        crossAxisSpacing: 12,
                                                        mainAxisSpacing: 10,
                                                        childAspectRatio: 1.8,
                                                        children: List.generate(
                                                            scripInfo.returnsGridview
                                                                .length, (index) {
                                                          return Container(
                                                              width: 120,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical: 7,
                                                                      horizontal: 8),
                                                              decoration: BoxDecoration(
                                                                  color: theme
                                                                          .isDarkMode
                                                                      ? WebDarkColors
                                                                          .surfaceVariant
                                                                      : WebColors
                                                                          .surfaceVariant,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                              child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      "${scripInfo.returnsGridview[index]['percent']}%",
                                                                      style:
                                                                          WebTextStyles
                                                                              .sub(
                                                                        isDarkTheme: theme
                                                                            .isDarkMode,
                                                                        color: scripInfo
                                                                                .returnsGridview[
                                                                                    index]
                                                                                    [
                                                                                    'percent']
                                                                                .toString()
                                                                                .startsWith(
                                                                                    "-")
                                                                            ? theme
                                                                                    .isDarkMode
                                                                                ? WebDarkColors
                                                                                    .error
                                                                                : WebColors
                                                                                    .error
                                                                            : theme
                                                                                    .isDarkMode
                                                                                ? WebDarkColors
                                                                                    .success
                                                                                : WebColors
                                                                                    .success,
                                                                        fontWeight:
                                                                            WebFonts
                                                                                .regular,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height: 4),
                                                                    Center(
                                                                        child: Text(
                                                                      "${scripInfo.returnsGridview[index]['duration']}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          WebTextStyles
                                                                              .para(
                                                                        isDarkTheme: theme
                                                                            .isDarkMode,
                                                                        color: theme
                                                                                .isDarkMode
                                                                            ? WebDarkColors
                                                                                .textSecondary
                                                                            : WebColors
                                                                                .textSecondary,
                                                                        fontWeight:
                                                                            WebFonts
                                                                                .regular,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                    ))
                                                                  ]));
                                                        })),
                                                    const SizedBox(height: 12),
                                                  ]
                                                ],
                              
                                                // Add spacing before the new sections
                                                // const SizedBox(
                                                //     height: 16),
                              
                                                // Futures Section (conditional)
                                                if (scripInfo.getOptionawait(
                                                    widget.wlValue.exch,
                                                    widget.wlValue.token))
                                                  _buildFuturesSection(
                                                      scripInfo, theme, depthData),
                              
                                                // Fundamentals Section (conditional)
                                                if (scripInfo.fundamentalData !=
                                                        null &&
                                                    scripInfo.fundamentalData?.msg !=
                                                        "no data found") ...[
                                                  _buildFundamentalsSection(
                                                      theme, depthData),
                                                ] else ...[
                                                  const SizedBox(),
                                                ]
                                              ]))
                                    ] else if (scripInfo.actDeptBtn ==
                                        "Fundamental") ...[
                                      if (ref
                                                  .read(marketWatchProvider)
                                                  .fundamentalData !=
                                              null &&
                                          ref
                                                  .read(marketWatchProvider)
                                                  .fundamentalData!
                                                  .msg
                                                  .toString() !=
                                              "no data found") ...[
                                        const SizedBox(height: 10),
                                        const FundamentalDataWidget(),
                                      ] else ...[
                                        const NoDataFound()
                                      ]
                                    ] else if (scripInfo.actDeptBtn == "Chart") ...[
                                      // ChartScreenWebView(
                                      //     chartArgs: chartArgs!, cHeight: 1.48)
                                    ] else if (scripInfo.actDeptBtn == "Future") ...[
                                      Container(
                                          padding:
                                              const EdgeInsets.symmetric(vertical: 3),
                                          decoration: BoxDecoration(
                                              color: const Color(0xffe3f2fd),
                                              borderRadius: BorderRadius.circular(6)),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(assets.dInfo,
                                                    color: WebDarkColors.primary),
                                                Text(
                                                  " Long press to add ${scripInfo.wlName}'s Watchlist",
                                                  style: WebTextStyles.para(
                                                    isDarkTheme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? WebDarkColors.iconSecondary
                                                        : WebColors.iconSecondary,
                                                    fontWeight: WebFonts.regular,
                                                    letterSpacing: 0.0,
                                                  ),
                                                )
                                              ])),
                                      const FutureScreen()
                                    ] else if (scripInfo.actDeptBtn ==
                                        "Set Alert") ...[
                                      // Set Alert is now shown as a dialog
                                      const SizedBox.shrink()
                                    ],
                                    if (!scripInfo.scripDepthloader)
                                      const SizedBox(height: 18),
                                  ]),
                                ),
                            ),
                            // Quick Order embedded below scrip info
                                      if (ref.read(marketWatchProvider).scripInfoModel != null)
                                        Expanded(
                                          flex: 1,
                                          child: Builder(builder: (context) {
                                            final lotSize = (ref.read(marketWatchProvider).scripInfoModel?.ls?.toString() ?? depthData.ls ?? "1");
                                            final orderArgs = OrderScreenArgs(
                                              exchange: widget.wlValue.exch,
                                              tSym: widget.wlValue.tsym,
                                              isExit: false,
                                              token: widget.wlValue.token,
                                              transType: true,
                                              lotSize: lotSize,
                                              ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
                                              perChange: depthData.pc ?? "0.00",
                                              orderTpye: '',
                                              holdQty: '',
                                              isModify: false,
                                              raw: {},
                                            );
                                            return QuickOrderScreenWeb(
                                              orderArg: orderArgs,
                                              scripInfo: ref.read(marketWatchProvider).scripInfoModel!,
                                              embedded: true,
                                            );
                                          }),
                                        ),
                          ],
                        ),
                      ),
                    );
                  });
            }),
          )),
    );
  }

  void _showSetAlertDialog(BuildContext context, GetQuotes depthData) {
    final theme = ref.read(themeProvider);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set Alert',
                        style: WebTextStyles.title(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SetAlertWeb(
                  depthdata: depthData,
                  wlvalue: widget.wlValue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    await ref.read(marketWatchProvider).fetchScripInfo(
        widget.wlValue.token, widget.wlValue.exch, context, true);

    // **FIX: Use lot size from scripInfoModel if in basket mode, otherwise use existing logic**
    final lotSize = widget.isBasket == "BasketMode"
        ? ref.read(marketWatchProvider).scripInfoModel?.ls?.toString() ??
            depthData.ls ??
            "1"
        : (depthData.ls?.isNotEmpty == true
            ? depthData.ls
            : ref.read(marketWatchProvider).scripInfoModel?.ls.toString());

    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: widget.wlValue.exch,
        tSym: widget.wlValue.tsym,
        isExit: false,
        token: widget.wlValue.token,
        transType: transType,
        lotSize: lotSize,
        ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
        perChange: depthData.pc ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});
    // Navigator.pop(ctx);
    ResponsiveNavigation.toPlaceOrderScreen(
      context: ctx,
      arguments: {
        "orderArg": orderArgs,
        "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
        "isBskt": widget.isBasket
      },
    );
  }

  Row lowHighBar(String low, String high, String value, ThemesProvider theme) {
    double? lowValue = double.tryParse(low);
    double? valueValue = double.tryParse(value);
    double? highValue = double.tryParse(high);

    double minValue = (lowValue != null && valueValue != null)
        ? (lowValue <= valueValue ? lowValue : valueValue)
        : 0.0; // Fallback if parsing fails

    double maxValue = (highValue != null && valueValue != null)
        ? (highValue >= valueValue ? highValue : valueValue)
        : 0.0; // Fallback if parsing fails

    List<double> valuesList =
        valueValue != null ? [valueValue] : [0.0]; // Fallback if parsing fails

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        low,
        style: WebTextStyles.sub(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.regular,
          letterSpacing: 0.0,
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width / 1.8,
        child: FlutterSlider(
          handlerHeight: 20,
          handlerWidth: 12,
          handler: FlutterSliderHandler(
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: theme.isDarkMode
                              ? const Color(0xffB0BEC5)
                              : const Color(0xff000000)),
                      child: const Center(
                          child: Text(
                        ' ',
                        style: TextStyle(
                          fontFamily: kIsWeb ? 'tenon' : null,
                          color: Colors.transparent,
                        ),
                      ))))),
          tooltip: FlutterSliderTooltip(
            disabled: true,
          ),
          trackBar: FlutterSliderTrackBar(
            inactiveDisabledTrackBarColor:
                const Color(0xff666666).withOpacity(.2),
            activeDisabledTrackBarColor: theme.isDarkMode
                ? const Color.fromARGB(255, 36, 35, 35).withOpacity(.2)
                : const Color.fromARGB(255, 247, 246, 246).withOpacity(.2),
            activeTrackBarHeight: 4,
            inactiveTrackBarHeight: 4,
          ),
          min: minValue,
          max: minValue == maxValue ? maxValue + 1 : maxValue,
          values: valuesList,
          onDragging: null,
          jump: false,
          disabled: true,
        ),
      ),
      Text(
        high,
        style: WebTextStyles.sub(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.regular,
          letterSpacing: 0.0,
        ),
      )
    ]);
  }

  // Ask side (Price on left, Qty on right)
  Widget _buildAskDepthPercentage(String price, String qty,
      MarketWatchProvider scripInfo, ThemesProvider theme) {
    return Stack(children: [
      // Transform.flip(
      //   flipX: true,
      //   child: LinearPercentIndicator(
      //     lineHeight: 20.0,
      //     backgroundColor:
      //         !theme.isDarkMode ? WebColors.surface : WebDarkColors.surface,
      //     percent: barPercentage,
      //     padding: const EdgeInsets.symmetric(horizontal: 0),
      //     progressColor: color.withOpacity(.2),
      //     // barRadius: const Radius.circular(10.0), // Half of lineHeight for capsule shape
      //   ),
      // ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              " ${price != "null" ? price : '0.00'} ",
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode ? WebDarkColors.error : WebColors.error,
                fontWeight: WebFonts.regular,
                letterSpacing: 0.0,
              ),
            ),
            Text(
              " ${qty != "null" ? qty : '0'} ",
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textSecondary
                    : WebColors.textSecondary,
                fontWeight: WebFonts.regular,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      )
    ]);
  }

  // Bid side (Qty on left, Price on right)
  Widget _buildBidDepthPercentage(String qty, String price,
      MarketWatchProvider scripInfo, ThemesProvider theme) {
    return Stack(children: [
      // LinearPercentIndicator(
      //   lineHeight: 20.0,
      //   backgroundColor:
      //       !theme.isDarkMode ? WebColors.surface : WebDarkColors.surface,
      //   percent: barPercentage,
      //   padding: const EdgeInsets.symmetric(horizontal: 0),
      //   progressColor: color.withOpacity(.2),
      //   // barRadius: const Radius.circular(4), // Half of lineHeight for capsule shape
      // ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              " ${qty != "null" ? qty : '0'} ",
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textSecondary
                    : WebColors.textSecondary,
                fontWeight: WebFonts.regular,
                letterSpacing: 0.0,
              ),
            ),
            Text(
              " ${price != "null" ? price : '0.00'} ",
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.secondary
                    : WebColors.secondary,
                fontWeight: WebFonts.regular,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      )
    ]);
  }

  // Futures navigation section
  Widget _buildFuturesSection(MarketWatchProvider scripInfo,
      ThemesProvider theme, GetQuotes depthData) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 150));
              await scripInfo.requestWSFut(context: context, isSubscribe: true);
              scripInfo.toggleFuturesExpansion();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Futures",
                        style: WebTextStyles.sub(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.regular,
                          letterSpacing: 0.0,
                        ),
                      ),
                      AnimatedRotation(
                        turns: scripInfo.isFuturesExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.chevron_right,
                          color: theme.isDarkMode
                              ? WebDarkColors.iconSecondary
                              : WebColors.iconSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        const ListDivider(),

        // Expandable Futures Content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: scripInfo.isFuturesExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListDivider(),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            assets.dInfo,
                            color: theme.isDarkMode
                                ? WebDarkColors.iconSecondary
                                : WebColors.iconSecondary,
                          ),
                          Text(
                            " Long press to add ${scripInfo.wlName}'s Watchlist",
                            style: WebTextStyles.para(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                              fontWeight: WebFonts.regular,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const FutureScreen(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Fundamentals navigation section
  Widget _buildFundamentalsSection(ThemesProvider theme, GetQuotes depthData) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (_isDisposed) return;

              await Future.delayed(const Duration(milliseconds: 150));
              final scripInfo = ref.read(marketWatchProvider);
              scripInfo.singlePageloader(true);

              try {
                if (scripInfo.fundamentalData == null ||
                    scripInfo.fundamentalData?.msg == "no data found") {
                  await scripInfo.fetchFundamentalData(
                      tradeSym:
                          "${widget.wlValue.exch}:${widget.wlValue.tsym}");
                }

                if (!mounted) return;

                if (scripInfo.fundamentalData != null &&
                    scripInfo.fundamentalData?.msg != "no data found") {
                  await scripInfo.chngDephBtn("Overview");
                  await Navigator.pushNamed(
                    context,
                    Routes.fundamentalDetail,
                    arguments: {
                      "wlValue": widget.wlValue,
                      "depthData": depthData,
                    },
                  );
                  if (mounted && !_isDisposed) {
                    await scripInfo.chngDephBtn("Overview");
                  }
                }
              } finally {
                if (mounted && !_isDisposed) {
                  scripInfo.singlePageloader(false);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fundamentals",
                        style: WebTextStyles.sub(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.regular,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.isDarkMode
                            ? WebDarkColors.iconSecondary
                            : WebColors.iconSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        const ListDivider(),
      ],
    );
  }

  // Add the data widget helper method
  Padding data(String name, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: WebTextStyles.sub(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                  fontWeight: WebFonts.regular,
                  letterSpacing: 0.0,
                ),
              ),
              Text(
                value,
                style: WebTextStyles.sub(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.regular,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          Divider(
              color:
                  theme.isDarkMode ? WebDarkColors.divider : WebColors.divider)
        ],
      ),
    );
  }
}
