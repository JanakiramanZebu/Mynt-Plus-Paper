import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/all.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_order_book_screen.dart';
// import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/loader_ui.dart';
// import '../../provider/mf_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../res/global_state_text.dart';
import 'mf_sip_screen.dart';
import 'mf_watchlist.dart';
import 'mutual_fund_screen_new.dart';

class MFExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  final Function(bool)? onBoundaryReached; // Callback for boundary detection
  const MFExploreScreens({super.key, required this.theme, this.onBoundaryReached});

  @override
  ConsumerState<MFExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<MFExploreScreens>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedTab = 0;

  final tablistitems = [
    {
      "imgpath": "assets.exportIcon",
      "title": "Explore",
      "index": 0,
    },
    {
      "imgpath": "assets.bookmarkLineIcon",
      "title": "Watchlist",
      "index": 1,
    },
    {
      "imgpath": "assets.bookmarkLineIcon",
      "title": "Portfolio",
      "index": 2,
    },
    {
      "imgpath": "assets.bookmarkLineIcon",
      "title": "SIP",
      "index": 3,
    }
  ];

  // final bestMFList = [
  //   {
  //     "funds": "46 funds",
  //     "image": "assets/explore/loan.svg",
  //     "subtitle": "Build wealth and save taxes",
  //     "title": "Save taxes"
  //   },
  //   {
  //     "funds": "90 funds",
  //     "image": "assets/explore/transactions.svg",
  //     "subtitle": "Stable income and growth",
  //     "title": "Equity + Debt"
  //   },
  //   {
  //     "funds": "56 funds",
  //     "image": "assets/explore/goldcoin.svg",
  //     "subtitle": "Hybrid of active and passive",
  //     "title": "Smart beta"
  //   },
  //   {
  //     "funds": "120 funds",
  //     "image": "assets/explore/globe.svg",
  //     "subtitle": "Diversify your portfolio globally",
  //     "title": "International funds"
  //   }
  // ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4,
        vsync: this,
        initialIndex: ref.read(mfProvider).activeTab ?? 0);
    selectedTab = ref.read(mfProvider).activeTab ?? 0;
    
    _tabController.animation!.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (selectedTab != newIndex) {
        setState(() {
          selectedTab = newIndex;
        });
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
    final theme = ref.read(themeProvider);
    final mfData = ref.watch(mfProvider);
    final portfolio = ref.watch(portfolioProvider);

    return TransparentLoaderScreen(
      isLoading: explore.loading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 150),
            // const CustomDragHandler(),
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
                      tablistitems.length,
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
                          },
                          child: _tabConstruct(
                              tablistitems[tab]['title'].toString(), theme, tab),
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
                 onBoundaryReached: widget.onBoundaryReached,
                 children: [
                   MutualFundNewScreen(
                     tabController: _tabController,
                   ),
                   const MFWatchlistScreen(),
                   const MfOrderBookScreen(),
                   const MFSipdetScreen()
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _tabConstruct(String title, ThemesProvider theme, int tab) {
    final isActive = selectedTab == tab;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          // width: 100,
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

  Widget _buildTab(String title, ThemesProvider theme, int tab, mfData) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          mfData.mfExTabchange(tab);
        });
        _tabController.animateTo(tab);
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        backgroundColor: theme.isDarkMode
            ? tab == mfData.activeTab
                ? colors.colorbluegrey
                : const Color.fromARGB(255, 255, 255, 255).withOpacity(.15)
            : tab == mfData.activeTab
                ? const Color(0xff000000)
                : const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        minimumSize: const Size(0, 30),
      ),
      child: Text(
        title,
        style: textStyle(
          theme.isDarkMode
              ? Color(tab == mfData.activeTab ? 0xff000000 : 0xffffffff)
              : Color(tab == mfData.activeTab ? 0xffffffff : 0xff000000),
          13,
          FontWeight.w500,
        ),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
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

  void _navigateToOuterTab({
    required int current,
    required int target,
    required VoidCallback action,
  }) {
    if (_isExternalTabChange || current == target) return;

    _isExternalTabChange = true;
    action();
    Future.delayed(const Duration(milliseconds: 500), () {
      _isExternalTabChange = false;
    });
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

        // Right swipe from first tab (Explore) -> notify parent to go to previous tab (Stocks)
        if (deltaX > minDistance && currentPage == 0) {
          if (widget.onBoundaryReached != null) {
            widget.onBoundaryReached!(true); // true = previous tab (Stocks)
          }
        }

        // Left swipe from last tab (SIP) -> notify parent to go to next tab (IPO)
        if (deltaX < -minDistance && currentPage == widget.children.length - 1) {
          if (widget.onBoundaryReached != null) {
            widget.onBoundaryReached!(false); // false = next tab (IPO)
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
