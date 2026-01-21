import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import '../../../locator/locator.dart';
import '../../../locator/preference.dart';

/// Singleton manager for the web chart iframe.
/// Loads once when app starts, then just shows/hides and changes symbol via postMessage.
class WebChartManager {
  static final WebChartManager _instance = WebChartManager._internal();
  factory WebChartManager() => _instance;
  WebChartManager._internal();

  static const String viewType = 'web-chart-singleton';

  html.IFrameElement? _iframe;
  bool _isRegistered = false;
  String? _currentToken;
  bool _isVisible = false;
  bool _hasUserChangedSymbol = false; // Track if user has changed symbol at least once

  // Pending symbol to use when iframe is created (if changeSymbol called before iframe ready)
  Map<String, dynamic>? _pendingSymbol;

  // Callback to notify UI when visibility changes
  VoidCallback? onVisibilityChanged;

  bool get isVisible => _isVisible;
  String? get currentToken => _currentToken;

  /// Initialize the iframe (call once when app starts)
  void initialize() {
    if (_isRegistered) return;

    final prefs = locator<Preferences>();

    try {
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          // Check if there's a pending symbol change - use that URL instead of default
          String initialUrl;
          if (_pendingSymbol != null) {
            initialUrl = _buildUrl(
              exch: _pendingSymbol!['exch'],
              token: _pendingSymbol!['token'],
              tsym: _pendingSymbol!['tsym'],
              isDarkMode: _pendingSymbol!['isDarkMode'],
              prefs: prefs,
            );
            _currentToken = _pendingSymbol!['token'];
            _hasUserChangedSymbol = true;
            debugPrint('WebChartManager: Creating iframe with pending symbol: ${_pendingSymbol!['tsym']}');
            // NOTE: Don't clear _pendingSymbol - keep it so subsequent iframes
            // also use the correct symbol (multiple HtmlElementView widgets may exist)
          } else {
            // Default to Nifty 50
            initialUrl = _buildUrl(
              exch: 'NSE',
              token: '26000',
              tsym: 'Nifty 50',
              isDarkMode: false,
              prefs: prefs,
            );
            _currentToken = '26000';
          }

          _iframe = html.IFrameElement()
            ..id = 'web-chart-iframe-$viewId'  // Unique ID per iframe
            ..style.border = 'none'
            ..style.height = '100%'
            ..style.width = '100%'
            ..style.pointerEvents = 'auto'
            ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
            ..src = initialUrl;

          debugPrint('WebChartManager: Iframe #$viewId created with URL for token: $_currentToken');
          return _iframe!;
        },
      );
      _isRegistered = true;
      debugPrint('WebChartManager: Iframe factory registered');
    } catch (e) {
      debugPrint('WebChartManager: Registration error: $e');
    }
  }

  /// Show the chart overlay
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      onVisibilityChanged?.call();
      debugPrint('WebChartManager: Chart shown');
    }
  }

  /// Hide the chart overlay
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      onVisibilityChanged?.call();
      debugPrint('WebChartManager: Chart hidden');
    }
  }

  /// Change symbol - uses URL reload for first change, postMessage for subsequent
  void changeSymbol({
    required String exch,
    required String token,
    required String tsym,
    required bool isDarkMode,
  }) {
    // Skip if same token
    if (token == _currentToken) {
      debugPrint('WebChartManager: Same token ($token), skipping');
      return;
    }

    debugPrint('WebChartManager: Changing symbol from $_currentToken to $token ($tsym)');
    _currentToken = token;

    // ALWAYS store as pending symbol - this ensures any NEW iframe created
    // (e.g., when panel renders ChartScreenWebViews) will use the correct symbol
    _pendingSymbol = {
      'exch': exch,
      'token': token,
      'tsym': tsym,
      'isDarkMode': isDarkMode,
    };

    // If iframe not ready yet, we're done - pending symbol will be used when created
    if (_iframe == null) {
      debugPrint('WebChartManager: Iframe not ready, stored pending symbol: $tsym');
      return;
    }

    // For the FIRST user symbol change, reload iframe URL because TradingView
    // widget might not be ready to receive postMessage yet
    if (!_hasUserChangedSymbol) {
      _hasUserChangedSymbol = true;
      debugPrint('WebChartManager: First symbol change, reloading iframe URL');
      _reloadWithUrl(exch, token, tsym, isDarkMode);
      return;
    }

    // For subsequent changes, use postMessage (faster, no reload)
    final message = {
      'action': 'changeScript',
      'exch': exch,
      'token': token,
      'tsym': tsym,
      'dark': isDarkMode.toString(),
    };

    try {
      _iframe!.contentWindow?.postMessage(message, '*');
      debugPrint('WebChartManager: Posted changeSymbol: $message');
    } catch (e) {
      debugPrint('WebChartManager: postMessage failed: $e');
      // Fallback: reload iframe with new URL
      _reloadWithUrl(exch, token, tsym, isDarkMode);
    }
  }

  /// Show chart with a specific symbol
  void showWithSymbol({
    required String exch,
    required String token,
    required String tsym,
    required bool isDarkMode,
  }) {
    changeSymbol(exch: exch, token: token, tsym: tsym, isDarkMode: isDarkMode);
    show();
  }

  /// Fallback: reload iframe with new URL
  void _reloadWithUrl(String exch, String token, String tsym, bool isDarkMode) {
    if (_iframe == null) return;
    final prefs = locator<Preferences>();
    _iframe!.src = _buildUrl(
      exch: exch,
      token: token,
      tsym: tsym,
      isDarkMode: isDarkMode,
      prefs: prefs,
    );
  }

  String _buildUrl({
    required String exch,
    required String token,
    required String tsym,
    required bool isDarkMode,
    required Preferences prefs,
  }) {
    // Add timestamp for cache-busting to ensure fresh load when symbol changes
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "https://mynt.zebuetrade.com/tv?src=app&symbol=$tsym&user=${prefs.clientId}&usession=${prefs.clientSession}&token=$token&exch=$exch&dark=$isDarkMode&_t=$timestamp";
  }
}

/// Global instance for easy access
final webChartManager = WebChartManager();
