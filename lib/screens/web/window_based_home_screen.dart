import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'dart:ui' show Rect, Offset;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/screens/web/market_watch/tv_chart/webview_chart.dart';
import 'package:mynt_plus/screens/web/ordersbook/order_book_screen_web.dart';
import 'package:mynt_plus/screens/web/funds/secure_fund_web.dart';
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
import '../../../provider/stocks_provider.dart';
import '../../../provider/web_subscription_manager.dart';
import '../Mobile/desk_reports/ca_action/ca_action_buyback.dart';
import '../../../res/res.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../sharedWidget/internet_widget.dart';
import '../../../sharedWidget/splash_loader.dart';
import 'profile/Reports/reports_screen_web.dart';
import 'profile/profile_main_screen_web.dart';
import 'profile/settings_web.dart';
import 'market_watch/watchlist_screen_web.dart';
import 'holdings/holding_screen_web.dart';
import 'position/position_screen_web.dart';
import 'dashboard_screen_web.dart';
import 'trade_action_screen_web.dart';
import 'market_watch/options/option_chain_ss_web.dart';
import '../Mobile/desk_reports/pledge_unpledge_screen.dart';
import '../Mobile/mutual_fund/mf_main_screen.dart';
import 'ipo/ipo_main_screen_web.dart';
import '../Mobile/bonds/bonds_main_screen.dart';
import '../../../utils/custom_navigator.dart';
import '../../../routes/route_names.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import 'market_watch/chart_with_depth_web.dart';
import 'customizable_split_home_screen.dart' show ScreenType;

/// Window-based home screen using WindowNavigator from shadcn_flutter
/// Screens are displayed as draggable, resizable windows
class WindowBasedHomeScreen extends ConsumerStatefulWidget {
  const WindowBasedHomeScreen({super.key});

  @override
  ConsumerState<WindowBasedHomeScreen> createState() => _WindowBasedHomeScreenState();
}

class _WindowBasedHomeScreenState extends ConsumerState<WindowBasedHomeScreen>
    with WidgetsBindingObserver {
  final GlobalKey<WindowNavigatorHandle> _navigatorKey = GlobalKey();
  late WebSocketProvider socketProvider;
  
  // Track which screens are open as windows
  final Map<ScreenType, int> _openWindows = {}; // ScreenType -> Window Index
  final Map<int, ScreenType> _windowToScreenType = {}; // Window Index -> ScreenType
  
  // Arguments storage for panel-specific screens
  DepthInputArgs? _optionChainArgs;
  DepthInputArgs? _currentDepthArgs;
  
  // Track loading states
  final Map<ScreenType, bool> _screenLoadingStates = {};
  
  // Cooldown for portfolio data fetching
  DateTime? _lastPortfolioFetch;
  static const _portfolioFetchCooldown = Duration(seconds: 30);
  
  // Track ongoing API requests
  final Set<String> _ongoingRequests = {};
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWindows();
    _setupWebNavigationHelper();
    _initializeWebSocket();
  }
  
  void _initializeWindows() {
    // Load saved window layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedLayout();
      // Add default windows
      _addWindow(ScreenType.dashboard);
      _addWindow(ScreenType.watchlist);
    });
  }
  
  Future<void> _loadSavedLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutJson = prefs.getString('window_layout');
      if (layoutJson != null) {
        // Restore windows from saved layout
        // Implementation depends on WindowNavigator's persistence API
        // For now, we'll just load the saved data structure
        jsonDecode(layoutJson) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading window layout: $e');
    }
  }
  
  Future<void> _saveLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final windows = _navigatorKey.currentState?.windows ?? [];
      final layout = {
        'windows': windows.asMap().entries.map((entry) {
          final index = entry.key;
          final window = entry.value;
          final bounds = window.bounds;
          return {
            'bounds': {
              'left': bounds?.left ?? 0.0,
              'top': bounds?.top ?? 0.0,
              'width': bounds?.width ?? 0.0,
              'height': bounds?.height ?? 0.0,
            },
            'screenType': _windowToScreenType[index]?.name,
          };
        }).toList(),
      };
      await prefs.setString('window_layout', jsonEncode(layout));
    } catch (e) {
      debugPrint('Error saving window layout: $e');
    }
  }
  
  void _setupWebNavigationHelper() {
    WebNavigationHelper.initialize(
      navigatorKey: GlobalKey<NavigatorState>(),
      navigateToScreen: (routeName, {arguments}) {
        _handleNavigation(routeName, arguments);
      },
      replaceScreen: (routeName, {arguments}) {
        _handleNavigation(routeName, arguments, replace: true);
      },
      goBack: () {
        // Handle back navigation
      },
    );
  }
  
  void _handleNavigation(String routeName, dynamic arguments, {bool replace = false}) {
    if (routeName == "orderBook" || routeName == Routes.orderBook) {
      _showScreenInWindow(ScreenType.orderBook);
    } else if (routeName == "optionChain") {
      if (arguments is DepthInputArgs) {
        _optionChainArgs = arguments;
        _showScreenInWindow(ScreenType.optionChain);
      }
    } else if (routeName == Routes.tradeActionScreen || routeName == "tradeActionScreen") {
      _showScreenInWindow(ScreenType.tradeAction);
    } else if (routeName == Routes.holdingscreen || routeName == "HoldingScreen") {
      _showScreenInWindow(ScreenType.holdings);
    } else if (routeName == Routes.positionscreen || routeName == "PositionScreen") {
      _showScreenInWindow(ScreenType.positions);
    } else if (routeName == Routes.fundscreen || routeName == "fundscreen") {
      _showScreenInWindow(ScreenType.funds);
    } else if (routeName == Routes.ipo || routeName == "Ipo" || routeName == "ipo") {
      _showScreenInWindow(ScreenType.ipo);
    }
  }
  
  void _initializeWebSocket() {
    ref.read(networkStateProvider).networkStream();
    ref.read(marketWatchProvider).fToast.init(context);
    ref.read(versionProvider).checkVersion(context);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted &&
          ref.read(networkStateProvider).connectionStatus !=
              ConnectivityResult.none) {
        _handleWebSocketConnections();
      }
    });
    
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
    ref.read(webSubscriptionManagerProvider).updateContext(context);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (ConstantName.timer != null) {
      ConstantName.timer!.cancel();
      ConstantName.timer = null;
    }
    socketProvider.closeSocket(false);
    ConstantName.chartwebViewController?.dispose();
    super.dispose();
  }
  
  void _handleWebSocketConnections() {
    if (!mounted) return;
    
    final websocket = ref.read(websocketProvider);
    
    if (websocket.connectioncount >= 5) {
      websocket.changeconnectioncount();
    }
    
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
    
    if (ref.read(networkStateProvider).connectionStatus !=
        ConnectivityResult.none) {
      _updateSubscriptionManagerForWindows();
    }
  }
  
  /// Add or show a screen in a window
  void _addWindow(ScreenType screenType) {
    // Check if window already exists
    // if (_openWindows.containsKey(screenType)) {
    //   // WindowNavigator should handle bringing to front automatically
    //   return;
    // }
    
    final size = MediaQuery.of(context).size;
    final windows = _navigatorKey.currentState?.windows ?? [];
    
    // Calculate position for new window (cascade style)
    final offset = windows.length * 30.0;
    final windowWidth = size.width * 0.6;
    final windowHeight = size.height * 0.7;
    
    final bounds = Rect.fromLTWH(
      offset.clamp(0.0, size.width - windowWidth),
      offset.clamp(0.0, size.height - windowHeight),
      windowWidth,
      windowHeight,
    );
    
    // Create window with screen content
    final window = Window(
      bounds: bounds,
      title: Text(_getScreenTitle(screenType)),
      content: _buildScreenContent(screenType),
    );
    
    // Add window
    _navigatorKey.currentState?.pushWindow(window);
    
    // Track the window by index
    final currentWindows = _navigatorKey.currentState?.windows ?? [];
    final windowIndex = currentWindows.length - 1;
    _openWindows[screenType] = windowIndex;
    _windowToScreenType[windowIndex] = screenType;
    
    // Handle screen-specific initialization
    _handleScreenTypeChange(screenType);
    
    // Save layout
    _saveLayout();
  }
  
  /// Show screen in window (alias for _addWindow)
  void _showScreenInWindow(ScreenType screenType) {
    _addWindow(screenType);
  }
  
  /// Build screen content widget
  Widget _buildScreenContent(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.dashboard:
        return const DashboardScreenWeb();
      case ScreenType.watchlist:
        return const WatchListScreenWeb();
      case ScreenType.holdings:
        return Consumer(
          builder: (context, ref, _) {
            final isLoading = _screenLoadingStates[ScreenType.holdings] ?? false;
            final holdloader = ref.watch(portfolioProvider.select((p) => p.holdloader));
            final holdingsModel = ref.watch(portfolioProvider.select((p) => p.holdingsModel));
            final theme = ref.read(themeProvider);
            final hasData = holdingsModel != null && holdingsModel.isNotEmpty;
            
            if (isLoading || holdloader || !hasData) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: theme.isDarkMode ? WebDarkColors.background : material.Colors.white,
                child: const CircularLoaderImage(),
              );
            }
            return HoldingScreenWeb(listofHolding: holdingsModel);
          },
        );
      case ScreenType.positions:
        return Consumer(
          builder: (context, ref, _) {
            final isLoading = _screenLoadingStates[ScreenType.positions] ?? false;
            final posloader = ref.watch(portfolioProvider.select((p) => p.posloader));
            final allPostionList = ref.watch(portfolioProvider.select((p) => p.allPostionList));
            final theme = ref.read(themeProvider);
            
            if (isLoading || posloader) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: theme.isDarkMode ? WebDarkColors.background : material.Colors.white,
                child: const CircularLoaderImage(),
              );
            }
            return PositionScreenWeb(listofPosition: allPostionList);
          },
        );
      case ScreenType.orderBook:
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
              // PERFORMANCE FIX: Use .select() to only watch getQuotes
              final quotes = ref.watch(marketWatchProvider.select((p) => p.getQuotes));
              final fallback = ChartArgs(exch: 'ABC', tsym: 'ABCD', token: '0123');
              return ChartWithDepthWeb(
                wlValue: DepthInputArgs(
                  exch: quotes?.exch ?? fallback.exch,
                  token: quotes?.token?.toString() ?? fallback.token,
                  tsym: quotes?.tsym ?? fallback.tsym,
                  instname: quotes?.instname ?? '',
                  symbol: quotes?.symbol ?? '',
                  expDate: quotes?.expDate ?? '',
                  option: quotes?.option ?? '',
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
        return TradeActionScreenWeb(
          key: const ValueKey('tradeAction'),
        );
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
    }
  }
  
  void _handleScreenTypeChange(ScreenType screenType) {
    _updateSubscriptionManagerForWindows();
    
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
      case ScreenType.ipo:
        _handleIPOTap();
        break;
      case ScreenType.tradeAction:
        _handleTradeActionTap();
        break;
      default:
        break;
    }
  }
  
  void _updateSubscriptionManagerForWindows() {
    final subscriptionManager = ref.read(webSubscriptionManagerProvider);
    final windows = _navigatorKey.currentState?.windows ?? [];
    
    for (int i = 0; i < windows.length; i++) {
      final screenType = _windowToScreenType[i];
      if (screenType != null) {
        subscriptionManager.updateActiveScreen(i, screenType);
      }
    }
  }
  
  // Screen handler methods (from customizable_split_home_screen.dart)
  void _handleDashboardTap() async {
    final indexProvider = ref.read(indexListProvider);
    final stocksProvider = ref.read(stocksProvide);
    final portfolio = ref.read(portfolioProvider);
    
    portfolio.cancelTimer();
    
    if (indexProvider.topIndicesForDashboard == null) {
      await indexProvider.getTopIndicesForDashboard(context);
    }
    
    if (stocksProvider.topGainers.isEmpty && stocksProvider.topLosers.isEmpty) {
      await stocksProvider.fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
    }
    if (stocksProvider.byValue.isEmpty && stocksProvider.byVolume.isEmpty) {
      await stocksProvider.fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
    }
    
    if (mounted) {
      _updateSubscriptionManagerForWindows();
    }
  }
  
  void _handleWatchlistTap() async {
    final portfolio = ref.read(portfolioProvider);
    portfolio.cancelTimer();
    _updateSubscriptionManagerForWindows();
  }
  
  void _handleHoldingsTap() async {
    setState(() {
      _screenLoadingStates[ScreenType.holdings] = true;
    });
    
    Future.microtask(() async {
      if (!mounted) return;
      
      final portfolio = ref.read(portfolioProvider);
      portfolio.cancelTimer();
      
      if (_isRequestInProgress('holdings')) {
        if (mounted) {
          setState(() {
            _screenLoadingStates[ScreenType.holdings] = false;
          });
        }
        return;
      }
      
      _markRequestStarted('holdings');
      
      try {
        await portfolio.fetchHoldings(context, "");
        
        if (mounted) {
          _updateSubscriptionManagerForWindows();
          setState(() {
            _screenLoadingStates[ScreenType.holdings] = false;
          });
        }
      } finally {
        _markRequestCompleted('holdings');
      }
    });
  }
  
  void _handlePositionsTap() async {
    setState(() {
      _screenLoadingStates[ScreenType.positions] = true;
    });
    
    Future.microtask(() async {
      if (!mounted) return;
      
      final portfolio = ref.read(portfolioProvider);
      portfolio.cancelTimer();
      
      if (_isRequestInProgress('positions')) {
        if (mounted) {
          setState(() {
            _screenLoadingStates[ScreenType.positions] = false;
          });
        }
        return;
      }
      
      _markRequestStarted('positions');
      
      try {
        await portfolio.fetchPositionBook(context, false);
        
        if (mounted) {
          portfolio.timerfunc();
          _updateSubscriptionManagerForWindows();
          setState(() {
            _screenLoadingStates[ScreenType.positions] = false;
          });
        }
      } finally {
        _markRequestCompleted('positions');
      }
    });
  }
  
  void _handleOrderBookTap() async {
    Future.microtask(() async {
      if (!mounted) return;
      
      final portfolio = ref.read(portfolioProvider);
      portfolio.cancelTimer();
      
      if (_isRequestInProgress('order_book')) {
        return;
      }
      
      _markRequestStarted('order_book');
      
      try {
        final orderProviderRef = ref.read(orderProvider);
        await orderProviderRef.fetchOrderBook(context, false);
        
        if (mounted) {
          orderProviderRef.changeTabIndex(0, context);
          _updateSubscriptionManagerForWindows();
        }
      } finally {
        _markRequestCompleted('order_book');
      }
    });
  }
  
  void _handleFundsTap() async {
    setState(() {
      _screenLoadingStates[ScreenType.funds] = true;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        if (!mounted) return;
        
        final portfolio = ref.read(portfolioProvider);
        final orderProviderRef = ref.read(orderProvider);
        final fundProviderRef = ref.read(fundProvider);
        
        portfolio.cancelTimer();
        
        orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
        portfolio.requestWSHoldings(context: context, isSubscribe: false);
        portfolio.requestWSPosition(context: context, isSubscribe: false);
        
        if (mounted) {
          await fundProviderRef.fetchFunds(context);
          
          if (mounted) {
            setState(() {
              _screenLoadingStates[ScreenType.funds] = false;
            });
          }
        }
      });
    });
  }
  
  void _handleIPOTap() async {
    setState(() {
      _screenLoadingStates[ScreenType.ipo] = true;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        if (!mounted) return;
        
        final portfolio = ref.read(portfolioProvider);
        final ipoProvider = ref.read(ipoProvide);
        final authProvi = ref.read(authProvider);
        
        portfolio.cancelTimer();
        
        portfolio.requestWSHoldings(context: context, isSubscribe: false);
        portfolio.requestWSPosition(context: context, isSubscribe: false);
        ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
        
        if (mounted) {
          authProvi.setIposAPicalls(context);
          ipoProvider.getipoorderbookmodel(context, true);
          
          if (mounted) {
            setState(() {
              _screenLoadingStates[ScreenType.ipo] = false;
            });
          }
        }
      });
    });
  }
  
  void _handleTradeActionTap() async {
    final portfolio = ref.read(portfolioProvider);
    final stocksProvider = ref.read(stocksProvide);
    
    portfolio.cancelTimer();
    
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
    
    if (_isRequestInProgress('trade_action')) {
      return;
    }
    
    _markRequestStarted('trade_action');
    
    try {
      await stocksProvider.fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
      await stocksProvider.fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
    } finally {
      _markRequestCompleted('trade_action');
    }
  }
  
  bool _isRequestInProgress(String requestKey) {
    return _ongoingRequests.contains(requestKey);
  }
  
  void _markRequestStarted(String requestKey) {
    _ongoingRequests.add(requestKey);
  }
  
  void _markRequestCompleted(String requestKey) {
    _ongoingRequests.remove(requestKey);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(webSubscriptionManagerProvider).updateContext(context);
        
        final now = DateTime.now();
        final shouldFetchPortfolio = _hasPortfolioScreen() &&
            (_lastPortfolioFetch == null ||
                now.difference(_lastPortfolioFetch!) > _portfolioFetchCooldown);
        
        Future.microtask(() async {
          try {
            await ref.read(indexListProvider).checkSession(context);
            if (mounted &&
                ref.read(indexListProvider).checkSess?.stat == "Ok" &&
                shouldFetchPortfolio) {
              _lastPortfolioFetch = now;
              
              final futures = <Future>[];
              final windows = _navigatorKey.currentState?.windows ?? [];
              
              for (int i = 0; i < windows.length; i++) {
                final screenType = _windowToScreenType[i];
                if (screenType == ScreenType.positions) {
                  futures.add(ref.read(portfolioProvider).fetchPositionBook(context, false));
                } else if (screenType == ScreenType.holdings) {
                  futures.add(ref.read(portfolioProvider).fetchHoldings(context, ""));
                } else if (screenType == ScreenType.orderBook) {
                  futures.add(ref.read(orderProvider).fetchOrderBook(context, false));
                }
              }
              
              if (futures.isNotEmpty) {
                await Future.wait(futures);
              }
              
              if (mounted) {
                setState(() {});
              }
            }
            _handleWebSocketConnections();
          } catch (e) {
            debugPrint("Error during app resume: $e");
          }
        });
        break;
      default:
        break;
    }
  }
  
  bool _hasPortfolioScreen() {
    return _openWindows.containsKey(ScreenType.positions) ||
        _openWindows.containsKey(ScreenType.holdings) ||
        _openWindows.containsKey(ScreenType.orderBook) ||
        _openWindows.containsKey(ScreenType.funds);
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
      child: material.Scaffold(
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
        // PERFORMANCE FIX: Use .select() to only watch connection status fields
        // Watching entire websocketProvider caused rebuilds every 500ms!
        final connectionCount = ref.watch(websocketProvider.select((p) => p.connectioncount));
        final reconnectionSuccess = ref.watch(websocketProvider.select((p) => p.reconnectionSuccess));
        final wsConnected = ref.watch(websocketProvider.select((p) => p.wsConnected));

        if ((internet.connectionStatus == ConnectivityResult.none ||
                connectionCount >= 5) &&
            !reconnectionSuccess &&
            !wsConnected) {
          ref.read(networkStateProvider).getContext(context);
          return material.Scaffold(
            appBar: material.AppBar(
              elevation: 0,
              backgroundColor: material.Colors.white,
            ),
            body: NoInternetScreen(
              onReconnectionSuccess: () {
                setState(() {});
              },
            ),
          );
        }

        final theme = ref.watch(themeProvider);
        return material.Scaffold(
          appBar: _buildAppBar(theme.isDarkMode),
          body: _buildWindowNavigator(theme),
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(58),
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? WebDarkColors.surface : material.Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDarkMode
                    ? WebDarkColors.divider.withOpacity(0.3)
                    : WebColors.divider.withOpacity(0.2),
                width: 1,
              ),
            ),
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
                // Logo
                RepaintBoundary(
                  child: SvgPicture.asset(
                    assets.appLogoIcon,
                    width: 100,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
                // Navigation screens
                Row(
                  children: [
                    _buildNavigationScreens(isDarkMode),
                    const SizedBox(width: 12),
                    RepaintBoundary(
                      child: _buildProfileSection(isDarkMode),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavigationScreens(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavItem('Dashboard', isDarkMode, ScreenType.dashboard, () => _showScreenInWindow(ScreenType.dashboard)),
        const SizedBox(width: 8),
        _buildNavItem('Watchlist', isDarkMode, ScreenType.watchlist, () => _showScreenInWindow(ScreenType.watchlist)),
        const SizedBox(width: 8),
        _buildNavItem('Positions', isDarkMode, ScreenType.positions, () => _showScreenInWindow(ScreenType.positions)),
        const SizedBox(width: 8),
        _buildNavItem('Holdings', isDarkMode, ScreenType.holdings, () => _showScreenInWindow(ScreenType.holdings)),
        const SizedBox(width: 8),
        _buildNavItem('Orders', isDarkMode, ScreenType.orderBook, () => _showScreenInWindow(ScreenType.orderBook)),
        const SizedBox(width: 8),
        _buildNavItem('Fund', isDarkMode, ScreenType.funds, () => _showScreenInWindow(ScreenType.funds)),
        const SizedBox(width: 8),
        _buildNavItem('IPO', isDarkMode, ScreenType.ipo, () => _showScreenInWindow(ScreenType.ipo)),
      ],
    );
  }
  
  Widget _buildNavItem(String title, bool isDarkMode, ScreenType screenType, VoidCallback onTap) {
    final isActive = _openWindows.containsKey(screenType);
    
    return _HoverableNavItem(
      title: title,
      isActive: isActive,
      onTap: onTap,
      isDarkMode: isDarkMode,
    );
  }
  
  Widget _buildProfileSection(bool isDarkMode) {
    return Consumer(
      builder: (context, ref, _) {
        final userProfile = ref.watch(userProfileProvider);
        final userDetail = userProfile.userDetailModel;
        final clientDetail = userProfile.clientDetailModel;
        
        String clientId = userDetail?.actid ?? clientDetail?.actid ?? '';
        
        return _ProfileDropdown(
          isDarkMode: isDarkMode,
          clientId: clientId,
        );
      },
    );
  }
  
  Widget _buildWindowNavigator(ThemesProvider theme) {
    return Consumer(
      builder: (context, ref, _) {
        final internetStatus = ref.watch(networkStateProvider
            .select((internet) => internet.connectionStatus));
        final showChart = ref.watch(userProfileProvider
            .select((userProfile) => userProfile.showchartof));
        
        if ((internetStatus == ConnectivityResult.wifi ||
                internetStatus == ConnectivityResult.mobile) &&
            !showChart) {
          return WindowNavigator(
            key: _navigatorKey,
            initialWindows: [],
            child: Container(
              color: theme.isDarkMode ? WebDarkColors.background : material.Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      size: 64,
                      color: material.Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Window-Based Trading Platform',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: material.Colors.grey[300],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click navigation items to open windows',
                      style: TextStyle(
                        fontSize: 16,
                        color: material.Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
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
              color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
      return await material.showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                final theme = ref.read(themeProvider);
                return material.AlertDialog(
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
                            material.Material(
                              color: material.Colors.transparent,
                              shape: const CircleBorder(),
                              child: material.InkWell(
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
                        child: material.OutlinedButton(
                          onPressed: () => material.Navigator.of(context).pop(true),
                          style: material.OutlinedButton.styleFrom(
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

// Reuse helper widgets from customizable_split_home_screen.dart
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: material.InkWell(
        onTap: widget.onTap,
        splashColor: material.Colors.transparent,
        highlightColor: material.Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.title,
            style: WebTextStyles.sub(
              isDarkTheme: widget.isDarkMode,
              color: widget.isActive
                  ? (widget.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                  : (_isHovered
                      ? (widget.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                          .withOpacity(0.8)
                      : (widget.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary)),
              fontWeight: widget.isActive ? WebFonts.bold : WebFonts.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}

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
      child: material.InkWell(
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
      child: material.Material(
        color: material.Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              top: 55,
              right: 16,
              child: GestureDetector(
                onTap: () {},
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
                      onNavigate: onClose,
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

class _ProfileCloseCallback extends InheritedWidget {
  final VoidCallback onClose;
  
  const _ProfileCloseCallback({
    required this.onClose,
    required super.child,
  });
  
  @override
  bool updateShouldNotify(_ProfileCloseCallback oldWidget) {
    return onClose != oldWidget.onClose;
  }
}

// Lazy loading wrapper for funds screen
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
    
    if (!_shouldLoad || fund.fundDetailModel == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.isDarkMode ? WebDarkColors.background : material.Colors.white,
        child: const CircularLoaderImage(),
      );
    }
    return const SecureFundWeb();
  }
}

