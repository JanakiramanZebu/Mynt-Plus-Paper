import 'dart:developer';
import 'dart:io';
// import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mynt_plus/firebase_options.dart';
import 'package:mynt_plus/locator/constant.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mynt_plus/notification/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'locator/locator.dart';
import 'locator/preference.dart';
import 'provider/core/screen_timeout_observer.dart';
import 'provider/thems.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
import 'themes/theme.dart';

// used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');

    message.data["imageUrl"] != ""
        ? NotificationService.showNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            summary: "Mynt",
            notificationLayout: NotificationLayout.BigPicture,
            bigPicture: message.data["imageUrl"],
            payload: {"navigate": "true", "url": message.data["url"]})
        : NotificationService.showNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            summary: "Mynt",
            notificationLayout: NotificationLayout.Default,
          );
  }
}

// This method represents the project's entry level.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  setupLocator();

  await NotificationService.initializeNotification();
  // NotificationService().initNotification();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: "dev project",options: DefaultFirebaseOptions.currentPlatform);
//  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Preferences pref = locator<Preferences>();
  await pref.init();

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
// It requests a registration token for sending messages to users from your App server or other trusted server environment.
  ConstantName.msgToken = await messaging.getToken();

  log("Token ${ConstantName.msgToken}");
  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.getInitialMessage().then((value) async {
    if (value != null) {
      final Uri url = Uri.parse(value.data["url"]);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((event) async {
    final Uri url = Uri.parse(event.data["url"]);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Message $message");
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
      print('Message notification: ${message.data["imageUrl"]}');
    }

    message.data["imageUrl"] != ""
        ? NotificationService.showNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            summary: "Mynt+",
            notificationLayout: NotificationLayout.BigPicture,
            bigPicture: message.data["imageUrl"],
            payload: {"navigate": "true", "url": message.data["url"]})
        : NotificationService.showNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            summary: "Mynt+",
            notificationLayout: NotificationLayout.Default);

    // NotificationService().showNotification(
    //     title: message.notification?.title, body: message.notification?.body);
    _messageStreamController.sink.add(message);
  });
  runApp(Phoenix(child: ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  // final FirebaseAnalytics analytics;
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final themeProvide = watch(themeProvider);
    themeProvide.getThemeData();
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarIconBrightness: themeProvide.isDarkMode
    //         ? Brightness.light
    //         : Brightness.dark, // For Android (dark icons)
    //     statusBarBrightness:
    //         themeProvide.isDarkMode ? Brightness.light : Brightness.dark,
    //     statusBarColor: themeProvide.isDarkMode ? Colors.black :Colors.white));
    return MaterialApp(
        themeMode: themeProvide.themeMode,
        theme: themeProvide.currentTheme,
        darkTheme: MyThemes.darkTheme,
        title: 'MYNT',
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRoutes.router,
  //       navigatorObservers: [
  //   FirebaseAnalyticsObserver(analytics: analytics,),
  //   ScreenTimeRouteObserver(), // <-- here
  // ],
  );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
