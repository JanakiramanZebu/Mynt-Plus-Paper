// import 'dart:developer';

import 'dart:io';

import '../models/profile_model/client_detail_model.dart';
import '../models/profile_model/qr_login_res.dart';
import '../models/profile_model/user_detail_model.dart';
import 'core/api_core.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

mixin UserProfileAPI on ApiCore {
// get user details from kambala

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

// get client details from kambala

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

// QR Login to web
  Future<QrLoginResponces> getqr(String uniqueid, String loginsrc) async {
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

// get Freez client account from kambala

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

  Future getProfileImage() async {
    try {
      final uri = Uri.parse("https://v3.mynt.in/dd/profile/get_profile_image?client_id=${prefs.clientId}");
      final response = await apiClient.get(uri);
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      print("error in get profile image ${e}");
      rethrow;
    }
  }

Future uploadImage(File imageFile) async {
  try {
    final uri = Uri.parse("https://v3.mynt.in/dd/profile/update_image");

    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(defaultHeaders);

    request.fields['client_id'] = prefs.clientId!; // string

    request.files.add(await http.MultipartFile.fromPath(
      'image',               
      imageFile.path,
    ));

    final streamedResponse = await apiClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);
     if (response.statusCode == 200) {
        return jsonDecode(response.body);

      } else {
        return {'data': 'ServerSide error'};
      }
    } catch (e) {
      print("error in upload image ${e}");
      rethrow;
    }
}

Future removeProfileImage() async {
  try {
    final uri = Uri.parse("https://v3.mynt.in/dd/profile/remove_image?client_id=${prefs.clientId}");
    final response = await apiClient.get(uri);
    return response;
  } catch (e) {
    rethrow;
  }
}


// get block client account from kambala

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
