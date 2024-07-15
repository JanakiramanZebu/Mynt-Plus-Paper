import '../models/indices/global_indices_model.dart';
import '../models/news_model.dart';
import '../models/stocks_model/toplist_stocks.dart';
import 'core/api_core.dart';

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
}
