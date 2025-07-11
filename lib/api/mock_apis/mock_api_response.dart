 

 

import 'package:flutter/services.dart';
import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/models/order_book_model/place_order_model.dart';
import 'package:mynt_plus/models/portfolio_model/position_book_model.dart';

import '../../models/json_model/strategy_model.dart';
import '../core/api_core.dart';

mixin MockApiResponse on ApiCore {

// Get json datas from asstes

  Future<StrategyJosnModel> getStrategyJson() async {
    try {
      final resp = await rootBundle.loadString("assets/mock_json/strategy.json");

      final json = jsonDecode(resp);

      // log("Strategy model =>  $json");
      return StrategyJosnModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }


    Future<Map<String, dynamic>> mockOrderBookResponse() async {
    try {
      final resp = await rootBundle.loadString("assets/mock_json/mockOrderBook.json");

      final json = jsonDecode(resp);
      final List<OrderBookModel> data = [];
      // log("Strategy model =>  $json");
      for (final item in json) {
              data.add(OrderBookModel.fromJson(item as Map<String, dynamic>));
            }
      return ({'stat': 'success', 'data': data});
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> mockPositionBookResponse() async {
    try {
      final resp = await rootBundle.loadString("assets/mock_json/mockPositionBook.json");

      final json = jsonDecode(resp);
      final List<PositionBookModel> data = [];
      // log("Strategy model =>  $json");
      for (final item in json) {
              data.add(
                  PositionBookModel.fromJson(item as Map<String, dynamic>));
            }
      return ({'stat': 'success', 'data': data});
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> mockPlaceSliceOrderResponse() async {
    try {
      final resp = await rootBundle.loadString("assets/mock_json/mockPlaceSliceOrderResp.json");
      final json = jsonDecode(resp);
      final List<PlaceOrderModel> data = [];
      for (final item in json) {
        data.add(PlaceOrderModel.fromJson(item as Map<String, dynamic>));
      }
      return ({'stat': 'success', 'data': data});
    } catch (e) {
      rethrow;
    }
  }
}
