import 'dart:developer';

import '../models/auth_model/totp_model.dart';
import '../models/profile_model/apikeymodel.dart';
import '../models/profile_model/generateapikey_model.dart';
import 'core/api_core.dart';

mixin GenerateApiKey on ApiCore {
// Get API key from kambala

  Future<Apikeymodel> getapikey() async {
    try {
      final uri = Uri.parse(apiLinks.apiKey);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');

      final json = jsonDecode(res.body);

      return Apikeymodel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Get REgenerate API key from kambala
  Future<GenerateApikeyModel> regenerateapikey(String month) async {
    try {
      final uri = Uri.parse(apiLinks.generateapiKey);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}", "valTime":"$month"}&jKey=${prefs.clientSession}''');

      final json = jsonDecode(res.body);

      return GenerateApikeyModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// get totp
  Future<TotpKey> getTotp() async {
    try {
      final uri = Uri.parse(apiLinks.totp);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
      //final json = jsonDecode(res.body);
      Map<String, dynamic> jsonResponse = jsonDecode(res.body);

      log("Logout Model => $jsonResponse");
      return TotpKey.fromJson(jsonResponse);
    } catch (e) {
      rethrow;
    }
  }
}
