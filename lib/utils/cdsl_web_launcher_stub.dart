// Stub implementation for non-web platforms

import 'package:flutter/widgets.dart';

// No-op on mobile - InAppWebView handles CDSL on mobile
void openCdslInPopup(Map data, {Function? onPopupClosed}) {}
void closeCdslPopup() {}
void openCdslFormInNewTab(Map data) {}
String setupCdslIframe(Map data) => '';
Widget buildCdslIframeView(String viewId) => const SizedBox();
