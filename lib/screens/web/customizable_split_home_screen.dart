import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/screens/web/market_watch/tv_chart/webview_chart.dart';
import 'package:mynt_plus/screens/web/ordersbook/order_book_screen_web.dart';
import 'package:mynt_plus/screens/web/funds/secure_fund_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../locator/constant.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/network_state_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/version_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/webview_chart_provider.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/ledger_provider.dart';
import '../../../provider/stocks_provider.dart';
import '../../../provider/web_subscription_manager.dart';
import '../Mobile/desk_reports/ca_action/ca_action_buyback.dart';
import '../../../res/res.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/internet_widget.dart';
import '../../../sharedWidget/splash_loader.dart';
import 'profile/Reports/reports_screen_web.dart';
import 'profile/profile_main_screen_web.dart';
import 'profile/settings_web.dart';
import 'splitter_widget.dart';
// import '../Mobile/market_watch/tv_chart/webview_chart.dart';
import 'market_watch/watchlist_screen_web.dart';
import 'holdings/holding_screen_web.dart';
import 'position/position_screen_web.dart';
import 'dashboard_screen_web.dart';
import 'trade_action_screen_web.dart';
// import '../Mobile/order_book/order_book_screen.dart';
import 'market_watch/options/option_chain_ss_web.dart';
import '../Mobile/desk_reports/pledge_unpledge_screen.dart';
// Removed CA Event and CP Action from panel screens
import '../Mobile/mutual_fund/mf_main_screen.dart';
import 'ipo/ipo_main_screen_web.dart';
import '../Mobile/bonds/bonds_main_screen.dart';
import '../../../utils/custom_navigator.dart';
import '../../../routes/route_names.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import 'market_watch/chart_with_depth_web.dart';
// import 'market_watch/scrip_tabs_manager.dart';
import 'window_based_home_screen.dart';

class CustomizableSplitHomeScreen extends ConsumerStatefulWidget {
  const CustomizableSplitHomeScreen({super.key});

  @override
  ConsumerState<CustomizableSplitHomeScreen> createState() =>
      _CustomizableSplitHomeScreenState();
}

class _CustomizableSplitHomeScreenState
    extends ConsumerState<CustomizableSplitHomeScreen>
    with WidgetsBindingObserver {
  late WebSocketProvider socketProvider;

  // Panel management
  final List<PanelConfig> _panels = [];
  // Arguments storage for panel-specific screens that require constructor params
  DepthInputArgs? _optionChainArgs;
  DepthInputArgs? _currentDepthArgs;
  final int _panelCount = 2; // Fixed to 2 panels
  bool _isInitialLoad = true; // Track if this is the initial load

  // Track loading states for each screen type
  final Map<ScreenType, bool> _screenLoadingStates = {};

  // Store initial tab index for trade action screen
  int? _tradeActionTabIndex;

  // Cooldown for portfolio data fetching to prevent excessive API calls
  DateTime? _lastPortfolioFetch;
  static const _portfolioFetchCooldown = Duration(seconds: 30);

  // Track ongoing API requests to prevent duplicate calls when user rapidly clicks the same screen
  // Key: screen identifier (e.g., 'holdings', 'positions')
  // This prevents duplicate API calls if user clicks the same screen multiple times rapidly
  // But allows fresh data fetch every time user switches between different screens
  final Set<String> _ongoingRequests = {};

  // Helper to check if a request is already in progress
  bool _isRequestInProgress(String requestKey) {
    return _ongoingRequests.contains(requestKey);
  }

  // Helper to mark request as started
  void _markRequestStarted(String requestKey) {
    _ongoingRequests.add(requestKey);
  }

  // Helper to mark request as completed
  void _markRequestCompleted(String requestKey) {
    _ongoingRequests.remove(requestKey);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize with default panels
    _initializeDefaultPanels();

    // Set up callback for showing scrip depth info in panel
    ref
        .read(marketWatchProvider)
        .setOnShowScripDepthInfoInPanel(showScripDepthInfoInPanel);

    // Load saved layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedLayout();
      _addDefaultScreens();
      // Mark initial load as complete after setup and initialize default screens
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _isInitialLoad = false;
          // Initialize the default screens after a delay
          _initializeDefaultScreenData();
        }
      });

      // Initialize WebNavigationHelper for web navigation
      WebNavigationHelper.initialize(
        navigatorKey: GlobalKey<NavigatorState>(),
        navigateToScreen: (routeName, {arguments}) {
          debugPrint("WebNavigationHelper.navigateToScreen called with: $routeName");
          if (routeName == "orderBook") {
            showOrderBookInPanel();
          } else if (routeName == "optionChain") {
            if (arguments is DepthInputArgs) {
              showOptionChainInPanel(arguments);
            }
          } else if (routeName == "pledgeAndUnpledge") {
            _handlePledgeUnpledgeTap();
          } else if (routeName == "corporateActions") {
            _handleCorporateActionsTap();
          } else if (routeName == "reports") {
            _handleReportsTap();
          } else if (routeName == "settings") {
            _handleSettingsTap();
          } else if (routeName == Routes.tradeActionScreen || routeName == "tradeActionScreen") {
            debugPrint("Trade action screen navigation triggered with arguments: $arguments");
            final tabIndex = arguments is int ? arguments : null;
            showTradeActionInPanel(tabIndex: tabIndex);
            // caEvent and cpAction removed from panel navigation
          } else if (routeName == Routes.holdingscreen || routeName == "HoldingScreen") {
            _handleHoldingsTap();
          } else if (routeName == Routes.positionscreen || routeName == "PositionScreen") {
            _handlePositionsTap();
          } else if (routeName == Routes.orderBook || routeName == "orderBook") {
            showOrderBookInPanel();
          } else if (routeName == Routes.fundscreen || routeName == "fundscreen") {
            _handleFundsTap();
          } else if (routeName == Routes.ipo || routeName == "Ipo" || routeName == "ipo") {
            _handleIPOTap();
          } else {
            debugPrint("Unknown route: $routeName");
          }
        },
        replaceScreen: (routeName, {arguments}) {
          debugPrint("WebNavigationHelper.replaceScreen called with: $routeName");
          if (routeName == "orderBook") {
            showOrderBookInPanel();
          } else if (routeName == "optionChain") {
            if (arguments is DepthInputArgs) {
              showOptionChainInPanel(arguments);
            }
          } else if (routeName == "pledgeAndUnpledge") {
            _handlePledgeUnpledgeTap();
          } else if (routeName == "corporateActions") {
            _handleCorporateActionsTap();
          } else if (routeName == "reports") {
            _handleReportsTap();
          } else if (routeName == "settings") {
            _handleSettingsTap();
          } else if (routeName == Routes.tradeActionScreen || routeName == "tradeActionScreen") {
            debugPrint("Trade action screen replacement triggered with arguments: $arguments");
            final tabIndex = arguments is int ? arguments : null;
            showTradeActionInPanel(tabIndex: tabIndex);
            // caEvent and cpAction removed from panel navigation
          } else if (routeName == Routes.holdingscreen || routeName == "HoldingScreen") {
            _handleHoldingsTap();
          } else if (routeName == Routes.positionscreen || routeName == "PositionScreen") {
            _handlePositionsTap();
          } else if (routeName == Routes.orderBook || routeName == "orderBook") {
            showOrderBookInPanel();
          } else if (routeName == Routes.fundscreen || routeName == "fundscreen") {
            _handleFundsTap();
          } else if (routeName == Routes.ipo || routeName == "Ipo" || routeName == "ipo") {
            _handleIPOTap();
          } else {
            debugPrint("Unknown route: $routeName");
          }
        },
        goBack: () {
          // Handle back navigation if needed
        },
      );
    });

    ref.read(networkStateProvider).networkStream();
    ref.read(marketWatchProvider).fToast.init(context);
    ref.read(versionProvider).checkVersion(context);

    // Initialize websocket connection early to ensure real-time data is available
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted &&
          ref.read(networkStateProvider).connectionStatus !=
              ConnectivityResult.none) {
        _handleWebSocketConnections();
      }
    });
    
    // Update subscription manager context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(webSubscriptionManagerProvider).updateContext(context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketProvider = ref.read(websocketProvider);
    
    // Update subscription manager context whenever dependencies change
    ref.read(webSubscriptionManagerProvider).updateContext(context);
  }

  @override
  void dispose() {
    _subscriptionUpdateDebounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (ConstantName.timer != null) {
      ConstantName.timer!.cancel();
      ConstantName.timer = null;
    }
    socketProvider.closeSocket(false);
    ConstantName.chartwebViewController?.dispose();
    super.dispose();
  }

  void _initializeDefaultPanels() {
    _createPanelsForCount(_panelCount);
  }

  void _createPanelsForCount(int count) {
    // Store existing screens before clearing
    List<ScreenType?> existingScreens = [];
    for (int i = 0; i < _panels.length; i++) {
      existingScreens.add(_panels[i].screenType);
    }

    _panels.clear();
    for (int i = 0; i < count; i++) {
      // Preserve existing screen if available, otherwise null
      ScreenType? existingScreen =
          i < existingScreens.length ? existingScreens[i] : null;

      _panels.add(
        PanelConfig(
          id: 'panel_${i + 1}',
          screenType: existingScreen, // Preserve existing screen or null
          screens: existingScreen != null ? [existingScreen] : [],
          activeScreenIndex: 0,
          width: 1.0, // Equal width for all panels
          height: 1.0, // Equal height for all panels
          isVisible: true,
          minWidth: 150.0,
          minHeight: 150.0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          currentWidth: 0.0, // Will be set when layout is built
          currentHeight: 0.0, // Will be set when layout is built
          enableHorizontalResize: true,
          enableVerticalResize: true,
        ),
      );
    }
  }

  Future<void> _loadSavedLayout() async {
    // Always initialize with default panels and show dashboard screen
    // This ensures the app always starts with dashboard screen, not the saved state
    _initializeDefaultPanels();
  }

  Future<void> _saveLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutData = {
        'panelCount': _panelCount,
        'panels': _panels.map((p) => p.toJson()).toList(),
      };
      await prefs.setString('custom_split_layout', jsonEncode(layoutData));
    } catch (e) {
      print('Error saving split layout: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Helper function to check if portfolio screens are active
    bool hasPortfolioScreen() {
      for (var panel in _panels) {
        if (panel.screenType == ScreenType.positions ||
            panel.screenType == ScreenType.holdings ||
            panel.screenType == ScreenType.orderBook ||
            panel.screenType == ScreenType.funds) {
          return true;
        }
      }
      return false;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        // Update subscription manager context on resume
        ref.read(webSubscriptionManagerProvider).updateContext(context);

        // Only fetch portfolio data if cooldown period has passed
        final now = DateTime.now();
        final shouldFetchPortfolio = hasPortfolioScreen() &&
            (_lastPortfolioFetch == null ||
                now.difference(_lastPortfolioFetch!) > _portfolioFetchCooldown);

        Future.microtask(() async {
          try {
            await ref.read(indexListProvider).checkSession(context);
            if (mounted &&
                ref.read(indexListProvider).checkSess?.stat == "Ok" &&
                shouldFetchPortfolio) {
              // Only fetch data for ACTIVE screens (smart fetching)
              debugPrint('Fetching data for active portfolio screens after cooldown');
              _lastPortfolioFetch = now;

              final futures = <Future>[];

              // Check each panel and only fetch data for active screens
              for (var panel in _panels) {
                if (panel.screenType == ScreenType.positions) {
                  futures.add(ref.read(portfolioProvider).fetchPositionBook(context, false));
                } else if (panel.screenType == ScreenType.holdings) {
                  futures.add(ref.read(portfolioProvider).fetchHoldings(context, ""));
                } else if (panel.screenType == ScreenType.orderBook) {
                  futures.add(ref.read(orderProvider).fetchOrderBook(context, false));
                  // Note: Trade Book and SIP are lazy loaded, only fetch if already loaded
                  if (ref.read(orderProvider).tradeBook != null &&
                      ref.read(orderProvider).tradeBook!.isNotEmpty) {
                    futures.add(ref.read(orderProvider).fetchTradeBook(context));
                  }
                }
              }

              if (futures.isNotEmpty) {
                debugPrint('Fetching ${futures.length} API(s) for ${_panels.where((p) => p.screenType == ScreenType.positions || p.screenType == ScreenType.holdings || p.screenType == ScreenType.orderBook).length} active portfolio screen(s)');
                await Future.wait(futures);
              } else {
                debugPrint('No portfolio screens active, skipping data fetch');
              }

              if (mounted) {
                setState(() {});
              }
            } else if (!shouldFetchPortfolio) {
              debugPrint('Skipping portfolio fetch - cooldown active or no portfolio screens');
            }
            _handleWebSocketConnections();
          } catch (e) {
            debugPrint("Error during app resume: $e");
          }
        });
        _handleChartData();
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {});
            }
          });
        }
        break;
      case AppLifecycleState.inactive:
        if (hasPortfolioScreen()) {
          ref.read(portfolioProvider).cancelTimer();
        }
        final userProfile = ref.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        break;
      case AppLifecycleState.paused:
        if (hasPortfolioScreen()) {
          ref.read(portfolioProvider).cancelTimer();
        }
        break;
      case AppLifecycleState.detached:
        if (hasPortfolioScreen()) {
          ref.read(portfolioProvider).cancelTimer();
        }
        final userProfile = ref.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        break;
      case AppLifecycleState.hidden:
        if (hasPortfolioScreen()) {
          ref.read(portfolioProvider).cancelTimer();
        }
    }
  }

  void _handleWebSocketConnections() {
    if (!mounted) return;

    final websocket = ref.read(websocketProvider);

    if (websocket.connectioncount >= 5) {
      websocket.changeconnectioncount();
    }

    // Establish base WebSocket connection if not connected
    // Note: Subscriptions are now handled by WebSubscriptionManager
    if (!websocket.wsConnected) {
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

    // Note: Removed direct subscription calls (requestMWScrip, requestWSHoldings, etc.)
    // WebSubscriptionManager now handles all screen-specific subscriptions
    // This prevents double subscriptions when screens are active
    if (ref.read(networkStateProvider).connectionStatus !=
        ConnectivityResult.none) {
      // WebSubscriptionManager will handle subscriptions based on active screens
      // Just ensure it's updated with current panel states
      _updateSubscriptionManagerForPanels();
    }
  }

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
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _buildMainScaffold(),
            _buildChartOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScaffold() {
    return Consumer(
      builder: (context, ref, _) {
        final internet = ref.watch(networkStateProvider);
        final websocket = ref.watch(websocketProvider);

        if ((internet.connectionStatus == ConnectivityResult.none ||
                websocket.connectioncount >= 5) &&
            !websocket.reconnectionSuccess &&
            !websocket.wsConnected) {
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

        if (internet.connectionStatus != ConnectivityResult.none &&
            !websocket.wsConnected &&
            websocket.retryscreen) {
          Future.microtask(() {
            if (mounted) {
              _handleWebSocketConnections();
              websocket.changeretryscreen(false);
              _handleReconnectionSuccess();
            }
          });
        }

        final theme = ref.watch(themeProvider);
        return Scaffold(
          appBar: _buildAppBar(theme.isDarkMode),
          body: Stack(
            children: [
              _buildCustomizableBody(theme),
            ],
          ),
        );
      },
    );
  }

  _buildAppBar(bool isDarkMode) {
    return PreferredSize(
      preferredSize:
          const Size.fromHeight(58), // Reduced height for compact design
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            // Clean minimal - white background
            color: isDarkMode ? WebDarkColors.surface : Colors.white,
            // Subtle border at bottom
            border: Border(
              bottom: BorderSide(
                color: isDarkMode
                    ? WebDarkColors.divider.withOpacity(0.3)
                    : WebColors.divider.withOpacity(0.2),
                width: 1,
              ),
            ),
            // Soft shadow for depth
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo section
                RepaintBoundary(
                  child: SvgPicture.asset(
                    assets.appLogoIcon,
                    width: 100,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
                // const SizedBox(width: 20),
                // Top indices section
                // Expanded(
                //   child: Container(
                //     height: 48, // Fixed height to prevent overflow
                //     color: isDarkMode
                //         ? WebDarkColors.surface
                //         : Colors
                //             .white, // White background for indices in light mode
                //     child: const SingleChildScrollView(
                //       scrollDirection: Axis.horizontal,
                //       child: DefaultIndexListWeb(src: true),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 20),
                // Navigation screens
                Row(
                  children: [
                    _buildNavigationScreens(isDarkMode),
                    const SizedBox(width: 12),
                    RepaintBoundary(
                      child: _buildSwapButton(isDarkMode),
                    ),
                    const SizedBox(width: 12),
                    // Profile section
                    RepaintBoundary(
                      child: _buildProfileSection(isDarkMode),
                    ),
                  ],
                ),
                // Swap button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizableBody(ThemesProvider theme) {
    return Consumer(
      builder: (context, ref, _) {
        final internetStatus = ref.watch(networkStateProvider
            .select((internet) => internet.connectionStatus));
        final showChart = ref.watch(userProfileProvider
            .select((userProfile) => userProfile.showchartof));

        if ((internetStatus == ConnectivityResult.wifi ||
                internetStatus == ConnectivityResult.mobile) &&
            !showChart) {
          return _buildSplitView(theme);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSplitView(ThemesProvider theme) {
    // Use window-based system
    return const WindowBasedHomeScreen();
  }
  
  /// Calculate responsive split ratio for watchlist based on screen width
  /// Uses Bootstrap-inspired breakpoints for optimal layout at different screen sizes
  ///
  /// Breakpoints:
  /// - XL (>= 1600px): 20% watchlist width
  /// - LG (>= 1200px): 25% watchlist width (default)
  /// - MD (>= 992px): 28% watchlist width
  /// - SM (>= 768px): 30% watchlist width
  /// - XS (< 768px): 35% watchlist width
  ///
  /// [isLeftPanel] - true if watchlist is in left panel, false if in right panel
  double _getResponsiveWatchlistRatio(BuildContext context, {required bool isLeftPanel}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double watchlistRatio;

    // Calculate watchlist width percentage based on screen size
    if (screenWidth >= 1600) {
      // Extra Large screens (>= 1600px): 20% watchlist
      watchlistRatio = 0.20;
    } else if (screenWidth >= 1200) {
      // Large screens (>= 1200px): 25% watchlist (default)
      watchlistRatio = 0.25;
    } else if (screenWidth >= 992) {
      // Medium screens (>= 992px): 28% watchlist
      watchlistRatio = 0.28;
    } else if (screenWidth >= 768) {
      // Small screens (>= 768px): 30% watchlist
      watchlistRatio = 0.30;
    } else {
      // Extra Small screens (< 768px): 35% watchlist
      watchlistRatio = 0.35;
    }

    // Apply min/max constraints to prevent extreme widths
    const double minWatchlistWidth = 280.0;  // Minimum 280px for readability
    const double maxWatchlistWidth = 450.0;  // Maximum 450px to prevent oversized

    // Calculate actual pixel width
    double actualWidth = screenWidth * watchlistRatio;

    // Clamp to min/max bounds
    actualWidth = actualWidth.clamp(minWatchlistWidth, maxWatchlistWidth);

    // Recalculate ratio based on clamped width
    watchlistRatio = actualWidth / screenWidth;

    // Return appropriate ratio based on panel position
    // If watchlist is on left: return the ratio directly (left panel = ratio, right panel = 1-ratio)
    // If watchlist is on right: return 1-ratio (left panel = 1-ratio, right panel = ratio)
    return isLeftPanel ? watchlistRatio : (1.0 - watchlistRatio);
  }

  Widget _buildGridContent(ThemesProvider theme) {
    return _buildTwoPanels(theme);
  }

  Widget _buildTwoPanels(ThemesProvider theme) {
    // Check if watchlist is in any panel to determine split ratio
    bool hasWatchlistInFirstPanel = _panels.isNotEmpty &&
        (_panels[0].screenType == ScreenType.watchlist ||
            (_panels[0].screens.isNotEmpty &&
                _panels[0].activeScreenIndex >= 0 &&
                _panels[0].activeScreenIndex < _panels[0].screens.length &&
                _panels[0].screens[_panels[0].activeScreenIndex] ==
                    ScreenType.watchlist));

    bool hasWatchlistInSecondPanel = _panels.length > 1 &&
        (_panels[1].screenType == ScreenType.watchlist ||
            (_panels[1].screens.isNotEmpty &&
                _panels[1].activeScreenIndex >= 0 &&
                _panels[1].activeScreenIndex < _panels[1].screens.length &&
                _panels[1].screens[_panels[1].activeScreenIndex] ==
                    ScreenType.watchlist));

    // Determine split ratio based on watchlist position and screen size
    double splitRatio = 0.5; // Default 50/50
    bool enableResize = true; // Default to resizable

    if (hasWatchlistInFirstPanel) {
      // Watchlist is in left panel - calculate responsive width
      splitRatio = _getResponsiveWatchlistRatio(context, isLeftPanel: true);
      enableResize = false; // Disable resize to maintain fixed ratio
    } else if (hasWatchlistInSecondPanel) {
      // Watchlist is in right panel - calculate responsive width
      splitRatio = _getResponsiveWatchlistRatio(context, isLeftPanel: false);
      enableResize = false; // Disable resize to maintain fixed ratio
    }

    return SplitterWidget(
      child1: _buildResizableGridSlot(0, theme),
      child2: _buildResizableGridSlot(1, theme),
      direction: Axis.horizontal,
      initialSplitRatio: splitRatio,
      splitterSize: 0.0,
      splitterColor: null, // Let the splitter use theme colors
      enableResize: enableResize,
      onSplitChanged: () {
        _saveLayout();
      },
    );
  }

  // Build resizable grid slot
  Widget _buildResizableGridSlot(int index, ThemesProvider theme) {
    if (index >= _panels.length) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? colors.colorGrey.withOpacity(0.1)
              : colors.colorGrey.withOpacity(0.05),
          // Removed border to eliminate thick border between layouts
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.grey,
            size: 32,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _buildGridSlot(index, theme),
    );
  }

  // Build grid slot (empty slot that can be filled)
  Widget _buildGridSlot(int index, ThemesProvider theme) {
    if (index >= _panels.length) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? colors.colorGrey.withOpacity(0.1)
              : colors.colorGrey.withOpacity(0.05),
          // Removed border to eliminate thick border between layouts
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.grey,
            size: 32,
          ),
        ),
      );
    }

    final panel = _panels[index];

    return Container(
      // margin: const EdgeInsets.all(0),
      color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      child: DragTarget<Object>(
        onAcceptWithDetails: (details) {
          final draggedData = details.data;
          if (draggedData is ScreenType) {
            setState(() {
              panel.screenType = draggedData;
              if (panel.screens.isEmpty) {
                panel.screens = [draggedData];
                panel.activeScreenIndex = 0;
              } else {
                panel.screens[panel.activeScreenIndex] = draggedData;
              }
            });
            _saveLayout();
          } else if (draggedData is PanelConfig && draggedData.id != panel.id) {
            _swapPanels(draggedData, panel);
            _saveLayout();
          }
        },
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          if (data is ScreenType) {
            return true;
          } else if (data is PanelConfig && data.id != panel.id) {
            return true;
          }
          return false;
        },
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;
          final isPanelSwap =
              candidateData.isNotEmpty && candidateData.first is PanelConfig;
          final isScreenDrop =
              candidateData.isNotEmpty && candidateData.first is ScreenType;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              // color: isHighlighted
              //     ? (isPanelSwap
              //         ? colors.ltpgreen.withOpacity(0.15)
              //         : colors.colorBlue.withOpacity(0.15))
              //     : (theme.isDarkMode
              //         ? colors.colorGrey.withOpacity(0.1)
              //         : colors.colorGrey.withOpacity(0.05)),
              // Add single border based on panel position
              border: Border(
                right: index == 0
                    ? BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider.withOpacity(0.5)
                            : WebColors.divider,
                        width: 1,
                        // width: 1,
                      )
                    : BorderSide.none,
                left: index == 1
                    ? BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider.withOpacity(0.5)
                            : WebColors.divider,
                        width: 1,
                        // width: 1,
                      )
                    : BorderSide.none,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: isPanelSwap
                            ? colors.ltpgreen.withOpacity(0.3)
                            : colors.colorBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                panel.screenType != null
                    ? _buildFilledSlot(panel, theme)
                    : _buildEmptySlot(theme),
                if (isScreenDrop && panel.screenType == null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: (theme.isDarkMode
                                ? WebDarkColors.primary
                                : WebColors.primary)
                            .withOpacity(0.1),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: theme.isDarkMode
                                  ? WebDarkColors.primary
                                  : WebColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drop to add',
                              style: WebTextStyles.caption(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.primary
                                    : WebColors.primary,
                                fontWeight: WebFonts.semiBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build empty slot
  Widget _buildEmptySlot(ThemesProvider theme) {
    return Container();

    //  InkWell(
    //   onTap: () {
    //     _showAddScreenDialog();
    //   },
    //   child: Container(
    //     decoration: BoxDecoration(
    //       color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
    //       // Removed border to eliminate thick border between layouts
    //     ),
    //     child: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(
    //             Icons.add_circle_outline,
    //             color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
    //             size: 32,
    //           ),
    //           const SizedBox(height: 8),
    //           Text(
    //             'Tap to add screen',
    //             style: WebTextStyles.caption(
    //               isDarkTheme: theme.isDarkMode,
    //               color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
    //               fontWeight: WebFonts.regular,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  // Build filled slot with screen content
  Widget _buildFilledSlot(PanelConfig panel, ThemesProvider theme) {
    // Get the active screen or fallback to screenType for backward compatibility
    ScreenType? activeScreen;
    if (panel.screens.isNotEmpty &&
        panel.activeScreenIndex >= 0 &&
        panel.activeScreenIndex < panel.screens.length) {
      activeScreen = panel.screens[panel.activeScreenIndex];
    } else {
      activeScreen = panel.screenType;
    }

    return Stack(
      children: [
        // Screen content (not draggable) - with padding to show below header
        Positioned(
          top: activeScreen == ScreenType.watchlist
              ? 0
              : 40, // No header for watchlist, 40px for others
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: panel.screens.isNotEmpty
                ? IndexedStack(
                    index: panel.activeScreenIndex >= 0 &&
                            panel.activeScreenIndex < panel.screens.length
                        ? panel.activeScreenIndex
                        : 0,
                    children: panel.screens.map((screenType) {
                      return _getScreenForType(screenType);
                    }).toList(),
                  )
                : (activeScreen != null
                    ? _getScreenForType(activeScreen)
                    : const SizedBox.shrink()),
          ),
        ),

        // Header with controls (draggable) - COMMENTED OUT FOR FUTURE USE
        /*
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Draggable<PanelConfig>(
            data: panel,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: () {
            },
            onDragEnd: (details) {
            },
            feedback: Material(
              elevation: 8,
              child: Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.drag_indicator,
                        color: WebDarkColors.iconSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getScreenTitleNullable(panel.screens.isNotEmpty 
                            ? panel.screens[panel.activeScreenIndex] 
                            : panel.screenType),
                        style: WebTextStyles.para(
                          isDarkTheme: true,
                          color: WebDarkColors.textSecondary,
                          fontWeight: WebFonts.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            childWhenDragging: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(color: colors.colorBlue, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.drag_indicator,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  // Drag handle
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_indicator,
                      color: theme.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      size: 16,
                    ),
                  ),
                  // Tabs for multiple screens
                  if (panel.screens.length > 1) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: panel.screens.asMap().entries.map((entry) {
                                int index = entry.key;
                                ScreenType screenType = entry.value;
                                bool isActive = index == panel.activeScreenIndex;
                                
                                return Container(
                                  constraints: const BoxConstraints(minWidth: 80),
                                  child: GestureDetector(
                                  onTap: () {
                                    // Manage websockets when switching between screens
                                    final previousScreenIndex = panel.activeScreenIndex;
                                    final previousScreenType = previousScreenIndex >= 0 && previousScreenIndex < panel.screens.length
                                        ? panel.screens[previousScreenIndex]
                                        : null;
                                    final newScreenType = panel.screens[index];
                                    
                                    setState(() {
                                      panel.activeScreenIndex = index;
                                    });
                                    
                                    // Handle websocket subscriptions for screen switching
                                    _handleScreenSwitch(previousScreenType, newScreenType);
                                    
                                    _saveLayout();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive 
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getIconForScreenType(screenType),
                                          color: WebDarkColors.textPrimary,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getScreenTitle(screenType),
                                          style: WebTextStyles.overline(
                                            isDarkTheme: true,
                                            color: WebDarkColors.textPrimary,
                                            fontWeight: isActive ? WebFonts.bold : WebFonts.regular,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (panel.screens.length > 1 && screenType != ScreenType.watchlist) ...[
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () => _removeScreenFromPanel(panel, index),
                                            child: Icon(
                                              Icons.close,
                                              color: WebDarkColors.textSecondary,
                                              size: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                    ),
                                  );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),
                    
                  ] else ...[
                    // Single screen title
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            _getScreenTitleNullable(activeScreen),
                            style: WebTextStyles.para(
                              isDarkTheme: true,
                              color: WebDarkColors.textPrimary,
                              fontWeight: WebFonts.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  if (activeScreen != ScreenType.watchlist && _hasAvailableScreensToAdd(panel))
                      IconButton(
                        icon: Icon(Icons.add, color: WebDarkColors.textPrimary, size: 16),
                        tooltip: 'Add Screen Tab',
                        onPressed: () {
                          _showAddScreenToPanelDialog(panel);
                        },
                      ),
                        ],
                      ),
                    ),
                  ],
                  // Screen selector (not for watchlist)
                  if (activeScreen != ScreenType.watchlist)
                    PopupMenuButton<ScreenType>(
                      icon: Icon(Icons.swap_horiz, color: WebDarkColors.textPrimary, size: 16),
                      tooltip: 'Replace Screen',
                      onSelected: (ScreenType newType) {
                        setState(() {
                          if (panel.screens.isNotEmpty) {
                            panel.screens[panel.activeScreenIndex] = newType;
                            // Update screenType for consistency with size detection
                            panel.screenType = newType;
                          } else {
                            panel.screenType = newType;
                            panel.screens = [newType];
                          }
                        });
                        _saveLayout();
                        // Call the appropriate handler function for the new screen type
                        _handleScreenTypeChange(newType);
                      },
                    itemBuilder: (context) => ScreenType.values
                        .where((type) => _shouldShowScreenOption(type, panel))
                        .map((type) {
                      return PopupMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _getIconForScreenType(type), 
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(_getScreenTitle(type)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  // Remove button (not for watchlist)
                  if (activeScreen != ScreenType.watchlist)
                    IconButton(
                      icon: Icon(Icons.close, color: WebDarkColors.textPrimary, size: 16),
                      onPressed: () {
                        // Clean up websockets and cache for the current screen
                        if (activeScreen != null) {
                          _cleanupScreenResources(activeScreen);
                        }
                        
                        setState(() {
                          panel.screenType = null;
                          panel.screens.clear();
                          panel.activeScreenIndex = 0;
                        });
                        _saveLayout();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        */

        // Tab header for non-watchlist panels (Layout 1)
        if (activeScreen != ScreenType.watchlist)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                // Window top bar - slight grey to indicate it's a window top bar
                color: theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface, // Subtle grey for window top bar
                // Window borders - all sides to make it look like a distinct window
                border: Border(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider.withOpacity(0.5)
                        : WebColors.divider,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider.withOpacity(0.5)
                        : WebColors.divider,
                    width: 1,
                  ),
                  left: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider.withOpacity(0.5)
                        : WebColors.divider,
                    width: 1,
                  ),
                  right: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider.withOpacity(0.5)
                        : WebColors.divider,
                    width: 1,
                  ),
                ),
                // Shadow to make it look elevated like a window
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.05),
                //     blurRadius: 4,
                //     offset: const Offset(0, 2),
                //     spreadRadius: 0,
                //   ),
                // ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // Tabs for multiple screens
                  if (panel.screens.length > 1) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: IntrinsicWidth(
                          child: Row(
                            children:
                                panel.screens.asMap().entries.map((entry) {
                              int index = entry.key;
                              ScreenType screenType = entry.value;
                              bool isActive = index == panel.activeScreenIndex;

                              return Container(
                                constraints: const BoxConstraints(minWidth: 80),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      panel.activeScreenIndex = index;
                                      panel.screenType = screenType;
                                    });
                                    _saveLayout();
                                    _updateSubscriptionManagerForPanels();
                                    _handleScreenTypeChange(screenType);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getIconForScreenType(screenType),
                                          color: WebDarkColors.textPrimary,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getScreenTitle(screenType),
                                          style: WebTextStyles.para(
                                            isDarkTheme: true,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: isActive
                                                ? WebFonts.bold
                                                : WebFonts.medium,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (panel.screens.length > 1) ...[
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _removeScreenFromPanel(
                                                panel, index),
                                            child: const Icon(
                                              Icons.close,
                                              color:
                                                  WebDarkColors.textSecondary,
                                              size: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Single screen title
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            _getScreenTitleNullable(activeScreen),
                            style: WebTextStyles.title(
                              isDarkTheme: true,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Add screen button (only show if there are screens available to add)
                  // if (activeScreen != ScreenType.watchlist && _hasAvailableScreensToAdd(panel))
                  //   IconButton(
                  //     icon: Icon(Icons.add, color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary, size: 18),
                  //     tooltip: 'Add Screen Tab',
                  //     onPressed: () {
                  //       _showAddScreenToPanelDialog(panel);
                  //     },
                  //   ),
                  // Screen selector
                  // PopupMenuButton<ScreenType>(
                  //   icon: Icon(Icons.swap_horiz, color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary, size: 18),
                  //   tooltip: 'Replace Screen',
                  //   onSelected: (ScreenType newType) {
                  //     setState(() {
                  //       if (panel.screens.isNotEmpty) {
                  //         panel.screens[panel.activeScreenIndex] = newType;
                  //         panel.screenType = newType;
                  //       } else {
                  //         panel.screenType = newType;
                  //         panel.screens = [newType];
                  //       }
                  //     });
                  //     _saveLayout();
                  //     _handleScreenTypeChange(newType);
                  //   },
                  //   itemBuilder: (context) => ScreenType.values
                  //       .where((type) => _shouldShowScreenOption(type, panel))
                  //       .map((type) {
                  //     return PopupMenuItem(
                  //       value: type,
                  //       child: Row(
                  //         children: [
                  //           Icon(
                  //             _getIconForScreenType(type),
                  //             size: 16,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Text(_getScreenTitle(type)),
                  //         ],
                  //       ),
                  //     );
                  //   }).toList(),
                  // ),
                  // Remove button
                  // Material(
                  //   color: Colors.transparent,
                  //   child: InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         panel.screenType = null;
                  //         panel.screens.clear();
                  //         panel.activeScreenIndex = 0;
                  //       });
                  //       if (activeScreen != null) {
                  //         _cleanupScreenResources(activeScreen);
                  //       }
                  //       _saveLayout();
                  //     },
                  //     borderRadius: BorderRadius.circular(18),
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Icon(
                  //         Icons.close,
                  //         color: theme.isDarkMode
                  //             ? WebDarkColors.textPrimary
                  //             : WebColors.textPrimary,
                  //         size: 18,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Build logo section for app bar

  // Build navigation screens for app bar
  Widget _buildNavigationScreens(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavItem('Dashboard', isDarkMode, ScreenType.dashboard,
            () => _handleDashboardTap()),
        const SizedBox(width: 8),
        _buildNavItem('Positions', isDarkMode, ScreenType.positions,
            () => _handlePositionsTap()),
        const SizedBox(width: 8),
        _buildNavItem('Holdings', isDarkMode, ScreenType.holdings,
            () => _handleHoldingsTap()),
        const SizedBox(width: 8),
        _buildNavItem('Orders', isDarkMode, ScreenType.orderBook,
            () => _handleOrderBookTap()),
        const SizedBox(width: 8),
        _buildNavItem(
            'Fund', isDarkMode, ScreenType.funds, () => _handleFundsTap()),
        const SizedBox(width: 8),
        _buildNavItem(
            'IPO', isDarkMode, ScreenType.ipo, () => _handleIPOTap()),
      ],
    );
  }

  // Build individual navigation item
  Widget _buildNavItem(String title, bool isDarkMode, ScreenType screenType,
      VoidCallback onTap) {
    // Check if this screen is currently active in any panel
    bool isActive = false;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      if (panel.screenType == screenType ||
          (panel.screens.isNotEmpty &&
              panel.activeScreenIndex >= 0 &&
              panel.activeScreenIndex < panel.screens.length &&
              panel.screens[panel.activeScreenIndex] == screenType)) {
        isActive = true;
        break;
      }
    }

    return _HoverableNavItem(
      title: title,
      isActive: isActive,
      onTap: onTap,
      isDarkMode: isDarkMode,
    );
  }

  // Build swap button for app bar with glassmorphism
  Widget _buildSwapButton(bool isDarkMode) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: _handleSwapPanels,
        borderRadius: BorderRadius.circular(10),
        splashColor: (isDarkMode ? WebDarkColors.primary : WebColors.primary)
            .withOpacity(0.2),
        highlightColor: (isDarkMode ? WebDarkColors.primary : WebColors.primary)
            .withOpacity(0.1),
        child: Icon(
          Icons.swap_horiz,
          color: isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }

  // Build profile section for app bar
  Widget _buildProfileSection(bool isDarkMode) {
    return Consumer(
      builder: (context, ref, _) {
        final userProfile = ref.watch(userProfileProvider);
        final userDetail = userProfile.userDetailModel;
        final clientDetail = userProfile.clientDetailModel;

        // Get client ID
        String clientId = userDetail?.actid ?? clientDetail?.actid ?? '';

        return _ProfileDropdown(
          isDarkMode: isDarkMode,
          clientId: clientId,
        );
      },
    );
  }

  Widget _getScreenForType(ScreenType type) {
    switch (type) {
      case ScreenType.dashboard:
        return const DashboardScreenWeb();
      case ScreenType.watchlist:
        return const WatchListScreenWeb();
      case ScreenType.holdings:
        return Consumer(
          builder: (context, ref, _) {
            // ✅ Optimize: Only watch specific properties instead of entire provider
            final isLoading = _screenLoadingStates[ScreenType.holdings] ?? false;
            final holdloader = ref.watch(portfolioProvider.select((p) => p.holdloader));
            final holdingsModel = ref.watch(portfolioProvider.select((p) => p.holdingsModel));
            final theme = ref.read(themeProvider); // Use read() since theme doesn't change often
            final hasData = holdingsModel != null && holdingsModel.isNotEmpty;

            // Show loader if local loading state is true, provider loading is true, or no data yet
            if (isLoading || holdloader || !hasData) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    theme.isDarkMode ? WebDarkColors.background : Colors.white,
                child: const CircularLoaderImage(),
              );
            }
            return HoldingScreenWeb(
                listofHolding: holdingsModel ?? []);
          },
        );
      case ScreenType.positions:
        return Consumer(
          builder: (context, ref, _) {
            // ✅ Optimize: Only watch specific properties instead of entire provider
            final isLoading = _screenLoadingStates[ScreenType.positions] ?? false;
            final posloader = ref.watch(portfolioProvider.select((p) => p.posloader));
            final allPostionList = ref.watch(portfolioProvider.select((p) => p.allPostionList));
            final theme = ref.read(themeProvider); // Use read() since theme doesn't change often

            // Show loader only when actively loading, not when no data exists
            if (isLoading || posloader) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    theme.isDarkMode ? WebDarkColors.background : Colors.white,
                child: const CircularLoaderImage(),
              );
            }
            return PositionScreenWeb(listofPosition: allPostionList);
          },
        );
      case ScreenType.orderBook:
        // Show OrderBookScreenWeb directly for instant response
        // It will handle its own loading states internally
        return const OrderBookScreenWeb();
      case ScreenType.funds:
        return const _LazyFundScreen();
      case ScreenType.mutualFund:
        return const MfmainScreen();
      case ScreenType.ipo:
        return const IPOScreen(isIpo: true);
      case ScreenType.bond:
        return const BondsScreen(isBonds: true);
      case ScreenType.scripDepthInfo:
        return Consumer(
          builder: (context, ref, _) {
            final args = _currentDepthArgs;
            if (args == null) {
              final mw = ref.watch(marketWatchProvider);
              final fallback =
                  ChartArgs(exch: 'ABC', tsym: 'ABCD', token: '0123');
              return ChartWithDepthWeb(
                wlValue: DepthInputArgs(
                  exch: mw.getQuotes?.exch ?? fallback.exch,
                  token: mw.getQuotes?.token?.toString() ?? fallback.token,
                  tsym: mw.getQuotes?.tsym ?? fallback.tsym,
                  instname: mw.getQuotes?.instname ?? '',
                  symbol: mw.getQuotes?.symbol ?? '',
                  expDate: mw.getQuotes?.expDate ?? '',
                  option: mw.getQuotes?.option ?? '',
                ),
              );
            }
            return ChartWithDepthWeb(wlValue: args);
          },
        );
      case ScreenType.optionChain:
        if (_optionChainArgs != null) {
          return OptionChainSSWeb(wlValue: _optionChainArgs!);
        }
        return const SizedBox.shrink();
      case ScreenType.pledgeUnpledge:
        return const PledgenUnpledge(ddd: "DDDDD");
      case ScreenType.corporateActions:
        return const CABuyback();
      case ScreenType.reports:
        return const ReportsScreenWeb();
      case ScreenType.settings:
        return const SettingsScreenWeb();
      case ScreenType.tradeAction:
        // Get tab index from stored state or use null for default
        final tabIndex = _tradeActionTabIndex;
        // Use a key based on tabIndex to force recreation when tab changes
        return TradeActionScreenWeb(
          key: ValueKey('tradeAction_$tabIndex'),
          initialTabIndex: tabIndex,
        );
      // caEvent and cpAction removed
    }
  }

  String _getScreenTitle(ScreenType type) {
    switch (type) {
      case ScreenType.dashboard:
        return 'Dashboard';
      case ScreenType.watchlist:
        return 'Watchlist';
      case ScreenType.holdings:
        return 'Holdings';
      case ScreenType.positions:
        return 'Positions';
      case ScreenType.orderBook:
        return 'Order Book';
      case ScreenType.funds:
        return 'Funds';
      case ScreenType.mutualFund:
        return 'Mutual Fund';
      case ScreenType.ipo:
        return 'IPO';
      case ScreenType.bond:
        return 'Bonds';
      case ScreenType.scripDepthInfo:
        return 'Chart View';
      case ScreenType.optionChain:
        return 'Option Chain';
      case ScreenType.pledgeUnpledge:
        return 'Pledge/Unpledge';
      case ScreenType.corporateActions:
        return 'Corporate Actions';
      case ScreenType.reports:
        return 'Reports';
      case ScreenType.settings:
        return 'Settings';
      case ScreenType.tradeAction:
        return 'Trade Action';
      // caEvent and cpAction removed
    }
  }

  IconData _getIconForScreenType(ScreenType type) {
    switch (type) {
      case ScreenType.dashboard:
        return Icons.dashboard;
      case ScreenType.watchlist:
        return Icons.list;
      case ScreenType.holdings:
        return Icons.inventory;
      case ScreenType.positions:
        return Icons.trending_up;
      case ScreenType.orderBook:
        return Icons.receipt;
      case ScreenType.funds:
        return Icons.account_balance;
      case ScreenType.mutualFund:
        return Icons.trending_up;
      case ScreenType.ipo:
        return Icons.public;
      case ScreenType.bond:
        return Icons.account_balance;
      case ScreenType.scripDepthInfo:
        return Icons.analytics;
      case ScreenType.optionChain:
        return Icons.table_chart;
      case ScreenType.pledgeUnpledge:
        return Icons.security;
      case ScreenType.corporateActions:
        return Icons.business;
      case ScreenType.reports:
        return Icons.assessment;
      case ScreenType.settings:
        return Icons.settings;
      case ScreenType.tradeAction:
        return Icons.trending_up;
      // caEvent and cpAction removed
    }
  }

  String _getScreenTitleNullable(ScreenType? type) {
    if (type == null) return 'Empty';
    return _getScreenTitle(type);
  }

  IconData _getIconForScreenTypeNullable(ScreenType? type) {
    if (type == null) return Icons.add;
    return _getIconForScreenType(type);
  }

  void _swapPanels(PanelConfig draggedPanel, PanelConfig targetPanel) {
    setState(() {
      // Find the indices of both panels
      final draggedIndex = _panels.indexWhere((p) => p.id == draggedPanel.id);
      final targetIndex = _panels.indexWhere((p) => p.id == targetPanel.id);

      if (draggedIndex != -1 &&
          targetIndex != -1 &&
          draggedIndex != targetIndex) {
        // Check if watchlist is involved in the swap
        bool draggedHasWatchlist = _panels[draggedIndex].screenType ==
                ScreenType.watchlist ||
            (_panels[draggedIndex].screens.isNotEmpty &&
                _panels[draggedIndex].screens.contains(ScreenType.watchlist));
        bool targetHasWatchlist = _panels[targetIndex].screenType ==
                ScreenType.watchlist ||
            (_panels[targetIndex].screens.isNotEmpty &&
                _panels[targetIndex].screens.contains(ScreenType.watchlist));

        // Swap the screen types
        final tempScreenType = _panels[draggedIndex].screenType;
        _panels[draggedIndex].screenType = _panels[targetIndex].screenType;
        _panels[targetIndex].screenType = tempScreenType;

        // Swap the multiple screens structure
        final tempScreens =
            List<ScreenType>.from(_panels[draggedIndex].screens);
        final tempActiveScreenIndex = _panels[draggedIndex].activeScreenIndex;

        _panels[draggedIndex].screens =
            List<ScreenType>.from(_panels[targetIndex].screens);
        _panels[draggedIndex].activeScreenIndex =
            _panels[targetIndex].activeScreenIndex;

        _panels[targetIndex].screens = tempScreens;
        _panels[targetIndex].activeScreenIndex = tempActiveScreenIndex;

        // Also swap the panel properties to maintain consistency
        final tempWidth = _panels[draggedIndex].width;
        final tempHeight = _panels[draggedIndex].height;
        final tempVisible = _panels[draggedIndex].isVisible;

        _panels[draggedIndex].width = _panels[targetIndex].width;
        _panels[draggedIndex].height = _panels[targetIndex].height;
        _panels[draggedIndex].isVisible = _panels[targetIndex].isVisible;

        _panels[targetIndex].width = tempWidth;
        _panels[targetIndex].height = tempHeight;
        _panels[targetIndex].isVisible = tempVisible;

        // If watchlist was involved in the swap, ensure the non-watchlist panel is active
        if (draggedHasWatchlist || targetHasWatchlist) {
          // Find which panel doesn't have watchlist
          int nonWatchlistPanelIndex = -1;

          for (int i = 0; i < _panels.length; i++) {
            bool hasWatchlist = _panels[i].screenType == ScreenType.watchlist ||
                (_panels[i].screens.isNotEmpty &&
                    _panels[i].screens.contains(ScreenType.watchlist));

            if (!hasWatchlist &&
                (_panels[i].screenType != null ||
                    _panels[i].screens.isNotEmpty)) {
              nonWatchlistPanelIndex = i;
              break;
            }
          }

          // If we found a non-watchlist panel, ensure it's active
          if (nonWatchlistPanelIndex != -1 &&
              _panels[nonWatchlistPanelIndex].screens.isNotEmpty) {
            // Set the active screen to the first non-watchlist screen
            for (int i = 0;
                i < _panels[nonWatchlistPanelIndex].screens.length;
                i++) {
              if (_panels[nonWatchlistPanelIndex].screens[i] !=
                  ScreenType.watchlist) {
                _panels[nonWatchlistPanelIndex].activeScreenIndex = i;
                break;
              }
            }
          }
        }
      }
    });
  }

  // Handle swap button press - swaps the positions of both panels
  void _handleSwapPanels() {
    setState(() {
      // Make sure we have exactly 2 panels
      if (_panels.length == 2) {
        // Swap the screen types between the two panels
        final tempScreenType = _panels[0].screenType;
        _panels[0].screenType = _panels[1].screenType;
        _panels[1].screenType = tempScreenType;

        // Swap the multiple screens structure
        final tempScreens = List<ScreenType>.from(_panels[0].screens);
        final tempActiveScreenIndex = _panels[0].activeScreenIndex;

        _panels[0].screens = List<ScreenType>.from(_panels[1].screens);
        _panels[0].activeScreenIndex = _panels[1].activeScreenIndex;

        _panels[1].screens = tempScreens;
        _panels[1].activeScreenIndex = tempActiveScreenIndex;

        // Also swap the panel properties to maintain consistency
        final tempWidth = _panels[0].width;
        final tempHeight = _panels[0].height;
        final tempVisible = _panels[0].isVisible;

        _panels[0].width = _panels[1].width;
        _panels[0].height = _panels[1].height;
        _panels[0].isVisible = _panels[1].isVisible;

        _panels[1].width = tempWidth;
        _panels[1].height = tempHeight;
        _panels[1].isVisible = tempVisible;
      }
    });

    // Save the layout
    _saveLayout();
  }

  // Show add screen dialog
  void _showAddScreenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final theme = ref.watch(themeProvider);
            return AlertDialog(
              backgroundColor:
                  theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Screen',
                        style: WebTextStyles.head(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: colors.colorGrey,
                      size: 24,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...ScreenType.values
                          .where((screenType) =>
                              screenType != ScreenType.watchlist)
                          .map((screenType) =>
                              _buildScreenOption(screenType, theme))
                          ,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build screen option in dialog
  Widget _buildScreenOption(ScreenType screenType, ThemesProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Find first empty panel or first panel if all are filled
          int targetIndex = _getFirstAvailablePanelIndex();

          setState(() {
            _panels[targetIndex].screenType = screenType;
            _panels[targetIndex].screens = [screenType];
            _panels[targetIndex].activeScreenIndex = 0;
          });
          _saveLayout();
          // Call the appropriate handler function for the new screen type
          _handleScreenTypeChange(screenType);
          Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? colors.colorGrey.withOpacity(0.1)
                : colors.colorGrey.withOpacity(0.05),
            border: Border.all(
              color: theme.isDarkMode
                  ? colors.colorGrey.withOpacity(0.2)
                  : colors.colorGrey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForScreenType(screenType),
                  color: theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getScreenTitle(screenType),
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    1,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.isDarkMode
                    ? WebDarkColors.iconSecondary
                    : WebColors.iconSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get the first available panel index
  int _getFirstAvailablePanelIndex() {
    for (int i = 0; i < _panels.length; i++) {
      if (_panels[i].screenType == null && _panels[i].screens.isEmpty) {
        return i;
      }
    }
    return 0; // Return first panel if all are filled
  }

  // Handle screen type change - calls appropriate handler based on screen type
  void _handleScreenTypeChange(ScreenType screenType) {
    // Update subscription manager with active screen
    _updateSubscriptionManagerForPanels();
    
    // Only call handlers if this is not the initial load
    if (_isInitialLoad) {
      return;
    }

    switch (screenType) {
      case ScreenType.dashboard:
        _handleDashboardTap();
        break;
      case ScreenType.watchlist:
        _handleWatchlistTap();
        break;
      case ScreenType.holdings:
        _handleHoldingsTap();
        break;
      case ScreenType.positions:
        _handlePositionsTap();
        break;
      case ScreenType.orderBook:
        _handleOrderBookTap();
        break;
      case ScreenType.funds:
        _handleFundsTap();
        break;
      case ScreenType.mutualFund:
        _handleMutualFundTap();
        break;
      case ScreenType.ipo:
        _handleIPOTap();
        break;
      case ScreenType.bond:
        _handleBondTap();
        break;
      case ScreenType.scripDepthInfo:
        _handleScripDepthInfoTap();
        break;
      case ScreenType.optionChain:
        // Option chain shows derivatives data; pause other streams similar to scrip depth
        _handleScripDepthInfoTap();
        break;
      case ScreenType.pledgeUnpledge:
        _handlePledgeUnpledgeTap();
        break;
      case ScreenType.corporateActions:
        _handleCorporateActionsTap();
        break;
      case ScreenType.reports:
        _handleReportsTap();
        break;
      case ScreenType.settings:
        _handleSettingsTap();
        break;
      case ScreenType.tradeAction:
        _handleTradeActionTap();
        break;
      // caEvent and cpAction removed
    }
  }

  // Handle scrip depth info tap
  void _handleScripDepthInfoTap() async {
    final portfolio = ref.read(portfolioProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref
        .read(orderProvider)
        .requestWSOrderBook(context: context, isSubscribe: false);
  }

  // Clean up websocket subscriptions and cache for a specific screen
  void _cleanupScreenResources(ScreenType? screenType) {
    if (screenType == null) return;

    // Check if widget is still mounted before cleanup
    if (!mounted) {
      return;
    }

    try {
      switch (screenType) {
        case ScreenType.holdings:
          if (mounted) {
            ref
                .read(portfolioProvider)
                .requestWSHoldings(context: context, isSubscribe: false);
          }
          _clearScreenCache(screenType);
          break;

        case ScreenType.positions:
          if (mounted) {
            ref
                .read(portfolioProvider)
                .requestWSPosition(context: context, isSubscribe: false);
          }
          _clearScreenCache(screenType);
          break;

        case ScreenType.orderBook:
          if (mounted) {
            // Unsubscribe from current active tab when leaving order book screen
            ref
                .read(orderProvider)
                .unsubscribeFromCurrentTab(context);
          }
          _clearScreenCache(screenType);
          break;

        case ScreenType.funds:
          _clearScreenCache(screenType);
          break;

        case ScreenType.scripDepthInfo:
          _clearScreenCache(screenType);
          break;

        case ScreenType.optionChain:
          _clearScreenCache(screenType);
          break;

        default:
          _clearScreenCache(screenType);
          break;
      }
    } catch (e) {}
  }

  // Clear cache for a specific screen type
  void _clearScreenCache(ScreenType? screenType) {
    if (screenType == null) return;

    try {
      final websocket = ref.read(websocketProvider);
      int removedCount = 0;

      // Get tokens/data specific to this screen type and clear them
      switch (screenType) {
        case ScreenType.holdings:
          final holdingsModel = ref.read(portfolioProvider).holdingsModel;
          if (holdingsModel != null) {
            for (var holding in holdingsModel) {
              // Get tokens from ExchTsym list within each holding
              for (var exchTsym in holding.exchTsym ?? []) {
                if (exchTsym.token != null && exchTsym.token!.isNotEmpty) {
                  // Remove the token data from socket cache
                  if (websocket.socketDatas.containsKey(exchTsym.token)) {
                    websocket.socketDatas.remove(exchTsym.token);
                    removedCount++;
                  }
                }
              }
            }
          }
          break;

        case ScreenType.positions:
          final positionsList = ref.read(portfolioProvider).allPostionList;
          for (var position in positionsList) {
            if (position.token != null && position.token!.isNotEmpty) {
              // Remove the token data from socket cache
              if (websocket.socketDatas.containsKey(position.token)) {
                websocket.socketDatas.remove(position.token);
                removedCount++;
              }
            }
          }
          break;

        case ScreenType.orderBook:
          break;

        default:
          break;
      }

      if (removedCount > 0) {
      } else {}
    } catch (e) {}
  }

  // Show ScripDepthInfo in a panel
  void showScripDepthInfoInPanel(dynamic watchListData) {
    // Accept DepthInputArgs and store as current selection
    if (watchListData is DepthInputArgs) {
      _currentDepthArgs = watchListData;
    }
    // Check if scrip details already exist in any panel
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasScripDetails = panel.screenType == ScreenType.scripDepthInfo ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.scripDepthInfo));

      if (hasScripDetails) {
        // Scrip details already exist, switch to that panel instead of creating duplicate
        setState(() {
          _panels[i].activeScreenIndex =
              panel.screens.indexOf(ScreenType.scripDepthInfo);
          if (_panels[i].activeScreenIndex == -1) {
            _panels[i].activeScreenIndex = 0;
          }
        });
        _saveLayout();
        return; // Exit early to prevent duplicate
      }
    }

    // Find the best panel to replace with scrip depth (prefer non-watchlist panels)
    int targetPanelIndex = -1;

    // Find any non-watchlist panel to replace
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));

      // Use first non-watchlist panel
      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }

    // If no suitable panel found, use left panel (index 0)
    if (targetPanelIndex == -1) {
      targetPanelIndex = 0;
    }

    // Replace the screen with ScripDepthInfo (don't add as tab)
    setState(() {
      // Store the previous screen type for cleanup if needed
      ScreenType? previousScreenType = _panels[targetPanelIndex].screenType;

      // Replace the entire screen with scrip depth info
      _panels[targetPanelIndex].screens = [ScreenType.scripDepthInfo];
      _panels[targetPanelIndex].activeScreenIndex = 0;
      _panels[targetPanelIndex].screenType = ScreenType.scripDepthInfo;

      // Clean up resources from the replaced screen
      if (previousScreenType != null &&
          previousScreenType != ScreenType.scripDepthInfo) {
        _cleanupScreenResources(previousScreenType);
      }
    });
    
    // Update subscription manager
    _updateSubscriptionManagerForPanels();

    _saveLayout();

    // Call the handler for the new screen type
    _handleScreenTypeChange(ScreenType.scripDepthInfo);
  }

  // Show OrderBook in a panel
  void showOrderBookInPanel() {
    // Check if order book already exists in any panel
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasOrderBook = panel.screenType == ScreenType.orderBook ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.orderBook));

      if (hasOrderBook) {
        // Order book already exists, switch to that panel instead of creating duplicate
        setState(() {
          _panels[i].activeScreenIndex =
              panel.screens.indexOf(ScreenType.orderBook);
          if (_panels[i].activeScreenIndex == -1) {
            _panels[i].activeScreenIndex = 0;
          }
        });
        _saveLayout();
        return; // Exit early to prevent duplicate
      }
    }

    // Find the panel that doesn't have watchlist (prefer left panel)
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));

      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }

    // If no panel without watchlist found, use the left panel (index 0) - avoid right panel with watchlist
    if (targetPanelIndex == -1) {
      targetPanelIndex =
          0; // Always use left panel to avoid replacing watchlist
    }

    // Set the OrderBook screen in the target panel
    setState(() {
      _panels[targetPanelIndex].screenType = ScreenType.orderBook;
      _panels[targetPanelIndex].screens = [ScreenType.orderBook];
      _panels[targetPanelIndex].activeScreenIndex = 0;
    });
    
    // Update subscription manager
    _updateSubscriptionManagerForPanels();

    _saveLayout();

    // Call the handler for the new screen type
    _handleScreenTypeChange(ScreenType.orderBook);
  }

  // Show Trade Action in a panel
  void showTradeActionInPanel({int? tabIndex}) {
    // Check if trade action already exists in any panel
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasTradeAction = panel.screenType == ScreenType.tradeAction ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.tradeAction));

      if (hasTradeAction) {
        // Trade action already exists, update the tab index and switch to that panel
        setState(() {
          _panels[i].activeScreenIndex =
              panel.screens.indexOf(ScreenType.tradeAction);
          if (_panels[i].activeScreenIndex == -1) {
            _panels[i].activeScreenIndex = 0;
          }
          // Update the tab index even if screen already exists
          _tradeActionTabIndex = tabIndex;
        });
        _saveLayout();
        // Force a rebuild to update the tab
        if (mounted) {
          setState(() {});
        }
        return; // Exit early to prevent duplicate
      }
    }

    // Find the panel that doesn't have watchlist (prefer left panel)
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));

      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }

    // If no panel without watchlist found, use the left panel (index 0) - avoid right panel with watchlist
    if (targetPanelIndex == -1) {
      targetPanelIndex =
          0; // Always use left panel to avoid replacing watchlist
    }

    // Set the Trade Action screen in the target panel
    setState(() {
      _panels[targetPanelIndex].screenType = ScreenType.tradeAction;
      _panels[targetPanelIndex].screens = [ScreenType.tradeAction];
      _panels[targetPanelIndex].activeScreenIndex = 0;
      // Store the tab index for the screen
      _tradeActionTabIndex = tabIndex;
    });
    
    // Update subscription manager
    _updateSubscriptionManagerForPanels();

    _saveLayout();

    // Call the handler for the new screen type
    _handleScreenTypeChange(ScreenType.tradeAction);
  }

  // Show Option Chain in a panel
  void showOptionChainInPanel(DepthInputArgs args) {
    // Check if already exists
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool exists = panel.screenType == ScreenType.optionChain ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.optionChain));
      if (exists) {
        setState(() {
          _optionChainArgs = args;
          _panels[i].activeScreenIndex =
              panel.screens.indexOf(ScreenType.optionChain);
          if (_panels[i].activeScreenIndex == -1) {
            _panels[i].activeScreenIndex = 0;
          }
        });
        _saveLayout();
        return;
      }
    }
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));
      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }
    if (targetPanelIndex == -1) targetPanelIndex = _panels.length > 1 ? 1 : 0;
    setState(() {
      _optionChainArgs = args;
      _panels[targetPanelIndex].screenType = ScreenType.optionChain;
      _panels[targetPanelIndex].screens = [ScreenType.optionChain];
      _panels[targetPanelIndex].activeScreenIndex = 0;
    });
    
    // Update subscription manager
    _updateSubscriptionManagerForPanels();
    
    _saveLayout();
  }

  // caEvent and cpAction handlers removed

  // Initialize default screen data after initial load
  void _initializeDefaultScreenData() {
    if (_panels.length >= 2) {
      // Right panel should only have watchlist - move any other screens to left panel
      if (_panels[1].screenType != null &&
          _panels[1].screenType != ScreenType.watchlist) {
        // Move the screen from right panel to left panel
        _panels[0].screenType = _panels[1].screenType;
        _panels[0].screens = List<ScreenType>.from(_panels[1].screens);
        _panels[0].activeScreenIndex = _panels[1].activeScreenIndex;

        // Clear right panel and set watchlist
        _panels[1].screenType = ScreenType.watchlist;
        _panels[1].screens = [ScreenType.watchlist];
        _panels[1].activeScreenIndex = 0;
      }

      // Initialize the screen on the left panel (which is now the primary content panel)
      if (_panels[0].screenType != null) {
        if (_panels[0].screenType == ScreenType.dashboard) {
          _handleDashboardTap();
        } else if (_panels[0].screenType == ScreenType.watchlist) {
          _handleWatchlistTap();
        } else if (_panels[0].screenType == ScreenType.holdings) {
          _handleHoldingsTap();
        } else if (_panels[0].screenType == ScreenType.positions) {
          _handlePositionsTap();
        } else if (_panels[0].screenType == ScreenType.orderBook) {
          _handleOrderBookTap();
        } else if (_panels[0].screenType == ScreenType.funds) {
          _handleFundsTap();
        }
      }

      // Initialize watchlist on right panel if it exists
      if (_panels[1].screenType == ScreenType.watchlist) {
        _handleWatchlistTap();
      }

      // Update subscription manager with initial screens
      _updateSubscriptionManagerForPanels();

      // Ensure websocket connections are established for real-time data
      if (mounted &&
          ref.read(networkStateProvider).connectionStatus !=
              ConnectivityResult.none) {
        _handleWebSocketConnections();
      }
    }
  }

  // Debounce timer to prevent rapid subscription manager updates
  Timer? _subscriptionUpdateDebounceTimer;
  static const Duration _subscriptionUpdateDebounceDelay = Duration(milliseconds: 200);
  
  // Track last update to prevent duplicate calls
  final Map<int, ScreenType?> _lastSubscriptionUpdate = {};
  
  // Update subscription manager based on current active panels (with debouncing)
  void _updateSubscriptionManagerForPanels() {
    // Cancel any pending debounce timer
    _subscriptionUpdateDebounceTimer?.cancel();
    
    // Debounce the update to prevent rapid calls
    _subscriptionUpdateDebounceTimer = Timer(_subscriptionUpdateDebounceDelay, () {
      _performSubscriptionManagerUpdate();
    });
  }
  
  /// Actually perform the subscription manager update (called after debounce)
  void _performSubscriptionManagerUpdate() {
    final subscriptionManager = ref.read(webSubscriptionManagerProvider);
    
    // Update subscription manager for each panel
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      ScreenType? activeScreen;
      
      if (panel.screens.isNotEmpty &&
          panel.activeScreenIndex >= 0 &&
          panel.activeScreenIndex < panel.screens.length) {
        activeScreen = panel.screens[panel.activeScreenIndex];
      } else {
        activeScreen = panel.screenType;
      }
      
      // Only update if the screen actually changed
      final lastScreen = _lastSubscriptionUpdate[i];
      if (lastScreen != activeScreen) {
        subscriptionManager.updateActiveScreen(i, activeScreen);
        _lastSubscriptionUpdate[i] = activeScreen;
      }
    }
  }

  // Individual screen type handlers (based on home_screen.dart)
  void _handleDashboardTap() async {
    // Replace screen immediately for instant UI response
    _replaceScreenInPanel(ScreenType.dashboard);

    // Move all async operations to background to prevent blocking UI
    Future.microtask(() async {
      if (!mounted) return;

      final indexProvider = ref.read(indexListProvider);
      final stocksProvider = ref.read(stocksProvide);
      final portfolio = ref.read(portfolioProvider);
      
      portfolio.cancelTimer();

      // Ensure top indices are fetched before WebSubscriptionManager subscribes
      // Only fetch if not already available to avoid duplicate API calls
      if (indexProvider.topIndicesForDashboard == null) {
        await indexProvider.getTopIndicesForDashboard(context);
      }
      
      // Fetch trade action data only if not already available
      // This prevents duplicate TopList API calls when clicking dashboard multiple times
      if (stocksProvider.topGainers.isEmpty && stocksProvider.topLosers.isEmpty) {
        await stocksProvider.fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
      }
      if (stocksProvider.byValue.isEmpty && stocksProvider.byVolume.isEmpty) {
        await stocksProvider.fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
      }
      
      // Update subscription manager AFTER data is fetched
      // This ensures tokens are available for subscription
      if (mounted) {
        _updateSubscriptionManagerForPanels();
      }
    });
  }

  void _handleWatchlistTap() async {
    // Update subscription manager
    _updateSubscriptionManagerForPanels();
    
   

    final portfolio = ref.read(portfolioProvider);
    portfolio.cancelTimer();
  }

  void _handleMutualFundTap() {
    final portfolio = ref.read(portfolioProvider);
    portfolio.cancelTimer();
  }

  // Check if there are any screens available to add to a panel
  bool _hasAvailableScreensToAdd(PanelConfig panel) {
    return ScreenType.values
        .where((screenType) => _shouldShowScreenOption(screenType, panel))
        .isNotEmpty;
  }

  // Replace screen in panel (don't add as tab)
  void _replaceScreenInPanel(ScreenType screenType) {
    // Find the panel that doesn't have watchlist (prefer left panel for non-watchlist screens)
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));

      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }

    // If no panel without watchlist found, use the left panel (index 0)
    if (targetPanelIndex == -1) {
      targetPanelIndex = 0;
    }

    setState(() {
      _panels[targetPanelIndex].screenType = screenType;
      _panels[targetPanelIndex].screens = [screenType];
      _panels[targetPanelIndex].activeScreenIndex = 0;
    });
    
    // Update subscription manager
    _updateSubscriptionManagerForPanels();

    // Save layout in background (non-blocking)
    Future.microtask(() => _saveLayout());
  }

  // Add screen as a panel tab (only for profile screens)
  void _addScreenAsPanelTab(ScreenType screenType) {
    // Find the first available panel (preferably left panel)
    for (int i = 0; i < _panels.length; i++) {
      // Check if screen already exists in this panel
      bool alreadyExists = _panels[i].screens.contains(screenType);

      if (alreadyExists) {
        // Switch to existing tab
        setState(() {
          _panels[i].activeScreenIndex = _panels[i].screens.indexOf(screenType);
          _panels[i].screenType =
              screenType; // Update for backward compatibility
        });
        _saveLayout();
        return;
      }
    }

    // Screen doesn't exist, add to left panel (index 0)
    if (_panels.isNotEmpty) {
      setState(() {
        _panels[0].screens.add(screenType);
        _panels[0].activeScreenIndex = _panels[0].screens.length - 1;
        _panels[0].screenType = screenType; // Update for backward compatibility
      });
      _saveLayout();
      // Call the appropriate handler function for the new screen type
      _handleScreenTypeChange(screenType);
    }
  }

  void _handleOrderBookTap() async {
    // Replace screen immediately - no loading state needed
    // OrderBookScreenWeb will handle its own loading gracefully
    _replaceScreenInPanel(ScreenType.orderBook);

    // Move all async operations to background to prevent blocking UI
    Future.microtask(() async {
      if (!mounted) return;

      final portfolio = ref.read(portfolioProvider);
      portfolio.cancelTimer();

      final orderProviderRef = ref.read(orderProvider);

      // Check if request is already in progress (prevents duplicate calls on rapid clicks)
      if (_isRequestInProgress('order_book')) {
        debugPrint('⏭️ Skipping Order Book fetch - request already in progress');
        return;
      }

      // Mark request as started
      _markRequestStarted('order_book');

      try {
        // Only fetch Order Book (Open Orders + Executed Orders)
        // Always fetch fresh data when switching to Order Book
        await orderProviderRef.fetchOrderBook(context, false);

        // Trade Book and SIP will be lazy loaded when user switches to those tabs
        // This is handled in OrderProvider.changeTabIndex()

        // Order book handles its own tab-specific subscriptions
        // Subscribe to Open Orders tab (tab 0) by default when order book opens
        if (mounted) {
          // Reset to Open Orders tab (index 0) and subscribe
          orderProviderRef.changeTabIndex(0, context);
          debugPrint("📥 [Order Book] Initial subscription to Open Orders tab (Tab 0)");
        }

        // Update subscription manager (order book is now SubscriptionType.none, so it won't subscribe)
        if (mounted) {
          _updateSubscriptionManagerForPanels();
        }
      } finally {
        // Always mark request as completed
        _markRequestCompleted('order_book');
      }
    });
  }

  void _handleIPOTap() async {
    // Set loading state immediately
    setState(() {
      _screenLoadingStates[ScreenType.ipo] = true;
    });

    // Replace screen immediately for instant UI response - this triggers setState synchronously
    _replaceScreenInPanel(ScreenType.ipo);

    // Allow UI to update first, then do background work
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        if (!mounted) return;

        final portfolio = ref.read(portfolioProvider);
        final ipoProvider = ref.read(ipoProvide);
        final authProvi = ref.read(authProvider);

        portfolio.cancelTimer();

        // Unsubscribe from other real-time data (non-blocking)
        portfolio.requestWSHoldings(context: context, isSubscribe: false);
        portfolio.requestWSPosition(context: context, isSubscribe: false);
        ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);

        // Fetch IPO data in the background (non-blocking)
        if (mounted) {
          authProvi.setIposAPicalls(context);
          ipoProvider.getipoorderbookmodel(context, true);

          // Clear loading state after data is fetched
          if (mounted) {
            setState(() {
              _screenLoadingStates[ScreenType.ipo] = false;
            });
          }
        }
      });
    });
  }

  void _handleBondTap() async {
    final portfolio = ref.read(portfolioProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref
        .read(orderProvider)
        .requestWSOrderBook(context: context, isSubscribe: false);

    // Fetch Bond data in the background
    Future.microtask(() {
      if (mounted) {
        ref.read(bondsProvider).fetchAllBonds();
      }
    });
  }

  // New handler methods for separate portfolio screens
  void _handleHoldingsTap() async {
    // Set loading state immediately
    setState(() {
      _screenLoadingStates[ScreenType.holdings] = true;
    });

    // Replace screen immediately for instant UI response
    _replaceScreenInPanel(ScreenType.holdings);

    // Move all async operations to background to prevent blocking UI
    Future.microtask(() async {
      if (!mounted) return;

      final portfolio = ref.read(portfolioProvider);
      portfolio.cancelTimer();

      // Check if request is already in progress (prevents duplicate calls on rapid clicks)
      if (_isRequestInProgress('holdings')) {
        debugPrint('⏭️ Skipping Holdings fetch - request already in progress');
        if (mounted) {
          setState(() {
            _screenLoadingStates[ScreenType.holdings] = false;
          });
        }
        return;
      }

      // Mark request as started
      _markRequestStarted('holdings');

      try {
        // Fetch holdings data BEFORE WebSubscriptionManager subscribes
        // This ensures tokens are available for subscription
        // Always fetch fresh data when switching to Holdings
        await portfolio.fetchHoldings(context, "");

        // Update subscription manager AFTER data is fetched
        // This ensures tokens are available for subscription
        if (mounted) {
          _updateSubscriptionManagerForPanels();

          // Clear loading state after data is fetched
          setState(() {
            _screenLoadingStates[ScreenType.holdings] = false;
          });
        }
      } finally {
        // Always mark request as completed
        _markRequestCompleted('holdings');
      }
    });
  }

  void _handlePositionsTap() async {
    // Set loading state immediately
    setState(() {
      _screenLoadingStates[ScreenType.positions] = true;
    });

    // Replace screen immediately for instant UI response
    _replaceScreenInPanel(ScreenType.positions);

    // Move all async operations to background to prevent blocking UI
    Future.microtask(() async {
      if (!mounted) return;

      final portfolio = ref.read(portfolioProvider);
      portfolio.cancelTimer();

      // Check if request is already in progress (prevents duplicate calls on rapid clicks)
      if (_isRequestInProgress('positions')) {
        debugPrint('⏭️ Skipping Positions fetch - request already in progress');
        if (mounted) {
          setState(() {
            _screenLoadingStates[ScreenType.positions] = false;
          });
        }
        return;
      }

      // Mark request as started
      _markRequestStarted('positions');

      try {
        // Fetch positions data BEFORE WebSubscriptionManager subscribes
        // This ensures tokens are available for subscription
        // Always fetch fresh data when switching to Positions
        await portfolio.fetchPositionBook(context, false);

        // Start position update timer
        if (mounted) {
          portfolio.timerfunc();

          // Update subscription manager AFTER data is fetched
          // This ensures tokens are available for subscription
          _updateSubscriptionManagerForPanels();

          // Clear loading state after data is fetched
          setState(() {
            _screenLoadingStates[ScreenType.positions] = false;
          });
        }
      } finally {
        // Always mark request as completed
        _markRequestCompleted('positions');
      }
    });
  }

  void _handleFundsTap() async {
    // Set loading state immediately
    setState(() {
      _screenLoadingStates[ScreenType.funds] = true;
    });

    // Replace screen immediately for instant UI response - this triggers setState synchronously
    _replaceScreenInPanel(ScreenType.funds);

    // Allow UI to update first, then do background work
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        if (!mounted) return;

        final portfolio = ref.read(portfolioProvider);
        final orderProviderRef = ref.read(orderProvider);
        final fundProviderRef = ref.read(fundProvider);

        portfolio.cancelTimer();

        // Unsubscribe from other real-time data (non-blocking)
        orderProviderRef.requestWSOrderBook(
            context: context, isSubscribe: false);
        portfolio.requestWSHoldings(context: context, isSubscribe: false);
        portfolio.requestWSPosition(context: context, isSubscribe: false);

        // Fetch funds data in the background (non-blocking)
        if (mounted) {
          await fundProviderRef.fetchFunds(context);

          // Clear loading state after data is fetched
          if (mounted) {
            setState(() {
              _screenLoadingStates[ScreenType.funds] = false;
            });
          }
        }
      });
    });
  }

  void _handlePledgeUnpledgeTap() async {
    // Add pledge/unpledge as a panel tab
    _addScreenAsPanelTab(ScreenType.pledgeUnpledge);

    final portfolio = ref.read(portfolioProvider);
    final reportsprovider = ref.read(ledgerProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref
        .read(orderProvider)
        .requestWSOrderBook(context: context, isSubscribe: false);

    // Fetch pledge/unpledge data
    if (reportsprovider.pledgeandunpledge == null) {
      await reportsprovider.getCurrentDate("pandu");
      reportsprovider.fetchpledgeandunpledge(context);
    }
  }

  // Handle corporate actions tap
  void _handleCorporateActionsTap() async {
    // Add corporate actions as a panel tab
    _addScreenAsPanelTab(ScreenType.corporateActions);

    final portfolio = ref.read(portfolioProvider);
    final reportsprovider = ref.read(ledgerProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref
        .read(orderProvider)
        .requestWSOrderBook(context: context, isSubscribe: false);

    // Fetch corporate actions data
    if (reportsprovider.holdingsAllData == null ||
        reportsprovider.cpactiondata == null) {
      if (reportsprovider.cpactionloader != true) {
        if (reportsprovider.cpactiondata == null) {
          reportsprovider.fetchcpactiondata(context);
        }
      }
      if (reportsprovider.holdingsloading != true) {
        await reportsprovider.getCurrentDate('else');
        if (reportsprovider.holdingsAllData == null) {
          await reportsprovider.fetchholdingsData(
              reportsprovider.today, context);
        }
      }
    }
  }

  // Handle reports tap
  void _handleReportsTap() async {
    // Add reports as a panel tab
    _addScreenAsPanelTab(ScreenType.reports);

    final portfolio = ref.read(portfolioProvider);
    final reportsprovider = ref.read(ledgerProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref
        .read(orderProvider)
        .requestWSOrderBook(context: context, isSubscribe: false);

    // Fetch reports data
    if (reportsprovider.ledgerAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.fetchLegerData(
          context, reportsprovider.startDate, reportsprovider.endDate, reportsprovider.includeBillMargin);
    }
    if (reportsprovider.holdingsAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.fetchholdingsData(reportsprovider.today, context);
    }
    if (reportsprovider.pnlAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.fetchpnldata(
          context, reportsprovider.startDate, reportsprovider.today, true);
    }
    if (reportsprovider.calenderpnlAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.calendarProvider();
      reportsprovider.fetchcalenderpnldata(
          context, reportsprovider.startDate, reportsprovider.today, 'Equity');
    }
    if (reportsprovider.taxpnldercomcur == null &&
        reportsprovider.taxpnleq == null) {
      await reportsprovider.getYearlistTaxpnl();
      await reportsprovider.getCurrentDate('');
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
  }

  // Handle settings tap
  void _handleSettingsTap() async {
    // Add settings as a panel tab
    _addScreenAsPanelTab(ScreenType.settings);

    final portfolio = ref.read(portfolioProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref
        .read(orderProvider)
        .requestWSOrderBook(context: context, isSubscribe: false);
  }

  // Handle trade action tap
  void _handleTradeActionTap() async {
    final portfolio = ref.read(portfolioProvider);
    final stocksProvider = ref.read(stocksProvide);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref
        .read(orderProvider)
        .requestWSOrderBook(context: context, isSubscribe: false);

    // Check if request is already in progress (prevents duplicate calls on rapid clicks)
    if (_isRequestInProgress('trade_action')) {
      debugPrint('⏭️ Skipping Trade Action fetch - request already in progress');
      return;
    }

    // Mark request as started
    _markRequestStarted('trade_action');

    try {
      // Fetch trade action data before WebSubscriptionManager subscribes
      // This ensures tokens are available for subscription
      // Always fetch fresh data when switching to Trade Action
      await stocksProvider.fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
      await stocksProvider.fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");

      // WebSubscriptionManager will handle subscription after data is fetched
      // via _updateSubscriptionManagerForPanels() which is called when screen is added
    } finally {
      // Always mark request as completed
      _markRequestCompleted('trade_action');
    }
  }

  // Show screen in right panel (for app bar navigation)
  void _showScreenInRightPanel(ScreenType screenType) {
    if (_panels.length < 2) return;

    // Find the panel that doesn't have watchlist (prefer right panel for non-watchlist screens)
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));

      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }

    // If no panel without watchlist found, use the right panel (index 1)
    if (targetPanelIndex == -1) {
      targetPanelIndex = 1;
    }

    setState(() {
      _panels[targetPanelIndex].screenType = screenType;
      _panels[targetPanelIndex].screens = [screenType];
      _panels[targetPanelIndex].activeScreenIndex = 0;
    });

    _saveLayout();
  }

  void _showScreenInLeftPanel(ScreenType screenType) {
    if (_panels.isEmpty) return;

    // Find the panel that doesn't have watchlist (prefer left panel for non-watchlist screens)
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));

      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }

    // If no panel without watchlist found, use the left panel (index 0)
    if (targetPanelIndex == -1) {
      targetPanelIndex = 0;
    }

    setState(() {
      _panels[targetPanelIndex].screenType = screenType;
      _panels[targetPanelIndex].screens = [screenType];
      _panels[targetPanelIndex].activeScreenIndex = 0;
    });

    _saveLayout();
  }

  // Show dialog to add screen to specific panel
  void _showAddScreenToPanelDialog(PanelConfig panel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final theme = ref.watch(themeProvider);
            return AlertDialog(
              backgroundColor:
                  theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Screen Tab',
                        style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          18,
                          2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: colors.colorGrey,
                      size: 24,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...ScreenType.values
                          .where((screenType) =>
                              _shouldShowScreenOption(screenType, panel))
                          .map((screenType) => _buildScreenOptionForPanel(
                              screenType, theme, panel))
                          ,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Check if screen option should be shown (hide duplicates only)
  bool _shouldShowScreenOption(ScreenType screenType, PanelConfig panel) {
    // Allow all screen types including app bar screens to be added as tabs

    // Check if current panel has watchlist
    bool panelHasWatchlist = panel.screenType == ScreenType.watchlist ||
        (panel.screens.isNotEmpty &&
            panel.screens.contains(ScreenType.watchlist));

    // If panel has watchlist, only allow watchlist to be added (no other screens)
    if (panelHasWatchlist) {
      if (screenType != ScreenType.watchlist) {
        return false; // Don't allow other screens in watchlist panel
      }
      // If it's watchlist, check if watchlist already exists
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty &&
              panel.screens.contains(ScreenType.watchlist));
      if (hasWatchlist) {
        return false; // Don't allow duplicate watchlist
      }
    }

    // Check if screen already exists in current panel
    bool alreadyExistsInPanel = panel.screens.contains(screenType);

    // Check if screen already exists in any other panel (for watchlist and scrip details)
    bool alreadyExistsInOtherPanel = false;
    if (screenType == ScreenType.watchlist ||
        screenType == ScreenType.scripDepthInfo) {
      for (int i = 0; i < _panels.length; i++) {
        if (i != _panels.indexOf(panel)) {
          final otherPanel = _panels[i];
          bool hasScreen = otherPanel.screenType == screenType ||
              (otherPanel.screens.isNotEmpty &&
                  otherPanel.screens.contains(screenType));
          if (hasScreen) {
            alreadyExistsInOtherPanel = true;
            break;
          }
        }
      }
    }

    // Hide if already exists in current panel or other panels
    return !alreadyExistsInPanel && !alreadyExistsInOtherPanel;
  }

  // Build screen option for panel dialog
  Widget _buildScreenOptionForPanel(
      ScreenType screenType, ThemesProvider theme, PanelConfig panel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Add as a regular screen to the panel
          setState(() {
            if (screenType != ScreenType.watchlist) {
              // Check if screen already exists in this panel
              if (!panel.screens.contains(screenType)) {
                panel.screens.add(screenType);
                panel.activeScreenIndex = panel.screens.length - 1;
              } else {
                // Switch to existing screen
                panel.activeScreenIndex = panel.screens.indexOf(screenType);
              }
              // Update screenType for backward compatibility
              panel.screenType = screenType;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Watchlist cannot be added'),
                ),
              );
            }
          });
          _saveLayout();
          // Call the appropriate handler function for the new screen type
          _handleScreenTypeChange(screenType);
          Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? colors.colorGrey.withOpacity(0.1)
                : colors.colorGrey.withOpacity(0.05),
            border: Border.all(
              color: theme.isDarkMode
                  ? colors.colorGrey.withOpacity(0.2)
                  : colors.colorGrey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForScreenType(screenType),
                  color: theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getScreenTitle(screenType),
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    1,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.isDarkMode
                    ? WebDarkColors.iconSecondary
                    : WebColors.iconSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add default screens to empty panels
  void _addDefaultScreens() {
    // Always set up default panels: dashboard screen on left panel, watchlist on right panel
    if (_panels.length >= 2) {
      // Right panel - watchlist only (fixed, cannot be replaced)
      _panels[1] = _panels[1].copyWith(
        screenType: ScreenType.watchlist,
        screens: [ScreenType.watchlist],
        activeScreenIndex: 0,
      );

      // Left panel - always set dashboard screen as default
      _panels[0] = _panels[0].copyWith(
        screenType: ScreenType.dashboard,
        screens: [ScreenType.dashboard],
        activeScreenIndex: 0,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  // Remove screen from panel
  void _removeScreenFromPanel(PanelConfig panel, int index) {
    // Prevent removing watchlist screens
    if (index >= 0 &&
        index < panel.screens.length &&
        panel.screens[index] == ScreenType.watchlist) {
      return; // Don't remove watchlist screens
    }

    // Get the screen type being removed
    ScreenType? screenTypeToRemove;
    if (index >= 0 && index < panel.screens.length) {
      screenTypeToRemove = panel.screens[index];
    }

    setState(() {
      panel.screens.removeAt(index);
      if (panel.activeScreenIndex >= panel.screens.length) {
        panel.activeScreenIndex = panel.screens.length - 1;
      }
      if (panel.activeScreenIndex < 0) {
        panel.activeScreenIndex = 0;
      }
      // Update screenType for backward compatibility
      if (panel.screens.isNotEmpty &&
          panel.activeScreenIndex >= 0 &&
          panel.activeScreenIndex < panel.screens.length) {
        panel.screenType = panel.screens[panel.activeScreenIndex];
      } else {
        panel.screenType = null;
      }
    });

    // Clean up resources for the removed screen
    if (screenTypeToRemove != null) {
      _cleanupScreenResources(screenTypeToRemove);
    }

    _saveLayout();
  }

  Widget _buildChartOverlay() {
    return Consumer(
      builder: (context, ref, _) {
        final showChart = ref.watch(userProfileProvider
            .select((userProfile) => userProfile.showchartof));
        final webViewKey = ref.watch(userProfileProvider
            .select((userProfile) => userProfile.webViewKey));
        final theme = ref.watch(themeProvider);

        return Positioned(
          key: webViewKey,
          bottom: showChart ? 0 : (MediaQuery.of(context).size.height + 100),
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastLinearToSlowEaseIn,
            decoration: BoxDecoration(
              color:
                  theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ChartScreenWebViews(
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

  void _handleReconnectionSuccess() {
    if (!mounted) return;
    setState(() {});
  }

  Future<bool> showExitPopup() async {
    if (ref.read(userProfileProvider).showchartof) {
      ref.read(userProfileProvider).setChartdialog(false);
      ref.read(chartUpdateProvider).changeOrientation('portrait');

      final mktwth = ref.read(marketWatchProvider);
      mktwth.chngDephBtn("Overview");
      mktwth.singlePageloader(true);
      mktwth.calldepthApis(context, mktwth.getQuotes, "");
      mktwth.singlePageloader(false);

      if (mounted) setState(() {});
      ref.read(marketWatchProvider).setChartScript('ABC', '0123', 'ABCD');
      return false;
    } else {
      return await showDialog(
              context: context,
              builder: (BuildContext context) {
                final theme = ref.read(themeProvider);
                return AlertDialog(
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.surface
                        : WebColors.backgroundTertiary,
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
                                    ? WebDarkColors.primary.withOpacity(0.1)
                                    : WebColors.primary.withOpacity(0.1),
                                highlightColor: theme.isDarkMode
                                    ? WebDarkColors.primary.withOpacity(0.05)
                                    : WebColors.primary.withOpacity(0.05),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.iconSecondary
                                        : WebColors.iconSecondary,
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
                            child: Text(
                              "Do you want to Exit the App?",
                              style: WebTextStyles.sub(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                    : WebColors.textPrimary,
                                fontWeight: WebFonts.regular,
                              ),
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
                            minimumSize: const Size(0, 45),
                            side: BorderSide(
                                color: theme.isDarkMode
                                    ? WebDarkColors.border
                                    : WebColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: theme.isDarkMode
                                ? WebDarkColors.primary
                                : WebColors.primary,
                          ),
                          child: Text(
                            "Exit",
                            style: WebTextStyles.title(
                              isDarkTheme: theme.isDarkMode,
                              color: WebDarkColors.textPrimary,
                              fontWeight: WebFonts.bold,
                            ),
                          ),
                        ),
                      ),
                    ]);
              }) ??
          false;
    }
  }
}

// Profile dropdown widget
class _ProfileDropdown extends StatefulWidget {
  final bool isDarkMode;
  final String clientId;

  const _ProfileDropdown({
    required this.isDarkMode,
    required this.clientId,
  });

  @override
  State<_ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<_ProfileDropdown> {
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => _ProfileDropdownOverlay(
        isDarkMode: widget.isDarkMode,
        clientId: widget.clientId,
        onClose: () {
          _removeOverlay();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: _toggleDropdown,
        borderRadius: BorderRadius.circular(10),
        splashColor:
            (widget.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                .withOpacity(0.2),
        highlightColor:
            (widget.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                .withOpacity(0.1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.clientId,
              style: WebTextStyles.sub(
                isDarkTheme: widget.isDarkMode,
                color: widget.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
                fontWeight: WebFonts.semiBold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isDropdownOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: widget.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper widget that provides close callback to UserAccountScreen via InheritedWidget
class ProfileMenuContentWrapper extends StatelessWidget {
  final VoidCallback onNavigate;

  const ProfileMenuContentWrapper({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileCloseCallback(
      onClose: onNavigate,
      child: const UserAccountScreenWeb(),
    );
  }
}

// InheritedWidget to provide close callback to UserAccountScreen
class _ProfileCloseCallback extends InheritedWidget {
  final VoidCallback onClose;

  const _ProfileCloseCallback({
    required this.onClose,
    required super.child,
  });

  static _ProfileCloseCallback? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ProfileCloseCallback>();
  }

  @override
  bool updateShouldNotify(_ProfileCloseCallback oldWidget) {
    return onClose != oldWidget.onClose;
  }
}

// Profile dropdown overlay widget
class _ProfileDropdownOverlay extends StatelessWidget {
  final bool isDarkMode;
  final String clientId;
  final VoidCallback onClose;

  const _ProfileDropdownOverlay({
    required this.isDarkMode,
    required this.clientId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = isDarkMode ? WebColorScheme.dark() : WebColorScheme.light();

    return GestureDetector(
      onTap: onClose,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // NO background overlay - removed as per request
            // Profile dropdown content positioned at top-right
            Positioned(
              top: 55, // Position below the app bar
              right: 16, // Align with the profile section
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping on content
                child: Container(
                  width: 350,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProfileMenuContentWrapper(
                      onNavigate: onClose, // Pass callback to close on any navigation
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Panel configuration class
class PanelConfig {
  final String id;
  ScreenType? screenType; // Allow null for empty slots
  List<ScreenType> screens; // Multiple screens for tabbed interface
  int activeScreenIndex; // Index of currently active screen
  double width; // As percentage of screen width (0.0 to 1.0)
  double height; // As percentage of screen height (0.0 to 1.0)
  bool isVisible;

  // Resize constraints
  double minWidth; // Minimum width in pixels
  double minHeight; // Minimum height in pixels
  double maxWidth; // Maximum width in pixels
  double maxHeight; // Maximum height in pixels

  // Current actual size in pixels
  double currentWidth;
  double currentHeight;

  // Resize capabilities
  bool enableHorizontalResize;
  bool enableVerticalResize;

  PanelConfig({
    required this.id,
    this.screenType,
    this.screens = const [],
    this.activeScreenIndex = 0,
    required this.width,
    required this.height,
    this.isVisible = true,
    this.minWidth = 150.0,
    this.minHeight = 150.0,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.currentWidth = 0.0,
    this.currentHeight = 0.0,
    this.enableHorizontalResize = true,
    this.enableVerticalResize = true,
  });

  PanelConfig copyWith({
    String? id,
    ScreenType? screenType,
    List<ScreenType>? screens,
    int? activeScreenIndex,
    double? width,
    double? height,
    bool? isVisible,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    double? currentWidth,
    double? currentHeight,
    bool? enableHorizontalResize,
    bool? enableVerticalResize,
  }) {
    return PanelConfig(
      id: id ?? this.id,
      screenType: screenType ?? this.screenType,
      screens: screens ?? this.screens,
      activeScreenIndex: activeScreenIndex ?? this.activeScreenIndex,
      width: width ?? this.width,
      height: height ?? this.height,
      isVisible: isVisible ?? this.isVisible,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      currentWidth: currentWidth ?? this.currentWidth,
      currentHeight: currentHeight ?? this.currentHeight,
      enableHorizontalResize:
          enableHorizontalResize ?? this.enableHorizontalResize,
      enableVerticalResize: enableVerticalResize ?? this.enableVerticalResize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenType': screenType?.name,
      'screens': screens.map((s) => s.name).toList(),
      'activeScreenIndex': activeScreenIndex,
      'width': width,
      'height': height,
      'isVisible': isVisible,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'maxWidth': maxWidth.isFinite
          ? maxWidth
          : 999999.0, // Convert infinity to a large number
      'maxHeight': maxHeight.isFinite
          ? maxHeight
          : 999999.0, // Convert infinity to a large number
      'currentWidth': currentWidth,
      'currentHeight': currentHeight,
      'enableHorizontalResize': enableHorizontalResize,
      'enableVerticalResize': enableVerticalResize,
    };
  }

  factory PanelConfig.fromJson(Map<String, dynamic> json) {
    return PanelConfig(
      id: json['id'],
      screenType: json['screenType'] != null
          ? ScreenType.values.firstWhere((e) => e.name == json['screenType'])
          : null,
      screens: (json['screens'] as List<dynamic>? ?? [])
          .map((s) => ScreenType.values.firstWhere((e) => e.name == s))
          .toList(),
      activeScreenIndex: json['activeScreenIndex'] ?? 0,
      width: json['width'].toDouble(),
      height: json['height']?.toDouble() ?? 0.5,
      isVisible: json['isVisible'] ?? true,
      minWidth: json['minWidth']?.toDouble() ?? 150.0,
      minHeight: json['minHeight']?.toDouble() ?? 150.0,
      maxWidth: (json['maxWidth']?.toDouble() ?? 999999.0) >= 999999.0
          ? double.infinity
          : json['maxWidth']?.toDouble() ?? double.infinity,
      maxHeight: (json['maxHeight']?.toDouble() ?? 999999.0) >= 999999.0
          ? double.infinity
          : json['maxHeight']?.toDouble() ?? double.infinity,
      currentWidth: json['currentWidth']?.toDouble() ?? 0.0,
      currentHeight: json['currentHeight']?.toDouble() ?? 0.0,
      enableHorizontalResize: json['enableHorizontalResize'] ?? true,
      enableVerticalResize: json['enableVerticalResize'] ?? true,
    );
  }
}

// Screen types enum
enum ScreenType {
  dashboard,
  watchlist,
  holdings,
  positions,
  orderBook,
  funds,
  mutualFund,
  ipo,
  bond,
  scripDepthInfo,
  optionChain,
  pledgeUnpledge,
  corporateActions,
  reports,
  settings,
  tradeAction,
}

// Hoverable navigation item widget
class _HoverableNavItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _HoverableNavItem({
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<_HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<_HoverableNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDarkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.title,
            style: WebTextStyles.sub(
              isDarkTheme: theme,
              color: widget.isActive
                  ? (theme ? WebDarkColors.primary : WebColors.primary)
                  : (_isHovered
                      ? (theme ? WebDarkColors.primary : WebColors.primary)
                          .withOpacity(0.8)
                      : (theme
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary)),
              fontWeight: widget.isActive ? WebFonts.bold : WebFonts.semiBold,
            ),
          ),
        ),
      ),
    );
  }

  // Loading indicator widget (static helper)
  static Widget _buildLoadingIndicatorWidget(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDarkMode ? WebDarkColors.background : Colors.white,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode ? WebDarkColors.primary : WebColors.primary,
          ),
        ),
      ),
    );
  }
}

// Lazy loading wrapper for OrderBookScreenWeb to prevent blocking UI
class _LazyOrderBookScreen extends ConsumerStatefulWidget {
  const _LazyOrderBookScreen();

  @override
  ConsumerState<_LazyOrderBookScreen> createState() =>
      _LazyOrderBookScreenState();
}

class _LazyOrderBookScreenState extends ConsumerState<_LazyOrderBookScreen> {
  bool _shouldLoad = false;

  @override
  void initState() {
    super.initState();
    // Defer widget creation using microtask to allow UI to render first
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _shouldLoad = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    // Show loader only during initial widget load phase (first 300ms)
    // After that, show the screen immediately - it can handle empty/loading states internally
    if (!_shouldLoad) {
      return _buildOrderBookLoadingIndicator(theme.isDarkMode);
    }
    // Show screen immediately - OrderBookScreenWeb has its own loading handling
    return const OrderBookScreenWeb();
  }

  Widget _buildOrderBookLoadingIndicator(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDarkMode ? WebDarkColors.background : Colors.white,
      child: const CircularLoaderImage(),
    );
  }
}

// Lazy loading wrapper for SecureFundWeb to prevent blocking UI
class _LazyFundScreen extends ConsumerStatefulWidget {
  const _LazyFundScreen();

  @override
  ConsumerState<_LazyFundScreen> createState() => _LazyFundScreenState();
}

class _LazyFundScreenState extends ConsumerState<_LazyFundScreen> {
  bool _shouldLoad = false;

  @override
  void initState() {
    super.initState();
    // Defer widget creation using microtask to allow UI to render first
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _shouldLoad = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(fundProvider);

    // Show loader if widget not loaded yet or if fund data is not available
    if (!_shouldLoad || fund.fundDetailModel == null) {
      return _buildFundLoadingIndicator(theme.isDarkMode);
    }
    return const SecureFundWeb();
  }

  Widget _buildFundLoadingIndicator(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDarkMode ? WebDarkColors.background : Colors.white,
      child: const CircularLoaderImage(),
    );
  }
}
