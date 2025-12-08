// import 'dart:developer';

import 'dart:convert';
import 'dart:io';

import '../models/profile_model/algo_strategy_model.dart';
import '../models/profile_model/client_detail_model.dart';
import '../models/profile_model/qr_login_res.dart';
import '../models/profile_model/user_detail_model.dart';
import '../models/profile_model/create_algo_strategy_request_model.dart';
import 'core/api_core.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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

  Future<List<AlgoStrategyModel>> getAlgoStrategy() async {
    try {
      final uri = Uri.parse(apiLinks.algoStrategy);
      final response = await apiClient.post(uri, 
          headers: defaultHeaders,
          body: jsonEncode({"clientid": 'ZP00285'}));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        // Handle both single object and array responses
        if (json is List) {
          return json.map((item) => AlgoStrategyModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (json is Map<String, dynamic>) {
          // If it's a single object, wrap it in a list
          return [AlgoStrategyModel.fromJson(json)];
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load algo strategies: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createAlgoStrategy({
    required CreateAlgoStrategyRequestModel requestData,
    required PlatformFile file,
  }) async {
    try {
      final uri = Uri.parse(apiLinks.createAlgoStrategy);
      
      var request = http.MultipartRequest('POST', uri);
      
      // Add text fields
      request.fields['algorithm_name'] = requestData.algorithmName;
      request.fields['submitted_by'] = requestData.submittedBy;
      request.fields['type'] = requestData.type;
      request.fields['category'] = requestData.category;
      request.fields['risk_level'] = requestData.riskLevel;
      request.fields['description'] = requestData.description;
      request.fields['logic_description'] = requestData.logicDescription;
      request.fields['code_lang'] = requestData.codeLang ?? '';
      
      // Add file with null safety check
      if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      } else {
        throw Exception('File bytes are null - file may not have been properly selected');
      }
      
      for (int i = 0; i < request.files.length; i++) {
        print("    File $i: ${request.files[i].field} - ${request.files[i].filename} (${request.files[i].length} bytes)");
      }
      
      print("📡 Sending request...");
      final streamedResponse = await apiClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to create algo strategy: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<Map<String, dynamic>> updateAlgoStrategy({
    required CreateAlgoStrategyRequestModel requestData,
    PlatformFile? file,
    required String submissionId,
    required String algoId,
  }) async {
    try {
      final uri = Uri.parse(apiLinks.updateAlgoStrategy);
      
      var request = http.MultipartRequest('POST', uri);
      
      // Add text fields
      request.fields['submission_id'] = submissionId;
      request.fields['algo_id'] = algoId;
      request.fields['algorithm_name'] = requestData.algorithmName;
      request.fields['submitted_by'] = requestData.submittedBy;
      request.fields['type'] = requestData.type;
      request.fields['category'] = requestData.category;
      request.fields['risk_level'] = requestData.riskLevel;
      request.fields['description'] = requestData.description;
      request.fields['logic_description'] = requestData.logicDescription;
      request.fields['code_lang'] = requestData.codeLang ?? '';
      
      // Add file with null safety check (optional in update)
      if (file != null && file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      }
      
      // Print raw request details
      print("🔍 RAW UPDATE REQUEST DETAILS:");
      print("  URL: ${request.url}");
      print("  Method: ${request.method}");
      print("  Headers: ${request.headers}");
      print("  Fields: ${request.fields}");
      print("  Files count: ${request.files.length}");
      for (int i = 0; i < request.files.length; i++) {
        print("    File $i: ${request.files[i].field} - ${request.files[i].filename} (${request.files[i].length} bytes)");
      }
      
      print("📡 Sending update request...");
      final streamedResponse = await apiClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      print("📥 RAW UPDATE RESPONSE RECEIVED:");
      print("  Status Code: ${response.statusCode}");
      print("  Status Message: ${response.reasonPhrase}");
      print("  Headers: ${response.headers}");
      print("  Content Length: ${response.contentLength}");
      print("  Body (Raw): ${response.body}");
      print("  Body Length: ${response.body.length} characters");
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("✅ Parsed Update Response: $responseData");
        return responseData;
      } else {
        print("❌ Error Update Response: ${response.body}");
        throw Exception('Failed to update algo strategy: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteAlgoStrategy(String submissionId, String algoId) async {
    try {
      final uri = Uri.parse(apiLinks.deleteAlgoStrategy);
      final response = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode({"algo_id": algoId}));
      return jsonDecode(response.body);
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
      // print("error in get profile image ${e}");
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
