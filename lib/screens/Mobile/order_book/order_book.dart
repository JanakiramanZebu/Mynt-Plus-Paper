import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/custom_text_form_field.dart';

import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/shocase_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../utils/no_emoji_inputformatter.dart';
import 'filter_scrip_bottom_sheet.dart';
import 'order_book_detail.dart';

class OrderBook extends ConsumerStatefulWidget {
  final List<OrderBookModel> orderBook;
  const OrderBook({super.key, required this.orderBook});

  @override
  ConsumerState<OrderBook> createState() => _OrderBookState();
}

class _OrderBookState extends ConsumerState<OrderBook> {
  StreamSubscription? _socketSubscription;

  // Throttling properties
  DateTime _lastSocketUpdateTime = DateTime.now();
  // FIX: Reduce throttling interval for faster LTP updates
  static const Duration _minUpdateInterval = Duration(milliseconds: 50);

  // Cache of items needing updates
  final Map<String, Map<String, dynamic>> _pendingUpdates = {};
  Timer? _batchUpdateTimer;

  // Timer for periodic data refresh - especially useful after market hours
  Timer? _periodicRefreshTimer;

  @override
  void initState() {
    super.initState();
    _setupSocketSubscription();

    // Schedule initial data fetch for any missing LTPs
    _scheduleDataFetch();

    // Set up periodic refresh to keep data fresh even without socket updates
    _setupPeriodicRefresh();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _batchUpdateTimer?.cancel();
    _periodicRefreshTimer?.cancel();
    super.dispose();
  }

  void _setupSocketSubscription() {
    // Use microtask to ensure context is available
    Future.microtask(() {
      final socketProvider = ref.read(websocketProvider);

      _socketSubscription =
          socketProvider.socketDataStream.listen((socketDatas) {
        if (socketDatas.isEmpty) return;

        // Apply throttling to avoid rapid updates
        final now = DateTime.now();
        if (now.difference(_lastSocketUpdateTime) < _minUpdateInterval) {
          _queueUpdates(socketDatas);
          return;
        }

        _lastSocketUpdateTime = now;
        _processUpdates(socketDatas);
      });
    });
  }

  void _queueUpdates(Map socketDatas) {
    // Queue updates to be processed in batch
    for (var order in _getActiveOrders()) {
      if (order.token == null || order.token!.isEmpty) continue;

      // Skip if no socket data for this token
      if (!socketDatas.containsKey(order.token)) continue;

      // Store update in pending queue
      _pendingUpdates[order.token!] = socketDatas[order.token];
    }

    // Schedule batch update if not already scheduled
    if (_batchUpdateTimer == null || !_batchUpdateTimer!.isActive) {
      _batchUpdateTimer = Timer(_minUpdateInterval, _processPendingUpdates);
    }
  }

  void _processPendingUpdates() {
    if (_pendingUpdates.isEmpty) return;

    // Create a map matching the socket data format
    final batchData = Map<String, dynamic>.from(_pendingUpdates);
    _pendingUpdates.clear();

    _processUpdates(batchData);
  }

  void _processUpdates(Map socketDatas) {
    bool hasUpdates = false;
    final items = _getActiveOrders();
    final orderProv = ref.read(orderProvider);

    // Helper function to check if a string is a valid numeric price
    bool isValidNumeric(String? value) {
      if (value == null || value == "null") {
        return false;
      }
      // FIX: Allow zero values when necessary (e.g., for newly listed stocks)
      return double.tryParse(value) != null;
    }

    for (var order in items) {
      if (order.token == null || order.token!.isEmpty) continue;

      // Skip if no socket data for this token
      if (!socketDatas.containsKey(order.token)) continue;

      final socketData = socketDatas[order.token];
      if (socketData == null || socketData.isEmpty) continue;

      // Cache current values to detect changes
      final currentLtp = order.ltp;
      final currentPerChange = order.perChange;

      // FIX: Prioritize LTP updates - check if it has a valid value
      final lp = socketData['lp']?.toString();
      if (isValidNumeric(lp)) {
        // Always update if different to ensure real-time display
        if (lp != currentLtp) {
          order.ltp = lp;
          hasUpdates = true;
        }
      }

      // Only update percent change if it has a valid value and has changed
      final pc = socketData['pc']?.toString();
      if (isValidNumeric(pc) && pc != currentPerChange) {
        order.perChange = pc;
        hasUpdates = true;
      }

      // Update change value too if available
      final chng = socketData['chng']?.toString();
      if (isValidNumeric(chng) && chng != order.change) {
        order.change = chng;
        hasUpdates = true;
      }
    }

    // FIX: Immediately update UI when price data changes
    if (hasUpdates && mounted) {
      // Reapply the last sorting if there's a persistent sort setting
      if (orderProv.lastOrderSortMethod.isNotEmpty) {
        orderProv.filterOrders(sorting: orderProv.lastOrderSortMethod);
      }
      setState(() {});
    }
  }

  // Helper to get current active orders from either search or main list
  List<OrderBookModel> _getActiveOrders() {
    final orderProv = ref.read(orderProvider);
    return orderProv.showSearchHold
        ? orderProv.orderSearchItem ?? []
        : widget.orderBook;
  }

  void _setupPeriodicRefresh() {
    // Refresh LTP data every 60 seconds (or adjust as needed)
    // This ensures we get updated data even when socket updates are sparse
    _periodicRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        _scheduleDataFetch();
      }
    });
  }

  void _scheduleDataFetch() {
    // Delay the fetch to allow for widget initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      // Get order items that need updating
      final itemsToUpdate = _getItemsWithMissingData();
      if (itemsToUpdate.isEmpty) return;

      // Fetch LTP data for these orders
      _fetchCurrentLtpData(itemsToUpdate);
    });
  }

  List<OrderBookModel> _getItemsWithMissingData() {
    final items = _getActiveOrders();

    // Filter to orders with missing or zero LTP
    return items.where((order) {
      // Check if LTP is missing or invalid
      return order.token != null &&
          order.token!.isNotEmpty &&
          (order.ltp == null ||
              order.ltp == "null" ||
              order.ltp == "0" ||
              order.ltp == "0.00");
    }).toList();
  }

  Future<void> _fetchCurrentLtpData(List<OrderBookModel> items) async {
    if (items.isEmpty) return;

    try {
      final orderProv = ref.read(orderProvider);

      // Create batch LTP arguments
      List<Map<String, String>> ltpArgs = [];
      for (var order in items) {
        if (order.token == null || order.exch == null) continue;
        ltpArgs.add({"exch": order.exch!, "token": order.token!});
      }

      if (ltpArgs.isEmpty) return;

      // Call API to get current LTP data
      final api = ref.read(orderProvider).api;
      final response = await api.getLTP(ltpArgs);

      if (response.statusCode != 200) return;

      Map res = jsonDecode(response.body);
      if (res["data"] == null) return;

      bool hasUpdates = false;

      // Update the orders with the fetched data
      for (var order in items) {
        if (order.token == null || !res["data"].containsKey(order.token))
          continue;

        final data = res["data"][order.token];

        // Helper function to check if a string is a valid numeric price
        bool isValidNumeric(String? value) {
          if (value == null ||
              value == "null" ||
              value == "0" ||
              value == "0.00") {
            return false;
          }
          return double.tryParse(value) != null;
        }

        // Update LTP if available
        if (data["lp"] != null && isValidNumeric(data["lp"].toString())) {
          order.ltp = data["lp"].toString();
          hasUpdates = true;
        }

        // Update close price if available
        if (data["close"] != null && isValidNumeric(data["close"].toString())) {
          order.close = data["close"].toString();
          order.c = data["close"].toString();
          hasUpdates = true;
        }

        // Calculate or update changes
        if (isValidNumeric(order.ltp) && isValidNumeric(order.close)) {
          final ltp = double.tryParse(order.ltp!)!;
          final close = double.tryParse(order.close!)!;

          // Update change
          order.change = (ltp - close).toStringAsFixed(2);

          // Update percent change
          if (close > 0) {
            order.perChange = ((ltp - close) * 100 / close).toStringAsFixed(2);
          }

          hasUpdates = true;
        } else if (data["change"] != null &&
            isValidNumeric(data["change"].toString())) {
          // If direct calculation not possible but API provides change
          order.perChange = data["change"].toString();
          hasUpdates = true;
        }
      }

      if (hasUpdates && mounted) {
        // Apply any persistent sort setting
        if (orderProv.lastOrderSortMethod.isNotEmpty) {
          orderProv.filterOrders(sorting: orderProv.lastOrderSortMethod);
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error fetching LTP data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider);
    final searchorder = order.orderSearchItem;
    final theme = ref.read(themeProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(children: [
        // if (widget.orderBook.isNotEmpty) _buildFilterSearchHeader(order, theme),
        Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                order.fetchOrderBook(context, true);
                order.fetchTradeBook(context);
              },
              child: searchorder!.isEmpty
                  ? widget.orderBook.isNotEmpty
                      ? _buildOrderList(widget.orderBook, order, theme)
                      : const SizedBox(height: 500, child: NoDataFound())
                  : searchorder.isNotEmpty
                      ? _buildOrderList(searchorder, order, theme)
                      : Container()),
        )
      ]),
    );
  }

  // Filter and search header
  Widget _buildFilterSearchHeader(OrderProvider order, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: order.orderSearchCtrl,
              autofocus: false,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                UpperCaseTextFormatter(),
                NoEmojiInputFormatter(),
                FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
              ],
              style: TextWidget.textStyle(
                fontSize: 14,
                theme: theme.isDarkMode,
                color: const Color(0xff000000),
                fw: 00,
              ),
              onChanged: (value) {
                order.orderSearch(value, context);
              },
              decoration: InputDecoration(
                fillColor: theme.isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffF1F3F8).withOpacity(0.5),
                filled: true,
                hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    color: const Color(0xff000000),
                    fw: 3),
                hintText: "Search",
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
                disabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(assets.searchIcon,
                      width: 18,
                      height: 18,
                      color: const Color(0xff586279),
                      fit: BoxFit.scaleDown),
                ),
                suffixIcon: order.orderSearchCtrl.text.isNotEmpty
                    ? Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: Colors.black.withOpacity(0.15),
                          highlightColor: Colors.black.withOpacity(0.08),
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 150),
                                () {
                              order.clearOrderSearch();
                            });
                          },
                          child: SvgPicture.asset(
                            assets.removeIcon,
                            width: 18,
                            height: 18,
                            color: const Color(0xff586279),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: Colors.black.withOpacity(0.15),
                          highlightColor: Colors.black.withOpacity(0.08),
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            showModalBottomSheet(
                              useSafeArea: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              context: context,
                              builder: (context) {
                                return const OrderbookFilterBottomSheet();
                              },
                            );
                          },
                          child: SvgPicture.asset(
                            assets.filterLines,
                            width: 18,
                            height: 18,
                            color: theme.isDarkMode
                                ? colors.darkiconcolor
                                : const Color(0xff333333),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Order list view
  Widget _buildOrderList(
      List<OrderBookModel> items, OrderProvider order, ThemesProvider theme) {
    final isSearchActive = order.showSearchHold;
    final searchText = order.orderSearchCtrl.text;

    // Determine what items to display
    final itemsToDisplay = isSearchActive && searchText.isNotEmpty
        ? order.orderSearchItem
        : widget.orderBook;

    if (itemsToDisplay!.isEmpty) {
      return const Center(
        child: SizedBox(height: 500, child: NoDataFound()),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: false,
      itemBuilder: (context, index) {
        final itemIndex = index;

        // Use Builder to get fresh context for each item
        return Builder(builder: (itemContext) {
          return _OrderItem(
            ref: ref,
            key: ValueKey('${items[itemIndex].norenordno}'),
            orderItem: items[itemIndex],
            theme: theme,
            onTap: () =>
                _navigateToOrderDetails(items[itemIndex], ref, itemContext),
            onLongPress: () {
              if (order.openOrder!.isNotEmpty &&
                  (order.tabCtrl.index == 1 ||
                      !["COMPLETE", "CANCELED", "REJECTED"]
                          .contains(items[itemIndex].status))) {
                Navigator.pushNamed(itemContext, Routes.orderExit,
                    arguments: order.openOrder);
              }
            },
          );
        });
      },
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 0,
        );
      },
    );
  }

  // Navigation to order details
  void _navigateToOrderDetails(
      OrderBookModel order, WidgetRef ref, BuildContext context) async {
    try {
      // Fetch linked scrip data
      await ref
          .read(marketWatchProvider)
          .fetchLinkeScrip("${order.token}", "${order.exch}", context);

      // Fetch scrip quote data
      final quoteResponse = await ref
          .watch(marketWatchProvider)
          .fetchScripQuote("${order.token}", "${order.exch}", context);

      // Update the order with latest price data from the quote
      if (quoteResponse != null && quoteResponse.stat == "Ok") {
        final getQuotes = ref.read(marketWatchProvider).getQuotes;
        if (getQuotes != null) {
          // Update LTP if available
          if (getQuotes.lp != null &&
              getQuotes.lp != "0" &&
              getQuotes.lp != "0.00") {
            order.ltp = getQuotes.lp;
          }

          // Update close price if available
          if (getQuotes.c != null &&
              getQuotes.c != "0" &&
              getQuotes.c != "0.00") {
            order.c = getQuotes.c;
            order.close = getQuotes.c; // Set both for consistency
          }

          // Update change and percent change if available
          if (getQuotes.chng != null) {
            order.change = getQuotes.chng;
          }

          if (getQuotes.pc != null) {
            order.perChange = getQuotes.pc;
          }

          // Calculate change and perChange if they're still missing but we have LTP and close
          final ltp = double.tryParse(order.ltp ?? "0.00") ?? 0.0;
          final closePrice = double.tryParse(order.c ?? "0.00") ?? 0.0;

          if (ltp > 0 && closePrice > 0) {
            // Calculate change if missing
            if (order.change == null ||
                order.change == "null" ||
                order.change == "0") {
              order.change = (ltp - closePrice).toStringAsFixed(2);
            }

            // Calculate percent change if missing
            if (order.perChange == null ||
                order.perChange == "null" ||
                order.perChange == "0") {
              order.perChange =
                  ((ltp - closePrice) * 100 / closePrice).toStringAsFixed(2);
            }
          }
        }
      }

      // Fetch order history
      ref.read(orderProvider).fetchOrderHistory("${order.norenordno}", context);

      // Fetch tech data for equity instruments
      if ((order.exch == "NSE" || order.exch == "BSE") &&
          (order.instname.toString() != "UNDIND")) {
        await ref.read(marketWatchProvider).fetchTechData(
            context: context,
            exch: "${order.exch}",
            tradeSym: "${order.tsym}",
            lastPrc: _getValidPrice(order));
      }

      // Use the fresh context for navigation

      if (mounted) {
        showModalBottomSheet(
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          isDismissible: true,
          enableDrag: false,
          useSafeArea: true,
          context: context,
          builder: (context) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: OrderBookDetail(orderBookData: order)),
        );
      }
    } catch (e) {
      print("Error navigating to order details: $e");
    }
  }

  // Get valid price (fixing null/0 LTP issue)
  String _getValidPrice(OrderBookModel order) {
    // Helper function to check if a string is a valid numeric price
    bool isValidPrice(String? value) {
      if (value == null || value == "null" || value == "0" || value == "0.00") {
        return false;
      }
      // Check if the value is a valid numeric string
      return double.tryParse(value) != null;
    }

    // First try current LTP, then check cached LTP, then fallback to other prices
    if (isValidPrice(order.ltp)) {
      return order.ltp!;
    }
    
    // Check cached LTP if current LTP is not valid
    if (order.token != null) {
      final cachedLTP = ref.read(websocketProvider).getCachedLTP(order.token!);
      if (isValidPrice(cachedLTP)) {
        return cachedLTP!;
      }
    }
    
    // Fallback to other price fields
    if (isValidPrice(order.avgprc)) {
      return order.avgprc!;
    } else if (isValidPrice(order.prc)) {
      return order.prc!;
    } else if (isValidPrice(order.c)) {
      return order.c!;
    } else if (isValidPrice(order.close)) {
      return order.close!;
    }
    return "0.00";
  }
}

// Extracted order item widget to isolate rebuilds
class _OrderItem extends StatefulWidget {
  final OrderBookModel orderItem;
  final ThemesProvider theme;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final WidgetRef ref;
  const _OrderItem({
    required Key key,
    required this.orderItem,
    required this.theme,
    required this.onTap,
    required this.onLongPress,
    required this.ref,
  }) : super(key: key);

  @override
  State<_OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<_OrderItem> {
  // Navigation lock to prevent multiple taps
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: widget.onLongPress,
      onTap: () async {
        widget.ref.read(orderProvider).showorderHistory(false);
        // Prevent multiple navigation events on rapid taps
        if (_isNavigating) return;

        try {
          setState(() => _isNavigating = true);
          await Future.microtask(() => widget.onTap());
        } catch (e) {
          print("Navigation error: $e");
        } finally {
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() => _isNavigating = false);
              }
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Symbol + Expiry | Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SYMBOL + EXPIRY
                Expanded(
                  child: TextWidget.subText(
                    text:
                        "${widget.orderItem.symbol?.replaceAll("-EQ", "")} ${widget.orderItem.expDate} ${widget.orderItem.option ?? ''}",
                        
                    theme: widget.theme.isDarkMode,
                    fw: 0,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                    color: widget.theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                  ),
                ),

                // Status badge (pill shape)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    // border: Border.all(color: _getStatusColor()),
                    borderRadius: BorderRadius.circular(4),
                    color: _getStatusColor().withOpacity(0.1),
                  ),
                  child: TextWidget.paraText(
                    text: _getStatusText(),
                    color: _getStatusColor(),
                    theme: false,
                    fw: 0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 2: Exchange - OrderType - Time | LTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextWidget.paraText(
                    text:
                        "${widget.orderItem.exch} - ${widget.orderItem.sPrdtAli} - ${widget.orderItem.prctyp} - ${formatDateTime(value: widget.orderItem.norentm!).substring(12, 21)}",
                    theme: false,
                    color: widget.theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ),
                TextWidget.paraText(
                  text: "LTP ${_getValidPrice()}",
                  theme: false,
                  color: widget.theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 3: BUY/SELL qty | value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextWidget.paraText(
                      text: widget.orderItem.trantype == "S" ? "SELL" : "BUY",
                      theme: false,
                      color: widget.orderItem.trantype == "S"
                          ? widget.theme.isDarkMode
                              ? colors.lossDark
                              : colors.lossLight
                          : widget.theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                      fw: 0,
                    ),
                    const SizedBox(width: 8),
                    TextWidget.paraText(
                      text: _getQuantityDisplay(),
                      color: widget.theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      theme: widget.theme.isDarkMode,
                      fw: 0,
                    ),
                  ],
                ),
                TextWidget.paraText(
                  text: _getAvgPrice(),
                  color: widget.theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  theme: widget.theme.isDarkMode,
                  fw: 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get status color based on order status (matching existing logic)
  Color _getStatusColor() {
    if (widget.orderItem.status == "COMPLETE") {
      return widget.theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (widget.orderItem.status == "CANCELED" ||
        widget.orderItem.status == "REJECTED") {
      return widget.theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      // For OPEN, PENDING, TRIGGER_PENDING, etc.
      return colors.pending;
    }
  }

  // Get status text for display (using exact status values)
  String _getStatusText() {
    return '${(widget.orderItem.status?.toString().toUpperCase() ?? 'unknown')[0].toUpperCase()}${(widget.orderItem.status?.toString().toUpperCase() ?? 'unknown').substring(1)}';
  }

  // Get quantity display like "56 / 423"
  String _getQuantityDisplay() {
    final filledQty = widget.orderItem.status != "COMPLETE" &&
            (widget.orderItem.fillshares?.isNotEmpty ?? false)
        ? (int.tryParse(widget.orderItem.fillshares.toString()) ?? 0)
        : widget.orderItem.status == "COMPLETE"
            ? (int.tryParse(widget.orderItem.rqty.toString()) ?? 0)
            : (int.tryParse(widget.orderItem.dscqty.toString()) ?? 0);

    final lotSize = widget.orderItem.exch == 'MCX'
        ? (int.tryParse(widget.orderItem.ls.toString()) ?? 1)
        : 1;

    final displayFilledQty = (filledQty / lotSize).toInt();
    final displayTotalQty =
        ((int.tryParse(widget.orderItem.qty.toString()) ?? 0) / lotSize)
            .toInt();

    return "$displayFilledQty / $displayTotalQty";
  }

  // Get total value
  String _getAvgPrice() {
    try {
      final price = double.tryParse(widget.orderItem.status == "COMPLETE"
              ? widget.orderItem.avgprc ?? "0"
              : widget.orderItem.prc ?? "0") ??
          0.0;

      final qty = int.tryParse(widget.orderItem.qty.toString()) ?? 0;
      final lotSize = widget.orderItem.exch == 'MCX'
          ? (int.tryParse(widget.orderItem.ls.toString()) ?? 1)
          : 1;

      final totalValue = price;
      return totalValue.toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  // Get total value
  String _getTrgPrice() {
    return widget.orderItem.trgprc ?? "0.00";
  }

  // Get valid price for display (fixing null/0 LTP issue)
  String _getValidPrice() {
    // Helper function to check if a string is a valid numeric price
    bool isValidPrice(String? value) {
      if (value == null || value == "null" || value == "0" || value == "0.00") {
        return false;
      }
      // Check if the value is a valid numeric string
      return double.tryParse(value) != null;
    }

    // First try current LTP, then check cached LTP, then fallback to other prices
    if (isValidPrice(widget.orderItem.ltp)) {
      return widget.orderItem.ltp!;
    }
    
    // Check cached LTP if current LTP is not valid
    if (widget.orderItem.token != null) {
      final cachedLTP = widget.ref.read(websocketProvider).getCachedLTP(widget.orderItem.token!);
      if (isValidPrice(cachedLTP)) {
        return cachedLTP!;
      }
    }
    
    // Fallback to other price fields
    if (isValidPrice(widget.orderItem.avgprc)) {
      return widget.orderItem.avgprc!;
    } else if (isValidPrice(widget.orderItem.prc)) {
      return widget.orderItem.prc!;
    } else if (isValidPrice(widget.orderItem.c)) {
      return widget.orderItem.c!;
    } else if (isValidPrice(widget.orderItem.close)) {
      return widget.orderItem.close!;
    }
    return "0.00";
  }
}
