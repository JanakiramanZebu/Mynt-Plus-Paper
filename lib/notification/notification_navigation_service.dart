import 'dart:async';
import 'package:flutter/foundation.dart';

/// Centralized notification navigation service using stream-based architecture
/// Replaces polling timers with event-driven approach for better performance
///
/// Key improvements:
/// - Single source of truth for navigation events
/// - No polling/timers - instant event delivery
/// - Battery efficient
/// - No race conditions
/// - Easy to test and debug
class NotificationNavigationService {
  // Singleton pattern to ensure single stream instance
  static final NotificationNavigationService _instance = NotificationNavigationService._internal();
  factory NotificationNavigationService() => _instance;
  NotificationNavigationService._internal();

  // Stream controller for navigation events - broadcast allows multiple listeners
  final _navigationController = StreamController<NotificationNavigationEvent>.broadcast();

  // Public stream that widgets/screens can listen to
  Stream<NotificationNavigationEvent> get navigationStream => _navigationController.stream;

  /// Request navigation to a notification screen/tab
  /// This is the SINGLE entry point for all notification navigation
  void requestNavigation({
    required String? messageType,
    required String? messageId,
    String? url,
  }) {
    if (messageType == null && messageId == null) {
      if (kDebugMode) {
        debugPrint('[NotificationNav] Ignoring empty navigation request');
      }
      return;
    }

    final event = NotificationNavigationEvent(
      messageType: messageType,
      messageId: messageId,
      url: url,
      timestamp: DateTime.now(),
    );

    if (kDebugMode) {
      debugPrint('[NotificationNav] New navigation event: type=$messageType, id=$messageId');
    }

    _navigationController.add(event);
  }

  /// Clear all pending events (useful for testing or cleanup)
  /// Note: StreamController doesn't support clearing events, but this method
  /// can be used to signal listeners to ignore pending events
  void clearAllEvents() {
    if (kDebugMode) {
      debugPrint('[NotificationNav] clearAllEvents() called - note: stream events cannot be cleared once emitted');
      debugPrint('[NotificationNav] Listeners should handle event filtering if needed');
    }
    // StreamController doesn't support clearing events once they're emitted
    // This method is kept for API consistency but does nothing
    // If you need to cancel pending navigation, implement a cancellation token pattern
  }

  /// Dispose the service (call on app shutdown)
  void dispose() {
    _navigationController.close();
  }
}

/// Navigation event data class
/// Contains all information needed to navigate to correct screen/tab and highlight message
class NotificationNavigationEvent {
  final String? messageType; // 'info', 'trade', 'broker', 'exchange', etc.
  final String? messageId;   // Unique message ID to highlight
  final String? url;          // Optional URL to open instead of app navigation
  final DateTime timestamp;   // When event was created

  NotificationNavigationEvent({
    required this.messageType,
    required this.messageId,
    this.url,
    required this.timestamp,
  });

  /// Converts message type to notification screen tab index
  /// Returns null if messageType is not for notification screen
  int? getNotificationTabIndex() {
    if (messageType == null) return null;

    switch (messageType!.toLowerCase()) {
      case 'broker':
        return 0; // Message tab
      case 'exchange':
        return 1; 
      case 'info':
        return 2; 
      default:
        return null; 
    }
  }

  /// Check if this is a trade notification (Portfolio → Orders → Trade)
  bool get isTradeNavigation {
    if (messageType == null) return false;
    final type = messageType!.toLowerCase();
    return type == 'trade';
  }

  /// Check if this is a notification screen navigation
  bool get isNotificationScreenNavigation {
    return getNotificationTabIndex() != null;
  }

  @override
  String toString() {
    return 'NotificationNavigationEvent(type: $messageType, id: $messageId, url: $url)';
  }
}
