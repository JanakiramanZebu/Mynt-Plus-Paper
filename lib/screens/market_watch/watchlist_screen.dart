import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
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
import 'index/index_screen.dart';
import 'my_stocks/stocks_screen.dart';
import 'scrip_filter_bottom_sheet.dart';
import 'watchlist_card.dart';
import 'watchlists_bottom_sheet.dart';

/// ---------------------------------------------------------------------------
/// Mock class ­(only for local dev / tests – keep as-is)
/// ---------------------------------------------------------------------------
class MockMarketWatchlist {
  final List<String> values;
  MockMarketWatchlist({required this.values});
}

/// ---------------------------------------------------------------------------
/// Sliver header that holds the horizontal tabs
/// ---------------------------------------------------------------------------
class _SliverTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final String selectedWatchlistName;
  final List<String>? watchlistNames;

  _SliverTabsDelegate({
    required this.child,
    required this.height,
    required this.selectedWatchlistName,
    this.watchlistNames,
  });

  @override
  Widget build(BuildContext ctx, double shrink, bool overlaps) => child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) {
    if (old is _SliverTabsDelegate) {
      final listChanged = !_listsEqual(watchlistNames, old.watchlistNames);
      final nameChanged = selectedWatchlistName != old.selectedWatchlistName;
      return listChanged || nameChanged;
    }
    return true;
  }

  bool _listsEqual(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// ---------------------------------------------------------------------------
/// Watch-list main screen
/// ---------------------------------------------------------------------------
class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen>
    with AutomaticKeepAliveClientMixin {
  /* ------------------------------ controllers ----------------------------- */
  final ScrollController _tabScrollController = ScrollController();
  late final SwipeActionController _swipeController;
  late final PageController _pageController;

  /* ------------------------------- internal ------------------------------- */
  final TextEditingController _searchController = TextEditingController();
  final double _tabWidth = 95.0;
  final List<String> _lastTabNames = [];

  Timer? _scrollDebounce;
  String _lastWatchlistName = '';
  int _currentPageIndex = 0;
  bool _isUserScrolling = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  /* ------------------------------------------------------------------------ */
  /*                                lifecycle                                */
  /* ------------------------------------------------------------------------ */
  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Watchlist screen',
      screenClass: 'WatchList_screen',
    );

    _swipeController = SwipeActionController(
      selectedIndexPathsChangeCallback:
          (changed, selected, currentCount) => _safeSetState(() {}),
    );

    _pageController = PageController(initialPage: 0);
    _tabScrollController.addListener(_handleTabScroll);

    // Use post-frame callback to avoid provider modification during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _initializeWatchlists();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollDebounce?.cancel();
    _tabScrollController.dispose();
    _pageController.dispose();
    _swipeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /* ------------------------------------------------------------------------ */
  /*                             initialization                               */
  /* ------------------------------------------------------------------------ */
  Future<void> _initializeWatchlists() async {
    if (_isDisposed) return;

    try {
      await _ensurePredefinedWatchlistsLoaded();
      
      // Initialize page controller after data is loaded
      if (!_isDisposed) {
        final marketWatch = ProviderScope.containerOf(context).read(marketWatchProvider);
        final watchList = marketWatch.marketWatchlist;
        
        if (watchList?.values != null) {
          final currentIndex = watchList!.values!.indexOf(marketWatch.wlName);
          if (currentIndex != -1) {
            _currentPageIndex = currentIndex;
            if (_pageController.hasClients) {
              _pageController.jumpToPage(currentIndex);
            }
            _scrollToSelectedTab(currentIndex, force: true);
          }
        }
        
        _safeSetState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing watchlists: $e');
    }
  }

  /* ------------------------------------------------------------------------ */
  /*                             scroll management                            */
  /* ------------------------------------------------------------------------ */
  void _handleTabScroll() {
    if (_isDisposed) return;

    // user started / stopped scrolling
    if (_tabScrollController.position.isScrollingNotifier.value) {
      _isUserScrolling = true;
    } else {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!_isDisposed) _isUserScrolling = false;
      });
    }

    // repaint header for fading/shadow if needed
    if (!_tabScrollController.position.isScrollingNotifier.value) {
      _safeSetState(() {});
    }
  }

  void _scrollToSelectedTab(int index, {bool force = false}) {
    if (!_tabScrollController.hasClients || _isDisposed) return;
    if (!force && _isUserScrolling) return;

    final viewW = _tabScrollController.position.viewportDimension;
    final max = _tabScrollController.position.maxScrollExtent;

    final target = (index * _tabWidth) - (viewW / 2) + (_tabWidth / 2);
    final offset = target.clamp(0.0, max);

    if ((_tabScrollController.offset - offset).abs() < 1.0) return;

    _tabScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToWatchlistTab(WidgetRef ref, String wlName) {
    final list = ref.read(marketWatchProvider.select((p) => p.marketWatchlist))?.values;
    if (list == null) return;

    final idx = list.indexOf(wlName);
    if (idx == -1) return;

    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 50), () {
      if (!_isDisposed) _scrollToSelectedTab(idx, force: true);
    });
  }

  /* ------------------------------------------------------------------------ */
  /*                           data initialisation                            */
  /* ------------------------------------------------------------------------ */
  Future<void> _ensurePredefinedWatchlistsLoaded() async {
    if (_isDisposed) return;

    try {
      final marketWatch = ProviderScope.containerOf(context).read(marketWatchProvider);
      final current = marketWatch.wlName;

      await marketWatch.fetchPreDefMWScrip(context);

      const predefined = ['Nifty50', 'Niftybank', 'Sensex', 'My Stocks'];

      // make sure current predefined list has data
      if (predefined.contains(current) && marketWatch.scrips.isEmpty) {
        await marketWatch.fetchMWScrip(current, context);
        await marketWatch.changeWLScrip(current, context);
      }

      // warm-up the others
      for (final name in predefined) {
        if (name == current) continue;
        final cached = marketWatch.marketWatchScripData[name];
        if (cached == null || jsonDecode(cached).isEmpty) {
          await marketWatch.fetchMWScrip(name, context);
        }
      }

      // Use post-frame callback to avoid provider modification during build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!_isDisposed) {
          await marketWatch.requestMWScrip(context: context, isSubscribe: true);
        }
      });
    } catch (e) {
      debugPrint('Error preloading watchlists: $e');
    }
  }

  /* ------------------------------------------------------------------------ */
  /*                           page change handling                           */
  /* ------------------------------------------------------------------------ */
  Future<void> _handlePageChanged(int pageIndex, WidgetRef ref) async {
    if (_isDisposed) return;

    final marketWatch = ref.read(marketWatchProvider);
    final watchList = marketWatch.marketWatchlist;
    
    if (watchList?.values == null || pageIndex >= watchList!.values!.length) return;

    final newWatchlistName = watchList.values![pageIndex];
    
    // Update current page index immediately
    _currentPageIndex = pageIndex;
    
    // Scroll tab to center
    _scrollToSelectedTab(pageIndex, force: true);

    try {
      // Unsubscribe from current watchlist
      await marketWatch.requestMWScrip(context: context, isSubscribe: false);

      // Change to new watchlist
      const predefined = ['My Stocks', 'Nifty50', 'Niftybank', 'Sensex'];
      final isPredefined = predefined.contains(newWatchlistName);
      
      await marketWatch.changeWlName(newWatchlistName, isPredefined ? 'Yes' : 'No');
      await marketWatch.changeWLScrip(newWatchlistName, context);
      
      // Subscribe to new watchlist
      await marketWatch.requestMWScrip(context: context, isSubscribe: true);
    } catch (e) {
      debugPrint('Error changing watchlist: $e');
    }
  }

  /* ------------------------------------------------------------------------ */
  /*                           tab tap handling                               */
  /* ------------------------------------------------------------------------ */
  Future<void> _handleTabTap(String name, int index, WidgetRef ref) async {
    if (_currentPageIndex == index) return;

    // Update current page index immediately
    _currentPageIndex = index;
    
    // Jump to page immediately for responsive UI
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }

    // Handle the actual data change
    await _handlePageChanged(index, ref);
  }

  /* ------------------------------------------------------------------------ */
  /*                                  build                                   */
  /* ------------------------------------------------------------------------ */
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer(builder: (ctx, ref, _) {
      final wlName = ref.watch(marketWatchProvider.select((p) => p.wlName));
      final watchList = ref.watch(marketWatchProvider.select((p) => p.marketWatchlist));
      final isPreDef = ref.watch(marketWatchProvider.select((p) => p.isPreDefWLs));
      final sortBy = ref.watch(marketWatchProvider.select((p) => p.sortByWL));
      final theme = ref.watch(themeProvider);

      /* ---------- keep tab centred when the *list* itself changes ---------- */
      final names = watchList?.values?.cast<String>() ?? [];
      if (!_listsEqual(names, _lastTabNames)) {
        _lastTabNames
          ..clear()
          ..addAll(names);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToWatchlistTab(ref, wlName),
        );
      }

      /* ---------- auto-scroll when the selected list name changes ---------- */
      if (_lastWatchlistName != wlName) {
        _lastWatchlistName = wlName;
        
        // Update current page index when watchlist name changes
        final currentIndex = names.indexOf(wlName);
        if (currentIndex != -1 && _currentPageIndex != currentIndex) {
          _currentPageIndex = currentIndex;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(currentIndex);
          }
        }
        
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToWatchlistTab(ref, wlName),
        );
      }

      return SafeArea(
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (_, inner) => [
            _buildSearchBar(ref, theme, wlName, isPreDef, watchList?.values?.length ?? 0),
            _buildPinnedTabs(ref, theme, watchList, wlName),
          ],
          body: _buildPageView(ref, theme, watchList, sortBy),
        ),
      );
    });
  }

  /* ------------------------------------------------------------------------ */
  /*                            PageView builder                              */
  /* ------------------------------------------------------------------------ */
  Widget _buildPageView(WidgetRef ref, ThemesProvider theme, dynamic watchList, String sortBy) {
    if (watchList?.values == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: watchList.values.length,
      onPageChanged: (index) {
        // Only handle page change if it's different from current
        if (index != _currentPageIndex) {
          _handlePageChanged(index, ref);
        }
      },
      itemBuilder: (context, index) {
        final pageName = watchList.values[index];
        final marketWatch = ref.read(marketWatchProvider);
        
        // Get scrips for this specific page
        final List pageScrips = (pageName == marketWatch.wlName)
            ? marketWatch.scrips
            : jsonDecode(marketWatch.marketWatchScripData[pageName] ?? '[]');

        return KeyedSubtree(
          key: ValueKey(pageName),
          child: RefreshIndicator(
            onRefresh: () async {
              await marketWatch.fetchMWScrip(pageName, context);
            },
            child: _buildPageContent(ref, theme, pageName, pageScrips, sortBy),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(WidgetRef ref, ThemesProvider theme, String pageName, List scrips, String sortBy) {
    if (pageName == 'My Stocks') {
      return const StocksScreen();
    }

    if (scrips.isEmpty) {
      return _buildEmptyState(theme, ref.read(marketWatchProvider));
    }

    return _buildWatchlistView(scrips, sortBy);
  }

  /* ------------------------------------------------------------------------ */
  /*                               UI helpers                                 */
  /* ------------------------------------------------------------------------ */
  SliverToBoxAdapter _buildSearchBar(
    WidgetRef ref,
    ThemesProvider theme,
    String wlName,
    String isPreDef,
    int scripLen,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: colors.searchBg,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              /* ------------------------------ search ----------------------------- */
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    final mw = ref.read(marketWatchProvider);
                    // Use post-frame callback to avoid provider modification during build
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await mw.requestMWScrip(context: context, isSubscribe: false);
                    });
                    Navigator.pushNamed(
                      context,
                      Routes.searchScrip,
                      arguments: wlName,
                    );
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      SvgPicture.asset(assets.searchIcon, width: 18, height: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextWidget.subText(
                          text: 'Search & add',
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          theme: theme.isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /* ------------------------------ filter ----------------------------- */
              if (isPreDef != 'Yes' && scripLen > 1)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.15)
                          : Colors.black.withOpacity(.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.08)
                          : Colors.black.withOpacity(.08),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        showModalBottomSheet(
                          useSafeArea: true,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          context: context,
                          builder: (_) => const ScripFilterBottomSheet(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          assets.searchFilter,
                          width: 16,
                          height: 16,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader _buildPinnedTabs(
    WidgetRef ref,
    ThemesProvider theme,
    dynamic watchList,
    String wlName,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabsDelegate(
        height: 40,
        selectedWatchlistName: wlName,
        watchlistNames: watchList?.values?.cast<String>(),
        child: Container(
          padding: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            border: Border(
              bottom: BorderSide(
                color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
              ),
            ),
          ),
          child: Row(
            children: [
              /* ------------------------------- menu ------------------------------ */
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: theme.isDarkMode
                        ? Colors.white.withOpacity(.15)
                        : Colors.black.withOpacity(.15),
                    highlightColor: theme.isDarkMode
                        ? Colors.white.withOpacity(.08)
                        : Colors.black.withOpacity(.08),
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 150));
                      showModalBottomSheet(
                        useSafeArea: true,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        context: context,
                        builder: (_) => WatchlistsBottomSheet(
                          currentWLName: wlName,
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: SvgPicture.asset(
                          assets.hamMenu,
                          width: 20,
                          height: 20,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /* ----------------------------- tab list ---------------------------- */
              Expanded(
                child: _buildWatchlistTabs(ref, wlName, watchList, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistTabs(
    WidgetRef ref,
    String wlName,
    dynamic watchList,
    ThemesProvider theme,
  ) {
    if (watchList?.values == null) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        key: const PageStorageKey<String>('watchlistTabs'),
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: watchList.values.length,
        itemBuilder: (_, i) {
          final name = watchList.values[i];
          final selected = name == wlName;

          return SizedBox(
            width: _tabWidth,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: theme.isDarkMode
                    ? Colors.white.withOpacity(.05)
                    : Colors.black.withOpacity(.05),
                highlightColor: theme.isDarkMode
                    ? Colors.white.withOpacity(.01)
                    : Colors.black.withOpacity(.01),
                onTapDown: (_) => HapticFeedback.lightImpact(),
                onTap: () => _handleTabTap(name, i, ref),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /* ------------------------------ label ----------------------------- */
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: TextWidget.subText(
                        text: _formatTabName(name),
                        color: selected
                            ? (theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight)
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        theme: theme.isDarkMode,
                        fw: selected ? 2 : null,
                      ),
                    ),

                    /* ------------------------------ bar ------------------------------- */
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 2,
                      width: selected ? _tabWidth - 18 : 0,
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
      ),
    );
  }

  Widget _buildEmptyState(ThemesProvider theme, MarketWatchProvider mw) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextBtn(
              label: 'Add Symbol',
              icon: assets.addCircleIcon,
              onPress: () {
                // Use post-frame callback to avoid provider modification during build
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await mw.requestMWScrip(context: context, isSubscribe: false);
                });
                Navigator.pushNamed(
                  context,
                  Routes.searchScrip,
                  arguments: mw.wlName,
                );
              },
            ),
            const SizedBox(height: 8),
            TextWidget.subText(
              text: 'No symbol in this watchlist',
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              theme: theme.isDarkMode,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 250,
              child: TextWidget.paraText(
                text:
                    'Use the search box above to find and add stocks, indices, futures or options.',
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                theme: theme.isDarkMode,
                align: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistView(List scrips, String sortBy) {
    return ListView.separated(
      key: ValueKey('${scrips.length}_$sortBy'),
      itemCount: scrips.length,
      cacheExtent: 500,
      separatorBuilder: (_, __) => const ListDivider(),
      itemBuilder: (_, i) =>
          RepaintBoundary(child: WatchlistCard(watchListData: scrips[i])),
    );
  }

  /* ------------------------------------------------------------------------ */
  /*                             small utilities                              */
  /* ------------------------------------------------------------------------ */
  String _formatTabName(String v) {
    if (v == 'My Stocks') return 'Holdings';
    if (v == 'Nifty50') return 'Nifty 50';
    if (v == 'Niftybank') return 'Nifty Bank';
    if (v == 'Sensex') return 'Sensex';
    return v.isEmpty
        ? ''
        : v.length <= 10
            ? '${v[0].toUpperCase()}${v.substring(1)}'
            : '${v.substring(0, 9)}..';
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }
}
