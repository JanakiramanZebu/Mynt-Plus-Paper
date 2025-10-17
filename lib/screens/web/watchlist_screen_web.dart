import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../utils/responsive_modal.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../res/global_state_text.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_text_btn.dart';
import '../../sharedWidget/list_divider.dart';
import '../market_watch/my_stocks/stocks_screen.dart';
import '../market_watch/scrip_filter_bottom_sheet.dart';
import 'watchlist_card_web.dart';
import '../market_watch/watchlists_bottom_sheet.dart';

class MockMarketWatchlist {
  final List<String> values;
  MockMarketWatchlist({required this.values});
}

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

class WatchListScreenWeb extends StatefulWidget {
  const WatchListScreenWeb({super.key});

  @override
  State<WatchListScreenWeb> createState() => _WatchListScreenWebState();
}

class _WatchListScreenWebState extends State<WatchListScreenWeb>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _tabScrollController = ScrollController();
  late final SwipeActionController _swipeController;
  late final PageController _pageController;

  final TextEditingController _searchController = TextEditingController();
  final double _tabWidth = 120.0; // Slightly wider for web
  final List<String> _lastTabNames = [];

  Timer? _scrollDebounce;
  String _lastWatchlistName = '';
  int _currentPageIndex = 0;
  bool _isUserScrolling = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Watchlist screen web',
      screenClass: 'WatchList_screen_web',
    );

    _swipeController = SwipeActionController(
      selectedIndexPathsChangeCallback: (changed, selected, currentCount) =>
          _safeSetState(() {}),
    );

    _tabScrollController.addListener(_handleTabScroll);
  }

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Initialize PageController with stored page index from provider
      final marketWatch =
          ProviderScope.containerOf(context).read(marketWatchProvider);
      _pageController =
          PageController(initialPage: marketWatch.currentWatchlistPageIndex);
      _currentPageIndex = marketWatch.currentWatchlistPageIndex;

      _isInitialized = true;

      // Initialize immediately with stored data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          _initializeWithStoredData();
        }
      });

      // Load additional data in background
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensurePredefinedWatchlistsLoaded();
      });
    }
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

  /// Initialize immediately with existing data - no loader needed
  void _initializeWithStoredData() {
    if (_isDisposed || !mounted) return;

    // Set tab scroll position to the stored page index
    _scrollToSelectedTab(_currentPageIndex, force: true);

    // Load additional data in background
    _ensurePredefinedWatchlistsLoaded();

    _safeSetState(() {});
  }

  void _handleTabScroll() {
    if (_isDisposed) return;

    if (_tabScrollController.position.isScrollingNotifier.value) {
      _isUserScrolling = true;
    } else {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!_isDisposed) _isUserScrolling = false;
      });
    }

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
    final list =
        ref.read(marketWatchProvider.select((p) => p.marketWatchlist))?.values;
    if (list == null) return;

    final idx = list.indexOf(wlName);
    if (idx == -1) return;

    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 50), () {
      if (!_isDisposed) _scrollToSelectedTab(idx, force: true);
    });
  }

  /// Background loading - doesn't block UI
  Future<void> _ensurePredefinedWatchlistsLoaded() async {
    if (_isDisposed) return;

    try {
      final marketWatch =
          ProviderScope.containerOf(context).read(marketWatchProvider);
      final current = marketWatch.wlName;

      await marketWatch.fetchPreDefMWScrip(context);

      const predefined = ['Nifty50', 'Niftybank', 'Sensex', 'My Stocks'];

      if (predefined.contains(current) && marketWatch.scrips.isEmpty) {
        await marketWatch.fetchMWScrip(current, context);
        await marketWatch.changeWLScrip(current, context);
      }

      for (final name in predefined) {
        if (name == current) continue;
        final cached = marketWatch.marketWatchScripData[name];
        if (cached == null || jsonDecode(cached).isEmpty) {
          await marketWatch.fetchMWScrip(name, context);
        }
      }

      await marketWatch.requestMWScrip(context: context, isSubscribe: true);
    } catch (e) {
      debugPrint('Error preloading watchlists: $e');
    }
  }

  Future<void> _handlePageChanged(int pageIndex, WidgetRef ref) async {
    if (_isDisposed) return;

    final marketWatch = ref.read(marketWatchProvider);
    final watchList = marketWatch.marketWatchlist;

    if (watchList?.values == null || pageIndex >= watchList!.values!.length)
      return;

    final newWatchlistName = watchList.values![pageIndex];

    _currentPageIndex = pageIndex;

    // Save the current page index to provider for persistence
    marketWatch.setCurrentWatchlistPageIndex(pageIndex);

    _scrollToSelectedTab(pageIndex, force: true);

    try {
      await marketWatch.requestMWScrip(context: context, isSubscribe: false);

      const predefined = ['My Stocks', 'Nifty50', 'Niftybank', 'Sensex'];
      final isPredefined = predefined.contains(newWatchlistName);

      await marketWatch.changeWlName(
          newWatchlistName, isPredefined ? 'Yes' : 'No');
      await marketWatch.changeWLScrip(newWatchlistName, context);

      await marketWatch.requestMWScrip(context: context, isSubscribe: true);
    } catch (e) {
      debugPrint('Error changing watchlist: $e');
    }
  }

  Future<void> _handleTabTap(String name, int index, WidgetRef ref) async {
    if (_currentPageIndex == index) return;

    _currentPageIndex = index;

    // Save the current page index to provider for persistence
    ref.read(marketWatchProvider).setCurrentWatchlistPageIndex(index);

    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }

    await _handlePageChanged(index, ref);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer(builder: (ctx, ref, _) {
      final wlName = ref.watch(marketWatchProvider.select((p) => p.wlName));
      final watchList =
          ref.watch(marketWatchProvider.select((p) => p.marketWatchlist));
      final isPreDef =
          ref.watch(marketWatchProvider.select((p) => p.isPreDefWLs));
      final sortBy = ref.watch(marketWatchProvider.select((p) => p.sortByWL));
      final providerPageIndex = ref.watch(
          marketWatchProvider.select((p) => p.currentWatchlistPageIndex));
      final theme = ref.watch(themeProvider);

      // Listen for page index changes from provider (e.g., from bottom sheet)
      if (providerPageIndex != _currentPageIndex &&
          _pageController.hasClients) {
        _currentPageIndex = providerPageIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients && !_isDisposed) {
            _pageController.jumpToPage(providerPageIndex);
          }
        });
      }

      final names = watchList?.values?.cast<String>() ?? [];
      if (!_listsEqual(names, _lastTabNames)) {
        _lastTabNames
          ..clear()
          ..addAll(names);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToWatchlistTab(ref, wlName),
        );
      }

      if (_lastWatchlistName != wlName) {
        _lastWatchlistName = wlName;

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToWatchlistTab(ref, wlName),
        );
      }

      return SafeArea(
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (_, inner) => [
            _buildSearchBar(
                ref, theme, wlName, isPreDef, watchList?.values?.length ?? 0),
            _buildPinnedTabs(ref, theme, watchList, wlName),
          ],
          body: _buildPageView(ref, theme, watchList, sortBy),
        ),
      );
    });
  }

  Widget _buildPageView(
      WidgetRef ref, ThemesProvider theme, dynamic watchList, String sortBy) {
    // Show immediately even if watchList is null initially
    if (watchList?.values == null) {
      return const SizedBox.shrink(); // No loader, just empty space
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: watchList.values.length,
      onPageChanged: (index) {
        if (index != _currentPageIndex) {
          _handlePageChanged(index, ref);
        }
      },
      itemBuilder: (context, index) {
        final pageName = watchList.values[index];

        return KeyedSubtree(
          key: ValueKey('${pageName}_$index'),
          child: Consumer(
            builder: (context, ref, _) {
              final marketWatch = ref.watch(marketWatchProvider);

              // Get data immediately - no async waiting
              List pageScrips = [];
              if (index == _currentPageIndex &&
                  pageName == marketWatch.wlName) {
                pageScrips = marketWatch.scrips;
              } else {
                final cachedData = marketWatch.marketWatchScripData[pageName];
                if (cachedData != null) {
                  try {
                    pageScrips = jsonDecode(cachedData);
                  } catch (e) {
                    debugPrint('Error parsing cached data for $pageName: $e');
                    pageScrips = [];
                  }
                }
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await marketWatch.fetchMWScrip(pageName, context);
                },
                child:
                    _buildPageContent(ref, theme, pageName, pageScrips, sortBy),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPageContent(WidgetRef ref, ThemesProvider theme, String pageName,
      List scrips, String sortBy) {
    if (pageName == 'My Stocks') {
      return const StocksScreen();
    }

    if (scrips.isEmpty) {
      return _buildEmptyState(theme, ref.read(marketWatchProvider));
    }

    return _buildWatchlistView(scrips, sortBy);
  }

  SliverToBoxAdapter _buildSearchBar(
    WidgetRef ref,
    ThemesProvider theme,
    String wlName,
    String isPreDef,
    int scripLen,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Increased padding for web
        child: Container(
          height: 48, // Increased height for web
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
            borderRadius: BorderRadius.circular(8), // Increased border radius for web
            border: Border.all(
              color: theme.isDarkMode 
                ? colors.dividerDark.withOpacity(0.3)
                : colors.dividerLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    final mw = ref.read(marketWatchProvider);
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await mw.requestMWScrip(
                          context: context, isSubscribe: false);
                    });
                    Navigator.pushNamed(
                      context,
                      Routes.searchScrip,
                      arguments: wlName,
                    );
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 16), // Increased padding for web
                      SvgPicture.asset(
                        assets.searchIcon,
                        width: 20, // Slightly larger for web
                        height: 20,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                      ),
                      const SizedBox(width: 12), // Increased spacing for web
                      Expanded(
                        child: TextWidget.subText(
                          text: 'Search & add',
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isPreDef != 'Yes' && scripLen > 1)
                Padding(
                  padding: const EdgeInsets.only(right: 8), // Increased padding for web
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
                        ResponsiveModal.show(
                          context: context,
                          child: const ScripFilterBottomSheet(),
                          useSafeArea: true,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10), // Increased padding for web
                        child: SvgPicture.asset(
                          assets.searchFilter,
                          width: 18, // Slightly larger for web
                          height: 18,
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
        height: 40, // Increased height for web
        selectedWatchlistName: wlName,
        watchlistNames: watchList?.values?.cast<String>(),
        child: Container(
          padding: const EdgeInsets.only(top: 8), // Increased padding for web
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            border: Border(
              bottom: BorderSide(
                color:
                    theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 6), // Increased padding for web
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
                      ResponsiveModal.show(
                        context: context,
                        child: WatchlistsBottomSheet(
                          currentWLName: wlName,
                        ),
                        useSafeArea: true,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 36, // Increased size for web
                      width: 36,
                      child: Center(
                        child: SvgPicture.asset(
                          assets.hamMenu,
                          width: 22, // Slightly larger for web
                          height: 22,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
      height: 35, // Increased height for web
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
                onTap: () => _handleTabTap(name, i, ref),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2), // Increased padding for web
                      child: TextWidget.subText(
                        text: _formatTabName(name),
                        color: selected
                            ? (theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight)
                            : (theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight),
                        theme: theme.isDarkMode,
                        fw: selected ? 1 : 3,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 3, // Slightly thicker for web
                      width: selected ? _tabWidth - 24 : 0, // Adjusted width for web
                      margin: const EdgeInsets.only(top: 2), // Increased margin for web
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
        padding: const EdgeInsets.symmetric(horizontal: 24), // Increased padding for web
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextBtn(
              label: 'Add Symbol',
              icon: assets.addCircleIcon,
              onPress: () {
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
            const SizedBox(height: 12), // Increased spacing for web
            TextWidget.headText(
              text: 'No symbol in this watchlist',
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              theme: theme.isDarkMode,
            ),
            const SizedBox(height: 12), // Increased spacing for web
            SizedBox(
              width: 300, // Increased width for web
              child: TextWidget.paraText(
                text: 'Use the search box above to find and add stocks, indices, futures or options.',
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
          RepaintBoundary(child: WatchlistCardWeb(watchListData: scrips[i])),
    );
  }

  String _formatTabName(String v) {
    if (v == 'My Stocks') return 'Holdings';
    if (v == 'Nifty50') return 'Nifty 50';
    if (v == 'Niftybank') return 'Nifty Bank';
    if (v == 'Sensex') return 'Sensex';
    return v.isEmpty
        ? ''
        : v.length <= 12 // Increased length limit for web
            ? '${v[0].toUpperCase()}${v.substring(1)}'
            : '${v.substring(0, 11)}..';
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
