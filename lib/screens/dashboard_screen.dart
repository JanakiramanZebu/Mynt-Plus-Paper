import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/ipo/ipo_main_screen.dart';
// import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../res/res.dart';
import '../../provider/thems.dart';
import '../provider/auth_provider.dart';
import '../provider/bonds_provider.dart';
import '../provider/iop_provider.dart';
import '../provider/ledger_provider.dart';
import '../provider/market_watch_provider.dart';
import '../provider/mf_provider.dart';
// import '../provider/portfolio_provider.dart';
import 'package:mynt_plus/main.dart';
import '../provider/stocks_provider.dart';
import '../res/global_state_text.dart';
import '../sharedWidget/custom_text_form_field.dart';
import '../utils/no_emoji_inputformatter.dart';
import 'bonds/bonds_main_screen.dart';
import 'stocks/explore/stocks/stock_screens.dart';
import 'mutual_fund/mf_explore_screens.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin, RouteAware {
  late TabController _mainTabController;
  late PageController _pageController;
  final FocusNode _searchFocusNode = FocusNode();
  
  // Track current main tab
  int _currentMainTab = 0;
  
  // Flag to prevent listener interference during initialization
  bool _isInitializing = true;

  // Callback function to handle child tab boundary navigation
  void _onChildTabBoundaryReached(bool isLeftSwipe) {
    if (isLeftSwipe) {
      // Swiping left (going to previous parent tab)
      if (_currentMainTab > 0) {
        _switchToParentTab(_currentMainTab - 1);
      }
    } else {
      // Swiping right (going to next parent tab)
      if (_currentMainTab < 3) {
        _switchToParentTab(_currentMainTab + 1);
      }
    }
  }

  void _switchToParentTab(int newTabIndex) {
    // Only proceed if the tab is actually changing
    if (_currentMainTab != newTabIndex) {
      setState(() {
        _currentMainTab = newTabIndex;
      });
      
      // Only animate if not already at target
      if (_mainTabController.index != newTabIndex) {
        _mainTabController.animateTo(newTabIndex);
      }
      
      // Only animate page if not already at target
      if (_pageController.page?.round() != newTabIndex) {
        _pageController.animateToPage(
          newTabIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _mainTabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
    
    _pageController = PageController(initialPage: 0);
    
    // Ensure initial state is synchronized
    _currentMainTab = 0;

    // Main tab listener
    _mainTabController.addListener(() {
      // Skip listener during initialization
      if (_isInitializing) return;
      
      if (_mainTabController.indexIsChanging) {
        setState(() {
          _currentMainTab = _mainTabController.index;
        });
        
        // Only synchronize PageController if it's not already at the target page
        // This prevents infinite loops between TabController and PageController
        if (_pageController.page?.round() != _mainTabController.index) {
          _pageController.animateToPage(
            _mainTabController.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        
        // Sync with provider when tab changes
        if (mounted) {
          ref.read(stocksProvide).syncTabIndex(_mainTabController.index);
        }
        // Clear search when switching tabs
        if (mounted) {
          ref.read(stocksProvide).searchController.clear();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(stocksProvide).syncTabIndex(0);
      }
      ref
          .read(marketWatchProvider)
          .requestMWScrip(context: context, isSubscribe: true);
      ref.read(authProvider).setIposAPicalls(context);
      ref.read(bondsProvider).fetchAllBonds();
      
      // Mark initialization as complete
      _isInitializing = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to route changes to unfocus search when returning
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    // Initialize provider state after dependencies are available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if widget is still mounted before proceeding
      if (!mounted) return;
      
      final reportsprovider = ref.read(ledgerProvider);
      // await ref.read(stocksProvide).getNews();

      reportsprovider.calendarProvider();
      // Initialize calendar provider
      final currentFY = reportsprovider.availableFinancialYears.first;
      if ((reportsprovider.hasDataForAllSegments)) {
        // Check mounted before using context
        if (!mounted) return;
        reportsprovider.fetchDataForAllSegmentsIfEmpty(
          context,
          reportsprovider.startDate,
          reportsprovider.today,
        );
        // Calendar PnL data will be fetched when needed
      }
      
      // Check mounted before async operations
      if (!mounted) return;
      await ref.read(mfProvider).fetchEtfCategory();
      
      // Check mounted after async operation
      if (!mounted) return;
      
      // Immediately set the default year and segment to show correct data from cache
      reportsprovider.setFinancialYear(currentFY);
      reportsprovider.setSegment(reportsprovider.availableSegments.first);
      
      if (reportsprovider.ledgerAllData == null) {
        // Check mounted before async operation
        if (!mounted) return;
        await reportsprovider.getCurrentDate('else');
        
        // Check mounted after async operation before using context
        if (!mounted) return;
        reportsprovider.fetchLegerData(
            context, reportsprovider.startDate, reportsprovider.endDate);
      }
      // Initialize mutual fund data
      // await ref.read(mfProvider).fetchBestMF();
      // await ref.read(mfProvider).fetchnewMFBestList();
      // await ref.read(mfProvider).fetchMFCategoryList("", "");
      // await ref.read(mfProvider).fetchmfallcatnew();
      // await ref.read(mfProvider).fetchmfholdingnew();
      // await ref.read(portfolioProvider).fetchMFHoldings(context);
      // await ref.read(mfProvider).fetchmfNFO(context);
      // await ref.read(mfProvider).fetchTopSchemes();
      // await ref.read(mfProvider).fetchMFWatchlist("", "", context, true, "");
      // await ref.read(mfProvider).fetchmfsiplist();
      // await ref.read(mfProvider).fetchmfsipnotlivelist();
      // await ref.read(mfProvider).fetchMfOrderbook(context);
      // await ref.read(mfProvider).fetchMFMandateDetail();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchFocusNode.dispose();
    
    // Safely dispose controllers
    try {
      _mainTabController.dispose();
    } catch (e) {
      // Controller might already be disposed
    }
    
    try {
      _pageController.dispose();
    } catch (e) {
      // Controller might already be disposed
    }
    
    super.dispose();
  }

  // RouteAware callbacks to unfocus when screens/popup close
  @override
  void didPopNext() {
    // A top route was popped and this route shows up again
    if (mounted) {
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void didPushNext() {
    // Another route has been pushed atop this one; ensure keyboard closed
    if (mounted) {
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final stocks = ref.watch(stocksProvide);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          title: Row(
            children: [
              // SvgPicture.asset(
              //   assets.myntnewLogo,
              //   width: 46,
              //   height: 46,
              // ),
              // const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: theme.isDarkMode
                        ? colors.searchBgDark
                        : colors.searchBg,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: InkWell(
                      onTap: () {
                        if (_mainTabController.index == 1) {
                          // FocusScope.of(context).unfocus();
                          Navigator.pushNamed(context, Routes.mfsearchscreen);
                        } else if (_mainTabController.index == 0) {
                          FocusScope.of(context).unfocus();
                          final mw = ref.read(marketWatchProvider);
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            await mw.requestMWScrip(
                                context: context, isSubscribe: false);
                          });
                          Navigator.pushNamed(
                            context,
                            Routes.searchScrip,
                            arguments: ref.watch(
                                marketWatchProvider.select((p) => p.wlName)),
                          );
                        }
                      },
                      child: AbsorbPointer(
                        absorbing: _mainTabController.index == 1 ||
                            _mainTabController.index == 0,
                        child: TextField(
                          focusNode: _searchFocusNode,
                          controller: stocks.searchController,
                          autofocus: false,
                          style: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                          ),
                          readOnly: _mainTabController.index == 2 ||
                                  _mainTabController.index == 3
                              ? false
                              : true,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            NoEmojiInputFormatter(),
                            FilteringTextInputFormatter.deny(
                                RegExp('[π£•₹€℅™∆√¶/.,]'))
                          ],
                          decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: TextWidget.textStyle(
                                  fontSize: 16,
                                  theme: theme.isDarkMode,
                                   fw: 0,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight),
                              fillColor: theme.isDarkMode
                                  ? colors.searchBgDark
                                  : colors.searchBg,
                              filled: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(assets.searchIcon,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fit: BoxFit.scaleDown,
                                    width: 20),
                              ),
                              suffixIcon:
                                  stocks.searchController.text.isNotEmpty
                                      ? Material(
                                          color: Colors.transparent,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            splashColor: theme.isDarkMode
                                                ? colors.splashColorDark
                                                : colors.splashColorLight,
                                            highlightColor: theme.isDarkMode
                                                ? colors.highlightDark
                                                : colors.highlightLight,
                                            onTap: () async {
                                              // Future.delayed(const Duration(milliseconds: 150), () {
                                              stocks.searchController.clear();
                                              FocusScope.of(context).unfocus();
                                              stocks.clearsearchlist(context);
                                              if (_mainTabController.index == 2) {
                                                ref
                                                    .read(ipoProvide)
                                                    .setIpoSearchQuery("");
                                                ;
                                              } else if (_mainTabController.index ==
                                                  3) {
                                                ref
                                                    .read(bondsProvider)
                                                    .bondscommonsearchcontroller
                                                    .clear();
                                              }
                                              //   if (positionBook.positionSearchCtrl.text.isEmpty) {
                                              //     positionBook.showPositionSearch(false);
                                              //   }
                                              // });)
                                            },
                                            child: SvgPicture.asset(
                                              assets.removeIcon,
                                              fit: BoxFit.scaleDown,
                                              width: 20,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                            ),
                                          ),
                                        )
                                      : null,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)),
                              disabledBorder: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20))),
                          onChanged: (value) {
                            stocks.searchdashboard(value, context,
                                tabIndex: _mainTabController.index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40), // Height for main tabs only
            child: Column(
              children: [
                // Main tabs
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: TabBar(
                    onTap: (index) {
                      // Only proceed if the tab is actually changing
                      if (_currentMainTab != index) {
                        // Update the current main tab
                        setState(() {
                          _currentMainTab = index;
                        });
                        
                        // Animate to the selected tab
                        _mainTabController.animateTo(index);
                        
                        // Animate to the selected page
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      
                      // Always sync the tab index with the provider and perform other actions
                      ref.read(stocksProvide).syncTabIndex(index);
                      FocusScope.of(context).unfocus();
                      stocks.searchController.clear();
                      stocks.clearsearchlist(context);
                      ref.read(ipoProvide).setSelectedTab(0);
                    },
                    tabAlignment: TabAlignment.start,
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: true,
                    indicatorColor: theme.isDarkMode
                        ? colors.secondaryDark
                        : colors.secondaryLight,
                    unselectedLabelColor: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    unselectedLabelStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: false,
                      fw: 0,
                    ),
                    labelColor: theme.isDarkMode
                        ? colors.secondaryDark
                        : colors.secondaryLight,
                    labelStyle:
                        TextWidget.textStyle(fontSize: 14, theme: false, fw: 2),
                    controller: _mainTabController,
                    tabs: stocks.exploreTabName,
                    labelPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.055),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                ),
              ],
            ),
          ),
        ),
                 body: PageView(
           controller: _pageController,
           onPageChanged: (index) {
             // Only update if the page actually changed
             if (_currentMainTab != index) {
               setState(() {
                 _currentMainTab = index;
               });
               
               // Only animate tab controller if it's not already at the target index
               if (_mainTabController.index != index) {
                 _mainTabController.animateTo(index);
               }
               
               // Sync with provider when page changes
               if (mounted) {
                 ref.read(stocksProvide).syncTabIndex(index);
               }
             }
           },
           children: [
             // Stocks - no child tabs
             const StockScreen(),
             // Mutual Fund - with child tabs
             MFExploreScreens(
               theme: ref.watch(themeProvider),
               onBoundaryReached: _onChildTabBoundaryReached,
             ),
             // IPO - with child tabs
             IPOScreen(
               initialTabIndex: 0, 
               isIpo: false,
               onBoundaryReached: _onChildTabBoundaryReached,
             ),
             // Bond - with child tabs
             BondsScreen(
               isBonds: false,
               onBoundaryReached: _onChildTabBoundaryReached,
             ),
           ],
         ),
      );
    });
  }





  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}


