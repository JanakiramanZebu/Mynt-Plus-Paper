import 'package:mynt_plus/models/client_profile_all_details/details_change_current_status_model.dart';
import 'package:mynt_plus/models/client_profile_all_details/profile_all_details_model.dart';
import 'package:mynt_plus/screens/profile_screen/profile_main_screen.dart';
import 'package:mynt_plus/sharedWidget/fund_function.dart';
import '../api/core/api_core.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String globalcurrmail = '';
String globalNewEmail = '';
String globaldpcode = '';
var globalfulldata;
String globalnewmob = '';

String globalIfscResponse = '';

final profileres = ProviderContainer().read(transcationProvider);
var profileres2 = profileres;

mixin ProfileAllDetailsApi on ApiCore {
  Future<DetailsChangeCurrentStatus> getDetailsChangeCurrentStatusApi() async {
    try {
      final uri = Uri.parse(apiLinks.detailschangecurrentstatusURL);
      final res = await apiClient.post(
        uri,
        headers: funddefaultHeaders,
        body: jsonEncode(
          {"client_id": "${prefs.clientId}"},
        ),
      );
      final json = jsonDecode(res.body);
      return DetailsChangeCurrentStatus.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  sendOTPtoChangeEmailApi(String newEmail, String oldEmail, String clientName,
      String dpcode) async {
    globalcurrmail = oldEmail;
    globalNewEmail = newEmail;
    globaldpcode = dpcode;
    try {
      final uri = Uri.parse(apiLinks.sendOTPEmailURL);

      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "client_id": "${prefs.clientId}",
            "previous_email": oldEmail,
            "present_email": newEmail,
            "client_name": clientName
          }));

      final json = jsonDecode((res.body));

      // // print("MF Master ==>${json['msg']}");

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  verifyOTPtoChangeEmailApi(String otpres, newEmail) async {
    try {
      final uri = Uri.parse(apiLinks.verifyOTPEmailURL);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "client_id": "${prefs.clientId}",
            "present_email": newEmail,
            "emailotp": otpres
          }));

      final json = jsonDecode((res.body));
      // // print("otpres $otpres");
      // // print("newemail $newEmail");

      // // print("otp email resp ==>${json['msg']}");

      if (json['msg'] == "otp valid") {
        // // print("function call");
        // // print("globalcurrmail , ${globalcurrmail}");
        // // print("client_id, ${prefs.clientId}");
        // // print("client_email: ${globalcurrmail}");
        // // print("dp_code: ${globaldpcode}");
        // // print("present_email: ${globalNewEmail}");
        // // print("previous_email: ${globalcurrmail}");

        // // print("client_name: ${prefs.clientName}");

        // // String old_email  = old;
        // // String newemail = json['new_email'];
        // // print("------------------------------------------------------");
        emailfilewrittenapi();
      }

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  emailfilewrittenapi() async {
    try {
      DateTime nowUtc = DateTime.now().toUtc();

      // Manually format the date
      String formattedDateUtc = "${nowUtc.year.toString().padLeft(4, '0')}-" +
          "${nowUtc.month.toString().padLeft(2, '0')}-" +
          "${nowUtc.day.toString().padLeft(2, '0')}T" +
          "${nowUtc.hour.toString().padLeft(2, '0')}:" +
          "${nowUtc.minute.toString().padLeft(2, '0')}:" +
          "${nowUtc.second.toString().padLeft(2, '0')}." +
          "${nowUtc.millisecond.toString().padLeft(3, '0')}" +
          "Z"; // You can use milliseconds instead of microseconds for simplicity.

      // // print("Formatted UTC date: $formattedDateUtc");
      // // print("Current date and time: $now");
      final uri = Uri.parse(apiLinks.filewriteemailURL);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "client_id": "${prefs.clientId}",
            "client_email": "${globalcurrmail}",
            "dp_code": globaldpcode,
            "date_time": "${formattedDateUtc}",
            "present_email": "${globalNewEmail}",
            "previous_email": "${globalcurrmail}",
            "client_name": "${prefs.clientName}",
          }));

      // // print(jsonEncode({
      //   "client_id": "${prefs.clientId}",
      //   "client_email": "${globalcurrmail}",
      //   "dp_code": globaldpcode,
      //   "date_time": "${formattedDateUtc}",
      //   "present_email": "${globalNewEmail}",
      //   "previous_email": "${globalcurrmail}",
      //   "client_name": "${prefs.clientName}",
      // }));

      final json = jsonDecode((res.body));

      // // print("filewriteep ==>${json}");

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

// startDigioEsign() async {
//   try {

//     final result = await platform.invokeMethod('startDigioEsign', {
//       'fileId': "DID250211194303853KXRAIB6KN72FOV",
//       'email': "sabarimechc12@gmail.com",
//       'session': "GWT250212102955344POFS5I2GD7C2DS",
//     });

//     if (result == 'Signed Successfully') {
//       // print("Document signed successfully!");

//     } else if (result == 'Signing cancelled') {
//       // print("Signing process was cancelled.");

//     } else {
//       // print("Unexpected result: $result");

//     }
//   } catch (e) {
//     // print('Error during Digio eSign: $e');

//   }
// }

  Future<void> esignfunstart() async {
    // // print("Starting Digio eSign workflow...");
    // var workflowResult;

    // try {
    //   var digioConfig = DigioConfig();
    //   digioConfig.theme.primaryColor = "#32a83a";
    //   digioConfig.environment = Environment.PRODUCTION;

    //   final _kycWorkflowPlugin = KycWorkflow(digioConfig);

    //   // Set the listener for gateway events
    //   _kycWorkflowPlugin.setGatewayEventListener((GatewayEvent? gatewayEvent) {
    //     // print("Gateway funnel event: " + gatewayEvent.toString());
    //   });

    //   // Start the eSign workflow
    //   workflowResult = await _kycWorkflowPlugin.start(
    //     "DID250211194303853KXRAIB6KN72FOV", // Sample Client ID
    //     "sabarimechc12@gmail.com", // Sample email
    //     "GWT250212102955344POFS5I2GD7C2DS", // Sample Reference ID
    //     null,
    //   );

    //   // print('workflowResult : ' + workflowResult.toString());
    // } catch (e) {
    //   // print('Error during Digio eSign: $e');
    // }
    // // print("eSign workflow finished.");
  }

  Future<ProfileAllDetails> getClientProfileAllDetailsApi() async {
    String payload = jsonEncode({"client_id": prefs.clientId});
    String encryptedPayload = encryptionFunction(payload);
    try {
      final uri = Uri.parse(apiLinks.profileAllDetailsURL);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({"string": encryptedPayload}));
      Map<String, dynamic> json = jsonDecode(res.body);
      if (json.containsKey('emsg')) {
        return ProfileAllDetails.fromJson(json);
      } else {
        final decryptedData = decryptionFunction(json["str"]);
        //  log("client Data------------ ${jsonDecode(jsonEncode(decryptedData))}}");
        print("decryptedData------------ ${jsonDecode(decryptedData)}");
        return ProfileAllDetails.fromJson(jsonDecode(decryptedData));
      }
    } catch (e) {
      // // print("object :: $e");
      rethrow;
    }
  }

  

//   Future<PendingStatus> fetchPendingstatusApi() async {
//   try {
//     final uri = Uri.parse(apiLinks.rekycpendingstatusURL);

//     final res = await apiClient.post(
//       uri,
//       // headers: defaultHeaders,
//       body: jsonEncode({"client_id": prefs.clientId}),
//     );
//     return PendingStatus.fromJson(jsonDecode(res.body));
//   } catch (e) {
//     print("error fetchpendig :::: ${e}");
//     rethrow;
//   }
// }


  mobileotpapifun(String newmo, clemail, oldmobilmo, fulldataprf) async {
//  String formattedData = jsonEncode(fulldataprf.toJson()); // Convert object to JSON
    // // print("Formatted Profile Data: $formattedData");

    // Now you can use []
    // // print("CLIENT_ID: ${fulldataprf.toJson()['CLIENT_ID']}");

    try {
      final uri = Uri.parse(apiLinks.mobotpreq);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "prev_mobile_no": oldmobilmo,
            "pres_mobile_no": newmo,
            "client_id": "${prefs.clientId}",
            "client_name": "${prefs.clientName}",
            "client_email": oldmobilmo
          }));

      final json = jsonDecode((res.body));
// startDigioEsign();
      // // print("otp email resp ==>${json['msg']}");
      // // print("------------------------------------------------------");
      // // print("testttt${fulldataprf}");

      esignfunstart();

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  mobileotpverify(String newmo, mbotp, fulldataprf) async {
    try {
      globalfulldata = fulldataprf;
      globalnewmob = newmo;
      final uri = Uri.parse(apiLinks.mobotpver);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "pres_mobile_no": newmo,
            "client_id": "${prefs.clientId}",
            "mobile_otp": mbotp,
            "prev_mobile_no": "${fulldataprf.toJson()['MOBILE_NO']}",
            "client_name": "${prefs.clientName}",
            "client_email": "${fulldataprf.toJson()['CLIENT_ID_MAIL']}",
            "dp_code": "${fulldataprf.toJson()['CLIENT_DP_CODE']}"
          }));

      final json = jsonDecode((res.body));

      // // print("otp email resp ==>${json['msg']}");
      // // print("${globalfulldata.toJson()['CLIENT_DP_CODE']}");

      if (json['msg'] == "otp valid") {
        mobilefilewrite();
      }

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  mobilefilewrite() async {
    try {
      DateTime nowUtc = DateTime.now().toUtc();

      // Manually format the date
      String formattedDateUtc = "${nowUtc.year.toString().padLeft(4, '0')}-" +
          "${nowUtc.month.toString().padLeft(2, '0')}-" +
          "${nowUtc.day.toString().padLeft(2, '0')}T" +
          "${nowUtc.hour.toString().padLeft(2, '0')}:" +
          "${nowUtc.minute.toString().padLeft(2, '0')}:" +
          "${nowUtc.second.toString().padLeft(2, '0')}." +
          "${nowUtc.millisecond.toString().padLeft(3, '0')}" +
          "Z"; // You can use milliseconds instead of microseconds for simplicity.

      // // print("Formatted UTC date: $formattedDateUtc");
      final uri = Uri.parse(apiLinks.filewritemob);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "pres_mobile_no": globalnewmob,
            "client_id": "${prefs.clientId}",
            "prev_mobile_no": "${globalfulldata.toJson()['MOBILE_NO']}",
            "client_name": "${prefs.clientName}",
            "client_email": "${globalfulldata.toJson()['CLIENT_ID_MAIL']}",
            "dp_code": "${globalfulldata.toJson()['CLIENT_DP_CODE']}",
            "date_time": formattedDateUtc
          }));
      final json = jsonDecode((res.body));

      // // print("filewriteep ==>${json}");

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  manaddbankapi(String newadd, String pincoderes, String dist, String state,
      String county, String profty, fulldataprf, String filepath) async {
    try {
      // // print(
      //     "123456er${newadd}, ${pincoderes}, ${dist}, ${state}, ${county}, ${profty}, ${filepath}");
      globalfulldata = fulldataprf;
      final uri = Uri.parse(apiLinks.adrchnURL);

      var request = http.MultipartRequest('POST', uri);

      // Adding headers
      request.headers.addAll(funddefaultHeaders);
      // // print("${fulldataprf.toJson()}");
      // Adding form data
      request.fields['proff'] = profty;
      request.fields['cur_address'] =
          '{"address":"${newadd}","pincode":"${pincoderes}","state":"${state}","dist":"${dist}","country":"${county}"}';
      request.fields['ext_address'] =
          ("${fulldataprf.toJson()['CL_RESI_ADD1']}, ${fulldataprf.toJson()['CL_RESI_ADD2']}, ${fulldataprf.toJson()['CL_RESI_ADD3']}");
      request.fields['dp_code'] = "${fulldataprf.toJson()['CLIENT_DP_CODE']}";
      request.fields['client_id'] = "${prefs.clientId}";
      request.fields['client_name'] = "${prefs.clientName}";
      request.fields['adr_manual'] = 'manual';
      request.fields['aadhar_address'] = '';
      request.fields['code'] = '';
      request.fields['state'] = '';
      request.fields['client_email'] =
          "${fulldataprf.toJson()['CLIENT_ID_MAIL']}";

      // // print("proff: ${request.fields['proff']}");
      // // print("cur_address: ${request.fields['cur_address']}");
      // // print("ext_address: ${request.fields['ext_address']}");
      // // print("dp_code: ${request.fields['dp_code']}");
      // // print("client_id: ${request.fields['client_id']}");
      // // print("client_name: ${request.fields['client_name']}");
      // // print("adr_manual: ${request.fields['adr_manual']}");
      // // print("aadhar_address: ${request.fields['aadhar_address']}");
      // // print("code: ${request.fields['code']}");
      // // print("state: ${request.fields['state']}");
      // // print("client_email: ${request.fields['client_email']}");

      // Attaching the file
      request.files.add(await http.MultipartFile.fromPath('file', filepath));

      // Sending the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        // print("Response: $responseBody");
        // return responseBody['msg'];
      } else {
        // // print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      // // print("Exception: $e");
    }
  }

  ledgerbalanceapi() async {
    try {
      final uri = Uri.parse(apiLinks.allledgerbalanceURL);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "clientid": "${prefs.clientId}",
          }));

      final json = jsonDecode(res.body);
      // print("djsonjson ==> ${json}");
      // print("ddpi balance ==> ${json['total']}");
      return json['total'];
      // int totalBalance;
      // if (json['total'] is int) {
      //   totalBalance = json['total']; // Directly use the int value
      // } else if (json['total'] is double) {
      //   totalBalance = json['total'].toInt(); // Convert double to int
      // } else {
      //   // Handle unexpected types (e.g., string or null)
      //   totalBalance = int.tryParse(json['total']?.toString() ?? '') ?? 0;
      // }

      // return totalBalance;
    } catch (e) {
      rethrow;
    }
  }

  finalddpisubmitapi(fulldataprf) async {
    // print("testing");
    // print("1111111111111111${fulldataprf.toJson()}");

    try {
      final uri = Uri.parse(apiLinks.ddpiURL);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "CLIENT_ID": "${prefs.clientId}",
            "CLIENT_NAME": "${prefs.clientName}",
            "MOBILE_NO": "${fulldataprf.toJson()['MOBILE_NO']}",
            "CLIENT_ID_MAIL": "${fulldataprf.toJson()['CLIENT_ID_MAIL']}",
            "CL_RESI_ADD3": "${fulldataprf.toJson()['CL_RESI_ADD1']}",
            "CLIENT_DP_CODE": "${fulldataprf.toJson()['CLIENT_DP_CODE']}",
            "PAN_NO": "${fulldataprf.toJson()['PAN_NO']}"
          }));

      final json = jsonDecode((res.body));

      // print("otp email resp ==>${json}");

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  mtfenabapipage(fulldataprf) async {
    // print("mtfff");
    // print("1111111111111111${fulldataprf.toJson()}");

    try {
      final uri = Uri.parse(apiLinks.mtfURL);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "client_id": "${prefs.clientId}",
            "client_name": "${prefs.clientName}",
            "client_email": "${fulldataprf.toJson()['CLIENT_ID_MAIL']}",
            "client_address": "${fulldataprf.toJson()['CL_RESI_ADD1']}",
            "dp_code": "${fulldataprf.toJson()['CLIENT_DP_CODE']}",
          }));

      final json = jsonDecode((res.body));

      // print("otp email resp ==>${json}");

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  incomeotesendapi(mobileno) async {
    // // print("mtfff");
    // // print("1111111111111111${fulldataprf.toJson()}");

    try {
      final uri = Uri.parse(apiLinks.incomeotpreqURL);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "client_id": "${prefs.clientId}",
            "client_name": "${prefs.clientName}",
            "mobile_number": mobileno,
          }));

      final json = jsonDecode((res.body));

      // print("otp email respincomeee ==>${json}");
      // print("otp email in1234567 ==>${json['msg']}");

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  incomeotpverfapi(otpno, fulldataprf, chipval, file, proftye) async {
    // // print("mtfff");
    // // print("1111111111111111${fulldataprf.toJson()}");
    globalfulldata = fulldataprf;
    try {
      final uri = Uri.parse(apiLinks.incomeotpverURL);
      final res = await apiClient.post(uri,
          headers: funddefaultHeaders,
          body: jsonEncode({
            "client_id": "${prefs.clientId}",
            "mobile_otp": otpno,
            "mobile_number": "${globalfulldata.toJson()['MOBILE_NO']}",
          }));

      final json = jsonDecode((res.body));

      if (json['msg'] == "otp valid") {
        incomeupdateaapi(fulldataprf, chipval, file, proftye);
      }

      // print("otp email respincomeee ==>${json}");
      // print("otp email in1234567 ==>${json['msg']}");

      return json['msg'];
    } catch (e) {
      rethrow;
    }
  }

  incomeupdateaapi(
      fulldataprf, String chipval, String filepath, String proftye) async {
    try {
      globalfulldata = fulldataprf;
      final uri = Uri.parse(apiLinks.incomeURL);

      var request = http.MultipartRequest('POST', uri);

      // Adding headers
      request.headers.addAll(funddefaultHeaders);

      // Adding form data
      request.fields['client_id'] = "${prefs.clientId}";
      request.fields['client_email'] =
          "${fulldataprf.toJson()['CLIENT_ID_MAIL']}";
      request.fields['client_name'] = "${prefs.clientName}";
      request.fields['ext_income_range'] =
          "${fulldataprf.toJson()['ANNUAL_INCOME']}";
      request.fields['cur_income_range'] = chipval;
      request.fields['proff'] = chipval == "Above 25L" ? "YES" : "NO";
      request.fields['dp_code'] = "${fulldataprf.toJson()['CLIENT_DP_CODE']}";
      request.fields['proff_type'] = chipval == "Above 25L" ? proftye : "";
      request.fields['password'] = "";
      request.fields['password_reqiured'] = "";

      //   // print("client_id: ${request.fields['client_id']}");
      // // print("client_email: ${request.fields['client_email']}");
      // // print("client_name: ${request.fields['client_name']}");
      // // print("ext_income_range: ${request.fields['ext_income_range']}");
      // // print("cur_income_range: ${request.fields['cur_income_range']}");
      // // print("proff: ${request.fields['proff']}");
      // // print("dp_code: ${request.fields['dp_code']}");
      // // print("proff_type: ${request.fields['proff_type']}");

      // Only add file if 'Above 25L' and filepath is valid
      if (chipval == "Above 25L" && filepath.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('proff_file', filepath));
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        // print("Response: $responseBody");
        // Return the response message or do further processing
      } else {
        // print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      // print("Exception: $e");
    }
  }

  ifsccodecheckapi(String ifsccode) async {
    // // print("djsonjson ==> ${ifsccode}");

    try {
      if (ifsccode.length > 9) {
        // print("Valid IFSC Code: $ifsccode");

        final uri = Uri.parse("https://ifsc.razorpay.com/$ifsccode");
        final res = await http.get(uri);

        if (res.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(res.body);
          globalfulldata = json;
          // print("@@@@@@@@@@@@${globalfulldata}");
          // print("11111111111${globalfulldata['MICR']}");

          if (json.containsKey('BANK') && json.containsKey('BRANCH')) {
            return "${json['BANK']} - ${json['BRANCH']}";
          } else {
            // print("Error: Invalid API response format");
            return "Invalid response";
          }
        } else {
          // print("Error: Invalid IFSC Code or API issue");
          return "Invalid IFSC Code";
        }
      } else {
        // print("Error: IFSC Code is too short");
        return "Invalid IFSC Code";
      }
    } catch (e) {
      rethrow;
    }
  }

  addbankapi(String banacc, String bankifc, String filepath, String profftype,
      String setpri, String accty, fulldataprf, bankdata) async {
//         final file = File(filepath);
// if (await file.exists()) {
    // print('File exists!${filepath}');
// } else {
//   // print('File does not exist at $filepath');
// }

    if (bankdata is String) {
      List<Map<String, dynamic>> decodedBankData =
          List<Map<String, dynamic>>.from(jsonDecode(bankdata));
      List<Map<String, String>> formattedBankData = decodedBankData.map((item) {
        return {
          "acc_no": item["Bank_AcNo"] as String,
          "ifsc_no": item["IFSC_Code"] as String,
        };
      }).toList();
      try {
        final uri = Uri.parse(
            "${apiLinks.bankURL}?mob=${fulldataprf.toJson()['MOBILE_NO']}&bankName=${globalfulldata['BANK']}&ifsc=${globalfulldata['IFSC']}&proff_type=${profftype}&branch=${globalfulldata['BRANCH']}&bank_account_type=${accty}&client_name=${prefs.clientName}&option=add&client_id=${prefs.clientId}&set_default=no&dp_code=${fulldataprf.toJson()['CLIENT_DP_CODE']}&micr=${globalfulldata['MICR']}&client_email=${fulldataprf.toJson()['CLIENT_ID_MAIL']}&password_required=NO&Password=&count=3");
        var request = http.MultipartRequest('POST', uri);
        request.headers.addAll(funddefaultHeaders);
        request.fields['bank_exists'] = jsonEncode(formattedBankData);
        request.files.add(await http.MultipartFile.fromPath('proff', filepath));
        // print("1111111111${filepath}");
        if (filepath.isNotEmpty) {
          request.files
              .add(await http.MultipartFile.fromPath('proff_file', filepath));
        }
        var response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          // print("Response: $responseBody");
        } else {
          // print("Error: ${response.reasonPhrase}");
        }
      } catch (e) {
        // print("Exception1111111: $e");
      }
    }
  }

  addfamilaccapi(String menid, String relation, String menpan, String mobilno,
      fulldataprf) async {
    try {
      final uri = Uri.parse(apiLinks.sendlinkrequestURL);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "clientid": "${prefs.clientId}",
            "memberid": menid,
            "pan": menpan,
            "mobile_no": mobilno,
            "clientname": "${prefs.clientName}",
            "relationship": relation
          }));
      // print({
      //   "clientid": "${prefs.clientId}",
      //   "memberid": menid,
      //   "pan": menpan,
      //   "mobile_no": mobilno,
      //   "clientname": "${prefs.clientName}",
      //   "relationship": relation
      // });
      final json = jsonDecode(res.body);
      // print(json['emsg']);

      return json['emsg'];
    } catch (e) {
      rethrow;
    }
  }

  closeacbalapi(String resaqon, fulldataprf) async {
    try {
      final uri = Uri.parse(apiLinks.checkclosureURL);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_id": "${prefs.clientId}",
          }));

      final json = jsonDecode(res.body);

      double balance = json['balance'] ?? 0.0;
      String msg1 = json['msg1'] ?? '';
      String msg2 = json['msg2'] ?? '';
      String stage = '';

      if (balance > 0 && msg2.isEmpty) {
        stage = "Stage 1: Positive Balance";
      } else if (balance < 0 && msg2.isEmpty) {
        stage = "Stage 2: Negative Balance";
      } else if (balance > 0 && msg2 == "some holdings") {
        stage = "Stage 3: Positive Balance & Some Holdings";
      } else if (balance < 0 && msg2 == "some holdings") {
        stage = "Stage 4: Negative Balance & Some Holdings";
      } else if (balance == 0 && msg2 == "some holdings") {
        stage = "Stage 5: Zero Balance & Some Holdings";
      } else if (msg2 == "some holdings") {
        stage = "Stage 6: Some Holdings (Balance Unspecified)";
      } else {
        stage = "Unknown Stage";
      }

      // print("Stage: $stage");
      // print("Balance: $balance");
      // print("Response JSON: $json");

      return {
        "stage": stage,
        "balance": balance,
        "msg1": msg1,
        "msg2": msg2,
      };

      // if (json['msg1'] == 'zero ledger balance' &&
      //     json['msg2'] == 'zero holdings' &&
      //     json['stat'] == 'Ok') {
      //   // print("condition satsfy");
      // } else {
      //   // print("condition not satsfy");
      //   holdingsapiceckapi();
      // }
      // // print("djsonjson ==> ${json}");
      // // // print("ddpi balance ==> ${json['total']}");
      // return json['total'];
    } catch (e) {
      rethrow;
    }
  }

  holdingsapiceckapi() async {
    try {
      final uri = Uri.parse(apiLinks.getholdingscheckURL);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({
            "client_code": "${prefs.clientId}",
          }));

      final json = jsonDecode(res.body);
      // print("djsonjson ==> ${json}");
      return json['total'];
    } catch (e) {
      rethrow;
    }
  }

  acccloserapi(String dpid, String boid, String filepath, String reason,
      fulldataprf, bankdata) async {
    List<Map<String, dynamic>> decodedBankData =
        List<Map<String, dynamic>>.from(jsonDecode(bankdata));

    // Convert decodedBankData to string format
    String bankDataString = jsonEncode(decodedBankData);
    globalfulldata = fulldataprf;

    // Print all data as string
    // Debugging: Print values before assigning them to request fields
    // print("client_id: ${prefs.clientId}");
    // print("client_name: ${prefs.clientName}");
    // print("client_email: ${fulldataprf.toJson()['CLIENT_ID_MAIL']}");
    // print("dp_code: ${fulldataprf.toJson()['CLIENT_DP_CODE']}");
    // print("segments: $bankDataString");
    // print("reason: ${dpid == '' ? 'no' : 'yes'}");
    // print(
    // "address: ${fulldataprf.toJson()['CL_RESI_ADD1']},${fulldataprf.toJson()['CL_RESI_ADD2']},${fulldataprf.toJson()['CL_RESI_ADD3']}");
    // print("transfer_client_id: $dpid");
    // print("transfer_dp_id: $boid");
    try {
      globalfulldata = fulldataprf;
      final uri = Uri.parse(apiLinks.closureURL);

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(funddefaultHeaders);
      request.fields['client_id'] = "${prefs.clientId}";
      request.fields['client_name'] = "${prefs.clientName}";
      request.fields['client_email'] =
          "${fulldataprf.toJson()['CLIENT_ID_MAIL']}";
      request.fields['dp_code'] = "${fulldataprf.toJson()['CLIENT_DP_CODE']}";
      request.fields['segments'] = bankDataString;
      request.fields['reason'] = reason;
      request.fields['transfer'] = dpid == "" ? "no" : 'yes';

      request.fields['address'] =
          "${fulldataprf.toJson()['CL_RESI_ADD1']},${fulldataprf.toJson()['CL_RESI_ADD2']},${fulldataprf.toJson()['CL_RESI_ADD3']}";
      request.fields['transfer_client_id'] = dpid;
      request.fields['transfer_dp_id'] = boid;
      // request.fields['cmr_file'] = "";
//  request.files
//             .add(await http.MultipartFile.fromPath('cmr_file', filepath));
      if (filepath.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('cmr_file', filepath));
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        // print("Response: $responseBody");
        // Return the response message or do further processing
      } else {
        // print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      // print("Exception: $e");
    }
  }
}
