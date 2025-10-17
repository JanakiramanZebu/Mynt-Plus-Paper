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
import '../../../provider/transcation_provider.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/ledger_provider.dart';
import '../../../res/global_state_text.dart';
import '../desk_reports/ca_action/ca_action_buyback.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/internet_widget.dart';
import 'default_index_list_web.dart';
import 'splitter_widget.dart';
import '../market_watch/tv_chart/webview_chart.dart';
import 'watchlist_screen_web.dart';
import 'scrip_tabs_manager.dart';
import 'holding_screen_web.dart';
import 'position_screen_web.dart';
import '../order_book/order_book_screen.dart';
import '../market_watch/option_chain/option_chain_ss.dart';
import '../desk_reports/pledge_unpledge_screen.dart';
// Removed CA Event and CP Action from panel screens
import '../profile_screen/fund_screen/secure_fund.dart';
import '../mutual_fund/mf_main_screen.dart';
import '../profile_screen/profile_main_screen.dart';
import '../ipo/ipo_main_screen.dart';
import '../bonds/bonds_main_screen.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutJson = prefs.getString('custom_split_layout');
      if (layoutJson != null) {
        final layoutData = jsonDecode(layoutJson) as Map<String, dynamic>;
        setState(() {
          _panelCount = layoutData['panelCount'] ?? 4;
          _panels = (layoutData['panels'] as List)
              .map((p) => PanelConfig.fromJson(p))
              .toList();
        });
      } else {
        // Initialize with default layout if no saved layout exists
        _initializeDefaultPanels();
      }
    } catch (e) {
      print('Error loading split layout: $e');
      // Fallback to default layout on error
      _initializeDefaultPanels();
    }
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
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
          ref.read(portfolioProvider).cancelTimer();
        }
        final userProfile = ref.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        break;
      case AppLifecycleState.paused:
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
          ref.read(portfolioProvider).cancelTimer();
        }
        break;
      case AppLifecycleState.detached:
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
          ref.read(portfolioProvider).cancelTimer();
        }
        final userProfile = ref.read(userProfileProvider);
        userProfile.setonloadChartdialog(false);
        break;
      case AppLifecycleState.hidden:
        if (ref.read(indexListProvider).selectedBtmIndx == 2) {
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
      preferredSize: Size.fromHeight(60),
      child: AppBar(
        shadowColor: isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        elevation: 0,
        backgroundColor: isDarkMode ? colors.colorBlack : colors.colorWhite,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Logo section
            SvgPicture.asset(
              assets.appLogoIcon,
              width: 100,
              height: 40,
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
            // Notification bell
            _buildNotificationBell(isDarkMode),
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
      splitterSize: 12.0,
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.3) : colors.colorGrey.withOpacity(0.2),
            width: 1,
            style: BorderStyle.solid,
          ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.3) : colors.colorGrey.withOpacity(0.2),
            width: 1,
            style: BorderStyle.solid,
          ),
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
      child: DragTarget<Object>(
        onAccept: (draggedData) {
          print('=== DRAG TARGET ACCEPT ===');
          print('Dragged data: $draggedData');
          print('Panel ID: ${panel.id}');
          if (draggedData is ScreenType) {
            print('Accepting ScreenType: ${draggedData.name}');
            print('Setting panel screen type to: ${draggedData.name}');
            setState(() {
              panel.screenType = draggedData;
              if (panel.screens.isEmpty) {
                panel.screens = [draggedData];
                panel.activeScreenIndex = 0;
              } else {
                panel.screens[panel.activeScreenIndex] = draggedData;
              }
            });
            print('Panel screen type after setState: ${panel.screenType?.name ?? 'null'}');
            _saveLayout();
          } else if (draggedData is PanelConfig && draggedData.id != panel.id) {
            print('Accepting PanelConfig swap');
            _swapPanels(draggedData, panel);
            _saveLayout();
          }
          print('=== DRAG TARGET ACCEPT COMPLETE ===');
        },
        onWillAccept: (data) {
          print('DragTarget onWillAccept called with: $data');
          if (data is ScreenType) {
            print('Will accept ScreenType: ${data.name}');
            return true;
          } else if (data is PanelConfig && data.id != panel.id) {
            print('Will accept PanelConfig swap');
            return true;
          }
          print('Will NOT accept data');
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted
                    ? (isPanelSwap ? colors.ltpgreen : colors.colorBlue)
                    : (theme.isDarkMode ? colors.colorGrey.withOpacity(0.3) : colors.colorGrey.withOpacity(0.2)),
                width: isHighlighted ? 3 : 1,
                style: BorderStyle.solid,
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
                        color: colors.colorBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: colors.colorBlue,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            TextWidget.captionText(
                              text: 'Drop to add',
                              theme: theme.isDarkMode,
                              color: colors.colorBlue,
                              fw: 1,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.1) : colors.colorGrey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.isDarkMode ? colors.colorGrey.withOpacity(0.3) : colors.colorGrey.withOpacity(0.2),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: theme.isDarkMode ? colors.colorGrey : colors.colorGrey.withOpacity(0.6),
                size: 32,
              ),
              const SizedBox(height: 8),
              TextWidget.captionText(
                text: 'Tap to add screen',
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.colorGrey : colors.colorGrey.withOpacity(0.6),
                fw: 0,
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
          top: 40, // Offset by header height
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: activeScreen != null ? _getScreenForType(activeScreen) : const SizedBox.shrink(),
          ),
        ),
        
        // Header with controls (draggable)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Draggable<PanelConfig>(
            data: panel,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: () {
              print('Drag started for PanelConfig: ${panel.id}');
            },
            onDragEnd: (details) {
              print('Drag ended for PanelConfig: ${panel.id}');
            },
            feedback: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.colorBlue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.drag_indicator,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      TextWidget.paraText(
                        text: _getScreenTitleNullable(panel.screens.isNotEmpty 
                            ? panel.screens[panel.activeScreenIndex] 
                            : panel.screenType),
                        theme: false,
                        color: Colors.white,
                        fw: 2,
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
                color: colors.colorBlue.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Drag handle
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.drag_indicator,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  // Tabs for multiple screens
                  if (panel.screens.length > 1) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [ 
                            Row(
                              children: panel.screens.asMap().entries.map((entry) {
                                int index = entry.key;
                                ScreenType screenType = entry.value;
                                bool isActive = index == panel.activeScreenIndex;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      panel.activeScreenIndex = index;
                                    });
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
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        TextWidget.overlineText(
                                          text: _getScreenTitle(screenType),
                                          theme: false,
                                          color: Colors.white,
                                          fw: isActive ? 2 : 0,
                                          textOverflow: TextOverflow.ellipsis,
                                        ),
                                        if (panel.screens.length > 1 && screenType != ScreenType.watchlist) ...[
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () => _removeScreenFromPanel(panel, index),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white.withOpacity(0.7),
                                              size: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (activeScreen != ScreenType.watchlist)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
                        tooltip: 'Add Screen Tab',
                        onPressed: () {
                          _showAddScreenToPanelDialog(panel);
                        },
                      ),
                          ],
                        ),
                      ),
                    ),
                    
                  ] else ...[
                    // Single screen title
                    Expanded(
                      child: Row(
                        children: [
                          TextWidget.paraText(
                            text: _getScreenTitleNullable(activeScreen),
                            theme: false,
                            color: Colors.white,
                            fw: 2,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                  if (activeScreen != ScreenType.watchlist)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
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
                      icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 16),
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
                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                      onPressed: () {
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
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
              ? colors.colorBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive 
              ? Border.all(color: colors.colorBlue.withOpacity(0.3), width: 1)
              : null,
        ),
        child: TextWidget.titleText(
          text: title,
          theme: isDarkMode,
          color: isActive 
              ? colors.colorBlue
              : (isDarkMode ? colors.colorWhite : colors.colorBlack),
          fw: isActive ? 1 : 0,
        ),
      ),
    );
  }

  // Build notification bell for app bar
  Widget _buildNotificationBell(bool isDarkMode) {
    return IconButton(
      onPressed: () {
        // Handle notification tap
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(
        Icons.notifications_outlined,
        color: isDarkMode ? colors.colorWhite : colors.colorBlack,
        size: 24,
      ),
      tooltip: 'Notifications',
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
        return const OrderBookScreen();
      case ScreenType.funds:
        return const SecureFund();
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

  // Show add screen dialog
  void _showAddScreenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final theme = ref.watch(themeProvider);
            return AlertDialog(
              backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                        color: colors.colorBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Screen',
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.isDarkMode 
                ? colors.colorGrey.withOpacity(0.1)
                : colors.colorGrey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
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
                  color: colors.colorBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForScreenType(screenType),
                  color: colors.colorBlue,
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
                color: theme.isDarkMode ? colors.colorGrey : colors.colorGrey.withOpacity(0.6),
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
        // Reports area; unsubscribe others
        _handleFundsTap();
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
    
    // Set the ScripDepthInfo screen in the target panel
    setState(() {
      _panels[targetPanelIndex].screenType = ScreenType.scripDepthInfo;
      _panels[targetPanelIndex].screens = [ScreenType.scripDepthInfo];
      _panels[targetPanelIndex].activeScreenIndex = 0;
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
      // Initialize watchlist (left panel)
      if (_panels[0].screenType == ScreenType.watchlist) {
        _handleWatchlistTap();
      }
      
      // Initialize portfolio screens (left panel only - right panel is reserved for watchlist)
      if (_panels[0].screenType == ScreenType.holdings) {
        _handleHoldingsTap();
      } else if (_panels[0].screenType == ScreenType.positions) {
        _handlePositionsTap();
      } else if (_panels[0].screenType == ScreenType.orderBook) {
        _handleOrderBookTap();
      } else if (_panels[0].screenType == ScreenType.funds) {
        _handleFundsTap();
      }
      
      // Right panel should only have watchlist - move any other screens to left panel
      if (_panels.length > 1 && _panels[1].screenType != null && _panels[1].screenType != ScreenType.watchlist) {
        // Move the screen from right panel to left panel
        _panels[0].screenType = _panels[1].screenType;
        _panels[0].screens = List<ScreenType>.from(_panels[1].screens);
        _panels[0].activeScreenIndex = _panels[1].activeScreenIndex;
        
        // Clear right panel and set watchlist
        _panels[1].screenType = ScreenType.watchlist;
        _panels[1].screens = [ScreenType.watchlist];
        _panels[1].activeScreenIndex = 0;
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

  void _handleOrderBookTap() async {
    // Show order book in right panel
    _showScreenInRightPanel(ScreenType.orderBook);
    
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
    // Show holdings in right panel
    _showScreenInRightPanel(ScreenType.holdings);
    
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
    // Show positions in right panel
    _showScreenInRightPanel(ScreenType.positions);
    
    final portfolio = ref.read(portfolioProvider);
    final orderProviderRef = ref.read(orderProvider);

    portfolio.cancelTimer();

    // Unsubscribe from other real-time data
    await orderProviderRef.requestWSOrderBook(context: context, isSubscribe: false);
    await portfolio.requestWSHoldings(context: context, isSubscribe: false);
    
    // Subscribe to positions data
    await portfolio.requestWSPosition(context: context, isSubscribe: true);

    // Fetch positions data in the background
    Future.microtask(() {
      if (mounted) {
        portfolio.fetchPositionBook(context, false);
        portfolio.timerfunc(); // Start position update timer
      }
    });
  }

  void _handleFundsTap() async {
    // Show funds in right panel
    _showScreenInRightPanel(ScreenType.funds);
    
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

  void _handlePledgeUnpledgeTap() async { // Show pledge/unpledge in right panel
    _showScreenInRightPanel(ScreenType.pledgeUnpledge);
    
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
    // Show corporate actions in left panel
    _showScreenInLeftPanel(ScreenType.corporateActions);
    
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
    // Show reports in left panel
    _showScreenInLeftPanel(ScreenType.reports);
    
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
    // Show settings in left panel
    _showScreenInLeftPanel(ScreenType.settings);
    
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
              backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                        color: colors.colorBlue,
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

  // Check if screen option should be shown (hide duplicates and app bar only screens)
  bool _shouldShowScreenOption(ScreenType screenType, PanelConfig panel) {
    // Hide app bar only screens from panel selection
    if (screenType == ScreenType.holdings || 
        screenType == ScreenType.positions || 
        screenType == ScreenType.orderBook || 
        screenType == ScreenType.funds) {
      return false;
    }
    
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
          setState(() {
            if (screenType != ScreenType.watchlist) {
              panel.screens.add(screenType);
              panel.activeScreenIndex = panel.screens.length - 1;
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.isDarkMode 
                ? colors.colorGrey.withOpacity(0.1)
                : colors.colorGrey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
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
                  color: colors.colorBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForScreenType(screenType),
                  color: colors.colorBlue,
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
                    FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.isDarkMode ? colors.colorGrey : colors.colorGrey.withOpacity(0.6),
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
    // Only add default screens if all panels are empty (first time setup)
    bool hasAnyScreens = _panels.any((panel) => panel.screenType != null || panel.screens.isNotEmpty);
    
    if (hasAnyScreens) {
      return; // Don't add defaults if there are already screens
    }
    
    // Set up default panels: empty left panel, watchlist on right panel
    if (_panels.length >= 2) {
      // Right panel - watchlist only (fixed, cannot be replaced)
      if (_panels[1].screenType == null && _panels[1].screens.isEmpty) {
        _panels[1] = _panels[1].copyWith(
          screenType: ScreenType.watchlist,
          screens: [ScreenType.watchlist],
          activeScreenIndex: 0,
        );
      }
      
      // Left panel - keep empty initially
      // User can add screens by tapping on the empty panel
    }
    
    if (mounted) {
      setState(() {});
      _saveLayout();
    }
  }




  // Remove screen from panel
  void _removeScreenFromPanel(PanelConfig panel, int index) {
    // Prevent removing watchlist screens
    if (index >= 0 && index < panel.screens.length && panel.screens[index] == ScreenType.watchlist) {
      return; // Don't remove watchlist screens
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
                      ? const Color(0xFF121212)
                      : const Color(0xFFF1F3F8),
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
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
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
                                ? colors.textSecondaryDark
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
                          minimumSize: const Size(0, 45),
                          side: BorderSide(color: colors.btnOutlinedBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: colors.primaryDark,
                        ),
                        child: TextWidget.titleText(
                          text: "Exit",
                          color: colors.colorWhite,
                          theme: theme.isDarkMode,
                          fw: 2,
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isDarkMode 
              ? colors.colorGrey.withOpacity(0.2) 
              : colors.colorGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isDarkMode 
                ? colors.colorGrey.withOpacity(0.3) 
                : colors.colorGrey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: TextWidget.subText(
          text: widget.clientId,
          theme: false,
          color: widget.isDarkMode ? colors.colorWhite : colors.colorBlack,
          fw: 1,
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
                    color: isDarkMode ? colors.colorBlack : colors.colorWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode 
                          ? colors.colorGrey.withOpacity(0.3) 
                          : colors.colorGrey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
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
      maxWidth: json['maxWidth']?.toDouble() ?? double.infinity,
      maxHeight: json['maxHeight']?.toDouble() ?? double.infinity,
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
  holdings, // App bar only
  positions, // App bar only
  orderBook, // App bar only
  funds, // App bar only
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

