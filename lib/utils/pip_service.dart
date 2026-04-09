// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/widgets.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/utils/custom_navigator.dart';

/// Global ValueNotifier for PiP visibility - reactive updates across the app
final pipVisibilityNotifier = ValueNotifier<bool>(false);

/// Represents a single position item in the PiP window.
class PipPositionItem {
  final String symbol;
  final String pnl;

  const PipPositionItem({required this.symbol, required this.pnl});
}

/// Service to manage Document Picture-in-Picture window for live P&L display.
///
/// Uses the Document PiP API (Chrome 116+) to show a floating always-on-top
/// window with Total P&L and individual position P&L values
/// that persists across browser tabs.
///
/// Tab sleep detection uses the Page Lifecycle API (freeze/resume events)
/// to show a "Paused" badge only when the browser actually suspends the tab.
class PipService {
  static JSObject? _pipWindow;
  static JSFunction? _freezeHandler;
  static JSFunction? _resumeHandler;
  static JSFunction? _messageHandler;

  /// Whether the Document PiP API is supported in the current browser.
  static bool get isSupported {
    return globalContext.has('documentPictureInPicture');
  }

  /// Opens the PiP window with initial P&L values and position items.
  static Future<bool> openPipWindow({
    String pnl = '0.00',
    String mtm = '0.00',
    List<PipPositionItem> positions = const [],
  }) async {
    if (!isSupported) {
      debugPrint('Document PiP API not supported in this browser');
      return false;
    }

    try {
      // Close existing PiP window if any
      await closePipWindow();

      // Get documentPictureInPicture from window
      final docPip = globalContext['documentPictureInPicture'] as JSObject;

      // Adjust height based on number of positions
      final itemCount = 1 + positions.length; // Total P&L + positions
      final height = 80 + (itemCount * 30).clamp(30, 300); // header + button + items

      // Call requestWindow({ width, height })
      final options = JSObject();
      options['width'] = 320.toJS;
      options['height'] = height.toJS;
      final windowPromise =
          docPip.callMethod('requestWindow'.toJS, options) as JSPromise;
      final pipWindowJs = await windowPromise.toDart;

      _pipWindow = pipWindowJs as JSObject;

      // Build HTML content
      final htmlContent = _buildHtmlContent(pnl, mtm, positions);

      // Inject content into PiP window's document body via eval
      final jsCode = '''
        (function(win) {
          var doc = win.document;
          doc.body.innerHTML = ${_escapeJsString(htmlContent)};

          // Add script for live updates + freeze/resume handling
          var script = doc.createElement('script');
          script.textContent = ${_escapeJsString(_updateListenerScript())};
          doc.head.appendChild(script);
        })
      ''';

      // Execute the setup function with the PiP window
      final setupFn = globalContext.callMethod('eval'.toJS, jsCode.toJS);
      (setupFn as JSFunction).callAsFunction(null, _pipWindow!);

      // Listen for PiP window close → sync state
      final onClose = ((JSAny? event) {
        _pipWindow = null;
        _removeFreezeResumeListeners();
        _removeMessageListener();
        pipVisibilityNotifier.value = false;
        debugPrint('PiP window closed');
      }).toJS;
      _pipWindow!.callMethod('addEventListener'.toJS, 'pagehide'.toJS, onClose);

      // Listen for messages FROM the PiP window (e.g., "Open Positions" button click)
      _setupMessageListener();

      // Register freeze/resume listeners on the MAIN document
      _setupFreezeResumeListeners();

      pipVisibilityNotifier.value = true;
      debugPrint('PiP window opened successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to open PiP window: $e');
      pipVisibilityNotifier.value = false;
      return false;
    }
  }

  /// Listens for messages from the PiP window back to the main tab.
  /// The "Open Positions" button in PiP sends a postMessage to window.opener.
  static void _setupMessageListener() {
    _removeMessageListener();
    _messageHandler = ((JSAny? event) {
      final messageEvent = event as JSObject;
      final data = messageEvent['data'];
      if (data == null) return;
      final dataObj = data as JSObject;
      final type = (dataObj['type'] as JSString?)?.toDart;
      if (type == 'mynt_pip_open_positions') {
        debugPrint('PiP: Open Positions button clicked — navigating');
        // Close PiP first
        closePipWindow();
        // Navigate to positions screen in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (WebNavigationHelper.isAvailable) {
            WebNavigationHelper.navigateTo(Routes.positionscreen);
          }
        });
      }
    }).toJS;
    globalContext.callMethod(
        'addEventListener'.toJS, 'message'.toJS, _messageHandler!);
  }

  /// Removes message listener from the main window.
  static void _removeMessageListener() {
    if (_messageHandler != null) {
      try {
        globalContext.callMethod(
            'removeEventListener'.toJS, 'message'.toJS, _messageHandler!);
      } catch (_) {}
      _messageHandler = null;
    }
  }

  /// Registers freeze/resume listeners on the main document.
  static void _setupFreezeResumeListeners() {
    _removeFreezeResumeListeners();

    final doc = globalContext['document'] as JSObject;

    _freezeHandler = ((JSAny? event) {
      if (_pipWindow == null) return;
      final data = JSObject();
      data['type'] = 'mynt_pip_freeze'.toJS;
      _pipWindow!.callMethod('postMessage'.toJS, data, '*'.toJS);
      debugPrint('PiP: Tab frozen — sent pause signal');
    }).toJS;

    _resumeHandler = ((JSAny? event) {
      if (_pipWindow == null) return;
      final data = JSObject();
      data['type'] = 'mynt_pip_resume'.toJS;
      _pipWindow!.callMethod('postMessage'.toJS, data, '*'.toJS);
      debugPrint('PiP: Tab resumed — sent resume signal');
    }).toJS;

    doc.callMethod('addEventListener'.toJS, 'freeze'.toJS, _freezeHandler!);
    doc.callMethod('addEventListener'.toJS, 'resume'.toJS, _resumeHandler!);
  }

  /// Removes freeze/resume listeners from the main document.
  static void _removeFreezeResumeListeners() {
    if (_freezeHandler != null || _resumeHandler != null) {
      try {
        final doc = globalContext['document'] as JSObject;
        if (_freezeHandler != null) {
          doc.callMethod(
              'removeEventListener'.toJS, 'freeze'.toJS, _freezeHandler!);
        }
        if (_resumeHandler != null) {
          doc.callMethod(
              'removeEventListener'.toJS, 'resume'.toJS, _resumeHandler!);
        }
      } catch (_) {}
      _freezeHandler = null;
      _resumeHandler = null;
    }
  }

  /// Closes the PiP window if open.
  static Future<void> closePipWindow() async {
    try {
      _removeFreezeResumeListeners();
      _removeMessageListener();
      if (_pipWindow != null) {
        _pipWindow!.callMethod('close'.toJS);
        _pipWindow = null;
        pipVisibilityNotifier.value = false;
      }
    } catch (e) {
      debugPrint('Error closing PiP window: $e');
      _pipWindow = null;
      pipVisibilityNotifier.value = false;
    }
  }

  /// Sends updated P&L, MTM, and position values to the PiP window.
  static void updatePipValues(
    String pnl,
    String mtm, {
    List<PipPositionItem> positions = const [],
  }) {
    if (_pipWindow == null) return;

    try {
      final data = JSObject();
      data['type'] = 'mynt_pip_update'.toJS;
      data['pnl'] = pnl.toJS;
      data['mtm'] = mtm.toJS;

      // Build positions array as JSON string for easy parsing in JS
      final posJson = StringBuffer('[');
      for (var i = 0; i < positions.length; i++) {
        if (i > 0) posJson.write(',');
        final sym = positions[i].symbol.replaceAll('"', '\\"');
        posJson.write('{"symbol":"$sym","pnl":"${positions[i].pnl}"}');
      }
      posJson.write(']');
      data['positions'] = posJson.toString().toJS;

      _pipWindow!.callMethod('postMessage'.toJS, data, '*'.toJS);
    } catch (e) {
      debugPrint('Error updating PiP values: $e');
    }
  }

  /// Whether PiP window is currently open.
  static bool get isOpen => _pipWindow != null;

  /// Toggle PiP on/off.
  static Future<void> togglePip({
    String pnl = '0.00',
    String mtm = '0.00',
    List<PipPositionItem> positions = const [],
  }) async {
    if (isOpen) {
      await closePipWindow();
    } else {
      await openPipWindow(pnl: pnl, mtm: mtm, positions: positions);
    }
  }

  /// Escapes a Dart string for safe embedding in JavaScript code as a string literal.
  static String _escapeJsString(String s) {
    final escaped = s
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
    return "'$escaped'";
  }

  /// Builds the HTML content string for the PiP window body.
  static String _buildHtmlContent(
      String pnl, String mtm, List<PipPositionItem> positions) {
    final pnlColor = _getColor(pnl);
    final formattedPnl = _formatIndian(pnl);

    final buf = StringBuffer();

    // Styles
    buf.write('<style>'
        '* { margin: 0; padding: 0; box-sizing: border-box; }'
        'body {'
        '  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;'
        '  background: #ffffff;'
        '  padding: 10px 12px;'
        '  user-select: none;'
        '  overflow-y: auto;'
        '  overflow-x: hidden;'
        '}'
        'body::-webkit-scrollbar { width: 4px; }'
        'body::-webkit-scrollbar-track { background: transparent; }'
        'body::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 2px; }'
        '.header {'
        '  display: flex;'
        '  justify-content: space-between;'
        '  align-items: center;'
        '  font-size: 11px;'
        '  font-weight: 600;'
        '  color: #6b7280;'
        '  text-transform: uppercase;'
        '  letter-spacing: 0.5px;'
        '  margin-bottom: 8px;'
        '  padding-bottom: 6px;'
        '  border-bottom: 1px solid #e5e7eb;'
        '}'
        '.open-btn {'
        '  font-size: 10px;'
        '  font-weight: 600;'
        '  color: #3b82f6;'
        '  cursor: pointer;'
        '  text-transform: uppercase;'
        '  letter-spacing: 0.3px;'
        '  border: none;'
        '  background: none;'
        '  padding: 2px 6px;'
        '  border-radius: 3px;'
        '}'
        '.open-btn:hover {'
        '  background: #eff6ff;'
        '  color: #2563eb;'
        '}'
        '.stat-row {'
        '  display: flex;'
        '  justify-content: space-between;'
        '  align-items: center;'
        '  padding: 4px 0;'
        '}'
        '.stat-row.total {'
        '  padding: 5px 0;'
        '  font-size: 13px;'
        '}'
        '.divider {'
        '  height: 1px;'
        '  background: #f3f4f6;'
        '  margin: 4px 0;'
        '}'
        '.stat-label {'
        '  font-size: 12px;'
        '  font-weight: 500;'
        '  color: #6b7280;'
        '}'
        '.stat-label.total-label {'
        '  font-weight: 600;'
        '  color: #374151;'
        '}'
        '.stat-value {'
        '  font-size: 13px;'
        '  font-weight: 600;'
        '  font-variant-numeric: tabular-nums;'
        '}'
        '.stat-value.total-value { font-size: 14px; }'
        '.pos-label {'
        '  font-size: 11px;'
        '  font-weight: 500;'
        '  color: #9ca3af;'
        '}'
        '.pos-value {'
        '  font-size: 12px;'
        '  font-weight: 600;'
        '  font-variant-numeric: tabular-nums;'
        '}'
        '.profit { color: #16a34a; }'
        '.loss { color: #dc2626; }'
        '.neutral { color: #6b7280; }'
        '.stale-badge {'
        '  display: none;'
        '  font-size: 9px;'
        '  font-weight: 600;'
        '  color: #f59e0b;'
        '  text-transform: uppercase;'
        '  letter-spacing: 0.5px;'
        '}'
        '.stale-badge.visible { display: inline; }'
        '</style>');

    // Header with "Open Positions" button and stale indicator
    buf.write('<div class="header">'
        '<span>Mynt by Zebu - Positions</span>'
        '<span>'
        '<span id="pip-stale" class="stale-badge">Paused</span>'
        '<button class="open-btn" id="pip-open-positions">Open</button>'
        '</span>'
        '</div>');

    // Total P&L row
    buf.write('<div class="stat-row total">'
        '  <span class="stat-label total-label">Total P&amp;L</span>'
        '  <span id="pip-pnl" class="stat-value total-value $pnlColor">\u20B9$formattedPnl</span>'
        '</div>');

    // Individual positions
    if (positions.isNotEmpty) {
      buf.write('<div class="divider"></div>');
      buf.write('<div id="pip-positions">');
      for (final pos in positions) {
        final color = _getColor(pos.pnl);
        final formatted = _formatIndian(pos.pnl);
        final escapedSymbol = pos.symbol
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;');
        buf.write('<div class="stat-row">'
            '  <span class="pos-label">$escapedSymbol</span>'
            '  <span class="pos-value $color">\u20B9$formatted</span>'
            '</div>');
      }
      buf.write('</div>');
    } else {
      buf.write('<div id="pip-positions"></div>');
    }

    return buf.toString();
  }

  /// Returns the JavaScript code for the update listener inside the PiP window.
  ///
  /// Handles message types:
  /// - `mynt_pip_update`: live P&L data from the main tab
  /// - `mynt_pip_freeze`: main tab is being frozen by the browser → show "Paused"
  /// - `mynt_pip_resume`: main tab is back → hide "Paused"
  ///
  /// Also sets up the "Open Positions" button click handler which sends
  /// a postMessage back to the opener (main tab) to trigger navigation.
  static String _updateListenerScript() {
    return 'function showPaused() {'
        '  var badge = document.getElementById("pip-stale");'
        '  if (badge) badge.className = "stale-badge visible";'
        '}'
        'function hidePaused() {'
        '  var badge = document.getElementById("pip-stale");'
        '  if (badge) badge.className = "stale-badge";'
        '}'
        // "Open Positions" button → send message to main tab
        'var openBtn = document.getElementById("pip-open-positions");'
        'if (openBtn) {'
        '  openBtn.addEventListener("click", function() {'
        '    window.opener.postMessage({ type: "mynt_pip_open_positions" }, "*");'
        '    window.opener.focus();'
        '  });'
        '}'
        'window.addEventListener("message", function(event) {'
        '  var data = event.data;'
        '  if (!data || !data.type) return;'
        '  if (data.type === "mynt_pip_freeze") {'
        '    showPaused();'
        '    return;'
        '  }'
        '  if (data.type === "mynt_pip_resume") {'
        '    hidePaused();'
        '    return;'
        '  }'
        '  if (data.type === "mynt_pip_update") {'
        '    hidePaused();'
        '    var pnlEl = document.getElementById("pip-pnl");'
        '    var posContainer = document.getElementById("pip-positions");'
        '    if (pnlEl) {'
        '      var pnlVal = parseFloat(data.pnl) || 0;'
        '      pnlEl.textContent = "\\u20B9" + formatIndian(data.pnl);'
        '      pnlEl.className = "stat-value total-value " + getColorClass(pnlVal);'
        '    }'
        '    if (posContainer && data.positions) {'
        '      try {'
        '        var positions = JSON.parse(data.positions);'
        '        var html = "";'
        '        if (positions.length > 0) {'
        '          for (var i = 0; i < positions.length; i++) {'
        '            var p = positions[i];'
        '            var val = parseFloat(p.pnl) || 0;'
        '            var colorClass = getColorClass(val);'
        '            var sym = p.symbol.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");'
        '            html += "<div class=\\"stat-row\\">"'
        '              + "<span class=\\"pos-label\\">" + sym + "</span>"'
        '              + "<span class=\\"pos-value " + colorClass + "\\">\\u20B9" + formatIndian(p.pnl) + "</span>"'
        '              + "</div>";'
        '          }'
        '        }'
        '        var divider = posContainer.previousElementSibling;'
        '        if (divider && divider.className === "divider") {'
        '          divider.style.display = positions.length > 0 ? "" : "none";'
        '        }'
        '        posContainer.innerHTML = html;'
        '      } catch(e) { console.error("PiP position parse error:", e); }'
        '    }'
        '  }'
        '});'
        'function getColorClass(val) {'
        '  if (val > 0) return "profit";'
        '  if (val < 0) return "loss";'
        '  return "neutral";'
        '}'
        'function formatIndian(numStr) {'
        '  var num = parseFloat(numStr) || 0;'
        '  var isNeg = num < 0;'
        '  num = Math.abs(num);'
        '  var parts = num.toFixed(2).split(".");'
        '  var intPart = parts[0];'
        '  var decPart = parts[1];'
        '  var lastThree = intPart.slice(-3);'
        '  var rest = intPart.slice(0, -3);'
        '  if (rest.length > 0) {'
        '    lastThree = "," + lastThree;'
        '    var formatted = rest.replace(/\\B(?=(\\d{2})+(?!\\d))/g, ",");'
        '    intPart = formatted + lastThree;'
        '  }'
        '  return (isNeg ? "-" : "") + intPart + "." + decPart;'
        '}';
  }

  /// Returns CSS class name based on value.
  static String _getColor(String value) {
    final val = double.tryParse(value) ?? 0;
    if (val > 0) return 'profit';
    if (val < 0) return 'loss';
    return 'neutral';
  }

  /// Formats number string in Indian number format (e.g., 1,23,456.78).
  static String _formatIndian(String numStr) {
    final value = double.tryParse(numStr) ?? 0;
    final isNeg = value < 0;
    final absVal = value.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    var intPart = parts[0];
    final decPart = parts[1];

    if (intPart.length > 3) {
      final lastThree = intPart.substring(intPart.length - 3);
      var rest = intPart.substring(0, intPart.length - 3);
      rest = rest.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{2})+$)'), (m) => '${m[1]},');
      intPart = '$rest,$lastThree';
    }

    return '${isNeg ? '-' : ''}$intPart.$decPart';
  }

  /// Helper to build position items list from portfolio provider data.
  static List<PipPositionItem> buildPositionItems({
    required Map groupedBySymbol,
    required List<String> groupPositionSym,
  }) {
    final items = <PipPositionItem>[];
    for (final symbol in groupPositionSym) {
      final groupData = groupedBySymbol[symbol];
      if (groupData == null) continue;
      // Skip custom groups - only show symbol-based groups
      final isCustomGrp = groupData['isCustomGrp'] ?? false;
      if (isCustomGrp) continue;
      final pnl = groupData['totPnl'] ?? '0.00';
      items.add(PipPositionItem(symbol: symbol, pnl: pnl));
    }
    return items;
  }
}
