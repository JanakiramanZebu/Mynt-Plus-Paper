import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/screens/web/order/order_confirmation_screen_web.dart';
import 'package:mynt_plus/utils/custom_navigator.dart';
import 'package:public_ip_address/public_ip_address.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/order_book_model/cancel_order_model.dart';
import '../models/order_book_model/get_brokerage.dart';
import '../models/order_book_model/gtt_order_book.dart';
import '../models/order_book_model/modify_order_model.dart';
import '../models/order_book_model/modify_sip_model.dart';
import '../models/order_book_model/order_book_model.dart';
import '../models/order_book_model/order_history_model.dart';
import '../models/order_book_model/order_margin_model.dart';
import '../models/order_book_model/place_gtt_order.dart';
import '../models/order_book_model/place_order_model.dart';
import '../models/order_book_model/sip_order_book.dart';
import '../models/order_book_model/sip_order_cancel.dart';
import '../models/order_book_model/sip_place_order.dart';
import '../models/order_book_model/trade_book_model.dart';
import '../routes/route_names.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import '../utils/responsive_snackbar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'market_watch_provider.dart';
import 'notification_provider.dart';
import 'order_input_provider.dart';
import 'websocket_provider.dart';
import 'portfolio_provider.dart';
import 'mf_provider.dart';

final orderProvider = ChangeNotifierProvider((ref) => OrderProvider(ref));

class OrderProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();

  int frezQtyOrderSliceMaxLimit = 40;

  final FToast _fToast = FToast();
  FToast get fToast => _fToast;
  final Ref ref;
  late TabController tabCtrl;
  PlaceOrderModel? _placeOrderModel;
  PlaceOrderModel? get placeOrderModel => _placeOrderModel;
  OrderMarginModel? _orderMarginModel;
  OrderMarginModel? get orderMarginModel => _orderMarginModel;
  OrderMarginModel? _bsktOrderMargin;
  OrderMarginModel? get bsktOrderMargin => _bsktOrderMargin;
  CancelOrderModel? _cancelOrderModel;
  CancelOrderModel? get cancelOrderModel => _cancelOrderModel;
  ModifyOrderModel? _modifyOrderModel;
  ModifyOrderModel? get modifyOrderModel => _modifyOrderModel;
  GetBrokerageModel? _getBrokerageModel;
  GetBrokerageModel? get getBrokerageModel => _getBrokerageModel;
  PlaceGttOrderModel? _placeGttOrderModel;
  PlaceGttOrderModel? get placeGttOrderModel => _placeGttOrderModel;
  PlaceGttOrderModel? _modifyGttOrderModel;
  PlaceGttOrderModel? get modifyGttOrderModel => _modifyGttOrderModel;
  List<OrderBookModel>? _orderBookModel = [];
  List<OrderBookModel>? get orderBookModel => _orderBookModel;
  List<OrderBookModel>? _torderBookModel = [];
  List<GttOrderBookModel>? _gttOrderBookModel = [];
  List<GttOrderBookModel>? get gttOrderBookModel => _gttOrderBookModel;
  // List<GttOrderBookModel>? _tgttOrderBookModel = [];
  List<GttOrderBookModel>? _gttOrderBookSearch = [];
  List<GttOrderBookModel>? get gttOrderBookSearch => _gttOrderBookSearch;
  final Preferences pref = locator<Preferences>();
  List<TradeBookModel>? _tradeBook = [];
  List<TradeBookModel>? get tradeBook => _tradeBook;
  List<TradeBookModel>? _ttradeBook = [];
  List<TradeBookModel>? _tradeBooksearch = [];
  List<TradeBookModel>? get tradeBooksearch => _tradeBooksearch;
  List<OrderBookModel>? _allOrder = [];
  List<OrderBookModel>? get allOrder => _allOrder;
  List<OrderBookModel>? _openOrder = [];
  List<OrderBookModel>? get openOrder => _openOrder;
  List<OrderBookModel>? _executedOrder = [];
  List<OrderBookModel>? get executedOrder => _executedOrder;

  List<OrderBookModel>? _orderSearchItem = [];
  List<OrderBookModel>? get orderSearchItem => _orderSearchItem;

  List<OrderBookModel> _orderBookSearchItem = [];
  List<OrderBookModel>? get orderBookSearchItem => _orderBookSearchItem;
  List<OrderHistoryModel> _orderHistoryModel = [];
  List<OrderHistoryModel>? get orderHistoryModel => _orderHistoryModel;

  SipPlaceOrderModel? _sipPlaceOrder;
  SipPlaceOrderModel? get sipPlaceOrder => _sipPlaceOrder;

  SipOrderBookModel? _siporderBookModel;
  SipOrderBookModel? get siporderBookModel => _siporderBookModel;

  List<SipDetails>? _siporderBookSearch = [];
  List<SipDetails>? get siporderBookSearch => _siporderBookSearch;

  CancleSipOrder? _cancleSipOrder;
  CancleSipOrder? get cancleSipOrder => _cancleSipOrder;

  ModifySIPModel? _modifySipModel;
  ModifySIPModel? get modifySipModel => _modifySipModel;

  List _bsktScripList = [];
  List get bsktScripList => _bsktScripList;

  List _bsktList = [];
  List get bsktList => _bsktList;

  Map _bsktScrips = {};
  Map get bsktScrips => _bsktScrips;

  bool _isBasketLoading = false;
  bool get isBasketLoading => _isBasketLoading;

  // Basket order tracking
  Map<String, List<String>> _basketOrderIds = {};
  Map<String, List<String>> get basketOrderIds => _basketOrderIds;
  
  Map<String, Map<String, String>> _basketOrderStatuses = {};
  Map<String, Map<String, String>> get basketOrderStatuses => _basketOrderStatuses;
  
  Map<String, String> _basketOverallStatus = {};
  Map<String, String> get basketOverallStatus => _basketOverallStatus;

  String? bsketNameError;

  final TextEditingController orderSearchCtrl = TextEditingController();
  final TextEditingController orderGttSearchCtrl = TextEditingController();
  final TextEditingController orderSipSearchCtrl = TextEditingController();
  final TextEditingController orderTradebookCtrl = TextEditingController();

  OrderProvider(this.ref);

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  List<Tab> _orderTabName = [];
  List<Tab> get orderTabName => _orderTabName;

  bool _showSearchOrder = false;
  bool get showSearchHold => _showSearchOrder;

  bool _showGttOrderSearch = false;
  bool get showGttOrderSearch => _showGttOrderSearch;

  bool _showSipOrderSearch = false;
  bool get showSipOrderSearch => _showSipOrderSearch;

  bool _showtradebookSearch = false;
  bool get showtradebookSearch => _showtradebookSearch;

  String _ip = "";
  String get ip => _ip;

  String _selectedBsktName = "";
  String get selectedBsktName => _selectedBsktName;

  bool _orderloader = false;
  bool get orderloader => _orderloader;
  int _exitOrderQty = 0;
  int get exitOrderQty => _exitOrderQty;
  bool _isExitAllOrder = false;
  bool get isExitAllOrder => _isExitAllOrder;

  bool _showOrderHistory = false;
  bool get showOrderHistory => _showOrderHistory;

  // Track currently subscribed symbols to avoid duplicate subscriptions
  Set<String> _subscribedSymbols = {};

  // Add this property to track the last sort method used
  String _lastOrderSortMethod = "TIMEDSC"; // Default sorting
  String get lastOrderSortMethod => _lastOrderSortMethod;

  clearAllorders() async {
    _torderBookModel = [];
    _ttradeBook = [];
    _orderBookModel = [];
    _gttOrderBookModel = [];
    _tradeBook = [];
    _orderSearchItem = [];
    _orderHistoryModel = [];
    _siporderBookModel = null;
    _siporderBookSearch = [];
    _gttOrderBookSearch = [];
    _tradeBooksearch = [];
    _executedOrder = [];
    _openOrder = [];
    _allOrder = [];
    _orderBookModel = [];
    _selectedTab = 0;
    // Clear basket data from preferences for current user
    // final userId = pref.clientId;
    // if (userId != null && userId.isNotEmpty) {
    //   await pref.setBasketListForUser(userId, '');
    //   await pref.setBasketScripForUser(userId, '');
    // }
    // Clear subscription tracking
    clearSubscriptions();
    notifyListeners();
  }

  showorderHistory(value) {
    _showOrderHistory = value;
    print("showOrderHistory: $_showOrderHistory");
    notifyListeners();
  }

  // Clear subscription tracking
  void clearSubscriptions() {
    _subscribedSymbols.clear();
    print("Cleared all WebSocket subscriptions tracking");
  }

  setOrderIp() async {
    _ip = await IpAddress().getIp();
  }

  setDOrderloader(bool value) {
    _orderloader = value;
  }

  setOrderloader(bool value) {
    _orderloader = value;
    notifyListeners();
  }

  selectExitOrder(int index) {
    for (var i = 0; i < (_openOrder?.length ?? 0); i++) {
      if (index == i) {
        if (_openOrder?[i] != null) {
          _openOrder![i].isExitSelection =
              !(_openOrder![i].isExitSelection ?? false);
        }
        if (_openOrder![i].isExitSelection!) {
          _exitOrderQty = _exitOrderQty + 1;
        } else {
          _exitOrderQty = _exitOrderQty - 1;
        }
      }

      if (_openOrder!.length == _exitOrderQty) {
        _isExitAllOrder = true;
      } else {
        _isExitAllOrder = false;
      }
    }

    notifyListeners();
  }

  selectExitAllOrders(bool isExitAll) {
    _isExitAllOrder = isExitAll;
    _exitOrderQty = 0;
    for (var i = 0; i < (_openOrder?.length ?? 0); i++) {
      if (_openOrder![i].qty != "0") {
        if (isExitAll) {
          _openOrder![i].isExitSelection = true;
          _exitOrderQty = _exitOrderQty + 1;
        } else {
          _openOrder![i].isExitSelection = false;
        }
      }
    }

    notifyListeners();
  }

// Change tab orderbook tab index
  Future<void> setPortfolioupdate(String mode) async {
    var result;
    if (mode == 'ob') {
      result = await api.getOrderBook();
      // result = await api.mockOrderBookResponse();
      if (result['stat'] == 'success') {
        _torderBookModel = result['data'];
      } else {
        if (result['stat'] == 'no data') {
          _orderBookModel = [];
        }
        _torderBookModel = [];
      }
    } else if (mode == 'tb') {
      result = await api.getTradeBook();
      if (result['stat'] == 'success') {
        _ttradeBook = result['data'];
      } else {
        if (result['stat'] == 'no data') {
          _tradeBook = [];
        }
        _ttradeBook = [];
      }
    } else if (mode == 'gtt') {
      result = await api.getGTTOrderBook();
      if (result['stat'] == 'success') {
        _gttOrderBookModel = result['data'];
      } else {
        if (result['stat'] == 'no data') {
          _gttOrderBookModel = [];
        }
        // _tgttOrderBookModel = [];
      }
    }
    print("qwqwqw prov alert btm $mode");
  }

  changeTabIndex(int index, BuildContext context) {
    // Skip if already on this tab (prevents unnecessary operations)
    if (_selectedTab == index) return;
    
    // Unfocus any active text fields when switching tabs
    FocusScope.of(context).unfocus();

    _selectedTab = index;
    
    // Only update tab sizes when necessary (defer to avoid blocking)
    Future.microtask(() => tabSize());
    
    // Hide search for all tabs
    showOrderSearch(false);
    showGTTOrderSearch(false);
    ref.read(marketWatchProvider).showAlertPendingSearch(false);
    showSipSearch(false);
    ref.read(marketWatchProvider).clearAlertSearch();
    
    // Clear search only if switching away from search-enabled tabs
    if (index > 3) {
      clearOrderSearch();
      clearGttOrderSearch();
      clearSipSearch();
    }
    
    // Only perform search if there's text and we're on a searchable tab
    if (orderSearchCtrl.text.isNotEmpty && index <= 3) {
      orderSearch(orderSearchCtrl.text, context);
    }
    
    // Only subscribe to WebSocket for tabs that need it (0-3)
    if (index <= 3) {
      requestWSOrderBook(isSubscribe: true, context: context);
    }

    // Only fetch basket data when switching to basket tab
    if (kIsWeb ? index == 5 : index == 4) {
      print("=== TAB SWITCH TO BASKET ===");
      print("Calling getBasketName()...");
      getBasketName();
      print("getBasketName() call initiated");
      print("============================");
    }
  }

  DateTime formatDate(String exdate) {
    List<String> parts = exdate.split(' ');

    if (parts.length == 3 && parts[1].length == 3) {
      String day = parts[0].padLeft(2, '0'); // Ensure day is two digits
      String monthAbbreviation = parts[1];
      String yearShort = parts[2];
      String year = '20$yearShort';

      String formatted = '$year-${_getMonthNumber(monthAbbreviation)}-$day';
      return DateTime.parse(formatted);
    } else {
      throw const FormatException('Invalid date format');
    }
  }

  String _getMonthNumber(String monthAbbreviation) {
    switch (monthAbbreviation.toUpperCase()) {
      case 'JAN':
        return '01';
      case 'FEB':
        return '02';
      case 'MAR':
        return '03';
      case 'APR':
        return '04';
      case 'MAY':
        return '05';
      case 'JUN':
        return '06';
      case 'JUL':
        return '07';
      case 'AUG':
        return '08';
      case 'SEP':
      case 'SEPT':
        return '09';
      case 'OCT':
        return '10';
      case 'NOV':
        return '11';
      case 'DEC':
        return '12';
      default:
        return '00';
    }
  }

// Change Basket name
  chngBsktName(String val, BuildContext context, bool isOpt) async {
    print("=== DEBUG CHANGE BASKET ===");
    print("Changing to basket: $val");
    print("isOpt: $isOpt");
    
    _selectedBsktName = val;

    // Refresh basket data from preferences to ensure latest state
    final userId = pref.clientId;
    print("UserId in change: $userId");
    
    if (userId != null && userId.isNotEmpty) {
      final userBasketScrips = pref.getBasketScripsForUser(userId) ?? "";
      print("User basket scrips in change: $userBasketScrips");
      
      _bsktScrips = userBasketScrips.isEmpty
          ? {}
          : jsonDecode(userBasketScrips);
    } else {
      final generalBasketScrips = pref.bsktScrips ?? "";
      print("General basket scrips in change: $generalBasketScrips");
      
      _bsktScrips = generalBasketScrips.isEmpty ? {} : jsonDecode(generalBasketScrips);
    }

    print("Parsed _bsktScrips in change: $_bsktScrips");
    _bsktScripList = _bsktScrips[val] ?? [];
    print("Set _bsktScripList for $val: ${_bsktScripList.length} items");
    print("==========================");

    if (_bsktScripList.isNotEmpty) {
      // Clean up expired scripts
      String input = "";
      final now = DateTime.now();
      _bsktScripList.asMap().entries.toList().reversed.forEach((entry) {
        final index = entry.key;
        final item = entry.value;
        try {
          Map spilitSymbol = spilitTsym(value: "${item['tsym']}");
          final expDateStr = spilitSymbol['expDate'];
          if (expDateStr == null || expDateStr.isEmpty) return;

          final parsedDate = formatDate(expDateStr);
          // **FIX: Only remove options that have expired (after expiry date), not on expiry date
          // Options are valid until end of expiry date, so only remove if current date is after expiry date
          final todayDate = DateTime(now.year, now.month, now.day);
          final expiryDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          if (todayDate.isAfter(expiryDate)) {
            removeBsktScrip(index, val);
          }
        } catch (e) {
          print('Error parsing expDate for ${item['tsym']}: $e');
        }
      });

      // Create input string for WebSocket subscription - only for symbols not already subscribed
      Set<String> symbolsToSubscribe = {};

      for (var script in _bsktScripList) {
        final symbolKey = "${script['exch']}|${script['token']}";
        if (!_subscribedSymbols.contains(symbolKey)) {
          symbolsToSubscribe.add(symbolKey);
          _subscribedSymbols.add(symbolKey);
        }
      }

      // Only establish new connections if needed
      if (symbolsToSubscribe.isNotEmpty) {
        input = symbolsToSubscribe.join("#");
        print("Subscribing to new basket scripts: $input");
        ref.read(websocketProvider).establishConnection(
            channelInput: input, task: "t", context: context);
      }

      // Update basket with latest values from socket data
      updateBasketFromSocketData();
    }

    await fetchBasketMargin();
    
    // Load order tracking data for the selected basket
    await _restoreOrderTrackingData();
    
    // Only update basket order status if we have order book data available
    if (_orderBookModel != null && _orderBookModel!.isNotEmpty) {
      updateBasketOrderStatus();
      // Also validate and clean up stale orders immediately after loading
      validateAllBasketOrderStatuses();
      // Save the cleaned basket data back to preferences
      await _saveBasketToPreferences(val);
    }
    
    if(!isOpt) {
      // Navigate to basket script list screen
      Navigator.pushNamed(context, Routes.bsktScripList, arguments: val);
    } 
    // Navigator.pushNamed(context, Routes.bsktScripList, arguments: val);
    notifyListeners();
  }

  // Method to update basket values from existing socket data
  void updateBasketFromSocketData() {
    try {
      final socketDatas = ref.read(websocketProvider).socketDatas;
      if (socketDatas.isEmpty || _bsktScripList.isEmpty) return;

      bool updated = false;

      // Update basket script list with current socket values
      for (var script in _bsktScripList) {
        final token = script['token']?.toString();
        if (token != null && socketDatas.containsKey(token)) {
          final lp = socketDatas[token]['lp']?.toString();
          final pc = socketDatas[token]['pc']?.toString();

          if (lp != null && lp != "null") {
            if (script['lp']?.toString() != lp) {
              script['lp'] = lp;
              updated = true;
            }
          }

          if (pc != null && pc != "null") {
            if (script['pc']?.toString() != pc) {
              script['pc'] = pc;
              updated = true;
            }
          }
        }
      }

      if (updated) {
        notifyBasketUpdates();
      }
    } catch (e) {
      print("Error updating basket from socket data: $e");
    }
  }

  // Notify listeners about basket updates without creating a full rebuild cycle
  void notifyBasketUpdates() {
    notifyListeners();
  }

  tabSize() {
    _orderTabName = [
      // Tab(text: _allOrder!.isNotEmpty ? "All (${_allOrder!.length})" : "All"),
      Tab(text: _openOrder!.isNotEmpty ? "Open ${_openOrder!.length}" : "Open"),
      Tab(
          text: _executedOrder!.isNotEmpty
              ? "Executed ${_executedOrder!.length}"
              : "Executed"),
      Tab(
        text: (_tradeBook != null && _tradeBook!.isNotEmpty)
            ? "Trade ${_tradeBook!.length}"
            : "Trade",
      ),
      Tab(
        text: (_gttOrderBookModel != null && _gttOrderBookModel!.isNotEmpty)
            ? "GTT ${_gttOrderBookModel!.length}"
            : "GTT",
      ),
      // Newly added tabs after GTT
      const Tab(text: "MF"),
      // const Tab(text: "IPO"),
      // const Tab(text: "Bonds"),
      Tab(
        text: _bsktList.isNotEmpty ? "Basket ${_bsktList.length}" : "Basket",
      ),
      // Tab(
      //   text: (_tradeBook != null && _tradeBook!.isNotEmpty)
      //       ? "Trade Book (${_tradeBook!.length})"
      //       : "Trade Book",
      // ),

      // Tab(
      //   text: (_siporderBookModel?.sipDetails?.isNotEmpty ?? false)
      //       ? "SIP ${_siporderBookModel!.sipDetails!.length}"
      //       : "SIP",
      // ),
      Tab(
        text: ref.read(marketWatchProvider).alertPendingModel != null &&
                ref.read(marketWatchProvider).alertPendingModel!.isNotEmpty
            ? "Alerts ${ref.read(marketWatchProvider).alertPendingModel!.length}"
            : "Alerts",
        // ref.read(marketWatchProvider).alertPendingModel != null &&
        //           ref.read(marketWatchProvider).alertPendingModel!.isNotEmpty)
        //       ? "Alert (${ref.read(marketWatchProvider).alertPendingModel!.length})"
        //       :
      )
    ];
    notifyListeners();
  }

  showOrderSearch(bool value) {
    _showSearchOrder = value;
    if (!_showSearchOrder) {
      _orderSearchItem = [];
    }
    notifyListeners();
  }

  showGTTOrderSearch(bool value) {
    _showGttOrderSearch = value;
    if (!_showGttOrderSearch) {
      _gttOrderBookSearch = [];
    }
    notifyListeners();
  }

  showSipSearch(bool value) {
    _showSipOrderSearch = value;
    if (!_showSipOrderSearch) {
      _siporderBookSearch = [];
    }
    notifyListeners();
  }

  showTradeSearch(bool value) {
    _showtradebookSearch = value;
    if (!_showtradebookSearch) {
      _tradeBooksearch = [];
    }
    notifyListeners();
  }

  clearGttOrderSearch() {
    orderGttSearchCtrl.clear();
    _gttOrderBookSearch = [];
    notifyListeners();
  }

  clearOrderSearch() {
    orderSearchCtrl.clear();
    _orderSearchItem = [];
    _tradeBooksearch = [];
    _gttOrderBookSearch = [];
    ref.read(marketWatchProvider).clearAlertSearch();
    ref.read(mfProvider).clearMfSearch();
    ref.read(notificationprovider).clearTriggeredAlertSearch();
    notifyListeners();
  }

  clearSipSearch() {
    orderSipSearchCtrl.clear();
    _siporderBookSearch = [];
    notifyListeners();
  }

  clearTradeBookSearch() {
    orderTradebookCtrl.clear();
    _tradeBooksearch = [];
    notifyListeners();
  }

  // A single search function to handle search for all order tabs
  searchOrders(String value, BuildContext context) {
    // Clear all previous search results
    _orderSearchItem = [];
    _tradeBooksearch = [];
    _gttOrderBookSearch = [];
    _siporderBookSearch = [];
    ref.read(marketWatchProvider).clearAlertSearch();
    ref.read(mfProvider).clearMfSearch();
    ref.read(notificationprovider).clearTriggeredAlertSearch();

    if (value.isNotEmpty) {
      switch (_selectedTab) {
        case 0: // Open Orders
          _orderSearchItem = _openOrder!
              .where((element) =>
                  element.tsym!.toUpperCase().contains(value.toUpperCase()))
              .toList();
          break;
        case 1: // Executed Orders
          _orderSearchItem = _executedOrder!
              .where((element) =>
                  element.tsym!.toUpperCase().contains(value.toUpperCase()))
              .toList();
          break;
        case 2: // Trade Book
          _tradeBooksearch = _tradeBook!
              .where((element) =>
                  element.tsym!.toUpperCase().contains(value.toUpperCase()))
              .toList();
          break;
        case 3: // GTT Orders
          _gttOrderBookSearch = _gttOrderBookModel!
              .where((element) =>
                  element.tsym!.toUpperCase().contains(value.toUpperCase()))
              .toList();
          break;
        case 4: // MF Orders (Web) / Basket (Mobile)
          // Only perform MF search on web (mobile uses case 4 for Basket which doesn't need search)
          if (kIsWeb) {
            final mf = ref.read(mfProvider);
            
            // Search MF orders - only if data exists
            if (mf.mflumpsumorderbook?.data != null && mf.mflumpsumorderbook!.data!.isNotEmpty) {
              final searchResult = mf.mflumpsumorderbook!.data!
                  .where((order) {
                    final schemeName = (order.name ?? order.schemename ?? '').toUpperCase();
                    return schemeName.contains(value.toUpperCase());
                  })
                  .toList();
              mf.setMfOrderSearch(searchResult);
            } else {
              // Clear search if no data
              mf.clearMfSearch();
            }
            
            // Search SIP orders - only if data exists
            if (mf.mfsiporderlist?.data != null && mf.mfsiporderlist!.data!.isNotEmpty) {
              final searchResult = mf.mfsiporderlist!.data!
                  .where((sip) {
                    final schemeName = (sip.name ?? '').toUpperCase();
                    final sipRegNo = (sip.sIPRegnNo ?? '').toUpperCase();
                    final searchUpper = value.toUpperCase();
                    return schemeName.contains(searchUpper) || sipRegNo.contains(searchUpper);
                  })
                  .toList();
              mf.setMfSipSearch(searchResult);
            } else {
              // Clear search if no data
              mf.setMfSipSearch([]);
            }
          }
          // Mobile case 4 is Basket - no search needed, so do nothing
          break;
        // case 5: // SIP Orders
        //   _siporderBookSearch = _siporderBookModel!.sipDetails!
        //       .where((element) =>
        //           element.sipName!.toUpperCase().contains(value.toUpperCase()))
        //       .toList();
        //   break;
        case 6: // Alerts
          final alertProvider = ref.read(marketWatchProvider);
          final notificationProvider = ref.read(notificationprovider);
          
          // Search pending alerts - only if data exists
          if (alertProvider.alertPendingModel != null && alertProvider.alertPendingModel!.isNotEmpty) {
            final searchResult = alertProvider.alertPendingModel!
                .where((element) =>
                    element.tsym!.toUpperCase().contains(value.toUpperCase()))
                .toList();
            alertProvider.setAlertPendingSearch(searchResult);
          } else {
            // Clear search if no data (mobile compatibility)
            alertProvider.setAlertPendingSearch([]);
          }
          
          // Search triggered alerts (broker messages) - only if data exists
          if (notificationProvider.brokermsg != null && notificationProvider.brokermsg!.isNotEmpty) {
            // First filter by alert-related messages (Ltp, above, below)
            final alertRelatedMessages = notificationProvider.brokermsg!
                .where((msg) =>
                    msg.dmsg != null &&
                    msg.dmsg!.contains("Ltp") &&
                    (msg.dmsg!.contains("above") || msg.dmsg!.contains("below")))
                .toList();
            
            // Then apply search filter
            final searchResult = alertRelatedMessages
                .where((msg) =>
                    msg.dmsg != null &&
                    msg.dmsg!.toUpperCase().contains(value.toUpperCase()))
                .toList();
            notificationProvider.setTriggeredAlertSearch(searchResult);
          } else {
            // Clear search if no data (mobile compatibility)
            notificationProvider.setTriggeredAlertSearch([]);
          }
          break;
      }
    }
    notifyListeners();
  }

  orderSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _showSearchOrder = true;
      _orderSearchItem = [];
      _orderSearchItem = _allOrder!
          .where((element) =>
              element.tsym!.toLowerCase().contains(value.toLowerCase()) ||
              (element.symbol?.toLowerCase().contains(value.toLowerCase()) ??
                  false))
          .toList();
      if (_orderSearchItem!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      }
    } else {
      _orderSearchItem = [];
    }

    notifyListeners();
  }

  orderGttSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _gttOrderBookSearch = [];
      _gttOrderBookSearch = _gttOrderBookModel!
          .where((element) =>
              element.tsym!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_gttOrderBookSearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      }
    } else {
      _gttOrderBookSearch = [];
    }

    notifyListeners();
  }

  orderSipSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _siporderBookSearch = [];
      _siporderBookSearch = _siporderBookModel!.sipDetails!
          .where((element) =>
              element.sipName!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_siporderBookSearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      }
    } else {
      _siporderBookSearch = [];
    }

    notifyListeners();
  }

  orderTradeBookSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _tradeBooksearch = [];
      _tradeBooksearch = _tradeBook!
          .where((element) =>
              element.tsym!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_tradeBooksearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      }
    } else {
      _tradeBooksearch = [];
    }

    notifyListeners();
  }

  Future fetchPlaceOrder(BuildContext context, PlaceOrderInput placeOrderInput,
      bool isExit, {bool quickOrder = false}) async {
    try {
      placeOrderInput.channel = defaultTargetPlatform == TargetPlatform.android
          ? '${ref.read(authProvider).deviceInfo["brand"]}'
          : "${ref.read(authProvider).deviceInfo["model"]}";

      _placeOrderModel = await api.getPlaceOrder(placeOrderInput, _ip);

      if (_placeOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        // _orderBookModel = await fetchOrderBook(context, true);
        // if (_orderBookModel!.isNotEmpty) {
        //   if (_orderBookModel![0].stat != "Not_Ok") {
        //     ConstantName.sessCheck = true;
        //     for (var element in _orderBookModel!) {
        //       if (element.norenordno == _placeOrderModel!.norenordno) {
        // ScaffoldMessenger.of(context).showSnackBar(successMessage(
        //     context, "Order placed successfully."
        //     // "Your ${element.trantype == "B" ? "buy" : "sell"} order ${element.norenordno} for ${element.tsym} in ${element.exch} is ${element.status}"
        //     ));
        // }
        //     }
        // notifyListeners();
        //   } else {
        //     if (_orderBookModel![0].emsg ==
        //             "Session Expired :  Invalid Session Key" &&
        //         _orderBookModel![0].stat == "Not_Ok") {
        //       ref.read(authProvider).ifSessionExpired(context);
        //     }
        //   }
        // }

        // if (!isExit) {
        //   Navigator.pop(context);
        // } else {

        // }

        // Don't call Navigator.pop for web overlay dialogs - they're closed via overlay entry removal
        // Only pop for mobile or non-overlay dialogs
        if (!quickOrder && !kIsWeb) {
          Navigator.pop(context);
        }
        if(kIsWeb) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.3), // Subtle dark backdrop
            builder: (BuildContext context) => OrderConfirmationScreenWeb(orderData: [_placeOrderModel!]),
          );
        }else{
        // Navigate to order confirmation screen
        Navigator.pushNamed(context, Routes.orderConfirmation, arguments: {
          'orderData': [_placeOrderModel!],
        });
        }
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        if (_placeOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        } else {
          showResponsiveSuccess(context, "${_placeOrderModel!.emsg}");
        }
      }

      return _placeOrderModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Place Order", "Error": "$e"});

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, "Error on placing order"));
      }
    } finally {
      notifyListeners();
    }
  }

  List<PlaceOrderModel> _sliceOrderResults = [];
  List<PlaceOrderModel> get sliceOrderResults => _sliceOrderResults;

  Future slicePlaceOrder(
      BuildContext context, PlaceOrderInput placeOrderInput) async {
    try {
      placeOrderInput.channel = defaultTargetPlatform == TargetPlatform.android
          ? '${ref.read(authProvider).deviceInfo["brand"]}'
          : "${ref.read(authProvider).deviceInfo["model"]}";

      _placeOrderModel = await api.getPlaceOrder(placeOrderInput, _ip);

      if (_placeOrderModel!.emsg == "Session Expired :  Invalid Session Key" &&
          _placeOrderModel!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      return _placeOrderModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Place Slice  Order", "Error": "$e"});
      notifyListeners();
    }
  }

  // New function to handle multiple slice orders and navigate to confirmation
  Future<void> slicePlaceOrderWithConfirmation(
      BuildContext context,
      List<PlaceOrderInput> placeOrderInputs,
      int quantity,
      int reminder) async {
    try {
      _sliceOrderResults.clear();
      List<Future<PlaceOrderModel?>> orderFutures = [];

      // Create futures for all slice orders
      final iterations = quantity >= frezQtyOrderSliceMaxLimit ? frezQtyOrderSliceMaxLimit : quantity;

      for (var i = 0; i < iterations; i++) {
        orderFutures.add(_placeSliceOrderInternal(placeOrderInputs[0]));
      }

      // Add reminder order future if needed
      if (reminder != 0 && placeOrderInputs.length > 1) {
        orderFutures.add(_placeSliceOrderInternal(placeOrderInputs[1]));
      }

      // Wait for all orders to complete
      final results = await Future.wait(orderFutures);

      // Process results
      bool hasSessionExpired = false;
      for (final result in results) {
        if (result != null) {
          if (result.emsg == "Session Expired :  Invalid Session Key") {
            hasSessionExpired = true;
            break;
          }
          if (result.stat == "Ok") {
            _sliceOrderResults.add(result);
          }
        }
      }
      // Handle session expiry
      if (hasSessionExpired) {
        ref.read(authProvider).ifSessionExpired(context);
      }

      // Show results
      if (_sliceOrderResults.isNotEmpty) {
        // Update order book
        fetchOrderBook(context, true);

        Navigator.pop(context);
        Navigator.pop(context);

        // Navigate to order confirmation screen with all sliced orders
        if (context.mounted) {
         if(kIsWeb) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.3), // Subtle dark backdrop
            builder: (BuildContext context) => OrderConfirmationScreenWeb(orderData: _sliceOrderResults),
          );
        }else{
        // Navigate to order confirmation screen
        Navigator.pushNamed(context, Routes.orderConfirmation, arguments: {
          'orderData': _sliceOrderResults,
        });
        }
        }
      } else {
        // Show error if no orders were successful
        if (context.mounted) {
          showResponsiveWarningMessage(context, "Failed to place orders. Please try again.");
        }
      }
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Slice Order Confirmation", "Error": "$e"});
      if (context.mounted) {
        showResponsiveWarningMessage(context, "Error placing orders: ${e.toString()}");
      }
      // notifyListeners();
    } finally {
      notifyListeners();
    }
  }

  // Helper function for placing individual slice orders
  Future<PlaceOrderModel?> _placeSliceOrderInternal(
      PlaceOrderInput placeOrderInput) async {
    try {
      placeOrderInput.channel = defaultTargetPlatform == TargetPlatform.android
          ? '${ref.read(authProvider).deviceInfo["brand"]}'
          : "${ref.read(authProvider).deviceInfo["model"]}";

      final result = await api.getPlaceOrder(placeOrderInput, _ip);
      return result;
    } catch (e) {
      print("Error placing slice order: $e");
      return null;
    }
  }

  Future fetchOrderBook(context, bool websocCon) async {
    try {
      await setPortfolioupdate('ob');
      if (_orderBookModel!.isNotEmpty) {
        if (_torderBookModel!.isNotEmpty) {
          _orderBookModel = _torderBookModel;
        }
      } else {
        toggleLoadingOn(true);
        _executedOrder = [];
        _openOrder = [];
        _allOrder = [];
        _orderBookModel = _torderBookModel;
      }

      pref.setOBScrip(true);
      pref.setOBPrice(true);
      pref.setOBtime(true);
      pref.setOBqty(true);
      pref.setOBproduct(true);

      if (_orderBookModel!.isNotEmpty) {
        if (_orderBookModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;
          _executedOrder = [];
          _openOrder = [];
          _allOrder = [];
          for (var element in _orderBookModel!) {
            if (element.exch == "BFO" && element.dname != null) {
              List<String> splitVal = element.dname!.split(" ");

              element.symbol = splitVal[0];
              element.expDate = "${splitVal[1]} ${splitVal[2]}";
              element.option = splitVal.length > 4
                  ? "${splitVal[3]} ${splitVal[4]}"
                  : splitVal[3];
            } else {
              Map spilitSymbol = spilitTsym(value: "${element.tsym}");

              element.symbol = "${spilitSymbol["symbol"]}";
              element.expDate = "${spilitSymbol["expDate"]}";
              element.option = "${spilitSymbol["option"]}";
            }
            if (element.stat == "Ok") {
              debugPrint("Order ${element.norenordno}: Status=${element.status}, Stat=${element.stat}");
              if (element.status == "REJECTED" ||
                  element.status == "CANCELED" ||
                  element.status == "COMPLETE" ||
                  element.status == "INVALID_STATUS_TYPE") {
                _executedOrder!.add(element);
                debugPrint("  -> Added to _executedOrder (Status: ${element.status})");
              } else {
                _openOrder!.add(element);
                debugPrint("  -> Added to _openOrder (Status: ${element.status})");
              }
              _allOrder!.add(element);
            } else {
              debugPrint("Order ${element.norenordno}: Stat=${element.stat}, Error=${element.emsg}");
              debugPrint("  -> NOT added to any list (stat != Ok)");
            }
          }

          // Reapply the last sort method if one was used
          if (_lastOrderSortMethod.isNotEmpty) {
            filterOrders(sorting: _lastOrderSortMethod);
          }

          notifyListeners();

          if (websocCon) {
            requestWSOrderBook(isSubscribe: true, context: context);
          }
          tabSize();
        } else {
          if (_orderBookModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _orderBookModel![0].stat == "Not_Ok") {
            ref.read(authProvider).ifSessionExpired(context);
          }
        }
      }
      return _orderBookModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Order Book", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {
      //

      // Update basket order statuses after fetching order book
      updateBasketOrderStatus();
      
      // Validate and clean up stale basket order statuses
      validateAllBasketOrderStatuses();

      toggleLoadingOn(false);
    }
  }

  Future fetchTradeBook(context) async {
    try {
      await setPortfolioupdate('tb');
      if (_tradeBook!.isNotEmpty) {
        if (_ttradeBook!.isNotEmpty) {
          _tradeBook = _ttradeBook;
        }
      } else {
        _tradeBook = _ttradeBook;
      }
      pref.setTbScrip(true);
      pref.setTbPrice(true);
      pref.setTbBuyOrSell(true);
      pref.setTbTime(true);
      if (_tradeBook!.isNotEmpty) {
        if (_tradeBook![0].stat == "Ok") {
          ConstantName.sessCheck = true;
          for (var element in _tradeBook!) {
            if (element.exch == "BFO" && element.dname != null) {
              List<String> splitVal = element.dname!.split(" ");

              element.symbol = splitVal[0];
              element.expDate = "${splitVal[1]} ${splitVal[2]}";
              element.option = splitVal.length > 4
                  ? "${splitVal[3]} ${splitVal[4]}"
                  : splitVal[3];
            } else {
              Map spilitSymbol = spilitTsym(value: "${element.tsym}");

              element.symbol = "${spilitSymbol["symbol"]}";
              element.expDate = "${spilitSymbol["expDate"]}";
              element.option = "${spilitSymbol["option"]}";
            }
          }
        }
        if (_tradeBook![0].emsg == "Session Expired :  Invalid Session Key" &&
            _tradeBook![0].stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
        if (_tradeBook![0].stat == "Not_Ok") {
          _tradeBook = [];
        }
      }
      tabSize();
      notifyListeners();

      return _tradeBook;
    } catch (e) {
      print("Trade book $e");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Trade Book", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchGTTOrderBook(context, String initLoad) async {
    try {
      await setPortfolioupdate('gtt');
      // if (_gttOrderBookModel!.isNotEmpty) {
      //   if (_tgttOrderBookModel!.isNotEmpty) {
      //     _gttOrderBookModel = _tgttOrderBookModel;
      //   }
      // } else {
      //   _gttOrderBookModel = _tgttOrderBookModel;
      // }
      if (_gttOrderBookModel!.isNotEmpty) {
        if (_gttOrderBookModel![0].stat == "Ok") {
          ConstantName.sessCheck = true;
          if (initLoad != "initLoad") {
            _selectedTab = 3;
            requestWSOrderBook(isSubscribe: true, context: context);
          }

          for (var element in _gttOrderBookModel!) {
            Map spilitSymbol = spilitTsym(value: "${element.tsym}");

            element.symbol = "${spilitSymbol["symbol"]}";
            element.expDate = "${spilitSymbol["expDate"]}";
            element.option = "${spilitSymbol["option"]}";

            element.ordDate = convertToISOFormat("${element.norentm}");
          }
          _gttOrderBookModel!.sort((a, b) => b.ordDate!.compareTo(a.ordDate!));
        }
        if (_gttOrderBookModel![0].emsg ==
                "Session Expired :  Invalid Session Key" &&
            _gttOrderBookModel![0].stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }

        if (_gttOrderBookModel![0].stat == "Not_Ok") {
          _gttOrderBookModel = [];
        }
      }
      tabSize();

      return _gttOrderBookModel;
    } catch (e) {
      print("GTT Order book $e");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API GTT Order Book", "Error": "$e"});
    } finally {
      notifyListeners();
    }
  }

  Future fetchOrderHistory(String orderNum, BuildContext context) async {
    try {
      _orderHistoryModel = await api.getOrderHistory(orderNum);
      print("${_orderHistoryModel[0].stat}");
      if (_orderHistoryModel[0].stat == "Not_Ok" &&
          _orderHistoryModel[0].emsg ==
              "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      notifyListeners();

      return _orderHistoryModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Single Order His", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  orderBookSearch(String Value) {
    if (Value.length > 1) {
      _orderBookSearchItem = [];
      Fluttertoast.cancel();
      _orderBookSearchItem = _executedOrder!
          .where((element) => element.tsym!.toLowerCase().contains(Value))
          .toList();
      if (_orderBookSearchItem.isEmpty) {
        Fluttertoast.showToast(
            msg: "No Data Found",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print("searchList");
      }
    } else {
      _orderBookSearchItem = [];
    }
    notifyListeners();
  }

  exitOrders(context) async {
    for (var element in _openOrder!) {
      if (element.isExitSelection ?? false) {
        if ((element.sPrdtAli == "BO" || element.sPrdtAli == "CO") &&
            element.snonum != null) {
          await fetchExitSNOOrd(element.snonum.toString(),
              element.prd.toString(), context, false);
        } else {
          await fetchOrderCancel(element.norenordno.toString(), context, false);
        }
      }
    }
    await fetchOrderBook(context, true);
    Navigator.pop(context);
    _exitOrderQty = 0;
    _isExitAllOrder = false;
  }

  Future fetchOrderCancel(String orderNum, context, bool loop) async {
    try {
      _cancelOrderModel = await api.getCancelOrder(orderNum);
      if (_cancelOrderModel!.stat == "Ok") {
        if (loop) {
          ConstantName.sessCheck = true;
          await fetchOrderBook(context, true);
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(successMessage(context, 'Order Cancelled'));

          Navigator.pop(context);
        }
      } else {
        ref.read(authProvider).ifSessionExpired(context);
      }

      return _cancelOrderModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Order Canl", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchExitSNOOrd(
      String snoOrdNum, String prd, context, bool loop) async {
    try {
      _cancelOrderModel = await api.getExitSNOOrder(snoOrdNum, prd);
      if (_cancelOrderModel!.stat == "Ok" &&
          _cancelOrderModel!.dmsg == "success") {
        if (loop) {
          ConstantName.sessCheck = true;
          await fetchOrderBook(context, true);
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(successMessage(context, 'Order Exited'));
          Navigator.pop(context);
        }
      } else {
        ref.read(authProvider).ifSessionExpired(context);
      }

      return _cancelOrderModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Order Canl", "Error": "$e"});
      notifyListeners();
    }
  }

  Future fetchModifyOrder(ModifyOrderInput input, context) async {
    try {
      _modifyOrderModel = await api.getModifyOrder(input, _ip);
      if (_modifyOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        await fetchOrderBook(context, true);
        PlaceOrderModel modifyOrderData = PlaceOrderModel(
          norenordno:
              _modifyOrderModel!.result, // Order number from modify result
          requestTime: _modifyOrderModel!.requestTime,
          stat: _modifyOrderModel!.stat,
        );
        modifyOrderData.emsg = _modifyOrderModel!.emsg;

        // ScaffoldMessenger.of(context)
        //     .showSnackBar(successMessage(context, 'Order Modified'));
        // Navigator.pop(context);

        if(kIsWeb) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.3), // Subtle dark backdrop
            builder: (BuildContext context) => OrderConfirmationScreenWeb(orderData: [modifyOrderData]),
          );
        }else{
        Navigator.pushNamed(context, Routes.orderConfirmation, arguments: {
          'orderData': [modifyOrderData],
        });
        }
      } else {
        if (_modifyOrderModel!.emsg ==
            "Session Expired :  Invalid Session Key") {
          ref.read(authProvider).ifSessionExpired(context);
        } else {
          showResponsiveSuccess(context, '${_modifyOrderModel!.emsg}');
        }
      }
      notifyListeners();
      return _modifyOrderModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Modify Order", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {}
  }

  Future fetchOrderMargin(OrderMarginInput input, BuildContext context) async {
    try {
      _orderMarginModel = await api.getOrderMargin(input);
      if (_orderMarginModel!.emsg == "Session Expired :  Invalid Session Key" &&
          _orderMarginModel!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      notifyListeners();
      return _orderMarginModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Order Margin", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {}
  }

  Future fetchGetBrokerage(BrokerageInput input, BuildContext context) async {
    try {
      _getBrokerageModel = await api.getBrokerage(input);
      if (_getBrokerageModel!.emsg ==
              "Session Expired :  Invalid Session Key" &&
          _getBrokerageModel!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      notifyListeners();
      return _getBrokerageModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Brokerage", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {}
  }

  requestWSOrderBook(
      {required bool isSubscribe, required BuildContext context}) {
    try {
      toggleLoadingOn(true);
      String input = "";
      
      // Only include open orders if Open Orders tab (index 0) or Executed Orders tab (index 1) is active
      if (_orderBookModel != null && (_selectedTab == 0 || _selectedTab == 1)) {
        if (_orderBookModel!.isNotEmpty &&
            _orderBookModel![0].stat != "Not_Ok") {
          input = _orderBookModel!
              .map((e) => "${e.exch}|${e.token}")
              .toSet()
              .join("#");
          print("Regular orders input: $input (Active tab: $_selectedTab)");
        }
      }
      
      // Only include executed orders if Executed Orders tab (index 1) is active
      if (_executedOrder != null && _selectedTab == 1 && _executedOrder!.isNotEmpty) {
        final executedTokens = _executedOrder!
            .where((e) => e.token != null && e.token!.isNotEmpty)
            .map((e) => "${e.exch}|${e.token}")
            .toSet()
            .join("#");
        if (executedTokens.isNotEmpty) {
          if (input.isNotEmpty) {
            input += "#$executedTokens";
          } else {
            input = executedTokens;
          }
          print("Executed orders input: $executedTokens");
        }
      }
      
      // Only include trade book if Trade Book tab (index 2) is active
      if (_tradeBook != null && _selectedTab == 2 && _tradeBook!.isNotEmpty) {
        final tradeTokens = _tradeBook!
            .where((e) => e.token != null && e.token!.isNotEmpty)
            .map((e) => "${e.exch}|${e.token}")
            .toSet()
            .join("#");
        if (tradeTokens.isNotEmpty) {
          if (input.isNotEmpty) {
            input += "#$tradeTokens";
          } else {
            input = tradeTokens;
          }
          print("Trade book input: $tradeTokens");
        }
      }

      // Only include GTT orders if GTT tab (index 3) is active
      if (_gttOrderBookModel!.isNotEmpty && _selectedTab == 3) {
        // Debug: Print GTT order tokens before subscription
        print("=== GTT ORDER SOCKET SUBSCRIPTION ===");
        print("GTT Orders count: ${_gttOrderBookModel!.length}");
        print("Subscribe mode: ${isSubscribe ? 'SUBSCRIBE' : 'UNSUBSCRIBE'}");
        print("Active tab: $_selectedTab (GTT tab is active)");

        final gttTokens = _gttOrderBookModel!
            .map((e) => "${e.exch}|${e.token}")
            .toSet()
            .join("#");

        // Debug: Print first 3 GTT order details
        for (int i = 0; i < _gttOrderBookModel!.length && i < 3; i++) {
          final gtt = _gttOrderBookModel![i];
          print(
              "  GTT $i: ${gtt.tsym} (${gtt.exch}|${gtt.token}) - Current LTP: ${gtt.ltp ?? 'null'}");
        }

        if (input.isNotEmpty) {
          input += "#$gttTokens";
        } else {
          input = gttTokens;
        }

        print("Total subscription input length: ${input.length}");
        print(
            "First 100 chars: ${input.substring(0, input.length > 100 ? 100 : input.length)}");
        print("=====================================");
      } else if (_gttOrderBookModel!.isNotEmpty && _selectedTab != 3) {
        print("GTT orders available but not subscribing (Active tab: $_selectedTab, GTT tab: 3)");
      }

      if (input.isNotEmpty) {
        ref.read(websocketProvider).establishConnection(
            channelInput: input,
            task: isSubscribe ? "t" : "u",
            context: context);
      } else {
        print("🚨 No input to subscribe to in requestWSOrderBook");
      }
    } catch (e) {
      print("❌ Error in requestWSOrderBook: $e");
    } finally {
      toggleLoadingOn(false);
    }
  }

  filterTradeBook(String sorting) {
    if (sorting == "ASC") {
      _tradeBook!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
    } else if (sorting == "DSC") {
      _tradeBook!.sort((a, b) => b.tsym!.compareTo(a.tsym!));
    } else if (sorting == "LTPDSC") {
      _tradeBook!.sort((a, b) {
        return double.parse(b.prc ?? "0.00")
            .compareTo(double.parse(a.prc ?? "0.00"));
      });
    } else if (sorting == "LTPASC") {
      _tradeBook!.sort((a, b) {
        return double.parse(a.prc ?? "0.00")
            .compareTo(double.parse(b.prc ?? "0.00"));
      });
    } else if (sorting == "BUY") {
      _tradeBook!.sort((a, b) => a.trantype!.compareTo(b.trantype!));
    } else if (sorting == "SELL") {
      _tradeBook!.sort((a, b) => b.trantype!.compareTo(a.trantype!));
    } else if (sorting == "TIMEHIGH") {
      _tradeBook!.sort((a, b) {
        DateTime dateA = DateTime.parse(formatToDateTime("${a.norentm}"));
        DateTime dateB = DateTime.parse(formatToDateTime("${b.norentm}"));
        return dateA.compareTo(dateB);
      });
    } else if (sorting == "TIMELOW") {
      _tradeBook!.sort((a, b) {
        DateTime dateA = DateTime.parse(formatToDateTime("${a.norentm}"));
        DateTime dateB = DateTime.parse(formatToDateTime("${b.norentm}"));
        return dateB.compareTo(dateA);
      });
    }
    notifyListeners();
  }

  filterGttOrders(String sorting) {
    if (sorting == "ASC") {
      _gttOrderBookModel!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
    } else if (sorting == "DSC") {
      _gttOrderBookModel!.sort((a, b) => b.tsym!.compareTo(a.tsym!));
    } else if (sorting == "LTPDSC") {
      _gttOrderBookModel!.sort((a, b) {
        return double.parse(b.ltp ?? "0.00")
            .compareTo(double.parse(a.ltp ?? "0.00"));
      });
    } else if (sorting == "LTPASC") {
      _gttOrderBookModel!.sort((a, b) {
        return double.parse(a.ltp ?? "0.00")
            .compareTo(double.parse(b.ltp ?? "0.00"));
      });
    } else if (sorting == "QTYDSC") {
      _gttOrderBookModel!.sort((a, b) {
        return int.parse("${b.qty ?? "0"}")
            .compareTo(int.parse("${a.qty ?? "0"}"));
      });
    } else if (sorting == "QTYASC") {
      _gttOrderBookModel!.sort((a, b) {
        return int.parse("${a.qty ?? "0"}")
            .compareTo(int.parse("${b.qty ?? "0"}"));
      });
    } else if (sorting == "PRODUCTASC") {
      _gttOrderBookModel!.sort((a, b) => a.prd!.compareTo(b.prd!));
    } else if (sorting == "PRODUCTDSC") {
      _gttOrderBookModel!.sort((a, b) => b.prd!.compareTo(a.prd!));
    } else if (sorting == "TIMEDSC") {
      _gttOrderBookModel!.sort((a, b) {
        DateTime dateA = DateTime.parse(formatToDateTime("${a.norentm}"));
        DateTime dateB = DateTime.parse(formatToDateTime("${b.norentm}"));
        return dateB.compareTo(dateA);
      });
    } else if (sorting == "TIMEASC") {
      _gttOrderBookModel!.sort((a, b) {
        DateTime dateA = DateTime.parse(formatToDateTime("${a.norentm}"));
        DateTime dateB = DateTime.parse(formatToDateTime("${b.norentm}"));
        return dateA.compareTo(dateB);
      });
    }
    notifyListeners();
  }

  void filterOrders({required String sorting}) {
    // Save the last sort method
    _lastOrderSortMethod = sorting;

    // Determine which lists to sort (both main lists and search results)
    List<OrderBookModel>? mainListToSort;
    List<OrderBookModel>? searchListToSort;

    if (_selectedTab == 0) {
      mainListToSort = _openOrder;
      searchListToSort = _orderSearchItem;
    } else if (_selectedTab == 1) {
      mainListToSort = _executedOrder;
      searchListToSort = _orderSearchItem;
    } else if (_selectedTab == 2) {
      // Trade book - handle separately since it's a different model type
      _sortTradeBook(sorting);
      return;
    } else if (_selectedTab == 3) {
      // GTT orders - handle separately since it's a different model type
      _sortGttOrders(sorting);
      return;
    } else {
      mainListToSort = _allOrder;
      searchListToSort = _orderSearchItem;
    }

    // Sort main list if it exists
    if (mainListToSort != null && mainListToSort.isNotEmpty) {
      _applySortingToOrderList(mainListToSort, sorting);
    }

    // Sort search results if they exist
    if (searchListToSort != null && searchListToSort.isNotEmpty) {
      _applySortingToOrderList(searchListToSort, sorting);
    }

    notifyListeners();
  }

  void _applySortingToOrderList(
      List<OrderBookModel> listToSort, String sorting) {
    // Sorting logic based on the 'sorting' parameter
    switch (sorting) {
      case "ASC":
        listToSort.sort((a, b) => a.tsym!.compareTo(b.tsym!));
        break;
      case "DSC":
        listToSort.sort((a, b) => b.tsym!.compareTo(a.tsym!));
        break;
      case "LTPASC":
        listToSort.sort((a, b) {
          final aLtp = double.tryParse(a.ltp ?? '0.0') ?? 0.0;
          final bLtp = double.tryParse(b.ltp ?? '0.0') ?? 0.0;
          return aLtp.compareTo(bLtp);
        });
        break;
      case "LTPDSC":
        listToSort.sort((a, b) {
          final aLtp = double.tryParse(a.ltp ?? '0.0') ?? 0.0;
          final bLtp = double.tryParse(b.ltp ?? '0.0') ?? 0.0;
          return bLtp.compareTo(aLtp);
        });
        break;
      case "PRODUCTASC":
        listToSort.sort((a, b) => a.sPrdtAli!.compareTo(b.sPrdtAli!));
        break;
      case "PRODUCTDSC":
        listToSort.sort((a, b) => b.sPrdtAli!.compareTo(a.sPrdtAli!));
        break;
      case "QTYASC":
        listToSort.sort((a, b) {
          final aQty = int.tryParse(a.qty ?? '0') ?? 0;
          final bQty = int.tryParse(b.qty ?? '0') ?? 0;
          return aQty.compareTo(bQty);
        });
        break;
      case "QTYDSC":
        listToSort.sort((a, b) {
          final aQty = int.tryParse(a.qty ?? '0') ?? 0;
          final bQty = int.tryParse(b.qty ?? '0') ?? 0;
          return bQty.compareTo(aQty);
        });
        break;
      case "TIMEASC":
        listToSort.sort((a, b) {
          final aDate = DateTime.tryParse(formatToDateTime(a.norentm ?? '')) ??
              DateTime(1970);
          final bDate = DateTime.tryParse(formatToDateTime(b.norentm ?? '')) ??
              DateTime(1970);
          return aDate.compareTo(bDate);
        });
        break;
      case "TIMEDSC":
        listToSort.sort((a, b) {
          final aDate = DateTime.tryParse(formatToDateTime(a.norentm ?? '')) ??
              DateTime(1970);
          final bDate = DateTime.tryParse(formatToDateTime(b.norentm ?? '')) ??
              DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;
      default:
        // No sorting
        break;
    }
  }

  void _sortTradeBook(String sorting) {
    // Sort main trade book list
    if (_tradeBook != null && _tradeBook!.isNotEmpty) {
      _applySortingToTradeBookList(_tradeBook!, sorting);
    }

    // Sort trade book search results
    if (_tradeBooksearch != null && _tradeBooksearch!.isNotEmpty) {
      _applySortingToTradeBookList(_tradeBooksearch!, sorting);
    }
  }

  void _applySortingToTradeBookList(List<dynamic> listToSort, String sorting) {
    // Sorting logic for trade book
    switch (sorting) {
      case "ASC":
        listToSort.sort((a, b) => a.tsym!.compareTo(b.tsym!));
        break;
      case "DSC":
        listToSort.sort((a, b) => b.tsym!.compareTo(a.tsym!));
        break;
      case "LTPASC":
        listToSort.sort((a, b) {
          final aPrice = double.tryParse(a.avgprc ?? '0.0') ?? 0.0;
          final bPrice = double.tryParse(b.avgprc ?? '0.0') ?? 0.0;
          return aPrice.compareTo(bPrice);
        });
        break;
      case "LTPDSC":
        listToSort.sort((a, b) {
          final aPrice = double.tryParse(a.avgprc ?? '0.0') ?? 0.0;
          final bPrice = double.tryParse(b.avgprc ?? '0.0') ?? 0.0;
          return bPrice.compareTo(aPrice);
        });
        break;
      case "PRODUCTASC":
        listToSort.sort((a, b) => a.sPrdtAli!.compareTo(b.sPrdtAli!));
        break;
      case "PRODUCTDSC":
        listToSort.sort((a, b) => b.sPrdtAli!.compareTo(a.sPrdtAli!));
        break;
      case "QTYASC":
        listToSort.sort((a, b) {
          final aQty = int.tryParse(a.flqty ?? '0') ?? 0;
          final bQty = int.tryParse(b.flqty ?? '0') ?? 0;
          return aQty.compareTo(bQty);
        });
        break;
      case "QTYDSC":
        listToSort.sort((a, b) {
          final aQty = int.tryParse(a.flqty ?? '0') ?? 0;
          final bQty = int.tryParse(b.flqty ?? '0') ?? 0;
          return bQty.compareTo(aQty);
        });
        break;
      case "TIMEASC":
        listToSort.sort((a, b) {
          final aDate = DateTime.tryParse(formatToDateTime(a.norentm ?? '')) ??
              DateTime(1970);
          final bDate = DateTime.tryParse(formatToDateTime(b.norentm ?? '')) ??
              DateTime(1970);
          return aDate.compareTo(bDate);
        });
        break;
      case "TIMEDSC":
        listToSort.sort((a, b) {
          final aDate = DateTime.tryParse(formatToDateTime(a.norentm ?? '')) ??
              DateTime(1970);
          final bDate = DateTime.tryParse(formatToDateTime(b.norentm ?? '')) ??
              DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;
      default:
        // No sorting
        break;
    }
  }

  void _sortGttOrders(String sorting) {
    // Sort main GTT orders list
    if (_gttOrderBookModel != null && _gttOrderBookModel!.isNotEmpty) {
      _applySortingToGttOrdersList(_gttOrderBookModel!, sorting);
    }

    // Sort GTT orders search results
    if (_gttOrderBookSearch != null && _gttOrderBookSearch!.isNotEmpty) {
      _applySortingToGttOrdersList(_gttOrderBookSearch!, sorting);
    }
  }

  void _applySortingToGttOrdersList(List<dynamic> listToSort, String sorting) {
    // Sorting logic for GTT orders
    switch (sorting) {
      case "ASC":
        listToSort.sort((a, b) => a.tsym!.compareTo(b.tsym!));
        break;
      case "DSC":
        listToSort.sort((a, b) => b.tsym!.compareTo(a.tsym!));
        break;
      case "LTPASC":
        listToSort.sort((a, b) {
          final aPrice = double.tryParse(a.d ?? '0.0') ?? 0.0;
          final bPrice = double.tryParse(b.d ?? '0.0') ?? 0.0;
          return aPrice.compareTo(bPrice);
        });
        break;
      case "LTPDSC":
        listToSort.sort((a, b) {
          final aPrice = double.tryParse(a.d ?? '0.0') ?? 0.0;
          final bPrice = double.tryParse(b.d ?? '0.0') ?? 0.0;
          return bPrice.compareTo(aPrice);
        });
        break;
      case "PRODUCTASC":
        listToSort.sort((a, b) => a.sPrdtAli!.compareTo(b.sPrdtAli!));
        break;
      case "PRODUCTDSC":
        listToSort.sort((a, b) => b.sPrdtAli!.compareTo(a.sPrdtAli!));
        break;
      case "QTYASC":
        listToSort.sort((a, b) {
          final aQty = int.tryParse(a.qty ?? '0') ?? 0;
          final bQty = int.tryParse(b.qty ?? '0') ?? 0;
          return aQty.compareTo(bQty);
        });
        break;
      case "QTYDSC":
        listToSort.sort((a, b) {
          final aQty = int.tryParse(a.qty ?? '0') ?? 0;
          final bQty = int.tryParse(b.qty ?? '0') ?? 0;
          return bQty.compareTo(aQty);
        });
        break;
      case "TIMEASC":
        listToSort.sort((a, b) {
          final aDate = DateTime.tryParse(formatToDateTime(a.norentm ?? '')) ??
              DateTime(1970);
          final bDate = DateTime.tryParse(formatToDateTime(b.norentm ?? '')) ??
              DateTime(1970);
          return aDate.compareTo(bDate);
        });
        break;
      case "TIMEDSC":
        listToSort.sort((a, b) {
          final aDate = DateTime.tryParse(formatToDateTime(a.norentm ?? '')) ??
              DateTime(1970);
          final bDate = DateTime.tryParse(formatToDateTime(b.norentm ?? '')) ??
              DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;
      default:
        // No sorting
        break;
    }
  }

  placeGTTOrder(PlaceGTTOrderInput input, BuildContext context) async {
    try {
      _placeGttOrderModel = await api.placeGTTOrderAPI(input);

      if (_placeGttOrderModel!.stat == "OI created") {
        ConstantName.sessCheck = true;
        ref.read(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        // Show success message - ResponsiveSnackBar for web, ScaffoldMessenger for mobile
        if (kIsWeb) {
          ResponsiveSnackBar.showSuccess(context, "Order Placed Successfully");
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(successMessage(context, "Order Placed Successfully"));
        }

        if (kIsWeb) {
          // On web, skip Navigator.pop and bottomMenu navigation
          // The draggable dialog will handle closing itself
        } else {
          Navigator.pop(context);
          ref.read(indexListProvider).bottomMenu(2, context);
          // Switch to Orders tab in Portfolio screen
          ref.read(portfolioProvider).changeTabIndex(2);
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.click);
        }
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API GTT Order ", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  modifyGTTOrder(PlaceGTTOrderInput input, BuildContext context) async {
    try {
      _modifyGttOrderModel = await api.modifyGTTOrderAPI(input);

      if (_modifyGttOrderModel!.stat == "OI replaced") {
        ConstantName.sessCheck = true;
        ref.read(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        // Show success message - ResponsiveSnackBar for web, ScaffoldMessenger for mobile
        if (kIsWeb) {
          ResponsiveSnackBar.showSuccess(context, "Modified Order");
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(successMessage(context, "Modified Order"));
        }

        if (kIsWeb) {
          // On web, skip Navigator.pop and bottomMenu navigation
          // The draggable dialog will handle closing itself
        } else {
          Navigator.pop(context);
          ref.read(indexListProvider).bottomMenu(2, context);
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.click);
        }
      } else {
        if (_modifyGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _modifyGttOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Modify GTT Order ", "Error": "$e"});
      notifyListeners();
    }
  }

  cancelGttOrder(String canId, BuildContext context) async {
    toggleLoadingOn(true);
    try {
      _placeGttOrderModel = await api.cancelGTTOrderAPI(canId);

      if (_placeGttOrderModel!.stat == "OI deleted") {
        ConstantName.sessCheck = true;

        // Show success message - ResponsiveSnackBar for web, ScaffoldMessenger for mobile
        if (kIsWeb) {
          ResponsiveSnackBar.showSuccess(context, "GTT Order Cancelled Successfully");
        } else {
          showResponsiveSuccess(context, "GTT Order Cancelled Successfully");
          Navigator.pop(context);
        }
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      if (_placeGttOrderModel!.stat == "Invalid Oi") {
        await fetchGTTOrderBook(context, "");
        // Show warning message - ResponsiveSnackBar for web, ScaffoldMessenger for mobile
        if (kIsWeb) {
          ResponsiveSnackBar.showWarning(context, "Provided GTT Order is not found");
        } else {
          showResponsiveWarningMessage(context, "Provided GTT Order is not found");
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API GTT Order  CANCEL", "Error": "$e"});
    } finally {
      await fetchGTTOrderBook(context, "");
      toggleLoadingOn(false);
      notifyListeners();
    }
  }

  placeOCOOrder(PlaceOcoOrderInput input, BuildContext context) async {
    try {
      _placeGttOrderModel = await api.placeOCOOrderAPI(input);

      if (_placeGttOrderModel!.stat == "OI created") {
        ConstantName.sessCheck = true;
        ref.read(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        // Show success message - ResponsiveSnackBar for web, ScaffoldMessenger for mobile
        if (kIsWeb) {
          ResponsiveSnackBar.showSuccess(context, "Order Placed Successfully");
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(successMessage(context, "Order Placed Successfully"));
        }

        if (kIsWeb) {
          // On web, skip Navigator.pop and bottomMenu navigation
          // The draggable dialog will handle closing itself
        } else {
          Navigator.pop(context);
          ref.read(indexListProvider).bottomMenu(2, context);
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.click);
        }
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API OCO Order ", "Error": "$e"});
    } finally {
      notifyListeners();
    }
  }

  modifyOCOOrder(PlaceOcoOrderInput input, BuildContext context) async {
    try {
      _modifyGttOrderModel = await api.modifyOCOOrderAPI(input);

      if (_modifyGttOrderModel!.stat == "OI replaced") {
        ConstantName.sessCheck = true;
        ref.read(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        // Show success message - ResponsiveSnackBar for web, ScaffoldMessenger for mobile
        if (kIsWeb) {
          ResponsiveSnackBar.showSuccess(context, "Modified Order");
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(successMessage(context, "Modified Order"));
        }

        if (kIsWeb) {
          // On web, skip Navigator.pop and bottomMenu navigation
          // The draggable dialog will handle closing itself
        } else {
          Navigator.pop(context);
          ref.read(indexListProvider).bottomMenu(2, context);
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.click);
        }
      } else {
        if (_modifyGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _modifyGttOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Modify OCO Order ", "Error": "$e"});
      notifyListeners();
    }
  }

  createBasketOrder(String val, BuildContext context) async {
    String curDate = convDateWithTime();
    getBasketName();
    
    // Check for duplicate basket names (case-insensitive)
    final trimmedName = val.trim();
    final lowerCaseName = trimmedName.toLowerCase();
    
    for (var basket in _bsktList) {
      if (basket['bsketName'].toString().toLowerCase() == lowerCaseName) {
        // Show error if duplicate found
        showResponsiveErrorMessage(context, "Basket name '$trimmedName' already exists");
        return; // Exit without creating duplicate
      }
    }
    
    _bsktList.add({
      "bsketName": trimmedName,
      "createdDate": curDate,
      "max": frezQtyOrderSliceMaxLimit.toString(),
      "curLength": '0'
    });
    final userId = pref.clientId;
    if (userId != null && userId.isNotEmpty) {
      await pref.setBasketListForUser(userId, jsonEncode(_bsktList));
    } else {
      await pref.setBasketList(jsonEncode(_bsktList));
    }
    getBasketName();
    
    // Auto-select the newly created basket
    await chngBsktName(val, context, true);
    
    tabSize();
    Navigator.pop(context);
    notifyListeners();
  }

  getBasketName() async {
    _isBasketLoading = true;
    notifyListeners();
    
    final userId = pref.clientId;
    
    print("=== DEBUG BASKET LOADING ===");
    print("UserId: $userId");
    print("bsktScrips : ${pref.bsktScrips}");
    
    // Check both storages to find where the data actually exists
    final generalBasketScrips = pref.bsktScrips ?? "";
    final userBasketScrips = (userId != null && userId.isNotEmpty) 
        ? (pref.getBasketScripsForUser(userId) ?? "") 
        : "";
    
    print("General bsktScrips: $generalBasketScrips");
    print("User bsktScrips: $userBasketScrips");
    
    // Use the storage that has data, prioritizing user-specific if both have data
    bool useUserStorage = false;
    
    if (userId != null && userId.isNotEmpty) {
      // Check if user-specific storage has been initialized (exists and is not just "{}")
      bool userStorageInitialized = userBasketScrips.isNotEmpty && userBasketScrips != "{}";
      
      if (userStorageInitialized) {
        useUserStorage = true;
        print("Using user-specific storage (already initialized)");
      } else if (generalBasketScrips.isNotEmpty && generalBasketScrips != "{}" && generalBasketScrips.length > 10) {
        // Only migrate if user storage has never been initialized
        final userBasketList = pref.getBasketListForUser(userId) ?? "";
        bool userListInitialized = userBasketList.isNotEmpty && userBasketList != "[]";
        
        if (!userListInitialized) {
          // First time migration - user storage is completely uninitialized
          print("First-time migration from general to user-specific storage");
          await pref.setBasketScripForUser(userId, generalBasketScrips);
          
          final generalBasketList = pref.bsktList ?? "";
          if (generalBasketList.isNotEmpty) {
            await pref.setBasketListForUser(userId, generalBasketList);
          }
          
          // Clear general storage after successful migration
          print("Clearing general storage after migration");
          await pref.setBasketScrip("{}");
          await pref.setBasketList("[]");
          
          useUserStorage = true;
        } else {
          // User storage exists but is empty - user has cleared their baskets
          print("User storage exists but empty - not migrating");
          useUserStorage = true;
        }
      } else {
        print("Both storages are empty or have minimal data");
        useUserStorage = true; // Default to user storage for new users
      }
    }
    
    if (useUserStorage && userId != null && userId.isNotEmpty) {
      // User-specific storage
      final userBasketList = pref.getBasketListForUser(userId) ?? "";
      final finalUserBasketScrips = pref.getBasketScripsForUser(userId) ?? "";
      
      print("Using User Basket List: $userBasketList");
      print("Using User Basket Scrips: $finalUserBasketScrips");
      
      _bsktList = userBasketList.isEmpty
          ? []
          : jsonDecode(userBasketList);
      _bsktScrips = finalUserBasketScrips.isEmpty
          ? {}
          : jsonDecode(finalUserBasketScrips);
    } else {
      // General storage
      final generalBasketList = pref.bsktList ?? "";
      
      print("Using General Basket List: $generalBasketList");
      print("Using General Basket Scrips: $generalBasketScrips");
      
      _bsktList = generalBasketList.isEmpty ? [] : jsonDecode(generalBasketList);
      _bsktScrips = generalBasketScrips.isEmpty ? {} : jsonDecode(generalBasketScrips);
    }
    
    print("Parsed _bsktList: $_bsktList");
    print("Parsed _bsktScrips: $_bsktScrips");
    print("Selected basket: $_selectedBsktName");

    if (_bsktList.isNotEmpty) {
      for (var element in _bsktList) {
        String basketName = element['bsketName'];
        List scipList = _bsktScrips[basketName] ?? [];
        element['curLength'] = "${scipList.length}";
        
        print("Basket: $basketName, Scripts count: ${scipList.length}");
        
        if (_selectedBsktName == basketName) {
          _bsktScripList = List.from(scipList);
          print("Set _bsktScripList for $basketName: ${_bsktScripList.length} items");
        }
      }
    }

    print("Final _bsktScripList: ${_bsktScripList.length} items");
    print("============================");
    
    _isBasketLoading = false;
    
    // Restore order tracking data after loading baskets
    await _restoreOrderTrackingData();
    
    print("=== AFTER BASKET LOAD ===");
    print("_bsktList.length: ${_bsktList.length}");
    print("_bsktList.isEmpty: ${_bsktList.isEmpty}");
    print("Order tracking restored for baskets: ${_basketOverallStatus.keys}");
    print("Calling notifyListeners()...");
    log("basket scrips$_bsktScrips");
    notifyListeners();
    print("notifyListeners() completed");
    print("========================");
  }

  // removeBasket(int index) async {

  //   _bsktList.removeAt(index);
  //   final userId = pref.clientId;
  //   if (userId != null && userId.isNotEmpty) {
  //     await pref.setBasketListForUser(userId, jsonEncode(_bsktList));
  //     _bsktList = pref.getBasketListForUser(userId)!.isEmpty
  //         ? []
  //         : jsonDecode(pref.getBasketListForUser(userId)!);
  //   } else {
  //     await pref.setBasketList(jsonEncode(_bsktList));
  //     _bsktList = pref.bsktList!.isEmpty ? [] : jsonDecode(pref.bsktList!);
  //   }
  //   tabSize();
  //   notifyListeners();
  // }

  Future<void> removeBasket(int index) async {
  // 1. Grab the basket name BEFORE you remove it
  final String removedBasketName = _bsktList[index]['bsketName'];

  // 2. Remove from list
  _bsktList.removeAt(index);

  // 3. Persist the updated basket list
  final userId = pref.clientId;
  if (userId != null && userId.isNotEmpty) {
    await pref.setBasketListForUser(userId, jsonEncode(_bsktList));
  } else {
    await pref.setBasketList(jsonEncode(_bsktList));
  }

  // 4. ALSO remove the scripts for that basket
  //    Get the current scripts map
  Map<String, dynamic> allScripts;
  if (userId != null && userId.isNotEmpty) {
    final raw = pref.getBasketScripsForUser(userId) ?? "{}";
    allScripts = raw.isEmpty ? {} : jsonDecode(raw);
    // Remove the key
    allScripts.remove(removedBasketName);
    // Persist back
    await pref.setBasketScripForUser(userId, jsonEncode(allScripts));
  } else {
    final raw = pref.bsktScrips ?? "{}";
    allScripts = raw.isEmpty ? {} : jsonDecode(raw);
    allScripts.remove(removedBasketName);
    await pref.setBasketScrip(jsonEncode(allScripts));
  }

  // 5. Update your in-memory map
  _bsktScrips = allScripts;
  // 5. **Reset all order‑tracking for that basket**
  resetBasketOrderTracking(removedBasketName);
  // 6. Refresh any dependent state (recomputing curLength etc.)
  tabSize();
  notifyListeners();
}

  removeBsktScrip(int index, String bsktName) async {
    try {
      print("=== DEBUG REMOVE BASKET SCRIP ===");
      print("Removing index: $index from basket: $bsktName");
      print("Current _bsktScripList length: ${_bsktScripList.length}");
      
      Map<String, dynamic> data = {};
      final userId = pref.clientId;
      print("UserId in remove: $userId");
      // 1️⃣ Capture the removed item
    final removedItem = _bsktScripList[index];
    final List<String> removedOrderIds =
        List<String>.from(removedItem['orderIds'] ?? <String>[]);
      
      // Get current basket scrips data
      if (userId != null && userId.isNotEmpty) {
        final userBasketScrips = pref.getBasketScripsForUser(userId) ?? "";
        print("User basket scrips before remove: $userBasketScrips");
        data = userBasketScrips.isEmpty ? {} : jsonDecode(userBasketScrips);
      } else {
        final generalBasketScrips = pref.bsktScrips ?? "";
        print("General basket scrips before remove: $generalBasketScrips");
        data = generalBasketScrips.isEmpty ? {} : jsonDecode(generalBasketScrips);
      }
      
      print("Parsed data before remove: $data");
      
      // Remove from local list
      if (index >= 0 && index < _bsktScripList.length) {
        final removedItem = _bsktScripList.removeAt(index);
        print("Removed item: $removedItem");
        print("_bsktScripList after removal: ${_bsktScripList.length} items");
      } else {
        print("Invalid index: $index");
      }
      
      // Update the basket data with the modified list
      data[bsktName] = List.from(_bsktScripList);
      print("Updated data for basket $bsktName: ${data[bsktName]?.length} items");
      
      // Also update the local _bsktScrips to keep it in sync
      _bsktScrips = Map.from(data);
      
      // Save to preferences
      String jsonData = jsonEncode(data);
      print("Saving JSON data: $jsonData");
      
      if (userId != null && userId.isNotEmpty) {
        await pref.setBasketScripForUser(userId, jsonData);
        print("Saved to user-specific storage");
        
        // Clear general storage to prevent conflicts after user makes changes
        if (pref.bsktScrips != null && pref.bsktScrips!.isNotEmpty) {
          print("Clearing general storage to prevent conflicts");
          await pref.setBasketScrip("{}");
        }
      } else {
        await pref.setBasketScrip(jsonData);
        print("Saved to general storage");
      }

      // 4️⃣ Only remove individual script orders if there actually were any
    if (removedOrderIds.isNotEmpty) {
      // Create a unique key for this script (token + index is more reliable than just token)
      String scriptKey = "${removedItem['token']}_$index";
      // Remove only this script's order tracking, not the entire basket
      removeScriptOrderTracking(bsktName, scriptKey, removedOrderIds);
    }
      
      print("================================");
      
      // Refresh all basket data
      await getBasketName();
      notifyListeners();
    } catch (e) {
      print("Error removing basket scrip: $e");
      // Still refresh basket data in case of error
      await getBasketName();
      notifyListeners();
    }
  }

  addToBasket(String basketName, Map<String, dynamic> basketItem, {BuildContext? context}) async {
    try {
      print("=== DEBUG ADD TO BASKET ===");
      print("Adding to basket: $basketName");
      print("Item: $basketItem");
      
      Map<String, dynamic> data = {};
      final userId = pref.clientId;
      
      // Get existing basket scrips data
      if (userId != null && userId.isNotEmpty) {
        final userBasketScrips = pref.getBasketScripsForUser(userId) ?? "";
        print("User basket scrips: $userBasketScrips");
        data = userBasketScrips.isEmpty ? {} : jsonDecode(userBasketScrips);
      } else {
        final generalBasketScrips = pref.bsktScrips ?? "";
        print("General basket scrips: $generalBasketScrips");
        data = generalBasketScrips.isEmpty ? {} : jsonDecode(generalBasketScrips);
      }
      
      // Get current scripts in the basket
      List currentScripts = data[basketName] ?? [];
      print("Current scripts count: ${currentScripts.length}");
      
      // Check basket limit (frezQtyOrderSliceMaxLimit items max)
      if (currentScripts.length >= frezQtyOrderSliceMaxLimit) {
        if (context != null) {
          showResponsiveErrorMessage(context, "Basket limit reached. Cannot add more than $frezQtyOrderSliceMaxLimit items to a basket.");
        }
        return false; // Return false to indicate failure
      }
      
      // Calculate splits needed for the new item
      final currentQty = int.parse(basketItem['qty'].toString());
      final currentFrzQty = basketItem['frzqty'] != null ? int.parse(basketItem['frzqty'].toString()) : null;
      
      List<Map<String, dynamic>> itemsToAdd = [];
      
      if (currentFrzQty != null && currentQty > currentFrzQty) {
        // Calculate number of full splits and remainder
        final fullSplits = currentQty ~/ currentFrzQty; // Integer division
        final remainder = currentQty % currentFrzQty;
        
        // Add full splits
        for (int i = 0; i < fullSplits; i++) {
          Map<String, dynamic> splitItem = Map.from(basketItem);
          splitItem['qty'] = currentFrzQty.toString();
          itemsToAdd.add(splitItem);
        }
        
        // Add remainder if exists
        if (remainder > 0) {
          Map<String, dynamic> remainderItem = Map.from(basketItem);
          remainderItem['qty'] = remainder.toString();
          itemsToAdd.add(remainderItem);
        }
      } else {
        // No split needed
        itemsToAdd.add(basketItem);
      }
      
      // Check if total orders in basket would exceed limit
      int currentBasketOrders = currentScripts.length;
      int newOrders = itemsToAdd.length;
      
      if (currentBasketOrders + newOrders > frezQtyOrderSliceMaxLimit) {
        if (context != null) {
          showResponsiveErrorMessage(context, "Cannot add to basket. Total orders would be ${currentBasketOrders + newOrders}, which exceeds the maximum limit of $frezQtyOrderSliceMaxLimit orders.");
        }
        return false; // Return false to indicate failure
      }
      
      // Add all split items to the basket
      currentScripts.addAll(itemsToAdd);
      print("After adding: ${currentScripts.length}");
      
      // Update the data
      data[basketName] = currentScripts;
      _bsktScrips = Map.from(data);
      
      // Save back to preferences
      String jsonData = jsonEncode(data);
      print("Saving add JSON: $jsonData");
      
      if (userId != null && userId.isNotEmpty) {
        await pref.setBasketScripForUser(userId, jsonData);
        print("Saved to user-specific storage");
        
        // Clear general storage to prevent conflicts
        if (pref.bsktScrips != null && pref.bsktScrips!.isNotEmpty) {
          print("Clearing general storage to prevent conflicts");
          await pref.setBasketScrip("{}");
        }
      } else {
        await pref.setBasketScrip(jsonData);
        print("Saved to general storage");
      }
      
      print("===========================");
      
      // Refresh basket data
      await getBasketName();
      notifyListeners();
      return true; // Return true to indicate success
    } catch (e) {
      print("Error adding to basket: $e");
      await getBasketName();
      notifyListeners();
      return false; // Return false to indicate failure
    }
  }

  fetchBasketMargin() async {
    try {
      List basket = [];
      if (_bsktScripList.isNotEmpty) {
        // Include ALL scripts in margin calculation (including executed ones)
        for (var i = 1; i < _bsktScripList.length; i++) {
          basket.add({
            "exch": '${_bsktScripList[i]["exch"]}',
            "tsym": '${_bsktScripList[i]["tsym"]}'.contains("&")
                ? '${_bsktScripList[i]["tsym"]}'.replaceAll("&", "%26")
                : '${_bsktScripList[i]["tsym"]}',
            "qty": '${_bsktScripList[i]["qty"]}',
            "prc": '${_bsktScripList[i]["prc"]}',
            "prd": '${_bsktScripList[i]["prd"]}',
            "trantype": '${_bsktScripList[i]["trantype"]}',
            "prctyp": '${_bsktScripList[i]["prctyp"]}',
            "trgprc": _bsktScripList[i]["trgprc"]?.toString() ?? '',
            "blprc": _bsktScripList[i]["blprc"]?.toString() ?? '',
            "bpprc": _bsktScripList[i]["bpprc"]?.toString() ?? ''
          });
        }

        // Use first script as main input with available order parameters
        OrderMarginInput inputs = OrderMarginInput(
            exch: '${_bsktScripList[0]["exch"]}',
            prc: '${_bsktScripList[0]["prc"]}',
            prctyp: '${_bsktScripList[0]["prctyp"]}',
            prd: '${_bsktScripList[0]["prd"]}',
            qty: '${_bsktScripList[0]["qty"]}',
            trantype: '${_bsktScripList[0]["trantype"]}',
            tsym: '${_bsktScripList[0]["tsym"]}',
            trgprc: _bsktScripList[0]["trgprc"]?.toString() ?? '',
            rorgprc: '', // Not available in basket data
            rorgqty: '', // Not available in basket data
            blprc: _bsktScripList[0]["blprc"]?.toString() ?? '', 
            bpprc: _bsktScripList[0]["bpprc"]?.toString() ?? '');
        _bsktOrderMargin = await api.getBasketMargin(inputs, basket);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  fetchSipPlaceOrder(BuildContext context, SipInputField sipOrderInput) async {
    try {
      toggleLoadingOn(true);
      _sipPlaceOrder = await api.getPlaceSipOrder(sipOrderInput);
      if (_sipPlaceOrder!.reqStatus == "OK") {
        changeTabIndex(5, context);
        ref.read(indexListProvider).bottomMenu(2, context);
        // Switch to Orders tab in Portfolio screen
        ref.read(portfolioProvider).changeTabIndex(2);
        fetchSipOrderHistory(context);
        tabSize();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "Order is Placed Sucessfully"));
        notifyListeners();
      } else if (_sipPlaceOrder!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
    } catch (e) {
      ref.read(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  fetchModifySipOrder(
      BuildContext context, ModifySipInput modifysipinput) async {
    try {
      toggleLoadingOn(true);
      _modifySipModel = await api.getmodifysiporder(modifysipinput);
      if (_modifySipModel!.reqStatus == "OK") {
        Navigator.pop(context);
        Navigator.pop(context);
        fetchSipOrderHistory(context);
        showResponsiveSuccess(context, "Order is Modified Sucessfully");
      }
      if (_modifySipModel!.reqStatus == "NOT_OK") {
        showResponsiveSuccess(context, "${_modifySipModel!.rejreason}");
      } else if (_modifySipModel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _modifySipModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "MODIFYSIP API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  filterSipOrder(String sorting) {
    if (sorting == "ASC") {
      _siporderBookModel!.sipDetails!
          .sort((a, b) => a.sipName!.compareTo(b.sipName!));
    } else if (sorting == "DSC") {
      _siporderBookModel!.sipDetails!
          .sort((a, b) => b.sipName!.compareTo(a.sipName!));
    } else if (sorting == "LTPASC") {
      _siporderBookModel!.sipDetails!.sort((a, b) {
        return double.parse(a.scrips![0].ltp ?? "0.00")
            .compareTo(double.parse(b.scrips![0].ltp ?? "0.00"));
      });
    } else if (sorting == "LTPDSC") {
      _siporderBookModel!.sipDetails!.sort((a, b) {
        return double.parse(b.scrips![0].ltp ?? "0.00")
            .compareTo(double.parse(a.scrips![0].ltp ?? "0.00"));
      });
    } else if (sorting == "PRECHANGASC") {
      _siporderBookModel!.sipDetails!.sort((a, b) {
        return double.parse(a.scrips![0].perChange ?? "0.00")
            .compareTo(double.parse(b.scrips![0].perChange ?? "0.00"));
      });
    } else if (sorting == "PRECHANGDSC") {
      _siporderBookModel!.sipDetails!.sort((a, b) {
        return double.parse(b.scrips![0].perChange ?? "0.00")
            .compareTo(double.parse(a.scrips![0].perChange ?? "0.00"));
      });
    } else if (sorting == "DATEASC") {
      _siporderBookModel!.sipDetails!.sort((a, b) {
        String dateA = duedateformate(value: "${a.internal!.dueDate}");
        String dateB = duedateformate(value: "${b.internal!.dueDate}");
        return dateA.compareTo(dateB);
      });
    } else if (sorting == "DATEDSC") {
      _siporderBookModel!.sipDetails!.sort((a, b) {
        String dateA = duedateformate(value: "${a.internal!.dueDate}");
        String dateB = duedateformate(value: "${b.internal!.dueDate}");
        return dateB.compareTo(dateA);
      });
    }
    notifyListeners();
  }

  Future fetchSipOrderHistory(BuildContext context) async {
    try {
      _siporderBookModel = await api.getSipOrderBook();
      tabSize();
      List ltpArgs = [];
      if (_siporderBookModel != null) {
        if (_siporderBookModel!.sipDetails != null) {
          ConstantName.sessCheck = true;
          for (var main = 0;
              main < _siporderBookModel!.sipDetails!.length;
              main++) {
            for (var i = 0;
                i < _siporderBookModel!.sipDetails![main].scrips!.length;
                i++) {
              ltpArgs.add({
                "exch":
                    "${_siporderBookModel!.sipDetails![main].scrips![i].exch}",
                "token":
                    "${_siporderBookModel!.sipDetails![main].scrips![i].token}"
              });
            }
          }
          final response = await api.getLTP(ltpArgs);
          Map res = jsonDecode(response.body);

          for (var main = 0;
              main < _siporderBookModel!.sipDetails!.length;
              main++) {
            for (var i = 0;
                i < _siporderBookModel!.sipDetails![main].scrips!.length;
                i++) {
              if (_siporderBookModel!.sipDetails![main].scrips![i].token
                      .toString() ==
                  "${res["data"]["${_siporderBookModel!.sipDetails![main].scrips![i].token}"]['token']}") {
                _siporderBookModel!.sipDetails![main].scrips![i].ltp =
                    "${res["data"]["${_siporderBookModel!.sipDetails![main].scrips![i].token}"]["lp"]}";
                _siporderBookModel!.sipDetails![main].scrips![i].close =
                    "${res["data"]["${_siporderBookModel!.sipDetails![main].scrips![i].token}"]["close"]}";

                _siporderBookModel!.sipDetails![main].scrips![i].perChange =
                    "${res["data"]["${_siporderBookModel!.sipDetails![main].scrips![i].token}"]["change"]}";
                _siporderBookModel!
                    .sipDetails![main].scrips![i].change = (double.parse(
                            "${_siporderBookModel!.sipDetails![main].scrips![i].ltp == "0" ? _siporderBookModel!.sipDetails![main].scrips![i].close : _siporderBookModel!.sipDetails![main].scrips![i].ltp}") -
                        double.parse(
                            "${_siporderBookModel!.sipDetails![main].scrips![i].close}"))
                    .toStringAsFixed(2);
              }
            }
          }
        } else {
          if (_siporderBookModel!.emsg ==
              "Session Expired :  Invalid Session Key") {
            ref.read(authProvider).ifSessionExpired(context);
          }
        }
      }
      notifyListeners();
      return _siporderBookModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "SIP ORDER HISTORY API", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchSipOrderCancel(String sipOrderno, context) async {
    try {
      _cancleSipOrder = await api.getSipCancelOrder(sipOrderno);
      await fetchSipOrderHistory(context);
      if (_cancleSipOrder!.reqStatus == "OK") {
        tabSize();
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Order Sucessfully Cancled"));
      } else if (cancleSipOrder!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _cancleSipOrder;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "SIP CANCEL API", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  placeBasketOrder(BuildContext context, {bool navigateToOrderBook = true}) async {
    try {
      debugPrint("=== BASKET PLACE ORDER START ===");
      // Initialize basket tracking for current basket
      String basketName = _selectedBsktName;
      debugPrint("Basket Name: $basketName");
      debugPrint("Total items in basket: ${_bsktScripList.length}");
      
      _basketOrderIds[basketName] = [];
      _basketOrderStatuses[basketName] = {};
      _basketOverallStatus[basketName] = 'placing';
      
      notifyListeners();
      
      List<String> successfulOrders = [];
      List<String> failedOrders = [];
      
      for (int index = 0; index < _bsktScripList.length; index++) {
        var element = _bsktScripList[index];
        String itemKey = "${element['tsym']}_${element['token']}_$index";
        
        debugPrint("\n--- Processing Basket Item $index ---");
        debugPrint("Item Key: $itemKey");
        debugPrint("TSYM: ${element['tsym']}");
        debugPrint("Exchange: ${element['exch']}");
        debugPrint("Token: ${element['token']}");
        debugPrint("Quantity: ${element['qty']}");
        debugPrint("Price: ${element['prc']}");
        debugPrint("Price Type: ${element['prctype']}");
        debugPrint("Product: ${element['prd']}");
        debugPrint("Transaction Type: ${element['trantype']}");
        debugPrint("Market Protection: ${element['mktProt']}");
        debugPrint("LTP: ${element['lp']}");
        debugPrint("Ret (Validity): ${element['ret']}");
        
        // Set channel - use empty string like mobile, or set to WEB for web platform
        String channelValue = '';
        if (kIsWeb) {
          channelValue = 'WEB';
        } else {
          channelValue = defaultTargetPlatform == TargetPlatform.android
              ? '${ref.read(authProvider).deviceInfo["brand"]}'
              : "${ref.read(authProvider).deviceInfo["model"]}";
        }
        debugPrint("Channel: $channelValue");
        
        // Set default validity (ret) if not provided - same logic as mobile/web place order screens
        String retValue = element['ret']?.toString().trim() ?? '';
        if (retValue.isEmpty) {
          // Default validity based on exchange: EOS for BSE/BFO, DAY for others
          String exchange = element['exch']?.toString() ?? '';
          if (exchange == "BSE" || exchange == "BFO") {
            retValue = "EOS";
          } else {
            retValue = "DAY";
          }
          debugPrint("Ret was empty, setting default: $retValue (Exchange: $exchange)");
        } else {
          debugPrint("Using provided ret value: $retValue");
        }
        
        // Convert prd to correct code format (same as mobile)
        // API expects: "C" (Delivery/CNC), "I" (Intraday/MIS), "F" (MTF), "B" (Bracket), "H" (Cover), "M" (Carry Forward/NRML)
        String prdValue = element['prd']?.toString().trim() ?? '';
        String ordTypeValue = element['ordType']?.toString().trim() ?? '';
        String prdCode = prdValue;
        
        // If prd is stored as name, convert to code
        if (prdValue.isNotEmpty) {
          // Check if it's already a code (single character)
          if (prdValue.length == 1 && ['C', 'I', 'F', 'B', 'H', 'M'].contains(prdValue.toUpperCase())) {
            prdCode = prdValue.toUpperCase();
          } else {
            // Convert name to code
            // For "CO - BO", check ordType to determine if it's Cover (H) or Bracket (B)
            if (prdValue == 'CO - BO' || prdValue == 'CO-BO') {
              if (ordTypeValue == 'CO') {
                prdCode = 'H'; // Cover Order
              } else if (ordTypeValue == 'BO') {
                prdCode = 'B'; // Bracket Order
              } else {
                // Default to Bracket if ordType is not available
                prdCode = 'B';
                debugPrint("CO - BO order without ordType, defaulting to Bracket (B)");
              }
            } else {
              Map<String, String> nameToCode = {
                'Delivery': 'C',
                'Intraday': 'I',
                'MTF': 'F',
                'MIS': 'I',
                'CNC': 'C',
                'NRML': 'M',
                'CO': 'H',
                'BO': 'B',
              };
              prdCode = nameToCode[prdValue] ?? 'C'; // Default to 'C' if not found
            }
            debugPrint("Converted prd from '$prdValue' to '$prdCode' (ordType: $ordTypeValue)");
          }
          
          // Final validation: For NSE/BSE equity orders, "M" (Carry Forward) is not valid
          // Convert "M" to "C" (Delivery) for equity orders to prevent rejection
          String exchange = element['exch']?.toString().trim() ?? '';
          String tsym = element['tsym']?.toString().trim() ?? '';
          bool isEquity = (exchange == "NSE" || exchange == "BSE") && 
                         (tsym.endsWith("-EQ") || tsym.contains("EQ"));
          
          if (prdCode == 'M' && isEquity) {
            prdCode = 'C'; // Convert Carry Forward to Delivery for equity orders
            debugPrint("Final validation: Converted prd from 'M' (Carry Forward) to 'C' (Delivery) for NSE/BSE equity order to prevent rejection");
          }
        } else {
          // Default to 'C' (Delivery) if prd is empty
          prdCode = 'C';
          debugPrint("prd was empty, setting default: 'C'");
        }
        debugPrint("Final prd code: $prdCode");
        
        PlaceOrderInput placeOrderInput = PlaceOrderInput(
            amo: element['amo'],
            blprc: element['blprc'],
            bpprc: element['bpprc'],
            dscqty: element['dscqty'],
            exch: element['exch'],
            prc: element['mktProt'].toString().isNotEmpty
                ? element['lp']
                : element['prc'],
            prctype: element['prctype'],
            prd: prdCode, // Use converted code
            qty: element['qty'],
            ret: retValue,
            trailprc: '',
            trantype: element['trantype'],
            trgprc: element['trgprc'],
            tsym: element['tsym'],
            mktProt: element['mktProt'],
            channel: channelValue);

        // Print the PlaceOrderInput payload that will be sent to API
        debugPrint("\n=== BASKET ORDER PAYLOAD ===");
        debugPrint("Exchange: ${placeOrderInput.exch}");
        debugPrint("TSYM: ${placeOrderInput.tsym}");
        debugPrint("Quantity: ${placeOrderInput.qty}");
        debugPrint("Price: ${placeOrderInput.prc}");
        debugPrint("Product (prd): ${placeOrderInput.prd}");
        debugPrint("Transaction Type: ${placeOrderInput.trantype}");
        debugPrint("Price Type (prctyp): ${placeOrderInput.prctype}");
        debugPrint("Validity (ret): ${placeOrderInput.ret}");
        debugPrint("Channel: ${placeOrderInput.channel}");
        debugPrint("AMO: ${placeOrderInput.amo}");
        debugPrint("Stop Loss (blprc): ${placeOrderInput.blprc}");
        debugPrint("Target (bpprc): ${placeOrderInput.bpprc}");
        debugPrint("Disclosed Qty (dscqty): ${placeOrderInput.dscqty}");
        debugPrint("Trigger Price (trgprc): ${placeOrderInput.trgprc}");
        debugPrint("Trailing Price (trailprc): ${placeOrderInput.trailprc}");
        debugPrint("Market Protection (mktProt): ${placeOrderInput.mktProt}");
        debugPrint("IP Address: $_ip");
        
        // Print as JSON for easy copy-paste
        Map<String, dynamic> payloadMap = {
          "exch": placeOrderInput.exch,
          "tsym": placeOrderInput.tsym,
          "qty": placeOrderInput.qty,
          "prc": (placeOrderInput.prctype == 'MKT' || placeOrderInput.prctype == 'SL-MKT') ? '0' : placeOrderInput.prc,
          "prd": placeOrderInput.prd,
          "trantype": placeOrderInput.trantype,
          "prctyp": placeOrderInput.prctype,
          "ret": placeOrderInput.ret.toUpperCase(),
          "channel": placeOrderInput.channel,
          "amo": placeOrderInput.amo,
          "blprc": placeOrderInput.blprc,
          "bpprc": placeOrderInput.bpprc,
          "dscqty": placeOrderInput.dscqty,
          "trgprc": placeOrderInput.trgprc,
          "trailprc": placeOrderInput.trailprc,
          "mkt_protection": placeOrderInput.mktProt,
        };
        debugPrint("\nPayload JSON:");
        debugPrint(jsonEncode(payloadMap));
        debugPrint("============================\n");
        
        debugPrint("Calling getPlaceOrder API...");
        _placeOrderModel = await api.getPlaceOrder(placeOrderInput, _ip);
        
        debugPrint("\n=== BASKET ORDER RESPONSE ===");
        if (_placeOrderModel != null) {
          debugPrint("Status: ${_placeOrderModel!.stat}");
          debugPrint("Error Message: ${_placeOrderModel!.emsg}");
          debugPrint("Order Number: ${_placeOrderModel!.norenordno}");
          debugPrint("Request Time: ${_placeOrderModel!.requestTime}");
          
          // Print full response as JSON
          debugPrint("\nResponse JSON:");
          debugPrint(jsonEncode(_placeOrderModel!.toJson()));
        } else {
          debugPrint("Response is null!");
        }
        debugPrint("============================\n");

        if (_placeOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeOrderModel!.stat == "Not_Ok") {
          debugPrint("ERROR: Session Expired");
          ref.read(authProvider).ifSessionExpired(context);
          break;
        } else if (_placeOrderModel!.stat == "Ok" && _placeOrderModel!.norenordno != null) {
          // Store successful order details
          String orderId = _placeOrderModel!.norenordno!;
          debugPrint("SUCCESS: Order placed with ID: $orderId");
          
          _basketOrderIds[basketName]!.add(orderId);
          _basketOrderStatuses[basketName]![itemKey] = 'placed';
          
          // Add order tracking to basket item
          element['orderIds'] = element['orderIds'] ?? [];
          element['orderIds'].add(orderId);
          element['orderStatus'] = 'placed';
          
          successfulOrders.add(orderId);
          ConstantName.sessCheck = true;
        } else {
          // Handle failed order
          debugPrint("FAILED: Order placement failed");
          debugPrint("  Status: ${_placeOrderModel!.stat}");
          debugPrint("  Error: ${_placeOrderModel!.emsg ?? 'Unknown error'}");
          debugPrint("  Order Number: ${_placeOrderModel!.norenordno}");
          
          _basketOrderStatuses[basketName]![itemKey] = 'failed';
          element['orderStatus'] = 'failed';
          element['orderError'] = _placeOrderModel!.emsg ?? 'Unknown error';
          failedOrders.add(element['tsym']);
          
          // IMPORTANT: Even failed orders should be tracked if they have an order number
          // Some APIs return order numbers even for failed orders
          if (_placeOrderModel!.norenordno != null) {
            String failedOrderId = _placeOrderModel!.norenordno!;
            debugPrint("  NOTE: Failed order has order ID: $failedOrderId - will track it");
            _basketOrderIds[basketName]!.add(failedOrderId);
            element['orderIds'] = element['orderIds'] ?? [];
            element['orderIds'].add(failedOrderId);
          }
        }
      }
      
      debugPrint("\n=== BASKET PLACE ORDER SUMMARY ===");
      debugPrint("Successful Orders: ${successfulOrders.length}");
      debugPrint("Failed Orders: ${failedOrders.length}");
      debugPrint("Total Order IDs tracked: ${_basketOrderIds[basketName]?.length ?? 0}");
      
      // Update overall basket status
      if (failedOrders.isEmpty) {
        _basketOverallStatus[basketName] = 'placed';
        debugPrint("Overall Status: placed");
      } else if (successfulOrders.isEmpty) {
        _basketOverallStatus[basketName] = 'failed';
        debugPrint("Overall Status: failed");
      } else {
        _basketOverallStatus[basketName] = 'partially_placed';
        debugPrint("Overall Status: partially_placed");
      }
      
      if (navigateToOrderBook) {
        debugPrint("Navigating to Order Book...");
        ref.read(indexListProvider).bottomMenu(2, context);

        debugPrint("Fetching Order Book...");
        await fetchOrderBook(context, false);
        debugPrint("Order Book fetched. Total orders: ${_orderBookModel?.length ?? 0}");
        debugPrint("Executed orders: ${_executedOrder?.length ?? 0}");
        
        await changeTabIndex(0, context);
        ref.read(indexListProvider).bottomMenu(2, context);

        Navigator.pop(context);
      }
      
      // Save order tracking data to preferences
      debugPrint("Saving order tracking data to preferences...");
      await _saveOrderTrackingData();
      debugPrint("Order tracking data saved");
      
      // Show appropriate success/failure message
      String message;
      if (failedOrders.isEmpty) {
        message = "Basket Order Successfully Placed (${successfulOrders.length} orders)";
      } else if (successfulOrders.isEmpty) {
        message = "Basket Order Failed - No orders placed";
      } else {
        message = "Basket Order Partially Placed - ${successfulOrders.length} success, ${failedOrders.length} failed";
      }
      
      debugPrint("Showing message: $message");
      ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, message));
          
      debugPrint("=== BASKET PLACE ORDER END ===\n");
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("=== BASKET PLACE ORDER ERROR ===");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      
      // Update basket status to failed
      if (_selectedBsktName.isNotEmpty) {
        _basketOverallStatus[_selectedBsktName] = 'failed';
      }
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Place Slice  Order", "Error": "$e"});
      notifyListeners();
    }
  }

  // Method to update basket order statuses from order book data
  void updateBasketOrderStatus() async {
    try {
      debugPrint("=== UPDATING BASKET ORDER STATUS ===");
      debugPrint("Order Book Model Count: ${_orderBookModel?.length ?? 0}");
      debugPrint("Executed Order Count: ${_executedOrder?.length ?? 0}");
      debugPrint("Open Order Count: ${_openOrder?.length ?? 0}");
      
      // Get all baskets that need processing (those with tracking data OR current basket with item orders)
      Set<String> basketsToProcess = Set<String>.from(_basketOrderIds.keys);
      
      // Also check if current basket has individual item order data
      if (_selectedBsktName.isNotEmpty && _bsktScripList.isNotEmpty) {
        bool hasItemOrders = _bsktScripList.any((item) => 
          item['orderIds'] != null && item['orderIds'].isNotEmpty
        );
        if (hasItemOrders) {
          basketsToProcess.add(_selectedBsktName);
        }
      }
      
      for (String basketName in basketsToProcess) {
        List<String> orderIds = _basketOrderIds[basketName] ?? [];
        
        // If no global order ids, try to collect from individual items
        if (orderIds.isEmpty && basketName == _selectedBsktName) {
          Set<String> itemOrderIds = {};
          for (var item in _bsktScripList) {
            if (item['orderIds'] != null && item['orderIds'].isNotEmpty) {
              itemOrderIds.addAll(List<String>.from(item['orderIds']));
            }
          }
          orderIds = itemOrderIds.toList();
          if (orderIds.isNotEmpty) {
            _basketOrderIds[basketName] = orderIds; // Update global tracking
          }
        }
        
        if (orderIds.isEmpty) continue;
        
        print("Processing basket: $basketName with ${orderIds.length} orders");
        
        // Check each order ID against current order book
        Map<String, String> orderIdToStatus = {};
        Map<String, OrderBookModel> orderIdToModel = {};
        int completedCount = 0;
        int rejectedCount = 0;
        int openCount = 0;
        
        for (String orderId in orderIds) {
          debugPrint("  Checking order ID: $orderId");
          // Find order in all order lists
          OrderBookModel? order = _findOrderById(orderId);
          
          if (order != null && order.status != null) {
            String actualStatus = order.status!; // Keep original case (REJECTED, COMPLETE, etc.)
            orderIdToStatus[orderId] = actualStatus;
            orderIdToModel[orderId] = order;
            
            debugPrint("    Order $orderId found - Status: $actualStatus");
            debugPrint("    Order TSYM: ${order.tsym}");
            debugPrint("    Order Exchange: ${order.exch}");
            debugPrint("    Order Stat: ${order.stat}");
            debugPrint("    Order Error: ${order.emsg}");
            
            // Count statuses
            if (actualStatus == 'COMPLETE') {
              completedCount++;
              debugPrint("    -> Counted as COMPLETE");
            } else if (actualStatus == 'REJECTED' || actualStatus == 'CANCELED') {
              rejectedCount++;
              debugPrint("    -> Counted as REJECTED/CANCELED (should appear in executed)");
            } else {
              openCount++; // OPEN or other statuses
              debugPrint("    -> Counted as OPEN/OTHER");
            }
          } else {
            // Order not found in order book - this means it's stale/expired
            debugPrint("    Order $orderId NOT FOUND in current orderbook");
            debugPrint("    This could mean:");
            debugPrint("      - Order was never placed (failed immediately)");
            debugPrint("      - Order is stale/expired");
            debugPrint("      - Order book hasn't been refreshed yet");
            // Don't add to orderIdToStatus map - let it be cleaned up
          }
        }
        
        debugPrint("  Status Summary for basket $basketName:");
        debugPrint("    Completed: $completedCount");
        debugPrint("    Rejected/Canceled: $rejectedCount");
        debugPrint("    Open: $openCount");
        debugPrint("    Total tracked: ${orderIds.length}");
        
        // Update individual basket items with real order statuses
        _updateBasketItemStatusesWithOrderBook(basketName, orderIdToStatus, orderIdToModel);
        
        // Update overall basket status based on real statuses
        if (completedCount == orderIds.length) {
          _basketOverallStatus[basketName] = 'completed';
        } else if (rejectedCount == orderIds.length) {
          _basketOverallStatus[basketName] = 'failed';
        } else if (rejectedCount > 0 && (rejectedCount + completedCount) == orderIds.length) {
          // Some rejected, some completed, none open
          _basketOverallStatus[basketName] = 'partially_completed';
        } else if (completedCount > 0) {
          // Some completed, others still open/processing
          _basketOverallStatus[basketName] = 'partially_filled';
        } else {
          // All orders still open/processing
          _basketOverallStatus[basketName] = 'placed';
        }
        
        print("Basket $basketName final status: ${_basketOverallStatus[basketName]}");
        print("Counts - Complete: $completedCount, Rejected: $rejectedCount, Open: $openCount");
      }
      
      // Save updated tracking data
      await _saveOrderTrackingData();
      
      notifyListeners();
    } catch (e) {
      print("Error updating basket order status: $e");
    }
  }
  
  // Helper method to find order by ID in all order lists
  OrderBookModel? _findOrderById(String orderId) {
    debugPrint("    _findOrderById: Searching for order ID: $orderId");
    
    // Search in all orders (orderBookModel)
    if (_orderBookModel != null) {
      try {
        OrderBookModel? found = _orderBookModel!.firstWhere(
          (order) => order.norenordno == orderId,
        );
        debugPrint("      Found in _orderBookModel");
        return found;
      } catch (e) {
        debugPrint("      Not found in _orderBookModel");
      }
    }
    
    // Search in executed orders (REJECTED, CANCELED, COMPLETE should be here)
    if (_executedOrder != null) {
      try {
        OrderBookModel? found = _executedOrder!.firstWhere(
          (order) => order.norenordno == orderId,
        );
        debugPrint("      Found in _executedOrder (status: ${found.status})");
        return found;
      } catch (e) {
        debugPrint("      Not found in _executedOrder");
      }
    }
    
    // Search in open orders
    if (_openOrder != null) {
      try {
        OrderBookModel? found = _openOrder!.firstWhere(
          (order) => order.norenordno == orderId,
        );
        debugPrint("      Found in _openOrder");
        return found;
      } catch (e) {
        debugPrint("      Not found in _openOrder");
      }
    }
    
    // Search in executed orders
    if (_executedOrder != null) {
      try {
        return _executedOrder!.firstWhere(
          (order) => order.norenordno == orderId,
        );
      } catch (e) {
        // Order not found
      }
    }
    
    return null; // Order not found anywhere
  }
  
  // Method to update individual basket items with order book data
  void _updateBasketItemStatusesWithOrderBook(String basketName, Map<String, String> orderIdToStatus, Map<String, OrderBookModel> orderIdToModel) {
    // Update basket items with real order data
    for (var element in _bsktScripList) {
      if (element['orderIds'] != null) {
        List<String> itemOrderIds = List<String>.from(element['orderIds']);
        
        // Find the status for this item's orders
        List<String> itemStatuses = [];
        List<String> itemOrderDetails = [];
        
        for (String orderId in itemOrderIds) {
          if (orderIdToStatus.containsKey(orderId)) {
            String status = orderIdToStatus[orderId]!;
            itemStatuses.add(status);
            
            // Add order details for display
            OrderBookModel? orderModel = orderIdToModel[orderId];
            if (orderModel != null) {
              String detail = 'ID: $orderId, Status: $status';
              if (orderModel.avgprc != null && orderModel.avgprc != "0.00") {
                detail += ', Avg: ₹${orderModel.avgprc}';
              }
              itemOrderDetails.add(detail);
            }
          }
        }
        
        // Set the primary status for this item (worst case scenario)
        if (itemStatuses.isEmpty) {
          // No valid order found in orderbook, reset order status
          print("DEBUG: Resetting order status for ${element['tsym']} - no valid orders found");
          element['orderStatus'] = null;
          element['orderDetails'] = null;
        } else if (itemStatuses.contains('REJECTED')) {
          element['orderStatus'] = 'REJECTED';
        } else if (itemStatuses.contains('CANCELED')) {
          element['orderStatus'] = 'CANCELED';
        } else if (itemStatuses.contains('COMPLETE')) {
          element['orderStatus'] = itemStatuses.every((s) => s == 'COMPLETE') ? 'COMPLETE' : 'PARTIAL';
        } else {
          element['orderStatus'] = 'OPEN';
        }
        
        // Store order details for UI display
        if (itemStatuses.isNotEmpty) {
          element['orderDetails'] = itemOrderDetails;
        }
        
        print("Updated item ${element['tsym']}: status=${element['orderStatus']}, details=${itemOrderDetails}");
      } else {
        // No order IDs means the item was never placed, reset any existing status
        element['orderStatus'] = null;
        element['orderDetails'] = null;
      }
    }
  }

  // Method to validate and clean up stale order statuses for all baskets
  void validateAllBasketOrderStatuses() {
    if (_orderBookModel == null || _orderBookModel!.isEmpty) {
      return;
    }

    // Create map of all current order IDs in orderbook for fast lookup
    Set<String> currentOrderIds = {};
    for (var order in _orderBookModel!) {
      if (order.norenordno != null) {
        currentOrderIds.add(order.norenordno!);
      }
    }

    // Check all basket items and reset status if order ID not found
    for (var element in _bsktScripList) {
      if (element['orderIds'] != null) {
        List<String> itemOrderIds = List<String>.from(element['orderIds']);
        
        // Check if any of the order IDs still exist in orderbook
        bool hasValidOrder = false;
        for (String orderId in itemOrderIds) {
          if (currentOrderIds.contains(orderId)) {
            hasValidOrder = true;
            break;
          }
        }
        
        // If no valid orders found, reset the status
        if (!hasValidOrder) {
          print("DEBUG: Found stale order for ${element['tsym']}, orderIds: $itemOrderIds");
          print("DEBUG: Current orderbook has ${currentOrderIds.length} orders");
          element['orderStatus'] = null;
          element['orderDetails'] = null;
          element['orderIds'] = null; // Also clear the order IDs
          print("Reset stale order status for ${element['tsym']} - orders not found in current orderbook");
        }
      }
    }
    
    notifyListeners();
  }

  // Method to save cleaned basket data back to preferences
  Future<void> _saveBasketToPreferences(String basketName) async {
    try {
      final userId = pref.clientId;
      if (userId != null && userId.isNotEmpty) {
        // Update the basket data in memory
        _bsktScrips[basketName] = _bsktScripList;
        
        // Save to user-specific preferences
        final updatedBasketData = jsonEncode(_bsktScrips);
        await pref.setBasketScripForUser(userId, updatedBasketData);
        print("DEBUG: Saved cleaned basket data for user $userId, basket: $basketName");
      } else {
        // Update the basket data in memory
        _bsktScrips[basketName] = _bsktScripList;
        
        // Save to general preferences
        final updatedBasketData = jsonEncode(_bsktScrips);
        await pref.setBasketScrip(updatedBasketData);
        print("DEBUG: Saved cleaned basket data to general preferences, basket: $basketName");
      }
    } catch (e) {
      print("ERROR: Failed to save cleaned basket data: $e");
    }
  }

  // Method to update individual basket item statuses
  void _updateBasketItemStatuses(String basketName, Map<String, String> orderStatuses) {
    try {
      for (int index = 0; index < _bsktScripList.length; index++) {
        var element = _bsktScripList[index];
        List<String>? orderIds = element['orderIds'];
        
        if (orderIds != null && orderIds.isNotEmpty) {
          // Check if any of the order IDs have been updated
          for (String orderId in orderIds) {
            if (orderStatuses.containsKey(orderId)) {
              element['orderStatus'] = orderStatuses[orderId];
              
              // Find full order details for additional info
              OrderBookModel? order = _orderBookModel?.firstWhere(
                (ord) => ord.norenordno == orderId,
                orElse: () => OrderBookModel(),
              );
              
              if (order?.avgprc != null) {
                element['avgPrice'] = order!.avgprc;
              }
              if (order?.fillshares != null) {
                element['filledQty'] = order!.fillshares;
              }
              if (order?.rejreason != null) {
                element['rejectionReason'] = order!.rejreason;
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error updating basket item statuses: $e");
    }
  }

  // Method to reset basket order tracking
  void resetBasketOrderTracking(String basketName) {
    _basketOrderIds.remove(basketName);
    _basketOrderStatuses.remove(basketName);
    _basketOverallStatus.remove(basketName);
    
    // Clear order tracking from basket items
    for (var element in _bsktScripList) {
      element.remove('orderIds');
      element.remove('orderStatus');
      element.remove('orderError');
      element.remove('avgPrice');
      element.remove('filledQty');
      element.remove('rejectionReason');
    }
    
    // Also clear from persistent storage immediately
    _clearBasketFromPersistentStorage(basketName);
    
    // Save the reset state to preferences
    _saveOrderTrackingData();
    
    notifyListeners();
  }

  // Helper method to clear specific basket from persistent storage
  Future<void> _clearBasketFromPersistentStorage(String basketName) async {
    try {
      final userId = pref.clientId;
      String? existingJsonData;
      
      if (userId != null && userId.isNotEmpty) {
        existingJsonData = pref.getOrderTrackingForUser(userId);
      } else {
        existingJsonData = pref.orderTracking;
      }
      
      if (existingJsonData != null && existingJsonData.isNotEmpty) {
        final existingData = jsonDecode(existingJsonData);
        
        // Clear this basket from all tracking data in persistent storage
        if (existingData['basketOrderIds'] != null) {
          (existingData['basketOrderIds'] as Map).remove(basketName);
        }
        if (existingData['basketOrderStatuses'] != null) {
          (existingData['basketOrderStatuses'] as Map).remove(basketName);
        }
        if (existingData['basketOverallStatus'] != null) {
          (existingData['basketOverallStatus'] as Map).remove(basketName);
        }
        if (existingData['basketItemsData'] != null) {
          (existingData['basketItemsData'] as Map).remove(basketName);
        }
        
        // Save the updated data back to persistent storage
        final updatedJsonData = jsonEncode(existingData);
        if (userId != null && userId.isNotEmpty) {
          await pref.setOrderTrackingForUser(userId, updatedJsonData);
        } else {
          await pref.setOrderTracking(updatedJsonData);
        }
      }
    } catch (e) {
      print("Error clearing basket from persistent storage: $e");
    }
  }

  // Method to remove individual script order tracking without affecting other scripts
  void removeScriptOrderTracking(String basketName, String scriptKey, List<String> orderIds) {
    // Remove specific order IDs from basket tracking
    if (_basketOrderIds.containsKey(basketName)) {
      for (String orderId in orderIds) {
        _basketOrderIds[basketName]?.remove(orderId);
      }
      // If no more orders left in basket, remove the basket entry
      if (_basketOrderIds[basketName]?.isEmpty ?? true) {
        _basketOrderIds.remove(basketName);
        _basketOrderStatuses.remove(basketName);
        _basketOverallStatus.remove(basketName);
      }
    }
    
    // Remove from basket order statuses
    if (_basketOrderStatuses.containsKey(basketName)) {
      _basketOrderStatuses[basketName]?.remove(scriptKey);
    }
    
    // Clear the individual script's order data from persistent storage
    _removeScriptFromPersistentStorage(basketName, scriptKey);
    
    // Save the updated state
    _saveOrderTrackingData();
    
    notifyListeners();
  }

  // Helper method to remove specific script from persistent storage
  Future<void> _removeScriptFromPersistentStorage(String basketName, String scriptKey) async {
    try {
      final userId = pref.clientId;
      String? existingJsonData;
      
      if (userId != null && userId.isNotEmpty) {
        existingJsonData = pref.getOrderTrackingForUser(userId);
      } else {
        existingJsonData = pref.orderTracking;
      }
      
      if (existingJsonData != null && existingJsonData.isNotEmpty) {
        final existingData = jsonDecode(existingJsonData);
        
        // Remove specific script from basketItemsData
        if (existingData['basketItemsData'] != null && 
            existingData['basketItemsData'][basketName] != null) {
          List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
            existingData['basketItemsData'][basketName]
          );
          
          // Remove items matching the script key (token + index combination)
          items.removeWhere((item) {
            String itemKey = "${item['token']}_${item['index']}";
            return itemKey == scriptKey;
          });
          
          if (items.isNotEmpty) {
            existingData['basketItemsData'][basketName] = items;
          } else {
            (existingData['basketItemsData'] as Map).remove(basketName);
          }
        }
        
        // Save the updated data back to persistent storage
        final updatedJsonData = jsonEncode(existingData);
        if (userId != null && userId.isNotEmpty) {
          await pref.setOrderTrackingForUser(userId, updatedJsonData);
        } else {
          await pref.setOrderTracking(updatedJsonData);
        }
      }
    } catch (e) {
      print("Error removing script from persistent storage: $e");
    }
  }
  
  // Method to check if basket has been placed
  bool isBasketPlaced(String basketName) {
    String status = _basketOverallStatus[basketName] ?? '';
    return ['placed', 'partially_placed', 'partially_filled', 'partially_completed', 'completed', 'failed'].contains(status);
  }

  // Method to get basket status for UI display
  String? getBasketStatus(String basketName) {
    return _basketOverallStatus[basketName];
  }
  
  // Save order tracking data to preferences
  Future<void> _saveOrderTrackingData() async {
    try {
      final userId = pref.clientId;
      
      // Read existing basket items data first to preserve other baskets' data
      Map<String, List<Map<String, dynamic>>> basketItemsData = {};
      try {
        String? existingJsonData;
        if (userId != null && userId.isNotEmpty) {
          existingJsonData = pref.getOrderTrackingForUser(userId);
        } else {
          existingJsonData = pref.orderTracking;
        }
        
        if (existingJsonData != null && existingJsonData.isNotEmpty) {
          final existingData = jsonDecode(existingJsonData);
          basketItemsData = Map<String, List<Map<String, dynamic>>>.from(
            (existingData['basketItemsData'] ?? {}).map((key, value) => 
              MapEntry(key, List<Map<String, dynamic>>.from(value))
            )
          );
        }
      } catch (e) {
        print("Error reading existing basket items data: $e");
      }
      
      // Update current basket's item data
      if (_selectedBsktName.isNotEmpty && _bsktScripList.isNotEmpty) {
        String basketName = _selectedBsktName;
        if (_basketOrderIds.containsKey(basketName) && _basketOrderIds[basketName]!.isNotEmpty) {
          List<Map<String, dynamic>> itemsWithOrders = [];
          for (int index = 0; index < _bsktScripList.length; index++) {
            var item = _bsktScripList[index];
            if (item['orderIds'] != null && item['orderIds'].isNotEmpty) {
              itemsWithOrders.add({
                'tsym': item['tsym'],
                'token': item['token'],
                'index': index, // Include index to handle duplicates
                'orderIds': item['orderIds'],
                'orderStatus': item['orderStatus'],
                'orderError': item['orderError'],
                'avgPrice': item['avgPrice'],
                'filledQty': item['filledQty'],
                'rejectionReason': item['rejectionReason'],
              });
            }
          }
          basketItemsData[basketName] = itemsWithOrders;
        }
      }
      
      final orderTrackingData = {
        'basketOrderIds': _basketOrderIds,
        'basketOrderStatuses': _basketOrderStatuses,
        'basketOverallStatus': _basketOverallStatus,
        'basketItemsData': basketItemsData,
      };
      
      final jsonData = jsonEncode(orderTrackingData);
      if (userId != null && userId.isNotEmpty) {
        await pref.setOrderTrackingForUser(userId, jsonData);
      } else {
        await pref.setOrderTracking(jsonData);
      }
    } catch (e) {
      print("Error saving order tracking data: $e");
    }
  }
  
  // Restore order tracking data from preferences
  Future<void> _restoreOrderTrackingData() async {
    try {
      final userId = pref.clientId;
      String? jsonData;
      
      if (userId != null && userId.isNotEmpty) {
        jsonData = pref.getOrderTrackingForUser(userId);
      } else {
        jsonData = pref.orderTracking;
      }
      
      if (jsonData != null && jsonData.isNotEmpty) {
        final data = jsonDecode(jsonData);
        _basketOrderIds = Map<String, List<String>>.from(
          (data['basketOrderIds'] ?? {}).map((key, value) => 
            MapEntry(key, List<String>.from(value))
          )
        );
        _basketOrderStatuses = Map<String, Map<String, String>>.from(
          (data['basketOrderStatuses'] ?? {}).map((key, value) => 
            MapEntry(key, Map<String, String>.from(value))
          )
        );
        _basketOverallStatus = Map<String, String>.from(data['basketOverallStatus'] ?? {});
        
        // Restore basket item order data
        Map<String, dynamic> basketItemsData = data['basketItemsData'] ?? {};
        _restoreBasketItemOrderDataFromSaved(basketItemsData);
        
        print("Restored order tracking for baskets: ${_basketOverallStatus.keys}");
      }
    } catch (e) {
      print("Error restoring order tracking data: $e");
    }
  }

  // Method to restore order tracking data to basket items from saved data
  void _restoreBasketItemOrderDataFromSaved(Map<String, dynamic> basketItemsData) {
    if (_selectedBsktName.isEmpty || _bsktScripList.isEmpty) return;
    
    String basketName = _selectedBsktName;
    List<dynamic>? savedItems = basketItemsData[basketName];
    
    if (savedItems == null || savedItems.isEmpty) return;
    
    print("Restoring saved order data for basket: $basketName with ${savedItems.length} saved items");
    
    // Match saved items with current basket items using proper index-based matching
    for (int index = 0; index < _bsktScripList.length; index++) {
      var currentItem = _bsktScripList[index];
      
      // Find matching saved item by tsym, token, and index (to handle duplicates correctly)
      for (var savedItem in savedItems) {
        if (savedItem['tsym'] == currentItem['tsym'] && 
            savedItem['token'] == currentItem['token'] &&
            savedItem['index'] == index) {
          
          // Restore all order tracking fields
          currentItem['orderIds'] = savedItem['orderIds'];
          currentItem['orderStatus'] = savedItem['orderStatus'];
          currentItem['orderError'] = savedItem['orderError'];
          currentItem['avgPrice'] = savedItem['avgPrice'];
          currentItem['filledQty'] = savedItem['filledQty'];
          currentItem['rejectionReason'] = savedItem['rejectionReason'];
          
          print("Restored saved data for item ${currentItem['tsym']} at index $index: status=${currentItem['orderStatus']}");
          break;
        }
      }
    }
  }

  // Method to restore order tracking data to basket items (fallback method)
  void _restoreBasketItemOrderData() {
    if (_selectedBsktName.isEmpty || _bsktScripList.isEmpty) return;
    
    String basketName = _selectedBsktName;
    List<String> orderIds = _basketOrderIds[basketName] ?? [];
    
    if (orderIds.isEmpty) return;
    
    print("Restoring order data for basket: $basketName with ${orderIds.length} orders");
    
    // For each basket item, restore its order tracking data if it exists
    for (int index = 0; index < _bsktScripList.length; index++) {
      var element = _bsktScripList[index];
      String itemKey = "${element['tsym']}_${element['token']}_$index";
      
      // Check if this item has order data
      String? itemStatus = _basketOrderStatuses[basketName]?[itemKey];
      if (itemStatus != null) {
        // Find matching order IDs for this item
        List<String> itemOrderIds = [];
        for (String orderId in orderIds) {
          // Try to match order to item - this is a simplified approach
          // In a more complex scenario, you might need better mapping
          OrderBookModel? order = _findOrderById(orderId);
          if (order != null && order.tsym == element['tsym']) {
            itemOrderIds.add(orderId);
            break; // Assuming one order per item for now
          }
        }
        
        if (itemOrderIds.isNotEmpty) {
          element['orderIds'] = itemOrderIds;
          element['orderStatus'] = itemStatus;
          
          // Get latest status from order book
          OrderBookModel? order = _findOrderById(itemOrderIds.first);
          if (order != null && order.status != null) {
            element['orderStatus'] = order.status!;
          }
          
          print("Restored order data for item ${element['tsym']}: status=${element['orderStatus']}");
        }
      }
    }
  }

  Future fetchPlaceGTTOrder(
      PlaceGTTOrderInput placeGttOrderInput, BuildContext context) async {
    try {
      _placeGttOrderModel = await api.placeGTTOrderAPI(placeGttOrderInput);

      if (_placeGttOrderModel!.stat == "OI created") {
        ConstantName.sessCheck = true;
        ref.read(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        // Show success message - ResponsiveSnackBar for web, ScaffoldMessenger for mobile
        if (kIsWeb) {
          ResponsiveSnackBar.showSuccess(context, "Order Placed Successfully");
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(successMessage(context, "Order Placed Successfully"));
        }

        if (kIsWeb) {
          // On web, skip Navigator.pop and bottomMenu navigation
          // The draggable dialog will handle closing itself
        } else {
          Navigator.pop(context);
          ref.read(indexListProvider).bottomMenu(2, context);
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.click);
        }
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API GTT Order ", "Error": "$e"});
      notifyListeners();
    } finally {}
  }
}
