import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'market_watch_provider.dart';
import 'order_input_provider.dart';
import 'websocket_provider.dart';
import 'portfolio_provider.dart';

final orderProvider = ChangeNotifierProvider((ref) => OrderProvider(ref));

class OrderProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();

  int frezQtyOrderSliceMaxLimit = 20;

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

  clearAllorders() {
    _torderBookModel = [];
    _ttradeBook = [];
    _orderBookModel = [];
    _gttOrderBookModel = [];
    _tradeBook = [];
    _orderSearchItem = [];
    _orderHistoryModel = [];
    _siporderBookModel = null;
    _siporderBookSearch = [];
    _bsktScripList = [];
    _bsktScripList = [];
    _gttOrderBookSearch = [];
    _tradeBooksearch = [];
    _executedOrder = [];
    _openOrder = [];
    _allOrder = [];
    _orderBookModel = [];
    _selectedTab = 0;
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
    // Unfocus any active text fields when switching tabs
    FocusScope.of(context).unfocus();

    _selectedTab = index;
    tabSize();
    showOrderSearch(false);
    showGTTOrderSearch(false);
    ref.read(marketWatchProvider).showAlertPendingSearch(false);
    showSipSearch(false);
    ref.read(marketWatchProvider).clearAlertSearch();
    clearOrderSearch();
    clearGttOrderSearch();
    clearSipSearch();
    orderSearch(orderSearchCtrl.text, context);
    if (index <= 3) {
      requestWSOrderBook(isSubscribe: true, context: context);
    }

    if (index == 4) {
      getBasketName();
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
  chngBsktName(String val, BuildContext context) async {
    _selectedBsktName = val;

    _bsktScrips = pref.bsktScrips!.isEmpty ? {} : jsonDecode(pref.bsktScrips!);

    _bsktScripList = _bsktScrips[val] ?? [];

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
          if (parsedDate.isBefore(now)) {
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

    Navigator.pushNamed(context, Routes.bsktScripList, arguments: val);
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
      const Tab(
        text: ("Alerts"),
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
        case 4: // Basket Orders - Search not applicable
          break;
        // case 5: // SIP Orders
        //   _siporderBookSearch = _siporderBookModel!.sipDetails!
        //       .where((element) =>
        //           element.sipName!.toUpperCase().contains(value.toUpperCase()))
        //       .toList();
        //   break;
        case 6: // Alerts
          final alertProvider = ref.read(marketWatchProvider);
          if (alertProvider.alertPendingModel != null) {
            final searchResult = alertProvider.alertPendingModel!
                .where((element) =>
                    element.tsym!.toUpperCase().contains(value.toUpperCase()))
                .toList();
            alertProvider.setAlertPendingSearch(searchResult);
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
      bool isExit) async {
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
        notifyListeners();
        //   } else {
        //     if (_orderBookModel![0].emsg ==
        //             "Session Expired :  Invalid Session Key" &&
        //         _orderBookModel![0].stat == "Not_Ok") {
        //       ref.read(authProvider).ifSessionExpired(context);
        //     }
        //   }
        // }

        if (!isExit) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }

        // Navigate to order confirmation screen
        Navigator.pushNamed(context, Routes.orderConfirmation, arguments: {
          'orderData': [_placeOrderModel!],
        });

        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        if (_placeOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "${_placeOrderModel!.emsg}"));
        }
      }

      return _placeOrderModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Place Order", "Error": "$e"});
      notifyListeners();
    } finally {}
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
      final iterations = quantity >= 20 ? 20 : quantity;

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

        // Navigate to order confirmation screen with all sliced orders
        if (context.mounted) {
          Navigator.pushNamed(context, Routes.orderConfirmation, arguments: {
            'orderData': _sliceOrderResults,
          });
        }
        notifyListeners();
      } else {
        // Show error if no orders were successful
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(warningMessage(
              context, "Failed to place orders. Please try again."));
        }
      }
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Slice Order Confirmation", "Error": "$e"});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "Error placing orders: ${e.toString()}"));
      }
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
          _selectedTab = 0;
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
              if (element.status == "REJECTED" ||
                  element.status == "CANCELED" ||
                  element.status == "COMPLETE" ||
                  element.status == "INVALID_STATUS_TYPE") {
                _executedOrder!.add(element);
              } else {
                _openOrder!.add(element);
              }
              _allOrder!.add(element);
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
      if (element.isExitSelection!) {
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

        Navigator.pushNamed(context, Routes.orderConfirmation, arguments: {
          'orderData': [modifyOrderData],
        });
      } else {
        if (_modifyOrderModel!.emsg ==
            "Session Expired :  Invalid Session Key") {
          ref.read(authProvider).ifSessionExpired(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, '${_modifyOrderModel!.emsg}'));
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
      if (_orderBookModel != null) {
        if (_orderBookModel!.isNotEmpty &&
            _orderBookModel![0].stat != "Not_Ok") {
          input = _orderBookModel!
              .map((e) => "${e.exch}|${e.token}")
              .toSet()
              .join("#");
          print("Regular orders input: $input");
        }
      }

      if (_gttOrderBookModel!.isNotEmpty) {
        // Debug: Print GTT order tokens before subscription
        print("=== GTT ORDER SOCKET SUBSCRIPTION ===");
        print("GTT Orders count: ${_gttOrderBookModel!.length}");
        print("Subscribe mode: ${isSubscribe ? 'SUBSCRIBE' : 'UNSUBSCRIBE'}");

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

        Navigator.pop(context);
        ref.read(indexListProvider).bottomMenu(2, context);
        // Switch to Orders tab in Portfolio screen
        ref.read(portfolioProvider).changeTabIndex(2);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
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
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Modified Order"));
        ref.read(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        Navigator.pop(context);
        ref.read(indexListProvider).bottomMenu(2, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
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

        // Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "GTT Order Cancelled Successfully"));
        Navigator.pop(context);
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      //  Navigator.pop(context);
      if (_placeGttOrderModel!.stat == "Invalid Oi") {
        await fetchGTTOrderBook(context, "");
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "Provided GTT Order is not found"));
        Navigator.pop(context);
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

        Navigator.pop(context);
        ref.read(indexListProvider).bottomMenu(2, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
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
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Modified Order"));
        ref.read(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        Navigator.pop(context);
        ref.read(indexListProvider).bottomMenu(2, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
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

    _bsktList.add({
      "bsketName": val,
      "createdDate": curDate,
      "max": '20',
      "curLength": '0'
    });
    await pref.setBasketList(jsonEncode(_bsktList));

    getBasketName();
    tabSize();
    Navigator.pop(context);
    notifyListeners();
  }

  getBasketName() async {
    _bsktList = pref.bsktList!.isEmpty ? [] : jsonDecode(pref.bsktList!);

    _bsktScrips = pref.bsktScrips!.isEmpty ? {} : jsonDecode(pref.bsktScrips!);

    if (_bsktList.isNotEmpty) {
      for (var element in _bsktList) {
        List scipList = _bsktScrips[element['bsketName']] ?? [];
        element['curLength'] = "${scipList.length}";
        if (_selectedBsktName == element['bsketName']) {
          _bsktScripList = scipList;
        }
      }
    }

    log("$_bsktScrips");
    notifyListeners();
  }

  removeBasket(int index) async {
    _bsktList.removeAt(index);

    await pref.setBasketList(jsonEncode(_bsktList));
    _bsktList = pref.bsktList!.isEmpty ? [] : jsonDecode(pref.bsktList!);
    tabSize();
    notifyListeners();
  }

  removeBsktScrip(int index, String bsktName) {
    Map<String, dynamic> data = {};
    data = pref.bsktScrips!.isEmpty ? {} : jsonDecode(pref.bsktScrips!);

    _bsktScripList.removeAt(index);

    data.addAll({bsktName: _bsktScripList});

    String jsonData = jsonEncode(data);

    pref.setBasketScrip(jsonData);

    getBasketName();
  }

  fetchBasketMargin() async {
    try {
      List basket = [];
      if (_bsktScripList.isNotEmpty) {
        for (var i = 0; i < _bsktScripList.length; i++) {
          if (i > 0) {
            basket.add({
              "exch": '${_bsktScripList[i]["exch"]}',
              "tsym": '${_bsktScripList[i]["tsym"]}'.contains("&")
                  ? '${_bsktScripList[i]["tsym"]}'.replaceAll("&", "%26")
                  : '${_bsktScripList[i]["tsym"]}',
              "qty": '${_bsktScripList[i]["qty"]}',
              "prc": '${_bsktScripList[i]["prc"]}',
              "prd": '${_bsktScripList[i]["prd"]}',
              "trantype": '${_bsktScripList[i]["trantype"]}',
              "prctyp": '${_bsktScripList[i]["prctyp"]}'
            });
          }
        }

        OrderMarginInput inputs = OrderMarginInput(
            exch: '${_bsktScripList[0]["exch"]}',
            prc: '${_bsktScripList[0]["prc"]}',
            prctyp: '${_bsktScripList[0]["prctyp"]}',
            prd: '${_bsktScripList[0]["prd"]}',
            qty: '${_bsktScripList[0]["qty"]}',
            trantype: '${_bsktScripList[0]["trantype"]}',
            tsym: '${_bsktScripList[0]["tsym"]}',
            trgprc: '',
            rorgprc: '',
            rorgqty: '',
            blprc: '');
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
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "Order is Modified Sucessfully"));
      }
      if (_modifySipModel!.reqStatus == "NOT_OK") {
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "${_modifySipModel!.rejreason}"));
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

  placeBasketOrder(BuildContext context) async {
    try {
      for (var element in _bsktScripList) {
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
            prd: element['prd'],
            qty: element['qty'],
            ret: element['ret'],
            trailprc: '',
            trantype: element['trantype'],
            trgprc: element['trgprc'],
            tsym: element['tsym'],
            mktProt: element['mktProt'],
            channel: defaultTargetPlatform == TargetPlatform.android
                ? '${ref.read(authProvider).deviceInfo["brand"]}'
                : "${ref.read(authProvider).deviceInfo["model"]}");

        _placeOrderModel = await api.getPlaceOrder(placeOrderInput, _ip);

        if (_placeOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeOrderModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
          break;
        } else {
          ConstantName.sessCheck = true;
        }
      }
      ref.read(indexListProvider).bottomMenu(2, context);

      await fetchOrderBook(context, false);
      await changeTabIndex(0, context);
      ref.read(indexListProvider).bottomMenu(2, context);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, "Basket Order Sucessfully Placed"));
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Place Slice  Order", "Error": "$e"});
      notifyListeners();
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

        Navigator.pop(context);
        ref.read(indexListProvider).bottomMenu(2, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
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
