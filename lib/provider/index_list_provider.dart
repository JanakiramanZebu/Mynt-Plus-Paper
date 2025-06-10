import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mynt_plus/provider/stocks_provider.dart';
import 'package:mynt_plus/provider/user_profile_provider.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/marketwatch_model/add_delete_scrip_model.dart';
import '../models/indices/all_index_model.dart';
import '../models/indices/index_list_model.dart';
import '../models/indices/index_order_model.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'market_watch_provider.dart';
import 'thems.dart';

final indexListProvider =
    ChangeNotifierProvider((ref) => IndexListProvider(ref));

class IndexListProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;
  IndexListProvider(this.ref);

  bool _isActiveTsym = false;
  bool get isActiveTsym => _isActiveTsym;
  IndexListModel? _defaultIndexList;
  IndexListModel? get defaultIndexList => _defaultIndexList;
  IndexListModel? _defTopIndex;
  IndexListModel? get defTopIndex => _defTopIndex;

  IndexListModel? _indexList;
  IndexListModel? get indexList => _indexList;

  List<IndexValue> _nseIndex = [];
  List<IndexValue> get nseIndex => _nseIndex;
  List<IndexValue> _bseIndex = [];
  List<IndexValue> get bseIndex => _bseIndex;
  List<IndexValue> _mcxIndex = [];
  List<IndexValue> get mCXIndex => _mcxIndex;

  List<IndexValue> _indIndex = [];
  List<IndexValue> get indIndex => _indIndex;

  AllIndexModel? _allIndexModel;
  AllIndexModel? get allIndexModel => _allIndexModel;

  int _selectedBtmIndx = 1;
  int get selectedBtmIndx => _selectedBtmIndx;
  List<String> indexExch = ["NSE", "MCX", "BSE"];
  List<IndexValue> _indValuesList = [];
  List<IndexValue> get indValuesList => _indValuesList;
  String _selectedExch = "NSE";
  String get slectedExch => _selectedExch;

  final String _indexSubToken = "";
  String get indexSubToken => _indexSubToken;

  AddDeleteScripModel? _checkSess;
  AddDeleteScripModel? get checkSess => _checkSess;

  final List _logError = [];
  List get logError => _logError;

  String _selectedIndExch = "NSE";

  String get selectedIndExch => _selectedIndExch;

  final FToast _fToast = FToast();
  FToast get fToast => _fToast;

  String _indexToken = "";
  String get indexToken => _indexToken;

  String _subscr = "";

  // More menus

  final List _moreMunus = [
    {'title': "IPO", "subTitle": "Main stream, SME IPO", "logo": ""},
    {'title': "Bonds", "subTitle": "Bonds", "logo": ""},
    {'title': "Mutual fund", "subTitle": "Funds", "logo": ""}
  ];

  List get moreMenu => _moreMunus;

  // void checkActiveTsym(bool value) {
  //   _isActiveTsym = value;
  //   notifyListeners();
  // }

// Change bottom tab menu

  bottomMenu(int value, BuildContext context) {
    // Store previous index to handle transitions correctly
    final int previousIndex = _selectedBtmIndx;
    _selectedBtmIndx = value;

    // Handle WebSocket subscriptions based on tab changes
    if (value == 0) {
      // Dashboard tab
      ref
          .read(stocksProvide)
          .requestWSTradeaction(isSubscribe: true, context: context);
      if (previousIndex == 1) {
        ref
            .read(marketWatchProvider)
            .requestMWScrip(context: context, isSubscribe: false);
      }
    } else if (value == 1) {
      // Watchlist tab
      ref
          .read(stocksProvide)
          .requestWSTradeaction(isSubscribe: false, context: context);
      ref
          .read(marketWatchProvider)
          .requestMWScrip(context: context, isSubscribe: true);
    } else {
      // For other tabs, unsubscribe from market watch
      ref
          .read(stocksProvide)
          .requestWSTradeaction(isSubscribe: false, context: context);
      if (previousIndex == 1) {
        ref
            .read(marketWatchProvider)
            .requestMWScrip(context: context, isSubscribe: false);
      }
    }

    // Ensure data is properly refreshed when switching to profile tab
    if (value == 4 && previousIndex != 4) {
      ref.read(userProfileProvider).fetchprofilemenu();
    }

    notifyListeners();
  }

// Set height for dropdown list items

  List<double> getCustomItemsHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (indexExch.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

// Add Divider for dropdown list items
  List<DropdownMenuItem<String>> addDividersAfterExpDates() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in indexExch) {
      menuItems.addAll([
        DropdownMenuItem<String>(
            value: item.toString(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Text(item.toString()))),
        //If it's last item, we will not add Divider after it.
        if (item != indexExch.last)
          DropdownMenuItem<String>(
              enabled: false,
              child: Divider(
                  color: ref.read(themeProvider).isDarkMode
                      ? colors.colorbluegrey
                      : colors.colorDivider))
      ]);
    }
    return menuItems;
  }

// Fetching data from the api and stored in a variable
  Future fetchIndexList(String exch, BuildContext context) async {
    try {
      if (_subscr.isNotEmpty) {
        ref.read(websocketProvider).establishConnection(
            channelInput: _subscr, task: 'u', context: context);
        _subscr = "";
      }
      if (exch != "exit") {
        _indValuesList = [];
        toggleLoad(true);
        // for (var i = 0; i < indexExch.length; i++) {
        _selectedExch = exch;

        _indexList = await api.getIndexList(exch);
        final localstorage = await SharedPreferences.getInstance();

        if (_indexList!.stat != "Not_Ok" || _indexList!.stat != null) {
          ConstantName.sessCheck = true;
          _indValuesList = _indexList!.indValues!;
          if (_subscr.isNotEmpty) {
            ref.read(websocketProvider).establishConnection(
                channelInput: _subscr, task: 'u', context: context);
          }
          for (var n = 0; n < _indValuesList.length; n++) {
            _indValuesList[n].exch = _selectedExch;

            if (_defaultIndexList!.indValues![0].token !=
                    _indValuesList[n].token &&
                _defaultIndexList!.indValues![1].token !=
                    _indValuesList[n].token &&
                _defaultIndexList!.indValues![2].token !=
                    _indValuesList[n].token &&
                _defaultIndexList!.indValues![3].token !=
                    _indValuesList[n].token) {
              _subscr +=
                  "${_indValuesList[n].exch}|${_indValuesList[n].token}#";
            }
          }
          if (_subscr.isNotEmpty) {
            ref.read(websocketProvider).establishConnection(
                channelInput: _subscr, task: 't', context: context);
          }
        } else {
          if (_indexList!.emsg == "Session Expired :  Invalid Session Key" &&
              _indexList!.stat == "Not_Ok") {
            pref.clearClientSession();
            ConstantName.sessCheck = false;
            ref.read(authProvider).loginMethCtrl.text =
                localstorage.getString("userId") ?? "";
            ConstantName.timer!.cancel();
            ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
                _indexList!.emsg!.replaceAll("Invalid Input :", "* ")));

            Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                arguments: "login",
                (route) => false);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      _logError.add({"type": "API Index", "Error": "$e"});
      notifyListeners();
      log("Failed to Index List Data:: ${e.toString()}");
    } finally {
      toggleLoad(false);
    }
  }

// Defalut index list
  Future getDeafultIndexList(BuildContext context) async {
    final localstorage = await SharedPreferences.getInstance();
    try {
      Map data = {
        "values": [
          {"idxname": "Nifty 50", "token": "26000", "exch": "NSE"},
          {"idxname": "Bank Nifty", "token": "26009", "exch": "NSE"},
          {"idxname": "Sensex", "token": "1", "exch": "BSE"},
          {"idxname": "India VIX", "token": "26017", "exch": "NSE"}
        ]
      };

      final resp = IndexListModel.fromJson(
          jsonDecode(jsonEncode(data)) as Map<String, dynamic>);

      _defaultIndexList = resp;
      if (localstorage.getStringList("marketIndex") == null) {
        localstorage.setStringList(
            "marketIndex",
            _defaultIndexList!.indValues!
                .map((e) => IndexListOrder(
                        index: _defaultIndexList!.indValues!.indexOf(e),
                        idxname: e.idxname!,
                        token: e.token!,
                        exch: e.exch!)
                    .toString())
                .toList());
      }

      await getIndeexListFromLocal(context);
    } catch (e) {
      _logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
      log("Failed to load defaut Index Data:: ${e.toString()}");
    }
  }

  Future fetchStockTopIndex() async {
    try {
      toggleLoadingOn(true);
      Map data = {
        "values": [
          {"idxname": "Nifty 50", "token": "26000", "exch": "NSE"},
          {"idxname": "Nifty Bank", "token": "26009", "exch": "NSE"},
          {"idxname": "Sensex", "token": "1", "exch": "BSE"},
          {"idxname": "India VIX", "token": "26017", "exch": "NSE"},
          {"idxname": "Nifty Fin Service", "token": "26037", "exch": "NSE"}
        ]
      };

      final resp = IndexListModel.fromJson(
          jsonDecode(jsonEncode(data)) as Map<String, dynamic>);

      _defTopIndex = resp;

      List ltpArgs = [];

      for (var element in _defTopIndex!.indValues!) {
        ltpArgs.add({"exch": "${element.exch}", "token": "${element.token}"});
      }

      final response = await api.getLTP(ltpArgs);

      Map res = jsonDecode(response.body);

      for (var element in _defTopIndex!.indValues!) {
        if (element.token.toString() ==
            "${res["data"]["${element.token}"]['token']}") {
          element.ltp = "${res["data"]["${element.token}"]["lp"]}";

          element.close = "${res["data"]["${element.token}"]["close"]}";

          element.perChange = "${res["data"]["${element.token}"]["change"]}";

          element.change = (double.parse(
                      "${element.ltp == "0" ? element.close : element.ltp}") -
                  double.parse("${element.close}"))
              .toStringAsFixed(2);
        }
      }

      notifyListeners();
    } catch (e) {
      log("$e");
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

// Fetch All index from kamabala using wrapper API

  fetchAllIndex() async {
    try {
      _allIndexModel = await api.getAllIndex();

      if (_allIndexModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        List ltpArgs = [];

        _nseIndex = _allIndexModel!.nSE!;
        _bseIndex = _allIndexModel!.bSE!;
        _mcxIndex = _allIndexModel!.mCX!;

        for (var element in _nseIndex) {
          element.exch = "NSE";
          ltpArgs.add({"exch": "NSE", "token": "${element.token}"});
        }

        for (var element in _bseIndex) {
          element.exch = "BSE";
          ltpArgs.add({"exch": "BSE", "token": "${element.token}"});
        }
        for (var element in _mcxIndex) {
          element.exch = "MCX";
          ltpArgs.add({"exch": "MCX", "token": "${element.token}"});
        }

        final response = await api.getLTP(ltpArgs);

        Map res = jsonDecode(response.body);

        for (var element in _nseIndex) {
          if (element.token.toString() ==
              "${res["data"]["${element.token}"]['token']}") {
            element.ltp = "${res["data"]["${element.token}"]["lp"]}";

            element.close = "${res["data"]["${element.token}"]["close"]}";

            element.perChange = "${res["data"]["${element.token}"]["change"]}";

            element.change = (double.parse(
                        "${element.ltp == "0" ? element.close : element.ltp}") -
                    double.parse("${element.close}"))
                .toStringAsFixed(2);
          }
        }
        for (var element in _bseIndex) {
          if (element.token.toString() ==
              "${res["data"]["${element.token}"]['token']}") {
            element.ltp = "${res["data"]["${element.token}"]["lp"]}";

            element.close = "${res["data"]["${element.token}"]["close"]}";

            element.perChange = "${res["data"]["${element.token}"]["change"]}";

            element.change = (double.parse(
                        "${element.ltp == "0" ? element.close : element.ltp}") -
                    double.parse("${element.close}"))
                .toStringAsFixed(2);
          }
        }
        for (var element in _mcxIndex) {
          if (element.token.toString() ==
              "${res["data"]["${element.token}"]['token']}") {
            element.ltp = "${res["data"]["${element.token}"]["lp"]}";

            element.close = "${res["data"]["${element.token}"]["close"]}";

            element.perChange = "${res["data"]["${element.token}"]["change"]}";

            element.change = (double.parse(
                        "${element.ltp == "0" ? element.close : element.ltp}") -
                    double.parse("${element.close}"))
                .toStringAsFixed(2);
          }
        }
        getchngIndexData(_selectedIndExch);
      } else {
        ConstantName.sessCheck = false;
      }

      notifyListeners();
    } catch (e) {
      log("$e");
    } finally {}
  }

// Get Index data by Exchange

  getchngIndexData(String exch) {
    _selectedIndExch = exch;
    if (exch == "NSE") {
      _indIndex = _nseIndex;
    } else if (exch == "BSE") {
      _indIndex = _bseIndex;
    } else {
      _indIndex = _mcxIndex;
    }
    notifyListeners();
  }

// Modify Default Index list and store in local

  changeIndex(
      IndexValue addNewIndex, BuildContext context, dynamic index) async {
    final localstorage = await SharedPreferences.getInstance();

    if (index == 0) {
      _defaultIndexList!.indValues!.removeAt(0);
      _defaultIndexList!.indValues!.insert(0, addNewIndex);
    } else if (index == 1) {
      _defaultIndexList!.indValues!.removeAt(1);
      _defaultIndexList!.indValues!.insert(1, addNewIndex);
    } else if (index == 2) {
      _defaultIndexList!.indValues!.removeAt(2);
      _defaultIndexList!.indValues!.insert(2, addNewIndex);
    } else {
      _defaultIndexList!.indValues!.removeAt(3);
      _defaultIndexList!.indValues!.insert(3, addNewIndex);
    }

    localstorage.setStringList(
        "marketIndex",
        _defaultIndexList!.indValues!
            .map((e) => IndexListOrder(
                    index: _defaultIndexList!.indValues!.indexOf(e),
                    idxname: e.idxname!,
                    token: e.token!,
                    exch: e.exch!)
                .toString())
            .toList());
    notifyListeners();

    await getIndeexListFromLocal(context);

    ref
        .read(marketWatchProvider)
        .requestMWScrip(isSubscribe: true, context: context);
    ScaffoldMessenger.of(context)
        .showSnackBar(successMessage(context, "Index scrip modified"));
  }

// Retrieve from locally stored index data

  Future getIndeexListFromLocal(BuildContext context) async {
    final localstorage = await SharedPreferences.getInstance();
    final List<String> indexList =
        localstorage.getStringList("marketIndex") ?? [];
    if (indexList.isNotEmpty) {
      final List<IndexValue> list = [..._defaultIndexList!.indValues ?? []];

      _indexToken = "";
      for (var e in indexList) {
        int index = int.parse(e.split(":").first);
        final splitted = e.split(":");
        list[index].idxname = splitted[1];
        list[index].token = splitted[2];
        list[index].exch = splitted[3];
      }
      _defaultIndexList!.indValues = list;
    }

    await requestdefaultIndex();
    notifyListeners();

    //
  }

// websocket Connection Request for default index list
  requestdefaultIndex() {
    _indexToken = "";
    if (_defaultIndexList != null) {
      if (_defaultIndexList!.indValues!.isNotEmpty) {
        for (var element in _defaultIndexList!.indValues!) {
          _indexToken += "${element.exch}|${element.token}#";
        }
      }
    }
    // notifyListeners();
  }

// Verifying the client's session each time
  checkSession(BuildContext context) async {
    try {
      // Don't show loading indicator for session checks - this causes visible UI lag
      bool wasLoadingOn = loading;
      if (wasLoadingOn) {
        toggleLoadingOn(false);
      }

      _checkSess = await api.getAddDeleteSciptoMW(
          isAdd: false, scripToken: "", wlname: "");

      if (_checkSess?.stat == null ||
          (_checkSess!.emsg == "Session Expired :  Invalid Session Key" &&
              _checkSess!.stat == "Not_Ok")) {
        // Directly call ifSessionExpired without waiting, as it handles cleanup
        ref.read(authProvider).ifSessionExpired(context);
        return;
      } else {
        _checkSess!.stat = "Ok";
      }

      // Only restore loading state if it was on before
      if (wasLoadingOn) {
        toggleLoadingOn(true);
      }

      notifyListeners();
    } catch (e) {
      // In case of any error, assume session is invalid
      // ref.read(authProvider).ifSessionExpired(context);
    }
  }

// Push Notification call
  fetchNotifyMsg() async {
    try {
      await api.getNotifyMsg();
    } catch (e) {
      print("   $e");
    }
  }
}
