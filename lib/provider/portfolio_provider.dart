import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';

import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/camsres_model.dart';
import '../models/order_book_model/place_order_model.dart';
import '../models/portfolio_model/holdings_model.dart';
import '../models/portfolio_model/mf_holdings_model.dart';
import '../models/portfolio_model/mf_quotes.dart';
import '../models/portfolio_model/position_book_model.dart';
import '../models/portfolio_model/position_convertion_model.dart';

import '../models/portfolio_model/position_group_model.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

import 'websocket_provider.dart';

final portfolioProvider =
    ChangeNotifierProvider((ref) => PortfolioProvider(ref));

class PortfolioProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final FToast _fToast = FToast();
  FToast get fToast => _fToast;
  final Ref ref;
  late TabController portTab;
  final TextEditingController holdingSearchCtrl = TextEditingController();
  final TextEditingController holdingMFSearchCtrl = TextEditingController();
  final TextEditingController positionSearchCtrl = TextEditingController();

  List<HoldingsModel>? _tholdingsModel = [];

  List<HoldingsModel>? _holdingsModel = [];
  List<HoldingsModel>? get holdingsModel => _holdingsModel;

  List<HoldingsModel>? _holdingSearchItem = [];
  List<HoldingsModel>? get holdingSearchItem => _holdingSearchItem;
  List<HoldingsModel> _sealableHoldings = [];
  List<HoldingsModel> get sealableHoldings => _sealableHoldings;
  List<HoldingsModel> _nonSealableHoldings = [];
  List<HoldingsModel> get nonSealableHoldings => _nonSealableHoldings;

  List<PositionBookModel>? _tpostionBookModel = [];

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

  Map<String, dynamic> _allholds = {};
  Map<String, dynamic> get allholds => _allholds;

  Camsmodel? _camsrespons;
  Camsmodel? get camsrespons => _camsrespons;

  String _ldate = "";
  String get ldate => _ldate;

  String _subscr = "";
  String get subscr => _subscr;

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
    const Tab(text: "Holdings"),
    const Tab(text: "Orders"),
    const Tab(text: "Funds")
  ];
  List<Tab> get portTabName => _portTabName;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  bool _posloader = false;
  bool get posloader => _posloader;

  bool _holdloader = false;
  bool get holdloader => _holdloader;

  bool _mfhloader = false;
  bool get mfhloader => _mfhloader;

  bool _tphloader = false;
  bool get tphloader => _tphloader;

  // Navigation locks to prevent duplicate actions
  bool _isFilterNavigating = false;
  bool get isFilterNavigating => _isFilterNavigating;

  void setFilterNavigating(bool value) {
    _isFilterNavigating = value;
    notifyListeners();
  }

// Position Grouping -----------

  Map _groupedBySymbol = {};
  Map get groupedBySymbol => _groupedBySymbol;

  // Map<String, dynamic> _positionGroup = {};
  // Map get positionGroup => _positionGroup;
  List<String> _groupPositionSym = [];
  List<String> get groupPositionSym => _groupPositionSym;
  List _oplists = [];
  List get oplists => _oplists;

  String _posSelection = "All position";

  String get posSelection => _posSelection;

  final List<String> _posGrpNames = ["All position", "Group by symbol"];

  List<String> get posGrpNames => _posGrpNames;

  List<GetGroupSymbol> _getPositionGroupSymbol = [];
  List<GetGroupSymbol> get getPositionGroupSymbol => _getPositionGroupSymbol;

  CreateGroupName? _groupName;
  CreateGroupName? get groupName => _groupName;

// change selected portfolio tab name

  clearAllportfolio() {
    _holdingsModel = [];
    _tholdingsModel = [];
    _postionBookModel = [];
    _tpostionBookModel = [];
    _allholds = {};
    _mfHoldingsModel = [];
    _allPostionList = [];
    _openPosition = [];
    _closedPosion = [];
    _holdingSearchItem = [];
    _positionSearchItem = [];
    _subscr = "";
    _mfTotInveest = 0.00;
    _mfTotCurrentVal = 0.00;
    _mfTotalPnl = 0.00;
    _mfTotalPnlPerchng = 0.00;
    _getPositionGroupSymbol = [];

    // Reset any timer or ongoing operations
    cancelTimer();

    notifyListeners();
  }

  changeTabIndex(int index) {
    _selectedTab = index;
    print("selectedTab: $index");
    notifyListeners();
  }

  chngPosSelection(String val) {
    _posSelection = val;
    notifyListeners();
  }

//  Assinging and portfolio name length set

  fetchBrokerDetails(
      BuildContext context, bool isSubscribe, bool consent) async {
    try {
      _tphloader = true;
      var res = await api.getallHolding();
      if (res.equities.isNotEmpty) {
        var one = res.equities;
        one.forEach((key, value) {
          for (var two in value['summary']) {
            _subscr += "${two['exch']}|${two['token']}#";
            two['totinv'] = (double.tryParse(two['lastTradedPrice']) ?? 0.0) *
                (double.tryParse("${two['units']}") ?? 0.0);
          }
        });
        requestallHoldings(isSubscribe: isSubscribe, context: context);
        _allholds = res.equities;
        _ldate = res.syncDatetime;
      } else {
        if (consent) {
          Future.delayed(const Duration(seconds: 2), () {
            ScaffoldMessenger.of(context)
                .showSnackBar(warningMessage(context, "Unable to fetch data"));
          });
        }
        _allholds = {};
      }
      notifyListeners();
    } catch (e) {
      print('Error: $e');
    } finally {
      _tphloader = false;
    }
  }

  Future fetchCamRedirct(BuildContext context) async {
    try {
      toggleLoadingOn(true);
      _camsrespons = await api.getcamsapi();
      Navigator.pushNamed(context, Routes.camsWebView,
          arguments: _camsrespons!.redirectionurl);
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "Fetch API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  // tabSize(theme) {
  //   _portTabName = [
  //     Tab(
  //         child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //           TextWidget.subText(
  //               text:
  //                   "Position${_allPostionList.isNotEmpty ? "s (${_allPostionList.length})" : ""}",
  //               theme: false,
  //               color: selectedTab == 0
  //                   ? theme.isDarkMode
  //                       ? colors.secondaryDark
  //                       : colors.secondaryLight
  //                   : theme.isDarkMode
  //                       ? colors.textSecondaryDark
  //                       : colors.textSecondaryLight,
  //               fw: selectedTab == 0 ? 0 : null)
  //         ])),
  //     Tab(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           TextWidget.subText(
  //               text:
  //                   "Holding${_holdingsModel!.isNotEmpty ? "s (${_holdingsModel!.length})" : ""}",
  //               theme: false,
  //               color: selectedTab == 1
  //                   ? theme.isDarkMode
  //                       ? colors.secondaryDark
  //                       : colors.secondaryLight
  //                   : theme.isDarkMode
  //                       ? colors.textSecondaryDark
  //                       : colors.textSecondaryLight,
  //               fw: selectedTab == 1 ? 0 : null)
  //         ],
  //       ),
  //     ),
  //     // if (_mfHoldingsModel!.isNotEmpty) ...[
  //     //   if (_mfHoldingsModel![0].stat != "Not_Ok") ...[
  //     Tab(
  //       child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             TextWidget.subText(
  //                 text: "Orders",
  //                 theme: false,
  //                 color: selectedTab == 2
  //                     ? theme.isDarkMode
  //                         ? colors.secondaryDark
  //                         : colors.secondaryLight
  //                     : theme.isDarkMode
  //                         ? colors.textSecondaryDark
  //                         : colors.textSecondaryLight,
  //                 fw: selectedTab == 2 ? 0 : null)
  //           ]),
  //     ),
  //     Tab(
  //       child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             TextWidget.subText(
  //                 text: "Funds",
  //                 theme: false,
  //                 color: selectedTab == 3
  //                     ? theme.isDarkMode
  //                         ? colors.secondaryDark
  //                         : colors.secondaryLight
  //                     : theme.isDarkMode
  //                         ? colors.textSecondaryDark
  //                         : colors.textSecondaryLight,
  //                 fw: selectedTab == 3 ? 0 : null)
  //           ]),
  //     ),
  //   ];

  //   notifyListeners();
  // }

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
    _showSearchPosition = false;

    notifyListeners();
  }

// Show position PNL / MTM value

  chngPositionPnl(bool value) {
    _isNetPnl = value;
    // Recalculate values after changing the PnL/MTM display mode
    positionCal(_isDay);
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

  Future<void> setPortfolioupdate(String mode) async {
    var result;
    if (mode == 'H') {
      result = await api.getHolding();
      if (result['stat'] == 'success') {
        _tholdingsModel = result['data'];
      } else {
        if (result['stat'] == 'no data') {
          _holdingsModel = [];
        }
        _tholdingsModel = [];
      }
    } else if (mode == 'P') {
      result = await api.getPositionBook();
      if (result['stat'] == 'success') {
        _tpostionBookModel = result['data'];
      } else {
        if (result['stat'] == 'no data') {
          _postionBookModel = [];
        }
        _tpostionBookModel = [];
      }
    }

    // var result;
    //   if (mode == 'H') {
    //     result = await api.getHolding();
    //   } else if (mode == 'P') {
    //     result = await api.getPositionBook();
    //   }

    // if (result['stat'] == 'no data') {
    //   if (mode == 'H') {
    //     _holdingsModel = [];
    //     _tholdingsModel = [];
    //   } else if (mode == 'P') {
    //     _postionBookModel = [];
    //     _tpostionBookModel = [];
    //   }
    // } else if (result['stat'] == 'success') {
    //   if (mode == 'H') {
    //     _tholdingsModel = result['data'];
    //   } else if (mode == 'P') {
    //     _tpostionBookModel = result['data'];
    //   }
    // } else if (result['stat'] == 'error') {
    //   if (mode == 'H') {
    //     _tholdingsModel = [];
    //   } else if (mode == 'P') {
    //     _tpostionBookModel = [];
    //   }
    // }
    print("qwqwqw prov alert btm $mode , ${result['stat']}");
  }

  Future fetchHoldings(context, String initail) async {
    final theme = ref.read(themeProvider);
    double invest = 0.0;
    try {
      await setPortfolioupdate('H');
      // if (_holdingsModel!.isNotEmpty) {
      //   if (_tholdingsModel!.isNotEmpty) {
      //     _holdingsModel = _tholdingsModel;
      //   }
      // If holdings exist, merge new data with existing
      if (_holdingsModel!.isNotEmpty && _tholdingsModel!.isNotEmpty) {
        // Merge each element instead of complete reset
        for (var newHolding in _tholdingsModel!) {
          final index = _holdingsModel!.indexWhere((oldHolding) =>
              oldHolding.exchTsym![0].token == newHolding.exchTsym![0].token);
          if (index != -1) {
            // Update only changed fields
            _holdingsModel![index].updateFrom(newHolding);
          } else {
            _holdingsModel!.add(newHolding);
          }
        }
      } else {
        _holdloader = true;
        _oneDayChngPer = 0.00;
        _showSearchHold = false;
        _totInvesHold = "0.00";
        _totPnlPercHolding = "0.00";
        _totalPnlHolding = 0.00;
        _totalCurrentVal = 0.00;
        _oneDayChng = 0.00;
        _showEdis = false;
        _sealableHoldings = [];
        _nonSealableHoldings = [];
        _holdingsModel = _tholdingsModel;
      }

      pref.setScrip(true);
      pref.setPrice(true);
      pref.setPerchnage(true);
      pref.setqty(true);
      pref.setInvestby(true);
      // tabSize(theme);
      if (_holdingsModel!.isNotEmpty) {
        if (_holdingsModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;

// Sorting Holdings data Trade symbol wise A to Z

          _holdingsModel!.sort(
              (a, b) => a.exchTsym![0].tsym!.compareTo(b.exchTsym![0].tsym!));
          _sealableHoldings = [];
          _nonSealableHoldings = [];
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
                int.parse("${element.trdqty ?? 0}");
            element.currentQty = qty;
            ref
                .read(websocketProvider)
                .socketDatas["${element.exchTsym![0].token}"] = {'holdQty': ""};

            ref
                    .read(websocketProvider)
                    .socketDatas["${element.exchTsym![0].token}"]['holdQty'] =
                "${element.currentQty}";

            double avgCost = double.parse(
                "${element.upldprc == "0.00" ? element.exchTsym![0].close ?? 0.0 : element.upldprc ?? 0.00}");

            element.avgPrc = "${qty > 0 ? avgCost : 0.00}";
            String avgPrc = "$avgCost";
            element.invested = (qty * avgCost).toStringAsFixed(2);

            invest += double.parse("${element.invested}");
            if (element.npoadqty.toString() != "null" ||
                element.npoadt1qty.toString() != "null") {
              _showEdis = true;
            }

            element.saleableQty = (int.parse("${element.holdqty ?? 0}") +
                    int.parse("${element.dpQty ?? 0}") +
                    int.parse("${element.btstqty ?? 0}")) -
                int.parse("${element.usedqty ?? 0}");
            if (element.sellAmt != null && element.sellAmt != "0.000000") {
              element.rpnl = (double.parse("${element.sellAmt ?? 0.00}") -
                      ((double.parse("${element.trdqty ?? 0.00}")) *
                          (double.parse("${avgPrc ?? 0.00}"))))
                  .toStringAsFixed(2);
              // element.rpnl = (double.parse("${element.invested ?? 0.00}") - double.parse("${element.sellAmt ?? 0.00}")).toString();
            }

            if (element.saleableQty != 0) {
              _sealableHoldings.add(element);
            } else {
              _nonSealableHoldings.add(element);
            }
          }

          _totInvesHold = invest.toStringAsFixed(2);

          // Reapply sorting if previously set
          if (_currentHoldingSortOption.isNotEmpty) {
            await filterHoldings(
                sorting: _currentHoldingSortOption, context: context);
          }

          if (initail == "Refresh") {
            await requestWSHoldings(isSubscribe: true, context: context);
            // timerfunc();
          }
        } else {
          if (_holdingsModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _holdingsModel![0].stat == "Not_Ok") {
            ref.read(authProvider).ifSessionExpired(context);
          }
          // _holdingsModel = [];
        }
      }
      notifyListeners();
    } catch (e) {
      print("qwqwqw hold sw catch ${e}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Holdings", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {
      _holdloader = false;
    }
  }

  Future fetchPositionBook(BuildContext context, bool isDay) async {
    try {
      await setPortfolioupdate('P');
      if (_postionBookModel!.isNotEmpty) {
        if (_tpostionBookModel!.isNotEmpty) {
          _postionBookModel = _tpostionBookModel;
        }
      } else {
        _posloader = true;
        _allPostionList = [];
        _totPnL = "0.00";
        _totMtm = "0.00";
        _exitAll = false;
        _totBookedPnL = "0.00";
        _totUnRealMtm = '0.00';
        _posSelection = "All position";
        _postionBookModel = _tpostionBookModel;
      }

      pref.setPosScrip(true);
      pref.setPosPrice(true);
      pref.setPosPerchnage(true);
      pref.setPosqty(true);
      pref.setPostion(true);
      if (_postionBookModel!.isNotEmpty) {
        if (_postionBookModel![0].stat != "Not_Ok") {
          for (var i = 0; i < _postionBookModel!.length; i++) {
            var element = _postionBookModel?[i];
            int tempqty = (int.parse(element!.daybuyqty.toString()) +
                        int.parse(element.cfbuyqty.toString())) <
                    (int.parse(element.daysellqty.toString()) +
                        int.parse(element.cfsellqty.toString()))
                ? int.parse(element.daybuyqty.toString())
                : int.parse(element.daysellqty.toString());
            tempqty =
                (tempqty * double.parse(element.prcftr.toString())).toInt();
            double tempavg = int.parse(element.netqty.toString()) > 0
                ? double.parse(element.daysellavgprc.toString()) -
                    double.parse(element.netupldprc.toString())
                : double.parse(element.netupldprc.toString()) -
                    double.parse(element.daybuyavgprc.toString());

            _postionBookModel?[i].temppnl =
                "${double.parse(tempavg.toString()) * int.parse(tempqty.toString())}";
          }

          ConstantName.sessCheck = true;
          _isDay = isDay;
          await splitPositionBook(isDay);

          // Reapply sorting if previously set
          if (_currentPositionSortOption.isNotEmpty) {
            await sortPositions(sorting: _currentPositionSortOption);
          }

          // await requestWSPosition(context: context, isSubscribe: true);
        } else {
          //

          if (_postionBookModel![0].emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _postionBookModel![0].stat == "Not_Ok") {
            ref.read(authProvider).ifSessionExpired(context);
          }
          _openPosition = [];
          // _postionBookModel = [];
        }
      }
      notifyListeners();
      return _postionBookModel;
    } catch (e) {
      print("qwqwqw pos sw catch ${e}");
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Position Book", "Error": "$e"});
      notifyListeners();
    } finally {
      _posloader = false;
    }
  }

// Fetching data from the api and stored in a variable

  Future fetchMFHoldings(context) async {
    final theme = ref.read(themeProvider);
    try {
      _mfhloader = true;
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
      // tabSize(theme);
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
            ref.read(authProvider).ifSessionExpired(context);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API MF Holdings", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {
      _mfhloader = false;
    }
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
    // Early return if no holdings
    if (holdingsModel == null || holdingsModel!.isEmpty) return;

    // Use local variables for performance and minimize string conversions
    double totalPnl = 0.0;
    double dayChange = 0.0;
    double invest = 0.0;
    double currentVal = 0.0;

    // Process holdings in batches to reduce UI blocking
    const int batchSize = 10;
    final int totalHoldings = holdingsModel!.length;
    int processedCount = 0;

    void processBatch(int startIndex) {
      final int endIndex = (startIndex + batchSize) < totalHoldings
          ? startIndex + batchSize
          : totalHoldings;

      for (int i = startIndex; i < endIndex; i++) {
        final holding = holdingsModel![i];

        // Direct non-null access with fallbacks
        final profitNloss =
            double.tryParse(holding.exchTsym![0].profitNloss ?? '0.0') ?? 0.0;
        final oneDayChg =
            double.tryParse(holding.exchTsym![0].oneDayChg ?? '0.0') ?? 0.0;
        final invested = double.tryParse(holding.invested ?? '0.0') ?? 0.0;
        final currentValue =
            double.tryParse(holding.currentValue ?? '0.0') ?? 0.0;

        // Accumulate totals
        totalPnl += profitNloss;
        dayChange += oneDayChg;
        invest += invested;
        currentVal += currentValue;
      }

      processedCount = endIndex;

      // If there are more holdings to process, schedule next batch
      if (processedCount < totalHoldings) {
        Future.microtask(() => processBatch(processedCount));
      } else {
        // All batches processed, update class variables
        _totalPnlHolding = totalPnl;
        _oneDayChng = dayChange;
        _totalCurrentVal = currentVal;
        _totInvesHold = invest.toStringAsFixed(2);

        // Calculate percentages
        _oneDayChngPer = currentVal > 0 ? (dayChange / currentVal) * 100 : 0.0;
        _totPnlPercHolding = invest > 0
            ? ((totalPnl / invest) * 100).toStringAsFixed(2)
            : '0.00';

        notifyListeners();
      }
    }

    // Start processing in batches
    processBatch(0);
  }

  // Implement correct MTM and PnL calculations
  positionCal(bool isDay) {
    double totalMtm = 0.0;
    double totalPnl = 0.0;
    double unRealMtm = 0.0;
    double bookPnl = 0.0;

    for (var position in _allPostionList) {
      final lp = double.tryParse(position.lp ?? "0.00") ?? 0.0;
      final prcFtr = double.tryParse(position.prcftr ?? "1.0") ?? 1.0;
      final mult = double.tryParse(position.mult ?? "1.0") ?? 1.0;
      final lotSize = double.tryParse(position.ls ?? "1.0") ?? 1.0;
      final netQty = int.tryParse(position.netqty ?? "0") ?? 0;

      final dayBuyQty = int.tryParse(position.daybuyqty ?? "0") ?? 0;
      final daySellQty = int.tryParse(position.daysellqty ?? "0") ?? 0;
      final cfBuyQty = int.tryParse(position.cfbuyqty ?? "0") ?? 0;
      final cfSellQty = int.tryParse(position.cfsellqty ?? "0") ?? 0;

      final dayBuyAmt = double.tryParse(position.daybuyamt ?? "0.00") ?? 0.0;
      final daySellAmt = double.tryParse(position.daysellamt ?? "0.00") ?? 0.0;
      final upldPrc = double.tryParse(position.upldprc ?? "0.00") ?? 0.0;
      final netAvgPrc = double.tryParse(position.netavgprc ?? "0.00") ?? 0.0;
      final netUpldPrc = double.tryParse(position.netupldprc ?? "0.00") ?? 0.0;
      final rpnl = double.tryParse(position.rpnl ?? "0.00") ?? 0.0;

      // Net Buy/Sell Qty
      final netBuyQty = dayBuyQty + cfBuyQty;
      final netSellQty = daySellQty + cfSellQty;

      // --- Assign qty and avgPrc as per isDay ---
      int qty = 0;
      double avgPrc = 0.0;

      if (isDay) {
        // qty logic for day
        if (position.exch == "MCX") {
          qty = ((dayBuyQty - daySellQty) / lotSize).toInt();
        } else {
          qty = dayBuyQty - daySellQty;
        }
        position.qty = qty.toString();

        // avgPrc logic for day
        position.avgPrc = (netQty == 0 ? "0.00" : position.dayavgprc ?? "0.00");
        avgPrc = double.tryParse(position.avgPrc ?? "0.00") ?? 0.0;
      } else {
        // qty logic for net
        qty = netQty;
        position.qty = qty.toString();

        // avgPrc logic for net
        if (qty == 0) {
          position.avgPrc = "0.00";
        } else {
          // If netupldprc != 0, use that, else netavgprc
          position.avgPrc = (netUpldPrc != 0.0)
              ? netUpldPrc.toStringAsFixed(2)
              : netAvgPrc.toStringAsFixed(2);
        }
        avgPrc = double.tryParse(position.avgPrc ?? "0.00") ?? 0.0;
      }

      // ActualBuyAvgPrice (for BookedPNL calculation)
      double actualBuyAvgPrice = 0.0;
      if (netBuyQty != 0) {
        actualBuyAvgPrice =
            ((dayBuyAmt / mult) + (upldPrc * prcFtr * cfBuyQty)) / netBuyQty;
      }

      // ActualSellAvgPrice (for BookedPNL calculation)
      double actualSellAvgPrice = 0.0;
      if (netSellQty != 0) {
        actualSellAvgPrice =
            ((daySellAmt / mult) + (upldPrc * prcFtr * cfSellQty)) / netSellQty;
      }

      // ActualBookedPNL
      double actualBookedPnl = 0.0;
      if (netQty > 0) {
        actualBookedPnl =
            (actualSellAvgPrice - actualBuyAvgPrice) * netSellQty * mult;
      } else {
        actualBookedPnl =
            (actualSellAvgPrice - actualBuyAvgPrice) * netBuyQty * mult;
      }

      // For MTM, avgprc = netavgprc
      double actualUnrealizedMtm = netQty * prcFtr * mult * (lp - netAvgPrc);

      // For PnL, avgprc = netupldprc if not 0 else netavgprc
      double avgPrcForUnrealized = netUpldPrc != 0.0 ? netUpldPrc : netAvgPrc;
      double actualUnrealizedPnl =
          netQty * prcFtr * mult * (lp - avgPrcForUnrealized);

      // MTM = rpnl + ActualUnrealizedMtoM
      double mtm = rpnl + actualUnrealizedMtm;

      // PnL = ActualBookedPNL + ActualUnrealizedMtoM
      double pnl = actualBookedPnl + actualUnrealizedPnl;

      // Assign back to position
      position.mTm = mtm.toStringAsFixed(2);
      position.profitNloss = pnl.toStringAsFixed(2);

      // Totals
      totalMtm += mtm;
      totalPnl += pnl;
      unRealMtm += actualUnrealizedPnl;
      bookPnl += actualBookedPnl;
    }

    _totMtm = totalMtm.toStringAsFixed(2);
    _totPnL = totalPnl.toStringAsFixed(2);
    _totUnRealMtm = unRealMtm.toStringAsFixed(2);
    _totBookedPnL = bookPnl.toStringAsFixed(2);
    notifyListeners();
  }

  // websocket Connection Request for Position scrip
  requestWSPosition(
      {required bool isSubscribe, required BuildContext context}) {
    try {
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
        ref.read(websocketProvider).establishConnection(
            channelInput: input,
            task: isSubscribe ? "t" : "u",
            context: context);
      }
    } catch (e) {}

    // notifyListeners();
  }

// websocket Connection Request for Holdings scrip
  requestWSHoldings(
      {required bool isSubscribe, required BuildContext context}) {
    try {
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
        ref.read(websocketProvider).establishConnection(
            channelInput: input,
            task: isSubscribe ? "t" : "u",
            context: context);
      }
    } catch (e) {}
  }

  requestallHoldings(
      {required bool isSubscribe, required BuildContext context}) {
    try {
      if (_subscr.isNotEmpty) {
        ref.read(websocketProvider).establishConnection(
            channelInput: _subscr, task: 't', context: context);
      }
    } catch (e) {}
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
                    ? '${ref.read(authProvider).deviceInfo["brand"]}'
                    : "${ref.read(authProvider).deviceInfo["model"]}");
            _placeOrderModel = await api.getPlaceOrder(
                placeOrderInput, ref.read(orderProvider).ip);

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
    // Store the current sort option
    _currentHoldingSortOption = sorting;

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
    // Store the current sort option
    _currentPositionSortOption = sorting;

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
    // Set loading state to true at the beginning
    // if (exitAll) {
    //   _isExitingAll = true;
    //   notifyListeners();
    // }

    try {
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
                      ? '${ref.read(authProvider).deviceInfo["brand"]}'
                      : "${ref.read(authProvider).deviceInfo["model"]}");
              _placeOrderModel = await api.getPlaceOrder(
                  placeOrderInput, ref.read(orderProvider).ip);

              if (_placeOrderModel!.stat!.toLowerCase() != "ok") {
                break;
              }
            }
            if (!element.isExitSelection!) {
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
                      ? '${ref.read(authProvider).deviceInfo["brand"]}'
                      : "${ref.read(authProvider).deviceInfo["model"]}",
                  frzqty: ((int.parse(element.frzqty.toString()) /
                              int.parse(element.ls.toString()))
                          .floor() *
                      int.parse(element.ls.toString())));
              await fetchExitPosition(context, placeOrderInput, true, true);
            }
          }
        }
      }
    } finally {
      // Reset loading state when done (whether successful or not)
      // if (exitAll) {
      //   _isExitingAll = false;
      //   notifyListeners();
      // }
    }

    // ref.read(indexListProvider).bottomMenu(2);
    // Navigator.pop(context);
  }

  exitAllHoldings(BuildContext context) async {
    for (var element in _sealableHoldings) {
      // Only exit holdings that are selected
      if (element.isExitHoldings!) {
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
                ? '${ref.read(authProvider).deviceInfo["brand"]}'
                : "${ref.read(authProvider).deviceInfo["model"]}",
            frzqty: 0);
        await fetchExitPosition(context, placeOrderInput, false, false);
      }
    }
  }

// Holding search by Trade symbol
  holdingSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _holdingSearchItem = [];
      _holdingSearchItem = _holdingsModel!
          .where((element) => element.exchTsym![0].tsym!
              .toUpperCase()
              .contains(value.toUpperCase()))
          .toList();
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
      // _showSearchPosition = true;
      _positionSearchItem = [];
      _positionSearchItem = _allPostionList
          .where((element) =>
              element.tsym!.toLowerCase().contains(value.toLowerCase()) ||
              (element.symbol?.toLowerCase().contains(value.toLowerCase()) ??
                  false))
          .toList();
    } else {
      // _showSearchPosition = false;
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
      _posloader = true;
      _groupName = await api.createGroupName(name);

      if (_groupName!.status == "Data inserted") {
        //  ref.read(indexListProvider).bottomMenu(1);
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
      _posloader = false;
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
      _posloader = true;
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
      _posloader = false;
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

  // Optimized for fast updates from websocket
  void updateHoldingValues(String token, Map<String, dynamic> socketData) {
    // Early return if no token or data
    if (token == null || socketData == null || _holdingsModel == null) return;

    // Use indexWhere with efficient stopping
    var index = -1;
    for (int i = 0; i < _holdingsModel!.length; i++) {
      if (_holdingsModel![i].exchTsym![0].token == token) {
        index = i;
        break;
      }
    }

    if (index == -1) return; // Not found, nothing to update

    var holding = _holdingsModel![index];
    bool hasUpdates = false;

    // Get new values from socket data
    final newLp = socketData['lp']?.toString();
    final newPc = socketData['pc']?.toString();
    final newChng = socketData['chng']?.toString();
    final newClose = socketData['c']?.toString();

    // Only update if valid values are received
    if (_isValidValue(newLp)) {
      holding.exchTsym![0].lp = newLp;
      hasUpdates = true;
    }

    if (_isValidValue(newPc)) {
      holding.exchTsym![0].perChange = newPc;
      hasUpdates = true;
    }

    if (_isValidValue(newChng)) {
      holding.exchTsym![0].change = newChng;
      hasUpdates = true;
    }

    if (_isValidValue(newClose)) {
      holding.exchTsym![0].close = newClose;
      hasUpdates = true;
    }

    // Only recalculate if we've actually updated any values
    if (hasUpdates) {
      _updateDerivedValues(holding);
    }
  }

  // Helper method to check if a value is valid
  bool _isValidValue(String? value) {
    return value != null &&
        value != "null" &&
        value != "0" &&
        value != "0.0" &&
        value != "0.00";
  }

  // Helper method to update derived values
  void _updateDerivedValues(HoldingsModel holding) {
    final qty = holding.currentQty ?? 0;
    final usedqty = int.parse(holding.usedqty ?? "0");
    // if (qty <= 0) return; // Nothing to calculate for zero quantity

    final lpDouble = double.tryParse(holding.exchTsym![0].lp ?? '0.0') ?? 0.0;
    if (lpDouble <= 0) return; // Can't calculate with invalid price

    // Update current value
    holding.currentValue = (qty * lpDouble).toStringAsFixed(2);

    // Get average cost with fallback to closing price
    final closeVal =
        double.tryParse(holding.exchTsym![0].close ?? "0.00") ?? 0.0;
    final avgCost = double.tryParse(holding.upldprc == "0.00"
            ? (closeVal > 0
                ? closeVal.toString()
                : holding.exchTsym![0].close ?? '0.0')
            : holding.upldprc ?? '0.00') ??
        0.0;

    if (avgCost <= 0) return; // Can't calculate with invalid cost

    holding.invested = (qty * avgCost).toStringAsFixed(2);
    final investedValue = double.tryParse(holding.invested ?? '0.00') ?? 0.00;

    // Calculate profit/loss
    final currentValue = double.tryParse(holding.currentValue ?? "0.00") ?? 0.0;
    holding.exchTsym![0].profitNloss =
        (currentValue - investedValue).toStringAsFixed(2);

    // Calculate percentage change if invested amount exists
    if (investedValue > 0.0) {
      final profitValue =
          double.tryParse(holding.exchTsym![0].profitNloss ?? "0.00") ?? 0.0;
      holding.exchTsym![0].pNlChng =
          ((profitValue / investedValue) * 100).toStringAsFixed(2);
    }

    // Calculate one day change if close value is valid
    if (closeVal > 0) {
      holding.exchTsym![0].oneDayChg =
          (((lpDouble - closeVal) * (qty - usedqty))).toStringAsFixed(2);
    }

    // Update totals
    updateHoldingStat();
  }

  updateHoldingStat() {
    _totalCurrentVal = 0.0;
    for (var holdingJson in holdingsModel!) {
      _totalCurrentVal += double.parse("${holdingJson.currentValue ?? 0.0}");
    }
  }

  Future fetchOplist(context) async {
    try {
      List oplist = await api.getOptionlist();
      _oplists = oplist;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API OPlist", "Error": "$e"});
      notifyListeners();
    }
  }

  splitPositionBook(bool isDay) async {
    final theme = ref.read(themeProvider);
    if (_postionBookModel!.isNotEmpty) {
      _closedPosion = [];
      double totBuyAmts = 0.00;
      double totSellAmts = 0.00;
      _allPostionList = [];
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

      await positionCal(isDay);
      getPositionGroupNames();
      // tabSize(theme);

      notifyListeners();
    }
  }

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

  Future fetchExitPosition(
      BuildContext context,
      PlaceOrderInput placeOrderInput,
      bool isPosition,
      bool multipleexit) async {
    try {
      int qty = int.parse(placeOrderInput.qty);
      int frzqty = int.parse(placeOrderInput.frzqty.toString());

      if (qty > frzqty) {
        int fullOrders = qty ~/ frzqty;
        int remainingQty = qty % frzqty;

        for (int i = 0; i < fullOrders; i++) {
          placeOrderInput.qty = frzqty.toString();
          _placeOrderModel = await api.getPlaceOrder(
              placeOrderInput, ref.read(orderProvider).ip);
        }

        if (remainingQty > 0) {
          placeOrderInput.qty = remainingQty.toString();
          _placeOrderModel = await api.getPlaceOrder(
              placeOrderInput, ref.read(orderProvider).ip);
        }
      } else {
        _placeOrderModel = await api.getPlaceOrder(
            placeOrderInput, ref.read(orderProvider).ip);
      }

      if (_placeOrderModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        if (isPosition) {
          await fetchPositionBook(context, _isDay);
        } else {
          await fetchHoldings(context, "Refresh");
        }
        if (!multipleexit) {
          Navigator.pop(context);
        }
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
    }
  }

  // Methods for exit holdings selection
  void selectExitAllHoldings(bool value) {
    _isExitAllHoldings = value;

    // Update selection status for all holdings
    for (var holding in _sealableHoldings) {
      holding.isExitHoldings = value;
    }

    // Update exit quantity count
    _exitHoldingsQty = value
        ? _sealableHoldings.fold(0, (sum, h) => sum + (h.saleableQty ?? 0))
        : 0;

    notifyListeners();
  }

  void selectExitHoldings(int index) {
    if (index < _sealableHoldings.length) {
      // Toggle selection for a specific holding
      _sealableHoldings[index].isExitHoldings =
          !_sealableHoldings[index].isExitHoldings!;

      // Recalculate total selected quantity
      _exitHoldingsQty = 0;
      bool allSelected = true;

      for (var holding in _sealableHoldings) {
        if (holding.isExitHoldings!) {
          _exitHoldingsQty += holding.saleableQty ?? 0;
        } else {
          allSelected = false;
        }
      }

      // Update "Select All" state based on individual selections
      _isExitAllHoldings = allSelected && _sealableHoldings.isNotEmpty;

      notifyListeners();
    }
  }

  // Methods for exit positions selection
  void selectExitAllPosition(bool value) {
    _isExitAllPosition = value;

    // Update selection status for all positions
    if (_openPosition != null) {
      for (var position in _openPosition!) {
        position.isExitSelection = value;
      }

      // Update exit quantity count
      _exitPositionQty =
          value ? _openPosition!.where((p) => p.qty != "0").length : 0;
    }

    notifyListeners();
  }

  void selectExitPosition(int index) {
    if (_openPosition != null && index < _openPosition!.length) {
      // Toggle selection for specific position
      _openPosition![index].isExitSelection =
          !_openPosition![index].isExitSelection!;

      // Recalculate total selected positions
      _exitPositionQty = 0;
      bool allSelected = true;

      for (var position in _openPosition!) {
        if (position.isExitSelection! && position.qty != "0") {
          _exitPositionQty++;
        }

        if (!position.isExitSelection! && position.qty != "0") {
          allSelected = false;
        }
      }

      // Update "Select All" state based on individual selections
      _isExitAllPosition =
          allSelected && _openPosition!.where((p) => p.qty != "0").isNotEmpty;

      notifyListeners();
    }
  }

  // Position conversion
  Future<void> fetchPositionConverstion(
      PositionConvertionInput input, BuildContext context) async {
    try {
      toggleLoadingOn(true);
      _positionConvertionModel = await api.getPositionConvertion(input);

      if (_positionConvertionModel!.stat == "Ok") {
        // Refresh position book after conversion
        await fetchPositionBook(context, _isDay);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "Position converted successfully"));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "${_positionConvertionModel!.emsg}"));
      }
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "Position Conversion", "Error": "$e"});
      ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, "Failed to convert position: $e"));
    } finally {
      toggleLoadingOn(false);
    }
  }

  positionGroupCal(
      bool isDay, List groupData, String groupName, bool iscusGrop) {
    if (groupData.isEmpty) return;

    double totalProfitNloss = 0.0;
    double totalMtm = 0.0;
    bool hasExitPositions = false;

    for (var position in groupData) {
      // Get common values used in calculations
      final lastPrice = double.tryParse(position["lp"] ?? "0.00") ?? 0.0;
      final prcFtr = double.tryParse(position["prcftr"] ?? "1.0") ?? 1.0;
      final mult = double.tryParse(position["mult"] ?? "1.0") ?? 1.0;
      final netQty = int.tryParse(position["netqty"] ?? "0") ?? 0;
      final netQtyWeighted = netQty * prcFtr;

      // Parse buy/sell quantities
      final dayBuyQty = int.tryParse(position["daybuyqty"] ?? "0") ?? 0;
      final daySellQty = int.tryParse(position["daysellqty"] ?? "0") ?? 0;
      final cfBuyQty = int.tryParse(position["cfbuyqty"] ?? "0") ?? 0;
      final cfSellQty = int.tryParse(position["cfsellqty"] ?? "0") ?? 0;

      // Calculate net buy and sell quantities
      final netBuyQty = dayBuyQty + cfBuyQty;
      final netSellQty = daySellQty + cfSellQty;

      // Parse prices and amounts
      final netAvgPrc = double.tryParse(position["netavgprc"] ?? "0.00") ?? 0.0;
      final upldPrc = double.tryParse(position["upldprc"] ?? "0.00") ?? 0.0;
      final dayBuyAmt = double.tryParse(position["daybuyamt"] ?? "0.00") ?? 0.0;
      final daySellAmt =
          double.tryParse(position["daysellamt"] ?? "0.00") ?? 0.0;
      final rpnl = double.tryParse(position["rpnl"] ?? "0.00") ?? 0.0;

      if (isDay) {
        // DAY POSITION GROUP CALCULATION
        position["avgPrc"] = netQty == 0 ? "0.00" : position["dayavgprc"];

        // Calculate quantity
        final qty = dayBuyQty - daySellQty;
        position["qty"] = "$qty";

        if (qty != 0) {
          hasExitPositions = true;

          // Calculate ActualUnrealizedMtoM
          final dayAvgPrc =
              double.tryParse(position["dayavgprc"] ?? "0.00") ?? 0.0;
          double unrealizedMtm =
              netQtyWeighted * mult * (lastPrice - dayAvgPrc);

          position["profitNloss"] = unrealizedMtm.toStringAsFixed(2);
          totalProfitNloss += unrealizedMtm;
        } else {
          // For closed positions
          position["profitNloss"] = position["rpnl"] ?? "0.00";
          totalProfitNloss += rpnl;
        }
      } else {
        // NET POSITION GROUP CALCULATION
        position["qty"] = position["netqty"] ?? "0";

        // Determine avgPrc for MTM and PnL according to rules
        double mtmAvgPrc = netAvgPrc;
        double pnlAvgPrc = upldPrc == 0.0 ? netAvgPrc : upldPrc;

        if (netQty == 0) {
          position["avgPrc"] = "0.00";
        } else if (_isNetPnl) {
          position["avgPrc"] =
              upldPrc == 0.0 ? position["netavgprc"] : position["upldprc"];
        } else {
          position["avgPrc"] = position["netavgprc"];
        }

        if (netQty != 0) {
          hasExitPositions = true;
        }

        if (netQty == 0) {
          // For closed positions
          position["mTm"] = position["rpnl"] ?? "0.00";
          position["profitNloss"] = position["rpnl"] ?? "0.00";
          totalMtm += rpnl;
          totalProfitNloss += rpnl;
        } else {
          // Calculate ActualUnrealizedMtoM for MTM
          double unrealizedMtmForMtm =
              netQtyWeighted * mult * (lastPrice - mtmAvgPrc);
          position["mTm"] = (rpnl + unrealizedMtmForMtm).toStringAsFixed(2);
          totalMtm += rpnl + unrealizedMtmForMtm;

          // Calculate ActualUnrealizedMtoM for PnL
          double unrealizedMtmForPnl =
              netQtyWeighted * mult * (lastPrice - pnlAvgPrc);

          // Calculate ActualBookedPNL
          double actualSellAvgPrice = 0.0;
          double actualBuyAvgPrice = 0.0;

          if (netSellQty > 0) {
            actualSellAvgPrice =
                ((daySellAmt / mult) + (upldPrc * prcFtr * cfSellQty)) /
                    netSellQty;
          }

          if (netBuyQty > 0) {
            actualBuyAvgPrice =
                ((dayBuyAmt / mult) + (upldPrc * prcFtr * cfBuyQty)) /
                    netBuyQty;
          }

          double actualBookedPnl = 0.0;
          if (netQty > 0) {
            actualBookedPnl =
                (actualSellAvgPrice - actualBuyAvgPrice) * netSellQty * mult;
          } else if (netQty < 0) {
            actualBookedPnl =
                (actualSellAvgPrice - actualBuyAvgPrice) * netBuyQty * mult;
          }

          // Final PnL = ActualBookedPNL + ActualUnrealizedMtoM
          position["profitNloss"] =
              (actualBookedPnl + unrealizedMtmForPnl).toStringAsFixed(2);
          totalProfitNloss += actualBookedPnl + unrealizedMtmForPnl;
        }
      }
    }

    // Update group summary
    _groupedBySymbol[groupName]['totPnl'] = totalProfitNloss.toStringAsFixed(2);
    _groupedBySymbol[groupName]['totMtm'] = totalMtm.toStringAsFixed(2);
    _groupedBySymbol[groupName]['isexit'] = "$hasExitPositions";

    // Update total P&L and MTM
    _updateTotalGroupValues();
  }

  // Helper method to update total group values
  void _updateTotalGroupValues() {
    double totalPnl = 0.0;
    double totalMtm = 0.0;

    for (var symbol in _groupPositionSym) {
      if (_groupedBySymbol[symbol]["isCustomGrp"] == false) {
        totalPnl +=
            double.tryParse(_groupedBySymbol[symbol]['totPnl'] ?? "0.00") ??
                0.0;
        totalMtm +=
            double.tryParse(_groupedBySymbol[symbol]['totMtm'] ?? "0.00") ??
                0.0;
      }
    }

    _totMtm = totalMtm.toStringAsFixed(2);
    _totPnL = totalPnl.toStringAsFixed(2);

    notifyListeners();
  }

  // Method for custom group position selection
  Future<void> cusGrpSelectPosition(List groupList) async {
    try {
      if (groupList.isNotEmpty) {
        // Mark which positions are already in the group
        for (var element in _allPostionList) {
          element.isAlreadyGroup = false;

          for (var grpElement in groupList) {
            if (element.token == grpElement['token'] &&
                element.prd == grpElement['prd']) {
              element.isAlreadyGroup = true;
              break;
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error in cusGrpSelectPosition: $e");
    }
  }

  // Add this near the other state variables
  bool _isExitingAll = false;
  bool get isExitingAll => _isExitingAll;

  // Add this near the other state variables
  String _currentPositionSortOption = "";
  String get currentPositionSortOption => _currentPositionSortOption;

  // Add this near the other state variables and _currentHoldingSortOption
  String _currentHoldingSortOption = "";
  String get currentHoldingSortOption => _currentHoldingSortOption;
}
