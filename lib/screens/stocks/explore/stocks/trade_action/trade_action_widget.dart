import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/thems.dart';

import '../../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../../models/explore_model/stocks_model/toplist_stocks.dart';
import '../../../../../provider/market_watch_provider.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/websocket_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/no_data_found.dart';
import '../../../../../sharedWidget/list_divider.dart';
import '../../../../../sharedWidget/snack_bar.dart';

class TradeAction extends ConsumerStatefulWidget {
  final bool showBookmarkButton;
  
  const TradeAction({
    super.key,
    this.showBookmarkButton = false,
  });

  @override
  ConsumerState<TradeAction> createState() => _TradeActionState();
}

class _TradeActionState extends ConsumerState<TradeAction>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  final ScrollController _tabScrollController = ScrollController();

  List<String> tradeAction = [
    "Top gainers",
    "Top losers",
    "Vol. breakout",
    "Most Active"
  ];

  int _currentPageIndex = 0;
  bool _isUserScrolling = false;

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

    _tabScrollController.addListener(_handleTabScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preloadTradeActionData();
    });
  }

  void _handleTabScroll() {
    if (_tabScrollController.position.isScrollingNotifier.value) {
      _isUserScrolling = true;
    } else {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _isUserScrolling = false;
      });
    }
  }

  void _scrollToSelectedTab(int index, {bool force = false}) {
    if (!_tabScrollController.hasClients) return;
    if (!force && _isUserScrolling) return;

    final viewW = _tabScrollController.position.viewportDimension;
    final max = _tabScrollController.position.maxScrollExtent;
    final tabWidth = 120.0; // Approximate tab width

    final target = (index * tabWidth) - (viewW / 2) + (tabWidth / 2);
    final offset = target.clamp(0.0, max);

    if ((_tabScrollController.offset - offset).abs() < 1.0) return;

    _tabScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
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

  Future<void> _handlePageChanged(int pageIndex) async {
    if (!mounted) return;

    _currentPageIndex = pageIndex;
    _scrollToSelectedTab(pageIndex, force: true);

    try {
      final actionTrade = ref.read(stocksProvide);
      await actionTrade.chngTradeAction(tradeAction[pageIndex]);
    } catch (e) {
      print("Error changing trade action: $e");
    }
  }

  Future<void> _handleTabTap(String action, int index) async {
    if (_currentPageIndex == index) return;

    _currentPageIndex = index;

    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }

    await _handlePageChanged(index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final actionTrade = ref.watch(stocksProvide);
      final marketWatch = ref.watch(marketWatchProvider);
      final theme = ref.watch(themeProvider);
      final socketDatas = ref.watch(websocketProvider).socketDatas;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       TextWidget.titleText(
          //         text: "Trade action",
          //         theme: theme.isDarkMode,
          //         fw: 1,
          //         color: theme.isDarkMode
          //             ? colors.textPrimaryDark
          //             : colors.textPrimaryLight,
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 15),

          // Tabs
          _buildTabs(theme),
          // const SizedBox(height: 15),

          // Page View
          Expanded(
            child: _buildPageView(actionTrade, marketWatch, theme, socketDatas),
          ),
        ],
      );
    });
  }

  Widget _buildTabs(ThemesProvider theme) {
    return Container(
      height: 35,
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: ListView.builder(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tradeAction.length,
        itemBuilder: (context, index) {
          final action = tradeAction[index];
          final isSelected = _currentPageIndex == index;

          return Container(
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                splashColor: theme.isDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.15),
                highlightColor: theme.isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.08),
                onTap: () => _handleTabTap(action, index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.isDarkMode ? colors.searchBgDark : const Color(0xffF1F3F8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 0),
                  child: Center(
                    child: TextWidget.subText(
                      text: action,
                      color: isSelected
                          ? theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight
                          : theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      fw: isSelected ? 2 : 2,
                      theme: !theme.isDarkMode,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageView(
    dynamic actionTrade,
    dynamic marketWatch,
    ThemesProvider theme,
    Map<dynamic, dynamic> socketDatas,
  ) {
    return PageView.builder(
      controller: _pageController,
      itemCount: tradeAction.length,
      onPageChanged: (index) {
        _handlePageChanged(index);
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

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 5),
          itemCount: topStocks.length.clamp(0, 5),
          separatorBuilder: (_, __) => const ListDivider(),
          itemBuilder: (context, index) {
            final stock = topStocks[index];

            if (socketDatas.containsKey(stock.token)) {
              stock.lp = "${socketDatas[stock.token]['lp'] ?? 0.00}";
              stock.pc = "${socketDatas[stock.token]['pc'] ?? 0.00}";
              stock.v = "${socketDatas[stock.token]['v'] ?? 0.00}";
            }

            return Column(
              children: [
                _buildStockCard(stock, marketWatch, theme),
              const ListDivider(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStockCard(
      TopGainers stock, dynamic marketWatch, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // borderRadius: BorderRadius.circular(6),
        splashColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
        highlightColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        onTap: () async {
          marketWatch.scripdepthsize(false);
          marketWatch.setETF(false);
          DepthInputArgs depthArgs = DepthInputArgs(
              exch: stock.exch.toString(),
              token: stock.token.toString(),
              tsym: stock.tsym.toString(),
              instname: "",
              symbol: stock.tsym.toString(),
              expDate: "",
              option: "");
          await marketWatch.calldepthApis(context, depthArgs, "");
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Left side - Stock info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stock symbol
                    TextWidget.subText(
                      text: stock.tsym?.split("-").isNotEmpty == true ? stock.tsym!.split("-").first.toUpperCase() : "",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                      theme: theme.isDarkMode,
                    ),
                    const SizedBox(height: 4),
                    // Exchange
                    TextWidget.paraText(
                      text: stock.exch ?? "",
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                  ],
                ),
              ),
              // Right side - Price data and conditional bookmark button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPriceData(stock, theme),
                  if (widget.showBookmarkButton) ...[
                    const SizedBox(width: 8),
                    _buildBookmarkButton(stock, marketWatch, theme),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceData(TopGainers stock, ThemesProvider theme) {
    final displayLtp = stock.lp ?? "0.00";
    
    // Calculate change: (lp - c) where lp is last price and c is close price
    final displayChange = (stock.lp != null && stock.c != null) 
        ? (double.tryParse(stock.lp.toString())! - double.tryParse(stock.c.toString())!).toStringAsFixed(2)
        : "0.00";
    
    // Calculate percentage change: ((ch / lp) * 100) where ch is the calculated change and lp is last price
    final displayPerChange = (stock.lp != null && double.tryParse(displayChange) != 0) 
        ? ((double.tryParse(displayChange)! / double.tryParse(stock.lp.toString())!) * 100).toStringAsFixed(2)
        : "0.00";

    final changeColor =
        displayChange.startsWith("-") || displayPerChange.startsWith('-')
            ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
            : (displayChange == "0.00" || displayPerChange == "0.00")
                ? (theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight)
                : (theme.isDarkMode ? colors.profitDark : colors.profitLight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            displayLtp,
            style: TextWidget.textStyle(
              fontSize: 16,
              color: changeColor,
              theme: theme.isDarkMode,
              fw: 0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TextWidget.paraText(
            text: "$displayChange ($displayPerChange%)",
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkButton(TopGainers stock, dynamic marketWatch, ThemesProvider theme) {
    return Consumer(
      builder: (context, ref, child) {
        final marketWatchState = ref.watch(marketWatchProvider);
        
        // Check if the stock is already in the current watchlist
        final isInWatchlist = marketWatchState.scrips.any((scrip) {
          // Handle both Map and object types
          if (scrip is Map) {
            return scrip['token'] == stock.token && scrip['exch'] == stock.exch;
          } else {
            return scrip.token == stock.token && scrip.exch == stock.exch;
          }
        });
        
        // For trade action stocks, we assume they are valid since they come from the API
        // The segment validation is more relevant for search results
        
        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.grey.withOpacity(0.3),
            highlightColor: Colors.grey.withOpacity(0.2),
            onTap: () async {
              try {
                final currentWLName = marketWatchState.wlName;
                if (currentWLName.isEmpty) {
                  error(context, "No active watchlist found.");
                  return;
                }
                
                final scripToken = "${stock.exch}|${stock.token}";
                final success = await marketWatchState.addDelMarketScrip(
                  currentWLName,
                  scripToken,
                  context,
                  !isInWatchlist, // isAdd: true if not in watchlist, false if already in watchlist
                  false, // isEdit
                  false, // isReOrder
                  false, // isOptionStike
                );
                
                if (success) {
                  // The success message is already handled in the addDelMarketScrip method
                  // Refresh the market watch data
                  await marketWatchState.fetchMWScrip(currentWLName, context);
                }
              } catch (e) {
                print("Error adding/removing stock from watchlist: $e");
                error(context, "Failed to update watchlist. Please try again.");
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                isInWatchlist ? assets.bookmarkIcon : assets.bookmarkedIcon,
                color: theme.isDarkMode && isInWatchlist
                    ? colors.colorLightBlue
                    : isInWatchlist
                        ? colors.colorBlue
                        : colors.textSecondaryDark,
                height: 20,
                width: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
