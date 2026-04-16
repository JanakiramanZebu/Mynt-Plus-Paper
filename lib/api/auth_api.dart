import 'dart:developer';
// Import only the specific exceptions for non-web builds
import 'dart:io' show SocketException, HttpException;
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_model/desk_logout_model.dart';
import '../models/auth_model/forgot_pass_model.dart';
import '../models/auth_model/logout_model.dart';
import '../models/auth_model/mobile_login_model.dart';
import '../models/auth_model/mobile_otp_model.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'core/api_core.dart';

mixin AuthApi on ApiCore {
// Login and get OTP

  Future<MobileLoginModel?> getMobileLogin(
      {required String uniqueId,
      required String mobileRclient,
      required String password,
      required String imei,
      required bool totp,
      required BuildContext context}) async {
    try {
      final uri = Uri.parse(apiLinks.mobileLogin);

      Map data = password.isEmpty
          ? {"mobile_unique": uniqueId, getInputType(mobileRclient): mobileRclient, "imei": imei, "TOTP": totp ? "TRUE" : ""}
          : {"mobile_unique": uniqueId, getInputType(mobileRclient): mobileRclient, "password": password, "imei": imei, "TOTP": totp ? "TRUE" : ""};

      final res = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode(data));

      log("Mobile Login   => ${res.body}");
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return MobileLoginModel.fromJson(json as Map<String, dynamic>);
      }
    } on SocketException catch (_) {
          error(context, "Network error. Please check your connection.");
      return null;
    } on HttpException catch (_) {
          error(context, "Network error. Unable to connect to server.");
      return null;
    } on TimeoutException catch (_) {
          error(context, "Connection timed out. Please try again.");
      return null;
    } catch (e) {
          error(context, "An error occurred. Please try again.");
      return null;
    }
    return null;
  }

// Verify OTP

  Future<MobileOtpModel?> getMobileOtp(
      {required String uniqueId, required String mobileRclient, required String imei, required String otp, required BuildContext context}) async {
    try {
      final uri = Uri.parse(apiLinks.mobileOtp);

      Map data = {"mobile_unique": uniqueId, getInputType(mobileRclient): mobileRclient, "otp": otp, "source": "MOB", "imei": imei};
      final res = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode(data));

      log("Mobile OTP  => ${res.body}");
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return MobileOtpModel.fromJson(json as Map<String, dynamic>);
      }
    } on SocketException catch (_) {
          error(context, "Network error. Please check your connection.");
      return null;
    } on HttpException catch (_) {
          error(context, "Network error. Unable to connect to server.");
      return null;
    } on TimeoutException catch (_) {
          error(context, "Connection timed out. Please try again.");
      return null;
    } catch (e) {
          error(context, "An error occurred. Please try again.");
      return null;
    }
    return null;
  }

// Logout

  Future<LogoutModel?> getLogout() async {
    try {
      final uri = Uri.parse(apiLinks.logout);
      final payload = '''jData={"uid":"${prefs.clientId}","source":"WEB" }&jKey=${prefs.clientSession}''';

    

      final res = await apiClient.post(uri, headers: defaultHeaders, body: payload);

     
      final json = jsonDecode(res.body);

      return LogoutModel.fromJson(json as Map<String, dynamic>);
    } on SocketException catch (_) {
      return null;
    } on HttpException catch (_) {
      return null;
    } on TimeoutException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

// Desk Logout - New API for web logout

  Future<DeskLogoutModel?> getDeskLogout() async {
    try {
      final uri = Uri.parse(apiLinks.deskLogout);
      final payload = {
        "clientid": prefs.clientId ?? "",
        "token": prefs.token ?? ""
      };

      

      final res = await apiClient.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(payload),
      );

     

      final json = jsonDecode(res.body);

      return DeskLogoutModel.fromJson(json as Map<String, dynamic>);
    } on SocketException catch (_) {
      return null;
    } on HttpException catch (_) {
      return null;
    } on TimeoutException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

// Forgot password

  Future<ForgetPasswordModel?> getForgetPassword(String field, String value, BuildContext context) async {
    try {
      final uri = Uri.parse(apiLinks.forgetPassword);
      final res = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode({"field": getInputType(field), "value": value}));

      // log("forgetPassword Res => ${res.body}");
      final json = jsonDecode(res.body);

      return ForgetPasswordModel.fromJson(json as Map<String, dynamic>);
    } on SocketException catch (_) {
          error(context, "Network error. Please check your connection.");
      return null;
    } on HttpException catch (_) {
          error(context, "Network error. Unable to connect to server.");
      return null;
    } on TimeoutException catch (_) {
          error(context, "Connection timed out. Please try again.");
      return null;
    } catch (e) {
          error(context, "An error occurred. Please try again.");
      return null;
    }
  }

  Future setAppversion(Map data, BuildContext context) async {
    try {
      final uri = Uri.parse(apiLinks.weblog);
      final res = await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode(data));
      final json = jsonDecode(res.body);

      return json;
    } on SocketException catch (_) {
          error(context, "Network error. Please check your connection.");
      return null;
    } on HttpException catch (_) {
          error(context, "Network error. Unable to connect to server.");
      return null;
    } on TimeoutException catch (_) {
          error(context, "Connection timed out. Please try again.");
      return null;
    } catch (e) {
          error(context, "An error occurred. Please try again.");
      return null;
    }
  }

  Future setOrderprefer(Map data, bool head, BuildContext context) async {
    try {
      final uri = Uri.parse(head ? apiLinks.setpref : "${apiLinks.getpref}?clientid=${prefs.clientId}&source=FWEB");
      final res = head ? await apiClient.post(uri, headers: defaultHeaders, body: jsonEncode(data)) : await apiClient.get(uri, headers: defaultHeaders);
      final json = jsonDecode(res.body);
      // print("object pref $json");

      return json;
    } on SocketException catch (_) {
          error(context, "Network error. Please check your connection.");
      return null;
    } on HttpException catch (_) {
          error(context, "Network error. Unable to connect to server.");
      return null;
    } on TimeoutException catch (_) {
          error(context, "Connection timed out. Please try again.");
      return null;
    } catch (e) {
          error(context, "An error occurred. Please try again.");
      return null;
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
