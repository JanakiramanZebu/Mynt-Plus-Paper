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
import '../provider/fund_provider.dart';
import '../provider/index_list_provider.dart';
import '../provider/market_watch_provider.dart';
import '../provider/network_state_provider.dart';
import '../provider/order_provider.dart';
import '../provider/portfolio_provider.dart';
import '../provider/thems.dart';
import '../provider/user_profile_provider.dart';
import '../provider/version_provider.dart';
import '../provider/websocket_provider.dart';
import '../provider/webview_chart_provider.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/internet_widget.dart';
import 'market_watch/index/index_screen.dart';
import 'market_watch/scrip_filter_bottom_sheet.dart';
import 'market_watch/tv_chart/webview_chart.dart';
import 'market_watch/watchlist_screen.dart';
import 'market_watch/watchlists_bottom_sheet.dart';
import 'order_book/basket/create_basket.dart';
import 'order_book/order_book_screen.dart';
import 'portfolio_screens/portfolio_screen.dart';
import 'portfolio_screens/positions/group/position_group_bottomsheet.dart';
import 'profile_screen/logged_user_bottom_sheet.dart';
import 'profile_screen/profile_main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late WebSocketProvider socketProvider; // Store the reference

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // FirebaseAnalytics.instance.logScreenView(
    //   screenName: 'HomeScreen',
    //   screenClass: 'HomeScreen', // Customize if needed.
    // );
// This is a websockt heartbeat connection that reconnects every two seconds only.
    ConstantName.timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        context.read(websocketProvider).reconnect(context);
        // context.read(websocketProvider).startPingCheck(context);
      }
    });
    context.read(networkStateProvider).networkStream();
    context.read(marketWatchProvider).fToast.init(context);
    context.read(versionProvider).checkVersion(context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketProvider = context.read(websocketProvider); // Store reference safely
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ConstantName.timer!.cancel();
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
            await context.read(indexListProvider).checkSession(context);
            
            // Only load data if session is valid and app is still mounted
            if (mounted && context.read(indexListProvider).checkSess?.stat == "Ok") {
              // Load these in parallel for better performance
              final futures = [
                context.read(portfolioProvider).fetchPositionBook(context, false),
                context.read(portfolioProvider).fetchHoldings(context, ""),
                context.read(orderProvider).fetchOrderBook(context, false),
                context.read(orderProvider).fetchTradeBook(context),
              ];
              
              await Future.wait(futures);
            }
            
            // Handle WebSocket connections after session validation
            _handleWebSocketConnections();
          } catch (e) {
            print("Error during app resume: $e");
          }
        });
        
        // Handle chart data in a separate task
        _handleChartData();
        break;
        
      case AppLifecycleState.inactive:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
        final userProfile = context.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        print("app in inactive");
        break;
        
      case AppLifecycleState.paused:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
        print("app in paused");
        break;
        
      case AppLifecycleState.detached:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
        final userProfile = context.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        print("app in detached");
        break;
        
      case AppLifecycleState.hidden:
        if (context.read(indexListProvider).selectedBtmIndx == 2) {
          context.read(portfolioProvider).cancelTimer();
        }
    }
  }
  
  // Extract WebSocket connection logic to separate method
  void _handleWebSocketConnections() {
    if (!mounted) return;
    
    final websocket = context.read(websocketProvider);
    
    if (websocket.wsConnected == false || websocket.wsConnected == true) {
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
      
      if (context.read(networkStateProvider).connectionStatus != ConnectivityResult.none) {
        websocket.changeconnectioncount();
        
        final indexProvide = context.read(indexListProvider);
        if (indexProvide.selectedBtmIndx == 1) {
          context.read(marketWatchProvider)
              .requestMWScrip(context: context, isSubscribe: true);
        }
        
        if (indexProvide.selectedBtmIndx == 2) {
          context.read(portfolioProvider)
              .requestWSHoldings(context: context, isSubscribe: true);
          context.read(portfolioProvider).timerfunc();
          context.read(portfolioProvider)
              .requestWSPosition(context: context, isSubscribe: true);
        }
        
        if (indexProvide.selectedBtmIndx == 3) {
          context.read(orderProvider)
              .requestWSOrderBook(context: context, isSubscribe: true);
        }
      }
    }
  }
  
  // Extract chart data handling to separate method
  void _handleChartData() {
    if (!mounted) return;
    
    final userProfile = context.read(userProfileProvider);
    final scriptInfo = context.read(marketWatchProvider).getQuotes;
    
    if (userProfile.showchartof && scriptInfo?.exch != null) {
      context.read(marketWatchProvider).setChartScript(
        scriptInfo!.exch.toString(),
        scriptInfo.token.toString(),
        scriptInfo.tsym.toString());
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
          resizeToAvoidBottomInset: context.read(userProfileProvider).showchartof ? false : true,
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
    final internet = context.read(networkStateProvider);
    final websocket = context.read(websocketProvider);
    
    // Show no internet screen if needed
    if (internet.connectionStatus == ConnectivityResult.none ||
        websocket.connectioncount >= 5) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xffFFFFFF),
        ),
        body: NoInternetScreen(),
      );
    }
    
    // Otherwise show the main app content
    return Consumer(
      builder: (context, watch, _) {
        final indexProvide = watch(indexListProvider);
        final theme = watch(themeProvider);
        
        return Scaffold(
          appBar: _buildAppBar(indexProvide),
          bottomNavigationBar: _buildBottomNav(indexProvide),
          body: _buildBody(indexProvide, theme),
        );
      },
    );
  }
  
  // Chart overlay component
  Widget _buildChartOverlay() {
    return Consumer(
      builder: (context, watch, _) {
        final userProfile = watch(userProfileProvider);
        final theme = watch(themeProvider);
        
        return Positioned(
          key: userProfile.webViewKey,
          bottom: userProfile.showchartof
            ? 0
            : (MediaQuery.of(context).size.height + 100),
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastLinearToSlowEaseIn,
            decoration: BoxDecoration(
              color: theme.isDarkMode
                ? colors.colorBlack
                : colors.colorWhite,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ChartScreenWebView(
                    chartArgs: ChartArgs(
                      exch: 'ABC',
                      tsym: 'ABCD',
                      token: '0123'
                    )
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // App bar based on selected tab
  PreferredSizeWidget? _buildAppBar(dynamic indexProvide) {
    // Return null for first tab
    if (indexProvide.selectedBtmIndx == 0) {
      return null;
    }
    
    return AppBar(
      shadowColor: context.read(themeProvider).isDarkMode
          ? colors.darkColorDivider
          : colors.colorDivider,
      leadingWidth: 205,
      elevation: .3,
      leading: _buildAppBarLeading(indexProvide.selectedBtmIndx),
      actions: _buildAppBarActions(indexProvide.selectedBtmIndx),
      bottom: _buildAppBarBottom(indexProvide.selectedBtmIndx),
    );
  }
  
  // App bar leading widget based on selected tab
  Widget _buildAppBarLeading(int selectedTab) {
    if (selectedTab == 1) {
      return Consumer(
        builder: (context, watch, _) {
          final marketWatchList = watch(marketWatchProvider);
          final portfolio = watch(portfolioProvider);
          final theme = watch(themeProvider);
          
          return InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              showModalBottomSheet(
                useSafeArea: true,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                context: context,
                builder: (context) {
                  return WatchlistsBottomSheet(currentWLName: marketWatchList.wlName);
                }
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      marketWatchList.wlName.isEmpty
                        ? marketWatchList.wlName
                        : marketWatchList.isPreDefWLs == "Yes"
                          ? marketWatchList.wlName == "My Stocks"
                            ? marketWatchList.wlName
                            : marketWatchList.wlName
                          : "${marketWatchList.wlName[0].toUpperCase()}${marketWatchList.wlName.substring(1)}'s Watchlist",
                      style: textStyle(
                        theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                        14,
                        FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    marketWatchList.wlName == "My Stocks"
                      ? "(${portfolio.holdingsModel!.length})"
                      : "(${marketWatchList.scrips.length})",
                    style: textStyle(
                      theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                      15,
                      FontWeight.w600)
                  ),
                  const SizedBox(width: 3),
                  SvgPicture.asset(
                    assets.downArrow,
                    color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                    width: 14
                  )
                ]
              )
            )
          );
        }
      );
    } else {
      return Consumer(
        builder: (context, watch, _) {
          final theme = watch(themeProvider);
          
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  selectedTab == 3
                    ? "Orderbook"
                    : selectedTab == 2
                      ? "Portfolio"
                      : "Dashboard",
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    17,
                    FontWeight.w600)
                ),
              ],
            ),
          );
        }
      );
    }
  }
  
  // App bar actions based on selected tab
  List<Widget> _buildAppBarActions(int selectedTab) {
    // Default empty list
    if (selectedTab == 0) {
      return [];
    }
    
    // Watchlist actions (tab 1)
    if (selectedTab == 1) {
      return [
        Consumer(builder: (context, watch, _) {
          final marketWatchList = watch(marketWatchProvider);
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (marketWatchList.isPreDefWLs != "Yes" && marketWatchList.scrips.length > 1)
                InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    showModalBottomSheet(
                      useSafeArea: true,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                      ),
                      context: context,
                      builder: (context) {
                        return const ScripFilterBottomSheet();
                      }
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 10),
                    child: SvgPicture.asset(
                      assets.filterLines,
                      width: 19,
                      color: colors.colorGrey
                    )
                  ),
                ),
              InkWell(
                onTap: () {
                  context.read(marketWatchProvider).requestMWScrip(
                    context: context,
                    isSubscribe: false
                  );
                  Navigator.pushNamed(
                    context,
                    Routes.searchScrip,
                    arguments: marketWatchList.wlName
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: SvgPicture.asset(
                    assets.searchIcon,
                    width: 19,
                    color: colors.colorGrey
                  )
                ),
              ),
            ],
          );
        }),
      ];
    }
    
    // Portfolio actions (tab 2)
    if (selectedTab == 2) {
      return [
        Consumer(builder: (context, watch, _) {
          final portfolio = watch(portfolioProvider);
          final theme = watch(themeProvider);
          final funds = watch(fundProvider);
          
          if (portfolio.selectedTab == 0 && portfolio.allPostionList.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 27,
                    padding: const EdgeInsets.only(right: 10),
                    child: OutlinedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          useSafeArea: true,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                          ),
                          context: context,
                          builder: (context) {
                            return const PositionGroupBottomSheet();
                          }
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32))
                        )
                      ),
                      child: Text(
                        "Group by",
                        style: textStyle(
                          theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                          12,
                          FontWeight.w600
                        )
                      )
                    ),
                  ),
                  if (portfolio.exitAll && 
                      portfolio.posSelection == "All position" && 
                      portfolio.openPosition!.length > 1)
                    SizedBox(
                      height: 27,
                      child: OutlinedButton(
                        onPressed: () {
                          _showExitAllDialog(context, portfolio);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32))
                          )
                        ),
                        child: Text(
                          "Exit All",
                          style: textStyle(
                            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                            12,
                            FontWeight.w600
                          )
                        )
                      ),
                    ),
                ],
              ),
            );
          } else if (portfolio.selectedTab == 2) {
            return Padding(
              padding: const EdgeInsets.only(right: 15, top: 16),
              child: InkWell(
                onTap: () async {
                  final pref = Preferences();
                  await funds.fetchHstoken(context);
                  
                  Future.delayed(const Duration(microseconds: 10), () {
                    launch('https://fund.mynt.in/fund/?sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}&src=app');
                  });
                },
                child: Text(
                  "Web",
                  style: textStyle(colors.colorBlue, 14, FontWeight.w600),
                ),
              ),
            );
          }
          
          return const SizedBox.shrink();
        }),
      ];
    }
    
    // Orderbook actions (tab 3)
    if (selectedTab == 3) {
      return [
        Consumer(builder: (context, watch, _) {
          final orderProviderWatch = watch(orderProvider);
          final theme = watch(themeProvider);
          
          if (orderProviderWatch.selectedTab == 4) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateBasket();
                        }
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32))
                      )
                    ),
                    child: Text(
                      "Create Basket",
                      style: textStyle(
                        theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                        12,
                        FontWeight.w600
                      )
                    )
                  )
                )
              ],
            );
          }
          
          return const SizedBox.shrink();
        }),
      ];
    }
    
    // Default empty list for other tabs
    return [];
  }
  
  // App bar bottom component
  PreferredSizeWidget? _buildAppBarBottom(int selectedTab) {
    if (selectedTab == 1) {
      return PreferredSize(
        preferredSize: const Size(20, 44),
        child: DefaultIndexList(src: false)
      );
    } else if (selectedTab == 4) {
      return PreferredSize(
        preferredSize: const Size(20, 8),
        child: _buildUserProfileSection(),
      );
    }
    return null;
  }
  
  // Build user profile tile for profile tab
  Widget _buildUserProfileSection() {
    return Consumer(builder: (context, watch, _) {
      final userProfile = watch(userProfileProvider);
      final theme = watch(themeProvider);
      
      if (userProfile.userloader) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: !theme.isDarkMode
              ? Colors.grey[300]
              : Color(0xff666666),
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
      
      final uname = userProfile.userDetailModel?.uname?.toString() ?? "";
      final uid = userProfile.userDetailModel?.uid?.toString() ?? "";
      
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
            builder: (_) => const LoggedUserBottomSheet(initRoute: 'switchAcc')
          );
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
              _truncateProfileName(uname),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle(
                Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                16,
                FontWeight.w600
              )
            ),
            Icon(
              Icons.expand_more,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              size: 28,
            )
          ],
        ),
        subtitle: Text(
          "Client ID: $uid",
          style: textStyle(
            const Color(0xff666666),
            12,
            FontWeight.w500
          )
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                splashRadius: 26,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.qrscanner);
                },
                icon: SvgPicture.asset(
                  "assets/profile/qr_code.svg",
                  width: 28,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
                ),
              ),
            ]
          )
        )
      );
    });
  }
  
  // Helper function for profile name truncation
  String _truncateProfileName(String text, {int maxLength = 12}) {
    return (text.length > maxLength)
        ? '${text.substring(0, maxLength)}...'
        : text;
  }
  
  // Body content
  Widget _buildBody(dynamic indexProvide, dynamic theme) {
    return Consumer(
      builder: (context, watch, _) {
        final internet = watch(networkStateProvider);
        final userProfile = watch(userProfileProvider);
        
        if ((internet.connectionStatus == ConnectivityResult.wifi ||
            internet.connectionStatus == ConnectivityResult.mobile) &&
            !userProfile.showchartof) {
          return _onItemTapped(indexProvide.selectedBtmIndx, theme);
        }
        return SizedBox.shrink();
      }
    );
  }
  
  // Bottom navigation
  Widget _buildBottomNav(dynamic indexProvide) {
    return Consumer(
      builder: (context, watch, _) {
        final theme = watch(themeProvider);
        
        return BottomAppBar(
          height: 58,
          shadowColor: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildBottomNavItem(1, assets.bookmarkedIcon, "Watchlist", indexProvide.selectedBtmIndx, theme),
              _buildBottomNavItem(2, assets.barChart, "Portfolio", indexProvide.selectedBtmIndx, theme),
              _buildBottomNavItem(3, assets.bag, "Orders", indexProvide.selectedBtmIndx, theme),
              _buildBottomNavItem(4, "assets/profile/userlogo.svg", "Profile", indexProvide.selectedBtmIndx, theme, 
                useHeight: true, height: 18),
            ],
          ),
        );
      }
    );
  }
  
  // Single bottom navigation item
  Widget _buildBottomNavItem(int index, String iconAsset, String label, int selectedIndex, 
    dynamic theme, {bool useHeight = false, double height = 24}) {
    final isSelected = selectedIndex == index;
    final internet = context.read(networkStateProvider);
    final isInternetAvailable = internet.connectionStatus != ConnectivityResult.none;
    
    return Expanded(
      child: RepaintBoundary(
        child: InkWell(
          onTap: isInternetAvailable ? () {
            // Bottom navigation tap handling
            switch (index) {
              case 1:
                _handleWatchlistTap();
                break;
              case 2:
                _handlePortfolioTap();
                break;
              case 3:
                _handleOrderbookTap();
                break;
              case 4:
                _handleProfileTap();
                break;
            }
          } : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              border: isSelected
                ? Border(
                    top: BorderSide(
                      color: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                      width: 2
                    )
                  )
                : null
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                useHeight
                  ? SvgPicture.asset(
                      iconAsset,
                      height: height,
                      color: _getBottomNavColor(theme, isSelected),
                    )
                  : SvgPicture.asset(
                      iconAsset,
                      color: _getBottomNavColor(theme, isSelected),
                    ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: textStyle(
                    _getBottomNavColor(theme, isSelected),
                    12,
                    isSelected ? FontWeight.w600 : FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper for nav item color
  Color _getBottomNavColor(dynamic theme, bool isSelected) {
    if (theme.isDarkMode && isSelected) {
      return colors.colorLightBlue;
    } else if (isSelected) {
      return colors.colorBlue;
    } else {
      return colors.colorGrey;
    }
  }
  
  // Bottom nav handlers
  void _handleWatchlistTap() async {
    final indexProvide = context.read(indexListProvider);
    final portfolio = context.read(portfolioProvider);
    final marketWatchList = context.read(marketWatchProvider);
    final orderProviderRef = context.read(orderProvider);
    
    indexProvide.bottomMenu(1, context);
    portfolio.cancelTimer();

    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await marketWatchList.requestMWScrip(context: context, isSubscribe: true);
  }
  
  void _handlePortfolioTap() async {
    final indexProvide = context.read(indexListProvider);
    final portfolio = context.read(portfolioProvider);
    final marketWatchList = context.read(marketWatchProvider);
    final orderProviderRef = context.read(orderProvider);
    
    indexProvide.bottomMenu(2, context);
    
    await portfolio.fetchMFHoldings(context);
    await marketWatchList.requestMWScrip(context: context, isSubscribe: false);
    await orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: true);
    await portfolio.requestWSPosition(context: context, isSubscribe: true);
  }
  
  void _handleOrderbookTap() async {
    final indexProvide = context.read(indexListProvider);
    final portfolio = context.read(portfolioProvider);
    final marketWatchList = context.read(marketWatchProvider);
    final orderProviderRef = context.read(orderProvider);
    
    indexProvide.bottomMenu(3, context);
    portfolio.cancelTimer();
    
    await orderProviderRef.fetchSipOrderHistory(context);
    await marketWatchList.fetchPendingAlert(context);
    await marketWatchList.requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    orderProviderRef.requestWSOrderBook(context: context, isSubscribe: true);
  }
  
  void _handleProfileTap() async {
    final indexProvide = context.read(indexListProvider);
    final portfolio = context.read(portfolioProvider);
    final reportsprovider = context.read(ledgerProvider);
    final fundProviderRef = context.read(fundProvider);
    final userProfile = context.read(userProfileProvider);
    final marketWatchList = context.read(marketWatchProvider);
    final orderProviderRef = context.read(orderProvider);
    
    indexProvide.bottomMenu(4, context);
    portfolio.cancelTimer();

    // Load minimal required profile data
    await fundProviderRef.fetchFunds(context);
    await userProfile.fetchprofilemenu();
    
    // Unsubscribe from other real-time data
    marketWatchList.requestMWScrip(context: context, isSubscribe: false);
    portfolio.requestWSHoldings(context: context, isSubscribe: false);
    orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    portfolio.requestWSPosition(context: context, isSubscribe: false);
  }

  // The screen will change depending on the condition when you click on the bottom menu items.
  Widget _onItemTapped(int index, ThemesProvider theme) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const WatchListScreen();
      case 2:
        return const PortfolioScreen();
      case 3:
        return const OrderBookScreen();
      case 4:
        return const UserAccountScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // If an application asks for user confirmation before you can exit it, do so.
  Future<bool> showExitPopup() async {
    if (context.read(userProfileProvider).showchartof) {
      setState(() {
        context.read(userProfileProvider).setChartdialog(false);
        context.read(chartUpdateProvider).changeOrientation('portrait');

        final mktwth = context.read(marketWatchProvider);
        mktwth.chngDephBtn("Overview");
        mktwth.singlePageloader(true);

        mktwth.calldepthApis(context, mktwth.getQuotes, "");

        mktwth.singlePageloader(false);
      });
      context.read(marketWatchProvider).setChartScript('ABC', '0123', 'ABCD');
      return false; // Prevent back navigation when chart is visible
    } else {
      return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    backgroundColor: context.read(themeProvider).isDarkMode
                        ? const Color.fromARGB(255, 18, 18, 18)
                        : colors.colorWhite,
                    titleTextStyle: textStyles.appBarTitleTxt.copyWith(
                        color: context.read(themeProvider).isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack),
                    contentTextStyle: textStyles.menuTxt,
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14))),
                    scrollable: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: const Text("Exit App"),
                    content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text("Do you want to Exit the App?")])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text("No",
                              style: textStyles.textBtn.copyWith(
                                  color: context.read(themeProvider).isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue))),
                      ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  context.read(themeProvider).isDarkMode
                                      ? colors.colorbluegrey
                                      : colors.colorBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              )),
                          child: Text("Yes",
                              style: textStyle(
                                  !context.read(themeProvider).isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500)))
                    ]);
              }) ??
          false;
    }
  }

  // Show exit all positions dialog
  void _showExitAllDialog(BuildContext context, dynamic portfolio) {
    final theme = context.read(themeProvider);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode ? const Color.fromARGB(255, 18, 18, 18) : colors.colorWhite,
          titleTextStyle: textStyles.appBarTitleTxt.copyWith(
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
          ),
          contentTextStyle: textStyles.menuTxt.copyWith(
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
          ),
          titlePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))
          ),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "No",
                style: textStyles.textBtn.copyWith(
                  color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue
                )
              )
            ),
            ElevatedButton(
              onPressed: () async {
                await portfolio.exitPosition(context, true);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: theme.isDarkMode ? colors.colorbluegrey : colors.colorBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                )
              ),
              child: Text(
                "Yes",
                style: textStyle(
                  !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500
                )
              ),
            ),
          ],
        );
      },
    );
  }
}

// Watchlist actions component
class _WatchlistActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final marketWatchList = watch(marketWatchProvider);
      
      return Row(
        children: [
          if (marketWatchList.isPreDefWLs != "Yes" && marketWatchList.scrips.length > 1)
            InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                  useSafeArea: true,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                  ),
                  context: context,
                  builder: (context) {
                    return const ScripFilterBottomSheet();
                  }
                );
              },
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 10),
                child: SvgPicture.asset(
                  assets.filterLines,
                  width: 19,
                  color: colors.colorGrey
                )
              ),
            ),
          InkWell(
            onTap: () {
              context.read(marketWatchProvider).requestMWScrip(
                context: context,
                isSubscribe: false
              );
              Navigator.pushNamed(
                context,
                Routes.searchScrip,
                arguments: marketWatchList.wlName
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: SvgPicture.asset(
                assets.searchIcon,
                width: 19,
                color: colors.colorGrey
              )
            ),
          ),
        ],
      );
    });
  }
}

// Portfolio actions stub
class _PortfolioActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final portfolio = watch(portfolioProvider);
      final selectedTab = portfolio.selectedTab;
      
      if (selectedTab == 0 && portfolio.allPostionList.isNotEmpty) {
        return _PositionGroupActions();
      } else if (selectedTab == 2) {
        return _FundsWebActions();
      }
      
      return SizedBox.shrink();
    });
  }
}

// Position group actions
class _PositionGroupActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final portfolio = watch(portfolioProvider);
      final theme = watch(themeProvider);
      
      return Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Row(
          children: [
            Container(
              height: 27,
              padding: const EdgeInsets.only(right: 10),
              child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    useSafeArea: true,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                    ),
                    context: context,
                    builder: (context) {
                      return const PositionGroupBottomSheet();
                    }
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32))
                  )
                ),
                child: Text(
                  "Group by",
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w600
                  )
                )
              ),
            ),
            if (portfolio.exitAll && 
                portfolio.posSelection == "All position" && 
                portfolio.openPosition!.length > 1)
              SizedBox(
                height: 27,
                child: OutlinedButton(
                  onPressed: () => _showExitAllDialog(context, portfolio),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32))
                    )
                  ),
                  child: Text(
                    "Exit All",
                    style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w600
                    )
                  )
                ),
              ),
          ]
        ),
      );
    });
  }
  
  void _showExitAllDialog(BuildContext context, dynamic portfolio) {
    final theme = context.read(themeProvider);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.isDarkMode ? const Color.fromARGB(255, 18, 18, 18) : colors.colorWhite,
          titleTextStyle: textStyles.appBarTitleTxt.copyWith(
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
          ),
          contentTextStyle: textStyles.menuTxt.copyWith(
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
          ),
          titlePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))
          ),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "No",
                style: textStyles.textBtn.copyWith(
                  color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue
                )
              )
            ),
            ElevatedButton(
              onPressed: () async {
                await portfolio.exitPosition(context, true);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: theme.isDarkMode ? colors.colorbluegrey : colors.colorBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                )
              ),
              child: Text(
                "Yes",
                style: textStyle(
                  !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500
                )
              ),
            ),
          ],
        );
      },
    );
  }
}

// Funds web actions
class _FundsWebActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, top: 16),
      child: InkWell(
        onTap: () async {
          final funds = context.read(fundProvider);
          final pref = Preferences();
          
          await funds.fetchHstoken(context);
          
          Future.delayed(const Duration(microseconds: 10), () {
            launch('https://fund.mynt.in/fund/?sAccountId=${pref.clientId}&sToken=${funds.fundHstoken!.hstk}&src=app');
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
class _OrderbookActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final orderProviderWatch = watch(orderProvider);
      final theme = watch(themeProvider);
      
      if (orderProviderWatch.selectedTab == 4) {
        return Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              height: 30,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const CreateBasket();
                    }
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32))
                  )
                ),
                child: Text(
                  "Create Basket",
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w600
                  )
                )
              )
            )
          ]
        );
      }
      
      return SizedBox.shrink();
    });
  }
}

// User profile tile
class _UserProfileTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final theme = watch(themeProvider);
      final userProfile = watch(userProfileProvider);
      
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
            builder: (_) => const LoggedUserBottomSheet(initRoute: 'switchAcc')
          );
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
              userProfile.userDetailModel!.uname.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle(
                Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
                16,
                FontWeight.w600
              )
            ),
            Icon(
              Icons.expand_more,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              size: 28,
            )
          ],
        ),
        subtitle: Text(
          "Client ID: ${userProfile.userDetailModel!.uid}",
          style: textStyle(
            const Color(0xff666666),
            12,
            FontWeight.w500
          )
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                splashRadius: 26,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.qrscanner);
                },
                icon: SvgPicture.asset(
                  "assets/profile/qr_code.svg",
                  width: 28,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
                ),
              ),
            ]
          )
        )
      );
    });
  }
}
