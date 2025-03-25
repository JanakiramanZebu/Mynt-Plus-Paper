import 'dart:developer';


import 'package:mynt_plus/models/mf_model/all_category_new_model.dart';
import 'package:mynt_plus/models/mf_model/mf_bestnewapi_list_model.dart';
import 'package:mynt_plus/models/mf_model/mf_hold_singlepage_model.dart';
import 'package:mynt_plus/models/mf_model/mf_holding_new_model.dart';
import 'package:mynt_plus/models/mf_model/mf_order_det_model.dart';
import 'package:mynt_plus/models/mf_model/mf_sip_cancel_mess_model.dart';
import 'package:mynt_plus/models/mf_model/mf_sip_reject_reason.dart';
import 'package:mynt_plus/models/mf_model/mf_sip_single_page_provider.dart';
import 'package:mynt_plus/models/mf_model/pause_sip_model.dart';
import 'package:mynt_plus/models/mf_model/sip_mf_list_model.dart';

import '../api/core/api_core.dart';
import '../models/mf_model/best_mf_list_model.dart';
import '../models/mf_model/best_mf_model.dart';
import '../models/mf_model/mandate_detail_model.dart';
import '../models/mf_model/mf_all_payment_model.dart';
import '../models/mf_model/mf_category_list_model.dart';
import '../models/mf_model/mf_categorytype_model.dart';
import '../models/mf_model/mf_create_mandate.dart';
import '../models/mf_model/mf_factsheet_data_model.dart';
import '../models/mf_model/mf_factsheet_graph.dart';
import '../models/mf_model/mf_lumpsum_order.dart';
import '../models/mf_model/mf_nav_graph_model.dart';
import '../models/mf_model/mf_nfo_model.dart';
import '../models/mf_model/mf_orderbook_lumpsum_model.dart';
import '../models/mf_model/mf_scheme_peers_model.dart';
import '../models/mf_model/mf_search_model.dart';
import '../models/mf_model/mf_sip_model.dart';
import '../models/mf_model/mf_watch_list.dart';
import '../models/mf_model/mf_x_sip_order_responces.dart';
import '../models/mf_model/mf_xsip_cancle_resone_res.dart';
import '../models/mf_model/mutual_fundmodel.dart';
import 'package:intl/intl.dart';

import '../models/mf_model/redemption_model.dart';
import '../models/mf_model/top_schemes_model.dart';
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

  Future<NFODataModel> getNFOData() async {
    try {
      final uri = Uri.parse(apiLinks.nfoMF);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
          }));

      final json = jsonDecode((res.body));

      // log("MF Master ==>$json");

      return NFODataModel.fromJson({"data":json});
    } catch (e) {
      rethrow;
    }
  }

   Future<mf_sip_reject_res> getsiprejreason() async {
    try {
      final uri = Uri.parse(apiLinks.nfoMF);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
          }));

      final json = jsonDecode((res.body));

      // log("MF Master ==>$json");

      return mf_sip_reject_res.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }


dynamic convertValuesToString(dynamic data) {
  if (data is Map) {
    return {
      for (final entry in data.entries)
        entry.key.toString(): convertValuesToString(entry.value)
    };
  } else if (data is List) {
    return [for (final item in data) convertValuesToString(item)];
  } else if (data == null) {
    return 'null';
  } else {
    // Handle special number cases
    if (data is num) {
      return convertNumber(data);
    }
    return data.toString();
  }
}

String convertNumber(num value) {
  // Convert scientific notation to full string representation
  if (value.abs() >= 1e+21 || value.abs() <= 1e-7) {
    return value.toStringAsExponential().toLowerCase();
  }
  // Preserve decimal precision for double values
  return value is int ? value.toString() : value.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(r'.$', '');
}

  Future<SearchMFmodel> getSearchMf(String searchValue) async {
    try {
      final uri = Uri.parse(apiLinks.searchMF);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"text": searchValue.toString()}));
      final mfsearch = jsonDecode(res.body);
      final json = convertValuesToString(mfsearch['data']);

     log("MF Master ==>$json");

      return SearchMFmodel.fromJson({'data': json});
    } catch (e) {
      rethrow;
    }
  }

  Future<TopSchemesModel> getTopSchemes() async {
    try {
      final uri = Uri.parse(apiLinks.topSchemes);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"sortkey":"AUM"}));
      final json = jsonDecode(res.body);

     log("Top Schemes ==>$json");

      return TopSchemesModel.fromJson(json as Map<String, dynamic>);
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

  Future<MFOrderBookModel> getorderbook() async {
    try {
      final uri = Uri.parse(apiLinks.lumpsumOrderbook);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}"
          }));

      final json = jsonDecode((res.body));
 print("MF orderBook ==>${json}");
      // log("MF orderBook ==>${json}");

      return MFOrderBookModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  redemptioncancelapi(orderno) async {
      // print("object",orderno);
    try {
      print("object");
      print("${orderno}");

      final uri = Uri.parse(apiLinks.redemptioncancel);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}",
            "order_number":orderno
          }));

      final json = jsonDecode((res.body));

      print("MF orderBook ==>${json}");

      return MFOrderBookModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }


  cancelsipapi(orderno,siprefno,droupreason,retext) async {
      print("ordermo ${orderno} ,siprefno ${siprefno} , droupreason ${droupreason} ");
    try {
      print("object");
      print("${orderno}");

      final uri = Uri.parse(apiLinks.sipcancelapiend);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}",
            "xsip_reg_no":orderno,
            "internal_refer_no":siprefno,
            "case_no":droupreason,
            "remarks": droupreason == "13" ? "${retext}" : ""
          }));

      final json = jsonDecode((res.body));

      print("MF cansipp resss ==>${json}");

      return mf_sip_cancel_message.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

    pausesipapi(orderno,notext) async {
      print("pausee ordermo ${orderno} ,siprefno ${notext}");
    try {
      print("object pausee");
      print("${orderno}");

      final uri = Uri.parse(apiLinks.pausesipendpoint);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}",
            "xsip_reg_no":orderno,
            "installments": notext
          }));

      final json = jsonDecode((res.body));

      print("pause res p resss ==>${json}");

      return pause_spi_res.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      print("${"error in pause ${e}"}");
      rethrow;
    }
  }

//  pausesipapi(orderno, notext) async {
//   print("pause ordermo: $orderno, siprefno: $notext");

//   try {
//     final uri = Uri.parse(apiLinks.pausesipendpoint);
//     final res = await apiClient.post(
//       uri,
//       headers: defaultHeaders,
//       body: jsonEncode({
//         "client_code": prefs.clientId,
//         "xsip_reg_no": orderno,
//         "installments": notext
//       }),
//     );

//     print("Raw Response: ${res.body}");

//     // Check for non-200 response
//     if (res.statusCode != 200) {
//       print("HTTP Error: ${res.statusCode}");
//       throw Exception("API Error: ${res.statusCode} - ${res.body}");
//     }

//     final json = jsonDecode(res.body);
//     print("Parsed JSON Response: $json");

//     return pause_spi_res.fromJson(json as Map<String, dynamic>);
//   } catch (e) {
//     print("Error in pause: $e");
//     rethrow;
//   }
// }

  mfallcatnewapi() async {
      // print("object",orderno);
    try {


      final uri = Uri.parse(apiLinks.mfallcatnewendpoit);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
           
          }));

      final json = jsonDecode((res.body));

      print("MF top cat neww${json}");

      return mf_catge_newlist.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<RedemptionModel> getMFRedemption(String scheme, String qty) async {
    try {
      final uri = Uri.parse(apiLinks.redemption);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}",
            "scheme_code": scheme,
            "qty": qty,
            "all_redeem":"N"

          }));

      final json = jsonDecode((res.body));

      // log("MF orderBook ==>${json}");

      return RedemptionModel.fromJson(json as Map<String, dynamic>);
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
      String upi,
      String schemeCode) async {
    try {
      final uri = Uri.parse(apiLinks.mfallpayment);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": prefs.clientId,
            "scheme_code": schemeCode,
            "amount": totalAmt,
            "acc_number": accno,
            "ifsc": ifsc,
            "bank_name": bankname,
            "mode_of_payment": paymentMethod,
            "vpa_id": upi,
          }));
      print({
            "client_code": prefs.clientId,
            "scheme_code": schemeCode,
            "amount": totalAmt,
            "acc_number": accno,
            "ifsc": ifsc,
            "bank_name": bankname,
            "mode_of_payment": paymentMethod,
            "vpa_id": upi,
          });
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

  Future<MFCategoryList> getMFCategoryList(String type, String subtype) async {
    try {
      final uri = Uri.parse(apiLinks.mfCategoryList);
      
      final res = await apiClient.post(uri, headers: defaultHeaders,
      body: jsonEncode({
        "Type":type,
        "sub":subtype
          }));

      final json = jsonDecode((res.body));

      // log("Best MF ==>$json");

      return MFCategoryList.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

   Future<BestMFListModel> getMFBestListData(String type) async {
    try {
      final uri = Uri.parse(apiLinks.mfCategoryListData);
      
      final res = await apiClient.post(uri, headers: defaultHeaders,
      body: jsonEncode({
        "title":type,
          }));

      final json = jsonDecode((res.body));

      // log("Best MF ==>$json");

      return BestMFListModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }


   Future<BestmfNewlist> getnewMFBestListData() async {
     try {
      final uri = Uri.parse(apiLinks.newbestMf);
      final res = await apiClient.get(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));

      print("Best MF @@@@@@@@1111==>$json");

      return BestmfNewlist.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }


  Future<MFCategoryType> getMFCategoryTypes() async {
    try {
      final uri = Uri.parse(apiLinks.mfCategoryTypes);
      final res = await apiClient.post(uri, headers: defaultHeaders);

      final json = jsonDecode((res.body));

      // log("Category Type MF ==>$json");

      return MFCategoryType.fromJson({"Data":json});
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
      String isin, String isAdd) async {
    try {
         print("watttadd");
      print("watttadd${isin},${isAdd}");
      final uri = Uri.parse(apiLinks.mfWatchlist);
      Map payload = {"client_code": "${prefs.clientId}", "type": isin == "" ? "View" : isAdd};

      if (isin != "") {
        payload.addAll({"isin": isin});
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
       isin, String isAdd) async {
    try {
      final uri = Uri.parse(apiLinks.mfWatchlist);
      Map payload = {"client_code": "${prefs.clientId}", "type": isin == "" ? "View" : isAdd };

      if (isin != "") {
        payload.addAll({"isin": isin});
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

Future<MFFactSheetDataModel?> getMFFactSheetData(String isin) async {
  try {
    final uri = Uri.parse("${apiLinks.factSheetData}?ISIN=$isin");
    final res = await apiClient.post(uri, headers: defaultHeaders);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return MFFactSheetDataModel.fromJson(json as Map<String, dynamic>);
    } else {
      print("API Error: ${res.statusCode} - ${res.body}");
      return null; // Return null in case of an error
    }
  } catch (e) {
    print("Exception: $e");
    return null; // Return null if an exception occurs
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


  Future<Sip_list_data> getSiplist() async {
    try {
      final uri = Uri.parse(apiLinks.mfsiplist);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"client_code": "${prefs.clientId}"}));

      final json = jsonDecode((res.body));

      print("mflisttt Type MF ==>$json");
      // print("mflisttt Type MF ==>$json.total_sip_amount");


      return Sip_list_data.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

    Future<Sip_single_page> getSipsinglepage(String value) async {
    try {
      final uri = Uri.parse(apiLinks.mfsinglepage);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"client_code": "${prefs.clientId}","sipregnno":"${value}"}));
          // body: jsonEncode({"client_code": "ZE1A40","sipregnno":"126150781"}));


      final json = jsonDecode((res.body));

      print("mflisttt Type MF ==>$json");
      // print("mflisttt Type MF ==>$json.total_sip_amount");


      return Sip_single_page.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

   Future<mf_order_sig_det> getsingleortderapi(String value,String bs , String type , String status,String sipno , String orderStatus ) async {
    try {
      final uri = Uri.parse(apiLinks.mfsingleorder);
      
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"ordernumber": "${value}","buysell":"${bs}","ordertype" : "${type}" ,"orderstatus":"${status}" ,"sipregnno" : "${sipno}" , "register_cancel":"${orderStatus == "usercancel" ? "" :  orderStatus}" }));
          // body: jsonEncode({"client_code": "ZE1A40","sipregnno":"126150781"}));


      final json = jsonDecode((res.body));

      print("mfsingle orfderrrrrr$json");
      // print("mflisttt Type MF ==>$json.total_sip_amount");


      return mf_order_sig_det.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

   Future<mf_holding_sig_det> getholdsinglepage(String value ) async {
    try {
      final uri = Uri.parse(apiLinks.mfholdsinlepageapi);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"client_code":"${prefs.clientId}","isin": "${value}" }));
          // body: jsonEncode({"client_code": "ZE1A40","sipregnno":"126150781"}));


      final json = jsonDecode((res.body));
print("client_code||||${prefs.clientId}");

print("valuee||||${value}");
      print("mfholdddddd$json");
      // print("mflisttt Type MF ==>$json.total_sip_amount");


      return mf_holding_sig_det.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

     Future<mf_holdoing_new> getmfholdnewapi( ) async {
    try {
      final uri = Uri.parse(apiLinks.mfholdnewapi);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"client_code":"${prefs.clientId}" }));
          // body: jsonEncode({"client_code": "ZE1A40","sipregnno":"126150781"}));


      final json = jsonDecode((res.body));
print("client_code||||${prefs.clientId}");

// print("valuee||||${value}");
      print("neww hold${json.toString()}");
      // print("mflisttt Tmfholddddddype MF ==>$json.total_sip_amount");


      return mf_holdoing_new.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }


}
