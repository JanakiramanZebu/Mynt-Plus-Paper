import 'dart:developer';
// Conditional import for HttpOverrides only on non-web platforms
import 'package:flutter/foundation.dart'
    show PlatformDispatcher, TargetPlatform, defaultTargetPlatform, kIsWeb;
// ignore: uri_does_not_exist
import 'utils/http_overrides_stub.dart'
    if (dart.library.io) 'utils/http_overrides.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:mynt_plus/firebase_options.dart';
import 'package:mynt_plus/locator/constant.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/chart_overlay_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'package:mynt_plus/notification/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'locator/locator.dart';
import 'locator/preference.dart';
import 'provider/thems.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
import 'themes/theme.dart';

// Global route observer to allow screens to react to navigation events
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Global provider to track Firebase initialization status
final firebaseInitializedProvider = StateProvider<bool>((ref) => false);

// Helper class for Firebase operations
class FirebaseHelper {
  // Static variable to track initialization status
  static bool _isInitialized = false;

  // Check if Firebase is initialized
  static bool isInitialized() {
    return _isInitialized;
  }

  // Mark Firebase as initialized
  static void setInitialized(bool value) {
    _isInitialized = value;

    // Also update the provider if possible
    try {
      final container = ProviderContainer();
      container.read(firebaseInitializedProvider.notifier).state = value;
    } catch (e) {
      // Silently handle provider update errors
      print("Provider update error: $e");
    }
  }
}

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
  if (!kIsWeb) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

// Separated Firebase initialization function for better control and performance
Future<void> initializeFirebaseAsync() async {
  final firebaseStartTime = DateTime.now();
  print("Firebase initialization started at: $firebaseStartTime");

  try {
    // Initialize Firebase with appropriate platform options
    if (TargetPlatform.android == defaultTargetPlatform) {
      await Firebase.initializeApp(
          name: "dev project", options: DefaultFirebaseOptions.currentPlatform);
    } else {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

    final coreInitTime = DateTime.now();
    final coreInitDuration = coreInitTime.difference(firebaseStartTime);
    print("Firebase core initialized in: ${coreInitDuration.inMilliseconds}ms");

    final Preferences pref = locator<Preferences>();

    // Only enable Crashlytics on mobile platforms (not web)
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      FirebaseCrashlytics.instance
          .setUserIdentifier("${pref.deviceName!} ${pref.imei}");
    }

    // Configure messaging
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

    // Get token for messaging
    ConstantName.msgToken = await messaging.getToken();
    log("Token ${ConstantName.msgToken}");

    // Configure background messaging handler (not supported on web)
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }

    // Handle notification click when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        if (message.data["url"] != null) {
          final Uri url = Uri.parse(message.data["url"]);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            print("Could not launch URL");
          }
        }
      }
    });

    // Handle notification click when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      if (message.data["url"] != null) {
        final Uri url = Uri.parse(message.data["url"]);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          print("Could not launch URL");
        }
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!kIsWeb) {
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

    // Update initialization state after successful Firebase initialization
    FirebaseHelper.setInitialized(true);

    final firebaseEndTime = DateTime.now();
    final totalFirebaseDuration = firebaseEndTime.difference(firebaseStartTime);
    print(
        "Firebase fully initialized in: ${totalFirebaseDuration.inMilliseconds}ms");
  } catch (e) {
    print("Firebase initialization error: $e");
    // Don't update the provider state if initialization fails
  }
}

void _clearBadgeOnStartup() async {
  // await AwesomeNotifications().cancelAll();
  await AwesomeNotifications().resetGlobalBadge();
}

// This method represents the project's entry level.
void main() async {
  // Track startup time
  final startTime = DateTime.now();
  print("App startup began at: $startTime");

  WidgetsFlutterBinding.ensureInitialized();
  initializeResources();
  if (!kIsWeb && TargetPlatform.android == defaultTargetPlatform) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  if (!kIsWeb) {
    applyHttpOverrides();
  }
  setupLocator();
  await NotificationService.initializeNotification();

  final Preferences pref = locator<Preferences>();
  await pref.init();
  try {
    _clearBadgeOnStartup();
  } catch (e) {
    print("Error in notification clearing $e");
  }
  // Run the app first without waiting for Firebase
  final beforeFirebase = DateTime.now();
  final startupDuration = beforeFirebase.difference(startTime);
  print("App ready to launch in: ${startupDuration.inMilliseconds}ms");

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const ProviderScope(child: MyApp()));

  // Initialize Firebase after the app has started (non-blocking)
  initializeFirebaseAsync();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the entire provider for web to ensure proper theme updates
    // For mobile, we optimize by only watching themeMode
    final themeProvide = kIsWeb
        ? ref.watch(themeProvider) // Web: watch entire provider for theme sync
        : ref.read(themeProvider); // Mobile: read once for performance

    final themeMode = ref.watch(themeProvider.select((t) => t.themeMode));
    themeProvide.getThemeData();

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarIconBrightness: themeProvide.isDarkMode
    //         ? Brightness.light
    //         : Brightness.dark, // For Android (dark icons)
    //     statusBarBrightness:
    //         themeProvide.isDarkMode ? Brightness.light : Brightness.dark,
    //     statusBarColor: themeProvide.isDarkMode ? Colors.black :Colors.white));

    // Use ShadcnApp for web, MaterialApp for mobile
    if (kIsWeb) {
      return shadcn.ShadcnApp(
        navigatorKey: rootNavigatorKey,
        title: 'MYNT',
        debugShowCheckedModeBanner: false,
        theme: shadcn.ThemeData(
          colorScheme: themeProvide
              .getShadcnColorScheme(), // Use provider method for proper sync
          radius: 0,
          // Note: shadcn components inherit from DefaultTextStyle belowz
          // If shadcn.ThemeData supports textTheme, you can set it here
        ),
        initialRoute: Routes.splash,
        onGenerateRoute: AppRoutes.router,
        navigatorObservers: [routeObserver],
        // builder: (context, child) {
        //   return shadcn.DrawerOverlay(
        //     child: Stack(
        //       children: [
        //         MediaQuery(
        //           data: MediaQuery.of(context).copyWith(
        //             textScaler: const TextScaler.linear(1.0),
        //           ),
        //           child: DefaultTextStyle(
        //             style: TextStyle(
        //               fontFamily: 'Geist',
        //               fontFeatures: const [FontFeature.proportionalFigures()],
        //             ),
        //             child: child!,
        //           ),
        //         ),
        //         const ChartOverlayWidget(),
        //       ],
        //     ),
        //   );
        // },
      );
    } else {
      return MaterialApp(
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        themeMode: themeMode,
        theme: themeProvide.currentTheme,
        darkTheme: MyThemes.darkTheme,
        title: 'MYNT',
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRoutes.router,
        navigatorObservers: [routeObserver],
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              const ChartOverlayWidget(),
            ],
          );
        },
      );
    }
  }
}

// HttpOverrides implementation moved to `utils/http_overrides.dart` with a web stub
