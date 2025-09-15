import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/chart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../locator/constant.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/webview_chart_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../res/global_state_text.dart';
import '../../../main.dart';
// import '../scrip_depth_info.dart';

/// Responsive utility class for chart screen
class ChartResponsiveHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }
  
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }
  
  /// Get device information for debugging
  static Map<String, dynamic> getDeviceInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    return {
      'width': size.width,
      'height': size.height,
      'topPadding': padding.top,
      'bottomPadding': padding.bottom,
      'devicePixelRatio': devicePixelRatio,
      'isTablet': isTablet(context),
      'isLandscape': isLandscape(context),
    };
  }
  
  /// Get detailed chart height calculation info for debugging
  // static Map<String, dynamic> getChartHeightInfo(BuildContext context, {
  //   required double topBarHeight,
  //   required double spacingHeight,
  //   required double actionButtonsHeight,
  //   required double actionButtonsPadding,
  // }) {
  //   final screenSize = MediaQuery.of(context).size;
  //   final padding = MediaQuery.of(context).padding;
  //   final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  //   final isTabletDevice = isTablet(context);
  //   final isLandscapeMode = isLandscape(context);
    
  //   final availableHeight = screenSize.height - 
  //       padding.top - 
  //       padding.bottom - 
  //       topBarHeight - 
  //       spacingHeight - 
  //       actionButtonsHeight - 
  //       actionButtonsPadding;
    
  //   final baseHeight = availableHeight > 300 ? availableHeight : 300.0;
    
  //   double finalHeight = baseHeight;
  //   String reductionReason = 'No reduction applied';
    
  //        if (isLandscapeMode) {
  //      final landscapeHeight = screenSize.height;
       
  //      if (isTabletDevice) {
  //        if (landscapeHeight < 600) {
  //          finalHeight = baseHeight * 0.80;
  //          reductionReason = 'Small tablet landscape: 20% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //        } else if (landscapeHeight < 800) {
  //          finalHeight = baseHeight * 0.85;
  //          reductionReason = 'Medium tablet landscape: 15% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //        } else {
  //          finalHeight = baseHeight * 0.90;
  //          reductionReason = 'Large tablet landscape: 10% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //        }
  //      } else {
  //        if (landscapeHeight < 400) {
  //          finalHeight = baseHeight * 0.70;
  //          reductionReason = 'Very small phone landscape: 30% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //        } else if (landscapeHeight < 500) {
  //          if (devicePixelRatio >= 3.0) {
  //            finalHeight = baseHeight * 0.75;
  //            reductionReason = 'Small high DPI phone landscape: 25% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //          } else {
  //            finalHeight = baseHeight * 0.80;
  //            reductionReason = 'Small phone landscape: 20% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //          }
  //        } else if (landscapeHeight < 600) {
  //          if (devicePixelRatio >= 3.0) {
  //            finalHeight = baseHeight * 0.80;
  //            reductionReason = 'Medium high DPI phone landscape: 20% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //          } else {
  //            finalHeight = baseHeight * 0.85;
  //            reductionReason = 'Medium phone landscape: 15% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //          }
  //        } else {
  //          finalHeight = baseHeight * 0.90;
  //          reductionReason = 'Large phone landscape: 10% reduction (height: ${landscapeHeight.toStringAsFixed(0)})';
  //        }
  //      }
  //    }
    
  //   return {
  //     'screenHeight': screenSize.height,
  //     'availableHeight': availableHeight,
  //     'baseHeight': baseHeight,
  //     'finalHeight': finalHeight,
  //     'reductionReason': reductionReason,
  //     'devicePixelRatio': devicePixelRatio,
  //     'isTablet': isTabletDevice,
  //     'isLandscape': isLandscapeMode,
  //   };
  // }
  
  static double getChartHeight(BuildContext context, {
    required double topBarHeight,
    required double spacingHeight,
    required double actionButtonsHeight,
    required double actionButtonsPadding,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    
    // Get device-specific information
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isTabletDevice = isTablet(context);
    final isLandscapeMode = isLandscape(context);
    
    // Calculate base available height
    final availableHeight = screenSize.height - 
        padding.top - 
        padding.bottom - 
        topBarHeight - 
        spacingHeight - 
        actionButtonsHeight - 
        actionButtonsPadding;
    
    // Ensure minimum height for chart visibility
    final baseHeight = availableHeight > 300 ? availableHeight : 300.0;
    
    // Dynamic landscape adjustments based on actual screen dimensions
    if (isLandscapeMode) {
      // Calculate the actual screen height in landscape
      final landscapeHeight = screenSize.height;
      print("landscapeHeight1 $landscapeHeight");
      
      if (isTabletDevice) {
        // Tablets: adaptive reduction based on screen height
        if (landscapeHeight < 400) {
          return baseHeight * 0.75; // 20% reduction for small tablets
        } else if (landscapeHeight < 800) {
          return baseHeight * 0.95; // 15% reduction for medium tablets
        } else {
          return baseHeight * 0.90; // 10% reduction for large tablets
        }
      } else {
        // Phones: adaptive reduction based on screen height and pixel density
        if (landscapeHeight < 400) {
          // Very small screens (like small phones in landscape)
          return baseHeight * 0.90; // 30% reduction
        } else if (landscapeHeight < 500) {
          // Small screens
          if (devicePixelRatio >= 3.0) {
            return baseHeight * 0.70; // 25% reduction for high DPI
          } else {
            return baseHeight * 0.70; // 20% reduction for others
          }
        } else if (landscapeHeight < 600) {
          // Medium screens
          if (devicePixelRatio >= 3.0) {
            return baseHeight * 0.80; // 20% reduction for high DPI
          } else {
            return baseHeight * 0.85; // 15% reduction for others
          }
        } else {
          // Large screens
          return baseHeight * 0.90; // 10% reduction
        }
      }
    }
    
    // Additional safety check for very small screens
    final finalHeight = baseHeight < 200 ? 200.0 : baseHeight;
    
    return finalHeight;
  }
}

class ChartScreenWebView extends StatefulWidget {
  final ChartArgs chartArgs;
  final VoidCallback? onSearchTap;

  const ChartScreenWebView({
    super.key,
    required this.chartArgs,
    this.onSearchTap,
  });

  @override
  State<ChartScreenWebView> createState() => _ChartScreenWebViewState();
}

class _ChartScreenWebViewState extends State<ChartScreenWebView> {
  double progress = 0;
  final Preferences prefs = locator<Preferences>();
  SharedPreferences? sharedPrefs;
  late WidgetRef ref;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Will be initialized in build method via Consumer
      // ref initialization happens in build method now
    });
    // WidgetsBinding post-frame callback will be handled in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Any post-frame operations can be moved here if needed
  }

  // @override
  // void didUpdateWidget(covariant ChartScreenWebView oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedTab());
  // }

  // void _scrollToSelectedTab() {
  //   final tvChart = ref.read(marketWatchProvider);

  //   final selectedIndex = tvChart.chartTabs
  //       .indexWhere((tab) => tab.token == tvChart.activeTab?.token);
  //   if (_scrollController.hasClients && selectedIndex != -1) {
  //     _scrollController.animateTo(
  //       selectedIndex * 120.0, // Adjust width estimate based on Chip size
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }

  @override
  void dispose() {
    // Restore system orientation to default (allow all orientations)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    ConstantName.chartwebViewController?.dispose();
    ConstantName.chartwebViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef widgetRef, _) {
        // Store ref for use in other methods
        ref = widgetRef;

        final tvChart = ref.watch(marketWatchProvider);
        final theme = ref.watch(themeProvider);
        final userProfile = ref.watch(userProfileProvider);
        final chartUpdate = ref.watch(chartUpdateProvider);

        // Load tabs and scroll on first build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ref.read(marketWatchProvider).loadDefaultTabs();
          // ref.read(marketWatchProvider).scrollToSelectedTab(false);
        });

        bool transbtn = tvChart.getQuotes?.instname != "UNDIND" &&
            tvChart.getQuotes?.instname != "COM";
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              _buildTopBar(tvChart, theme, userProfile, chartUpdate),
              _buildWebView(
                  tvChart, theme, userProfile.showchartof, chartUpdate, context),
              const SizedBox(height: 4),
          
               if (transbtn) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ChartResponsiveHelper.isTablet(context) ? 24 : 16, // Responsive padding
                  0, 
                  ChartResponsiveHelper.isTablet(context) ? 24 : 16, 
                  0
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // IconButton(
                      //   padding: const EdgeInsets.all(0),
                      //   icon: Icon(Icons.restart_alt,
                      //       color: theme.isDarkMode
                      //           ? colors.colorWhite
                      //           : colors.colorBlack), // Back icon
                      //   onPressed: () {
                      //     ConstantName.chartwebViewController?.loadUrl(
                      //       urlRequest: URLRequest(
                      //         url: WebUri(
                      //           "https://mynt.zebuetrade.com/tv?src=app&symbol=${widget.chartArgs.tsym}&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}&exch=${widget.chartArgs.exch}&dark=${theme.isDarkMode}",
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
          
                      
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if (transbtn) {
                              await placeOrderInput(
                                  tvChart, context, tvChart.getQuotes!, true);
                            }
                          },
                          child: Container(
                            height: ChartResponsiveHelper.isTablet(context) ? 48 : 40, // Responsive height
                            decoration: BoxDecoration(
                              color: transbtn
                                  ? const Color(0xFF0037B7) // Blue color for Buy
                                  : const Color(0xFF0037B7).withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(6)),
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
                      SizedBox(width: ChartResponsiveHelper.isTablet(context) ? 24 : 18), // Responsive spacing
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if (transbtn) {
                              await placeOrderInput(
                                  tvChart, context, tvChart.getQuotes!, false);
                            }
                          },
                          child: Container(
                            height: ChartResponsiveHelper.isTablet(context) ? 48 : 40, // Responsive height
                            decoration: BoxDecoration(
                              color: transbtn
                                  ? const Color(0xFFC40024) // Red color for Sell
                                  : const Color(0xFFC40024).withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(6)),
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
                    ]),
              ) ,
               ]
            ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(
      MarketWatchProvider tvChart, theme, userProfile, chartUpdate) {
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
            SizedBox(
              width: 40,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Colors.grey.withOpacity(0.4),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  onTap: () {
                    final chartState = ref.read(chartProvider);
                    final prevRoute = chartState.previousRoute;
                    final originalArgs = chartState.originalArgs;
                    ref.read(chartProvider.notifier).hideChart();
                    
                    // Handle navigation after hiding chart
                    if (prevRoute != null && prevRoute.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          if (prevRoute == Routes.optionChain && originalArgs != null) {
                            // Use the stored original DepthInputArgs to navigate back to option chain
                            rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                              Routes.optionChain, 
                              (route) => route.settings.name == Routes.homeScreen || route.isFirst,
                              arguments: originalArgs
                            );
                          } else if (prevRoute == Routes.positionGroupDetail ||
                                     prevRoute == Routes.positionDetail ||
                                     prevRoute == Routes.holdingDetail) {
                            // For portfolio screens, navigate back without special arguments
                            rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                              prevRoute, 
                              (route) => route.settings.name == Routes.homeScreen || route.isFirst
                            );
                          } else {
                            rootNavigatorKey.currentState?.pushReplacementNamed(prevRoute);
                          }
                        }
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      size: 18,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(), // Expanded(
            //   child: ListView.separated(
            //     controller: tvChart.scrollController,
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.only(right: 8),
            //     itemCount:
            //         tvChart.chartTabs.length, // List of tabs (tokens/symbols)
            //     separatorBuilder: (_, __) => const SizedBox(width: 8),
            //     itemBuilder: (context, index) {
            //       final last = tvChart.chartTabs.first;
            //       final tab = tvChart.chartTabs[index];
            //       final isSelected = tab.token == tvChart.activeTab?.token;

            //       return InkWell(
            //         onTap: () async {
            //           await tvChart.fetchScripQuoteIndex(
            //               tab.token, tab.exch, context);
            //           tvChart.setChartScript(tab.exch, tab.token, tab.tsym);
            //         },
            //         borderRadius: BorderRadius.circular(16),
            //         child: Chip(
            //           visualDensity:
            //               const VisualDensity(vertical: -4, horizontal: 0),
            //           labelPadding: const EdgeInsets.only(right: 0),
            //           padding: index > 1
            //               ? const EdgeInsets.only(left: 16)
            //               : const EdgeInsets.symmetric(horizontal: 8),
            //           label: TextWidget.paraText(
            //               text: tab.tsym,
            //               color: theme.isDarkMode
            //                   ? Color(isSelected ? 0xff000000 : 0xffffffff)
            //                   : Color(isSelected ? 0xffffffff : 0xff000000),
            //               theme: theme.isDarkMode,
            //               fw: 0),
            //           backgroundColor: theme.isDarkMode
            //               ? (isSelected
            //                   ? const Color(0xffffffff)
            //                   : const Color(0xff000000))
            //               : (isSelected
            //                   ? const Color(0xff000000)
            //                   : const Color(0xffffffff)),
            //           shape: StadiumBorder(
            //             side: BorderSide(
            //               color: theme.isDarkMode
            //                   ? (!isSelected
            //                       ? colors.colorWhite
            //                       : colors.colorBlack)
            //                   : (isSelected
            //                       ? colors.colorWhite
            //                       : colors.colorBlack),
            //             ),
            //           ),
            //           // deleteIcon: index > 1
            //           //     ? Icon(
            //           //         Icons.close,
            //           //         size: 16,
            //           //         color: theme.isDarkMode
            //           //             ? Color(isSelected ? 0xff000000 : 0xffffffff)
            //           //             : Color(isSelected ? 0xffffffff : 0xff000000),
            //           //       )
            //           //     : null,
            //           // onDeleted: index > 1
            //           //     ? () async {
            //           //         tvChart.removeChartTab(tab, false);
            //           //         if (tvChart.activeTab?.token == tab.token) {
            //           //           await tvChart.fetchScripQuoteIndex(
            //           //               last.token, last.exch, context);
            //           //           tvChart.setChartScript(
            //           //               last.exch, last.token, last.tsym);
            //           //         }
            //           //       }
            //           //     : null,
            //           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //           // padding: const EdgeInsets.symmetric(horizontal: 8),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            Material(
              color: Colors.transparent, // Needed for ripple effect to show
              child: InkWell(
                customBorder: const CircleBorder(),// Optional: match icon shape
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.highlightDark
                    : colors.highlightLight,
                onTap: () async {
                  if (chartUpdate.orientation == 'portrait') {
                    chartUpdate.changeOrientation('landscape');
                  } else {
                    chartUpdate.changeOrientation('portrait');
                  }
                },
                child: Padding(
                  padding:
                      EdgeInsets.all(8), // Slight padding for ripple visibility
                  child: SvgPicture.asset(
                    assets.rotationIcon,
                    width: 20,
                    height: 20,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Material(
              color: Colors
                  .transparent, // Ensures ripple shows on transparent background
              child: InkWell(
               customBorder: const CircleBorder(), // Optional: for a smooth ripple
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.highlightDark
                    : colors.highlightLight,
                onTap: () async {
                  ref
                      .read(marketWatchProvider)
                      .requestMWScrip(context: context, isSubscribe: false);
                  
                  if (widget.onSearchTap != null) {
                    widget.onSearchTap!();
                  } else {
                    Navigator.of(context).pushNamed(
                      Routes.searchScrip,
                      arguments: "Chart||Is",
                    );
                  }
                  // userProfile.setChartdialog(false);
                },
                child: Padding(
                  padding:
                      EdgeInsets.all(8), // Gives space for ripple visibility
                  child: SvgPicture.asset(
                    assets.searchIcon1,
                    width: 20,
                    height: 20,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(MarketWatchProvider tvChart, theme, showchartof,
      chartUpdate, BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Calculate available height for chart using responsive helper
    final topBarHeight = 40.0;
    final spacingHeight = 4.0;
    
    // Check if transaction buttons should be shown
    final bool transbtn = tvChart.getQuotes?.instname != "UNDIND" &&
        tvChart.getQuotes?.instname != "COM";
    
    final actionButtonsHeight = transbtn ? 40.0 : 0.0;
    final actionButtonsPadding = transbtn ? 60.0 : 0.0;
    
    // Get responsive chart height
    final chartHeight = ChartResponsiveHelper.getChartHeight(
      context,
      topBarHeight: topBarHeight,
      spacingHeight: spacingHeight,
      actionButtonsHeight: actionButtonsHeight,
      actionButtonsPadding: actionButtonsPadding,
    );
    
    // Minimal safety check for landscape mode (since we have precise calculations now)
    final finalChartHeight = ChartResponsiveHelper.isLandscape(context) 
        ? chartHeight * 0.98  // Only 2% extra reduction for final safety
        : chartHeight;
    
    // // Debug: Print chart height calculation details
    // if (ChartResponsiveHelper.isLandscape(context)) {
    //   final heightInfo = ChartResponsiveHelper.getChartHeightInfo(
    //     context,
    //     topBarHeight: topBarHeight,
    //     spacingHeight: spacingHeight,
    //     actionButtonsHeight: actionButtonsHeight,
    //     actionButtonsPadding: actionButtonsPadding,
    //   );
      
    // }
    
    return SizedBox(
      height: finalChartHeight,
      width: screenWidth,
      child: InAppWebView(
        key: ref.read(userProfileProvider).webViewKey,
        gestureRecognizers: {
          // Factory<VerticalDragGestureRecognizer>(
          //     () => VerticalDragGestureRecognizer()),
          // Factory<HorizontalDragGestureRecognizer>(
          //     () => HorizontalDragGestureRecognizer()),
          // Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
          // Factory<LongPressGestureRecognizer>(
          //     () => LongPressGestureRecognizer()),

          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        initialUrlRequest: URLRequest(
          url: WebUri(
              "https://mynt.zebuetrade.com/tv?src=app&symbol=${widget.chartArgs.tsym}&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}&exch=${widget.chartArgs.exch}&dark=${theme.isDarkMode}"
              // "https://global-grammar-349410.web.app/?symbol=${widget.chartArgs.exch}%3A${widget.chartArgs.tsym}"
              // "&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}"
              // "&exch=${widget.chartArgs.exch}&res=${tvChart.chartDuration}&dark=${theme.isDarkMode}&showseries=Y",
              ),
        ),
        onConsoleMessage: (controller, consoleMessage) {
          ConstantName.chartwebViewController = controller;
        },
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          // Add responsive settings for better chart display
          useWideViewPort: true,
          loadWithOverviewMode: true,
          supportZoom: true,
          builtInZoomControls: true,
          displayZoomControls: false,
          // Additional responsive settings
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          // Better handling of different screen densities
          textZoom: 100,
        ),
        onWebViewCreated: (controller) {
          ConstantName.chartwebViewController = controller;
          
          // Load the chart with current user credentials
          final chartUrl = "https://mynt.zebuetrade.com/tv?src=app&symbol=${widget.chartArgs.tsym}&user=${prefs.clientId}&usession=${prefs.clientSession}&token=${widget.chartArgs.token}&exch=${widget.chartArgs.exch}&dark=${theme.isDarkMode}";
          controller.loadUrl(urlRequest: URLRequest(url: WebUri(chartUrl)));
        },
        onReceivedError: (controller, request, error) {
          ConstantName.chartwebViewController = controller;

          if (error.description.contains('recreating_view')) {
            setState(() {
              ref.read(userProfileProvider).setonloadChartdialog(true);
            });
          }
        },
        onProgressChanged: (controller, progress) async {
          WebUri? currentUrl = await controller.getUrl();

          setState(() {
            this.progress = progress / 100;
            if (ref.read(userProfileProvider).showchartof && progress == 100) {
              final mktpro = ref.read(marketWatchProvider).getQuotes;

              String redirUrl = currentUrl.toString();
              Uri url = Uri.parse(redirUrl);
              Map<String, String> queryParams = url.queryParameters;
              String? query = queryParams['token'];
              if (mktpro!.token != "" && mktpro.token.toString() != query) {
                // print("sddccdcdcdc WebUri ${currentUrl.toString()}");
                tvChart.setChartScript(mktpro.exch.toString(),
                    mktpro.token.toString(), mktpro.tsym.toString());
              }
              // print("sddccdcdcdc $progress $query");
            }
          });
        },
      ),
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    // Hide chart before opening order screen
    ref.read(chartProvider.notifier).hideChart();
    
    final raw = ref.read(marketWatchProvider).getQuotes;
    await ref
        .read(marketWatchProvider)
        .fetchScripInfo(raw!.token.toString(), raw.exch.toString(), ctx, true);
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

    // Navigator.pop(context);
    rootNavigatorKey.currentState?.pushNamed(Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
      "isBskt": '',
      "fromChart": true, // Add flag to indicate coming from chart
    });
  }
}
