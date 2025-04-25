import 'dart:developer';
import 'dart:io';
// import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'provider/thems.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
import 'themes/theme.dart';

// used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();

// Create a dedicated function for handling notification messages
void handleNotificationMessage(RemoteMessage message) {
  // Consistent notification display logic
  if (message.data["imageUrl"] != null && message.data["imageUrl"] != "") {
    NotificationService.showNotification(
      title: message.notification?.title,
      body: message.notification?.body?.replaceAll("  ", "\n"),
      notificationLayout: NotificationLayout.BigPicture,
      bigPicture: message.data["imageUrl"],
      payload: {"navigate": "true", "url": message.data["url"]},
    );
  } else {
    NotificationService.showNotification(
      title: message.notification?.title,
      body: message.notification?.body?.replaceAll("  ", "\n"),
      notificationLayout: NotificationLayout.BigText,
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}


// This method represents the project's entry level.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  setupLocator();
  await NotificationService.initializeNotification();
  WidgetsFlutterBinding.ensureInitialized();
  if (TargetPlatform.android == defaultTargetPlatform) {
    await Firebase.initializeApp(
        name: "dev project", options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  final Preferences pref = locator<Preferences>();
  await pref.init();
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
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

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.getInitialMessage().then((message) async {
  if (message != null) {
    // Handle notification click when app was terminated
    if (message.data["url"] != null) {
      final Uri url = Uri.parse(message.data["url"]);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        print("Could not launch URL");
      }
    }
  }
});
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
  // Handle notification click when app was in background
  if (message.data["url"] != null) {
    final Uri url = Uri.parse(message.data["url"]);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print("Could not launch URL");
    }
  }
});
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (kDebugMode) {
    print("Message $message");
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
    print('Message notification: ${message.data["imageUrl"]}');
  }
  
  handleNotificationMessage(message);
  _messageStreamController.sink.add(message);
});
  runApp(Phoenix(child: const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
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
        onGenerateRoute: AppRoutes.router);
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
