import '../api/core/api_core.dart';
import '../models/mf_model/best_mf_model.dart';
import '../models/mf_model/mandate_detail_model.dart';
import '../models/mf_model/mf_factsheet_data_model.dart';
import '../models/mf_model/mf_factsheet_graph.dart';
import '../models/mf_model/mf_nav_graph_model.dart';
import '../models/mf_model/mf_scheme_peers_model.dart';
import '../models/mf_model/mf_sip_model.dart';
import '../models/mf_model/mf_watch_list.dart';
import '../models/mf_model/mutual_fundmodel.dart';
import 'package:intl/intl.dart';
mixin MutualFundApi on ApiCore {
  Future<MutualFundModel> getMasterMF() async {
    try {
      final uri = Uri.parse(apiLinks.masterMF);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "filter": "normal",
            "Purchase_Allowed": "Y",
            "Redemption_Allowed": "Y",
            "Purchase_Transaction_mode": ["DP", "D"]
          }));

      final json = jsonDecode((res.body));

      // log("MF Master ==>$json");

      return MutualFundModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BestMFModel> getBestMF() async {
    try {
      final uri = Uri.parse(apiLinks.bestMf);
      final res = await apiClient.post(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));

      // log("Best MF ==>$json");

      return BestMFModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MFWatchlistModel> getMFWatchlist(
      MutualFundList? scipt, String isAdd) async {
    try {
      final uri = Uri.parse(apiLinks.mfWatchlist);
      Map payload = {"client_code": "${prefs.clientId}", "type": isAdd};

      if (scipt != null) {
        payload.addAll({"scripts": scipt});
      }

      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode(payload));

      final json = jsonDecode((res.body));

      return MFWatchlistModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<MFFactSheetDataModel> getMFFactSheetData(String isin) async {
    try {
      final uri = Uri.parse("${apiLinks.factSheetData}?ISIN=$isin");

      final res = await apiClient.post(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));

      // log("Fact Sheet  => $json");

      return MFFactSheetDataModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MFFactSheetGraph> getMFFactSheetGraph(String isin) async {
    try {
      final uri = Uri.parse("${apiLinks.factSheetGraph}?ISIN=$isin");

      final res = await apiClient.post(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));

      //  print("Fact Sheet Graph => $json");

      return MFFactSheetGraph.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MFSchemePeers> getMFSchemePeer(String isin, String year) async {
    try {
      final uri = Uri.parse("${apiLinks.schemePeers}?ISIN=$isin&year=$year");

      final res = await apiClient.post(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));
      //  log("Schene Peer => $json");
      return MFSchemePeers.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MFNavGraph> getMFNavGraph(String isin) async {
    DateTime curDate = DateTime.now();
    try {
      final uri = Uri.parse(
          "${apiLinks.navGraph}?ISIN=$isin&fromDate=1990-01-01&toDate=${curDate.year}-${curDate.month}-${curDate.day}");

      final res = await apiClient.post(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));

      return MFNavGraph.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MandateDetailModel> getMandateDetail() async {
    DateTime curDate = DateTime.now();

    DateFormat formatter = DateFormat('dd/MM/yyyy');

  // Format the current date
  String formattedDate = formatter.format(DateTime(curDate.year+30,curDate.month,curDate.day));
    try {
      final uri = Uri.parse(apiLinks.mandateDetail);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}",
            "mandate_id": "",
            "from_date": "01/01/1900",
            "to_date": formattedDate
          }));

      final json = jsonDecode((res.body));

      return MandateDetailModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MfSIPModel> getMFSip(String isin, String schemeCode) async {
    try {
      final uri = Uri.parse(apiLinks.mfSip);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"isin": isin, "scheme_code": schemeCode}));

      final json = jsonDecode((res.body));

      return MfSIPModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
