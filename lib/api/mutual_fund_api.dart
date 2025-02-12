import 'dart:developer';

import '../api/core/api_core.dart';
import '../models/mf_model/best_mf_model.dart';
import '../models/mf_model/mandate_detail_model.dart';
import '../models/mf_model/mf_all_payment_model.dart';
import '../models/mf_model/mf_create_mandate.dart';
import '../models/mf_model/mf_factsheet_data_model.dart';
import '../models/mf_model/mf_factsheet_graph.dart';
import '../models/mf_model/mf_lumpsum_order.dart';
import '../models/mf_model/mf_nav_graph_model.dart';
import '../models/mf_model/mf_orderbook_lumpsum_model.dart';
import '../models/mf_model/mf_scheme_peers_model.dart';
import '../models/mf_model/mf_search_model.dart';
import '../models/mf_model/mf_sip_model.dart';
import '../models/mf_model/mf_watch_list.dart';
import '../models/mf_model/mf_x_sip_order_responces.dart';
import '../models/mf_model/mf_xsip_cancle_resone_res.dart';
import '../models/mf_model/mutual_fundmodel.dart';
import 'package:intl/intl.dart';

import '../models/mf_model/x_sip_cancel_order_model.dart';

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

  Future<SearchMFmodel> getSearchMf(String searchValue) async {
    try {
      final uri = Uri.parse(apiLinks.searchMF);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"text": searchValue.toString()}));

      final json = jsonDecode((res.body));

     // log("MF Master ==>$json");

      return SearchMFmodel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MfPlaceOrderResponces> getLumpSumOrder(
      MfPlaceOrderInput mforderlumpsuminput) async {
    try {
      final uri = Uri.parse(apiLinks.lumpsumOrder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "trans_code": mforderlumpsuminput.transcode,
            "client_code": prefs.clientId,
            "scheme_code": mforderlumpsuminput.schemecode,
            "buy_sell": mforderlumpsuminput.buysell,
            "buy_sell_type": mforderlumpsuminput.buyselltype,
            "dptxn": mforderlumpsuminput.dptxn,
            "amount": mforderlumpsuminput.amount,
            "all_redeem": mforderlumpsuminput.allredeem,
            "kyc_status": mforderlumpsuminput.kycstatus,
            "qty": mforderlumpsuminput.qty,
            "euin_flag": mforderlumpsuminput.euinflag,
            "min_redeem": mforderlumpsuminput.minredeem,
            "dpc": mforderlumpsuminput.dpc
          }));

      final json = jsonDecode((res.body));

      log("palce order mf ==>$json");

      return MfPlaceOrderResponces.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MfLumpSumOrderbook> getorderbook() async {
    try {
      final uri = Uri.parse(apiLinks.lumpsumOrderbook);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}",
            "from_date": "",
            "to_date": ""
          }));

      final json = jsonDecode((res.body));

      // log("MF orderBook ==>${json}");

      return MfLumpSumOrderbook.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<XsipOrderResponces> getXsipPurchase(
      String schemecode,
      String startDate,
      String freqtype,
      String amt,
      String noofinstallment,
      String enddate,
      String mandateId) async {
    try {
      final uri = Uri.parse(apiLinks.mfXSiporder);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "trans_code": "NEW",
            "scheme_code": schemecode,
            "client_code": prefs.clientId,
            "trans_mode": "D",
            "start_date": startDate,
            "freq_type": freqtype,
            "freq_allowed": "1",
            "installment_amt": amt,
            "no_of_installment": noofinstallment,
            "euin_flag": "N",
            "first_order": "N",
            "end_date": "1",
            "mandate_id": mandateId
          }));

      final json = jsonDecode((res.body));

      log("MF X-sip PlaceOrder ==>$json");

      return XsipOrderResponces.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MfCreateMandateModel> getCreateMandate(
      String amount, String startDate, String endDate) async {
    ////parse date

    try {
      DateTime parsedDate = DateFormat("d/M/yyyy").parse(startDate);
      String startDateformattedDate =
          DateFormat("dd/MM/yyyy").format(parsedDate);
      DateTime endparsedDate = DateFormat("d/M/yyyy").parse(endDate);
      String endDateDateformattedDate =
          DateFormat("dd/MM/yyyy").format(endparsedDate);
      final uri = Uri.parse(apiLinks.mandatecreate);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": prefs.clientId,
            "amount": amount,
            "startdate": startDateformattedDate,
            "enddate": endDateDateformattedDate
          }));

      final json = jsonDecode((res.body));

      log("MF Create Mandate ==>$json");

      return MfCreateMandateModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<XsipOrderCancleResponces> getxsipCancle(String xsipregno,
      String internalrefno, String caseno, String remarks) async {
    try {
      final uri = Uri.parse(apiLinks.mfxsipcancel);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": prefs.clientId,
            "xsip_reg_no": xsipregno,
            "internal_refer_no": internalrefno,
            "case_no": caseno,
            "remarks": ""
          }));

      final json = jsonDecode((res.body));

      log("MF X_sip cancel order ==>$json");

      return XsipOrderCancleResponces.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<AllPaymentMfModel> getmfallpayment(
      String orderNumber,
      String totalAmt,
      String accno,
      String ifsc,
      String bankname,
      String paymentMethod,
      String internalrefno,
      String mandateId,
      String upi) async {
    try {
      final uri = Uri.parse(apiLinks.mfallpayment);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": prefs.clientId,
            "order_number": orderNumber,
            "total_amount": totalAmt,
            "acc_number": accno,
            "ifsc": ifsc,
            "bank_name": bankname,
            "mode_of_payment": paymentMethod,
            "internal_ref_no": internalrefno,
            "mandate_id": mandateId,
            "vpa_id": upi,
            "loop_back_url": "https://app.mynt.in/mutualfund",
            "allow_loop_back": "N"
          }));

      final json = jsonDecode((res.body));

      log("MF ALLL PAYMENT ==>$json");

      return AllPaymentMfModel.fromJson(json as Map<String, dynamic>);
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

  Future<XsipOrderCancleResone> getXsipCancleResone() async {
    try {
      final uri = Uri.parse(apiLinks.mfXsipcancleRes);
      final res = await apiClient.post(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));

      //log("X-SIP OREDER CANCEL RESONE ==>$json");

      return XsipOrderCancleResone.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      print("X-SIP OREDER CANCEL RESONE :: $e");
      rethrow;
    }
  }

  Future<MFWatchlistModel> getMFWatchlistsearch(
      MfList? scipt, String isAdd) async {
    try {
      final uri = Uri.parse(apiLinks.mfWatchlist);
      Map payload = {"client_code": "${prefs.clientId}", "type": isAdd};

      if (scipt != null) {
        payload.addAll({"scripts": scipt.toJson()});
      }

      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode(payload));
      log("DDDDDDDDD ${res.body}");
      final json = jsonDecode((res.body));

      return MFWatchlistModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      log("API ERROr ::: $e");
      rethrow;
    }
  }

  Future<MFWatchlistModel> getMFWatchlist(
      MutualFundList? scipt, String isAdd) async {
    try {
      final uri = Uri.parse(apiLinks.mfWatchlist);
      Map payload = {"client_code": "${prefs.clientId}", "type": isAdd};

      if (scipt != null) {
        payload.addAll({"scripts": scipt.toJson()});
      }

      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode(payload));
      ///log("DDDDDDDDD ${res.body}");
      final json = jsonDecode((res.body));

      return MFWatchlistModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      log("API ERROr ::: $e");
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
    String formattedDate = formatter
        .format(DateTime(curDate.year + 30, curDate.month, curDate.day));
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
