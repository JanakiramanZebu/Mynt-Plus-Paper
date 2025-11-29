import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:mynt_plus/screens/web/ordersbook/basket/basket_list_web.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/splash_loader.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/order_book_model/trade_book_model.dart';
import '../../../models/order_book_model/gtt_order_book.dart';
import 'mf/mf_order_book_screen_web.dart';
import 'mf/mf_sip_screen_web.dart';
// import '../order_book/filter_scrip_bottom_sheet.dart';
import 'pending_alert_card_web.dart';
import 'order_book_detail_screen_web.dart';
import 'trade_book_detail_screen_web.dart';
import 'gtt_order_book_detail_screen_web.dart';
import 'modify_gtt_web.dart';
import '../order/modify_place_order_web_screen.dart';
import '../order/place_order_screen_web.dart';
import '../../../utils/responsive_navigation.dart';
import '../../../utils/responsive_snackbar.dart';

class OrderBookScreenWeb extends ConsumerStatefulWidget {
  const OrderBookScreenWeb({super.key});

  @override
  ConsumerState<OrderBookScreenWeb> createState() => _OrderBookScreenWebState();
}

class _OrderBookScreenWebState extends ConsumerState<OrderBookScreenWeb>
    with TickerProviderStateMixin {
  final Set<int> _selectedOrders = <int>{};
  TabController?
      _tabController; // Make nullable to allow deferred initialization
  StreamSubscription? _socketSubscription;
  final ScrollController _openOrdersHorizontalScrollController = ScrollController();
  final ScrollController _openOrdersVerticalScrollController = ScrollController();
  final ScrollController _executedOrdersHorizontalScrollController = ScrollController();
  final ScrollController _executedOrdersVerticalScrollController = ScrollController();
  final ScrollController _tradeBookHorizontalScrollController = ScrollController();
  final ScrollController _tradeBookVerticalScrollController =
      ScrollController();
  final ScrollController _gttVerticalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  String? _hoveredRowToken; // Track which row is being hovered

  // Track processing states for order actions
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingOrderToken; // Track which order is being processed

  // Draggable dialog positions
  Offset _modifyDialogPosition = const Offset(100, 100);
  Offset _placeOrderDialogPosition = const Offset(150, 150);

  // Sort state per table
  int? _orderSortColumnIndex;
  bool _orderSortAscending = true;
  int? _tradeSortColumnIndex;
  bool _tradeSortAscending = true;
  int? _gttSortColumnIndex;
  bool _gttSortAscending = true;

  // GTT new implementation -------------

  // Scroll controllers for vertical and horizontal scroll
// final ScrollController _gttVerticalScrollController = ScrollController();
  final ScrollController _gttHorizontalScrollController = ScrollController();

// Hover + processing tokens (you already have similar; keep or override)
// String? _hoveredRowToken;
// String? _processingOrderToken;
// bool _isProcessingCancel = false;
// bool _isProcessingModify = false;

// Make sure these exist (you already had these; if not, add them)
// int? _gttSortColumnIndex;
// bool _gttSortAscending = true;

// Selected rows if you use it (you used `_selectedOrders` earlier)
// final Set<int> _selectedOrders = {};

// -------------------------------------------------------------gtt new implementation end -------------

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
        initialIndex: orderProviderRef.selectedTab,
      );

      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          // Only call when tab change is complete, not during animation
          ref
              .read(orderProvider)
              .changeTabIndex(_tabController!.index, context);
        }
      });

      // Set up WebSocket subscription
      _setupSocketSubscription();

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
    _socketSubscription?.cancel();
    _tabController?.dispose(); // Handle nullable TabController
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

  void _setupSocketSubscription() {
    Future.microtask(() {
      final socketProvider = ref.read(websocketProvider);

      _socketSubscription =
          socketProvider.socketDataStream.listen((socketDatas) {
        if (socketDatas.isEmpty) return;

        if (mounted) {
          _processUpdates(socketDatas);
        }
      });
    });
  }

  void _processUpdates(Map socketDatas) {
    // Check if widget is still mounted before accessing providers
    if (!mounted) return;

    bool hasUpdates = false;
    final orderBook = ref.read(orderProvider);

    // Helper function to check if a string is a valid numeric price
    bool isValidNumeric(String? value) {
      if (value == null || value == "null") {
        return false;
      }
      return double.tryParse(value) != null;
    }

    // Update order book with LTP changes
    _updateOrderBook(orderBook, socketDatas, isValidNumeric,
        (updated) => hasUpdates = hasUpdates || updated);

    // Update trade book with LTP changes
    _updateTradeBook(orderBook, socketDatas, isValidNumeric,
        (updated) => hasUpdates = hasUpdates || updated);

    // Update GTT order book with LTP changes
    _updateGttOrderBook(orderBook, socketDatas, isValidNumeric,
        (updated) => hasUpdates = hasUpdates || updated);

    // Notify listener if there were updates
    if (hasUpdates && mounted) {
      setState(() {});
    }
  }

  void _updateOrderBook(OrderProvider orderBook, Map socketDatas,
      bool Function(String?) isValidNumeric, Function(bool) setHasUpdates) {
    // Update open orders
    if (orderBook.openOrder != null) {
      for (var order in orderBook.openOrder!) {
        if (order.token == null || order.token!.isEmpty) continue;
        if (!socketDatas.containsKey(order.token)) continue;

        final socketData = socketDatas[order.token];
        if (socketData == null || socketData.isEmpty) continue;

        final lp = socketData['lp']?.toString();
        if (isValidNumeric(lp) && lp != order.ltp) {
          order.ltp = lp;
          setHasUpdates(true);
        }

        final chng = socketData['chng']?.toString();
        if (isValidNumeric(chng) && chng != order.change) {
          order.change = chng;
          setHasUpdates(true);
        }

        final pc = socketData['pc']?.toString();
        if (isValidNumeric(pc) && pc != order.perChange) {
          order.perChange = pc;
          setHasUpdates(true);
        }
      }
    }

    // Update executed orders
    if (orderBook.executedOrder != null) {
      for (var order in orderBook.executedOrder!) {
        if (order.token == null || order.token!.isEmpty) continue;
        if (!socketDatas.containsKey(order.token)) continue;

        final socketData = socketDatas[order.token];
        if (socketData == null || socketData.isEmpty) continue;

        final lp = socketData['lp']?.toString();
        if (isValidNumeric(lp) && lp != order.ltp) {
          order.ltp = lp;
          setHasUpdates(true);
        }
      }
    }

    // Update search items
    if (orderBook.orderSearchItem != null) {
      for (var order in orderBook.orderSearchItem!) {
        if (order.token == null || order.token!.isEmpty) continue;
        if (!socketDatas.containsKey(order.token)) continue;

        final socketData = socketDatas[order.token];
        if (socketData == null || socketData.isEmpty) continue;

        final lp = socketData['lp']?.toString();
        if (isValidNumeric(lp) && lp != order.ltp) {
          order.ltp = lp;
          setHasUpdates(true);
        }
      }
    }
  }

  void _updateTradeBook(OrderProvider orderBook, Map socketDatas,
      bool Function(String?) isValidNumeric, Function(bool) setHasUpdates) {
    if (orderBook.tradeBook != null) {
      for (var trade in orderBook.tradeBook!) {
        if (trade.token == null || trade.token!.isEmpty) continue;
        if (!socketDatas.containsKey(trade.token)) continue;

        final socketData = socketDatas[trade.token];
        if (socketData == null || socketData.isEmpty) continue;

        final lp = socketData['lp']?.toString();
        if (isValidNumeric(lp) && lp != trade.ltp) {
          trade.ltp = lp;
          setHasUpdates(true);
        }

        final chng = socketData['chng']?.toString();
        if (isValidNumeric(chng) && chng != trade.change) {
          trade.change = chng;
          setHasUpdates(true);
        }

        final pc = socketData['pc']?.toString();
        if (isValidNumeric(pc) && pc != trade.perChange) {
          trade.perChange = pc;
          setHasUpdates(true);
        }
      }
    }

    if (orderBook.tradeBooksearch != null) {
      for (var trade in orderBook.tradeBooksearch!) {
        if (trade.token == null || trade.token!.isEmpty) continue;
        if (!socketDatas.containsKey(trade.token)) continue;

        final socketData = socketDatas[trade.token];
        if (socketData == null || socketData.isEmpty) continue;

        final lp = socketData['lp']?.toString();
        if (isValidNumeric(lp) && lp != trade.ltp) {
          trade.ltp = lp;
          setHasUpdates(true);
        }

        final chng = socketData['chng']?.toString();
        if (isValidNumeric(chng) && chng != trade.change) {
          trade.change = chng;
          setHasUpdates(true);
        }

        final pc = socketData['pc']?.toString();
        if (isValidNumeric(pc) && pc != trade.perChange) {
          trade.perChange = pc;
          setHasUpdates(true);
        }
      }
    }
  }

  void _updateGttOrderBook(OrderProvider orderBook, Map socketDatas,
      bool Function(String?) isValidNumeric, Function(bool) setHasUpdates) {
    if (orderBook.gttOrderBookModel != null) {
      for (var gttOrder in orderBook.gttOrderBookModel!) {
        if (gttOrder.token == null || gttOrder.token!.isEmpty) continue;
        if (!socketDatas.containsKey(gttOrder.token)) continue;

        final socketData = socketDatas[gttOrder.token];
        if (socketData == null || socketData.isEmpty) continue;

        final lp = socketData['lp']?.toString();
        if (isValidNumeric(lp) && lp != gttOrder.ltp) {
          gttOrder.ltp = lp;
          setHasUpdates(true);
        }

        final chng = socketData['chng']?.toString();
        if (isValidNumeric(chng) && chng != gttOrder.change) {
          gttOrder.change = chng;
          setHasUpdates(true);
        }

        final pc = socketData['pc']?.toString();
        if (isValidNumeric(pc) && pc != gttOrder.perChange) {
          gttOrder.perChange = pc;
          setHasUpdates(true);
        }
      }
    }

    if (orderBook.gttOrderBookSearch != null) {
      for (var gttOrder in orderBook.gttOrderBookSearch!) {
        if (gttOrder.token == null || gttOrder.token!.isEmpty) continue;
        if (!socketDatas.containsKey(gttOrder.token)) continue;

        final socketData = socketDatas[gttOrder.token];
        if (socketData == null || socketData.isEmpty) continue;

        final lp = socketData['lp']?.toString();
        if (isValidNumeric(lp) && lp != gttOrder.ltp) {
          gttOrder.ltp = lp;
          setHasUpdates(true);
        }

        final chng = socketData['chng']?.toString();
        if (isValidNumeric(chng) && chng != gttOrder.change) {
          gttOrder.change = chng;
          setHasUpdates(true);
        }

        final pc = socketData['pc']?.toString();
        if (isValidNumeric(pc) && pc != gttOrder.perChange) {
          gttOrder.perChange = pc;
          setHasUpdates(true);
        }
      }
    }
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
    final orderBook = ref.watch(orderProvider);

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

  Widget _buildHeader(ThemesProvider theme, OrderProvider orderBook) {
    // This method is kept but not used directly - tabs and search are now in _buildTabsAndActionBar
    return const SizedBox.shrink();
  }

  Widget _buildMainContent(ThemesProvider theme, OrderProvider orderBook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs and Search Bar in same row
        _buildTabsAndActionBar(theme, orderBook),

        const SizedBox(height: 16),

        // Content Area
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
                      // All tabs now use the standard search method in provider
                      // This is faster because filtering happens in provider, not in build
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
          // Left arrow button
          // _buildTabArrowButton(
          //   icon: Icons.chevron_left,
          //   onPressed: () => _scrollTabsLeft(),
          //   theme: theme,
          // ),
          // const SizedBox(width: 5),
          // Tabs scrollable area
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
                final isLast = index == orderBook.orderTabName.length - 1;

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
                    isLast,
                    theme,
                  ),
                );
              }).toList(),
            ),
          ),
          // const SizedBox(width: 5),
          // Right arrow button
          // _buildTabArrowButton(
          //   icon: Icons.chevron_right,
          //   onPressed: () => _scrollTabsRight(),
          //   theme: theme,
          // ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab(
    String title,
    String? badge,
    int index,
    bool isSelected,
    bool isLast,
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
    // Calculate table height based on available screen space
    // Use LayoutBuilder to get actual available constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height: screen height minus all UI elements
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = 32.0; // Top and bottom padding (16 * 2)
        final headerHeight = 50.0; // Header height (tabs + search bar)
        final spacing = 16.0; // Spacing between header and content
        final bottomMargin = 20.0; // Bottom margin to prevent overflow
        final tableHeight =
            screenHeight - padding - headerHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height to prevent overflow
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        return SizedBox(
          height: calculatedHeight.toDouble(),
          child: IndexedStack(
            index: _tabController?.index ?? 0,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: _buildOrderBookTable(
                  theme,
                  (orderBook.orderSearchCtrl.text.isNotEmpty
                      ? (orderBook.orderSearchItem ?? [])
                      : (orderBook.openOrder ?? [])),
                  'Open Orders',
                  _openOrdersHorizontalScrollController,
                  _openOrdersVerticalScrollController,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: _buildOrderBookTable(
                  theme,
                  (orderBook.orderSearchCtrl.text.isNotEmpty
                      ? (orderBook.orderSearchItem ?? [])
                      : (orderBook.executedOrder ?? [])),
                  'Executed Orders',
                  _executedOrdersHorizontalScrollController,
                  _executedOrdersVerticalScrollController,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: _buildTradeBookTable(
                  theme,
                  (orderBook.orderSearchCtrl.text.isNotEmpty
                      ? (orderBook.tradeBooksearch ?? [])
                      : (orderBook.tradeBook ?? [])),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: _buildGttOrderBookTable(
                  theme,
                  (orderBook.orderSearchCtrl.text.isNotEmpty
                      ? (orderBook.gttOrderBookSearch ?? [])
                      : (orderBook.gttOrderBookModel ?? [])),
                ),
              ),
              // MF tab with sub tabs: Orders and SIP
              _buildMFSubTabs(theme),
              // IPO Orders placeholder
              // const IpoOrderBookScreenWeb(),
              // Bonds Orders placeholder
              // const BondsOrderBookScreenWeb(),
              const BasketList(),
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
            // Left arrow button
            // _buildTabArrowButton(
            //   icon: Icons.chevron_left,
            //   onPressed: () => _scrollTabsLeft(),
            //   theme: theme,
            // ),
            // const SizedBox(width: 5),
            // Tabs scrollable area
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
            // const SizedBox(width: 5),
            // Right arrow button
            // _buildTabArrowButton(
            //   icon: Icons.chevron_right,
            //   onPressed: () => _scrollTabsRight(),
            //   theme: theme,
            // ),
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

  Widget _buildOrderBookTable(
      ThemesProvider theme, 
      List<OrderBookModel> orders, 
      String title,
      ScrollController horizontalScrollController,
      ScrollController verticalScrollController) {
    final orderBook = ref.watch(orderProvider);

    // Show loading indicator if data is being fetched and no existing data
    if (orders.isEmpty) {
      if (orderBook.loading) {
        return const SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading orders...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox(
          height: 400,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: NoDataFound(),
            ),
          ),
        );
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = 32.0; // Top and bottom padding (16 * 2)
        final headerHeight = 50.0; // Header height (tabs + search bar)
        final spacing = 16.0; // Spacing between header and content
        final bottomMargin = 20.0; // Bottom margin
        final tableHeight =
            screenHeight - padding - headerHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveOrderBookColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            height: calculatedHeight.toDouble(),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: theme.isDarkMode
                  ? WebDarkColors.background
                  : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  // Make both scrollbars always visible
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                  
                  // Consistent thickness for both horizontal and vertical
                  thickness: MaterialStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  
                  // Consistent radius
                  radius: const Radius.circular(3),
                  
                  // Consistent colors for both scrollbars
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  
                  trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0,
                ),
              ),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1840,
                sortColumnIndex: _orderSortColumnIndex,
                sortAscending: _orderSortAscending,
                fixedLeftColumns: 1, // Fix the first column (Instrument)
                fixedColumnsColor: theme.isDarkMode 
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                showBottomBorder: true,
                horizontalScrollController: horizontalScrollController,
                scrollController: verticalScrollController,
                showCheckboxColumn: false,
                headingRowColor: MaterialStateProperty.all(
                  theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary.withOpacity(0.05),
                ),
                headingTextStyle: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                dataTextStyle: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                border: TableBorder(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  horizontalInside: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  // Remove vertical lines
                ),
                columns: _buildOrderBookDataTable2Columns(headers, columnMinWidth, theme),
                rows: _buildOrderBookDataTable2Rows(orders, headers, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  int _getOrderBookColumnIndexForHeader(String header) {
    switch (header) {
      case 'Instrument': return 0;
      case 'Product': return 1;
      case 'Type': return 2;
      case 'Qty': return 3;
      case 'Avg price': return 4;
      case 'LTP': return 5;
      case 'Price': return 6;
      case 'Trigger price': return 7;
      case 'Order value': return 8;
      case 'Status': return 9;
      case 'Time': return 10;
      default: return -1;
    }
  }

  List<DataColumn2> _buildOrderBookDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
  ) {
    return headers.map((header) {
      final columnIndex = _getOrderBookColumnIndexForHeader(header);
      final isInstrument = header == 'Instrument';
      final isTime = header == 'Time';
      
      return DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              header,
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildOrderBookSortIcon(columnIndex, theme),
          ],
        ),
        size: isInstrument ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isInstrument ? 300.0 : (isTime ? 220.0 : null),
        onSort: (index, ascending) => _onSortOrderTable(columnIndex, ascending),
      );
    }).toList();
  }

  List<DataRow2> _buildOrderBookDataTable2Rows(
    List<OrderBookModel> orders,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = _sortedOrders(orders);
    return sorted.map((order) {
      final uniqueId = order.norenordno?.toString() ??
          order.token?.toString() ??
          '';
      final isHovered = _hoveredRowToken == uniqueId;

      return DataRow2(
        color: MaterialStateProperty.resolveWith((states) {
          if (isHovered) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return null;
        }),
        cells: headers.map((header) {
          return _buildOrderBookDataTable2Cell(
            header,
            order,
            theme,
            isHovered,
            uniqueId,
          );
        }).toList(),
        onTap: () => _openOrderDetail(order),
      );
    }).toList();
  }

  DataCell _buildOrderBookDataTable2Cell(
    String column,
    OrderBookModel order,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId,
  ) {
    Widget cellContent;
    
    switch (column) {
      case 'Instrument':
        cellContent = _buildOrderBookInstrumentCellContent(
          order,
          theme,
          isHovered,
          uniqueId,
        );
        break;
      case 'Product':
        cellContent = _buildOrderBookTextCell(
          order.sPrdtAli ?? order.prd ?? 'N/A',
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Type':
        final buySell = order.trantype == "S" ? "SELL" : "BUY";
        final buttonColor = order.trantype == "S"
            ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
            : (theme.isDarkMode ? colors.profitDark : colors.profitLight);
        cellContent = _buildOrderBookTextCell(
          buySell,
          theme,
          Alignment.centerLeft,
          color: buttonColor,
        );
        break;
      case 'Qty':
        cellContent = _buildOrderBookTextCell(
          order.qty?.toString() ?? '0',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Avg price':
        cellContent = _buildOrderBookTextCell(
          order.avgprc ?? '0.00',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'LTP':
        cellContent = _buildOrderBookTextCell(
          _getValidLTP(order),
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Price':
        cellContent = _buildOrderBookTextCell(
          _getValidPrice(order),
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Trigger price':
        final triggerPrice = (order.trgprc != null && 
            order.trgprc != '0' && 
            order.trgprc != '0.00') 
            ? order.trgprc! 
            : '0.00';
        cellContent = _buildOrderBookTextCell(
          triggerPrice,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Order value':
        String orderValue = '0.00';
        try {
          double price = double.tryParse(order.avgprc ?? "0") ?? 0.0;
          int qty = int.tryParse(order.qty.toString()) ?? 0;
          orderValue = (price * qty).toStringAsFixed(2);
        } catch (e) {
          orderValue = '0.00';
        }
        cellContent = _buildOrderBookTextCell(
          orderValue,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Status':
        final statusText = _getStatusText(order);
        final statusColor = _getStatusColor(statusText, theme);
        cellContent = _buildOrderBookTextCell(
          statusText,
          theme,
          Alignment.centerLeft,
          color: statusColor,
        );
        break;
      case 'Time':
        final time = order.norentm != null ? order.norentm! : '0.00';
        cellContent = _buildOrderBookTextCell(
          formatDateTime(value: time),
          theme,
          Alignment.centerLeft,
        );
        break;
      default:
        cellContent = const SizedBox.shrink();
    }

    // Wrap with MouseRegion to detect hover anywhere on the cell
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: cellContent,
        ),
      ),
    );
  }

  Widget _buildOrderBookInstrumentCellContent(
    OrderBookModel order,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId,
  ) {
    final isProcessing = _processingOrderToken == uniqueId;
    final isPending = order.status == "PENDING" ||
        order.status == "OPEN" ||
        order.status == "TRIGGER_PENDING";

    String symbol = '${order.tsym ?? ''}';
    String exchange = order.exch ?? '';
    String displayText = symbol.trim();
    if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
      displayText += ' ${exchange.trim()}';
    }

    return Row(
      children: [
        Expanded(
          flex: isHovered ? 1 : 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: displayText,
              child: Text(
                displayText,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        // Action buttons fade in on hover
        IgnorePointer(
          ignoring: !isHovered,
          child: AnimatedOpacity(
            opacity: isHovered ? 1 : 0,
            duration: const Duration(milliseconds: 140),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending) ...[
                  _buildOrderHoverButton(
                    label: 'Cancel',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.error
                        : WebColors.error,
                    onPressed: isProcessing && _isProcessingCancel
                        ? null
                        : () => _handleCancelOrder(order),
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildOrderHoverButton(
                    label: 'Modify',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                    onPressed: isProcessing && _isProcessingModify
                        ? null
                        : () => _handleModifyOrder(order),
                    theme: theme,
                  ),
                ] else ...[
                  _buildOrderHoverButton(
                    label: 'Repeat',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                    onPressed: () => _handleRepeatOrder(order),
                    theme: theme,
                  ),
                  if (order.status == "OPEN") ...[
                    const SizedBox(width: 6),
                    _buildOrderHoverButton(
                      label: 'Cancel',
                      color: Colors.white,
                      backgroundColor: theme.isDarkMode
                          ? WebDarkColors.error
                          : WebColors.error,
                      onPressed: isProcessing && _isProcessingCancel
                          ? null
                          : () => _handleCancelOrder(order),
                      theme: theme,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderBookSortIcon(int columnIndex, ThemesProvider theme) {
    if (_orderSortColumnIndex == columnIndex) {
      return const SizedBox(width: 16); // Reserve space for DataTable2's arrow
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode
            ? WebDarkColors.iconSecondary
            : WebColors.iconSecondary,
      );
    }
  }



  Widget _buildOrderBookTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Text(
          text,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: color ??
                (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary),
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1, 
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildTradeBookTable(
      ThemesProvider theme, List<TradeBookModel> trades) {
    final orderBook = ref.watch(orderProvider);

    // Show loading indicator if data is being fetched and no existing data
    if (trades.isEmpty) {
      if (orderBook.loading) {
        return const SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading trades...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox(
          height: 400,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: NoDataFound(),
            ),
          ),
        );
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveTradeBookColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
        // Calculate height based on available space
        final calculatedHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : 600.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            height: calculatedHeight.toDouble(),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: theme.isDarkMode
                  ? WebDarkColors.background
                  : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  // Make both scrollbars always visible
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                  
                  // Consistent thickness for both horizontal and vertical
                  thickness: MaterialStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  
                  // Consistent radius
                  radius: const Radius.circular(3),
                  
                  // Consistent colors for both scrollbars
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  
                  trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0,
                ),
              ),
              child: DataTable2(
                columns: _buildTradeBookDataTable2Columns(headers, columnMinWidth, theme),
                rows: _buildTradeBookDataTable2Rows(trades, headers, theme),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1200,
                sortColumnIndex: _tradeSortColumnIndex,
                sortAscending: _tradeSortAscending,
                fixedLeftColumns: 1, // Fix Instrument column
                fixedColumnsColor: theme.isDarkMode 
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                headingRowColor: MaterialStateProperty.all(
                  theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary.withOpacity(0.05),
                ),
                headingTextStyle: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                dataTextStyle: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                border: TableBorder(
                  top: BorderSide(
                    color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
                    width: 1,
                  ),
                  horizontalInside: BorderSide(
                    color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
                    width: 1,
                  ),
                  // Removed verticalInside, left, right to remove vertical lines
                ),
                showBottomBorder: true,
                horizontalScrollController: _tradeBookHorizontalScrollController,
                scrollController: _tradeBookVerticalScrollController,
                showCheckboxColumn: false,
              ),
            ),
          ),
        );
      },
    );
  }

  int _getTradeBookColumnIndexForHeader(String header) {
    switch (header) {
      case 'Instrument': return 0;
      case 'Product': return 1;
      case 'Type': return 2;
      case 'Qty': return 3;
      case 'Price': return 4;
      case 'Trade value': return 5;
      case 'Order no': return 6;
      case 'Time': return 7;
      default: return -1;
    }
  }

  List<DataColumn2> _buildTradeBookDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
  ) {
    return headers.map((header) {
      final columnIndex = _getTradeBookColumnIndexForHeader(header);
      final isInstrument = header == 'Instrument';
      final isTime = header == 'Time';
      
      return DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              header,
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildTradeBookSortIcon(columnIndex, theme),
          ],
        ),
        size: isInstrument ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isInstrument ? 300.0 : (isTime ? 220.0 : null),
        onSort: (index, ascending) => _onSortTradeTable(columnIndex, ascending),
      );
    }).toList();
  }

  List<DataRow2> _buildTradeBookDataTable2Rows(
    List<TradeBookModel> trades,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = _sortedTrades(trades);
    return sorted.map((trade) {
      final token = trade.token ?? '';
      final index = sorted.indexOf(trade);
      final uniqueId = '$token$index';
      final isHovered = _hoveredRowToken == uniqueId;

      return DataRow2(
        cells: headers.map((header) {
          Widget cellContent;
          switch (header) {
            case 'Instrument':
              cellContent = _buildTradeBookInstrumentCellContent(trade, theme, uniqueId);
              break;
            case 'Product':
              cellContent = _buildTradeBookTextCell(
                trade.sPrdtAli ?? 'N/A',
                theme,
                Alignment.centerLeft,
              );
              break;
            case 'Type':
              final buySell = trade.trantype == "S" ? "SELL" : "BUY";
              final textColor = trade.trantype == "S"
                  ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
                  : (theme.isDarkMode ? colors.profitDark : colors.profitLight);
              cellContent = _buildTradeBookTextCell(
                buySell,
                theme,
                Alignment.centerLeft,
                color: textColor,
              );
              break;
            case 'Qty':
              cellContent = _buildTradeBookTextCell(
                trade.qty?.toString() ?? 'N/A',
                theme,
                Alignment.centerRight,
              );
              break;
            case 'Price':
              cellContent = _buildTradeBookTextCell(
                trade.avgprc?.toString() ?? 'N/A',
                theme,
                Alignment.centerRight,
              );
              break;
            case 'Trade value':
              String tradeValue = "0.00";
              try {
                if (trade.flqty != null && trade.flprc != null) {
                  tradeValue = (double.parse(trade.flqty!) * double.parse(trade.flprc!))
                      .toStringAsFixed(2);
                }
              } catch (e) {
                tradeValue = "0.00";
              }
              cellContent = _buildTradeBookTextCell(
                tradeValue,
                theme,
                Alignment.centerRight,
              );
              break;
            case 'Order no':
              cellContent = _buildTradeBookTextCell(
                trade.norenordno?.toString() ?? 'N/A',
                theme,
                Alignment.centerLeft,
              );
              break;
            case 'Time':
              final time = trade.norentm != null ? trade.norentm! : 'N/A';
              cellContent = _buildTradeBookTextCell(
                formatDateTime(value: time),
                theme,
                Alignment.centerLeft,
              );
              break;
            default:
              cellContent = const SizedBox.shrink();
          }
          
          return DataCell(
            MouseRegion(
              onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
              onExit: (_) => setState(() => _hoveredRowToken = null),
              child: SizedBox.expand(
                child: cellContent,
              ),
            ),
          );
        }).toList(),
        color: MaterialStateProperty.resolveWith((states) {
          if (isHovered) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return null;
        }),
        onTap: () => _openTradeDetail(trade),
      );
    }).toList();
  }

  Widget _buildTradeBookSortIcon(int columnIndex, ThemesProvider theme) {
    if (_tradeSortColumnIndex == columnIndex) {
      return const SizedBox(width: 16); // Reserve space for DataTable2's arrow
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
      );
    }
  }

  Widget _buildTradeBookInstrumentCellContent(
    TradeBookModel trade,
    ThemesProvider theme,
    String uniqueId,
  ) {
    final symbol = trade.symbol?.replaceAll("-EQ", "") ?? trade.tsym ?? 'N/A';
    final expDate = trade.expDate ?? '';
    final option = trade.option ?? '';
    String displayText = symbol;
    if (expDate.isNotEmpty) {
      displayText += ' $expDate';
    }
    if (option.isNotEmpty) {
      displayText += ' $option';
    }
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: displayText,
        child: Text(
          displayText,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }



  Widget _buildTradeBookTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Text(
          text,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: color ??
                (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary),
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1, 
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  // Helper method to get responsive column configuration for Trade Book
  // Always show all columns - horizontal scroll handles overflow on small screens
  Map<String, dynamic> _getResponsiveTradeBookColumns(double screenWidth) {
    return {
      'headers': ['Instrument', 'Product', 'Type', 'Qty', 'Price', 'Trade value', 'Order no', 'Time'],
      'columnFlex': {
        'Instrument': 3,
        'Product': 2,
        'Type': 2,
        'Qty': 1,
        'Price': 2,
        'Trade value': 2,
        'Order no': 2,
        'Time': 2,
      },
      'columnMinWidth': {
        'Instrument': 300,
        'Product': 110,
        'Type': 90,
        'Qty': 80,
        'Price': 100,
        'Trade value': 130,
        'Order no': 120,
        'Time': 220,
      },
    };
  }

  // Helper method to get responsive column configuration for Order Book
  // Always show all columns - horizontal scroll handles overflow on small screens
  Map<String, dynamic> _getResponsiveOrderBookColumns(double screenWidth) {
    return {
      'headers': ['Instrument', 'Product', 'Type', 'Qty', 'Avg price', 'LTP', 'Price', 'Trigger price', 'Order value', 'Status', 'Time'],
      'columnMinWidth': {
        'Instrument': 300,
        'Product': 110,
        'Type': 90,
        'Qty': 80,
        'Avg price': 120,
        'LTP': 100,
        'Price': 100,
        'Trigger price': 150,
        'Order value': 130,
        'Status': 110,
        'Time': 220,
      },
    };
  }

  // Helper method to get responsive column configuration for GTT
  // Always show all columns - horizontal scroll handles overflow on small screens
  Map<String, dynamic> _getResponsiveGttColumns(double screenWidth) {
    return {
      'headers': ['Instrument', 'Product', 'Type', 'Qty', 'LTP', 'Trigger', 'Status', 'Time'],
      'columnMinWidth': {
        'Instrument': 300,
        'Product': 110,
        'Type': 90,
        'Qty': 80,
        'LTP': 100,
        'Trigger': 120,
        'Status': 110,
        'Time': 220,
      },
    };
  }

  int _getGttColumnIndexForHeader(String header) {
    switch (header) {
      case 'Instrument': return 0;
      case 'Product': return 1;
      case 'Type': return 2;
      case 'Qty': return 3;
      case 'LTP': return 4;
      case 'Trigger': return 5;
      case 'Status': return 6;
      case 'Time': return 7;
      default: return -1;
    }
  }

  List<DataColumn2> _buildGttDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
  ) {
    return headers.map((header) {
      final columnIndex = _getGttColumnIndexForHeader(header);
      final isInstrument = header == 'Instrument';
      final isTime = header == 'Time';
      
      return DataColumn2(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              header,
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            _buildGttSortIcon(columnIndex, theme),
          ],
        ),
        size: isInstrument ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isInstrument ? 300.0 : (isTime ? 220.0 : null),
        onSort: (index, ascending) => _onSortGttTable(columnIndex, ascending),
      );
    }).toList();
  }

  List<DataRow2> _buildGttDataTable2Rows(
    List<GttOrderBookModel> gttOrders,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = _sortedGtt(gttOrders);
    return sorted.map((gttOrder) {
      final uniqueId = '${gttOrder.alId ?? ''}_${gttOrder.tsym ?? ''}';
      final isHovered = _hoveredRowToken == uniqueId;

      return DataRow2(
        color: MaterialStateProperty.resolveWith((states) {
          if (isHovered) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return null;
        }),
        cells: headers.map((header) {
          return _buildGttDataTable2Cell(
            header,
            gttOrder,
            theme,
            isHovered,
            uniqueId,
          );
        }).toList(),
        onTap: () => _openGttOrderDetail(gttOrder),
      );
    }).toList();
  }

  DataCell _buildGttDataTable2Cell(
    String column,
    GttOrderBookModel gttOrder,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId,
  ) {
    Widget cellContent;
    
    switch (column) {
      case 'Instrument':
        cellContent = _buildGttInstrumentCellContent(
          gttOrder,
          theme,
          isHovered,
          uniqueId,
        );
        break;
      case 'Product':
        cellContent = _buildGttTextCell(
          gttOrder.placeOrderParams?.sPrdtAli ?? 'N/A',
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Type':
        final isBuy = gttOrder.trantype == "B";
        final buttonColor = isBuy
            ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
            : (theme.isDarkMode ? colors.lossDark : colors.lossLight);
        cellContent = _buildGttTextCell(
          isBuy ? "BUY" : "SELL",
          theme,
          Alignment.centerLeft,
          color: buttonColor,
        );
        break;
      case 'Qty':
        cellContent = _buildGttTextCell(
          gttOrder.qty?.toString() ?? '0',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'LTP':
        cellContent = _buildGttTextCell(
          _getValidLTPForGtt(gttOrder),
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Trigger':
        cellContent = _buildGttTextCell(
          gttOrder.d ?? '0.00',
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Status':
        final status = gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
        final statusColor = _getGttStatusColor(status, theme);
        cellContent = _buildGttTextCell(
          _getGttStatusText(status),
          theme,
          Alignment.centerLeft,
          color: statusColor,
        );
        break;
      case 'Time':
        final time = gttOrder.norentm != null ? gttOrder.norentm! : '';
        cellContent = _buildGttTextCell(
          time.isNotEmpty ? formatDateTime(value: time) : '',
          theme,
          Alignment.centerLeft,
        );
        break;
      default:
        cellContent = const SizedBox.shrink();
    }

    // Wrap with MouseRegion to detect hover anywhere on the cell
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: cellContent,
        ),
      ),
    );
  }

  Widget _buildGttInstrumentCellContent(
    GttOrderBookModel gttOrder,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId,
  ) {
    final isProcessing = _processingOrderToken == uniqueId;
    final status = gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
    final isPending = status == 'PENDING' || status == 'TRIGGER_PENDING';

    String symbol = '${gttOrder.tsym?.replaceAll("-EQ", "") ?? 'N/A'}';
    String exchange = gttOrder.exch ?? '';
    String displayText = symbol.trim();
    if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
      displayText += ' ${exchange.trim()}';
    }

    return Row(
      children: [
        Expanded(
          flex: isHovered ? 1 : 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: displayText,
              child: Text(
                displayText,
                style: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        // Action buttons fade in on hover
        IgnorePointer(
          ignoring: !isHovered,
          child: AnimatedOpacity(
            opacity: isHovered ? 1 : 0,
            duration: const Duration(milliseconds: 140),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending) ...[
                  _buildOrderHoverButton(
                    label: 'Cancel',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.error
                        : WebColors.error,
                    onPressed: isProcessing && _isProcessingCancel
                        ? null
                        : () => _handleCancelGttOrder(gttOrder),
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildOrderHoverButton(
                    label: 'Modify',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                    onPressed: isProcessing && _isProcessingModify
                        ? null
                        : () => _handleModifyGttOrder(gttOrder),
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGttSortIcon(int columnIndex, ThemesProvider theme) {
    if (_gttSortColumnIndex == columnIndex) {
      return const SizedBox(width: 16); // Reserve space for DataTable2's arrow
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode
            ? WebDarkColors.iconSecondary
            : WebColors.iconSecondary,
      );
    }
  }

  Widget _buildGttOrderBookTable(
      ThemesProvider theme, List<GttOrderBookModel> gttOrders) {
    final orderBook = ref.watch(orderProvider);

    // Show loading indicator if data is being fetched and no existing data
    if (gttOrders.isEmpty) {
      if (orderBook.loading) {
        return const SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading GTT orders...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox(
          height: 400,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: NoDataFound(),
            ),
          ),
        );
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = 32.0; // Top and bottom padding (16 * 2)
        final headerHeight = 50.0; // Header height (tabs + search bar)
        final spacing = 16.0; // Spacing between header and content
        final bottomMargin = 20.0; // Bottom margin
        final tableHeight =
            screenHeight - padding - headerHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveGttColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            height: calculatedHeight.toDouble(),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: theme.isDarkMode
                  ? WebDarkColors.background
                  : Colors.white,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  // Make both scrollbars always visible
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                  
                  // Consistent thickness for both horizontal and vertical
                  thickness: MaterialStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  
                  // Consistent radius
                  radius: const Radius.circular(3),
                  
                  // Consistent colors for both scrollbars
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  
                  trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0,
                ),
              ),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1200,
                sortColumnIndex: _gttSortColumnIndex,
                sortAscending: _gttSortAscending,
                fixedLeftColumns: 1, // Fix the first column (Instrument)
                fixedColumnsColor: theme.isDarkMode 
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                showBottomBorder: true,
                horizontalScrollController: _gttHorizontalScrollController,
                scrollController: _gttVerticalScrollController,
                showCheckboxColumn: false,
                headingRowColor: MaterialStateProperty.all(
                  theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary.withOpacity(0.05),
                ),
                headingTextStyle: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                dataTextStyle: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                border: TableBorder(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  horizontalInside: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  // Remove vertical lines
                ),
                columns: _buildGttDataTable2Columns(headers, columnMinWidth, theme),
                rows: _buildGttDataTable2Rows(gttOrders, headers, theme),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildGttTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Text(
          text,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: color ??
                (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary),
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1, 
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildOrderHoverButton({
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label,
            style: WebTextStyles.custom(
                fontSize: 12, isDarkTheme: theme.isDarkMode, color: color)),
      ),
    );
  }

  Widget _buildSortableColumnHeader(
      String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _orderSortColumnIndex == columnIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        // Reserve fixed space for sort indicator
        SizedBox(
          width: 20,
          height: 16,
          child: !isSorted
              ? Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: theme.isDarkMode
                      ? WebDarkColors.iconSecondary
                      : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  DataCell _buildCellWithHover(
      OrderBookModel order, ThemesProvider theme, String token, DataCell cell,
      {Alignment alignment = Alignment.centerRight}) {
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = token),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment,
            child: cell.child,
          ),
        ),
      ),
    );
  }

  // Sorting helpers
  List<OrderBookModel> _sortedOrders(List<OrderBookModel> orders) {
    if (_orderSortColumnIndex == null) return orders;
    final sorted = [...orders];
    int c = _orderSortColumnIndex!;
    bool asc = _orderSortAscending;
    int cmp<T extends Comparable>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    }

    num parseNum(String? v) => double.tryParse(v ?? '') ?? 0;
    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Instrument
          r = cmp(a.tsym, b.tsym);
          break;
        case 1: // Product
          r = cmp(a.sPrdtAli ?? a.prd, b.sPrdtAli ?? b.prd);
          break;
        case 2: // Type
          r = cmp(a.trantype, b.trantype);
          break;
        case 3: // Qty
          r = cmp(num.tryParse(a.qty.toString()) ?? 0,
              num.tryParse(b.qty.toString()) ?? 0);
          break;
        case 4: // Avg price
          r = cmp(parseNum(a.avgprc), parseNum(b.avgprc));
          break;
        case 5: // LTP
          r = cmp(parseNum(a.ltp), parseNum(b.ltp));
          break;
        case 6: // Price
          r = cmp(parseNum(a.prc), parseNum(b.prc));
          break;
        case 7: // Trigger price
          r = cmp(parseNum(a.trgprc), parseNum(b.trgprc));
          break;
        case 8: // Order value
          final av = (parseNum(a.avgprc ?? "0") *
              (int.tryParse(a.qty.toString()) ?? 0));
          final bv = (parseNum(b.avgprc ?? "0") *
              (int.tryParse(b.qty.toString()) ?? 0));
          r = cmp(av, bv);
          break;
        case 9: // Status
          r = cmp(a.status, b.status);
          break;
        case 10: // Time
          r = cmp(a.norentm, b.norentm);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  void _onSortOrderTable(int columnIndex, bool ascending) {
    setState(() {
      _orderSortColumnIndex = columnIndex;
      _orderSortAscending = ascending;
    });
  }

  List<TradeBookModel> _sortedTrades(List<TradeBookModel> trades) {
    if (_tradeSortColumnIndex == null) return trades;
    final sorted = [...trades];
    int c = _tradeSortColumnIndex!;
    bool asc = _tradeSortAscending;
    int cmp<T extends Comparable>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    }

    num parseNum(String? v) => double.tryParse(v ?? '') ?? 0;
    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Instrument
          r = cmp(a.tsym, b.tsym);
          break;
        case 1: // Product
          r = cmp(a.sPrdtAli, b.sPrdtAli);
          break;
        case 2: // Type (Transaction)
          r = cmp(a.trantype, b.trantype);
          break;
        case 3: // Qty
          r = cmp(num.tryParse(a.qty.toString()) ?? 0,
              num.tryParse(b.qty.toString()) ?? 0);
          break;
        case 4: // Price
          r = cmp(parseNum(a.avgprc), parseNum(b.avgprc));
          break;
        case 5: // Trade value (flqty * flprc)
          final av =
              (parseNum(a.flqty?.toString() ?? "0") * parseNum(a.flprc ?? "0"));
          final bv =
              (parseNum(b.flqty?.toString() ?? "0") * parseNum(b.flprc ?? "0"));
          r = cmp(av, bv);
          break;
        case 6: // Order no
          r = cmp(a.norenordno, b.norenordno);
          break;
        case 7: // Time
          r = cmp(a.norentm, b.norentm);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  void _onSortTradeTable(int columnIndex, bool ascending) {
    setState(() {
      if (_tradeSortColumnIndex == columnIndex) {
        _tradeSortAscending = !_tradeSortAscending;
      } else {
        _tradeSortColumnIndex = columnIndex;
        _tradeSortAscending = ascending;
      }
    });
  }

  Widget _buildTradeSortableColumnHeader(
      String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _tradeSortColumnIndex == columnIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 20,
          height: 16,
          child: !isSorted
              ? Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: theme.isDarkMode
                      ? WebDarkColors.iconSecondary
                      : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  List<GttOrderBookModel> _sortedGtt(List<GttOrderBookModel> gtt) {
    // Safety check: ensure we always return a list (never null)
    if (gtt.isEmpty) return gtt;
    if (_gttSortColumnIndex == null) return gtt;
    final sorted = [...gtt];
    int c = _gttSortColumnIndex!;
    bool asc = _gttSortAscending;
    int cmp<T extends Comparable>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    }

    num parseNum(String? v) => double.tryParse(v ?? '') ?? 0;
    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Instrument (new order: Instrument is now column 0)
          r = cmp(a.tsym, b.tsym);
          break;
        case 1: // Product (new order: Product is now column 1)
          r = cmp(a.placeOrderParams?.sPrdtAli, b.placeOrderParams?.sPrdtAli);
          break;
        case 2: // Type (new order: Type is now column 2)
          r = cmp(a.trantype, b.trantype);
          break;
        case 3: // Qty
          r = cmp(num.tryParse(a.qty.toString()) ?? 0,
              num.tryParse(b.qty.toString()) ?? 0);
          break;
        case 4: // LTP
          r = cmp(parseNum(a.ltp), parseNum(b.ltp));
          break;
        case 5: // Trigger price
          r = cmp(parseNum(a.d), parseNum(b.d));
          break;
        case 6: // Status
          r = cmp(a.gttOrderCurrentStatus, b.gttOrderCurrentStatus);
          break;
        case 7: // Time (new order: Time is now column 7)
          r = cmp(a.norentm, b.norentm);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  void _onSortGttTable(int columnIndex, bool ascending) {
    setState(() {
      _gttSortColumnIndex = columnIndex;
      _gttSortAscending = ascending;
    });
  }

  DataCell _buildTradeCellWithHover(
      TradeBookModel trade, ThemesProvider theme, String token, DataCell cell,
      {Alignment alignment = Alignment.centerRight}) {
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = token),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment,
            child: cell.child,
          ),
        ),
      ),
    );
  }


  void _openOrderDetail(OrderBookModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderBookDetailScreenWeb(orderBookData: order);
      },
    );
  }

  // Order action handlers
  Future<void> _handleCancelOrder(OrderBookModel orderData) async {
    final uniqueId =
        orderData.norenordno?.toString() ?? orderData.token?.toString() ?? '';
    if (_isProcessingCancel && _processingOrderToken == uniqueId) return;

    try {
      setState(() {
        _isProcessingCancel = true;
        _processingOrderToken = uniqueId;
      });

      // Show confirmation dialog first
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          final theme = ref.read(themeProvider);
          final symbol = orderData.tsym?.replaceAll("-EQ", "") ?? 'N/A';
          final exchange = orderData.exch ?? '';
          final displayText = '$symbol $exchange'.trim();

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.isDarkMode
                              ? WebDarkColors.divider
                              : WebColors.divider,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cancel Order',
                          style: WebTextStyles.dialogTitle(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            splashColor: theme.isDarkMode
                                ? Colors.white.withOpacity(.15)
                                : Colors.black.withOpacity(.15),
                            highlightColor: theme.isDarkMode
                                ? Colors.white.withOpacity(.08)
                                : Colors.black.withOpacity(.08),
                            onTap: () => Navigator.of(dialogContext).pop(false),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: theme.isDarkMode
                                    ? WebDarkColors.iconSecondary
                                    : WebColors.iconSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content area
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          top: 0, bottom: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Are you sure you want to cancel this order?',
                                textAlign: TextAlign.center,
                                style: WebTextStyles.dialogContent(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              displayText,
                              textAlign: TextAlign.center,
                              style: WebTextStyles.dialogContent(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                    : WebColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.error
                                    : WebColors.error,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: Colors.white.withOpacity(0.2),
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  onTap: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: Center(
                                    child: Text(
                                      'Cancel Order',
                                      style: WebTextStyles.buttonMd(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (shouldCancel != true) {
        // User cancelled the confirmation dialog, reset processing state
        if (mounted) {
          setState(() {
            _isProcessingCancel = false;
            _processingOrderToken = null;
          });
        }
        return;
      }

      // Proceed with cancel after confirmation
      // Pass false for loop to avoid Navigator.pop issues when canceling from table
      // The provider will not auto-pop dialogs, which is what we want when canceling from hover buttons
      final cancelResult = await ref.read(orderProvider).fetchOrderCancel(
            "${orderData.norenordno}",
            context,
            false, // Changed to false to prevent unwanted Navigator.pop calls
          );

      // Refresh order book after successful cancel
      if (cancelResult != null && cancelResult.stat == "Ok") {
        await ref.read(orderProvider).fetchOrderBook(context, true);
        if (mounted) {
          ResponsiveSnackBar.showSuccess(context, 'Order Cancelled');
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to cancel order');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCancel = false;
          _processingOrderToken = null;
        });
      }
    }
  }

  Future<void> _handleModifyOrder(OrderBookModel orderData) async {
    final uniqueId =
        orderData.norenordno?.toString() ?? orderData.token?.toString() ?? '';
    if (_isProcessingModify && _processingOrderToken == uniqueId) return;

    try {
      setState(() {
        _isProcessingModify = true;
        _processingOrderToken = uniqueId;
      });

      await ref.read(marketWatchProvider).fetchScripInfo(
            "${orderData.token}",
            '${orderData.exch}',
            context,
            true,
          );

      if (!mounted) return;

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        ResponsiveSnackBar.showError(
            context, 'Unable to fetch scrip information');
        return;
      }

      // Show draggable modify order dialog without backdrop
      _showDraggableModifyDialog(orderData, scripInfo);

      // Refresh order book after a short delay to reflect any changes
      if (mounted) {
        // Wait a bit for any potential modifications to complete
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            await ref.read(orderProvider).fetchOrderBook(context, true);
          }
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open modify order: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingModify = false;
          _processingOrderToken = null;
        });
      }
    }
  }

  void _showDraggableModifyDialog(OrderBookModel orderData, dynamic scripInfo) {
    ModifyPlaceOrderScreenWeb.showDraggable(
      context: context,
      modifyOrderArgs: orderData,
      scripInfo: scripInfo,
      orderArg: _createOrderArgs(orderData),
      initialPosition: _modifyDialogPosition,
    );
  }

  Future<void> _handleRepeatOrder(OrderBookModel orderData) async {
    try {
      await ref.read(marketWatchProvider).fetchScripInfo(
            "${orderData.token}",
            "${orderData.exch}",
            context,
            true,
          );

      if (!mounted) return;

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        ResponsiveSnackBar.showError(
            context, 'Unable to fetch scrip information');
        return;
      }

      // Create OrderScreenArgs for repeat order
      final orderArgs = _createOrderArgs(orderData);

      // Use ResponsiveNavigation instead of draggable dialog
      await ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": "",
        },
      );
    } catch (e) {
      // Handle error
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open place order: ${e.toString()}');
      }
    }
  }

  void _showDraggablePlaceOrderDialog(
      OrderBookModel orderData, dynamic scripInfo) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _DraggablePlaceOrderDialog(
        orderData: orderData,
        scripInfo: scripInfo,
        createOrderArgs: _createOrderArgs,
        initialPosition: _placeOrderDialogPosition,
        onPositionChanged: (newPosition) {
          _placeOrderDialogPosition = newPosition;
        },
        onClose: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  void _showDraggableGttModifyDialog(
      GttOrderBookModel gttOrderData, dynamic scripInfo) {
    // Show ModifyGttWeb as a draggable dialog
    ModifyGttWeb.showDraggable(
      context: context,
      gttOrderBook: gttOrderData,
      scripInfo: scripInfo,
    );
  }

  OrderScreenArgs _createOrderArgs(OrderBookModel orderData) {
    return OrderScreenArgs(
      exchange: orderData.exch.toString(),
      tSym: orderData.tsym.toString(),
      isExit: false,
      token: orderData.token.toString(),
      transType: orderData.trantype == 'B' ? true : false,
      lotSize: orderData.ls,
      ltp: "${orderData.ltp ?? orderData.c ?? 0.00}",
      perChange: orderData.change ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: orderData.toJson(),
    );
  }

  void _openTradeDetail(TradeBookModel trade) {
    showDialog(
      context: context,
      builder: (context) => TradeBookDetailScreenWeb(
        tradeData: trade,
      ),
    );
  }

  void _openGttOrderDetail(GttOrderBookModel gttOrder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GttOrderBookDetailScreenWeb(gttOrder: gttOrder);
      },
    );
  }

  // GTT order action handlers
  Future<void> _handleCancelGttOrder(GttOrderBookModel gttOrderData) async {
    final uniqueId = '${gttOrderData.alId ?? ''}_${gttOrderData.tsym ?? ''}';
    if (_isProcessingCancel && _processingOrderToken == uniqueId) return;

    try {
      setState(() {
        _isProcessingCancel = true;
        _processingOrderToken = uniqueId;
      });

      // Show confirmation dialog
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          final theme = ref.read(themeProvider);
          final symbol = gttOrderData.tsym?.replaceAll("-EQ", "") ?? 'N/A';
          final exchange = gttOrderData.exch ?? '';
          final displayText = '$symbol $exchange'.trim();

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.isDarkMode
                              ? WebDarkColors.divider
                              : WebColors.divider,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cancel GTT Order',
                          style: WebTextStyles.dialogTitle(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            splashColor: theme.isDarkMode
                                ? Colors.white.withOpacity(.15)
                                : Colors.black.withOpacity(.15),
                            highlightColor: theme.isDarkMode
                                ? Colors.white.withOpacity(.08)
                                : Colors.black.withOpacity(.08),
                            onTap: () => Navigator.of(dialogContext).pop(false),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: theme.isDarkMode
                                    ? WebDarkColors.iconSecondary
                                    : WebColors.iconSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content area
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          top: 0, bottom: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Are you sure you want to cancel this GTT order?',
                                textAlign: TextAlign.center,
                                style: WebTextStyles.dialogContent(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              displayText,
                              textAlign: TextAlign.center,
                              style: WebTextStyles.dialogContent(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                    : WebColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.tertiary
                                    : WebColors.tertiary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: Colors.white.withOpacity(0.2),
                                  highlightColor: Colors.white.withOpacity(0.1),
                                  onTap: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: Center(
                                    child: Text(
                                      'Cancel Order',
                                      style: WebTextStyles.buttonMd(
                                        isDarkTheme: theme.isDarkMode,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (shouldCancel != true) {
        // User cancelled the confirmation dialog, reset processing state
        if (mounted) {
          setState(() {
            _isProcessingCancel = false;
            _processingOrderToken = null;
          });
        }
        return;
      }

      // Cancel the GTT order
      await ref.read(orderProvider).cancelGttOrder(
            "${gttOrderData.alId}",
            context,
          );

      // Refresh GTT order book after successful cancel
      await ref.read(orderProvider).fetchGTTOrderBook(context, "");
      // Note: Success message is already shown by cancelGttOrder in provider
    } catch (e) {
      // Handle error
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to cancel GTT order');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCancel = false;
          _processingOrderToken = null;
        });
      }
    }
  }

  Future<void> _handleModifyGttOrder(GttOrderBookModel gttOrderData) async {
    final uniqueId = '${gttOrderData.alId ?? ''}_${gttOrderData.tsym ?? ''}';
    if (_isProcessingModify && _processingOrderToken == uniqueId) return;

    try {
      setState(() {
        _isProcessingModify = true;
        _processingOrderToken = uniqueId;
      });

      await ref.read(marketWatchProvider).fetchScripInfo(
            "${gttOrderData.token}",
            '${gttOrderData.exch}',
            context,
            true,
          );

      if (!mounted) return;

      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        ResponsiveSnackBar.showError(
            context, 'Unable to fetch scrip information');
        return;
      }

      // Show modify GTT order screen as draggable dialog
      _showDraggableGttModifyDialog(gttOrderData, scripInfo);
    } catch (e) {
      // Handle error
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open modify GTT order: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingModify = false;
          _processingOrderToken = null;
        });
      }
    }
  }

  DataCell _buildTimeCell(OrderBookModel item, ThemesProvider theme) {
    String time = item.norentm != null ? item.norentm! : '0.00';

    return DataCell(
      Text(
        formatDateTime(value: time),
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildTypeCell(OrderBookModel item, ThemesProvider theme) {
    String buySell = item.trantype == "S" ? "SELL" : "BUY";
    Color buttonColor = item.trantype == "S"
        ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
        : (theme.isDarkMode ? colors.profitDark : colors.profitLight);

    return DataCell(
      Text(
        buySell,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: buttonColor,
        ),
      ),
    );
  }

  DataCell _buildInstrumentCell(OrderBookModel item, ThemesProvider theme) {
    String symbol = '${item.tsym}';
    String exchange = item.exch ?? '';

    String displayText = symbol;
    if (exchange.isNotEmpty) {
      displayText += ' $exchange';
    }

    return DataCell(
      Text(
        displayText,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataCell _buildInstrumentCellWithHover(
      OrderBookModel order, ThemesProvider theme, String token) {
    final orderToken = token;
    final isHovered = _hoveredRowToken == orderToken;
    final isProcessing = _processingOrderToken == orderToken;

    // Determine which buttons to show based on order status
    final isPending = order.status == "PENDING" ||
        order.status == "OPEN" ||
        order.status == "TRIGGER_PENDING";

    String symbol = '${order.tsym ?? ''}';
    String exchange = order.exch ?? '';

    String displayText = symbol.trim();
    if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
      displayText += ' ${exchange.trim()}';
    }

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = orderToken),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Row(
            children: [
              // Text that takes at least 50% of width, leaves space for buttons
              Expanded(
                flex: isHovered
                    ? 1
                    : 2, // When hovered, text takes less space but still visible
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: displayText,
                    child: Text(
                      displayText,
                      style: WebTextStyles.tableDataCompact(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              // Buttons on the right side - fade in/out
              IgnorePointer(
                ignoring: !isHovered,
                child: AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending) ...[
                        // Cancel button for pending orders
                        _buildOrderHoverButton(
                          label: 'Cancel',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.error
                              : WebColors.error,
                          onPressed: isProcessing && _isProcessingCancel
                              ? null
                              : () => _handleCancelOrder(order),
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                        // Modify button for pending orders
                        _buildOrderHoverButton(
                          label: 'Modify',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          onPressed: isProcessing && _isProcessingModify
                              ? null
                              : () => _handleModifyOrder(order),
                          theme: theme,
                        ),
                      ] else ...[
                        // Repeat Order button for completed orders
                        _buildOrderHoverButton(
                          label: 'Repeat',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          onPressed: () => _handleRepeatOrder(order),
                          theme: theme,
                        ),
                        // Cancel button for OPEN status completed orders
                        if (order.status == "OPEN") ...[
                          const SizedBox(width: 6),
                          _buildOrderHoverButton(
                            label: 'Cancel',
                            color: Colors.white,
                            backgroundColor: theme.isDarkMode
                                ? WebDarkColors.error
                                : WebColors.error,
                            onPressed: isProcessing && _isProcessingCancel
                                ? null
                                : () => _handleCancelOrder(order),
                            theme: theme,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildOrderHoverButton({
  //   String? label,
  //   required Color color,
  //   Color? backgroundColor,
  //   Color? borderColor,
  //   double? borderRadius,
  //   required VoidCallback? onPressed,
  //   required ThemesProvider theme,
  // }) {
  //   final borderRadiusValue = borderRadius ?? 5.0;
  //   return SizedBox(
  //     height: 28,
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(borderRadiusValue),
  //         splashColor: color.withOpacity(0.15),
  //         highlightColor: color.withOpacity(0.08),
  //         onTap: onPressed,
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 8),
  //           decoration: BoxDecoration(
  //             color: backgroundColor ?? Colors.transparent,
  //             borderRadius: BorderRadius.circular(borderRadiusValue),
  //             border: borderColor != null
  //                 ? Border.all(
  //                     color: borderColor,
  //                     width: 1,
  //                   )
  //                 : null,
  //           ),
  //           child: Center(
  //             child: Text(
  //               label ?? "",
  //               style: WebTextStyles.custom(
  //                 fontSize: 11,
  //                 isDarkTheme: theme.isDarkMode,
  //                 color: color,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  DataCell _buildProductCell(OrderBookModel item, ThemesProvider theme) {
    String product = item.sPrdtAli ?? 'N/A';

    return DataCell(
      Text(
        product,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildQtyCell(OrderBookModel item, ThemesProvider theme) {
    String qty = item.qty?.toString() ?? '0.00';

    return DataCell(
      Text(
        qty,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildAvgPriceCell(OrderBookModel item, ThemesProvider theme) {
    String avgPrice = item.avgprc ?? '0.00';

    return DataCell(
      Text(
        avgPrice,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildOrderValueCell(OrderBookModel item, ThemesProvider theme) {
    String orderValue = '0.00';

    try {
      double price = double.tryParse(item.avgprc ?? "0") ?? 0.0;
      int qty = int.tryParse(item.qty.toString()) ?? 0;
      orderValue = (price * qty).toStringAsFixed(2);
    } catch (e) {
      orderValue = '0.00';
    }

    return DataCell(
      Text(
        orderValue,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildLTPCell(OrderBookModel item, ThemesProvider theme) {
    String ltpValue = _getValidLTP(item);

    return DataCell(
      Text(
        ltpValue,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildPriceCell(OrderBookModel item, ThemesProvider theme) {
    String displayText = _getValidPrice(item);

    return DataCell(
      Text(
        displayText,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildStatusCell(OrderBookModel item, ThemesProvider theme) {
    String statusText = _getStatusText(item);
    Color statusColor = _getStatusColor(statusText, theme);

    return DataCell(
      Text(
        statusText,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: statusColor,
        ),
      ),
    );
  }

  DataCell _buildTriggerPriceCell(OrderBookModel item, ThemesProvider theme) {
    String triggerPrice = '0.00';

    if (item.trgprc != null && item.trgprc != '0' && item.trgprc != '0.00') {
      triggerPrice = item.trgprc!;
    }

    return DataCell(
      Text(
        triggerPrice,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  // Helper methods to match mobile UI exactly

  // String _formatTimeForWeb(String timeString) {
  //   // Format time to match web UI: "10:09:44"
  //   try {
  //     // Assuming timeString is in format like "2024-01-15 10:09:44"
  //     if (timeString.length >= 19) {
  //       return timeString.substring(11, 19); // Extract "10:09:44"
  //     }
  //     return timeString;
  //   } catch (e) {
  //     return timeString;
  //   }
  // }

  String _formatTime(String timeString) {
    // Format time to match mobile UI: "10:13 AM"
    try {
      // Assuming timeString is in format like "2024-01-15 10:13:45"
      if (timeString.length >= 19) {
        String timePart = timeString.substring(11, 19); // Extract "10:13:45"
        List<String> parts = timePart.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        String period = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  // DataCell builders for TradeBookModel
  DataCell _buildSymbolCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String symbol = item.symbol?.replaceAll("-EQ", "") ?? item.tsym ?? 'N/A';
    String expDate = item.expDate ?? '';
    String option = item.option ?? '';

    String displayText = symbol;
    if (expDate.isNotEmpty) {
      displayText += ' $expDate';
    }
    if (option.isNotEmpty) {
      displayText += ' $option';
    }

    return DataCell(
      Text(
        displayText,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataCell _buildTransactionCellForTrade(
      TradeBookModel item, ThemesProvider theme) {
    String buySell = item.trantype == "S" ? "SELL" : "BUY";

    Color textColor = item.trantype == "S"
        ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
        : (theme.isDarkMode ? colors.profitDark : colors.profitLight);

    return DataCell(
      Text(
        buySell,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: textColor,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildTimeCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String time = item.norentm != null ? item.norentm! : 'N/A';

    return DataCell(
      Text(
        formatDateTime(value: time),
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildProductCellForTrade(
      TradeBookModel item, ThemesProvider theme) {
    String product = item.sPrdtAli ?? 'N/A';

    return DataCell(
      Text(
        product,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildQtyCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String qty = item.qty?.toString() ?? 'N/A';

    return DataCell(
      Text(
        qty,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildPriceCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String price = item.avgprc?.toString() ?? 'N/A';

    return DataCell(
      Text(
        price,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildTradeValueCellForTrade(
      TradeBookModel item, ThemesProvider theme) {
    String tradeValue = "0.00";

    try {
      if (item.flqty != null && item.flprc != null) {
        tradeValue = (double.parse(item.flqty!) * double.parse(item.flprc!))
            .toStringAsFixed(2);
      }
    } catch (e) {
      tradeValue = "0.00";
    }

    return DataCell(
      Text(
        tradeValue,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildOrderNoCellForTrade(
      TradeBookModel item, ThemesProvider theme) {
    String orderNo = item.norenordno?.toString() ?? 'N/A';

    return DataCell(
      Text(
        orderNo,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  String _getValidLTP(OrderBookModel item) {
    // Helper function to check if a string is a valid numeric price
    bool isValidPrice(String? value) {
      if (value == null || value == "null" || value == "0" || value == "0.00") {
        return false;
      }
      return double.tryParse(value) != null;
    }

    // For LTP column, prioritize real-time LTP from WebSocket
    if (isValidPrice(item.ltp)) {
      return item.ltp!;
    }

    // Fallback to other price fields if LTP is not available
    if (isValidPrice(item.avgprc)) {
      return item.avgprc!;
    } else if (isValidPrice(item.prc)) {
      return item.prc!;
    } else if (isValidPrice(item.c)) {
      return item.c!;
    } else if (isValidPrice(item.close)) {
      return item.close!;
    }

    return "0.00";
  }

  String _getValidPrice(OrderBookModel item) {
    // Helper function to check if a string is a valid numeric price
    bool isValidPrice(String? value) {
      if (value == null || value == "null" || value == "0" || value == "0.00") {
        return false;
      }
      return double.tryParse(value) != null;
    }

    // For Price column, prioritize original order price from API
    // This should NOT be updated by WebSocket data
    if (isValidPrice(item.prc)) {
      return item.prc!;
    }

    return "0.00";
  }

  String _getStatusText(OrderBookModel item) {
    String status = item.status?.toString().toUpperCase() ?? 'unknown';
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  Color _getStatusColor(String status, ThemesProvider theme) {
    switch (status.toLowerCase()) {
      case 'complete':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'canceled':
      case 'rejected':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      default:
        // For OPEN, PENDING, TRIGGER_PENDING, etc.
        return colors.pending;
    }
  }

  // GTT-specific cell builder methods
  DataCell _buildTimeCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        formatDateTime(value: item.norentm!),
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildTypeCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    final isBuy = item.trantype == "B";
    return DataCell(
      Text(
        isBuy ? "BUY" : "SELL",
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: isBuy
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildInstrumentCellForGtt(
      GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        '${item.tsym?.replaceAll("-EQ", "") ?? 'N/A'}-${item.exch ?? ''}',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildGttInstrumentCellWithHover(
      GttOrderBookModel gttOrder, ThemesProvider theme, String token) {
    final gttOrderToken = token;
    final isHovered = _hoveredRowToken == gttOrderToken;
    final isProcessing = _processingOrderToken == gttOrderToken;

    // Determine which buttons to show based on GTT order status
    // GTT orders can be cancelled/modified if status is PENDING
    final status = gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
    final isPending = status == 'PENDING' || status == 'TRIGGER_PENDING';

    String symbol = '${gttOrder.tsym?.replaceAll("-EQ", "") ?? 'N/A'}';
    String exchange = gttOrder.exch ?? '';

    String displayText = symbol.trim();
    if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
      displayText += '-${exchange.trim()}';
    }

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = gttOrderToken),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Row(
            children: [
              // Text that takes at least 50% of width, leaves space for buttons
              Expanded(
                flex: isHovered
                    ? 1
                    : 2, // When hovered, text takes less space but still visible
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: displayText,
                    child: Text(
                      displayText,
                      style: WebTextStyles.custom(
                        fontSize: 13,
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: WebFonts.medium,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              // Buttons on the right side - fade in/out
              IgnorePointer(
                ignoring: !isHovered,
                child: AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending) ...[
                        // Cancel button for pending GTT orders
                        _buildOrderHoverButton(
                          label: 'Cancel',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.error
                              : WebColors.error,
                          onPressed: isProcessing && _isProcessingCancel
                              ? null
                              : () => _handleCancelGttOrder(gttOrder),
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                        // Modify button for pending GTT orders
                        _buildOrderHoverButton(
                          label: 'Modify',
                          color: Colors.white,
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          onPressed: isProcessing && _isProcessingModify
                              ? null
                              : () => _handleModifyGttOrder(gttOrder),
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildProductCellForGtt(
      GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.placeOrderParams?.sPrdtAli ?? '',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildQtyCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.qty?.toString() ?? '0',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildLTPCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        _getValidLTPForGtt(item),
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildTriggerPriceCellForGtt(
      GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.d ?? '0.00',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildStatusCellForGtt(
      GttOrderBookModel item, ThemesProvider theme) {
    final status = item.gttOrderCurrentStatus?.toUpperCase() ?? '';
    return DataCell(
      Text(
        _getGttStatusText(status),
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: _getGttStatusColor(status, theme),
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  String _getValidLTPForGtt(GttOrderBookModel item) {
    bool isValidPrice(String? value) {
      if (value == null || value == "null" || value == "0" || value == "0.00") {
        return false;
      }
      return double.tryParse(value) != null;
    }

    if (isValidPrice(item.ltp)) {
      return item.ltp!;
    }
    if (isValidPrice(item.prc)) {
      return item.prc!;
    } else if (isValidPrice(item.c)) {
      return item.c!;
    } else if (isValidPrice(item.close)) {
      return item.close!;
    }
    return "0.00";
  }

  // GTT-specific helper methods
  String _getGttStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'triggered':
        return 'TRIGGERED';
      case 'cancelled':
        return 'CANCELLED';
      case 'completed':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }

  Color _getGttStatusColor(String status, ThemesProvider theme) {
    switch (status.toLowerCase()) {
      case 'pending':
        return colors.pending;
      case 'triggered':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'cancelled':
      case 'rejected':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'completed':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      default:
        return colors.pending;
    }
  }
}

// Draggable Modify Dialog Widget
// Draggable Place Order Dialog Widget
class _DraggablePlaceOrderDialog extends ConsumerStatefulWidget {
  final OrderBookModel orderData;
  final dynamic scripInfo;
  final OrderScreenArgs Function(OrderBookModel) createOrderArgs;
  final Offset initialPosition;
  final Function(Offset) onPositionChanged;
  final VoidCallback onClose;

  const _DraggablePlaceOrderDialog({
    required this.orderData,
    required this.scripInfo,
    required this.createOrderArgs,
    required this.initialPosition,
    required this.onPositionChanged,
    required this.onClose,
  });

  @override
  ConsumerState<_DraggablePlaceOrderDialog> createState() =>
      _DraggablePlaceOrderDialogState();
}

class _DraggablePlaceOrderDialogState
    extends ConsumerState<_DraggablePlaceOrderDialog> {
  late Offset _position;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;

    // Listen for navigation changes (when confirmation screen appears)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForNavigationChanges();
    });
  }

  void _listenForNavigationChanges() {
    // Monitor for navigation events that might indicate the place order dialog should close
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Stop checking after 30 seconds to prevent memory leaks
      if (timer.tick > 150) {
        // 30 seconds
        timer.cancel();
        return;
      }

      // Check if a new route has been pushed (like confirmation screen)
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        // Get the current route to check if it's a confirmation screen
        final currentRoute = ModalRoute.of(context);
        final routeName = currentRoute?.settings.name;

        // Don't close for surveillance dialogs or other temporary dialogs
        // Only close for actual confirmation screens or permanent navigation
        if (routeName != null &&
            (routeName.contains('confirmation') ||
                routeName.contains('order_confirmation'))) {
          // Close this dialog after a short delay to allow the confirmation to fully appear
          Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              widget.onClose();
            }
          });
          timer.cancel();
        }
        // For other dialogs (like surveillance), let them stay open
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenSize = MediaQuery.of(context).size;

    // Constrain position to screen bounds
    final constrainedPosition = Offset(
      _position.dx
          .clamp(0, screenSize.width - 520), // 520 = dialog width + padding
      _position.dy.clamp(
          0,
          screenSize.height -
              (screenSize.height * 0.9 + 20)), // dialog height + padding
    );

    return Stack(
      children: [
        // Invisible full-screen tap detector to close dialog when clicking outside
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Actual dialog
        Positioned(
          left: constrainedPosition.dx,
          top: constrainedPosition.dy,
          child: GestureDetector(
            onTap: () {}, // Prevent tap from propagating to background
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  _position.dx + details.delta.dx,
                  _position.dy + details.delta.dy,
                );
              });
              widget.onPositionChanged(_position);
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
              });
            },
            child: Material(
              elevation: _isDragging ? 16 : 8,
              borderRadius: BorderRadius.circular(5),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              child: Container(
                width: 500,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                  ),
                ),
                child: Column(
                  children: [
                    // Draggable header
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.backgroundSecondary
                            : WebColors.backgroundSecondary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: theme.isDarkMode
                                ? WebDarkColors.divider
                                : WebColors.divider,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Drag handle
                          const SizedBox(width: 8),
                          Icon(
                            Icons.drag_indicator,
                            size: 16,
                            color: theme.isDarkMode
                                ? WebDarkColors.iconSecondary
                                : WebColors.iconSecondary,
                          ),
                          const SizedBox(width: 8),
                          // Title
                          Expanded(
                            child: Text(
                              'Place Order - ${widget.orderData.tsym}',
                              style: WebTextStyles.dialogTitle(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                              ),
                            ),
                          ),
                          // Close button
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              splashColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(.15)
                                  : Colors.black.withOpacity(.15),
                              highlightColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(.08)
                                  : Colors.black.withOpacity(.08),
                              onTap: widget.onClose,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.iconSecondary
                                      : WebColors.iconSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    // Content area
                    Expanded(
                      child: PlaceOrderScreenWeb(
                        orderArg: widget.createOrderArgs(widget.orderData),
                        scripInfo: widget.scripInfo,
                        isBasket: '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

