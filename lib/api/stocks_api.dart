 

 

import 'dart:developer';

import '../models/explore_model/stocks_model/corporate_action_model.dart'; 
import '../models/explore_model/stocks_model/get_ad_indices.dart';
import '../models/explore_model/stocks_model/sector_thematric_detail_model.dart';
import '../models/explore_model/stocks_model/stock_monitor_model.dart';
import '../models/indices/global_indices_model.dart';
import '../models/news_model.dart';
import '../models/explore_model/stocks_model/toplist_stocks.dart';
import 'core/api_core.dart';
import 'package:http/http.dart';

mixin StocksAPI on ApiCore {
  Future<List<NewsModel>> fetchNews(String date) async {
    final List<NewsModel> data = [];
    try {
      final uri = Uri.parse(apiLinks.newsurl);

      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: json.encode({"date": date}));

      final newsRes = jsonDecode(res.body);
      if (newsRes[0] == []) {
        final NewsModel news = NewsModel.fromJson(json as Map<String, dynamic>);
        return [news];
      } else {
        for (int j = 0; j < newsRes.length; j++) {
          data.add(NewsModel.fromJson(newsRes[j] as Map<String, dynamic>));
        }
      }
    } catch (e) {
      rethrow;
    }

    return data;
  }

  Future<List<GlobalIndicesModel>> fetchGlobalIndices() async {
    try {
      final uri = Uri.parse(apiLinks.getGlobalIndex);
      final res = await apiClient.post(uri);
      final json = jsonDecode(res.body);

      final List<GlobalIndicesModel> data = [];

      for (final item in json) {
        data.add(GlobalIndicesModel.fromJson(item as Map<String, dynamic>));
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<TopListStocks> getTradeAction(
      String exch, String bskt, String crt) async {
    try {
      final uri = Uri.parse(apiLinks.topListStock);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"exch": exch, "bskt": bskt, "crt": crt}));

      final json = jsonDecode(res.body);

      // log("Trade Action data ${res.body}");

      return TopListStocks.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getadindicesAdvdec(String indexName) async {
    try {
      final uri = Uri.parse(apiLinks.getadindicesAdvdec);
      final response = await apiClient.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"index": indexName}));

      

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future< List< SectorThematicDetailModel>> getadindices(String indexName) async {
    try {
      final uri = Uri.parse(apiLinks.getadindices);
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode({"index": indexName}));

      final json = jsonDecode(res.body);

      // log("Trade Action data ${res.body}");
      final List< SectorThematicDetailModel> data = [];

      for (final item in json) {
              data.add(SectorThematicDetailModel.fromJson(item as Map<String, dynamic>));
            }

      return data;
    } catch (e) {
      rethrow;
    }
  }

    Future< GetAdIndicesModel> getAllAdindices( ) async {
    try {
      final uri = Uri.parse(apiLinks.getadindices);
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode({"index": ""}));

      final json = jsonDecode(res.body);
    // log("ALL INDICES ${res.body}");
 

      return GetAdIndicesModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<CorporateActionModel> getCorporateAction() async {
    try {
      final uri = Uri.parse(apiLinks.getCorporateAction);
      final response = await apiClient
          .post(uri, headers: {'Content-Type': 'application/json'});

    //  print("Top Indices Data ${response.body}");
      final json = jsonDecode(response.body);
      return CorporateActionModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }


  Future<List<StockMoniterModel>> getStockMonitor() async {
    try {
      final uri = Uri.parse(apiLinks.getStockMonitor);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:  jsonEncode({"exch": "NSE", "basket": "NIFTY50", "condition": "VolUpPriceDown"}));
           log("Stock Monitor=>${res.body} ");
      final List<StockMoniterModel> data = [];
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        try {
          if (json['stat'] == 'Not_Ok') {
            final StockMoniterModel ord =
               StockMoniterModel.fromJson(json as Map<String, dynamic>);
            return [ord];
          } else {
            for (final item in json) {
              data.add(StockMoniterModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(StockMoniterModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
