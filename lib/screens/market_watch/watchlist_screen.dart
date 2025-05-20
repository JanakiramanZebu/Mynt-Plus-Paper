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
import 'watchlist_card.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreen();
}

class _WatchListScreen extends State<WatchListScreen> with AutomaticKeepAliveClientMixin {
  final PageController _controller = PageController(initialPage: 0);
  late SwipeActionController swipecontroller;
  bool _isDisposed = false;
  String _currentWatchlist = "";

  @override
  bool get wantKeepAlive => true;

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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Consumer(builder: (context, ScopedReader watch, _) {
      final marketWatch = watch(marketWatchProvider);
      final userProfile = watch(userProfileProvider);
      final theme = context.read(themeProvider);
      
      // Check if watchlist changed to reduce rebuilds when only prices change
      bool watchlistChanged = _currentWatchlist != marketWatch.wlName;
      if (watchlistChanged) {
        _currentWatchlist = marketWatch.wlName;
      }

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
              await marketWatch.fetchMWScrip(marketWatch.wlName, context);
            },
            child: marketWatch.wlName == "My Stocks"
                ? const StocksScreen()
                : marketWatch.scrips.isEmpty
                    ? _buildEmptyState(theme, marketWatch)
                    : _buildWatchlistView(marketWatch, watchlistChanged),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(ThemesProvider theme, MarketWatchProvider marketWatch) {
    // Cache the icon to prevent rebuilds
    final noDataIcon = SvgPicture.asset(
      assets.noDatafound,
      color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
    );
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            noDataIcon,
            const SizedBox(height: 4),
            Text("There is no symbol in this watchlist",
                style: textStyle(const Color(0xff666666), 15, FontWeight.w400)),
            const SizedBox(height: 4),
            CustomTextBtn(
                label: 'Add symbol',
                onPress: () {
                  marketWatch.requestMWScrip(context: context, isSubscribe: false);
                  Navigator.pushNamed(context, Routes.searchScrip,
                      arguments: marketWatch.wlName);
                },
                icon: assets.addCircleIcon)
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistView(MarketWatchProvider marketWatch, bool watchlistChanged) {
    // Using a more optimized list to prevent unnecessary rebuilds
    return ListView.separated(
      key: ValueKey(marketWatch.wlName), // Use key to rebuild when watchlist changes
      shrinkWrap: false,
      physics: const BouncingScrollPhysics(),
      itemCount: marketWatch.scrips.length,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (BuildContext context, int idx) {
        final scrip = marketWatch.scrips[idx];
        
        // Use RepaintBoundary to isolate the card from other cards
        return RepaintBoundary(
          child: WatchlistCard(watchListData: scrip),
        );
      },
      // Use cacheExtent to improve smoothness
      cacheExtent: 500,
    );
  }
}
