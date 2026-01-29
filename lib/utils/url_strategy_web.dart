/// Web implementation for URL manipulation
/// Uses dart:html to directly update browser URL without triggering navigation

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Update browser URL using History API WITHOUT triggering Flutter navigation
/// This changes the URL in the address bar without causing a page reload or widget rebuild
void updateBrowserUrl(String urlPath) {
  // Use replaceState to update URL without adding to browser history
  // This prevents back button from cycling through all panel changes
  html.window.history.replaceState(null, '', urlPath);
}
