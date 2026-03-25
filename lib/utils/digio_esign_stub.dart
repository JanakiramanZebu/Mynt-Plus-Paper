// Stub implementation for non-web platforms (no-op)

import 'dart:async';

Future<String> startDigioEsign({
  required String fileId,
  required String email,
  required String session,
}) async {
  // On mobile, Digio SDK is not available via JS - use native SDK instead
  return 'failure';
}

/// Launch Digilocker OAuth (same-window redirect) - no-op on mobile
void launchDigilockerAuth() {}

/// Check if current URL has Digilocker callback params - always null on mobile
Map<String, String>? getDigilockerCallbackParams() => null;

/// Clear Digilocker callback params from URL - no-op on mobile
void clearDigilockerCallbackParams() {}
