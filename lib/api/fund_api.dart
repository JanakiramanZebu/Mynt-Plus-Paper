import '../models/mf_model/mf_bank_detail_model.dart';
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

  Future<VerifyUPIModel> getVerifyUpi(String upiId, String accno) async {
    try {
      final uri = Uri.parse(apiLinks.verifyUPI);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "VPA": upiId,
            "clientID": "${prefs.clientId}",
            "bank_acc": accno
          }));
      final json = jsonDecode(res.body);
      // log("HDFC STATUS => ${res.body}");
      final upivalidation = VerifyUPIModel.fromJson(json);
      return upivalidation;
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

  Future<BankDetailsModel> getBankDetail() async {
    try {
      final uri = Uri.parse(apiLinks.bankDetail);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"client_code": "${prefs.clientId}"}));

      final json = jsonDecode((res.body));

      //  print("Bank Details => $json");

      return BankDetailsModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<UPIDetailsModel> getUPI() async {
    try {
      final uri = Uri.parse("https://fundapi.mynt.in/withdraw/view_upi_id");

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"client_id": "${prefs.clientId}"}));

      final json = jsonDecode((res.body));

      //  print("UPI Details => $json");

      return UPIDetailsModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
