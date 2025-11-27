import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/screens/market_watch/stock_events_dialog.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/snack_bar.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final holdingProvide = ref.watch(portfolioProvider).holdingsModel;
      final marketWatch = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);
      return ref.watch(portfolioProvider).loading
          ? const Center(child: CircularProgressIndicator())
          : holdingProvide!.isEmpty
              ? const Center(
                  child: NoDataFound(
                    title: "No Holdings Found",
                    subtitle:
                        "You haven't made any investments yet. Build your portfolio today!",
                        secondaryEnabled: false,
                  ),
                )
              : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: holdingProvide.length * 2 - 1,
                  itemBuilder: (BuildContext context, int idx) {
                    int index = idx ~/ 2;

                    if (idx.isOdd) {
                      return const ListDivider();
                    }
                    
                    final events = marketWatch.filterStockEventsByToken(holdingProvide[index].exchTsym![0].token ?? "");
                    
                    return StreamBuilder<Map>(
                        stream: ref.watch(websocketProvider).socketDataStream,
                        builder: (context, snapshot) {
                          final socketDatas = snapshot.data ?? {};

                          if (socketDatas.containsKey(
                              holdingProvide[index].exchTsym![0].token)) {
                            final socketData = socketDatas[
                                holdingProvide[index].exchTsym![0].token];

                            // Only update with valid data
                            final lp = socketData['lp']?.toString();
                            if (lp != null &&
                                lp != "null" &&
                                lp != "0" &&
                                lp != "0.00") {
                              holdingProvide[index].exchTsym![0].lp = lp;
                            }

                            final chng = socketData['chng']?.toString();
                            if (chng != null && chng != "null") {
                              holdingProvide[index].exchTsym![0].change = chng;
                            }

                            final pc = socketData['pc']?.toString();
                            if (pc != null && pc != "null") {
                              holdingProvide[index].exchTsym![0].perChange = pc;
                            }

                            final c = socketData['c']?.toString();
                            if (c != null &&
                                c != "null" &&
                                c != "0" &&
                                c != "0.00") {
                              holdingProvide[index].exchTsym![0].close = c;
                            }
                          }

                          return InkWell(
                              onLongPress: () {
                                if (marketWatch.isPreDefWLs == "Yes") {
                                      warningMessage(context,
                                          "This is a pre-defined watchlist that cannot be edited!");
                                }
                              },
                              onTap: () async {
                                DepthInputArgs depthArgs = DepthInputArgs(
                                    exch: holdingProvide[index]
                                        .exchTsym![0]
                                        .exch
                                        .toString(),
                                    token: holdingProvide[index]
                                        .exchTsym![0]
                                        .token
                                        .toString(),
                                    tsym: holdingProvide[index]
                                        .exchTsym![0]
                                        .tsym
                                        .toString(),
                                    instname: holdingProvide[index]
                                        .exchTsym![0]
                                        .symbol
                                        .toString(),
                                    symbol: holdingProvide[index]
                                        .exchTsym![0]
                                        .symbol
                                        .toString(),
                                    expDate: "",
                                    option: "");
                                await marketWatch.calldepthApis(
                                    context, depthArgs, "");
                              },
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                dense: false,
                                title: Padding(
                                   padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                    
                                      Text(
                                        "${holdingProvide[index].exchTsym![0].symbol} ",
                                        style: TextWidget.textStyle(
                                          fontSize: 14,
                                          color: theme.isDarkMode
                                                          ? colors.textPrimaryDark
                                                          : colors.textPrimaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                      ),
                                     
                                  
                                      if (holdingProvide[index]
                                          .exchTsym![0]
                                          .option!
                                          .isNotEmpty)
                                        Text(
                                          "${holdingProvide[index].exchTsym![0].option}",
                                          style: TextWidget.textStyle(
                                                        fontSize: 14,
                                                       color: theme.isDarkMode
                                                          ? colors.textPrimaryDark
                                                          : colors.textPrimaryLight,
                                                        theme: theme.isDarkMode,
                                                        fw: 0,
                                                      ),
                                        ),
                                    ],
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                   
                                    Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          CustomExchBadge(
                                              exch:
                                                  "${holdingProvide[index].exchTsym![0].exch}"),
                                          if (holdingProvide[index]
                                              .exchTsym![0]
                                              .expDate!
                                              .isNotEmpty)
                                            TextWidget.paraText(
                                              text:
                                                  " ${holdingProvide[index].exchTsym![0].expDate}  ",
                                              color:theme.isDarkMode ? colors.textSecondaryDark :  colors.textSecondaryLight,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                              const SizedBox(width: 6),
                                          SvgPicture.asset(assets.suitcase,
                                              height: 12,
                                              width: 16,
                                              color: theme.isDarkMode
                                                  ? colors.secondaryDark
                                                  : colors.secondaryLight),
                                          const SizedBox(width: 4),
                                          TextWidget.paraText(
                                            text:
                                                "${holdingProvide[index].currentQty}",
                                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                            theme: theme.isDarkMode,
                                            fw: 0,
                                          ),
                                          if (marketWatch.hasStockEvents(events,holdingProvide[index].exchTsym![0].token ?? '')) ...[
                                          const SizedBox(width: 6),
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  useSafeArea: true,
                                                  isDismissible: true,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(16),
                                                      topRight: Radius.circular(16),
                                                    ),
                                                  ),
                                                  enableDrag: true,
                                                  builder: (context) => Container(
                                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                    child: DraggableScrollableSheet(
                                                      initialChildSize: 0.6,
                                                      expand: false,
                                                      minChildSize: 0.4,
                                                      maxChildSize: 0.9,
                                                      builder: (context, scrollController) => StockEventsDialog(
                                                        stockToken: holdingProvide[index].exchTsym![0].token!,
                                                        stockName: holdingProvide[index].exchTsym![0].symbol!,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(8),
                                              splashColor: theme.isDarkMode
                                                  ? Colors.white.withOpacity(0.15)
                                                  : Colors.black.withOpacity(0.15),
                                              highlightColor: theme.isDarkMode
                                                  ? Colors.white.withOpacity(0.08)
                                                  : Colors.black.withOpacity(0.08),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: theme.isDarkMode
                                                      ? colors.darkiconcolor.withOpacity(0.2)
                                                      : colors.darkiconcolor.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: theme.isDarkMode
                                                        ? colors.darkiconcolor.withOpacity(0.3)
                                                        : colors.darkiconcolor.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // SvgPicture.asset(assets.barChart,
                                                    //     height: 12,
                                                    //     width: 16,
                                                    //     color: theme.isDarkMode
                                                    //         ? colors.secondaryDark
                                                    //         : colors.secondaryLight),
                                                    // const SizedBox(width: 4),
                                                    TextWidget.captionText(
                                                      text: events["dividend"]!=null?"DIVIDEND":events["bonus"]!=null?"BONUS":events["split"]!=null?"SPLIT":events["rights"]!=null?"RIGHTS":"EVENT",
                                                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                      theme: theme.isDarkMode,
                                                      fw: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                       padding: const EdgeInsets.only(bottom: 4),
                                      child: TextWidget.titleText(
                                          text:
                                              "${holdingProvide[index].exchTsym![0].lp}",
                                          color: holdingProvide[index]
                                                      .exchTsym![0]
                                                      .change!
                                                      .startsWith("-") ||
                                                  holdingProvide[index]
                                                      .exchTsym![0]
                                                      .perChange!
                                                      .startsWith('-')
                                              ?  theme.isDarkMode ? colors.lossDark : colors.lossLight
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
                                                  ?  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight
                                                  : theme.isDarkMode ? colors.profitDark : colors.profitLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                          ),
                                    ),
                                    // const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: TextWidget.paraText(
                                          text:
                                              "${holdingProvide[index].exchTsym![0].change == "null" ? "0.00 " : holdingProvide[index].exchTsym![0].change} "
                                              "(${holdingProvide[index].exchTsym![0].perChange == "null" ? "(0.00%)" : "${holdingProvide[index].exchTsym![0].perChange ?? 0.00}%"})",
                                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                          ),
                                    ),
                                  ],
                                ),
                              ));
                        });
                  },
                );
    });
  }
}
