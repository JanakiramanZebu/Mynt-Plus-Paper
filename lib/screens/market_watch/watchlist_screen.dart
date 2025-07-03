import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:mynt_plus/res/colors.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';

import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_btn.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/snack_bar.dart';
import 'my_stocks/stocks_screen.dart';
import 'watchlist_card.dart';
import 'index/index_screen.dart';
import 'scrip_filter_bottom_sheet.dart';
import 'watchlists_bottom_sheet.dart';

// Mock class to temporarily hold watchlist data with predefined lists included
class MockMarketWatchlist {
  final List<String> values;

  MockMarketWatchlist({required this.values});
}

// Custom delegate for persistent tabs header
class _SliverTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final int selectedTabIndex;
  final List<String>? watchlistNames; // Add watchlist names to track changes

  _SliverTabsDelegate({
    required this.child,
    required this.height,
    required this.selectedTabIndex,
    this.watchlistNames,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // Rebuild when the selected tab index changes OR when watchlist data changes
    if (oldDelegate is _SliverTabsDelegate) {
      // Check if selected tab changed
      bool selectedTabChanged =
          selectedTabIndex != oldDelegate.selectedTabIndex;

      // Check if watchlist data changed (create/update/delete)
      bool watchlistDataChanged = false;
      if (watchlistNames != null && oldDelegate.watchlistNames != null) {
        // Compare lists - check length and content
        watchlistDataChanged =
            watchlistNames!.length != oldDelegate.watchlistNames!.length ||
                !_listsEqual(watchlistNames!, oldDelegate.watchlistNames!);
      } else if (watchlistNames != oldDelegate.watchlistNames) {
        // One is null, the other isn't
        watchlistDataChanged = true;
      }

      return selectedTabChanged || watchlistDataChanged;
    }
    return true;
  }

  // Helper method to compare two lists
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreen();
}

class _WatchListScreen extends State<WatchListScreen>
    with AutomaticKeepAliveClientMixin {
  final PageController _controller = PageController(initialPage: 0);
  final ScrollController _tabScrollController = ScrollController();
  late SwipeActionController swipecontroller;
  bool _isDisposed = false;
  bool _tappedwatch = false;
  String _currentWatchlist = "";
  bool _isPageControllerInitialized = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex =
      0; // Track selected tab index locally for immediate UI updates
  int _lastWatchlistCount =
      0; // Track watchlist count to detect CRUD operations
  bool _isListScrolled = false; // Track if content is scrolled
  bool _isUserScrolling = false; // Track if user is manually scrolling tabs
  DateTime _lastUserScrollTime =
      DateTime.now(); // Track when user last scrolled

  // Simple fixed width for each tab for reliable calculations
  final double tabWidth = 95.0; // Adjusted width to fit abbreviated names

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

    // Add listener to the page controller to reset scroll state on page change
    _controller.addListener(_handlePageScroll);

    // Initialize page controller with saved page index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePageController();

      // Ensure predefined watchlists are loaded properly
      _ensurePredefinedWatchlistsLoaded();
    });

    // Add listener to scroll controller to track user scrolling
    _tabScrollController.addListener(() {
      if (_isDisposed) return;

      // Check if user is actively scrolling
      if (_tabScrollController.position.isScrollingNotifier.value) {
        // User is scrolling - mark as user-initiated scrolling
        _isUserScrolling = true;
        _lastUserScrollTime = DateTime.now();
      } else {
        // Scrolling ended - wait a bit before allowing auto-scroll again
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_isDisposed) {
            _isUserScrolling = false;
          }
        });
      }

      // Force rebuild when scrolling ends to ensure correct tab highlighting
      if (!_tabScrollController.position.isScrollingNotifier.value) {
        setState(() {});
      }
    });

    super.initState();
  }

  // Ensure all predefined watchlists have their data loaded
  void _ensurePredefinedWatchlistsLoaded() async {
    if (_isDisposed) return;

    try {
      final marketWatch =
          ProviderScope.containerOf(context).read(marketWatchProvider);
      final currentWatchlist = marketWatch.wlName;

      print(
          "Ensuring predefined watchlists are loaded. Current watchlist: $currentWatchlist");

      // Make sure we have the predefined watchlist data first
      await marketWatch.fetchPreDefMWScrip(context);

      // Force refresh predefined watchlists
      final predefinedLists = ["Nifty50", "Niftybank", "Sensex", "My Stocks"];

      // Check if the current watchlist is predefined and needs data
      bool isCurrentPredefined = predefinedLists.contains(currentWatchlist);
      if (isCurrentPredefined) {
        print("Current watchlist is predefined: $currentWatchlist");

        // Check if we need to refresh the current predefined watchlist
        if (marketWatch.scrips.isEmpty) {
          print(
              "Current predefined watchlist has no data, fetching data for: $currentWatchlist");
          await marketWatch.fetchMWScrip(currentWatchlist, context);
          await marketWatch.changeWLScrip(currentWatchlist, context);
        }
      }

      // Preload other predefined watchlists in the background
      for (final listName in predefinedLists) {
        // Only load if not the current watchlist (which should be loaded already)
        if (listName != currentWatchlist) {
          // Only load if we don't have cached data
          if (!marketWatch.marketWatchScripData.containsKey(listName) ||
              (marketWatch.marketWatchScripData.containsKey(listName) &&
                  jsonDecode(marketWatch.marketWatchScripData[listName])
                      .isEmpty)) {
            print("Preloading data for watchlist: $listName");
            await marketWatch.fetchMWScrip(listName, context);
          } else {
            print("Skipping preload for $listName - already has cached data");
          }
        }
      }

      // Make sure we re-subscribe to the current watchlist after preloading
      await marketWatch.requestMWScrip(context: context, isSubscribe: true);
    } catch (e) {
      print("Error preloading watchlists: $e");
    }
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

  // Method to handle page controller scroll events
  void _handlePageScroll() {
    // Reset elevation when page changes
    if (_controller.page?.round() != _controller.page && _isListScrolled) {
      // We're in between pages (during animation), reset elevation
      setState(() {
        _isListScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.removeListener(_handlePageScroll);
    _controller.dispose();
    _tabScrollController.dispose();
    swipecontroller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Enhanced tab scrolling to ensure selected tab is always clearly visible
  void _scrollToSelectedTab(int index, {bool force = false}) {
    if (!_tabScrollController.hasClients || _isDisposed) return;

    // Don't auto-scroll if user is manually scrolling tabs (unless forced)
    if (!force && _isUserScrolling) return;

    // Don't auto-scroll if user scrolled tabs recently (unless forced)
    // But reduce the timeout to 1 second for better responsiveness
    if (!force && DateTime.now().difference(_lastUserScrollTime).inSeconds < 1)
      return;

    // Get the viewport width
    final double viewportWidth =
        _tabScrollController.position.viewportDimension;

    // Calculate the ideal position - center the tab in the viewport
    // We want the tab to be in the center of the visible area
    final double targetOffset =
        (index * tabWidth) - (viewportWidth / 2) + (tabWidth / 2);

    // Clamp the value to valid scroll range
    final double scrollTo =
        targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent);

    // Always scroll, even if tab is partially visible, to ensure it's centered
    _tabScrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic, // More pronounced animation curve
    );
  }

  // Method to add visual emphasis to active tab
  void _highlightActiveTab(WidgetRef ref, String wlName) {
    final marketWatchlist =
        ref.read(marketWatchProvider.select((p) => p.marketWatchlist));
    if (marketWatchlist?.values != null) {
      int selectedIndex = marketWatchlist!.values!.indexOf(wlName);
      if (selectedIndex != -1) {
        // Schedule this after the build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && _tabScrollController.hasClients) {
            _scrollToSelectedTab(
                selectedIndex); // Don't force, respect user scrolling

            // Force refresh for predefined watchlists when they become active
            if (wlName == "Nifty50" ||
                wlName == "Niftybank" ||
                wlName == "Sensex") {
              final marketWatch = ref.read(marketWatchProvider);
              final scrips = marketWatch.scrips;

              // Only refresh if there's no data
              if (scrips.isEmpty) {
                print("Forcing data refresh for empty watchlist: $wlName");
                marketWatch.fetchMWScrip(wlName, context).then((_) {
                  // Re-subscribe after fetching fresh data
                  marketWatch.requestMWScrip(
                      context: context, isSubscribe: true);
                });
              }
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer(builder: (context, WidgetRef ref, _) {
      // Use select to watch only specific properties instead of the entire provider
      final wlName = ref.watch(marketWatchProvider.select((p) => p.wlName));
      final originalMarketWatchlist =
          ref.watch(marketWatchProvider.select((p) => p.marketWatchlist));
      final scrips = ref.watch(marketWatchProvider.select((p) => p.scrips));
      final isPreDefWLs =
          ref.watch(marketWatchProvider.select((p) => p.isPreDefWLs));
      final scripsLength =
          ref.watch(marketWatchProvider.select((p) => p.scrips.length));

      final sortBy = ref.watch(marketWatchProvider.select((p) => p.sortByWL));
      final theme = ref.watch(themeProvider);

      // Use the original marketWatchlist data as-is
      final marketWatchlist = originalMarketWatchlist;

      // Ensure page controller is initialized with the correct index
      // This also helps when the user returns to the screen
      if (!_isPageControllerInitialized) {
        final savedIndex =
            ref.read(marketWatchProvider).currentWatchlistPageIndex;
        if (savedIndex >= 0 &&
            savedIndex < (marketWatchlist?.values?.length ?? 0)) {
          // Set the selected tab index for immediate UI updates
          _selectedTabIndex = savedIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed && _controller.hasClients) {
              _controller.jumpToPage(savedIndex);
              _isPageControllerInitialized = true;

              // When initializing, ensure the current page has data
              final currentName = marketWatchlist?.values?[savedIndex];
              if (currentName != null &&
                  (currentName == "Nifty50" ||
                      currentName == "Niftybank" ||
                      currentName == "Sensex")) {
                // Immediately force refresh for predefined watchlists
                ref
                    .read(marketWatchProvider)
                    .fetchMWScrip(currentName, context)
                    .then((_) {
                  // And re-subscribe to ensure we get updates
                  ref
                      .read(marketWatchProvider)
                      .requestMWScrip(context: context, isSubscribe: true);
                });
              }
            }
          });
        }
      }

      // Check if watchlist changed to reduce rebuilds when only prices change
      bool watchlistChanged = _currentWatchlist != wlName;
      if (watchlistChanged) {
        _currentWatchlist = wlName;
      }

      // Always sync the selected tab index with the provider's current watchlist
      // This handles cases where watchlists are created/edited/deleted
      bool watchlistCountChanged = false;
      if (marketWatchlist?.values != null) {
        final watchlistCount = marketWatchlist!.values!.length;

        // Detect CRUD operations by checking if watchlist count changed
        // BUT exclude the change from adding predefined lists (which increases count by 4)
        watchlistCountChanged =
            _lastWatchlistCount != 0 && _lastWatchlistCount != watchlistCount;

        // Check if this is just predefined lists being added (count increased by exactly 4)
        bool isPredefinedAddition = (_lastWatchlistCount > 0) &&
            (watchlistCount == _lastWatchlistCount + 4) &&
            marketWatchlist!.values!.contains("My Stocks") &&
            marketWatchlist!.values!.contains("Nifty50") &&
            marketWatchlist!.values!.contains("Niftybank") &&
            marketWatchlist!.values!.contains("Sensex");

        _lastWatchlistCount = watchlistCount;

        // If watchlist count changed but it's NOT just predefined lists being added, then it's a real CRUD operation
        if (watchlistCountChanged && !isPredefinedAddition) {
          print(
              "DEBUG UI: Real CRUD operation detected, refreshing watchlist data...");
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!_isDisposed) {
              try {
                final marketWatch = ref.read(marketWatchProvider);
                print(
                    "Watchlist count changed, refreshing complete watchlist data...");

                // Refresh predefined watchlists to ensure they're included
                await marketWatch.fetchPreDefMWScrip(context);

                // Also refresh the current watchlist data
                await marketWatch.fetchMWScrip(marketWatch.wlName, context);
              } catch (e) {
                print("Error refreshing watchlist data after CRUD: $e");
              }
            }
          });
        } else if (isPredefinedAddition) {
          print(
              "DEBUG UI: Predefined lists addition detected, no additional refresh needed");
        }

        final newIndex = marketWatchlist!.values!.indexOf(wlName);

        // Ensure selected index is valid and matches current watchlist
        bool needsUpdate = false;
        int targetIndex = _selectedTabIndex;

        if (newIndex != -1) {
          // Current watchlist found in the list
          if (newIndex != _selectedTabIndex) {
            targetIndex = newIndex;
            needsUpdate = true;
          }
        } else {
          // Current watchlist not found, might be deleted
          // Clamp to valid range
          if (_selectedTabIndex >= watchlistCount) {
            targetIndex = watchlistCount - 1;
            needsUpdate = true;
          }
        }

        // Ensure index is never negative
        if (targetIndex < 0 && watchlistCount > 0) {
          targetIndex = 0;
          needsUpdate = true;
        }

        if (needsUpdate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) {
              setState(() {
                _selectedTabIndex = targetIndex;
              });
            }
          });
        }
      }

      // Only auto-highlight tab if user isn't manually scrolling tabs
      if (!_isUserScrolling &&
          DateTime.now().difference(_lastUserScrollTime).inSeconds >= 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            _highlightActiveTab(ref, wlName);
          }
        });
      }

      return SafeArea(
        child: NestedScrollView(
          // Remove conditional physics to ensure consistent scrolling
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // Search bar that scrolls away normally
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0x80F1F3F8),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        // Search tappable area
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              final marketWatch = ref.read(marketWatchProvider);
                              marketWatch.requestMWScrip(
                                  context: context, isSubscribe: false);
                              Navigator.pushNamed(context, Routes.searchScrip,
                                  arguments: wlName);
                            },
                            child: Row(
                              children: [
                                // Search icon
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 16, right: 10),
                                    child: SvgPicture.asset(
                                      assets.search,
                                      width: 16,
                                      height: 16,
                                    )),

                                // Search text
                                Expanded(
                                  child: TextWidget.subText(
                                    text: 'Search & Add stocks',
                                    color: theme.isDarkMode ? colors.textPrimaryDark :  colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Suffix: Filter button
                        if (isPreDefWLs != "Yes" && scripsLength > 1)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                onTap: () async {
                                  // Add delay for visual feedback
                                  await Future.delayed(const Duration(milliseconds: 150));                                  
                                  
                                  FocusScope.of(context).unfocus();
                                  showModalBottomSheet(
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    context: context,
                                    builder: (context) =>
                                        const ScripFilterBottomSheet(),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    assets.filterLines,
                                    width: 18,
                                    height: 18,
                                    color: colors.colorGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Pinned tabs section
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabsDelegate(
                  height: 40,
                  selectedTabIndex:
                      _selectedTabIndex, // Pass the selected index to force rebuilds
                  watchlistNames: marketWatchlist?.values?.cast<
                      String>(), // Pass watchlist names to detect changes
                  child: Container(
                    padding: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorWhite,
                      // tab bottom border
                      border: Border(
                        bottom: BorderSide(
                          color: theme.isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFE0E0E0),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Container(
                      height: 40,
                      child: Row(
                        children: [
                          // Menu icon at the start of tabs
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 4),
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                onTap: () async {
                                  // Add delay for visual feedback
                                  await Future.delayed(
                                      const Duration(milliseconds: 150));

                                  showModalBottomSheet(
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    context: context,
                                    builder: (context) => WatchlistsBottomSheet(
                                        currentWLName: wlName),
                                  );
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  child: Center(
                                    child: Icon(
                                      Icons.menu,
                                      size: 24,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Watchlist tabs
                          Expanded(
                            child: _buildWatchlistTabs(
                                ref, wlName, marketWatchlist),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: PageView.builder(
            itemCount: marketWatchlist?.values?.length ?? 0,
            scrollDirection: Axis.horizontal,
            controller: _controller,
            onPageChanged: (int d) async {
              // Immediately update selected tab index for instant UI feedback
              setState(() {
                _tappedwatch = true;
                _selectedTabIndex = d;
              });

              // Force scroll to the new active tab since user swiped to change watchlist
              _scrollToSelectedTab(d, force: true);

              // Save the current page index to the provider
              ref.read(marketWatchProvider).setCurrentWatchlistPageIndex(d);

              // Get the new watchlist name before unsubscribing
              String newWatchlistName = marketWatchlist!.values![d];

              // Debug log
              print("Page changed to watchlist: $newWatchlistName (index: $d)");

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

                // For predefined lists, ensure we have data
                if (newWatchlistName == "Nifty50" ||
                    newWatchlistName == "Niftybank" ||
                    newWatchlistName == "Sensex") {
                  // Explicitly check for predefined data and force refresh if needed
                  bool hasCachedData = marketWatch.marketWatchScripData
                      .containsKey(newWatchlistName);
                  if (!hasCachedData) {
                    print(
                        "No cached data for $newWatchlistName, forcing refresh");
                    await marketWatch.fetchPreDefMWScrip(context);
                  }
                }
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
              // ---------- 1.  name & data that belong to THIS page ----------
              final String pageName = marketWatchlist!.values![index];
              final List pageScrips = (pageName == marketWatch.wlName)
                  ? marketWatch.scrips
                  : jsonDecode(
                      marketWatch.marketWatchScripData[pageName] ?? '[]');

              // ---------- 2.  give the page its own key so Flutter won’t recycle ----------
              return KeyedSubtree(
                key: ValueKey(pageName),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await marketWatch.fetchMWScrip(pageName, context);
                  },
                  child: pageName == "My Stocks"
                      ? const StocksScreen()
                      : pageScrips.isEmpty
                          ? _buildEmptyState(theme, marketWatch, ref)
                          : _buildWatchlistView(
                              pageScrips,
                              /*watchlistChanged:*/ false,
                              ["Nifty50", "Niftybank", "Sensex", "My Stocks"]
                                      .contains(pageName)
                                  ? "Yes"
                                  : "No",
                              sortBy,
                            ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildWatchlistTabs(
      WidgetRef ref, String wlName, dynamic marketWatchlist) {
    final theme = ref.watch(themeProvider);

    if (marketWatchlist == null || marketWatchlist.values == null) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _tabScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: marketWatchlist.values.length,
      itemBuilder: (context, index) {
        final name = marketWatchlist.values[index];
        final isSelected = index == _selectedTabIndex;

        // Debug print to check if selection is working
        if (isSelected) {
          print(
              "Tab $index ($name) is selected, _selectedTabIndex: $_selectedTabIndex");
        }

        // Fixed width container to define the tab size
        return Container(
          width: tabWidth,
          margin: const EdgeInsets.only(right: 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.01)
                  : Colors.black.withOpacity(0.01),
              onTapDown: (_) {
                // Provide haptic feedback for tab tap
                HapticFeedback.lightImpact();
              },
              onTap: () async {
                // Add delay for visual feedback
                await Future.delayed(const Duration(milliseconds: 150));
                // Only handle tap if it's actually a different tab
                if (index == _selectedTabIndex) {
                  return; // Don't do anything if tapping the already selected tab
                }

                // First immediately scroll to center the tapped tab (force it since user tapped)
                _scrollToSelectedTab(index, force: true);

                final marketWatch = ref.read(marketWatchProvider);

                // Force immediate UI update by updating selected tab index
                setState(() {
                  _selectedTabIndex = index;
                  _currentWatchlist = name;
                });

                // Use jumpToPage for instant navigation to prevent active color traveling
                _controller.jumpToPage(index);

                // Then update data after the UI has responded
                await marketWatch.requestMWScrip(
                    context: context, isSubscribe: false);

                if (name == "My Stocks" ||
                    name == "Nifty50" ||
                    name == "Niftybank" ||
                    name == "Sensex") {
                  await marketWatch.changeWlName(name, "Yes");
                } else {
                  await marketWatch.changeWlName(name, "No");
                }

                await marketWatch.changeWLScrip(name, context);

                // Subscribe to data for all watchlist types
                await marketWatch.requestMWScrip(
                    context: context, isSubscribe: true);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: TextWidget.subText(
                        text: _formatTabName(name),
                        color: isSelected
                            ? theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        theme: theme.isDarkMode,
                        fw: isSelected ? 0 : null),
                  ),
                  // Animated underline indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 2,
                    width: isSelected ? tabWidth - 18 : 0,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: colors.colorBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Format tab names to be short but recognizable
  String _formatTabName(String name) {
    if (name == "My Stocks") return "Holdings";
    if (name == "Nifty50") return "Nifty 50";
    if (name == "Niftybank") return "Nifty Bank";
    if (name == "Sensex") return "Sensex";

    // For user-created watchlists, keep the name but ensure it's capitalized
    if (name.isEmpty) return "";
    return name.length <= 10
        ? "${name[0].toUpperCase()}${name.substring(1)}"
        : "${name.substring(0, 9)}..";
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
            CustomTextBtn(
                label: 'Add Symbol',
                onPress: () {
                  marketWatch.requestMWScrip(
                      context: context, isSubscribe: false);
                  Navigator.pushNamed(context, Routes.searchScrip,
                      arguments: marketWatch.wlName);
                },
                icon: assets.addCircleIcon),
            TextWidget.subText(
                text: "No symbol in this watchlist",
                color: colors.colorBlack,
                theme: theme.isDarkMode,
                fw: 00),
            const SizedBox(height: 8),
            SizedBox(
              width: 250,
              child: Center(
                child: TextWidget.paraText(
                    text:
                        "Use the search box above to find and add stocks, indices, futures or options. ",
                    color: const Color(0xff666666),
                    theme: theme.isDarkMode,
                    align: TextAlign.center,
                    fw: 00),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistView(
      List scrips, bool watchlistChanged, String isPreDefWLs, String sortBy) {
    // Debug output to check the data structure
    print("Building watchlist view with ${scrips.length} items");
    if (scrips.isNotEmpty) {
      print("First item in watchlist: ${scrips[0]}");
      // Check if key fields that the WatchlistCard expects are present
      if (scrips[0] is Map) {
        final item = scrips[0];
        print("Has token: ${item.containsKey('token')}");
        print("Has tsym: ${item.containsKey('tsym')}");
        print("Has exch: ${item.containsKey('exch')}");
        print("tsym value: ${item['tsym']}");
      }
    }

    // Using a more optimized list to prevent unnecessary rebuilds
    // Add sortBy parameter to create a unique key that changes when sort changes
    return ListView.separated(
      key: ValueKey(
          "${scrips.length}_$sortBy"), // Use key based on list length AND sort order

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
