import 'dart:io';

/// Applies permissive HTTP overrides to accept bad SSL certificates.
/// This is used for mobile/desktop targets only. On web, this is a no-op
/// via the stub file `http_overrides_stub.dart`.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void applyHttpOverrides() {
  HttpOverrides.global = MyHttpOverrides();
}
