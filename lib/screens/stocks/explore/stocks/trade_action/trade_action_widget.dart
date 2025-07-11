import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/thems.dart';

import '../../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../../models/explore_model/stocks_model/toplist_stocks.dart';
import '../../../../../provider/market_watch_provider.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/websocket_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/no_data_found.dart';

class TradeAction extends ConsumerStatefulWidget {
  const TradeAction({super.key});

  @override
  ConsumerState<TradeAction> createState() => _TradeActionState();
}

class _TradeActionState extends ConsumerState<TradeAction>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  // late int _lastFetchedIndex ;
  List<String> tradeAction = [
    "Top gainers",
    "Top losers",
    "Vol. breakout",
    "Most Active"
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: tradeAction.length, vsync: this, initialIndex: 0);
    _pageController = PageController(initialPage: _tabController.index);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preloadTradeActionData();
    });
  }

  void _preloadTradeActionData() async {
    if (!mounted) return;

    try {
      final actionTrade =
          ProviderScope.containerOf(context).read(stocksProvide);

      for (final action in tradeAction) {
        await actionTrade.chngTradeAction(action);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await actionTrade.chngTradeAction(tradeAction[0]);
      actionTrade.requestWSTradeaction(isSubscribe: true, context: context);
    } catch (e) {
      print("Error preloading trade action data: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final actionTrade = ref.watch(stocksProvide);
      final marketWatch = ref.watch(marketWatchProvider);
      final theme = ref.watch(themeProvider);
      final socketDatas = ref.watch(websocketProvider).socketDatas;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.titleText(
                text: "Trade action",
                theme: theme.isDarkMode,
                fw: 1,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
              ),
              // DropdownButtonHideUnderline(
              //   child: DropdownButton2(
              //     menuItemStyleData: MenuItemStyleData(
              //         customHeights: actionTrade.getCustomItemsHeight()),

              //     buttonStyleData: const ButtonStyleData(
              //         height: 32,
              //         width: 100,
              //         decoration: BoxDecoration(
              //             color: Color(0xffF1F3F8),
              //             borderRadius:
              //                 BorderRadius.all(Radius.circular(32)))),
              //     dropdownStyleData: DropdownStyleData(
              //       width: 100,
              //       padding: const EdgeInsets.symmetric(vertical: 6),
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       offset: const Offset(0, 8),
              //     ),
              //     // buttonSplashColor: Colors.transparent,
              //     isExpanded: true,
              //     hint: TextWidget.subText(
              //         text: actionTrade.selctedTradeAct,
              //         theme: theme.isDarkMode),
              //     items: actionTrade.addDividersAfterExpDates(),
              //     // customItemsHeights: actionTrade.getCustomItemsHeight(),
              //     value: actionTrade.selctedTradeAct,
              //     onChanged: (value) async {
              //       if (value != actionTrade.selctedTradeAct) {
              //         actionTrade.chngTradeAct("$value");
              //       }
              //     },
              //     // buttonHeight: 36,
              //     // buttonWidth: 120,
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 36,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: const BoxDecoration(),
                  labelPadding: const EdgeInsets.only(right: 8),
                  indicatorColor: Colors.transparent,
                  labelColor: colors.colorBlack,
                  labelStyle:
                      TextWidget.textStyle(fontSize: 16, fw: 3, theme: false),
                  unselectedLabelColor: colors.colorWhite,
                  unselectedLabelStyle:
                      TextWidget.textStyle(fontSize: 16, fw: 3, theme: false),
                  tabs: List.generate(tradeAction.length, (index) {
                    final action = tradeAction[index];
                    final isSelected = _tabController.index == index;

                    return Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.btnBg)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: TextWidget.paraText(
                          text: action,
                          color: isSelected
                              ? (theme.isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorBlack)
                              : colors.textSecondaryLight,
                          fw: isSelected ? 2 : 3,
                          theme: !theme.isDarkMode,
                        ),
                      ),
                    );
                  }),
                  onTap: (index) async {
                    // Allow direct navigation to any tab
                    _tabController.animateTo(index);
                    // _pageController.animateToPage(
                    //   index,
                    //   duration: const Duration(milliseconds: 300),
                    //   curve: Curves.easeInOut,
                    // );
                    // actionTrade.requestWSTradeaction(isSubscribe: false, context: context);
                    await actionTrade.chngTradeAction(tradeAction[index]);
                    // actionTrade.requestWSTradeaction(isSubscribe: true, context: context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 350,
              child: PageView.builder(
                controller: _pageController,
                itemCount: tradeAction.length,
                onPageChanged: (index) async {
                  _tabController.animateTo(index);
                  await actionTrade.chngTradeAction(tradeAction[index]);
                },
                itemBuilder: (context, pageIndex) {
                  final currentAction = tradeAction[pageIndex];
                  List<TopGainers> topStocks;

                  switch (currentAction) {
                    case "Top gainers":
                      topStocks = actionTrade.topGainers;
                      break;
                    case "Top losers":
                      topStocks = actionTrade.topLosers;
                      break;
                    case "Vol. breakout":
                      topStocks = actionTrade.byVolume;
                      break;
                    case "Most Active":
                      topStocks = actionTrade.byValue;
                      break;
                    default:
                      topStocks = actionTrade.topStockData;
                  }

                  if (topStocks.isEmpty) {
                    return const Center(child: NoDataFound());
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topStocks.length.clamp(0, 5),
                    itemBuilder: (context, index) {
                      final stock = topStocks[index];

                      if (socketDatas.containsKey(stock.token)) {
                        stock.lp = "${socketDatas[stock.token]['lp'] ?? 0.00}";
                        stock.pc = "${socketDatas[stock.token]['pc'] ?? 0.00}";
                        stock.v = "${socketDatas[stock.token]['v'] ?? 0.00}";
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                DepthInputArgs depthArgs = DepthInputArgs(
                                    exch: topStocks[index].exch.toString(),
                                    token: topStocks[index].token.toString(),
                                    tsym: topStocks[index].tsym.toString(),
                                    instname: "",
                                    symbol: topStocks[index].tsym.toString(),
                                    expDate: "",
                                    option: "");
                                await marketWatch.calldepthApis(
                                    context, depthArgs, "");
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.subText(
                                          text: "${topStocks[index].tsym} ?? "
                                                  ""
                                              .split("-")
                                              .first,
                                          fw: 3,
                                          theme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                        ),
                                        const SizedBox(height: 8),
                                        TextWidget.paraText(
                                          text: "${topStocks[index].exch}",
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 3,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        TextWidget.subText(
                                          text: "${topStocks[index].lp}",
                                          fw: 3,
                                          theme: theme.isDarkMode,
                                          color: topStocks[index]
                                                  .lp!
                                                  .startsWith("-")
                                              ? theme.isDarkMode
                                                  ? colors.lossDark
                                                  : colors.lossLight
                                              : double.tryParse(stock.lp!) !=
                                                          null &&
                                                      double.parse(stock.lp!) >
                                                          0
                                                  ? theme.isDarkMode
                                                      ? colors.profitDark
                                                      : colors.profitLight
                                                  : theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                        ),
                                        const SizedBox(height: 8),
                                        TextWidget.paraText(
                                          text:
                                              "${topStocks[index].c} (${topStocks[index].pc}%)",
                                          fw: 3,
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          theme: theme.isDarkMode,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              thickness: 0,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ]);
    });
  }
}
