import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import 'my_stocks/stocks_screen_web.dart';
import 'watchlist_card_web.dart';
import 'search_dialog_web.dart';
import 'edit_scrip_web.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import 'index/index_bottom_sheet_web.dart';

// Provider to manage delete mode state
final deleteModeProvider =
    StateNotifierProvider<DeleteModeNotifier, bool>((ref) {
  return DeleteModeNotifier();
});

class DeleteModeNotifier extends StateNotifier<bool> {
  DeleteModeNotifier() : super(false);

  void setDeleteMode(bool isActive) {
    state = isActive;
  }
}

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

class _SliverIndexSlotsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverIndexSlotsDelegate({
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext ctx, double shrink, bool overlaps) => child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) {
    return old is! _SliverIndexSlotsDelegate || old.height != height;
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
  final List<String> _lastTabNames = [];

  /// Get responsive tab width based on watchlist panel width
  double _getResponsiveTabWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Estimate watchlist width (assuming 20-35% of screen based on breakpoints)
    double watchlistWidth;
    if (screenWidth >= 1600) {
      watchlistWidth = screenWidth * 0.20;
    } else if (screenWidth >= 1200) {
      watchlistWidth = screenWidth * 0.25;
    } else if (screenWidth >= 992) {
      watchlistWidth = screenWidth * 0.28;
    } else if (screenWidth >= 768) {
      watchlistWidth = screenWidth * 0.30;
    } else {
      watchlistWidth = screenWidth * 0.35;
    }

    // Tab width based on available watchlist space
    if (watchlistWidth >= 400) {
      return 120.0; // Wide watchlist: comfortable tab width
    } else if (watchlistWidth >= 320) {
      return 100.0; // Medium watchlist: slightly narrower tabs
    } else {
      return 90.0;  // Narrow watchlist: compact tabs
    }
  }

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
    final tabWidth = _getResponsiveTabWidth(context);

    final target = (index * tabWidth) - (viewW / 2) + (tabWidth / 2);
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

      // Watch delete mode state from provider
      final showDeleteMode = ref.watch(deleteModeProvider);

      return SafeArea(
        child: Container(
          color: theme.isDarkMode
              ? WebDarkColors.background
              : WebColors.background,
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (_, inner) => [
              _buildSearchBar(context, ref, theme, wlName, isPreDef,
                  watchList?.values?.length ?? 0),
              _buildPinnedTabs(ref, theme, watchList, wlName),
              _buildIndexSlots(ref, theme),
            ],
            body: showDeleteMode
                ? EditScripWeb(
                    wlName: wlName,
                    showInDialog: false,
                  )
                : _buildPageView(ref, theme, watchList, sortBy),
          ),
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
      return const StocksScreenWeb();
    }

    if (scrips.isEmpty) {
      return _buildEmptyState(theme, ref.read(marketWatchProvider));
    }

    return _buildWatchlistView(scrips, sortBy);
  }

  SliverToBoxAdapter _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    ThemesProvider theme,
    String wlName,
    String isPreDef,
    int scripLen,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        color: colors.colorWhite,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
        child: Row(
          children: [
            // Menu button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  hoverColor: theme.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  splashColor: theme.isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                  onTap: () => _showWatchlistDialog(context, ref, wlName),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        assets.hamMenu,
                        width: 20,
                        height: 20,
                        color: theme.isDarkMode
                            ? WebDarkColors.iconSecondary
                            : WebColors.iconSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Search bar
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  // color: theme.isDarkMode ? WebDarkColors.inputBackground : WebColors.inputBackground,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode
                        ? WebDarkColors.inputBorder
                        : WebColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          // final mw = ref.read(marketWatchProvider);
                          // WidgetsBinding.instance.addPostFrameCallback((_) async {
                          //   await mw.requestMWScrip(
                          //       context: context, isSubscribe: false);
                          // });
                          _showSearchDialog(context, ref, wlName);
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            SvgPicture.asset(
                              assets.searchIcon,
                              width: 16,
                              height: 16,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search & add',
                                style: WebTextStyles.formInput(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textSecondary
                                      : WebColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isPreDef != 'Yes' && scripLen > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            hoverColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            splashColor: theme.isDarkMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.2),
                            onTap: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 150));
                              _showFilterPopup(context, ref);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                assets.searchFilter,
                                width: 14,
                                height: 14,
                                color: theme.isDarkMode
                                    ? WebDarkColors.iconSecondary
                                    : WebColors.iconSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WEB VERSION
  Widget _buildPinnedTabs(
    WidgetRef ref,
    ThemesProvider theme,
    dynamic watchList,
    String wlName,
  ) {
    final tabContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border(
        //   bottom: BorderSide(
        //     color: theme.isDarkMode
        //         ? WebDarkColors.inputBorder
        //         : WebColors.inputBorder,
        //     width: 1,
        //   ),
        // ),
      ),
      child: _buildWatchlistTabs(ref, wlName, watchList, theme),
    );

    // Calculate total height: content (60) = 60
    const double tabsHeight = 60.0;

    return SliverPersistentHeader(
      pinned: true, // This keeps the tabs fixed at the top
      delegate: _SliverTabsDelegate(
        child: tabContent,
        height: tabsHeight,
        selectedWatchlistName: wlName,
        watchlistNames: watchList?.values?.cast<String>(),
      ),
    );
  }

  // Build index slots widget - shows 2 index slots below tabs (pinned like tabs)
  // Responsive: shows 1 slot on narrow watchlist, 2 slots on wide watchlist
  Widget _buildIndexSlots(WidgetRef ref, ThemesProvider theme) {
    final indexContent = Consumer(
      builder: (context, ref, _) {
        final indexProvider = ref.watch(indexListProvider);
        final marketWatch = ref.read(marketWatchProvider);
        final indexValues = indexProvider.defaultIndexList?.indValues;

        if (indexValues == null || indexValues.isEmpty) {
          return const SizedBox.shrink();
        }

        // Determine layout based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        final watchlistWidth = _getWatchlistWidth(screenWidth);
        final showSingleSlot = watchlistWidth < 350; // Show 1 slot if watchlist < 350px

        // Show only first 2 indices
        final displayIndices = indexValues.length >= 2
            ? indexValues.take(2).toList()
            : indexValues;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? WebDarkColors.background
                : WebColors.background,
          ),
          child: showSingleSlot
              ? _buildSingleIndexSlot(displayIndices, theme, marketWatch, indexProvider)
              : _buildDoubleIndexSlots(displayIndices, theme, marketWatch, indexProvider),
        );
      },
    );

    // Calculate total height: padding vertical (6*2) + item height (52) = 64
    const double indexSlotsHeight = 64.0;

    return SliverPersistentHeader(
      pinned: true, // This keeps the index slots fixed at the top
      delegate: _SliverIndexSlotsDelegate(
        child: indexContent,
        height: indexSlotsHeight,
      ),
    );
  }

  // Helper to calculate watchlist width based on screen width
  double _getWatchlistWidth(double screenWidth) {
    if (screenWidth >= 1600) {
      return screenWidth * 0.20;
    } else if (screenWidth >= 1200) {
      return screenWidth * 0.25;
    } else if (screenWidth >= 992) {
      return screenWidth * 0.28;
    } else if (screenWidth >= 768) {
      return screenWidth * 0.30;
    } else {
      return screenWidth * 0.35;
    }
  }

  // Build double index slots layout (2 slots side by side with horizontal scroll)
  Widget _buildDoubleIndexSlots(
    List<dynamic> displayIndices,
    ThemesProvider theme,
    dynamic marketWatch,
    dynamic indexProvider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(2, (index) {
            if (index >= displayIndices.length) {
              return const SizedBox.shrink();
            }
            final item = displayIndices[index];
            return Padding(
              padding: EdgeInsets.only(
                right: index < 1 ? 8 : 0,
              ),
              child: _WatchlistIndexSlotWeb(
                indexItem: item,
                indexPosition: index,
                theme: theme,
                marketWatch: marketWatch,
                indexProvider: indexProvider,
              ),
            );
          }),
        ),
      ),
    );
  }

  // Build single index slot layout with horizontal scroll (for narrow watchlist)
  Widget _buildSingleIndexSlot(
    List<dynamic> displayIndices,
    ThemesProvider theme,
    dynamic marketWatch,
    dynamic indexProvider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            displayIndices.length,
            (index) {
              final item = displayIndices[index];
              return Padding(
                padding: EdgeInsets.only(right: index < displayIndices.length - 1 ? 8 : 0),
                child: _WatchlistIndexSlotWeb(
                  indexItem: item,
                  indexPosition: index,
                  theme: theme,
                  marketWatch: marketWatch,
                  indexProvider: indexProvider,
                ),
              );
            },
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

    final tabs = watchList.values.cast<String>();

    return SizedBox(
      height: 60, 
      child: Row(
        children: [
          // Left arrow button
          _buildTabArrowButton(
            icon: Icons.chevron_left,
            onPressed: () => _scrollTabsLeft(),
            theme: theme,
          ),

          const SizedBox(width: 5),
          // Tabs scrollable area
          Expanded(
            child: ScrollConfiguration(
              behavior: DragScrollBehavior(),
              child: SingleChildScrollView(
                controller: _tabScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: [
                    for (final name in tabs)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildTabItem(name, wlName, theme, ref),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Right arrow button
          _buildTabArrowButton(
            icon: Icons.chevron_right,
            onPressed: () => _scrollTabsRight(),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTabArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemesProvider theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.isDarkMode ? WebDarkColors.border : WebColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: theme.isDarkMode
                  ? WebDarkColors.iconSecondary
                  : WebColors.iconSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
      String name, String wlName, ThemesProvider theme, WidgetRef ref) {
    final isActive = name == wlName;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _handleTabTap(
            name,
            ref
                    .read(marketWatchProvider)
                    .marketWatchlist
                    ?.values
                    ?.toList()
                    .indexOf(name) ??
                0,
            ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isActive
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.white,
            border: Border.all(
              color: isActive
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isActive ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            _formatTabName(name),
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isActive
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _scrollTabsLeft() {
    if (!_tabScrollController.hasClients) return;

    final currentOffset = _tabScrollController.offset;
    final newOffset = (currentOffset - 200)
        .clamp(0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollTabsRight() {
    if (!_tabScrollController.hasClients) return;

    final currentOffset = _tabScrollController.offset;
    final newOffset = (currentOffset + 200)
        .clamp(0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildEmptyState(ThemesProvider theme, MarketWatchProvider mw) {
    return Container(
      color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CustomTextBtnWeb(
              //   label: 'Add Symbol',
              //   icon: assets.addCircleIcon,
              //   onPress: () {
              //     mw.requestMWScrip(context: context, isSubscribe: false);
              //     showDialog(
              //       context: context,
              //       barrierColor: Colors.transparent,
              //       builder: (BuildContext context) {
              //         return SearchDialogWeb(
              //           wlName: mw.wlName,
              //           isBasket: "Watchlist",
              //         );
              //       },
              //     );
              //   },
              // ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    mw.requestMWScrip(context: context, isSubscribe: false);

                    showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return SearchDialogWeb(
                          wlName: mw.wlName,
                          isBasket: "Watchlist",
                        );
                      },
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors
                          .grey.shade200, // adjust to match your custom widget
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          assets.addCircleIcon,
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Add Symbol',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'No symbol in this watchlist',
                style: WebTextStyles.bodySmall(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 300,
                child: Text(
                  'Use the search box above to find and add stocks, indices, futures or options.',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.para(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textSecondary
                        : WebColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistView(List scrips, String sortBy) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        return Container(
          color: theme.isDarkMode
              ? WebDarkColors.background
              : WebColors.background,
          child: ListView.separated(
            key: ValueKey('${scrips.length}_$sortBy'),
            itemCount: scrips.length,
            cacheExtent: 500,
            padding: const EdgeInsets.only(
                right: 12.0,
                bottom:
                    8.0), // Add right padding to prevent scrollbar from hiding content
            separatorBuilder: (_, __) => const ListDivider(),
            itemBuilder: (_, i) => RepaintBoundary(
                child: WatchlistCardWeb(watchListData: scrips[i])),
          ),
        );
      },
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

  void _showFilterPopup(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final marketWatch = ref.read(marketWatchProvider);
    final currentSort = marketWatch.sortByWL;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      items: [
        _buildFilterMenuItem('Scrip Name', 'scrip', theme, currentSort),
        _buildFilterMenuItem('LTP', 'price', theme, currentSort),
        _buildFilterMenuItem('Perc.Change', 'perchng', theme, currentSort),
      ],
    ).then((value) {
      if (value != null) {
        _handleFilterSelection(value, ref);
      }
    });
  }

  PopupMenuItem<String> _buildFilterMenuItem(
      String title, String value, ThemesProvider theme, String currentSort) {
    // Determine if this option is currently active and its direction
    bool isActive = false;
    bool isAscending = false;

    if (value == "scrip") {
      isActive = currentSort.contains("Scrip");
      isAscending = currentSort.contains("A to Z");
    } else if (value == "price") {
      isActive = currentSort.contains("Price");
      isAscending = currentSort.contains("Low to High");
    } else if (value == "perchng") {
      isActive = currentSort.contains("Per.Chng");
      isAscending = currentSort.contains("Low to High");
    }

    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 150, // Fixed width to prevent resizing
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Text on the left
              Expanded(
                child: Text(
                  title,
                  style: WebTextStyles.bodySmall(
                    isDarkTheme: theme.isDarkMode,
                    color: isActive
                        ? (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary)
                        : (theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Reserve space for icon on the right (always 18px + 8px spacing)
              SizedBox(
                width: 26, // 18px icon + 8px spacing
                child: isActive
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 8),
                          Icon(
                            isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 18,
                            color: theme.isDarkMode
                                ? WebDarkColors.primary
                                : WebColors.primary,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFilterSelection(String filterType, WidgetRef ref) {
    final marketWatch = ref.read(marketWatchProvider);
    String sortingValue = "";

    // Get current sort state to determine direction
    final currentSort = marketWatch.sortByWL;

    if (filterType == "scrip") {
      // Toggle between A to Z and Z to A
      if (currentSort.contains("Scrip - A to Z")) {
        sortingValue = "Scrip - Z to A";
      } else {
        sortingValue = "Scrip - A to Z";
      }
    } else if (filterType == "price") {
      // Toggle between Low to High and High to Low
      if (currentSort.contains("Price - Low to High")) {
        sortingValue = "Price - High to Low";
      } else {
        sortingValue = "Price - Low to High";
      }
    } else if (filterType == "perchng") {
      // Toggle between Low to High and High to Low
      if (currentSort.contains("Per.Chng - Low to High")) {
        sortingValue = "Per.Chng - High to Low";
      } else {
        sortingValue = "Per.Chng - Low to High";
      }
    }

    // Apply the sort using the same method as the original filter
    marketWatch.getSortByWL(sortingValue);
    marketWatch.filterMWScrip(
        sorting: sortingValue, wlName: marketWatch.wlName, context: context);
  }

  void _showWatchlistDialog(
      BuildContext context, WidgetRef ref, String currentWLName) {
    final theme = ref.read(themeProvider);
    final marketWatch = ref.read(marketWatchProvider);
    final watchlist = marketWatch.marketWatchlist!.values!;
    final preDefWl = marketWatch.preDefWL;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            width: 500,
            height: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close icon
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Watchlist',
                        style: WebTextStyles.dialogTitle(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                      ),
                      Material(
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
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content area with padding
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 6, bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Watchlist items with radio buttons

                        if (watchlist.length - preDefWl.length <
                            10) // 4 predefined watchlists: My Stocks, Nifty50, Niftybank, Sensex
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _showCreateWatchlistDialog(
                                        context, ref),
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    splashColor: theme.isDarkMode
                                        ? Colors.white.withOpacity(.15)
                                        : Colors.black.withOpacity(.15),
                                    highlightColor: theme.isDarkMode
                                        ? Colors.white.withOpacity(.08)
                                        : Colors.black.withOpacity(.08),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '+ Create New Watchlist',
                                        style: WebTextStyles.buttonSm(
                                          isDarkTheme: theme.isDarkMode,
                                          color: WebColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: watchlist.length,
                            itemBuilder: (context, index) {
                              final watchlistName = watchlist[index];
                              final isPredefined =
                                  preDefWl.contains(watchlistName);
                              return InkWell(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  if (watchlistName != currentWLName) {
                                    await _handleWatchlistSelection(
                                        watchlistName, ref);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 2),
                                  child: Row(
                                    children: [
                                      // Radio button
                                      Radio<String>(
                                        value: watchlistName,
                                        groupValue: currentWLName,
                                        onChanged: (value) async {
                                          Navigator.of(context).pop();
                                          if (value != null &&
                                              value != currentWLName) {
                                            await _handleWatchlistSelection(
                                                value, ref);
                                          }
                                        },
                                        activeColor: theme.isDarkMode
                                            ? WebDarkColors.primary
                                            : WebColors.primary,
                                      ),
                                      const SizedBox(width: 6),

                                      // Watchlist name
                                      Expanded(
                                        child: Text(
                                          _formatWatchlistName(watchlistName),
                                          style: WebTextStyles.bodySmall(
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      // Edit and Delete buttons for custom watchlists
                                      if (!isPredefined) ...[
                                        Material(
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
                                            onTap: () =>
                                                _showEditWatchlistDialog(
                                                    context,
                                                    ref,
                                                    watchlistName),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: theme.isDarkMode
                                                    ? WebDarkColors
                                                        .iconSecondary
                                                    : WebColors.iconSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Material(
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
                                            onTap: () =>
                                                _showDeleteWatchlistDialog(
                                                    context,
                                                    ref,
                                                    watchlistName),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(
                                                Icons.delete_outline_outlined,
                                                size: 18,
                                                color: theme.isDarkMode
                                                    ? WebDarkColors.tertiary
                                                    : WebColors.tertiary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatWatchlistName(String name) {
    if (name.isEmpty) return name;

    switch (name) {
      case "My Stocks":
        return "Holdings";
      case "Nifty50":
        return "Nifty 50";
      case "Niftybank":
        return "Nifty Bank";
      default:
        return "${name[0].toUpperCase()}${name.substring(1)}";
    }
  }

  Future<void> _handleWatchlistSelection(
      String watchlistName, WidgetRef ref) async {
    final marketWatch = ref.read(marketWatchProvider);

    try {
      await marketWatch.requestMWScrip(context: context, isSubscribe: false);

      const predefined = ['My Stocks', 'Nifty50', 'Niftybank', 'Sensex'];
      final isPredefined = predefined.contains(watchlistName);

      await marketWatch.changeWlName(
          watchlistName, isPredefined ? 'Yes' : 'No');
      await marketWatch.changeWLScrip(watchlistName, context);

      await marketWatch.requestMWScrip(context: context, isSubscribe: true);

      // Update the page controller to show the selected watchlist
      final watchList = marketWatch.marketWatchlist;
      if (watchList?.values != null) {
        final watchlists = watchList!.values!.cast<String>();
        final newIndex = watchlists.indexOf(watchlistName);
        if (newIndex != -1) {
          _currentPageIndex = newIndex;
          marketWatch.setCurrentWatchlistPageIndex(newIndex);
          if (_pageController.hasClients) {
            _pageController.jumpToPage(newIndex);
          }
        }
      }
    } catch (e) {
      debugPrint('Error changing watchlist: $e');
    }
  }

  void _showEditWatchlistDialog(
      BuildContext context, WidgetRef ref, String watchlistName) {
    final theme = ref.read(themeProvider);
    final TextEditingController controller =
        TextEditingController(text: watchlistName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Watchlist',
                        style: WebTextStyles.dialogTitle(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                      ),
                      Material(
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
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16, top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 40,
                            child: CustomTextFormField(
                              fillColor: theme.isDarkMode
                                  ? WebDarkColors.backgroundTertiary
                                  : WebColors.backgroundTertiary,
                              onChanged: (value) {
                                // Handle change if needed
                              },
                              hintText: "Enter watchlist name",
                              hintStyle: WebTextStyles.formInput(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                    : WebColors.textSecondary,
                              ),
                              keyboardType: TextInputType.text,
                              style: WebTextStyles.formInput(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                              ),
                              textCtrl: controller,
                              textAlign: TextAlign.start,
                              autofocus: true,
                              inputFormate: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9 ]'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: Colors.white.withOpacity(0.2),
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  onTap: () async {
                                    final newName = controller.text.trim();
                                    if (newName.isNotEmpty &&
                                        newName != watchlistName) {
                                      // Let the provider method handle dialog closing and notifications
                                      await _handleWatchlistRename(
                                          watchlistName, newName, ref, context);
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'Save',
                                      style: WebTextStyles.buttonMd(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteWatchlistDialog(
      BuildContext context, WidgetRef ref, String watchlistName) {
    final theme = ref.read(themeProvider);
    final mainDialogContext = context;

    showDialog(
      context: context,
      builder: (BuildContext deleteDialogContext) {
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delete Watchlist',
                        style: WebTextStyles.dialogTitle(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                      ),
                      Material(
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
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16, top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you sure you want to delete "${_formatWatchlistName(watchlistName)}"?',
                            style: WebTextStyles.bodySmall(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: Colors.white.withOpacity(0.2),
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  onTap: () async {
                                    Navigator.of(deleteDialogContext)
                                        .pop(); // Close delete confirmation dialog
                                    await _handleWatchlistDelete(
                                        watchlistName, ref);
                                    // Small delay to ensure deletion completes
                                    await Future.delayed(
                                        const Duration(milliseconds: 200));
                                    // Close main dialog after successful deletion
                                    Navigator.of(mainDialogContext).pop();
                                  },
                                  child: Center(
                                    child: Text(
                                      'Delete',
                                      style: WebTextStyles.buttonMd(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateWatchlistDialog(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final TextEditingController controller = TextEditingController();
    final mainDialogContext = context; // Store reference to main dialog context

    showDialog(
      context: context,
      builder: (BuildContext createDialogContext) {
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Watchlist',
                        style: WebTextStyles.dialogTitle(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                      ),
                      Material(
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
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16, top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 40,
                            child: CustomTextFormField(
                              fillColor: theme.isDarkMode
                                  ? WebDarkColors.backgroundTertiary
                                  : WebColors.backgroundTertiary,
                              onChanged: (value) {
                                // Handle change if needed
                              },
                              hintText: "Enter watchlist name",
                              hintStyle: WebTextStyles.formInput(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                    : WebColors.textSecondary,
                              ),
                              keyboardType: TextInputType.text,
                              style: WebTextStyles.formInput(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                              ),
                              textCtrl: controller,
                              textAlign: TextAlign.start,
                              autofocus: true,
                              inputFormate: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9 ]'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: Colors.white.withOpacity(0.2),
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  onTap: () async {
                                    final name = controller.text.trim();
                                    if (name.isNotEmpty) {
                                      Navigator.of(createDialogContext)
                                          .pop(); // Close create dialog
                                      await _handleWatchlistCreate(name, ref);
                                      // Small delay to ensure creation completes
                                      await Future.delayed(
                                          const Duration(milliseconds: 200));
                                      // Close main dialog after successful creation
                                      Navigator.of(mainDialogContext).pop();
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'Create',
                                      style: WebTextStyles.buttonMd(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleWatchlistRename(String oldName, String newName,
      WidgetRef ref, BuildContext context) async {
    final marketWatch = ref.read(marketWatchProvider);
    try {
      await marketWatch.fetchWatchListRename(oldName, newName, context);
    } catch (e) {
      debugPrint('Error renaming watchlist: $e');
    }
  }

  Future<void> _handleWatchlistDelete(
      String watchlistName, WidgetRef ref) async {
    final marketWatch = ref.read(marketWatchProvider);
    try {
      await marketWatch.deleteWatchList(watchlistName, context);
    } catch (e) {
      debugPrint('Error deleting watchlist: $e');
    }
  }

  Future<void> _handleWatchlistCreate(String name, WidgetRef ref) async {
    final marketWatch = ref.read(marketWatchProvider);
    try {
      await marketWatch.addWatchList(name, context);
    } catch (e) {
      debugPrint('Error creating watchlist: $e');
    }
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref, String wlName) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return SearchDialogWeb(
          wlName: wlName,
          isBasket: "Watchlist",
        );
      },
    );
  }
}

// Index slot widget for watchlist screen with hover edit icon
class _WatchlistIndexSlotWeb extends ConsumerStatefulWidget {
  final dynamic indexItem;
  final int indexPosition;
  final ThemesProvider theme;
  final dynamic marketWatch;
  final dynamic indexProvider;

  const _WatchlistIndexSlotWeb({
    Key? key,
    required this.indexItem,
    required this.indexPosition,
    required this.theme,
    required this.marketWatch,
    required this.indexProvider,
  }) : super(key: key);

  @override
  ConsumerState<_WatchlistIndexSlotWeb> createState() =>
      _WatchlistIndexSlotWebState();
}

class _WatchlistIndexSlotWebState
    extends ConsumerState<_WatchlistIndexSlotWeb> {
  bool _isHovered = false;

  Future<void> _handleTap(BuildContext context) async {
    try {
      // Fetch index list before opening bottom sheet
      await widget.indexProvider.fetchIndexList("NSE", context);

      // Open the bottom sheet dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: IndexBottomSheetWeb(
              defaultIndex: widget.indexItem,
              indexPosition: widget.indexPosition,
            ),
          );
        },
      );

      // Clean up after dialog closes
      await widget.indexProvider.fetchIndexList("exit", context);
      await widget.marketWatch.requestMWScrip(
          context: context, isSubscribe: true);
    } catch (e) {
      debugPrint("Error in index slot tap: $e");
    }
  }

  Future<void> _handleIndexClick(BuildContext context) async {
    try {
      // First, safely fetch the quote data
      await widget.marketWatch.fetchScripQuoteIndex(
          widget.indexItem.token?.toString() ?? "",
          widget.indexItem.exch?.toString() ?? "",
          context);

      final quots = widget.marketWatch.getQuotes;

      // Make sure we have valid quote data before proceeding
      if (quots == null) {
        return;
      }

      // Create DepthInputArgs with null safety
      final depthArgs = DepthInputArgs(
          exch: quots.exch?.toString() ?? "",
          token: quots.token?.toString() ?? "",
          tsym: quots.tsym?.toString() ?? "",
          instname: quots.instname?.toString() ?? "",
          symbol: quots.symbol?.toString() ?? "",
          expDate: quots.expDate?.toString() ?? "",
          option: quots.option?.toString() ?? "");

      // Call depth APIs with the safely constructed arguments
      if (depthArgs.token.isNotEmpty && depthArgs.exch.isNotEmpty) {
        await widget.marketWatch.calldepthApis(context, depthArgs, "");
      }
    } catch (e) {
      debugPrint("Error in index click: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        child: InkWell(
          customBorder: const RoundedRectangleBorder(),
          splashColor: widget.theme.isDarkMode
              ? WebDarkColors.primary.withOpacity(0.1)
              : WebColors.primary.withOpacity(0.1),
          highlightColor: widget.theme.isDarkMode
              ? WebDarkColors.primary.withOpacity(0.05)
              : WebColors.primary.withOpacity(0.05),
          onTap: () => _handleIndexClick(context),
            child: Container(
            height: 52, // Compact height
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary,
              // border: Border.all(
              //   color: widget.theme.isDarkMode                    
              //         ? WebDarkColors.primary
              //         : WebColors.primary,
              //   // width: 1,

              // ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Index name - match default_index_list_web.dart exactly
                    Text(
                      widget.indexItem.idxname ?? "",
                      style: WebTextStyles.symbolList(
                        isDarkTheme: widget.theme.isDarkMode,
                        color: widget.theme.isDarkMode
                            ? WebDarkColors.textPrimary 
                            : WebColors.textPrimary,                      
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Live price widget
                    _WatchlistLivePriceWidget(
                      key: ValueKey('price_${widget.indexItem.token ?? ""}'),
                      token: widget.indexItem.token?.toString() ?? "",
                      initialLtp: (widget.indexItem.ltp == null ||
                              widget.indexItem.ltp == "null")
                          ? "0.00"
                          : widget.indexItem.ltp?.toString() ?? "0.00",
                      initialChange: (widget.indexItem.change == null ||
                              widget.indexItem.change == "null")
                          ? "0.00"
                          : widget.indexItem.change?.toString() ?? "0.00",
                      initialPerChange: (widget.indexItem.perChange == null ||
                              widget.indexItem.perChange == "null")
                          ? "0.00"
                          : widget.indexItem.perChange?.toString() ?? "0.00",
                      isDarkMode: widget.theme.isDarkMode,
                    ),
                  ],
                ),
                // Edit icon on hover
                if (_isHovered)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: widget.theme.isDarkMode
                            ? Colors.white.withOpacity(.15)
                            : Colors.black.withOpacity(.15),
                        highlightColor: widget.theme.isDarkMode
                            ? Colors.white.withOpacity(.08)
                            : Colors.black.withOpacity(.08),
                        onTap: () => _handleTap(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.theme.isDarkMode
                                ? WebDarkColors.surface
                                : WebColors.surface,
                            shape: BoxShape.circle,
                            // border: Border.all(
                            //   color: widget.theme.isDarkMode
                            //       ? WebDarkColors.border
                            //       : WebColors.border,
                            //   width: 1,
                            // ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: widget.theme.isDarkMode
                                ? WebDarkColors.iconSecondary
                                : WebColors.iconSecondary,
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
    );
  }
}

// Live price widget for watchlist index slots
class _WatchlistLivePriceWidget extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;
  final String initialChange;
  final String initialPerChange;
  final bool isDarkMode;

  const _WatchlistLivePriceWidget({
    Key? key,
    required this.token,
    required this.initialLtp,
    required this.initialChange,
    required this.initialPerChange,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  ConsumerState<_WatchlistLivePriceWidget> createState() =>
      _WatchlistLivePriceWidgetState();
}

class _WatchlistLivePriceWidgetState
    extends ConsumerState<_WatchlistLivePriceWidget> {
  late String _ltp;
  late String _change;
  late String _perChange;
  StreamSubscription? _subscription;
  bool _isUpdatePending = false;
  final _debouncer = _Debouncer(milliseconds: 300);
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _ltp = widget.initialLtp == "null" ? "0.00" : widget.initialLtp;
    _change = widget.initialChange == "null" ? "0.00" : widget.initialChange;
    _perChange =
        widget.initialPerChange == "null" ? "0.00" : widget.initialPerChange;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _setupSocketListener();
      _isInitialized = true;
    }
  }

  @override
  void didUpdateWidget(_WatchlistLivePriceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _ltp = widget.initialLtp == "null" ? "0.00" : widget.initialLtp;
      _change = widget.initialChange == "null" ? "0.00" : widget.initialChange;
      _perChange =
          widget.initialPerChange == "null" ? "0.00" : widget.initialPerChange;
      _subscription?.cancel();
      _isInitialized = false;
      _setupSocketListener();
      _isInitialized = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _debouncer.cancel();
    super.dispose();
  }

  void _setupSocketListener() {
    if (widget.token.isEmpty) return;

    final websocket =
        ProviderScope.containerOf(context).read(websocketProvider);

    final existingData = websocket.socketDatas[widget.token];
    if (existingData != null) {
      _updateFromSocketData(existingData);
    }

    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(widget.token)) {
        final socketData = data[widget.token];
        if (socketData != null) {
          final hasChanged = _updateFromSocketData(socketData);
          if (hasChanged && mounted && !_isUpdatePending) {
            _isUpdatePending = true;
            _debouncer.run(() {
              if (mounted) {
                setState(() {});
                _isUpdatePending = false;
              }
            });
          }
        }
      }
    });
  }

  bool _updateFromSocketData(dynamic data) {
    bool hasChanged = false;
    final newLtp = data['lp']?.toString() ?? "0.00";
    if (newLtp != "null" && newLtp != _ltp) {
      _ltp = newLtp;
      hasChanged = true;
    }
    final newChange = data['chng']?.toString() ?? "0.00";
    if (newChange != "null" && newChange != _change) {
      _change = newChange;
      hasChanged = true;
    }
    final newPerChange = data['pc']?.toString() ?? "0.00";
    if (newPerChange != "null" && newPerChange != _perChange) {
      _perChange = newPerChange;
      hasChanged = true;
    }
    return hasChanged;
  }

  Color _getChangeColor(String change, String perChange) {
    if (change.startsWith("-") || perChange.startsWith('-')) {
      return widget.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else if ((change == "null" || perChange == "null") ||
        (change == "0.00" || perChange == "0.00")) {
      return widget.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    } else {
      return widget.isDarkMode ? WebDarkColors.success : WebColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor(_change, _perChange);
    // Match default_index_list_web.dart _LivePriceWidgetWeb exactly (src: false)
    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$_ltp  ",
            style: _getTextStyle(
              changeColor,
              13, // Match font size from default_index_list_web.dart
              1,
            ),
          ),

          Text(
            "$_change ",
            style: _getTextStyle(
              WebColors.textPrimary, // Match default_index_list_web.dart
              13, // Match font size
              1,
            ),
          ),

          Text(
            "($_perChange%)",
            style: _getTextStyle(
              WebColors.textPrimary, // Match default_index_list_web.dart
              13, // Match font size
              1,
            ),
          )
        ],
      ),
    );
  }

  // Cache for text styles - match default_index_list_web.dart
  static final Map<String, TextStyle> _textStyleCache = {};

  TextStyle _getTextStyle(Color color, double size, [int? fw]) {
    final key = '${color.value}|$size|${fw ?? "null"}';
    return _textStyleCache.putIfAbsent(
      key,
      () => WebTextStyles.priceWatch(
        isDarkTheme: true, // Match default_index_list_web.dart
        color: color,
      ),
    );
  }
}

// Debouncer helper class for throttling updates
class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

class DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
