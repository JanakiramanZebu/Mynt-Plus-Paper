import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/custom_text_form_field.dart';

import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_scrip_bottom_sheet.dart';

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
  static const Duration _minUpdateInterval = Duration(milliseconds: 200);

  // Cache of items needing updates
  final Map<String, Map<String, dynamic>> _pendingUpdates = {};
  Timer? _batchUpdateTimer;

  @override
  void initState() {
    super.initState();
    _setupSocketSubscription();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _batchUpdateTimer?.cancel();
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

    for (var order in items) {
      if (order.token == null || order.token!.isEmpty) continue;

      // Skip if no socket data for this token
      if (!socketDatas.containsKey(order.token)) continue;

      final socketData = socketDatas[order.token];
      if (socketData == null || socketData.isEmpty) continue;

      // Cache current values to detect changes
      final currentLtp = order.ltp;
      final currentPerChange = order.perChange;

      // Only update LTP if it has a valid value and has changed
      final lp = socketData['lp']?.toString();
      if (lp != null &&
          lp != "null" &&
          lp != "0" &&
          lp != "0.00" &&
          lp != currentLtp) {
        order.ltp = lp;
        hasUpdates = true;
      }

      // Only update percent change if it has a valid value and has changed
      final pc = socketData['pc']?.toString();
      if (pc != null &&
          pc != "null" &&
          pc != "0" &&
          pc != "0.00" &&
          pc != currentPerChange) {
        order.perChange = pc;
        hasUpdates = true;
      }

      // Update change value too if available
      final chng = socketData['chng']?.toString();
      if (chng != null && chng != "null" && chng != order.change) {
        order.change = chng;
        hasUpdates = true;
      }
    }

    // Only trigger rebuild if actual data changed
    if (hasUpdates && mounted) {
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

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider);
    final searchorder = order.orderSearchItem;
    final theme = ref.read(themeProvider);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(children: [
        if (widget.orderBook.length > 1)
          _buildFilterSearchHeader(order, theme),
        if (order.showSearchHold) _buildSearchBar(order, theme),
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
              decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  border: Border(
                      bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          width: 6))),
              child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 2, top: 8, bottom: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Row(children: [
                      InkWell(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16))),
                                context: context,
                                builder: (context) {
                                  return const OrderbookFilterBottomSheet();
                                });
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SvgPicture.asset(assets.filterLines,
                                  color: theme.isDarkMode
                                      ? colors.darkiconcolor
                                      : const Color(0xff333333)))),
                      InkWell(
                          onTap: () {
                            order.showOrderSearch(true);
                          },
                          child: Padding(
                        padding: const EdgeInsets.only(right: 12, left: 10),
                              child: SvgPicture.asset(assets.searchIcon,
                                  width: 19, color: const Color(0xff333333))))
                    ])
            ])));
  }

  // Search bar
  Widget _buildSearchBar(OrderProvider order, ThemesProvider theme) {
    return Container(
            height: 62,
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        width: 6))),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    controller: order.orderSearchCtrl,
              style: textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    decoration: InputDecoration(
                        fillColor: const Color(0xffF1F3F8),
                        filled: true,
                        hintStyle: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xff69758F), 15, FontWeight.w500)),
                        prefixIconColor: const Color(0xff586279),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SvgPicture.asset(assets.searchIcon,
                              color: const Color(0xff586279),
                              fit: BoxFit.contain,
                              width: 20),
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            order.clearOrderSearch();
                          },
                          child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SvgPicture.asset(assets.removeIcon,
                                fit: BoxFit.scaleDown, width: 20),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20)),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Search Scrip Name",
                        contentPadding: const EdgeInsets.only(top: 20),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20))),
                    onChanged: (value) async {
                      order.orderSearch(value, context);
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      order.showOrderSearch(false);
                      order.clearOrderSearch();
                    },
                    child: Text("Close", style: textStyles.textBtn))
              ],
            ),
    );
  }

  // Order list view
  Widget _buildOrderList(List<OrderBookModel> items, OrderProvider order,
      ThemesProvider theme) {
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: false,
                              itemBuilder: (context, index) {
                                final itemIndex = index ~/ 2;
                                
                                if (index.isOdd) {
                                  return Container(
              color:
                  theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                      height: 6);
                                }
                                
        if (items[itemIndex].status == null) {
          return Container();
        }

        // Use Builder to get fresh context for each item
        return Builder(builder: (itemContext) {
          return _OrderItem(
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
      itemCount: items.length * 2 - 1,
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
      final quoteResponse = await ref.watch(marketWatchProvider)
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
      ref
          .read(orderProvider)
          .fetchOrderHistory("${order.norenordno}", context);

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
      Navigator.pushNamed(context, Routes.orderDetail, arguments: order);
    } catch (e) {
      print("Error navigating to order details: $e");
    }
  }

  // Get valid price (fixing null/0 LTP issue)
  String _getValidPrice(OrderBookModel order) {
    // First try LTP, then avgprc, then prc, then close, then default to "0.00"
    if (order.ltp != null &&
        order.ltp != "null" &&
        order.ltp != "0" &&
        order.ltp != "0.00") {
      return order.ltp!;
    } else if (order.avgprc != null &&
        order.avgprc != "null" &&
        order.avgprc != "0" &&
        order.avgprc != "0.00") {
      return order.avgprc!;
    } else if (order.prc != null &&
        order.prc != "null" &&
        order.prc != "0" &&
        order.prc != "0.00") {
      return order.prc!;
    } else if (order.c != null &&
        order.c != "null" &&
        order.c != "0" &&
        order.c != "0.00") {
      return order.c!;
    } else if (order.close != null &&
        order.close != "null" &&
        order.close != "0" &&
        order.close != "0.00") {
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

  const _OrderItem({
    required Key key,
    required this.orderItem,
    required this.theme,
    required this.onTap,
    required this.onLongPress,
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
        // Prevent multiple navigation events on rapid taps
        if (_isNavigating) return;

        try {
          setState(() {
            _isNavigating = true;
          });

          // Execute the navigation with await to catch exceptions
          await Future.microtask(() => widget.onTap());
        } catch (e) {
          print("Navigation error: $e");
        } finally {
          // Reset navigation lock after some delay
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isNavigating = false;
                });
              }
            });
          }
        }
      },
      child: Container(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                _buildHeaderRow(widget.theme),
                const SizedBox(height: 4),
                _buildExchangeRow(widget.theme),
                const SizedBox(height: 4),
                Divider(
                    color: widget.theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                const SizedBox(height: 2),
                _buildQuantityRow(widget.theme),
                const SizedBox(height: 10),
                _buildStatusRow(widget.theme),
              ])),
    );
  }

  // Header with symbol and LTP
  Widget _buildHeaderRow(ThemesProvider theme) {
    // Get the best available price to display
    final displayPrice = _getValidPrice();

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Row(children: [
        Text("${widget.orderItem.symbol} ",
            overflow: TextOverflow.ellipsis,
            style: textStyles.scripNameTxtStyle.copyWith(
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
        Text("${widget.orderItem.option} ",
            overflow: TextOverflow.ellipsis,
            style: textStyles.scripNameTxtStyle.copyWith(
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
      ]),
      // Wrap in RepaintBoundary since LTP updates frequently
      RepaintBoundary(
        child: Row(
                                                          children: [
                                                            Text(" LTP: ",
                style: textStyle(const Color(0xff5E6B7D), 13, FontWeight.w600)),
            Text("₹$displayPrice",
                                                                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
          ],
        ),
      ),
    ]);
  }

  // Exchange information row
  Widget _buildExchangeRow(ThemesProvider theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
              CustomExchBadge(exch: "${widget.orderItem.exch}"),
              Text(" ${widget.orderItem.expDate} ",
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.scripExchTxtStyle.copyWith(
                                                                        color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack)),
                                                            Container(
                  margin: const EdgeInsets.only(left: 7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                                decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                                                                    color: theme.isDarkMode
                          ? const Color(0xff666666).withOpacity(.2)
                          : const Color(0xff999999).withOpacity(.2)),
                  child: Text("${widget.orderItem.sPrdtAli}",
                                                                    style: textStyle(
                          const Color(0xff666666), 11, FontWeight.w600))),
                                                            Container(
                  margin: const EdgeInsets.only(left: 7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                                decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                                                                    color: theme.isDarkMode
                          ? const Color(0xff666666).withOpacity(.2)
                          : const Color(0xff999999).withOpacity(.2)),
                  child: Text("${widget.orderItem.prctyp}",
                                                                    style: textStyle(
                          const Color(0xff666666), 11, FontWeight.w600)))
            ],
          ),
          // Wrap percent change in RepaintBoundary as it updates frequently
          RepaintBoundary(
            child: Text(" (${widget.orderItem.perChange ?? 0.00}%)",
                style:
                    textStyle(_getPercentChangeColor(), 12, FontWeight.w500)),
          ),
        ]);
  }

  // Quantity information row
  Widget _buildQuantityRow(ThemesProvider theme) {
    // Calculate quantity display with lot size adjustment
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

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Row(children: [
                                                          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: theme.isDarkMode
                    ? widget.orderItem.trantype == "S"
                        ? colors.darkred.withOpacity(.2)
                        : colors.ltpgreen.withOpacity(.2)
                    : Color(widget.orderItem.trantype == "S"
                                                                              ? 0xffFCF3F3
                                                                              : 0xffECF8F1)),
            child: Text(widget.orderItem.trantype == "S" ? "SELL" : "BUY",
                                                                  style: textStyle(
                    widget.orderItem.trantype == "S"
                                                                          ? colors.darkred
                                                                          : colors.ltpgreen,
                                                                      12,
                                                                      FontWeight.w600))),
                                                          const SizedBox(width: 8),
        Text(formatDateTime(value: widget.orderItem.norentm!).substring(13, 21),
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500))
                                                        ]),
                                                        Row(children: [
                                                          Text("Qty: ",
            style: textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
                                                          Text(
          "$displayFilledQty/$displayTotalQty",
                                                            style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                                14,
                                                                FontWeight.w500),
                                                          )
                                                        ])
    ]);
  }

  // Status and price row
  Widget _buildStatusRow(ThemesProvider theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                        Row(children: [
        SvgPicture.asset(widget.orderItem.status == "COMPLETE"
                                                              ? assets.completedIcon
            : widget.orderItem.status == "CANCELED" ||
                    widget.orderItem.status == "REJECTED"
                ? assets.cancelledIcon
                : assets.warningIcon),
                                                          Text(
            " ${widget.orderItem.stIntrn![0].toUpperCase()}${widget.orderItem.stIntrn!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                                                              style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                                  13,
                                                                  FontWeight.w500)),
                                                        ]),
                                                        Row(children: [
                                                          Text("Prc: ",
            style: textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
        Text("${widget.orderItem.avgprc ?? widget.orderItem.prc ?? 0.00}",
                                                              style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                                  14,
                                                                  FontWeight.w500)),
        if (widget.orderItem.prctyp == "SL-LMT" ||
            widget.orderItem.prctyp == "SL-MKT") ...[
          const SizedBox(child: Text(' / ')),
                                                            Text("TP: ",
              style: textStyle(const Color(0xff5E6B7D), 14, FontWeight.w500)),
          Text("${widget.orderItem.trgprc ?? 0.00}",
                                                                style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500))
        ]
      ])
    ]);
  }

  // Get the color for percent change
  Color _getPercentChangeColor() {
    if (widget.orderItem.perChange == null) return colors.ltpgrey;
    if (widget.orderItem.perChange!.startsWith("-")) return colors.darkred;
    if (widget.orderItem.perChange == "0.00") return colors.ltpgrey;
    return colors.ltpgreen;
  }

  // Get valid price for display (fixing null/0 LTP issue)
  String _getValidPrice() {
    // First try LTP, then avgprc, then prc, then close, then default to "0.00"
    if (widget.orderItem.ltp != null &&
        widget.orderItem.ltp != "null" &&
        widget.orderItem.ltp != "0" &&
        widget.orderItem.ltp != "0.00") {
      return widget.orderItem.ltp!;
    } else if (widget.orderItem.avgprc != null &&
        widget.orderItem.avgprc != "null" &&
        widget.orderItem.avgprc != "0" &&
        widget.orderItem.avgprc != "0.00") {
      return widget.orderItem.avgprc!;
    } else if (widget.orderItem.prc != null &&
        widget.orderItem.prc != "null" &&
        widget.orderItem.prc != "0" &&
        widget.orderItem.prc != "0.00") {
      return widget.orderItem.prc!;
    } else if (widget.orderItem.c != null &&
        widget.orderItem.c != "null" &&
        widget.orderItem.c != "0" &&
        widget.orderItem.c != "0.00") {
      return widget.orderItem.c!;
    } else if (widget.orderItem.close != null &&
        widget.orderItem.close != "null" &&
        widget.orderItem.close != "0" &&
        widget.orderItem.close != "0.00") {
      return widget.orderItem.close!;
    }
    return "0.00";
  }
}
