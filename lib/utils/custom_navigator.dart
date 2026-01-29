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

  // Cancel function for popstate listener
  static Function? _cancelPopStateListener;

  // Callback for handling browser back/forward navigation
  static Function(String urlPath)? _onBrowserNavigation;

  // Flag to track if we're handling browser back/forward navigation
  // When true, URL updates should be skipped to preserve forward history
  static bool _isHandlingBrowserNavigation = false;

  /// Check if currently handling browser back/forward navigation
  static bool get isHandlingBrowserNavigation => _isHandlingBrowserNavigation;

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

    // Set up browser back/forward listener for web
    if (kIsWeb) {
      _setupPopStateListener();
    }
  }

  /// Set up listener for browser back/forward button
  static void _setupPopStateListener() {
    // Cancel any existing listener
    _cancelPopStateListener?.call();

    _cancelPopStateListener = url_strategy.onPopState((String path) {
      debugPrint('WebNavigationHelper: Browser navigation to $path');
      _handleBrowserNavigation(path);
    });
  }

  /// Handle browser back/forward navigation
  static void _handleBrowserNavigation(String urlPath) {
    // Set flag to prevent URL updates during browser navigation
    // This preserves forward history when pressing back button
    _isHandlingBrowserNavigation = true;
    debugPrint('WebNavigationHelper: Browser navigation started to $urlPath');

    try {
      // Notify external listener if registered
      if (_onBrowserNavigation != null) {
        _onBrowserNavigation!(urlPath);
        return;
      }

      // Default handling: navigate to screen based on URL
      final routeName = _urlPathToRouteName(urlPath);
      if (routeName != null && _replaceScreen != null) {
        // Use replaceScreen to avoid adding another history entry
        _replaceScreen!(routeName);
        debugPrint('WebNavigationHelper: Navigated to $routeName from browser back/forward');
      }
    } finally {
      // Reset flag after a longer delay to allow all navigation callbacks
      // and GoRouter widget rebuilds to complete
      // Using 500ms to ensure all async frame callbacks have executed
      Future.delayed(const Duration(milliseconds: 500), () {
        _isHandlingBrowserNavigation = false;
        debugPrint('WebNavigationHelper: Browser navigation handling complete');
      });
    }
  }

  /// Register callback for browser navigation events
  /// This allows the main screen controller to handle navigation
  static void setOnBrowserNavigation(Function(String urlPath)? callback) {
    _onBrowserNavigation = callback;
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

  // Map URL paths back to route names (for browser back/forward)
  static String? _urlPathToRouteName(String urlPath) {
    // Remove leading slash if present
    final path = urlPath.startsWith('/') ? urlPath : '/$urlPath';

    switch (path) {
      case WebRoutes.holdings:
        return 'holdings';
      case WebRoutes.positions:
        return 'positions';
      case WebRoutes.orders:
        return Routes.orderBook;
      case WebRoutes.funds:
        return 'funds';
      case WebRoutes.ipo:
        return 'ipo';
      case WebRoutes.mutualFunds:
        return 'mutualFunds';
      case WebRoutes.reports:
        return 'reports';
      case WebRoutes.optionChain:
        return 'optionChain';
      case WebRoutes.home:
      case '/':
        return 'dashboard';
      default:
        return null;
    }
  }

  /// Update browser URL WITHOUT triggering GoRouter navigation
  /// This uses the browser's History API directly to avoid widget rebuilds
  /// Skips update if currently handling browser back/forward to preserve forward history
  static void updateUrl(String urlPath) {
    if (!kIsWeb) return;

    // Skip URL update if we're handling browser back/forward navigation
    // This prevents clearing forward history when pressing back button
    if (_isHandlingBrowserNavigation) {
      debugPrint('WebNavigationHelper: Skipping URL update (handling browser navigation)');
      return;
    }

    try {
      url_strategy.updateBrowserUrl(urlPath);
      debugPrint('WebNavigationHelper: Updated URL to $urlPath');
    } catch (e) {
      debugPrint('WebNavigationHelper: Failed to update URL: $e');
    }
  }

  /// Replace URL without adding to history (for redirects)
  static void replaceUrl(String urlPath) {
    if (!kIsWeb) return;
    try {
      url_strategy.replaceBrowserUrl(urlPath);
      debugPrint('WebNavigationHelper: Replaced URL to $urlPath');
    } catch (e) {
      debugPrint('WebNavigationHelper: Failed to replace URL: $e');
    }
  }

  /// Get current browser URL path
  static String getCurrentPath() {
    if (!kIsWeb) return '';
    return url_strategy.getCurrentPath();
  }

  // Check if navigation is available
  static bool get isAvailable => _navigateToScreen != null;

  /// Clean up resources
  static void dispose() {
    _cancelPopStateListener?.call();
    _cancelPopStateListener = null;
    _onBrowserNavigation = null;
  }
}
