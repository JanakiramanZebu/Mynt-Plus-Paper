import 'dart:developer';

import '../models/auth_model/totp_model.dart';
import '../models/profile_model/apikeymodel.dart';
import '../models/profile_model/generateapikey_model.dart';
import '../models/profile_model/generatenewapikey_model.dart';
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
Future<GenerateApikeyModel> generateapikeynewuser(String month) async {
    try {
      final uri = Uri.parse(apiLinks.generateapiKeynewuser);
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

  Future<GenerateNewApiKeyModel> getapikeynew() async {
    try {
      final uri = Uri.parse(apiLinks.getapikeynew);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"app_key":"ZP00180"}&jKey=4e87ce5848fd2087b2da0be90d6490935c8d528b7ab0a833fbfa8afa566b160e''');
              
      print('getapikeynew response: ${res.body}');
      final json = jsonDecode(res.body);
      return GenerateNewApiKeyModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<GenerateNewApiKeyModel> submitApiKeyNew({
    required String appKey,
    required String secretCode,
    required String redirectUrl,
    required String displayName,
    required List<String> ipAddresses,
    required List<String> userIds,
  }) async {
    try {
      final uri = Uri.parse(apiLinks.appkeystore);

      final jDataMap = {
        'app_key': appKey,
        'sec_code': secretCode,
        'red_url': redirectUrl,
        'dname': displayName,
        'ipaddr': ipAddresses.map((e) => {'ipaddr': e}).toList(),
        'uid': userIds.map((e) => {'uid': e}).toList(),
      };

      const sessionKey = '4e87ce5848fd2087b2da0be90d6490935c8d528b7ab0a833fbfa8afa566b160e';
      final body = 'jData=' + jsonEncode(jDataMap) + '&jKey=' + sessionKey;

      print('=== AppKeyStore REQUEST === $body');
      final res = await apiClient.post(
        uri,
        headers: defaultHeaders,
        body: body,
      );

      print('=== AppKeyStore RESPONSE === Status Code: ${res.statusCode} | Response: ${res.body}');
      
      if (res.statusCode != 200) {
        throw Exception('API call failed with status ${res.statusCode}: ${res.body}');
      }
      
      final json = jsonDecode(res.body);
      return GenerateNewApiKeyModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<GenerateApikeyModel> regenerateapikey(String month) async {
    try {
      final uri = Uri.parse(apiLinks.generateapiKey);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}", "valTime":"$month"}&jKey=${prefs.clientSession}''');
      print((res.body));
      final json = jsonDecode(res.body);

      return GenerateApikeyModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// get totp
  Future<TotpKey> getTotp(bool apiurl) async {
    try {
      final uri = Uri.parse(apiurl ? apiLinks.gentotp : apiLinks.gettotp);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}"}&jKey=${prefs.clientSession}''');
      //final json = jsonDecode(res.body);
      Map<String, dynamic> jsonResponse = jsonDecode(res.body);

      log("totp Model => $jsonResponse");
      return TotpKey.fromJson(jsonResponse);
    } catch (e) {
      rethrow;
    }
  }
}
