import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';

import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_btn.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/snack_bar.dart';
import 'my_stocks/stocks_screen.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreen();
}

class _WatchListScreen extends State<WatchListScreen> {
  final PageController _controller = PageController(initialPage: 0);

  late SwipeActionController swipecontroller;
  bool _isDisposed = false;

  @override
  void initState() {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Watchlist screen',
      screenClass: 'WatchList_screen',
    );
    swipecontroller = SwipeActionController(selectedIndexPathsChangeCallback:
        (changedIndexPaths, selected, currentCount) {
      if (!_isDisposed) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    swipecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final marketWatch = watch(marketWatchProvider);
      final userProfile = watch(userProfileProvider);

      final socketDatas = watch(websocketProvider).socketDatas;
      final theme = context.read(themeProvider);
      return PageView.builder(
        itemCount: marketWatch.marketWatchlist!.values!.length,
        scrollDirection: Axis.horizontal,
        controller: _controller,
        onPageChanged: (int d) async {
          // Swipe to change wathclist

          // Un-subscribe previous market watch scrip datas
          await marketWatch.requestMWScrip(
              context: context, isSubscribe: false);
          for (var i = 0;
              i < marketWatch.marketWatchlist!.values!.length;
              i++) {
            if (i == d) {
              if (marketWatch.marketWatchlist!.values![i] == "My Stocks" ||
                  marketWatch.marketWatchlist!.values![i] == "Nifty50" ||
                  marketWatch.marketWatchlist!.values![i] == "Niftybank" ||
                  marketWatch.marketWatchlist!.values![i] == "Sensex") {
                await marketWatch.changeWlName(
                    marketWatch.marketWatchlist!.values![i], "Yes");
              } else {
                await marketWatch.changeWlName(
                    marketWatch.marketWatchlist!.values![i], "No");
              }
            }
          }

          await marketWatch.changeWLScrip(marketWatch.wlName, context);
        },
        itemBuilder: (BuildContext context, int index) {
          return RefreshIndicator(
            onRefresh: () async {
              // if (marketWatch.wlName == "My Stocks") {
              //   // await context.read(portfolioProvider).fetchHoldings(context,"");
              // } else if (marketWatch.isPreDefWLs != "Yes") {
              //   await marketWatch.fetchMWScrip(marketWatch.wlName, context);
              // }
              await marketWatch.fetchMWScrip(marketWatch.wlName, context);
            },
            child: marketWatch.wlName == "My Stocks"
                ? const StocksScreen()
                : marketWatch.scrips.isEmpty
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(assets.noDatafound,
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider),
                              const SizedBox(height: 4),
                              Text("There is no symbol in this watchlist",
                                  style: textStyle(const Color(0xff666666), 15,
                                      FontWeight.w400)),
                              const SizedBox(height: 4),
                              CustomTextBtn(
                                  label: 'Add symbol',
                                  onPress: () {
                                    marketWatch.requestMWScrip(
                                        context: context, isSubscribe: false);
                                    Navigator.pushNamed(
                                        context, Routes.searchScrip,
                                        arguments: marketWatch.wlName);
                                  },
                                  icon: assets.addCircleIcon)
                            ]),
                      ))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: marketWatch.scrips.length,
                        separatorBuilder: (context, index) => const ListDivider(),
                        itemBuilder: (BuildContext context, int idx) {
                          final scrip = marketWatch.scrips[idx];

                          // The market watch scrip data item list is provided here. These scrips are subscribed to Websocket, and we verify that the conditions fit the market watch scrip before adding the data to the market watch list.
                          if (socketDatas
                              .containsKey(scrip['token'])) {
                            scrip['ltp'] = "${socketDatas["${scrip['token']}"]['lp'] ?? 0.00}";
                            scrip['change'] = "${socketDatas["${scrip['token']}"]['chng'] ?? 0.00}";
                            scrip['perChange'] = "${socketDatas["${scrip['token']}"]['pc'] ?? 0.00}";
                            scrip['close'] = "${socketDatas["${scrip['token']}"]['c'] ?? 0.00}";

                            if (scrip['change'].toString() == "null") {
                              scrip['change'] = "0.00";
                            }
                            if ((scrip['perChange'].toString() == "null" ||
                                    scrip['perChange'].toString() == "0.00") &&
                                scrip['ltp'] != '0.00') {
                              scrip['perChange'] = scrip['change'].toString() != "0.00"
                                  ? ((double.parse(scrip['change']) /
                                              double.parse(scrip['ltp'])) *
                                          100)
                                      .toStringAsFixed(2)
                                  : "0.00";
                            }
                            if (scrip['close'].toString() == "null") {
                              scrip['close'] = "0.00";
                            }
                          }

                          bool opt = marketWatch.getOptionawait(
                              scrip['exch'], scrip['token']);

                          return SwipeActionCell(
                            isDraggable: true,
                            fullSwipeFactor: 0.7,
                            controller: swipecontroller,
                            index: idx,
                            key: ValueKey(scrip),
                            leadingActions: [
                              SwipeAction(
                                  performsFirstActionWithFullSwipe: true,
                                  color: const Color(0xff9db6fb),
                                  icon: SvgPicture.asset(assets.charticon,
                                      color: theme.isDarkMode
                                          ? const Color(0xff000000)
                                          : const Color(0xffffffff),
                                      width: 24),
                                  onTap: (handler) async {
                                    userProfile.setonloadChartdialog(true);
                                    await marketWatch.fetchScripQuoteIndex(
                                        scrip['token'], scrip['exch'], context);
                                    userProfile.setChartdialog(true);
                                    marketWatch.setChartScript(
                                        marketWatch.getQuotes!.exch.toString(),
                                        marketWatch.getQuotes!.token.toString(),
                                        marketWatch.getQuotes!.tsym.toString());
                                    handler(false);
                                  }),
                              if (opt) ...[
                                SwipeAction(
                                    color: Color(!theme.isDarkMode
                                        ? 0xffe7edfe
                                        : 0xff041d62),
                                    icon: SvgPicture.asset(assets.optChainIcon,
                                        color: (!theme.isDarkMode
                                            ? const Color(0xff000000)
                                            : const Color(0xffffffff)),
                                        width: 24),
                                    onTap: (handler) async {
                                      // marketWatch.calldepthApis();
                                      if (opt) {
                                        // await marketWatch.calldepthApis(
                                        //     context,
                                        //     marketWatch.scrips[idx],
                                        //     "Option|-|Deph");
                                        DepthInputArgs depthArgs =
                                            DepthInputArgs(
                                                exch: scrip['exch'],
                                                token: scrip['token'],
                                                tsym: scrip['tsym'],
                                                instname: scrip['instname'],
                                                symbol: scrip['symbol'],
                                                expDate: scrip['expDate'],
                                                option: scrip['option']);
                                        marketWatch.singlePageloader(true);
                                        Navigator.pushNamed(
                                            context, Routes.optionChain,
                                            arguments: depthArgs);
                                        marketWatch.setOptionScript(
                                            context,
                                            scrip['exch'],
                                            scrip['token'],
                                            scrip['tsym']);
                                      }
                                      handler(false);
                                    })
                              ],
                            ],
                            trailingActions: (scrip['instname'] != "UNDIND" &&
                                    scrip['instname'] != "COM")
                                ? [
                                    SwipeAction(
                                        performsFirstActionWithFullSwipe: true,
                                        title: "BUY",
                                        color: Color(theme.isDarkMode
                                            ? 0xffcaedc4
                                            : 0xffedf9eb),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: colors.ltpgreen),
                                        onTap: (handler) async {
                                          await placeOrderInput(
                                              marketWatch,
                                              context,
                                              scrip,
                                              true);
                                          handler(false);
                                        }),
                                    SwipeAction(
                                        title: "SELL",
                                        color: Color(theme.isDarkMode
                                            ? 0xfffbbbb6
                                            : 0xfffee8e7),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: colors.darkred),
                                        onTap: (handler) async {
                                          await placeOrderInput(
                                              marketWatch,
                                              context,
                                              scrip,
                                              false);
                                          handler(false);
                                        }),
                                  ]
                                : [],
                            child: ListTile(
                                onLongPress: () {
                                  if (marketWatch.isPreDefWLs == "Yes") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        warningMessage(context,
                                            "This is a pre-defined watchlist that cannot be edited!"));
                                  } else {
                                    context
                                        .read(marketWatchProvider)
                                        .requestMWScrip(
                                            context: context,
                                            isSubscribe: false);
                                    Navigator.pushNamed(
                                        context, Routes.editScrip,
                                        arguments: marketWatch.wlName);
                                  }
                                },
                                onTap: () async {
                                  await marketWatch.calldepthApis(
                                      context, scrip, "");
                                },
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                dense: true,
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "${scrip["symbol"].toString().toUpperCase()} ",
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack)),
                                    if (scrip["option"].toString().isNotEmpty)
                                      Text(
                                          "${scrip["option"]}",
                                          style: textStyles.scripNameTxtStyle
                                              .copyWith(
                                                  color:
                                                      const Color(0xff666666))),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        CustomExchBadge(
                                            exch: '${scrip["exch"]}'),
                                        if (scrip['expDate']
                                            .toString()
                                            .isNotEmpty)
                                          Text(
                                              " ${scrip['expDate']}  ",
                                              style: textStyles
                                                  .scripExchTxtStyle
                                                  .copyWith(
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack)),
                                        if (scrip['holdingQty'] != null) ...[
                                          SvgPicture.asset(assets.suitcase,
                                              height: 12,
                                              width: 16,
                                              color: theme.isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue),
                                          Text(
                                              " ${scrip['holdingQty']}",
                                              style: textStyles
                                                  .scripExchTxtStyle
                                                  .copyWith(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .colorLightBlue
                                                          : colors.colorBlue,
                                                      fontWeight:
                                                          FontWeight.w600))
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "₹${scrip['ltp'] ?? 0.00}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${scrip["change"].toString() == "null" ? 0.00 : scrip['change']} (${scrip['perChange'].toString() == "null" ? 0.00 : scrip["perChange"]}%)",
                                        style: textStyle(
                                            scrip['change'].toString().startsWith("-") ||
                                                    scrip['perChange']
                                                        .toString()
                                                        .startsWith('-')
                                                ? colors.darkred
                                                : (scrip['change'].toString() ==
                                                                "null" ||
                                                            scrip['perChange']
                                                                    .toString() ==
                                                                "null") ||
                                                        (scrip['change'].toString() ==
                                                                    "0.00" ||
                                                                scrip['perChange']
                                                                        .toString() ==
                                                                    "0.00")
                                                    ? colors.ltpgrey
                                                    : colors.ltpgreen,
                                            12,
                                            FontWeight.w600),
                                      )
                                    ])),
                          );
                        },
                      ),
          );
        },
      );
    });
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      Map depthData, bool transType) async {
    await context.read(marketWatchProvider).fetchScripInfo(
        depthData['token'].toString(),
        depthData['exch'].toString(),
        context,
        true);
    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: depthData['exch'].toString(),
        tSym: depthData['tsym'].toString(),
        isExit: false,
        token: depthData['token'].toString(),
        transType: transType,
        lotSize: depthData['ls'],
        ltp: "${depthData['ltp'] ?? depthData['close'] ?? 0.00}",
        perChange: depthData['perChange'] ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});
    Navigator.pushNamed(ctx, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ctx.read(marketWatchProvider).scripInfoModel!,
      "isBskt": ""
    });
  }
}
