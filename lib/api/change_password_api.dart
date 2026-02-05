import 'package:crypto/crypto.dart';

import 'core/api_core.dart';
import '../models/auth_model/mynt_changepass_model.dart';
 

mixin ChangePasswordApi on ApiCore {
   

  Future<MyntChangePasswordModel> getChangePasswordProfile(
      String userId, String oldpassword, String password) async {
    var enCodePass = utf8.encode(oldpassword);
    var sha256Pass = sha256.convert(enCodePass);
 
    try {
      final uri = Uri.parse(apiLinks.myntchangePassword);
      final res = await apiClient.post(uri,
          headers: {'Content-Type': 'text/plain'},
          body: 'jData=${jsonEncode({"uid": userId, "oldpwd": "$sha256Pass", "pwd": password})}');

      // log("change Password => ${res.body}");
      final json = jsonDecode(res.body);

      return MyntChangePasswordModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      // print(e);
      rethrow;
    }
  }
}
