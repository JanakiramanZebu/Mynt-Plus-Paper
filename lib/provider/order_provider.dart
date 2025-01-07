import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

final orderProvider = ChangeNotifierProvider((ref) => OrderProvider(ref.read));

class OrderProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final FToast _fToast = FToast();
  FToast get fToast => _fToast;
  final Reader ref;
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
  List<OrderBookModel>? _orderBookModel;
  List<OrderBookModel>? get orderBookModel => _orderBookModel;
  List<GttOrderBookModel>? _gttOrderBookModel = [];
  List<GttOrderBookModel>? get gttOrderBookModel => _gttOrderBookModel;
  List<GttOrderBookModel>? _gttOrderBookSearch = [];
  List<GttOrderBookModel>? get gttOrderBookSearch => _gttOrderBookSearch;
  final Preferences pref = locator<Preferences>();
  List<TradeBookModel>? _tradeBook;
  List<TradeBookModel>? get tradeBook => _tradeBook;
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

  String _selectedBsktName = "";
  String get selectedBsktName => _selectedBsktName;

// Change tab orderbook tab index

  changeTabIndex(int index, BuildContext context) {
    _selectedTab = index;
    tabSize();
    showOrderSearch(false);
    showGTTOrderSearch(false);
    ref(marketWatchProvider).showAlertPendingSearch(false);
    showSipSearch(false);
    ref(marketWatchProvider).clearAlertSearch();
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

// Change Basket name
  chngBsktName(String val, BuildContext context) async {
    _selectedBsktName = val;

    _bsktScrips = pref.bsktScrips!.isEmpty ? {} : jsonDecode(pref.bsktScrips!);

    _bsktScripList = _bsktScrips[val] ?? [];

    if (_bsktScripList.isNotEmpty) {
      String input = "";
      for (var i = 0; i < _bsktScripList.length; i++) {
        input += "${_bsktScripList[i]['exch']}|${_bsktScripList[i]['token']}#";
      }
      if (input.isNotEmpty) {
        ref(websocketProvider).establishConnection(
            channelInput: input, task: "t", context: context);
      }
    }

    await fetchBasketMargin();

    Navigator.pushNamed(context, Routes.bsktScripList, arguments: val);
    notifyListeners();
  }

  tabSize() {
    _orderTabName = [
      Tab(text: "All (${_allOrder!.length})"),
      Tab(text: "Open (${_openOrder!.length})"),
      Tab(text: "Executed (${_executedOrder!.length})"),
      Tab(
          text:
              "GTT Order (${_gttOrderBookModel == null ? 0 : _gttOrderBookModel!.length})"),
      Tab(text: "Basket Order (${_bsktList.length})"),
      Tab(text: "Trade Book (${_tradeBook == null ? 0 : _tradeBook!.length})"),
      Tab(
          text:
              "Alert (${ref(marketWatchProvider).alertPendingModel!.length})"),
      Tab(
          text:
              "SIP Order(${_siporderBookModel?.sipDetails?.length == null ? 0 : _siporderBookModel!.sipDetails!.length})")
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

  orderSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _orderSearchItem = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _orderSearchItem = _allOrder!
          .where((element) =>
              element.tsym!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_orderSearchItem!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _orderSearchItem = [];
    }

    notifyListeners();
  }

  orderGttSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _gttOrderBookSearch = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _gttOrderBookSearch = _gttOrderBookModel!
          .where((element) =>
              element.tsym!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_gttOrderBookSearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _gttOrderBookSearch = [];
    }

    notifyListeners();
  }

  orderSipSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _siporderBookSearch = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _siporderBookSearch = _siporderBookModel!.sipDetails!
          .where((element) =>
              element.sipName!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_siporderBookSearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _siporderBookSearch = [];
    }

    notifyListeners();
  }

  orderTradeBookSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _tradeBooksearch = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _tradeBooksearch = _tradeBook!
          .where((element) =>
              element.tsym!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_tradeBooksearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
          ? '${ref(authProvider).deviceInfo["brand"]}'
          : "${ref(authProvider).deviceInfo["model"]}";

      _placeOrderModel = await api.getPlaceOrder(placeOrderInput);

      if (_placeOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        _orderBookModel = await fetchOrderBook(context, true);
        if (_orderBookModel!.isNotEmpty) {
          if (_orderBookModel![0].stat != "Not_Ok") {
            ConstantName.sessCheck = true;
            for (var element in _orderBookModel!) {
              if (element.norenordno == _placeOrderModel!.norenordno) {
                ScaffoldMessenger.of(context).showSnackBar(successMessage(
                    context,
                    "Your ${element.trantype == "B" ? "buy" : "sell"} order ${element.norenordno} for ${element.tsym} in ${element.exch} is ${element.status}"));
              }
            }
            notifyListeners();
          } else {
            if (_orderBookModel![0].emsg ==
                    "Session Expired :  Invalid Session Key" &&
                _orderBookModel![0].stat == "Not_Ok") {
              ref(authProvider).ifSessionExpired(context);
            }
          }
        }

        if (!isExit) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
        ref(indexListProvider).bottomMenu(3, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        if (_placeOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeOrderModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "${_placeOrderModel!.emsg}"));
        }
      }

      return _placeOrderModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Place Order", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future slicePlaceOrder(
      BuildContext context, PlaceOrderInput placeOrderInput) async {
    try {
      placeOrderInput.channel = defaultTargetPlatform == TargetPlatform.android
          ? '${ref(authProvider).deviceInfo["brand"]}'
          : "${ref(authProvider).deviceInfo["model"]}";

      _placeOrderModel = await api.getPlaceOrder(placeOrderInput);

      if (_placeOrderModel!.emsg == "Session Expired :  Invalid Session Key" &&
          _placeOrderModel!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      return _placeOrderModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Place Slice  Order", "Error": "$e"});
      notifyListeners();
    }
  }

  Future fetchOrderBook(context, bool websocCon) async {
    try {
      toggleLoadingOn(true);
      pref.setOBScrip(true);
      pref.setOBPrice(true);
      pref.setOBtime(true);
      pref.setOBqty(true);
      pref.setOBproduct(true);
      _executedOrder = [];
      _openOrder = [];
      _allOrder = [];
      _orderBookModel = [];

      _orderBookModel = await api.getOrderBook();

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

          notifyListeners();

          if (websocCon) {
            requestWSOrderBook(isSubscribe: true, context: context);
          }
          tabSize();
        } else {
          if (_orderBookModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _orderBookModel![0].stat == "Not_Ok") {
            ref(authProvider).ifSessionExpired(context);
          }
        }
      }
      return _orderBookModel;
    } catch (e) {
      ref(indexListProvider)
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
      _tradeBook = [];
      _tradeBook = await api.getTradeBook();
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
          ref(authProvider).ifSessionExpired(context);
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
      ref(indexListProvider)
          .logError
          .add({"type": "API Trade Book", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchGTTOrderBook(context, String initLoad) async {
    try {
      _gttOrderBookModel = [];
      _gttOrderBookModel = await api.getGTTOrderBook();
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
          ref(authProvider).ifSessionExpired(context);
        }

        if (_gttOrderBookModel![0].stat == "Not_Ok") {
          _gttOrderBookModel = [];
        }
      }
      tabSize();
      notifyListeners();

      return _gttOrderBookModel;
    } catch (e) {
      print("GTT Order book $e");
      ref(indexListProvider)
          .logError
          .add({"type": "API GTT Order Book", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchOrderHistory(String orderNum, BuildContext context) async {
    try {
      _orderHistoryModel = await api.getOrderHistory(orderNum);
      print("${_orderHistoryModel[0].stat}");
      if (_orderHistoryModel[0].stat == "Not_Ok" &&
          _orderHistoryModel[0].emsg ==
              "Session Expired :  Invalid Session Key") {
        ref(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      notifyListeners();

      return _orderHistoryModel;
    } catch (e) {
      ref(indexListProvider)
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

  Future fetchOrderCancel(String orderNum, context) async {
    try {
      _cancelOrderModel = await api.getCancelOrder(orderNum);
      if (_cancelOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        await fetchOrderBook(context, true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, 'Order Cancelled'));

        Navigator.pop(context);
      } else {
        ref(authProvider).ifSessionExpired(context);
      }

      return _cancelOrderModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Order Canl", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchExitSNOOrd(String snoOrdNum, String prd, context) async {
    try {
      _cancelOrderModel = await api.getExitSNOOrder(snoOrdNum, prd);
      if (_cancelOrderModel!.stat == "Ok" &&
          _cancelOrderModel!.dmsg == "success") {
        ConstantName.sessCheck = true;
        await fetchOrderBook(context, true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, 'Order Exited'));
        Navigator.pop(context);
      } else {
        ref(authProvider).ifSessionExpired(context);
      }

      return _cancelOrderModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Order Canl", "Error": "$e"});
      notifyListeners();
    }
  }

  Future fetchModifyOrder(ModifyOrderInput input, context) async {
    try {
      _modifyOrderModel = await api.getModifyOrder(input);
      if (_modifyOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        await fetchOrderBook(context, true);

        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, 'Order Modified'));
        Navigator.pop(context);
      } else {
        if (_modifyOrderModel!.emsg ==
            "Session Expired :  Invalid Session Key") {
          ref(authProvider).ifSessionExpired(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, '${_modifyOrderModel!.emsg}'));
        }
      }
      notifyListeners();
      return _modifyOrderModel;
    } catch (e) {
      ref(indexListProvider)
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
        ref(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      notifyListeners();
      return _orderMarginModel;
    } catch (e) {
      ref(indexListProvider)
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
        ref(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }

      notifyListeners();
      return _getBrokerageModel;
    } catch (e) {
      ref(indexListProvider)
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
          for (var i = 0; i < _orderBookModel!.length; i++) {
            input +=
                "${_orderBookModel![i].exch}|${_orderBookModel![i].token}#";
          }
        }
      }

      if (_gttOrderBookModel!.isNotEmpty) {
        for (var element in _gttOrderBookModel!) {
          input += "${element.exch}|${element.token}#";
        }
      }

      if (input.isNotEmpty) {
        // ConstantName.lastSubscribe = input;
        ref(websocketProvider).establishConnection(
            channelInput: input,
            task: isSubscribe ? "t" : "u",
            context: context);
      }
    } catch (e) {
    } finally {
      toggleLoadingOn(false);
    }

    // notifyListeners();
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

  filterOrders({required String sorting}) async {
    if (_selectedTab == 0) {
      if (sorting == "ASC") {
        _allOrder!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
      } else if (sorting == "DSC") {
        _allOrder!.sort((a, b) => b.tsym!.compareTo(a.tsym!));
      } else if (sorting == "LTPDSC") {
        _allOrder!.sort((a, b) {
          return double.parse(b.ltp ?? "0.00")
              .compareTo(double.parse(a.ltp ?? "0.00"));
        });
      } else if (sorting == "LTPASC") {
        _allOrder!.sort((a, b) {
          return double.parse(a.ltp ?? "0.00")
              .compareTo(double.parse(b.ltp ?? "0.00"));
        });
      } else if (sorting == "QTYDSC") {
        _allOrder!.sort((a, b) {
          return int.parse(b.qty ?? "0").compareTo(int.parse(a.qty ?? "0"));
        });
      } else if (sorting == "QTYASC") {
        _allOrder!.sort((a, b) {
          return int.parse(a.qty ?? "0").compareTo(int.parse(b.qty ?? "0"));
        });
      } else if (sorting == "PRODUCTASC") {
        _allOrder!.sort((a, b) => a.sPrdtAli!.compareTo(b.sPrdtAli!));
      } else if (sorting == "PRODUCTDSC") {
        _allOrder!.sort((a, b) => b.sPrdtAli!.compareTo(a.sPrdtAli!));
      } else if (sorting == "TIMEDSC") {
        _allOrder!.sort((a, b) => b.norentm!.compareTo(a.norentm!));
      } else if (sorting == "TIMEASC") {
        _allOrder!.sort((a, b) => a.norentm!.compareTo(b.norentm!));
      }
    } else if (_selectedTab == 1) {
      if (sorting == "ASC") {
        _openOrder!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
      } else if (sorting == "DSC") {
        _openOrder!.sort((a, b) => b.tsym!.compareTo(a.tsym!));
      } else if (sorting == "LTPDSC") {
        _openOrder!.sort((a, b) {
          return double.parse(b.ltp ?? "0.00")
              .compareTo(double.parse(a.ltp ?? "0.00"));
        });
      } else if (sorting == "LTPASC") {
        _openOrder!.sort((a, b) {
          return double.parse(a.ltp ?? "0.00")
              .compareTo(double.parse(b.ltp ?? "0.00"));
        });
      } else if (sorting == "QTYDSC") {
        _openOrder!.sort((a, b) {
          return int.parse(b.qty ?? "0").compareTo(int.parse(a.qty ?? "0"));
        });
      } else if (sorting == "QTYASC") {
        _openOrder!.sort((a, b) {
          return int.parse(a.qty ?? "0").compareTo(int.parse(b.qty ?? "0"));
        });
      } else if (sorting == "PRODUCTASC") {
        _openOrder!.sort((a, b) => a.sPrdtAli!.compareTo(b.sPrdtAli!));
      } else if (sorting == "PRODUCTDSC") {
        _openOrder!.sort((a, b) => b.sPrdtAli!.compareTo(a.sPrdtAli!));
      } else if (sorting == "TIMEDSC") {
        _openOrder!.sort((a, b) => b.norentm!.compareTo(a.norentm!));
      } else if (sorting == "TIMEASC") {
        _openOrder!.sort((a, b) => a.norentm!.compareTo(b.norentm!));
      }
    } else if (_selectedTab == 2) {
      if (sorting == "ASC") {
        _executedOrder!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
      } else if (sorting == "DSC") {
        _executedOrder!.sort((a, b) => b.tsym!.compareTo(a.tsym!));
      } else if (sorting == "LTPDSC") {
        _executedOrder!.sort((a, b) {
          return double.parse(b.ltp ?? "0.00")
              .compareTo(double.parse(a.ltp ?? "0.00"));
        });
      } else if (sorting == "LTPASC") {
        _executedOrder!.sort((a, b) {
          return double.parse(a.ltp ?? "0.00")
              .compareTo(double.parse(b.ltp ?? "0.00"));
        });
      } else if (sorting == "QTYDSC") {
        _executedOrder!.sort((a, b) {
          return int.parse(b.qty ?? "0").compareTo(int.parse(a.qty ?? "0"));
        });
      } else if (sorting == "QTYASC") {
        _executedOrder!.sort((a, b) {
          return int.parse(a.qty ?? "0").compareTo(int.parse(b.qty ?? "0"));
        });
      } else if (sorting == "PRODUCTASC") {
        _executedOrder!.sort((a, b) => a.sPrdtAli!.compareTo(b.sPrdtAli!));
      } else if (sorting == "PRODUCTDSC") {
        _executedOrder!.sort((a, b) => b.sPrdtAli!.compareTo(a.sPrdtAli!));
      } else if (sorting == "TIMEDSC") {
        _executedOrder!.sort((a, b) => b.norentm!.compareTo(a.norentm!));
      } else if (sorting == "TIMEASC") {
        _executedOrder!.sort((a, b) => a.norentm!.compareTo(b.norentm!));
      }
    }
    {}

    notifyListeners();
  }

  fetchGttPlaceOrder(PlaceGTTOrderInput input, BuildContext context) async {
    try {
      _placeGttOrderModel = await api.getPlaceGTTOrder(input);

      if (_placeGttOrderModel!.stat == "OI created") {
        ConstantName.sessCheck = true;
        ref(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        Navigator.pop(context);
        ref(indexListProvider).bottomMenu(3, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API GTT Order ", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  fetchModifyGTTOrder(PlaceGTTOrderInput input, BuildContext context) async {
    try {
      _modifyGttOrderModel = await api.getModifyGTTOrder(input);

      if (_modifyGttOrderModel!.stat == "OI replaced") {
        ConstantName.sessCheck = true;
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Modified Order"));
        ref(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        Navigator.pop(context);
        ref(indexListProvider).bottomMenu(3, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        if (_modifyGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _modifyGttOrderModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Modify GTT Order ", "Error": "$e"});
      notifyListeners();
    }
  }

  fetchGttCancelOrder(String canId, BuildContext context) async {
    try {
      _placeGttOrderModel = await api.getCancelGTTorder(canId);

      if (_placeGttOrderModel!.stat == "OI deleted") {
        await fetchGTTOrderBook(context, "");
        ConstantName.sessCheck = true;

        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API GTT Order  CANCEL", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  fetchOCOPlaceOrder(PlaceOcoOrderInput input, BuildContext context) async {
    try {
      _placeGttOrderModel = await api.getPlaceOcoOrder(input);

      if (_placeGttOrderModel!.stat == "OI created") {
        ConstantName.sessCheck = true;
        ref(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        Navigator.pop(context);
        ref(indexListProvider).bottomMenu(3, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        if (_placeGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeGttOrderModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API OCO Order ", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  fetchOCOModifyOrder(PlaceOcoOrderInput input, BuildContext context) async {
    try {
      _modifyGttOrderModel = await api.getModifyOcoOrder(input);

      if (_modifyGttOrderModel!.stat == "OI replaced") {
        ConstantName.sessCheck = true;
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Modified Order"));
        ref(ordInputProvider).clearTextField();
        await fetchGTTOrderBook(context, "");

        Navigator.pop(context);
        ref(indexListProvider).bottomMenu(3, context);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        if (_modifyGttOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _modifyGttOrderModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
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
        changeTabIndex(7, context);
        ref(indexListProvider).bottomMenu(3, context);
        fetchSipOrderHistory(context);
        tabSize();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "Order is Placed Sucessfully"));
        notifyListeners();
      } else if (_sipPlaceOrder!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
    } catch (e) {
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
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
        ref(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _modifySipModel;
    } catch (e) {
      ref(indexListProvider)
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
            ref(authProvider).ifSessionExpired(context);
          }
        }
      }
      notifyListeners();
      return _siporderBookModel;
    } catch (e) {
      ref(indexListProvider)
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
        ref(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _cancleSipOrder;
    } catch (e) {
      ref(indexListProvider)
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
                ? '${ref(authProvider).deviceInfo["brand"]}'
                : "${ref(authProvider).deviceInfo["model"]}");

        _placeOrderModel = await api.getPlaceOrder(placeOrderInput);

        if (_placeOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeOrderModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
          break;
        } else {
          ConstantName.sessCheck = true;
        }
      }
      ref(indexListProvider).bottomMenu(2, context);

      await fetchOrderBook(context, false);
      await changeTabIndex(0, context);
      ref(indexListProvider).bottomMenu(3, context);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, "Basket Order Sucessfully Placed"));
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Place Slice  Order", "Error": "$e"});
      notifyListeners();
    }
  }
}
