import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'websocket_provider.dart';
import 'network_state_provider.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';

/// Lightweight subscription manager that tracks active subscriptions
/// and handles reconnection only when necessary
class SubscriptionManager extends ChangeNotifier with WidgetsBindingObserver {
  final Ref ref;
  
  SubscriptionManager(this.ref) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  // Track active subscriptions (symbols as keys to avoid duplicates)
  final Set<String> _activeSubscriptions = <String>{};
  
  // App lifecycle tracking
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  DateTime? _lastPauseTime;
  bool _wasDisconnectedInBackground = false;
  
  // Network tracking
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  ConnectivityResult _lastNetworkStatus = ConnectivityResult.mobile;
  
  // Context management - avoid stale context issues
  BuildContext? _lastValidContext;
  DateTime? _lastContextUpdate;
  
  // Reconnection management - prevent duplicate reconnection attempts
  bool _isReconnecting = false;
  DateTime? _lastReconnectionAttempt;
  Timer? _reconnectionDebounceTimer;
  
  // Getters
  Set<String> get activeSubscriptions => Set.from(_activeSubscriptions);
  int get subscriptionCount => _activeSubscriptions.length;
  bool get hasActiveSubscriptions => _activeSubscriptions.isNotEmpty;
  AppLifecycleState get currentState => _currentState;
  
  void _init() {
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
  }
  
  /// Add subscription (prevents duplicates automatically)
  /// Supports both single symbols "NSE|123456" and multiple symbols "NSE|123456#BSE|789012"
  void addSubscription(String symbolString) {
    if (symbolString.isEmpty) return;
    
    // Check session before adding subscriptions
    if (!_isUserLoggedIn()) {
      log('SubscriptionManager: Not adding subscriptions - user not logged in');
      return;
    }
    
    bool changed = false;
    // Handle both single symbols and symbol strings with # delimiter
    final symbols = symbolString.contains('#') 
        ? symbolString.split('#').where((s) => s.isNotEmpty) 
        : [symbolString];
    
    for (final symbol in symbols) {
      if (_activeSubscriptions.add(symbol.trim())) {
        changed = true;
      }
    }
    
    if (changed) {
      log('SubscriptionManager: Added ${symbols.length} subscriptions from "$symbolString" (Total: ${_activeSubscriptions.length})');
      notifyListeners();
    }
  }
  
  /// Remove subscription
  /// Supports both single symbols "NSE|123456" and multiple symbols "NSE|123456#BSE|789012"
  void removeSubscription(String symbolString) {
    if (symbolString.isEmpty) return;
    
    bool changed = false;
    // Handle both single symbols and symbol strings with # delimiter
    final symbols = symbolString.contains('#') 
        ? symbolString.split('#').where((s) => s.isNotEmpty) 
        : [symbolString];
    
    for (final symbol in symbols) {
      if (_activeSubscriptions.remove(symbol.trim())) {
        changed = true;
      }
    }
    
    if (changed) {
      log('SubscriptionManager: Removed ${symbols.length} subscriptions from "$symbolString" (Total: ${_activeSubscriptions.length})');
      notifyListeners();
    }
  }
  
  /// Add multiple subscriptions
  void addSubscriptions(List<String> symbols) {
    bool changed = false;
    for (final symbol in symbols) {
      if (symbol.isNotEmpty && _activeSubscriptions.add(symbol)) {
        changed = true;
      }
    }
    if (changed) {
      log('SubscriptionManager: Added ${symbols.length} subscriptions (Total: ${_activeSubscriptions.length})');
      notifyListeners();
    }
  }
  
  /// Remove multiple subscriptions
  void removeSubscriptions(List<String> symbols) {
    bool changed = false;
    for (final symbol in symbols) {
      if (_activeSubscriptions.remove(symbol)) {
        changed = true;
      }
    }
    if (changed) {
      log('SubscriptionManager: Removed ${symbols.length} subscriptions (Total: ${_activeSubscriptions.length})');
      notifyListeners();
    }
  }
  
  /// Clear all subscriptions
  void clearAllSubscriptions() {
    if (_activeSubscriptions.isNotEmpty) {
      final count = _activeSubscriptions.length;
      _activeSubscriptions.clear();
      log('SubscriptionManager: Cleared all $count subscriptions');
      notifyListeners();
    }
  }
  
  /// Check if symbol is subscribed (checks individual symbol like "NSE|123456")
  bool isSubscribed(String symbol) {
    return _activeSubscriptions.contains(symbol.trim());
  }
  
  /// Check if any of the symbols in a string are subscribed
  bool hasAnySubscription(String symbolString) {
    if (symbolString.isEmpty) return false;
    
    final symbols = symbolString.contains('#') 
        ? symbolString.split('#').where((s) => s.isNotEmpty) 
        : [symbolString];
    
    return symbols.any((symbol) => _activeSubscriptions.contains(symbol.trim()));
  }
  
  /// Update context for future use (called by active screens)
  void updateContext(BuildContext context) {
    _lastValidContext = context;
    _lastContextUpdate = DateTime.now();
    log('SubscriptionManager: Context updated from active screen');
    
    // Debounce reconnection attempts to prevent rapid calls
    _reconnectionDebounceTimer?.cancel();
    _reconnectionDebounceTimer = Timer(const Duration(seconds: 2), () {
      // Only reconnect if we have pending subscriptions and websocket is disconnected
      final wsProvider = ref.read(websocketProvider);
      if (hasActiveSubscriptions && !wsProvider.wsConnected && !_isReconnecting) {
        final shouldReconnect = _shouldReconnect();
        if (shouldReconnect) {
          log('SubscriptionManager: Fresh context available, attempting deferred reconnection');
          _reconnectWithActiveSubscriptions();
        }
      }
    });
  }
  
  /// Get a valid context, preferring fresh context over potentially stale ones
  BuildContext? _getValidContext() {
    // If we have a recent context (less than 30 minutes old), use it
    if (_lastValidContext != null && _lastContextUpdate != null) {
      final contextAge = DateTime.now().difference(_lastContextUpdate!);
      if (contextAge < const Duration(minutes: 30)) {
        try {
          // Try to validate if the context is still valid by checking if it's mounted
          if (_lastValidContext!.mounted) {
            log('SubscriptionManager: Using recent valid context (${contextAge.inMinutes}m old)');
            return _lastValidContext;
          }
        } catch (e) {
          log('SubscriptionManager: Recent context is no longer valid: $e');
        }
      } else {
        log('SubscriptionManager: Context too old (${contextAge.inMinutes}m), discarding');
      }
    }
    
    // Fallback to network provider context (might be stale but better than nothing)
    final networkProvider = ref.read(networkStateProvider);
    final networkContext = networkProvider.context;
    
    if (networkContext != null) {
      try {
        if (networkContext.mounted) {
          log('SubscriptionManager: Using network provider context as fallback');
          return networkContext;
        }
      } catch (e) {
        log('SubscriptionManager: Network provider context is invalid: $e');
      }
    }
    
    log('SubscriptionManager: No valid context available');
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
        // Do nothing for inactive (temporary state)
        break;
    }
  }
  
  void _handleAppGoingToBackground() {
    _lastPauseTime = DateTime.now();
    log('SubscriptionManager: App going to background');
    
    // Check if websocket is still connected
    final wsProvider = ref.read(websocketProvider);
    _wasDisconnectedInBackground = !wsProvider.wsConnected;
    
    if (_wasDisconnectedInBackground) {
      log('SubscriptionManager: WebSocket was already disconnected');
    }
  }
  
  void _handleAppResumed(AppLifecycleState previousState) {
    final resumeTime = DateTime.now();
    log('SubscriptionManager: App resumed from $previousState');
    
    // Only check for reconnection if we have active subscriptions
    if (!hasActiveSubscriptions) {
      log('SubscriptionManager: No active subscriptions, skipping reconnection check');
      return;
    }
    
    // Check if we need to reconnect
    final needsReconnection = _shouldReconnect();
    
    if (needsReconnection) {
      log('SubscriptionManager: Reconnection needed, restoring ${_activeSubscriptions.length} subscriptions');
      _reconnectWithActiveSubscriptions();
    } else {
      log('SubscriptionManager: WebSocket still connected, no reconnection needed');
    }
  }
  
  void _handleNetworkChange(ConnectivityResult result) {
    log('SubscriptionManager: Network changed from $_lastNetworkStatus to $result');
    
    final wasConnected = _lastNetworkStatus != ConnectivityResult.none;
    final isNowConnected = result != ConnectivityResult.none;
    
    _lastNetworkStatus = result;
    
    // If network came back online and we have subscriptions, check session and reconnect
    if (!wasConnected && isNowConnected && hasActiveSubscriptions) {
      if (_isUserLoggedIn()) {
        log('SubscriptionManager: Network restored, reconnecting with active subscriptions');
        _reconnectWithActiveSubscriptions();
      } else {
        log('SubscriptionManager: Network restored but user not logged in, skipping reconnection');
      }
    }
  }
  
  bool _shouldReconnect() {
    // First check if user is logged in and session is valid
    if (!_isUserLoggedIn()) {
      log('SubscriptionManager: User not logged in or session expired, skipping reconnection');
      return false;
    }
    
    final wsProvider = ref.read(websocketProvider);
    
    // Always reconnect if websocket is disconnected and we have subscriptions
    if (!wsProvider.wsConnected && hasActiveSubscriptions) {
      return true;
    }
    
    // If websocket was disconnected when we went to background
    if (_wasDisconnectedInBackground && hasActiveSubscriptions) {
      return true;
    }
    
    // Check if we were in background for too long (optional threshold)
    if (_lastPauseTime != null) {
      final backgroundDuration = DateTime.now().difference(_lastPauseTime!);
      if (backgroundDuration > const Duration(minutes: 5) && hasActiveSubscriptions) {
        log('SubscriptionManager: Was in background for ${backgroundDuration.inMinutes} minutes, forcing reconnection');
        return true;
      }
    }
    
    return false;
  }
  
  /// Check if user is logged in with valid session
  bool _isUserLoggedIn() {
    try {
      final Preferences pref = locator<Preferences>();
      
      // Check if session exists and is not empty
      final clientSession = pref.clientSession;
      final clientId = pref.clientId;
      
      // Check ConstantName.sessCheck flag
      final sessCheckValid = ConstantName.sessCheck;
      
      log('SubscriptionManager: Session validation - clientSession: ${clientSession?.isNotEmpty ?? false}, clientId: ${clientId?.isNotEmpty ?? false}, sessCheck: $sessCheckValid');
      
      // User is logged in if:
      // 1. Has valid client session
      // 2. Has client ID 
      // 3. Session check flag is true
      final isLoggedIn = (clientSession?.isNotEmpty ?? false) && 
                        (clientId?.isNotEmpty ?? false) && 
                        sessCheckValid;
      
      if (!isLoggedIn) {
        log('SubscriptionManager: User session invalid - clearing subscriptions');
        clearAllSubscriptions(); // Clear subscriptions if user is logged out
      }
      
      return isLoggedIn;
    } catch (e) {
      log('SubscriptionManager: Error checking user session: $e');
      return false; // Assume not logged in if error occurs
    }
  }
  
  /// Reconnect websocket and restore all active subscriptions in batches of 50
  Future<void> _reconnectWithActiveSubscriptions() async {
    // Prevent multiple simultaneous reconnection attempts
    if (_isReconnecting) {
      log('SubscriptionManager: ⏸️  Reconnection already in progress, skipping');
      return;
    }
    
    // Throttle reconnection attempts - don't reconnect if we just tried recently
    if (_lastReconnectionAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastReconnectionAttempt!);
      if (timeSinceLastAttempt < const Duration(seconds: 5)) {
        log('SubscriptionManager: ⏸️  Reconnection attempted too recently (${timeSinceLastAttempt.inSeconds}s ago), skipping');
        return;
      }
    }
    
    log('SubscriptionManager: _reconnectWithActiveSubscriptions called');
    log('SubscriptionManager: hasActiveSubscriptions = $hasActiveSubscriptions');
    log('SubscriptionManager: _activeSubscriptions.length = ${_activeSubscriptions.length}');
    
    // Final session validation before reconnection
    if (!_isUserLoggedIn()) {
      log('SubscriptionManager: ❌ Session invalid during reconnection, aborting');
      return;
    }
    
    if (!hasActiveSubscriptions) {
      log('SubscriptionManager: No active subscriptions to restore, returning early');
      return;
    }
    
    try {
      _isReconnecting = true;
      _lastReconnectionAttempt = DateTime.now();
      
      final wsProvider = ref.read(websocketProvider);
      
      // Check if already connected - if so, just restore subscriptions without reconnecting
      if (wsProvider.wsConnected) {
        log('SubscriptionManager: ✅ WebSocket already connected, restoring subscriptions only');
        // Restore subscriptions without reconnecting
        await _restoreSubscriptionsOnly(wsProvider);
        _isReconnecting = false;
        return;
      }
      
      // Get a valid context using improved context management
      final context = _getValidContext();
      
      if (context == null) {
        log('SubscriptionManager: ❌ No valid context available for reconnection - deferring until app becomes active');
        // Don't clear subscriptions, just defer reconnection until context becomes available
        return;
      }
      
      log('SubscriptionManager: ✅ Using valid context for reconnection');

      // Close existing connection if any and ensure clean reconnection
      if (wsProvider.wsConnected) {
        log('SubscriptionManager: Closing existing websocket connection');
        wsProvider.closeSocket(true);
        await Future.delayed(const Duration(milliseconds: 500)); // Longer pause for clean disconnect
      }
      
      // Establish fresh connection first before subscribing
      log('SubscriptionManager: Establishing fresh websocket connection...');
      await wsProvider.establishConnection(
        channelInput: "", // Empty input for connection establishment
        task: "c", // Connection task
        context: context,
      );
      
      // Wait for connection to be established
      int connectionAttempts = 0;
      const maxConnectionAttempts = 10;
      while (!wsProvider.wsConnected && connectionAttempts < maxConnectionAttempts) {
        await Future.delayed(const Duration(milliseconds: 300));
        connectionAttempts++;
        log('SubscriptionManager: Waiting for connection... attempt $connectionAttempts/$maxConnectionAttempts');
      }
      
      if (!wsProvider.wsConnected) {
        log('SubscriptionManager: ❌ Failed to establish websocket connection after $connectionAttempts attempts');
        return;
      }
      
      log('SubscriptionManager: ✅ WebSocket connected successfully, proceeding with subscriptions');
      
      log('━━━ SUBSCRIPTION MANAGER RESTORATION DEBUG ━━━');
      log('SubscriptionManager: Starting restoration of ${_activeSubscriptions.length} symbols');
      log('SubscriptionManager: Active subscriptions: ${_activeSubscriptions.toList()}');
      
      // Restore subscriptions in batches of 50
      final subscriptionList = _activeSubscriptions.toList();
      const batchSize = 50;
      int totalBatches = (subscriptionList.length / batchSize).ceil();
      
      log('SubscriptionManager: Will send $totalBatches batches of up to $batchSize symbols each');
      
      for (int i = 0; i < subscriptionList.length; i += batchSize) {
        final endIndex = (i + batchSize < subscriptionList.length) 
            ? i + batchSize 
            : subscriptionList.length;
        
        final batch = subscriptionList.sublist(i, endIndex);
        final batchNumber = (i ~/ batchSize) + 1;
        
        // Convert batch to string format expected by websocket
        final batchString = batch.join('#');
        
        log('SubscriptionManager: 📦 Batch $batchNumber/$totalBatches (${batch.length} symbols):');
        log('  Symbols: ${batch.join(", ")}');
        log('  Batch string: "$batchString"');
        
        // Ensure websocket is still connected before sending batch
        if (!wsProvider.wsConnected) {
          log('  ⚠️ WebSocket disconnected before batch $batchNumber, attempting reconnection...');
          await wsProvider.establishConnection(
            channelInput: "",
            task: "c",
            context: context,
          );
          
          // Wait briefly for reconnection
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (!wsProvider.wsConnected) {
            log('  ❌ Failed to reconnect for batch $batchNumber, skipping remaining batches');
            break;
          }
          log('  ✅ Reconnected successfully for batch $batchNumber');
        }
        
        log('  Calling wsProvider.establishConnection...');
        
        try {
          // Subscribe to batch - use connectTouchLine directly to ensure proper tracking
          wsProvider.connectTouchLine(
            task: "t",
            input: batchString,
            context: context,
          );
          log('  ✅ Batch $batchNumber websocket call completed successfully');
        } catch (e) {
          log('  ❌ Batch $batchNumber failed: $e');
        }
        
        // Small delay between batches to avoid overwhelming the server
        if (endIndex < subscriptionList.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      log('🎯 SubscriptionManager: Restoration completed - sent ${subscriptionList.length} symbols in $totalBatches batches');
      log('━━━ END RESTORATION DEBUG ━━━');
      
    } catch (e) {
      log('SubscriptionManager: Error during reconnection: $e');
    } finally {
      _isReconnecting = false;
    }
  }
  
  /// Restore subscriptions only (when websocket is already connected)
  Future<void> _restoreSubscriptionsOnly(dynamic wsProvider) async {
    try {
      final context = _getValidContext();
      if (context == null) {
        log('SubscriptionManager: ❌ No valid context for subscription restoration');
        return;
      }
      
      final subscriptionList = _activeSubscriptions.toList();
      const batchSize = 50;
      
      for (int i = 0; i < subscriptionList.length; i += batchSize) {
        final endIndex = (i + batchSize < subscriptionList.length) 
            ? i + batchSize 
            : subscriptionList.length;
        
        final batch = subscriptionList.sublist(i, endIndex);
        final batchString = batch.join('#');
        
        if (wsProvider.wsConnected) {
          wsProvider.connectTouchLine(
            task: "t",
            input: batchString,
            context: context,
          );
        }
        
        if (endIndex < subscriptionList.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      log('SubscriptionManager: ✅ Subscriptions restored (${subscriptionList.length} symbols)');
    } catch (e) {
      log('SubscriptionManager: Error restoring subscriptions: $e');
    }
  }
  
  /// Manual reconnection trigger (for external use)
  Future<void> forceReconnection() async {
    log('SubscriptionManager: Manual reconnection triggered');
    printCurrentState();
    
    // Validate session before attempting reconnection
    if (!_isUserLoggedIn()) {
      log('SubscriptionManager: Manual reconnection aborted - user not logged in');
      return;
    }
    
    await _reconnectWithActiveSubscriptions();
  }
  
  /// Debug method to print current subscription state
  void printCurrentState() {
    log('━━━ SUBSCRIPTION MANAGER CURRENT STATE ━━━');
    log('Total active subscriptions: ${_activeSubscriptions.length}');
    log('Current app state: $_currentState');
    log('Last network status: $_lastNetworkStatus'); 
    log('Was disconnected in background: $_wasDisconnectedInBackground');
    if (_activeSubscriptions.isNotEmpty) {
      log('Active subscriptions:');
      for (int i = 0; i < _activeSubscriptions.length; i++) {
        final symbol = _activeSubscriptions.elementAt(i);
        log('  ${i + 1}. $symbol');
      }
    } else {
      log('No active subscriptions');
    }
    log('━━━ END CURRENT STATE ━━━');
  }
  
  /// Get all active subscriptions as a formatted string for websocket (exchange|token#exchange|token...)
  String getSubscriptionString() {
    if (_activeSubscriptions.isEmpty) return '';
    return _activeSubscriptions.join('#');
  }
  
  /// Get active subscriptions in batches for websocket reconnection
  List<String> getSubscriptionBatches({int batchSize = 50}) {
    if (_activeSubscriptions.isEmpty) return [];
    
    final subscriptionList = _activeSubscriptions.toList();
    final batches = <String>[];
    
    for (int i = 0; i < subscriptionList.length; i += batchSize) {
      final endIndex = (i + batchSize < subscriptionList.length) 
          ? i + batchSize 
          : subscriptionList.length;
      
      final batch = subscriptionList.sublist(i, endIndex);
      batches.add(batch.join('#'));
    }
    
    return batches;
  }
  
  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'activeSubscriptions': _activeSubscriptions.length,
      'subscriptions': _activeSubscriptions.toList(),
      'currentState': _currentState.toString(),
      'lastPauseTime': _lastPauseTime?.toIso8601String(),
      'wasDisconnectedInBackground': _wasDisconnectedInBackground,
      'lastNetworkStatus': _lastNetworkStatus.toString(),
      'subscriptionString': getSubscriptionString(),
    };
  }
  
  @override
  void dispose() {
    _reconnectionDebounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    _activeSubscriptions.clear();
    super.dispose();
  }
}

/// Provider for SubscriptionManager
final subscriptionManagerProvider = ChangeNotifierProvider<SubscriptionManager>((ref) {
  return SubscriptionManager(ref);
});