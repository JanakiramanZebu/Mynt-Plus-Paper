import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/Mobile/order_book/basket/basket_list.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/no_data_found.dart';
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
  
  // Sort state per table
  int? _orderSortColumnIndex;
  bool _orderSortAscending = true;
  int? _tradeSortColumnIndex;
  bool _tradeSortAscending = true;
  int? _gttSortColumnIndex;
  bool _gttSortAscending = true;

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

    return GestureDetector(
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
                // Header Section
                _buildHeader(theme, orderBook),
                const SizedBox(height: 24),
                
                // Main Content Area
                _buildMainContent(theme, orderBook),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme, OrderProvider orderBook) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                    borderRadius: BorderRadius.circular(5),
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
              // Removed standalone filter button; sorting is now available on each header
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemesProvider theme, OrderProvider orderBook) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          _buildTabs(theme, orderBook),
          
          // Content Area
          _buildContentArea(theme, orderBook),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemesProvider theme, OrderProvider orderBook) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(8),
        dividerColor: Colors.transparent,
        unselectedLabelColor: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
        labelColor: Colors.white,
        labelStyle: TextWidget.textStyle(
          fontSize: 14,
          theme: theme.isDarkMode,
          fw: 2,
          color: Colors.white,
        ),
        unselectedLabelStyle: TextWidget.textStyle(
          fontSize: 14,
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fw: 1,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tabs: orderBook.orderTabName.asMap().entries.map((entry) {
          final index = entry.key;
          final tabString = entry.value;
          
          final parts = tabString.text?.split(' ') ?? [];
          final title = parts.first;
          final badge = parts.length > 1 ? parts[1] : null;

          return Tab(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    style: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      fw: _tabController.index == index ? 2 : 1,
                      color: _tabController.index == index 
                          ? Colors.white
                          : theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    ),
                    child: Text(title),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tabController.index == index 
                            ? Colors.white.withOpacity(0.2)
                            : theme.isDarkMode 
                                ? colors.textSecondaryDark.withOpacity(0.1)
                                : colors.textSecondaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _tabController.index == index 
                              ? Colors.white.withOpacity(0.3)
                              : theme.isDarkMode 
                                  ? colors.textSecondaryDark.withOpacity(0.2)
                                  : colors.textSecondaryLight.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        style: TextWidget.textStyle(
                          fontSize: 11,
                          theme: theme.isDarkMode,
                          fw: 2,
                          color: _tabController.index == index 
                              ? Colors.white
                              : theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        ),
                        child: Text(badge),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentArea(ThemesProvider theme, OrderProvider orderBook) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 600,
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: const BasketList(),
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
  }

  Widget _buildMFSubTabs(ThemesProvider theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorPadding: const EdgeInsets.all(8),
                dividerColor: Colors.transparent,
                unselectedLabelColor: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                labelColor: Colors.white,
                labelStyle: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  fw: 2,
                  color: Colors.white,
                ),
                unselectedLabelStyle: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 1,
                ),
                tabs: const [
                  Tab(text: 'Orders'),
                  Tab(text: 'SIP'),
                ],
              ),
            ),
            Expanded(
              child: const TabBarView(
                children: [
                  MfOrderBookScreenWeb(),
                  MFSipdetScreenWeb(),
                ],
              ),
            ),
          ],
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

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GestureDetector(
          onTap: () {
            // Handle tap on empty space if needed
          },
          child: DataTable(
            showCheckboxColumn: false,
            sortColumnIndex: _orderSortColumnIndex,
            sortAscending: _orderSortAscending,
            headingRowColor: WidgetStateProperty.all(
              theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.05);
                }
                return null;
              },
            ),
            columns: [
              DataColumn(
                label: _buildSortableColumnHeader('Time', theme,
                    isActive: _orderSortColumnIndex == 0, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(0),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Type', theme,
                    isActive: _orderSortColumnIndex == 1, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(1),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Instrument', theme,
                    isActive: _orderSortColumnIndex == 2, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(2),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Product', theme,
                    isActive: _orderSortColumnIndex == 3, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(3),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Qty', theme,
                    isActive: _orderSortColumnIndex == 4, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(4),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Avg price', theme,
                    isActive: _orderSortColumnIndex == 5, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(5),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('LTP', theme,
                    isActive: _orderSortColumnIndex == 6, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(6),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Price', theme,
                    isActive: _orderSortColumnIndex == 7, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(7),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Trigger price', theme,
                    isActive: _orderSortColumnIndex == 8, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(8),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Order value', theme,
                    isActive: _orderSortColumnIndex == 9, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(9),
              ),
              DataColumn(
                label: _buildSortableColumnHeader('Status', theme,
                    isActive: _orderSortColumnIndex == 10, ascending: _orderSortAscending),
                onSort: (i, asc) => _onSortOrderTable(10),
              ),
            ],
            rows: _sortedOrders(orders).asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              
              return DataRow(
                selected: _selectedOrders.contains(index),
                onSelectChanged: (bool? selected) {
                  // Open detail view when row is selected
                  _openOrderDetail(order);
                },
                cells: [
                  _buildTimeCell(order, theme),
                  _buildTypeCell(order, theme),
                  _buildInstrumentCell(order, theme),
                  _buildProductCell(order, theme),
                  _buildQtyCell(order, theme),
                  _buildAvgPriceCell(order, theme),
                  _buildLTPCell(order, theme),
                  _buildPriceCell(order, theme),
                  _buildTriggerPriceCell(order, theme),
                  _buildOrderValueCell(order, theme),
                  _buildStatusCell(order, theme),
                ],
              );
            }).toList(),
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

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: DataTable(
          showCheckboxColumn: false,
          sortColumnIndex: _tradeSortColumnIndex,
          sortAscending: _tradeSortAscending,
        headingRowColor: WidgetStateProperty.all(
          theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        ),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.05);
            }
            return null;
          },
        ),
        columns: [
          DataColumn(
            label: _buildSortableColumnHeader('Time', theme,
                isActive: _tradeSortColumnIndex == 0, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(0),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Type', theme,
                isActive: _tradeSortColumnIndex == 1, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(1),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Instrument', theme,
                isActive: _tradeSortColumnIndex == 2, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(2),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Product', theme,
                isActive: _tradeSortColumnIndex == 3, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(3),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Qty', theme,
                isActive: _tradeSortColumnIndex == 4, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(4),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Price', theme,
                isActive: _tradeSortColumnIndex == 5, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(5),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Trade value', theme,
                isActive: _tradeSortColumnIndex == 6, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(6),
          ),
          DataColumn(
            label: _buildSortableColumnHeader('Order no', theme,
                isActive: _tradeSortColumnIndex == 7, ascending: _tradeSortAscending),
            onSort: (i, asc) => _onSortTradeTable(7),
          ),
        ],
        rows: _sortedTrades(trades).asMap().entries.map((entry) {
          final index = entry.key;
          final trade = entry.value;
          
          return DataRow(
            selected: _selectedOrders.contains(index),
            onSelectChanged: (bool? selected) {
              // Open trade detail when row is selected
              _openTradeDetail(trade);
            },
            cells: [
              _buildTimeCellForTrade(trade, theme),
              _buildTransactionCellForTrade(trade, theme),
              _buildSymbolCellForTrade(trade, theme),
              _buildProductCellForTrade(trade, theme),
              _buildQtyCellForTrade(trade, theme),
              _buildPriceCellForTrade(trade, theme),
              _buildTradeValueCellForTrade(trade, theme),
              _buildOrderNoCellForTrade(trade, theme),
            ],
          );
        }).toList(),
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

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: DataTable(
          showCheckboxColumn: false,
          sortColumnIndex: _gttSortColumnIndex,
          sortAscending: _gttSortAscending,
          headingRowColor: WidgetStateProperty.all(
            theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
          ),
          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.1);
              }
              if (states.contains(WidgetState.hovered)) {
                return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.05);
              }
              return null;
            },
          ),
          columns: [
            DataColumn(
              label: _buildSortableColumnHeader('Time', theme,
                  isActive: _gttSortColumnIndex == 0, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(0),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Type', theme,
                  isActive: _gttSortColumnIndex == 1, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(1),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Instrument', theme,
                  isActive: _gttSortColumnIndex == 2, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(2),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Product', theme,
                  isActive: _gttSortColumnIndex == 3, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(3),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Qty', theme,
                  isActive: _gttSortColumnIndex == 4, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(4),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('LTP', theme,
                  isActive: _gttSortColumnIndex == 5, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(5),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Trigger price', theme,
                  isActive: _gttSortColumnIndex == 6, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(6),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Status', theme,
                  isActive: _gttSortColumnIndex == 7, ascending: _gttSortAscending),
              onSort: (i, asc) => _onSortGttTable(7),
            ),
          ],
          rows: _sortedGtt(gttOrders).asMap().entries.map((entry) {
            final index = entry.key;
            final gttOrder = entry.value;
            
            return DataRow(
              selected: _selectedOrders.contains(index),
              onSelectChanged: (bool? selected) {
                // Open GTT order detail when row is selected
                _openGttOrderDetail(gttOrder);
              },
              cells: [
                _buildTimeCellForGtt(gttOrder, theme),
                _buildTypeCellForGtt(gttOrder, theme),
                _buildInstrumentCellForGtt(gttOrder, theme),
                _buildProductCellForGtt(gttOrder, theme),
                _buildQtyCellForGtt(gttOrder, theme),
                _buildLTPCellForGtt(gttOrder, theme),
                _buildTriggerPriceCellForGtt(gttOrder, theme),
                _buildStatusCellForGtt(gttOrder, theme),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, {bool isActive = false, bool ascending = true}) {
    // Rely on DataTable's built-in sort indicator; don't render a custom arrow here
    return Text(
      label,
      style: TextWidget.textStyle(
        fontSize: 12,
        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
        theme: theme.isDarkMode,
        fw: 2,
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
        case 0: // Time
          r = cmp(a.norentm, b.norentm);
          break;
        case 1: // Type
          r = cmp(a.trantype, b.trantype);
          break;
        case 2: // Instrument
          r = cmp(a.tsym, b.tsym);
          break;
        case 3: // Product
          r = cmp(a.sPrdtAli ?? a.prd, b.sPrdtAli ?? b.prd);
          break;
        case 4: // Qty
          r = cmp(num.tryParse(a.qty.toString()) ?? 0, num.tryParse(b.qty.toString()) ?? 0);
          break;
        case 5: // Avg price
          r = cmp(parseNum(a.avgprc), parseNum(b.avgprc));
          break;
        case 6: // LTP
          r = cmp(parseNum(a.ltp), parseNum(b.ltp));
          break;
        case 7: // Price
          r = cmp(parseNum(a.prc), parseNum(b.prc));
          break;
        case 8: // Trigger price
          r = cmp(parseNum(a.trgprc), parseNum(b.trgprc));
          break;
        case 9: // Order value
          final av = (parseNum(a.prc) * (int.tryParse(a.qty.toString()) ?? 0));
          final bv = (parseNum(b.prc) * (int.tryParse(b.qty.toString()) ?? 0));
          r = cmp(av, bv);
          break;
        case 10: // Status
          r = cmp(a.status, b.status);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  void _onSortOrderTable(int columnIndex) {
    setState(() {
      if (_orderSortColumnIndex == columnIndex) {
        _orderSortAscending = !_orderSortAscending; // toggle asc/desc
      } else {
        _orderSortColumnIndex = columnIndex;
        _orderSortAscending = true; // default to ascending on new column
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
        case 0: // Time
          r = cmp(a.norentm, b.norentm);
          break;
        case 1: // Type (Transaction)
          r = cmp(a.trantype, b.trantype);
          break;
        case 2: // Instrument
          r = cmp(a.tsym, b.tsym);
          break;
        case 3: // Product
          r = cmp(a.sPrdtAli, b.sPrdtAli);
          break;
        case 4: // Qty
          r = cmp(num.tryParse(a.qty.toString()) ?? 0, num.tryParse(b.qty.toString()) ?? 0);
          break;
        case 5: // Price
          r = cmp(parseNum(a.avgprc), parseNum(b.avgprc));
          break;
        case 6: // Trade value (flprc)
          r = cmp(parseNum(a.flprc), parseNum(b.flprc));
          break;
        case 7: // Order no
          r = cmp(a.norenordno, b.norenordno);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  void _onSortTradeTable(int columnIndex) {
    setState(() {
      if (_tradeSortColumnIndex == columnIndex) {
        _tradeSortAscending = !_tradeSortAscending;
      } else {
        _tradeSortColumnIndex = columnIndex;
        _tradeSortAscending = true;
      }
    });
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
        case 0: // Time
          r = cmp(a.norentm, b.norentm);
          break;
        case 1: // Type
          r = cmp(a.trantype, b.trantype);
          break;
        case 2: // Instrument
          r = cmp(a.tsym, b.tsym);
          break;
        case 3: // Product
          r = cmp(a.placeOrderParams?.sPrdtAli, b.placeOrderParams?.sPrdtAli);
          break;
        case 4: // Qty
          r = cmp(num.tryParse(a.qty.toString()) ?? 0, num.tryParse(b.qty.toString()) ?? 0);
          break;
        case 5: // LTP
          r = cmp(parseNum(a.ltp), parseNum(b.ltp));
          break;
        case 6: // Trigger price
          r = cmp(parseNum(a.d), parseNum(b.d));
          break;
        case 7: // Status
          r = cmp(a.gttOrderCurrentStatus, b.gttOrderCurrentStatus);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  void _onSortGttTable(int columnIndex) {
    setState(() {
      if (_gttSortColumnIndex == columnIndex) {
        _gttSortAscending = !_gttSortAscending;
      } else {
        _gttSortColumnIndex = columnIndex;
        _gttSortAscending = true;
      }
    });
  }

  void _openOrderDetail(OrderBookModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderBookDetailScreenWeb(orderBookData: order);
      },
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
  DataCell _buildTimeCell(OrderBookModel item, ThemesProvider theme) {
    // Format time to match web UI: "10:09:44"
    String time = item.norentm != null ? item.norentm! : '0.00';
    
    return DataCell(
      Text(
       formatDateTime(value: time),
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildTypeCell(OrderBookModel item, ThemesProvider theme) {
    // Match web UI BUY/SELL button format
    String buySell = item.trantype == "S" ? "SELL" : "BUY";
    Color buttonColor = item.trantype == "S"
        ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
        : (theme.isDarkMode ? colors.profitDark : colors.profitLight);
    
    return DataCell(
      Text(
        buySell,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: buttonColor,
          theme: false,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildInstrumentCell(OrderBookModel item, ThemesProvider theme) {
    // Match web UI instrument format: "TCS-EQ NSE"
    String symbol = '${item.tsym}';
    String exchange = item.exch ?? '';
    
    String displayText = symbol;
    if (exchange.isNotEmpty) {
      displayText += ' $exchange';
    }
    
    return DataCell(
      Text(
        displayText,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildProductCell(OrderBookModel item, ThemesProvider theme) {
    String product = item.sPrdtAli ?? 'N/A';
    
    return DataCell(
      Text(
        product,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildQtyCell(OrderBookModel item, ThemesProvider theme) {
    // Match web UI quantity format: "1"
    String qty = item.qty?.toString() ?? '0.00';
    
    return DataCell(
      Text(
        qty,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildAvgPriceCell(OrderBookModel item, ThemesProvider theme) {
    // Match web UI avg price format: "0.00"
    String avgPrice = item.avgprc ?? '0.00';
    
    return DataCell(
      Text(
        avgPrice,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildOrderValueCell(OrderBookModel item, ThemesProvider theme) {
    // Match web UI order value format: "0.00"
    String orderValue = '0.00';
    
    try {
      double price = double.tryParse(item.prc ?? "0") ?? 0.0;
      int qty = int.tryParse(item.qty.toString()) ?? 0;
      orderValue = (price * qty).toStringAsFixed(2);
    } catch (e) {
      orderValue = '0.00';
    }
    
    return DataCell(
      Text(
        orderValue,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }


  DataCell _buildLTPCell(OrderBookModel item, ThemesProvider theme) {
    // Match web UI LTP format: "3001.50" (without LTP prefix)
    // LTP should show real-time data from WebSocket
    String ltpValue = _getValidLTP(item);
    
    return DataCell(
      Text(
        ltpValue,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }


  DataCell _buildPriceCell(OrderBookModel item, ThemesProvider theme) {
    // Match mobile UI price display logic
    String displayText = _getValidPrice(item);
    
    return DataCell(
      Text(
        displayText,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }


  DataCell _buildStatusCell(OrderBookModel item, ThemesProvider theme) {
    // Match mobile UI status display
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
          style: TextWidget.textStyle(
            fontSize: 12,
            color: statusColor,
            theme: false,
            fw: 2,
          ),
        ),
      ),
    );
  }


  DataCell _buildTriggerPriceCell(OrderBookModel item, ThemesProvider theme) {
    // For orders, trigger price is directly available as trgprc
    String triggerPrice = '0.00';
    
    // Check direct trgprc property (for regular orders)
    if (item.trgprc != null && item.trgprc != '0' && item.trgprc != '0.00') {
      triggerPrice = item.trgprc!;
    } 
    // // Fallback to order price
    // else if (item.prc != null) {
    //   triggerPrice = item.prc!;
    // }
    
    return DataCell(
      Text(
        triggerPrice,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
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
    // Match mobile UI formatting exactly
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildTransactionCellForTrade(TradeBookModel item, ThemesProvider theme) {
    // Match mobile UI transaction format: "BUY 0 / 550"
    String buySell = item.trantype == "S" ? "SELL" : "BUY";
    
    String displayText = '$buySell';
    
    Color textColor = item.trantype == "S"
        ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
        : (theme.isDarkMode ? colors.profitDark : colors.profitLight);
    
    return DataCell(
      Text(
        displayText,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: textColor,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildTimeCellForTrade(TradeBookModel item, ThemesProvider theme) {
    // Match mobile UI time format: "10:13 AM"
    String time = item.norentm != null ? _formatTime(item.norentm!) : 'N/A';
    
    return DataCell(
      Text(
       formatDateTime(value:time),
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildProductCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String product = item.sPrdtAli ?? 'N/A';
    
    return DataCell(
      Text(
        product,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildQtyCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String qty = item.qty?.toString() ?? 'N/A';
    
    return DataCell(
      Text(
        qty,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildPriceCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String price = item.avgprc?.toString() ?? 'N/A';
    
    return DataCell(
      Text(
        price,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildTradeValueCellForTrade(TradeBookModel item, ThemesProvider theme) {
    // Use flprc as requested
    String tradeValue = "${item.flqty != null && item.flprc != null ? (double.parse(item.flqty!) * double.parse(item.flprc!)) : 0.00}";
    
    return DataCell(
      Text(
        tradeValue,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildOrderNoCellForTrade(TradeBookModel item, ThemesProvider theme) {
    String orderNo = item.norenordno?.toString() ?? 'N/A';
    
    return DataCell(
      Text(
        orderNo,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
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
    
    // Fallback to other price fields if prc is not available
    if (isValidPrice(item.avgprc)) {
      return item.avgprc!;
    } else if (isValidPrice(item.c)) {
      return item.c!;
    } else if (isValidPrice(item.close)) {
      return item.close!;
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildTypeCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    final isBuy = item.trantype == "B";
    return DataCell(
      Text(
        isBuy ? "BUY" : "SELL",
        style: TextWidget.textStyle(
          fontSize: 12,
          color: isBuy
              ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
              : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildInstrumentCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        '${item.tsym?.replaceAll("-EQ", "") ?? 'N/A'}-${item.exch ?? ''}',
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildProductCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.placeOrderParams?.sPrdtAli ?? '',
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildQtyCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.qty?.toString() ?? '0',
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }


  DataCell _buildLTPCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        _getValidLTPForGtt(item),
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }


  DataCell _buildTriggerPriceCellForGtt(GttOrderBookModel item, ThemesProvider theme) {
    return DataCell(
      Text(
        item.d ?? '0.00',
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
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
          style: TextWidget.textStyle(
            fontSize: 12,
            color: _getGttStatusColor(status, theme),
            theme: theme.isDarkMode,
            fw: 2,
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
