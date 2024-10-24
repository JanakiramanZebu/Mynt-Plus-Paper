import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mynt_plus/api/core/api_link.dart';

import '../models/auth_model/forgot_pass_model.dart';
import '../models/auth_model/logout_model.dart';
import '../models/auth_model/mobile_login_model.dart';
import '../models/auth_model/mobile_otp_model.dart';
import '../models/auth_model/validate_seesion_model.dart';
import '../sharedWidget/snack_bar.dart';
import 'core/api_core.dart';

mixin AuthApi on ApiCore {
  Future<MobileLoginModel> getMobileLogin(
      {required String uniqueId,
      required String mobileRclient,
      required String password,
      required String imei,
      required BuildContext context}) async {
    try {
      final uri = Uri.parse(apiLinks.mobileLogin);

      Map data = !prefs.isMobileLogin!
          ? {
              "mobile_unique": uniqueId,
              "clientid": mobileRclient,
              "imei": imei,
              "password": password
            }
          : password.isEmpty
              ? {
                  "mobile_unique": uniqueId,
                  "clientid": mobileRclient,
                  "imei": imei
                }
              : {
                  "mobile_unique": uniqueId,
                  "mobile": mobileRclient,
                  "password": password,
                  "imei": imei
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

  Future<MobileOtpModel> getMobileOtp(
      {required String uniqueId,
      required String mobileRclient,
   required   String imei,
      required String otp,
      required BuildContext context}) async {
    try {
      final uri = Uri.parse(apiLinks.mobileOtp);

      Map data = !prefs.isMobileLogin!
          ? {
              "mobile_unique": uniqueId,
              "clientid": mobileRclient,
              "otp": otp,
                  "imei": imei,
              "source": ApiLinks.source
            }
          : {
              "mobile_unique": uniqueId,
              "mobile": mobileRclient,
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

  Future<ForgetPasswordModel> getForgetPassword(
      String field, String value) async {
    try {
      final uri = Uri.parse(apiLinks.forgetPassword);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode({"field": field, "value": value}));

      // log("forgetPassword Res => ${res.body}");
      final json = jsonDecode(res.body);

      return ForgetPasswordModel.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<ValidateSession> getValidateSession(
      {required String deviceInfo}) async {
    try {
      final uri = Uri.parse(apiLinks.validateSession);
      final res = await apiClient.post(uri,
          headers: defaultHeaders,
          body: jsonEncode(
              {"mobile_unique": deviceInfo, "clientid": prefs.clientId}));

      // log("forgetPassword Res => ${res.body}");
      final json = jsonDecode(res.body);

      return ValidateSession.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
