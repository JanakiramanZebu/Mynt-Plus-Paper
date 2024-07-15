import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import 'package:intl/intl.dart';
import '../models/indices/global_indices_model.dart';
import '../models/news_model.dart';
import '../models/stocks_model/toplist_stocks.dart';
import 'core/default_change_notifier.dart';

final stocksProvide = ChangeNotifierProvider((ref) => StocksProvider(ref.read));

class StocksProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();

  final Reader ref;

  List<NewsModel>? _newsModel;
  List<NewsModel>? get newsModel => _newsModel;
  List<GlobalIndicesModel>? _globalIndicesModel;
  List<GlobalIndicesModel>? get globalIndicesModel => _globalIndicesModel;

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
  String _tradeData = "Top gainer";
  String get tradeData => _tradeData;
  StocksProvider(this.ref);

  List<String> tradeActType = ["Equity", "F&O"];

  String _selctedTradeAct = "Equity";

  bool _moreFunRatio = false;
  bool get moreFunRatio => _moreFunRatio;

  final List<String> _eveType = [
    "Announcement",
    "Bonus",
    "Divedend",
    "Rights",
    "Split"
  ];

  List<String> get eveType => _eveType;

  String _selectedEvent = "Announcement";
  String get selectedevent => _selectedEvent;
  showMoreFunRatio() {
    _moreFunRatio = !_moreFunRatio;
    notifyListeners();
  }

  chngEvent(String val) {
    _selectedEvent = val;
    notifyListeners();
  }

  final List<String> _finacialType = ["Income", "Balance sheet", "Cashflow"];

  List<String> get finacialType => _finacialType;

  String _selctedFinType = "Income";

  String get selctedFinType => _selctedFinType;

  String get selctedTradeAct => _selctedTradeAct;
  chngTradeAct(String val) async {
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

      await chngTradeAction("Top gainers");

      notifyListeners();
    } catch (e) {
      print("$e");
    }
  }

  chngTradeAction(String val) {
    _tradeData = val;
    if (val == "Top gainers") {
      _topStockData = _topGainers;
    } else if (val == "Top losers") {
      _topStockData = _topLosers;
    } else if (val == "Volume") {
      _topStockData = _byVolume;
    } else {
      _topStockData = _byValue;
    }

    notifyListeners();
  }

  chngfinancilaType(String val) {
    _selctedFinType = val;
    notifyListeners();
  }
}
