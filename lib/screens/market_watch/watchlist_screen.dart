import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../models/marketwatch_model/get_quotes.dart';
import '../../provider/market_watch_provider.dart';

import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_btn.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/snack_bar.dart';
import 'my_stocks/stocks_screen.dart';
import 'scrip_depth_info.dart';

class WatchListScreen extends ConsumerWidget {
  WatchListScreen({super.key});

  final PageController _controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final marketWatch = watch(marketWatchProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme = context.read(themeProvider);
    return PageView.builder(
      itemCount: marketWatch.marketWatchlist!.values!.length,
      scrollDirection: Axis.horizontal,
      controller: _controller,
      onPageChanged: (int d) async {
        await marketWatch.requestMWScrip(context: context, isSubscribe: false);
        for (var i = 0; i < marketWatch.marketWatchlist!.values!.length; i++) {
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
            if (marketWatch.wlName == "My Stocks") {
              // await context.read(portfolioProvider).fetchHoldings(context,"");
            } else if (marketWatch.isPreDefWLs != "Yes") {
              await marketWatch.fetchMWScrip(marketWatch.wlName, context);
            }
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
                      itemCount: marketWatch.scrips.length,
                      // itemCount: marketWatch.marketWatchScripData[marketWatch.marketWatchlist!.values![index]],
                      itemBuilder: (BuildContext context, int idx) {
                        if (socketDatas
                            .containsKey(marketWatch.scrips[idx]['token'])) {
                          marketWatch.scrips[idx]['ltp'] =
                              "${socketDatas["${marketWatch.scrips[idx]['token']}"]['lp'] ?? 0.00}";
                          marketWatch.scrips[idx]['change'] =
                              "${socketDatas["${marketWatch.scrips[idx]['token']}"]['chng'] ?? 0.00}";
                          marketWatch.scrips[idx]['perChange'] =
                              "${socketDatas["${marketWatch.scrips[idx]['token']}"]['pc'] ?? 0.00}";
                          marketWatch.scrips[idx]['close'] =
                              "${socketDatas["${marketWatch.scrips[idx]['token']}"]['c'] ?? 0.00}";

                          if (marketWatch.scrips[idx]['change'].toString() ==
                              "null") {
                            marketWatch.scrips[idx]['change'] = "0.00";
                          }
                          if (marketWatch.scrips[idx]['perChange'].toString() ==
                              "null") {
                            marketWatch.scrips[idx]['perChange'] = "0.00";
                          }
                          if (marketWatch.scrips[idx]['close'].toString() ==
                              "null") {
                            marketWatch.scrips[idx]['close'] = "0.00";
                          }
                        }
                        return ListTile(
                            onLongPress: () {
                              if (marketWatch.isPreDefWLs == "Yes") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    warningMessage(context,
                                        "This is a pre-defined watchlist that cannot be edited!"));
                              } else {
                                context
                                    .read(marketWatchProvider)
                                    .requestMWScrip(
                                        context: context, isSubscribe: false);
                                Navigator.pushNamed(context, Routes.editScrip,
                                    arguments: marketWatch.wlName);
                              }
                            },
                            onTap: () async {
                              marketWatch.chngDephBtn("Overview");
                              await marketWatch.fetchScripQuote(
                                  "${marketWatch.scrips[idx]['token']}",
                                  "${marketWatch.scrips[idx]['exch']}",
                                  context);

                              await watch(websocketProvider).establishConnection(
                                  channelInput:
                                      "${marketWatch.scrips[idx]['exch']}|${marketWatch.scrips[idx]['token']}",
                                  task: "d",
                                  context: context);

                              if (marketWatch.getQuotes!.stat == "Ok") {
                                await context
                                    .read(marketWatchProvider)
                                    .fetchLinkeScrip(
                                        "${marketWatch.scrips[idx]['token']}",
                                        "${marketWatch.scrips[idx]['exch']}",
                                        context);

                                context
                                    .read(marketWatchProvider)
                                    .fetchFundamentalData(
                                        tradeSym:
                                            "${marketWatch.scrips[idx]['exch']}:${marketWatch.scrips[idx]['tsym']}");
                                if ((marketWatch.scrips[idx]['exch'] == "NSE" ||
                                    marketWatch.scrips[idx]['exch'] == "BSE")) {
                                  context
                                      .read(marketWatchProvider)
                                      .depthBtns
                                      .add({
                                    "btnName": "Fundamental",
                                    "imgPath": assets.dInfo,
                                    "case":
                                        "Click here to view fundamental data."
                                  });
                                  await context.read(marketWatchProvider).fetchTechData(
                                      context: context,
                                      exch:
                                          "${context.read(marketWatchProvider).getQuotes!.exch}",
                                      tradeSym:
                                          "${context.read(marketWatchProvider).getQuotes!.tsym}",
                                      lastPrc:
                                          "${context.read(marketWatchProvider).getQuotes!.lp ?? context.read(marketWatchProvider).getQuotes!.c ?? 0.00}");
                                }

                                context
                                    .read(marketWatchProvider)
                                    .depthBtns
                                    .add({
                                  "btnName": "Set Alert",
                                  "imgPath": "assets/icon/calendar.svg",
                                  "case":
                                      "Click here to view the trading view chart."
                                });

                                DepthInputArgs depthArgs = DepthInputArgs(
                                    exch: '${marketWatch.scrips[idx]['exch']}',
                                    token:
                                        '${marketWatch.scrips[idx]['token']}',
                                    tsym: '${marketWatch.scrips[idx]['tsym']}',
                                    instname: marketWatch.scrips[idx]
                                            ['instname'] ??
                                        "",
                                    symbol:
                                        '${marketWatch.scrips[idx]['symbol']}',
                                    expDate:
                                        '${marketWatch.scrips[idx]['expDate']}',
                                    option:
                                        '${marketWatch.scrips[idx]['option']}');

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
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: ScripDepthInfo(
                                            wlValue: depthArgs, isBasket: '' )));
                              }
                            },
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            dense: true,
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    "${marketWatch.scrips[idx]["symbol"].toString().toUpperCase()} ",
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)),
                                if (marketWatch.scrips[idx]["option"]
                                    .toString()
                                    .isNotEmpty)
                                  Text("${marketWatch.scrips[idx]["option"]}",
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: const Color(0xff666666))),
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
                                        exch:
                                            '${marketWatch.scrips[idx]["exch"]}'),
                                    if (marketWatch.scrips[idx]['expDate']
                                        .toString()
                                        .isNotEmpty)
                                      Text(
                                          " ${marketWatch.scrips[idx]['expDate']}  ",
                                          style: textStyles.scripExchTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack)),
                                    if (marketWatch.scrips[idx]['holdingQty'] !=
                                        null) ...[
                                      SvgPicture.asset(assets.suitcase,
                                          height: 12,
                                          width: 16,
                                          color: theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue),
                                      Text(
                                          " ${marketWatch.scrips[idx]['holdingQty']}",
                                          style: textStyles.scripExchTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorLightBlue
                                                      : colors.colorBlue,
                                                  fontWeight: FontWeight.w600))
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
                                      "₹${marketWatch.scrips[idx]['ltp'] ?? 0.00}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${marketWatch.scrips[idx]["change"].toString() == "null" ? 0.00 : marketWatch.scrips[idx]['change']} (${marketWatch.scrips[idx]['perChange'].toString() == "null" ? 0.00 : marketWatch.scrips[idx]["perChange"]}%)",
                                    style: textStyle(
                                        marketWatch.scrips[idx]['change']
                                                    .toString()
                                                    .startsWith("-") ||
                                                marketWatch.scrips[idx]
                                                        ['perChange']
                                                    .toString()
                                                    .startsWith('-')
                                            ? colors.darkred
                                            : (marketWatch.scrips[idx]['change']
                                                                .toString() ==
                                                            "null" ||
                                                        marketWatch.scrips[idx]['perChange']
                                                                .toString() ==
                                                            "null") ||
                                                    (marketWatch.scrips[idx]
                                                                    ['change']
                                                                .toString() ==
                                                            "0.00" ||
                                                        marketWatch.scrips[idx]
                                                                    ['perChange']
                                                                .toString() ==
                                                            "0.00")
                                                ? colors.ltpgrey
                                                : colors.ltpgreen,
                                        12,
                                        FontWeight.w600),
                                  )
                                ]));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const ListDivider();
                      }),
        );
      },
    );
  }

   
}
