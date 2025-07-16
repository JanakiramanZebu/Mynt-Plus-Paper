import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../locator/constant.dart';
import '../locator/preference.dart';
import '../models/marketwatch_model/market_watch_scrip_model.dart';
import '../provider/api_key_provider.dart';
import '../provider/auth_provider.dart';
import '../provider/fund_provider.dart';
import '../provider/index_list_provider.dart';
import '../provider/market_watch_provider.dart';
import '../provider/network_state_provider.dart';
import '../provider/notification_provider.dart';
import '../provider/order_provider.dart';
import '../provider/portfolio_provider.dart';
import '../provider/thems.dart';
import '../provider/transcation_provider.dart';
import '../provider/user_profile_provider.dart';
import '../provider/version_provider.dart';
import '../provider/websocket_provider.dart';
import '../provider/webview_chart_provider.dart';
import '../res/global_state_text.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/internet_widget.dart';
import 'market_watch/index/index_screen.dart';
import 'market_watch/scrip_filter_bottom_sheet.dart';
import 'market_watch/tv_chart/webview_chart.dart';
import 'market_watch/watchlist_screen.dart';
import 'market_watch/watchlists_bottom_sheet.dart';
import 'mutual_fund/mf_main_screen.dart';
import 'order_book/basket/create_basket.dart';
import 'order_book/order_book_screen.dart';
import 'portfolio_screens/portfolio_screen.dart';
import 'portfolio_screens/positions/group/position_group_bottomsheet.dart';
import 'profile_screen/logged_user_bottom_sheet.dart';
import 'profile_screen/profile_main_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  late WebSocketProvider socketProvider; // Store the reference

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // FirebaseAnalytics.instance.logScreenView(
    //   screenName: 'HomeScreen',
    //   screenClass: 'HomeScreen', // Customize if needed.
    // );
    // This is a websocket heartbeat connection that reconnects every two seconds only.
    ConstantName.timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        ref.read(websocketProvider).reconnect(context);
        // ref.read(websocketProvider).startPingCheck(context);
      }
    });
    ref.read(networkStateProvider).networkStream();
    ref.read(marketWatchProvider).fToast.init(context);
    ref.read(versionProvider).checkVersion(context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketProvider = ref.read(websocketProvider); // Store reference safely
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Cancel the timer before disposing
    if (ConstantName.timer != null) {
      ConstantName.timer!.cancel();
      ConstantName.timer = null;
    }
    // Close socket but don't attempt to reconnect since we're disposing
    socketProvider.closeSocket(false);
    ConstantName.chartwebViewController?.dispose();
    super.dispose();
  }

// Determining the app's state, such as inactive, stopped, resumed, and so forth
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // Don't use await to avoid blocking the UI thread
        // Check session status in the background to prevent freezing
        Future.microtask(() async {
          try {
            // Check session status without loading indicators
            await ref.read(indexListProvider).checkSession(context);

            // Only load data if session is valid and app is still mounted
            if (mounted &&
                ref.read(indexListProvider).checkSess?.stat == "Ok") {
              // Load these in parallel for better performance
              final futures = [
                ref.read(portfolioProvider).fetchPositionBook(context, false),
                ref.read(portfolioProvider).fetchHoldings(context, ""),
                ref.read(orderProvider).fetchOrderBook(context, false),
                ref.read(orderProvider).fetchTradeBook(context),
              ];

              await Future.wait(futures);

              // Make sure to re-enable all navigation functionality
              if (mounted) {
                setState(() {
                  // Trigger rebuild to ensure navigation is responsive
                });
              }
            }

            // Handle WebSocket connections after session validation
            _handleWebSocketConnections();
          } catch (e) {
            print("Error during app resume: $e");
          }
        });

        // Handle chart data in a separate task
        _handleChartData();

        // Add this after connections are reestablished
        // Force UI refresh with latest data
        if (mounted) {
          // Give a slight delay for data to arrive
          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                // This will force the current tab to rebuild with fresh data
              });
            }
          });
        }
        break;

      case AppLifecycleState.inactive:
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
          ref.read(portfolioProvider).cancelTimer();
        }
        final userProfile = ref.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        print("app in inactive");
        break;

      case AppLifecycleState.paused:
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
          ref.read(portfolioProvider).cancelTimer();
        }
        print("app in paused");
        break;

      case AppLifecycleState.detached:
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
          ref.read(portfolioProvider).cancelTimer();
        }
        final userProfile = ref.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        print("app in detached");
        break;

      case AppLifecycleState.hidden:
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
          ref.read(portfolioProvider).cancelTimer();
        }
    }
  }

  // Extract WebSocket connection logic to separate method
  void _handleWebSocketConnections() {
    if (!mounted) return;

    final websocket = ref.read(websocketProvider);
    final indexProvide = ref.read(indexListProvider);

    // Reset connection count if needed
    if (websocket.connectioncount >= 5) {
      websocket.changeconnectioncount();
    }

    // Handle connection states
    if (!websocket.wsConnected) {
      // If not connected, try to re-establish connection
      if (ConstantName.lastSubscribe.isNotEmpty) {
        websocket.establishConnection(
            channelInput: ConstantName.lastSubscribe,
            task: "t",
            context: context);
      }

      if (ConstantName.lastSubscribeDepth.isNotEmpty) {
        websocket.establishConnection(
            channelInput: ConstantName.lastSubscribeDepth,
            task: "d",
            context: context);
      }
    }

    // Ensure current tab data is properly loaded
    if (ref.read(networkStateProvider).connectionStatus !=
        ConnectivityResult.none) {
      // Request data based on currently selected tab
      switch (indexProvide.selectedBtmIndx) {
        case 1:
          ref
              .read(marketWatchProvider)
              .requestMWScrip(context: context, isSubscribe: true);
          break;
        case 2:
          ref
              .read(portfolioProvider)
              .requestWSHoldings(context: context, isSubscribe: true);
          ref.read(portfolioProvider).timerfunc();
          ref
              .read(portfolioProvider)
              .requestWSPosition(context: context, isSubscribe: true);
          ref
              .read(orderProvider)
              .requestWSOrderBook(context: context, isSubscribe: true);
          break;
        // case 3:
        //   ref
        //       .read(orderProvider)
        //       .requestWSOrderBook(context: context, isSubscribe: true);
        //   break;
        case 4:
          // Profile tab has no websocket dependency
          break;
      }
    }
  }

  // Extract chart data handling to separate method
  void _handleChartData() {
    if (!mounted) return;

    final userProfile = ref.read(userProfileProvider);
    final scriptInfo = ref.read(marketWatchProvider).getQuotes;

    if (userProfile.showchartof && scriptInfo?.exch != null) {
      ref.read(marketWatchProvider).setChartScript(scriptInfo!.exch.toString(),
          scriptInfo.token.toString(), scriptInfo.tsym.toString());
    } else if (userProfile.showchartof) {
      userProfile.setChartdialog(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // It displays a dialogue to update our Application if the version has changed from the previous version.
    // var upgrader = Upgrader(
    //   messages: MyUpgraderMessages(),
    // );

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          bool shouldExit = await showExitPopup();
          if (shouldExit) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset:
              ref.read(userProfileProvider).showchartof ? false : true,
          body: Stack(
            children: [
              _buildMainScaffold(),
              _buildChartOverlay(),
            ],
          ),
        ));
  }

  // Main scaffold with navigation and content
  Widget _buildMainScaffold() {
    // Watch network and websocket state to respond to changes
    return Consumer(
      builder: (context, ref, _) {
        final internet = ref.watch(networkStateProvider);
        final websocket = ref.watch(websocketProvider);

        // Show no internet screen if needed - only when there's truly no connection or
        // maximum reconnection attempts reached without successful reconnection
        if ((internet.connectionStatus == ConnectivityResult.none ||
                websocket.connectioncount >= 5) &&
            !websocket.reconnectionSuccess &&
            !websocket.wsConnected) {
          // Pass the context to the network provider to enable reconnection attempts
          ref.read(networkStateProvider).getContext(context);

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body: NoInternetScreen(
              onReconnectionSuccess: _handleReconnectionSuccess,
            ),
          );
        }

        // When internet has been restored, ensure websocket connection is properly re-established
        if (internet.connectionStatus != ConnectivityResult.none &&
            !websocket.wsConnected &&
            websocket.retryscreen) {
          // This ensures we properly reconnect websocket when returning from no internet state
          Future.microtask(() {
            if (mounted) {
              _handleWebSocketConnections();
              // Reset the retryscreen flag to prevent duplicate reconnection attempts
              websocket.changeretryscreen(false);
              // Force UI refresh to ensure navigation works
              _handleReconnectionSuccess();
            }
          });
        }

        // Otherwise show the main app content
        // Use select to listen only to the selected bottom index
        final selectedBtmIndx = ref.watch(indexListProvider
            .select((indexProvide) => indexProvide.selectedBtmIndx));

        final theme = ref.watch(
            themeProvider); // Theme is used throughout, so watching the whole provider is acceptable here

        return Scaffold(
          // Pass only the selected index to the AppBar builder
          appBar: _buildAppBar(selectedBtmIndx, theme.isDarkMode),
          bottomNavigationBar: buildBottomNav(selectedBtmIndx, theme),
          // Pass only the selected index and theme to the Body builder
          body: _buildBody(selectedBtmIndx, theme),
        );
      },
    );
  }

  // Handle successful reconnection after internet issues
  void _handleReconnectionSuccess() {
    if (!mounted) return;

    // Ensure all navigation is working by forcing a rebuild
    setState(() {
      // This rebuild ensures navigation handlers are properly attached
    });

    // Make sure data for current tab is loaded
    final selectedTab = ref.read(indexListProvider).selectedBtmIndx;

    // Reload essential data based on selected tab
    switch (selectedTab) {
      // case 0: // Mutual Fund
      //   // ref.read(mfProvider).mfExTabchange(2);
      //   break;
      case 1: // Watchlist
        ref.read(marketWatchProvider).fetchMWList(context, false);
        break;
      case 2: // Portfolio
        ref.read(portfolioProvider).fetchHoldings(context, "");
        ref.read(portfolioProvider).fetchPositionBook(context, false);
        break;
      case 4: // Profile
        ref.read(userProfileProvider).fetchUserDetail(context);
        break;
    }
  }

  // Chart overlay component
  Widget _buildChartOverlay() {
    return Consumer(
      builder: (context, ref, _) {
        // Use select to listen only to the showchartof property
        final showChart = ref.watch(userProfileProvider
            .select((userProfile) => userProfile.showchartof));
        final webViewKey = ref.watch(userProfileProvider
            .select((userProfile) => userProfile.webViewKey));
        final theme = ref.watch(themeProvider); // Theme is used here

        return Positioned(
          key: webViewKey,
          bottom: showChart ? 0 : (MediaQuery.of(context).size.height + 100),
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastLinearToSlowEaseIn,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ChartScreenWebView(
                      chartArgs:
                          ChartArgs(exch: 'ABC', tsym: 'ABCD', token: '0123')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // App bar based on selected tab
  // Accept selectedTab and isDarkMode as parameters to avoid watching providers here
  PreferredSizeWidget? _buildAppBar(int selectedTab, bool isDarkMode) {
    // Return null for first tab
    if (selectedTab == 0) {
      return null;
    }

    // For watchlist tab, only show the index list
    if (selectedTab == 1) {
      return AppBar(
        shadowColor: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        elevation: 0,
        backgroundColor:
            isDarkMode ? const Color(0xff121212) : colors.colorWhite,
        automaticallyImplyLeading: false,
        title: null,
        bottom: _buildAppBarBottom(selectedTab),
      );
    }

    // if (selectedTab == 1) {
    //   return null;
    // }

    // For other tabs
    else if (selectedTab == 2) {
      return AppBar(
        shadowColor: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        leadingWidth: 205,
        elevation: selectedTab == 3 || selectedTab == 2 ? 0 : 0.3,
        leading: _buildAppBarLeading(selectedTab),
        actions: _buildAppBarActions(selectedTab),
        bottom: _buildAppBarBottom(selectedTab),
      );
    }
    return null;
  }

  // App bar leading widget based on selected tab
  Widget _buildAppBarLeading(int selectedTab) {
    if (selectedTab == 1) {
      return Consumer(builder: (context, ref, _) {
        // Use select to listen only to the watchlist name and scrips count
        final wlName = ref.watch(
            marketWatchProvider.select((marketWatch) => marketWatch.wlName));
        final scripsLength = ref.watch(marketWatchProvider
            .select((marketWatch) => marketWatch.scrips.length));
        // Use select for isPreDefWLs
        final isPreDefWLs = ref.watch(marketWatchProvider
            .select((marketWatch) => marketWatch.isPreDefWLs));
        // Use select for holdings count
        final holdingsLength = ref.watch(portfolioProvider
            .select((portfolio) => portfolio.holdingsModel!.length));
        final theme = ref.watch(themeProvider); // Theme is needed here

        return InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              showModalBottomSheet(
                  useSafeArea: true,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16))),
                  context: context,
                  builder: (context) {
                    return WatchlistsBottomSheet(currentWLName: wlName);
                  });
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      wlName.isEmpty
                          ? wlName
                          : isPreDefWLs == "Yes"
                              ? wlName == "My Stocks"
                                  ? wlName
                                  : wlName
                              : "${wlName[0].toUpperCase()}${wlName.substring(1)}'s Watchlist",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                      wlName == "My Stocks"
                          ? "(${holdingsLength})"
                          : "(${scripsLength})",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                          15,
                          FontWeight.w600)),
                  const SizedBox(width: 3),
                  SvgPicture.asset(assets.downArrow,
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue,
                      width: 14)
                ])));
      });
    } else if (selectedTab == 2) {
      return Consumer(builder: (context, ref, _) {
        final theme = ref.watch(themeProvider); // Theme is needed here

        return Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextWidget.heroText(
                  text: selectedTab == 3
                      ? "Orders"
                      : selectedTab == 2
                          ? "Portfolio"
                          : "Dashboard",
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                  theme: false)
            ],
          ),
        );
      });
    } else {
      return const SizedBox.shrink();
    }
  }

  // App bar actions based on selected tab
  List<Widget>? _buildAppBarActions(int selectedTab) {
    // Default empty list
    if (selectedTab == 0) {
      return null; // Return null for no actions
    }

    // Watchlist actions (tab 1)
    if (selectedTab == 1) {
      // Return the extracted widget within a list
      // return [_WatchlistActions()];
      return null;
    }

    // Portfolio actions (tab 2)
    if (selectedTab == 2) {
      // Return the extracted widget within a list
      return [_PortfolioActions()];
    }

    // Default empty list for other tabs
    return null; // Return null for no actions
  }

  // App bar bottom component
  PreferredSizeWidget? _buildAppBarBottom(int selectedTab) {
    if (selectedTab == 1) {
      return PreferredSize(
          preferredSize:
              const Size(double.infinity, 10), // Use double.infinity for width
          child: Consumer(builder: (context, WidgetRef ref, _) {
            final theme = ref.watch(themeProvider);
            return Container(
              // color: theme.isDarkMode
              //     ? const Color(0xFF1A1A1A)
              //     : const Color(0xFFF1F3F8),
              child: const DefaultIndexList(src: true),
            );
          }));
    }
    // else if (selectedTab == 4) {
    //   return PreferredSize(
    //     preferredSize: const Size(20, 8), // Adjust height as needed
    //     child: _buildUserProfileSection(), // Use the extracted widget
    //   );
    // }
    return null;
  }

  // Build user profile tile for profile tab
  Widget _buildUserProfileSection() {
    return _UserProfileTile();
  }

  // Helper function for profile name truncation
  String _truncateProfileName(String text, {int maxLength = 12}) {
    return (text.length > maxLength)
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  // Body content
  Widget _buildBody(int selectedTab, ThemesProvider theme) {
    return Consumer(builder: (context, ref, _) {
      // Use select to listen only to the connectionStatus
      final internetStatus = ref.watch(
          networkStateProvider.select((internet) => internet.connectionStatus));
      // Use select to listen only to the showchartof property
      final showChart = ref.watch(
          userProfileProvider.select((userProfile) => userProfile.showchartof));

      if ((internetStatus == ConnectivityResult.wifi ||
              internetStatus == ConnectivityResult.mobile) &&
          !showChart) {
        // Use the selected tab directly to return the corresponding screen
        return _onItemTapped(selectedTab, theme);
      }
      return SizedBox.shrink();
    });
  }

  // Bottom navigation
  Widget buildBottomNav(int selectedTab, ThemesProvider theme) {
    Preferences pref = Preferences();

    final uid = pref.clientId!;
    return BottomAppBar(
      height: 64,
      shadowColor:
          theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // _buildBottomNavItem(0, assets.home, "Home", selectedTab, theme),
          _buildBottomNavItem(
              1, assets.watchlistIcon, "Watchlists", selectedTab, theme),
          _buildBottomNavItem(
              2, assets.portfolioIcon, "Portfolio", selectedTab, theme),
          _buildBottomNavItem(
              3, assets.mfIcon, "Mutual Fund", selectedTab, theme),
          _buildBottomNavItem(4, assets.profileIcon, uid, selectedTab, theme,
              useHeight: true, height: 18),
        ],
      ),
    );
  }

  // Single bottom navigation item
  Widget _buildBottomNavItem(int index, String iconAsset, String label,
      int selectedIndex, ThemesProvider theme,
      {bool useHeight = false, double height = 24}) {
    final isSelected = selectedIndex == index;
    // We'll still check internet status but avoid using it to disable navigation
    final internetStatus = ref.watch(
        networkStateProvider.select((internet) => internet.connectionStatus));

    return Expanded(
      child: RepaintBoundary(
        child: InkWell(
          onTap: () {
            // Always allow navigation taps regardless of internet status
            // This ensures UI stays interactive even during reconnection
            switch (index) {
              // case 0:
              //   _handleDashboardTap();
              //   break;
              case 1:
                _handleWatchlistTap();
                break;
              case 2:
                _handlePortfolioTap();
                break;
              case 3:
                _handleMutualFundTap();
                break;
              case 4:
                _handleProfileTap();
                break;
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
                border: isSelected
                    ? Border(
                        top: BorderSide(
                            color: theme.isDarkMode
                                ? colors.colorLightBlue
                                : colors.colorBlue,
                            width: 2))
                    : null),
            child: Column(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 8),
                    useHeight
                        ? SizedBox(
                            child: SvgPicture.asset(
                              iconAsset,
                              height: height,
                              color: _getBottomNavColor(theme, isSelected),
                            ),
                          )
                        : SvgPicture.asset(
                            iconAsset,
                            // width: index == 0 ? 20 : null,
                            color: _getBottomNavColor(theme, isSelected),
                          ),
                    SizedBox(height: index == 3 ? 6 : 8),
                  ],
                ),
                Text(
                  label,
                  style: TextWidget.textStyle(
                    fontSize: 12,
                    color: _getBottomNavColor(theme, isSelected),
                    theme: theme.isDarkMode,

                    // fw: isSelected ? 1 : 00
                  ),
                  textAlign: TextAlign.center,
                  // softWrap: true,
                  // maxLines: 1,
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for nav item color
  Color _getBottomNavColor(ThemesProvider theme, bool isSelected) {
    if (theme.isDarkMode && isSelected) {
      return colors.colorLightBlue;
    } else if (isSelected) {
      return colors.colorBlue;
    } else {
      return colors.colorGrey;
    }
  }

  // Bottom nav handlers
  _handleDashboardTap() async {
    final indexProvide = ref.read(indexListProvider);
    final portfolio = ref.read(portfolioProvider);
    final marketWatchList = ref.read(marketWatchProvider);
    final orderProviderRef = ref.read(orderProvider);
    final fundProviderRef = ref.read(fundProvider);

    indexProvide.bottomMenu(0, context);
    portfolio.cancelTimer();

    // Unsubscribe from real-time data for other tabs
    marketWatchList.requestMWScrip(context: context, isSubscribe: false);
    portfolio.requestWSHoldings(context: context, isSubscribe: false);
    orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    portfolio.requestWSPosition(context: context, isSubscribe: false);

    // Fetch data in the background without blocking UI transition
    Future.microtask(() {
      if (mounted) {
        // Portfolio data
        portfolio.fetchHoldings(context, "");
        portfolio.fetchPositionBook(context, false);

        // Funds data
        fundProviderRef.fetchFunds(context);
      }
    });
  }

  void _handleWatchlistTap() async {
    final indexProvide = ref.read(indexListProvider);
    final portfolio = ref.read(portfolioProvider);
    final marketWatchList = ref.read(marketWatchProvider);
    final orderProviderRef = ref.read(orderProvider);

    indexProvide.bottomMenu(1, context);
    portfolio.cancelTimer();

    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await orderProviderRef.requestWSOrderBook(
        context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await marketWatchList.requestMWScrip(context: context, isSubscribe: true);

    // Load any additional watchlist data in the background
    // Future.microtask(() {
    //   if (mounted) {
    //     marketWatchList.fetchMWList(context, false);
    //   }
    // });
  }

  void _handlePortfolioTap() async {
    final indexProvide = ref.read(indexListProvider);
    final portfolio = ref.read(portfolioProvider);
    final marketWatchList = ref.read(marketWatchProvider);
    final orderProviderRef = ref.read(orderProvider);
    final fundProviderRef = ref.read(fundProvider);

    indexProvide.bottomMenu(2, context);

    // Run websocket subscription changes immediately (no await)
    await marketWatchList.requestMWScrip(context: context, isSubscribe: false);
    await orderProviderRef.requestWSOrderBook(
        context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: true);
    await portfolio.requestWSPosition(context: context, isSubscribe: true);

    await ref.read(transcationProvider).fetchValidateToken(context);

    await ref.read(transcationProvider).ip();
    await ref.read(transcationProvider).fetchupiIdView(
          ref
              .read(transcationProvider)
              .bankdetails!
              .dATA![ref.read(transcationProvider).indexss][1],
          ref
              .read(transcationProvider)
              .bankdetails!
              .dATA![ref.read(transcationProvider).indexss][2],
        );
    await ref.read(transcationProvider).fetchcwithdraw(context);

    // Fetch data in the background without blocking UI transition
    Future.microtask(() {
      if (mounted) {
        // Portfolio data
        portfolio.fetchHoldings(context, "");
        portfolio.fetchPositionBook(context, false);
        portfolio.fetchMFHoldings(context);

        // Funds data
        fundProviderRef.fetchFunds(context);

        // Order data for the Orders tab
        orderProviderRef.fetchOrderBook(context, false);
        orderProviderRef.fetchTradeBook(context);
        orderProviderRef.fetchSipOrderHistory(context);
        marketWatchList.fetchPendingAlert(context);
      }
    });

    // Start position update timer
    portfolio.timerfunc();
  }

  void _handleMutualFundTap() {
    final portfolio = ref.read(portfolioProvider);
    portfolio.cancelTimer();
    ref.read(indexListProvider).bottomMenu(3, context);
  }

  void _handleProfileTap() {
    final indexProvide = ref.read(indexListProvider);
    final portfolio = ref.read(portfolioProvider);
    final reportsprovider = ref.read(ledgerProvider);
    final fundProviderRef = ref.read(fundProvider);
    final userProfile = ref.read(userProfileProvider);
    final marketWatchList = ref.read(marketWatchProvider);
    final orderProviderRef = ref.read(orderProvider);
    final authProviderRef = ref.read(authProvider);

    indexProvide.bottomMenu(4, context);
    portfolio.cancelTimer();

    // Load minimal required profile data
    // fundProviderRef.fetchFunds(context);
    userProfile.fetchprofilemenu();

    // Unsubscribe from other real-time data
    marketWatchList.requestMWScrip(context: context, isSubscribe: false);
    portfolio.requestWSHoldings(context: context, isSubscribe: false);
    orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    portfolio.requestWSPosition(context: context, isSubscribe: false);

    // Load profile data in the background
    Future.microtask(() async {
      if (mounted) {
        // User profile and account details
        userProfile.fetchUserDetail(context);
        userProfile.fetchprofilemenu();

        // Funds data
        fundProviderRef.fetchFunds(context);

        // IPOs
        authProviderRef.setIposAPicalls();
        // mf
        authProviderRef.setmfapicalls(context);

        await ref.read(userProfileProvider).fetchsetting();
        await ref.read(apikeyprovider).fetchapikey(context);
        await ref.read(notificationprovider).fetchexchagemsg(context);
        await ref.read(notificationprovider).fetchbrokermsg(context);

        //funds

        await ref.read(transcationProvider).fetchValidateToken(context);

        await ref.read(transcationProvider).ip();
        await ref.read(transcationProvider).fetchupiIdView(
              ref
                  .read(transcationProvider)
                  .bankdetails!
                  .dATA![ref.read(transcationProvider).indexss][1],
              ref
                  .read(transcationProvider)
                  .bankdetails!
                  .dATA![ref.read(transcationProvider).indexss][2],
            );
        await ref.read(transcationProvider).fetchcwithdraw(context);

        //// reports/////
        if (reportsprovider.ledgerAllData == null) {
          await reportsprovider.getCurrentDate('else');
          reportsprovider.fetchLegerData(
              context, reportsprovider.startDate, reportsprovider.endDate);
        }

        if (reportsprovider.pnlAllData == null) {
          await reportsprovider.getCurrentDate('else');
          reportsprovider.fetchpnldata(
              context, reportsprovider.startDate, reportsprovider.today, true);
        }
        if (reportsprovider.calenderpnlAllData == null) {
          await reportsprovider.getCurrentDate('else');
          reportsprovider.calendarProvider();
          reportsprovider.fetchsharingdata(reportsprovider.startDate,
              reportsprovider.today, 'Equity', context);
          reportsprovider.fetchcalenderpnldata(context,
              reportsprovider.startDate, reportsprovider.today, 'Equity');
        }
        if (reportsprovider.taxpnldercomcur == null &&
            reportsprovider.taxpnleq == null) {
          await reportsprovider.getYearlistTaxpnl();
          reportsprovider.getCurrentDate('');
          reportsprovider.fetchtaxpnleqdata(
              context, reportsprovider.yearforTaxpnl);

          reportsprovider.taxpnlExTabchange(0);
          reportsprovider.chargesforeqtaxpnl(
              context, reportsprovider.yearforTaxpnl);
        }
        if (reportsprovider.tradebookdata == null) {
          await reportsprovider.getCurrentDate('tradebook');
          reportsprovider.fetchtradebookdata(
              context, reportsprovider.startDate, reportsprovider.today);
        }
        if (reportsprovider.pdfdownload == null) {
          await reportsprovider.getCurrentDate('else');
          reportsprovider.fetchpdfdownload(
              context, reportsprovider.startDate, reportsprovider.today);
        }
        if (reportsprovider.pledgeandunpledge == null) {
          await reportsprovider.getCurrentDate("pandu");
          reportsprovider.fetchpledgeandunpledge(context);
        }
        // if (reportsprovider.positiondata == null) {
        //    reportsprovider.fetchposition(context);
        // }
        if (reportsprovider.caeventalldata == null) {
          await reportsprovider.getCurrentDate('caevent');
          reportsprovider.fetchcaeventsdata(
              context, reportsprovider.startDate, reportsprovider.endDate);
        }
        if (reportsprovider.holdingsAllData == null) {
          await reportsprovider.getCurrentDate('else');
          await reportsprovider.fetchholdingsData(
              reportsprovider.today, context);
        }
        // cop action
        if (reportsprovider.cpactiondata == null) {
          reportsprovider.fetchcpactiondata(context);
        }
      }
    });
  }

// The screen will change depending on the condition when you click on the bottom menu items.
  Widget _onItemTapped(int index, ThemesProvider theme) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        // The WatchListScreen itself will handle listening to marketWatchProvider
        return const WatchListScreen();
      case 2:
        return const PortfolioScreen();
      case 3:
        // Navigate to mutual fund screen
        return const MfmainScreen();
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   ref.read(indexListProvider).bottomMenu(1, context);
      //   Navigator.pushNamed(context, Routes.mfmainscreen);
      // });
      // return const SizedBox.shrink();
      case 4:
        return const UserAccountScreen();
      default:
        return const SizedBox.shrink();
    }
  }

// If an application asks for user confirmation before you can exit it, do so.
  Future<bool> showExitPopup() async {
    if (ref.read(userProfileProvider).showchartof) {
      // Use ref.read for calls that don't need a rebuild
      ref.read(userProfileProvider).setChartdialog(false);
      ref.read(chartUpdateProvider).changeOrientation('portrait');

      final mktwth = ref.read(marketWatchProvider);
      mktwth.chngDephBtn("Overview");
      mktwth.singlePageloader(true);

      // Ensure context is passed if needed by calldepthApis
      mktwth.calldepthApis(context, mktwth.getQuotes, "");

      mktwth.singlePageloader(false);

      // Update state locally if needed
      if (mounted) setState(() {});

      ref.read(marketWatchProvider).setChartScript('ABC', '0123', 'ABCD');
      return false; // Prevent back navigation when chart is visible
    } else {
      return await showDialog(
              context: context,
              builder: (BuildContext context) {
                // Use ref.read where state is not needed for building the dialog
                final theme = ref.read(themeProvider);
                return AlertDialog(
                    backgroundColor: colors.colorWhite,
                    titlePadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    scrollable: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    actionsPadding: const EdgeInsets.only(
                        bottom: 16, right: 16, left: 16, top: 8),
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    title: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () async {
                                  await Future.delayed(
                                      const Duration(milliseconds: 150));
                                  Navigator.of(context).pop(false);
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: theme.isDarkMode
                                    ? colors.splashColorDark
                                    : colors.splashColorLight,
                                highlightColor: theme.isDarkMode
                                    ? colors.splashColorDark
                                    : colors.splashColorLight,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22,
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: TextWidget.subText(
                              text: "Do you want to Exit the App?",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40), // width, height
                            side: BorderSide(
                                color: colors
                                    .btnOutlinedBorder), // Outline border color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor:
                                colors.primaryDark, // Transparent background
                          ),
                          child: TextWidget.titleText(
                            text: "Exit",
                            color: !theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            theme: theme.isDarkMode,
                            fw: 0,
                          ),
                        ),
                      ),
                    ]);
              }) ??
          false;
    }
  }
}

// Watchlist actions component
class _WatchlistActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref.read outside the Consumer builder for method calls
    final marketWatchProviderRef = ref.read(marketWatchProvider);

    return Row(
      children: [
        // Use Consumer here to watch specific properties
        Consumer(builder: (context, ref, _) {
          // Use select to listen only to isPreDefWLs and scrips length
          final isPreDefWLs = ref.watch(marketWatchProvider
              .select((marketWatch) => marketWatch.isPreDefWLs));
          final scripsLength = ref.watch(marketWatchProvider
              .select((marketWatch) => marketWatch.scrips.length));

          if (isPreDefWLs != "Yes" && scripsLength > 1) {
            return InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                    useSafeArea: true,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    context: context,
                    builder: (context) {
                      return const ScripFilterBottomSheet();
                    });
              },
              child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 10),
                  child: SvgPicture.asset(assets.filterLines,
                      width: 19, color: colors.colorGrey)),
            );
          }
          return const SizedBox.shrink();
        }),
        Consumer(builder: (context, ref, _) {
          // Add another Consumer for the search icon
          // Use select for wlName
          final wlName = ref.watch(
              marketWatchProvider.select((marketWatch) => marketWatch.wlName));

          return InkWell(
            onTap: () {
              // Use the ref.read obtained outside the Consumer
              marketWatchProviderRef.requestMWScrip(
                  context: context, isSubscribe: false);
              Navigator.pushNamed(context, Routes.searchScrip,
                  arguments: wlName);
            },
            child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 8),
                child: SvgPicture.asset(assets.searchIcon,
                    width: 19, color: colors.colorGrey)),
          );
        }),
      ],
    );
  }
}

// Portfolio actions stub
class _PortfolioActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to listen only to the selectedTab and allPostionList length
    final selectedTab = ref
        .watch(portfolioProvider.select((portfolio) => portfolio.selectedTab));
    final allPostionListLength = ref.watch(portfolioProvider
        .select((portfolio) => portfolio.allPostionList.length));

    if (selectedTab == 0 && allPostionListLength > 0) {
      // return _PositionGroupActions();
    } else if (selectedTab == 2) {
      // Orders tab
      // return _OrdersActions();
    } else if (selectedTab == 3) {
      // Funds tab
      return _FundsWebActions();
    }

    return SizedBox.shrink();
  }
}

// Orders actions
// class _OrdersActions extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Use select to listen only to the selectedTab from order provider
//     final selectedTab = ref.watch(
//         orderProvider.select((orderProvider) => orderProvider.selectedTab));
//     final theme = ref.watch(themeProvider); // Theme is needed here

//     if (selectedTab == 4) {
//       // Basket tab
//       return Row(children: [
//         Container(
//           decoration: BoxDecoration(
//             color: colors.btnBg,
//             borderRadius: BorderRadius.circular(5),
//             border: Border.all(color: colors.btnOutlinedBorder, width: 1),
//           ),
//           child: Material(
//             color: Colors.transparent,
//             shape: const BeveledRectangleBorder(),
//             child: InkWell(
//                 customBorder: const BeveledRectangleBorder(),
//                 splashColor: theme.isDarkMode
//                     ? colors.splashColorDark
//                     : colors.splashColorLight,
//                 highlightColor: theme.isDarkMode
//                     ? colors.highlightDark
//                     : colors.highlightLight,
//                 onTap: () {
//                   Future.delayed(const Duration(milliseconds: 150), () {
//                     showModalBottomSheet(
//                         context: context,
//                         useSafeArea: true,
//                         isScrollControlled: true,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.vertical(top: Radius.circular(16)),
//                         ),
//                         builder: (BuildContext context) {
//                           return const CreateBasket();
//                         });
//                   });
//                 },
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//                   child: TextWidget.subText(
//                       text: "Create Basket",
//                       theme: theme.isDarkMode,
//                       color: theme.isDarkMode
//                           ? colors.primaryDark
//                           : colors.primaryLight,
//                       fw: 2),
//                 )),
//           ),
//         ),
//         const SizedBox(width: 16),
//       ]);
//     }

//     return SizedBox.shrink();
//   }
// }

// Position group actions
class PositionGroupActions extends ConsumerWidget {
  // Make this a ConsumerWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    // Use select to listen only to exitAll, posSelection, and openPosition length
    final exitAll =
        ref.watch(portfolioProvider.select((portfolio) => portfolio.exitAll));
    final posSelection = ref
        .watch(portfolioProvider.select((portfolio) => portfolio.posSelection));
    final openPositionLength = ref.watch(portfolioProvider.select(
        (portfolio) => portfolio.openPosition?.length ?? 0)); // Handle null
    final portfolio =
        ref.read(portfolioProvider); // Use ref.read for method calls
    final theme = ref.watch(themeProvider); // Theme is needed here

    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: Row(children: [
        //                                                   Container(
        //                                                     height: 27,
        //   padding: const EdgeInsets.only(right: 10),
        //   child: OutlinedButton(
        //     onPressed: () {
        //                                                               showModalBottomSheet(
        //         useSafeArea: true,
        //         isScrollControlled: true,
        //         shape: const RoundedRectangleBorder(
        //           borderRadius: BorderRadius.vertical(top: Radius.circular(16))
        //         ),
        //                                                                   context: context,
        //                                                                   builder: (context) {
        //                                                                     return const PositionGroupBottomSheet();
        //         }
        //       );
        //                                                             },
        //                                                             style: OutlinedButton.styleFrom(
        //                                                                 side: BorderSide(
        //         color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack
        //       ),
        //                                                                 shape: const RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(32))
        //       )
        //     ),
        //                                                             child: Text(
        //                                                                 "Group by",
        //                                                                 style: textStyle(
        //                                                                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        //                                                                     12,
        //         FontWeight.w600
        //       )
        //     )
        //   ),
        // ),
        if (exitAll && posSelection == "All position" && openPositionLength > 1)
          SizedBox(
            height: 27,
            child: OutlinedButton(
                // Pass ref to _showExitAllDialog
                onPressed: ref.watch(portfolioProvider).isExitingAll
                    ? null // Disable button while exiting
                    : () => _showExitAllDialog(context, portfolio, ref),
                style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32)))),
                child: ref.watch(portfolioProvider).isExitingAll
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                        ))
                    : Text("Exit All",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            12,
                            FontWeight.w600))),
          ),
      ]),
    );
  }

  // Show exit all positions dialog - Accept ref
  void _showExitAllDialog(
      BuildContext context, dynamic portfolio, WidgetRef ref) {
    final theme = ref.read(themeProvider); // Use ref.read here

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulBuilder to manage local dialog state
        return StatefulBuilder(builder: (context, setState) {
          // Track local loading state
          bool isExiting = false;

          return AlertDialog(
            backgroundColor: theme.isDarkMode
                ? const Color.fromARGB(255, 18, 18, 18)
                : colors.colorWhite,
            titleTextStyle: textStyles.appBarTitleTxt.copyWith(
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
            contentTextStyle: textStyles.menuTxt.copyWith(
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14))),
            scrollable: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text("Exit Position"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Are you sure you want to exit all positions?")
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed:
                      isExiting ? null : () => Navigator.of(context).pop(),
                  child: Text("No",
                      style: textStyles.textBtn.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue))),
              Consumer(builder: (context, ref, _) {
                final isExitingAll = ref.watch(portfolioProvider).isExitingAll;

                return ElevatedButton(
                  onPressed: isExitingAll
                      ? null
                      : () async {
                          // Use setState to update local loading state
                          setState(() => isExiting = true);

                          // Execute the exit position
                          await portfolio.exitPosition(context, true);

                          // Close the dialog
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  child: isExitingAll
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: !theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                          ),
                        )
                      : Text("Yes",
                          style: textStyle(
                              !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                );
              }),
            ],
          );
        });
      },
    );
  }
}

// Funds web actions
class _FundsWebActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, top: 16),
      child: InkWell(
        onTap: () async {
          // Use ref.read for providers when just calling methods
          final funds = ref.read(fundProvider);
          final pref = Preferences();

          await funds.fetchHstoken(context);

          Future.delayed(const Duration(microseconds: 10), () {
            launch(
                'https://fund.mynt.in/fund/?sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}&src=app');
          });
        },
        child: Text(
          "Web",
          style: textStyle(colors.colorBlue, 14, FontWeight.w600),
        ),
      ),
    );
  }
}

// Orderbook actions
class _OrderbookActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to listen only to the selectedTab
    final selectedTab = ref.watch(
        orderProvider.select((orderProvider) => orderProvider.selectedTab));
    final theme = ref.watch(themeProvider); // Theme is needed here

    if (selectedTab == 3) {
      return Row(children: [
        Container(
            margin: const EdgeInsets.only(right: 8),
            height: 30,
            child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (BuildContext context) {
                        return const CreateBasket();
                      });
                },
                style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: theme.isDarkMode
                            ? colors.colorGrey
                            : colors.colorBlack),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32)))),
                child: Text("Create Basket",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        12,
                        FontWeight.w600))))
      ]);
    }

    return SizedBox.shrink();
  }
}

// User profile tile
class _UserProfileTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to listen only to the userloader property
    final userloader = ref.watch(
        userProfileProvider.select((userProfile) => userProfile.userloader));
    final theme = ref.watch(themeProvider); // Theme is needed here
    final userProfile = ref
        .read(userProfileProvider); // Use ref.read for accessing data directly

    if (userloader) {
      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: CircleAvatar(
          backgroundColor:
              !theme.isDarkMode ? Colors.grey[300] : Color(0xff666666),
        ),
        title: Container(
          height: 16,
          width: 150,
          color: !theme.isDarkMode ? Colors.grey[300] : Color(0xff666666),
        ),
        subtitle: Container(
          height: 12,
          width: 100,
          color: !theme.isDarkMode ? Colors.grey[300] : Color(0xff666666),
        ),
        trailing: Container(
          height: 24,
          width: 50,
          color: !theme.isDarkMode ? Colors.grey[300] : Color(0xff666666),
        ),
      );
    }

    // Use select to listen only to uname and uid
    final uname = ref.watch(userProfileProvider.select(
        (userProfile) => userProfile.userDetailModel?.uname?.toString() ?? ""));
    final uid = ref.watch(userProfileProvider.select(
        (userProfile) => userProfile.userDetailModel?.uid?.toString() ?? ""));

    return ListTile(
        onTap: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              builder: (_) =>
                  const LoggedUserBottomSheet(initRoute: 'switchAcc'));
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: SvgPicture.asset(
          assets.myntnewLogo,
          width: 46,
          height: 46,
        ),
        title: Row(
          children: [
            Text(
                _truncateProfileName(
                    uname), // Use the local _truncateProfileName
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle(
                    Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                    16,
                    FontWeight.w600)),
            Icon(
              Icons.expand_more,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              size: 28,
            )
          ],
        ),
        subtitle: Text("Client ID: $uid",
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        trailing: SizedBox(
            width: 100,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                splashRadius: 26,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.qrscanner);
                },
                icon: SvgPicture.asset("assets/profile/qr_code.svg",
                    width: 28,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack),
              ),
            ])));
  }

  // Helper function for profile name truncation - Needs to be static or outside the widget
  // Moving this to _HomeScreenState as it was originally there
  String _truncateProfileName(String text, {int maxLength = 12}) {
    return (text.length > maxLength)
        ? '${text.substring(0, maxLength)}...'
        : text;
  }
}
