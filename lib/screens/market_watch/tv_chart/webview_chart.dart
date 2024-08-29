import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../../../locator/constant.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/network_state_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_widget_button.dart';
import '../../../sharedWidget/no_internet_widget.dart';
import 'charttype_bottom.dart';
import 'drwaing_bottom.dart';
import 'resolution_bottom.dart';

class ChartScreenWebView extends StatefulWidget {
  final ChartArgs chartArgs;
  const ChartScreenWebView({super.key, required this.chartArgs});

  @override
  State<ChartScreenWebView> createState() => _ChartScreenWebViewState();
}

class _ChartScreenWebViewState extends State<ChartScreenWebView> {
  // final pref = locator<Preferences>();
  double progress = 0;
  late ContextMenu contextMenu;
  final Preferences prefs = locator<Preferences>();

  @override
  void initState() {
    super.initState();
    // context.read(networkStateProvider).networkStream();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                await ConstantName.webViewController!.clearFocus();
                await ConstantName.webViewController!.evaluateJavascript(
                    source: "window.tvWidget.activeChart().setChartType(1)");
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {},
        onHideContextMenu: () {},
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print(
              "onContextMenuActionItemClicked: $id ${contextMenuItemClicked.title}");
        });
  }

  @override
  void dispose() { 
 
    // ConstantName.webViewController!.clearCache() ;
    // ConstantName.webViewController!.evaluateJavascript(
    //     source: 'window.localStorage.removeItem("tick_tick")');
    ConstantName.charttimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final tvChart = watch(marketWatchProvider);
      final internet = watch(networkStateProvider);
      final socketDatas = watch(websocketProvider).socketDatas;
      final theme = watch(themeProvider);
      return SizedBox(
          height: MediaQuery.of(context).size.height / 1.49,
          child: Stack(children: [
            Column(children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          border: Border(
                              top: BorderSide(
                                  color:
                                      const Color(0xff2962ff).withOpacity(.1))),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.white24,
                                blurRadius: 10.0,
                                spreadRadius: 10.0,
                                offset: Offset(10.0, 10.0))
                          ]),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 0),
                      height: 50,
                      child: Row(children: [
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  CustomWidgetButton(
                                      onPress: () {
                                        showModalBottomSheet(
                                            useRootNavigator: true,
                                            useSafeArea: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            // shape: RoundedRectangleBorder(
                                            //     borderRadius: BorderRadius.vertical(
                                            //         top: Radius.circular(25.0))),
                                            backgroundColor: Colors.white,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                const ResolutionBottom());
                                      },
                                      widget: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 6),
                                          child: Text(tvChart.duration,
                                              style: textStyle(
                                                  !theme.isDarkMode
                                                      ? colors.colorBlack
                                                      : colors.colorWhite,
                                                  14,
                                                  FontWeight.w600),
                                              overflow:
                                                  TextOverflow.ellipsis))),
                                  VerticalDivider(
                                      thickness: 2,
                                      color: const Color(0xff2962ff)
                                          .withOpacity(.1)),
                                  CustomWidgetButton(
                                      onPress: () {
                                        showModalBottomSheet(
                                            useRootNavigator: true,
                                            useSafeArea: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            backgroundColor: Colors.white,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                const ChartTypeBottomSheet());
                                      },
                                      widget: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(children: [
                                            SvgPicture.asset(
                                              'assets/tvchart/candle.svg',
                                              color: !theme.isDarkMode
                                                  ? colors.colorBlack
                                                  : colors.colorWhite,
                                            ),
                                            // Sizer.halfHorizontal(),
                                            Text("Chart type",
                                                style: textStyle(
                                                    !theme.isDarkMode
                                                        ? colors.colorBlack
                                                        : colors.colorWhite,
                                                    13,
                                                    FontWeight.w500))
                                          ]))),
                                  VerticalDivider(
                                      thickness: 2,
                                      color: const Color(0xff2962ff)
                                          .withOpacity(.1)),
                                  CustomWidgetButton(
                                      onPress: () async {
                                        await ConstantName.webViewController!
                                            .evaluateJavascript(
                                                source:
                                                    "window.tvWidget.chart().executeActionById('insertIndicator')");
                                      },
                                      widget: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 6),
                                          child: Row(children: [
                                            SvgPicture.asset(
                                                'assets/tvchart/fx.svg',
                                                color: !theme.isDarkMode
                                                    ? colors.colorBlack
                                                    : colors.colorWhite),
                                            // Sizer.halfHorizontal(),
                                            Text("Indicators",
                                                style: textStyle(
                                                    !theme.isDarkMode
                                                        ? colors.colorBlack
                                                        : colors.colorWhite,
                                                    13,
                                                    FontWeight.w500))
                                          ]))),
                                  VerticalDivider(
                                      thickness: 2,
                                      color: const Color(0xff2962ff)
                                          .withOpacity(.1)),
                                  CustomWidgetButton(
                                      onPress: () async {
                                        await ConstantName.webViewController!
                                            .evaluateJavascript(
                                                source:
                                                    "window.tvWidget.chart().executeActionById('compareOrAdd')");
                                      },
                                      widget: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 6),
                                          child: Row(children: [
                                            SvgPicture.asset(
                                                'assets/tvchart/add.svg',
                                                color: !theme.isDarkMode
                                                    ? colors.colorBlack
                                                    : colors.colorWhite),
                                            // Sizer.halfHorizontal(),
                                            Text("Compare",
                                                style: textStyle(
                                                    !theme.isDarkMode
                                                        ? colors.colorBlack
                                                        : colors.colorWhite,
                                                    13,
                                                    FontWeight.w500))
                                          ]))),
                                  VerticalDivider(
                                      thickness: 2,
                                      color: const Color(0xff2962ff)
                                          .withOpacity(.1)),
                                  CustomWidgetButton(
                                      onPress: () {
                                        showModalBottomSheet(
                                            useRootNavigator: true,
                                            useSafeArea: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            backgroundColor: Colors.white,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                const DrawingBottomSheet());
                                      },
                                      widget: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 6),
                                          child: Row(children: [
                                            SvgPicture.asset(
                                                'assets/tvchart/brush.svg',
                                                color: !theme.isDarkMode
                                                    ? colors.colorBlack
                                                    : colors.colorWhite),
                                            const SizedBox(width: 6),
                                            Text("Drawing",
                                                style: textStyle(
                                                    !theme.isDarkMode
                                                        ? colors.colorBlack
                                                        : colors.colorWhite,
                                                    13,
                                                    FontWeight.w500))
                                          ])))
                                ])))
                      ]))),
              Expanded(
                  child: InAppWebView(
                      // windowId: 0,
                      gestureRecognizers: Set()
                        ..add(Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer()))
                        ..add(
                          Factory<HorizontalDragGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer(),
                          ),
                        )
                        ..add(
                          Factory<ScaleGestureRecognizer>(
                            () => ScaleGestureRecognizer(),
                          ),
                        )
                        ..add(Factory<LongPressGestureRecognizer>(
                            () => LongPressGestureRecognizer())),
                      initialUrlRequest: URLRequest(
                          url: Uri.parse(
                              // "https://tv-mobile-chart.web.app/charts?userid=${ApiLinks.userID}&usession=${ApiLinks.session}"
                              "https://tv-chart-new.firebaseapp.com/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}")),
                      initialOptions: InAppWebViewGroupOptions(
                          crossPlatform:
                              InAppWebViewOptions(transparentBackground: true)),
                      onWebViewCreated: (InAppWebViewController controller) {
                        setState(() {
                          print(
                              "https://tv-chart-new.firebaseapp.com/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}");
                          ConstantName.webViewController = controller;
                          ConstantName.charttimer = Timer.periodic(
                              const Duration(milliseconds: 300), (timer) {
                            Map json = {
                              "t": "df",
                              "e": widget.chartArgs.exch,
                              "tk": widget.chartArgs.token,
                              "lp": socketDatas[widget.chartArgs.token]['lp'] ??
                                  "0.00",
                              "v": socketDatas[widget.chartArgs.token]['v']
                            };
                            ConstantName.webViewController!.evaluateJavascript(
                                source:
                                    'window.localStorage.setItem("tick_tick",\'${jsonEncode(json)}\')');
                          });
                        });
                      },
                      onProgressChanged:
                          (InAppWebViewController controller, int progress) {
                        setState(() {
                          this.progress = progress / 100;
                        });
                      }))
            ]),
            if (internet.connectionStatus == ConnectivityResult.none) ...[
              const NoInternetWidget()
            ]
          ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
