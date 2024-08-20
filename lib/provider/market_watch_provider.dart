import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/marketwatch_model/add_delete_scrip_model.dart';
import '../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../models/marketwatch_model/alert_model/cancel_alert_model.dart';
import '../models/marketwatch_model/alert_model/manage_price_alert_model.dart';
import '../models/marketwatch_model/alert_model/modify_alert_model.dart';
import '../models/marketwatch_model/alert_model/set_alert_model.dart';
import '../models/marketwatch_model/get_quotes.dart';
import '../models/marketwatch_model/linked_scrips.dart';
import '../models/marketwatch_model/market_watch_scrip_model.dart';
import '../models/marketwatch_model/market_watchlist_model.dart';
import '../models/marketwatch_model/opt_chain_model.dart';
import '../models/marketwatch_model/pre_define_wl_model.dart';
import '../models/marketwatch_model/scrip_info.dart';
import '../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../models/marketwatch_model/scrip_overview/technical_data.dart';
import '../models/marketwatch_model/search_scrip_model.dart';
import '../res/res.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'portfolio_provider.dart';
import 'websocket_provider.dart';

final marketWatchProvider =
    ChangeNotifierProvider((ref) => MarketWatchProvider(ref.read));

class MarketWatchProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Reader ref;

  String _searchErrorText = "Enter more than TWO letters";
  String get searchErrorText => _searchErrorText;

  List _depthBtns = [
    {"btnName": "Overview", "imgPath": assets.dInfo},
    {"btnName": "Chart", "imgPath": assets.charticon}
  ];
  String _actDeptBtn = "Overview";
  String get actDeptBtn => _actDeptBtn;
  final List<Tab> _scipOverViewTab = [
    const Tab(text: "Overview"),
    const Tab(text: "Chart")
  ];

  String _sortByWL = "";
  String get sortByWL => _sortByWL;

  List _returnsGridview = [];

  List get returnsGridview => _returnsGridview;

  String _optionStrPrc = "0.00";

  String get optionStrPrc => _optionStrPrc;

  String _futToken = "0.00";

  String get futToken => _futToken;
  String __futExch = "";

  String get futExch => __futExch;

  List get depthBtns => _depthBtns;
  List<Tab> get scripOverViewTab => _scipOverViewTab;
  List<bool>? _isAdded;
  List<bool>? get isAdded => _isAdded;

  MarketWatchlist? _marketWatchlist;
  MarketWatchlist? get marketWatchlist => _marketWatchlist;
  // MarketWatchlist? _preDefMWlist;
  // MarketWatchlist? get preDefMWlist => _preDefMWlist;

  final List<String> _preDefWL = [
    "My Stocks",
    "Nifty50",
    "Niftybank",
    "Sensex"
  ];

  List<Tab> _searchTabList = const [
    Tab(text: "All"),
    Tab(text: "Equity"),
    Tab(text: "F&O"),
    Tab(text: "Currency"),
    Tab(text: "Commodity")
  ];

  List<Tab> get searchTabList => _searchTabList;

  List<String> get preDefWL => _preDefWL;
  List<WatchListValues> _searchMWLScrip = [];
  List<WatchListValues> get searchMWLScrip => _searchMWLScrip;

  MarketWatchScrip? _marketWatchScrip;
  MarketWatchScrip? get marketWatchScrip => _marketWatchScrip;

  PreDefinedMWlist? _preDefinedMWlist;

  PreDefinedMWlist? get preDefinedMWlist => _preDefinedMWlist;

  List<WatchListValues> _watchListValues = [];
  List<WatchListValues> get watchListValues => _watchListValues;
  ScripInfoModel? _scripInfoModel;
  ScripInfoModel? get scripInfoModel => _scripInfoModel;

  List<ManagePriceAlertModel>? _setManagePrice;
  List<ManagePriceAlertModel>? get setManagePrice => _setManagePrice;
  int _delScripQty = 0;
  int get delScripQty => _delScripQty;

  GetQuotes? _getQuotes;
  GetQuotes? get getQuotes => _getQuotes;

  GetQuotes? _getStikePrc;
  GetQuotes? get getStikePrc => _getStikePrc;

  AddDeleteScripModel? _addDeleteScripModel;
  AddDeleteScripModel? get addDeleteScripModel => _addDeleteScripModel;

  SearchScripModel? _searchScripModel;

  SearchScripModel? get searchScripModel => _searchScripModel;

  List<ScripValue>? _allSearchScrip = [];
  List<ScripValue>? get allSearchScrip => _allSearchScrip;
  List<ScripValue>? _equitySearchScrip = [];
  List<ScripValue>? get equitySearchScrip => _equitySearchScrip;
  List<ScripValue>? _currencySearchScrip = [];
  List<ScripValue>? get currencySearchScrip => _currencySearchScrip;
  List<ScripValue>? _commoditySearchScrip = [];
  List<ScripValue>? get commoditySearchScrip => _commoditySearchScrip;
  List<ScripValue>? _fNoSearchScrip = [];
  List<ScripValue>? get fNoSearchScrip => _fNoSearchScrip;

  fetchSearchTabSize() {
    _searchTabList = [
      Tab(
          text:
              "All${_allSearchScrip!.isNotEmpty ? " (${_allSearchScrip!.length})" : ""}"),
      Tab(
          text:
              "Equity${_equitySearchScrip!.isNotEmpty ? " (${_equitySearchScrip!.length})" : ""}"),
      Tab(
          text:
              "F&O${_fNoSearchScrip!.isNotEmpty ? " (${_fNoSearchScrip!.length})" : ""}"),
      Tab(
          text:
              "Currency${_currencySearchScrip!.isNotEmpty ? " (${_currencySearchScrip!.length})" : ""}"),
      Tab(
          text:
              "Commodity${_commoditySearchScrip!.isNotEmpty ? " (${_commoditySearchScrip!.length})" : ""}")
    ];
    notifyListeners();
  }

  CancelAlertModel? _cancelalert;
  CancelAlertModel? get cancelalert => _cancelalert;

  SetAlertModel? _setAlertModel;
  SetAlertModel? get setAlertModel => _setAlertModel;

  ModifyAlertModel? _modifyalertmodel;
  ModifyAlertModel? get modifyalertmodel => _modifyalertmodel;

  List<AlertPendingModel>? _alertPendingModel = [];
  List<AlertPendingModel>? get alertPendingModel => _alertPendingModel;

  String _mwSubToken = "";
  String get mwSubToken => _mwSubToken;

// Option chain
  List<String> _sortedDate = [];
  String? _selectedExpDate;
  String? _selectedTradeSym;
  String _numStrike = "10";
  String? _optionExch;
  final List<String> _numStrikes = ["5", "10", "15", "50"];

  List<String> get sortDate => _sortedDate;
  String? get selectedExpDate => _selectedExpDate;
  String? get selectedTradeSym => _selectedTradeSym;
  String get numStrike => _numStrike;
  String? get optionExch => _optionExch;
  List<String> get numStrikes => _numStrikes;

  LinkedScrips? _linkedScrips;
  LinkedScrips? get linkedScrips => _linkedScrips;
  List<Equls>? _equls = [];
  List<Futures>? _fut = [];
  List<OptionExp>? _optExp = [];
  List<Equls>? get equls => _equls;
  List<Futures>? get fut => _fut;
  List<OptionExp>? get optExp => _optExp;
  OptionChainModel? _optionChainModel;
  OptionChainModel? get optionChainModel => _optionChainModel;
  List<OptionValues> _optChainPut = [];
  List<OptionValues> _optChainCall = [];
  List<OptionValues> get optChainPut => _optChainPut;
  List<OptionValues> get optChainCall => _optChainCall;

  List<OptionValues> _optChainPutUp = [];
  List<OptionValues> _optChainCallUp = [];
  List<OptionValues> _optChainPutDown = [];
  List<OptionValues> _optChainCallDown = [];
  List<OptionValues> get optChainPutUp => _optChainPutUp;
  List<OptionValues> get optChainCallUP => _optChainCallUp;
  List<OptionValues> get optChainPutDown => _optChainPutDown;
  List<OptionValues> get optChainCallDown => _optChainCallDown;
  MarketWatchProvider(this.ref);

  String _wlName = "";

  String get wlName => _wlName;
  String _isPreDefWLs = "No";

  String get isPreDefWLs => _isPreDefWLs;

  String _tradeSym = "";
  String get tradeSym => _tradeSym;
  String _exch = "";
  String get exchange => _exch;
  String _duration = "5m";
  String get duration => _duration;

  String _chartDuration = "5";
  String get chartDuration => _chartDuration;

  double _totBuyQtyPer = 0.00;
  double _totSellQtyPer = 0.00;
  int _maxBuyQty = 0;
  int _maxSellQty = 0;
  double _totBuyQtyPerChng = 0.00;

  double get totBuyQtyPer => _totBuyQtyPer;
  double get totSellQtyPer => _totSellQtyPer;
  int get maxBuyQty => _maxBuyQty;
  int get maxSellQty => _maxSellQty;
  double get totBuyQtyPerChng => _totBuyQtyPerChng;

// Scrip Overview
  TechnicalData? _techData;
  TechnicalData? get techData => _techData;

  List<PrcComparisionChartData> _prcComChrtData1 = [];
  List<PrcComparisionChartData> _prcComChrtData2 = [];
  List<PrcComparisionChartData> _prcComChrtData3 = [];
  List<PrcComparisionChartData> _prcComChrtData4 = [];
  List<PrcComparisionChartData> _prcComChrtData5 = [];

  List<PrcComparisionChartData> get prcComChrtData1 => _prcComChrtData1;
  List<PrcComparisionChartData> get prcComChrtData2 => _prcComChrtData2;
  List<PrcComparisionChartData> get prcComChrtData3 => _prcComChrtData3;
  List<PrcComparisionChartData> get prcComChrtData4 => _prcComChrtData4;
  List<PrcComparisionChartData> get prcComChrtData5 => _prcComChrtData5;
  StockData? _fundamentalData;
  StockData? get fundamentalData => _fundamentalData;

  String _firstGetData = "0";
  String get fistGetData => _firstGetData;

  final FToast _fToast = FToast();
  FToast get fToast => _fToast;

  //   fundamental

  List<String> _mfHoldingDate = [];
  List<String> get mfHoldingDate => _mfHoldingDate;

  String _selectedMfHolddate = "";
  String get selectedMfHolddate => _selectedMfHolddate;

  int _selectedMfHoldindex = 0;
  int get selectedMfHoldindex => _selectedMfHoldindex;
  chngMfHoldDate(String val, int index) {
    _selectedMfHolddate = val;
    _selectedMfHoldindex = index;
    notifyListeners();
  }

  chngDephBtn(String val) {
    _actDeptBtn = val;
    notifyListeners();
  }

  List<String> shareHoldType = [
    "Promoter Holding",
    "Foriegin Institution",
    "Other Domestic Institution",
    "Retail and Others",
    "Mutual Funds"
  ];

  String _selctedShareHold = "Promoter Holding";

  String get selctedShareHold => _selctedShareHold;
  chngshareHold(String val) async {
    _selctedShareHold = val;

    notifyListeners();
  }

  List _peersChartKeys = [];

  List get peersChartKeys => _peersChartKeys;

  List<String> mfHoldType = ["Mkt cap held%", "AUM", "Weight%"];

  String _selctedmfHold = "Mkt cap held%";

  String get selctedmfHold => _selctedmfHold;
  chngMfHold(String val) async {
    _selctedmfHold = val;

    notifyListeners();
  }

  List<String> _finnceYears = [];
  List<String> get finnceYears => _finnceYears;

  List<String> finType = ["Standalone", "Consolidated"];

  String _selctedFinType = "Standalone";

  String get selcteFinType => _selctedFinType;
  chngFinType(String val) async {
    _selctedFinType = val;

    notifyListeners();
  }

  String _selctedFinYear = "";

  String get selcteFinYear => _selctedFinYear;
  chngFinYear(String val) async {
    _selctedFinYear = val;

    notifyListeners();
  }

  List<double> getCustomItemsHeight(List<String> numofList) {
    List<double> itemsHeights = [];
    for (var i = 0; i < (numofList.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<String> peersType = [
    "LTP",
    "Mkt Cap",
    "PE Ratio",
    "PB Ratio",
    "ROCE",
    "Evebitda",
    "Debt to EQ",
    "Div yield"
  ];

  String _selctedPeers = "LTP";

  String get selctedPeers => _selctedPeers;
  chngPeersType(String val) async {
    _selctedPeers = val;

    notifyListeners();
  }

  List<DropdownMenuItem<String>> addDividersAfterExpDates(
      List<String> numofList) {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in numofList) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item.toString(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(item.toString()))),
          //If it's last item, we will not add Divider after it.
          if (item != numofList.last)
            DropdownMenuItem<String>(
              enabled: false,
              child: Divider(color: colors.colorDivider),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> getStochCustomItemsHeight(List<String> numofList) {
    List<double> itemsHeights = [];
    for (var i = 0; i < (numofList.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<DropdownMenuItem<String>> addDividersAfterStock(List<String> numofList) {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in numofList) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item.toString(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    item.toString(),
                  ))),
          //If it's last item, we will not add Divider after it.
          if (item != numofList.last)
            DropdownMenuItem<String>(
              enabled: false,
              child: Divider(color: ref(themeProvider).isDarkMode
              ?colors.darkColorDivider
              :colors.colorDivider),
            ),
        ],
      );
    }
    return menuItems;
  }

  void selecexpDate(String value) {
    _selectedExpDate = value;
    notifyListeners();
  }

  void selecTradSym(String value) {
    _selectedTradeSym = value;
    notifyListeners();
  }

  void selecNumStrike(String value) {
    _numStrike = value;
    notifyListeners();
  }

  void optExch(String value) {
    _optionExch = value;
    notifyListeners();
  }

  updateOptStrPrc(String val) {
    _optionStrPrc = val;
  }

// depthWLAddBtn(){
//     _isAdded = List<bool>.filled(_searchScripModel!.values!.length, false);
// }

  void activeTsym(String symbol, String exch) {
    _tradeSym = symbol;
    // pref.setActiveSymbol(symbol);
    _exch = exch;
    // pref.setActiveExchange(exch);
    notifyListeners();
  }

  void activeResolution(String duration) {
    _duration = duration;
    notifyListeners();
  }

  void activeDuration(String duration) {
    _chartDuration = duration;
    notifyListeners();
  }

  setpageName(String name) {
    ConstantName.pageName = name;
    notifyListeners();
  }

  scripSearch(String value, BuildContext context) async {
    if (value.length > 1) {
      await fetchSearchScrip(searchText: value, context: context);
    } else {
      searchClear();
    }
    notifyListeners();
  }

  lastScbTok(String val) {
    ConstantName.lastSubscribe = val;
    notifyListeners();
  }

  changeWlName(String name, String isWList) {
    _wlName = name;
    _isPreDefWLs = isWList;
    notifyListeners();
  }

  searchClear() {
    _searchErrorText = "Enter more than TWO letters";

    // _searchScripModel!.values = [];
    _allSearchScrip = [];
    _commoditySearchScrip = [];
    _fNoSearchScrip = [];
    _equitySearchScrip = [];
    _currencySearchScrip = [];

    fetchSearchTabSize();
    notifyListeners();
  }

  isActiveAddBtn(bool val, int index) {
    _isAdded![index] = val;

    notifyListeners();
  }

  Map _marketWatchScripData = {};
  Map get marketWatchScripData => _marketWatchScripData;

  List _scrips = [];
  List get scrips => _scrips;

  Future fetchMWList(BuildContext context) async {
    try {
      _marketWatchlist = await api.getMWList();

      if (_marketWatchlist!.stat == "Ok") {
        ConstantName.sessCheck = true;
        if (_marketWatchlist!.values!.isEmpty) {
          _marketWatchlist!.values!.add("My");
        } else {
          _marketWatchlist!.values!.sort((a, b) => a.compareTo(b));
          notifyListeners();
          _marketWatchScripData = {};
          for (var element in _marketWatchlist!.values!) {
            await fetchMWScrip(element, context);
          }
        }

        if (_wlName.isEmpty) {
          _wlName = _marketWatchlist!.values!.first;
        }

        _marketWatchlist!.values!.addAll(_preDefWL);
        await changeWLScrip(_wlName, context);
        await fetchPreDefMWScrip(context);
      } else {
        if (_marketWatchlist!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _marketWatchlist!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
      return _marketWatchlist;
    } catch (e) {
      print("Failed $e");
      ref(indexListProvider)
          .logError
          .add({"type": "API Market WL", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchMWScrip(String wlname, context) async {
    try {
      toggleLoadingOn(true);

//  await requestWSMarketWatchScrip(context: context, isSubscribe: false);
      _marketWatchScrip = await api.getMWScrip(wlname);

      if (_marketWatchScrip!.stat == "Ok") {
        ConstantName.sessCheck = true;
        _watchListValues = _marketWatchScrip!.values;

        if (_watchListValues.isNotEmpty) {
          for (var element in _watchListValues) {
            Map spilitSymbol = spilitTsym(value: "${element.tsym}");

            element.symbol = "${spilitSymbol["symbol"]}";
            element.expDate = "${spilitSymbol["expDate"]}";
            element.option = "${spilitSymbol["option"]}";

            if (ref(portfolioProvider).holdingsModel!.isNotEmpty) {
              for (var holding in ref(portfolioProvider).holdingsModel!) {
                if (holding.exchTsym![0].exch == "NSE" ||
                    holding.exchTsym![0].exch == "BSE") {
                  if (element.token == holding.exchTsym![0].token) {
                    element.holdingQty = "${holding.currentQty ?? 0}";
                  }
                }
              }
            }
          }
        }

        _marketWatchScripData.addAll({wlname: jsonEncode(_watchListValues)});

        notifyListeners();
      } else {
        if (_marketWatchScrip!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _marketWatchScrip!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
        _watchListValues = [];
      }

      return _marketWatchScrip;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Market Watch Scrip", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchPreDefMWScrip(BuildContext context) async {
    try {
      // requestWSMarketWatchScrip(context: context, isSubscribe: false);
      toggleLoadingOn(true);

      _preDefinedMWlist = await api.getPreDefMWScrip();

      if (_preDefinedMWlist != null) {
        if (_preDefinedMWlist!.stat == "Ok") {
          ConstantName.sessCheck = true;

          if (_preDefinedMWlist!.nIFTY50NSE!.isNotEmpty) {
            _preDefinedMWlist!.nIFTY50NSE!.sort((a, b) {
              return a.tsym!.compareTo(b.tsym!);
            });
            for (var element in _preDefinedMWlist!.nIFTY50NSE!) {
              Map spilitSymbol = spilitTsym(value: "${element.tsym}");

              element.symbol = "${spilitSymbol["symbol"]}";
              element.expDate = "${spilitSymbol["expDate"]}";
              element.option = "${spilitSymbol["option"]}";

              if (ref(portfolioProvider).holdingsModel!.isNotEmpty) {
                for (var holding in ref(portfolioProvider).holdingsModel!) {
                  if (holding.exchTsym![0].exch == "NSE" ||
                      holding.exchTsym![0].exch == "BSE") {
                    if (element.token == holding.exchTsym![0].token) {
                      element.holdingQty = "${holding.currentQty ?? 0}";
                    }
                  }
                }
              }
            }
          }
          if (_preDefinedMWlist!.nIFTYBANKNSE!.isNotEmpty) {
            _preDefinedMWlist!.nIFTYBANKNSE!.sort((a, b) {
              return a.tsym!.compareTo(b.tsym!);
            });
            for (var element in _preDefinedMWlist!.nIFTYBANKNSE!) {
              Map spilitSymbol = spilitTsym(value: "${element.tsym}");

              element.symbol = "${spilitSymbol["symbol"]}";
              element.expDate = "${spilitSymbol["expDate"]}";
              element.option = "${spilitSymbol["option"]}";

              if (ref(portfolioProvider).holdingsModel!.isNotEmpty) {
                for (var holding in ref(portfolioProvider).holdingsModel!) {
                  if (holding.exchTsym![0].exch == "NSE" ||
                      holding.exchTsym![0].exch == "BSE") {
                    if (element.token == holding.exchTsym![0].token) {
                      element.holdingQty = "${holding.currentQty ?? 0}";
                    }
                  }
                }
              }
            }
          }
          if (_preDefinedMWlist!.sENSEXBSE!.isNotEmpty) {
            _preDefinedMWlist!.sENSEXBSE!.sort((a, b) {
              return a.tsym!.compareTo(b.tsym!);
            });
            for (var element in _preDefinedMWlist!.sENSEXBSE!) {
              Map spilitSymbol = spilitTsym(value: "${element.tsym}");

              element.symbol = "${spilitSymbol["symbol"]}";
              element.expDate = "${spilitSymbol["expDate"]}";
              element.option = "${spilitSymbol["option"]}";

              if (ref(portfolioProvider).holdingsModel!.isNotEmpty) {
                for (var holding in ref(portfolioProvider).holdingsModel!) {
                  if (holding.exchTsym![0].exch == "NSE" ||
                      holding.exchTsym![0].exch == "BSE") {
                    if (element.token == holding.exchTsym![0].token) {
                      element.holdingQty = "${holding.currentQty ?? 0}";
                    }
                  }
                }
              }
            }
          }

          _marketWatchScripData
              .addAll({"Nifty50": jsonEncode(_preDefinedMWlist!.nIFTY50NSE!)});
          _marketWatchScripData.addAll(
              {"Niftybank": jsonEncode(_preDefinedMWlist!.nIFTYBANKNSE!)});
          _marketWatchScripData
              .addAll({"Sensex": jsonEncode(_preDefinedMWlist!.sENSEXBSE!)});
          notifyListeners();

          // await requestWSMarketWatchScrip(context: context, isSubscribe: true);
        } else {
          if (_marketWatchScrip!.emsg ==
                  "Session Expired :  Invalid Session Key" &&
              _marketWatchScrip!.stat == "Not_Ok") {
            ref(authProvider).ifSessionExpired(context);
          }
          // _watchListValues = [];
        }
      }
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Market Watch Scrip", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchScripInfo(String token, String exch, BuildContext context) async {
    try {
      _scripInfoModel = await api.getScripInfo(token, exch);

      if (_scripInfoModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        Map spilitSymbol = spilitTsym(value: "${_scripInfoModel!.tsym}");

        _scripInfoModel!.symbol = "${spilitSymbol["symbol"]}";
        _scripInfoModel!.expDate = "${spilitSymbol["expDate"]}";
        _scripInfoModel!.option = "${spilitSymbol["option"]}";
      }

      if (_scripInfoModel!.emsg == "Session Expired :  Invalid Session Key" &&
          _scripInfoModel!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }
      return _scripInfoModel;
    } catch (e) {
      print(e);
      ref(indexListProvider)
          .logError
          .add({"type": "API Scrip Info", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchScripQuote(
      String token, String exch, BuildContext context) async {
    try {
      _getQuotes = await api.getScripQuote(token, exch);

      if (_getQuotes!.stat == "Ok") {
        ConstantName.sessCheck = true;
        Map spilitSymbol = spilitTsym(value: "${_getQuotes!.tsym}");
        _getQuotes!.symbol = "${spilitSymbol["symbol"]}";
        _getQuotes!.expDate = "${spilitSymbol["expDate"]}";
        _getQuotes!.option = "${spilitSymbol["option"]}";

        _optionStrPrc = "${_getQuotes!.lp}";

        scripQtyCal();
      }
      if (_getQuotes!.emsg == "Session Expired :  Invalid Session Key" &&
          _getQuotes!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _getQuotes;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Scrip Quote", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchStikePrc(String token, String exch, BuildContext context) async {
    try {
      _getStikePrc = await api.getScripQuote(token, exch);

      if (_getStikePrc!.stat == "Ok") {
        ConstantName.sessCheck = true;
        if (_getStikePrc!.exch == "NSE" ||
            (_getStikePrc!.exch == "MCX" &&
                _getStikePrc!.instname == "FUTCOM")) {
          _optionStrPrc = "${_getStikePrc!.lp}";
        }
        await ref(websocketProvider).establishConnection(
            channelInput: '${_getStikePrc!.exch}|${_getStikePrc!.token!}',
            task: "t",
            context: context);
      }
      if (_getStikePrc!.emsg == "Session Expired :  Invalid Session Key" &&
          _getStikePrc!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Scrip Quote", "Error": "$e"});
      notifyListeners();
    }
  }

  void scripQtyCal() {
    if (_getQuotes!.instname != "UNDIND" && _getQuotes!.instname != "COM") {
      if (_getQuotes!.tbq != null || _getQuotes!.tsq != null) {
        _totBuyQtyPer = (int.parse("${_getQuotes!.tbq ?? 0}") /
                (int.parse("${_getQuotes!.tbq ?? 0}") +
                    int.parse("${_getQuotes!.tsq ?? 0}"))) *
            100;

        _totSellQtyPer = (int.parse("${_getQuotes!.tsq ?? 0}") /
                (int.parse("${_getQuotes!.tbq ?? 0}") +
                    int.parse("${_getQuotes!.tsq ?? 0}"))) *
            100;
        if (_totBuyQtyPer.isNaN) {
          _totBuyQtyPer = 0.00;
        }
        if (_totSellQtyPer.isNaN) {
          _totSellQtyPer = 0.00;
        }
        _totBuyQtyPerChng = _totBuyQtyPer / 100;
        _maxSellQty = [
          int.parse("${_getQuotes!.sq2 ?? 0}"),
          int.parse("${_getQuotes!.sq1 ?? 0}"),
          int.parse("${_getQuotes!.sq3 ?? 0}"),
          int.parse("${_getQuotes!.sq4 ?? 0}"),
          int.parse("${_getQuotes!.sq5 ?? 0}")
        ].reduce(max);
        _maxBuyQty = [
          int.parse("${_getQuotes!.bq2 ?? 0}"),
          int.parse("${_getQuotes!.bq1 ?? 0}"),
          int.parse("${_getQuotes!.bq3 ?? 0}"),
          int.parse("${_getQuotes!.bq4 ?? 0}"),
          int.parse("${_getQuotes!.bq5 ?? 0}")
        ].reduce(max);
      }
    }
  }

  Future fetchSearchScrip(
      {required String searchText, required BuildContext context}) async {
    try {
      toggleLoadingOn(true);

      _searchScripModel = await api.getSearchScrip(searchText: searchText);

      _allSearchScrip = [];
      _equitySearchScrip = [];
      _fNoSearchScrip = [];
      _currencySearchScrip = [];
      _commoditySearchScrip = [];
      if (_searchScripModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        _isAdded = List<bool>.filled(_searchScripModel!.values!.length, false);
        if (_searchScripModel!.values!.isNotEmpty) {
          for (var i = 0; i < _searchScripModel!.values!.length; i++) {
            Map spilitSymbol =
                spilitTsym(value: "${_searchScripModel!.values![i].tsym}");

            _searchScripModel!.values![i].symbol = "${spilitSymbol["symbol"]}";
            _searchScripModel!.values![i].expDate =
                "${spilitSymbol["expDate"]}";
            _searchScripModel!.values![i].option = "${spilitSymbol["option"]}";

            for (var j = 0; j < _scrips.length; j++) {
              if (_searchScripModel!.values![i].tsym == _scrips[j]['tsym']) {
                _isAdded![i] = true;
              }
            }
            _allSearchScrip = _searchScripModel!.values!;
            if (_searchScripModel!
                        .values![i].instname!
                        .toUpperCase() ==
                    "FUTCUR" ||
                _searchScripModel!
                        .values![i].instname!
                        .toUpperCase() ==
                    "FUTIRC" ||
                _searchScripModel!
                        .values![i].instname!
                        .toUpperCase() ==
                    "FUTIRT" ||
                _searchScripModel!.values![i].instname!.toUpperCase() ==
                    "OPTCUR" ||
                _searchScripModel!.values![i].instname!.toUpperCase() ==
                    "OPTIRC") {
              _currencySearchScrip!.add(_searchScripModel!.values![i]);
            } else if (_searchScripModel!.values![i].instname!.toUpperCase() ==
                    "AUCSO" ||
                _searchScripModel!
                        .values![i].instname!
                        .toUpperCase() ==
                    "COM" ||
                _searchScripModel!
                        .values![i].instname!
                        .toUpperCase() ==
                    "FUTCOM" ||
                _searchScripModel!.values![i].instname!.toUpperCase() ==
                    "FUTIDX" ||
                _searchScripModel!.values![i].instname!.toUpperCase() ==
                    "OPTFUT") {
              _commoditySearchScrip!.add(_searchScripModel!.values![i]);
            } else if ((_searchScripModel!.values![i].instname!.toUpperCase() ==
                        "FUTIDX" ||
                    _searchScripModel!.values![i].instname!.toUpperCase() ==
                        "FUTSTK") ||
                (_searchScripModel!.values![i].instname!.toUpperCase() ==
                        "OPTIDX" ||
                    _searchScripModel!.values![i].instname!.toUpperCase() ==
                        "OPTSTK")) {
              _fNoSearchScrip!.add(_searchScripModel!.values![i]);
            } else {
              _equitySearchScrip!.add(_searchScripModel!.values![i]);
            }

            notifyListeners();
          }

          _searchErrorText = "";
        }
      } else {
        _searchErrorText = "No Data Found";

        if (_searchScripModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _searchScripModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      fetchSearchTabSize();
      notifyListeners();
      return _searchScripModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Search", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchLinkeScrip(
      String token, String exch, BuildContext context) async {
    try {
      _depthBtns = [
        {
          "btnName": "Overview",
          "imgPath": assets.dInfo,
          "case": "click here to view the market depth."
        },
        {
          "btnName": "Chart",
          "imgPath": assets.charticon,
          "case": "Click here to view the trading view chart."
        }
      ];

      _linkedScrips = await api.getLinkedScrip(token, exch);
      if (_linkedScrips!.stat == "Ok") {
        ConstantName.sessCheck = true;
        _equls = _linkedScrips!.equls;
        _fut = _linkedScrips!.fut;
        _optExp = _linkedScrips!.optExp;

        if (_optExp!.isNotEmpty) {
          _depthBtns.add({
            "btnName": "Option",
            "imgPath": assets.optChainIcon,
            "case": "Click here to view the Option chain details."
          });

          List<DateTime> dates = _optExp!.map((dateString) {
            List<String> parts = dateString.exd!.split('-');
            int day = int.parse(parts[0]);
            int year = int.parse(parts[2]);

            Map<String, int> monthMap = {
              'JAN': 1,
              'FEB': 2,
              'MAR': 3,
              'APR': 4,
              'MAY': 5,
              'JUN': 6,
              'JUL': 7,
              'AUG': 8,
              'SEP': 9,
              'OCT': 10,
              'NOV': 11,
              'DEC': 12
            };
            int month = monthMap[parts[1].toUpperCase()]!;

            return DateTime(year, month, day);
          }).toList();
          dates.sort((a, b) => a.compareTo(b));
          _sortedDate = dates.map((date) {
            String day = date.day.toString().padLeft(2, '0');
            // String month = date.month.toString().padLeft(2, '0');
            String year = date.year.toString();

            Map<int, String> monthMap = {
              1: 'JAN',
              2: 'FEB',
              3: 'MAR',
              4: 'APR',
              5: 'MAY',
              6: 'JUN',
              7: 'JUL',
              8: 'AUG',
              9: 'SEP',
              10: 'OCT',
              11: 'NOV',
              12: 'DEC'
            };
            String monthString = monthMap[date.month]!.toUpperCase();

            return "$day-$monthString-$year";
          }).toList();

          // print("########### $_sortedDate");
          _selectedExpDate = _sortedDate[0];
          for (var i = 0; i < _optExp!.length; i++) {
            if (_selectedExpDate == _optExp![i].exd) {
              _optionExch = _optExp![i].exch;
              _selectedTradeSym = _optExp![i].tsym;
            }
          }
        }
        if (_fut!.isNotEmpty) {
          _depthBtns.add({
            "btnName": "Future",
            "imgPath": assets.optChainIcon,
            "case": "click here to view the futures of the underline scrpit."
          });

          _futToken = "${_fut![0].token}";
          __futExch = "${_fut![0].exch}";

          // print("Future $_futToken  $__futExch ");
          for (var element in _fut!) {
            Map spilitSymbol = spilitTsym(value: "${element.tsym}");

            element.symbol = "${spilitSymbol["symbol"]}";
            element.expDate = "${spilitSymbol["expDate"]}";
            element.option = "${spilitSymbol["option"]}";
          }
        }
      } else {
        ref(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
      return _linkedScrips;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Linked Scrip", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchOPtionChain(
      {required String strPrc,
      required String tradeSym,
      required String exchange,
      required BuildContext context,
      required String numofStrike}) async {
    try {
      toggleLoad(true);
      if (_optionChainModel != null) {
        requestWSOptChain(context: context, isSubscribe: false);
      }

      print("Strike Price $strPrc     ------ ");
      _optionChainModel = await api.getOptionChain(
          context: context,
          strPrc: strPrc,
          tradeSym: tradeSym,
          exchange: exchange,
          numofStrike: numofStrike);
      if (_optionChainModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        await splitOptionChain(context);
      } else {
        _optChainCall = [];
        _optChainPut = [];
        if (_optionChainModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _searchScripModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }

      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Option Chain", "Error": "$e"});
      notifyListeners();
      debugPrint(e.toString());
    } finally {
      toggleLoad(false);
    }
  }

  Future fetchTechData(
      {required String exch,
      required String tradeSym,
      required String lastPrc,
      required BuildContext context}) async {
    try {
      _techData = await api.getTechData(exch, tradeSym);
      _returnsGridview = [];
      if (_techData!.stat == "OK") {
        ConstantName.sessCheck = true;
        techDataCalc(lastPrc);
      }

      if (_techData!.emsg == "Session Expired :  Invalid Session Key" &&
          _techData!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Tech Data", "Error": "$e"});
      notifyListeners();
      debugPrint(e.toString());
    } finally {
      toggleLoad(false);
    }
  }

  Future fetchFundamentalData({required String tradeSym}) async {
    try {
      _fundamentalData = await api.getFundamentalData(tradeSym);

      if (_fundamentalData!.msg != "no data found") {
        // _firstGetData="1";
        // _depthBtns.add({
        //   "btnName": "Fundamental",
        //   "imgPath": assets.charticon,
        //   "case": "Click here to view the trading view chart."
        // });
        DateFormat format = DateFormat("yyyy-MM-dd");
        _mfHoldingDate = [];
        _fundamentalData!.shareholdings!.sort((a, b) {
          return format.parse(b.date!).compareTo(format.parse(a.date!));
        });
        for (var element in _fundamentalData!.shareholdings!) {
          String formattedDate =
              DateFormat.yMMMMd().format(format.parse(element.date!));

          List<String> date = [];

          date = formattedDate.split(" ");

          element.convDate =
              "${date[0].substring(0, 3)} ${date[2].substring(2)}";

          _mfHoldingDate.add(element.convDate!);
        }

        _selectedMfHolddate = _mfHoldingDate[0];
        _selectedMfHoldindex = 0;

        _fundamentalData!.stockFinancialsConsolidated!.balanceSheet!
            .sort((a, b) {
          return format
              .parse(b.yearEndDate!)
              .compareTo(format.parse(a.yearEndDate!));
        });

        for (var element
            in _fundamentalData!.stockFinancialsConsolidated!.balanceSheet!) {
          String formattedDate =
              DateFormat.yMMMMd().format(format.parse(element.yearEndDate!));

          List<String> date = [];

          date = formattedDate.split(" ");

          element.convDate =
              "${date[0].substring(0, 3)} ${date[2].substring(2)}";
        }
        _fundamentalData!.stockFinancialsConsolidated!.incomeSheet!
            .sort((a, b) {
          return format
              .parse(b.yearEndDate!)
              .compareTo(format.parse(a.yearEndDate!));
        });

        for (var element
            in _fundamentalData!.stockFinancialsConsolidated!.incomeSheet!) {
          String formattedDate =
              DateFormat.yMMMMd().format(format.parse(element.yearEndDate!));

          List<String> date = [];

          date = formattedDate.split(" ");

          element.convDate =
              "${date[0].substring(0, 3)} ${date[2].substring(2)}";
        }
        _fundamentalData!.stockFinancialsConsolidated!.cashflowSheet!
            .sort((a, b) {
          return format
              .parse(b.yearEndDate!)
              .compareTo(format.parse(a.yearEndDate!));
        });

        for (var element
            in _fundamentalData!.stockFinancialsConsolidated!.cashflowSheet!) {
          String formattedDate =
              DateFormat.yMMMMd().format(format.parse(element.yearEndDate!));

          List<String> date = [];

          date = formattedDate.split(" ");

          element.convDate =
              "${date[0].substring(0, 3)} ${date[2].substring(2)}";
        }

        _fundamentalData!.stockFinancialsStandalone!.balanceSheet!.sort((a, b) {
          return format
              .parse(b.yearEndDate!)
              .compareTo(format.parse(a.yearEndDate!));
        });

        for (var element
            in _fundamentalData!.stockFinancialsStandalone!.balanceSheet!) {
          String formattedDate =
              DateFormat.yMMMMd().format(format.parse(element.yearEndDate!));

          List<String> date = [];

          date = formattedDate.split(" ");

          element.convDate =
              "${date[0].substring(0, 3)} ${date[2].substring(2)}";
        }
        _selctedFinYear = _fundamentalData!
            .stockFinancialsStandalone!.balanceSheet![0].convDate
            .toString();
        _fundamentalData!.stockFinancialsStandalone!.incomeSheet!.sort((a, b) {
          return format
              .parse(b.yearEndDate!)
              .compareTo(format.parse(a.yearEndDate!));
        });
        _finnceYears = [];
        for (var element
            in _fundamentalData!.stockFinancialsStandalone!.incomeSheet!) {
          String formattedDate =
              DateFormat.yMMMMd().format(format.parse(element.yearEndDate!));

          List<String> date = [];

          date = formattedDate.split(" ");

          element.convDate =
              "${date[0].substring(0, 3)} ${date[2].substring(2)}";
          _finnceYears.add("${element.convDate}");
        }
        _fundamentalData!.stockFinancialsStandalone!.cashflowSheet!
            .sort((a, b) {
          return format
              .parse(b.yearEndDate!)
              .compareTo(format.parse(a.yearEndDate!));
        });
        _finnceYears = [];
        for (var element
            in _fundamentalData!.stockFinancialsStandalone!.cashflowSheet!) {
          String formattedDate =
              DateFormat.yMMMMd().format(format.parse(element.yearEndDate!));

          List<String> date = [];

          date = formattedDate.split(" ");

          element.convDate =
              "${date[0].substring(0, 3)} ${date[2].substring(2)}";
          _finnceYears.add("${element.convDate}");
        }

        List ltpArgs = [];

        for (var element in _fundamentalData!.peersComparison!.stock!) {
          ltpArgs.add({
            "exch": element.sYMBOL!.substring(0, 3),
            "token": "${element.zebuToken}"
          });
        }
        for (var element in _fundamentalData!.peersComparison!.peers!) {
          ltpArgs.add({
            "exch": element.sYMBOL!.substring(0, 3),
            "token": "${element.zebuToken}"
          });
        }

        final response = await api.getLTP(ltpArgs);

        Map res = jsonDecode(response.body);

        for (var element in _fundamentalData!.peersComparison!.stock!) {
          if (element.zebuToken.toString() ==
              "${res["data"]["${element.zebuToken}"]['token']}") {
            element.ltp = "${res["data"]["${element.zebuToken}"]["lp"]}";
          }
        }
        for (var element in _fundamentalData!.peersComparison!.peers!) {
          if (element.zebuToken.toString() ==
              "${res["data"]["${element.zebuToken}"]['token']}") {
            element.ltp = "${res["data"]["${element.zebuToken}"]["lp"]}";
          }
        }
        _peersChartKeys = _fundamentalData!.peerComparisonChart!.keys.toList();

        _prcComChrtData1 = [];
        _prcComChrtData2 = [];
        _prcComChrtData3 = [];
        _prcComChrtData4 = [];
        _prcComChrtData5 = [];

        for (var i = 0; i < _peersChartKeys.length; i++) {
          List close = _fundamentalData!
              .peerComparisonChart![_peersChartKeys[i]]['close'];
          List dates = _fundamentalData!
              .peerComparisonChart![_peersChartKeys[i]]['date'];

          for (var j = 0; j < dates.length; j++) {
            String formattedDate =
                DateFormat.yMMMMd().format(format.parse("${dates[j]}"));

            List<String> date = [];

            date = formattedDate.split(" ");

            if (i == 0) {
              _prcComChrtData1.add(PrcComparisionChartData(
                  "${date[0].toString().substring(0, 3)} ${date[2].substring(2)}",
                  close[j]));
            } else if (i == 1) {
              _prcComChrtData2.add(PrcComparisionChartData(
                  "${date[0].toString().substring(0, 3)} ${date[2].substring(2)}",
                  close[j]));
            } else if (i == 2) {
              _prcComChrtData3.add(PrcComparisionChartData(
                  "${date[0].toString().substring(0, 3)} ${date[2].substring(2)}",
                  close[j]));
            } else if (i == 3) {
              _prcComChrtData4.add(PrcComparisionChartData(
                  "${date[0].toString().substring(0, 3)} ${date[2].substring(2)}",
                  close[j]));
            } else {
              _prcComChrtData5.add(PrcComparisionChartData(
                  "${date[0].toString().substring(0, 3)} ${date[2].substring(2)}",
                  close[j]));
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Fundamental ", "Error": "$e"});
      notifyListeners();
      debugPrint(e.toString());
    } finally {}
  }

  techDataCalc(String lastPrc) {
    _returnsGridview = [];
    double ltp = double.parse(lastPrc);

    if (_techData != null) {
      double wk1c =
          double.parse(_techData == null ? "0.00" : _techData!.wk1C ?? "0.00");
      double wk1Def = ltp - wk1c;
      _techData!.wk1Pc = ((wk1Def / wk1c) * 100).toStringAsFixed(2);

      _returnsGridview.add({
        "duration": "One Week",
        "low": "${_techData!.wk1L}",
        "high": "${_techData!.wk1H}",
        "percent":
            _techData!.wk1Pc == "Infinity" ? "0.00" : "${_techData!.wk1Pc}",
        "ltp": lastPrc
      });

      double wk2c = double.parse(_techData!.wk2C ?? "0.00");
      double wk2Def = ltp - wk2c;
      _techData!.wk2Pc = ((wk2Def / wk2c) * 100).toStringAsFixed(2);

      _returnsGridview.add({
        "duration": "Two Week",
        "low": "${_techData!.wk2L}",
        "high": "${_techData!.wk2H}",
        "percent":
            _techData!.wk2Pc == "Infinity" ? "0.00" : "${_techData!.wk2Pc}",
        "ltp": lastPrc
      });
      double mnth1c = double.parse(_techData!.mnth1C ?? "0.00");
      double mnth1Def = ltp - mnth1c;
      _techData!.mnth1Pc = ((mnth1Def / mnth1c) * 100).toStringAsFixed(2);

      _returnsGridview.add({
        "duration": "One Month",
        "low": "${_techData!.mnth1L}",
        "high": "${_techData!.mnth1H}",
        "percent":
            _techData!.mnth1Pc == "Infinity" ? "0.00" : "${_techData!.mnth1Pc}",
        "ltp": lastPrc
      });
      double mnth3c = double.parse(_techData!.mnth3C ?? "0.00");
      double mnth3Def = ltp - mnth3c;
      _techData!.mnth3Pc = ((mnth3Def / mnth3c) * 100).toStringAsFixed(2);

      _returnsGridview.add({
        "duration": "Three Month",
        "low": "${_techData!.mnth3L}",
        "high": "${_techData!.mnth3H}",
        "percent":
            _techData!.mnth3Pc == "Infinity" ? "0.00" : "${_techData!.mnth3Pc}",
        "ltp": lastPrc
      });
      double wk52c = double.parse(_techData!.wk52C ?? "0.00");
      double wk52Def = ltp - wk52c;
      _techData!.wk52Pc = ((wk52Def / wk52c) * 100).toStringAsFixed(2);

      _returnsGridview.add({
        "duration": "52 Week",
        "low": "${_techData!.wk52L}",
        "high": "${_techData!.wk52H}",
        "percent":
            _techData!.wk52Pc == "Infinity" ? "0.00" : "${_techData!.wk52Pc}",
        "ltp": lastPrc
      });
    }
  }

  splitOptionChain(BuildContext context) {
    _optChainCall = [];
    _optChainPut = [];

    for (var element in _optionChainModel!.optValue!) {
      Map spilitSymbol = spilitTsym(value: "${element.tsym}");

      element.symbol = "${spilitSymbol["symbol"]}";
      element.expDate = "${spilitSymbol["expDate"]}";
      element.option = "${spilitSymbol["option"]}";
      if (element.optt == "CE") {
        _optChainCall.add(element);

        int callLength = _optChainCall.length ~/ 2;
        _optChainCallDown = _optChainCall.sublist(0, callLength);

        _optChainCallUp = _optChainCall.sublist(callLength);
      } else {
        _optChainPut.add(element);
        int putLength = _optChainPut.length ~/ 2;
        _optChainPutDown = _optChainPut.sublist(0, putLength);

        _optChainPutUp = _optChainPut.sublist(putLength);
      }
    }
    notifyListeners();
    requestWSOptChain(context: context, isSubscribe: true);
  }

  requestWSOptChain(
      {required bool isSubscribe, required BuildContext context}) {
    String input = "";
    if (_optionChainModel != null) {
      if (_optionChainModel!.optValue != null) {
        for (var element in _optionChainModel!.optValue!) {
          input += "${element.exch}|${element.token}#";
        }
      }
    }

    if (input.isNotEmpty) {
      // lastScbTok(input);
      ref(websocketProvider).establishConnection(
          channelInput: input.substring(0, input.length - 1),
          task: isSubscribe ? "t" : "u",
          context: context);
    }
  }

  requestWSFut({required bool isSubscribe, required BuildContext context}) {
    String input = "";

    if (_fut!.isNotEmpty) {
      for (var element in _fut!) {
        input += "${element.exch}|${element.token}#";
      }
    }

    notifyListeners();

    if (input.isNotEmpty) {
      // lastScbTok(input);
      ref(websocketProvider).establishConnection(
          channelInput: input.substring(0, input.length - 1),
          task: isSubscribe ? "t" : "u",
          context: context);
    }
  }

  marketWatchScripSearch(String value) {
    if (value.length > 1) {
      _searchMWLScrip = [];
      Fluttertoast.cancel();
      _searchMWLScrip = _watchListValues
          .where((element) => element.tsym!.toLowerCase().contains(value))
          .toList();
      if (_searchMWLScrip.isEmpty) {}
    } else {
      _searchMWLScrip = [];
    }
    notifyListeners();
  }

//  REWORK TO CHANGE FLOW =========

  changeWLScrip(String wName, BuildContext context) async {
    _scrips = wName == "My Stocks"
        ? []
        : await jsonDecode(_marketWatchScripData[wName]);

    if (wName == "My Stocks") {
      await ref(portfolioProvider)
          .requestWSHoldings(context: context, isSubscribe: true);
    } else {
      await requestMWScrip(context: context, isSubscribe: true);
    }

    notifyListeners();
  }

  deleteWatchList(String wlName, BuildContext context) async {
    String input = "";

    for (var element in _scrips) {
      input += "${element['exch']}|${element['token']}#";
    }

    _addDeleteScripModel = await api.getAddDeleteSciptoMW(
        isAdd: false, scripToken: input, wlname: wlName);

    if (_addDeleteScripModel!.stat!.toUpperCase() == "OK") {
      await changeWlName("", "No");
      await fetchMWList(context);
    }
  }

  addWatchList(String wlName, BuildContext context) async {
    _addDeleteScripModel = await api.getAddDeleteSciptoMW(
        isAdd: true, scripToken: "", wlname: wlName);

    if (_addDeleteScripModel!.stat!.toUpperCase() == "OK") {
      await changeWlName(wlName, "No");
      await fetchMWList(context);
    } else {
      ref(authProvider).ifSessionExpired(context);
    }
  }

  addDelMarketScrip(String wlName, String scripTok, BuildContext context,
      bool isAdd, bool isEdit, bool isReOrder) async {
    _addDeleteScripModel = await api.getAddDeleteSciptoMW(
        isAdd: isAdd, scripToken: scripTok, wlname: wlName);

    if (_addDeleteScripModel!.stat!.toUpperCase() == "OK") {
      ConstantName.sessCheck = true;
      if (!isReOrder) {
        await fetchMWScrip(wlName, context);

        await changeWLScrip(wlName, context);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Scrip order was changed"));
      }

      if (!isEdit) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(successMessage(
            context,
            isAdd
                ? "Scrip was added to watchlist $wlName"
                : "Scrip was removed from watchlist $wlName"));
      }
    } else if (_addDeleteScripModel!.emsg ==
        "Session Expired :  Invalid Session Key") {
      ref(authProvider).ifSessionExpired(context);
    }
  }

  requestMWScrip(
      {required bool isSubscribe, required BuildContext context}) async {
    String input = "";
    _delScripQty = 0;

    if (_scrips.isNotEmpty) {
      for (var element in _scrips) {
        element['isSelected'] = false;
        input += "${element['exch']}|${element['token']}#";
      }
    } else {
      input = ref(indexListProvider).indexSubToken;
    }

    if (input.isNotEmpty) {
      input += ref(indexListProvider).indexSubToken;
      _mwSubToken = input;

      await ref(websocketProvider).establishConnection(
          channelInput: input, task: isSubscribe ? "t" : "u", context: context);
    }
  }

  getSortByWL(String val) {
    _sortByWL = val;
    notifyListeners();
  }

  filterMWScrip(
      {required String sorting,
      required String wlName,
      required BuildContext context}) async {
    final localstorage = await SharedPreferences.getInstance();

    String addInput = "";
    String delInput = "";
    List<String> filterData = [];
    if (sorting == "Scrip - Z to A") {
      _scrips.sort((a, b) {
        filterData.add("${b['exch']}|${b['token']}#");
        return b['tsym'].toString().compareTo(a['tsym'].toString());
      });

      filterData = filterData.toSet().toList();

      for (var element in filterData) {
        delInput += element;
      }
      for (var element in _scrips) {
        addInput += "${element['exch']}|${element['token']}#";
      }
      await addDelMarketScrip(wlName, delInput, context, false, true, false);
      await addDelMarketScrip(wlName, addInput, context, true, true, false);
    } else if (sorting == "Scrip - A to Z") {
      _scrips.sort((a, b) {
        filterData.add("${b['exch']}|${b['token']}#");
        return a['tsym'].toString().compareTo(b['tsym'].toString());
      });

      filterData = filterData.toSet().toList();
      for (var element in filterData) {
        delInput += element;
      }
      for (var element in _scrips) {
        addInput += "${element['exch']}|${element['token']}#";
      }

      await addDelMarketScrip(wlName, delInput, context, false, true, false);
      await addDelMarketScrip(wlName, addInput, context, true, true, false);
    } else if (sorting == "Price - Low to High") {
      _scrips.sort((a, b) {
        filterData.add("${b['exch']}|${b['token']}#");

        return double.parse(a['ltp']).compareTo(double.parse(b['ltp']));
      });

      filterData = filterData.toSet().toList();
      for (var element in filterData) {
        delInput += element;
      }
      for (var element in _scrips) {
        addInput += "${element['exch']}|${element['token']}#";
      }
      await addDelMarketScrip(wlName, delInput, context, false, true, false);
      await addDelMarketScrip(wlName, addInput, context, true, true, false);
    } else if (sorting == "Price - High to Low") {
      _scrips.sort((a, b) {
        filterData.add("${b['exch']}|${b['token']}#");

        return double.parse(b['ltp']).compareTo(double.parse(a['ltp']));
      });

      filterData = filterData.toSet().toList();
      for (var element in filterData) {
        delInput += element;
      }
      for (var element in _scrips) {
        addInput += "${element['exch']}|${element['token']}#";
      }
      await addDelMarketScrip(wlName, delInput, context, false, true, false);
      await addDelMarketScrip(wlName, addInput, context, true, true, false);
    } else if (sorting == "Per.Chng - High to Low") {
      _scrips.sort((a, b) {
        filterData.add("${b['exch']}|${b['token']}#");
        return double.parse("${b['perChange']}")
            .compareTo(double.parse("${a['perChange']}"));
      });

      filterData = filterData.toSet().toList();
      for (var element in filterData) {
        delInput += element;
      }
      for (var element in _scrips) {
        addInput += "${element['exch']}|${element['token']}#";
      }
      await addDelMarketScrip(wlName, delInput, context, false, true, false);
      await addDelMarketScrip(wlName, addInput, context, true, true, false);
    } else if (sorting == "Per.Chng - Low to High") {
      _scrips.sort((a, b) {
        filterData.add("${b['exch']}|${b['token']}#");
        return double.parse("${a['perChange']}")
            .compareTo(double.parse("${b['perChange']}"));
      });

      filterData = filterData.toSet().toList();
      for (var element in filterData) {
        delInput += element;
      }
      for (var element in _scrips) {
        addInput += "${element['exch']}|${element['token']}#";
      }
      await addDelMarketScrip(wlName, delInput, context, false, true, false);
      await addDelMarketScrip(wlName, addInput, context, true, true, false);
    }

    _sortByWL = sorting;
    localstorage.setString("sortByWL", _sortByWL);
    notifyListeners();
  }

  delQty() {
    _delScripQty = 0;
    notifyListeners();
  }

  void selectDeleteScrip(int index) {
    if (_scrips[index]['isSelected']) {
      _scrips[index]['isSelected'] = false;
      _delScripQty = _delScripQty - 1;
    } else {
      _scrips[index]['isSelected'] = true;
      _delScripQty = _delScripQty + 1;
    }

    notifyListeners();
  }

  deleteScrip(BuildContext context, String wlName) async {
    String input = "";
    for (var element in _scrips) {
      if (element['isSelected']) {
        input += "${element['exch']}|${element['token']}#";
      }
    }
    await addDelMarketScrip(wlName, input, context, false, false, false);

    if (_scrips.isEmpty) {
      Navigator.pop(context);
    }
    _delScripQty = 0;
    notifyListeners();
  }

  void reOrderList(
      {required int oldIndex,
      required int newIndex,
      required String wlName,
      required BuildContext context}) async {
    final localstorage = await SharedPreferences.getInstance();
    final int oldI = oldIndex;
    int newI = newIndex;
    if (newI > oldI) {
      newI -= 1;
    }
    String addInput = "";
    String deleteInput = "";

    final element = _scrips.removeAt(oldI);
    deleteInput = "${element['exch']}|${element['token']}#";
    for (var elementa in _scrips) {
      deleteInput += "${elementa['exch']}|${elementa['token']}#";
    }

    _scrips.insert(newI, element);

    await addDelMarketScrip(wlName, deleteInput, context, false, true, true);

    for (var elements in _scrips) {
      addInput += "${elements['exch']}|${elements['token']}#";
    }

    await addDelMarketScrip(wlName, addInput, context, true, true, false);
    _sortByWL = "";

    localstorage.setString("sortByWL", _sortByWL);
    notifyListeners();
  }

  //////SET ALERT//////

  Future fetchSetAlert(
      String exch,
      String tysm,
      String value,
      String alertTypeVal,
      BuildContext context,
      int index,
      String lp,
      String remark) async {
    try {
      _setAlertModel =
          await api.getSetAlert(exch, tysm, value, alertTypeVal, remark);
      context.read(marketWatchProvider).alertPendingModel!.length;
      fetchPendingAlert(context);
      if (_setAlertModel!.stat! == "OI created") {
        fetchPendingAlert(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "${_setAlertModel?.stat}"));
      } else if (_setAlertModel!.stat! == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
      return _setAlertModel;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future fetchPendingAlert(BuildContext context) async {
    try {
      _alertPendingModel = await api.getPendingAlert();

      List ltpArgs = [];

      if (_alertPendingModel!.isNotEmpty) {
        if (_alertPendingModel![0].stat != "Not_Ok") {
          ConstantName.sessCheck = true;
          for (var element in _alertPendingModel!) {
            ltpArgs
                .add({"exch": "${element.exch}", "token": "${element.token}"});
          }
          final response = await api.getLTP(ltpArgs);
          Map res = jsonDecode(response.body);
          for (var element in _alertPendingModel!) {
            if (element.token.toString() ==
                "${res["data"]["${element.token}"]['token']}") {
              element.ltp = "${res["data"]["${element.token}"]["lp"]}";
              element.close = "${res["data"]["${element.token}"]["close"]}";

              element.perChange =
                  "${res["data"]["${element.token}"]["change"]}";
              element.change = (double.parse(
                          "${element.ltp == "0" ? element.close : element.ltp}") -
                      double.parse("${element.close}"))
                  .toStringAsFixed(2);
            }
          }
        } else {
          _alertPendingModel = [];
          ConstantName.sessCheck = false;
        }
      }

      notifyListeners();
      return _alertPendingModel;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future fetchCancelAlert(String alid, BuildContext context) async {
    try {
      if (_cancelalert?.stat == "OI deleted") {
        fetchPendingAlert(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "${_cancelalert?.stat}"));
        context.read(marketWatchProvider)._alertPendingModel!.length;
      }
      _cancelalert = await api.getCancelAlert(alid);
      ConstantName.sessCheck = true;
      if (_cancelalert!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _cancelalert;
    } catch (e) {
      rethrow;
    }
  }

  Future fetchmodifyalert(String exch, String tysm, String value,
      String alertTypeVal, String alid, BuildContext context) async {
    try {
      _modifyalertmodel =
          await api.getmodifyalert(exch, tysm, value, alertTypeVal, alid);

      if (_modifyalertmodel!.stat! == "OI replaced") {
        ConstantName.sessCheck = true;
        fetchPendingAlert(context);
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "${_modifyalertmodel?.stat}"));
      } else if (_modifyalertmodel!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
      return _modifyalertmodel;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
