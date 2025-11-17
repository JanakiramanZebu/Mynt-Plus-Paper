import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../../routes/route_names.dart';
import '../../../../res/global_state_text.dart';

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

  // Helper method to disable iframe pointer events
  void _disableIframeInteraction() {
    _iframeElement?.style.pointerEvents = 'none';
    // Also try to find iframe by querying DOM as fallback
    final iframes = html.document.querySelectorAll('iframe');
    for (var iframe in iframes) {
      if (iframe is html.IFrameElement) {
        iframe.style.pointerEvents = 'none';
      }
    }
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
        final theme = ref.watch(themeProvider);
        final userProfile = ref.watch(userProfileProvider);
        final chartUpdate = ref.watch(chartUpdateProvider);

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

  Widget _buildTopBar(
       MarketWatchProvider tvChart, theme, userProfile, chartUpdate) {
        bool transbtn = tvChart.getQuotes?.instname != "UNDIND" &&
            tvChart.getQuotes?.instname != "COM";
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        height: 40,
        child: Row(
          children: [
            // SizedBox(
            //   width: 40,
            //   child: Material(
            //     color: Colors.transparent,
            //     shape: const CircleBorder(),
            //     clipBehavior: Clip.hardEdge,
            //     child: InkWell(
            //       customBorder: const CircleBorder(),
            //       splashColor: Colors.grey.withOpacity(0.4),
            //       highlightColor: Colors.grey.withOpacity(0.2),
            //       onTap: () async {
            //         await Future.delayed(const Duration(milliseconds: 150));
            //         userProfile.setChartdialog(false);
            //         if (tvChart.scripsize) {
            //           tvChart.chngDephBtn("Overview");
            //         } else {
            //           tvChart.chngDephBtn("Overview");
            //           tvChart.singlePageloader(true);
            //           await tvChart.calldepthApis(
            //               context, tvChart.getQuotes, "");
            //           tvChart.singlePageloader(false);
            //         }
            //         tvChart.setChartScript('ABC', '0123', 'ABCD');
            //         chartUpdate.changeOrientation('portrait');
            //       },
            //       child: Container(
            //         width: 44,
            //         height: 44,
            //         alignment: Alignment.center,
            //         child: Icon(
            //           Icons.arrow_back_ios_outlined,
            //           size: 18,
            //           color: theme.isDarkMode
            //               ? colors.textSecondaryDark
            //               : colors.textSecondaryLight,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const Spacer(),
            //  if (transbtn) ...[
            //     _buildTransactionButtons(tvChart, theme, userProfile, context),
            //   ],
            // Rotate icon - COMMENTED OUT (not needed)
            // Material(
            //   color: Colors.transparent,
            //   child: InkWell(
            //     customBorder: const CircleBorder(),
            //     splashColor: theme.isDarkMode
            //         ? colors.splashColorDark
            //         : colors.splashColorLight,
            //     highlightColor: theme.isDarkMode
            //         ? colors.highlightDark
            //         : colors.highlightLight,
            //     onTap: () async {
            //       if (chartUpdate.orientation == 'portrait') {
            //         chartUpdate.changeOrientation('landscape');
            //       } else {
            //         chartUpdate.changeOrientation('portrait');
            //       }
            //     },
            //     child: Padding(
            //       padding: const EdgeInsets.all(8),
            //       child: SvgPicture.asset(
            //         assets.rotationIcon,
            //         width: 20,
            //         height: 20,
            //         color: theme.isDarkMode
            //             ? colors.textSecondaryDark
            //             : colors.textSecondaryLight,
            //       ),
            //     ),
            //   ),
            // ),
            // Search icon - COMMENTED OUT (moved to chart_with_depth_web.dart header)
            // Material(
            //   color: Colors.transparent,
            //   child: InkWell(
            //     customBorder: const CircleBorder(),
            //     splashColor: theme.isDarkMode
            //         ? colors.splashColorDark
            //         : colors.splashColorLight,
            //     highlightColor: theme.isDarkMode
            //         ? colors.highlightDark
            //         : colors.highlightLight,
            //     onTap: () async {
            //       // Block iframe immediately before navigation
            //       if (mounted) {
            //         setState(() {
            //           _blockIframe = true;
            //         });
            //       }
            //       _disableIframeInteraction();
            //       ref
            //           .read(marketWatchProvider)
            //           .requestMWScrip(context: context, isSubscribe: false);
            //       await Navigator.pushNamed(
            //         context,
            //         Routes.searchScrip,
            //         arguments: "Chart||Is",
            //       );
            //       // Unblock after returning
            //       _enableIframeInteraction();
            //       if (mounted) {
            //         setState(() {
            //           _blockIframe = false;
            //         });
            //       }
            //     },
            //     child: Padding(
            //       padding: const EdgeInsets.all(8),
            //       child: SvgPicture.asset(
            //         assets.searchIcon1,
            //         width: 20,
            //         height: 20,
            //         color: theme.isDarkMode
            //             ? colors.textSecondaryDark
            //             : colors.textSecondaryLight,
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
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
        if (!_blockIframe) {
          if (_iframeElement != null) {
            _iframeElement!.style.pointerEvents = 'auto';
          }
          // Also update all iframes as fallback
          final iframes = html.document.querySelectorAll('iframe');
          for (var iframe in iframes) {
            if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
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
        // Immediately disable iframe interaction - query DOM directly if needed
        if (_iframeElement != null) {
          _iframeElement!.style.pointerEvents = 'none';
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
          }
        }
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

  Widget _buildTransactionButtons(
      MarketWatchProvider tvChart, theme, userProfile, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            height: 35,
            child: InkWell(
              onTap: () async {
                userProfile.setChartdialog(false);
                await placeOrderInput(
                    tvChart, context, tvChart.getQuotes!, true);
              },
              child: Container(
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF0037B7),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Center(
                  child: TextWidget.subText(
                    text: "Buy",
                    color: const Color(0XFFFFFFFF),
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 100,
            height: 35,
            child: InkWell(
              onTap: () async {
                userProfile.setChartdialog(false);
                await placeOrderInput(
                    tvChart, context, tvChart.getQuotes!, false);
              },
              child: Container(
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFC40024),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Center(
                  child: TextWidget.subText(
                    text: "Sell",
                    color: const Color(0XFFFFFFFF),
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    
    // Disable pointer events on iframe before showing dialog
    _disableIframeInteraction();
    if (mounted) {
      setState(() {
        _blockIframe = true;
      });
    }
    
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
    
    // Re-enable pointer events on iframe after dialog closes
    _enableIframeInteraction();
    if (mounted) {
      setState(() {
        _blockIframe = false;
      });
    }
  }
}
