import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mynt_plus/api/core/api_link.dart';

import '../models/auth_model/forgot_pass_model.dart';
import '../models/auth_model/logout_model.dart';
import '../models/auth_model/mobile_login_model.dart';
import '../models/auth_model/mobile_otp_model.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'core/api_core.dart';

mixin AuthApi on ApiCore {
// Login and get OTP

  Future<MobileLoginModel> getMobileLogin(
      {required String uniqueId,
      required String mobileRclient,
      required String password,
      required String imei,
      required bool totp,
      required BuildContext context}) async {
    try {
      final uri = Uri.parse(apiLinks.mobileLogin);

      Map data = password.isEmpty
          ? {
              "mobile_unique": uniqueId,
              getInputType(mobileRclient): mobileRclient,
              "imei": imei,
              "TOTP": totp ? "TRUE" : ""
            }
          : {
              "mobile_unique": uniqueId,
              getInputType(mobileRclient): mobileRclient,
              "password": password,
              "imei": imei,
              "TOTP": totp ? "TRUE" : ""
            };

      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode(data));

      log("Mobile Login   => ${res.body}");
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return MobileLoginModel.fromJson(json as Map<String, dynamic>);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            error(context, "${res.statusCode} ${res.reasonPhrase}"));
        return MobileLoginModel.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("asd $e");
      rethrow;
    }
  }

// Verify OTP

  Future<MobileOtpModel> getMobileOtp(
      {required String uniqueId,
      required String mobileRclient,
      required String imei,
      required String otp,
      required BuildContext context}) async {
    try {
      final uri = Uri.parse(apiLinks.mobileOtp);

      Map data = {
        "mobile_unique": uniqueId,
        getInputType(mobileRclient): mobileRclient,
        "otp": otp,
        "source": ApiLinks.source,
        "imei": imei
      };
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode(data));

      log("Mobile OTP  => ${res.body}");
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return MobileOtpModel.fromJson(json as Map<String, dynamic>);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            error(context, "${res.statusCode} ${res.reasonPhrase}"));
        return MobileOtpModel.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("asd $e");
      rethrow;
    }
  }

// Logout

  Future<LogoutModel> getLogout() async {
    try {
      final uri = Uri.parse(apiLinks.logout);

      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body:
              '''jData={"uid":"${prefs.clientId}" }&jKey=${prefs.clientSession}''');

      // log("Logout Model => ${res.body}");
      final json = jsonDecode(res.body);

      return LogoutModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

// Forgot password

  Future<ForgetPasswordModel> getForgetPassword(
      String field, String value) async {
    try {
      final uri = Uri.parse(apiLinks.forgetPassword);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"field": getInputType(field), "value": value}));

      // log("forgetPassword Res => ${res.body}");
      final json = jsonDecode(res.body);

      return ForgetPasswordModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future setAppversion(Map data) async {
    try {
      final uri = Uri.parse(apiLinks.weblog);
      final res = await apiClient.post(uri,
          headers: defaultHeaders, body: jsonEncode(data));
      final json = jsonDecode(res.body);

      return json;
    } catch (e) {
      rethrow;
    }
  }

  Future setOrderprefer(Map data, bool head) async {
    try {
      final uri = Uri.parse(head
          ? apiLinks.setpref
          : "${apiLinks.getpref}?clientid=${prefs.clientId}&source=MOB");
      final res = head
          ? await apiClient.post(uri,
              headers: defaultHeaders, body: jsonEncode(data))
          : await apiClient.get(uri, headers: defaultHeaders);
      final json = jsonDecode(res.body);
      // print("object pref $json");

      return json;
    } catch (e) {
      rethrow;
    }
  }

  // Future<ValidateSession> getValidateSession(
  //     {required String deviceInfo}) async {
  //   try {
  //     final uri = Uri.parse(apiLinks.validateSession);
  //     final res = await apiClient.post(uri,
  //         headers: defaultHeaders,
  //         body: jsonEncode(
  //             {"mobile_unique": deviceInfo, "clientid": prefs.clientId}));

  //     // log("forgetPassword Res => ${res.body}");
  //     final json = jsonDecode(res.body);

  //     return ValidateSession.fromJson(json as Map<String, dynamic>);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
