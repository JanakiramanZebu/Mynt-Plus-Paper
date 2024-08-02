import '../models/fund_model/show_upi_model.dart';
import '../models/fund_model/upivalidation_model.dart';
import '../models/profile_model/fund_detial_model.dart';
import '../models/profile_model/hs_token_model.dart';
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
  Future<UpiIdValidationModel> getupiidvalidation(
      String upiId,  String accno) async {
    try {
      final uri = Uri.parse(apiLinks.hdfcupicheck);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode(
              {"VPA": upiId, "clientID": "${prefs.clientId}", "bank_acc": accno}));
      final json = jsonDecode(res.body);
      // log("HDFC STATUS => ${res.body}");
      final upivalidation = UpiIdValidationModel.fromJson(json);
      return upivalidation;
    } catch (e) {
      rethrow;
    }
  }

   Future<ViewUpiIdModel> getviewupiid() async {
    try {
      final uri = Uri.parse(apiLinks.viewupiid);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"client_id": "${prefs.clientId}"}));
      final json = jsonDecode(res.body);
      print("view upi id => ${res.body}");
      final viewupiid = ViewUpiIdModel.fromJson(json);
      return viewupiid;
    } catch (e) {
      rethrow;
    }
  }
  
}
