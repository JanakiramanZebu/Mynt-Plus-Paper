// import 'dart:developer';

import '../models/profile_model/client_detail_model.dart';
import '../models/profile_model/qr_login_res.dart';
import '../models/profile_model/user_detail_model.dart';
import 'core/api_core.dart';
import 'package:http/http.dart';

mixin UserProfileAPI on ApiCore {
  Future<UserDetailModel> getUserDetail() async {
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

  Future<QrLoginResponces> getqr(String uniqueid , String loginsrc) async {
    try {
      final uri = Uri.parse(apiLinks.getQrScanner);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "unique_id": uniqueid,
            "clientid": "${prefs.clientId}",
            "apitoken": "${prefs.clientSession}",
            "source": "MOB",
            "login_source": loginsrc
          }));

      final json = jsonDecode(res.body);
      print(json);
      return QrLoginResponces.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getaFreezeAc() async {
    try {
      final uri = Uri.parse(apiLinks.freezeAccount);
      final response = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}","actid":"${prefs.clientId}" ,"type":"1"}&jKey=${prefs.clientSession}''');

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getaBlockAc() async {
    try {
      final uri = Uri.parse(apiLinks.blockAcct);
      final response = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
