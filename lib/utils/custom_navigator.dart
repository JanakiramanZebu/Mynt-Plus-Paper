import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../routes/route_names.dart';
import '../routes/web_router.dart';

// Conditional import for web URL manipulation
import 'url_strategy_stub.dart' if (dart.library.html) 'url_strategy_web.dart'
    as url_strategy;

class WebNavigationHelper {
  // ignore: unused_field
  static GlobalKey<NavigatorState>? _webNavigatorKey;
  static Function(String, {Object? arguments})? _navigateToScreen;
  static Function(String, {Object? arguments})? _replaceScreen;
  static VoidCallback? _goBack;
  // ignore: unused_field
  static BuildContext? _context;

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

  // Set context for URL updates (call this from widget's build method)
  static void setContext(BuildContext context) {
    _context = context;
  }

  // Navigate to a screen in the right panel
  static void navigateTo(String routeName, {Object? arguments}) {
    if (_navigateToScreen != null) {
      _navigateToScreen!(routeName, arguments: arguments);
      // Update browser URL for web
      _updateUrlForRoute(routeName);
    }
  }

  // Replace current screen in the right panel
  static void replaceTo(String routeName, {Object? arguments}) {
    if (_replaceScreen != null) {
      _replaceScreen!(routeName, arguments: arguments);
      // Update browser URL for web
      _updateUrlForRoute(routeName);
    }
  }

  // Go back in the right panel
  static void goBack() {
    if (_goBack != null) {
      _goBack!();
    }
  }

  // Update browser URL based on route name (web only)
  static void _updateUrlForRoute(String routeName) {
    if (!kIsWeb) return;

    final urlPath = _routeNameToUrlPath(routeName);
    if (urlPath != null) {
      updateUrl(urlPath);
    }
  }

  // Map route names to URL paths
  static String? _routeNameToUrlPath(String routeName) {
    switch (routeName) {
      case Routes.holdingscreen: // 'HoldingScreen'
      case 'holdings':
        return WebRoutes.holdings;
      case Routes.positionscreen: // 'PositionScreen'
      case 'positions':
        return WebRoutes.positions;
      case Routes.orderBook: // 'orderBook'
        return WebRoutes.orders;
      case Routes.fundscreen: // 'fundscreen'
      case 'funds':
        return WebRoutes.funds;
      case Routes.ipo: // 'Ipo'
      case 'ipo':
        return WebRoutes.ipo;
      case Routes.mfmainscreen:
      case 'mutualFunds':
        return WebRoutes.mutualFunds;
      case 'reports':
        return WebRoutes.reports;
      case 'optionChain':
        return WebRoutes.optionChain;
      case 'dashboard':
        return WebRoutes.home;
      default:
        return null;
    }
  }

  /// Update browser URL WITHOUT triggering GoRouter navigation
  /// This uses the browser's History API directly to avoid widget rebuilds
  static void updateUrl(String urlPath) {
    if (!kIsWeb) return;
    try {
      url_strategy.updateBrowserUrl(urlPath);
      debugPrint('WebNavigationHelper: Updated URL to $urlPath');
    } catch (e) {
      debugPrint('WebNavigationHelper: Failed to update URL: $e');
    }
  }

  // Check if navigation is available
  static bool get isAvailable => _navigateToScreen != null;
}
