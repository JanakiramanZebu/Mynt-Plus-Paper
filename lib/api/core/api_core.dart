import 'package:http/http.dart' show Client;

import '../../locator/locator.dart';
import '../../locator/preference.dart';
import 'api_link.dart';
// import '../../global/preferences.dart';
// import '../../locator/locator.dart';
// import 'api_link.dart';
export 'dart:convert';

mixin ApiCore {
  
  // http request
  final apiClient = Client();
  // get local storage data
  final prefs = locator<Preferences>();
  // get local variable datas from class
  final apiLinks = locator<ApiLinks>();

  Map<String, String> get defaultHeaders {
    return {
      'Content-Type': 'application/json',
      'Connection': 'keep-alive',
      'Accept': 'application/json',
    };
  }

  Map<String, String> get funddefaultHeaders {
    return {
      'Authorization': "${prefs.token}",
      'clientid': "${prefs.clientId}",
      'Content-Type': 'application/json'
    };
  }

  
  Map<String, String> get testingrameshheader {
    return {
      'Authorization': "00290a98a8d0afb10cb38afb57d83d3409efebf2227257284b56be866d514c89",
      'clientid': "TN1V2",
      'Content-Type': 'application/json'
    };
  }

  Map<String, String> get razorpaytHeaders {
    return {
      'Authorization': "${prefs.token}",
      'clientid': "${prefs.clientId}",
    };
  }

  void dispose() {
    apiClient.close();
  }
}
