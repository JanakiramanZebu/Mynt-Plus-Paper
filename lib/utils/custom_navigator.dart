import 'package:flutter/material.dart';

class WebNavigationHelper {
  static GlobalKey<NavigatorState>? _webNavigatorKey;
  static Function(String, {Object? arguments})? _navigateToScreen;
  static Function(String, {Object? arguments})? _replaceScreen;
  static VoidCallback? _goBack;

  // Initialize the web navigation helper with the main controller's methods
  static void initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    required Function(String, {Object? arguments}) navigateToScreen,
    required Function(String, {Object? arguments}) replaceScreen,
    required VoidCallback goBack,
  }) {
    _webNavigatorKey = navigatorKey;
    _navigateToScreen = navigateToScreen;
    _replaceScreen = replaceScreen;
    _goBack = goBack;
  }

  // Navigate to a screen in the right panel
  static void navigateTo(String routeName, {Object? arguments}) {
    if (_navigateToScreen != null) {
      _navigateToScreen!(routeName, arguments: arguments);
    }
  }

  // Replace current screen in the right panel
  static void replaceTo(String routeName, {Object? arguments}) {
    if (_replaceScreen != null) {
      _replaceScreen!(routeName, arguments: arguments);
    }
  }

  // Go back in the right panel
  static void goBack() {
    if (_goBack != null) {
      _goBack!();
    }
  }

  // Check if navigation is available
  static bool get isAvailable => _navigateToScreen != null;
}