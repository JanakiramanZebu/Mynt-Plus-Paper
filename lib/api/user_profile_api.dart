import '../models/profile_model/client_detail_model.dart';
import '../models/profile_model/user_detail_model.dart';
import 'core/api_core.dart';

mixin UserProfileAPI on ApiCore {
  Future<UserDetailModel> getUserDetail(String ueserId, String session) async {
    try {
      final uri = Uri.parse(apiLinks.userDetail);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');

      // log("UserDetails => ${res.body}");

      final json = jsonDecode(res.body);

      return UserDetailModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<ClientDetailModel> getClientDetail() async {
    try {
      final uri = Uri.parse(apiLinks.clientDetail);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');

      // log("ClientDetails => ${res.body}");
      final json = jsonDecode(res.body);

      return ClientDetailModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
