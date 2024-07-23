import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'locator/locator.dart';
import 'locator/preference.dart';
import 'provider/thems.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
import 'themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  setupLocator();

  await Upgrader.clearSavedSettings();
  final Preferences pref = locator<Preferences>();
  await pref.init();

  runApp(Phoenix(child: const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final themeProvide = watch(themeProvider);
    themeProvide.getThemeData();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: themeProvide.isDarkMode
            ? Brightness.light
            : Brightness.dark, // For Android (dark icons)
        statusBarBrightness:
            themeProvide.isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: themeProvide.isDarkMode ? Colors.black :Colors.white));
    return MaterialApp(
        themeMode: themeProvide.themeMode,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        title: 'MYNT +',
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
