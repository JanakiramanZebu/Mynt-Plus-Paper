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
    
    return Consumer(builder: (context, WidgetRef ref, _) {
      // Use select to watch only specific properties instead of the entire provider
      final wlName = ref.watch(marketWatchProvider.select((p) => p.wlName));
      final marketWatchlist = ref.watch(marketWatchProvider.select((p) => p.marketWatchlist));
      final scrips = ref.watch(marketWatchProvider.select((p) => p.scrips));
      final isPreDefWLs = ref.watch(marketWatchProvider.select((p) => p.isPreDefWLs));
      final theme = ref.read(themeProvider);
      
      // Check if watchlist changed to reduce rebuilds when only prices change
      bool watchlistChanged = _currentWatchlist != wlName;
      if (watchlistChanged) {
        _currentWatchlist = wlName;
      }

      return PageView.builder(
        itemCount: marketWatchlist?.values?.length ?? 0,
        scrollDirection: Axis.horizontal,
        controller: _controller,
        onPageChanged: (int d) async {
          // Get the new watchlist name before unsubscribing
          String newWatchlistName = marketWatchlist!.values![d];
          
          // Get provider instance for method calls
          final marketWatch = ref.read(marketWatchProvider);
          
          // Unsubscribe from current watchlist
          await marketWatch.requestMWScrip(context: context, isSubscribe: false);
          
          // Change to the new watchlist with proper flag
          if (newWatchlistName == "My Stocks" ||
              newWatchlistName == "Nifty50" ||
              newWatchlistName == "Niftybank" ||
              newWatchlistName == "Sensex") {
            await marketWatch.changeWlName(newWatchlistName, "Yes");
          } else {
            await marketWatch.changeWlName(newWatchlistName, "No");
          }
          
          // Change watchlist scrips
          await marketWatch.changeWLScrip(marketWatch.wlName, context);
          
          // Special handling for My Stocks - explicitly subscribe to index data
          if (newWatchlistName == "My Stocks") {
            // Force resubscription to ensure index data is included
            await marketWatch.requestMWScrip(context: context, isSubscribe: true);
          }
        },
        itemBuilder: (BuildContext context, int index) {
          final marketWatch = ref.read(marketWatchProvider);
          
          return RefreshIndicator(
            onRefresh: () async {
              await marketWatch.fetchMWScrip(wlName, context);
            },
            child: wlName == "My Stocks"
                ? const StocksScreen()
                : scrips.isEmpty
                    ? _buildEmptyState(theme, marketWatch, ref)
                    : _buildWatchlistView(scrips, watchlistChanged, isPreDefWLs),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(ThemesProvider theme, MarketWatchProvider marketWatch, WidgetRef ref) {
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

  Widget _buildWatchlistView(List scrips, bool watchlistChanged, String isPreDefWLs) {
    // Using a more optimized list to prevent unnecessary rebuilds
    return ListView.separated(
      key: ValueKey(scrips.length), // Use key based on list length for more precise rebuilds
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: scrips.length,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (BuildContext context, int idx) {
        final scrip = scrips[idx];
        
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
