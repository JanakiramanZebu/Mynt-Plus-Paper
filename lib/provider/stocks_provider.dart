import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import 'package:intl/intl.dart';
import '../models/explore_model/ca_events_model.dart';
import '../models/explore_model/stocks_model/corporate_action_model.dart';
import '../models/explore_model/stocks_model/get_ad_indices.dart';
import '../models/explore_model/stocks_model/sctor_thematic_model.dart';
import '../models/explore_model/stocks_model/sector_thematric_detail_model.dart';
import '../models/explore_model/stocks_model/stock_monitor_model.dart';
import '../models/indices/global_indices_model.dart';
import '../models/news_model.dart';
import '../models/explore_model/stocks_model/action_trade_model.dart';
import '../models/explore_model/stocks_model/toplist_stocks.dart';
import 'bonds_provider.dart';
import 'core/default_change_notifier.dart';
import 'iop_provider.dart';

final stocksProvide = ChangeNotifierProvider((ref) => StocksProvider(ref));

class StocksProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();

  final Ref ref;

  NewsModel? _newsModel;
  NewsModel? get newsModel => _newsModel;
  List<GlobalIndicesModel>? _globalIndicesModel;
  List<GlobalIndicesModel>? get globalIndicesModel => _globalIndicesModel;
  List<ActionTradeModel>? _actionTrademodel;
  List<ActionTradeModel>? get actionTrademodel => _actionTrademodel;

  TopListStocks? _topListStocks;
  TopListStocks? get topListStocks => _topListStocks;
  List<TopGainers> _topGainers = [];
  List<TopGainers> _topLosers = [];
  List<TopGainers> _byValue = [];
  List<TopGainers> _byVolume = [];
  List<TopGainers> _topStockData = [];
  List<TopGainers> get topGainers => _topGainers;
  List<TopGainers> get topLosers => _topLosers;
  List<TopGainers> get byValue => _byValue;
  List<TopGainers> get byVolume => _byVolume;
  List<TopGainers> get topStockData => _topStockData;

  List<StockMoniterModel> _stockMonitor = [];
  List<StockMoniterModel> get stockMonitor => _stockMonitor;
  String _tradeData = "Top gainer";
  String get tradeData => _tradeData;
  StocksProvider(this.ref);

  List<String> tradeActType = ["Equity", "F&O"];

  String _selctedTradeAct = "Equity";
  String _selctedEventAct = "dividend";

  bool _moreFunRatio = false;
  bool get moreFunRatio => _moreFunRatio;

  final List<String> _eveType = [
    "Announcement",
    "Bonus",
    "Divedend",
    "Rights",
    "Split"
  ];

  String _slectSMSym = "Nifty 50";
  String get slectSMSym => _slectSMSym;
  String _slectSMFilter = "Volume & Price Up";
  String get slectSMFilter => _slectSMFilter;

  String _slectBaskt = "NIFTY50";
  String get slectBaskt => _slectBaskt;
  String _slectFilterCont = "VolUpPriceUp";
  String get slectFilterCont => _slectFilterCont;

  chngSMSym(String val) {
    _slectSMSym = val;

    for (var element in _stockMonitorSym) {
      if (_slectSMSym == "${element['symbol']}") {
        _slectBaskt = "${element["bskt"]}";

        fetchStockMonitor("NSE", _slectBaskt, _slectFilterCont);
      }
    }
    notifyListeners();
  }

  chngSMFilter(String val, String val1) {
    _slectSMFilter = val;
    _slectFilterCont = val1;
    fetchStockMonitor("NSE", _slectBaskt, _slectFilterCont);
    notifyListeners();
  }

  final List _stockMonitorSym = [
    {"symbol": "All", "bskt": "A"},
    {"symbol": "Nifty 50", "bskt": "NIFTY50"},
    {"symbol": "Nifty 500", "bskt": "NIFTY500"},
    {"symbol": "Nifty MIDCAP 50", "bskt": "NIFTYMCAP50"},
    {"symbol": "Nifty SMALCAP 50", "bskt": "NIFTYSMCAP50"}
  ];

  List get stockMonitorSym => _stockMonitorSym;

  final List _stockMonitorFilter = [
    {"filterType": "Volume & Price Up", "cont": "VolUpPriceUp"},
    {"filterType": "Volume & Price Down", "cont": "VolUpPriceDown"},
    {"filterType": "Open High", "cont": "OpenHigh"},
    {"filterType": "Open Low", "cont": "OpenLow"},
    {"filterType": "High Break", "cont": "HighBreak"},
    {"filterType": "Low Break", "cont": "LowBreak"}
  ];

  List get stockMonitorFilter => _stockMonitorFilter;

  List<String> get eveType => _eveType;
  String _selectedEvent = "Announcement";
  String get selectedevent => _selectedEvent;

  List<SectorThemeaticModel> _sectorsData = [];

  List<SectorThemeaticModel> _thematicData = [];

  List<SectorThemeaticModel> _strategicData = [];

  List<SectorThemeaticModel> _niftyData = [];

  List<SectorThemeaticModel> get sectorsData => _sectorsData;

  List<SectorThemeaticModel> get thematicDat => _thematicData;

  List<SectorThemeaticModel> get strategicData => _strategicData;

  List<SectorThemeaticModel> get niftyData => _niftyData;

  CorporateActionModel? _corporateActionModel;
  CorporateActionModel? get corporateActionModel => _corporateActionModel;

  CAevents? _caeventsModel;
  CAevents? get caeventsModel => _caeventsModel;

  List<SectorThematicDetailModel> _indicesData = [];
  List<SectorThematicDetailModel> get indicesData => _indicesData;

  GetAdIndicesModel? _getAdIndicesModel;
  GetAdIndicesModel? get getAdIndicesModel => _getAdIndicesModel;

  final TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  globalsearch(String value) {
    _searchController.text = value;
    notifyListeners();
  }

  searchdashboard(String value, BuildContext context) {
    // _searchController.clear();

    if (value.isNotEmpty) {
      switch (exploreIndex) {
        case 0:
          break;
        case 1:
          ref.read(bondsProvider).searchCommonBonds(value, context);
          break;
        case 2:
          ref.read(ipoProvide).searchCommonIpo(value, context);

          // ref.read(stocksProvide).searchCommonStocks(value, context);
          break;
      }
    }
    notifyListeners();
  }

  showMoreFunRatio() {
    _moreFunRatio = !_moreFunRatio;
    notifyListeners();
  }

  chngEvent(String val) {
    _selectedEvent = val;
    notifyListeners();
  }

  late TabController exploreTab;
  final List<Tab> _exploreTabName = [
    const Tab(text: "Stocks"),
    const Tab(text: "Bonds"),
    const Tab(text: "IPOs"),
  ];
  List<Tab> get exploreTabName => _exploreTabName;

  final List<String> _finacialType = ["Income", "Balance sheet", "Cashflow"];

  List<String> get finacialType => _finacialType;

  String _selctedFinType = "Income";

  String get selctedFinType => _selctedFinType;

  final List<String> _exploreNames = ["Stock", "Mutual Fund", "IPOs", "Bonds"];

  List<String> get exploreNames => _exploreNames;

  String _exploreName = "Stock";

  String get exploreName => _exploreName;
  int _exploreIndex = 0;
  PageController controller = PageController(initialPage: 0);
  int get exploreIndex => _exploreIndex;

  chngExpName(String val, int ind) {
    _exploreName = val;
    _exploreIndex = ind;
    controller = PageController(initialPage: ind);
    notifyListeners();
  }

  String get selctedTradeAct => _selctedTradeAct;
  String get selctedEventAct => _selctedEventAct;

  chngTradeAct(String val) async {
    if (val == "init") {
      _selctedTradeAct = "Equity";
      await fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
      await fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
    } else {
      _selctedTradeAct = val;

      if (val == "Equity") {
        await fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
        await fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
      } else {
        await fetchTradeAction("NFO", "NFOALL", "topG_L", "topG_L");
        await fetchTradeAction("NFO", "NFOALL", "mostActive", "mostActive");
      }
      notifyListeners();
    }
  }

  chngEventAct(String val) async {
    _selctedEventAct = val.toLowerCase();
    notifyListeners();
  }

  List<double> getCustomItemsHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (tradeActType.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<double> getSMCustomItemsHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_stockMonitorSym.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<DropdownMenuItem<String>> addSMDivider() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _stockMonitorSym) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item["symbol"].toString(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    item["symbol"].toString(),
                    style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff000000),
                            fontSize: 13)),
                  ))),
          //If it's last item, we will not add Divider after it.
          if (item != _stockMonitorSym.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<DropdownMenuItem<String>> addDividersAfterExpDates() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in tradeActType) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item.toString(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    item.toString(),
                    style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff000000),
                            fontSize: 13)),
                  ))),
          //If it's last item, we will not add Divider after it.
          if (item != tradeActType.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> getSMCustItemsHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (tradeActType.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<DropdownMenuItem<String>> addSMividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in tradeActType) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item.toString(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    item.toString(),
                    style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff000000),
                            fontSize: 13)),
                  ))),
          //If it's last item, we will not add Divider after it.
          if (item != tradeActType.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  Future getNews() async {
    try {
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String formatted = formatter.format(now);

      _newsModel = await api.fetchNews(formatted);

      return _newsModel;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "$e",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
      rethrow;
    }
  }

  Future getGlobalIndices() async {
    try {
      _globalIndicesModel = await api.fetchGlobalIndices();
      return _globalIndicesModel;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "$e",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
      rethrow;
    }
  }

  Future fetchTradeAction(
      String exch, String bskt, String crt, String isMostAct) async {
    try {
      _topListStocks = await api.getTradeAction(exch, bskt, crt);

      if (_topListStocks!.stat == "Ok") {
        if (isMostAct == "mostActive") {
          _byValue = _topListStocks!.byValue ?? [];
          _byVolume = _topListStocks!.byVolume ?? [];
        } else {
          _topGainers = _topListStocks!.topGainers ?? [];
          _topLosers = _topListStocks!.topLosers ?? [];
        }
      }
      notifyListeners();
    } catch (e) {
      print("$e");
    }
  }

  //Future getActionTrade() async {
  //   try {
  //     _actionTrademodel = await api.fetchTradeAction();
  //     return _actionTrademodel;
  //   } catch (e) {
  //     print(e);

  //     rethrow;
  //   }
  // }

  chngTradeAction(String val) {
    if (val == 'init') {
      _tradeData = "Top gainers";
      _topStockData = _topGainers;
    } else {
      _tradeData = val;
      if (val == "Top gainers") {
        _topStockData = _topGainers;
      } else if (val == "Top losers") {
        _topStockData = _topLosers;
      } else if (val == "Vol. breakout") {
        _topStockData = _byVolume;
      } else {
        _topStockData = _byValue;
      }
      notifyListeners();
    }
  }

  chngfinancilaType(String val) {
    _selctedFinType = val;
    notifyListeners();
  }

  defaultSectorThemematicData() {
    _sectorsData = [
      SectorThemeaticModel(
          chng: "",
          secName: "NIFTY FINANCIAL SERVICES",
          secCount: "",
          name: "Financial Services",
          ltp: "",
          token: "26037",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "NIFTY OIL AND GAS INDEX",
          secCount: "",
          name: "Oil & Gas",
          ltp: "",
          token: "26071",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "NIFTY BANK",
          secCount: "",
          name: "Bank",
          ltp: "",
          token: "26009",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "NIFTY IT",
          secCount: "",
          name: "IT",
          ltp: "",
          token: "26008",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "NIFTY FMCG",
          secCount: "",
          name: "FMCG",
          ltp: "",
          token: "26021",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
    ];

    _thematicData = [
      SectorThemeaticModel(
          chng: "",
          secName: "Nifty India Manufacturing",
          secCount: "",
          name: "Manufacturing",
          ltp: "",
          token: "26080",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "NIFTY INFRASTRUCTURE",
          secCount: "",
          name: "InfraStructure",
          ltp: "",
          token: "26019",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "NIFTY INDIA CONSUMPTION",
          secCount: "",
          name: "Consumption",
          ltp: "",
          token: "26036",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "Nifty Mobility",
          secCount: "",
          name: "Mobility",
          ltp: "",
          token: "26008",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: ""),
      SectorThemeaticModel(
          chng: "",
          secName: "Nifty India Digital",
          secCount: "",
          name: "Digital",
          ltp: "",
          token: "26077",
          perChng: "",
          poistive: "",
          nutral: "",
          marketCap: "",
          close: "")
    ];
    fetchIndicesAdvdec();
    notifyListeners();
  }

  fetchIndicesAdvdec() async {
    try {
      final response = await api.getadindicesAdvdec("");

      Map res = jsonDecode(response.body);
      List ltpArgs = [];
      for (var element in res.keys) {
        for (var sector in _sectorsData) {
          if (element.toString() == sector.secName.toString()) {
            sector.negative = "${res["$element"]["Negative"]}";
            sector.poistive = "${res["$element"]["Positive"]}";
            sector.nutral = "${res["$element"]["Neutral"]}";
            sector.marketCap = "${res["$element"]["marketCap"]}";
            sector.token = "${res["$element"]["token"]}";

            sector.secCount = (int.parse(sector.poistive ?? "0") +
                    int.parse(sector.nutral ?? "0") +
                    int.parse(sector.negative ?? "0"))
                .toString();
            ltpArgs.add({"exch": "NSE", "token": "${sector.token}"});

            // print("${sector.secCount}");
          }
        }
      }

      for (var element in res.keys) {
        for (var sector in _thematicData) {
          if (element.toString() == sector.secName.toString()) {
            sector.negative = "${res["$element"]["Negative"]}";
            sector.poistive = "${res["$element"]["Positive"]}";
            sector.nutral = "${res["$element"]["Neutral"]}";
            sector.marketCap = "${res["$element"]["marketCap"]}";
            sector.token = "${res["$element"]["token"]}";

            sector.secCount = (int.parse(sector.poistive ?? "0") +
                    int.parse(sector.nutral ?? "0") +
                    int.parse(sector.negative ?? "0"))
                .toString();
            ltpArgs.add({"exch": "NSE", "token": "${sector.token}"});

            // print("${sector.secCount}");
          }
        }
      }

      final ltpDatas = await api.getLTP(ltpArgs);

      Map ltpData = jsonDecode(ltpDatas.body);

      for (var element in _sectorsData) {
        if (element.token.toString() ==
            "${ltpData["data"]["${element.token}"]['token']}") {
          element.ltp = "${ltpData["data"]["${element.token}"]["lp"]}";

          element.close = "${ltpData["data"]["${element.token}"]["close"]}";

          element.perChng = "${ltpData["data"]["${element.token}"]["change"]}";

          element.chng = (double.parse(
                      "${element.ltp == "0" ? element.close : element.ltp}") -
                  double.parse("${element.close}"))
              .toStringAsFixed(2);
        }
      }

      for (var element in _thematicData) {
        if (element.token.toString() ==
            "${ltpData["data"]["${element.token}"]['token']}") {
          element.ltp = "${ltpData["data"]["${element.token}"]["lp"]}";

          element.close = "${ltpData["data"]["${element.token}"]["close"]}";

          element.perChng = "${ltpData["data"]["${element.token}"]["change"]}";

          element.chng = (double.parse(
                      "${element.ltp == "0" ? element.close : element.ltp}") -
                  double.parse("${element.close}"))
              .toStringAsFixed(2);
        }
      }

// _tradeActionKeys.add(jsonEncode(res.keys) );
//    for (var i = 0; i < res.length; i++) {

//     print("${res[i]}");
// //    for (var element in _sectorsData) {
// //   if (res[element]) {

//    }

// }
//  }
    } catch (e) {
      print(e);
    }
  }

  Future fetchCorporateAction() async {
    try {
      _corporateActionModel = await api.getCorporateAction();

      notifyListeners();
    } catch (e) {
      print("$e");
    }
  }

  Future fetchCAevents() async {
    try {
      _caeventsModel = await api.getCAeventsdata();
      notifyListeners();
    } catch (e) {
      print("$e");
    }
  }

  Future fetchAdindices(String name) async {
    try {
      _indicesData = await api.getadindices(name);

      for (var element in _indicesData) {
        element.perChng = (double.parse(element.ltp ?? "0.00") -
                double.parse(element.close ?? "0.0"))
            .toStringAsFixed(2);
      }
      notifyListeners();
    } catch (e) {
      print("$e");
    }
  }

  Future fetchALLAdindices() async {
    try {
      _getAdIndicesModel = await api.getAllAdindices();

      final response = await api.getadindicesAdvdec("");

      Map res = jsonDecode(response.body);

      _sectorsData = [];

      List ltpArgs = [];
      for (var element in _getAdIndicesModel!.sectoralIndices!) {
        if (res.containsKey(element)) {
          _sectorsData.add(SectorThemeaticModel(
              secName: element,
              name: "",
              secCount: (int.parse("${res[element]["Positive"]}") +
                      int.parse("${res[element]["Neutral"]}") +
                      int.parse("${res[element]["Negative"]}"))
                  .toString(),
              ltp: "",
              chng: "",
              perChng: "",
              negative: "${res[element]["Negative"]}",
              poistive: "${res[element]["Positive"]}",
              close: "",
              token: "${res[element]["token"]}",
              nutral: "${res[element]["Neutral"]}",
              marketCap: "${res[element]["marketCap"]}"));
        }

        if (res[element]["token"] != "") {
          ltpArgs.add({"exch": "NSE", "token": "${res[element]["token"]}"});
        }

        // print("${sector.secCount}");
      }
      _thematicData = [];

      for (var element in _getAdIndicesModel!.thematicIndices!) {
        if (res.containsKey(element)) {
          _thematicData.add(SectorThemeaticModel(
              secName: element,
              name: "",
              secCount: (int.parse("${res[element]["Positive"]}") +
                      int.parse("${res[element]["Neutral"]}") +
                      int.parse("${res[element]["Negative"]}"))
                  .toString(),
              ltp: "",
              chng: "",
              perChng: "",
              negative: "${res[element]["Negative"]}",
              poistive: "${res[element]["Positive"]}",
              close: "",
              token: "${res[element]["token"]}",
              nutral: "${res[element]["Neutral"]}",
              marketCap: "${res[element]["marketCap"]}"));
        }

        if (res[element]["token"] != "") {
          ltpArgs.add({"exch": "NSE", "token": "${res[element]["token"]}"});
        }

        // print("${sector.secCount}");
      }

      _strategicData = [];

      for (var element in _getAdIndicesModel!.strategyIndices!) {
        if (res.containsKey(element)) {
          _strategicData.add(SectorThemeaticModel(
              secName: element,
              name: "",
              secCount: (int.parse("${res[element]["Positive"]}") +
                      int.parse("${res[element]["Neutral"]}") +
                      int.parse("${res[element]["Negative"]}"))
                  .toString(),
              ltp: "",
              chng: "",
              perChng: "",
              negative: "${res[element]["Negative"]}",
              poistive: "${res[element]["Positive"]}",
              close: "",
              token: "${res[element]["token"]}",
              nutral: "${res[element]["Neutral"]}",
              marketCap: "${res[element]["marketCap"]}"));
        }
        if (res[element]["token"] != "") {
          ltpArgs.add({"exch": "NSE", "token": "${res[element]["token"]}"});
        }
        // print("${sector.secCount}");
      }

      _niftyData = [];

      for (var element in _getAdIndicesModel!.niftyIndices!) {
        if (res.containsKey(element)) {
          _niftyData.add(SectorThemeaticModel(
              secName: element,
              name: "",
              secCount: (int.parse("${res[element]["Positive"]}") +
                      int.parse("${res[element]["Neutral"]}") +
                      int.parse("${res[element]["Negative"]}"))
                  .toString(),
              ltp: "",
              chng: "",
              perChng: "",
              negative: "${res[element]["Negative"]}",
              poistive: "${res[element]["Positive"]}",
              close: "",
              token: "${res[element]["token"]}",
              nutral: "${res[element]["Neutral"]}",
              marketCap: "${res[element]["marketCap"]}"));
        }
        if (res[element]["token"] != "") {
          ltpArgs.add({"exch": "NSE", "token": "${res[element]["token"]}"});
        }
        // print("${sector.secCount}");
      }

      final ltpDatas = await api.getLTP(ltpArgs);

      Map ltpData = jsonDecode(ltpDatas.body);

      for (var element in _sectorsData) {
        if (element.token!.isNotEmpty) {
          if (element.token.toString() ==
              "${ltpData["data"]["${element.token}"]['token']}") {
            element.ltp = "${ltpData["data"]["${element.token}"]["lp"]}";

            element.close = "${ltpData["data"]["${element.token}"]["close"]}";

            element.perChng =
                "${ltpData["data"]["${element.token}"]["change"]}";

            element.chng = (double.parse(
                        "${element.ltp == "0" ? element.close : element.ltp}") -
                    double.parse("${element.close}"))
                .toStringAsFixed(2);
          }
        }
      }

      for (var element in _thematicData) {
        if (element.token!.isNotEmpty) {
          if (element.token.toString() ==
              "${ltpData["data"]["${element.token}"]['token']}") {
            element.ltp = "${ltpData["data"]["${element.token}"]["lp"]}";

            element.close = "${ltpData["data"]["${element.token}"]["close"]}";

            element.perChng =
                "${ltpData["data"]["${element.token}"]["change"]}";

            element.chng = (double.parse(
                        "${element.ltp == "0" ? element.close : element.ltp}") -
                    double.parse("${element.close}"))
                .toStringAsFixed(2);
          }
        }
      }

      for (var element in _strategicData) {
        if (element.token!.isNotEmpty) {
          if (element.token.toString() ==
              "${ltpData["data"]["${element.token}"]['token']}") {
            element.ltp = "${ltpData["data"]["${element.token}"]["lp"]}";

            element.close = "${ltpData["data"]["${element.token}"]["close"]}";

            element.perChng =
                "${ltpData["data"]["${element.token}"]["change"]}";

            element.chng = (double.parse(
                        "${element.ltp == "0" ? element.close : element.ltp}") -
                    double.parse("${element.close}"))
                .toStringAsFixed(2);
          }
        }
      }
      for (var element in _niftyData) {
        if (element.token!.isNotEmpty) {
          if (element.token.toString() ==
              "${ltpData["data"]["${element.token}"]['token']}") {
            element.ltp = "${ltpData["data"]["${element.token}"]["lp"]}";

            element.close = "${ltpData["data"]["${element.token}"]["close"]}";

            element.perChng =
                "${ltpData["data"]["${element.token}"]["change"]}";

            element.chng = (double.parse(
                        "${element.ltp == "0" ? element.close : element.ltp}") -
                    double.parse("${element.close}"))
                .toStringAsFixed(2);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      print("$e");
    }
  }

  requestWSTradeaction(
      {required bool isSubscribe, required BuildContext context}) {
    try {
      String input = "";
      if (_topStockData.isNotEmpty) {
        input =
            _topStockData.map((e) => "${e.exch}|${e.token}").toSet().join("#");
        print("input $input");
      }

      if (input.isNotEmpty) {
        // ConstantName.lastSubscribe = input;
        ref.read(websocketProvider).establishConnection(
            channelInput: input,
            task: isSubscribe ? "t" : "u",
            context: context);
      }
    } catch (e) {}

    notifyListeners();
  }

  fetchStockMonitor(String exch, String bskt, String cont) async {
    try {
      _stockMonitor = await api.getStockMonitor(exch, bskt, cont);
      // List ltpArgs=[];
      if (_stockMonitor.isNotEmpty) {
        if (_stockMonitor[0].stat == "Not_Ok") {
          _stockMonitor = [];
        }

// for (var element in _stockMonitor) {
//    ltpArgs.add({"exch": "NSE", "token": "${element.token}"});
// }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }
}
