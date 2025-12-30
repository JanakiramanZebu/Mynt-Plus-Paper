// import 'dart:convert';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings("@mipmap/ic_launcher");

//     var initializationSettingsIOS = DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//         onDidReceiveLocalNotification:
//             (int id, String? title, String? body, String? payload) async {});

//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await notificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse:
//             (NotificationResponse notificationResponse) async {});
//   }

//   notificationDetails() {
//     return const NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName',
//             importance: Importance.max, playSound: false),
//         iOS: DarwinNotificationDetails());
//   }

//   Future showNotification(
//       {int id = 1014, String? title, String? body, String? payLoad, required String url}) async {
//          final http.Response response = await http.get(Uri.parse(url));
//     BigPictureStyleInformation bigPictureStyleInformation =
//         BigPictureStyleInformation(
//       ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
//       largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(image)),
//     );
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
// }
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final notificationservice = ChangeNotifierProvider((ref) => NotificationService(ref));

class NotificationService extends ChangeNotifier {
  final Ref ref;
  NotificationService(this.ref);
  static Future<void> initializeNotification() async {
    if (kIsWeb) {
      // Web: local notifications via awesome_notifications are not supported.
      // Firebase Messaging will handle notifications.
      return;
    }
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
            icon: "resource://drawable/res_notification_app_icon")
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
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    debugPrint('payload $payload');
    if (payload["navigate"] == "true") {
      final Uri url = Uri.parse(payload['url']!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
      // MainApp.navigatorKey.currentState?.push(
      //   MaterialPageRoute(
      //     builder: (_) => const SecondScreen(),
      //   ),
      // );
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

    if (kIsWeb) {
      // On web we skip local notifications and rely on push/UI.
      return;
    }
    // If a big picture is provided but layout is default, upgrade layout automatically
    final layout = (bigPicture != null && notificationLayout == NotificationLayout.Default) ? NotificationLayout.BigPicture : notificationLayout;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'high_importance_channel',
          title: title,
          body: processedBody,
          actionType: actionType,
          notificationLayout: layout,
          autoDismissible: true,
          showWhen: true,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture,
          // icon: "resource://drawable/res_notification_app_icon",
          color: Colors.blue.shade900),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }
}
