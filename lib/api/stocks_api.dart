// ignore_for_file: unused_import
// removed unused import

import 'package:mynt_plus/models/explore_model/basket_backtest_analysis_model.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/models/strategy_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';

import '../models/explore_model/ca_events_model.dart';
import '../models/explore_model/portfolioanalisys_models.dart';
import '../models/explore_model/referral_rewards_model.dart';
import '../models/explore_model/stocks_model/corporate_action_model.dart';
import '../models/explore_model/stocks_model/get_ad_indices.dart';
import '../models/explore_model/stocks_model/sector_thematric_detail_model.dart';
import '../models/explore_model/stocks_model/stock_monitor_model.dart';
import '../models/indices/global_indices_model.dart';
import '../models/news_model.dart';
import '../models/explore_model/stocks_model/toplist_stocks.dart';
import '../models/marketwatch_model/search_scrip_model.dart';
import '../models/span_calc_model.dart';
import 'core/api_core.dart';
import 'package:http/http.dart';

mixin StocksAPI on ApiCore {
  Future< NewsModel> fetchNews(String date) async {
 
    try {
      final uri = Uri.parse("https://sess.mynt.in/newsfeedin?pagesize=48&pagecount=1&filterdate=day");

      final res = await apiClient.get(uri,
          headers: defaultHeaders );

      final json = jsonDecode(res.body);
        
     return NewsModel.fromJson(json as Map<String, dynamic>);
      } catch (e) {
       rethrow;
    }

   
  }
  Future< PortfolioResponse> fetchPortfolioAnalysis(String clientId, String session) async {
 
    try {
      final uri = Uri.parse('${apiLinks.portfolioAnalysisURL}?client_id=$clientId&session=$session');
      final res = await apiClient.get(uri);
      final json = jsonDecode(res.body);
      if(json['stat'] == 'Not_Ok'){
        return PortfolioResponse(
          xirrResult: 0.0,
          accountAllocation: {},
          marketCapAllocation: {},
          sectorAllocation: {},
          topStocks: [],
          fundamentals: [],
          chartData: null,
          message: "No data found",
        );
      }
        
     return PortfolioResponse.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        print("Portfolio Analysis Error: $e");
       rethrow;
    }

   
  }
  Future<ReferralRewards> fetchReferralBonus(String clientId) async {
    try {
      final uri = Uri.parse(apiLinks.referralBonusURL);
      final res = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode({"client_id": clientId}));
      final json = jsonDecode(res.body);
      return ReferralRewards.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
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

  Future<StrategyResponse> createStrategy(StrategyRequest request) async {
    try {
      final response = await apiClient.post(
        Uri.parse('http://192.168.5.119:8002/client/create_strategy'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print("response Strategy :::::: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StrategyResponse(
          success: true,
          message: 'Strategy created successfully',
          data: responseData,
        );
      } else {
        return StrategyResponse(
          success: false,
          message: 'Failed to create strategy: ${response.statusCode}',
        );
      }
    } catch (e) {
      return StrategyResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  Future<StrategyList> getStrategyList() async {
    try {
      final response = await apiClient.post(Uri.parse('http://192.168.5.119:8002/client/get_strategies'),
      headers: defaultHeaders,
      body: jsonEncode({"uid": "ZP00285"}));
          
      final json = jsonDecode(response.body);

      print("Strategy List: $json");

      return StrategyList.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      print("Strategy List Error: $e");
      rethrow;
    }
  }

  String _deploymessage = "";
  // String get deployMessage => _deploymessage;

  Future<String> deployStrategy(String strategyId) async {
    try {
      final response = await apiClient.post(Uri.parse('http://192.168.5.119:8002/client/StrategyDeploy'),
      headers: defaultHeaders,
      body: jsonEncode({"uid": "ZP00285", "strategyid": strategyId}));
          
      final json = jsonDecode(response.body);

      print("Strategy List: $json");

      return _deploymessage = "Strategy deployed successfully";
    } catch (e) {
      print("Strategy List Error: $e");
      rethrow;
    }
  }

  

  Future<Map<String, String>> getStrikePrice(String symbol, String expiry) async {
    // Simulate API call for strike prices
    try {

      final response = await apiClient.get(Uri.parse('http://192.168.5.119:8002/client/Symbols'));
          
      final json = jsonDecode(response.body);

      return json;

      print("Strategy List: $json");
    } catch (e) {
      print("Strategy List Error: $e");
      rethrow;
    }
    // return {
    //   'ATM': '56900',
    //   'ITM': '56800',
    //   'OTM': '57000',
    // };
  }

  Future<List<String>> getExpiryDates(String symbol) async {
    // Simulate API call for expiry dates
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      '28-AUG-2025',
      '04-SEP-2025',
      '11-SEP-2025',
      '18-SEP-2025',
    ];
  }


  Future<List<SectorThematicDetailModel>> getadindices(String indexName) async {
    try {
      final uri = Uri.parse(apiLinks.getadindices);
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode({"index": indexName}));

      final json = jsonDecode(res.body);

      // log("Trade Action data ${res.body}");
      final List<SectorThematicDetailModel> data = [];

      for (final item in json) {
        data.add(
            SectorThematicDetailModel.fromJson(item as Map<String, dynamic>));
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<GetAdIndicesModel> getAllAdindices() async {
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


  Future<CAevents> getCAeventsdata() async {
    try {
      final uri = Uri.parse(apiLinks.getCAevents);
      final response = await apiClient
          .post(uri, headers: {'Content-Type': 'application/json'});

      //  print("Top Indices Data ${response.body}");
      final json = jsonDecode(response.body);
      return CAevents.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StockMoniterModel>> getStockMonitor(
      String exch, String bskt, String cont) async {
    try {
      final uri = Uri.parse(apiLinks.getStockMonitor);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"exch": exch, "basket": bskt, "condition": cont}));
      //  log("Stock Monitor=>${res.body} ");
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
              data.add(
                  StockMoniterModel.fromJson(item as Map<String, dynamic>));
            }
          }
        } catch (e) {
          if (res.statusCode == 200) {
            for (final item in json) {
              data.add(
                  StockMoniterModel.fromJson(item as Map<String, dynamic>));
            }
          }
        }
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<SearchScripModel> searchScrip(String searchText, {List<String> filters = const ["NFO", "BFO"]}) async {
    try {
      final uri = Uri.parse("https://be.mynt.in/global/SearchScrip");
      
      final body = '''jData={"uid":"","stext":"$searchText","fil":["NFO","BFO"]}&jKey=''';


      final res = await apiClient.post(uri,
          headers: {'Content-Type': 'text/plain'},
          body: body);

          final json = jsonDecode(res.body);
      return SearchScripModel.fromJson(json as Map<String, dynamic>);

        // return res.body;

     
    } catch (e) {
      print("Search Scrip Error: $e");
      rethrow;
    }
  }

  /// SpanCalc - calculates SPAN and Exposure margins for a list of positions
  Future<SpanCalcResponse> spanCalc({required String actid, required List<SpanCalcPositionItem> positions}) async {
    try {
      final uri = Uri.parse(apiLinks.spanCalc);
      final payload = {
        "actid": "DEMOIT",
        "pos": positions.map((e) => e.toJson()).toList(),
      };

      print("SpanCalc payload: ${positions.map((e) => e.toJson()).toList()}");

      // final String jKey = (prefs.clientSession != null && prefs.clientSession!.isNotEmpty)
      //     ? '&jKey=${prefs.clientSession}'
      //     : '';
      final body = 'jData=${jsonEncode(payload)}';

      final res = await apiClient.post(uri,
          headers: {'Content-Type': 'text/plain'},
          body: body);

      final json = jsonDecode(res.body);
      print("SpanCalc response: ${res.body}");
      return SpanCalcResponse.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      print("SpanCalc Error: $e");
      rethrow;
    }
  }

 Future<SavedStrategyModel> fetchbasketlist() async {
    try {
      final uri = Uri.parse(apiLinks.mfbasketanalysis);
      final payload = {
        "client_id": prefs.clientId,
        "type_in": "get",
      };
      final res = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode(payload));
      final json = jsonDecode(res.body);
      print("fetchbasketlist response: ${res.body}");
      return SavedStrategyModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      print("fetchbasketlist Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createbasketsStrategy({
    required int yearIn,
    required List<Map<String, dynamic>> schemeValues,
    required String basketName,
    String compareSymbol = "NSE:NIFTYBEES-EQ",
    required double investmentAmount,
    required String invesmentdetail,
  }) async {
    try {
      final uri = Uri.parse(apiLinks.mfbasketanalysis);
      
      final payload = {
        "client_id": prefs.clientId,
        "type_in": "add",
        "name": basketName,
        "years_in": yearIn,
        "schema_values": schemeValues,
        "compare_symbol": compareSymbol,
        "invest_amount":investmentAmount,
        "investment_details":invesmentdetail,
      };
      
      print("=== CREATE STRATEGY ===");
      print("Create payload: ${jsonEncode(payload)}");
      final res = await apiClient.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(payload),
      );
      final json = jsonDecode(res.body);
      print("Create response status: ${res.statusCode}");
      print("Create response body: ${res.body}");
      return json;
    } catch (e) {
      print("createbasketsStrategy Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatebasketsStrategy({
    required String uuid,
    required int yearIn,
    required List<Map<String, dynamic>> schemeValues,
    required String basketName,
    String compareSymbol = "NSE:NIFTYBEES-EQ",
    required double investmentAmount,
    required String invesmentdetail,
  }) async {
    try {
      final uri = Uri.parse(apiLinks.mfbasketanalysis);
      
      final payload = {
        "client_id": prefs.clientId,
        "type_in": "update",
        "id": uuid,
        "name": basketName,
        "years_in": yearIn,
        "schema_values": schemeValues,
        "compare_symbol": compareSymbol,
        "invest_amount": investmentAmount,
        "investment_details": invesmentdetail,
      };
      
      final res = await apiClient.post(
        uri, 
        headers: defaultHeaders,
        body: jsonEncode(payload),
      );
      
      final json = jsonDecode(res.body);
      print("updatebasketsStrategy response: ${res.body}");
      return json;

    } catch (e) {
      print("updatebasketsStrategy Error: $e");
      rethrow;
    }
  }

  Future<Response> deletebasketsStrategy(String uuid) async {
    try {
     final uri = Uri.parse(apiLinks.mfbasketanalysis);
      final res = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode({"client_id": prefs.clientId, "type_in": "remove", "id": uuid}));
      return res;
    } catch (e) {
      print("deletebasketsStrategy Error: $e");
      rethrow;
    }
    }

    // Perform backtest analysis
  Future<PortfolioAnalysisModel?> performBacktest(BacktestRequest request, String uuid) async {
  try {
    final payload = {
      "client_id": prefs.clientId,
      "type_in": "backtest",
      "id": uuid,
      "year_in": request.yearIn,
      "investment_amount": request.investmentAmount,
      "scheme_values": request.schemeValues.map((s) => {
            "name": s.name,
            "schema_name": s.schemaName,
            "percentage": s.percentage,
            "isin": s.isin,
            "scheme_type": s.schemeType,
          }).toList(),
      "compare_symbol": request.compareSymbol,
    };

   

    final response = await apiClient.post(
      Uri.parse("https://r3ljq6dl-8005.inc1.devtunnels.ms/collections/portfolio_analysis"),
      headers: defaultHeaders,
      body: jsonEncode(payload),
    );

    print("Backtest API Response Status: ${response.statusCode}");
    print("Backtest API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        return PortfolioAnalysisModel.fromJson(jsonData as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    } else {
      print("Backtest API Error: ${response.statusCode} ${response.body}");
      return null;
    }
  } catch (e) {
    print("performBacktest Exception: $e");
    rethrow;
  }
}

}
