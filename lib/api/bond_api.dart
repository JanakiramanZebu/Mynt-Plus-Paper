import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import 'package:mynt_plus/models/bonds_model/place_order_response_model.dart';

import '../api/core/api_core.dart';
import '../models/bonds_model/govt_bonds_model.dart';
import '../models/bonds_model/ledger_bal_model.dart';
import '../models/bonds_model/sovereign_gold_bonds_model.dart';
import '../models/bonds_model/state_bonds_model.dart';
import '../models/bonds_model/treasury_bonds_model.dart';

mixin BondsApi on ApiCore {
  Future<GovtBonds> getGovtBondApi() async {
    try {
      final uri = Uri.parse(apiLinks.getGSec);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      // log("Govt Bond ==>$json");

      return GovtBonds.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<TreasuryBonds> getTreasuryBondApi() async {
    try {
      final uri = Uri.parse(apiLinks.getTBill);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      // log("T-Bill ==>$json");

      return TreasuryBonds.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<StateBonds> getStateBondApi() async {
    try {
      final uri = Uri.parse(apiLinks.getSDL);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      // log("State Bond ==>$json");

      return StateBonds.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<SovereignGoldBonds> getGoldBondApi() async {
    try {
      final uri = Uri.parse(apiLinks.getSGB);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      // log("Gold Bond==>$json");

      return SovereignGoldBonds.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<LedgerBalModel> getLedgerBalApi() async {
    try {
      final uri = Uri.parse(apiLinks.getLedgerBal);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"clientid": "${prefs.clientId}"}));

      final json = jsonDecode((res.body));

      // log("Govt Bond ==>$json");

      return LedgerBalModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BondsOrderBookModel>> getBondsOrderBookApi() async {
    try {
      final uri = Uri.parse(apiLinks.getOrderBook);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"client_id": "${prefs.clientId}"}));
          // print("getBondsOrderBookApi  ::  ${res.body}");
      final List json = jsonDecode((res.body))["orderbook"];//.containsKey("msg") && jsonDecode((res.body))["msg"]=="orders not found" ? []:jsonDecode((res.body));

      return json.map(
        (data) {
          //  print("MAP ERROR $e");
          return BondsOrderBookModel.fromJson(data as Map<String, dynamic>);
        },
      ).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PlacedBondOrderResp> placeBondOrderApi(
      String symbol, int investmentValue, int price) async {
    try {
      final uri = Uri.parse(apiLinks.placeBondOrder);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "requestfor": "BUY",
            "symbol": symbol,
            "investmentValue": investmentValue,
            "price": price
          }));
      final json = jsonDecode((res.body));
        // print(" placeBondOrderApi Response ::: $json");
      // log("Gold Bond==>$json");

      return PlacedBondOrderResp.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }


  Future<PlacedBondOrderResp> cancelBondOrderApi(
      String symbol, String investmentValue, int price,String clientApplicationNumber,String orderNumber) async {
    try {
      final uri = Uri.parse(apiLinks.placeBondOrder);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "clientApplicationNumber":clientApplicationNumber,
            "orderNumber":orderNumber,
            "requestfor": "REMOVE",
            "symbol": symbol,
            "investmentValue": investmentValue,
            "price": price
          }));
      final json = jsonDecode((res.body));
        // print(" cancelBondOrderApi Response  ::: $json");
      // log("Gold Bond==>$json");

      return PlacedBondOrderResp.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}