import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/web/ordersbook/basket/basket_list_web.dart';

import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/splash_loader.dart';
import 'mf/mf_order_book_screen_web.dart';
import 'mf/mf_sip_screen_web.dart';
import 'pending_alert_card_web.dart';
import 'screens/open_orders_screen.dart';
import 'screens/executed_orders_screen.dart';
import 'screens/trade_book_screen.dart';
import 'screens/gtt_orders_screen.dart';

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
  final ScrollController _openOrdersHorizontalScrollController = ScrollController();
  final ScrollController _openOrdersVerticalScrollController = ScrollController();
  final ScrollController _executedOrdersHorizontalScrollController = ScrollController();
  final ScrollController _executedOrdersVerticalScrollController = ScrollController();
  final ScrollController _tradeBookHorizontalScrollController = ScrollController();
  final ScrollController _tradeBookVerticalScrollController = ScrollController();
  final ScrollController _gttVerticalScrollController = ScrollController();
  final ScrollController _gttHorizontalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // MF tab state
  int _mfTabIndex = 0; // 0 for Orders, 1 for SIP

  // Track initialization state
  bool _isInitialized = false;

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
    });
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
            setState(() {
              // Trigger rebuild to update tab selection UI
            });
          }
          ref
              .read(orderProvider)
              .changeTabIndex(_tabController!.index, context);
        }
      });

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
          padding: const EdgeInsets.all(16.0),
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

        const SizedBox(height: 16),

        // Content Area - Now just delegates to separate screens
        _buildContentArea(theme, orderBook),
      ],
    );
  }

  Widget _buildTabsAndActionBar(ThemesProvider theme, OrderProvider orderBook) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Segmented Control Tabs on the left
        _buildSegmentedControl(theme, orderBook),
        // Fixed spacing instead of Spacer to avoid excessive gap
        const SizedBox(width: 16),
        // Search Bar with max width constraint
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            height: 40,
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? WebDarkColors.inputBackground
                  : WebColors.inputBackground,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.inputBorder
                    : WebColors.inputBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                SvgPicture.asset(
                  assets.searchIcon,
                  width: 20,
                  height: 20,
                  fit: BoxFit.scaleDown,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: orderBook.orderSearchCtrl,
                    autofocus: false,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    style: WebTextStyles.formInput(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search orders',
                      hintStyle: WebTextStyles.formInput(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      orderBook.searchOrders(value, context);
                    },
                  ),
                ),
                if (orderBook.orderSearchCtrl.text.isNotEmpty)
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        orderBook.clearOrderSearch();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          assets.removeIcon,
                          width: 20,
                          height: 20,
                          fit: BoxFit.scaleDown,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl(ThemesProvider theme, OrderProvider orderBook) {
    return SizedBox(
      height: 45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: orderBook.orderTabName.asMap().entries.map((entry) {
                final index = entry.key;
                final tabString = entry.value;
                final isSelected = (_tabController?.index ?? 0) == index;

                final parts = tabString.text?.split(' ') ?? [];
                final title = parts.first;
                final badge = parts.length > 1 ? parts[1] : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildSegmentedTab(
                    title,
                    badge,
                    index,
                    isSelected,
                    theme,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab(
    String title,
    String? badge,
    int index,
    bool isSelected,
    ThemesProvider theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          if (_tabController != null && _tabController!.index != index) {
            _tabController!.animateTo(index);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: WebTextStyles.tab(
                  isDarkTheme: theme.isDarkMode,
                  color: isSelected
                      ? (theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary)
                      : (theme.isDarkMode
                          ? WebDarkColors.navItem
                          : WebColors.navItem),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Text(
                  '($badge)',
                  style: WebTextStyles.tab(
                    isDarkTheme: theme.isDarkMode,
                    color: isSelected
                        ? (theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary)
                        : (theme.isDarkMode
                            ? WebDarkColors.navItem
                            : WebColors.navItem),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea(ThemesProvider theme, OrderProvider orderBook) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        const padding = 32.0;
        const headerHeight = 50.0;
        const spacing = 16.0;
        const bottomMargin = 20.0;
        final tableHeight =
            screenHeight - padding - headerHeight - spacing - bottomMargin;

        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        return SizedBox(
          height: calculatedHeight.toDouble(),
          child: IndexedStack(
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
              _buildMFSubTabs(theme),
              // Basket List
              const BasketList(),
              // Pending Alerts
              const PendingAlertWeb(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMFSubTabs(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented Control Tabs
        _buildMFSegmentedControl(theme),
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

  Widget _buildMFSegmentedControl(ThemesProvider theme) {
    final tabs = ['Orders', 'SIP'];

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 45,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(tabs.length, (index) {
                  final isSelected = _mfTabIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildMFSegmentedTab(
                      tabs[index],
                      index,
                      isSelected,
                      theme,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMFSegmentedTab(
    String title,
    int index,
    bool isSelected,
    ThemesProvider theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => setState(() => _mfTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
