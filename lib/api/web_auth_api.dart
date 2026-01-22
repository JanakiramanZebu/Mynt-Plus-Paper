import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/auth_model/mobile_login_model.dart';
import '../models/auth_model/mobile_otp_model.dart';
import '../sharedWidget/snack_bar.dart';

/// Web-specific authentication API service
/// This service handles the web login flow with source="WEB" 
/// and includes TOTP generation functionality
class WebAuthApi {
  // Base URL for login APIs
  static const String _loginBaseUrl = 'https://ws.mynt.in/login';
  
  // Go Mynt URL for TOTP APIs  
  static const String _goMyntUrl = 'https://go.mynt.in/NorenWClientWeb';
  
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  /// Determine if input is mobile or client ID
  static String _getInputType(String input) {
    return RegExp(r'^[0-9]+$').hasMatch(input) ? 'mobile' : 'clientid';
  }

  /// Web Login API - Validates credentials and triggers OTP/TOTP flow
  /// Uses source="WEB" instead of "MOB"
  static Future<MobileLoginModel?> webMobileLogin({
    required String uniqueId,
    required String mobileOrClientId,
    required String password,
    required String imei,
    required bool totp,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('$_loginBaseUrl/MobileLogin');
      
      final inputType = _getInputType(mobileOrClientId);
      
      Map<String, dynamic> data = {
        'device': 'WEB', // Web-specific source
        inputType: mobileOrClientId.toUpperCase(),
        'password': password,
      };

      log("Web Login Request => $data");
      
      final res = await http.post(
        uri, 
        headers: _defaultHeaders, 
        body: jsonEncode(data),
      );

      log("Web Login Response => ${res.body}");
      
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return MobileLoginModel.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Web Login error: $e");
      error(context, "An error occurred. Please try again.");
    }
    return null;
  }

  /// Send OTP API - Separate endpoint for sending OTP
  /// This is called when user switches from TOTP to OTP mode
  static Future<Map<String, dynamic>?> sendOtp({
    required String mobileOrClientId,
    required String source,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('$_loginBaseUrl/otp_send');
      
      final inputType = _getInputType(mobileOrClientId);
      
      Map<String, dynamic> data = {
        'device': source,
        inputType: mobileOrClientId.toUpperCase(),
      };

      log("Send OTP Request => $data");
      
      final res = await http.post(
        uri, 
        headers: _defaultHeaders, 
        body: jsonEncode(data),
      );

      log("Send OTP Response => ${res.body}");
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Send OTP error: $e");
      error(context, "Failed to send OTP. Please try again.");
    }
    return null;
  }

  /// Verify OTP API - Verify OTP/TOTP and complete login
  /// Uses source="WEB" for web platform
  static Future<MobileOtpModel?> webVerifyOtp({
    required String uniqueId,
    required String mobileOrClientId,
    required String otp,
    required String imei,
    required String source,
    required Map<String, dynamic>? logData,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('$_loginBaseUrl/otp_verify');
      
      final inputType = _getInputType(mobileOrClientId);
      
      Map<String, dynamic> data = {
        'source': source,
        'otp': otp,
        inputType: mobileOrClientId.toUpperCase(),
      };
      
      // Add log data if provided
      if (logData != null) {
        data['log'] = logData;
      }

      log("Web OTP Verify Request => $data");
      
      final res = await http.post(
        uri, 
        headers: _defaultHeaders, 
        body: jsonEncode(data),
      );

      log("Web OTP Verify Response => ${res.body}");
      
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return MobileOtpModel.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Web OTP Verify error: $e");
      error(context, "OTP verification failed. Please try again.");
    }
    return null;
  }

  /// Get TOTP Secret Key - Retrieves existing TOTP secret if available
  static Future<TotpData?> getTotpSecretKey({
    required String clientId,
    required String apiSession,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('$_goMyntUrl/GetSecretKey');
      
      final body = 'jData={"uid":"$clientId"}&jKey=$apiSession';

      log("Get TOTP Key Request => $body");
      
      final res = await http.post(
        uri, 
        headers: {'Content-Type': 'text/plain'}, 
        body: body,
      );

      log("Get TOTP Key Response => ${res.body}");
      
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['uid'] != null && json['pwd'] != null) {
          return TotpData.fromJson(json as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint("Get TOTP Key error: $e");
    }
    return null;
  }

  /// Generate TOTP Secret Key - Creates new TOTP secret
  static Future<TotpData?> generateTotpSecretKey({
    required String clientId,
    required String apiSession,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('$_goMyntUrl/GenSecretKey');
      
      final body = 'jData={"uid":"$clientId"}&jKey=$apiSession';

      log("Gen TOTP Key Request => $body");
      
      final res = await http.post(
        uri, 
        headers: {'Content-Type': 'text/plain'}, 
        body: body,
      );

      log("Gen TOTP Key Response => ${res.body}");
      
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return TotpData.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Gen TOTP Key error: $e");
      error(context, "Failed to generate TOTP. Please try again.");
    }
    return null;
  }

  /// Get or Generate TOTP - Tries to get existing, generates new if not found
  static Future<TotpData?> getOrGenerateTotp({
    required String clientId,
    required String apiSession,
    required BuildContext context,
  }) async {
    // First try to get existing TOTP
    TotpData? totpData = await getTotpSecretKey(
      clientId: clientId,
      apiSession: apiSession,
      context: context,
    );
    
    // If no existing TOTP, generate new one
    if (totpData == null) {
      totpData = await generateTotpSecretKey(
        clientId: clientId,
        apiSession: apiSession,
        context: context,
      );
    }
    
    return totpData;
  }

  /// QR Login API - For QR code based login
  static Future<MobileOtpModel?> qrLogin({
    required String uniqueId,
    required String source,
    required String imei,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('https://copy.mynt.in/QRlogin');
      
      Map<String, dynamic> data = {
        'unique_id': uniqueId,
        'source': source,
        'imei': imei,
      };

      log("QR Login Request => $data");
      
      final res = await http.post(
        uri, 
        headers: _defaultHeaders, 
        body: jsonEncode(data),
      );

      log("QR Login Response => ${res.body}");
      
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return MobileOtpModel.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("QR Login error: $e");
    }
    return null;
  }

  /// Forgot Password API
  static Future<Map<String, dynamic>?> forgotPassword({
    required String mobileOrClientId,
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('$_loginBaseUrl/ForgetPassword');
      
      final inputType = _getInputType(mobileOrClientId);
      
      Map<String, dynamic> data = {
        'field': inputType,
        'value': mobileOrClientId.toUpperCase(),
      };

      log("Forgot Password Request => $data");
      
      final res = await http.post(
        uri, 
        headers: _defaultHeaders, 
        body: jsonEncode(data),
      );

      log("Forgot Password Response => ${res.body}");
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Forgot Password error: $e");
      error(context, "Failed to process request. Please try again.");
    }
    return null;
  }
  /// Validate Session - Check if existing session is valid
  static Future<Map<String, dynamic>?> validateSession({
    required String clientId,
    required String apiSession,
  }) async {
    try {
      final uri = Uri.parse('$_goMyntUrl/UserDetails');
      
      final body = 'jData={"uid":"$clientId"}&jKey=$apiSession';

      log("Validate Session Request => $body");
      
      final res = await http.post(
        uri, 
        headers: {'Content-Type': 'text/plain'}, 
        body: body,
      );

      log("Validate Session Response => ${res.body}");
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Validate Session error: $e");
    }
    return null;
  }
}

/// Model for TOTP data
class TotpData {
  final String? uid;
  final String? pwd;
  final String? stat;
  final String? emsg;

  TotpData({
    this.uid,
    this.pwd,
    this.stat,
    this.emsg,
  });

  factory TotpData.fromJson(Map<String, dynamic> json) {
    return TotpData(
      uid: json['uid'] as String?,
      pwd: json['pwd'] as String?,
      stat: json['stat'] as String?,
      emsg: json['emsg'] as String?,
    );
  }

  /// Generate QR code URI for authenticator apps
  String getQrUri() {
    if (uid != null && pwd != null) {
      return 'otpauth://totp/MYNT:$uid?secret=$pwd&issuer=MYNT WEB';
    }
    return '';
  }

  bool get isValid => uid != null && pwd != null;
}
