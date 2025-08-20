import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../themes/theme.dart';
import 'core/default_change_notifier.dart';
import 'user_profile_provider.dart';

final themeProvider = ChangeNotifierProvider((ref) => ThemesProvider(ref));

class ThemesProvider extends DefaultChangeNotifier {
  final pref = locator<Preferences>();
  ThemeMode themeMode = ThemeMode.light;
  ThemeData _currentTheme = MyThemes.lightThemebanner;
  ThemeData get currentTheme => _currentTheme;

  navigateToNewPage(BuildContext context) {
    _currentTheme = MyThemes.lightTheme;
    notifyListeners();
  }

    removeUsermatrial(BuildContext context) {
    _currentTheme = MyThemes.lightThemebanner;
    notifyListeners();
  }


  List<String> themeTypes = ["Light", "Dark"];
  String _deviceTheme = "Light";

  String get deviceTheme => _deviceTheme;

  bool get isDarkMode {
    if (pref.userAppTheme == "Dark") {
      themeMode = ThemeMode.dark;
      pref.setAppTheme("Dark");
      return themeMode == ThemeMode.dark;
    }
    //else if (pref.userAppTheme == "System Default") {
    //   final brightness = SchedulerBinding.instance.window.platformBrightness;
    //   themeMode =
    //       brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    //   pref.setTheme(themeMode == Brightness.dark ? true : false);
    //   pref.setAppTheme("System Default");
    //   return brightness == Brightness.dark;
    // }
    else {
      pref.setAppTheme("Light");
      return themeMode == ThemeMode.dark;
    }

    // return false;
  }

// Getting a default app theme

  void getThemeData() async {
    print("THEME :::  ${pref.userAppTheme} $themeMode");
    _deviceTheme = pref.userAppTheme!;
    if (pref.userAppTheme == "Dark") {
      themeMode = ThemeMode.dark;
      pref.setTheme(themeMode == ThemeMode.dark);
      log('themeMode   ::: $themeMode');
      pref.setAppTheme("Dark");
      SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.grey[800],
          systemNavigationBarIconBrightness: Brightness.light));
    }
    // else if (pref.userAppTheme == "System Default") {
    //   final brightness = SchedulerBinding.instance.window.platformBrightness;
    //   themeMode =
    //       brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    //   log('themeMode System ::: $themeMode');
    //   pref.setAppTheme("System Default");
    //    pref.setTheme(themeMode == ThemeMode.dark);
    // }
    else if (pref.userAppTheme == "Light") {
      SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark, // For Android (light icons)
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.grey[200],
          systemNavigationBarIconBrightness: Brightness.dark));
      themeMode = ThemeMode.light;
      pref.setTheme(themeMode == ThemeMode.dark);
      pref.setAppTheme("Light");
    }
  }

// Set app theme mode

  set isDarkMode(bool value) {
    themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme({required String themeMod}) {
    pref.setAppTheme(themeMod);
    final brightness = SchedulerBinding.instance.window.platformBrightness;
    themeMode =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    if (pref.userAppTheme == "Dark") {
      SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.grey[800],
          systemNavigationBarIconBrightness: Brightness.light));
      _deviceTheme = "Dark";
      themeMode = ThemeMode.dark;
      pref.setTheme(true);
    } else if (pref.userAppTheme == "Light") {
      SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark, // For Android (light icons)
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.grey[200],
          systemNavigationBarIconBrightness: Brightness.dark));
      _deviceTheme = "Light";
      themeMode = ThemeMode.light;
      pref.setTheme(false);
    }
    // else {
    //   _deviceTheme = "System Default";
    //   final brightness = SchedulerBinding.instance.window.platformBrightness;
    // themeMode = brightness == Brightness.dark
    //     ? ThemeMode.dark
    //    : ThemeMode.light;

    //          pref.setTheme(brightness == Brightness.dark);
    // }
    ref.read(userProfileProvider).fetchsetting();
    notifyListeners();
  }

  final Ref ref;
  ThemesProvider(this.ref);
}
