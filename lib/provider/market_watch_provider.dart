// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/user_profile_provider.dart';
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
import '../models/marketwatch_model/search_scrip_new_model.dart';
import '../models/marketwatch_model/watchlist_rename_model.dart';
import '../res/res.dart';
import '../screens/market_watch/scrip_depth_info.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'order_provider.dart';
import 'portfolio_provider.dart';
import 'websocket_provider.dart';
import 'dart:async';

final marketWatchProvider =
    ChangeNotifierProvider((ref) => MarketWatchProvider(ref));

class MarketWatchProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;

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
  List linkedscript = ['NFO', 'BFO', 'MCX', 'NCOM', 'BCOM', 'CDS'];

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
    Tab(text: "Commodity"),
    Tab(text: "Indices")
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

  SearchScripNewModel? _searchScripModel;

  SearchScripNewModel? get searchScripModel => _searchScripModel;

  List<ScripNewValue>? _allSearchScrip = [];
  List<ScripNewValue>? get allSearchScrip => _allSearchScrip;
  List<ScripNewValue>? _equitySearchScrip = [];
  List<ScripNewValue>? get equitySearchScrip => _equitySearchScrip;
  List<ScripNewValue>? _currencySearchScrip = [];
  List<ScripNewValue>? get currencySearchScrip => _currencySearchScrip;
  List<ScripNewValue>? _commoditySearchScrip = [];
  List<ScripNewValue>? get commoditySearchScrip => _commoditySearchScrip;
  List<ScripNewValue>? _fNoSearchScrip = [];
  List<ScripNewValue>? get fNoSearchScrip => _fNoSearchScrip;

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

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  // Track current watchlist page index
  int _currentWatchlistPageIndex = 0;
  int get currentWatchlistPageIndex => _currentWatchlistPageIndex;

  // Method to update current watchlist page index
  void setCurrentWatchlistPageIndex(int index) {
    _currentWatchlistPageIndex = index;
    // Store in SharedPreferences for persistence
    _saveCurrentPageIndex();
  }

  // Save current page index to SharedPreferences
  Future<void> _saveCurrentPageIndex() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          "currentWatchlistPageIndex", _currentWatchlistPageIndex);
    } catch (e) {
      print("Error saving watchlist page index: $e");
    }
  }

  // Add StreamSubscription for WebSocket data
  StreamSubscription? _socketDataSubscription;

  MarketWatchProvider(this.ref) {
    // Load sort preference asynchronously - don't block the constructor
    _loadSortPreference();
    // Load saved page index
    _loadCurrentPageIndex();

    // Listen to WebSocket data updates using a proper subscription
    _setupWebSocketListener();
  }

  // Setup WebSocket listener with proper error handling
  void _setupWebSocketListener() {
    try {
      // Cancel any existing subscription first
      _socketDataSubscription?.cancel();

      // Create a new subscription with proper error handling
      _socketDataSubscription =
          ref.read(websocketProvider).socketDataStream.listen(
        (data) {
          if (data.isNotEmpty) {
            try {
              // Convert to Map<String, dynamic> to match the expected type
              final Map<String, dynamic> typedData =
                  Map<String, dynamic>.from(data);
              updateSocketData(typedData);
            } catch (e) {
              print("Error processing socket data update: $e");
            }
          }
        },
        onError: (error) {
          print("Error in socket data stream: $error");
        },
      );
    } catch (e) {
      print("Error setting up WebSocket listener: $e");
    }
  }

  @override
  void dispose() {
    // Cancel the socket data subscription to avoid memory leaks
    if (_socketDataSubscription != null) {
      try {
        _socketDataSubscription?.cancel();
        _socketDataSubscription = null;
      } catch (e) {
        print("Error canceling socket subscription: $e");
      }
    }

    // Call the parent dispose method
    super.dispose();
  }

  // Method to load current page index from SharedPreferences
  Future<void> _loadCurrentPageIndex() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentWatchlistPageIndex =
          prefs.getInt("currentWatchlistPageIndex") ?? 0;
      notifyListeners();
    } catch (e) {
      print("Error loading watchlist page index: $e");
    }
  }

  // Method to load sort preference from SharedPreferences
  Future<void> _loadSortPreference() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _sortByWL = prefs.getString("sortByWL") ?? "";
      notifyListeners();
    } catch (e) {
      print("Error loading sort preference: $e");
    }
  }

  // CRITICAL NEW METHOD: Sync current socket values to the watchlist model before sorting
  void syncSocketDataToModel() {
    if (_scrips.isEmpty) return;

    try {
      final socketDatas = ref.read(websocketProvider).socketDatas;
      bool dataUpdated = false;

      // Update each scrip with current socket data if available
      for (int i = 0; i < _scrips.length; i++) {
        final token = _scrips[i]['token']?.toString();
        if (token != null &&
            token.isNotEmpty &&
            socketDatas.containsKey(token)) {
          final socketData = socketDatas[token];

          // Update ltp from socket 'lp' field
          if (socketData['lp'] != null &&
              socketData['lp'].toString() != "null" &&
              socketData['lp'].toString() != "0.00") {
            _scrips[i]['ltp'] = socketData['lp'].toString();
            dataUpdated = true;
          }

          // Update change from socket 'chng' field
          if (socketData['chng'] != null &&
              socketData['chng'].toString() != "null") {
            _scrips[i]['change'] = socketData['chng'].toString();
            dataUpdated = true;
          }

          // Update percentage change from socket 'pc' field
          if (socketData['pc'] != null &&
              socketData['pc'].toString() != "null") {
            _scrips[i]['perChange'] = socketData['pc'].toString();
            dataUpdated = true;
          }

          // Update other important fields
          final relevantFields = [
            'h',
            'l',
            'o',
            'c',
            'v',
            'ap',
            'bp1',
            'sp1',
            'tbq',
            'tsq'
          ];
          for (var field in relevantFields) {
            if (socketData[field] != null &&
                socketData[field].toString() != "null") {
              _scrips[i][field] = socketData[field].toString();
            }
          }
        }
      }

      if (dataUpdated) {
        print("Socket data synced to model for ${_scrips.length} scrips");
      }
    } catch (e) {
      print("Error syncing socket data: $e");
    }
  }

  // Method to apply saved sorting without server calls
  void _applySavedSorting() {
    if (_sortByWL.isEmpty || _scrips.isEmpty) return;

    try {
      // Make sure we have fresh data before sorting
      syncSocketDataToModel();

      // Create a copy of the list to preserve object references
      final List<dynamic> tempScrips = List<dynamic>.from(_scrips);

      // Apply the current sort
      switch (_sortByWL) {
        case "Scrip - Z to A":
          tempScrips.sort(
              (a, b) => b['tsym'].toString().compareTo(a['tsym'].toString()));
          break;

        case "Scrip - A to Z":
          tempScrips.sort(
              (a, b) => a['tsym'].toString().compareTo(b['tsym'].toString()));
          break;

        case "Price - Low to High":
          tempScrips.sort((a, b) {
            double aPrice =
                double.tryParse(a['ltp']?.toString() ?? '0.00') ?? 0.0;
            double bPrice =
                double.tryParse(b['ltp']?.toString() ?? '0.00') ?? 0.0;
            return aPrice.compareTo(bPrice);
          });
          break;

        case "Price - High to Low":
          tempScrips.sort((a, b) {
            double aPrice =
                double.tryParse(a['ltp']?.toString() ?? '0.00') ?? 0.0;
            double bPrice =
                double.tryParse(b['ltp']?.toString() ?? '0.00') ?? 0.0;
            return bPrice.compareTo(aPrice);
          });
          break;

        case "Per.Chng - High to Low":
          tempScrips.sort((a, b) {
            double aChange =
                double.tryParse(a['perChange']?.toString() ?? '0.00') ?? 0.0;
            double bChange =
                double.tryParse(b['perChange']?.toString() ?? '0.00') ?? 0.0;
            return bChange.compareTo(aChange);
          });
          break;

        case "Per.Chng - Low to High":
          tempScrips.sort((a, b) {
            double aChange =
                double.tryParse(a['perChange']?.toString() ?? '0.00') ?? 0.0;
            double bChange =
                double.tryParse(b['perChange']?.toString() ?? '0.00') ?? 0.0;
            return aChange.compareTo(bChange);
          });
          break;
      }

      // Update the list with the sorted data
      _scrips = tempScrips;

      print("Applied sorting: $_sortByWL");
    } catch (e) {
      print("Error applying sorting: $e");
    }
  }

  String _wlName = "";

  String get wlName => _wlName;
  String _isPreDefWLs = "No";

  String get isPreDefWLs => _isPreDefWLs;

  String _tradeSym = "";
  get tradeSym => _tradeSym;
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

  List<String> _exarr = [];

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

  getOptionawait(String exch, String token) {
    final portfolios = ref.read(portfolioProvider).oplists;
    bool value = (linkedscript.contains(exch) ||
        (portfolios.isNotEmpty && portfolios.contains(int.parse(token))));
    return value;
  }

  calldepthApis(BuildContext context, raw, basket) async {
    ref.read(userProfileProvider).setonloadChartdialog(true);
    chngDephBtn(basket == "Option|-|Deph" ? "Option" : "Overview");
    singlePageloader(true);
    bool flow = raw.runtimeType.toString() == '_Map<String, dynamic>';
// _Map<String, dynamic>
    DepthInputArgs depthArgs = DepthInputArgs(
        exch: '${flow ? raw['exch'] : raw.exch}',
        token: '${flow ? raw['token'] : raw.token}',
        tsym: '${flow ? raw['tsym'] : raw.tsym}',
        instname: flow ? raw['instname'] : raw.instname ?? "",
        symbol: '${flow ? raw['symbol'] : raw.symbol}',
        expDate: '${flow ? raw['expDate'] : raw.expDate}',
        option: '${flow ? raw['option'] : raw.option}');

    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ScripDepthInfo(wlValue: depthArgs, isBasket: basket)));

    await ref.read(websocketProvider).establishConnection(
        channelInput:
            "${flow ? raw['exch'] : raw.exch}|${flow ? raw['token'] : raw.token}",
        task: "d",
        context: context);
    singlePageloader(false);
    await fetchScripQuote("${flow ? raw['token'] : raw.token}",
        "${flow ? raw['exch'] : raw.exch}", context);
    if (getOptionawait(
        flow ? raw['exch'] : raw.exch, flow ? raw['token'] : raw.token)) {
      await fetchScripInfo("${flow ? raw['token'] : raw.token}",
          "${flow ? raw['exch'] : raw.exch}", context);
      await fetchLinkeScrip("${flow ? raw['token'] : raw.token}",
          "${flow ? raw['exch'] : raw.exch}", context);
    }

    if (((flow ? raw['exch'] : raw.exch) == "NSE" ||
        (flow ? raw['exch'] : raw.exch) == "BSE")) {
      fetchFundamentalData(
          tradeSym:
              "${flow ? raw['exch'] : raw.exch}:${(flow ? raw['tsym'] : raw.tsym)}");

      await fetchTechData(
          context: context,
          exch: "${(flow ? raw['exch'] : raw.exch)}",
          tradeSym: "${(flow ? raw['tsym'] : raw.tsym)}",
          lastPrc: "${_getQuotes.lp ?? _getQuotes.c ?? 0.00}");
    }
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
                  color: ref.read(themeProvider).isDarkMode
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

  final List<ChartArgs> _chartTabs = [];
  ChartArgs? _activeTab;
  List<ChartArgs> get chartTabs => _chartTabs;
  ChartArgs? get activeTab => _activeTab;

  final List<ChartArgs> _optionTabs = [];
  ChartArgs? _oactiveTab;
  List<ChartArgs> get optionTabs => _optionTabs;
  ChartArgs? get oactiveTab => _oactiveTab;

  final List<ChartArgs> defaultChartTabs = [
    ChartArgs(tsym: "Nifty 50", token: "26000", exch: "NSE"),
    ChartArgs(tsym: "Nifty Bank", token: "26009", exch: "NSE"),
    // ChartArgs(tsym: "Sensex", token: "1", exch: "BSE"),
    // ChartArgs(tsym: "India VIX", token: "26017", exch: "NSE"),
  ];

  void loadDefaultTabs() {
    if (_chartTabs.isEmpty) {
      _chartTabs.addAll(defaultChartTabs);
      _oactiveTab = _chartTabs.first;
      notifyListeners();
    }
    if (_optionTabs.isEmpty) {
      _optionTabs.addAll(defaultChartTabs);
      _oactiveTab = _optionTabs.first;
      notifyListeners();
    }
  }

  void addChartTab(ChartArgs tab, bool type) {
    if (type) {
      if (!_optionTabs.any((t) => t.token == tab.token)) {
        _optionTabs.add(tab);
      }
      _activeTab = tab;
    } else {
      if (!_chartTabs.any((t) => t.token == tab.token)) {
        _chartTabs.add(tab);
      }
      _activeTab = tab;
    }
    notifyListeners();
  }

  void selectChartTab(String token, bool type) {
    if (type) {
      _oactiveTab = _optionTabs.firstWhere(
        (tab) => tab.token == token,
        orElse: () => ChartArgs(
            tsym: '',
            token: '',
            exch: ''), // <- this works if ChartArgs? is allowed
      );
    } else {
      _activeTab = _chartTabs.firstWhere(
        (tab) => tab.token == token,
        orElse: () => ChartArgs(
            tsym: '',
            token: '',
            exch: ''), // <- this works if ChartArgs? is allowed
      );
    }
    notifyListeners();
  }

  void removeChartTab(ChartArgs tab, bool type) {
    if (type) {
      _optionTabs.removeWhere((t) => t.token == tab.token);
    } else {
      _chartTabs.removeWhere((t) => t.token == tab.token);
    }
    notifyListeners();
  }

  void setChartScript(String exch, String token, String tsym) async {
    await ConstantName.chartwebViewController!.evaluateJavascript(
        source:
            "window.changeScript([{exch: '$exch', token: '$token', tsym: '$tsym'}], '${ref.read(themeProvider).isDarkMode}')");
    if (_chartTabs.length == 5 &&
        (_chartTabs.any((t) => t.token == token)) != true) {
      removeChartTab(_chartTabs.last, false);
    }
    if (token != "0123") {
      addChartTab(ChartArgs(tsym: tsym, token: token, exch: exch), false);
    }
    selectChartTab(token.toString(), false);
    scrollToSelectedTab(false);
    notifyListeners();
  }

  void setOptionScript(
      BuildContext context, String exch, String token, String tsym) async {
    toggleLoad(true);
    singlePageloader(true);
    notifyListeners();
    await fetchScripQuoteIndex(token, exch, context);
    if (exch == "BFO" ||
        exch == "NFO" ||
        (exch == "MCX" && _getQuotes.instname == "OPTFUT")) {
      await fetchStikePrc(
          "${_getQuotes.undTk}", "${_getQuotes.undExch}", context);
    } else {
      updateOptStrPrc(_getQuotes.lp.toString());
    }

    await ref.read(websocketProvider).establishConnection(
        channelInput: (_getQuotes.exch == "BFO" ||
                _getQuotes.exch == "NFO" ||
                (_getQuotes.exch == "MCX" && _getQuotes.instname == "OPTFUT"))
            ? '${_getQuotes.undExch}|${_getQuotes.undTk!}'
            : '${_getQuotes.exch}|${_getQuotes.token!}',
        task: "t",
        context: context);

    await fetchLinkeScrip(token, exch, context);

    await fetchOPtionChain(
        context: context,
        exchange: optionExch!,
        numofStrike: numStrike,
        strPrc: optionStrPrc,
        tradeSym: selectedTradeSym!);
    singlePageloader(false);
    toggleLoad(false);
    if (_optionTabs.length == 5 &&
        (_optionTabs.any((t) => t.token == token)) != true) {
      removeChartTab(_optionTabs.last, true);
    }
    addChartTab(ChartArgs(tsym: tsym, token: token, exch: exch), true);

    selectChartTab(token.toString(), true);
    scrollToSelectedTab(true);
    notifyListeners();
  }

  void scrollToSelectedTab(bool type) {
    final selectedIndex = type
        ? _optionTabs.indexWhere((tab) => tab.token == _oactiveTab?.token)
        : _chartTabs.indexWhere((tab) => tab.token == _activeTab?.token);
    if (_scrollController.hasClients && selectedIndex != -1) {
      _scrollController.animateTo(
        selectedIndex * 120.0, // Adjust width estimate based on Chip size
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
          .where((element) => element.tsym!.toLowerCase().contains(value.toLowerCase()))
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

  scripSearch(
      String value, BuildContext context, int? seg, String options) async {
    if (value.length > 2) {
      await fetchSearchScrip(
          searchText: value,
          context: context,
          segment: ["", "EQ", "FO", "CUR", "COM", "IDX"][seg ?? 0],
          option: options == "Option||Is");
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

  Future fetchMWList(BuildContext context, bool waitis,
      [bool swit = false]) async {
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
          bool isFirst = true;

          for (var element in _marketWatchlist!.values!) {
            if (!waitis) {
              await fetchMWScrip(element, context);
            } else if (isFirst && waitis) {
              await fetchMWScrip(element, context);
              isFirst = false;
            } else {
              fetchMWScrip(element, context); // No await here
            }
          }
        }

        if (_wlName.isEmpty) {
          _wlName = _marketWatchlist!.values!.first;
        }
        _marketWatchlist!.values!.addAll(_preDefWL);
        fetchPreDefMWScrip(context);
        if (swit == false) {
          await changeWLScrip(_wlName, context);
        }
      } else {
        if (_marketWatchlist!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _marketWatchlist!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
      return _marketWatchlist;
    } catch (e) {
      print("Failed $e");
      ref
          .read(indexListProvider)
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
              if (element.exch == "MCX" && element.instname == 'FUTCOM') {
                element.option = 'FUT';
              }
            }

            // Holdings Qty add to market watch scrip
            if (ref.read(portfolioProvider).holdingsModel!.isNotEmpty) {
              for (var holding in ref.read(portfolioProvider).holdingsModel!) {
                if (holding.exchTsym![0].exch == "NSE" ||
                    holding.exchTsym![0].exch == "BSE") {
                  if (element.token == holding.exchTsym![0].token) {
                    element.holdingQty = "${holding.currentQty ?? 0}";
                  }
                }
              }
            }
          }
        } else {
          _watchListValues = [];
        }

        _marketWatchScripData.addAll({wlname: jsonEncode(_watchListValues)});

        notifyListeners();
      } else {
        if (_marketWatchScrip!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _marketWatchScrip!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
        _watchListValues = [];
      }

      return _marketWatchScrip;
    } catch (e) {
      ref
          .read(indexListProvider)
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
              if (ref.read(portfolioProvider).holdingsModel!.isNotEmpty) {
                for (var holding
                    in ref.read(portfolioProvider).holdingsModel!) {
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
              if (ref.read(portfolioProvider).holdingsModel!.isNotEmpty) {
                for (var holding
                    in ref.read(portfolioProvider).holdingsModel!) {
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
              if (ref.read(portfolioProvider).holdingsModel!.isNotEmpty) {
                for (var holding
                    in ref.read(portfolioProvider).holdingsModel!) {
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
            ref.read(authProvider).ifSessionExpired(context);
          }
          // _watchListValues = [];
        }
      }
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Market Watch Scrip", "Error": "$e"});
      notifyListeners();
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }

// Fetching data from the api and stored in a variable
  Future fetchScripInfo(String token, String exch, BuildContext context,
      [bool order = false]) async {
    try {
      if (order == false &&
          storeQuotes.containsKey(token) &&
          storeQuotes[token]?['s'] != null) {
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
          ref.read(authProvider).ifSessionExpired(context);
        }
      }

      notifyListeners();
      return _scripInfoModel;
    } catch (e) {
      print(e);
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Scrip Info", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  Future fetchScripQuoteIndex(
      String token, String exch, BuildContext context) async {
    try {
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

          scripQtyCal();
        }
        if (_getQuotes.emsg == "Session Expired :  Invalid Session Key" &&
            _getQuotes.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
      return _getQuotes;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Scrip Quote", "Error": "$e"});
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
      if (getOptionawait(exch, token)) {
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
      if (exch == 'NSE' || exch == 'BSE') {
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
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
      return _getQuotes;
    } catch (e) {
      ref
          .read(indexListProvider)
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
            _getStikePrc!.exch == "BSE" ||
            (_getStikePrc!.exch == "MCX" &&
                _getStikePrc!.instname == "FUTCOM")) {
          _optionStrPrc = "${_getStikePrc!.lp}";
        }
        await ref.read(websocketProvider).establishConnection(
            channelInput: '${_getStikePrc!.exch}|${_getStikePrc!.token!}',
            task: "t",
            context: context);
      }
      if (_getStikePrc!.emsg == "Session Expired :  Invalid Session Key" &&
          _getStikePrc!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
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
      {required String searchText,
      required BuildContext context,
      required String segment,
      required bool option}) async {
    try {
      toggleLoadingOn(true);
      if (_exarr.isEmpty) {
        List<String> rawList =
            ref.read(userProfileProvider).userDetailModel?.exarr ?? [];
        _exarr = rawList.map((e) => '"${e.toString()}"').toList();
      } // _searchScripModel = await api.getSearchScrip(searchText: searchText);
      _searchScripModel = await api.getSearchScripNew(
          searchText: searchText, categ: segment, exchs: _exarr, opt: option);
      _allSearchScrip = [];
      // _equitySearchScrip = [];
      // _fNoSearchScrip = [];
      // _currencySearchScrip = [];
      // _commoditySearchScrip = [];
      if (_searchScripModel?.stat == "Ok") {
        ConstantName.sessCheck = true;

        final values = _searchScripModel!.values!;
        _isAdded = List<bool>.filled(values.length, false);

        if (values.isNotEmpty) {
          // final Set<String> currencySet = {
          //   "FUTCUR",
          //   "FUTIRC",
          //   "FUTIRT",
          //   "OPTCUR",
          //   "OPTIRC"
          // };
          // final Set<String> commoditySet = {
          //   "AUCSO",
          //   "FUTCOM",
          //   "FUTIDX",
          //   "OPTFUT"
          // };
          // final Set<String> fnoSet = {"FUTIDX", "FUTSTK", "OPTIDX", "OPTSTK"};

          for (int i = 0; i < values.length; i++) {
            final val = values[i];
            final exch = val.exch;
            final dname = val.dname;
            // final instname = val.instname?.toUpperCase() ?? "";
            final tsym = val.tsym;

            if (exch == "BFO" && dname != null) {
              final splitVal = dname.split(" ");
              val.symbol = splitVal[0];
              val.expDate = "${splitVal[1]} ${splitVal[2]}";
              val.option = splitVal.length > 4
                  ? "${splitVal[3]} ${splitVal[4]}"
                  : splitVal[3];
            } else {
              final spilitSymbol = spilitTsym(value: tsym ?? "");
              val.symbol = spilitSymbol["symbol"];
              val.expDate = spilitSymbol["expDate"];
              val.option = spilitSymbol["option"];
            }

            for (var scrip in _scrips) {
              if (tsym == scrip['tsym']) {
                _isAdded![i] = true;
                break;
              }
            }

            // if (instname != "COM") {
            _allSearchScrip?.add(val);

            //   if (currencySet.contains(instname)) {
            //     _currencySearchScrip?.add(val);
            //   } else if (commoditySet.contains(instname)) {
            //     _commoditySearchScrip?.add(val);
            //   } else if (fnoSet.contains(instname)) {
            //     _fNoSearchScrip?.add(val);
            //   } else {
            //     _equitySearchScrip?.add(val);
            //   }
            // }
          }
          print("_allSearchScrip ${_allSearchScrip?.length}");

          _searchErrorText = "";
          notifyListeners();
        }
      } else {
        _searchErrorText = "No Data Found";

        if (_searchScripModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _searchScripModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }

      notifyListeners();
      return _searchScripModel;
    } catch (e) {
      ref
          .read(indexListProvider)
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
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      notifyListeners();
      return _linkedScrips;
    } catch (e) {
      ref
          .read(indexListProvider)
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
      print(
          "op Strike Price $strPrc ------ $tradeSym ------ $exchange ------ $numofStrike");
      _optionChainModel = await api.getOptionChain(
          context: context,
          strPrc: strPrc,
          tradeSym: tradeSym,
          exchange: exchange,
          numofStrike: numofStrike);
      if (_optionChainModel!.stat == "Ok") {
        ConstantName.sessCheck = true;

        // Seprating option chain scrips (Call / Put)
        await splitOptionChain(context, double.parse(strPrc));
      } else {
        _optChainCall = [];
        _optChainPut = [];
        if (_optionChainModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _searchScripModel!.stat == "Not_Ok") {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }

      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
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
          ref.read(authProvider).ifSessionExpired(context);
        }
      }
      techDataCalc(lastPrc);

      notifyListeners();
    } catch (e) {
      ref
          .read(indexListProvider)
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
        if(fundamentalData != null && fundamentalData!.shareholdings != null){
        sortAndFormatDates(
          _fundamentalData!.shareholdings!,
          (element) => element.date!,
          (element, value) => element.convDate = value,
        );
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
      ref
          .read(indexListProvider)
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
  splitOptionChain(BuildContext context, double strPrc) {
    _optChainCall = [];
    _optChainPut = [];
    _optChainCallDown = [];
    _optChainCallUp = [];
    _optChainPutDown = [];
    _optChainPutUp = [];
// Seperating Trade symbol(symbol,exp date, Option)
    final List<OptionValues>? opt = _optionChainModel!.optValue;
    for (var el in List<OptionValues>.from(opt!)) {
      String complementType = el.optt == 'PE' ? 'CE' : 'PE';

      bool exists = opt.any((item) =>
          item.optt == complementType &&
          num.parse(item.strprc.toString()) == num.parse(el.strprc.toString()));

      if (!exists) {
        _optionChainModel!.optValue!.add(OptionValues(
          exch: el.exch,
          token: "${el.token}${el.token}",
          tsym: "|||",
          optt: complementType,
          pp: el.pp,
          ls: el.ls,
          ti: el.ti,
          strprc: el.strprc,
        ));
      }
    }

    _optionChainModel!.optValue!.sort((a, b) {
      return num.parse(a.strprc.toString())
          .compareTo(num.parse(b.strprc.toString()));
    });

    for (var element in _optionChainModel!.optValue!) {
      Map spilitSymbol = spilitTsym(value: "${element.tsym}");

      element.symbol = "${spilitSymbol["symbol"]}";
      element.expDate = "${spilitSymbol["expDate"]}";
      element.option = "${spilitSymbol["option"]}";
      if (element.optt == "CE") {
        _optChainCall.add(element);
        // int callLength = _optChainCall.length ~/ 2;
        if (strPrc < double.parse(element.strprc.toString())) {
          _optChainCallDown.add(element);
        } else {
          _optChainCallUp.add(element);
        }
      } else {
        _optChainPut.add(element);
        // int putLength = _optChainPut.length ~/ 2;
        if (strPrc < double.parse(element.strprc.toString())) {
          _optChainPutDown.add(element);
        } else {
          _optChainPutUp.add(element);
        }
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
      ref.read(websocketProvider).establishConnection(
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
      ref.read(websocketProvider).establishConnection(
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
      // Check if we have cached data for this watchlist
      bool wlis = _marketWatchScripData.containsKey(wName);

      // Handle special cases or use cached data
      _scrips = wName == "My Stocks"
          ? [] // My Stocks is handled specially through portfolio
          : wlis
              ? await jsonDecode(_marketWatchScripData[wName]) ?? []
              : [];

      // Log the number of symbols for debugging
      print("Watchlist change: $wName with ${_scrips.length} symbols");

      // Apply sorting if there's a saved sort preference and if there are scrips to sort
      if (_scrips.isNotEmpty && _sortByWL.isNotEmpty) {
        _applySavedSorting();
      }

      // Handle portfolio holdings data if "My Stocks" watchlist
      if (wName == "My Stocks") {
        // Portfolio holdings need different subscription handling
        await ref
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: true);
      } else {
        // Standard watchlist - subscribe to the scrips
        if (_scrips.isNotEmpty) {
          await requestMWScrip(context: context, isSubscribe: true);
        } else {
          // If no symbols in watchlist, still ensure we're unsubscribed from previous
          await requestMWScrip(context: context, isSubscribe: false);
          print("No symbols in watchlist: $wName");
        }
      }
    } catch (e) {
      print("Watchlist change error: $e");
    }

    notifyListeners();
  }

// Delete market scrips by watchlist name
  Future<void> deleteWatchList(String walName, BuildContext context) async {
    String input = "";

    // Get the scrips for this watchlist, even if it's not the active one
    List scripList = [];
    if (_marketWatchScripData.containsKey(walName)) {
      scripList = jsonDecode(_marketWatchScripData[walName]) ?? [];
    }

    // Build the input string for deletion
    for (var element in scripList) {
      input += "${element['exch']}|${element['token']}#";
    }

    try {
      toggleLoadingOn(true);
      _addDeleteScripModel = await api.getAddDeleteSciptoMW(
          isAdd: false, scripToken: input, wlname: walName);

      if (_addDeleteScripModel!.stat!.toUpperCase() == "OK") {
        // If the deleted watchlist is the active one, change to a different watchlist
        if (walName == _wlName) {
          // Find the first available watchlist that's not the one being deleted
          String newWlName = "";
          if (_marketWatchlist != null &&
              _marketWatchlist!.values!.isNotEmpty) {
            for (String wl in _marketWatchlist!.values!) {
              if (wl != walName) {
                newWlName = wl;
                break;
              }
            }
          }

          // If we found an alternative, switch to it
          if (newWlName.isNotEmpty) {
            await changeWlName(newWlName, "No");
          } else {
            // If no alternative found, reset to empty
            await changeWlName("", "No");
          }
        }

        // Refresh the watchlist data
        await fetchMWList(context, false, true);
      }
    } finally {
      toggleLoadingOn(false);
    }
  }

// Add market scrips by watchlist name
  addWatchList(String wlName, BuildContext context) async {
    _addDeleteScripModel = await api.getAddDeleteSciptoMW(
        isAdd: true, scripToken: "", wlname: wlName);

    if (_addDeleteScripModel!.stat!.toUpperCase() == "OK") {
      toggleLoadingOn(true);
      await changeWlName(wlName, "No");
      await fetchMWList(context, false);
      toggleLoadingOn(false);
    } else {
      ref.read(authProvider).ifSessionExpired(context);
    }
  }

  Future<bool> addDelMarketScrip(
      String wlName,
      String scripTok,
      BuildContext context,
      bool isAdd,
      bool isEdit,
      bool isReOrder,
      bool isOptionStike) async {
    try {
      _addDeleteScripModel = await api.getAddDeleteSciptoMW(
          isAdd: isAdd, scripToken: scripTok, wlname: wlName);

      if (_addDeleteScripModel!.stat!.toUpperCase() == "OK") {
        ConstantName.sessCheck = true;
        if (!isReOrder) {
          await fetchMWScrip(wlName, context);
          await changeWLScrip(wlName, context);
        } else {
          // Wrap ScaffoldMessenger calls in try-catch to handle disposed widgets
          try {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
                successMessage(context, "Scrip order was changed"));
          } catch (e) {
            if (e.toString().contains("widget was disposed") ||
                e.toString().contains("after the widget was disposed")) {
              print("Widget was disposed when showing SnackBar: $e");
            } else {
              print("Error showing SnackBar: $e");
            }
          }
        }
        if (!isEdit) {
          // Wrap ScaffoldMessenger calls in try-catch to handle disposed widgets
          try {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(successMessage(
                context,
                isAdd
                    ? "Scrip was added to watchlist $wlName"
                    : "Scrip was removed from watchlist $wlName"));
          } catch (e) {
            if (e.toString().contains("widget was disposed") ||
                e.toString().contains("after the widget was disposed")) {
              print("Widget was disposed when showing SnackBar: $e");
            } else {
              print("Error showing SnackBar: $e");
            }
          }
        }
        if (isEdit && isOptionStike) {
          try {
            Fluttertoast.showToast(
                msg: "Scrip was added to watchlist $wlName",
                timeInSecForIosWeb: 2,
                backgroundColor: colors.colorBlack,
                textColor: colors.colorWhite,
                fontSize: 14.0);
          } catch (e) {
            print("Error showing toast: $e");
          }
        }
        return true;
      } else if (_addDeleteScripModel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        try {
          ref.read(authProvider).ifSessionExpired(context);
        } catch (e) {
          print("Error handling session expiration: $e");
        }
      }
      return false;
    } catch (e) {
      print("Error in addDelMarketScrip: $e");
      return false;
    }
  }

// websocket Connection Request for Market watch scrip
  requestMWScrip(
      {required bool isSubscribe, required BuildContext context}) async {
    try {
      toggleLoadingOn(true);
      String input = "";
      _delScripQty = 0;

      // Get index tokens first for market indices
      await ref.read(indexListProvider).requestdefaultIndex();
      if (ref.read(indexListProvider).indexToken.isNotEmpty) {
        input = ref.read(indexListProvider).indexToken;
      }

      // Add all scrips from current watchlist to the subscription
      if (_scrips.isNotEmpty) {
        for (var element in _scrips) {
          element['isSelected'] = false;
          input += "${element['exch']}|${element['token']}#";
        }
      }

      // Only attempt subscription if we have valid tokens
      if (input.isNotEmpty) {
        print(
            "WebSocket: ${isSubscribe ? "Subscribing to" : "Unsubscribing from"} ${input.split('#').length} symbols");
        await ref.read(websocketProvider).establishConnection(
            channelInput: input,
            task: isSubscribe ? "t" : "u",
            context: context);
      } else {
        print("WebSocket: No symbols to subscribe");
      }
    } catch (e) {
      print("WebSocket subscription error: $e");
    } finally {
      toggleLoadingOn(false);
    }
  }

  // Sort preference management
  getSortByWL(String val) async {
    _sortByWL = val;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("sortByWL", val);
    } catch (e) {
      print("Error saving sort preference: $e");
    }
    notifyListeners();
  }

  // Sorting alert list
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

  // Sorting market watch scrip by trade symbol
  filterMWScrip(
      {required String sorting,
      required String wlName,
      required BuildContext context}) {
    print("Starting filterMWScrip with sorting: $sorting");

    // If no scrips to sort, exit early
    if (_scrips.isEmpty) {
      print("No scrips to sort in watchlist $wlName");
      return;
    }

    // Store the current sort option immediately in the provider state
    _sortByWL = sorting;

    // Save to persistent storage in the background
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("sortByWL", sorting);
    }).catchError((e) {
      print("Error saving sort preference: $e");
    });

    // Log sample data before sorting
    if (_scrips.isNotEmpty) {
      print(
          "Before sorting - Sample scrip: ${_scrips[0]['tsym']} LTP: ${_scrips[0]['ltp']} PerChange: ${_scrips[0]['perChange']}");
    }

    // Make sure we have fresh data before sorting
    syncSocketDataToModel();

    // Create a copy to preserve original objects
    final List<dynamic> tempScrips = List<dynamic>.from(_scrips);

    // Apply sorting based on requested type
    switch (sorting) {
      case "Scrip - Z to A":
        tempScrips.sort((a, b) {
          String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
          String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
          return bSymbol.compareTo(aSymbol);
        });
        break;

      case "Scrip - A to Z":
        tempScrips.sort((a, b) {
          String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
          String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
          return aSymbol.compareTo(bSymbol);
        });
        break;

      case "Price - Low to High":
        tempScrips.sort((a, b) {
          // Use the helper method for numeric values
          double aPrice = _parseNumericValue(a['ltp']);
          double bPrice = _parseNumericValue(b['ltp']);

          // If values are equal, use symbol as secondary sort
          if (aPrice == bPrice) {
            String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
            String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
            return aSymbol.compareTo(bSymbol);
          }

          return aPrice.compareTo(bPrice);
        });
        break;

      case "Price - High to Low":
        tempScrips.sort((a, b) {
          // Use the helper method for numeric values
          double aPrice = _parseNumericValue(a['ltp']);
          double bPrice = _parseNumericValue(b['ltp']);

          // If values are equal, use symbol as secondary sort
          if (aPrice == bPrice) {
            String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
            String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
            return aSymbol.compareTo(bSymbol);
          }

          return bPrice.compareTo(aPrice);
        });
        break;

      case "Per.Chng - High to Low":
        tempScrips.sort((a, b) {
          // Use the helper method for numeric values
          double aChange = _parseNumericValue(a['perChange']);
          double bChange = _parseNumericValue(b['perChange']);

          // If values are equal, use symbol as secondary sort
          if (aChange == bChange) {
            String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
            String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
            return aSymbol.compareTo(bSymbol);
          }

          return bChange.compareTo(aChange);
        });
        break;

      case "Per.Chng - Low to High":
        tempScrips.sort((a, b) {
          // Use the helper method for numeric values
          double aChange = _parseNumericValue(a['perChange']);
          double bChange = _parseNumericValue(b['perChange']);

          // If values are equal, use symbol as secondary sort
          if (aChange == bChange) {
            String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
            String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
            return aSymbol.compareTo(bSymbol);
          }

          return aChange.compareTo(bChange);
        });
        break;
    }

    // Log sample data after sorting
    if (tempScrips.isNotEmpty) {
      print(
          "After sorting - Sample scrip: ${tempScrips[0]['tsym']} LTP: ${tempScrips[0]['ltp']} PerChange: ${tempScrips[0]['perChange']}");
    }

    // Update the list with the sorted data
    _scrips = tempScrips;

    // Force UI update
    notifyListeners();

    // Update the backend in the background
    _updateBackendSortOrderNonBlocking(wlName, context);
  }

  // Non-blocking backend update to avoid UI stutters
  void _updateBackendSortOrderNonBlocking(String wlName, BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateBackendSortOrder(wlName, context);
    });
  }

  // Helper method to safely parse numeric values from various formats
  double _parseNumericValue(dynamic value) {
    if (value == null) return 0.0;

    // If value is already a number, return it directly
    if (value is num) return value.toDouble();

    // Convert to string for safe parsing
    String strValue = value.toString().trim();

    // Handle empty strings
    if (strValue.isEmpty) return 0.0;

    // Remove any currency symbols, commas, or other non-numeric characters
    strValue = strValue.replaceAll(RegExp(r'[₹,%]'), '').trim();

    try {
      return double.parse(strValue);
    } catch (e) {
      print("Error parsing numeric value '$value': $e");
      return 0.0;
    }
  }

  // Helper method to update the backend without blocking UI
  void _updateBackendSortOrder(String wlName, BuildContext context) {
    // Use a longer delay to ensure UI has fully updated before backend operations
    Future.delayed(const Duration(milliseconds: 300), () async {
      try {
        // Build a single string with all tokens in the current sort order
        final String scripTokens = _scrips
            .map((scrip) => "${scrip['exch']}|${scrip['token']}")
            .join("#");

        if (scripTokens.isEmpty) {
          return;
        }

        // First step: Delete all scrips (but only from backend, not UI)
        final deleteResult = await addDelMarketScrip(
            wlName, "$scripTokens#", context, false, true, true, false);

        // Second step: Add all scrips back in the new order (only to backend)
        if (deleteResult) {
          await addDelMarketScrip(
              wlName, "$scripTokens#", context, true, true, true, false);

          print("Backend watchlist order updated successfully");
        }
      } catch (e) {
        // Silently handle errors in the background operation
        print("Error updating backend sort order: $e");
      }
    });
  }

  // Improved sorting logic with reset to ensure clean sort operations
  void _sortScrips(String sorting) {
    // Ensure we have fresh data before sorting
    syncSocketDataToModel();

    // Reset any previous sort flags in data
    for (var scrip in _scrips) {
      scrip.remove('_sortRank');
    }

    // Apply the requested sort
    if (sorting == "Scrip - Z to A") {
      _scrips.sort((a, b) {
        String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
        String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
        return bSymbol.compareTo(aSymbol);
      });
    } else if (sorting == "Scrip - A to Z") {
      _scrips.sort((a, b) {
        String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
        String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
        return aSymbol.compareTo(bSymbol);
      });
    } else if (sorting == "Price - Low to High") {
      // First, normalize the LTP values and add a sort rank
      for (int i = 0; i < _scrips.length; i++) {
        double ltp = _parseTradingDouble(_scrips[i]['ltp']);
        _scrips[i]['_sortRank'] = ltp;
      }

      _scrips.sort((a, b) {
        double aLtp = a['_sortRank'] as double;
        double bLtp = b['_sortRank'] as double;

        // Special handling for zero and negative values
        // Order: negative values, then zeros, then positive values
        if (aLtp < 0 && bLtp >= 0) return -1;
        if (aLtp >= 0 && bLtp < 0) return 1;
        if (aLtp == 0 && bLtp > 0) return -1;
        if (aLtp > 0 && bLtp == 0) return 1;

        // Normal comparison for values in the same category
        int result = aLtp.compareTo(bLtp);

        // If LTPs are equal, use symbol as tiebreaker
        if (result == 0) {
          String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
          String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
          return aSymbol.compareTo(bSymbol);
        }
        return result;
      });
    } else if (sorting == "Price - High to Low") {
      // First, normalize the LTP values and add a sort rank
      for (int i = 0; i < _scrips.length; i++) {
        double ltp = _parseTradingDouble(_scrips[i]['ltp']);
        _scrips[i]['_sortRank'] = ltp;
      }

      _scrips.sort((a, b) {
        double aLtp = a['_sortRank'] as double;
        double bLtp = b['_sortRank'] as double;

        // Special handling for zero and negative values
        // Order: positive values, then zeros, then negative values
        if (aLtp > 0 && bLtp <= 0) return -1;
        if (aLtp <= 0 && bLtp > 0) return 1;
        if (aLtp == 0 && bLtp < 0) return -1;
        if (aLtp < 0 && bLtp == 0) return 1;

        // Normal comparison for values in the same category
        int result = bLtp.compareTo(aLtp);

        // If LTPs are equal, use symbol as tiebreaker
        if (result == 0) {
          String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
          String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
          return aSymbol.compareTo(bSymbol);
        }
        return result;
      });
    } else if (sorting == "Per.Chng - High to Low") {
      // First, normalize the percentage change values and add a sort rank
      for (int i = 0; i < _scrips.length; i++) {
        double perChange = _parseTradingDouble(_scrips[i]['perChange']);
        _scrips[i]['_sortRank'] = perChange;
      }

      _scrips.sort((a, b) {
        double aChange = a['_sortRank'] as double;
        double bChange = b['_sortRank'] as double;

        // Special handling for zero values
        if (aChange > 0 && bChange <= 0) return -1;
        if (aChange <= 0 && bChange > 0) return 1;
        if (aChange == 0 && bChange < 0) return -1;
        if (aChange < 0 && bChange == 0) return 1;

        // Normal comparison for values in the same category
        int result = bChange.compareTo(aChange);

        // If percentage changes are equal, use symbol as tiebreaker
        if (result == 0) {
          String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
          String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
          return aSymbol.compareTo(bSymbol);
        }
        return result;
      });
    } else if (sorting == "Per.Chng - Low to High") {
      // First, normalize the percentage change values and add a sort rank
      for (int i = 0; i < _scrips.length; i++) {
        double perChange = _parseTradingDouble(_scrips[i]['perChange']);
        _scrips[i]['_sortRank'] = perChange;
      }

      _scrips.sort((a, b) {
        double aChange = a['_sortRank'] as double;
        double bChange = b['_sortRank'] as double;

        // Special handling for zero values
        if (aChange < 0 && bChange >= 0) return -1;
        if (aChange >= 0 && bChange < 0) return 1;
        if (aChange == 0 && bChange > 0) return -1;
        if (aChange > 0 && bChange == 0) return 1;

        // Normal comparison for values in the same category
        int result = aChange.compareTo(bChange);

        // If percentage changes are equal, use symbol as tiebreaker
        if (result == 0) {
          String aSymbol = (a['tsym'] ?? "").toString().toUpperCase();
          String bSymbol = (b['tsym'] ?? "").toString().toUpperCase();
          return aSymbol.compareTo(bSymbol);
        }
        return result;
      });
    }

    // Clean up temp sorting data
    for (var scrip in _scrips) {
      scrip.remove('_sortRank');
    }
  }

  // Helper method to parse trading-specific doubles
  double _parseTradingDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();

    // Handle empty strings
    if (value.toString().trim().isEmpty) return 0.0;

    // Remove any currency symbols or commas
    String cleanValue = value.toString().replaceAll(RegExp(r'[₹,]'), '').trim();

    // Handle percentage signs
    if (cleanValue.endsWith('%')) {
      cleanValue = cleanValue.substring(0, cleanValue.length - 1);
    }

    try {
      // Parse the cleaned value
      return double.parse(cleanValue);
    } catch (e) {
      // For invalid values in trading context, return 0
      print("Error parsing value '$value': $e");
      return 0.0;
    }
  }

  // Socket data update method to maintain sorting
  void updateSocketData(Map<String, dynamic> socketDatas) {
    if (socketDatas == null || _scrips.isEmpty) return;

    bool dataUpdated = false;

    // First pass: Update the data in the scrips list
    for (var scrip in _scrips) {
      String token = scrip['token']?.toString() ?? "";
      if (token.isNotEmpty && socketDatas.containsKey(token)) {
        final socketData = socketDatas[token];

        // Update LTP
        if (socketData['lp'] != null && socketData['lp'].toString() != "null") {
          String newValue = socketData['lp'].toString();
          if (scrip['ltp'] != newValue) {
            scrip['ltp'] = newValue;
            dataUpdated = true;
          }
        }

        // Update change
        if (socketData['chng'] != null &&
            socketData['chng'].toString() != "null") {
          String newValue = socketData['chng'].toString();
          if (scrip['change'] != newValue) {
            scrip['change'] = newValue;
            dataUpdated = true;
          }
        }

        // Update percentage change
        if (socketData['pc'] != null && socketData['pc'].toString() != "null") {
          String newValue = socketData['pc'].toString();
          if (scrip['perChange'] != newValue) {
            scrip['perChange'] = newValue;
            dataUpdated = true;
          }
        }

        // Update other relevant fields
        final relevantFields = [
          'h',
          'l',
          'o',
          'c',
          'v',
          'ap',
          'bp1',
          'sp1',
          'tbq',
          'tsq'
        ];

        for (var field in relevantFields) {
          if (socketData[field] != null &&
              socketData[field].toString() != "null") {
            String newValue = socketData[field].toString();
            if (scrip[field] != newValue) {
              scrip[field] = newValue;
              dataUpdated = true;
            }
          }
        }
      }
    }

    // If we have updates and a sort preference, re-apply the sort
    if (dataUpdated && _sortByWL.isNotEmpty) {
      try {
        // Log pre-sort data for debugging
        if (_scrips.isNotEmpty) {
          print(
              "Socket update - Pre-sort: ${_scrips[0]['tsym']} LTP: ${_scrips[0]['ltp']} PerChange: ${_scrips[0]['perChange']}");
        }

        // Create a copy of the list to preserve object references
        final List<dynamic> tempScrips = List<dynamic>.from(_scrips);

        // Apply the sort without having to check the type again
        switch (_sortByWL) {
          case "Scrip - Z to A":
            tempScrips.sort(
                (a, b) => b['tsym'].toString().compareTo(a['tsym'].toString()));
            break;

          case "Scrip - A to Z":
            tempScrips.sort(
                (a, b) => a['tsym'].toString().compareTo(b['tsym'].toString()));
            break;

          case "Price - Low to High":
            tempScrips.sort((a, b) {
              double aPrice = _parseNumericValue(a['ltp']);
              double bPrice = _parseNumericValue(b['ltp']);
              return aPrice.compareTo(bPrice);
            });
            break;

          case "Price - High to Low":
            tempScrips.sort((a, b) {
              double aPrice = _parseNumericValue(a['ltp']);
              double bPrice = _parseNumericValue(b['ltp']);
              return bPrice.compareTo(aPrice);
            });
            break;

          case "Per.Chng - High to Low":
            tempScrips.sort((a, b) {
              double aChange = _parseNumericValue(a['perChange']);
              double bChange = _parseNumericValue(b['perChange']);
              return bChange.compareTo(aChange);
            });
            break;

          case "Per.Chng - Low to High":
            tempScrips.sort((a, b) {
              double aChange = _parseNumericValue(a['perChange']);
              double bChange = _parseNumericValue(b['perChange']);
              return aChange.compareTo(bChange);
            });
            break;
        }

        // Log post-sort data for debugging
        if (tempScrips.isNotEmpty) {
          print(
              "Socket update - Post-sort: ${tempScrips[0]['tsym']} LTP: ${tempScrips[0]['ltp']} PerChange: ${tempScrips[0]['perChange']}");
        }

        // Update the list with the sorted data
        _scrips = tempScrips;
      } catch (e) {
        print("Error applying sort during socket update: $e");
      }
    }

    // Notify listeners to update the UI - only if data actually changed
    if (dataUpdated) {
      notifyListeners();
    }
  }

  // Add scrip method with sort maintenance
  Future<void> addScrip(
      Map<String, dynamic> scrip, String wlName, BuildContext context) async {
    // Add the scrip to the list
    if (scrip != null) {
      _scrips.add(scrip);
    }

    // If sorting is active, maintain the sort order
    if (_sortByWL != null && _sortByWL.isNotEmpty) {
      await filterMWScrip(sorting: _sortByWL, wlName: wlName, context: context);
    }
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
      ref.read(orderProvider).changeTabIndex(6, context);

      if (_setAlertModel!.stat! == "OI created") {
        // Fetch updated alert list
        await fetchPendingAlert(context);

        // Update the tab count immediately
        ref.read(orderProvider).tabSize();

        // Display success message
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Alert created successfully"));

        // Close the alert creation screens
        Navigator.pop(context);
        Navigator.pop(context);

        // Navigate to the Alert tab after closing the alert creation screens
        ref.read(orderProvider).changeTabIndex(6, context);
      } else if (_setAlertModel!.stat! == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
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
          ref.read(indexListProvider).bottomMenu(3, context);
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

  Future<bool> fetchCancelAlert(String alid, BuildContext context) async {
    try {
      // First make the API call to cancel the alert
      _cancelalert = await api.getCancelAlert(alid);
      ConstantName.sessCheck = true;

      if (_cancelalert!.stat == "OI deleted") {
        // Fetch updated alert list
        await fetchPendingAlert(context);

        // Update the tab count immediately
        ref.read(orderProvider).tabSize();

        // Show success message using a safe approach
        // This should be safe since we're using the context from the caller
        // which should be the order book screen that remains active
        try {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "Alert deleted successfully"));
        } catch (e) {
          print("Could not show SnackBar: $e");
        }

        // Return success status
        notifyListeners();
        return true;
      } else if (_cancelalert!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
        return false;
      }

      notifyListeners();
      return false;
    } catch (e) {
      print("Error canceling alert: $e");
      return false;
    }
  }

  Future fetchmodifyalert(String exch, String tysm, String value,
      String alertTypeVal, String alid, BuildContext context) async {
    try {
      _modifyalertmodel =
          await api.getmodifyalert(exch, tysm, value, alertTypeVal, alid);

      if (_modifyalertmodel!.stat! == "Alert modified successfully") {
        ConstantName.sessCheck = true;

        // Fetch updated alert list
        await fetchPendingAlert(context);

        // Update the tab count immediately
        ref.read(orderProvider).tabSize();

        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "${_modifyalertmodel?.stat}"));
      } else if (_modifyalertmodel!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
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
        fetchMWList(context, false);
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
        ref.read(authProvider).ifSessionExpired(context);
      }
    } catch (e) {
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }
  ////
}
