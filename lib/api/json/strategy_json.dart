 

 

import 'package:flutter/services.dart';

import '../../models/json_model/strategy_model.dart';
import '../core/api_core.dart';

mixin StrategyJson on ApiCore {
  Future<StrategyJosnModel> getStrategyJson() async {
    try {
      final resp = await rootBundle.loadString("assets/json/strategy.json");

      final json = jsonDecode(resp);

      // log("Strategy model =>  $json");
      return StrategyJosnModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
