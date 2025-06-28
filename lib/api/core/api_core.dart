import 'dart:async';
import 'package:http/http.dart'
    show BaseClient, BaseRequest, Client, StreamedResponse;

import '../../locator/locator.dart';
import '../../locator/preference.dart';
import 'api_link.dart';
// import '../../global/preferences.dart';
// import '../../locator/locator.dart';
// import 'api_link.dart';
export 'dart:convert';

class _ConditionalTimeoutClient extends BaseClient {
  final Client _inner;
  final Duration _timeout;

  final List<String> _timeoutBaseUrls = const [
    'https://go.mynt.in/NorenWClient',
    'https://be.mynt.in/',
    'https://ws.mynt.in/'
  ];

  _ConditionalTimeoutClient(this._inner,
      {Duration timeout = const Duration(seconds: 10)})
      : _timeout = timeout;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final urlString = request.url.toString();

    final bool shouldApplyTimeout =
        _timeoutBaseUrls.any((baseUrl) => urlString.startsWith(baseUrl));

    if (shouldApplyTimeout) {
      return _inner.send(request).timeout(_timeout);
    } else {
      return _inner.send(request);
    }
  }

  @override
  void close() {
    _inner.close();
  }
}

mixin ApiCore {
  
  // http request
  final _apiClient = Client();
  // get local storage data
  final prefs = locator<Preferences>();
  // get local variable datas from class
  final apiLinks = locator<ApiLinks>();

  Client get apiClient => _ConditionalTimeoutClient(_apiClient);

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
    _apiClient.close();
  }
}
