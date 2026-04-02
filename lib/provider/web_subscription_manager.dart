import 'dart:async';
import 'dart:developer';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'websocket_provider.dart';
import 'market_watch_provider.dart';
import 'portfolio_provider.dart';
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

  // MASTER LIST: Track ALL subscribed symbols (used for reconnection)
  // This persists across screen changes and is used to resend all subscriptions on reconnect
  final Set<String> _activeSubscriptions = <String>{};

  // TICKER SUBSCRIPTIONS: Persistent subscriptions for ticker header (positions)
  // These symbols are NEVER unsubscribed while user is logged in, ensuring ticker always updates
  final Set<String> _tickerSubscriptions = <String>{};

  // Track which screens need which subscription types
  Map<ScreenType, SubscriptionType> _screenSubscriptionTypes = {};
  
  // App lifecycle tracking
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  DateTime? _lastPauseTime;
  bool _wasDisconnectedInBackground = false;

  // Browser tab visibility tracking
  DateTime? _tabHiddenTime;
  // How long the tab must be hidden before we force-reconnect on return
  static const Duration _staleConnectionThreshold = Duration(seconds: 5);
  
  // Network tracking
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  ConnectivityResult _lastNetworkStatus = ConnectivityResult.mobile;

  // WebSocket state tracking for reconnection
  bool _lastKnownWsConnected = false;
  VoidCallback? _wsProviderListener;
  
  // Context management
  BuildContext? _lastValidContext;
  DateTime? _lastContextUpdate;
  
  // Getters
  Map<int, ScreenType?> get activeScreens => Map.from(_activeScreens);
  Map<ScreenType, Set<String>> get screenSubscriptions => Map.from(_screenSubscriptions);
  AppLifecycleState get currentState => _currentState;

  // Master subscription list getters (like mobile)
  Set<String> get activeSubscriptions => Set.from(_activeSubscriptions);
  int get subscriptionCount => _activeSubscriptions.length;
  bool get hasActiveSubscriptions => _activeSubscriptions.isNotEmpty;

  // Ticker subscription getters
  Set<String> get tickerSubscriptions => Set.from(_tickerSubscriptions);
  int get tickerSubscriptionCount => _tickerSubscriptions.length;
  bool get hasTickerSubscriptions => _tickerSubscriptions.isNotEmpty;
  
  void _init() {
    // Initialize subscription types for each screen
    _initializeSubscriptionTypes();

    // Listen to browser tab visibility changes
    // This is CRITICAL for web: Flutter's AppLifecycleState does NOT reliably fire
    // on browser tab switches. Without this, the app won't know when to reconnect
    // after the user switches tabs and comes back.
    html.document.addEventListener('visibilitychange', _onBrowserVisibilityChange);

    // Listen to network changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      // connectivity_plus 7.0.0 returns List<ConnectivityResult>
      // Take the first result or check if any connection is available
      final result = results.isNotEmpty
          ? (results.contains(ConnectivityResult.none)
              ? ConnectivityResult.none
              : results.first)
          : ConnectivityResult.none;
      _handleNetworkChange(result);
    });

    // Listen to websocket connection state changes
    // This ensures subscriptions are restored after websocket reconnects (e.g., after page refresh)
    _setupWebSocketListener();
  }

  /// Handle browser tab visibility changes (visibilitychange event)
  /// This fires reliably on tab switch, unlike Flutter's AppLifecycleState on web
  void _onBrowserVisibilityChange(html.Event event) {
    final isVisible = html.document.visibilityState == 'visible';

    if (!isVisible) {
      // Tab is being hidden - record the time
      _tabHiddenTime = DateTime.now();
      log('WebSubscriptionManager: Browser tab hidden');
      print('🔇 [WebSubscriptionManager] Browser tab hidden');
      return;
    }

    // Tab is becoming visible again
    log('WebSubscriptionManager: Browser tab visible again');
    print('🔊 [WebSubscriptionManager] Browser tab visible again');

    if (!_isUserLoggedIn()) return;

    final wasHiddenFor = _tabHiddenTime != null
        ? DateTime.now().difference(_tabHiddenTime!)
        : Duration.zero;

    print('   Was hidden for: ${wasHiddenFor.inSeconds}s');
    print('   Active subscriptions in master list: ${_activeSubscriptions.length}');

    _tabHiddenTime = null;

    // If tab was hidden long enough for the connection to go stale, force full restore
    if (wasHiddenFor >= _staleConnectionThreshold) {
      print('🔄 [WebSubscriptionManager] Tab was hidden for ${wasHiddenFor.inSeconds}s (>= ${_staleConnectionThreshold.inSeconds}s threshold)');
      print('   Forcing WebSocket reconnect and full re-subscription...');
      log('WebSubscriptionManager: Forcing reconnect after tab was hidden for ${wasHiddenFor.inSeconds}s');

      _forceReconnectAndResubscribe();
    } else {
      // Short switch - just verify connection is alive and data is flowing
      final wsProvider = ref.read(websocketProvider);
      if (!wsProvider.wsConnected) {
        print('⚠️ [WebSubscriptionManager] WebSocket disconnected during short tab switch, reconnecting...');
        _forceReconnectAndResubscribe();
      } else {
        print('✅ [WebSubscriptionManager] WebSocket still connected after short tab switch');
      }
    }
  }

  /// Force close the WebSocket, reconnect, and re-subscribe only what's currently needed.
  /// Rebuilds the master list from active screens + ticker to avoid accumulating stale symbols.
  /// This ensures every visible screen gets fresh data after returning from a background tab.
  void _forceReconnectAndResubscribe() {
    if (!_isUserLoggedIn()) return;

    final wsProvider = ref.read(websocketProvider);
    final context = _getValidContext();

    // Rebuild the master list from what's actually needed right now
    // instead of using the accumulated list which may have stale symbols
    final freshSymbols = _rebuildActiveSymbols();

    print('═══════════════════════════════════════════════════════════');
    print('🔄 [WebSubscriptionManager] FORCE RECONNECT AFTER TAB SWITCH');
    print('   Old master list: ${_activeSubscriptions.length} symbols');
    print('   Rebuilt fresh list: ${freshSymbols.length} symbols');
    print('   Ticker subscriptions: ${_tickerSubscriptions.length}');
    print('   Active screens: ${_activeScreens.length}');
    print('═══════════════════════════════════════════════════════════');

    // Replace master list with only what's currently needed
    _activeSubscriptions.clear();
    _activeSubscriptions.addAll(freshSymbols);

    // Clear deduplication and per-screen tracking so everything gets re-sent
    _currentWebSocketSubscriptions.clear();
    _screenSubscriptions.clear();

    // Force close the existing connection (it may be stale/zombie)
    wsProvider.closeSocket(true);

    // Give it a moment to clean up, then reconnect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isUserLoggedIn()) return;

      final stillConnected = ref.read(websocketProvider).wsConnected;
      if (stillConnected) {
        // Already reconnected (fast reconnect) - just re-send subscriptions
        print('⚡ [WebSubscriptionManager] Already reconnected, sending subscriptions from master list');
        _sendAllSubscriptionsFromMasterList();
      } else if (context != null) {
        // Need to reconnect - the _handleWebSocketStateChange listener will
        // pick up the reconnection and call _sendAllSubscriptionsFromMasterList
        // because _activeSubscriptions (master list) is not empty
        print('🔌 [WebSubscriptionManager] Triggering reconnection...');
        ref.read(websocketProvider).reconnect(context);
      } else {
        print('⚠️ [WebSubscriptionManager] No valid context for reconnection');
      }

      print('═══════════════════════════════════════════════════════════\n');
    });
  }

  /// Rebuild the set of symbols actually needed right now from active screens + ticker.
  /// This prevents stale symbols from accumulating in the master list over time.
  Set<String> _rebuildActiveSymbols() {
    final symbols = <String>{};

    // 1. Gather symbols from all currently active screens
    for (final screenType in _activeScreens.values) {
      if (screenType == null) continue;
      final subType = _screenSubscriptionTypes[screenType] ?? SubscriptionType.none;
      if (subType == SubscriptionType.none) continue;

      try {
        final screenSymbols = _getSymbolsForScreen(screenType, subType);
        symbols.addAll(screenSymbols);
      } catch (e) {
        log('WebSubscriptionManager: Error getting symbols for $screenType during rebuild: $e');
      }
    }

    // 2. Always include ticker subscriptions (positions in header - must always be live)
    symbols.addAll(_tickerSubscriptions);

    return symbols;
  }

  /// Set up listener for websocket connection state changes
  void _setupWebSocketListener() {
    try {
      final wsProvider = ref.read(websocketProvider);
      _lastKnownWsConnected = wsProvider.wsConnected;

      _wsProviderListener = () {
        _handleWebSocketStateChange();
      };

      wsProvider.addListener(_wsProviderListener!);
      log('WebSubscriptionManager: WebSocket listener set up');
    } catch (e) {
      log('WebSubscriptionManager: Error setting up websocket listener: $e');
    }
  }

  // Track if this is the first WebSocket connection (initial page load)
  bool _isInitialConnection = true;

  // Pending subscription queue - subscriptions waiting for WebSocket to be ready
  final List<_PendingSubscription> _pendingSubscriptionQueue = [];
  Timer? _retryTimer;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  /// Handle websocket connection state changes
  void _handleWebSocketStateChange() {
    try {
      final wsProvider = ref.read(websocketProvider);
      final isNowConnected = wsProvider.wsConnected;

      // Check if socket just connected (was disconnected, now connected)
      if (!_lastKnownWsConnected && isNowConnected) {
        log('WebSubscriptionManager: WebSocket connected');
        print('🔄 [WebSubscriptionManager] WebSocket connected');
        print('   Active subscriptions in master list: ${_activeSubscriptions.length}');
        print('   Pending queue size: ${_pendingSubscriptionQueue.length}');
        print('   Is initial connection: $_isInitialConnection');

        // Clear deduplication tracking (NOT the master list!)
        _currentWebSocketSubscriptions.clear();

        // Process any pending subscriptions first
        if (_pendingSubscriptionQueue.isNotEmpty) {
          print('📤 [WebSubscriptionManager] Processing ${_pendingSubscriptionQueue.length} pending subscriptions');
          _processPendingSubscriptions();
        }

        // Check if we have subscriptions to restore from master list
        if (_activeSubscriptions.isNotEmpty && _isUserLoggedIn()) {
          print('📤 [WebSubscriptionManager] Restoring ${_activeSubscriptions.length} subscriptions from master list');

          // Minimal delay to let connection stabilize, then restore
          Future.delayed(const Duration(milliseconds: 100), () {
            // Double-check socket is still connected before restoring
            final stillConnected = ref.read(websocketProvider).wsConnected;
            if (stillConnected) {
              _sendAllSubscriptionsFromMasterList();
            } else {
              log('WebSubscriptionManager: Socket disconnected before restore, skipping');
            }
          });
        } else if (_activeScreens.isNotEmpty && _isUserLoggedIn()) {
          // No master list but have active screens
          if (_isInitialConnection) {
            // INITIAL LOAD: Don't try to restore immediately - data hasn't been fetched yet
            // Screen handlers (e.g., _handleDashboardTap) will call _updateSubscriptionManagerForPanels
            // after fetching data, which will properly subscribe with the fetched data.
            print('⏳ [WebSubscriptionManager] Initial load - waiting for screen handlers to fetch data and subscribe');
            log('WebSubscriptionManager: Initial connection - skipping immediate restore, screen handlers will subscribe after data fetch');

            // Mark initial connection as complete
            _isInitialConnection = false;
          } else {
            // RECONNECTION: Try to restore via screen-based method with longer delay
            // to give time for any pending data refreshes
            print('📤 [WebSubscriptionManager] Reconnection - restoring via active screens');
            Future.delayed(const Duration(milliseconds: 500), () {
              final stillConnected = ref.read(websocketProvider).wsConnected;
              if (stillConnected) {
                _restoreActiveSubscriptions();
              }
            });
          }
        } else if (_isUserLoggedIn()) {
          // No subscriptions yet - screens will register and subscribe later
          log('WebSubscriptionManager: No subscriptions to restore, waiting for screens to register');
          _isInitialConnection = false;
        }
      }

      _lastKnownWsConnected = isNowConnected;
    } catch (e) {
      log('WebSubscriptionManager: Error handling websocket state change: $e');
    }
  }

  /// Check and reconnect WebSocket if disconnected
  /// Call this when navigating to a new page to ensure connection is active
  Future<void> ensureConnected(BuildContext context) async {
    if (!_isUserLoggedIn()) return;

    try {
      final wsProvider = ref.read(websocketProvider);

      if (!wsProvider.wsConnected) {
        print('🔌 [WebSubscriptionManager] WebSocket disconnected, triggering reconnection');
        log('WebSubscriptionManager: Triggering reconnection');

        // Update context for future use
        updateContext(context);

        // Trigger reconnection
        wsProvider.reconnect(context);
      } else {
        // Socket is connected - check if we have subscriptions that need to be sent
        if (_activeSubscriptions.isNotEmpty && _currentWebSocketSubscriptions.isEmpty) {
          print('📤 [WebSubscriptionManager] Socket connected but no subscriptions sent, restoring...');
          log('WebSubscriptionManager: Restoring subscriptions after connection check');
          _sendAllSubscriptionsFromMasterList();
        }
      }
    } catch (e) {
      print('❌ [WebSubscriptionManager] Error in ensureConnected: $e');
      log('WebSubscriptionManager: Error in ensureConnected: $e');
    }
  }

  /// Force reconnection and resubscription
  /// Use this when WebSocket seems stuck and not receiving data
  Future<void> forceReconnect(BuildContext context) async {
    if (!_isUserLoggedIn()) return;

    print('═══════════════════════════════════════════════════════════');
    print('🔄 [WebSubscriptionManager] FORCE RECONNECT');
    print('   Active screens: ${_activeScreens.length}');
    print('   Master list subscriptions: ${_activeSubscriptions.length}');
    print('═══════════════════════════════════════════════════════════');

    try {
      final wsProvider = ref.read(websocketProvider);

      // Close existing connection
      wsProvider.closeSocket(true);

      // Clear local tracking (but NOT the master list - we need it for restoration)
      _currentWebSocketSubscriptions.clear();

      // Wait a moment for cleanup
      await Future.delayed(const Duration(milliseconds: 300));

      // Update context
      updateContext(context);

      // Reconnect
      wsProvider.reconnect(context);

      print('✅ [WebSubscriptionManager] Force reconnect initiated');
      print('═══════════════════════════════════════════════════════════\n');
    } catch (e) {
      print('❌ [WebSubscriptionManager] Error in forceReconnect: $e');
      log('WebSubscriptionManager: Error in forceReconnect: $e');
    }
  }

  /// Check if WebSocket is ready for subscriptions
  bool _isWebSocketReady() {
    try {
      final wsProvider = ref.read(websocketProvider);
      return wsProvider.wsConnected;
    } catch (e) {
      return false;
    }
  }

  /// Queue a subscription for later if WebSocket isn't ready
  void _queueSubscription(ScreenType screenType, Set<String> symbols, int retryCount) {
    // Remove any existing pending subscription for this screen
    _pendingSubscriptionQueue.removeWhere((p) => p.screenType == screenType);

    _pendingSubscriptionQueue.add(_PendingSubscription(
      screenType: screenType,
      symbols: symbols,
      retryCount: retryCount,
      timestamp: DateTime.now(),
    ));

    print('📋 [WebSubscriptionManager] Queued subscription for $screenType (${symbols.length} symbols, retry $retryCount)');

    // Start retry timer if not already running
    _startRetryTimer();
  }

  /// Start retry timer to process pending subscriptions
  void _startRetryTimer() {
    if (_retryTimer?.isActive == true) return;

    _retryTimer = Timer.periodic(_retryDelay, (_) {
      if (_pendingSubscriptionQueue.isEmpty) {
        _retryTimer?.cancel();
        _retryTimer = null;
        return;
      }

      if (_isWebSocketReady()) {
        _processPendingSubscriptions();
      }
    });
  }

  /// Process all pending subscriptions
  void _processPendingSubscriptions() {
    if (_pendingSubscriptionQueue.isEmpty) return;

    final toProcess = List<_PendingSubscription>.from(_pendingSubscriptionQueue);
    _pendingSubscriptionQueue.clear();

    for (final pending in toProcess) {
      if (pending.retryCount >= _maxRetries) {
        print('⚠️ [WebSubscriptionManager] Max retries reached for ${pending.screenType}, dropping');
        continue;
      }

      // Try to subscribe
      _subscribeToScreenWithSymbols(pending.screenType, pending.symbols, pending.retryCount + 1);
    }
  }

  /// Subscribe to a screen with specific symbols (used for retry)
  Future<void> _subscribeToScreenWithSymbols(ScreenType screenType, Set<String> symbols, int retryCount) async {
    if (!_isUserLoggedIn()) return;

    // Check WebSocket readiness
    if (!_isWebSocketReady()) {
      print('⏳ [WebSubscriptionManager] WebSocket not ready, queueing ${screenType} subscription (retry $retryCount)');
      _queueSubscription(screenType, symbols, retryCount);
      return;
    }

    final context = _getValidContext();
    if (context == null) {
      log('WebSubscriptionManager: No valid context for subscription');
      // Queue for retry with context
      _queueSubscription(screenType, symbols, retryCount);
      return;
    }

    if (symbols.isEmpty) {
      print('⚠️ [WebSubscriptionManager] No symbols to subscribe for $screenType');
      return;
    }

    // Filter out already subscribed symbols
    final newSymbols = symbols.where((s) => !_currentWebSocketSubscriptions.contains(s)).toSet();

    if (newSymbols.isEmpty) {
      print('ℹ️ [WebSubscriptionManager] All symbols for $screenType already subscribed');
      _screenSubscriptions[screenType] = symbols;
      return;
    }

    print('✅ [WebSubscriptionManager] Subscribing ${newSymbols.length} symbols for $screenType (retry $retryCount)');

    try {
      final wsProvider = ref.read(websocketProvider);
      final symbolString = newSymbols.join('#');

      wsProvider.connectTouchLine(
        task: "d",
        input: symbolString,
        context: context,
      );

      _currentWebSocketSubscriptions.addAll(newSymbols);
      _activeSubscriptions.addAll(newSymbols);
      _screenSubscriptions[screenType] = symbols;

      print('✅ [WebSubscriptionManager] Successfully subscribed to $screenType');
    } catch (e) {
      print('❌ [WebSubscriptionManager] Error subscribing to $screenType: $e');
      // Queue for retry
      if (retryCount < _maxRetries) {
        _queueSubscription(screenType, symbols, retryCount);
      }
    }
  }

  /// Send ALL subscriptions from master list directly to websocket
  /// This is used on reconnection to restore all subscriptions at once
  void _sendAllSubscriptionsFromMasterList() {
    if (_activeSubscriptions.isEmpty) {
      log('WebSubscriptionManager: No subscriptions in master list to send');
      return;
    }

    final context = _getValidContext();
    if (context == null) {
      log('WebSubscriptionManager: No valid context for sending subscriptions');
      return;
    }

    print('═══════════════════════════════════════════════════════════');
    print('📤 [WebSubscriptionManager] SENDING ALL SUBSCRIPTIONS FROM MASTER LIST');
    print('   Total symbols: ${_activeSubscriptions.length}');
    print('═══════════════════════════════════════════════════════════');

    try {
      final wsProvider = ref.read(websocketProvider);

      // Send subscriptions in batches of 50 to avoid overwhelming the server
      final subscriptionList = _activeSubscriptions.toList();
      const batchSize = 50;
      int totalBatches = (subscriptionList.length / batchSize).ceil();

      log('WebSubscriptionManager: Sending $totalBatches batches of up to $batchSize symbols each');

      for (int i = 0; i < subscriptionList.length; i += batchSize) {
        final endIndex = (i + batchSize < subscriptionList.length)
            ? i + batchSize
            : subscriptionList.length;

        final batch = subscriptionList.sublist(i, endIndex);
        final batchString = batch.join('#');
        final batchNum = (i ~/ batchSize) + 1;

        print('📦 [WebSubscriptionManager] Sending batch $batchNum/$totalBatches (${batch.length} symbols)');

        // Send directly via websocket - using depth subscription for web
        wsProvider.connectTouchLine(
          task: "d",
          input: batchString,
          context: context,
        );

        // Track as currently subscribed
        _currentWebSocketSubscriptions.addAll(batch);
      }

      print('✅ [WebSubscriptionManager] All ${_activeSubscriptions.length} subscriptions sent');
      print('═══════════════════════════════════════════════════════════\n');

    } catch (e) {
      print('❌ [WebSubscriptionManager] Error sending subscriptions: $e');
      log('WebSubscriptionManager: Error sending subscriptions from master list: $e');
    }
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
      // scripDepthInfo handles its own subscription via setIsDepthVisibleWeb
      // Setting to none prevents unsubscribing other panels' symbols when depth opens
      ScreenType.scripDepthInfo: SubscriptionType.none,
      ScreenType.optionChain: SubscriptionType.marketWatch,
      ScreenType.pledgeUnpledge: SubscriptionType.none,
      ScreenType.corporateActions: SubscriptionType.none,
      ScreenType.reports: SubscriptionType.none,
      ScreenType.settings: SubscriptionType.none,
      ScreenType.tradeAction: SubscriptionType.marketWatch,
    };
  }
  
  // Debounce timers to prevent rapid screen updates - ONE PER PANEL
  // Using a Map ensures each panel's subscription is processed independently
  // This fixes the bug where only the last panel's subscription was processed
  final Map<int, Timer> _updateDebounceTimers = {};
  // Track pending screen changes so we can complete them if needed
  final Map<int, _PendingScreenChange> _pendingScreenChanges = {};
  static const Duration _updateDebounceDelay = Duration(milliseconds: 300);

  /// Update active screen for a panel (with debouncing to prevent rapid calls)
  void updateActiveScreen(int panelIndex, ScreenType? screenType) {
    final previousScreen = _activeScreens[panelIndex];

    // Early return if no actual change
    if (previousScreen == screenType) {
      return; // No change - skip unnecessary processing
    }

    // Cancel any pending debounce timer FOR THIS PANEL ONLY
    _updateDebounceTimers[panelIndex]?.cancel();

    // Track the pending screen change so we can complete it if needed
    _pendingScreenChanges[panelIndex] = _PendingScreenChange(
      panelIndex: panelIndex,
      previousScreen: previousScreen,
      newScreen: screenType,
    );

    // Debounce the update for this specific panel
    _updateDebounceTimers[panelIndex] = Timer(_updateDebounceDelay, () {
      _pendingScreenChanges.remove(panelIndex);
      _performScreenUpdate(panelIndex, previousScreen, screenType);
      // Clean up timer reference after execution
      _updateDebounceTimers.remove(panelIndex);
    });
  }

  /// Refresh subscriptions for the current screen (when data becomes available after initial load)
  /// This bypasses the "no change" check and re-subscribes with fresh data
  void refreshCurrentScreen(int panelIndex, ScreenType? screenType) {
    if (screenType == null) return;

    print('\n🔄 [WebSubscriptionManager] Refreshing panel $panelIndex subscriptions for: $screenType');
    log('WebSubscriptionManager: Refreshing subscriptions for $screenType');

    // Re-subscribe to get fresh symbols (data may have been fetched since initial load)
    _subscribeToScreen(screenType);
  }

  /// Actually perform the screen update (called after debounce)
  void _performScreenUpdate(int panelIndex, ScreenType? previousScreen, ScreenType? screenType) {
    print('\n🔄 [WebSubscriptionManager] Panel $panelIndex screen change:');
    print('   From: ${previousScreen ?? "none"}');
    print('   To: ${screenType ?? "none"}');
    log('WebSubscriptionManager: Panel $panelIndex screen changed from $previousScreen to $screenType');

    // CRITICAL FIX: Before unsubscribing, complete ALL pending subscription timers
    // This ensures _screenSubscriptions is fully populated for all panels
    // Without this, the unsubscribe check may think no other panel needs the symbols
    _completePendingSubscriptionTimers(excludePanelIndex: panelIndex);

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

  /// Complete all pending subscription timers immediately (except for the excluded panel)
  /// This ensures _screenSubscriptions is fully populated before any unsubscription logic runs
  void _completePendingSubscriptionTimers({int? excludePanelIndex}) {
    final pendingPanels = _pendingScreenChanges.keys.toList();

    for (final panelIdx in pendingPanels) {
      if (panelIdx == excludePanelIndex) continue; // Skip the panel being changed

      final pending = _pendingScreenChanges[panelIdx];
      final timer = _updateDebounceTimers[panelIdx];

      if (pending != null && timer != null && timer.isActive) {
        timer.cancel();

        // For initial subscriptions (previousScreen is null), we just need to subscribe
        // For screen changes, we'd do the full update - but during initial load,
        // previousScreen is typically null, so we just subscribe the new screen
        final screenToSubscribe = pending.newScreen;
        if (screenToSubscribe != null && !_screenSubscriptions.containsKey(screenToSubscribe)) {
          print('⚡ [WebSubscriptionManager] Fast-tracking subscription for panel $panelIdx: $screenToSubscribe');
          _activeScreens[panelIdx] = screenToSubscribe;
          _subscribeToScreen(screenToSubscribe);
        }
      }

      _updateDebounceTimers.remove(panelIdx);
      _pendingScreenChanges.remove(panelIdx);
    }
  }
  
  /// Subscribe to a screen's data
  Future<void> _subscribeToScreen(ScreenType screenType) async {
    if (!_isUserLoggedIn()) {
      log('WebSubscriptionManager: Not subscribing - user not logged in');
      return;
    }

    final subscriptionType = _screenSubscriptionTypes[screenType] ?? SubscriptionType.none;

    if (subscriptionType == SubscriptionType.none) {
      return; // Screen doesn't need subscriptions
    }

    // Check WebSocket readiness BEFORE getting symbols
    if (!_isWebSocketReady()) {
      print('⏳ [WebSubscriptionManager] WebSocket not ready for $screenType, will retry when connected');
      // Queue empty set - will be filled when retry happens
      _queueSubscription(screenType, {}, 0);
      return;
    }

    final context = _getValidContext();
    if (context == null) {
      log('WebSubscriptionManager: No valid context for subscription');
      return;
    }

    print('═══════════════════════════════════════════════════════════');
    print('📱 [WebSubscriptionManager] SUBSCRIBING to screen: $screenType');
    print('   Subscription Type: $subscriptionType');
    print('   WebSocket ready: ${_isWebSocketReady()}');
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

      // Final WebSocket check before sending
      if (!_isWebSocketReady()) {
        print('⏳ [WebSubscriptionManager] WebSocket disconnected before sending, queueing $screenType');
        _queueSubscription(screenType, symbolsToSubscribe, 0);
        return;
      }

      // Subscribe via websocket provider (which handles the subscription manager integration)
      final wsProvider = ref.read(websocketProvider);
      final symbolString = newSymbols.join('#');

      // Use connectTouchLine which properly tracks subscriptions - using depth for web
      wsProvider.connectTouchLine(
        task: "d",
        input: symbolString,
        context: context,
      );

      // Track these symbols as subscribed (for deduplication)
      _currentWebSocketSubscriptions.addAll(newSymbols);

      // ADD TO MASTER LIST (for reconnection)
      _activeSubscriptions.addAll(newSymbols);

      print('📝 [WebSubscriptionManager] Added ${newSymbols.length} symbols to tracking');
      print('   Current subscriptions: ${_currentWebSocketSubscriptions.length}');
      print('   Master list total: ${_activeSubscriptions.length}');

      // Store symbols per screen type for cleanup later
      _screenSubscriptions[screenType] = symbolsToSubscribe;

      print('✅ [WebSubscriptionManager] Successfully subscribed to $screenType');
      print('═══════════════════════════════════════════════════════════\n');

    } catch (e) {
      print('❌ [WebSubscriptionManager] ERROR subscribing to $screenType: $e');
      print('═══════════════════════════════════════════════════════════\n');
      log('WebSubscriptionManager: Error subscribing to $screenType: $e');
      // Queue for retry on error
      final symbols = _getSymbolsForScreen(screenType, _screenSubscriptionTypes[screenType] ?? SubscriptionType.none);
      if (symbols.isNotEmpty) {
        _queueSubscription(screenType, symbols, 0);
      }
    }
  }

  /// Get symbols that need subscription for a screen type
  Set<String> _getSymbolsForScreen(ScreenType screenType, SubscriptionType subscriptionType) {
    Set<String> symbols = {};

    try {
      switch (subscriptionType) {
        case SubscriptionType.marketWatch:
          if (screenType == ScreenType.dashboard) {
            // Dashboard needs top indices, default indices, and trade action stocks
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

            // Add trade action stocks for "Today's trade action" section
            final stocksProvider = ref.read(stocksProvide);

            // Top gainers (first 5 shown in dashboard)
            for (var stock in stocksProvider.topGainers.take(5)) {
              if (stock.exch != null && stock.token != null) {
                symbols.add('${stock.exch}|${stock.token}');
              }
            }

            // Top losers (first 5 shown in dashboard)
            for (var stock in stocksProvider.topLosers.take(5)) {
              if (stock.exch != null && stock.token != null) {
                symbols.add('${stock.exch}|${stock.token}');
              }
            }

            // Volume breakout (first 5 shown in dashboard)
            for (var stock in stocksProvider.byVolume.take(5)) {
              if (stock.exch != null && stock.token != null) {
                symbols.add('${stock.exch}|${stock.token}');
              }
            }

            // Most active (first 5 shown in dashboard)
            for (var stock in stocksProvider.byValue.take(5)) {
              if (stock.exch != null && stock.token != null) {
                symbols.add('${stock.exch}|${stock.token}');
              }
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

  /// Get current watchlist symbols (symbols visible in watchlist panel)
  Set<String> _getWatchlistSymbols() {
    final symbols = <String>{};
    try {
      final mwProvider = ref.read(marketWatchProvider);

      // Get symbols from the current watchlist scrips
      final scrips = mwProvider.scrips;
      for (var scrip in scrips) {
        final exch = scrip['exch']?.toString();
        final token = scrip['token']?.toString();
        if (exch != null && token != null && exch.isNotEmpty && token.isNotEmpty) {
          symbols.add('$exch|$token');
        }
      }
    } catch (e) {
      log('WebSubscriptionManager: Error getting watchlist symbols: $e');
    }
    return symbols;
  }

  /// Get current index symbols (top indices and default indices)
  Set<String> _getIndexSymbols() {
    final symbols = <String>{};
    try {
      final indexProvider = ref.read(indexListProvider);

      // Add top indices (dashboard)
      final topIndices = indexProvider.topIndicesForDashboard?.indValues ?? [];
      for (var index in topIndices) {
        if (index.exch != null && index.token != null) {
          symbols.add('${index.exch}|${index.token}');
        }
      }

      // Add default indices
      final defaultIndices = indexProvider.defaultIndexList?.indValues ?? [];
      for (var index in defaultIndices) {
        if (index.exch != null && index.token != null) {
          symbols.add('${index.exch}|${index.token}');
        }
      }
    } catch (e) {
      log('WebSubscriptionManager: Error getting index symbols: $e');
    }
    return symbols;
  }

  /// Subscribe to ticker symbols (positions) - these persist across screen changes
  /// Call this after positions data is fetched to ensure ticker always shows live data
  Future<void> subscribeTickerSymbols(BuildContext context) async {
    if (!_isUserLoggedIn()) {
      log('WebSubscriptionManager: Not subscribing ticker - user not logged in');
      return;
    }

    // Check WebSocket readiness
    if (!_isWebSocketReady()) {
      print('⏳ [WebSubscriptionManager] WebSocket not ready for ticker subscriptions');
      return;
    }

    print('═══════════════════════════════════════════════════════════');
    print('📊 [WebSubscriptionManager] SUBSCRIBING TICKER SYMBOLS (Positions)');
    print('═══════════════════════════════════════════════════════════');

    try {
      // Get position symbols for ticker
      final portfolio = ref.read(portfolioProvider);
      final positions = portfolio.postionBookModel ?? [];

      final newTickerSymbols = <String>{};
      for (var position in positions) {
        if (position.exch != null && position.token != null) {
          newTickerSymbols.add('${position.exch}|${position.token}');
        }
      }

      if (newTickerSymbols.isEmpty) {
        print('ℹ️  [WebSubscriptionManager] No positions for ticker subscription');
        print('═══════════════════════════════════════════════════════════\n');
        return;
      }

      // Find symbols that need to be subscribed (not already in master list)
      final symbolsToSubscribe = newTickerSymbols.where((symbol) =>
        !_currentWebSocketSubscriptions.contains(symbol)
      ).toSet();

      // Update ticker subscriptions tracking
      _tickerSubscriptions.clear();
      _tickerSubscriptions.addAll(newTickerSymbols);

      if (symbolsToSubscribe.isEmpty) {
        print('ℹ️  [WebSubscriptionManager] All ticker symbols already subscribed');
        print('   Ticker symbols: ${newTickerSymbols.length}');
        print('═══════════════════════════════════════════════════════════\n');
        return;
      }

      print('✅ [WebSubscriptionManager] Subscribing ${symbolsToSubscribe.length} ticker symbols');
      print('   Total ticker symbols: ${newTickerSymbols.length}');
      print('   New symbols: ${symbolsToSubscribe.length}');
      if (symbolsToSubscribe.length <= 10) {
        print('   Symbols: ${symbolsToSubscribe.join(", ")}');
      } else {
        print('   First 10 symbols: ${symbolsToSubscribe.take(10).join(", ")}...');
      }

      // Subscribe via websocket
      final wsProvider = ref.read(websocketProvider);
      final symbolString = symbolsToSubscribe.join('#');

      wsProvider.connectTouchLine(
        task: "d",
        input: symbolString,
        context: context,
      );

      // Track subscriptions
      _currentWebSocketSubscriptions.addAll(symbolsToSubscribe);
      _activeSubscriptions.addAll(symbolsToSubscribe);

      print('✅ [WebSubscriptionManager] Ticker symbols subscribed successfully');
      print('   Current total subscriptions: ${_currentWebSocketSubscriptions.length}');
      print('   Master list total: ${_activeSubscriptions.length}');
      print('═══════════════════════════════════════════════════════════\n');

    } catch (e) {
      print('❌ [WebSubscriptionManager] Error subscribing ticker symbols: $e');
      log('WebSubscriptionManager: Error subscribing ticker symbols: $e');
    }
  }

  /// Refresh ticker subscriptions when positions data changes
  /// Call this after positions are fetched/refreshed
  Future<void> refreshTickerSubscriptions(BuildContext context) async {
    print('🔄 [WebSubscriptionManager] Refreshing ticker subscriptions...');
    await subscribeTickerSymbols(context);
  }

  /// Get current ticker (position) symbols
  Set<String> _getTickerSymbols() {
    final symbols = <String>{};
    try {
      final portfolio = ref.read(portfolioProvider);
      final positions = portfolio.postionBookModel ?? [];
      for (var position in positions) {
        if (position.exch != null && position.token != null) {
          symbols.add('${position.exch}|${position.token}');
        }
      }
    } catch (e) {
      log('WebSubscriptionManager: Error getting ticker symbols: $e');
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

    // CRITICAL: Also check symbols that are actively used by providers
    // This prevents unsubscribing symbols that are shown in watchlist, depth, etc.
    try {
      final marketWatch = ref.read(marketWatchProvider);

      // Add current depth symbol (the symbol user clicked on)
      final depthSymbol = marketWatch.currentDepthSymbol;
      if (depthSymbol != null && depthSymbol.isNotEmpty) {
        symbolsStillNeeded.add(depthSymbol);
        print('   🔒 Protected depth symbol: $depthSymbol');
      }

      // Add all watchlist symbols (visible in watchlist panel)
      final watchlistSymbols = _getWatchlistSymbols();
      if (watchlistSymbols.isNotEmpty) {
        symbolsStillNeeded.addAll(watchlistSymbols);
        print('   🔒 Protected ${watchlistSymbols.length} watchlist symbols');
      }

      // Add index symbols (visible in dashboard/indices)
      final indexSymbols = _getIndexSymbols();
      if (indexSymbols.isNotEmpty) {
        symbolsStillNeeded.addAll(indexSymbols);
        print('   🔒 Protected ${indexSymbols.length} index symbols');
      }

      // CRITICAL FIX: Protect holdings symbols - they need real-time updates
      final portfolio = ref.read(portfolioProvider);
      final holdings = portfolio.holdingsModel ?? [];
      for (var holding in holdings) {
        final exchTsymList = holding.exchTsym ?? [];
        for (var exchTsym in exchTsymList) {
          if (exchTsym.exch != null && exchTsym.token != null) {
            symbolsStillNeeded.add('${exchTsym.exch}|${exchTsym.token}');
          }
        }
      }
      if (holdings.isNotEmpty) {
        print('   🔒 Protected ${holdings.length} holdings symbols');
      }

      // CRITICAL FIX: Protect positions symbols - they need real-time updates
      final positions = portfolio.postionBookModel ?? [];
      for (var position in positions) {
        if (position.exch != null && position.token != null) {
          symbolsStillNeeded.add('${position.exch}|${position.token}');
        }
      }
      if (positions.isNotEmpty) {
        print('   🔒 Protected ${positions.length} positions symbols');
      }

      // CRITICAL: Protect ticker symbols (positions) - these NEVER get unsubscribed
      // Ticker header needs live position data regardless of which screen is active
      if (_tickerSubscriptions.isNotEmpty) {
        symbolsStillNeeded.addAll(_tickerSubscriptions);
        print('   🔒 Protected ${_tickerSubscriptions.length} ticker symbols (positions)');
      }
    } catch (e) {
      print('   ⚠️ Error getting protected symbols: $e');
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

      // Use connectTouchLine with unsubscribe depth task for web
      wsProvider.connectTouchLine(
        task: "ud", // Unsubscribe depth task
        input: symbolString,
        context: context,
      );

      // Remove these symbols from our tracking (deduplication)
      _currentWebSocketSubscriptions.removeAll(symbolsToUnsubscribe);

      // REMOVE FROM MASTER LIST (for reconnection)
      _activeSubscriptions.removeAll(symbolsToUnsubscribe);

      print('📝 [WebSubscriptionManager] Removed ${symbolsToUnsubscribe.length} symbols from tracking');
      print('   Current subscriptions: ${_currentWebSocketSubscriptions.length}');
      print('   Master list total: ${_activeSubscriptions.length}');

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

  /// Update watchlist subscriptions when switching between watchlist tabs
  /// This properly unsubscribes old watchlist symbols and subscribes to new ones
  /// while protecting symbols used by other screens
  Future<void> updateWatchlistSubscriptions({
    required Set<String> oldSymbols,
    required Set<String> newSymbols,
    required BuildContext context,
  }) async {
    print('═══════════════════════════════════════════════════════════');
    print('🔄 [WebSubscriptionManager] WATCHLIST TAB CHANGE');
    print('   Old symbols: ${oldSymbols.length}');
    print('   New symbols: ${newSymbols.length}');
    print('═══════════════════════════════════════════════════════════');

    // Collect all protected symbols (symbols used by other screens)
    final protectedSymbols = <String>{};

    try {
      // 1. Protect symbols from all active screen subscriptions EXCEPT watchlist
      for (var entry in _screenSubscriptions.entries) {
        if (entry.key != ScreenType.watchlist) {
          protectedSymbols.addAll(entry.value);
        }
      }
      print('   🔒 Protected ${protectedSymbols.length} symbols from other screens');

      // 2. Protect depth symbol
      final marketWatch = ref.read(marketWatchProvider);
      final depthSymbol = marketWatch.currentDepthSymbol;
      if (depthSymbol != null && depthSymbol.isNotEmpty) {
        protectedSymbols.add(depthSymbol);
        print('   🔒 Protected depth symbol: $depthSymbol');
      }

      // 3. Protect index symbols
      final indexSymbols = _getIndexSymbols();
      if (indexSymbols.isNotEmpty) {
        protectedSymbols.addAll(indexSymbols);
        print('   🔒 Protected ${indexSymbols.length} index symbols');
      }

      // 4. Protect holdings symbols
      final portfolio = ref.read(portfolioProvider);
      final holdings = portfolio.holdingsModel ?? [];
      for (var holding in holdings) {
        final exchTsymList = holding.exchTsym ?? [];
        for (var exchTsym in exchTsymList) {
          if (exchTsym.exch != null && exchTsym.token != null) {
            protectedSymbols.add('${exchTsym.exch}|${exchTsym.token}');
          }
        }
      }

      // 5. Protect positions symbols
      final positions = portfolio.postionBookModel ?? [];
      for (var position in positions) {
        if (position.exch != null && position.token != null) {
          protectedSymbols.add('${position.exch}|${position.token}');
        }
      }

      // 6. Protect ticker symbols (always active for ticker header)
      if (_tickerSubscriptions.isNotEmpty) {
        protectedSymbols.addAll(_tickerSubscriptions);
        print('   🔒 Protected ${_tickerSubscriptions.length} ticker symbols');
      }
    } catch (e) {
      print('   ⚠️ Error getting protected symbols: $e');
    }

    // Find symbols to unsubscribe (in old but not in new, and not protected)
    final symbolsToUnsubscribe = oldSymbols.where((symbol) =>
      !newSymbols.contains(symbol) && !protectedSymbols.contains(symbol)
    ).toSet();

    // Find symbols to subscribe (in new but not currently subscribed)
    final symbolsToSubscribe = newSymbols.where((symbol) =>
      !_currentWebSocketSubscriptions.contains(symbol)
    ).toSet();

    print('   📤 Symbols to unsubscribe: ${symbolsToUnsubscribe.length}');
    print('   📥 Symbols to subscribe: ${symbolsToSubscribe.length}');

    final wsProvider = ref.read(websocketProvider);

    // Unsubscribe old symbols
    if (symbolsToUnsubscribe.isNotEmpty) {
      if (symbolsToUnsubscribe.length <= 10) {
        print('   🗑️ Unsubscribing: ${symbolsToUnsubscribe.join(", ")}');
      } else {
        print('   🗑️ Unsubscribing first 10: ${symbolsToUnsubscribe.take(10).join(", ")}...');
      }

      try {
        final symbolString = symbolsToUnsubscribe.join('#');
        wsProvider.connectTouchLine(
          task: "ud",
          input: symbolString,
          context: context,
        );

        // Remove from tracking
        _currentWebSocketSubscriptions.removeAll(symbolsToUnsubscribe);
        _activeSubscriptions.removeAll(symbolsToUnsubscribe);
      } catch (e) {
        print('   ❌ Error unsubscribing: $e');
      }
    }

    // Subscribe to new symbols
    if (symbolsToSubscribe.isNotEmpty) {
      if (symbolsToSubscribe.length <= 10) {
        print('   ➕ Subscribing: ${symbolsToSubscribe.join(", ")}');
      } else {
        print('   ➕ Subscribing first 10: ${symbolsToSubscribe.take(10).join(", ")}...');
      }

      try {
        final symbolString = symbolsToSubscribe.join('#');
        wsProvider.connectTouchLine(
          task: "d",
          input: symbolString,
          context: context,
        );

        // Add to tracking
        _currentWebSocketSubscriptions.addAll(symbolsToSubscribe);
        _activeSubscriptions.addAll(symbolsToSubscribe);
      } catch (e) {
        print('   ❌ Error subscribing: $e');
      }
    }

    // Update the watchlist screen subscription record with new symbols
    _screenSubscriptions[ScreenType.watchlist] = newSymbols;

    print('   ✅ Watchlist subscriptions updated');
    print('   Current total: ${_currentWebSocketSubscriptions.length}');
    print('   Master list: ${_activeSubscriptions.length}');
    print('═══════════════════════════════════════════════════════════\n');
  }

  /// Get current watchlist symbols as a set (for use in updateWatchlistSubscriptions)
  Set<String> getCurrentWatchlistSymbols() {
    return _screenSubscriptions[ScreenType.watchlist] ?? {};
  }

  /// Unsubscribe specific tokens (for option chain, futures symbol changes)
  /// This method checks for protected symbols before unsubscribing
  /// Protected symbols: watchlist, depth, holdings, positions, indices, other active screens
  Future<void> unsubscribeTokens({
    required Set<String> tokensToCheck,
    required BuildContext context,
    String source = 'unknown',
  }) async {
    if (tokensToCheck.isEmpty) {
      print('ℹ️  [WebSubscriptionManager] No tokens to unsubscribe for $source');
      return;
    }

    print('═══════════════════════════════════════════════════════════');
    print('🗑️  [WebSubscriptionManager] UNSUBSCRIBING tokens for: $source');
    print('   Tokens to check: ${tokensToCheck.length}');
    print('═══════════════════════════════════════════════════════════');

    // Collect all protected symbols
    final protectedSymbols = <String>{};

    try {
      // 1. Protect symbols from all active screen subscriptions
      for (var screenSubscriptions in _screenSubscriptions.values) {
        protectedSymbols.addAll(screenSubscriptions);
      }
      print('   🔒 Protected ${protectedSymbols.length} symbols from active screens');

      // 2. Protect watchlist symbols
      final watchlistSymbols = _getWatchlistSymbols();
      if (watchlistSymbols.isNotEmpty) {
        protectedSymbols.addAll(watchlistSymbols);
        print('   🔒 Protected ${watchlistSymbols.length} watchlist symbols');
      }

      // 3. Protect depth symbol
      final marketWatch = ref.read(marketWatchProvider);
      final depthSymbol = marketWatch.currentDepthSymbol;
      if (depthSymbol != null && depthSymbol.isNotEmpty) {
        protectedSymbols.add(depthSymbol);
        print('   🔒 Protected depth symbol: $depthSymbol');
      }

      // 4. Protect index symbols
      final indexSymbols = _getIndexSymbols();
      if (indexSymbols.isNotEmpty) {
        protectedSymbols.addAll(indexSymbols);
        print('   🔒 Protected ${indexSymbols.length} index symbols');
      }

      // 5. Protect holdings symbols
      final portfolio = ref.read(portfolioProvider);
      final holdings = portfolio.holdingsModel ?? [];
      for (var holding in holdings) {
        final exchTsymList = holding.exchTsym ?? [];
        for (var exchTsym in exchTsymList) {
          if (exchTsym.exch != null && exchTsym.token != null) {
            protectedSymbols.add('${exchTsym.exch}|${exchTsym.token}');
          }
        }
      }

      // 6. Protect positions symbols
      final positions = portfolio.postionBookModel ?? [];
      for (var position in positions) {
        if (position.exch != null && position.token != null) {
          protectedSymbols.add('${position.exch}|${position.token}');
        }
      }

      // 7. Protect futures symbols (if futures list is open) - BUT NOT if we're unsubscribing futures
      if (source != 'futures') {
        final futList = marketWatch.fut ?? [];
        for (var fut in futList) {
          if (fut.exch != null && fut.token != null) {
            protectedSymbols.add('${fut.exch}|${fut.token}');
          }
        }
      }

      // 8. Protect current option chain tokens (if option chain is open) - BUT NOT if we're unsubscribing optionChain
      if (source != 'optionChain') {
        final optionChainModel = marketWatch.optionChainModel;
        if (optionChainModel?.optValue != null) {
          for (var option in optionChainModel!.optValue!) {
            if (option.exch != null && option.token != null) {
              protectedSymbols.add('${option.exch}|${option.token}');
            }
          }
          print('   🔒 Protected ${optionChainModel.optValue!.length} option chain symbols');
        }
      }

      // 9. Protect ticker symbols (always active for ticker header)
      if (_tickerSubscriptions.isNotEmpty) {
        protectedSymbols.addAll(_tickerSubscriptions);
        print('   🔒 Protected ${_tickerSubscriptions.length} ticker symbols');
      }

    } catch (e) {
      print('   ⚠️ Error getting protected symbols: $e');
    }

    // Find tokens that can be unsubscribed (not protected)
    final tokensToUnsubscribe = tokensToCheck.where((token) =>
      !protectedSymbols.contains(token)
    ).toSet();

    if (tokensToUnsubscribe.isEmpty) {
      print('ℹ️  [WebSubscriptionManager] All tokens for $source are protected');
      print('   Total tokens: ${tokensToCheck.length}');
      print('   Protected: ${tokensToCheck.length}');
      print('═══════════════════════════════════════════════════════════\n');
      return;
    }

    print('✅ [WebSubscriptionManager] Unsubscribing ${tokensToUnsubscribe.length} tokens for $source');
    print('   Total tokens: ${tokensToCheck.length}');
    print('   Protected: ${tokensToCheck.length - tokensToUnsubscribe.length}');
    print('   To unsubscribe: ${tokensToUnsubscribe.length}');
    if (tokensToUnsubscribe.length <= 10) {
      print('   Tokens: ${tokensToUnsubscribe.join(", ")}');
    } else {
      print('   First 10 tokens: ${tokensToUnsubscribe.take(10).join(", ")}...');
    }

    try {
      // Unsubscribe via websocket provider
      final wsProvider = ref.read(websocketProvider);
      final symbolString = tokensToUnsubscribe.join('#');

      // Use unsubscribe depth task for web
      wsProvider.connectTouchLine(
        task: "ud",
        input: symbolString,
        context: context,
      );

      // Remove from tracking
      _currentWebSocketSubscriptions.removeAll(tokensToUnsubscribe);
      _activeSubscriptions.removeAll(tokensToUnsubscribe);

      print('📝 [WebSubscriptionManager] Removed ${tokensToUnsubscribe.length} tokens from tracking');
      print('   Current subscriptions: ${_currentWebSocketSubscriptions.length}');
      print('   Master list total: ${_activeSubscriptions.length}');
      print('✅ [WebSubscriptionManager] Successfully unsubscribed tokens for $source');
      print('═══════════════════════════════════════════════════════════\n');

    } catch (e) {
      print('❌ [WebSubscriptionManager] ERROR unsubscribing tokens for $source: $e');
      print('═══════════════════════════════════════════════════════════\n');
      log('WebSubscriptionManager: Error unsubscribing tokens for $source: $e');
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

    // On web, the browser visibilitychange handler (_onBrowserVisibilityChange)
    // is more reliable for detecting tab switches. However, AppLifecycleState.resumed
    // can still fire in some cases (e.g., window minimize/restore), so handle it too.
    // Use the same force-reconnect approach to ensure all screens get fresh data.
    if (_shouldReconnect()) {
      log('WebSubscriptionManager: Reconnection needed, forcing full reconnect');
      _forceReconnectAndResubscribe();
    } else if (_activeSubscriptions.isNotEmpty && _currentWebSocketSubscriptions.isEmpty) {
      // Connection appears alive but no subscriptions tracked - re-send from master list
      log('WebSubscriptionManager: Connection alive but subscriptions lost, restoring from master list');
      _sendAllSubscriptionsFromMasterList();
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
            task: "ud", // Unsubscribe depth for web
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
    _activeSubscriptions.clear(); // Clear master list on logout
    _tickerSubscriptions.clear(); // Clear ticker subscriptions on logout
    notifyListeners();
  }

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'activeScreens': _activeScreens.map((k, v) => MapEntry(k.toString(), v?.toString())),
      'screenSubscriptions': _screenSubscriptions.map((k, v) => MapEntry(k.toString(), v.length.toString())),
      'currentWebSocketSubscriptions': _currentWebSocketSubscriptions.length,
      'activeSubscriptions (master list)': _activeSubscriptions.length,
      'tickerSubscriptions': _tickerSubscriptions.length,
      'tickerSymbols': _tickerSubscriptions.toList(),
      'websocketSymbols': _currentWebSocketSubscriptions.toList(),
      'masterListSymbols': _activeSubscriptions.toList(),
      'currentState': _currentState.toString(),
      'lastPauseTime': _lastPauseTime?.toIso8601String(),
      'wasDisconnectedInBackground': _wasDisconnectedInBackground,
      'lastNetworkStatus': _lastNetworkStatus.toString(),
    };
  }
  
  @override
  void dispose() {
    // Remove browser visibility listener
    html.document.removeEventListener('visibilitychange', _onBrowserVisibilityChange);

    // Cancel all per-panel debounce timers
    for (final timer in _updateDebounceTimers.values) {
      timer.cancel();
    }
    _updateDebounceTimers.clear();

    _retryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();

    // Remove websocket listener
    if (_wsProviderListener != null) {
      try {
        ref.read(websocketProvider).removeListener(_wsProviderListener!);
      } catch (e) {
        log('WebSubscriptionManager: Error removing websocket listener: $e');
      }
    }

    _activeScreens.clear();
    _screenSubscriptions.clear();
    _currentWebSocketSubscriptions.clear();
    _activeSubscriptions.clear(); // Clear master list
    _tickerSubscriptions.clear(); // Clear ticker subscriptions
    _pendingSubscriptionQueue.clear();
    _pendingScreenChanges.clear();
    super.dispose();
  }
}

/// Pending subscription waiting for WebSocket to be ready
class _PendingSubscription {
  final ScreenType screenType;
  final Set<String> symbols;
  final int retryCount;
  final DateTime timestamp;

  _PendingSubscription({
    required this.screenType,
    required this.symbols,
    required this.retryCount,
    required this.timestamp,
  });
}

/// Pending screen change waiting to be processed (used to fast-track subscriptions)
class _PendingScreenChange {
  final int panelIndex;
  final ScreenType? previousScreen;
  final ScreenType? newScreen;

  _PendingScreenChange({
    required this.panelIndex,
    required this.previousScreen,
    required this.newScreen,
  });
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

