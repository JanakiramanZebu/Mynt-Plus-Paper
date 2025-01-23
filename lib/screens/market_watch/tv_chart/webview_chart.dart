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
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
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

  void startChartUpdateTimer(InAppWebViewController controller) {
    chartUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final socketDatas = context.read(websocketProvider).socketDatas;
      final depthData = context.read(marketWatchProvider).getQuotes!;
      final tokenData = socketDatas[depthData.token];

      if (tokenData != null) {
        final json = {
          "t": "df",
          "e": depthData.exch,
          "tk": depthData.token,
          "lp": tokenData['lp']?.toString() ?? "0.00",
          "v": tokenData['v']?.toString() ?? "0.00",
        };

        // Update local storage
        sharedPrefs?.setString("chartData", jsonEncode(json));

        // Update WebView
        controller.evaluateJavascript(
            source:
                'window.localStorage.setItem("tick_tick",\'${jsonEncode(json)}\')');
      }
    });
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
        return SizedBox(
          height: (MediaQuery.of(context).size.height -
              (depthData.instname == "UNDIND" || depthData.instname == "COM"
                  ? 93
                  : 133)),
          child: Column(
            children: [
              _buildTopBar(tvChart, theme, userProfile),
              _buildWebView(tvChart, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(MarketWatchProvider tvChart, theme, userProfile) {
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
                      icon: Icon(
                        Icons.chevron_left,
                        color: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        size: 32,
                      ), // Back icon
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
      
                        // if ((tvChart.getQuotes
                        //                 ?.exch ==
                        //             "NSE" ||
                        //         tvChart
                        //                 .getQuotes
                        //                 ?.exch ==
                        //             "BSE") &&
                        //     (tvChart.getQuotes
                        //             ?.instname
                        //             .toString() !=
                        //         "UNDIND")) {
                        //   context
                        //       .read(
                        //           marketWatchProvider)
                        //       .depthBtns
                        //       .add({
                        //     "btnName": "Fundamental",
                        //     "imgPath": assets.dInfo,
                        //     "case":
                        //         "Click here to view fundamental data."
                        //   });
                        // }
      
                        // context
                        //     .read(marketWatchProvider)
                        //     .depthBtns
                        //     .add({
                        //   "btnName": "Set Alert",
                        //   "imgPath":
                        //       "assets/icon/calendar.svg",
                        //   "case":
                        //       "Click here to view the trading view chart."
                        // });
                        tvChart.singlePageloader(false);
      
                        await ConstantName.webViewController!.evaluateJavascript(
                            source:
                                "window.changeScript('ABC:ABCD',0123, '${theme.isDarkMode ? 'Y' : 'N'}')");
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

  Widget _buildWebView(MarketWatchProvider tvChart, theme) {
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
          startChartUpdateTimer(controller);

          // print("objec ${"https://tv-chart-new.firebaseapp.com/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}"
          //     "&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}"
          //     "&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}"}t");
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
}
