/// Stub implementation for non-web platforms
/// This file is used on mobile (iOS/Android) where dart:html is not available

/// No-op on mobile - URL manipulation is only for web
void updateBrowserUrl(String urlPath) {
  // No-op on mobile platforms
}

/// No-op on mobile
void replaceBrowserUrl(String urlPath) {
  // No-op on mobile platforms
}

/// No-op on mobile - returns a no-op cancel function
Function onPopState(void Function(String path) callback) {
  return () {}; // No-op cancel function
}

/// Returns empty string on mobile
String getCurrentPath() {
  return '';
}
