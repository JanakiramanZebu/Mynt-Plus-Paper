import 'package:http/http.dart' show Client;

import '../../locator/locator.dart';
import '../../locator/preference.dart';
import 'api_link.dart';
// import '../../global/preferences.dart';
// import '../../locator/locator.dart';
// import 'api_link.dart';
export 'dart:convert';

mixin ApiCore {
  final apiClient = Client();
  final prefs = locator<Preferences>();
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
