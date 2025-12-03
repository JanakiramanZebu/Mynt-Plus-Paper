import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/screens/web/order/place_order_screen_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Web-only imports
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/user_profile_provider.dart';
import '../../../../provider/webview_chart_provider.dart';
import '../../../../res/res.dart';
import 'chart_iframe_guard.dart';

class ChartScreenWebViews extends StatefulWidget {
  final ChartArgs chartArgs;

  const ChartScreenWebViews({
    super.key,
    required this.chartArgs,
  });

  @override
  State<ChartScreenWebViews> createState() => _ChartScreenWebViewsState();
}

class _ChartScreenWebViewsState extends State<ChartScreenWebViews> {
  final Preferences prefs = locator<Preferences>();
  SharedPreferences? sharedPrefs;
  late WidgetRef ref;
  
  // Unique identifier for this webview instance
  late String webViewType;
  bool isWebViewRegistered = false;
  
  // Flutter-side overlay to block pointer events over the iframe
  bool _blockIframe = false;
  // Track hover state to control overlay when cursor leaves without exit events
  bool _isHovering = false;
  
  // Store reference to iframe element
  html.IFrameElement? _iframeElement;
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    // Generate unique view type to avoid conflicts
    webViewType = 'chart-webview-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _registerWebView(String chartUrl) {
    if (isWebViewRegistered) return;
    
    try {
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        webViewType,
        (int viewId) {
          _iframeElement = html.IFrameElement()
            ..id = 'chart-iframe-$viewId'
            ..style.border = 'none'
            ..style.height = '100%'
            ..style.width = '100%'
            ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
            ..src = chartUrl
            // default to disabled; MouseRegion will toggle on hover
            ..style.pointerEvents = 'none';
          
          return _iframeElement!;
        },
      );
      isWebViewRegistered = true;
    } catch (e) {
      debugPrint('View factory registration error: $e');
    }
  }

  String _buildChartUrl({String? exch, String? token, String? tsym}) {
    final theme = ref.read(themeProvider);
    final useExch = exch ?? widget.chartArgs.exch;
    final useToken = token ?? widget.chartArgs.token;
    final useTsym = tsym ?? widget.chartArgs.tsym;
    return "https://mynt.zebuetrade.com/tv?src=app&symbol=$useTsym&user=${prefs.clientId}&usession=${prefs.clientSession}&token=$useToken&exch=$useExch&dark=${theme.isDarkMode}";
  }

  // Helper method to disable iframe pointer events and reset cursor
  void _disableIframeInteraction() {
    _iframeElement?.style.pointerEvents = 'none';
    _iframeElement?.style.cursor = 'default';
    // Also try to find iframe by querying DOM as fallback
    final iframes = html.document.querySelectorAll('iframe');
    for (var iframe in iframes) {
      if (iframe is html.IFrameElement) {
        iframe.style.pointerEvents = 'none';
        iframe.style.cursor = 'default';
      }
    }
    // Reset cursor on document body to ensure it's reset globally
    html.document.body?.style.cursor = 'default';
  }

  // Helper method to enable iframe pointer events
  void _enableIframeInteraction() {
    _iframeElement?.style.pointerEvents = 'auto';
    // Also try to find iframe by querying DOM as fallback
    final iframes = html.document.querySelectorAll('iframe');
    for (var iframe in iframes) {
      if (iframe is html.IFrameElement) {
        iframe.style.pointerEvents = 'auto';
      }
    }
  }

  @override
  void dispose() {
    _enableIframeInteraction(); // Restore interaction on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef widgetRef, _) {
        ref = widgetRef;

        final tvChart = ref.watch(marketWatchProvider);

        // If iframe is already created and the selected scrip changed, update src
        final newToken = tvChart.getQuotes?.token?.toString() ?? widget.chartArgs.token;
        if (_iframeElement != null && newToken != _currentToken) {
          final newUrl = _buildChartUrl(
            exch: tvChart.getQuotes?.exch,
            token: tvChart.getQuotes?.token?.toString(),
            tsym: tvChart.getQuotes?.tsym,
          );
          _iframeElement!.src = newUrl;
          _currentToken = newToken;
          // Ensure disabled when not hovering after src change
          if (!_isHovering) {
            _iframeElement!.style.pointerEvents = 'none';
            _iframeElement!.style.cursor = 'default';
          }
        }

        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top bar with navigation and controls
              // _buildTopBar(tvChart, theme, userProfile, chartUpdate),
              
              // WebView for web platform
              _buildWebView(context),
              
              const SizedBox(height: 4),
              
              // Buy/Sell buttons
             
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebView(BuildContext context) {
    // Build initial URL from current provider state if available
    final tvChart = ref.read(marketWatchProvider);
    final chartUrl = _buildChartUrl(
      exch: tvChart.getQuotes?.exch,
      token: tvChart.getQuotes?.token?.toString(),
      tsym: tvChart.getQuotes?.tsym,
    );
    
    // Register the iframe factory
    _registerWebView(chartUrl);
    
    return MouseRegion(
      onEnter: (_) {
        if (mounted && !_isHovering) {
          setState(() {
            _isHovering = true;
          });
        }
        // Enable only if not blocked by overlay/dialog
    if (!_blockIframe && !ChartIframeGuard.isLocked) {
          if (_iframeElement != null) {
            _iframeElement!.style.pointerEvents = 'auto';
          }
          // Also update all iframes as fallback
          final iframes = html.document.querySelectorAll('iframe');
          for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe') && !ChartIframeGuard.isLocked) {
              iframe.style.pointerEvents = 'auto';
            }
          }
        }
      },
      onHover: (_) {
        if (mounted && !_isHovering) {
          setState(() {
            _isHovering = true;
          });
        }
      },
      onExit: (_) {
        // Immediately disable iframe interaction and reset cursor - query DOM directly if needed
        if (_iframeElement != null) {
          _iframeElement!.style.pointerEvents = 'none';
          _iframeElement!.style.cursor = 'default';
        }
        if (mounted && _isHovering) {
          setState(() {
            _isHovering = false;
          });
        }
        // Also update all iframes as fallback
        final iframes = html.document.querySelectorAll('iframe');
        for (var iframe in iframes) {
          if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
            iframe.style.pointerEvents = 'none';
            iframe.style.cursor = 'default';
          }
        }
        // Reset cursor on document body to ensure it's reset globally
        html.document.body?.style.cursor = 'default';
      },
      child: SizedBox(
        height: (MediaQuery.of(context).size.height - 205),
        child: Stack(
          children: [
            HtmlElementView(
              key: ValueKey(webViewType),
              viewType: webViewType,
            ),
            // Show overlay whenever blocked or not hovering
            if (_blockIframe || !_isHovering)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Container(color: Colors.transparent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    
    final raw = ref.read(marketWatchProvider).getQuotes;
    await ref.read(marketWatchProvider).fetchScripInfo(
        raw!.token.toString(), raw.exch.toString(), ctx, true);
    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: raw.exch.toString(),
        tSym: raw.tsym.toString(),
        isExit: false,
        token: raw.token.toString(),
        transType: transType,
        lotSize: depthData.ls,
        ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
        perChange: depthData.pc ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});

    // Show place order screen as draggable dialog
    PlaceOrderScreenWeb.showDraggable(
      context: ctx,
      orderArg: orderArgs,
      scripInfo: ref.read(marketWatchProvider).scripInfoModel!,
      isBasket: "",
    );
  }
}
