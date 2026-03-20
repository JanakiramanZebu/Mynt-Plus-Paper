import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/web/customizable_split_home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/web/authentication/login/login_web.dart';
import '../screens/web/scalper/scalper_screen_web.dart';
import '../utils/custom_navigator.dart';
import '../main.dart' show registerWebNavigatorKey;

/// GoRouter for web - enables URL synchronization with browser
/// Only used when kIsWeb is true
///
/// This router handles URL-based navigation for the web app:
/// - `/splash` → Splash screen (entry point)
/// - `/login` → Login screen
/// - `/` → Main dashboard (after login)
/// - `/holdings` → Holdings screen in right panel
/// - `/positions` → Positions screen in right panel
/// - `/orders` → Order book in right panel
/// - `/funds` → Funds screen in right panel
/// - `/option-chain` → Option chain in right panel

/// Route paths for web
class WebRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/';
  static const String holdings = '/holdings';
  static const String positions = '/positions';
  static const String orders = '/orders';
  static const String funds = '/funds';
  static const String optionChain = '/option-chain';
  static const String ipo = '/ipo';
  static const String mutualFunds = '/mutual-funds';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String portfolioAnalysis = '/portfolio-analysis';
  static const String strategyBuilder = '/strategy-builder';
  static const String scalper = '/scalper';
  static const String tradingViewWebHook = '/tradingview-webhook';
  static const String basketDashboard = '/basket-dashboard';
}

/// Global GoRouter instance for web
/// Access via context.go() or context.push() methods
late final GoRouter webRouter;

/// Navigator key for web - used for showing dialogs from sheets/overlays
final GlobalKey<NavigatorState> webNavigatorKey = GlobalKey<NavigatorState>();

/// Initialize the web router
/// Call this in main() before runApp() when kIsWeb is true
void initializeWebRouter() {
  // Register webNavigatorKey with main.dart's helper functions
  // This allows getNavigatorKey()/getNavigatorContext() to work on web
  registerWebNavigatorKey(() => webNavigatorKey);

  webRouter = GoRouter(
    navigatorKey: webNavigatorKey,
    initialLocation: WebRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    routes: [
      // Splash screen - entry point
      GoRoute(
        path: WebRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login screen (web-specific)
      GoRoute(
        path: WebRoutes.login,
        builder: (context, state) => const LoginScreenWeb(),
      ),

      // Main home/dashboard route
      GoRoute(
        path: WebRoutes.home,
        builder: (context, state) => const CustomizableSplitHomeScreen(),
      ),

      // Holdings screen
      GoRoute(
        path: WebRoutes.holdings,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.holdings,
        ),
      ),

      // Positions screen
      GoRoute(
        path: WebRoutes.positions,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.positions,
        ),
      ),

      // Orders/Order book screen
      GoRoute(
        path: WebRoutes.orders,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.orderBook,
        ),
      ),

      // Funds screen
      GoRoute(
        path: WebRoutes.funds,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.funds,
        ),
      ),

      // Option chain screen
      GoRoute(
        path: WebRoutes.optionChain,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.optionChain,
        ),
      ),

      // IPO screen
      GoRoute(
        path: WebRoutes.ipo,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.ipo,
        ),
      ),

      // Mutual Funds screen
      GoRoute(
        path: WebRoutes.mutualFunds,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.mutualFund,
        ),
      ),

      // Reports screen
      GoRoute(
        path: WebRoutes.reports,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.reports,
        ),
      ),

      // Portfolio Analysis screen
      GoRoute(
        path: WebRoutes.portfolioAnalysis,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.portfolioAnalysis,
        ),
      ),

      // Strategy Builder screen - wrapped in home screen for session validation & web layout
      GoRoute(
        path: WebRoutes.strategyBuilder,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.strategyBuilder,
        ),
      ),

      // TradingView WebHook screen
      GoRoute(
        path: WebRoutes.tradingViewWebHook,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.tradingViewWebHook,
        ),
      ),

      // Basket Dashboard screen
      GoRoute(
        path: WebRoutes.basketDashboard,
        builder: (context, state) => const CustomizableSplitHomeScreen(
          initialRightPanel: ScreenTypeParam.basketDashboard,
        ),
      ),

      // Scalper screen - standalone full-screen trading interface
      GoRoute(
        path: WebRoutes.scalper,
        builder: (context, state) => const ScalperScreenWeb(),
      ),
    ],

    // Handle unknown routes - redirect to home
    errorBuilder: (context, state) => const CustomizableSplitHomeScreen(),
  );
}

/// Extension to update URL without full navigation
/// Use this to sync URL when panel navigation happens internally
extension WebRouterExtension on BuildContext {
  /// Update browser URL and ADD to history stack (enables back button)
  /// Uses WebNavigationHelper which handles platform differences
  void updateWebUrl(String path) {
    if (kIsWeb) {
      WebNavigationHelper.updateUrl(path);
    }
  }

  /// Replace current URL without adding to history
  /// Use this for URL updates that shouldn't be back-navigable
  void replaceWebUrl(String path) {
    if (kIsWeb) {
      WebNavigationHelper.replaceUrl(path);
    }
  }

  /// Get current route path
  String get currentPath {
    if (kIsWeb) {
      return WebNavigationHelper.getCurrentPath();
    }
    return GoRouterState.of(this).uri.path;
  }
}
