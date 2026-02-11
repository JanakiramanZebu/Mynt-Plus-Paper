import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/all.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_order_book_screen.dart';
// import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
// import '../../provider/mf_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/portfolio_provider.dart';
import 'mf_sip_screen.dart';
import 'mutual_fund_screen_new.dart';
import 'mf_watchlist.dart';


class MFExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider? theme;
  final Function(bool)? onBoundaryReached; // Callback for boundary detection
  final VoidCallback? onNfoTap; // Callback when NFO card is tapped (for web panel navigation)
  final Function(String title, String subtitle, String icon)? onCollectionTap; // Callback when collection is tapped
  final Function(String title, String subtitle, String icon)? onCategoryTap; // Callback when category is tapped
  final VoidCallback? onSipCalculatorTap;
  final VoidCallback? onCagrCalculatorTap;
  final Function(MutualFundList mfData)? onFundTap; // Callback when fund is tapped (for web panel navigation)

  const MFExploreScreens({
    super.key,
    this.theme,
    this.onBoundaryReached,
    this.onNfoTap,
    this.onCollectionTap,
    this.onCategoryTap,
    this.onSipCalculatorTap,
    this.onCagrCalculatorTap,
    this.onFundTap,
  });

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

    return MyntLoaderOverlay(
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
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    tablistitems.length,
                    (tab) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            selectedTab = tab;
                          });
                          _tabController.animateTo(tab);
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
        
                         Expanded(
               child: _CustomTabBarView(
                 controller: _tabController,
                 onBoundaryReached: widget.onBoundaryReached,
                  children: [
                    MutualFundNewScreen(
                      tabController: _tabController,
                      onNfoTap: widget.onNfoTap,
                      onCollectionTap: widget.onCollectionTap,
                      onCategoryTap: widget.onCategoryTap,
                      onSipCalculatorTap: widget.onSipCalculatorTap,
                      onCagrCalculatorTap: widget.onCagrCalculatorTap,
                    ),
                   MFWatchlistScreen(onFundTap: widget.onFundTap),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? theme.isDarkMode ? MyntColors.primaryDark : MyntColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: MyntWebTextStyles.body(
          context,
          fontWeight: MyntFonts.medium,
          color: isActive
              ? theme.isDarkMode ? MyntColors.primaryDark : MyntColors.primary
              : theme.isDarkMode
                  ? MyntColors.textSecondaryDark
                  : MyntColors.textSecondary,
        ),
      ),
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
                ? MyntColors.searchBgDark
                : const Color.fromARGB(255, 255, 255, 255).withValues(alpha: .15)
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
    return webText(
          context,
          weight: fWeight, color: color, size: fontSize);
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

        // Use addPostFrameCallback to prevent state changes during mouse device updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

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
        });
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
