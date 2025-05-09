
import 'package:flutter/material.dart';
import '../models/marketwatch_model/add_delete_scrip_model.dart';
import '../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../models/marketwatch_model/alert_model/cancel_alert_model.dart';
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
import '../models/marketwatch_model/search_scrip_new_model.dart';
import '../models/marketwatch_model/watchlist_rename_model.dart';
import 'core/api_core.dart';

mixin MarketWatchApi on ApiCore {
  // Get List of watchlist names form kambala

  Future<MarketWatchlist> getMWList() async {
    try {
      final uri = Uri.parse(apiLinks.watchList);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
      //  log("Market Watchlist => ${res.body}");
      final json = jsonDecode(res.body);

      return MarketWatchlist.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Edit watchlist name from kambala

  Future<WatchlistRenameModel> getWatchListRename(
      String oldName, String newName) async {
    try {
      final uri = Uri.parse(apiLinks.watchListrename);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","wlname":"$oldName","newwlname":"$newName"}&jKey=${prefs.clientSession}''');

      final json = jsonDecode(res.body);

      return WatchlistRenameModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get List of Market scrips by watchlist names form kambala

  Future<MarketWatchScrip> getMWScrip(String wlname) async {
    try {
      final uri = Uri.parse(apiLinks.marketWatchScrip);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","wlname":"$wlname"}&jKey=${prefs.clientSession}''');
      // log("Market WatchScrip => ${res.body}");
      final json = jsonDecode(res.body);

      return MarketWatchScrip.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get Predefined MArket scrips (NIFTY,BANK NIFTY,SENSEX)

  Future<PreDefinedMWlist> getPreDefMWScrip() async {
    try {
      final uri = Uri.parse(apiLinks.preDefdMWatchScrip);
      final res = await apiClient.post(uri, headers: defaultHeaders);
      // log(" Pre Def Market WatchScrip => ${res.body}");
      final json = jsonDecode(res.body);

      return PreDefinedMWlist.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get Single Market scrip info from kambala

  Future<ScripInfoModel> getScripInfo(String token, String exch) async {
    try {
      final uri = Uri.parse(apiLinks.securityInfo);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","exch":"$exch","token":"$token"}&jKey=${prefs.clientSession}''');

      // log("Scrip Info => ${res.body}");
      final json = jsonDecode(res.body);

      return ScripInfoModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get Single Market scrip Details from kambala

  Future<GetQuotes> getScripQuote(String token, String exch) async {
    try {
      final uri = Uri.parse(apiLinks.getQuotes);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","exch":"$exch","token":"$token"}&jKey=${prefs.clientSession}''');

      //  log("Scrip Get Info => ${res.body}");
      final json = jsonDecode(res.body);

      return GetQuotes.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // get Add / Delete Scrips to watchlist from kamabal

  Future<AddDeleteScripModel> getAddDeleteSciptoMW(
      {required String wlname,
      required String scripToken,
      required bool isAdd}) async {
    try {
      final uri =
          Uri.parse(isAdd ? apiLinks.addMWScrips : apiLinks.deleteMWScrips);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","wlname":"$wlname","scrips":"$scripToken"}&jKey=${prefs.clientSession}''');

      // log("Add Delete SciptoMW => ${res.body}");
      final json = jsonDecode(res.body);

      return AddDeleteScripModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get Trade symbol wise search from kambala

  Future<SearchScripModel> getSearchScrip({required String searchText}) async {
    try {
      final uri = Uri.parse(apiLinks.searchScrip);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","stext":"${searchText.replaceAll("&", "%26")}"}&jKey=${prefs.clientSession}''');

      //  log("Search Scrip => ${res.body}");
      final json = jsonDecode(res.body);

      return SearchScripModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

    Future<SearchScripNewModel> getSearchScripNew({required String searchText, required String categ, required List exchs}) async {
    try {
      final uri = Uri.parse(apiLinks.searchScripNew);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","stext":"${searchText.replaceAll("&", "%26")}","cat":"$categ","fil":${exchs.toList()}}&jKey=${prefs.clientSession}''');

       print("Search Scrip => ${res.body}");
      final json = jsonDecode(res.body);
       print("Search Scrip => ${json['values'].length}");
      return SearchScripNewModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get Linked scrip details from kambala

  Future<LinkedScrips> getLinkedScrip(String token, String exch) async {
    try {
      final uri = Uri.parse(apiLinks.getLinkedScrip);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","exch":"$exch","token":"$token"}&jKey=${prefs.clientSession}''');

      //  log(" LinkedScrips Info => ${res.body}");
      final json = jsonDecode(res.body);

      return LinkedScrips.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get Option chain datas from kambala

  Future<OptionChainModel?> getOptionChain(
      {required String strPrc,
      required String tradeSym,
      required String exchange,
      required BuildContext context,
      required String numofStrike}) async {
    try {
      final uri = Uri.parse(apiLinks.optionChain);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","exch":"$exchange" ,"tsym":"$tradeSym","cnt":"$numofStrike ","strprc":"$strPrc"}&jKey=${prefs.clientSession}''');

      //  log(" Option Chain   => ${res.body}");

      final resp = OptionChainModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
      return resp;
    } catch (e) {
      // log(e.toString());
      rethrow;
    }
  }

  // Future<MarketWatchlist> getPreDefMWList() async {
  //   try {
  //     final uri = Uri.parse(apiLinks.preDefinedMWList);
  //     final res = await apiClient.post(uri,
  //         headers: defaultHeaders,
  //         body:
  //             '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');

  //     final json = jsonDecode(res.body);

  //     return MarketWatchlist.fromJson(json as Map<String, dynamic>);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Get Scrip returns data from kambala

  Future<TechnicalData> getTechData(String exch, String tsym) async {
    try {
      final uri = Uri.parse(apiLinks.technicalData);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","exch":"$exch","tsym":"$tsym"}&jKey=${prefs.clientSession}''');

      final json = jsonDecode(res.body);

      // log(" Tech Data   => ${res.body}");

      return TechnicalData.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Get Equity and BSE Stocks fundamental data

  Future<StockData> getFundamentalData(String tsym) async {
    try {
      final uri = Uri.parse(apiLinks.fundamentalDetail);
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode({"symbol": tsym}));

      final json = jsonDecode(res.body);

    //  log(" Fundamental Data   => ${res.body}");

      return StockData.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

/////////////////// SET ALERTS API////////////////
  Future<SetAlertModel> getSetAlert(String exch, String tysm, String value,
      String alertTypeVal, String remark) async {
    try {
      final uri = Uri.parse(apiLinks.setAlert);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","exch":"$exch","tsym":"$tysm","ai_t":"$alertTypeVal","validity":"GTT","d":"$value","remarks":"$remark"}&jKey=${prefs.clientSession}''');

      // log("SetAlert => ${res.body}");
      final json = jsonDecode(res.body);

      return SetAlertModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AlertPendingModel>> getPendingAlert() async {
    try {
      final uri = Uri.parse(apiLinks.pendingalert);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
      // log("Pending Alert => ${res.body}");

      final List<AlertPendingModel> data = [];

      final json = jsonDecode(res.body);

      try {
        if (json['stat'] == 'Not_Ok') {
          final AlertPendingModel ord =
              AlertPendingModel.fromJson(json as Map<String, dynamic>);
          return [ord];
        } else {
          for (final item in json) {
            data.add(AlertPendingModel.fromJson(item as Map<String, dynamic>));
          }
        }
      } catch (e) {
        if (res.statusCode == 200) {
          for (final item in json) {
            data.add(AlertPendingModel.fromJson(item as Map<String, dynamic>));
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<CancelAlertModel> getCancelAlert(String alId) async {
    try {
      final uri = Uri.parse(apiLinks.cancelAlert);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","al_id":"$alId"}&jKey=${prefs.clientSession}''');

      // log("Cancel  => ${res.body}");
      final json = jsonDecode(res.body);

      return CancelAlertModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<ModifyAlertModel> getmodifyalert(String exch, String tysm,
      String value, String alertTypeVal, String alid) async {
    try {
      final uri = Uri.parse(apiLinks.modifyalert);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","exch":"$exch","tsym":"$tysm","ai_t":"$alertTypeVal","validity":"GTT","al_id":"$alid","d":"$value"}&jKey=${prefs.clientSession}''');

      // log("Modify Alert => ${res.body}");
      final json = jsonDecode(res.body);

      return ModifyAlertModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
