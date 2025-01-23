// ignore_for_file: use_build_context_synchronously

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
import '../models/marketwatch_model/watchlist_rename_model.dart';
import '../res/res.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'order_provider.dart';
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

  final TextEditingController alertPendingSearchtext = TextEditingController();

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

//  Pre-defined market watchlist

  final List<String> _preDefWL = [
    "My Stocks",
    "Nifty50",
    "Niftybank",
    "Sensex"
  ];

// Search scrip Filter by Instument name

  final List<Tab> _searchTabList = const [
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

  // GetQuotes? _getQuotes;
  GetQuotes _getQuotes = GetQuotes(
    requestTime: '',
    stat: '',
    exch: '',
    tsym: '',
    cname: '',
    symname: '',
    seg: '',
    instname: '',
    isin: '',
    pp: "0.0",
    ls: "0.0",
    ti: "0",
    mult: "0.0",
    lut: '',
    uc: "0.0",
    lc: "0.0",
    wk52H: "0.0",
    wk52L: "0.0",
    toi: "0",
    issuecap: '',
    cutofAll: '',
    prcftrD: "0.0",
    token: '',
    lp: "0.0",
    c: "0.0",
    h: "0.0",
    l: "0.0",
    ap: "0.0",
    o: "0.0",
    v: "0",
    ltq: "0",
    ltt: '',
    ltd: '',
    tbq: "0.0",
    tsq: "0.0",
    bp1: "0.0",
    sp1: "0.0",
    ordMsg: '',
    emsg: "",
    poi: "",
    chng: "",
    pc: "",
    expDate: "",
    option: "",
    symbol: "",
  );
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

  CancelAlertModel? _cancelalert;
  CancelAlertModel? get cancelalert => _cancelalert;

  SetAlertModel? _setAlertModel;
  SetAlertModel? get setAlertModel => _setAlertModel;

  ModifyAlertModel? _modifyalertmodel;
  ModifyAlertModel? get modifyalertmodel => _modifyalertmodel;

  List<AlertPendingModel>? _alertPendingModel = [];
  List<AlertPendingModel>? get alertPendingModel => _alertPendingModel;

  List<AlertPendingModel>? _alertPendingSearch = [];
  List<AlertPendingModel>? get alertPendingSearch => _alertPendingSearch;

  WatchlistRenameModel? _watchlistRenameModel;
  WatchlistRenameModel? get watchlistRenameModel => _watchlistRenameModel;

  final String _mwSubToken = "";
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

  final String _firstGetData = "0";
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

  bool _showAlertSearch = false;
  bool get showAlertSearch => _showAlertSearch;

  bool _scripDepthloader = false;
  bool get scripDepthloader => _scripDepthloader;

  Map<String, Map<String, dynamic>> storeQuotes = {};

  singlePageloader(bool value) {
    _scripDepthloader = value;
    notifyListeners();
  }

  showAlertPendingSearch(bool value) {
    _showAlertSearch = value;
    if (!_showAlertSearch) {
      _alertPendingSearch = [];
    }
    notifyListeners();
  }

  clearAlertSearch() {
    alertPendingSearchtext.clear();
    _alertPendingSearch = [];
    notifyListeners();
  }

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

// Set height for dropdown list items

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

// Add Divider for dropdown list items
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
              child: Divider(
                  color: ref(themeProvider).isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider),
            ),
        ],
      );
    }
    return menuItems;
  }

// Option chain options

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

  orderAletrPendingSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _alertPendingSearch = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _alertPendingSearch = _alertPendingModel!
          .where((element) => element.tsym!.toLowerCase().contains(value))
          .toList();
      if (_alertPendingSearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _alertPendingSearch = [];
    }

    notifyListeners();
  }

// Search scrip by tarde symbol

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

// Change watchlist name
  changeWlName(String name, String isWList) {
    _wlName = name;
    _isPreDefWLs = isWList;
    notifyListeners();
  }

// clear search filter values

  searchClear() {
    _searchErrorText = "Enter more than TWO letters";

    // _searchScripModel!.values = [];
    _allSearchScrip = [];
    _commoditySearchScrip = [];
    _fNoSearchScrip = [];
    _equitySearchScrip = [];
    _currencySearchScrip = [];

    notifyListeners();
  }

// Watchlist scrip delete selection

  isActiveAddBtn(bool val, int index) {
    _isAdded![index] = val;

    notifyListeners();
  }

  Map _marketWatchScripData = {};
  Map get marketWatchScripData => _marketWatchScripData;

  List _scrips = [];
  List get scrips => _scrips;

// Fetching data from the api and stored in a variable

  Future fetchMWList(BuildContext context) async {
    try {
      _marketWatchlist = await api.getMWList();
      pref.setMWScrip(true);
      pref.setMWPrice(true);
      pref.setMWPerchnage(true);
      if (_marketWatchlist!.stat == "Ok") {
        ConstantName.sessCheck = true;
        if (_marketWatchlist!.values!.isEmpty) {
          _marketWatchlist!.values!.add("My");
        } else {
          _marketWatchlist!.values!.sort((a, b) => a.compareTo(b));

          _marketWatchScripData = {};
          for (var element in _marketWatchlist!.values!) {
            await fetchMWScrip(element, context);
          }
        }

        if (_wlName.isEmpty) {
          _wlName = _marketWatchlist!.values!.first;
        }

        _marketWatchlist!.values!.addAll(_preDefWL);

        await fetchPreDefMWScrip(context);
        await changeWLScrip(_wlName, context);
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

// Fetching data from the api and stored in a variable

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
// Seperating Trade symbol(symbol,exp date, Option)

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

            // Holdings Qty add to market watch scrip
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

// Fetching data from the api and stored in a variable
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
              // Seperating Trade symbol(symbol,exp date, Option)
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
// Seperating Trade symbol(symbol,exp date, Option)

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
              // Seperating Trade symbol(symbol,exp date, Option)
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
// Pre-define market scrip adding to watchlist
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

// Fetching data from the api and stored in a variable
  Future fetchScripInfo(String token, String exch, BuildContext context) async {
    try {
      if (storeQuotes.containsKey(token) && storeQuotes[token]?['s'] != null) {
        _scripInfoModel = storeQuotes[token]?['s'];
        ConstantName.sessCheck = true;
        print('qqq if si');
      } else {
        print('qqq else');
        _scripInfoModel = await api.getScripInfo(token, exch);

        if (_scripInfoModel!.stat == "Ok") {
          // Seperating Trade symbol(symbol,exp date, Option)
          ConstantName.sessCheck = true;
          if (_scripInfoModel!.exch == "BFO" &&
              _scripInfoModel!.dname != null) {
            List<String> splitVal = _scripInfoModel!.dname!.split(" ");

            _scripInfoModel!.symbol = splitVal[0];
            _scripInfoModel!.expDate = "${splitVal[1]} ${splitVal[2]}";
            _scripInfoModel!.option = splitVal.length > 4
                ? "${splitVal[3]} ${splitVal[4]}"
                : splitVal[3];
          } else {
            Map spilitSymbol = spilitTsym(value: "${_scripInfoModel!.tsym}");

            _scripInfoModel!.symbol = "${spilitSymbol["symbol"]}";
            _scripInfoModel!.expDate = "${spilitSymbol["expDate"]}";
            _scripInfoModel!.option = "${spilitSymbol["option"]}";
          }
          storeQuotes[token]?['s'] = {};
          storeQuotes[token]?['s'] = _scripInfoModel;
        }

        if (_scripInfoModel!.emsg == "Session Expired :  Invalid Session Key" &&
            _scripInfoModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }

      notifyListeners();
      return _scripInfoModel;
    } catch (e) {
      print(e);
      ref(indexListProvider)
          .logError
          .add({"type": "API Scrip Info", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

// Fetching data from the api and stored in a variable
  Future fetchScripQuote(
      String token, String exch, BuildContext context) async {
    try {
      _returnsGridview = [];
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

      final portfolios = ref(portfolioProvider);

      if (portfolios.oplists.isNotEmpty &&
          portfolios.oplists.contains(int.parse(token))) {
        _depthBtns.add({
          "btnName": "Option",
          "imgPath": assets.optChainIcon,
          "case": "Click here to view the Option chain details."
        });
        _depthBtns.add({
          "btnName": "Future",
          "imgPath": assets.optChainIcon,
          "case": "click here to view the futures of the underline scrpit."
        });
      } 
      if(exch == 'NSE' || exch == 'BSE') {
            _depthBtns.add({
          "btnName": "Fundamental",
          "imgPath": assets.dInfo,
          "case": "Click here to view fundamental data."
        });
        
      }
        _depthBtns.add({
          "btnName": "Set Alert",
          "imgPath": assets.calendar,
          "case": "click here to view the futures of the underline scrpit."
        });
      if (storeQuotes.isNotEmpty &&
          storeQuotes.containsKey(token) &&
          storeQuotes[token]?['q'] != null) {
        print('qqq sq if');
        ConstantName.sessCheck = true;
        _getQuotes = storeQuotes[token]?['q'];
      } else {
        print('qqq qs else');
        _getQuotes = await api.getScripQuote(token, exch);

        if (_getQuotes.stat == "Ok") {
          ConstantName.sessCheck = true;
// Seperating Trade symbol(symbol,exp date, Option)
          if (_getQuotes.exch == "BFO" && _getQuotes.cname != null) {
            List<String> splitVal = _getQuotes.cname!.split(" ");

            _getQuotes.symbol = splitVal[0];
            _getQuotes.expDate = "${splitVal[1]} ${splitVal[2]}";
            _getQuotes.option = splitVal.length > 4
                ? "${splitVal[3]} ${splitVal[4]}"
                : splitVal[3];
          } else {
            Map spilitSymbol = spilitTsym(value: "${_getQuotes.tsym}");
            _getQuotes.symbol = "${spilitSymbol["symbol"]}";
            _getQuotes.expDate = "${spilitSymbol["expDate"]}";
            _getQuotes.option = "${spilitSymbol["option"]}";
          }

          storeQuotes[token] = {};
          storeQuotes[token]?['q'] = _getQuotes;
          _optionStrPrc = "${_getQuotes.lp}";

// Scrip market depth calc
          scripQtyCal();
        }
        if (_getQuotes.emsg == "Session Expired :  Invalid Session Key" &&
            _getQuotes.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
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

  // Fetching stike price for  option chain

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

// Scrip market depth calc
  void scripQtyCal() {
    if (_getQuotes.instname != "UNDIND" && _getQuotes.instname != "COM") {
      if ((_getQuotes.tbq != "null" && _getQuotes.tbq != null) ||
          (_getQuotes.tsq != "null" && _getQuotes.tsq != null)) {
        _totBuyQtyPer = (int.tryParse(_getQuotes.tbq?.toString() ?? "0") ?? 0) /
            ((int.tryParse(_getQuotes.tbq?.toString() ?? "0") ?? 0) +
                (int.tryParse(_getQuotes.tsq?.contains('.') == true
                        ? _getQuotes.tsq!.split(".")[0]
                        : _getQuotes.tsq ?? "0") ??
                    0)) *
            100;

        int tbqValue = int.tryParse(_getQuotes.tbq ?? "0") ?? 0;
        int tsqValue = int.tryParse(
                _getQuotes.tsq != null && _getQuotes.tsq!.contains('.')
                    ? _getQuotes.tsq!.split(".")[0]
                    : _getQuotes.tsq ?? "0") ??
            0;
        if ((tbqValue + tsqValue) == 0) {
          _totSellQtyPer = 0;
        } else {
          _totSellQtyPer = (tsqValue / (tbqValue + tsqValue)) * 100;
        }
        if (_totBuyQtyPer.isNaN) {
          _totBuyQtyPer = 0.00;
        }
        if (_totSellQtyPer.isNaN) {
          _totSellQtyPer = 0.00;
        }
        _totBuyQtyPerChng = _totBuyQtyPer / 100;
        // Parse each value safely using int.tryParse
        _maxSellQty = [
          int.tryParse(_getQuotes.sq2 ?? "0") ?? 0,
          int.tryParse(_getQuotes.sq1 ?? "0") ?? 0,
          int.tryParse(_getQuotes.sq3 ?? "0") ?? 0,
          int.tryParse(_getQuotes.sq4 ?? "0") ?? 0,
          int.tryParse(_getQuotes.sq5 ?? "0") ?? 0
        ].reduce(max);

// Parse each value safely for maxBuyQty
        _maxBuyQty = [
          int.tryParse(_getQuotes.bq2 ?? "0") ?? 0,
          int.tryParse(_getQuotes.bq1 ?? "0") ?? 0,
          int.tryParse(_getQuotes.bq3 ?? "0") ?? 0,
          int.tryParse(_getQuotes.bq4 ?? "0") ?? 0,
          int.tryParse(_getQuotes.bq5 ?? "0") ?? 0
        ].reduce(max);
      }
    }
  }

// Fetching data from the api and stored in a variable
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
// Seperating Trade symbol(symbol,exp date, Option)

            if (_searchScripModel!.values![i].exch == "BFO" &&
                _searchScripModel!.values![i].dname != null) {
              List<String> splitVal =
                  _searchScripModel!.values![i].dname!.split(" ");

              _searchScripModel!.values![i].symbol = splitVal[0];
              _searchScripModel!.values![i].expDate =
                  "${splitVal[1]} ${splitVal[2]}";
              _searchScripModel!.values![i].option = splitVal.length > 4
                  ? "${splitVal[3]} ${splitVal[4]}"
                  : splitVal[3];
            } else {
              Map spilitSymbol =
                  spilitTsym(value: "${_searchScripModel!.values![i].tsym}");

              _searchScripModel!.values![i].symbol =
                  "${spilitSymbol["symbol"]}";
              _searchScripModel!.values![i].expDate =
                  "${spilitSymbol["expDate"]}";
              _searchScripModel!.values![i].option =
                  "${spilitSymbol["option"]}";
            }
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

  // Fetching data from the api and stored in a variable

  Future fetchLinkeScrip(
      String token, String exch, BuildContext context) async {
    try {
      // _depthBtns = [
      //   {
      //     "btnName": "Overview",
      //     "imgPath": assets.dInfo,
      //     "case": "click here to view the market depth."
      //   },
      //   {
      //     "btnName": "Chart",
      //     "imgPath": assets.charticon,
      //     "case": "Click here to view the trading view chart."
      //   }
      // ];
      if (storeQuotes.containsKey(token) && storeQuotes[token]?['l'] != null) {
        print('qqq ls if ');
        ConstantName.sessCheck = true;
        _linkedScrips = storeQuotes[token]?['l']['all'];
        _equls = storeQuotes[token]?['l']['eq'];
        _fut = storeQuotes[token]?['l']['fu'];
        _optExp = storeQuotes[token]?['l']['op'];
        if (_optExp!.isNotEmpty) {

          _sortedDate = storeQuotes[token]?['l']['sortdate'];
          _selectedExpDate = _sortedDate[0];

          _optionExch = storeQuotes[token]?['l']['optionExch'];
          _selectedTradeSym = storeQuotes[token]?['l']['selectedTradeSym'];
        }
        if (_fut!.isNotEmpty) {

          _futToken = "${_fut![0].token}";
          __futExch = "${_fut![0].exch}";
        }
      } else {
        print('qqq ls else');
        _linkedScrips = await api.getLinkedScrip(token, exch);
        if (_linkedScrips!.stat == "Ok") {
          ConstantName.sessCheck = true;
          _equls = _linkedScrips!.equls;
          _fut = _linkedScrips!.fut;
          _optExp = _linkedScrips!.optExp;

          if (_optExp!.isNotEmpty) {

// Option expiry Date wise sorting

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
            _futToken = "${_fut![0].token}";
            __futExch = "${_fut![0].exch}";

            // print("Future $_futToken  $__futExch ");

            // Seperating Trade symbol(symbol,exp date, Option)
            for (var element in _fut!) {
              Map spilitSymbol = spilitTsym(value: "${element.tsym}");

              element.symbol = "${spilitSymbol["symbol"]}";
              element.expDate = "${spilitSymbol["expDate"]}";
              element.option = "${spilitSymbol["option"]}";
            }
          }
          storeQuotes[token]?['l'] = {};
          storeQuotes[token]?['l'] = {
            'all': _linkedScrips,
            'eq': _equls,
            'fu': _fut,
            'op': _optExp,
            'sortdate': _sortedDate,
            'optionExch': _optionExch,
            'selectedTradeSym': _selectedTradeSym,
          };
        } else {
          ref(authProvider).ifSessionExpired(context);
        }
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

// Fetching data from the api and stored in a variable
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

        // Seprating option chain scrips (Call / Put)
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

// Fetching data from the api and stored in a variable
  Future fetchTechData(
      {required String exch,
      required String tradeSym,
      required String lastPrc,
      required BuildContext context}) async {
    try {
      String? token = _getQuotes.token;
      if (storeQuotes.containsKey(token) && storeQuotes[token]?['t'] != null) {
        print('qqq td if ');
        ConstantName.sessCheck = true;
        _techData = storeQuotes[token]?['t'];
      } else {
        print('qqq td else');
        _techData = await api.getTechData(exch, tradeSym);
        _returnsGridview = [];
        if (_techData!.stat == "OK") {
          ConstantName.sessCheck = true;
          storeQuotes[token]?['t'] = {};
          storeQuotes[token]?['t'] = _techData;
        }

        if (_techData!.emsg == "Session Expired :  Invalid Session Key" &&
            _techData!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }
      techDataCalc(lastPrc);

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

// Fetching fundametal datas
  Future fetchFundamentalData({required String tradeSym}) async {
    try {
      String? token = _getQuotes.token;
      if (storeQuotes.containsKey(token) && storeQuotes[token]?['f'] != null) {
        _fundamentalData = storeQuotes[token]?['f'];
      } else {
        _fundamentalData = await api.getFundamentalData(tradeSym);
      }

      List ltpArgs = [];

      if (_fundamentalData!.msg != "no data found") {
        storeQuotes[token]?['f'] = {};
        storeQuotes[token]?['f'] = _fundamentalData;
        _peersChartKeys = _fundamentalData!.peerComparisonChart!.keys.toList();
        DateFormat format = DateFormat("yyyy-MM-dd");
        _mfHoldingDate = [];

        void sortAndFormatDates(
            List<dynamic> data,
            String Function(dynamic) getDate,
            void Function(dynamic, String) setConvDate) {
          data.sort((a, b) =>
              format.parse(getDate(b)).compareTo(format.parse(getDate(a))));
          for (var element in data) {
            String formattedDate =
                DateFormat.yMMMMd().format(format.parse(getDate(element)));
            List<String> date = formattedDate.split(" ");
            setConvDate(
                element, "${date[0].substring(0, 3)} ${date[2].substring(2)}");
          }
        }

        // Shareholding dates
        sortAndFormatDates(
          _fundamentalData!.stockFinancialsConsolidated!.balanceSheet!,
          (element) => element.yearEndDate!,
          (element, value) => element.convDate = value,
        );

        // Financial statements
        var consolidated = _fundamentalData!.stockFinancialsConsolidated!;
        var standalone = _fundamentalData!.stockFinancialsStandalone!;
        sortAndFormatDates(
          consolidated.balanceSheet!,
          (element) => element.yearEndDate!,
          (element, value) => element.convDate = value,
        );
        sortAndFormatDates(
          consolidated.incomeSheet!,
          (element) => element.yearEndDate!,
          (element, value) => element.convDate = value,
        );
        sortAndFormatDates(
          consolidated.cashflowSheet!,
          (element) => element.yearEndDate!,
          (element, value) => element.convDate = value,
        );
        sortAndFormatDates(
          standalone.balanceSheet!,
          (element) => element.yearEndDate!,
          (element, value) => element.convDate = value,
        );
        sortAndFormatDates(
          standalone.incomeSheet!,
          (element) => element.yearEndDate!,
          (element, value) => element.convDate = value,
        );
        sortAndFormatDates(
          standalone.cashflowSheet!,
          (element) => element.yearEndDate!,
          (element, value) => element.convDate = value,
        );

        _selctedFinYear = standalone.balanceSheet![0].convDate!;
        _finnceYears = standalone.incomeSheet!.map((e) => e.convDate!).toList();

        // Peer comparisons
        for (var peers in [
          _fundamentalData!.peersComparison!.stock!,
          _fundamentalData!.peersComparison!.peers!
        ]) {
          for (var element in peers) {
            String ltp = element.sYMBOL!.substring(0, 3);
            String tok = element.zebuToken!;
            if (ltp.isNotEmpty && tok.isNotEmpty) {
              ltpArgs.add({"exch": ltp, "token": tok});
            }
          }
        }

        final response = await api.getLTP(ltpArgs);
        Map res = jsonDecode(response.body);

        void updateLtpData(List data) {
          for (var element in data) {
            String tok = element.zebuToken!;
            if (tok.isNotEmpty && tok == res["data"][tok]?['token']) {
              element.ltp = res["data"][tok]["lp"];
            }
          }
        }

        updateLtpData(_fundamentalData!.peersComparison!.stock!);
        updateLtpData(_fundamentalData!.peersComparison!.peers!);

        // Price comparison chart data
        List<List<PrcComparisionChartData>> chartDataLists = [
          _prcComChrtData1,
          _prcComChrtData2,
          _prcComChrtData3,
          _prcComChrtData4,
          _prcComChrtData5,
        ];

        for (var i = 0; i < _peersChartKeys.length; i++) {
          var close = _fundamentalData!.peerComparisonChart![_peersChartKeys[i]]
              ['close'];
          var dates = _fundamentalData!.peerComparisonChart![_peersChartKeys[i]]
              ['date'];
          for (var j = 0; j < dates.length; j++) {
            String formattedDate =
                DateFormat('MMM dd').format(DateTime.parse(dates[j]));
            String date = formattedDate.split(" ")[0];
            chartDataLists[i].add(PrcComparisionChartData(date, close[j]));
          }
        }
      }

      notifyListeners();
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Fundamental ", "Error": "$e"});
      notifyListeners();
      debugPrint(" FUNDAMENTAL ERROR ::: ${e.toString()}");
    } finally {}
  }

// Scrip returns data(Year/Month/Week/Day)
  techDataCalc(String lastPrc) {
    _returnsGridview = [];
    double ltp = lastPrc != "null" ? double.parse(lastPrc) : 0.0;

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

  // Seprating option chain scrips (Call / Put)
  splitOptionChain(BuildContext context) {
    _optChainCall = [];
    _optChainPut = [];
// Seperating Trade symbol(symbol,exp date, Option)
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

// websocket Connection Request for Option chain list

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

// websocket Connection Request for Future list
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

// Swipe or Change to watchlist

  changeWLScrip(String wName, BuildContext context) async {
    try {
      _scrips = wName == "My Stocks"
          ? []
          : await jsonDecode(_marketWatchScripData[wName]) ?? [];

      if (wName == "My Stocks") {
        await ref(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: true);
      } else {
        await requestMWScrip(context: context, isSubscribe: true);
      }
    } catch (e) {
      print("object  - $e");
    }

    notifyListeners();
  }

// Delete market scrips by watchlist name
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

// Add market scrips by watchlist name
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
      bool isAdd, bool isEdit, bool isReOrder, bool isOptionStike) async {
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
      if (isEdit && isOptionStike) {
        Fluttertoast.showToast(
            msg: "Scrip was added to watchlist $wlName",
            timeInSecForIosWeb: 2,
            backgroundColor: colors.colorBlack,
            textColor: colors.colorWhite,
            fontSize: 14.0);
      }
    } else if (_addDeleteScripModel!.emsg ==
        "Session Expired :  Invalid Session Key") {
      ref(authProvider).ifSessionExpired(context);
    }
  }

// websocket Connection Request for Market watch scrip
  requestMWScrip(
      {required bool isSubscribe, required BuildContext context}) async {
    try {
      toggleLoadingOn(true);
      String input = "";
      _delScripQty = 0;
      await ref(indexListProvider).requestdefaultIndex();
      if (ref(indexListProvider).indexToken.isNotEmpty) {
        input = ref(indexListProvider).indexToken;
      }

      if (_scrips.isNotEmpty) {
        for (var element in _scrips) {
          element['isSelected'] = false;
          input += "${element['exch']}|${element['token']}#";
        }
      }

      if (input.isNotEmpty) {
        await ref(websocketProvider).establishConnection(
            channelInput: input,
            task: isSubscribe ? "t" : "u",
            context: context);
      }
    } catch (e) {
    } finally {
      toggleLoadingOn(false);
    }
  }

  getSortByWL(String val) {
    _sortByWL = val;
    notifyListeners();
  }

// Sorting market watch scrip by trade symbol(LTP,symbol,)

  filterPendingAlert(String sorting) {
    if (sorting == "ASC") {
      _alertPendingModel!.sort((a, b) => a.tsym!.compareTo(b.tsym!));
    } else if (sorting == "DSC") {
      _alertPendingModel!.sort((a, b) => b.tsym!.compareTo(a.tsym!));
    } else if (sorting == "LTPDSC") {
      _alertPendingModel!.sort((a, b) {
        return double.parse(b.ltp ?? "0.00")
            .compareTo(double.parse(a.ltp ?? "0.00"));
      });
    } else if (sorting == "LTPASC") {
      _alertPendingModel!.sort((a, b) {
        return double.parse(a.ltp ?? "0.00")
            .compareTo(double.parse(b.ltp ?? "0.00"));
      });
    } else if (sorting == "ALERTVALUEDSC") {
      _alertPendingModel!.sort((a, b) {
        return double.parse(b.d ?? "0.00")
            .compareTo(double.parse(a.d ?? "0.00"));
      });
    } else if (sorting == "ALERTVALUEASC") {
      _alertPendingModel!.sort((a, b) {
        return double.parse(a.d ?? "0.00")
            .compareTo(double.parse(b.d ?? "0.00"));
      });
    }
    notifyListeners();
  }

// Sorting market watch scrip by trade symbol(LTP,symbol,)
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
      await addDelMarketScrip(
          wlName, delInput, context, false, true, false, false);
      await addDelMarketScrip(
          wlName, addInput, context, true, true, false, false);
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

      await addDelMarketScrip(
          wlName, delInput, context, false, true, false, false);
      await addDelMarketScrip(
          wlName, addInput, context, true, true, false, false);
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
      await addDelMarketScrip(
          wlName, delInput, context, false, true, false, false);
      await addDelMarketScrip(
          wlName, addInput, context, true, true, false, false);
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
      await addDelMarketScrip(
          wlName, delInput, context, false, true, false, false);
      await addDelMarketScrip(
          wlName, addInput, context, true, true, false, false);
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
      await addDelMarketScrip(
          wlName, delInput, context, false, true, false, false);
      await addDelMarketScrip(
          wlName, addInput, context, true, true, false, false);
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
      await addDelMarketScrip(
          wlName, delInput, context, false, true, false, false);
      await addDelMarketScrip(
          wlName, addInput, context, true, true, false, false);
    }

    _sortByWL = sorting;
    localstorage.setString("sortByWL", _sortByWL);
    notifyListeners();
  }

// Assing Del Qty =0
  delQty() {
    _delScripQty = 0;
    notifyListeners();
  }

// Selection for scrip selcetion
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
    await addDelMarketScrip(wlName, input, context, false, false, false, false);

    if (_scrips.isEmpty) {
      Navigator.pop(context);
    }
    _delScripQty = 0;
    notifyListeners();
  }

// Market watch scrip re-order
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

    await addDelMarketScrip(
        wlName, deleteInput, context, false, true, true, false);

    for (var elements in _scrips) {
      addInput += "${elements['exch']}|${elements['token']}#";
    }

    await addDelMarketScrip(
        wlName, addInput, context, true, true, false, false);
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
      ref(orderProvider).changeTabIndex(6, context);

      if (_setAlertModel!.stat! == "OI created") {
        fetchPendingAlert(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "${_setAlertModel?.stat}"));
        Navigator.pop(context);
        Navigator.pop(context);
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
          ref(indexListProvider).bottomMenu(3, context);
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

///// new code by dd
  Future fetchWatchListRename(
      String oldName, String newName, BuildContext context) async {
    try {
      toggleLoadingOn(true);
      _watchlistRenameModel = await api.getWatchListRename(oldName, newName);
      if (_watchlistRenameModel!.stat == "Ok") {
        fetchMWList(context);
        _wlName = newName;
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(successMessage(context,
            "The name of the watchlist has been successfully changed."));
        notifyListeners();
      } else if (_watchlistRenameModel!.stat == "Not_Ok") {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "${_watchlistRenameModel!.emsg}"));
      } else if (_watchlistRenameModel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref(authProvider).ifSessionExpired(context);
      }
    } catch (e) {
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }
  ////
}
