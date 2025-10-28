import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
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
import '../Mobile/desk_reports/ca_action/ca_action_buyback.dart';
import '../../../res/res.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/internet_widget.dart';
import 'market_watch/index/default_index_list_web.dart';
import 'splitter_widget.dart';
import '../Mobile/market_watch/tv_chart/webview_chart.dart';
import 'market_watch/watchlist_screen_web.dart';
import 'market_watch/scrip_tabs_manager.dart';
import 'holdings/holding_screen_web.dart';
import 'position/position_screen_web.dart';
import '../Mobile/order_book/order_book_screen.dart';
import '../Mobile/market_watch/option_chain/option_chain_ss.dart';
import '../Mobile/desk_reports/pledge_unpledge_screen.dart';
// Removed CA Event and CP Action from panel screens
import '../Mobile/profile_screen/fund_screen/secure_fund.dart';
import '../Mobile/mutual_fund/mf_main_screen.dart';
import '../Mobile/profile_screen/profile_main_screen.dart';
import '../Mobile/ipo/ipo_main_screen.dart';
import '../Mobile/bonds/bonds_main_screen.dart';
import '../../../utils/custom_navigator.dart';
import '../../models/marketwatch_model/get_quotes.dart';

class CustomizableSplitHomeScreen extends ConsumerStatefulWidget {
  const CustomizableSplitHomeScreen({super.key});

  @override
  ConsumerState<CustomizableSplitHomeScreen> createState() => _CustomizableSplitHomeScreenState();
}

class _CustomizableSplitHomeScreenState extends ConsumerState<CustomizableSplitHomeScreen>
    with WidgetsBindingObserver {
  late WebSocketProvider socketProvider;

  // Panel management
  List<PanelConfig> _panels = [];
  // Arguments storage for panel-specific screens that require constructor params
  DepthInputArgs? _optionChainArgs;
  int _panelCount = 2; // Fixed to 2 panels
  bool _isInitialLoad = true; // Track if this is the initial load
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize with default panels
    _initializeDefaultPanels();
    
    // Set up callback for showing scrip depth info in panel
    ref.read(marketWatchProvider).setOnShowScripDepthInfoInPanel(showScripDepthInfoInPanel);
    
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
          // caEvent and cpAction removed from panel navigation
          }
        },
        replaceScreen: (routeName, {arguments}) {
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
          // caEvent and cpAction removed from panel navigation
          }
        },
        goBack: () {
          // Handle back navigation if needed
        },
      );
    });
    
    // Initialize websocket heartbeat
    ConstantName.timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        ref.read(websocketProvider).reconnect(context);
      }
    });
    
    ref.read(networkStateProvider).networkStream();
    ref.read(marketWatchProvider).fToast.init(context);
    ref.read(versionProvider).checkVersion(context);
    
    // Initialize websocket connection early to ensure real-time data is available
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && ref.read(networkStateProvider).connectionStatus != ConnectivityResult.none) {
        _handleWebSocketConnections();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketProvider = ref.read(websocketProvider);
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
      ScreenType? existingScreen = i < existingScreens.length ? existingScreens[i] : null;
      
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
    // Always initialize with default panels and show positions screen
    // This ensures the app always starts with positions screen, not the saved state
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
        Future.microtask(() async {
          try {
            await ref.read(indexListProvider).checkSession(context);
            if (mounted && ref.read(indexListProvider).checkSess?.stat == "Ok") {
              final futures = [
                ref.read(portfolioProvider).fetchPositionBook(context, false),
                ref.read(portfolioProvider).fetchHoldings(context, ""),
                ref.read(orderProvider).fetchOrderBook(context, false),
                ref.read(orderProvider).fetchTradeBook(context),
              ];
              await Future.wait(futures);
              if (mounted) {
                setState(() {});
              }
            }
            _handleWebSocketConnections();
          } catch (e) {
            print("Error during app resume: $e");
          }
        });
        _handleChartData();
        if (mounted) {
          Future.delayed(Duration(milliseconds: 300), () {
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

    if (ref.read(networkStateProvider).connectionStatus != ConnectivityResult.none) {
      ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: true);
      ref.read(portfolioProvider).requestWSHoldings(context: context, isSubscribe: true);
      ref.read(portfolioProvider).requestWSPosition(context: context, isSubscribe: true);
      ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: true);
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
      preferredSize: Size.fromHeight(54), // Increased height for better visibility
      child: AppBar(
        shadowColor: Colors.transparent,
        elevation: 0,
        backgroundColor: WebDarkColors.background, // Web dark background
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Logo section
            SvgPicture.asset(
              assets.appLogoIcon,
              width: 100,
              height: 38,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            // Top indices section
            const Expanded(
              child: SingleChildScrollView(
                child: DefaultIndexListWeb(src: true)),
            ),
            // const Spacer(),
            // Navigation screens
            _buildNavigationScreens(isDarkMode),
            const SizedBox(width: 16),
            // Swap button
            _buildSwapButton(isDarkMode),
            const SizedBox(width: 16),
            // Profile section
            _buildProfileSection(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizableBody(ThemesProvider theme) {
    return Consumer(
      builder: (context, ref, _) {
        final internetStatus = ref.watch(
            networkStateProvider.select((internet) => internet.connectionStatus));
        final showChart = ref.watch(
            userProfileProvider.select((userProfile) => userProfile.showchartof));

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
    return _buildGridContent(theme);
  }

  Widget _buildGridContent(ThemesProvider theme) {
    return _buildTwoPanels(theme);
  }

  Widget _buildTwoPanels(ThemesProvider theme) {
    // Check if watchlist is in any panel to determine split ratio
    bool hasWatchlistInFirstPanel = _panels.length > 0 && (
        _panels[0].screenType == ScreenType.watchlist ||
        (_panels[0].screens.isNotEmpty && 
         _panels[0].activeScreenIndex >= 0 && 
         _panels[0].activeScreenIndex < _panels[0].screens.length &&
         _panels[0].screens[_panels[0].activeScreenIndex] == ScreenType.watchlist)
    );
    
    bool hasWatchlistInSecondPanel = _panels.length > 1 && (
        _panels[1].screenType == ScreenType.watchlist ||
        (_panels[1].screens.isNotEmpty && 
         _panels[1].activeScreenIndex >= 0 && 
         _panels[1].activeScreenIndex < _panels[1].screens.length &&
         _panels[1].screens[_panels[1].activeScreenIndex] == ScreenType.watchlist)
    );
    
    // Determine split ratio based on watchlist position
    double splitRatio = 0.5; // Default 50/50
    bool enableResize = true; // Default to resizable
    
    if (hasWatchlistInFirstPanel) {
      // Watchlist is in left panel, give it 25% width (same as when it was on right)
      splitRatio = 0.25; // Watchlist gets 25%, other panel gets 75%
      enableResize = false; // Disable resize to maintain fixed ratio
    } else if (hasWatchlistInSecondPanel) {
      // Watchlist is in right panel, give other panel 75% width
      splitRatio = 0.75; // First panel gets 75%, watchlist gets 25%
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
          color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.1) : colors.colorGrey.withOpacity(0.05),
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
          color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.1) : colors.colorGrey.withOpacity(0.05),
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
        onAccept: (draggedData) {
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
        onWillAccept: (data) {
          if (data is ScreenType) {
            return true;
          } else if (data is PanelConfig && data.id != panel.id) {
            return true;
          }
          return false;
        },
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;
          final isPanelSwap = candidateData.isNotEmpty && candidateData.first is PanelConfig;
          final isScreenDrop = candidateData.isNotEmpty && candidateData.first is ScreenType;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isHighlighted 
                  ? (isPanelSwap ? colors.ltpgreen.withOpacity(0.15) : colors.colorBlue.withOpacity(0.15))
                  : (theme.isDarkMode ? colors.colorGrey.withOpacity(0.1) : colors.colorGrey.withOpacity(0.05)),
              // Add single border based on panel position
              border: Border(
                right: index == 0 ? BorderSide(
                  color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.3) : colors.colorGrey.withOpacity(0.2),
                  // width: 1,
                ) : BorderSide.none,
                left: index == 1 ? BorderSide(
                  color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.3) : colors.colorGrey.withOpacity(0.2),
                  // width: 1,
                ) : BorderSide.none,
              ),
              boxShadow: isHighlighted ? [
                BoxShadow(
                  color: isPanelSwap ? colors.ltpgreen.withOpacity(0.3) : colors.colorBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
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
                        color: (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.1),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drop to add',
                              style: WebTextStyles.caption(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
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
    return InkWell(
      onTap: () {
        _showAddScreenDialog();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          // Removed border to eliminate thick border between layouts
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add screen',
                style: WebTextStyles.caption(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                  fontWeight: WebFonts.regular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build filled slot with screen content
  Widget _buildFilledSlot(PanelConfig panel, ThemesProvider theme) {
    // Get the active screen or fallback to screenType for backward compatibility
    ScreenType? activeScreen;
    if (panel.screens.isNotEmpty && panel.activeScreenIndex >= 0 && panel.activeScreenIndex < panel.screens.length) {
      activeScreen = panel.screens[panel.activeScreenIndex];
    } else {
      activeScreen = panel.screenType;
    }
    
    return Stack(
      children: [
        // Screen content (not draggable) - with padding to show below header
        Positioned(
          top: activeScreen == ScreenType.watchlist ? 0 : 40, // No header for watchlist, 40px for others
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
                    index: panel.activeScreenIndex >= 0 && panel.activeScreenIndex < panel.screens.length
                        ? panel.activeScreenIndex
                        : 0,
                    children: panel.screens.map((screenType) {
                      return _getScreenForType(screenType);
                    }).toList(),
                  )
                : (activeScreen != null ? _getScreenForType(activeScreen) : const SizedBox.shrink()),
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
              height: 40,
              decoration: BoxDecoration(
                color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary.withOpacity(0.1),
               
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
                            children: panel.screens.asMap().entries.map((entry) {
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
                                _handleScreenTypeChange(screenType);
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
                                      style: WebTextStyles.para(
                                        isDarkTheme: true,
                                        color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                                        fontWeight: isActive ? WebFonts.bold : WebFonts.medium,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (panel.screens.length > 1) ...[
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _removeScreenFromPanel(panel, index),
                                        child: Icon(
                                          Icons.close,
                                          color: WebDarkColors.textSecondary,
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
                            style: WebTextStyles.sub(
                              isDarkTheme: true,
                              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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
                  PopupMenuButton<ScreenType>(
                    icon: Icon(Icons.swap_horiz, color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary, size: 18),
                    tooltip: 'Replace Screen',
                    onSelected: (ScreenType newType) {
                      setState(() {
                        if (panel.screens.isNotEmpty) {
                          panel.screens[panel.activeScreenIndex] = newType;
                          panel.screenType = newType;
                        } else {
                          panel.screenType = newType;
                          panel.screens = [newType];
                        }
                      });
                      _saveLayout();
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
                  // Remove button
                  IconButton(
                    icon: Icon(Icons.close, color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary, size: 18),
                    onPressed: () {
                      setState(() {
                        panel.screenType = null;
                        panel.screens.clear();
                        panel.activeScreenIndex = 0;
                      });
                       if (activeScreen != null) {
                          _cleanupScreenResources(activeScreen);
                        }
                      _saveLayout();
                    },
                  ),
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
        _buildNavItem('Positions', isDarkMode, ScreenType.positions, () => _handlePositionsTap()),
        const SizedBox(width: 8),
        _buildNavItem('Holdings', isDarkMode, ScreenType.holdings, () => _handleHoldingsTap()),
        const SizedBox(width: 8),
        _buildNavItem('Orders', isDarkMode, ScreenType.orderBook, () => _handleOrderBookTap()),
        const SizedBox(width: 8),
        _buildNavItem('Fund', isDarkMode, ScreenType.funds, () => _handleFundsTap()),
      ],
    );
  }

  // Build individual navigation item
  Widget _buildNavItem(String title, bool isDarkMode, ScreenType screenType, VoidCallback onTap) {
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
    );
  }

  // Build swap button for app bar
  Widget _buildSwapButton(bool isDarkMode) {
    return InkWell(
      onTap: _handleSwapPanels,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.1),
      hoverColor: Colors.white.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.swap_horiz,
          color: WebDarkColors.textPrimary, // Always white on dark background
          size: 24,
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
      case ScreenType.watchlist:
        return const WatchListScreenWeb();
      case ScreenType.holdings:
        return Consumer(
          builder: (context, ref, _) {
            final portfolio = ref.watch(portfolioProvider);
            return HoldingScreenWeb(listofHolding: portfolio.holdingsModel ?? []);
          },
        );
      case ScreenType.positions:
        return Consumer(
          builder: (context, ref, _) {
            final portfolio = ref.watch(portfolioProvider);
            return PositionScreenWeb(listofPosition: portfolio.allPostionList);
          },
        );
      case ScreenType.orderBook:
        return const OrderBookScreenWeb();
      case ScreenType.funds:
        return const SecureFundWeb();
      case ScreenType.mutualFund:
        return const MfmainScreen();
      case ScreenType.ipo:
        return const IPOScreen(isIpo: true);
      case ScreenType.bond:
        return const BondsScreen(isBonds: true);
      case ScreenType.scripDepthInfo:
        return const ScripTabsManager();
      case ScreenType.optionChain:
        if (_optionChainArgs != null) {
          return OptionChainSS(wlValue: _optionChainArgs!);
        }
        return const SizedBox.shrink();
      case ScreenType.pledgeUnpledge:
        return const PledgenUnpledge(ddd: "DDDDD");
      case ScreenType.corporateActions:
        return CABuyback();
      case ScreenType.reports:
        return ReportsScreen();
      case ScreenType.settings:
        return SettingsScreen();
      // caEvent and cpAction removed
    }
  }

  String _getScreenTitle(ScreenType type) {
    switch (type) {
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
        return 'Scrip Details';
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
      // caEvent and cpAction removed
    }
  }

  IconData _getIconForScreenType(ScreenType type) {
    switch (type) {
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
      
      if (draggedIndex != -1 && targetIndex != -1 && draggedIndex != targetIndex) {
        // Check if watchlist is involved in the swap
        bool draggedHasWatchlist = _panels[draggedIndex].screenType == ScreenType.watchlist ||
            (_panels[draggedIndex].screens.isNotEmpty && _panels[draggedIndex].screens.contains(ScreenType.watchlist));
        bool targetHasWatchlist = _panels[targetIndex].screenType == ScreenType.watchlist ||
            (_panels[targetIndex].screens.isNotEmpty && _panels[targetIndex].screens.contains(ScreenType.watchlist));
        
        // Swap the screen types
        final tempScreenType = _panels[draggedIndex].screenType;
        _panels[draggedIndex].screenType = _panels[targetIndex].screenType;
        _panels[targetIndex].screenType = tempScreenType;
        
        // Swap the multiple screens structure
        final tempScreens = List<ScreenType>.from(_panels[draggedIndex].screens);
        final tempActiveScreenIndex = _panels[draggedIndex].activeScreenIndex;
        
        _panels[draggedIndex].screens = List<ScreenType>.from(_panels[targetIndex].screens);
        _panels[draggedIndex].activeScreenIndex = _panels[targetIndex].activeScreenIndex;
        
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
                (_panels[i].screens.isNotEmpty && _panels[i].screens.contains(ScreenType.watchlist));
            
            if (!hasWatchlist && (_panels[i].screenType != null || _panels[i].screens.isNotEmpty)) {
              nonWatchlistPanelIndex = i;
              break;
            }
          }
          
          // If we found a non-watchlist panel, ensure it's active
          if (nonWatchlistPanelIndex != -1 && _panels[nonWatchlistPanelIndex].screens.isNotEmpty) {
            // Set the active screen to the first non-watchlist screen
            for (int i = 0; i < _panels[nonWatchlistPanelIndex].screens.length; i++) {
              if (_panels[nonWatchlistPanelIndex].screens[i] != ScreenType.watchlist) {
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
              backgroundColor: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
                        color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Screen',
                        style: WebTextStyles.head(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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
                          .where((screenType) => screenType != ScreenType.watchlist)
                          .map((screenType) => 
                            _buildScreenOption(screenType, theme)
                          ).toList(),
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
                  color: (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForScreenType(screenType),
                  color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
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
                color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
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
    // Only call handlers if this is not the initial load
    if (_isInitialLoad) {
      return;
    }
    
    switch (screenType) {
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
      // caEvent and cpAction removed
    }
  }

  // Handle scrip depth info tap
  void _handleScripDepthInfoTap() async {
    final portfolio = ref.read(portfolioProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
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
            ref.read(portfolioProvider).requestWSHoldings(context: context, isSubscribe: false);
          }
          _clearScreenCache(screenType);
          break;
          
        case ScreenType.positions:
          if (mounted) {
            ref.read(portfolioProvider).requestWSPosition(context: context, isSubscribe: false);
          }
          _clearScreenCache(screenType);
          break;
          
        case ScreenType.orderBook:
          if (mounted) {
            ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
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
      
    } catch (e) {
    }
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
      } else {
      }
    } catch (e) {
    }
  }

  // Show ScripDepthInfo in a panel
  void showScripDepthInfoInPanel(dynamic watchListData) {
    // Check if scrip details already exist in any panel
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasScripDetails = panel.screenType == ScreenType.scripDepthInfo ||
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.scripDepthInfo));
      
      if (hasScripDetails) {
        // Scrip details already exist, switch to that panel instead of creating duplicate
        setState(() {
          _panels[i].activeScreenIndex = panel.screens.indexOf(ScreenType.scripDepthInfo);
          if (_panels[i].activeScreenIndex == -1) {
            _panels[i].activeScreenIndex = 0;
          }
        });
        _saveLayout();
        return; // Exit early to prevent duplicate
      }
    }
    
    // Find the best panel to add scrip tab to
    int targetPanelIndex = -1;
    
    // First, look for a panel that already has multiple tabs (like Holdings, Order Book)
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
      
      // Skip watchlist panels, but prefer panels with existing tabs
      if (!hasWatchlist && panel.screens.length > 0) {
        targetPanelIndex = i;
        break;
      }
    }
    
    // If no panel with existing tabs, find any non-watchlist panel
    if (targetPanelIndex == -1) {
      for (int i = 0; i < _panels.length; i++) {
        final panel = _panels[i];
        bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
            (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
        
        if (!hasWatchlist) {
          targetPanelIndex = i;
          break;
        }
      }
    }
    
    // If no suitable panel found, use left panel (index 0)
    if (targetPanelIndex == -1) {
      targetPanelIndex = 0;
    }
    
    // Add ScripDepthInfo as a new tab (don't replace existing tabs)
    setState(() {
      if (_panels[targetPanelIndex].screens.isEmpty) {
        // If panel is empty, initialize with ScripDepthInfo
        _panels[targetPanelIndex].screens = [ScreenType.scripDepthInfo];
        _panels[targetPanelIndex].activeScreenIndex = 0;
      } else {
        // Add to existing tabs
        if (!_panels[targetPanelIndex].screens.contains(ScreenType.scripDepthInfo)) {
          _panels[targetPanelIndex].screens.add(ScreenType.scripDepthInfo);
        }
        _panels[targetPanelIndex].activeScreenIndex = _panels[targetPanelIndex].screens.indexOf(ScreenType.scripDepthInfo);
      }
      // Update screenType for backward compatibility
      _panels[targetPanelIndex].screenType = ScreenType.scripDepthInfo;
    });
    
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
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.orderBook));
      
      if (hasOrderBook) {
        // Order book already exists, switch to that panel instead of creating duplicate
        setState(() {
          _panels[i].activeScreenIndex = panel.screens.indexOf(ScreenType.orderBook);
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
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
      
      if (!hasWatchlist) {
        targetPanelIndex = i;
        break;
      }
    }
    
    // If no panel without watchlist found, use the left panel (index 0) - avoid right panel with watchlist
    if (targetPanelIndex == -1) {
      targetPanelIndex = 0; // Always use left panel to avoid replacing watchlist
    }
    
    // Set the OrderBook screen in the target panel
    setState(() {
      _panels[targetPanelIndex].screenType = ScreenType.orderBook;
      _panels[targetPanelIndex].screens = [ScreenType.orderBook];
      _panels[targetPanelIndex].activeScreenIndex = 0;
    });
    
    _saveLayout();
    
    // Call the handler for the new screen type
    _handleScreenTypeChange(ScreenType.orderBook);
  }

  // Show Option Chain in a panel
  void showOptionChainInPanel(DepthInputArgs args) {
    // Check if already exists
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool exists = panel.screenType == ScreenType.optionChain ||
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.optionChain));
      if (exists) {
        setState(() {
          _optionChainArgs = args;
          _panels[i].activeScreenIndex = panel.screens.indexOf(ScreenType.optionChain);
          if (_panels[i].activeScreenIndex == -1) _panels[i].activeScreenIndex = 0;
        });
        _saveLayout();
        return;
      }
    }
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
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
    _saveLayout();
  }

 

  // caEvent and cpAction handlers removed

  // Initialize default screen data after initial load
  void _initializeDefaultScreenData() {
    if (_panels.length >= 2) {
      // Right panel should only have watchlist - move any other screens to left panel
      if (_panels[1].screenType != null && _panels[1].screenType != ScreenType.watchlist) {
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
        if (_panels[0].screenType == ScreenType.watchlist) {
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
      
      // Ensure websocket connections are established for real-time data
      if (mounted && ref.read(networkStateProvider).connectionStatus != ConnectivityResult.none) {
        _handleWebSocketConnections();
      }
    }
  }

  // Individual screen type handlers (based on home_screen.dart)
  void _handleWatchlistTap() async {
    final portfolio = ref.read(portfolioProvider);
    final marketWatchList = ref.read(marketWatchProvider);
    final orderProviderRef = ref.read(orderProvider);

    portfolio.cancelTimer();

    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await orderProviderRef.requestWSOrderBook(
        context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await marketWatchList.requestMWScrip(context: context, isSubscribe: true);
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
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
      
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
          _panels[i].screenType = screenType; // Update for backward compatibility
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
    // Replace screen instead of adding as tab
    _replaceScreenInPanel(ScreenType.orderBook);
    
    final portfolio = ref.read(portfolioProvider);
    final orderProviderRef = ref.read(orderProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await orderProviderRef.requestWSOrderBook(context: context, isSubscribe: true);

    // Fetch order data in the background
    Future.microtask(() {
      if (mounted) {
        orderProviderRef.fetchOrderBook(context, false);
        orderProviderRef.fetchTradeBook(context);
        orderProviderRef.fetchSipOrderHistory(context);
      }
    });
  }

  void _handleIPOTap() async {
    final portfolio = ref.read(portfolioProvider);
    final ipoProvider = ref.read(ipoProvide);
    final authProvi = ref.read(authProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);

    // Fetch IPO data in the background
    Future.microtask(() {
      if (mounted) {
        authProvi.setIposAPicalls(context);
        ipoProvider.getipoorderbookmodel(context, true);
      }
    });
  }

  void _handleBondTap() async {
    final portfolio = ref.read(portfolioProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    // await ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);

    // Fetch Bond data in the background
    Future.microtask(() {
      if (mounted) {
      ref.read(bondsProvider).fetchAllBonds();
      }
    });
  }

  // New handler methods for separate portfolio screens
  void _handleHoldingsTap() async {
    // Replace screen instead of adding as tab
    _replaceScreenInPanel(ScreenType.holdings);
    
    final portfolio = ref.read(portfolioProvider);
    final orderProviderRef = ref.read(orderProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    await orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);
    
    // Subscribe to holdings data
    await portfolio.requestWSHoldings(context: context, isSubscribe: true);

    // Fetch holdings data in the background
    Future.microtask(() {
      if (mounted) {
        portfolio.fetchHoldings(context, "");
      }
    });
  }

  void _handlePositionsTap() async {
    // Replace screen instead of adding as tab
    _replaceScreenInPanel(ScreenType.positions);
    
    final portfolio = ref.read(portfolioProvider);
    final orderProviderRef = ref.read(orderProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    await orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    
    // Fetch positions data first to ensure we have tokens to subscribe to
    await portfolio.fetchPositionBook(context, false);
    
    // Subscribe to positions data after fetching (now we have tokens)
    await portfolio.requestWSPosition(context: context, isSubscribe: true);
    
    // Start position update timer
    portfolio.timerfunc();
  }

  void _handleFundsTap() async {
    // Replace screen instead of adding as tab
    _replaceScreenInPanel(ScreenType.funds);
    
    final portfolio = ref.read(portfolioProvider);
    final orderProviderRef = ref.read(orderProvider);
    final fundProviderRef = ref.read(fundProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    await orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    await portfolio.requestWSPosition(context: context, isSubscribe: false);

    // Fetch funds data in the background
    Future.microtask(() {
      if (mounted) {
        fundProviderRef.fetchFunds(context);
      }
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
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
    
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
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
    
    // Fetch corporate actions data
    if (reportsprovider.holdingsAllData == null || reportsprovider.cpactiondata == null) {
      if (reportsprovider.cpactionloader != true) {
        if (reportsprovider.cpactiondata == null) {
          reportsprovider.fetchcpactiondata(context);
        }
      }
      if (reportsprovider.holdingsloading != true) {
        await reportsprovider.getCurrentDate('else');
        if (reportsprovider.holdingsAllData == null) {
          await reportsprovider.fetchholdingsData(reportsprovider.today, context);
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
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
    
    // Fetch reports data
    if (reportsprovider.ledgerAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.fetchLegerData(context, reportsprovider.startDate, reportsprovider.endDate);
    }
    if (reportsprovider.holdingsAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.fetchholdingsData(reportsprovider.today, context);
    }
    if (reportsprovider.pnlAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.fetchpnldata(context, reportsprovider.startDate, reportsprovider.today, true);
    }
    if (reportsprovider.calenderpnlAllData == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.calendarProvider();
      reportsprovider.fetchcalenderpnldata(context, reportsprovider.startDate, reportsprovider.today, 'Equity');
    }
    if (reportsprovider.taxpnldercomcur == null && reportsprovider.taxpnleq == null) {
      await reportsprovider.getYearlistTaxpnl();
      await reportsprovider.getCurrentDate('');
    }
    if (reportsprovider.tradebookdata == null) {
      await reportsprovider.getCurrentDate('tradebook');
      reportsprovider.fetchtradebookdata(context, reportsprovider.startDate, reportsprovider.today);
    }
    if (reportsprovider.pdfdownload == null) {
      await reportsprovider.getCurrentDate('else');
      reportsprovider.fetchpdfdownload(context, reportsprovider.startDate, reportsprovider.today);
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
    await ref.read(orderProvider).requestWSOrderBook(context: context, isSubscribe: false);
  }

  // Show screen in right panel (for app bar navigation)
  void _showScreenInRightPanel(ScreenType screenType) {
    if (_panels.length < 2) return;
    
    // Find the panel that doesn't have watchlist (prefer right panel for non-watchlist screens)
    int targetPanelIndex = -1;
    for (int i = 0; i < _panels.length; i++) {
      final panel = _panels[i];
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
      
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
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
      
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
              backgroundColor: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
                        color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Screen Tab',
                        style: textStyle(
                          theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                          .where((screenType) => _shouldShowScreenOption(screenType, panel))
                          .map((screenType) => 
                            _buildScreenOptionForPanel(screenType, theme, panel)
                          ).toList(),
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
        (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
    
    // If panel has watchlist, only allow watchlist to be added (no other screens)
    if (panelHasWatchlist) {
      if (screenType != ScreenType.watchlist) {
        return false; // Don't allow other screens in watchlist panel
      }
      // If it's watchlist, check if watchlist already exists
      bool hasWatchlist = panel.screenType == ScreenType.watchlist ||
          (panel.screens.isNotEmpty && panel.screens.contains(ScreenType.watchlist));
      if (hasWatchlist) {
        return false; // Don't allow duplicate watchlist
      }
    }
    
    // Check if screen already exists in current panel
    bool alreadyExistsInPanel = panel.screens.contains(screenType);
    
    // Check if screen already exists in any other panel (for watchlist and scrip details)
    bool alreadyExistsInOtherPanel = false;
    if (screenType == ScreenType.watchlist || screenType == ScreenType.scripDepthInfo) {
      for (int i = 0; i < _panels.length; i++) {
        if (i != _panels.indexOf(panel)) {
          final otherPanel = _panels[i];
          bool hasScreen = otherPanel.screenType == screenType ||
              (otherPanel.screens.isNotEmpty && otherPanel.screens.contains(screenType));
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
  Widget _buildScreenOptionForPanel(ScreenType screenType, ThemesProvider theme, PanelConfig panel) {
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
                SnackBar(
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
                  color: (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForScreenType(screenType),
                  color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
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
                color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
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
    // Always set up default panels: position screen on left panel, watchlist on right panel
    if (_panels.length >= 2) {
      // Right panel - watchlist only (fixed, cannot be replaced)
      _panels[1] = _panels[1].copyWith(
        screenType: ScreenType.watchlist,
        screens: [ScreenType.watchlist],
        activeScreenIndex: 0,
      );
      
      // Left panel - always set position screen as default
      _panels[0] = _panels[0].copyWith(
        screenType: ScreenType.positions,
        screens: [ScreenType.positions],
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
    if (index >= 0 && index < panel.screens.length && panel.screens[index] == ScreenType.watchlist) {
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
      if (panel.screens.isNotEmpty && panel.activeScreenIndex >= 0 && panel.activeScreenIndex < panel.screens.length) {
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
              color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ChartScreenWebView(
                      chartArgs:  ChartArgs(exch: 'ABC', tsym: 'ABCD', token: '0123')),
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
                          side: BorderSide(color: theme.isDarkMode ? WebDarkColors.border : WebColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
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
    return InkWell(
      onTap: _toggleDropdown,
      borderRadius: BorderRadius.circular(5),
      splashColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.1),
      hoverColor: Colors.white.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // decoration: BoxDecoration(
        //   color: WebDarkColors.surfaceVariant, // Subtle overlay on dark background
        //   borderRadius: BorderRadius.circular(5),
        //   border: Border.all(
        //     color: WebDarkColors.border, // Subtle border
        //     width: 1,
        //   ),
        // ),
        child: Text(
          widget.clientId,
          style: WebTextStyles.sub(
            isDarkTheme: true,
            color: WebDarkColors.textPrimary, // Always white on dark background
            fontWeight: WebFonts.semiBold,
          ),
        ),
      ),
    );
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
    return GestureDetector(
      onTap: onClose,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Background overlay
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
              ),
            ),
            // Profile dropdown content
            Positioned(
              top: 55, // Position below the app bar
              right: 16, // Align with the profile section
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping on content
                child: Container(
                  width: 300,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: isDarkMode ? WebDarkColors.surface : WebColors.surface,
                    border: Border.all(
                      color: isDarkMode 
                          ? WebDarkColors.border 
                          : WebColors.border,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    child: const UserAccountScreen(),
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
      enableHorizontalResize: enableHorizontalResize ?? this.enableHorizontalResize,
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
      'maxWidth': maxWidth.isFinite ? maxWidth : 999999.0, // Convert infinity to a large number
      'maxHeight': maxHeight.isFinite ? maxHeight : 999999.0, // Convert infinity to a large number
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
      maxWidth: (json['maxWidth']?.toDouble() ?? 999999.0) >= 999999.0 ? double.infinity : json['maxWidth']?.toDouble() ?? double.infinity,
      maxHeight: (json['maxHeight']?.toDouble() ?? 999999.0) >= 999999.0 ? double.infinity : json['maxHeight']?.toDouble() ?? double.infinity,
      currentWidth: json['currentWidth']?.toDouble() ?? 0.0,
      currentHeight: json['currentHeight']?.toDouble() ?? 0.0,
      enableHorizontalResize: json['enableHorizontalResize'] ?? true,
      enableVerticalResize: json['enableVerticalResize'] ?? true,
    );
  }
}

// Screen types enum
enum ScreenType {
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
}

// Hoverable navigation item widget
class _HoverableNavItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _HoverableNavItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_HoverableNavItem> createState() => _HoverableNavItemState();
}

class _HoverableNavItemState extends State<_HoverableNavItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(6),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          widget.title,
          style: WebTextStyles.sub(
            isDarkTheme: true,
            color: WebDarkColors.textPrimary,
            fontWeight: widget.isActive ? WebFonts.bold : WebFonts.semiBold,
          ),
        ),
      ),
    );
  }
}

