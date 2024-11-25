import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/order_book_model/place_order_model.dart';
import '../models/portfolio_model/holdings_model.dart';
import '../models/portfolio_model/mf_holdings_model.dart';
import '../models/portfolio_model/mf_quotes.dart';
import '../models/portfolio_model/position_book_model.dart';
import '../models/portfolio_model/position_convertion_model.dart';

import '../models/portfolio_model/position_group_model.dart';
import '../res/res.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

import 'websocket_provider.dart';

final portfolioProvider =
    ChangeNotifierProvider((ref) => PortfolioProvider(ref.read));

class PortfolioProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final FToast _fToast = FToast();
  FToast get fToast => _fToast;
  final Reader ref;
  late TabController portTab;
  final TextEditingController holdingSearchCtrl = TextEditingController();
  final TextEditingController holdingMFSearchCtrl = TextEditingController();
  final TextEditingController positionSearchCtrl = TextEditingController();
  List<HoldingsModel>? _holdingsModel = [];
  List<HoldingsModel>? get holdingsModel => _holdingsModel;

  List<HoldingsModel>? _holdingSearchItem = [];
  List<HoldingsModel>? get holdingSearchItem => _holdingSearchItem;
  List<HoldingsModel> _sealableHoldings = [];
  List<HoldingsModel> get sealableHoldings => _sealableHoldings;
  List<HoldingsModel> _nonSealableHoldings = [];
  List<HoldingsModel> get nonSealableHoldings => _nonSealableHoldings;

  List<PositionBookModel>? _postionBookModel = [];
  List<PositionBookModel>? get postionBookModel => _postionBookModel;
  List<PositionBookModel>? _openPosition = [];
  List<PositionBookModel>? get openPosition => _openPosition;
  List<PositionBookModel>? _closedPosion = [];
  List<PositionBookModel>? get closedPosion => _closedPosion;

  List<PositionBookModel> _allPostionList = [];
  List<PositionBookModel> get allPostionList => _allPostionList;

  // List<PositionBookModel> _postionGropList = [];
  // List<PositionBookModel> get postionGropList => _postionGropList;

  List<PositionBookModel> _positionSearchItem = [];
  List<PositionBookModel> get positionSearchItem => _positionSearchItem;
  PositionConvertionModel? _positionConvertionModel;
  PositionConvertionModel? get positionConvertionModel =>
      _positionConvertionModel;

  final String _allPnlPosition = '0.00';
  String get allPnlPosition => _allPnlPosition;

  double _totalPnlHolding = 0.00;
  double get totalPnlHolding => _totalPnlHolding;
  double _totalCurrentVal = 0.00;
  double get totalCurrentVal => _totalCurrentVal;
  double _oneDayChng = 0.00;
  double get oneDayChng => _oneDayChng;
  double _oneDayChngPer = 0.00;
  double get oneDayChngPer => _oneDayChngPer;
  String _totPnlPercHolding = "0.00";
  String get totPnlPercHolding => _totPnlPercHolding;
  String _totInvesHold = "0.00";
  String get totInvesHold => _totInvesHold;

  int _exitPositionQty = 0;
  int get exitPositionQty => _exitPositionQty;
  bool _isExitAllPosition = false;
  bool get isExitAllPosition => _isExitAllPosition;

  int _exitHoldingsQty = 0;
  int get exitHoldingsQty => _exitHoldingsQty;
  bool _isExitAllHoldings = false;
  bool get isExitAllHoldings => _isExitAllHoldings;
  PlaceOrderModel? _placeOrderModel;
  PlaceOrderModel? get placeOrderModel => _placeOrderModel;

  String _totBuyAmt = '0.00';
  String get totBuyAmt => _totBuyAmt;
  String _totSellAmt = '0.00';
  String get totSellAmt => _totSellAmt;
  String _netVal = '0.00';
  String get netVal => _netVal;
  bool _isDay = false;
  bool get isDay => _isDay;

  String _totPnL = '0.00';
  String get totPnL => _totPnL;
  String _totMtm = '0.00';
  String get totMtM => _totMtm;

  String _totUnRealMtm = '0.00';
  String get totUnRealMtm => _totUnRealMtm;
  String _totBookedPnL = '0.00';
  String get totBookedPnL => _totBookedPnL;

  bool _isNetPnl = true;
  bool get isNetPnl => _isNetPnl;

  PortfolioProvider(this.ref);

  bool _showSearchHold = false;
  bool get showSearchHold => _showSearchHold;

  bool _showSearchPosition = false;
  bool get showSearchPosition => _showSearchPosition;
  bool _showEdis = false;
  bool get showEdis => _showEdis;

  bool _exitAll = false;
  bool get exitAll => _exitAll;
  List<Tab> _portTabName = [
    const Tab(text: "Positions"),
    const Tab(text: "Holdings")
  ];
  List<Tab> get portTabName => _portTabName;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

// Position Grouping -----------

  Map _groupedBySymbol = {};
  Map get groupedBySymbol => _groupedBySymbol;

  // Map<String, dynamic> _positionGroup = {};
  // Map get positionGroup => _positionGroup;
  List<String> _groupPositionSym = [];
  List<String> get groupPositionSym => _groupPositionSym;

  String _posSelection = "All position";

  String get posSelection => _posSelection;

  final List<String> _posGrpNames = ["All position", "Group by symbol"];

  List<String> get posGrpNames => _posGrpNames;

  List<GetGroupSymbol> _getPositionGroupSymbol = [];
  List<GetGroupSymbol> get getPositionGroupSymbol => _getPositionGroupSymbol;

  CreateGroupName? _groupName;
  CreateGroupName? get groupName => _groupName;

// change selected portfolio tab name

  changeTabIndex(int index) {
    _selectedTab = index;
  }

  chngPosSelection(String val) {
    _posSelection = val;
    notifyListeners();
  }

//  Assinging and portfolio name length set

  tabSize() {
    _portTabName = [
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text(
                "Position${_allPostionList.isNotEmpty ? "s (${_allPostionList.length})" : ""}"),
          ])),
      Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "Holding${_holdingsModel!.isNotEmpty ? "s (${_holdingsModel!.length})" : ""}")
          ],
        ),
      ),
      if (_mfHoldingsModel!.isNotEmpty) ...[
        if (_mfHoldingsModel![0].stat != "Not_Ok") ...[
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("MF Holdings (${_mfHoldingsModel!.length})")],
            ),
          ),
        ]
      ]
    ];

    notifyListeners();
  }

// Holding search enable & hide

  showHoldSearch(bool value) {
    _showSearchHold = value;
    if (!_showSearchHold) {
      _holdingSearchItem = [];
    }
    notifyListeners();
  }

//  Position search enable & hide

  showPositionSearch(bool value) {
    _showSearchPosition = value;
    if (!_showSearchPosition) {
      _positionSearchItem = [];
    }
    positionSearchCtrl.clear();
    notifyListeners();
  }

// Holding search text field clear and search list item clear

  clearHoldSearch() {
    holdingSearchCtrl.clear();
    _holdingSearchItem = [];

    notifyListeners();
  }

// Position search text field clear and search list item clear

  clearPositionSearch() {
    positionSearchCtrl.clear();
    _positionSearchItem = [];

    notifyListeners();
  }

// Show position PNL / MTM value

  chngPositionPnl(bool value) {
    _isNetPnl = value;
    notifyListeners();
  }

  positionToggle(bool value, context) {
    clearPositionSearch();
    showPositionSearch(false);
    _isDay = value;

    fetchPositionBook(context, value);
    notifyListeners();
  }

  // MF Holdings

  double _mfTotInveest = 0.00;
  double get mfTotInveest => _mfTotInveest;

  double _mfTotCurrentVal = 0.00;
  double get mfTotCurrentVal => _mfTotCurrentVal;

  double _mfTotalPnl = 0.00;
  double get mfTotalPnl => _mfTotalPnl;

  double _mfTotalPnlPerchng = 0.00;
  double get mfTotalPnlPerchng => _mfTotalPnlPerchng;

  bool _showSearchHoldMF = false;
  bool get showSearchHoldMF => _showSearchHoldMF;

  static List dsgs = [];

  List<MFHoldingsModel>? _mfHoldingsModel = [];
  List<MFHoldingsModel>? get mfHoldingsModel => _mfHoldingsModel;
  List<MFHoldingsModel>? _mfHoldingSearchItem = [];
  List<MFHoldingsModel>? get mfHoldingSearchItem => _mfHoldingSearchItem;

  // Mutual fund Holding search text field clear and search list item clear

  showHoldMFSearch(bool value) {
    _showSearchHoldMF = value;
    if (!_showSearchHoldMF) {
      _mfHoldingSearchItem = [];
    }
    notifyListeners();
  }
// MF Holdings search text field clear and search list item clear

  clearHoldMFSearch() {
    holdingMFSearchCtrl.clear();
    _mfHoldingSearchItem = [];

    notifyListeners();
  }

  MFQuotes? _mfQuotes;
  MFQuotes? get mfQuotes => _mfQuotes;

  // String _totPnlHoldings = "0.00";
  // String get totPnlHoldings => _totPnlHoldings;

  // setPnlHoldings(String val) {
  //   _totPnlHoldings = val;
  // }

// Fetching data from the api and stored in a variable

  Future fetchHoldings(context, String initail) async {
    double invest = 0.0;
    try {
      toggleLoadingOn(true);
      _oneDayChngPer = 0.00;
      _showSearchHold = false;
      _holdingsModel = [];
      _totInvesHold = "0.00";
      _totPnlPercHolding = "0.00";
      _totalPnlHolding = 0.00;
      _totalCurrentVal = 0.00;
      _oneDayChng = 0.00;
      _showEdis = false;
      _sealableHoldings = [];
      _nonSealableHoldings = [];
      _holdingsModel = await api.getHolding();

      pref.setScrip(true);
      pref.setPrice(true);
      pref.setPerchnage(true);
      pref.setqty(true);
      pref.setInvestby(true);

      tabSize();
      if (_holdingsModel!.isNotEmpty) {
        if (_holdingsModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;

// Sorting Holdings data Trade symbol wise A to Z

          _holdingsModel!.sort(
              (a, b) => a.exchTsym![0].tsym!.compareTo(b.exchTsym![0].tsym!));

          for (var element in _holdingsModel!) {
            element.isExitHoldings = false;

// Seperating Trade symbol(symbol,exp date, Option)

            Map spilitSymbol =
                spilitTsym(value: "${element.exchTsym![0].tsym}");

            element.exchTsym![0].symbol = "${spilitSymbol["symbol"]}";
            element.exchTsym![0].expDate = "${spilitSymbol["expDate"]}";
            element.exchTsym![0].option = "${spilitSymbol["option"]}";
            int qty = (int.parse("${element.npoadqty ?? 0}") +
                    int.parse("${element.brkcolqty ?? 0}") +
                    int.parse("${element.npoadt1qty ?? 0}") +
                    int.parse("${element.holdqty ?? 0}") +
                    int.parse("${element.btstqty ?? 0}")) -
                int.parse("${element.usedqty ?? 0}");
            element.currentQty = qty;
            ref(websocketProvider)
                .socketDatas["${element.exchTsym![0].token}"] = {'holdQty': ""};

            ref(websocketProvider).socketDatas["${element.exchTsym![0].token}"]
                ['holdQty'] = "${element.currentQty}";

            double avgCost = double.parse(
                "${element.upldprc == "0.00" ? element.exchTsym![0].close ?? 0.0 : element.upldprc ?? 0.00}");

            element.avgPrc = "$avgCost";
            element.invested = (qty * avgCost).toStringAsFixed(2);

            invest += double.parse("${element.invested}");
            if (element.npoadqty.toString() != "null") {
              _showEdis = true;
            }

            element.saleableQty = (int.parse("${element.holdqty ?? 0}") +
                    int.parse("${element.dpQty ?? 0}") +
                    int.parse("${element.btstqty ?? 0}")) -
                int.parse("${element.usedqty ?? 0}");

            if (element.saleableQty != 0) {
              _sealableHoldings.add(element);
            } else {
              _nonSealableHoldings.add(element);
            }
          }

          _totInvesHold = invest.toStringAsFixed(2);
          if (initail == "Refresh") {
            await requestWSHoldings(isSubscribe: true, context: context);
            timerfunc();
          }
        } else {
          if (_holdingsModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _holdingsModel![0].stat == "Not_Ok") {
            ref(authProvider).ifSessionExpired(context);
          }
          _holdingsModel = [];
        }
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Holdings", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }

// Fetching data from the api and stored in a variable

  Future fetchMFHoldings(context) async {
    try {
      // _mfHoldingsModel = [];
      _mfHoldingsModel = await api.getMFHolding();
      _mfTotInveest = 0.00;
      _mfTotCurrentVal = 0.00;
      _mfTotalPnl = 0.00;
      _mfTotalPnlPerchng = 0.00;
      pref.setMfScrip(true);
      pref.setMfPrice(true);
      pref.setMfPerchnage(true);
      pref.setMfqty(true);
      pref.setMfInvestby(true);
      tabSize();
      if (_mfHoldingsModel!.isNotEmpty) {
        if (_mfHoldingsModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;

// PNL Calculation

          for (var element in _mfHoldingsModel!) {
            element.invested = (double.parse("${element.uploadPrc ?? 0.00}") *
                    double.parse("${element.holdqty ?? 0.00}"))
                .toStringAsFixed(2);
            _mfTotInveest += double.parse("${element.invested ?? 0.00}");

            if (element.exchTsym![0].nav == null) {
              _mfQuotes = await api.getMFQutoes("${element.exchTsym![0].exch}",
                  "${element.exchTsym![0].token}");

              element.exchTsym![0].nav =
                  double.parse("${_mfQuotes!.nav ?? 0.00}").toStringAsFixed(2);
            }
            element.currentVal =
                (double.parse("${element.exchTsym![0].nav ?? 0.00}") *
                        double.parse("${element.holdqty ?? 0.00}"))
                    .toStringAsFixed(2);

            _mfTotCurrentVal += double.parse("${element.currentVal ?? 0.00}");

            element.exchTsym![0].pnl =
                (double.parse("${element.currentVal ?? 0.00}") -
                        double.parse("${element.invested ?? 0.00}"))
                    .toStringAsFixed(2);
            _mfTotalPnl += double.parse("${element.exchTsym![0].pnl ?? 0.00}");

            element.exchTsym![0].pnlPerChng =
                ((double.parse("${element.exchTsym![0].pnl ?? 0.00}") /
                            double.parse("${element.invested ?? 0.00}")) *
                        100)
                    .toStringAsFixed(2);
          }

          _mfTotalPnlPerchng = ((_mfTotalPnl / _mfTotInveest) * 100);
          _mfHoldingsModel!.sort(
              (a, b) => a.exchTsym![0].tsym!.compareTo(b.exchTsym![0].tsym!));
        } else {
          if (_mfHoldingsModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _mfHoldingsModel![0].stat == "Not_Ok") {
            ref(authProvider).ifSessionExpired(context);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API MF Holdings", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {}
  }

  setTotPnlHoldings(double val) {
    _totalPnlHolding = val;
  }

  setOneDayChng(double val) {
    _oneDayChng = val;
  }

  // setTotPnlPercHolding(String val) {
  //   _totPnlPercHolding = val;
  // }

  setTotInvHoldings(double val) {
    _totInvesHold = val.toStringAsFixed(2);
  }

  setTotCurrentVal(double val) {
    _totalCurrentVal = val;
    _totPnlPercHolding = _totInvesHold == "0.00"
        ? "0.00"
        : ((double.parse("$_totalPnlHolding") / double.parse(_totInvesHold)) *
                100)
            .toStringAsFixed(2);
  }

  setOneDayChngPer() {
    _oneDayChngPer = ((_oneDayChng / _totalCurrentVal) * 100);
  }

  Timer? _timer;
  cancelTimer() {
    times = false;
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  bool times = false;

  void timerfunc() {
    if (!times) {
      print("Timer called");
      _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
        times = true;
        pnlHoldCal();
      });
    }
  }

  pnlHoldCal() {
    _totalPnlHolding = 0.00;
    _oneDayChng = 0.00;
    double invest = 0.00;
    _totalCurrentVal = 0.00;
    _oneDayChngPer == 0.00;
    _totPnlPercHolding = "0.00";
    for (var holdingJson in holdingsModel!) {
      _totalPnlHolding +=
          double.parse("${holdingJson.exchTsym![0].profitNloss ?? 0.0}");
      _oneDayChng +=
          double.parse("${holdingJson.exchTsym![0].oneDayChg ?? 0.0}");
      invest += double.parse("${holdingJson.invested ?? 0.0}");
      _totInvesHold = invest.toStringAsFixed(2);
      _totalCurrentVal += double.parse("${holdingJson.currentValue ?? 0.0}");
    }
    _oneDayChngPer = ((_oneDayChng / _totalCurrentVal) * 100);

    _totPnlPercHolding = _totInvesHold == "0.00"
        ? "0.00"
        : ((double.parse("$_totalPnlHolding") / double.parse(_totInvesHold)) *
                100)
            .toStringAsFixed(2);

    notifyListeners();
  }

  Future fetchPositionBook(BuildContext context, bool isDay) async {
    try {
      toggleLoadingOn(true);
      _postionBookModel = [];
      _allPostionList = [];
      _totPnL = "0.00";
      _totMtm = "0.00";
      _exitAll = false;
      _totBookedPnL = "0.00";
      _posSelection = "All position";
      _totUnRealMtm = '0.00';
      _postionBookModel = await api.getPositionBook();
      pref.setPosScrip(true);
      pref.setPosPrice(true);
      pref.setPosPerchnage(true);
      pref.setPosqty(true);
      pref.setPostion(true);
      // splitPositionBook(isDay);
      if (_postionBookModel!.isNotEmpty) {
        if (_postionBookModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;
          _isDay = isDay;
          await splitPositionBook(isDay);

          // await requestWSPosition(context: context, isSubscribe: true);
        } else {
          //

          if (_postionBookModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _postionBookModel![0].stat == "Not_Ok") {
            ref(authProvider).ifSessionExpired(context);
          }
          _openPosition = [];
          _postionBookModel = [];
        }
      }
      notifyListeners();
      return _postionBookModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Position Book", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchPositionConverstion(
      PositionConvertionInput positionConvertionInput, context) async {
    try {
      _positionConvertionModel =
          await api.getPositionConvertion(positionConvertionInput);

      if (_positionConvertionModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        fetchPositionBook(context, false);
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Position Converted"));
        Future.delayed(const Duration(seconds: 1), () {
          fetchPositionBook(context, false);
          Navigator.pop(context);

          Navigator.pop(context);
        });
      } else {
        if (_positionConvertionModel!.emsg ==
            "Session Expired :  Invalid Session Key") {
          ref(authProvider).ifSessionExpired(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              warningMessage(context, "${_positionConvertionModel!.emsg}"));
        }
      }

      return _positionConvertionModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Position Conv", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  splitPositionBook(bool isDay) async {
    // _positionGrpName = "All";
    if (_postionBookModel!.isNotEmpty) {
      _closedPosion = [];
      double totBuyAmts = 0.00;
      double totSellAmts = 0.00;
      _allPostionList = [];
      // _postionGropList = [];
      // _positionGroup = {};
      _totPnL = "0.00";
      _totMtm = "0.00";
      _exitAll = false;
      _totBookedPnL = "0.00";
      _totUnRealMtm = '0.00';
      _openPosition = [];

      for (var element in _postionBookModel!) {
        element.isExitSelection = false;

        if (element.netqty == "0") {
          _closedPosion!.add(element);
          _closedPosion!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
        } else {
          _openPosition!.add(element);
          _openPosition!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
        }

        totBuyAmts += double.parse(element.totbuyamt ?? "0.00");
        totSellAmts += double.parse(element.totsellamt ?? "0.00");
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

      _totBuyAmt = totBuyAmts.toStringAsFixed(2);
      _totSellAmt = totSellAmts.toStringAsFixed(2);

      _netVal = (double.parse(_totBuyAmt) - double.parse(_totSellAmt))
          .toStringAsFixed(2);

      _exitAll = false;
      if (isDay) {
        int check = 0;
        for (var element in _openPosition!) {
          if (element.daybuyqty != "0" || element.daysellqty != "0") {
            check = check + 1;
            _allPostionList.add(element);

            if (check >= 2) {
              _exitAll = true;
            }
          }
        }
      } else {
        int check = 0;
        for (var element in _openPosition!) {
          check = check + 1;
          _allPostionList.add(element);
        }
        if (check >= 2) {
          _exitAll = true;
        }
      }

      for (var element in _closedPosion!) {
        if (isDay) {
          if (element.daybuyqty != "0" || element.daysellqty != "0") {
            _allPostionList.add(element);
          }
        } else {
          _allPostionList.add(element);
        }
      }
      // if (_allPostionList.length <= 1) {
      //   _posSelection = "All position";
      // }
      await positionCal(isDay);

      // await positionGroupCal(isDay, {});

      getPositionGroupNames();
      tabSize();

      notifyListeners();
    }
  }

  selectExitPosition(int index) {
    for (var i = 0; i < _allPostionList.length; i++) {
      if (index == i) {
        _allPostionList[i].isExitSelection =
            !_allPostionList[i].isExitSelection!;

        if (_allPostionList[i].isExitSelection!) {
          _exitPositionQty = _exitPositionQty + 1;
        } else {
          _exitPositionQty = _exitPositionQty - 1;
        }
      }

      if (_openPosition!.length == _exitPositionQty) {
        _isExitAllPosition = true;
      } else {
        _isExitAllPosition = false;
      }
    }

    notifyListeners();
  }

  selectExitAllPosition(bool isExitAll) {
    _isExitAllPosition = isExitAll;
    _exitPositionQty = 0;
    for (var i = 0; i < _allPostionList.length; i++) {
      if (_allPostionList[i].qty != "0") {
        if (isExitAll) {
          _allPostionList[i].isExitSelection = true;
          _exitPositionQty = _exitPositionQty + 1;
        } else {
          _allPostionList[i].isExitSelection = false;
        }
      }
    }

    notifyListeners();
  }

  cusGrpSelectPosition(List addedSymbol) {
    for (var element in _postionBookModel!) {
      element.isExitSelection = false;
      for (var addedSymbol in addedSymbol) {
        if (element.tsym == addedSymbol['tsym']) {
          element.isExitSelection = true;
        }
      }
    }

    notifyListeners();
  }

  selectExitHoldings(int index) {
    for (var i = 0; i < _sealableHoldings.length; i++) {
      if (index == i) {
        sealableHoldings[i].isExitHoldings =
            !sealableHoldings[i].isExitHoldings!;

        if (sealableHoldings[i].isExitHoldings!) {
          _exitHoldingsQty = _exitHoldingsQty + 1;
        } else {
          _exitHoldingsQty = _exitHoldingsQty - 1;
        }
      }

      if (sealableHoldings.length == _exitHoldingsQty) {
        _isExitAllHoldings = true;
      } else {
        _isExitAllHoldings = false;
      }
    }

    notifyListeners();
  }

  selectExitAllHoldings(bool isExitAll) {
    _isExitAllHoldings = isExitAll;
    _exitHoldingsQty = 0;

    for (var element in _sealableHoldings) {
      if (isExitAll) {
        element.isExitHoldings = true;
        _exitHoldingsQty = _exitHoldingsQty + 1;
      } else {
        element.isExitHoldings = false;
      }
    }

    notifyListeners();
  }

  Future fetchExitPosition(BuildContext context,
      PlaceOrderInput placeOrderInput, bool isPosition) async {
    try {
      _placeOrderModel = await api.getPlaceOrder(placeOrderInput);

      if (_placeOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        if (isPosition) {
          await fetchPositionBook(context, _isDay);
        } else {
          await fetchHoldings(context, "Refresh");
        }
        Navigator.pop(context);
        // ref(orderProvider).fetchOrderBook(context, false);
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

// Position Calculation
  positionCal(bool isDay) {
    double totalMtm = 0.00;
    double totalPnl = 0.00;
    double unRealMtm = 0.00;
    double bookPnl = 0.00;

    int qty = 0;

    double avgPrc = 0.00;

    String pnl = "0.00";
    for (var element in _allPostionList) {
      double lastPrice = double.parse(element.lp == null || element.lp == "null"
          ? "0.00"
          : "${element.lp}");
      if (isDay) {
        element.avgPrc = element.netqty == "0" ? "0.00" : element.dayavgprc;

        avgPrc = double.parse(element.avgPrc ?? "0.00");
        qty = (int.parse("${element.daybuyqty ?? 0}") -
            int.parse("${element.daysellqty ?? 0}"));

        element.qty = "$qty";

        if (qty != 0) {
          pnl = element.netqty == "0"
              ? qty > 0
                  ? ((qty * lastPrice) -
                          (qty * double.parse(element.daybuyavgprc ?? "0.00")))
                      .toStringAsFixed(2)
                  : ((qty * lastPrice) -
                          (qty * double.parse(element.daysellavgprc ?? "0.00")))
                      .toStringAsFixed(2)
              : (element.exch == "MCX" || element.exch == "CDS")
                  ? ((lastPrice - avgPrc) *
                          (int.parse("${element.mult ?? 0}") * qty))
                      .toStringAsFixed(2)
                  : ((lastPrice - avgPrc) * qty).toStringAsFixed(2);

          element.profitNloss = pnl;

          unRealMtm += double.parse(element.profitNloss!);

          bookPnl += ((qty * double.parse(element.daybuyavgprc ?? "0.00")) -
              (qty * double.parse(element.daysellavgprc ?? "0.00")));
        } else {
          bookPnl += double.parse(element.rpnl!);
        }
      } else {
        element.qty = "${element.netqty}";

        qty = int.parse(element.qty ?? "0");

        element.avgPrc = qty == 0
            ? "0.00"
            : _isNetPnl
                ? element.upldprc == "0.00"
                    ? element.dayavgprc
                    : element.upldprc
                : element.netavgprc;

        avgPrc = double.parse(element.avgPrc ?? "0.00");
        if (element.exch == "MCX" || element.exch == "CDS") {
          double value =
              (lastPrice - double.parse(element.netavgprc ?? "0.00")) *
                  (int.parse("${element.mult ?? 0}") * qty);

          element.mTm = qty == 0 ? element.rpnl : value.toStringAsFixed(2);

          if (qty == 0) {
            if (element.cfbuyqty != "0") {
              element.profitNloss =
                  (double.parse("${element.daysellavgprc ?? 0.00}") *
                              int.parse("${element.daysellqty ?? 0}") -
                          int.parse("${element.cfbuyqty ?? 0}") *
                              double.parse("${element.upldprc ?? 0.00}"))
                      .toStringAsFixed(2);
            } else if (element.cfsellqty != "0") {
              element.profitNloss = (int.parse("${element.cfsellqty ?? 0}") *
                          double.parse("${element.upldprc ?? 0.00}") -
                      double.parse("${element.daybuyavgprc ?? 0.00}") *
                          int.parse("${element.daybuyqty ?? 0}"))
                  .toStringAsFixed(2);
            }
          } else {
            element.profitNloss = ((lastPrice -
                        double.parse(
                            "${element.upldprc == "0.00" ? element.avgPrc : element.upldprc}")) *
                    (int.parse("${element.mult ?? 0}") * qty))
                .toStringAsFixed(2);
          }
        } else {
          double value =
              (((lastPrice - double.parse(element.netavgprc ?? "0.00")) * qty) +
                  double.parse("${element.rpnl ?? 0.00}"));

          element.mTm = qty != 0 ? value.toStringAsFixed(2) : "${element.rpnl}";

          if (qty == 0) {
            if (element.cfbuyqty != "0") {
              element.profitNloss =
                  ((double.parse("${element.daysellavgprc ?? 0.00}") *
                              int.parse("${element.daysellqty ?? 0}")) -
                          (int.parse("${element.cfbuyqty ?? 0}") *
                              double.parse("${element.upldprc ?? 0.00}")) -
                          (int.parse("${element.daybuyqty ?? 0}") *
                              double.parse("${element.daybuyavgprc ?? 0.00}")))
                      .toStringAsFixed(2);
            } else if (element.cfsellqty != "0") {
              element.profitNloss = ((int.parse("${element.cfsellqty ?? 0}") *
                          double.parse("${element.upldprc ?? 0.00}")) -
                      (double.parse("${element.daybuyavgprc ?? 0.00}") *
                          int.parse("${element.daybuyqty ?? 0}")) -
                      (int.parse("${element.daysellqty ?? 0}") *
                          double.parse("${element.daysellavgprc ?? 0.00}")))
                  .toStringAsFixed(2);
            } else {
              element.profitNloss = element.rpnl;
            }

            // print(" 34 ${element.profitNloss}");
          } else {
            element.profitNloss = (((lastPrice -
                            double.parse(
                                "${element.upldprc == "0.00" ? element.avgPrc : element.upldprc}")) *
                        qty) +
                    double.parse("${element.rpnl ?? 0.00}"))
                .toStringAsFixed(2);

            // print(  "34   ${element.profitNloss}");
          }
        }

        totalMtm += double.parse(element.mTm!);
        totalPnl +=
            double.parse("${element.profitNloss ?? element.rpnl ?? 0.00}");
      }
    }

    _totMtm = totalMtm.toStringAsFixed(2);

    _totPnL = totalPnl.toStringAsFixed(2);
    _totUnRealMtm = unRealMtm.toStringAsFixed(2);

    _totBookedPnL = bookPnl.toStringAsFixed(2);
  }

// Fetch Group Names and Grouped scrips
  getPositionGroupNames() {
    try {
      _groupedBySymbol = {};
      for (var element in _allPostionList) {
        if (_groupedBySymbol.containsKey(element.symbol)) {
          _groupedBySymbol['${element.symbol}']["groupList"]
              .add(jsonDecode(jsonEncode(element)));
        } else {
          _groupedBySymbol.addAll({
            "${element.symbol}": {
              "isCustomGrp": false,
              "totMtm": "0.00",
              "totPnl": "0.00",
              "groupList": [jsonDecode(jsonEncode(element))]
            }
          });
        }
      }

      for (var element in _getPositionGroupSymbol) {
        if (_groupedBySymbol.containsKey(element.posname)) {
          _groupedBySymbol['${element.posname}']["groupList"]
              .add(jsonDecode(jsonEncode(element.posdata)));
        } else {
// log("${jsonDecode(jsonEncode(element.posdata))  }");

          _groupedBySymbol.addAll({
            "${element.posname}": {
              "isCustomGrp": true,
              "totMtm": "0.00",
              "totPnl": "0.00",
              "groupList": jsonDecode(jsonEncode(element.posdata))
            }
          });
        }
      }

      _groupPositionSym = [];

      if (_groupedBySymbol.keys.isNotEmpty) {
        for (var element in _groupedBySymbol.keys) {
          _groupPositionSym.add(element);
        }
      }
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

// Position group by Group names
  positionGroupCal(
      bool isDay, List groupData, String groupName, bool iscusGrop) {
    // double totalMtm = 0.00;
    // double totalPnl = 0.00;
    double unRealMtm = 0.00;
    double bookPnl = 0.00;

    int qty = 0;
    double totalProfitNloss = 0.00;
    double totalMtms = 0.00;

    double avgPrc = 0.00;
    String pnl = "0.00";

    if (groupData.isNotEmpty) {
      for (var element in groupData) {
        double lastPrice = double.parse(
            element["lp"] == null || element["lp"] == "null"
                ? "0.00"
                : "${element["lp"]}");
        if (isDay) {
          element["avgPrc"] =
              element["netqty"] == "0" ? "0.00" : element["dayavgprc"];

          avgPrc = double.parse(element["avgPrc"] ?? "0.00");
          qty = (int.parse("${element["daybuyqty"] ?? 0}") -
              int.parse("${element["daysellqty"] ?? 0}"));

          element["qty"] = "$qty";

          if (qty != 0) {
            pnl = element["netqty"] == "0"
                ? qty > 0
                    ? ((qty * lastPrice) -
                            (qty *
                                double.parse(
                                    element['daybuyavgprc'] ?? "0.00")))
                        .toStringAsFixed(2)
                    : ((qty * lastPrice) -
                            (qty *
                                double.parse(
                                    element['daysellavgprc'] ?? "0.00")))
                        .toStringAsFixed(2)
                : (element["exch"] == "MCX" || element["exch"] == "CDS")
                    ? ((lastPrice - avgPrc) *
                            (int.parse("${element['mult'] ?? 0}") * qty))
                        .toStringAsFixed(2)
                    : ((lastPrice - avgPrc) * qty).toStringAsFixed(2);

            element["profitNloss"] = pnl;

            unRealMtm += double.parse(pnl);

            bookPnl +=
                ((qty * double.parse(element['daybuyavgprc'] ?? "0.00")) -
                    (qty * double.parse(element['daysellavgprc'] ?? "0.00")));
            _groupedBySymbol[groupName]['totPnl'] =
                unRealMtm.toStringAsFixed(2);
          } else {
            element["profitNloss"] = element["rpnl"];
            bookPnl += double.parse(element["rpnl"] ?? "0.00");
            _groupedBySymbol[groupName]['totPnl'] = bookPnl.toStringAsFixed(2);
          }
        } else {
          element["qty"] = "${element["netqty"]}";

          qty = int.parse(element["qty"] ?? "0");

          element["avgPrc"] = qty == 0
              ? "0.00"
              : _isNetPnl
                  ? element["upldprc"] == "0.00"
                      ? element["dayavgprc"]
                      : element["upldprc"]
                  : element["netavgprc"];

          avgPrc = double.parse(element["avgPrc"] ?? "0.00");
          if (element["exch"] == "MCX" || element["exch"] == "CDS") {
            double value =
                (lastPrice - double.parse(element["netavgprc"] ?? "0.00")) *
                    (int.parse("${element['mult'] ?? 0}") * qty);

            element['mTm'] =
                qty == 0 ? element["rpnl"] : value.toStringAsFixed(2);

            if (qty == 0) {
              if (element["cfbuyqty"] != "0") {
                element['profitNloss'] = ((double.parse(
                                "${element['daysellavgprc'] ?? 0.00}") *
                            int.parse("${element['daysellqty'] ?? 0}")) -
                        (int.parse("${element['cfbuyqty'] ?? 0}") *
                            double.parse("${element['upldprc'] ?? 0.00}")) -
                        (int.parse("${element['daybuyqty'] ?? 0}") *
                            double.parse("${element['daybuyavgprc'] ?? 0.00}")))
                    .toStringAsFixed(2);
              } else if (element['cfsellqty'] != "0") {
                element['profitNloss'] = ((int.parse(
                                "${element['cfsellqty'] ?? 0}") *
                            double.parse("${element['upldprc'] ?? 0.00}")) -
                        (double.parse("${element['daybuyavgprc'] ?? 0.00}") *
                            int.parse("${element['daybuyqty'] ?? 0}")) -
                        (int.parse("${element['daysellqty'] ?? 0}") *
                            double.parse(
                                "${element['daysellavgprc'] ?? 0.00}")))
                    .toStringAsFixed(2);
              }
            } else {
              element['profitNloss'] = ((lastPrice -
                          double.parse(
                              "${element['upldprc'] == "0.00" ? element['avgPrc'] : element['upldprc']}")) *
                      (int.parse("${element['mult'] ?? 0}") * qty))
                  .toStringAsFixed(2);
            }
          } else {
            double value =
                (((lastPrice - double.parse(element['netavgprc'] ?? "0.00")) *
                        qty) +
                    double.parse("${element['rpnl'] ?? 0.00}"));

            element['mTm'] =
                qty != 0 ? value.toStringAsFixed(2) : "${element['rpnl']}";

            if (qty == 0) {
              if (element['cfbuyqty'] != "0") {
                element['profitNloss'] =
                    (double.parse("${element['daysellavgprc'] ?? 0.00}") *
                                int.parse("${element['daysellqty'] ?? 0}") -
                            int.parse("${element['cfbuyqty'] ?? 0}") *
                                double.parse("${element['upldprc'] ?? 0.00}"))
                        .toStringAsFixed(2);
              } else if (element['cfsellqty'] != "0") {
                element['profitNloss'] =
                    (int.parse("${element['cfsellqty'] ?? 0}") *
                                double.parse("${element['upldprc'] ?? 0.00}") -
                            double.parse("${element['daybuyavgprc'] ?? 0.00}") *
                                int.parse("${element['daybuyqty'] ?? 0}"))
                        .toStringAsFixed(2);
              } else {
                element['profitNloss'] = element['rpnl'];
              }

              // print(" 34 ${element.profitNloss}");
            } else {
              element['profitNloss'] = (((lastPrice -
                              double.parse(
                                  "${element['upldprc'] == "0.00" ? element['avgPrc'] : element['upldprc']}")) *
                          qty) +
                      double.parse("${element['rpnl'] ?? 0.00}"))
                  .toStringAsFixed(2);

              // print(  "34   ${element.profitNloss}");
            }
          }

          totalMtms += double.parse(element['mTm'] ?? "0.00");
          totalProfitNloss += double.parse(
              "${element['profitNloss'] ?? element['rpnl'] ?? 0.00}");

          _groupedBySymbol[groupName]['totPnl'] =
              totalProfitNloss.toStringAsFixed(2);

          _groupedBySymbol[groupName]['totMtm'] = totalMtms.toStringAsFixed(2);
        }

        bool shouldExit = groupData.any((item) => item['qty'] != '0');

        _groupedBySymbol[groupName]['isexit'] = "$shouldExit";
      }
    }

    double ctotPnl = 0.00;

    double ctotMtm = 0.00;

    for (var element in _groupPositionSym) {
      if (_groupedBySymbol[element]["isCustomGrp"] == false) {
        ctotPnl += double.parse(_groupedBySymbol[element]['totPnl']);
        ctotMtm += double.parse(_groupedBySymbol[element]['totMtm']);
      }
    }

    _totMtm = ctotMtm.toStringAsFixed(2);

    _totPnL = ctotPnl.toStringAsFixed(2);
    _totUnRealMtm = unRealMtm.toStringAsFixed(2);

    _totBookedPnL = bookPnl.toStringAsFixed(2);

    notifyListeners();
  }

// websocket Connection Request for Position scrip
  requestWSPosition(
      {required bool isSubscribe, required BuildContext context}) {
    String input = "";

    if (_postionBookModel != null) {
      if (_postionBookModel!.isNotEmpty &&
          _postionBookModel![0].stat != "Not_Ok") {
        for (var element in _postionBookModel!) {
          input += "${element.exch}|${element.token}#";
        }
      }
    }
    if (input.isNotEmpty) {
      // ConstantName.lastSubscribe = input;
      ref(websocketProvider).establishConnection(
          channelInput: input, task: isSubscribe ? "t" : "u", context: context);
    }
    // notifyListeners();
  }

// websocket Connection Request for Holdings scrip
  requestWSHoldings(
      {required bool isSubscribe, required BuildContext context}) {
    String input = "";
    if (_holdingsModel != null) {
      if (_holdingsModel!.isNotEmpty) {
        if (_holdingsModel![0].stat != "Not_Ok") {
          for (var i = 0; i < _holdingsModel!.length; i++) {
            input +=
                "${_holdingsModel![i].exchTsym![0].exch}|${_holdingsModel![i].exchTsym![0].token}#";
          }
        }
      }
    }
    if (input.isNotEmpty) {
      // ConstantName.lastSubscribe = input;
      ref(websocketProvider).establishConnection(
          channelInput: input, task: isSubscribe ? "t" : "u", context: context);
    }
  }

  exitGroupedPosition(BuildContext context, List positionData) async {
    if (positionData.isNotEmpty) {
      for (var element in positionData) {
        if (element['qty'].toString() != "0") {
          if (((element['s_prdt_ali'] == "MIS" ||
                  element['s_prdt_ali'] == "CNC") ||
              element['s_prdt_ali'] == "NRML")) {
            PlaceOrderInput placeOrderInput = PlaceOrderInput(
                amo: "",
                blprc: '',
                bpprc: '',
                dscqty: "",
                exch: "${element['exch']}",
                prc: "0",
                prctype: "MKT",
                prd: "${element['prd']}",
                qty: element['qty'].toString().replaceAll("-", ""),
                ret: "DAY",
                trailprc: '',
                trantype: int.parse(element['qty'] ?? "0") < 0 ? 'B' : 'S',
                trgprc: "",
                tsym: "${element['tsym']}",
                mktProt: '',
                channel: defaultTargetPlatform == TargetPlatform.android
                    ? '${ref(authProvider).deviceInfo["brand"]}'
                    : "${ref(authProvider).deviceInfo["model"]}");
            _placeOrderModel = await api.getPlaceOrder(placeOrderInput);

            if (_placeOrderModel!.stat!.toLowerCase() != "ok") {
              break;
            }
          }
        }
      }
      await fetchPositionBook(context, _isDay);
    }
  }
// Sort Holding data (LTP,Symbol,Change,Per Change)

  filterHoldings(
      {required String sorting, required BuildContext context}) async {
    if (sorting == "ASC") {
      _holdingsModel!
          .sort((a, b) => a.exchTsym![0].tsym!.compareTo(b.exchTsym![0].tsym!));
    } else if (sorting == "DSC") {
      _holdingsModel!
          .sort((a, b) => b.exchTsym![0].tsym!.compareTo(a.exchTsym![0].tsym!));
    } else if (sorting == "LTPDSC") {
      _holdingsModel!.sort((a, b) {
        return double.parse(
                b.exchTsym![0].lp == null || b.exchTsym![0].lp == "null"
                    ? "0.00"
                    : "${b.exchTsym![0].lp}")
            .compareTo(double.parse(
                a.exchTsym![0].lp == null || a.exchTsym![0].lp == "null"
                    ? "0.00"
                    : "${a.exchTsym![0].lp}"));
      });
    } else if (sorting == "LTPASC") {
      _holdingsModel!.sort((a, b) {
        return double.parse(
                a.exchTsym![0].lp == null || a.exchTsym![0].lp == "null"
                    ? "0.00"
                    : "${a.exchTsym![0].lp}")
            .compareTo(double.parse(
                b.exchTsym![0].lp == null || b.exchTsym![0].lp == "null"
                    ? "0.00"
                    : "${b.exchTsym![0].lp}"));
      });
    } else if (sorting == "QTYDSC") {
      _holdingsModel!.sort((a, b) {
        return int.parse(b.currentQty == null || b.currentQty == "null"
                ? "0.00"
                : "${b.currentQty}")
            .compareTo(int.parse(a.currentQty == null || a.currentQty == "null"
                ? "0.00"
                : "${a.currentQty}"));
      });
    } else if (sorting == "QTYASC") {
      _holdingsModel!.sort((a, b) {
        return int.parse(a.currentQty == null || a.currentQty == "null"
                ? "0.00"
                : "${a.currentQty}")
            .compareTo(int.parse(b.currentQty == null || b.currentQty == "null"
                ? "0.00"
                : "${b.currentQty}"));
      });
    } else if (sorting == "PCDESC") {
      _holdingsModel!.sort((a, b) {
        return double.parse(b.exchTsym![0].perChange == null ||
                    b.exchTsym![0].perChange == "null"
                ? "0.00"
                : "${b.exchTsym![0].perChange}")
            .compareTo(double.parse(a.exchTsym![0].perChange == null ||
                    a.exchTsym![0].perChange == "null"
                ? "0.00"
                : "${a.exchTsym![0].perChange}"));
      });
    } else if (sorting == "PCASC") {
      _holdingsModel!.sort((a, b) {
        return double.parse(a.exchTsym![0].perChange == null ||
                    a.exchTsym![0].perChange == "null"
                ? "0.00"
                : "${a.exchTsym![0].perChange}")
            .compareTo(double.parse(b.exchTsym![0].perChange == null ||
                    b.exchTsym![0].perChange == "null"
                ? "0.00"
                : "${b.exchTsym![0].perChange}"));
      });
    } else if (sorting == "INVDESC") {
      _holdingsModel!.sort((a, b) {
        return double.parse(b.invested == null || b.invested == "null"
                ? "0.00"
                : "${b.invested}")
            .compareTo(double.parse(a.invested == null || a.invested == "null"
                ? "0.00"
                : "${a.invested}"));
      });
    } else if (sorting == "INVASC") {
      _holdingsModel!.sort((a, b) {
        return double.parse(a.invested == null || a.invested == "null"
                ? "0.00"
                : "${a.invested}")
            .compareTo(double.parse(b.invested == null || b.invested == "null"
                ? "0.00"
                : "${b.invested}"));
      });
    }

    notifyListeners();
  }
// Sort MF Holding data (LTP,Symbol,Change,Per Change)

  filterMfHoldings(
      {required String sorting, required BuildContext context}) async {
    if (sorting == "ASC") {
      _mfHoldingsModel!.sort(
          (a, b) => a.exchTsym![0].cname!.compareTo(b.exchTsym![0].cname!));
    } else if (sorting == "DSC") {
      _mfHoldingsModel!.sort(
          (a, b) => b.exchTsym![0].cname!.compareTo(a.exchTsym![0].cname!));
    } else if (sorting == "LTPDSC") {
      _mfHoldingsModel!.sort((a, b) {
        return double.parse(
                b.exchTsym![0].nav == null || b.exchTsym![0].nav == "null"
                    ? "0.00"
                    : "${b.exchTsym![0].nav}")
            .compareTo(double.parse(
                a.exchTsym![0].nav == null || a.exchTsym![0].nav == "null"
                    ? "0.00"
                    : "${a.exchTsym![0].nav}"));
      });
    } else if (sorting == "LTPASC") {
      _mfHoldingsModel!.sort((a, b) {
        return double.parse(
                a.exchTsym![0].nav == null || a.exchTsym![0].nav == "null"
                    ? "0.00"
                    : "${a.exchTsym![0].nav}")
            .compareTo(double.parse(
                b.exchTsym![0].nav == null || b.exchTsym![0].nav == "null"
                    ? "0.00"
                    : "${b.exchTsym![0].nav}"));
      });
    } else if (sorting == "QTYDSC") {
      _mfHoldingsModel!.sort((a, b) {
        return int.parse(b.holdqty == null || b.holdqty == "null"
                ? "0.00"
                : "${b.holdqty}")
            .compareTo(int.parse(a.holdqty == null || a.holdqty == "null"
                ? "0.00"
                : "${a.holdqty}"));
      });
    } else if (sorting == "QTYASC") {
      _mfHoldingsModel!.sort((a, b) {
        return double.parse(a.holdqty == null || a.holdqty == "null"
                ? "0.00"
                : "${a.holdqty}")
            .compareTo(double.parse(b.holdqty == null || b.holdqty == "null"
                ? "0.00"
                : "${b.holdqty}"));
      });
    } else if (sorting == "PCDESC") {
      _mfHoldingsModel!.sort((a, b) {
        return double.parse(b.exchTsym![0].pnlPerChng == null ||
                    b.exchTsym![0].pnlPerChng == "null"
                ? "0.00"
                : "${b.exchTsym![0].pnlPerChng}")
            .compareTo(double.parse(a.exchTsym![0].pnlPerChng == null ||
                    a.exchTsym![0].pnlPerChng == "null"
                ? "0.00"
                : "${a.exchTsym![0].pnlPerChng}"));
      });
    } else if (sorting == "PCASC") {
      _mfHoldingsModel!.sort((a, b) {
        return double.parse(a.exchTsym![0].pnlPerChng == null ||
                    a.exchTsym![0].pnlPerChng == "null"
                ? "0.00"
                : "${a.exchTsym![0].pnlPerChng}")
            .compareTo(double.parse(b.exchTsym![0].pnlPerChng == null ||
                    b.exchTsym![0].pnlPerChng == "null"
                ? "0.00"
                : "${b.exchTsym![0].pnlPerChng}"));
      });
    } else if (sorting == "INVDESC") {
      _mfHoldingsModel!.sort((a, b) {
        return double.parse(b.invested == null || b.invested == "null"
                ? "0.00"
                : "${b.invested}")
            .compareTo(double.parse(a.invested == null || a.invested == "null"
                ? "0.00"
                : "${a.invested}"));
      });
    } else if (sorting == "INVASC") {
      _mfHoldingsModel!.sort((a, b) {
        return double.parse(a.invested == null || a.invested == "null"
                ? "0.00"
                : "${a.invested}")
            .compareTo(double.parse(b.invested == null || b.invested == "null"
                ? "0.00"
                : "${b.invested}"));
      });
    }

    notifyListeners();
  }

// Sort position data (LTP,Symbol,Change,Per Change)
  sortPositions({required String sorting}) async {
    if (sorting == "ASC") {
      _allPostionList.sort((a, b) => a.tsym!.compareTo(b.tsym!));
    } else if (sorting == "DSC") {
      _allPostionList.sort((a, b) => b.tsym!.compareTo(a.tsym!));
    } else if (sorting == "LTPDSC") {
      _allPostionList.sort((a, b) {
        return double.parse(b.lp == null || b.lp == "null" ? "0.00" : "${b.lp}")
            .compareTo(double.parse(
                a.lp == null || a.lp == "null" ? "0.00" : "${a.lp}"));
      });
    } else if (sorting == "LTPASC") {
      _allPostionList.sort((a, b) {
        return double.parse(a.lp == null || a.lp == "null" ? "0.00" : "${a.lp}")
            .compareTo(double.parse(
                b.lp == null || b.lp == "null" ? "0.00" : "${b.lp}"));
      });
    } else if (sorting == "QTYDSC") {
      _allPostionList.sort((a, b) {
        return int.parse(b.qty == null || b.qty == "null" ? "0" : "${b.qty}")
            .compareTo(
                int.parse(a.qty == null || a.qty == "null" ? "0" : "${a.qty}"));
      });
    } else if (sorting == "QTYASC") {
      _allPostionList.sort((a, b) {
        return int.parse(a.qty == null || a.qty == "null" ? "0" : "${a.qty}")
            .compareTo(int.parse(
                b.qty == null || b.qty == "null" ? "0.00" : "${b.qty}"));
      });
    } else if (sorting == "PCDESC") {
      _allPostionList.sort((a, b) {
        return double.parse(b.perChange == null || b.perChange == "null"
                ? "0.00"
                : "${b.perChange}")
            .compareTo(double.parse(a.perChange == null || a.perChange == "null"
                ? "0.00"
                : "${a.perChange}"));
      });
    } else if (sorting == "PCASC") {
      _allPostionList.sort((a, b) {
        return double.parse(a.perChange == null || a.perChange == "null"
                ? "0.00"
                : "${a.perChange}")
            .compareTo(double.parse(b.perChange == null || b.perChange == "null"
                ? "0.00"
                : "${b.perChange}"));
      });
    } else if (sorting == "Close") {
      _allPostionList.sort((a, b) {
        return int.parse("${a.netqty}").compareTo(int.parse("${b.netqty}"));
      });
    } else if (sorting == "Open") {
      _allPostionList.sort((a, b) {
        return int.parse("${b.netqty}").compareTo(int.parse("${a.netqty}"));
      });
    }

    notifyListeners();
  }

  exitPosition(BuildContext context, bool exitAll) async {
    for (var element in _allPostionList) {
      if (element.qty != "0") {
        if (((element.sPrdtAli == "MIS" || element.sPrdtAli == "CNC") ||
            element.sPrdtAli == "NRML")) {
          if (exitAll) {
            PlaceOrderInput placeOrderInput = PlaceOrderInput(
                amo: "",
                blprc: '',
                bpprc: '',
                dscqty: "",
                exch: "${element.exch}",
                prc: "0",
                prctype: "MKT",
                prd: "${element.prd}",
                qty: element.qty!.replaceAll("-", ""),
                ret: "DAY",
                trailprc: '',
                trantype: int.parse(element.qty!) < 0 ? 'B' : 'S',
                trgprc: "",
                tsym: "${element.tsym}",
                mktProt: '',
                channel: defaultTargetPlatform == TargetPlatform.android
                    ? '${ref(authProvider).deviceInfo["brand"]}'
                    : "${ref(authProvider).deviceInfo["model"]}");
            _placeOrderModel = await api.getPlaceOrder(placeOrderInput);

            if (_placeOrderModel!.stat!.toLowerCase() != "ok") {
              break;
            }
          } else {
            if (element.isExitSelection!) {
              PlaceOrderInput placeOrderInput = PlaceOrderInput(
                  amo: "",
                  blprc: '',
                  bpprc: '',
                  dscqty: "",
                  exch: "${element.exch}",
                  prc: "0",
                  prctype: "MKT",
                  prd: "${element.prd}",
                  qty: element.qty!.replaceAll("-", ""),
                  ret: "DAY",
                  trailprc: '',
                  trantype: int.parse(element.qty!) < 0 ? 'B' : 'S',
                  trgprc: "",
                  tsym: "${element.tsym}",
                  mktProt: '',
                  channel: defaultTargetPlatform == TargetPlatform.android
                      ? '${ref(authProvider).deviceInfo["brand"]}'
                      : "${ref(authProvider).deviceInfo["model"]}");
              await fetchExitPosition(context, placeOrderInput, true);
            }
          }
        }
      }
    }

    // ref(indexListProvider).bottomMenu(2);
    // Navigator.pop(context);
  }

  exitAllHoldings(BuildContext context) async {
    for (var element in _sealableHoldings) {
      PlaceOrderInput placeOrderInput = PlaceOrderInput(
          amo: "",
          blprc: '',
          bpprc: '',
          dscqty: "",
          exch: "${element.exchTsym![0].exch}",
          prc: "0",
          prctype: "MKT",
          prd: "${element.prd}",
          qty: "${element.saleableQty}",
          ret: "DAY",
          trailprc: '',
          trantype: 'S',
          trgprc: "",
          tsym: "${element.exchTsym![0].tsym}",
          mktProt: '',
          channel: defaultTargetPlatform == TargetPlatform.android
              ? '${ref(authProvider).deviceInfo["brand"]}'
              : "${ref(authProvider).deviceInfo["model"]}");
      await fetchExitPosition(context, placeOrderInput, false);
    }
  }

// Holding search by Trade symbol
  holdingSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _holdingSearchItem = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _holdingSearchItem = _holdingsModel!
          .where((element) => element.exchTsym![0].tsym!
              .toUpperCase()
              .contains(value.toUpperCase()))
          .toList();
      if (_holdingSearchItem!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _holdingSearchItem = [];
    }
    notifyListeners();
  }

// MF Holding search by Trade symbol
  mfHoldingSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _mfHoldingSearchItem = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _mfHoldingSearchItem = _mfHoldingsModel!
          .where((element) => element.exchTsym![0].tsym!
              .toUpperCase()
              .contains(value.toUpperCase()))
          .toList();
      if (_mfHoldingSearchItem!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _mfHoldingSearchItem = [];
    }
    notifyListeners();
  }

// Fetching data from the api and stored in a variable
  positionSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _positionSearchItem = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _positionSearchItem = _allPostionList
          .where((element) =>
              element.tsym!.toLowerCase().contains(value.toLowerCase()))
          .toList();
      if (_positionSearchItem.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _positionSearchItem = [];
    }
    notifyListeners();
  }

// Fetching data from the api and stored in a variable
  Future fetchPosGroupSymbol(String name, bool isCreateGrp) async {
    try {
      _getPositionGroupSymbol = await api.getGroupPosition();
      _totPnL = "0.00";
      _totMtm = "0.00";
      _exitAll = false;
      _totBookedPnL = "0.00";
      _totUnRealMtm = '0.00';

      if (isCreateGrp) {
        _posSelection = "Group by symbol";
      }
      getPositionGroupNames();

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

// Fetching data from the api and stored in a variable
  Future fetchGroupName(String name, BuildContext c, bool isCreateGrp) async {
    try {
      toggleLoadingOn(true);
      _groupName = await api.createGroupName(name);

      if (_groupName!.status == "Data inserted") {
        //  ref(indexListProvider).bottomMenu(1);
        await fetchPosGroupSymbol(name, isCreateGrp);

        Navigator.pop(c);
      } else {
        Fluttertoast.showToast(
            msg: "${_groupName!.status}",
            timeInSecForIosWeb: 2,
            backgroundColor: colors.colorBlack,
            textColor: colors.colorWhite,
            fontSize: 14.0);
      }
    } finally {
      toggleLoadingOn(false);
    }
  }

// Fetching data from the api and stored in a variable
  Future fetchAddGroupSymbol(String name, BuildContext c, Map data) async {
    try {
      _groupName = await api.addGroupNameSymbol(name, data);

      if (_groupName!.status == "symbol added") {
        await fetchPosGroupSymbol(name, true);
        Fluttertoast.showToast(
            msg: "Scrip was added to $name",
            timeInSecForIosWeb: 2,
            backgroundColor: colors.colorBlack,
            textColor: colors.colorWhite,
            fontSize: 14.0);
        Navigator.pop(c);
      } else {
        Fluttertoast.showToast(
            msg: "${_groupName!.status} to $name",
            timeInSecForIosWeb: 2,
            backgroundColor: colors.colorBlack,
            textColor: colors.colorWhite,
            fontSize: 14.0);
      }
    } catch (e) {}
  }

// Fetching data from the api and stored in a variable
  Future fetchDeleteGroupName(String name, BuildContext c) async {
    try {
      toggleLoadingOn(true);
      _groupName = await api.deletePositionGrpName(name);

      if (_groupName!.status == "Data deleted") {
        await fetchPosGroupSymbol(name, true);

        // Navigator.pop(c);
      } else {
        Fluttertoast.showToast(
            msg: "${_groupName!.status}",
            timeInSecForIosWeb: 2,
            backgroundColor: colors.colorBlack,
            textColor: colors.colorWhite,
            fontSize: 14.0);
      }
    } finally {
      toggleLoadingOn(false);
    }
  }

// Fetching data from the api and stored in a variable
  Future fetchDeleteGroupSymbol(
      String name, BuildContext c, String tsym) async {
    try {
      _groupName = await api.deletePositionGrpSym(name, tsym);

      if (_groupName!.status == "symbol removed") {
        await fetchPosGroupSymbol(name, false);

        Fluttertoast.showToast(
            msg: "Group symbol $tsym was deleted",
            timeInSecForIosWeb: 2,
            backgroundColor: colors.colorBlack,
            textColor: colors.colorWhite,
            fontSize: 14.0);
        Navigator.pop(c);
      } else {
        Fluttertoast.showToast(
            msg: "${_groupName!.status}",
            timeInSecForIosWeb: 2,
            backgroundColor: colors.colorBlack,
            textColor: colors.colorWhite,
            fontSize: 14.0);
      }
    } catch (e) {}
  }

// updating Holings data from websocket
  void updateHoldingValues(String token, Map<String, dynamic> socketData) {
    var index = _holdingsModel!
        .indexWhere((holding) => holding.exchTsym![0].token == token);

    if (index != -1) {
      var holding = _holdingsModel![index];

      holding.exchTsym![0].lp = "${socketData['lp'] ?? 0.00}";
      holding.exchTsym![0].perChange = "${socketData['pc'] ?? 0.00}";
      holding.exchTsym![0].close = "${socketData['c'] ?? 0.00}";

      // Calculate current value, invested, and P&L
      holding.currentValue = (int.parse("${holding.currentQty ?? 0}") *
              double.parse("${holding.exchTsym![0].lp ?? 0.0}"))
          .toStringAsFixed(2);

      double avgCost = double.parse(
          "${holding.upldprc == "0.00" ? holding.exchTsym![0].close ?? 0.0 : holding.upldprc ?? 0.00}");
      holding.invested = (holding.currentQty! * avgCost).toStringAsFixed(2);

      holding.exchTsym![0].pNlChng = holding.invested == "0.00"
          ? "0.00"
          : ((double.parse("${holding.exchTsym![0].profitNloss}") /
                      double.parse("${holding.invested ?? 0.00}")) *
                  100)
              .toStringAsFixed(2)
              .toString();

      holding.exchTsym![0].oneDayChg =
          ((double.parse(holding.exchTsym![0].lp ?? "0.00") -
                      double.parse(holding.exchTsym![0].close ?? "0.00")) *
                  int.parse("${holding.currentQty ?? 0}"))
              .toStringAsFixed(2);

      if (holding.currentQty == 0) {
        double sellAmt = double.parse(holding.sellAmt ?? "0.00");
        int usedQty = int.parse(holding.usedqty ?? "0");
        double price = (sellAmt / usedQty);
        double pnl = price - double.parse(holding.upldprc ?? "0.0");
        holding.exchTsym![0].profitNloss = (pnl * usedQty).toStringAsFixed(2);
      } else {
        holding.exchTsym![0].profitNloss =
            (double.parse(holding.currentValue ?? "0.00") -
                    double.parse(holding.invested ?? "0.00"))
                .toStringAsFixed(2);
      }

      notifyListeners();
    }
  }
}
