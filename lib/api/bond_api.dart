// import 'dart:developer';

import 'dart:developer';

import '../api/core/api_core.dart';
import '../models/bonds_data/govt_bonds.dart';
import '../models/bonds_data/ledger_bal_model.dart';
import '../models/bonds_data/sovereign_gold_bonds.dart';
import '../models/bonds_data/state_bond.dart';
import '../models/bonds_data/treasury_bonds.dart';

mixin BondApi on ApiCore {
  Future<GovtBond> getGovtBond() async {
    try {
      final uri = Uri.parse(apiLinks.getGSec);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      // log("Govt Bond ==>$json");

      return GovtBond.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<TreasuryBond> getTreasuryBond() async {
    try {
      final uri = Uri.parse(apiLinks.getTBill);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      // log("T-Bill ==>$json");

      return TreasuryBond.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<StateBonds> getStateBond() async {
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

  Future<SovereignGoldBonds> getGoldBond() async {
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

  Future<LedgerBalModel> getLedgerBal() async {
    try {
      final uri = Uri.parse(apiLinks.getLedgerBal);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"clientid": "${prefs.clientId}"}));

      final json = jsonDecode((res.body));

      log("Govt Bond ==>$json");

      return LedgerBalModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
