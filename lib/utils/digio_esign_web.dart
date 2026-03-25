// Web implementation: calls Digio JS SDK

// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Dynamically loads the Digio JS SDK if not already loaded.
/// Returns true if SDK is available after loading.
Future<bool> _ensureDigioSdkLoaded() async {
  // Already loaded
  if (js.context['Digio'] != null) return true;

  final completer = Completer<bool>();

  // Check if script tag already exists but hasn't loaded yet
  final existing = html.document.querySelector('script[src*="digio.js"]');
  if (existing != null) {
    // Script tag exists but Digio not available - remove and reload
    existing.remove();
  }

  // Dynamically inject the script
  final script = html.ScriptElement()
    ..src = 'https://app.digio.in/sdk/v11/digio.js'
    ..type = 'text/javascript';

  script.onLoad.listen((_) {
    // Give a small delay for the script to initialize globals
    Future.delayed(const Duration(milliseconds: 300), () {
      final loaded = js.context['Digio'] != null;
      print('Digio SDK dynamic load result: $loaded');
      if (!completer.isCompleted) completer.complete(loaded);
    });
  });

  script.onError.listen((_) {
    print('Digio SDK script failed to load');
    if (!completer.isCompleted) completer.complete(false);
  });

  html.document.head?.append(script);

  // Timeout after 10 seconds
  Future.delayed(const Duration(seconds: 10), () {
    if (!completer.isCompleted) {
      print('Digio SDK load timed out');
      completer.complete(false);
    }
  });

  return completer.future;
}

/// Calls the Digio JS SDK inline for e-sign.
/// Returns 'success' if signed successfully, 'failure' otherwise.
///
/// Flutter web renders on a <canvas> inside <flt-glass-pane> that
/// covers the entire viewport with a high z-index. The Digio SDK creates its
/// overlay as regular DOM elements on <body>, which renders BEHIND Flutter.
/// Solution: temporarily lower Flutter's glass pane z-index so Digio is visible,
/// then restore it when done.
Future<String> startDigioEsign({
  required String fileId,
  required String email,
  required String session,
}) async {
  final completer = Completer<String>();

  // Ensure Digio SDK is loaded
  final sdkLoaded = await _ensureDigioSdkLoaded();
  if (!sdkLoaded) {
    print('Digio SDK could not be loaded');
    return 'failure';
  }

  // Listen for a custom DOM event dispatched by the JS callback
  StreamSubscription? sub;
  sub = html.window.on['digio-esign-result'].listen((event) {
    sub?.cancel();
    // Restore Flutter glass pane z-index
    _restoreFlutterOverlay();
    final customEvent = event as html.CustomEvent;
    final result = customEvent.detail?.toString() ?? 'failure';
    if (!completer.isCompleted) completer.complete(result);
  });

  try {
    // Lower Flutter's glass pane so Digio's overlay renders on top
    _lowerFlutterOverlay();

    // Execute everything in pure JavaScript to avoid Dart↔JS serialization issues
    final jsCode = '''
      (function() {
        try {
          var fid = "\$fileId";
          var em = "\$email";
          var sess = "\$session";
          console.log("Digio params - fileId:", fid, "email:", em, "session:", sess);
          var options = {
            environment: "production",
            callback: function(t) {
              console.log("Digio callback response:", JSON.stringify(t));
              var result = "failure";
              if (t && t.message === "Signed Successfully") {
                result = "success";
              }
              window.dispatchEvent(new CustomEvent("digio-esign-result", { detail: result }));
            },
            logo: "https://mynt.in/assets/icon/MYNT_App_Logo_v2.svg"
          };
          var digio = new Digio(options);
          digio.init();
          digio.submit(fid, em, sess);
          console.log("Digio submit called successfully");
        } catch(e) {
          console.error("Digio SDK error:", e);
          window.dispatchEvent(new CustomEvent("digio-esign-result", { detail: "failure" }));
        }
      })();
    '''
        .replaceAll(r'$fileId', _escapeJs(fileId))
        .replaceAll(r'$email', _escapeJs(email))
        .replaceAll(r'$session', _escapeJs(session));

    js.context.callMethod('eval', [jsCode]);
  } catch (e) {
    print('Digio SDK launch error: $e');
    _restoreFlutterOverlay();
    sub.cancel();
    if (!completer.isCompleted) completer.complete('failure');
  }

  // Timeout after 5 minutes if no callback fires
  Future.delayed(const Duration(minutes: 5), () {
    if (!completer.isCompleted) {
      sub?.cancel();
      _restoreFlutterOverlay();
      completer.complete('failure');
    }
  });

  return completer.future;
}

/// Lower Flutter's glass pane z-index so Digio SDK overlay is visible and interactive.
void _lowerFlutterOverlay() {
  final glassPane = html.document.querySelector('flt-glass-pane');
  if (glassPane != null && glassPane is html.HtmlElement) {
    glassPane.style.zIndex = '-1';
    glassPane.style.pointerEvents = 'none';
  }
  final flutterView = html.document.querySelector('flutter-view');
  if (flutterView != null && flutterView is html.HtmlElement) {
    flutterView.style.zIndex = '-1';
    flutterView.style.pointerEvents = 'none';
  }
}

/// Restore Flutter's glass pane after Digio overlay closes.
void _restoreFlutterOverlay() {
  final glassPane = html.document.querySelector('flt-glass-pane');
  if (glassPane != null && glassPane is html.HtmlElement) {
    glassPane.style.zIndex = '';
    glassPane.style.pointerEvents = '';
  }
  final flutterView = html.document.querySelector('flutter-view');
  if (flutterView != null && flutterView is html.HtmlElement) {
    flutterView.style.zIndex = '';
    flutterView.style.pointerEvents = '';
  }
}

/// Escape string for safe JS string interpolation
String _escapeJs(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r');
}

// ═══════════════════════════════════════════════════════════════════════
//  DIGILOCKER OAUTH HELPERS (same-window redirect, like Vue)
// ═══════════════════════════════════════════════════════════════════════

/// Opens Digilocker OAuth in a new browser tab.
/// After auth, Digilocker redirects back to profile.mynt.in/profile?code=xxx&state=yyy.
/// The Flutter app reads code/state from URL on reload and calls the API.
void launchDigilockerAuth() {
  final stateId =
      'signup${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  final url = 'https://api.digitallocker.gov.in/public/oauth2/1/authorize'
      '?response_type=code&client_id=A987F208'
      '&state=$stateId';

  // Open in new tab
  html.window.open(url, '_blank');
}

/// Check if current URL has Digilocker callback params (code & state).
/// Returns {'code': '...', 'state': '...'} if present, null otherwise.
Map<String, String>? getDigilockerCallbackParams() {
  final uri = Uri.parse(html.window.location.href);
  final code = uri.queryParameters['code'];
  final state = uri.queryParameters['state'];
  if (code != null && code.isNotEmpty && state != null && state.isNotEmpty) {
    return {'code': code, 'state': state};
  }
  return null;
}

/// Clear the code/state query params from the URL (so it doesn't re-trigger on refresh).
void clearDigilockerCallbackParams() {
  final uri = Uri.parse(html.window.location.href);
  // Remove code and state from query params
  final cleanParams = Map<String, String>.from(uri.queryParameters)
    ..remove('code')
    ..remove('state');
  final cleanUri = uri.replace(queryParameters: cleanParams.isEmpty ? null : cleanParams);
  // Replace URL without reloading the page
  html.window.history.replaceState(null, '', cleanUri.toString());
}
