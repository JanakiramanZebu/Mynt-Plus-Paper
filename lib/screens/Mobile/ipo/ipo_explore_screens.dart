import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/Mobile/ipo/ipo_orderbook_screen/ipo_order_book_main_screen.dart';
import 'package:mynt_plus/screens/Mobile/ipo/upcoming/ipo_upcoming.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/loader_ui.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/global_state_text.dart';
import 'main_sme_list/main_sme_list.dart';

class IpoExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  final int? initialTabIndex;
  final Function(bool)? onBoundaryReached; // Callback for boundary detection
  const IpoExploreScreens(
      {super.key, required this.theme, this.initialTabIndex, this.onBoundaryReached});

  @override
  ConsumerState<IpoExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<IpoExploreScreens>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  int selectedTab = 0;
  // ref.read(ipoProvide).selectedTab = selectedTab;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex ?? 0);
    selectedTab = widget.initialTabIndex ?? 0;
    
    _tabController.animation!.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (selectedTab != newIndex) {
        setState(() {
          selectedTab = newIndex;
        });
        ref.read(ipoProvide).setSelectedTab(newIndex);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to provider's selected tab changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final providerTab = ref.read(ipoProvide).selectedTab;
        if (providerTab != selectedTab) {
          setState(() {
            selectedTab = providerTab;
          });
          _tabController.animateTo(providerTab);
        }
      }
    });
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final explore = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);

    return TransparentLoaderScreen(
      isLoading: explore.loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 150),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: MediaQuery.of(context).padding.bottom),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    width: 0,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    ref.read(ipoProvide).tablistitems.length,
                    (tab) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.01)
                            : Colors.black.withOpacity(0.01),
                        onTap: () {
                          setState(() {
                            selectedTab = tab;
                          });
                          _tabController.animateTo(tab);
                          // Also update the page controller to jump directly
                          if (_tabController.index != tab) {
                            _tabController.index = tab;
                          }
                          
                          ref.read(ipoProvide).clearCommonIpoSearch();
                          ref.read(ipoProvide).setIpoSearchQuery("");
                          FocusScope.of(context).unfocus();
                        },
                        child: _tabConstruct(
                            ref.read(ipoProvide).tablistitems[tab]['title'].toString(), theme, tab),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _CustomTabBarView(
              controller: _tabController,
              children: const [
                MainSmeListCard(),
                UpcomingIpo(),
                IpoOrderbookMainScreen(),
              ],
              onBoundaryReached: widget.onBoundaryReached,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabConstruct(String title, ThemesProvider theme, int tab) {
    final isActive = selectedTab == tab;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: TextWidget.subText(
            text: title,
            color: isActive
                ? theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight
                : theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
            textOverflow: TextOverflow.ellipsis,
            maxLines: 1,
            theme: theme.isDarkMode,
            fw: isActive ? 2 : 2,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 2,
          width: isActive ? 82 : 0,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: colors.colorBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// Custom TabBarView that handles edge swipe gestures to parent tabs
class _CustomTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;
  final Function(bool)? onBoundaryReached;

  const _CustomTabBarView({
    required this.controller,
    required this.children,
    this.onBoundaryReached,
  });

  @override
  State<_CustomTabBarView> createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<_CustomTabBarView> {
  late PageController _pageController;
  bool _isExternalTabChange = false;

  // Track pointer events for edge swipes
  double _startX = 0;
  double _startY = 0;
  double _currentX = 0;
  double _currentY = 0;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.controller.index);

    // Listen to internal tab controller changes (sync with page)
    widget.controller.addListener(() {
      if (_isExternalTabChange) {
        return; // Avoid sync during external tab transition
      }

      final currentPage = _pageController.page?.round();
      final newIndex = widget.controller.index;

      if (_pageController.hasClients && currentPage != newIndex) {
        // Use jumpToPage for distant tabs to avoid scrolling through all intermediate tabs
        // Use animateToPage only for adjacent tabs (distance of 1)
        final distance = (currentPage! - newIndex).abs();
        if (distance > 1) {
          _pageController.jumpToPage(newIndex);
        } else {
          _pageController.animateToPage(
            newIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _startX = event.position.dx;
        _startY = event.position.dy;
        _currentX = _startX;
        _currentY = _startY;
        _isTracking = true;
      },
      onPointerMove: (PointerMoveEvent event) {
        if (_isTracking) {
          _currentX = event.position.dx;
          _currentY = event.position.dy;
        }
      },
      onPointerUp: (PointerUpEvent event) {
        if (!_isTracking) return;
        _isTracking = false;

        final deltaX = _currentX - _startX;
        final deltaY = _currentY - _startY;
        final currentPage = _pageController.page?.round() ?? 0;

        // Only process if horizontal movement is greater than vertical
        if (deltaX.abs() <= deltaY.abs()) return;

        // Minimum distance for edge swipe
        const minDistance = 50.0;

        // Right swipe from first tab (Open) -> notify parent to go to previous tab (Mutual Fund)
        if (deltaX > minDistance && currentPage == 0) {
          if (widget.onBoundaryReached != null) {
            widget.onBoundaryReached!(true); // true = previous tab (Mutual Fund)
          }
        }

        // Left swipe from last tab (My Bids) -> notify parent to go to next tab (Bond)
        if (deltaX < -minDistance && currentPage == widget.children.length - 1) {
          if (widget.onBoundaryReached != null) {
            widget.onBoundaryReached!(false); // false = next tab (Bond)
          }
        }
      },
      onPointerCancel: (PointerCancelEvent event) {
        _isTracking = false;
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.children.length,
        onPageChanged: (index) {
          // Jump directly to the tapped tab without animation
          widget.controller.animateTo(index);
        },
        itemBuilder: (context, index) => widget.children[index],
      ),
    );
  }
}
