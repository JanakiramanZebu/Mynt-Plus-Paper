import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mynt_plus/screens/Mobile/profile_screen/notification_screens/notification_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart' show getNavigatorState;
import '../routes/route_names.dart';
import 'notification_navigation_service.dart';

final notificationservice =
    ChangeNotifierProvider((ref) => NotificationService(ref));

class NotificationService extends ChangeNotifier {
  final Ref ref;
  NotificationService(this.ref);

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      "resource://drawable/res_notification_app_icon",
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Colors.blue.shade900,
          ledColor: Colors.blue,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
          icon: "resource://drawable/res_notification_app_icon"
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      debugPrint('[Notification] onNotificationCreatedMethod');
    }
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      debugPrint('[Notification] onNotificationDisplayedMethod');
    }
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      debugPrint('[Notification] onDismissActionReceivedMethod');
    }
  }

  /// Use this method to detect when the user taps on a notification or action button
  /// This is called when user taps on Awesome Notification (FOREGROUND notifications)
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {   

    final payload = receivedAction.payload ?? {};

    try {
      
      final messageType = payload["type"]; // 'info', 'trade', 'broker', 'exchange', etc.
      final uniqueId = payload["uniqueID"]; // Message ID to highlight
      final url = payload["url"]; // URL to open (optional)    

      // Check if URL exists - if yes, open URL instead of navigating to app
      if (url != null && url.isNotEmpty) {
        final Uri uri = Uri.parse(url);
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {         
          return; // URL opened successfully, don't navigate in app
        }
      }

      // Use the new stream-based navigation service
      // This handles both notification screen and trade navigation
      _handleNotificationNavigation(
        messageType: messageType,
        uniqueId: uniqueId,
        url: url,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Notification] ❌ Error handling Awesome Notification tap: $e');
        debugPrint('[Notification] Stack trace: ${StackTrace.current}');
      }
    }
  }

  /// Centralized navigation handler for notifications
  /// Routes to different screens based on messageType
  static void _handleNotificationNavigation({
    required String? messageType,
    required String? uniqueId,
    String? url,
  }) {
    // Helper function to check if messageType is for notification screen
    bool isNotificationScreenType(String? type) {
      if (type == null) return false;
      final lowerType = type.toLowerCase();
      return  lowerType == 'info';
    }

    // Helper function to check if messageType is for trade navigation
    bool isTradeType(String? type) {
      if (type == null) {
        if (kDebugMode) debugPrint('[Notification] isTradeType: type is null');
        return false;
      }
      final lowerType = type.toLowerCase();
      return lowerType == 'trade' ;
    }

    // Check if it's a notification screen navigation
    if (isNotificationScreenType(messageType)) {
      // Check if already on notification screen
      final isAlreadyOnScreen = Notificationpage.isCurrentlyVisible();

      if (isAlreadyOnScreen) {
        // Already on notification screen - just send event to switch tab
        NotificationNavigationService().requestNavigation(
          messageType: messageType,
          messageId: uniqueId,
          url: url,
        );
      } else {
      
        // Navigate to notification screen
        final navigatorState = getNavigatorState();
        if (navigatorState != null) {
          navigatorState.pushNamed(Routes.notificationpage);
        }

        // Send navigation event after a delay to allow screen to initialize
        // Using addPostFrameCallback for better timing than hard-coded delay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            NotificationNavigationService().requestNavigation(
              messageType: messageType,
              messageId: uniqueId,
              url: url,
            );
          });
        });
      }
      return;
    }

    // Check if it's a trade navigation
    if (isTradeType(messageType)) {
      if (kDebugMode) {
        debugPrint('[Notification] Sending trade navigation event');
      }
      // Send event for home_screen to handle
      NotificationNavigationService().requestNavigation(
        messageType: messageType,
        messageId: uniqueId,
        url: url,
      );
      return;
    }

    // Unknown message type
    if (kDebugMode) {
      debugPrint('[Notification] Unknown message type: $messageType');
    }
  }

  static Future<void> showNotification({
    final String? title,
    final String? body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));
    final processedBody = body?.replaceAll('\n', '<br>');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: processedBody,
        actionType: actionType,
        notificationLayout: notificationLayout,
        autoDismissible: true,
        showWhen: true,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
        color:Colors.blue.shade900
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }
}
