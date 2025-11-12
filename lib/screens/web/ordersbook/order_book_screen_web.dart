import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/web/ordersbook/basket/basket_list_web.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/snack_bar.dart';
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
import '../../../utils/responsive_navigation.dart';

class OrderBookScreenWeb extends ConsumerStatefulWidget {
  const OrderBookScreenWeb({super.key});

  @override
  ConsumerState<OrderBookScreenWeb> createState() => _OrderBookScreenWebState();
}

class _OrderBookScreenWebState extends ConsumerState<OrderBookScreenWeb>
    with TickerProviderStateMixin {
  final Set<int> _selectedOrders = <int>{};
  late TabController _tabController;
  StreamSubscription? _socketSubscription;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  String? _hoveredRowToken; // Track which row is being hovered
  
  // Track processing states for order actions
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingOrderToken; // Track which order is being processed
  
  // Sort state per table
  int? _orderSortColumnIndex;
  bool _orderSortAscending = true;
  int? _tradeSortColumnIndex;
  bool _tradeSortAscending = true;
  int? _gttSortColumnIndex;
  bool _gttSortAscending = true;
  
  // MF tab state
  int _mfTabIndex = 0; // 0 for Orders, 1 for SIP

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ref.read(orderProvider).orderTabName.length,
      vsync: this,
      initialIndex: ref.read(orderProvider).selectedTab,
    );

    _tabController.addListener(() {
      // Just call the provider method like mobile does
      ref.read(orderProvider).changeTabIndex(_tabController.index, context);
    });

    // Set up WebSocket subscription for real-time LTP updates
    _setupSocketSubscription();

    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Order Book Screen Web',
      screenClass: 'OrderBookScreenWeb',
    );
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _tabController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _setupSocketSubscription() {
    Future.microtask(() {
      final socketProvider = ref.read(websocketProvider);
      
      _socketSubscription = socketProvider.socketDataStream.listen((socketDatas) {
        if (socketDatas.isEmpty) return;
        
        if (mounted) {
          _processUpdates(socketDatas);
        }
      });
    });
  }

  void _processUpdates(Map socketDatas) {
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
    _updateOrderBook(orderBook, socketDatas, isValidNumeric, (updated) => hasUpdates = hasUpdates || updated);
    
    // Update trade book with LTP changes
    _updateTradeBook(orderBook, socketDatas, isValidNumeric, (updated) => hasUpdates = hasUpdates || updated);
    
    // Update GTT order book with LTP changes
    _updateGttOrderBook(orderBook, socketDatas, isValidNumeric, (updated) => hasUpdates = hasUpdates || updated);
    
    // Notify listener if there were updates
    if (hasUpdates && mounted) {
      setState(() {});
    }
  }
  
  void _updateOrderBook(OrderProvider orderBook, Map socketDatas, bool Function(String?) isValidNumeric, Function(bool) setHasUpdates) {
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
  
  void _updateTradeBook(OrderProvider orderBook, Map socketDatas, bool Function(String?) isValidNumeric, Function(bool) setHasUpdates) {
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
  
  void _updateGttOrderBook(OrderProvider orderBook, Map socketDatas, bool Function(String?) isValidNumeric, Function(bool) setHasUpdates) {
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
    final orderBook = ref.watch(orderProvider);
    final theme = ref.watch(themeProvider);

    if (orderBook.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
        width: double.infinity,
      height: double.infinity,
      color: theme.isDarkMode ? WebDarkColors.background : Colors.white,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: () async {
            await orderBook.fetchOrderBook(context, true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Content Area (includes tabs and search bar)
                  _buildMainContent(theme, orderBook),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
      children: [
        // Segmented Control Tabs on the left
        _buildSegmentedControl(theme, orderBook),
        // Spacer to push action items to the right
        const Spacer(),
        // Search Bar
        SizedBox(
          width: 400,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
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
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: orderBook.orderSearchCtrl,
                    autofocus: false,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 3,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search orders...',
                      hintStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 3,
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
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
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
                final isSelected = _tabController.index == index;
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
          if (_tabController.index != index) {
            _tabController.animateTo(index);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : (theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface),
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width:  1.5,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: WebTextStyles.sub(
                  isDarkTheme: theme.isDarkMode,
                  color: isSelected
                      ? (theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary)
                      : (theme.isDarkMode
                          ? WebDarkColors.navItem
                          : WebColors.navItem),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Text(
                  '($badge)',
                  style: WebTextStyles.custom(
                    fontSize: 14,
                    isDarkTheme: theme.isDarkMode,
                    color: isSelected
                    ? (theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary)
                    : (theme.isDarkMode
                        ? WebDarkColors.navItem
                        : WebColors.navItem),
                    fontWeight: FontWeight.w600,
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
        final tableHeight = screenHeight - padding - headerHeight - spacing - bottomMargin;
        
        // Ensure we don't exceed 75% of screen height to prevent overflow
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight ? maxHeight : (tableHeight > 400 ? tableHeight : 400.0);
        
        return SizedBox(
          height: calculatedHeight.toDouble(),
          child: TabBarView(
        controller: _tabController,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topLeft,
              child: _buildOrderBookTable(
                theme,
                (orderBook.orderSearchCtrl.text.isNotEmpty
                        ? (orderBook.orderSearchItem ?? [])
                        : (orderBook.openOrder ?? [])),
                'Open Orders',
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topLeft,
              child: _buildOrderBookTable(
                theme,
                (orderBook.orderSearchCtrl.text.isNotEmpty
                        ? (orderBook.orderSearchItem ?? [])
                        : (orderBook.executedOrder ?? [])),
                'Executed Orders',
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topLeft,
              child: _buildTradeBookTable(
                theme,
                (orderBook.orderSearchCtrl.text.isNotEmpty
                        ? (orderBook.tradeBooksearch ?? [])
                        : (orderBook.tradeBook ?? [])),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topLeft,
              child: _buildGttOrderBookTable(
                theme,
                (orderBook.orderSearchCtrl.text.isNotEmpty
                        ? (orderBook.gttOrderBookSearch ?? [])
                        : (orderBook.gttOrderBookModel ?? [])),
              ),
            ),
          ),
          // MF tab with sub tabs: Orders and SIP
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildMFSubTabs(theme),
          ),
          // IPO Orders placeholder
          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 200),
          //   child: const IpoOrderBookScreenWeb(),
          // ),
          // // Bonds Orders placeholder
          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 200),
          //   child: const BondsOrderBookScreenWeb(),
          // ),
          const AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: BasketList(),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topLeft,
              child: const PendingAlertWeb()),
          ),
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
        // Content Area
        Expanded(
          child: _mfTabIndex == 0
              ? const MfOrderBookScreenWeb()
              : const MFSipdetScreenWeb(),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : (theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface),
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBookTable(ThemesProvider theme, List<OrderBookModel> orders, String title) {
    if (orders.isEmpty) {
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

    return Scrollbar(
      controller: _verticalScrollController,
      thumbVisibility: true,
      radius: Radius.zero,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(right: 16), // Space for vertical scrollbar
          child: Column(
            children: [
              Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                radius: Radius.zero,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16), // Space at top of horizontal scrollbar
                    child: DataTable(
              columnSpacing: 15,
              showCheckboxColumn: false,
              sortColumnIndex: _orderSortColumnIndex,
              sortAscending: _orderSortAscending,
              headingRowHeight: 44,
              headingRowColor: WidgetStateProperty.all(Colors.transparent),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary)
                        .withOpacity(0.05);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary)
                        .withOpacity(0.1);
                  }
                  return null;
                },
              ),
            columns: [
              DataColumn(
                label: _buildSortableColumnHeader('Instrument', theme, 0),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Product', theme, 1),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Type', theme, 2),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Qty', theme, 3),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Avg price', theme, 4),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('LTP', theme, 5),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Price', theme, 6),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Trigger price', theme, 7),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Order value', theme, 8),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Status', theme, 9),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Time', theme, 10),
                onSort: (columnIndex, ascending) => _onSortOrderTable(columnIndex, ascending),
              ),
            ],
            rows: _sortedOrders(orders).map((order) {
              // Use order number as unique identifier for hover (not token, which is shared across orders)
              final uniqueId = order.norenordno?.toString() ?? order.token?.toString() ?? '';
              
              return DataRow(
                onSelectChanged: (bool? selected) {
                  _openOrderDetail(order);
                },
                cells: [
                  // Instrument - text (left aligned)
                  _buildInstrumentCellWithHover(order, theme, uniqueId),
                  // Product - text (left aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildProductCell(order, theme), alignment: Alignment.centerLeft),
                  // Type - text (left aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildTypeCell(order, theme), alignment: Alignment.centerLeft),
                  // Qty - numeric (right aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildQtyCell(order, theme), alignment: Alignment.centerRight),
                  // Avg price - numeric (right aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildAvgPriceCell(order, theme), alignment: Alignment.centerRight),
                  // LTP - numeric (right aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildLTPCell(order, theme), alignment: Alignment.centerRight),
                  // Price - numeric (right aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildPriceCell(order, theme), alignment: Alignment.centerRight),
                  // Trigger price - numeric (right aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildTriggerPriceCell(order, theme), alignment: Alignment.centerRight),
                  // Order value - numeric (right aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildOrderValueCell(order, theme), alignment: Alignment.centerRight),
                  // Status - text (left aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildStatusCell(order, theme), alignment: Alignment.centerLeft),
                  // Time - text (left aligned)
                  _buildCellWithHover(order, theme, uniqueId, _buildTimeCell(order, theme), alignment: Alignment.centerLeft),
                ],
              );
            }).toList(),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      );
    
  }

  Widget _buildTradeBookTable(ThemesProvider theme, List<TradeBookModel> trades) {
    if (trades.isEmpty) {
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

    return Scrollbar(
      controller: _verticalScrollController,
      thumbVisibility: true,
      radius: Radius.zero,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(right: 16), // Space for vertical scrollbar
          child: Column(
            children: [
              Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                radius: Radius.zero,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16), // Space at top of horizontal scrollbar
                    child: DataTable(
              columnSpacing: 15,
              showCheckboxColumn: false,
              sortColumnIndex: _tradeSortColumnIndex,
              sortAscending: _tradeSortAscending,
              headingRowHeight: 44,
              headingRowColor: WidgetStateProperty.all(Colors.transparent),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary)
                        .withOpacity(0.05);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary)
                        .withOpacity(0.1);
                  }
                  return null;
                },
              ),
        columns: [
          DataColumn(
            label: _buildTradeSortableColumnHeader('Instrument', theme, 0),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildTradeSortableColumnHeader('Product', theme, 1),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildTradeSortableColumnHeader('Type', theme, 2),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildTradeSortableColumnHeader('Qty', theme, 3),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildTradeSortableColumnHeader('Price', theme, 4),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildTradeSortableColumnHeader('Trade value', theme, 5),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildTradeSortableColumnHeader('Order no', theme, 6),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
          DataColumn(
            label: _buildTradeSortableColumnHeader('Time', theme, 7),
            onSort: (columnIndex, ascending) => _onSortTradeTable(columnIndex, ascending),
          ),
        ],
        rows: _sortedTrades(trades).map((trade) {
          final token = trade.token ?? '';
          
          return DataRow(
            onSelectChanged: (bool? selected) {
              _openTradeDetail(trade);
            },
            cells: [
              // Instrument - text (left aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildSymbolCellForTrade(trade, theme), alignment: Alignment.centerLeft),
              // Product - text (left aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildProductCellForTrade(trade, theme), alignment: Alignment.centerLeft),
              // Type - text (left aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildTransactionCellForTrade(trade, theme), alignment: Alignment.centerLeft),
              // Qty - numeric (right aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildQtyCellForTrade(trade, theme), alignment: Alignment.centerRight),
              // Price - numeric (right aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildPriceCellForTrade(trade, theme), alignment: Alignment.centerRight),
              // Trade value - numeric (right aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildTradeValueCellForTrade(trade, theme), alignment: Alignment.centerRight),
              // Order no - text (left aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildOrderNoCellForTrade(trade, theme), alignment: Alignment.centerLeft),
              // Time - text (left aligned)
              _buildTradeCellWithHover(trade, theme, token, _buildTimeCellForTrade(trade, theme), alignment: Alignment.centerLeft),
            ],
          );
        }).toList(),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      );
    
  }

  Widget _buildGttOrderBookTable(ThemesProvider theme, List<GttOrderBookModel> gttOrders) {
    if (gttOrders.isEmpty) {
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

    return Scrollbar(
      controller: _verticalScrollController,
      thumbVisibility: true,
      radius: Radius.zero,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(right: 16), // Space for vertical scrollbar
          child: Column(
            children: [
              Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                radius: Radius.zero,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16), // Space at top of horizontal scrollbar
                    child: DataTable(
              columnSpacing: 10,
              showCheckboxColumn: false,
              sortColumnIndex: _gttSortColumnIndex,
              sortAscending: _gttSortAscending,
              headingRowHeight: 44,
              headingRowColor: WidgetStateProperty.all(Colors.transparent),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary)
                        .withOpacity(0.05);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return (theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary)
                        .withOpacity(0.1);
                  }
                  return null;
                },
              ),
          columns: [
            // Reordered to match order book: Instrument, Product, Type, Qty, LTP, Trigger price, Status, Time
            DataColumn(
              label: _buildGttSortableColumnHeader('Instrument', theme, 0),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildGttSortableColumnHeader('Product', theme, 1),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildGttSortableColumnHeader('Type', theme, 2),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildGttSortableColumnHeader('Qty', theme, 3),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildGttSortableColumnHeader('LTP', theme, 4),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildGttSortableColumnHeader('Trigger price', theme, 5),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildGttSortableColumnHeader('Status', theme, 6),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
            DataColumn(
              label: _buildGttSortableColumnHeader('Time', theme, 7),
              onSort: (columnIndex, ascending) => _onSortGttTable(columnIndex, ascending),
            ),
          ],
          rows: _sortedGtt(gttOrders).asMap().entries.map((entry) {
            final index = entry.key;
            final gttOrder = entry.value;
            // Create unique identifier for hover
            final uniqueId = '${gttOrder.alId ?? ''}_${gttOrder.tsym ?? ''}_$index';
            
            return DataRow(
              selected: _selectedOrders.contains(index),
              onSelectChanged: (bool? selected) {
                // Open GTT order detail when row is selected
                _openGttOrderDetail(gttOrder);
              },
              cells: [
                // Instrument - text (left aligned) with hover buttons
                _buildGttInstrumentCellWithHover(gttOrder, theme, uniqueId),
                // Product - text (left aligned)
                _buildGttCellWithHover(gttOrder, theme, uniqueId, _buildProductCellForGtt(gttOrder, theme), alignment: Alignment.centerLeft),
                // Type - text (left aligned)
                _buildGttCellWithHover(gttOrder, theme, uniqueId, _buildTypeCellForGtt(gttOrder, theme), alignment: Alignment.centerLeft),
                // Qty - numeric (right aligned)
                _buildGttCellWithHover(gttOrder, theme, uniqueId, _buildQtyCellForGtt(gttOrder, theme), alignment: Alignment.centerRight),
                // LTP - numeric (right aligned)
                _buildGttCellWithHover(gttOrder, theme, uniqueId, _buildLTPCellForGtt(gttOrder, theme), alignment: Alignment.centerRight),
                // Trigger price - numeric (right aligned)
                _buildGttCellWithHover(gttOrder, theme, uniqueId, _buildTriggerPriceCellForGtt(gttOrder, theme), alignment: Alignment.centerRight),
                // Status - text (left aligned)
                _buildGttCellWithHover(gttOrder, theme, uniqueId, _buildStatusCellForGtt(gttOrder, theme), alignment: Alignment.centerLeft),
                // Time - text (left aligned)
                _buildGttCellWithHover(gttOrder, theme, uniqueId, _buildTimeCellForGtt(gttOrder, theme), alignment: Alignment.centerLeft),
              ],
            );
          }).toList(),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      );
    
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _orderSortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.custom(
            fontSize: 14,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.bold,
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
                  color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  DataCell _buildCellWithHover(OrderBookModel order, ThemesProvider theme, String token, DataCell cell, {Alignment alignment = Alignment.centerRight}) {
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
          r = cmp(num.tryParse(a.qty.toString()) ?? 0, num.tryParse(b.qty.toString()) ?? 0);
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
          final av = (parseNum(a.avgprc ?? "0") * (int.tryParse(a.qty.toString()) ?? 0));
          final bv = (parseNum(b.avgprc ?? "0") * (int.tryParse(b.qty.toString()) ?? 0));
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
      if (_orderSortColumnIndex == columnIndex) {
        _orderSortAscending = !_orderSortAscending;
      } else {
        _orderSortColumnIndex = columnIndex;
        _orderSortAscending = ascending;
      }
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
          r = cmp(num.tryParse(a.qty.toString()) ?? 0, num.tryParse(b.qty.toString()) ?? 0);
          break;
        case 4: // Price
          r = cmp(parseNum(a.avgprc), parseNum(b.avgprc));
          break;
        case 5: // Trade value (flqty * flprc)
          final av = (parseNum(a.flqty?.toString() ?? "0") * parseNum(a.flprc ?? "0"));
          final bv = (parseNum(b.flqty?.toString() ?? "0") * parseNum(b.flprc ?? "0"));
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

  Widget _buildTradeSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _tradeSortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.custom(
            fontSize: 14,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.bold,
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
                  color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  List<GttOrderBookModel> _sortedGtt(List<GttOrderBookModel> gtt) {
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
          r = cmp(num.tryParse(a.qty.toString()) ?? 0, num.tryParse(b.qty.toString()) ?? 0);
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
      if (_gttSortColumnIndex == columnIndex) {
        _gttSortAscending = !_gttSortAscending;
      } else {
        _gttSortColumnIndex = columnIndex;
        _gttSortAscending = ascending;
      }
    });
  }

  DataCell _buildTradeCellWithHover(TradeBookModel trade, ThemesProvider theme, String token, DataCell cell, {Alignment alignment = Alignment.centerRight}) {
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

  DataCell _buildGttCellWithHover(GttOrderBookModel gttOrder, ThemesProvider theme, String token, DataCell cell, {Alignment alignment = Alignment.centerRight}) {
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

  Widget _buildGttSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _gttSortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.custom(
            fontSize: 14,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.bold,
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
                  color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
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
    final uniqueId = orderData.norenordno?.toString() ?? orderData.token?.toString() ?? '';
    if (_isProcessingCancel && _processingOrderToken == uniqueId) return;

    try {
      setState(() {
        _isProcessingCancel = true;
        _processingOrderToken = uniqueId;
      });

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
          ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'Order Cancelled'),
          );
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          error(context, 'Failed to cancel order'),
        );
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
    final uniqueId = orderData.norenordno?.toString() ?? orderData.token?.toString() ?? '';
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
        ScaffoldMessenger.of(context).showSnackBar(
          error(context, 'Unable to fetch scrip information'),
        );
        return;
      }

      // Show modify order screen as dialog (same format as place order)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: SizedBox(
              width: 500,
              height: MediaQuery.of(context).size.height * 0.9,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ModifyPlaceOrderScreenWeb(
                    modifyOrderArgs: orderData,
                    orderArg: _createOrderArgs(orderData),
                    scripInfo: scripInfo,
                  );
                }
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          error(context, 'Failed to open modify order: ${e.toString()}'),
        );
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

  Future<void> _handleRepeatOrder(OrderBookModel orderData) async {
    try {
      await ref.read(marketWatchProvider).fetchScripInfo(
        "${orderData.token}",
        "${orderData.exch}",
        context,
        true,
      );

      if (!mounted) return;

      ResponsiveNavigation.toPlaceOrderScreen(context: context, arguments: {
        "orderArg": _createOrderArgs(orderData),
        "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
        "isBskt": '',
      });
    } catch (e) {
      // Handle error
    }
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
    final uniqueId = gttOrderData.alId?.toString() ?? gttOrderData.tsym?.toString() ?? '';
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
            backgroundColor: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                            fontWeight: FontWeight.w700,
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
                              padding: const EdgeInsets.all(5),
                              child: Icon(
                                Icons.close,
                                size: 18,
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Are you sure you want to cancel this GTT order?\n\n$displayText',
                              textAlign: TextAlign.center,
                              style: WebTextStyles.custom(
                                fontSize: 13,
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.isDarkMode
                                  ? WebDarkColors.primary
                                  : WebColors.primary,
                              minimumSize: const Size(0, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              'Cancel Order',
                              style: WebTextStyles.custom(
                                fontSize: 13,
                                isDarkTheme: theme.isDarkMode,
                                color: WebColors.surface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (shouldCancel != true) {
        return;
      }

      // Cancel the GTT order
      await ref.read(orderProvider).cancelGttOrder(
        "${gttOrderData.alId}",
        context,
      );

      // Refresh GTT order book after successful cancel
      await ref.read(orderProvider).fetchGTTOrderBook(context, "");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, 'GTT Order Cancelled'),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          error(context, 'Failed to cancel GTT order'),
        );
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
    final uniqueId = gttOrderData.alId?.toString() ?? gttOrderData.tsym?.toString() ?? '';
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
        ScaffoldMessenger.of(context).showSnackBar(
          error(context, 'Unable to fetch scrip information'),
        );
        return;
      }

      // Show modify GTT order screen as dialog
      // ModifyGttWeb already returns a Dialog, so we just show it directly
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ModifyGttWeb(
            gttOrderBook: gttOrderData,
            scripInfo: scripInfo,
          );
        },
      );
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          error(context, 'Failed to open modify GTT order: ${e.toString()}'),
        );
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: buttonColor,
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataCell _buildInstrumentCellWithHover(OrderBookModel order, ThemesProvider theme, String token) {
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
                flex: isHovered ? 1 : 2, // When hovered, text takes less space but still visible
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

  Widget _buildOrderHoverButton({
    String? label,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final borderRadiusValue = borderRadius ?? 5.0;
    return SizedBox(
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                label ?? "",
                style: WebTextStyles.custom(
                  fontSize: 11,
                  isDarkTheme: theme.isDarkMode,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildProductCell(OrderBookModel item, ThemesProvider theme) {
    String product = item.sPrdtAli ?? 'N/A';
    
    return DataCell(
      Text(
        product,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildQtyCell(OrderBookModel item, ThemesProvider theme) {
    String qty = item.qty?.toString() ?? '0.00';
    
    return DataCell(
      Text(
        qty,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildAvgPriceCell(OrderBookModel item, ThemesProvider theme) {
    String avgPrice = item.avgprc ?? '0.00';
    
    return DataCell(
      Text(
        avgPrice,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildLTPCell(OrderBookModel item, ThemesProvider theme) {
    String ltpValue = _getValidLTP(item);
    
    return DataCell(
      Text(
        ltpValue,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildPriceCell(OrderBookModel item, ThemesProvider theme) {
    String displayText = _getValidPrice(item);
    
    return DataCell(
      Text(
        displayText,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildStatusCell(OrderBookModel item, ThemesProvider theme) {
    String statusText = _getStatusText(item);
    Color statusColor = _getStatusColor(statusText, theme);
    
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusText,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: statusColor,
            fontWeight: WebFonts.medium,
          ),
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
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataCell _buildTransactionCellForTrade(TradeBookModel item, ThemesProvider theme) {
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildProductCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String product = item.sPrdtAli ?? 'N/A';
    
    return DataCell(
      Text(
        product,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildTradeValueCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String tradeValue = "0.00";
    
    try {
      if (item.flqty != null && item.flprc != null) {
        tradeValue = (double.parse(item.flqty!) * double.parse(item.flprc!)).toStringAsFixed(2);
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildOrderNoCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String orderNo = item.norenordno?.toString() ?? 'N/A';
    
    return DataCell(
      Text(
        orderNo,
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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

  DataCell _buildInstrumentCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        '${item.tsym?.replaceAll("-EQ", "") ?? 'N/A'}-${item.exch ?? ''}',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }

  DataCell _buildGttInstrumentCellWithHover(GttOrderBookModel gttOrder, ThemesProvider theme, String token) {
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
                flex: isHovered ? 1 : 2, // When hovered, text takes less space but still visible
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

  DataCell _buildProductCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.placeOrderParams?.sPrdtAli ?? '',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }


  DataCell _buildTriggerPriceCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.d ?? '0.00',
        style: WebTextStyles.custom(
          fontSize: 13,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          fontWeight: WebFonts.medium,
        ),
      ),
    );
  }


  DataCell _buildStatusCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    final status = item.gttOrderCurrentStatus?.toUpperCase() ?? '';
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getGttStatusColor(status, theme).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _getGttStatusText(status),
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: _getGttStatusColor(status, theme),
            fontWeight: WebFonts.medium,
          ),
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
