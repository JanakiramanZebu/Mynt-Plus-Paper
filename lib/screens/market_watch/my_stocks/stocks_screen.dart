import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../scrip_depth_info.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final holdingProvide = watch(portfolioProvider).holdingsModel;
      final socketDatas = watch(websocketProvider).socketDatas;
      final marketWatch = watch(marketWatchProvider);
      final theme = context.read(themeProvider);
      return watch(portfolioProvider).loading
          ? const Center(child: CircularProgressIndicator())
          : holdingProvide!.isEmpty
              ? const Center(child: NoDataFound())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: holdingProvide.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const ListDivider();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          if (socketDatas.containsKey(
                              holdingProvide[index].exchTsym![0].token)) {
                            holdingProvide[index].exchTsym![0].lp =
                                "${socketDatas["${holdingProvide[index].exchTsym![0].token}"]['lp'] ?? 0.00}";
                            holdingProvide[index].exchTsym![0].change =
                                "${socketDatas["${holdingProvide[index].exchTsym![0].token}"]['chng'] ?? 0.00}";
                            holdingProvide[index].exchTsym![0].perChange =
                                "${socketDatas["${holdingProvide[index].exchTsym![0].token}"]['pc'] ?? 0.00}";
                            holdingProvide[index].exchTsym![0].close =
                                "${socketDatas["${holdingProvide[index].exchTsym![0].token}"]['c'] ?? 0.00}";
                          }
                          return InkWell(
                              onLongPress: () {
                                if (marketWatch.isPreDefWLs == "Yes") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      warningMessage(context,
                                          "This is a pre-defined watchlist that cannot be edited!"));
                                }
                              },
                              onTap: () async {
                                marketWatch.chngDephBtn("Overview");
                                marketWatch.singlePageloader(true);

                                DepthInputArgs depthArgs = DepthInputArgs(
                                    exch:
                                        '${holdingProvide[index].exchTsym![0].exch}',
                                    token:
                                        '${holdingProvide[index].exchTsym![0].token}',
                                    tsym:
                                        '${holdingProvide[index].exchTsym![0].tsym}',
                                    instname: "",
                                    symbol:
                                        '${holdingProvide[index].exchTsym![0].symbol}',
                                    expDate:
                                        '${holdingProvide[index].exchTsym![0].expDate}',
                                    option:
                                        '${holdingProvide[index].exchTsym![0].option}');

                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    isDismissible: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16))),
                                    backgroundColor: const Color(0xffffffff),
                                    context: context,
                                    builder: (context) => ScripDepthInfo(
                                        wlValue: depthArgs, isBasket: ''));

                                await watch(websocketProvider).establishConnection(
                                    channelInput:
                                        "${holdingProvide[index].exchTsym![0].exch}|${holdingProvide[index].exchTsym![0].token}",
                                    task: "d",
                                    context: context);
                                marketWatch.singlePageloader(false);

                                await marketWatch.fetchScripQuote(
                                    "${holdingProvide[index].exchTsym![0].token}",
                                    "${holdingProvide[index].exchTsym![0].exch}",
                                    context);

                                if (marketWatch.getQuotes!.stat == "Ok") {
                                  await marketWatch.fetchLinkeScrip(
                                      "${holdingProvide[index].exchTsym![0].token}",
                                      "${holdingProvide[index].exchTsym![0].exch}",
                                      context);

                                  marketWatch.fetchFundamentalData(
                                      tradeSym:
                                          "${holdingProvide[index].exchTsym![0].exch}:${holdingProvide[index].exchTsym![0].tsym}");
                                  context
                                      .read(marketWatchProvider)
                                      .depthBtns
                                      .add({
                                    "btnName": "Fundamental",
                                    "imgPath": assets.dInfo,
                                    "case":
                                        "Click here to view fundamental data."
                                  });

                                  await marketWatch.fetchTechData(
                                      context: context,
                                      exch:
                                          "${context.read(marketWatchProvider).getQuotes!.exch}",
                                      tradeSym:
                                          "${context.read(marketWatchProvider).getQuotes!.tsym}",
                                      lastPrc:
                                          "${context.read(marketWatchProvider).getQuotes!.lp ?? context.read(marketWatchProvider).getQuotes!.c ?? 0.00}");

                                  //  await watch(portfolioProvider).    isOpenScripInfo ("${holdingProvide[index].exchTsym![0].token}");
                                  //  }
                                }
                              },
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                dense: true,
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "${holdingProvide[index].exchTsym![0].symbol} ",
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack)),
                                    if (holdingProvide[index]
                                        .exchTsym![0]
                                        .option!
                                        .isNotEmpty)
                                      Text(
                                          "${holdingProvide[index].exchTsym![0].option}",
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
                                            exch:
                                                "${holdingProvide[index].exchTsym![0].exch}"),
                                        if (holdingProvide[index]
                                            .exchTsym![0]
                                            .expDate!
                                            .isNotEmpty)
                                          Text(
                                              " ${holdingProvide[index].exchTsym![0].expDate}  ",
                                              style: textStyles
                                                  .scripExchTxtStyle
                                                  .copyWith(
                                                      color:
                                                          colors.colorBlack)),
                                        SvgPicture.asset(assets.suitcase,
                                            height: 12,
                                            width: 16,
                                            color: colors.colorBlue),
                                        Text(
                                            " ${holdingProvide[index].currentQty}",
                                            style: textStyles.scripExchTxtStyle
                                                .copyWith(
                                                    color: colors.colorBlue,
                                                    fontWeight:
                                                        FontWeight.w600))
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "₹${holdingProvide[index].exchTsym![0].lp}",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${holdingProvide[index].exchTsym![0].change == "null" ? "0.00 " : holdingProvide[index].exchTsym![0].change} "
                                      "${holdingProvide[index].exchTsym![0].perChange == "null" ? "(0.00%)" : "(${holdingProvide[index].exchTsym![0].perChange ?? 0.00}%)"}",
                                      style: textStyle(
                                          holdingProvide[index]
                                                      .exchTsym![0]
                                                      .change!
                                                      .startsWith("-") ||
                                                  holdingProvide[index]
                                                      .exchTsym![0]
                                                      .perChange!
                                                      .startsWith('-')
                                              ? colors.darkred
                                              : (holdingProvide[index]
                                                                  .exchTsym![0]
                                                                  .change ==
                                                              "null" ||
                                                          holdingProvide[index]
                                                                  .exchTsym![0]
                                                                  .perChange ==
                                                              "null") ||
                                                      (holdingProvide[index]
                                                                  .exchTsym![0]
                                                                  .change ==
                                                              "0.00" ||
                                                          holdingProvide[index]
                                                                  .exchTsym![0]
                                                                  .perChange ==
                                                              "0.00")
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen,
                                          12,
                                          FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )

                              // StockListCard(
                              //     holdingData: holdingProvide[index],
                              //     exchTsym: holdingProvide[index].exchTsym![0]),
                              );
                        },
                      ),
                    ],
                  ),
                );
    });
  }
}
