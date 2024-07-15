import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../models/order_book_model/place_order_model.dart';
import '../models/portfolio_model/holdings_model.dart';
import '../models/portfolio_model/mf_holdings_model.dart';
import '../models/portfolio_model/mf_quotes.dart';
import '../models/portfolio_model/position_book_model.dart';
import '../models/portfolio_model/position_convertion_model.dart';
import '../routes/route_names.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'order_provider.dart';
import 'websocket_provider.dart';

final portfolioProvider =
    ChangeNotifierProvider((ref) => PortfolioProvider(ref.read));

class PortfolioProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
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
  changeTabIndex(int index) {
    _selectedTab = index;
  }

  tabSize() {
    _portTabName = [
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text(
                "Positions ${_allPostionList.isNotEmpty ? "(${_allPostionList.length})" : ""}"),
          ])),
      Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "Holdings ${_holdingsModel!.isNotEmpty ? "(${_holdingsModel!.length})" : ""}")
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

  showHoldSearch(bool value) {
    _showSearchHold = value;
    if (!_showSearchHold) {
      _holdingSearchItem = [];
    }
    notifyListeners();
  }

  showPositionSearch(bool value) {
    _showSearchPosition = value;
    if (!_showSearchPosition) {
      _positionSearchItem = [];
    }
    positionSearchCtrl.clear();
    notifyListeners();
  }

  clearHoldSearch() {
    holdingSearchCtrl.clear();
    _holdingSearchItem = [];

    notifyListeners();
  }

  clearPositionSearch() {
    positionSearchCtrl.clear();
    _positionSearchItem = [];

    notifyListeners();
  }

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
  showHoldMFSearch(bool value) {
    _showSearchHoldMF = value;
    if (!_showSearchHoldMF) {
      _mfHoldingSearchItem = [];
    }
    notifyListeners();
  }

  clearHoldMFSearch() {
    holdingMFSearchCtrl.clear();
    _mfHoldingSearchItem = [];

    notifyListeners();
  }

  MFQuotes? _mfQuotes;
  MFQuotes? get mfQuotes => _mfQuotes;

  String _totPnlHoldings = "0.00";
  String get totPnlHoldings => _totPnlHoldings;

  setPnlHoldings(String val) {
    _totPnlHoldings = val;
  }

  Future fetchHoldings(context, String initail) async {
    double invest = 0.0;
    try {
      final localstorage = await SharedPreferences.getInstance();
      toggleLoadingOn(true);

      _holdingsModel = [];
      _holdingsModel = await api.getHolding();
      _totInvesHold = "0.00";
      _totPnlPercHolding = "0.00";
      _totalPnlHolding = 0.00;
      _totalCurrentVal = 0.00;
      _oneDayChng = 0.00;
      _showEdis = false;
      _sealableHoldings = [];
      _nonSealableHoldings = [];

      tabSize();
      if (_holdingsModel!.isNotEmpty) {
        if (_holdingsModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;
          _holdingsModel!.sort(
              (a, b) => a.exchTsym![0].tsym!.compareTo(b.exchTsym![0].tsym!));

          for (var element in _holdingsModel!) {
            element.isExitHoldings = false;
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
                int.parse("${element.usedqty}");
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
          if (initail == "Refresh") {
            requestWSHoldings(isSubscribe: true, context: context);
          }

          _totInvesHold = invest.toStringAsFixed(2);

          log("tot invest $_totInvesHold ");
        } else {
          if (_holdingsModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _holdingsModel![0].stat == "Not_Ok") {
            ConstantName.sessCheck = false;
            ref(authProvider).loginMethCtrl.text =
                localstorage.getString("userId") ?? "";
            ConstantName.timer!.cancel();
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(errorSnackBar('${_holdingsModel![0].emsg}'));
            Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                arguments: "deviceLogin",
                (route) => false);
          }
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

  Future fetchMFHoldings(context) async {
    try {
      final localstorage = await SharedPreferences.getInstance();
      toggleLoadingOn(true);

      // _mfHoldingsModel = [];
      _mfHoldingsModel = await api.getMFHolding();
      _mfTotInveest = 0.00;
      _mfTotCurrentVal = 0.00;
      _mfTotalPnl = 0.00;
      _mfTotalPnlPerchng = 0.00;
      tabSize();
      if (_mfHoldingsModel!.isNotEmpty) {
        if (_mfHoldingsModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;

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
            ConstantName.sessCheck = false;
            ref(authProvider).loginMethCtrl.text =
                localstorage.getString("userId") ?? "";
            ConstantName.timer!.cancel();
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(errorSnackBar('${_holdingsModel![0].emsg}'));
            Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                arguments: "deviceLogin",
                (route) => false);
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
    } finally {
      toggleLoadingOn(false);
    }
  }

  // holdingCalc(String token, String ltp) {
  //   _totalCurrentVal = 0.00;
  //   _oneDayChng = 0.00;

  //   double totPnl = 0.00;
  //   if (_holdingsModel!.isNotEmpty) {
  //     if (_holdingsModel![0].stat != "Not_Ok") {
  //       // for (var element in _holdingsModel!) {
  //       // int qty = (int.parse(
  //       //         "${element.npoadqty ?? element.brkcolqty ?? element.npoadt1qty??element.holdqty}")) -
  //       //     int.parse("${element.usedqty}");

  //       // if (socketDatas.containsKey(element.exchTsym![0].token)) {
  //       //   element.exchTsym![0].lp =
  //       //       "${socketDatas["${element.exchTsym![0].token}"]['lp']}";

  //       //   element.exchTsym![0].perChange =
  //       //       "${socketDatas["${element.exchTsym![0].token}"]['pc']}";

  //       //   element.exchTsym![0].close =
  //       //       "${socketDatas["${element.exchTsym![0].token}"]['c']}";
  //       // }
  //       // int qty = (int.parse("${element.npoadqty ?? 0}") +
  //       //         int.parse("${element.brkcolqty ?? 0}") +
  //       //         int.parse("${element.npoadt1qty ?? 0}") +
  //       //         int.parse("${element.holdqty ?? 0}") +
  //       //         int.parse("${element.btstqty ?? 0}")) -
  //       //     int.parse("${element.usedqty}");
  //       // element.currentQty = qty;
  //       // double avgCost = double.parse(
  //       //     "${element.upldprc == "0.00" ? element.exchTsym![0].close ?? 0.0 : element.upldprc ?? 0.00}");

  //       // element.saleableQty = (int.parse("${element.holdqty ?? 0}") +
  //       //         int.parse("${element.dpQty ?? 0}") +
  //       //         int.parse("${element.btstqty ?? 0}")) -
  //       //     int.parse("${element.usedqty ?? 0}");
  //       // element.invested = (qty * avgCost).toStringAsFixed(2);

  //       // invest += double.parse("${element.invested}");
  //       // for (var ele in element.exchTsym!) {

  //       // double lastPrice = double.parse(ltp);

  //       // element.exchTsym![0].profitNloss =
  //       //     ((lastPrice - double.parse(element.avgPrc ?? "0.00")) *
  //       //             int.parse("${element.currentQty ?? 0}"))
  //       //         .toStringAsFixed(2)
  //       //         .toString();
  //       // double closePrice =
  //       //     double.parse("${element.exchTsym![0].close ?? 0.0}");

  //       // element.exchTsym![0].pNlChng = element.invested == "0.00"
  //       //     ? "0.00"
  //       //     : ((double.parse("${element.exchTsym![0].profitNloss}") /
  //       //                 double.parse("${element.invested ?? 0.00}")) *
  //       //             100)
  //       //         .toStringAsFixed(2)
  //       //         .toString();
  //       // element.exchTsym![0].oneDayChg = ((lastPrice - closePrice) *
  //       //         int.parse("${element.currentQty ?? 0}"))
  //       //     .toStringAsFixed(2);
  //       // totPnl+=
  //       //           double.parse("${element.exchTsym![0].profitNloss}");
  //       //       _oneDayChng += double.parse("${element.exchTsym![0].oneDayChg??0.00}");

  //       //       // element.currentValue = (int.parse("${element.currentQty ?? 0}") *
  //       //       //         double.parse("${element.exchTsym![0].lp ?? 0.0}"))
  //       //       //     .toStringAsFixed(2);
  //       //       _totalCurrentVal += double.parse(element.currentValue??"0.00");

  //       // }
  //       // }
  //       _totalPnlHolding = totPnl;
  //       _totPnlPercHolding = _totInvesHold == "0.00"
  //           ? "0.00"
  //           : ((double.parse("$_totalPnlHolding") /
  //                       double.parse(_totInvesHold)) *
  //                   100)
  //               .toStringAsFixed(2);

  //       _oneDayChngPer = ((_oneDayChng / _totalCurrentVal) * 100);
  //       // _totPnlPercHolding = totPnlPercHolding;

  //       print("sdfs ${_totalPnlHolding}");
  //     }
  //   }
  //   // notifyListeners();
  // }

  pnlHoldCal() {
    if (_holdingsModel!.isNotEmpty) {
      if (_holdingsModel![0].stat != "Not_Ok") {
        _totalCurrentVal = _holdingsModel!.fold(0,
            (sum, next) => sum + double.parse("${next.currentValue ?? 0.00}"));
        _totalPnlHolding = _holdingsModel!.fold(
            0,
            (sum, next) =>
                sum + double.parse("${next.exchTsym![0].profitNloss ?? 0.00}"));
        _oneDayChng = _holdingsModel!.fold(
            0,
            (sum, next) =>
                sum + double.parse("${next.exchTsym![0].oneDayChg ?? 0.00}"));
        _totPnlPercHolding = _totInvesHold == "0.00"
            ? "0.00"
            : ((double.parse("$_totalPnlHolding") /
                        double.parse(_totInvesHold)) *
                    100)
                .toStringAsFixed(2);

        _oneDayChngPer = ((_oneDayChng / _totalCurrentVal) * 100);
      }
    }
  }

  Future fetchPositionBook(BuildContext context, bool isDay) async {
    try {
      final localstorage = await SharedPreferences.getInstance();
      toggleLoadingOn(true);
      _postionBookModel = [];
      _allPostionList = [];
      _totPnL = "0.00";
      _totMtm = "0.00";
      _exitAll = false;
      _postionBookModel = await api.getPositionBook();
      // splitPositionBook(isDay);
      if (_postionBookModel!.isNotEmpty) {
        if (_postionBookModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;
          _isDay = isDay;
          await splitPositionBook(isDay);

          // await requestWSPosition(context: context, isSubscribe: true);
        } else {
          _openPosition = [];
          if (_postionBookModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _postionBookModel![0].stat == "Not_Ok") {
            ConstantName.sessCheck = false;
            ref(authProvider).loginMethCtrl.text =
                localstorage.getString("userId") ?? "";
            ConstantName.timer!.cancel();
            // ScaffoldMessenger.of(context)
            //     .showSnackBar(errorSnackBar('${_postionBookModel![0].emsg}'));
            Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                arguments: "deviceLogin",
                (route) => false);
          }
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
          ConstantName.sessCheck = false;
          ConstantName.timer!.cancel();
          Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.loginScreen,
              arguments: "login",
              (route) => false);
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
    if (_postionBookModel!.isNotEmpty) {
      _closedPosion = [];
      double totBuyAmts = 0.00;
      double totSellAmts = 0.00;
      _allPostionList = [];

      _openPosition = [];
      for (var element in _postionBookModel!) {
        element.isExitSelection = false;

        if (element.netqty == "0") {
          _closedPosion!.add(element);
          _closedPosion!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
        } else {
          _exitAll = true;
          _openPosition!.add(element);
          _openPosition!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
        }

        totBuyAmts += double.parse(element.totbuyamt ?? "0.00");
        totSellAmts += double.parse(element.totsellamt ?? "0.00");

        Map spilitSymbol = spilitTsym(value: "${element.tsym}");

        element.symbol = "${spilitSymbol["symbol"]}";
        element.expDate = "${spilitSymbol["expDate"]}";
        element.option = "${spilitSymbol["option"]}";
      }

      _totBuyAmt = totBuyAmts.toStringAsFixed(2);
      _totSellAmt = totSellAmts.toStringAsFixed(2);

      _netVal = (double.parse(_totBuyAmt) - double.parse(_totSellAmt))
          .toStringAsFixed(2);
      for (var element in _openPosition!) {
        if (isDay) {
          if (element.daybuyqty != "0" || element.daysellqty != "0") {
            _allPostionList.add(element);
          }
        } else {
          _allPostionList.add(element);
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

      // await allPositionPnl(isDay);
      await positionCal(isDay);
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
      final localstorage = await SharedPreferences.getInstance();

      // _placeOrderModel = await api.getPlaceOrder(placeOrderInput);

      if (_placeOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        if (isPosition) {
          await fetchPositionBook(context, _isDay);
        } else {
          await fetchHoldings(context, "Refresh");
        }

        // ref(orderProvider).fetchOrderBook(context, false);

        ref(indexListProvider).bottomMenu(1);
        Navigator.pop(context);
      } else {
        if (_placeOrderModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _placeOrderModel!.stat == "Not_Ok") {
          ConstantName.sessCheck = false;
          ref(authProvider).loginMethCtrl.text =
              localstorage.getString("userId") ?? "";
          ConstantName.timer!.cancel();
          Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.loginScreen,
              arguments: "deviceLogin",
              (route) => false);
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "${_placeOrderModel!.emsg}"));
      }

      return _placeOrderModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Place Order", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  positionCal(bool isDay) {
    double totalMtm = 0.00;
    double totalPnl = 0.00;
    double unRealMtm = 0.00;
    double bookPnl = 0.00;

    int qty = 0;

    double avgPrc = 0.00;

    String pnl = "0.00";
    for (var element in _allPostionList) {
      double lastPrice =
          double.parse(element.lp == null ? "0.00" : "${element.lp}");
      if (isDay) {
        element.avgPrc = element.netqty == "0" ? "0.00" : element.dayavgprc;

        avgPrc = double.parse(element.avgPrc ?? "0.00");
        qty = (int.parse("${element.daybuyqty ?? 0}") -
            int.parse("${element.daysellqty ?? 0}"));

        element.qty = "$qty";

        if (qty != 0) {
          pnl = element.netqty == "0"
              ? (double.parse("${element.totsellamt ?? 0.00}") -
                      double.parse("${element.totbuyamt ?? 0.00}"))
                  .toStringAsFixed(2)
              : (element.exch == "MCX" || element.exch == "CDS")
                  ? ((lastPrice - avgPrc) *
                          (int.parse("${element.mult ?? 0}") * qty))
                      .toStringAsFixed(2)
                  : ((lastPrice - avgPrc) * qty).toStringAsFixed(2);

          element.profitNloss = pnl;

          unRealMtm += double.parse(element.profitNloss!);
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
              (lastPrice - double.parse(element.netavgprc ?? "0.00")) * qty;

          element.mTm = qty != 0 ? value.toStringAsFixed(2) : "${element.rpnl}";

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
            } else {
              element.profitNloss = element.rpnl;
            }

            // print(" 34 ${element.profitNloss}");
          } else {
            element.profitNloss = ((lastPrice -
                        double.parse(
                            "${element.upldprc == "0.00" ? element.avgPrc : element.upldprc}")) *
                    qty)
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

  requestWSPosition(
      {required bool isSubscribe, required BuildContext context}) {
    String input = "";
    if (_postionBookModel!.isNotEmpty &&
        _postionBookModel![0].stat != "Not_Ok") {
      for (var element in _postionBookModel!) {
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

  requestWSHoldings(
      {required bool isSubscribe, required BuildContext context}) {
    String input = "";

    if (_holdingsModel!.isNotEmpty) {
      if (_holdingsModel![0].stat != "Not_Ok") {
        for (var i = 0; i < _holdingsModel!.length; i++) {
          // for (var j = 0; j < _holdingsModel![i].exchTsym!.length; j++) {
          // if (_holdingsModel![i].exchTsym![j].exch == 'NSE' ) {
          input +=
              "${_holdingsModel![i].exchTsym![0].exch}|${_holdingsModel![i].exchTsym![0].token}#";
          // }
          // }
        }
      }
    }
    if (input.isNotEmpty) {
      // ConstantName.lastSubscribe = input;
      ref(websocketProvider).establishConnection(
          channelInput: input, task: isSubscribe ? "t" : "u", context: context);
    }
  }

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
    }

    notifyListeners();
  }

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
    }

    notifyListeners();
  }

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

  exitAllPosition(BuildContext context, bool isSelectionExit) async {
    for (var element in _allPostionList) {
      if (element.qty != "0") {
        if (((element.sPrdtAli == "MIS" || element.sPrdtAli == "CNC") ||
            element.sPrdtAli == "NRML")) {
          if (isSelectionExit) {
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
                      : "${ref(authProvider).deviceInfo["model"]}",
                  userAgent: defaultTargetPlatform == TargetPlatform.android
                      ? '${ref(authProvider).deviceInfo["model"]}'
                      : "${ref(authProvider).deviceInfo["name"]}",
                  appInstaId: defaultTargetPlatform == TargetPlatform.android
                      ? '${ref(authProvider).deviceInfo["id"]}'
                      : "${ref(authProvider).deviceInfo["identifierForVendor"]}");
              await fetchExitPosition(context, placeOrderInput, true);
            }
          } else {
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
                    : "${ref(authProvider).deviceInfo["model"]}",
                userAgent: defaultTargetPlatform == TargetPlatform.android
                    ? '${ref(authProvider).deviceInfo["model"]}'
                    : "${ref(authProvider).deviceInfo["name"]}",
                appInstaId: defaultTargetPlatform == TargetPlatform.android
                    ? '${ref(authProvider).deviceInfo["id"]}'
                    : "${ref(authProvider).deviceInfo["identifierForVendor"]}");
            await ref(orderProvider)
                .fetchPlaceOrder(context, placeOrderInput, true);
          }
        }
      }
    }
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
              : "${ref(authProvider).deviceInfo["model"]}",
          userAgent: defaultTargetPlatform == TargetPlatform.android
              ? '${ref(authProvider).deviceInfo["model"]}'
              : "${ref(authProvider).deviceInfo["name"]}",
          appInstaId: defaultTargetPlatform == TargetPlatform.android
              ? '${ref(authProvider).deviceInfo["id"]}'
              : "${ref(authProvider).deviceInfo["identifierForVendor"]}");
      await fetchExitPosition(context, placeOrderInput, false);
    }
  }

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

  positionSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _positionSearchItem = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _positionSearchItem = _allPostionList
          .where((element) => element.tsym!.toLowerCase().contains(value))
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
}
