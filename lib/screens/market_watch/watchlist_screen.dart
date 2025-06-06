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

class _WatchListScreen extends State<WatchListScreen>
    with AutomaticKeepAliveClientMixin {
  final PageController _controller = PageController();
  late SwipeActionController swipecontroller;
  bool _isDisposed = false;
  String _currentWatchlist = "";
  bool _isPageControllerInitialized = false;

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

    // Initialize page controller with saved page index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePageController();
    });

    super.initState();
  }

  // Method to initialize page controller with saved index
  void _initializePageController() {
    if (_isDisposed || _isPageControllerInitialized) return;

    try {
      // Get the current index from the provider using Consumer
      final marketWatch =
          ProviderScope.containerOf(context).read(marketWatchProvider);
      final savedIndex = marketWatch.currentWatchlistPageIndex;

      // Only update if we have a valid index and the controller is not disposed
      if (savedIndex >= 0 && _controller.hasClients) {
        _controller.jumpToPage(savedIndex);
        _isPageControllerInitialized = true;
      }
    } catch (e) {
      print("Error initializing page controller: $e");
    }
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
      final marketWatchlist =
          ref.watch(marketWatchProvider.select((p) => p.marketWatchlist));
      final scrips = ref.watch(marketWatchProvider.select((p) => p.scrips));
      final isPreDefWLs =
          ref.watch(marketWatchProvider.select((p) => p.isPreDefWLs));
      final sortBy = ref.watch(marketWatchProvider
          .select((p) => p.sortByWL)); // Watch sort order changes
      final theme = ref.read(themeProvider);

      // Ensure page controller is initialized with the correct index
      // This also helps when the user returns to the screen
      if (!_isPageControllerInitialized) {
        final savedIndex =
            ref.read(marketWatchProvider).currentWatchlistPageIndex;
        if (savedIndex >= 0 &&
            savedIndex < (marketWatchlist?.values?.length ?? 0)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed && _controller.hasClients) {
              _controller.jumpToPage(savedIndex);
              _isPageControllerInitialized = true;
            }
          });
        }
      }

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
          // Save the current page index to the provider
          ref.read(marketWatchProvider).setCurrentWatchlistPageIndex(d);

          // Get the new watchlist name before unsubscribing
          String newWatchlistName = marketWatchlist!.values![d];

          // Get provider instance for method calls
          final marketWatch = ref.read(marketWatchProvider);

          // Unsubscribe from current watchlist
          await marketWatch.requestMWScrip(
              context: context, isSubscribe: false);

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
            await marketWatch.requestMWScrip(
                context: context, isSubscribe: true);
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
                    : _buildWatchlistView(scrips, watchlistChanged, isPreDefWLs,
                        sortBy), // Pass sortBy to rebuild on sort changes
          );
        },
      );
    });
  }

  Widget _buildEmptyState(
      ThemesProvider theme, MarketWatchProvider marketWatch, WidgetRef ref) {
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
                  marketWatch.requestMWScrip(
                      context: context, isSubscribe: false);
                  Navigator.pushNamed(context, Routes.searchScrip,
                      arguments: marketWatch.wlName);
                },
                icon: assets.addCircleIcon)
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistView(
      List scrips, bool watchlistChanged, String isPreDefWLs, String sortBy) {
    // Using a more optimized list to prevent unnecessary rebuilds
    // Add sortBy parameter to create a unique key that changes when sort changes
    return ListView.separated(
      key: ValueKey(
          "${scrips.length}_$sortBy"), // Use key based on list length AND sort order
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
