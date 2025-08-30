import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_state_provider.dart';
import 'websocket_provider.dart';

/// Manages app lifecycle events and handles subscription restoration
class AppLifecycleManager extends ChangeNotifier with WidgetsBindingObserver {
  final Ref ref;
  
  AppLifecycleManager(this.ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  AppLifecycleState _currentState = AppLifecycleState.resumed;
  DateTime? _lastPauseTime;
  DateTime? _lastResumeTime;
  bool _isRestoringOnResume = false;
  Timer? _restorationDebounceTimer;
  
  // Configurable settings
  static const Duration _backgroundThreshold = Duration(seconds: 5);
  static const Duration _restorationDebounceDelay = Duration(milliseconds: 500);
  static const int _maxRestorationAttempts = 3;
  
  AppLifecycleState get currentState => _currentState;
  bool get isRestoringOnResume => _isRestoringOnResume;
  DateTime? get lastPauseTime => _lastPauseTime;
  DateTime? get lastResumeTime => _lastResumeTime;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final previousState = _currentState;
    _currentState = state;
    
    log('AppLifecycleManager: State changed from $previousState to $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed(previousState);
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
    
    notifyListeners();
  }
  
  /// Handle app resumed state
  void _handleAppResumed(AppLifecycleState previousState) {
    _lastResumeTime = DateTime.now();
    
    // Cancel any pending restoration
    _restorationDebounceTimer?.cancel();
    
    // Only restore subscriptions if app was truly backgrounded
    final shouldRestore = _shouldRestoreSubscriptions(previousState);
    
    if (shouldRestore) {
      // Use debounce to avoid multiple rapid restoration attempts
      _restorationDebounceTimer = Timer(_restorationDebounceDelay, () {
        _performSubscriptionRestoration();
      });
    }
    
    log('AppLifecycleManager: App resumed, restoration needed: $shouldRestore');
  }
  
  /// Handle app paused state
  void _handleAppPaused() {
    _lastPauseTime = DateTime.now();
    
    // Perform cleanup if needed
    _performPauseCleanup();
    
    log('AppLifecycleManager: App paused');
  }
  
  /// Handle app inactive state
  void _handleAppInactive() {
    // App is temporarily inactive (e.g., during phone call, notification overlay)
    // Usually no action needed
    log('AppLifecycleManager: App inactive');
  }
  
  /// Handle app detached state
  void _handleAppDetached() {
    // App is about to be terminated
    _performFinalCleanup();
    log('AppLifecycleManager: App detached');
  }
  
  /// Handle app hidden state
  void _handleAppHidden() {
    // App is hidden but may still be running in background
    log('AppLifecycleManager: App hidden');
  }
  
  /// Determine if subscriptions should be restored
  bool _shouldRestoreSubscriptions(AppLifecycleState previousState) {
    // Only restore if app was paused or detached
    if (previousState != AppLifecycleState.paused && 
        previousState != AppLifecycleState.detached &&
        previousState != AppLifecycleState.hidden) {
      return false;
    }
    
    // Check if app was backgrounded for significant time
    if (_lastPauseTime != null && _lastResumeTime != null) {
      final backgroundDuration = _lastResumeTime!.difference(_lastPauseTime!);
      return backgroundDuration > _backgroundThreshold;
    }
    
    return true;
  }
  
  /// Perform subscription restoration
  Future<void> _performSubscriptionRestoration() async {
    if (_isRestoringOnResume) {
      log('AppLifecycleManager: Restoration already in progress');
      return;
    }
    
    _isRestoringOnResume = true;
    notifyListeners();
    
    try {
      // Check network connectivity first
      final networkProvider = ref.read(networkStateProvider);
      if (networkProvider.connectionStatus == ConnectivityResult.none) {
        log('AppLifecycleManager: No network connection, skipping restoration');
        return;
      }
      
      // Get the context from network provider (if available)
      final context = networkProvider.context;
      if (context == null) {
        log('AppLifecycleManager: No context available for restoration');
        return;
      }
      
      log('AppLifecycleManager: Starting subscription restoration...');
      
      // Print lifecycle restoration debug info
      _printLifecycleRestorationDebugInfo();
      
      // Force websocket reconnection to ensure fresh connection
      final wsProvider = ref.read(websocketProvider);
      wsProvider.closeSocket(true);
      
      // Short delay to ensure clean disconnection
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Restore subscriptions using enhanced network state provider
      await networkProvider.restoreAllSubscriptions();
      
      // Additional validation - check if websocket is connected
      await _validateConnectionWithRetry(context, maxAttempts: _maxRestorationAttempts);
      
      log('AppLifecycleManager: Subscription restoration completed successfully');
      
    } catch (e) {
      log('AppLifecycleManager: Error during subscription restoration: $e');
      
      // Fallback: trigger network state update to force reconnection
      try {
        final connectivity = Connectivity();
        final result = await connectivity.checkConnectivity();
        ref.read(networkStateProvider).updateConnectionStatus(result);
      } catch (fallbackError) {
        log('AppLifecycleManager: Fallback restoration also failed: $fallbackError');
      }
    } finally {
      _isRestoringOnResume = false;
      notifyListeners();
    }
  }
  
  /// Validate connection with retry mechanism
  Future<void> _validateConnectionWithRetry(BuildContext context, {int maxAttempts = 3}) async {
    final wsProvider = ref.read(websocketProvider);
    
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      // Wait a bit for connection to establish
      await Future.delayed(Duration(milliseconds: 500 * attempt));
      
      if (wsProvider.wsConnected) {
        log('AppLifecycleManager: Connection validated on attempt $attempt');
        return;
      }
      
      if (attempt < maxAttempts) {
        log('AppLifecycleManager: Connection not ready, retrying... (attempt $attempt/$maxAttempts)');
        
        // Try to re-establish connection using captured subscriptions - restore all, not just 1
        final capturedSubscriptions = wsProvider.getActiveSubscriptionsForRestoration(maxCount: 50);
        
        log('AppLifecycleManager: Attempting to restore ${capturedSubscriptions.length} subscriptions');
        
        for (final subscription in capturedSubscriptions) {
          try {
            wsProvider.establishConnection(
              channelInput: subscription.symbols,
              task: subscription.task,
              context: context,
            );
            
            // Small delay between subscriptions
            await Future.delayed(const Duration(milliseconds: 100));
          } catch (e) {
            log('AppLifecycleManager: Error restoring ${subscription.pageContext}: $e');
          }
        }
      }
    }
    
    log('AppLifecycleManager: Connection validation failed after $maxAttempts attempts');
  }
  
  /// Perform cleanup when app is paused
  void _performPauseCleanup() {
    // Clean up old subscriptions to free memory
    final wsProvider = ref.read(websocketProvider);
    wsProvider.cleanupOldSubscriptions();
  }
  
  /// Perform final cleanup when app is being terminated
  void _performFinalCleanup() {
    _restorationDebounceTimer?.cancel();
    
    // Close websocket connection cleanly
    try {
      ref.read(websocketProvider).closeSocket(false);
    } catch (e) {
      log('AppLifecycleManager: Error during final cleanup: $e');
    }
  }
  
  /// Manually trigger subscription restoration (for testing or edge cases)
  Future<void> manuallyRestoreSubscriptions() async {
    log('AppLifecycleManager: Manual subscription restoration triggered');
    await _performSubscriptionRestoration();
  }
  
  /// Print lifecycle restoration debug information
  void _printLifecycleRestorationDebugInfo() {
    final backgroundDuration = _lastPauseTime != null && _lastResumeTime != null
        ? _lastResumeTime!.difference(_lastPauseTime!).inSeconds
        : null;
        
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 APP LIFECYCLE RESTORATION DEBUG INFO');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📱 Current State: $_currentState');
    print('⏸️  Last Pause Time: ${_lastPauseTime?.toIso8601String() ?? 'N/A'}');
    print('▶️  Last Resume Time: ${_lastResumeTime?.toIso8601String() ?? 'N/A'}');
    print('⏱️  Background Duration: ${backgroundDuration != null ? '${backgroundDuration}s' : 'N/A'}');
    print('🔄 Currently Restoring: $_isRestoringOnResume');
    print('🎯 Background Threshold: ${_backgroundThreshold.inSeconds}s');
    print('🔢 Max Restoration Attempts: $_maxRestorationAttempts');
    
    final networkProvider = ref.read(networkStateProvider);
    print('🌐 Network Status: ${networkProvider.connectionStatus}');
    print('📊 Connection Quality: ${networkProvider.connectionQualityScore}');
    
    print('⏰ Restoration Trigger Time: ${DateTime.now().toIso8601String()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentState': _currentState.toString(),
      'lastPauseTime': _lastPauseTime?.toIso8601String(),
      'lastResumeTime': _lastResumeTime?.toIso8601String(),
      'isRestoring': _isRestoringOnResume,
      'backgroundDuration': _lastPauseTime != null && _lastResumeTime != null
          ? _lastResumeTime!.difference(_lastPauseTime!).inSeconds
          : null,
    };
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restorationDebounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for AppLifecycleManager
final appLifecycleManagerProvider = ChangeNotifierProvider<AppLifecycleManager>((ref) {
  return AppLifecycleManager(ref);
});