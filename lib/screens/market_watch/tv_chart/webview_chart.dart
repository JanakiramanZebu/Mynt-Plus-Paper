import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../sharedWidget/functions.dart';
import '../../../res/global_state_text.dart';
import '../../portfolio_screens/holdings/holding_detail_screen.dart';
// import '../scrip_depth_info.dart';

class ChartScreenWebView extends StatefulWidget {
  final ChartArgs chartArgs;

  const ChartScreenWebView({
    super.key,
    required this.chartArgs,
  });

  @override
  State<ChartScreenWebView> createState() => _ChartScreenWebViewState();
}

class _ChartScreenWebViewState extends State<ChartScreenWebView> {
  double progress = 0;
  final Preferences prefs = locator<Preferences>();
  SharedPreferences? sharedPrefs;
  late WidgetRef ref;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Will be initialized in build method via Consumer
      // ref initialization happens in build method now
    });
    // WidgetsBinding post-frame callback will be handled in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Any post-frame operations can be moved here if needed
  }

  // @override
  // void didUpdateWidget(covariant ChartScreenWebView oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedTab());
  // }

  // void _scrollToSelectedTab() {
  //   final tvChart = ref.read(marketWatchProvider);

  //   final selectedIndex = tvChart.chartTabs
  //       .indexWhere((tab) => tab.token == tvChart.activeTab?.token);
  //   if (_scrollController.hasClients && selectedIndex != -1) {
  //     _scrollController.animateTo(
  //       selectedIndex * 120.0, // Adjust width estimate based on Chip size
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }

  @override
  void dispose() {
    ConstantName.chartwebViewController?.dispose();
    ConstantName.chartwebViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef widgetRef, _) {
        // Store ref for use in other methods
        ref = widgetRef;

        final tvChart = ref.watch(marketWatchProvider);
        final theme = ref.watch(themeProvider);
        final userProfile = ref.watch(userProfileProvider);
        final chartUpdate = ref.watch(chartUpdateProvider);

        // Load tabs and scroll on first build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ref.read(marketWatchProvider).loadDefaultTabs();
          // ref.read(marketWatchProvider).scrollToSelectedTab(false);
        });

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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // IconButton(
                    //   padding: const EdgeInsets.all(0),
                    //   icon: Icon(Icons.restart_alt,
                    //       color: theme.isDarkMode
                    //           ? colors.colorWhite
                    //           : colors.colorBlack), // Back icon
                    //   onPressed: () {
                    //     ConstantName.chartwebViewController?.loadUrl(
                    //       urlRequest: URLRequest(
                    //         url: WebUri(
                    //           "https://mynt.zebuetrade.com/tv?src=app&symbol=${widget.chartArgs.tsym}&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}&exch=${widget.chartArgs.exch}&dark=${theme.isDarkMode}",
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
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
                  ? const Color(0xFF0037B7) // Blue color for Buy
                  : const Color(0xFF0037B7).withOpacity(0.2),
              borderRadius: const BorderRadius.all(
               Radius.circular(6)
              ),
            ),
            child: Center(
              child: TextWidget.subText(
                text: "Buy",
                color: const Color(0XFFFFFFFF),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
          ),
        ),
      ),
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
                  ? const Color(0xFFC40024) // Red color for Sell
                  : const Color(0xFFC40024).withOpacity(0.2),
              borderRadius: const BorderRadius.all(Radius.circular(6)
              ),
            ),
            child: Center(
              child: TextWidget.subText(
                text: "Sell",
                color: const Color(0XFFFFFFFF),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
          ),
        ),
      ),
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
        height: 40,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: SvgPicture.asset(
  assets.backCustomIcon,
  width: 20,
  height: 20,
),
                onPressed: () async {
                  userProfile.setChartdialog(false);
                  if (tvChart.scripsize) {
                    tvChart.chngDephBtn("Overview");
                  } else {
                    tvChart.chngDephBtn("Overview");
                    tvChart.singlePageloader(true);
                    await tvChart.calldepthApis(context, tvChart.getQuotes, "");
                    tvChart.singlePageloader(false);
                  }
                  tvChart.setChartScript('ABC', '0123', 'ABCD');
                  chartUpdate.changeOrientation('portrait');
                },
              ),
            ),
            const Spacer(),            // Expanded(
            //   child: ListView.separated(
            //     controller: tvChart.scrollController,
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.only(right: 8),
            //     itemCount:
            //         tvChart.chartTabs.length, // List of tabs (tokens/symbols)
            //     separatorBuilder: (_, __) => const SizedBox(width: 8),
            //     itemBuilder: (context, index) {
            //       final last = tvChart.chartTabs.first;
            //       final tab = tvChart.chartTabs[index];
            //       final isSelected = tab.token == tvChart.activeTab?.token;

            //       return InkWell(
            //         onTap: () async {
            //           await tvChart.fetchScripQuoteIndex(
            //               tab.token, tab.exch, context);
            //           tvChart.setChartScript(tab.exch, tab.token, tab.tsym);
            //         },
            //         borderRadius: BorderRadius.circular(16),
            //         child: Chip(
            //           visualDensity:
            //               const VisualDensity(vertical: -4, horizontal: 0),
            //           labelPadding: const EdgeInsets.only(right: 0),
            //           padding: index > 1
            //               ? const EdgeInsets.only(left: 16)
            //               : const EdgeInsets.symmetric(horizontal: 8),
            //           label: TextWidget.paraText(
            //               text: tab.tsym,
            //               color: theme.isDarkMode
            //                   ? Color(isSelected ? 0xff000000 : 0xffffffff)
            //                   : Color(isSelected ? 0xffffffff : 0xff000000),
            //               theme: theme.isDarkMode,
            //               fw: 0),
            //           backgroundColor: theme.isDarkMode
            //               ? (isSelected
            //                   ? const Color(0xffffffff)
            //                   : const Color(0xff000000))
            //               : (isSelected
            //                   ? const Color(0xff000000)
            //                   : const Color(0xffffffff)),
            //           shape: StadiumBorder(
            //             side: BorderSide(
            //               color: theme.isDarkMode
            //                   ? (!isSelected
            //                       ? colors.colorWhite
            //                       : colors.colorBlack)
            //                   : (isSelected
            //                       ? colors.colorWhite
            //                       : colors.colorBlack),
            //             ),
            //           ),
            //           // deleteIcon: index > 1
            //           //     ? Icon(
            //           //         Icons.close,
            //           //         size: 16,
            //           //         color: theme.isDarkMode
            //           //             ? Color(isSelected ? 0xff000000 : 0xffffffff)
            //           //             : Color(isSelected ? 0xffffffff : 0xff000000),
            //           //       )
            //           //     : null,
            //           // onDeleted: index > 1
            //           //     ? () async {
            //           //         tvChart.removeChartTab(tab, false);
            //           //         if (tvChart.activeTab?.token == tab.token) {
            //           //           await tvChart.fetchScripQuoteIndex(
            //           //               last.token, last.exch, context);
            //           //           tvChart.setChartScript(
            //           //               last.exch, last.token, last.tsym);
            //           //         }
            //           //       }
            //           //     : null,
            //           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //           // padding: const EdgeInsets.symmetric(horizontal: 8),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: SvgPicture.asset(
  assets.rotationIcon,
  width: 20,
  height: 20,
), // Back icon
              onPressed: () async {
                if (chartUpdate.orientation == 'portrait') {
                  chartUpdate.changeOrientation('landscape');
                } else {
                  chartUpdate.changeOrientation('portrait');
                }
              },
            ),
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: SvgPicture.asset(
  assets.searchIcon1,
  width: 20,
  height: 20,
),// Back icon
              onPressed: () async {
                ref
                    .read(marketWatchProvider)
                    .requestMWScrip(context: context, isSubscribe: false);
                Navigator.pushNamed(
                  context,
                  Routes.searchScrip,
                  arguments: "Chart||Is",
                );
                // userProfile.setChartdialog(false);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(MarketWatchProvider tvChart, theme, showchartof,
      chartUpdate, BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height -
          (TargetPlatform.iOS == defaultTargetPlatform ? 180 : 150)),
      child: InAppWebView(
        key: ref.read(userProfileProvider).webViewKey,
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
              "https://mynt.zebuetrade.com/tv?src=app&symbol=${widget.chartArgs.tsym}&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}&exch=${widget.chartArgs.exch}&dark=${theme.isDarkMode}"
              // "https://global-grammar-349410.web.app/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}"
              // "&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}"
              // "&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}&showseries=Y",
              ),
        ),
        onConsoleMessage: (controller, consoleMessage) {
          ConstantName.chartwebViewController = controller;
        },
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
        ),
        onWebViewCreated: (controller) {
          ConstantName.chartwebViewController = controller;
        },
        onReceivedError: (controller, request, error) {
          ConstantName.chartwebViewController = controller;

          if (error.description.contains('recreating_view')) {
            setState(() {
              ref.read(userProfileProvider).setonloadChartdialog(true);
            });
          }
        },
        onProgressChanged: (controller, progress) async {
          WebUri? currentUrl = await controller.getUrl();

          setState(() {
            this.progress = progress / 100;
            if (ref.read(userProfileProvider).showchartof && progress == 100) {
              final mktpro = ref.read(marketWatchProvider).getQuotes;

              String redirUrl = currentUrl.toString();
              Uri url = Uri.parse(redirUrl);
              Map<String, String> queryParams = url.queryParameters;
              String? query = queryParams['token'];
              if (mktpro!.token != "" && mktpro.token.toString() != query) {
                // print("sddccdcdcdc WebUri ${currentUrl.toString()}");
                tvChart.setChartScript(mktpro.exch.toString(),
                    mktpro.token.toString(), mktpro.tsym.toString());
              }
              // print("sddccdcdcdc $progress $query");
            }
          });
        },
      ),
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    final raw = ref.read(marketWatchProvider).getQuotes;
    await ref
        .read(marketWatchProvider)
        .fetchScripInfo(raw!.token.toString(), raw.exch.toString(), ctx, true);
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
      "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
      "isBskt": ''
    });
  }
}
