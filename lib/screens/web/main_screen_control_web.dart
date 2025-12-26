import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/dashboard_screen.dart';
import 'package:mynt_plus/screens/web/market_watch/watchlist_screen_web.dart';
import 'package:mynt_plus/screens/Mobile/portfolio_screens/portfolio_screen.dart';
import 'package:mynt_plus/screens/Mobile/profile_screen/profile_main_screen.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/web_resources.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/routes/app_routes.dart';
import 'package:mynt_plus/utils/custom_navigator.dart';

class MainControlerScreenForWeb extends ConsumerStatefulWidget {
  const MainControlerScreenForWeb({super.key});

  @override
  ConsumerState<MainControlerScreenForWeb> createState() =>
      _MainControlerScreenForWebState();
}

class _MainControlerScreenForWebState
    extends ConsumerState<MainControlerScreenForWeb> {
  int selectedTab = 0; // 0: Home, 1: Watchlist, 2: Portfolio, 3: Profile

  // Navigation state for right panel
  final GlobalKey<NavigatorState> _rightPanelNavigatorKey =
      GlobalKey<NavigatorState>();
  String _currentRoute = '/dashboard';

  // Split panel state
  double _splitRatio = 0.3; // 30% left, 70% right
  bool _isPanelsSwapped = false;
  bool _isDraggingSplitter = false;
  static const double _minPanelWidth = 200.0;
  static const double _splitterWidth = 6.0;

  @override
  void initState() {
    super.initState();

    // Set initial route based on selected tab
    _updateRouteForTab();

    // Initialize WebNavigationHelper after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WebNavigationHelper.initialize(
        navigatorKey: _rightPanelNavigatorKey,
        navigateToScreen: navigateToScreen,
        replaceScreen: replaceScreen,
        goBack: goBack,
      );
    });
  }

  void navigateInRightPanel(String route, {Object? arguments}) {
    setState(() {
      _currentRoute = route;
    });
  }

  // Update current route based on selected tab
  void _updateRouteForTab() {
    String newRoute;
    switch (selectedTab) {
      case 0:
        newRoute = '/dashboard';
        break;
      case 1:
        newRoute = '/watchlist';
        break;
      case 2:
        newRoute = '/portfolio';
        break;
      case 3:
        newRoute = '/profile';
        break;
      default:
        newRoute = '/dashboard';
    }

    if (_currentRoute != newRoute) {
      setState(() {
        _currentRoute = newRoute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mynt Plus Web"),
        actions: [
          _buildNavButton(0, assets.home, "Home", theme),
          // _buildNavButton(1, assets.watchlistIcon, "Watchlist", theme),
          _buildNavButton(2, assets.portfolioIcon, "Portfolio", theme),
          _buildNavButton(3, assets.profileIcon, "Profile", theme),
          const SizedBox(width: 16),
          // Panel swap button
          IconButton(
            onPressed: _swapPanels,
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Swap Panels',
            style: IconButton.styleFrom(
              backgroundColor: _isPanelsSwapped
                  ? (theme.isDarkMode
                      ? WebColors.primaryLight.withOpacity(0.1)
                      : WebColors.primary.withOpacity(0.1))
                  : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResizableSplitView(constraints);
          },
        ),
      ),
    );
  }

  // Build navigation button for app bar
  Widget _buildNavButton(
      int index, String iconAsset, String label, ThemesProvider theme) {
    final isSelected = selectedTab == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          if (mounted) {
            setState(() {
              selectedTab = index;
            });
            _updateRouteForTab();
            
            // Navigate in the right panel
            if (_rightPanelNavigatorKey.currentState != null) {
              _rightPanelNavigatorKey.currentState!
                  .pushReplacementNamed(_currentRoute);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebColors.primaryLight.withOpacity(0.1)
                    : WebColors.primary.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: theme.isDarkMode
                        ? WebColors.primaryLight
                        : WebColors.primary,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconAsset,
                height: 20,
                colorFilter: ColorFilter.mode(_getNavButtonColor(theme, isSelected), BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: _getNavButtonColor(theme, isSelected),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get color for navigation button
  Color _getNavButtonColor(ThemesProvider theme, bool isSelected) {
    if (theme.isDarkMode && isSelected) {
      return WebColors.primaryLight;
    } else if (theme.isDarkMode && !isSelected) {
      return WebDarkColors.textSecondary;
    } else if (!theme.isDarkMode && isSelected) {
      return WebColors.primary;
    } else {
      return WebColors.textSecondary;
    }
  }

  // Build the resizable split view
  Widget _buildResizableSplitView(BoxConstraints constraints) {
    final leftWidth = _splitRatio * constraints.maxWidth;
    final rightWidth = constraints.maxWidth - leftWidth - _splitterWidth;

    return Row(
      children: [
        // Left panel
        SizedBox(
          width: leftWidth,
          child: _getLeftPanel(),
        ),
        // Resizable splitter
        _buildSplitter(constraints),
        // Right panel
        SizedBox(
          width: rightWidth,
          child: _getRightPanel(),
        ),
      ],
    );
  }

  // Build the draggable splitter
  Widget _buildSplitter(BoxConstraints constraints) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDraggingSplitter = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          final newSplitRatio =
              (details.globalPosition.dx / constraints.maxWidth).clamp(
                  _minPanelWidth / constraints.maxWidth,
                  1.0 -
                      (_minPanelWidth + _splitterWidth) / constraints.maxWidth);
          _splitRatio = newSplitRatio;
        });
      },
      onPanEnd: (details) {
        setState(() {
          _isDraggingSplitter = false;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: _splitterWidth,
          color: _isDraggingSplitter
              ? WebColors.primary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          child: Center(
            child: Container(
              width: 2,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Get left panel content (considering swap)
  Widget _getLeftPanel() {
    if (_isPanelsSwapped) {
      return _getTabContentWithNavigator();
    } else {
      return const WatchListScreenWeb();
    }
  }

  // Get right panel content (considering swap)
  Widget _getRightPanel() {
    if (_isPanelsSwapped) {
      return const WatchListScreenWeb();
    } else {
      return _getTabContentWithNavigator();
    }
  }

  // Swap panels
  void _swapPanels() {
    setState(() {
      _isPanelsSwapped = !_isPanelsSwapped;
    });
  }

  // Get content with Navigator for proper routing
  Widget _getTabContentWithNavigator() {
    return Container(
      key: ValueKey(_currentRoute), // Force rebuild when route changes
      child: Navigator(
        key: _rightPanelNavigatorKey,
        initialRoute: _currentRoute,
        onGenerateRoute: (settings) {
          return _generateRightPanelRoute(settings);
        },
      ),
    );
  }

  // Generate routes for right panel navigator
  Route<dynamic> _generateRightPanelRoute(RouteSettings settings) {
    Widget page;

    // Handle main tab navigation first
    if (_isTabRoute(settings.name)) {
      page = _getTabContent();
    } else {
      // Handle app navigation routes dynamically
      try {
        final route = AppRoutes.router(RouteSettings(
          name: settings.name,
          arguments: settings.arguments,
        ));

        if (route is MaterialPageRoute) {
          page = Container(
            constraints: const BoxConstraints.expand(),
            child: route.builder(context),
          );
        } else if (route is PageRouteBuilder) {
          page = Container(
            constraints: const BoxConstraints.expand(),
            child: route.pageBuilder(context, const AlwaysStoppedAnimation(1.0),
                const AlwaysStoppedAnimation(0.0)),
          );
        } else {
          page = _getTabContent();
        }
      } catch (e) {
        page = _getTabContent();
      }
    }

    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }

  // Check if the route is a tab route
  bool _isTabRoute(String? routeName) {
    return routeName == '/dashboard' ||
        routeName == '/watchlist' ||
        routeName == '/portfolio' ||
        routeName == '/profile' ||
        routeName == null;
  }

  // Get content for right panel based on selected tab
  Widget _getTabContent() {
    switch (selectedTab) {
      case 0:
        return Container(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: const DashboardScreen(),
          ),
        );
      case 1:
        return Container(
          constraints: const BoxConstraints.expand(),
          child: const WatchListScreenWeb(),
        );
      case 2:
        return Container(
          constraints: const BoxConstraints.expand(),
          child: const PortfolioScreen(),
        );
      case 3:
        return Container(
          constraints: const BoxConstraints.expand(),
          child: const UserAccountScreen(),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: const DashboardScreen(),
          ),
        );
    }
  }

  // Method to handle app navigation from anywhere in the app
  void navigateToScreen(String routeName, {Object? arguments}) {
    if (_rightPanelNavigatorKey.currentState != null) {
      _rightPanelNavigatorKey.currentState!.pushNamed(
        routeName,
        arguments: arguments,
      );
    }
  }

  // Method to replace current screen in right panel
  void replaceScreen(String routeName, {Object? arguments}) {
    if (_rightPanelNavigatorKey.currentState != null) {
      _rightPanelNavigatorKey.currentState!.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    }
  }

  // Method to go back in right panel
  void goBack() {
    if (_rightPanelNavigatorKey.currentState != null &&
        _rightPanelNavigatorKey.currentState!.canPop()) {
      _rightPanelNavigatorKey.currentState!.pop();
    }
  }
}