import 'dart:developer';

import '../api/core/api_core.dart';
import '../models/bonds_data/gold_bond.dart';
import '../models/bonds_data/gsec.dart'; 

mixin BondApi on ApiCore {
  Future<Gsecdata> fetchGsecdata() async {
    try {
      final uri = Uri.parse(apiLinks.gsecdetails);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      log("G.SEC_DATA==>$json");

      return Gsecdata.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Goldbondmodel> fetchGoldbond() async {
    try {
      final uri = Uri.parse(apiLinks.goldbonddetails);
      final res = await apiClient.post(uri);
      final json = jsonDecode((res.body));

      log("gold_bond==>$json");

      return Goldbondmodel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
