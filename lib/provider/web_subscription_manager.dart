import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'websocket_provider.dart';
import 'market_watch_provider.dart';
import 'portfolio_provider.dart';
import 'order_provider.dart';
import 'index_list_provider.dart';
import 'stocks_provider.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../screens/web/customizable_split_home_screen.dart';

/// Web-specific subscription manager that tracks active screens across multiple panels
/// and manages websocket subscriptions accordingly
class WebSubscriptionManager extends ChangeNotifier with WidgetsBindingObserver {
  final Ref ref;
  
  WebSubscriptionManager(this.ref) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  // Track active screens per panel (panel index -> ScreenType)
  final Map<int, ScreenType?> _activeScreens = {};

  // Track subscriptions per screen type (ScreenType -> Set of symbols)
  final Map<ScreenType, Set<String>> _screenSubscriptions = {};

  // Track which symbols are currently subscribed via websocket (for deduplication)
  final Set<String> _currentWebSocketSubscriptions = {};
  
  // Track which screens need which subscription types
  Map<ScreenType, SubscriptionType> _screenSubscriptionTypes = {};
  
  // App lifecycle tracking
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  DateTime? _lastPauseTime;
  bool _wasDisconnectedInBackground = false;
  
  // Network tracking
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _lastNetworkStatus = ConnectivityResult.mobile;
  
  // Context management
  BuildContext? _lastValidContext;
  DateTime? _lastContextUpdate;
  
  // Getters
  Map<int, ScreenType?> get activeScreens => Map.from(_activeScreens);
  Map<ScreenType, Set<String>> get screenSubscriptions => Map.from(_screenSubscriptions);
  AppLifecycleState get currentState => _currentState;
  
  void _init() {
    // Initialize subscription types for each screen
    _initializeSubscriptionTypes();
    
    // Listen to network changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _handleNetworkChange(result);
    });
  }
  
  /// Initialize which subscription type each screen needs
  void _initializeSubscriptionTypes() {
    _screenSubscriptionTypes = {
      ScreenType.dashboard: SubscriptionType.marketWatch,
      ScreenType.watchlist: SubscriptionType.marketWatch,
      ScreenType.holdings: SubscriptionType.holdings,
      ScreenType.positions: SubscriptionType.positions,
      ScreenType.orderBook: SubscriptionType.none, // Order book handles its own tab-specific subscriptions
      ScreenType.funds: SubscriptionType.none,
      ScreenType.mutualFund: SubscriptionType.none,
      ScreenType.ipo: SubscriptionType.none,
      ScreenType.bond: SubscriptionType.none,
      ScreenType.scripDepthInfo: SubscriptionType.marketWatch,
      ScreenType.optionChain: SubscriptionType.marketWatch,
      ScreenType.pledgeUnpledge: SubscriptionType.none,
      ScreenType.corporateActions: SubscriptionType.none,
      ScreenType.reports: SubscriptionType.none,
      ScreenType.settings: SubscriptionType.none,
      ScreenType.tradeAction: SubscriptionType.marketWatch,
    };
  }
  
  /// Update active screen for a panel
  void updateActiveScreen(int panelIndex, ScreenType? screenType) {
    final previousScreen = _activeScreens[panelIndex];
    
    if (previousScreen == screenType) {
      return; // No change
    }
    
    print('\n🔄 [WebSubscriptionManager] Panel $panelIndex screen change:');
    print('   From: ${previousScreen ?? "none"}');
    print('   To: ${screenType ?? "none"}');
    log('WebSubscriptionManager: Panel $panelIndex screen changed from $previousScreen to $screenType');
    
    // Unsubscribe from previous screen if it exists
    if (previousScreen != null) {
      _unsubscribeFromScreen(previousScreen);
    }
    
    // Update active screen
    if (screenType != null) {
      _activeScreens[panelIndex] = screenType;
      _subscribeToScreen(screenType);
    } else {
      _activeScreens.remove(panelIndex);
    }
    
    notifyListeners();
  }
  
  /// Subscribe to a screen's data
  Future<void> _subscribeToScreen(ScreenType screenType) async {
    if (!_isUserLoggedIn()) {
      log('WebSubscriptionManager: Not subscribing - user not logged in');
      return;
    }

    final context = _getValidContext();
    if (context == null) {
      log('WebSubscriptionManager: No valid context for subscription');
      return;
    }

    final subscriptionType = _screenSubscriptionTypes[screenType] ?? SubscriptionType.none;

    if (subscriptionType == SubscriptionType.none) {
      return; // Screen doesn't need subscriptions
    }

    print('═══════════════════════════════════════════════════════════');
    print('📱 [WebSubscriptionManager] SUBSCRIBING to screen: $screenType');
    print('   Subscription Type: $subscriptionType');
    print('═══════════════════════════════════════════════════════════');
    log('WebSubscriptionManager: Subscribing to $screenType (type: $subscriptionType)');

    try {
      // For dashboard, ensure top indices are fetched first
      if (screenType == ScreenType.dashboard) {
        final indexProvider = ref.read(indexListProvider);
        // Ensure top indices are available
        if (indexProvider.topIndicesForDashboard == null) {
          await indexProvider.getTopIndicesForDashboard(context);
        }
      }
      
      // For trade action, ensure trade action data is fetched first
      if (screenType == ScreenType.tradeAction) {
        final stocksProvider = ref.read(stocksProvide);
        // Ensure trade action data is available
        if (stocksProvider.topGainers.isEmpty && stocksProvider.topLosers.isEmpty) {
          await stocksProvider.fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
          await stocksProvider.fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
        }
      }
      
      // Note: Order book handles its own tab-specific subscriptions via changeTabIndex
      // No need to fetch data here as it's handled in _handleOrderBookTap

      // Get symbols that need subscription for this screen
      Set<String> symbolsToSubscribe = _getSymbolsForScreen(screenType, subscriptionType);

      if (symbolsToSubscribe.isEmpty) {
        print('⚠️  [WebSubscriptionManager] No symbols to subscribe for $screenType');
        log('WebSubscriptionManager: No symbols to subscribe for $screenType');
        return;
      }

      // Filter out symbols that are already subscribed
      final newSymbols = symbolsToSubscribe.where((symbol) =>
        !_currentWebSocketSubscriptions.contains(symbol)
      ).toSet();

      if (newSymbols.isEmpty) {
        print('ℹ️  [WebSubscriptionManager] All symbols for $screenType already subscribed');
        print('   Total symbols needed: ${symbolsToSubscribe.length}');
        print('   Already subscribed: ${symbolsToSubscribe.length}');
        print('   Total tracked symbols in WebSubscriptionManager: ${_currentWebSocketSubscriptions.length}');
        if (symbolsToSubscribe.length <= 10) {
          print('   Symbols: ${symbolsToSubscribe.join(", ")}');
        } else {
          print('   First 10 symbols: ${symbolsToSubscribe.take(10).join(", ")}...');
        }
        print('   ℹ️  Reason: These symbols were previously subscribed by WebSubscriptionManager');
        print('   ✅ Tracking these symbols for $screenType cleanup');
        print('═══════════════════════════════════════════════════════════\n');
        // Still track these symbols for this screen even if already subscribed
        // This ensures proper cleanup when screen is removed
        _screenSubscriptions[screenType] = symbolsToSubscribe;
        log('WebSubscriptionManager: All symbols for $screenType already subscribed');
        return;
      }

      print('✅ [WebSubscriptionManager] Subscribing to ${newSymbols.length} symbols for $screenType');
      print('   Total symbols needed: ${symbolsToSubscribe.length}');
      print('   New symbols: ${newSymbols.length}');
      print('   Already subscribed: ${symbolsToSubscribe.length - newSymbols.length}');
      if (newSymbols.length <= 10) {
        print('   Symbols: ${newSymbols.join(", ")}');
      } else {
        print('   First 10 symbols: ${newSymbols.take(10).join(", ")}...');
      }
      log('WebSubscriptionManager: Subscribing to ${newSymbols.length} new symbols for $screenType');

      // Subscribe via websocket provider (which handles the subscription manager integration)
      final wsProvider = ref.read(websocketProvider);
      final symbolString = newSymbols.join('#');

      // Use connectTouchLine which properly tracks subscriptions
      wsProvider.connectTouchLine(
        task: "t",
        input: symbolString,
        context: context,
      );

      // Track these symbols as subscribed
      _currentWebSocketSubscriptions.addAll(newSymbols);
      print('📝 [WebSubscriptionManager] Added ${newSymbols.length} symbols to tracking set');
      print('   Total tracked symbols now: ${_currentWebSocketSubscriptions.length}');

      // Store symbols per screen type for cleanup later
      _screenSubscriptions[screenType] = symbolsToSubscribe;

      print('✅ [WebSubscriptionManager] Successfully subscribed to $screenType');
      print('═══════════════════════════════════════════════════════════\n');

    } catch (e) {
      print('❌ [WebSubscriptionManager] ERROR subscribing to $screenType: $e');
      print('═══════════════════════════════════════════════════════════\n');
      log('WebSubscriptionManager: Error subscribing to $screenType: $e');
    }
  }

  /// Get symbols that need subscription for a screen type
  Set<String> _getSymbolsForScreen(ScreenType screenType, SubscriptionType subscriptionType) {
    Set<String> symbols = {};

    try {
      switch (subscriptionType) {
        case SubscriptionType.marketWatch:
          if (screenType == ScreenType.dashboard) {
            // Dashboard needs top indices and default indices, not watchlist
            final indexProvider = ref.read(indexListProvider);
            
            // Get top indices tokens (8 specific indices for dashboard)
            indexProvider.requestTopIndicesToken();
            final topIndicesToken = indexProvider.topIndicesToken;
            if (topIndicesToken.isNotEmpty) {
              // Parse tokens from string format "exch|token#exch|token#..."
              final tokens = topIndicesToken.split('#').where((t) => t.isNotEmpty && t.trim().isNotEmpty);
              symbols.addAll(tokens);
            }
            
            // Get default indices tokens (Nifty, Sensex, etc.)
            indexProvider.requestdefaultIndex();
            final defaultTokens = indexProvider.indexToken;
            if (defaultTokens.isNotEmpty) {
              // Parse tokens from string format "exch|token#exch|token#..."
              final tokens = defaultTokens.split('#').where((t) => t.isNotEmpty && t.trim().isNotEmpty);
              symbols.addAll(tokens);
            }
          } else if (screenType == ScreenType.tradeAction) {
            // Trade action needs all trade action stocks (all tabs combined)
            final stocksProvider = ref.read(stocksProvide);
            
            // Get all trade action stocks from all tabs
            final allTradeActionStocks = <String>{};
            
            // Top gainers
            for (var stock in stocksProvider.topGainers) {
              if (stock.exch != null && stock.token != null) {
                allTradeActionStocks.add('${stock.exch}|${stock.token}');
              }
            }
            
            // Top losers
            for (var stock in stocksProvider.topLosers) {
              if (stock.exch != null && stock.token != null) {
                allTradeActionStocks.add('${stock.exch}|${stock.token}');
              }
            }
            
            // Volume breakout
            for (var stock in stocksProvider.byVolume) {
              if (stock.exch != null && stock.token != null) {
                allTradeActionStocks.add('${stock.exch}|${stock.token}');
              }
            }
            
            // Most active
            for (var stock in stocksProvider.byValue) {
              if (stock.exch != null && stock.token != null) {
                allTradeActionStocks.add('${stock.exch}|${stock.token}');
              }
            }
            
            symbols.addAll(allTradeActionStocks);
          } else {
            // For watchlist and other marketWatch screens, use watchlist scrips
            final mwProvider = ref.read(marketWatchProvider);
            final watchlistScrips = mwProvider.marketWatchScrip?.values ?? [];
            for (var scrip in watchlistScrips) {
              if (scrip.exch != null && scrip.token != null) {
                symbols.add('${scrip.exch}|${scrip.token}');
              }
            }
          }
          break;

        case SubscriptionType.holdings:
          // Get symbols from holdings
          final portfolio = ref.read(portfolioProvider);
          final holdings = portfolio.holdingsModel ?? [];
          for (var holding in holdings) {
            // Holdings have exchTsym list containing the exchange and token
            final exchTsymList = holding.exchTsym ?? [];
            for (var exchTsym in exchTsymList) {
              if (exchTsym.exch != null && exchTsym.token != null) {
                symbols.add('${exchTsym.exch}|${exchTsym.token}');
              }
            }
          }
          break;

        case SubscriptionType.positions:
          // Get symbols from positions
          final portfolio = ref.read(portfolioProvider);
          final positions = portfolio.postionBookModel ?? [];
          for (var position in positions) {
            if (position.exch != null && position.token != null) {
              symbols.add('${position.exch}|${position.token}');
            }
          }
          break;

        case SubscriptionType.orderBook:
          // Order book handles its own tab-specific subscriptions via changeTabIndex
          // Return empty set as WebSubscriptionManager doesn't manage order book subscriptions
          break;

        case SubscriptionType.none:
          break;
      }
    } catch (e) {
      log('WebSubscriptionManager: Error getting symbols for $screenType: $e');
    }

    return symbols;
  }
  
  /// Unsubscribe from a screen's data
  Future<void> _unsubscribeFromScreen(ScreenType screenType) async {
    final context = _getValidContext();
    if (context == null) {
      log('WebSubscriptionManager: No valid context for unsubscription');
      return;
    }

    final subscriptionType = _screenSubscriptionTypes[screenType] ?? SubscriptionType.none;

    if (subscriptionType == SubscriptionType.none) {
      return; // Screen doesn't have subscriptions
    }

    print('═══════════════════════════════════════════════════════════');
    print('📱 [WebSubscriptionManager] UNSUBSCRIBING from screen: $screenType');
    print('   Subscription Type: $subscriptionType');
    print('═══════════════════════════════════════════════════════════');

    // Get symbols that were subscribed for this screen
    final screenSymbols = _screenSubscriptions[screenType];
    if (screenSymbols == null || screenSymbols.isEmpty) {
      print('⚠️  [WebSubscriptionManager] No symbols tracked for $screenType, skipping unsubscribe');
      print('═══════════════════════════════════════════════════════════\n');
      log('WebSubscriptionManager: No symbols tracked for $screenType, skipping unsubscribe');
      return;
    }

    // Check if any other active screen needs the same symbols
    final symbolsStillNeeded = <String>{};
    for (var entry in _activeScreens.entries) {
      final otherScreenType = entry.value;
      if (otherScreenType != null && otherScreenType != screenType) {
        final otherScreenSymbols = _screenSubscriptions[otherScreenType];
        if (otherScreenSymbols != null) {
          symbolsStillNeeded.addAll(otherScreenSymbols);
        }
      }
    }

    // Find symbols that can be unsubscribed (not needed by any other screen)
    final symbolsToUnsubscribe = screenSymbols.where((symbol) =>
      !symbolsStillNeeded.contains(symbol)
    ).toSet();

    if (symbolsToUnsubscribe.isEmpty) {
      print('ℹ️  [WebSubscriptionManager] All symbols for $screenType still needed by other screens');
      print('   Total symbols: ${screenSymbols.length}');
      print('   Still needed by: ${_activeScreens.values.where((s) => s != null && s != screenType).join(", ")}');
      print('═══════════════════════════════════════════════════════════\n');
      log('WebSubscriptionManager: All symbols for $screenType still needed by other screens');
      return;
    }

    print('✅ [WebSubscriptionManager] Unsubscribing from ${symbolsToUnsubscribe.length} symbols for $screenType');
    print('   Total symbols for screen: ${screenSymbols.length}');
    print('   Symbols to unsubscribe: ${symbolsToUnsubscribe.length}');
    print('   Symbols still needed: ${screenSymbols.length - symbolsToUnsubscribe.length}');
    if (symbolsToUnsubscribe.length <= 10) {
      print('   Symbols: ${symbolsToUnsubscribe.join(", ")}');
    } else {
      print('   First 10 symbols: ${symbolsToUnsubscribe.take(10).join(", ")}...');
    }
    log('WebSubscriptionManager: Unsubscribing from ${symbolsToUnsubscribe.length} symbols for $screenType');

    try {
      // Unsubscribe via websocket provider
      final wsProvider = ref.read(websocketProvider);
      final symbolString = symbolsToUnsubscribe.join('#');

      // Use connectTouchLine with unsubscribe task
      wsProvider.connectTouchLine(
        task: "u", // Unsubscribe task
        input: symbolString,
        context: context,
      );

      // Remove these symbols from our tracking
      _currentWebSocketSubscriptions.removeAll(symbolsToUnsubscribe);
      print('📝 [WebSubscriptionManager] Removed ${symbolsToUnsubscribe.length} symbols from tracking set');
      print('   Total tracked symbols now: ${_currentWebSocketSubscriptions.length}');

      // Clear the screen's subscription record
      _screenSubscriptions.remove(screenType);

      print('✅ [WebSubscriptionManager] Successfully unsubscribed from $screenType');
      print('═══════════════════════════════════════════════════════════\n');
      log('WebSubscriptionManager: Successfully unsubscribed from $screenType');
    } catch (e) {
      print('❌ [WebSubscriptionManager] ERROR unsubscribing from $screenType: $e');
      print('═══════════════════════════════════════════════════════════\n');
      log('WebSubscriptionManager: Error unsubscribing from $screenType: $e');
    }
  }
  
  /// Update context for future use
  void updateContext(BuildContext context) {
    _lastValidContext = context;
    _lastContextUpdate = DateTime.now();
    log('WebSubscriptionManager: Context updated');
  }
  
  /// Get a valid context
  BuildContext? _getValidContext() {
    // If we have a recent context (less than 30 minutes old), use it
    if (_lastValidContext != null && _lastContextUpdate != null) {
      final contextAge = DateTime.now().difference(_lastContextUpdate!);
      if (contextAge < const Duration(minutes: 30)) {
        try {
          if (_lastValidContext!.mounted) {
            return _lastValidContext;
          }
        } catch (e) {
          log('WebSubscriptionManager: Recent context is no longer valid: $e');
        }
      }
    }
    
    // Note: NetworkStateProvider doesn't expose context publicly
    // We'll rely on the lastValidContext we already have
    return null;
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final previousState = _currentState;
    _currentState = state;
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _handleAppGoingToBackground();
        break;
        
      case AppLifecycleState.resumed:
        _handleAppResumed(previousState);
        break;
        
      case AppLifecycleState.inactive:
        break;
    }
  }
  
  void _handleAppGoingToBackground() {
    _lastPauseTime = DateTime.now();
    log('WebSubscriptionManager: App going to background');
    
    final wsProvider = ref.read(websocketProvider);
    _wasDisconnectedInBackground = !wsProvider.wsConnected;
  }
  
  void _handleAppResumed(AppLifecycleState previousState) {
    log('WebSubscriptionManager: App resumed from $previousState');
    
    // Check if we need to reconnect
    if (_shouldReconnect()) {
      log('WebSubscriptionManager: Reconnection needed, restoring subscriptions');
      _restoreActiveSubscriptions();
    } else {
      log('WebSubscriptionManager: WebSocket still connected, no reconnection needed');
    }
  }
  
  void _handleNetworkChange(ConnectivityResult result) {
    log('WebSubscriptionManager: Network changed from $_lastNetworkStatus to $result');
    
    final wasConnected = _lastNetworkStatus != ConnectivityResult.none;
    final isNowConnected = result != ConnectivityResult.none;
    
    _lastNetworkStatus = result;
    
    // If network came back online and we have active screens, restore subscriptions
    if (!wasConnected && isNowConnected && _activeScreens.isNotEmpty) {
      if (_isUserLoggedIn()) {
        log('WebSubscriptionManager: Network restored, restoring subscriptions');
        _restoreActiveSubscriptions();
      }
    }
  }
  
  bool _shouldReconnect() {
    if (!_isUserLoggedIn()) {
      return false;
    }
    
    final wsProvider = ref.read(websocketProvider);
    
    // Reconnect if websocket is disconnected and we have active screens
    if (!wsProvider.wsConnected && _activeScreens.isNotEmpty) {
      return true;
    }
    
    // If websocket was disconnected when we went to background
    if (_wasDisconnectedInBackground && _activeScreens.isNotEmpty) {
      return true;
    }
    
    return false;
  }
  
  /// Restore subscriptions for all active screens
  Future<void> _restoreActiveSubscriptions() async {
    if (!_isUserLoggedIn()) {
      log('WebSubscriptionManager: Session invalid, aborting restoration');
      return;
    }

    if (_activeScreens.isEmpty) {
      log('WebSubscriptionManager: No active screens to restore');
      return;
    }

    final context = _getValidContext();
    if (context == null) {
      log('WebSubscriptionManager: No valid context for restoration');
      return;
    }

    log('WebSubscriptionManager: Restoring subscriptions for ${_activeScreens.length} active screens');

    // Clear current tracking since we're doing a full restore
    _currentWebSocketSubscriptions.clear();
    _screenSubscriptions.clear();

    // Restore subscriptions for each active screen
    for (final screenType in _activeScreens.values) {
      if (screenType != null) {
        await _subscribeToScreen(screenType);
      }
    }
  }
  
  /// Check if user is logged in with valid session
  bool _isUserLoggedIn() {
    try {
      final Preferences pref = locator<Preferences>();
      
      final clientSession = pref.clientSession;
      final clientId = pref.clientId;
      final sessCheckValid = ConstantName.sessCheck;
      
      final isLoggedIn = (clientSession?.isNotEmpty ?? false) && 
                        (clientId?.isNotEmpty ?? false) && 
                        sessCheckValid;
      
      if (!isLoggedIn) {
        log('WebSubscriptionManager: User session invalid - clearing active screens');
        _activeScreens.clear();
      }
      
      return isLoggedIn;
    } catch (e) {
      log('WebSubscriptionManager: Error checking user session: $e');
      return false;
    }
  }
  
  /// Clear all active screens and subscriptions
  void clearAll() {
    log('WebSubscriptionManager: Clearing all active screens');

    final context = _getValidContext();
    if (context != null) {
      // Unsubscribe all tracked websocket subscriptions
      if (_currentWebSocketSubscriptions.isNotEmpty) {
        try {
          final wsProvider = ref.read(websocketProvider);
          final symbolString = _currentWebSocketSubscriptions.join('#');

          log('WebSubscriptionManager: Unsubscribing from ${_currentWebSocketSubscriptions.length} symbols');

          wsProvider.connectTouchLine(
            task: "u",
            input: symbolString,
            context: context,
          );
        } catch (e) {
          log('WebSubscriptionManager: Error during clearAll unsubscribe: $e');
        }
      }
    }

    _activeScreens.clear();
    _screenSubscriptions.clear();
    _currentWebSocketSubscriptions.clear();
    notifyListeners();
  }
  
  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'activeScreens': _activeScreens.map((k, v) => MapEntry(k.toString(), v?.toString())),
      'screenSubscriptions': _screenSubscriptions.map((k, v) => MapEntry(k.toString(), v.length.toString())),
      'currentWebSocketSubscriptions': _currentWebSocketSubscriptions.length,
      'websocketSymbols': _currentWebSocketSubscriptions.toList(),
      'currentState': _currentState.toString(),
      'lastPauseTime': _lastPauseTime?.toIso8601String(),
      'wasDisconnectedInBackground': _wasDisconnectedInBackground,
      'lastNetworkStatus': _lastNetworkStatus.toString(),
    };
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    _activeScreens.clear();
    _screenSubscriptions.clear();
    _currentWebSocketSubscriptions.clear();
    super.dispose();
  }
}

/// Subscription types that different screens need
enum SubscriptionType {
  none,
  marketWatch,
  holdings,
  positions,
  orderBook,
}

/// Provider for WebSubscriptionManager
final webSubscriptionManagerProvider = ChangeNotifierProvider<WebSubscriptionManager>((ref) {
  return WebSubscriptionManager(ref);
});

