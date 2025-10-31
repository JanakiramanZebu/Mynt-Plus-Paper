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
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_btn_web.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../Mobile/market_watch/my_stocks/stocks_screen.dart';
import 'watchlist_card_web.dart';
import 'search_dialog_web.dart';
import 'edit_scrip_web.dart';

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
              _buildSearchBar(
                  context, ref, theme, wlName, isPreDef, watchList?.values?.length ?? 0),
              _buildPinnedTabs(ref, theme, watchList, wlName),
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
      return const StocksScreen();
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
                                style: WebTextStyles.para(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textHint
                                      : WebColors.textHint,
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
                              await Future.delayed(const Duration(milliseconds: 150));
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? WebDarkColors.navBackground
            : WebColors.navBackground,
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode
                ? WebDarkColors.navDivider
                : WebColors.navDivider,
            width: 1,
          ),
        ),
      ),
      child: _buildWatchlistTabs(ref, wlName, watchList, theme),
    );

    // Calculate total height: padding (8 top + 8 bottom) + content (45) = 61
    const double tabsHeight = 61.0;

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

  Widget _buildWatchlistTabs(
    WidgetRef ref,
    String wlName,
    dynamic watchList,
    ThemesProvider theme,
  ) {
    if (watchList?.values == null) return const SizedBox.shrink();

    final tabs = watchList.values.cast<String>();
    

    return SizedBox(
      height: 45, // Increased height to accommodate better spacing
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
          color: theme.isDarkMode 
              ? WebDarkColors.surface 
              : WebColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.isDarkMode 
                ? WebDarkColors.border 
                : WebColors.border,
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

  Widget _buildTabItem(String name, String wlName, ThemesProvider theme, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _handleTabTap(name, ref.read(marketWatchProvider).marketWatchlist?.values?.toList().indexOf(name) ?? 0, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: name == wlName
              ? BoxDecoration(
                  color:
                      theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                  borderRadius: BorderRadius.circular(5),
                )
              : null,
          child: Text(
            _formatTabName(name),
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.para(
              isDarkTheme: theme.isDarkMode,
              color: name == wlName
                  ? (theme.isDarkMode ? WebDarkColors.surface : WebColors.surface)
                  : (theme.isDarkMode ? WebDarkColors.navItem : WebColors.navItem),
              fontWeight: name == wlName ? FontWeight.w700 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _scrollTabsLeft() {
    if (!_tabScrollController.hasClients) return;
    
    final currentOffset = _tabScrollController.offset;
    final newOffset = (currentOffset - 200).clamp(0.0, _tabScrollController.position.maxScrollExtent);
    
    _tabScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    
  }

  void _scrollTabsRight() {
    if (!_tabScrollController.hasClients) return;
    
    final currentOffset = _tabScrollController.offset;
    final newOffset = (currentOffset + 200).clamp(0.0, _tabScrollController.position.maxScrollExtent);
    
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
              CustomTextBtnWeb(
                label: 'Add Symbol',
                icon: assets.addCircleIcon,
                onPress: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await mw.requestMWScrip(
                        context: context, isSubscribe: false);
                  });
                  Navigator.pushNamed(
                    context,
                    Routes.searchScrip,
                    arguments: mw.wlName,
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'No symbol in this watchlist',
                style: WebTextStyles.sub(
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
            padding: const EdgeInsets.only(right: 12.0, bottom: 8.0), // Add right padding to prevent scrollbar from hiding content
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
        borderRadius: BorderRadius.circular(8),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (isActive) ...[
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.primary
                    : WebColors.primary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: isActive
                    ? (theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary)
                    : (theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary),
                fontWeight: isActive ? WebFonts.semiBold : WebFonts.regular,
              ),
            ),
          ],
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 620,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Watchlist',
                      style: WebTextStyles.title(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: FontWeight.w700,
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
                          padding: const EdgeInsets.all(8),
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
                const SizedBox(height: 8),

                // Watchlist items with radio buttons
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: watchlist.length,
                    itemBuilder: (context, index) {
                      final watchlistName = watchlist[index];
                      final isPredefined = preDefWl.contains(watchlistName);
                      return InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                          if (watchlistName != currentWLName) {
                            await _handleWatchlistSelection(watchlistName, ref);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: Row(
                            children: [
                              // Radio button
                              Radio<String>(
                                value: watchlistName,
                                groupValue: currentWLName,
                                onChanged: (value) async {
                                  Navigator.of(context).pop();
                                  if (value != null && value != currentWLName) {
                                    await _handleWatchlistSelection(value, ref);
                                  }
                                },
                                activeColor: theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary,
                              ),
                              const SizedBox(width: 8),

                              // Watchlist name
                              Expanded(
                                child: Text(
                                  _formatWatchlistName(watchlistName),
                                  style: WebTextStyles.para(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
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
                                    onTap: () => _showEditWatchlistDialog(
                                        context, ref, watchlistName),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.iconSecondary
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
                                    onTap: () => _showDeleteWatchlistDialog(
                                        context, ref, watchlistName),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.iconSecondary
                                            : WebColors.iconSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Create new watchlist button - only show if user has less than 10 custom watchlists
                 if (watchlist.length - preDefWl.length < 10) // 4 predefined watchlists: My Stocks, Nifty50, Niftybank, Sensex
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _showCreateWatchlistDialog(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Create New Watchlist',
                        style: WebTextStyles.sub(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.surface
                              : WebColors.surface,
                          fontWeight: FontWeight.w700,
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Watchlist',
                      style: WebTextStyles.title(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: FontWeight.w700,
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
                          padding: const EdgeInsets.all(8),
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
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Watchlist Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                      ),
                    ),
                  ),
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newName = controller.text.trim();
                      if (newName.isNotEmpty && newName != watchlistName) {
                        // Let the provider method handle dialog closing and notifications
                        await _handleWatchlistRename(
                            watchlistName, newName, ref, context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: WebTextStyles.sub(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.surface
                            : WebColors.surface,
                        fontWeight: FontWeight.w700,
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delete Watchlist',
                      style: WebTextStyles.title(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: FontWeight.w700,
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
                          padding: const EdgeInsets.all(8),
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
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete "${_formatWatchlistName(watchlistName)}"?',
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(deleteDialogContext)
                          .pop(); // Close delete confirmation dialog
                      await _handleWatchlistDelete(watchlistName, ref);
                      // Small delay to ensure deletion completes
                      await Future.delayed(const Duration(milliseconds: 200));
                      // Close main dialog after successful deletion
                      Navigator.of(mainDialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: WebTextStyles.sub(
                        isDarkTheme: false,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Watchlist',
                      style: WebTextStyles.title(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: FontWeight.w700,
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
                          padding: const EdgeInsets.all(8),
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
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Watchlist Name',
                    hintText: 'Enter watchlist name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                      ),
                    ),
                  ),
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Create',
                      style: WebTextStyles.sub(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.surface
                            : WebColors.surface,
                        fontWeight: FontWeight.w700,
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

  Future<void> _handleWatchlistRename(
      String oldName, String newName, WidgetRef ref, BuildContext context) async {
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
      builder: (BuildContext context) {
        return SearchDialogWeb(
          wlName: wlName,
          isBasket: "Watchlist",
        );
      },
    );
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
