import '../models/version_model/version_mod.dart';
import 'core/api_core.dart';

mixin VersionApi on ApiCore {
  Future<VersionModel> getVersionApi() async {
    try {
      final uri =
          Uri.parse("https://sess.mynt.in/strapi/appversion?fields=version");
      final response = await apiClient
          .get(uri, headers: {'Content-Type': 'application/json'});

      //  print("Top Indices Data ${response.body}");
      final json = jsonDecode(response.body);
      print("version ${json}");
      return VersionModel.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }
}
