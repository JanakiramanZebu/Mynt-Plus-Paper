import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import 'package:intl/intl.dart';
import '../models/order_book_model/basket_model.dart';
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
  final Preferences pref = locator<Preferences>();
  List<TradeBookModel>? _tradeBook;
  List<TradeBookModel>? get tradeBook => _tradeBook;
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

  CancleSipOrder? _cancleSipOrder;
  CancleSipOrder? get cancleSipOrder => _cancleSipOrder;

  ModifySIPModel? _modifySipModel;
  ModifySIPModel? get modifySipModel => _modifySipModel;

  List<BasketModel> _basketName = [];
  List<BasketModel> get basketName => _basketName;

  Map _bsktScrips = {};
  Map get bsktScrips => _bsktScrips;

  String? bsketNameError;

  final TextEditingController orderSearchCtrl = TextEditingController();

  OrderProvider(this.ref);

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  List<Tab> _orderTabName = [];
  List<Tab> get orderTabName => _orderTabName;

  bool _showSearchOrder = false;
  bool get showSearchHold => _showSearchOrder;
  changeTabIndex(int index) {
    _selectedTab = index;

    // if (index == 4) {
    //   getBasketName();
    // }
  }

  String _selectedBsktName = "";
  String get selectedBsktName => _selectedBsktName;

  chngBsktName(String val) {
    _selectedBsktName = val;
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
      // Tab(text: "Basket Order (${pref.basketNameList!.length})"),
      Tab(text: "Trade Book (${_tradeBook == null ? 0 : _tradeBook!.length})"),
      Tab(
          text:
              "Alert (${ref(marketWatchProvider).alertPendingModel!.length})"),
      Tab(
          text:
              "SIP Order(${_siporderBookModel?.sipDetails?.length == null ? 0 : _siporderBookModel!.sipDetails!.length})"),
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

  clearOrderSearch() {
    orderSearchCtrl.clear();
    _orderSearchItem = [];

    notifyListeners();
  }

  orderSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _orderSearchItem = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _orderSearchItem = _allOrder!
          .where((element) => element.tsym!.toLowerCase().contains(value))
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

  Future fetchPlaceOrder(BuildContext context, PlaceOrderInput placeOrderInput,
      bool isExit) async {
    try {
      placeOrderInput.channel = defaultTargetPlatform == TargetPlatform.android
          ? '${ref(authProvider).deviceInfo["brand"]}'
          : "${ref(authProvider).deviceInfo["model"]}";
      placeOrderInput.userAgent =
          defaultTargetPlatform == TargetPlatform.android
              ? '${ref(authProvider).deviceInfo["model"]}'
              : "${ref(authProvider).deviceInfo["name"]}";
      placeOrderInput.appInstaId =
          defaultTargetPlatform == TargetPlatform.android
              ? '${ref(authProvider).deviceInfo["id"]}'
              : "${ref(authProvider).deviceInfo["identifierForVendor"]}";

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
        ref(indexListProvider).bottomMenu(3);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
        // ScaffoldMessenger.of(context).clearSnackBars();
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(successSnackBar("Order Placed"));

        // Navigator.pop(context);
        // Navigator.pushNamed(context, Routes.portfolioOrderbookScreen);
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
      placeOrderInput.userAgent =
          defaultTargetPlatform == TargetPlatform.android
              ? '${ref(authProvider).deviceInfo["model"]}'
              : "${ref(authProvider).deviceInfo["name"]}";
      placeOrderInput.appInstaId =
          defaultTargetPlatform == TargetPlatform.android
              ? '${ref(authProvider).deviceInfo["id"]}'
              : "${ref(authProvider).deviceInfo["identifierForVendor"]}";

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
    //
    try {
      toggleLoadingOn(true);
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
    String input = "";
    if (_orderBookModel != null) {
      if (_orderBookModel!.isNotEmpty && _orderBookModel![0].stat != "Not_Ok") {
        for (var i = 0; i < _orderBookModel!.length; i++) {
          input += "${_orderBookModel![i].exch}|${_orderBookModel![i].token}#";
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
          channelInput: input, task: isSubscribe ? "t" : "u", context: context);
    }
    // notifyListeners();
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
      } else if (sorting == "PCDESC") {
        _allOrder!.sort((a, b) {
          return double.parse(b.perChange ?? "0.00")
              .compareTo(double.parse(a.perChange ?? "0.00"));
        });
      } else {
        _allOrder!.sort((a, b) {
          return double.parse(a.perChange ?? "0.00")
              .compareTo(double.parse(b.perChange ?? "0.00"));
        });
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
      } else if (sorting == "PCDESC") {
        _openOrder!.sort((a, b) {
          return double.parse(b.perChange ?? "0.00")
              .compareTo(double.parse(a.perChange ?? "0.00"));
        });
      } else {
        _openOrder!.sort((a, b) {
          return double.parse(a.perChange ?? "0.00")
              .compareTo(double.parse(b.perChange ?? "0.00"));
        });
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
      } else if (sorting == "PCDESC") {
        _executedOrder!.sort((a, b) {
          return double.parse(b.perChange ?? "0.00")
              .compareTo(double.parse(a.perChange ?? "0.00"));
        });
      } else {
        _executedOrder!.sort((a, b) {
          return double.parse(a.perChange ?? "0.00")
              .compareTo(double.parse(b.perChange ?? "0.00"));
        });
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
        ref(indexListProvider).bottomMenu(3);
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
        ref(indexListProvider).bottomMenu(3);
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
        ref(indexListProvider).bottomMenu(3);
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
        ref(indexListProvider).bottomMenu(3);
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
    final now = DateTime.now();

    final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final inputDatetime = inputFormat.parse("$now");

    final outputFormat = DateFormat("dd MMM yyyy, hh:mm a");
    final formattedDatetime = outputFormat.format(inputDatetime);

    List<BasketModel> basketList = [
      BasketModel(
          basketname: val,
          createdDate: formattedDatetime,
          max: '20',
          curLength: '0')
    ];

    _basketName = await getLocalData();

    await setLocalData(_basketName, basketList);

    _basketName = await getLocalData();

    Navigator.pop(context);
    notifyListeners();
  }

  getBasketName() async {
    _basketName = await getLocalData();
    _bsktScrips = {};
    if (_basketName.isNotEmpty) {
      for (var element in _basketName) {
        _bsktScrips.addAll({element.basketname: []});
      }
      print("basket scrips ${_bsktScrips}");
    }
    notifyListeners();
  }

  Future<void> setLocalData(
      List<BasketModel> list, List<BasketModel> currentUser) async {
    List<BasketModel> uniqueList = [];
    list.add(currentUser[0]);

    Set<String> uniqueCombos = <String>{};
    for (var element in list.reversed) {
      String combo = element.basketname;

      if (!uniqueCombos.contains(combo)) {
        uniqueCombos.add(combo);
        uniqueList.add(element);
      }
    }

    final List<String> jsonList =
        uniqueList.map((obj) => obj.toJson()).toList();

    pref.setBasketNameList(jsonList);
  }

  Future<List<BasketModel>> getLocalData() async {
    List<String>? jsonList = pref.basketNameList;

    if (jsonList != null) {
      return jsonList
          .map((jsonString) => BasketModel.fromJson(jsonString))
          .toList();
    } else {
      return [];
    }
  }

  fetchSipPlaceOrder(BuildContext context, SipInputField sipOrderInput) async {
    try {
      toggleLoadingOn(true);
      _sipPlaceOrder = await api.getPlaceSipOrder(sipOrderInput);
      if (_sipPlaceOrder!.reqStatus == "OK") {
        changeTabIndex(6);
        ref(indexListProvider).bottomMenu(3);
        fetchSipOrderHistory();
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
        fetchSipOrderHistory();
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

  Future fetchSipOrderHistory() async {
    try {
      _siporderBookModel = await api.getSipOrderBook();
      tabSize();
      List ltpArgs = [];
      if (_siporderBookModel!.sipDetails!.isNotEmpty) {
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
            } else {
              siporderBookModel!.sipDetails!.isEmpty;
              ConstantName.sessCheck = false;
            }
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
      await fetchSipOrderHistory();
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
}
