import 'dart:async';

import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/routes/app_routes.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../provider/websocket_provider.dart';
import '../../locator/constant.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'futures/future_screen.dart';
import 'over_view/funtamental_data_widget.dart';
import 'scrip_detail_dialogue.dart';
import 'set_alert_screen.dart';
import './fundamental_detail_screen.dart';
import './set_alert_screen_new.dart';

class ScripDepthInfo extends ConsumerStatefulWidget {
  final DepthInputArgs wlValue;
  final String isBasket;

  const ScripDepthInfo({
    super.key,
    required this.wlValue,
    required this.isBasket,
  });

  @override
  ConsumerState<ScripDepthInfo> createState() => _ScripDepthInfoState();
}

class _ScripDepthInfoState extends ConsumerState<ScripDepthInfo>
    with AutomaticKeepAliveClientMixin {
  double initSize = 0.88;
  ChartArgs? chartArgs;
  String regtoken = "";
  bool _isDisposed = false;
  bool _hasScrolled = false;

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
      () => TextWidget.textStyle(
          fontSize: size, color: color, theme: false, fw: fw),
    );
  }

  TextStyle _getTitleStyle(Color color) {
    final key = '${color.value}_title';
    return _titleStyleCache.putIfAbsent(
      key,
      () => _getTextStyle(
        color,
        12,
      ),
    );
  }

  TextStyle _getValueStyle(Color color) {
    final key = '${color.value}_value';
    return _valueStyleCache.putIfAbsent(
      key,
      () => _getTextStyle(
        color,
        14,
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
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Helper method to calculate safe initial size
  double _getSafeInitialSize(double desiredSize) {
    double minSize = 0.05; // Updated to match new minChildSize
    return desiredSize < minSize ? minSize : desiredSize;
  }

  void _initializeSize() {
    setState(() {
      // Ensure initialChildSize is always >= minChildSize (0.05)
      initSize = (ref.read(marketWatchProvider).actDeptBtn != "Overview") ||
              ref.read(marketWatchProvider).scripsize == true
          ? 0.99
          : 0.28;

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
            Text(title1, style: _getTitleStyle(const Color(0xff666666))),
            const SizedBox(height: 4),
            Text(value1,
                style: _getValueStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
            const SizedBox(height: 4),
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider)
          ],
        ),
      ),
      const SizedBox(width: 24),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title2, style: _getTitleStyle(const Color(0xff666666))),
            const SizedBox(height: 4),
            Text(value2,
                style: _getValueStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
            const SizedBox(height: 4),
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider)
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
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight)),
            const SizedBox(height: 4),
            Text(value,
                style: _getValueStyle(theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight)),
            const SizedBox(height: 4),
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider)
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
    final color = isBuy ? colors.ltpgreen : colors.darkred;

    return Stack(children: [
      Transform.flip(
        flipX: !isBuy,
        child: LinearPercentIndicator(
          lineHeight: 20.0,
          backgroundColor:
              !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  13,
                  0),
            ),
            Text(
              " ${price != "null" ? price : '0.00'} ",
              style: _getTextStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
          child: Consumer(builder: (context, WidgetRef ref, _) {
            final depthData = ref.watch(marketWatchProvider).getQuotes!;
            final scripInfo = ref.watch(marketWatchProvider);
            final theme = ref.read(themeProvider);
            final userProfile = ref.watch(userProfileProvider);

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

                  return GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! > 500) {
                        // A fast enough downward swipe detected
                        Navigator.of(context).pop();
                      }
                    },
                    child: DraggableScrollableSheet(
                        initialChildSize: initSize,
                        minChildSize: 0.05,
                        maxChildSize: 0.99,
                        expand: false,
                        builder: (BuildContext ctx,
                            ScrollController scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0xff999999),
                                      blurRadius: 4.0,
                                      offset: Offset(2.0, 0.0))
                                ]),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      controller: scrollController,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            boxShadow: _hasScrolled
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
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
                                                const CustomDragHandler(),
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    TextWidget
                                                                        .titleText(
                                                                      text:
                                                                          "${widget.wlValue.symbol.replaceAll("-EQ", "").toUpperCase()} ${widget.wlValue.expDate} ${widget.wlValue.option} ${widget.wlValue.exch} ",
                                                                      color: theme.isDarkMode
                                                                          ? colors
                                                                              .textPrimaryDark
                                                                          : colors
                                                                              .textPrimaryLight,
                                                                      theme: theme
                                                                          .isDarkMode,
                                                                    ),
                                                                    Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      shape:
                                                                          const CircleBorder(),
                                                                      child: InkWell(
                                                                          customBorder: const CircleBorder(),
                                                                          splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight, // Customize as needed
                                                                          highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                                                                          onTap: () async {
                                                                            await scripInfo.fetchScripInfo(
                                                                                depthData.token!,
                                                                                depthData.exch!,
                                                                                ctx);
                                                                            if (scripInfo.scripInfoModel!.stat ==
                                                                                "Ok") {
                                                                              showModalBottomSheet(
                                                                                  backgroundColor: colors.colorBlack,
                                                                                  isScrollControlled: true,
                                                                                  useSafeArea: true,
                                                                                  isDismissible: true,
                                                                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return const ScripDetailDialogue();
                                                                                  });
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: SvgPicture.asset(
                                                                                assets.dInfo,
                                                                                width: 18,
                                                                                height: 15,
                                                                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                              ))),
                                                                    )
                                                                  ]),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Material(
                                                                    color: Colors
                                                                        .transparent, // Important to allow splash visibility
                                                                    shape:
                                                                        const CircleBorder(),
                                                                    child:
                                                                        InkWell(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      onTap:
                                                                          () async {
                                                                        // Add delay for visual feedback
                                                                        await Future.delayed(const Duration(
                                                                            milliseconds:
                                                                                150));

                                                                        if (_isDisposed)
                                                                          return;

                                                                        try {
                                                                          // Reset state before navigation
                                                                          await scripInfo
                                                                              .chngDephBtn("Overview");

                                                                          if (!mounted)
                                                                            return;

                                                                          await Navigator
                                                                              .pushNamed(
                                                                            context,
                                                                            Routes.setAlertScreen,
                                                                            arguments: {
                                                                              "depthdata": depthData,
                                                                              "wlvalue": widget.wlValue,
                                                                            },
                                                                          );

                                                                          // Reset state after navigation
                                                                          if (mounted &&
                                                                              !_isDisposed) {
                                                                            await scripInfo.chngDephBtn("Overview");
                                                                          }
                                                                        } catch (e) {
                                                                          if (mounted) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              const SnackBar(
                                                                                content: Text('Failed to open Set Alert screen'),
                                                                                duration: Duration(seconds: 2),
                                                                              ),
                                                                            );
                                                                          }
                                                                        }
                                                                      },
                                                                      splashColor: theme.isDarkMode
                                                                          ? colors
                                                                              .splashColorDark
                                                                          : colors
                                                                              .splashColorLight,
                                                                      highlightColor: theme.isDarkMode
                                                                          ? colors
                                                                              .highlightDark
                                                                          : colors
                                                                              .highlightLight,
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          assets
                                                                              .alert,
                                                                          width:
                                                                              20,
                                                                          height:
                                                                              20,
                                                                          color: theme.isDarkMode
                                                                              ? colors.textPrimaryDark
                                                                              : colors.textPrimaryLight,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          TextWidget.titleText(
                                                            text:
                                                                "${depthData.lp != "null" ? depthData.lp ?? depthData.c ?? 0.00 : '0.00'}",
                                                            color: (depthData.chng ==
                                                                            "null" ||
                                                                        depthData.chng ==
                                                                            null) ||
                                                                    depthData
                                                                            .chng ==
                                                                        "0.00"
                                                                ? colors
                                                                    .textSecondaryLight
                                                                : depthData.chng!.startsWith(
                                                                            "-") ||
                                                                        depthData
                                                                            .pc!
                                                                            .startsWith(
                                                                                "-")
                                                                    ? colors
                                                                        .error
                                                                    : colors
                                                                        .success,
                                                            theme: theme
                                                                .isDarkMode,
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          TextWidget.paraText(
                                                            text:
                                                                "${(double.tryParse(depthData.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(depthData.pc ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight,
                                                            theme: theme
                                                                .isDarkMode,
                                                          )
                                                        ])),

                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: Column(
                                                    children: [
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
                                                      if (!scripInfo
                                                              .scripDepthloader &&
                                                          widget.wlValue
                                                                  .instname !=
                                                              "UNDIND" &&
                                                          widget.wlValue
                                                                  .instname !=
                                                              "COM")
                                                        scripInfo.actDeptBtn ==
                                                                "Set Alert"
                                                            ? Container()
                                                            : Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        16),
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
                                                                              ctx,
                                                                              depthData,
                                                                              true);
                                                                        },
                                                                        child: Container(
                                                                            height:
                                                                                40,
                                                                            decoration:
                                                                                BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(5)),
                                                                            child: Center(child: TextWidget.subText(text: "BUY", color: colors.colorWhite, theme: theme.isDarkMode, fw: 2))),
                                                                      )),
                                                                      const SizedBox(
                                                                          width:
                                                                              16),
                                                                      Expanded(
                                                                          child: InkWell(
                                                                              onTap: () async {
                                                                                await placeOrderInput(scripInfo, ctx, depthData, false);
                                                                              },
                                                                              child: Container(height: 40, decoration: BoxDecoration(color: colors.tertiary, borderRadius: BorderRadius.circular(5)), child: Center(child: TextWidget.subText(text: "SELL", color: colors.colorWhite, theme: theme.isDarkMode, fw: 2)))))
                                                                    ])),
                                                    ],
                                                  ),
                                                ),
                                                if (!scripInfo
                                                        .scripDepthloader &&
                                                    widget.wlValue.instname !=
                                                        "UNDIND" &&
                                                    widget.wlValue.instname !=
                                                        "COM")
                                                  const ListDivider(),
                                                if (!scripInfo
                                                        .scripDepthloader &&
                                                    widget.wlValue.instname !=
                                                        "UNDIND" &&
                                                    widget.wlValue.instname !=
                                                        "COM")
                                                  const ListDivider(),
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
                                      ]),
                                  scripInfo.scripDepthloader
                                      ? const Center(
                                          child: Padding(
                                          padding: EdgeInsets.only(top: 120),
                                          child: CircularProgressIndicator(),
                                        ))
                                      : Expanded(
                                          child: NotificationListener<
                                                  ScrollNotification>(
                                              onNotification:
                                                  (scrollNotification) {
                                                if (scrollNotification
                                                    is ScrollUpdateNotification) {
                                                  setState(() {
                                                    _hasScrolled =
                                                        scrollNotification
                                                                .metrics
                                                                .pixels >
                                                            0;
                                                  });
                                                }
                                                return true;
                                              },
                                              child: ListView(
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  controller: scrollController,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8),
                                                      child: Row(
                                                        children: [
                                                          // Chart button
                                                          if (true) // Chart is always available
                                                            Expanded(
                                                              child: Center(
                                                                child: Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      InkWell(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    onTap:
                                                                        () async {
                                                                      // Add delay for visual feedback
                                                                      await Future.delayed(const Duration(
                                                                          milliseconds:
                                                                              150));

                                                                      scripInfo
                                                                          .singlePageloader(
                                                                              true);

                                                                      setState(
                                                                          () {
                                                                        initSize =
                                                                            _getSafeInitialSize(0.28);
                                                                        scripInfo
                                                                            .chngDephBtn("Chart");
                                                                      });

                                                                      if (scripInfo
                                                                          .scripsize) {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                      } else {
                                                                        Navigator.pop(
                                                                            context);
                                                                      }

                                                                      if (currentRouteName ==
                                                                          Routes
                                                                              .searchScrip) {
                                                                        scripInfo.requestMWScrip(
                                                                            context:
                                                                                context,
                                                                            isSubscribe:
                                                                                true);
                                                                        scripInfo
                                                                            .searchClear();
                                                                        scripInfo
                                                                            .setpageName("");
                                                                        Navigator.pop(
                                                                            context);
                                                                        currentRouteName =
                                                                            'homeScreen';
                                                                      }

                                                                      userProfile
                                                                          .setChartdialog(
                                                                              true);

                                                                      scripInfo.setChartScript(
                                                                          widget
                                                                              .wlValue
                                                                              .exch,
                                                                          widget
                                                                              .wlValue
                                                                              .token,
                                                                          widget
                                                                              .wlValue
                                                                              .tsym);

                                                                      scripInfo
                                                                          .singlePageloader(
                                                                              false);
                                                                    },
                                                                    splashColor: theme.isDarkMode
                                                                        ? colors
                                                                            .splashColorDark
                                                                        : colors
                                                                            .splashColorLight,
                                                                    highlightColor: theme.isDarkMode
                                                                        ? colors
                                                                            .highlightDark
                                                                        : colors
                                                                            .highlightLight,
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          SvgPicture
                                                                              .asset(
                                                                            assets.chart,
                                                                            color: theme.isDarkMode
                                                                                ? colors.secondaryDark
                                                                                : colors.secondaryLight,
                                                                            width:
                                                                                16,
                                                                            height:
                                                                                16,
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          TextWidget
                                                                              .subText(
                                                                            text:
                                                                                "Chart",
                                                                            color: theme.isDarkMode
                                                                                ? colors.secondaryDark
                                                                                : colors.secondaryLight,
                                                                            theme:
                                                                                theme.isDarkMode,
                                                                            // fw: 2,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                          // Spacer between buttons - only show if both buttons are visible
                                                          if (scripInfo
                                                              .getOptionawait(
                                                                  widget.wlValue
                                                                      .exch,
                                                                  widget.wlValue
                                                                      .token))
                                                            const SizedBox(
                                                                width: 20),

                                                          // Options button
                                                          if (scripInfo
                                                              .getOptionawait(
                                                                  widget.wlValue
                                                                      .exch,
                                                                  widget.wlValue
                                                                      .token))
                                                            Expanded(
                                                              child: Center(
                                                                child: Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      InkWell(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    onTap:
                                                                        () async {
                                                                      // scripInfo.singlePageloader(true);

                                                                      scripInfo.setOptionScript(
                                                                          context,
                                                                          widget
                                                                              .wlValue
                                                                              .exch,
                                                                          widget
                                                                              .wlValue
                                                                              .token,
                                                                          widget
                                                                              .wlValue
                                                                              .tsym);

                                                                      await Future.delayed(const Duration(
                                                                          milliseconds:
                                                                              150));

                                                                      if (mounted) {
                                                                        Navigator.pop(
                                                                            context);
                                                                        await Navigator.pushNamed(
                                                                            context,
                                                                            Routes
                                                                                .optionChain,
                                                                            arguments:
                                                                                widget.wlValue);
                                                                      }
                                                                    },
                                                                    splashColor: theme.isDarkMode
                                                                        ? colors
                                                                            .splashColorDark
                                                                        : colors
                                                                            .splashColorLight,
                                                                    highlightColor: theme.isDarkMode
                                                                        ? colors
                                                                            .highlightDark
                                                                        : colors
                                                                            .highlightLight,
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          SvgPicture
                                                                              .asset(
                                                                            assets.options,
                                                                            color: theme.isDarkMode
                                                                                ? colors.secondaryDark
                                                                                : colors.secondaryLight,
                                                                            width:
                                                                                16,
                                                                            height:
                                                                                16,
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          TextWidget
                                                                              .subText(
                                                                            text:
                                                                                "Options",
                                                                            color: theme.isDarkMode
                                                                                ? colors.secondaryDark
                                                                                : colors.secondaryLight,
                                                                            theme:
                                                                                theme.isDarkMode,
                                                                            // fw: 2,
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
                                                    if (scripInfo.actDeptBtn ==
                                                        "Overview") ...[
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 8),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                    height: 4),

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
                                                                const SizedBox(
                                                                    height: 4),
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
                                                                if (widget.wlValue
                                                                            .instname !=
                                                                        "UNDIND" &&
                                                                    widget.wlValue
                                                                            .instname !=
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
                                                                  Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                TextWidget.paraText(
                                                                                  text: "Quantity",
                                                                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                                  theme: theme.isDarkMode,
                                                                                ),
                                                                                TextWidget.paraText(
                                                                                  text: "Bid",
                                                                                  color: colors.secondary,
                                                                                  theme: theme.isDarkMode,
                                                                                )
                                                                              ]),
                                                                              const SizedBox(height: 10),
                                                                              _buildBidDepthPercentage("${depthData.bq1 ?? 0}", "${depthData.bp1 ?? 0.00}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildBidDepthPercentage("${depthData.bq2 ?? 0}", "${depthData.bp2 ?? 0.00}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildBidDepthPercentage("${depthData.bq3 ?? 0}", "${depthData.bp3 ?? 0.00}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildBidDepthPercentage("${depthData.bq4 ?? 0}", "${depthData.bp4 ?? 0.00}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildBidDepthPercentage("${depthData.bq5 ?? 0}", "${depthData.bp5 ?? 0.00}", scripInfo, theme)
                                                                            ])),
                                                                        const SizedBox(
                                                                            width:
                                                                                20),
                                                                        Expanded(
                                                                            child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                TextWidget.paraText(
                                                                                  text: "Ask",
                                                                                  color: colors.tertiary,
                                                                                  theme: theme.isDarkMode,
                                                                                ),
                                                                                TextWidget.paraText(
                                                                                  text: "Quantity",
                                                                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                                  theme: theme.isDarkMode,
                                                                                )
                                                                              ]),
                                                                              const SizedBox(height: 10),
                                                                              _buildAskDepthPercentage("${depthData.sp1 ?? 0.00}", "${depthData.sq1 ?? 0}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildAskDepthPercentage("${depthData.sp2 ?? 0.00}", "${depthData.sq2 ?? 0}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildAskDepthPercentage("${depthData.sp3 ?? 0.00}", "${depthData.sq3 ?? 0}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildAskDepthPercentage("${depthData.sp4 ?? 0.00}", "${depthData.sq4 ?? 0}", scripInfo, theme),
                                                                              const SizedBox(height: 6),
                                                                              _buildAskDepthPercentage("${depthData.sp5 ?? 0.00}", "${depthData.sq5 ?? 0}", scripInfo, theme)
                                                                            ]))
                                                                      ]),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),
                                                                  Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            TextWidget.subText(
                                                                              text: "${depthData.tbq != "null" ? depthData.tbq ?? 0 : '0'}",
                                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                              theme: theme.isDarkMode,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            TextWidget.paraText(
                                                                              text: "(${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%)",
                                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                              theme: theme.isDarkMode,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            TextWidget.paraText(
                                                                              text: "(${scripInfo.totSellQtyPer.toStringAsFixed(2)}%)",
                                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                              theme: theme.isDarkMode,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            TextWidget.subText(
                                                                              text: "${depthData.tsq != "null" ? depthData.tsq ?? 0 : '0'}",
                                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                              theme: theme.isDarkMode,
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ]),

                                                                  (scripInfo.totBuyQtyPer.toStringAsFixed(2) ==
                                                                              "0.00" &&
                                                                          scripInfo.totSellQtyPer.toStringAsFixed(2) ==
                                                                              "0.00")
                                                                      ? const SizedBox()
                                                                      : Column(
                                                                          children: [
                                                                            const SizedBox(height: 10),
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
                                                                                barRadius: const Radius.circular(4.0), // Half of lineHeight for capsule shape
                                                                                backgroundColor: (scripInfo.totBuyQtyPer.toStringAsFixed(2) == "0.00" && scripInfo.totSellQtyPer.toStringAsFixed(2) == "0.00") ? colors.textSecondaryLight : colors.tertiary,
                                                                                percent: scripInfo.totBuyQtyPerChng,
                                                                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                                                                progressColor: colors.primary),
                                                                            const SizedBox(height: 16),
                                                                          ],
                                                                        ),
                                                                ],
                                                                const SizedBox(
                                                                    height: 4),
                                                                if ((widget.wlValue
                                                                            .instname !=
                                                                        "UNDIND" &&
                                                                    widget.wlValue
                                                                            .instname !=
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
                                                                  if (depthData
                                                                          .seg !=
                                                                      "EQT") ...[
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
                                                                      depthData.ltt !=
                                                                              "null"
                                                                          ? depthData.ltt ??
                                                                              "--"
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
                                                                  if (scripInfo
                                                                      .returnsGridview
                                                                      .isNotEmpty) ...[
                                                                    // TextWidget.titleText(
                                                                    //     text:
                                                                    //         "Returns",
                                                                    //     theme: theme
                                                                    //         .isDarkMode,
                                                                    //     fw: 1),
                                                                    const SizedBox(
                                                                        height:
                                                                            16),
                                                                    GridView.count(
                                                                        crossAxisCount: 3,
                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                        shrinkWrap: true,
                                                                        crossAxisSpacing: 12,
                                                                        mainAxisSpacing: 10,
                                                                        childAspectRatio: 1.8,
                                                                        children: List.generate(scripInfo.returnsGridview.length, (index) {
                                                                          return Container(
                                                                              width: 120,
                                                                              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                                                                              decoration: BoxDecoration(color: colors.btnBg, borderRadius: BorderRadius.circular(8)),
                                                                              child: Column(children: [
                                                                                TextWidget.subText(
                                                                                  text: "${scripInfo.returnsGridview[index]['percent']}%",
                                                                                  color: Color(scripInfo.returnsGridview[index]['percent'].toString().startsWith("-") ? 0xFFFF1717 : 0xFF00B14F),
                                                                                  theme: theme.isDarkMode,
                                                                                ),
                                                                                const SizedBox(height: 4),
                                                                                Center(
                                                                                    child: TextWidget.paraText(
                                                                                  text: "${scripInfo.returnsGridview[index]['duration']}",
                                                                                  align: TextAlign.center,
                                                                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                                  theme: theme.isDarkMode,
                                                                                ))
                                                                              ]));
                                                                        })),
                                                                  ]
                                                                ],

                                                                // Add spacing before the new sections
                                                                // const SizedBox(
                                                                //     height: 16),

                                                                // Futures Section (conditional)
                                                                if (scripInfo.getOptionawait(
                                                                    widget
                                                                        .wlValue
                                                                        .exch,
                                                                    widget
                                                                        .wlValue
                                                                        .token))
                                                                  _buildFuturesSection(
                                                                      scripInfo,
                                                                      theme,
                                                                      depthData),

                                                                // Fundamentals Section (conditional)
                                                                if (scripInfo
                                                                            .fundamentalData !=
                                                                        null &&
                                                                    scripInfo
                                                                            .fundamentalData
                                                                            ?.msg !=
                                                                        "no data found") ...[
                                                                  _buildFundamentalsSection(
                                                                      theme,
                                                                      depthData),
                                                                ] else ...[
                                                                  const SizedBox(),
                                                                ]
                                                              ]))
                                                    ] else if (scripInfo
                                                            .actDeptBtn ==
                                                        "Fundamental") ...[
                                                      if (ref
                                                                  .read(
                                                                      marketWatchProvider)
                                                                  .fundamentalData !=
                                                              null &&
                                                          ref
                                                                  .read(
                                                                      marketWatchProvider)
                                                                  .fundamentalData!
                                                                  .msg
                                                                  .toString() !=
                                                              "no data found") ...[
                                                        const SizedBox(
                                                            height: 10),
                                                        const FundamentalDataWidget(),
                                                      ] else ...[
                                                        const NoDataFound()
                                                      ]
                                                    ] else if (scripInfo
                                                            .actDeptBtn ==
                                                        "Chart") ...[
                                                      // ChartScreenWebView(
                                                      //     chartArgs: chartArgs!, cHeight: 1.48)
                                                    ] else if (scripInfo
                                                            .actDeptBtn ==
                                                        "Future") ...[
                                                      Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 3),
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                  0xffe3f2fd),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6)),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SvgPicture.asset(
                                                                    assets
                                                                        .dInfo,
                                                                    color: colors
                                                                        .colorBlue),
                                                                TextWidget
                                                                    .paraText(
                                                                  text:
                                                                      " Long press to add ${scripInfo.wlName}'s Watchlist",
                                                                  color: theme.isDarkMode
                                                                      ? colors
                                                                          .secondaryDark
                                                                      : colors
                                                                          .secondaryLight,
                                                                  theme: theme
                                                                      .isDarkMode,
                                                                )
                                                              ])),
                                                      const FutureScreen()
                                                    ] else if (scripInfo
                                                            .actDeptBtn ==
                                                        "Set Alert") ...[
                                                      SetAlert(
                                                          depthdata: depthData,
                                                          wlvalue:
                                                              widget.wlValue)
                                                    ]
                                                  ])),
                                        ),
                                  if (!scripInfo.scripDepthloader) ...[
                                    const SizedBox(height: 18)
                                  ]
                                ]),
                          );
                        }),
                  );
                });
          })),
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    await ref.read(marketWatchProvider).fetchScripInfo(
        widget.wlValue.token, widget.wlValue.exch, context, true);
    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: widget.wlValue.exch,
        tSym: widget.wlValue.tsym,
        isExit: false,
        token: widget.wlValue.token,
        transType: transType,
        lotSize: depthData.ls,
        ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
        perChange: depthData.pc ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});
    Navigator.pop(ctx);
    Navigator.pushNamed(ctx, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
      "isBskt": widget.isBasket
    });
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
      TextWidget.subText(
        text: low,
        theme: theme.isDarkMode,
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
                        style: TextStyle(color: Colors.transparent),
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
      TextWidget.subText(
        text: high,
        color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        theme: theme.isDarkMode,
      )
    ]);
  }

  // Ask side (Price on left, Qty on right)
  Widget _buildAskDepthPercentage(String price, String qty,
      MarketWatchProvider scripInfo, ThemesProvider theme) {
    final maxQty = scripInfo.maxSellQty;
    final barPercentage =
        (((int.tryParse(qty) ?? 0) / maxQty) * 100 / 100).clamp(0.0, 1.0);
    final color = colors.darkred;

    return Stack(children: [
      // Transform.flip(
      //   flipX: true,
      //   child: LinearPercentIndicator(
      //     lineHeight: 20.0,
      //     backgroundColor:
      //         !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
            TextWidget.subText(
              text: " ${price != "null" ? price : '0.00'} ",
              color: colors.tertiary,
              theme: theme.isDarkMode,
            ),
            TextWidget.subText(
              text: " ${qty != "null" ? qty : '0'} ",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              theme: theme.isDarkMode,
            ),
          ],
        ),
      )
    ]);
  }

  // Bid side (Qty on left, Price on right)
  Widget _buildBidDepthPercentage(String qty, String price,
      MarketWatchProvider scripInfo, ThemesProvider theme) {
    final maxQty = scripInfo.maxBuyQty;
    final barPercentage =
        (((int.tryParse(qty) ?? 0) / maxQty) * 100 / 100).clamp(0.0, 1.0);
    final color = colors.ltpgreen;

    return Stack(children: [
      // LinearPercentIndicator(
      //   lineHeight: 20.0,
      //   backgroundColor:
      //       !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
            TextWidget.subText(
              text: " ${qty != "null" ? qty : '0'} ",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              theme: theme.isDarkMode,
            ),
            TextWidget.subText(
              text: " ${price != "null" ? price : '0.00'} ",
              color: theme.isDarkMode
                  ? colors.secondaryDark
                  : colors.secondaryLight,
              theme: theme.isDarkMode,
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
                  // const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget.subText(
                        text: "Futures",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                      ),
                      AnimatedRotation(
                        turns: scripInfo.isFuturesExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.chevron_right,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
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
                                ? colors.secondaryDark
                                : colors.secondaryLight,
                          ),
                          TextWidget.paraText(
                            text:
                                " Long press to add ${scripInfo.wlName}'s Watchlist",
                            color: theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight,
                            theme: theme.isDarkMode,
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
                      TextWidget.subText(
                        text: "Fundamentals",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
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
              TextWidget.subText(
                text: name,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
              TextWidget.subText(
                text: value,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
              ),
            ],
          ),
          // const SizedBox(height: 12),
          Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider)
        ],
      ),
    );
  }
}
