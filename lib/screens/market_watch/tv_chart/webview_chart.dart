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
import '../../../provider/webview_chart_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_widget_button.dart';
import '../../../sharedWidget/functions.dart';
import '../scrip_depth_info.dart';
import 'charttype_bottom.dart';
import 'drwaing_bottom.dart';
import 'resolution_bottom.dart';

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
        final depthData = context.read(marketWatchProvider).getQuotes!;
        final userProfile = watch(userProfileProvider);
        final chartUpdate = context.read(chartUpdateProvider);
        return Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: (MediaQuery.of(context).size.height -
                  (depthData.instname == "UNDIND" || depthData.instname == "COM"
                      ? (defaultTargetPlatform == TargetPlatform.iOS)
                          ? 72
                          : 51
                      : (defaultTargetPlatform == TargetPlatform.iOS)
                          ? 88
                          : 96)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTopBar(tvChart, theme, userProfile, chartUpdate),
                  _buildWebView(
                      tvChart, theme, userProfile.showchartof, chartUpdate),
                  if (tvChart.getQuotes?.instname != "UNDIND" &&
                      tvChart.getQuotes?.instname != "COM") ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: InkWell(
                              onTap: () async {
                                userProfile.setChartdialog(false);
                                await placeOrderInput(
                                    tvChart, context, tvChart.getQuotes!, true);
                              },
                              child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: const Color(0xff43A833),
                                      borderRadius: BorderRadius.circular(108)),
                                  child: Center(
                                      child: Text("BUY",
                                          style: textStyle(
                                              const Color(0XFFFFFFFF),
                                              16,
                                              FontWeight.w600)))),
                            )),
                            const SizedBox(width: 18),
                            Expanded(
                                child: InkWell(
                                    onTap: () async {
                                      userProfile.setChartdialog(false);
                                      await placeOrderInput(tvChart, context,
                                          tvChart.getQuotes!, false);
                                    },
                                    child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: colors.darkred,
                                            borderRadius:
                                                BorderRadius.circular(108)),
                                        child: Center(
                                            child: Text("SELL",
                                                style: textStyle(
                                                    const Color(0XFFFFFFFF),
                                                    16,
                                                    FontWeight.w600))))))
                          ]),
                    )
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(
      MarketWatchProvider tvChart, theme, userProfile, chartUpdate) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          border: Border(
            top: BorderSide(color: const Color(0xff2962ff).withOpacity(.1)),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        height: 40,
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
                        tvChart.chngDephBtn("Overview");
                        tvChart.singlePageloader(true);

                        DepthInputArgs depthArgs = DepthInputArgs(
                            exch: '${tvChart.getQuotes?.exch}',
                            token: '${tvChart.getQuotes?.token}',
                            tsym: '${tvChart.getQuotes?.tsym}',
                            instname: tvChart.getQuotes?.instname ?? "",
                            symbol: '${tvChart.getQuotes?.symbol}',
                            expDate: '${tvChart.getQuotes?.expDate}',
                            option: '${tvChart.getQuotes?.option}');

                        showModalBottomSheet(
                            isScrollControlled: true,
                            useSafeArea: true,
                            isDismissible: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16))),
                            context: context,
                            builder: (context) => Container(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: ScripDepthInfo(
                                    wlValue: depthArgs, isBasket: '')));
                        tvChart.singlePageloader(false);
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
                    _buildDivider(),
                    _buildButton(
                      label: tvChart.duration,
                      onPressed: () =>
                          _showBottomSheet(context, const ResolutionBottom()),
                      theme: theme,
                    ),
                    _buildDivider(),
                    _buildSvgButton(
                      asset: 'assets/tvchart/candle.svg',
                      label: "Chart type",
                      onPressed: () => _showBottomSheet(
                          context, const ChartTypeBottomSheet()),
                      theme: theme,
                    ),
                    _buildDivider(),
                    _buildSvgButton(
                      asset: 'assets/tvchart/fx.svg',
                      label: "Indicators",
                      onPressed: () =>
                          ConstantName.webViewController?.evaluateJavascript(
                        source:
                            "window.tvWidget.chart().executeActionById('insertIndicator')",
                      ),
                      theme: theme,
                    ),
                    _buildDivider(),
                    _buildSvgButton(
                      asset: 'assets/tvchart/add.svg',
                      label: "Compare",
                      onPressed: () =>
                          ConstantName.webViewController?.evaluateJavascript(
                        source:
                            "window.tvWidget.chart().executeActionById('compareOrAdd')",
                      ),
                      theme: theme,
                    ),
                    _buildDivider(),
                    _buildSvgButton(
                      asset: 'assets/tvchart/brush.svg',
                      label: "Drawing",
                      onPressed: () =>
                          _showBottomSheet(context, const DrawingBottomSheet()),
                      theme: theme,
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

  Widget _buildDivider() {
    return VerticalDivider(
        thickness: 2, color: const Color(0xff2962ff).withOpacity(.1));
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required theme,
  }) {
    return CustomWidgetButton(
      onPress: onPressed,
      widget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Text(
          label,
          style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSvgButton({
    required String asset,
    required String label,
    required VoidCallback onPressed,
    required theme,
  }) {
    return CustomWidgetButton(
      onPress: onPressed,
      widget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            SvgPicture.asset(
              asset,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                13,
                FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(
      MarketWatchProvider tvChart, theme, showchartof, chartUpdate) {
    return Expanded(
      child: InAppWebView(
        gestureRecognizers: {
          Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer()),
          Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer()),
          Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        },
        initialUrlRequest: URLRequest(
          url: WebUri(
            "https://tv-chart-new.firebaseapp.com/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}"
            "&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}"
            "&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}&showseries=Y",
          ),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(transparentBackground: true),
        ),
        onWebViewCreated: (controller) {
          ConstantName.webViewController = controller;
          chartUpdate.startChartUpdateTimer(showchartof);

          // print("objec ${"https://tv-chart-new.firebaseapp.com/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}"
          //     "&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}"
          //     "&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}&showseries=Y"}");
        },
        onProgressChanged: (_, progress) {
          setState(() {
            this.progress = progress / 100;
          });
        },
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
      useRootNavigator: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => bottomSheet,
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
