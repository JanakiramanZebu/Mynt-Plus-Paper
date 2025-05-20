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
import 'package:percent_indicator/percent_indicator.dart';
import '../../../provider/websocket_provider.dart';
import '../../locator/constant.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
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

class ScripDepthInfo extends StatefulWidget {
  final DepthInputArgs wlValue;
  final String isBasket;

  const ScripDepthInfo(
      {super.key, required this.wlValue, required this.isBasket});

  @override
  State<ScripDepthInfo> createState() => _ScripDepthInfoState();
}

class _ScripDepthInfoState extends State<ScripDepthInfo> {
  double initSize = 0.88;
  ChartArgs? chartArgs;
  String regtoken = "";
  
  // Cache for text styles
  static final Map<String, TextStyle> _textStyleCache = {};
  static final Map<String, TextStyle> _titleStyleCache = {};
  static final Map<String, TextStyle> _valueStyleCache = {};
  
  // Memoized text styles
  TextStyle _getTextStyle(Color color, double size, FontWeight weight) {
    final key = '${color.value}_${size}_${weight.index}';
    return _textStyleCache.putIfAbsent(
      key,
      () => TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }

  TextStyle _getTitleStyle(Color color) {
    final key = '${color.value}_title';
    return _titleStyleCache.putIfAbsent(
      key,
      () => _getTextStyle(color, 12, FontWeight.w500),
    );
  }

  TextStyle _getValueStyle(Color color) {
    final key = '${color.value}_value';
    return _valueStyleCache.putIfAbsent(
      key,
      () => _getTextStyle(color, 14, FontWeight.w500),
    );
  }

  @override
  void initState() {
    super.initState();
    regtoken = widget.wlValue.token;
    _initializeSize();
    
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Stock details',
      screenClass: 'ScripDepthInfo',
    );
  }

  void _initializeSize() {
    setState(() {
      initSize = (context.read(marketWatchProvider).actDeptBtn != "Overview" ||
              widget.wlValue.instname != "UNDIND" &&
                  widget.wlValue.instname != "COM")
          ? 0.88
          : 0.38;
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
  Widget _buildInfoRow(String title1, String value1, String title2, String value2, ThemesProvider theme) {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title1, style: _getTitleStyle(const Color(0xff666666))),
            const SizedBox(height: 2),
            Text(value1, style: _getValueStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
            const SizedBox(height: 2),
            Divider(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider)
          ],
        ),
      ),
      const SizedBox(width: 24),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title2, style: _getTitleStyle(const Color(0xff666666))),
            const SizedBox(height: 2),
            Text(value2, style: _getValueStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
            const SizedBox(height: 2),
            Divider(color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider)
          ],
        ),
      )
    ]);
  }

  // Memoized depth percentage builder
  Widget _buildDepthPercentage(String qty, String price, bool isBuy, MarketWatchProvider scripInfo, ThemesProvider theme) {
    final maxQty = isBuy ? scripInfo.maxBuyQty : scripInfo.maxSellQty;
    final barPercentage = (((int.tryParse(qty) ?? 0) / maxQty) * 100 / 100).clamp(0.0, 1.0);
    final color = isBuy ? colors.ltpgreen : colors.darkred;
    
    return Stack(children: [
      Transform.flip(
        flipX: !isBuy,
        child: LinearPercentIndicator(
          lineHeight: 20.0,
          backgroundColor: !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
              style: _getTextStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 13, FontWeight.w500),
            ),
            Text(
              " ${price != "null" ? price : '0.00'} ",
              style: _getTextStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack, 13, FontWeight.w500),
            ),
          ],
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true, // Allows back navigation
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return; // If system handled back, do nothing

          await context.read(marketWatchProvider).chngDephBtn("Overview");

          // Initialize and cancel the timer
          ConstantName.charttimer =
              Timer.periodic(const Duration(milliseconds: 0), (timer) {});
          ConstantName.charttimer!.cancel();

          await context
              .read(marketWatchProvider)
              .requestWSOptChain(context: context, isSubscribe: false);

          await context.read(websocketProvider).establishConnection(
                channelInput: "${widget.wlValue.exch}|${widget.wlValue.token}",
                task: "ud",
                context: context,
              );

          if (context.read(marketWatchProvider).actDeptBtn == "Chart") {
            // Additional logic if needed
          }

          Navigator.of(context).pop(); // Proceed with back navigation
        },
        child: Consumer(builder: (context, ScopedReader watch, _) {
          final depthData = watch(marketWatchProvider).getQuotes!;
          final scripInfo = watch(marketWatchProvider);
          final theme = context.read(themeProvider);
          final userProfile = watch(userProfileProvider);
          
          return StreamBuilder<Map>(
            stream: watch(websocketProvider).socketDataStream,
            builder: (context, snapshot) {
              final socketDatas = snapshot.data ?? {};
              
              // Update depth data with WebSocket data if available
              if (socketDatas.containsKey(regtoken)) {
                _processDepthData(depthData, socketDatas[regtoken]);

                if (scripInfo.actDeptBtn == "Overview") {
                  if ((depthData.exch == "NSE" || depthData.exch == "BSE") &&
                      (depthData.instname != "UNDIND")) {
                    scripInfo.techDataCalc("${depthData.lp}");
                  }
                  if (widget.wlValue.instname != "UNDIND" &&
                      widget.wlValue.instname != "COM") {
                    scripInfo.scripQtyCal();
                  }
                }
              }
              
              return DraggableScrollableSheet(
                  initialChildSize: initSize,
                  minChildSize: (widget.wlValue.instname != "UNDIND" &&
                          widget.wlValue.instname != "COM")
                      ? 0.4
                      : 0.22,
                  maxChildSize: .99,
                  expand: false,
                  builder: (BuildContext ctx, ScrollController scrollController) {
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
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        const CustomDragHandler(),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                            "${widget.wlValue.symbol.toUpperCase()} ",
                                                            style: textStyle(
                                                                !theme.isDarkMode
                                                                    ? colors
                                                                        .colorBlack
                                                                    : colors
                                                                        .colorWhite,
                                                                16,
                                                                FontWeight.w600)),
                                                        Text(widget.wlValue.option,
                                                            style: textStyle(
                                                                !theme.isDarkMode
                                                                    ? colors
                                                                        .colorBlack
                                                                    : colors
                                                                        .colorWhite,
                                                                16,
                                                                FontWeight.w600)),
                                                        InkWell(
                                                            onTap: () async {
                                                              await scripInfo
                                                                  .fetchScripInfo(
                                                                      depthData
                                                                          .token!,
                                                                      depthData
                                                                          .exch!,
                                                                      ctx);
                                                              if (scripInfo
                                                                      .scripInfoModel!
                                                                      .stat ==
                                                                  "Ok") {
                                                                showModalBottomSheet(
                                                                    backgroundColor:
                                                                        const Color(
                                                                            0xff000000),
                                                                    isScrollControlled:
                                                                        true,
                                                                    useSafeArea:
                                                                        true,
                                                                    isDismissible:
                                                                        true,
                                                                    shape: const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.vertical(
                                                                                top: Radius.circular(
                                                                                    16))),
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                  return const ScripDetailDialogue();
                                                                });
                                                              }
                                                            },
                                                            child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right: 8,
                                                                        bottom: 4,
                                                                        top: 4),
                                                                child: SvgPicture.asset(
                                                                    assets.dInfo,
                                                                    width: 18,
                                                                    height: 15,
                                                                    color: const Color(
                                                                        0xff666666))))
                                                  ]),
                                                  Text(
                                                      "₹${depthData.lp != "null" ? depthData.lp ?? depthData.c ?? 0.00 : '0.00'}",
                                                      style: textStyle(
                                                          !theme.isDarkMode
                                                              ? colors.colorBlack
                                                              : colors.colorWhite,
                                                          16,
                                                          FontWeight.w600)),
                                                ])),
                                        const SizedBox(height: 5),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(children: [
                                                    CustomExchBadge(
                                                        exch: widget.wlValue.exch),
                                                    Text(
                                                        "  ${widget.wlValue.expDate}",
                                                        style: textStyle(
                                                            !theme.isDarkMode
                                                                ? colors.colorBlack
                                                                : colors.colorWhite,
                                                            12,
                                                            FontWeight.w600)),
                                                  ]),
                                                  Text(
                                                      "${(double.tryParse(depthData.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(depthData.pc ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                                                      style: textStyle(
                                                          (depthData.chng ==
                                                                      "null" ||
                                                                  depthData
                                                                          .chng ==
                                                                      null) ||
                                                              depthData.chng ==
                                                                  "0.00"
                                                          ? colors.ltpgrey
                                                          : depthData.chng!
                                                                      .startsWith(
                                                                          "-") ||
                                                                  depthData.pc!
                                                                      .startsWith(
                                                                          "-")
                                                              ? colors.darkred
                                                              : colors.ltpgreen,
                                                          12,
                                                          FontWeight.w500))
                                                ])),
                                        const SizedBox(height: 8),
                                        Container(
                                            padding: const EdgeInsets.only(
                                                left: 14, top: 8, bottom: 8),
                                            height: 52,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .darkColorDivider
                                                            : colors.colorDivider,
                                                        width: 0),
                                                    top: BorderSide(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .darkColorDivider
                                                            : colors.colorDivider,
                                                        width: 0))),
                                            child: ListView.separated(
                                                scrollDirection: Axis.horizontal,
                                                itemCount:
                                                    scripInfo.depthBtns.length,
                                                itemBuilder: (BuildContext context,
                                                    int index) {
                                                  return ElevatedButton(
                                                      onPressed: () async {
                                                        scripInfo
                                                            .singlePageloader(true);

                                                        setState(() {
                                                          initSize =
                                                              scripInfo.depthBtns[
                                                                      index]
                                                                  [
                                                                  'btnName'] ==
                                                              "Chart"
                                                          ? .40
                                                          : .99;

                                                          scripInfo.chngDephBtn(
                                                              scripInfo.depthBtns[
                                                                      index]
                                                                  [
                                                                  'btnName']);
                                                        });

                                                        if (scripInfo.depthBtns[
                                                                index]['btnName'] ==
                                                            "Chart") {
                                                          Navigator.pop(context);

                                                          if (currentRouteName ==
                                                              Routes.searchScrip) {
                                                            scripInfo
                                                                .requestMWScrip(
                                                                    context:
                                                                        context,
                                                                    isSubscribe:
                                                                        true);
                                                            scripInfo.searchClear();
                                                            scripInfo
                                                                .setpageName("");
                                                            Navigator.pop(context);
                                                            currentRouteName =
                                                                'homeScreen';
                                                          }

                                                          userProfile
                                                              .setChartdialog(true);

                                                          scripInfo.setChartScript(
                                                              widget.wlValue.exch,
                                                              widget.wlValue.token,
                                                              widget.wlValue.tsym);
                                                        } else if (scripInfo
                                                                    .depthBtns[
                                                                index]['btnName'] ==
                                                            "Option") {
                                                          scripInfo
                                                              .singlePageloader(
                                                                  true);
                                                          Navigator.pop(context);
                                                          Navigator.pushNamed(
                                                              context,
                                                              Routes.optionChain,
                                                              arguments:
                                                                  widget.wlValue);
                                                          scripInfo.setOptionScript(
                                                              context,
                                                              widget.wlValue.exch,
                                                              widget.wlValue.token,
                                                              widget.wlValue.tsym);
                                                        } else if (scripInfo
                                                                    .depthBtns[
                                                                index]['btnName'] ==
                                                            "Future") {
                                                          await scripInfo
                                                              .requestWSFut(
                                                                  context: context,
                                                                  isSubscribe:
                                                                      true);
                                                        } else if (scripInfo
                                                                .actDeptBtn ==
                                                            "Overview") {
                                                          await watch(
                                                                  websocketProvider)
                                                              .establishConnection(
                                                                  channelInput:
                                                                      "${depthData.exch}|${depthData.token}",
                                                                  task: "d",
                                                                  context: context);
                                                        } else if (scripInfo
                                                                .actDeptBtn ==
                                                            "Fundamental") {
                                                          scripInfo.chngshareHold(
                                                              "Promoter Holding");
                                                        }

                                                        scripInfo.singlePageloader(
                                                            false);
                                                      },
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                              elevation: 0,
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 12,
                                                                  vertical: 0),
                                                              backgroundColor: theme
                                                                      .isDarkMode
                                                                  ? scripInfo.actDeptBtn ==
                                                                          scripInfo.depthBtns[index][
                                                                              'btnName']
                                                                      ? colors
                                                                          .colorbluegrey
                                                                      : const Color(
                                                                              0xffB5C0CF)
                                                                          .withOpacity(
                                                                              .15)
                                                                  : scripInfo.actDeptBtn ==
                                                                          scripInfo.depthBtns[index]
                                                                              [
                                                                              'btnName']
                                                                      ? const Color(
                                                                          0xff000000)
                                                                      : const Color(
                                                                          0xffF1F3F8),
                                                              shape:
                                                                  const StadiumBorder()),
                                                      child: Row(children: [
                                                        SvgPicture.asset(
                                                          "${scripInfo.depthBtns[index]['imgPath']}",
                                                          color: theme.isDarkMode
                                                              ? Color(scripInfo
                                                                          .actDeptBtn ==
                                                                      scripInfo.depthBtns[index]
                                                                          [
                                                                          'btnName']
                                                                  ? 0xff000000
                                                                  : 0xffffffff)
                                                              : Color(scripInfo
                                                                          .actDeptBtn ==
                                                                      scripInfo.depthBtns[index]
                                                                          [
                                                                          'btnName']
                                                                  ? 0xffffffff
                                                                  : 0xff000000),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                            "${scripInfo.depthBtns[index]['btnName']}",
                                                            style: textStyle(
                                                                theme.isDarkMode
                                                                    ? Color(scripInfo
                                                                                .actDeptBtn ==
                                                                            scripInfo.depthBtns[index]
                                                                                [
                                                                                'btnName']
                                                                        ? 0xff000000
                                                                        : 0xffffffff)
                                                                    : Color(scripInfo
                                                                                .actDeptBtn ==
                                                                            scripInfo.depthBtns[index]
                                                                                [
                                                                                'btnName']
                                                                        ? 0xffffffff
                                                                        : 0xff000000),
                                                            12.5,
                                                            FontWeight.w500))
                                                      ]));
                                                },
                                                separatorBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return const SizedBox(width: 10);
                                                })),
                                      ])
                                ]),

                            scripInfo.scripDepthloader
                                ? const Center(
                                    child: Padding(
                                    padding: EdgeInsets.only(top: 120),
                                    child: CircularProgressIndicator(),
                                  ))
                                :
                                Expanded(
                                    child: ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        controller: scrollController,
                                        children: [
                                      if (scripInfo.actDeptBtn == "Overview") ...[
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 4),
                                                  _buildInfoRow(
                                                      "Open",
                                                      "${depthData.o != "null" ? depthData.o ?? 0.00 : '0.00'}",
                                                      "Close",
                                                      "${depthData.c != "null" ? depthData.c ?? 0.00 : '0.00'}",
                                                      theme),
                                                  const SizedBox(height: 4),
                                                  if (depthData.l != "null" &&
                                                      depthData.h != "null" &&
                                                      double.parse(depthData.h
                                                              .toString()) >
                                                          0 &&
                                                      depthData.l !=
                                                          depthData.h) ...[
                                                    Text("Low - High",
                                                        style: textStyle(
                                                            const Color(
                                                                0xff666666),
                                                            12,
                                                            FontWeight.w500)),
                                                    const SizedBox(height: 4),
                                                    lowHighBar(
                                                        "${depthData.l ?? 0.00}",
                                                        "${depthData.h ?? 0.00}",
                                                        "${depthData.lp ?? depthData.c ?? 0.00}",
                                                        theme),
                                                    const SizedBox(height: 2),
                                                    Divider(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .darkColorDivider
                                                            : colors
                                                                .colorDivider),
                                                  ] else ...[
                                                    _buildInfoRow(
                                                        "Low",
                                                        "${depthData.l}",
                                                        "High",
                                                        "${depthData.h}",
                                                        theme),
                                                  ],
                                                  if ((depthData.wk52L != "null" && depthData.wk52L != null) &&
                                                      (depthData.wk52H !=
                                                              "null" &&
                                                          depthData.wk52H !=
                                                              null) &&
                                                      double.parse(depthData.wk52H
                                                              .toString()) >
                                                          0 &&
                                                      depthData.wk52L !=
                                                          depthData.wk52H) ...[
                                                    const SizedBox(height: 6),
                                                    Text(
                                                        "52 Week Low - 52 Week High",
                                                        style: textStyle(
                                                            const Color(
                                                                0xff666666),
                                                            12,
                                                            FontWeight.w500)),
                                                    const SizedBox(height: 4),
                                                    lowHighBar(
                                                        "${depthData.wk52L ?? 0.00}",
                                                        "${depthData.wk52H ?? 0.00}",
                                                        "${depthData.lp ?? depthData.c ?? 0.00}",
                                                        theme),
                                                    Divider(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .darkColorDivider
                                                            : colors
                                                                .colorDivider),
                                                    const SizedBox(height: 6)
                                                  ] else ...[
                                                    _buildInfoRow(
                                                        "52 Week Low",
                                                        "${depthData.wk52L}",
                                                        "52 Week High",
                                                        "${depthData.wk52H}",
                                                        theme),
                                                  ],
                                                  if (widget.wlValue.instname !=
                                                          "UNDIND" &&
                                                      widget.wlValue.instname !=
                                                          "COM") ...[
                                                    Text("Market Depth",
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            14,
                                                            FontWeight.w600)),
                                                    const SizedBox(height: 6),
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
                                                                  Text("Qty",
                                                                      style: textStyle(
                                                                          const Color(
                                                                              0XFF506D84),
                                                                          13,
                                                                          FontWeight
                                                                              .w600)),
                                                                  Text("Bid",
                                                                      style: textStyle(
                                                                          const Color(
                                                                              0xff43A833),
                                                                          13,
                                                                          FontWeight
                                                                              .w600))
                                                                ]),
                const SizedBox(height: 7),
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
                                                                  Text("Ask",
                                                                      style: textStyle(
                                                                          colors
                                                                              .darkred,
                                                                          13,
                                                                          FontWeight
                                                                              .w600)),
                                                                  Text("Qty",
                                                                      style: textStyle(
                                                                          const Color(
                                                                              0XFF506D84),
                                                                          13,
                                                                          FontWeight
                                                                              .w600))
                                                                ]),
                const SizedBox(height: 7),
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
                                                    const SizedBox(height: 10),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "${depthData.tbq != "null" ? depthData.tbq ?? 0 : '0'}",
                                                              style: textStyle(
                                                                  theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack,
                                                                  15,
                                                                  FontWeight
                                                                      .w600)),
                                                          Text(
                                                              "${depthData.tsq != "null" ? depthData.tsq ?? 0 : '0'}",
                                                              style: textStyle(
                                                                  theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack,
                                                                  15,
                                                                  FontWeight
                                                                      .w600))
                                                        ]),
                                                    const SizedBox(height: 6),
                                                    LinearPercentIndicator(
                                                        leading: Text(
                                                            "${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%",
                                                            style: textStyle(
                                                                theme.isDarkMode
                                                                    ? colors
                                                                        .colorWhite
                                                                    : colors
                                                                        .colorBlack,
                                                                14,
                                                                FontWeight.w500)),
                                                        trailing: Text(
                                                            "${scripInfo.totSellQtyPer.toStringAsFixed(2)}%",
                                                            style: textStyle(
                                                                theme.isDarkMode
                                                                    ? colors
                                                                        .colorWhite
                                                                    : colors
                                                                        .colorBlack,
                                                                14,
                                                                FontWeight.w500)),
                                                        lineHeight: 12.0,
                                                        barRadius:
                                                            const Radius.circular(
                                                                4),
                                                        backgroundColor: (scripInfo
                                                                        .totBuyQtyPer
                                                                        .toStringAsFixed(
                                                                            2) ==
                                                                    "0.00" &&
                                                                scripInfo.totSellQtyPer
                                                                        .toStringAsFixed(2) ==
                                                                    "0.00")
                                                            ? const Color(0xffECEDEE)
                                                            : const Color(0XFFD34645),
                                                        percent: scripInfo.totBuyQtyPerChng,
                                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                                        progressColor: const Color(0xff43A833)),
                                                    const SizedBox(height: 5),
                                                    Divider(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .darkColorDivider
                                                            : colors.colorDivider)
                                                  ],
                                                  const SizedBox(height: 4),
                                                  if ((widget.wlValue.instname !=
                                                          "UNDIND" &&
                                                      widget.wlValue.instname !=
                                                          "COM")) ...[
                                                    _buildInfoRow(
                                                        "Avg Price",
                                                        "${depthData.ap ?? 0.00}",
                                                        "Volume",
                                                        "${depthData.v != "null" ? depthData.v ?? 0.00 : '0'}",
                                                        theme),
                                                    const SizedBox(height: 4),
                                                    _buildInfoRow(
                                                        "Lower Circuit",
                                                        "${depthData.lc != "null" ? depthData.lc ?? 0.00 : '0.00'}",
                                                        "Upper Circuit",
                                                        "${depthData.uc != "null" ? depthData.uc ?? 0.00 : '0.00'}",
                                                        theme),
                                                    const SizedBox(height: 4),
                                                    _buildInfoRow(
                                                        "Last Trade Qty",
                                                        "${depthData.ltq != "null" ? depthData.ltq ?? 0.00 : '0'}",
                                                        "Last Trade Time",
                                                        depthData.ltt != "null"
                                                            ? depthData.ltt ??
                                                                "--"
                                                            : "--",
                                                        theme),
                                                    const SizedBox(height: 4),
                                                    if (depthData.seg !=
                                                        "EQT") ...[
                                                      _buildInfoRow(
                                                          "Open Intrest",
                                                          "${depthData.oi ?? 0.00}",
                                                          "Change in OI",
                                                          "${depthData.poi ?? 0.00}",
                                                          theme),
                                                      const SizedBox(height: 4),
                                                    ],
                                                    if (scripInfo.returnsGridview
                                                        .isNotEmpty) ...[
                                                      Text("Returns",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              14,
                                                              FontWeight.w600)),
                                                      const SizedBox(height: 8),
                                                      GridView.count(
                                                          crossAxisCount: 3,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          crossAxisSpacing: 12,
                                                          mainAxisSpacing: 10,
                                                          childAspectRatio: 1.8,
                                                          children: List.generate(
                                                              scripInfo
                                                                  .returnsGridview
                                                                  .length,
                                                              (index) {
                                                            return Container(
                                                                width: 120,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            7,
                                                                        horizontal:
                                                                            8),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                            0xffB5C0CF)
                                                                        .withOpacity(
                                                                            .15),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8)),
                                                                child: Column(
                                                                    children: [
                                                                      Text(
                                                                          "${scripInfo.returnsGridview[index]['percent']}%",
                                                                          style: textStyle(
                                                                              Color(scripInfo.returnsGridview[index]['percent'].toString().startsWith("-")
                                                                                  ? 0xffF44336
                                                                                  : 0xff43A833),
                                                                              18,
                                                                              FontWeight.w500)),
                                                                      const SizedBox(
                                                                          height:
                                                                              4),
                                                                      Text(
                                                                          "${scripInfo.returnsGridview[index]['duration']}",
                                                                          textAlign:
                                                                              TextAlign
                                                                                  .center,
                                                                          style: textStyle(
                                                                              const Color(0xff666666),
                                                                              12,
                                                                              FontWeight.w500))
                                                                    ]));
                                                          }))
                                                    ]
                                                  ]
                                                ]))
                                      ] else if (scripInfo.actDeptBtn ==
                                          "Fundamental") ...[
                                        if (context
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
                                      ] else if (scripInfo.actDeptBtn ==
                                          "Chart") ...[
                                        // ChartScreenWebView(
                                        //     chartArgs: chartArgs!, cHeight: 1.48)
                                      ] else if (scripInfo.actDeptBtn ==
                                          "Future") ...[
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3),
                                            decoration: BoxDecoration(
                                                color: const Color(0xffe3f2fd),
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(assets.dInfo,
                                                      color: colors.colorBlue),
                                                  Text(
                                                      " Long press to add ${scripInfo.wlName}'s Watchlist",
                                                      style: textStyle(
                                                          colors.colorBlue,
                                                          12,
                                                          FontWeight.w500))
                                                ])),
                                        const FutureScreen()
                                      ] else if (scripInfo.actDeptBtn ==
                                          "Set Alert") ...[
                                        SetAlert(
                                            depthdata: depthData,
                                            wlvalue: widget.wlValue)
                                      ]
                                    ])),

                            if (!scripInfo.scripDepthloader &&
                                widget.wlValue.instname != "UNDIND" &&
                                widget.wlValue.instname != "COM")
                              scripInfo.actDeptBtn == "Set Alert"
                                  ? Container()
                                  : Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: theme.isDarkMode
                                                      ? colors.darkColorDivider
                                                      : colors.colorDivider))),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: InkWell(
                                              onTap: () async {
                                                await placeOrderInput(scripInfo,
                                                    ctx, depthData, true);
                                              },
                                              child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          const Color(0xff43A833),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              108)),
                                                  child: Center(
                                                      child: Text("BUY",
                                                          style: textStyle(
                                                              const Color(
                                                                  0XFFFFFFFF),
                                                              16,
                                                              FontWeight.w600)))),
                                            )),
                                            const SizedBox(width: 18),
                                            Expanded(
                                                child: InkWell(
                                                    onTap: () async {
                                                      await placeOrderInput(
                                                          scripInfo,
                                                          ctx,
                                                          depthData,
                                                          false);
                                                    },
                                                    child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            color: colors.darkred,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(108)),
                                                        child: Center(
                                                            child: Text("SELL",
                                                                style: textStyle(
                                                                    const Color(
                                                                        0XFFFFFFFF),
                                                                16,
                                                                    FontWeight
                                                                        .w600))))))
                                          ])),
                            if (!scripInfo.scripDepthloader) ...[
                              const SizedBox(height: 18)
                            ]
                          ]),
                    );
                  });
            });
        }));
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    await context.read(marketWatchProvider).fetchScripInfo(
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
      "scripInfo": ctx.read(marketWatchProvider).scripInfoModel!,
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
      Text(low,
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500)),
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
      Text(high,
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500))
    ]);
  }

  // Ask side (Price on left, Qty on right)
  Widget _buildAskDepthPercentage(String price, String qty, MarketWatchProvider scripInfo, ThemesProvider theme) {
    final maxQty = scripInfo.maxSellQty;
    final barPercentage = (((int.tryParse(qty) ?? 0) / maxQty) * 100 / 100).clamp(0.0, 1.0);
    final color = colors.darkred;
    
    return Stack(children: [
      Transform.flip(
        flipX: true,
        child: LinearPercentIndicator(
          lineHeight: 20.0,
          backgroundColor: !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
              " ${price != "null" ? price : '0.00'} ",
              style: TextStyle(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
            ),
            Text(
              " ${qty != "null" ? qty : '0'} ",
              style: TextStyle(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      )
    ]);
  }

  // Bid side (Qty on left, Price on right)
  Widget _buildBidDepthPercentage(String qty, String price, MarketWatchProvider scripInfo, ThemesProvider theme) {
    final maxQty = scripInfo.maxBuyQty;
    final barPercentage = (((int.tryParse(qty) ?? 0) / maxQty) * 100 / 100).clamp(0.0, 1.0);
    final color = colors.ltpgreen;
    
    return Stack(children: [
      LinearPercentIndicator(
        lineHeight: 20.0,
        backgroundColor: !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        percent: barPercentage,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        progressColor: color.withOpacity(.2),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 1.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              " ${qty != "null" ? qty : '0'} ",
              style: TextStyle(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
            ),
            Text(
              " ${price != "null" ? price : '0.00'} ",
              style: TextStyle(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
