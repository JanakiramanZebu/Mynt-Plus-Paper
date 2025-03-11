import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../locator/constant.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/webview_chart_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';

class ChartScreenWebView extends StatefulWidget {
  final ChartArgs chartArgs;
  final double cHeight;

  const ChartScreenWebView({
    super.key,
    required this.chartArgs,
    required this.cHeight,
  });

  @override
  State<ChartScreenWebView> createState() => _ChartScreenWebViewState();
}

class _ChartScreenWebViewState extends State<ChartScreenWebView> {
  double progress = 0;
  late ContextMenu contextMenu;
  final Preferences prefs = locator<Preferences>();
  Timer? chartUpdateTimer;
  SharedPreferences? sharedPrefs;

  @override
  void initState() {
    super.initState();
    setupContextMenu();
    _initializePreferences();
  }

  void setupContextMenu() {
    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          androidId: 1,
          iosId: "1",
          title: "Special",
          action: () async {
            await ConstantName.webViewController?.evaluateJavascript(
                source: "window.tvWidget.activeChart().setChartType(1)");
          },
        ),
      ],
    );
  }

  Future<void> _initializePreferences() async {
    sharedPrefs = await SharedPreferences.getInstance();
    _loadSavedChartData();
  }

  void _loadSavedChartData() {
    if (sharedPrefs != null) {
      final savedData = sharedPrefs!.getString("chartData");
      if (savedData != null) {
        final json = jsonDecode(savedData);

        // Apply saved data to the WebView
        ConstantName.webViewController?.evaluateJavascript(
            source:
                'window.localStorage.setItem("tick_tick",\'${jsonEncode(json)}\')');
      }
    }
  }

  @override
  void dispose() {
    chartUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ScopedReader watch, _) {
        final tvChart = watch(marketWatchProvider);
        final theme = watch(themeProvider);
        final userProfile = watch(userProfileProvider);
        final chartUpdate = context.read(chartUpdateProvider);
        bool transbtn = tvChart.getQuotes?.instname != "UNDIND" &&
            tvChart.getQuotes?.instname != "COM";
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildTopBar(tvChart, theme, userProfile, chartUpdate),
            _buildWebView(
                tvChart, theme, userProfile.showchartof, chartUpdate, context),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: InkWell(
                      onTap: () async {
                        if (transbtn) {
                          userProfile.setChartdialog(false);
                          await placeOrderInput(
                              tvChart, context, tvChart.getQuotes!, true);
                        }
                      },
                      child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: transbtn
                                  ? colors.ltpgreen
                                  : colors.ltpgreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(60)),
                          child: Center(
                              child: Text("BUY",
                                  style: textStyle(const Color(0XFFFFFFFF), 16,
                                      FontWeight.w600)))),
                    )),
                    const SizedBox(width: 18),
                    Expanded(
                        child: InkWell(
                            onTap: () async {
                              if (transbtn) {
                                userProfile.setChartdialog(false);
                                await placeOrderInput(tvChart, context,
                                    tvChart.getQuotes!, false);
                              }
                            },
                            child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: transbtn
                                        ? colors.darkred
                                        : colors.darkred.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(60)),
                                child: Center(
                                    child: Text("SELL",
                                        style: textStyle(
                                            const Color(0XFFFFFFFF),
                                            16,
                                            FontWeight.w600))))))
                  ]),
            )
          ],
        );
      },
    );
  }

  Widget _buildTopBar(
      MarketWatchProvider tvChart, theme, userProfile, chartUpdate) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        height: 32,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: SvgPicture.asset(assets.backArrow,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack), // Back icon
                      onPressed: () async {
                        userProfile.setChartdialog(false);
                        await ConstantName.webViewController!.evaluateJavascript(
                            source:
                                "window.changeScript('ABC:ABCD',0123, '${theme.isDarkMode ? 'Y' : 'N'}')");
                        ConstantName.webViewController!.evaluateJavascript(
                            source:
                                'window.localStorage.removeItem("tick_tick")');
                        chartUpdate
                            .startChartUpdateTimer(userProfile.showchartof);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(MarketWatchProvider tvChart, theme, showchartof,
      chartUpdate, BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height -
          (TargetPlatform.iOS == defaultTargetPlatform ? 160 : 108)),
      child: InAppWebView(
        gestureRecognizers: {
          // Factory<VerticalDragGestureRecognizer>(
          //     () => VerticalDragGestureRecognizer()),
          // Factory<HorizontalDragGestureRecognizer>(
          //     () => HorizontalDragGestureRecognizer()),
          // Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
          // Factory<LongPressGestureRecognizer>(
          //     () => LongPressGestureRecognizer()),

          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        initialUrlRequest: URLRequest(
          url: WebUri(
            "https://global-grammar-349410.web.app/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}"
            "&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}"
            "&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}&showseries=Y",
          ),
        ),
        onConsoleMessage: (controller, consoleMessage) {
          if (consoleMessage.message.contains(":|=|:")) {
            String tsym = consoleMessage.message.split(":|=|:")[1];
            if (tsym.split("|")[1] !=
                context.read(marketWatchProvider).getQuotes?.token.toString()) {
              ConstantName.webViewController!.evaluateJavascript(
                  source: 'window.localStorage.removeItem("tick_tick")');
              chartUpdate.startChartUpdateTimer(false);
              context.read(websocketProvider).establishConnection(
                  channelInput: tsym, task: "t", context: context);
              context.read(marketWatchProvider).fetchScripQuoteIndex(
                  tsym.split("|")[1], tsym.split("|")[0], context);
              chartUpdate.startChartUpdateTimer(true);
            }
          }
        },
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(transparentBackground: true),
        ),
        onWebViewCreated: (controller) {
          ConstantName.webViewController = controller;
          chartUpdate.startChartUpdateTimer(showchartof);
        },
        onProgressChanged: (_, progress) {
          setState(() {
            this.progress = progress / 100;
          });
        },
      ),
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    final raw = context.read(marketWatchProvider).getQuotes;
    await context
        .read(marketWatchProvider)
        .fetchScripInfo(raw!.token.toString(), raw.exch.toString(), ctx);
    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: raw.exch.toString(),
        tSym: raw.tsym.toString(),
        isExit: false,
        token: raw.token.toString(),
        transType: transType,
        lotSize: depthData.ls,
        ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
        perChange: depthData.pc ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});

    // Navigator.pop(context);
    Navigator.pushNamed(ctx, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ctx.read(marketWatchProvider).scripInfoModel!,
      "isBskt": ''
    });
  }
}
