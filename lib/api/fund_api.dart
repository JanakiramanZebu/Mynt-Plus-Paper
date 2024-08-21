import '../models/profile_model/fund_detial_model.dart';
import '../models/profile_model/hs_token_model.dart';
import '../models/profile_model/option_z_model.dart';
import 'core/api_core.dart';

mixin FundApi on ApiCore {
  Future<GetHsTokenModel> getHsToken() async {
    try {
      final uri = Uri.parse(apiLinks.getHsToken);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
      final json = jsonDecode(res.body);

      final fundHstoken = GetHsTokenModel.fromJson(json);

      return fundHstoken;
    } catch (e) {
      rethrow;
    }
  }

  Future<FundDetailModel> getFunds() async {
    try {
      final uri = Uri.parse(apiLinks.getlimits);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');

      final json = jsonDecode(res.body);
      // print(res.body);

      return FundDetailModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<OptionZmodel> getaOptionZ(String key) async {
    try {
      final uri = Uri.parse(
          "https://sess.mynt.in/OAuthMobile?vc=instaoptions&key=$key");
      final response = await apiClient.post(uri, headers: defaultHeaders);
      final json = jsonDecode(response.body);
      return OptionZmodel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
