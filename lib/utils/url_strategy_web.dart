/// Web implementation for URL manipulation
/// Uses dart:html to directly update browser URL without triggering navigation

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Update browser URL using History API WITHOUT triggering Flutter navigation
/// Uses pushState to add entry to browser history (supports back button)
void updateBrowserUrl(String urlPath) {
  // Get current URL to avoid duplicate pushState calls
  final currentPath = html.window.location.pathname ?? '';

  // Only push if the path is actually different
  if (currentPath != urlPath) {
    html.window.history.pushState({'path': urlPath}, '', urlPath);
  }
}

/// Replace current URL without adding to history
/// Use this for URL updates that shouldn't be navigable via back button
void replaceBrowserUrl(String urlPath) {
  html.window.history.replaceState({'path': urlPath}, '', urlPath);
}

/// Listen for browser back/forward button events
/// Returns a function to cancel the listener
Function onPopState(void Function(String path) callback) {
  void handler(html.Event event) {
    final path = html.window.location.pathname ?? '/';
    callback(path);
  }

  html.window.addEventListener('popstate', handler);

  // Return cancel function
  return () {
    html.window.removeEventListener('popstate', handler);
  };
}

/// Get current URL path
String getCurrentPath() {
  return html.window.location.pathname ?? '/';
}
