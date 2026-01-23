import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/screens/web/ordersbook/basket/basket_list_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../sharedWidget/splash_loader.dart';
// import 'mf/mf_order_book_screen_web.dart';
// import 'mf/mf_sip_screen_web.dart';
import 'pending_alert_card_web.dart';
import 'screens/open_orders_screen.dart';
import 'screens/executed_orders_screen.dart';
import 'screens/trade_book_screen.dart';
import 'screens/gtt_orders_screen.dart';
import '../../../sharedWidget/common_search_fields_web.dart';

/// Main Order Book Screen - Now just a coordinator
/// All table logic is in separate screen widgets
class OrderBookScreenWeb extends ConsumerStatefulWidget {
  const OrderBookScreenWeb({super.key});

  @override
  ConsumerState<OrderBookScreenWeb> createState() => _OrderBookScreenWebState();
}

class _OrderBookScreenWebState extends ConsumerState<OrderBookScreenWeb>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final ScrollController _openOrdersHorizontalScrollController =
      ScrollController();
  final ScrollController _openOrdersVerticalScrollController =
      ScrollController();
  final ScrollController _executedOrdersHorizontalScrollController =
      ScrollController();
  final ScrollController _executedOrdersVerticalScrollController =
      ScrollController();
  final ScrollController _tradeBookHorizontalScrollController =
      ScrollController();
  final ScrollController _tradeBookVerticalScrollController =
      ScrollController();
  final ScrollController _gttVerticalScrollController = ScrollController();
  final ScrollController _gttHorizontalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // MF tab state
  int _mfTabIndex = 0; // 0 for Orders, 1 for SIP

  // Track initialization state
  bool _isInitialized = false;

  // Store reference to search controller for safe disposal
  TextEditingController? _orderSearchCtrl;

  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  void _updateScrollArrows() {
    if (!mounted) return;
    setState(() {
      _canScrollLeft =
          _tabScrollController.hasClients && _tabScrollController.offset > 0;
      _canScrollRight = _tabScrollController.hasClients &&
          _tabScrollController.offset <
              _tabScrollController.position.maxScrollExtent;
    });
  }

  void _scrollTabs({required bool left}) {
    if (!_tabScrollController.hasClients) return;
    final contentSize = _tabScrollController.position.viewportDimension;
    final maxScroll = _tabScrollController.position.maxScrollExtent;
    final currentScroll = _tabScrollController.offset;
    final scrollAmount = contentSize * 0.8; // Scroll 80% of view width

    double target;
    if (left) {
      target = (currentScroll - scrollAmount).clamp(0.0, maxScroll);
    } else {
      target = (currentScroll + scrollAmount).clamp(0.0, maxScroll);
    }

    _tabScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _setupListeners() {
    _tabScrollController.addListener(_updateScrollArrows);
    // Initial check
    Future.delayed(const Duration(milliseconds: 500), _updateScrollArrows);
  }

  @override
  void initState() {
    super.initState();

    // Initialize non-blocking components immediately
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Order Book Screen Web',
      screenClass: 'OrderBookScreenWeb',
    );

    // Defer heavy operations until after UI renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHeavyComponents();
      _setupSearchListener();
      _setupListeners();
    });
  }

  void _setupSearchListener() {
    if (!mounted) return;
    final orderBook = ref.read(orderProvider);
    _orderSearchCtrl = orderBook.orderSearchCtrl;
    _orderSearchCtrl?.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) return;
    final orderBook = ref.read(orderProvider);
    final context = this.context;
    if (context.mounted) {
      // Ensure _selectedTab is synced with current tab controller index
      final currentTabIndex = _tabController?.index ?? orderBook.selectedTab;
      if (currentTabIndex != orderBook.selectedTab) {
        // Sync the tab index if it's out of sync
        orderBook.changeTabIndex(currentTabIndex, context);
      }
      orderBook.searchOrders(orderBook.orderSearchCtrl.text, context);
    }
  }

  void _initializeHeavyComponents() async {
    if (!mounted) return;

    try {
      // Initialize TabController after UI renders
      final orderProviderRef = ref.read(orderProvider);
      _tabController = TabController(
        length: orderProviderRef.orderTabName.length,
        vsync: this,
        initialIndex: 0, // Always start with Open Orders tab
      );

      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          // Only call when tab change is complete, not during animation
          if (mounted) {
            final orderBook = ref.read(orderProvider);

            // Clear search when tab change completes (prevents showing wrong data)
            orderBook.clearOrderSearch();

            // Update tab index in provider - this will handle all tab-related logic
            orderBook.changeTabIndex(_tabController!.index, context);

            setState(() {
              // Trigger rebuild to update tab selection UI
            });
          }
        }
      });

      // Initialize the first tab (Open Orders) immediately to set up WebSocket
      if (mounted) {
        final orderProviderRef = ref.read(orderProvider);
        orderProviderRef.changeTabIndex(0, context);
        // Force WebSocket subscription for order tokens
        // (changeTabIndex may skip if already on tab 0, so call directly)
        orderProviderRef.requestWSOrderBook(isSubscribe: true, context: context);
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing Order Book components: $e');
      // Fallback initialization
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Remove search listener using stored reference (safe during dispose)
    _orderSearchCtrl?.removeListener(_onSearchChanged);

    _tabController?.dispose();
    _openOrdersHorizontalScrollController.dispose();
    _openOrdersVerticalScrollController.dispose();
    _executedOrdersHorizontalScrollController.dispose();
    _executedOrdersVerticalScrollController.dispose();
    _tradeBookHorizontalScrollController.dispose();
    _tradeBookVerticalScrollController.dispose();
    _gttVerticalScrollController.dispose();
    _gttHorizontalScrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    // Always show the UI structure immediately for better UX
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isInitialized
            ? _buildInitializedContent(theme)
            : _buildLoadingContent(theme),
      ),
    );
  }

  Widget _buildInitializedContent(ThemesProvider theme) {
    final orderBook = ref.read(orderProvider);

    return SizedBox.expand(
      child: RefreshIndicator(
        onRefresh: () async {
          await orderBook.fetchOrderBook(context, true);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Content Area (includes tabs and search bar)
              Expanded(
                child: _buildMainContent(theme, orderBook),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(ThemesProvider theme) {
    return const CircularLoaderImage();
  }

  Widget _buildMainContent(ThemesProvider theme, OrderProvider orderBook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs and Search Bar in same row
        _buildTabsAndActionBar(theme, orderBook),

        // Content Area - Now just delegates to separate screens
        Expanded(
          child: _buildContentArea(theme, orderBook),
        ),
      ],
    );
  }

  Widget _buildTabsAndActionBar(ThemesProvider theme, OrderProvider orderBook) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Update scroll arrows state when layout changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateScrollArrows();
          });

          final double availableWidth = constraints.maxWidth;
          double searchWidth;
          if (availableWidth >= 1100) {
            searchWidth = 400;
          } else if (availableWidth >= 800) {
            searchWidth = 300;
          } else if (availableWidth >= 500) {
            searchWidth = 200;
          } else {
            searchWidth = 140;
          }

          return Row(
            children: [
              // Shadcn TabList on the left - Direct implementation for better responsiveness
              // Wrap with shadcn.Theme to use custom primary color for active tab
              Expanded(
                child: Row(
                  children: [
                    if (availableWidth < 1300)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: _canScrollLeft
                              ? () => _scrollTabs(left: true)
                              : null,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.chevron_left,
                              size: 20,
                              color: _canScrollLeft
                                  ? (theme.isDarkMode
                                      ? Colors.white
                                      : Colors.black)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _tabScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: orderBook.orderTabName.map((tabString) {
                            final parts = tabString.text?.split(' ') ?? [];
                            final title = parts.first;
                            final badge = parts.length > 1 ? parts[1] : null;

                            final tabIndex =
                                orderBook.orderTabName.indexOf(tabString);
                            final isActive =
                                (_tabController?.index ?? 0) == tabIndex;

                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  if (_tabController != null &&
                                      _tabController!.index != tabIndex) {
                                    _tabController!.animateTo(tabIndex);
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? (theme.isDarkMode
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.05))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        title,
                                        style: MyntWebTextStyles.body(
                                          context,
                                          fontWeight: isActive
                                              ? MyntFonts.semiBold
                                              : MyntFonts.medium,
                                        ).copyWith(
                                          color: isActive
                                              ? shadcn.Theme.of(context)
                                                  .colorScheme
                                                  .foreground
                                              : shadcn.Theme.of(context)
                                                  .colorScheme
                                                  .mutedForeground,
                                        ),
                                      ),
                                      if (badge != null) ...[
                                        const SizedBox(width: 4),
                                        Transform.translate(
                                          offset: const Offset(0, -6),
                                          child: Text(
                                            badge,
                                            style: MyntWebTextStyles.bodySmall(
                                              context,
                                              fontWeight: isActive
                                                  ? MyntFonts.semiBold
                                                  : MyntFonts.medium,
                                            ).copyWith(
                                              fontSize: 13,
                                              color: isActive
                                                  ? shadcn.Theme.of(context)
                                                      .colorScheme
                                                      .foreground
                                                  : shadcn.Theme.of(context)
                                                      .colorScheme
                                                      .mutedForeground,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (availableWidth < 1300)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: _canScrollRight
                              ? () => _scrollTabs(left: false)
                              : null,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: _canScrollRight
                                  ? (theme.isDarkMode
                                      ? Colors.white
                                      : Colors.black)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Gap between tabs and search
              const SizedBox(width: 16),
              // Search Bar with MyntSearchTextField matching positions page styling
              SizedBox(
                height: 40,
                width: searchWidth,
                child: MyntSearchTextField.withSmartClear(
                  controller: orderBook.orderSearchCtrl,
                  placeholder: 'Search orders',
                  leadingIcon: assets.searchIcon,
                  onClear: () {
                    FocusScope.of(context).unfocus();
                    orderBook.clearOrderSearch();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContentArea(ThemesProvider theme, OrderProvider orderBook) {
    return IndexedStack(
      index: _tabController?.index ?? 0,
      children: [
        // Open Orders - Now uses separate screen widget
        OpenOrdersScreen(
          horizontalScrollController: _openOrdersHorizontalScrollController,
          verticalScrollController: _openOrdersVerticalScrollController,
        ),
        // Executed Orders - Now uses separate screen widget
        ExecutedOrdersScreen(
          horizontalScrollController: _executedOrdersHorizontalScrollController,
          verticalScrollController: _executedOrdersVerticalScrollController,
        ),
        // Trade Book - Now uses separate screen widget
        TradeBookScreen(
          horizontalScrollController: _tradeBookHorizontalScrollController,
          verticalScrollController: _tradeBookVerticalScrollController,
        ),
        // GTT Orders - Now uses separate screen widget
        GttOrdersScreen(
          horizontalScrollController: _gttHorizontalScrollController,
          verticalScrollController: _gttVerticalScrollController,
        ),
        // MF tab with sub tabs: Orders and SIP
        // _buildMFSubTabs(theme),
        // Basket List
        const BasketList(),
        // Pending Alerts
        const PendingAlertWeb(),
      ],
    );
  }

  // COMMENTED: MF tab functionality
  /*
  Widget _buildMFSubTabs(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shadcn TabList - Matching holdings screen style
        Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: Builder(
            builder: (context) {
              final currentTheme = shadcn.Theme.of(context);
              final isDark = theme.isDarkMode;
              // Create a new ColorScheme based on the default, but with custom primary color
              final baseColorScheme = isDark
                  ? shadcn.ColorSchemes.darkDefaultColor
                  : shadcn.ColorSchemes.lightDefaultColor;

              // Create custom ColorScheme with theme-appropriate primary color
              final primaryColor =
                  theme.isDarkMode ? WebDarkColors.primary : WebColors.primary;
              final customColorScheme = baseColorScheme.copyWith(
                primary: () => primaryColor,
              );

              return shadcn.Theme(
                data: shadcn.ThemeData(
                  colorScheme: customColorScheme,
                  radius: currentTheme.radius,
                ),
                child: shadcn.TabList(
                  index: _mfTabIndex,
                  onChanged: (value) {
                    if (mounted && _mfTabIndex != value) {
                      setState(() {
                        _mfTabIndex = value;
                      });
                    }
                  },
                  children: [
                    shadcn.TabItem(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'Geist',
                          color: _mfTabIndex == 0
                              ? (theme.isDarkMode
                                  ? WebDarkColors.primary
                                  : WebColors.primary)
                              : customColorScheme.mutedForeground,
                          fontWeight: WebFonts.bold,
                        ),
                        child: const Text('Orders'),
                      ),
                    ),
                    shadcn.TabItem(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'Geist',
                          color: _mfTabIndex == 1
                              ? (theme.isDarkMode
                                  ? WebDarkColors.primary
                                  : WebColors.primary)
                              : customColorScheme.mutedForeground,
                          fontWeight: WebFonts.bold,
                        ),
                        child: const Text('SIP'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Content Area - Use IndexedStack to keep both widgets alive
        Expanded(
          child: IndexedStack(
            index: _mfTabIndex,
            children: const [
              MfOrderBookScreenWeb(),
              MFSipdetScreenWeb(),
            ],
          ),
        ),
      ],
    );
  }
  */
}
