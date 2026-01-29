import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/Mobile/bonds/bonds_orderbook_screen/bonds_order_book_main_screen.dart';
import 'package:mynt_plus/screens/Mobile/bonds/live_bonds/bonds_list.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/loader_ui.dart';
import '../../../../res/global_state_text.dart';

import '../../../../sharedWidget/common_search_fields_web.dart';


class BondsExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  final int? initialTabIndex;
  final Function(bool)? onBoundaryReached; // Callback for boundary detection
  const BondsExploreScreens(
      {super.key, required this.theme, this.initialTabIndex, this.onBoundaryReached});

  @override
  ConsumerState<BondsExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<BondsExploreScreens>
    with TickerProviderStateMixin {
  late TabController _allBondsTabController;

  final tablistitems = [
    {
      "Aimgpath": "",
      // "imgpath": assets.exportIcon,
      "title": "Bonds",
      "index": 0,
    },
    // {
    //   "Aimgpath": "",
    //   // "imgpath": assets.bookmarkLineIcon,
    //   "title": "T-bill",
    //   "index": 1,
    // },
    // {
    //   "Aimgpath": "",
    //   // "imgpath": assets.bag,
    //   "title": "SDL",
    //   "index": 2,
    // },
    // {
    //   "Aimgpath": "",
    //   // "imgpath": assets.bag,
    //   "title": "SGB",
    //   "index": 3,
    // },
    {
      "Aimgpath": "",
      // "imgpath": assets.bag,
      "title": "My Bids",
      "index": 1,
    }
  ];

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: tablistitems.length, vsync: this, initialIndex: 0);
    _allBondsTabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex ?? 0);
    selectedTab = widget.initialTabIndex ?? 0;

    _allBondsTabController.animation?.addListener(() {
      final newIndex = _allBondsTabController.animation?.value.round() ?? 0;
      if (selectedTab != newIndex) {
        setState(() {
          selectedTab = newIndex; // Update activeTab immediately on swipe
        });
      }
    });
  }

// TabController(
//           length: ref.read(bondsProvider).tablistitems.length,
//           vsync: this,
//           initialIndex: ref.read(bondsProvider).selectedBondTab["index"])

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final explore = ref.watch(authProvider);
        final bonds = ref.watch(bondsProvider);
        final theme = ref.read(themeProvider);
        //  List<Map<String, Object>> tablistitems = btablistitems;
        return TransparentLoaderScreen(
          isLoading: explore.loading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 8,
                  bottom: 8,
                ),

                decoration: BoxDecoration(
                  // border: Border(
                  //   bottom: BorderSide(
                  //     color: widget.theme.isDarkMode
                  //         ? colors.darkColorDivider
                  //         : colors.colorDivider,
                  //     width: 0,
                  //   ),
                  // ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        tablistitems.length,
                        (tab) => Material(
                          color: Colors.transparent,
                          child: InkWell(
                            // borderRadius: BorderRadius.circular(6),
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
                              _allBondsTabController.animateTo(tab);
                              // Also update the page controller to jump directly
                              if (_allBondsTabController.index != tab) {
                                _allBondsTabController.index = tab;
                              }
                              ref
                                  .read(bondsProvider)
                                  .bondscommonsearchcontroller
                                  .clear();
                              ref.read(bondsProvider).clearCommonBondsSearch();
                              FocusScope.of(context).unfocus();
                            },
                            child: tabConstruce(
                              tablistitems[tab]['title'].toString(),
                              theme,
                              tab,
                              () {},
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: selectedTab == 0
                          ? SizedBox(
                              width: 300,
                              child: MyntSearchTextField(
                                controller: bonds.bondscommonsearchcontroller,
                                placeholder: "Search & add",
                                leadingIcon: assets.searchIcon,
                                onChanged: (value) {
                                  bonds.searchCommonBonds(value, context);
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CustomTabBarView(
                  controller: _allBondsTabController,
                  onBoundaryReached: widget.onBoundaryReached,
                  children: const [
                    BondsListScreen(), 
                    BondsOrderbookMainScreen()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget tabConstruce(
      String title, ThemesProvider theme, int tab, VoidCallback onPressed) {
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
  final bool _isExternalTabChange = false;

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

        // Right swipe from first tab (Bonds) -> notify parent to go to previous tab (IPO)
        if (deltaX > minDistance && currentPage == 0) {
          if (widget.onBoundaryReached != null) {
            widget.onBoundaryReached!(true); // true = previous tab (IPO)
          }
        }

        // Left swipe from last tab (My Bids) -> notify parent to go to next tab (no next parent, so this would be end)
        if (deltaX < -minDistance && currentPage == widget.children.length - 1) {
          if (widget.onBoundaryReached != null) {
            widget.onBoundaryReached!(false); // false = next tab (but no next parent)
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