import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/foundation.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../routes/route_names.dart';
import '../../../utils/custom_navigator.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../utils/responsive_navigation.dart';
import '../../../utils/responsive_snackbar.dart';
// import '../../Mobile/market_watch/edit_scrip.dart';
// import 'edit_scrip_web.dart';
import '../../Mobile/market_watch/new_fundamental_screen.dart';
import 'futures/future_screen_web.dart';
import 'set_alert_web.dart';
import 'watchlist_screen_web.dart' show deleteModeProvider;

// Provider to manage expanded watchlist item
final expandedWatchlistItemProvider =
    StateNotifierProvider<ExpandedWatchlistItemNotifier, String?>((ref) {
  return ExpandedWatchlistItemNotifier();
});

class ExpandedWatchlistItemNotifier extends StateNotifier<String?> {
  ExpandedWatchlistItemNotifier() : super(null);

  void setExpandedToken(String? token) {
    state = token;
  }
}

class WatchlistCardWeb extends ConsumerStatefulWidget {
  final dynamic watchListData;
  const WatchlistCardWeb({super.key, required this.watchListData});

  @override
  ConsumerState<WatchlistCardWeb> createState() => _WatchlistCardWebState();
}

class _WatchlistCardWebState extends ConsumerState<WatchlistCardWeb> {
  // Add navigation lock to prevent multiple navigation events
  bool _isNavigating = false;
  bool _isHovered = false;
  bool _isExpanded = false;
  bool _isMenuOpen = false;
  final GlobalKey _menuButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final marketWatch = ref.read(marketWatchProvider);
    final depthData = ref.watch(marketWatchProvider).getQuotes!;
    final expandedToken = ref.watch(expandedWatchlistItemProvider);

    // Check if this card is expanded
    _isExpanded = expandedToken == widget.watchListData['token']?.toString();

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(8), // Increased border radius for web
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              // onLongPress: () {
              //   if (marketWatch.isPreDefWLs == "Yes") {
              //     showResponsiveWarningMessage(context,
              //         "This is a pre-defined watchlist that cannot be edited!");
              //   } else {
              //     ref
              //         .read(marketWatchProvider)
              //         .requestMWScrip(context: context, isSubscribe: false);
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) =>
              //                 EditScrip(wlName: marketWatch.wlName)));
              //   }
              // },
              onTap: () async {
                // Clicking the list item opens the chart
                if (_isNavigating) return;
                
                // Close any previously expanded item
                ref
                    .read(expandedWatchlistItemProvider.notifier)
                    .setExpandedToken(null);
                
                try {
                  setState(() {
                    _isNavigating = true;
                  });

                  // Create proper DepthInputArgs object like in StocksScreen
                  DepthInputArgs depthArgs = DepthInputArgs(
                      exch: widget.watchListData["exch"].toString(),
                      token: widget.watchListData["token"].toString(),
                      tsym: widget.watchListData["tsym"].toString(),
                      instname:
                          widget.watchListData["instname"]?.toString() ??
                              widget.watchListData["symbol"].toString(),
                      symbol: widget.watchListData["symbol"].toString(),
                      expDate:
                          widget.watchListData["expDate"]?.toString() ?? "",
                      option:
                          widget.watchListData["option"]?.toString() ?? "");

                  // Call depth APIs for chart navigation
                  marketWatch.scripdepthsize(false);
                  await marketWatch.calldepthApis(context, depthArgs, "");

                  // Open in 80% panel as split Chart + Depth via tabs manager
                  ref.read(marketWatchProvider).openScripInWebPanel(context, depthArgs, "Watchlist");
                } catch (e) {
                  // Handle any errors
                  debugPrint('Error opening chart: $e');
                } finally {
                  // Reset navigation lock after some delay to prevent immediate re-clicks
                  if (mounted) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() {
                          _isNavigating = false;
                        });
                      }
                    });
                  }
                }
              },
          child: Container(
            color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Increased padding for web
            child: Row(
              children: [
                // Left side - Symbol info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Symbol name and option
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.watchListData["symbol"]
                                .toString()
                                .replaceAll("-EQ", "")
                                .toUpperCase(),
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  :  WebColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.watchListData["option"].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                "${widget.watchListData["option"]}",
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      :  WebColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8), 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.watchListData["exch"]}',
                            style: WebTextStyles.caption(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              // height: 1.3,
                              // letterSpacing: 0.0,
                            ),
                          ),
                          if (widget.watchListData['expDate'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                " ${widget.watchListData['expDate']}",
                                style: WebTextStyles.custom(
                                  fontSize: 10,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textSecondary
                                      : WebColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  // height: 1.3,
                                  // letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          if (widget.watchListData['holdingQty'] != null &&
                              widget.watchListData['holdingQty']
                                  .toString()
                                  .isNotEmpty &&
                              widget.watchListData['holdingQty'] != "null") ...[
                            const SizedBox(width: 8),
                            SvgPicture.asset(assets.suitcase,
                                height: 14, // Slightly larger for web
                                width: 18,
                                color: theme.isDarkMode
                                    ? WebDarkColors.iconSecondary
                                    : WebColors.iconSecondary),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.watchListData['holdingQty']}",
                              style: WebTextStyles.custom(
                                fontSize: 10,
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                    : WebColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                // letterSpacing: 0.0,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side - Action buttons and price data
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Action buttons (shown on hover, when menu is open, or when expanded)
                    if (_isHovered || _isMenuOpen || _isExpanded)
                      Builder(
                        builder: (context) {
                          // Check if this is an index or commodity
                          final instname = widget.watchListData["instname"]?.toString() ?? "";
                          final isIndexOrCommodity = instname == "UNDIND" || instname == "COM";
                          
                          // Get exchange and token for futures/fundamentals/options check
                          final exch = widget.watchListData["exch"]?.toString() ?? "";
                          final token = widget.watchListData["token"]?.toString() ?? "";
                          
                          // Check if futures available (same condition as scrip_depth_info_web)
                          final hasFutures = marketWatch.getOptionawait(exch, token);
                          
                          // Check if fundamentals available (not for indices or commodities)
                          final hasFundamentals = instname != "UNDIND" && instname != "COM";
                          
                          // Check if options available (same condition as futures)
                          final hasOptions = marketWatch.getOptionawait(exch, token);
                          
                          final bool isPredefined = marketWatch.isPreDefWLs == "Yes";
                          return Container(
                            width: 200, // Adjusted to accommodate delete icon
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Only show Buy/Sell buttons if not index or commodity
                                if (!isIndexOrCommodity) ...[
                                  _buildHoverButton(
                                    label: 'B',
                                    color: Colors.white,
                                    backgroundColor: theme.isDarkMode
                                        ? WebDarkColors.primary
                                        : WebColors.primary,
                                    onPressed: () async {
                                      try {
                                        await _placeOrderInput(context, depthData, true);
                                      } catch (e) {
                                        // Additional safety catch at button level
                                        print('Buy button error: $e');
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildHoverButton(
                                    label: 'S',
                                    color: Colors.white,
                                    backgroundColor: theme.isDarkMode
                                        ? WebDarkColors.tertiary
                                        : WebColors.tertiary,
                                    onPressed: () async {
                                      try {
                                        await _placeOrderInput(context, depthData, false);
                                      } catch (e) {
                                        // Additional safety catch at button level
                                        print('Sell button error: $e');
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),

                                ],
                                // Chart button always shows (icon only)
                                _buildHoverButton(
                                  iconAsset: assets.chart,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textSecondary
                                      : WebColors.textSecondary,
                                  backgroundColor: Colors.transparent,
                                  borderColor: theme.isDarkMode
                                      ? WebDarkColors.border
                                      : WebColors.border,
                                  onPressed: () async {
                                   DepthInputArgs depthArgs = DepthInputArgs(
                                            exch: widget.watchListData["exch"]
                                                .toString(),
                                            token: widget.watchListData["token"]
                                                .toString(),
                                            tsym: widget.watchListData["tsym"]
                                                .toString(),
                                            instname: widget
                                                    .watchListData["instname"]
                                                    ?.toString() ??
                                                widget.watchListData["symbol"]
                                                    .toString(),
                                            symbol: widget
                                                .watchListData["symbol"]
                                                .toString(),
                                            expDate: widget
                                                    .watchListData["expDate"]
                                                    ?.toString() ??
                                                "",
                                            option: widget
                                                    .watchListData["option"]
                                                    ?.toString() ??
                                                "");

                                        // Only call depth APIs for full navigation, not for expansion
                                        marketWatch.scripdepthsize(false);
                                        await marketWatch.calldepthApis(
                                            context, depthArgs, "");

                                        // Open split view in 80% panel
                                        ref.read(marketWatchProvider).openScripInWebPanel(context, depthArgs, "Watchlist");
                                  },
                                ),
                                  const SizedBox(width: 6),
                                // Expand/Collapse button
                                // SizedBox(
                                //   width: 28,
                                //   height: 28,
                                //   child: Material(
                                //     color: Colors.transparent,
                                //     child: InkWell(
                                //       borderRadius: BorderRadius.circular(5),
                                //       splashColor: theme.isDarkMode
                                //           ? Colors.white.withOpacity(0.15)
                                //           : Colors.black.withOpacity(0.15),
                                //       highlightColor: theme.isDarkMode
                                //           ? Colors.white.withOpacity(0.08)
                                //           : Colors.black.withOpacity(0.08),
                                //       onTap: () {
                                //         final currentToken = widget.watchListData['token']?.toString();
                                //         if (_isExpanded) {
                                //           // Collapse - just toggle the state
                                //           ref
                                //               .read(expandedWatchlistItemProvider.notifier)
                                //               .setExpandedToken(null);
                                //         } else {
                                //           // Expand - just toggle the state (data will load when expanded content renders)
                                //           ref
                                //               .read(expandedWatchlistItemProvider.notifier)
                                //               .setExpandedToken(currentToken);
                                //         }
                                //       },
                                //       child: Container(
                                //         decoration: BoxDecoration(
                                //           color: Colors.transparent,
                                //           borderRadius: BorderRadius.circular(5),
                                //           border: Border.all(
                                //             color: theme.isDarkMode
                                //                 ? WebDarkColors.border
                                //                 : WebColors.border,
                                //             width: 1,
                                //           ),
                                //         ),
                                //         child: Center(
                                //           child: Transform.rotate(
                                //             angle: _isExpanded ? 3.14159 : 0, // 180 degrees for up, 0 for down
                                //             child: SvgPicture.asset(
                                //               assets.downArrow,
                                //               width: 8,
                                //               height: 8,
                                //               colorFilter: ColorFilter.mode(
                                //                 theme.isDarkMode
                                //                     ? WebDarkColors.textSecondary
                                //                     : WebColors.textSecondary,
                                //                 BlendMode.srcIn,
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                  const SizedBox(width: 6),
                                // Delete-one button (only for non-predefined watchlists)
                                if (!isPredefined)
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(5),
                                        splashColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(0.15)
                                            : Colors.black.withOpacity(0.15),
                                        highlightColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.08),
                                        onTap: () async {
                                          try {
                                            // Build single scrip token input: exch|token#
                                            final String exch = widget.watchListData["exch"]?.toString() ?? "";
                                            final String token = widget.watchListData["token"]?.toString() ?? "";
                                            final String input = "$exch|$token#";

                                            // Prevent multiple operations
                                            if (_isNavigating) return;
                                            setState(() { _isNavigating = true; });

                                            // Call delete single scrip API
                                            await ref
                                                .read(marketWatchProvider)
                                                .addDelMarketScrip(marketWatch.wlName, input, context, false, false, false, false);
                                            if (mounted) {
                                              showResponsiveSuccess(context, 'Scrip removed from watchlist');
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              showResponsiveError(context, 'Failed to delete scrip');
                                            }
                                          } finally {
                                            if (mounted) {
                                              Future.delayed(const Duration(milliseconds: 400), () {
                                                if (mounted) {
                                                  setState(() { _isNavigating = false; });
                                                }
                                              });
                                            }
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: theme.isDarkMode
                                                  ? WebDarkColors.border
                                                  : WebColors.border,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              assets.trash,
                                              width: 14,
                                              height: 14,
                                              colorFilter: ColorFilter.mode(
                                                theme.isDarkMode
                                                    ? WebDarkColors.iconSecondary
                                                    : WebColors.iconSecondary,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (!isPredefined) const SizedBox(width: 6),
                                // Three dots menu (only if has futures, fundamentals or options)
                                // if (hasFutures || hasFundamentals || hasOptions)
                                //   _buildThreeDotsMenu(
                                //     theme: theme,
                                //     hasFutures: hasFutures,
                                //     hasFundamentals: hasFundamentals,
                                //     hasOptions: hasOptions,
                                //     exch: exch,
                                //     token: token,
                                //     depthData: depthData,
                                //   ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox(),
                    const SizedBox(width: 16), // Increased spacing for web
                    // Price data
                    RepaintBoundary(
                      child: _PriceDataWidgetWeb(
                          token: widget.watchListData['token'],
                          initialData: widget.watchListData),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          ),
          // Expandable content section
          if (_isExpanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                // color: theme.isDarkMode ? WebDarkColors.surfaceVariant : WebColors.surfaceVariant,
                padding: const EdgeInsets.fromLTRB(16, 16, 28,
                    16), // Extra right padding to prevent scrollbar overlap
                child: _buildExpandedContent(depthData, theme),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(GetQuotes depthData, ThemesProvider theme) {
    // Get current token for this specific card
    final currentToken = widget.watchListData['token']?.toString() ?? "";

    return StreamBuilder<dynamic>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        Map<String, dynamic> socketData;

        if (snapshot.hasData) {
          final socketDatas = Map<String, dynamic>.from(snapshot.data as Map);
          socketData = socketDatas.containsKey(currentToken)
              ? Map<String, dynamic>.from(
                  socketDatas[currentToken] as Map? ?? {})
              : <String, dynamic>{};
        } else {
          final existingSocketData = ref.read(websocketProvider).socketDatas;
          socketData = existingSocketData.containsKey(currentToken)
              ? Map<String, dynamic>.from(
                  existingSocketData[currentToken] ?? {})
              : <String, dynamic>{};
        }

        // Priority: Socket data → Watchlist data → Default
        final open = socketData['o']?.toString() ??
            widget.watchListData['open']?.toString() ??
            '0.00';
        final high = socketData['h']?.toString() ??
            widget.watchListData['high']?.toString() ??
            '0.00';
        final low = socketData['l']?.toString() ??
            widget.watchListData['low']?.toString() ??
            '0.00';
        final close = socketData['c']?.toString() ??
            widget.watchListData['close']?.toString() ??
            '0.00';
        final volume = socketData['v']?.toString() ??
            widget.watchListData['volume']?.toString() ??
            '0';
        final avgPrice = socketData['ap']?.toString() ?? '0.00';

        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Open, High, Low, Prev Close in grid format (always shown)
        Column(
          children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(theme, "Open", open),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(theme, "High", high),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(theme, "Low", low),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(theme, "Prev Close", close),
                  ),
                ],
              ),
          ],
        ),
        // Market Depth Section (only for non-index/non-commodity)
        if (widget.watchListData['instname']?.toString() != "UNDIND" &&
            widget.watchListData['instname']?.toString() != "COM") ...[
          const SizedBox(height: 16),
          _buildMarketDepthSection(socketData, theme),
          const SizedBox(height: 16),
        ],
        
        // Trading Info Section
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(theme, "Avg Price", avgPrice),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(theme, "Volume", volume),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(theme, "LTQ", 
                      socketData['ltq']?.toString() ?? widget.watchListData['ltq']?.toString() ?? "0"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(theme, "LTT", 
                      socketData['ltt']?.toString() ?? widget.watchListData['ltt']?.toString() ?? "--"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Open Interest (only for futures/options, not equity)
            if (depthData.seg != "EQT") ...[
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(theme, "Open Interest", 
                        socketData['oi']?.toString() ?? widget.watchListData['oi']?.toString() ?? "0"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(theme, "Change in OI", 
                        socketData['poi']?.toString() ?? widget.watchListData['poi']?.toString() ?? "0"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // 52 Week High-Low
            _buildInfoItem(theme, "52 Weeks High-Low", 
                "${socketData['52h']?.toString() ?? widget.watchListData['52h']?.toString() ?? "0.00"} - ${socketData['52l']?.toString() ?? widget.watchListData['52l']?.toString() ?? "0.00"}"),
            const SizedBox(height: 12),
            
            // Daily Price Range (DPR)
            _buildInfoItem(theme, "DPR", 
                "${socketData['uc']?.toString() ?? widget.watchListData['uc']?.toString() ?? "0.00"} - ${socketData['lc']?.toString() ?? widget.watchListData['lc']?.toString() ?? "0.00"}"),
          ],
        ),
      ],
    );
      },
    );
  }

  // Market Depth Section with Bid/Ask data
  Widget _buildMarketDepthSection(
      Map<String, dynamic> socketData, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Market Depth Header
        // Text(
        //   "Market Depth",
        //   style: WebTextStyles.title(
        //     isDarkTheme: theme.isDarkMode,
        //     color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
        //     fontWeight: WebFonts.medium,
        //   ),
        // ),
        // const SizedBox(height: 12),
        
        Row(
          children: [
            // Bid Side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quantity",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.regular,
                          ),
                        ),
                        Text(
                          "Bid",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: WebDarkColors.secondary,
                            fontWeight: WebFonts.regular,
                          ),
                        )
                      ]),
                  const SizedBox(height: 8),
                  _buildDepthRow(socketData['bq1']?.toString() ?? "0",
                      socketData['bp1']?.toString() ?? "0.00", theme),
                  _buildDepthRow(socketData['bq2']?.toString() ?? "0",
                      socketData['bp2']?.toString() ?? "0.00", theme),
                  _buildDepthRow(socketData['bq3']?.toString() ?? "0",
                      socketData['bp3']?.toString() ?? "0.00", theme),
                  _buildDepthRow(socketData['bq4']?.toString() ?? "0",
                      socketData['bp4']?.toString() ?? "0.00", theme),
                  _buildDepthRow(socketData['bq5']?.toString() ?? "0",
                      socketData['bp5']?.toString() ?? "0.00", theme),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Ask Side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ask",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.loss
                                : WebColors.loss,
                            fontWeight: WebFonts.regular,
                          ),
                        ),
                        Text(
                          "Quantity",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.regular,
                          ),
                        )
                      ]),
                  const SizedBox(height: 8),
                  _buildDepthRow(socketData['sp1']?.toString() ?? "0.00",
                      socketData['sq1']?.toString() ?? "0", theme,
                      isAsk: true),
                  _buildDepthRow(socketData['sp2']?.toString() ?? "0.00",
                      socketData['sq2']?.toString() ?? "0", theme,
                      isAsk: true),
                  _buildDepthRow(socketData['sp3']?.toString() ?? "0.00",
                      socketData['sq3']?.toString() ?? "0", theme,
                      isAsk: true),
                  _buildDepthRow(socketData['sp4']?.toString() ?? "0.00",
                      socketData['sq4']?.toString() ?? "0", theme,
                      isAsk: true),
                  _buildDepthRow(socketData['sp5']?.toString() ?? "0.00",
                      socketData['sq5']?.toString() ?? "0", theme,
                      isAsk: true),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total Quantities
        _buildTotalQuantities(socketData, theme),
      ],
    );
  }
  
  // Helper to build total quantities with percentages
  Widget _buildTotalQuantities(Map<String, dynamic> socketData, ThemesProvider theme) {
    final scripInfo = ref.read(marketWatchProvider);
    final tbq = socketData['tbq']?.toString() ?? "0";
    final tsq = socketData['tsq']?.toString() ?? "0";
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  tbq,
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                    fontWeight: WebFonts.regular,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "(${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%)",
                  style: WebTextStyles.para(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                    fontWeight: WebFonts.regular,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "(${scripInfo.totSellQtyPer.toStringAsFixed(2)}%)",
                  style: WebTextStyles.para(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                    fontWeight: WebFonts.regular,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  tsq,
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                    fontWeight: WebFonts.regular,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (scripInfo.totBuyQtyPer.toStringAsFixed(2) != "0.00" || 
            scripInfo.totSellQtyPer.toStringAsFixed(2) != "0.00")
          Column(
            children: [
              const SizedBox(height: 10),
              LinearPercentIndicator(
                lineHeight: 5.0,
                barRadius: const Radius.circular(4.0),
                backgroundColor: theme.isDarkMode 
                    ? WebDarkColors.error 
                    : WebColors.error,
                percent: scripInfo.totBuyQtyPerChng,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                progressColor: theme.isDarkMode 
                    ? WebDarkColors.primary 
                    : WebColors.primary,
              ),
            ],
          ),
      ],
    );
  }

  // Helper to build market depth rows
  Widget _buildDepthRow(String value1, String value2, ThemesProvider theme,
      {bool isAsk = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isAsk ? value1 : value1, // Price for ask, Qty for bid
            style: WebTextStyles.para(
              isDarkTheme: theme.isDarkMode,
              color: isAsk
                  ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              fontWeight: WebFonts.regular,
            ),
          ),
          Text(
            isAsk ? value2 : value2, // Qty for ask, Price for bid
            style: WebTextStyles.para(
              isDarkTheme: theme.isDarkMode,
              color: isAsk
                  ? (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary)
                  : (theme.isDarkMode
                      ? WebDarkColors.secondary
                      : WebColors.secondary),
              fontWeight: WebFonts.regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketDepth(ThemesProvider theme, MarketWatchProvider scripInfo,
      GetQuotes depthData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quantity",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.regular,
                          ),
                        ),
                        Text(
                          "Bid",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: WebDarkColors.secondary,
                            fontWeight: WebFonts.regular,
                          ),
                        )
                      ]),
                  const SizedBox(height: 6),
                  _buildBidDepthRow("${depthData.bq1 ?? 0}",
                      "${depthData.bp1 ?? 0.00}", theme),
                  const SizedBox(height: 4),
                  _buildBidDepthRow("${depthData.bq2 ?? 0}",
                      "${depthData.bp2 ?? 0.00}", theme),
                  const SizedBox(height: 4),
                  _buildBidDepthRow("${depthData.bq3 ?? 0}",
                      "${depthData.bp3 ?? 0.00}", theme),
                  const SizedBox(height: 4),
                  _buildBidDepthRow("${depthData.bq4 ?? 0}",
                      "${depthData.bp4 ?? 0.00}", theme),
                  const SizedBox(height: 4),
                  _buildBidDepthRow("${depthData.bq5 ?? 0}",
                      "${depthData.bp5 ?? 0.00}", theme)
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ask",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.error
                                : WebColors.error,
                            fontWeight: WebFonts.regular,
                            letterSpacing: 0.0,
                          ),
                        ),
                        Text(
                          "Quantity",
                          style: WebTextStyles.para(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.regular,
                            letterSpacing: 0.0,
                          ),
                        )
                      ]),
                  const SizedBox(height: 6),
                  _buildAskDepthRow("${depthData.sp1 ?? 0.00}",
                      "${depthData.sq1 ?? 0}", theme),
                  const SizedBox(height: 4),
                  _buildAskDepthRow("${depthData.sp2 ?? 0.00}",
                      "${depthData.sq2 ?? 0}", theme),
                  const SizedBox(height: 4),
                  _buildAskDepthRow("${depthData.sp3 ?? 0.00}",
                      "${depthData.sq3 ?? 0}", theme),
                  const SizedBox(height: 4),
                  _buildAskDepthRow("${depthData.sp4 ?? 0.00}",
                      "${depthData.sq4 ?? 0}", theme),
                  const SizedBox(height: 4),
                  _buildAskDepthRow("${depthData.sp5 ?? 0.00}",
                      "${depthData.sq5 ?? 0}", theme)
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              Text(
                "${depthData.tbq != "null" ? depthData.tbq ?? 0 : '0'}",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                  fontWeight: WebFonts.regular,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                "(${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%)",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                  fontWeight: WebFonts.regular,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "(${scripInfo.totSellQtyPer.toStringAsFixed(2)}%)",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                  fontWeight: WebFonts.regular,
                  letterSpacing: 0.0,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "${depthData.tsq != "null" ? depthData.tsq ?? 0 : '0'}",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                  fontWeight: WebFonts.regular,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          )
        ]),
        (scripInfo.totBuyQtyPer.toStringAsFixed(2) == "0.00" &&
                scripInfo.totSellQtyPer.toStringAsFixed(2) == "0.00")
            ? const SizedBox()
            : Column(
                children: [
                  const SizedBox(height: 10),
                  LinearPercentIndicator(

                      // leading: Text(
                      //     "${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%",
                      //     style: textStyle(
                      //         theme.isDarkMode
                      //             ? colors
                      //                 .colorWhite
                      //             : colors
                      //                 .colorBlack,
                      //         14,
                      //         FontWeight
                      //             .w500)),
                      // trailing: Text(
                      //     "${scripInfo.totSellQtyPer.toStringAsFixed(2)}%",
                      //     style: textStyle(
                      //         theme.isDarkMode
                      //             ? colors
                      //                 .colorWhite
                      //             : colors
                      //                 .colorBlack,
                      //         14,
                      //         FontWeight
                      //             .w500)),
                      lineHeight: 5.0,
                      barRadius: const Radius.circular(
                          4.0), // Half of lineHeight for capsule shape
                      backgroundColor:
                          (scripInfo.totBuyQtyPer.toStringAsFixed(2) ==
                                      "0.00" &&
                                  scripInfo.totSellQtyPer.toStringAsFixed(2) ==
                                      "0.00")
                              ? theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary
                              : theme.isDarkMode
                                  ? WebDarkColors.error
                                  : WebColors.error,
                      percent: scripInfo.totBuyQtyPerChng,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      progressColor: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary),
                  const SizedBox(height: 16),
                ],
              ),
      ],
    );
  }

  Widget _buildBidDepthRow(String qty, String price, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          " ${qty != "null" ? qty : '0'} ",
          style: WebTextStyles.custom(
            fontSize: 12,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
            fontWeight: WebFonts.medium,
            letterSpacing: 0.0,
          ),
        ),
        Text(
          " ${price != "null" ? price : '0.00'} ",
          style: WebTextStyles.custom(
            fontSize: 12,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.secondary
                : WebColors.secondary,
            fontWeight: WebFonts.medium,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildAskDepthRow(String price, String qty, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          " ${price != "null" ? price : '0.00'} ",
          style: WebTextStyles.custom(
            fontSize: 12,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? WebDarkColors.error : WebColors.error,
            fontWeight: WebFonts.medium,
          ),
        ),
        Text(
          " ${qty != "null" ? qty : '0'} ",
          style: WebTextStyles.custom(
            fontSize: 12,
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
            fontWeight: WebFonts.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(ThemesProvider theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: WebTextStyles.para(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary,
              fontWeight: WebFonts.regular,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: WebFonts.regular,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 4),
          Divider(
            color: theme.isDarkMode
                ? WebDarkColors.divider
                : WebColors.divider,
          ),
        ],
      ),
    );
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    String? iconAsset,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    required VoidCallback? onPressed,
  }) {
    final theme = ref.read(themeProvider);
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: iconAsset != null
                  ? SvgPicture.asset(
                      iconAsset,
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        color,
                        BlendMode.srcIn,
                      ),
                    )
                  : icon != null
                      ? Icon(
                          icon,
                          size: 14,
                          color: color,
                        )
                      : Text(
                          label ?? "",
                          style: WebTextStyles.custom(
                            fontSize: 11,
                            isDarkTheme: theme.isDarkMode,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThreeDotsMenu({
    required ThemesProvider theme,
    required bool hasFutures,
    required bool hasFundamentals,
    required bool hasOptions,
    required String exch,
    required String token,
    required GetQuotes depthData,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        key: _menuButtonKey,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
          highlightColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          onTap: () {
            setState(() {
              _isMenuOpen = true;
            });
            
            // Use GlobalKey to get the correct render box position
            final RenderBox? button = _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
            if (button == null || !button.attached) return;
            
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            
            // Get the button's position in overlay coordinates
            final Offset buttonTopLeft = button.localToGlobal(
              Offset.zero,
              ancestor: overlay,
            );
            final Offset buttonBottomRight = button.localToGlobal(
              button.size.bottomRight(Offset.zero),
              ancestor: overlay,
            );
            
            // Position menu below the button, with menu's top-right aligned to button's bottom-right
            // Calculate with a small offset for spacing
            const double menuSpacing = 4.0; // Small gap between button and menu
            final RelativeRect position = RelativeRect.fromLTRB(
              buttonTopLeft.dx,                                 // Left edge starts from button left (menu can extend left)
              buttonBottomRight.dy + menuSpacing,                // Menu top is below button bottom with spacing
              overlay.size.width - buttonBottomRight.dx,         // Menu right edge aligns with button right edge
              overlay.size.height - buttonBottomRight.dy - 200,  // Leave room for menu height
            );

            showMenu<String>(
              context: context,
              position: position,
              color:
                  theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
              elevation: 8,
              shape: RoundedRectangleBorder(
                // borderRadius: BorderRadius.circular(),
              ),
              items: [
                // if (hasFutures)
                //   PopupMenuItem<String>(
                //     value: 'futures',
                //     child: Row(
                //       children: [
                //         Text(
                //           'Futures',
                //           style: WebTextStyles.custom(
                //             fontSize: 13,
                //             isDarkTheme: theme.isDarkMode,
                //             color: theme.isDarkMode
                //                 ? WebDarkColors.textPrimary
                //                 : WebColors.textPrimary,
                //             fontWeight: FontWeight.w700,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // if (hasFundamentals)
                //   PopupMenuItem<String>(
                //     value: 'fundamentals',
                //     child: Text(
                //       'Fundamentals',
                //       style: WebTextStyles.custom(
                //         fontSize: 13,
                //         isDarkTheme: false,
                //         color: WebColors.textPrimary,
                //         fontWeight: FontWeight.w700,
                //       ),
                //     ),
                //   ),
                // if (hasOptions)
                //   PopupMenuItem<String>(
                //     value: 'options',
                //     child: Text(
                //       'Options Chain',
                //       style: WebTextStyles.custom(
                //         fontSize: 13,
                //         isDarkTheme: false,
                //         color: WebColors.textPrimary,
                //         fontWeight: FontWeight.w700,
                //       ),
                //     ),
                //   ),
                // PopupMenuItem<String>(
                //   value: 'setAlert',
                //   child: Text(
                //     'Set Alert',
                //     style: WebTextStyles.custom(
                //       fontSize: 13,
                //       isDarkTheme: theme.isDarkMode,
                //       color: theme.isDarkMode
                //           ? WebDarkColors.textPrimary
                //           : WebColors.textPrimary,
                //           fontWeight: FontWeight.w700,
                //     ),
                //   ),
                // ),
                // PopupMenuItem<String>(
                //   value: 'deleteMultiple',
                //   child: Text(
                //     'Delete Multiple',
                //     style: WebTextStyles.custom(
                //       fontSize: 13,
                //       isDarkTheme: theme.isDarkMode,
                //       color: theme.isDarkMode
                //           ? WebDarkColors.textPrimary
                //           : WebColors.textPrimary,
                //       fontWeight: FontWeight.w700,
                //     ),
                //   ),
                // ),
              ],
            ).then((value) {
              setState(() {
                _isMenuOpen = false;
              });
              if (value != null) {
                _handleMenuAction(value, depthData, exch, token);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.border
                    : WebColors.border,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Transform.rotate(
                angle: 1.5708, // 90 degrees in radians (π/2)
                child: SvgPicture.asset(
                  assets.threedots,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    theme.isDarkMode
                        ? WebDarkColors.iconSecondary
                        : WebColors.iconSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(
      String action, GetQuotes depthData, String exch, String token) async {
    if (_isNavigating) return;

    final marketWatch = ref.read(marketWatchProvider);
    final theme = ref.read(themeProvider);

    try {
      setState(() {
        _isNavigating = true;
      });

      if (action == 'futures') {
        // Load futures data first
        marketWatch.singlePageloader(true);

        try {
          // Fetch linked scripts (this loads futures data)
          await marketWatch.fetchScripQuoteIndex(token, exch, context);
          if (marketWatch.getOptionawait(exch, token)) {
            await marketWatch.fetchLinkeScrip(token, exch, context);
            // Request futures WebSocket data
            await marketWatch.requestWSFut(context: context, isSubscribe: true);
          }

          if (!mounted) return;

          // Open only futures screen in a dialog
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext dialogContext) {
              return Dialog(
                backgroundColor: theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 600,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Futures',
                              style: WebTextStyles.title(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(.15)
                                    : Colors.black.withOpacity(.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(.08)
                                    : Colors.black.withOpacity(.08),
                                onTap: () {
                                  // Unsubscribe from futures WebSocket
                                  marketWatch.requestWSFut(
                                      context: context, isSubscribe: false);
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.iconSecondary
                                        : WebColors.iconSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Info message
                      // Container(
                      //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      //   decoration: BoxDecoration(
                      //     color: theme.isDarkMode
                      //         ? WebDarkColors.primary.withOpacity(0.1)
                      //         : WebColors.primary.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(6),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Icon(
                      //         Icons.info_outline,
                      //         size: 16,
                      //         color: theme.isDarkMode
                      //             ? WebDarkColors.primary
                      //             : WebColors.primary,
                      //       ),
                      //       const SizedBox(width: 8),
                      //       Text(
                      //         'Long press to add ${marketWatch.wlName}\'s Watchlist',
                      //         style: WebTextStyles.para(
                      //           isDarkTheme: theme.isDarkMode,
                      //           color: theme.isDarkMode
                      //               ? WebDarkColors.primary
                      //               : WebColors.primary,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // Futures content - Use IntrinsicHeight to size to content
                      Consumer(
                        builder: (context, ref, _) {
                          return const FutureScreenWeb();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } finally {
          if (mounted) {
            marketWatch.singlePageloader(false);
          }
        }
      } else if (action == 'fundamentals') {
        // Open fundamentals in a dialog
        marketWatch.singlePageloader(true);

        try {
          // Always fetch fresh fundamental data for the current scrip
          await marketWatch.fetchFundamentalData(
            tradeSym: "$exch:${widget.watchListData["tsym"]?.toString() ?? ""}",
          );

          if (!mounted) return;

          if (marketWatch.fundamentalData != null &&
              marketWatch.fundamentalData?.msg != "no data found") {
            // Create DepthInputArgs and get depth data
            DepthInputArgs depthArgs = _createDepthArgs();
            final depthData = marketWatch.getQuotes!;

            // Show as dialog
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext dialogContext) {
                  return Dialog(
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.surface
                        : WebColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: 700,
                      constraints:
                          const BoxConstraints(maxHeight: 800, minHeight: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${depthArgs.symbol.replaceAll("-EQ", "").toUpperCase()}${depthArgs.expDate} ${depthArgs.option} Stock Report',
                                  style: WebTextStyles.title(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    splashColor: theme.isDarkMode
                                        ? Colors.white.withOpacity(.15)
                                        : Colors.black.withOpacity(.15),
                                    highlightColor: theme.isDarkMode
                                        ? Colors.white.withOpacity(.08)
                                        : Colors.black.withOpacity(.08),
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.iconSecondary
                                            : WebColors.iconSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content without AppBar
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: NewFundamentalScreen(
                                  wlValue: depthArgs,
                                  depthData: depthData,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        } finally {
          if (mounted) {
            marketWatch.singlePageloader(false);
          }
        }
      } else if (action == 'options') {
        // Open Options Chain
        try {
          // Setup option script
          final tsym = widget.watchListData["tsym"]?.toString() ?? "";
          marketWatch.setOptionScript(context, exch, token, tsym);

          // Wait for setup to complete
          await Future.delayed(const Duration(milliseconds: 150));

          if (!mounted) return;

          // Navigate to options chain
          final DepthInputArgs wlValue = _createDepthArgs();
          if (kIsWeb && WebNavigationHelper.isAvailable) {
            WebNavigationHelper.navigateTo("optionChain", arguments: wlValue);
          } else {
            await Navigator.pushNamed(context, Routes.optionChainWeb, arguments: wlValue);
          }
        } catch (e) {
          if (mounted) {
            showResponsiveError(context, 'Failed to open Options Chain');
          }
        }
      } else if (action == 'setAlert') {
        try {
          // Reset state before showing dialog
          await marketWatch.chngDephBtn("Overview");

          if (!mounted) return;

          // Get depth data from provider and create depth args
          final depthData = marketWatch.getQuotes!;
          final depthArgs = _createDepthArgs();
          
          // Show Set Alert dialog
          _showSetAlertDialog(context, depthData, depthArgs);

          // Reset state after dialog is closed
          if (mounted) {
            await marketWatch.chngDephBtn("Overview");
          }
        } catch (e) {
          if (mounted) {
            showResponsiveError(
              context,
              'Failed to open Set Alert screen',
            );
          }
        }
      } else if (action == 'deleteMultiple') {
        try {
          // Enable delete mode in the watchlist screen
          ref.read(deleteModeProvider.notifier).setDeleteMode(true);
        } catch (e) {
          if (mounted) {
            showResponsiveError(
              context,
              'Failed to open Delete Multiple screen',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Menu action error: $e');
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isNavigating = false;
            });
          }
        });
      }
    }
  }

  // Helper to create DepthInputArgs from watchlist data
  DepthInputArgs _createDepthArgs() {
    return DepthInputArgs(
      exch: widget.watchListData["exch"].toString(),
      token: widget.watchListData["token"].toString(),
      tsym: widget.watchListData["tsym"].toString(),
      instname: widget.watchListData["instname"]?.toString() ?? widget.watchListData["symbol"].toString(),
      symbol: widget.watchListData["symbol"].toString(),
      expDate: widget.watchListData["expDate"]?.toString() ?? "",
      option: widget.watchListData["option"]?.toString() ?? "",
    );
  }

  void _showSetAlertDialog(BuildContext context, GetQuotes depthData, DepthInputArgs depthArgs) {
    final theme = ref.read(themeProvider);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: theme.isDarkMode 
              ? WebDarkColors.surface 
              : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 500),           
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric( horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set Alert',
                        style: WebTextStyles.sub(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SetAlertWeb(
                  depthdata: depthData,
                  wlvalue: depthArgs,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to safely parse numeric values
  String _safeParseNumeric(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;

    String stringValue = value.toString().trim();

    // Handle common invalid values
    if (stringValue.isEmpty ||
        stringValue == 'null' ||
        stringValue == '0.0' ||
        stringValue == '0' ||
        stringValue == 'NaN' ||
        stringValue == 'Infinity') {
      return defaultValue;
    }

    // Try to parse as double first, then int
    try {
      double.parse(stringValue);
      return stringValue;
    } catch (e) {
      try {
        int.parse(stringValue);
        return stringValue;
      } catch (e) {
        return defaultValue;
      }
    }
  }

  // Helper method to safely parse lot size
  String _safeParseLotSize(
      dynamic scripInfoLs, dynamic depthDataLs, String defaultValue) {
    // Try scripInfo first
    String scripInfoValue = _safeParseNumeric(scripInfoLs, "");
    if (scripInfoValue.isNotEmpty && scripInfoValue != defaultValue) {
      return scripInfoValue;
    }

    // Try depthData
    String depthDataValue = _safeParseNumeric(depthDataLs, "");
    if (depthDataValue.isNotEmpty && depthDataValue != defaultValue) {
      return depthDataValue;
    }

    return defaultValue;
  }

  Future<void> _placeOrderInput(
      BuildContext ctx, GetQuotes depthData, bool transType) async {
    try {
      // Prevent multiple simultaneous calls
      if (_isNavigating) return;

      setState(() {
        _isNavigating = true;
      });

      // Fetch scrip info first, exactly like reference implementation
      await ref.read(marketWatchProvider).fetchScripInfo(
          widget.watchListData['token']?.toString() ?? "",
          widget.watchListData['exch']?.toString() ?? "",
          context,
          true);

      // Ensure scripInfo is loaded before proceeding
      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        throw Exception('Failed to load scrip information');
      }

      // Use exact lot size logic from reference implementation
      final isBasketMode = widget.watchListData['isBasket']?.toString() ?? "";
      final lotSize = isBasketMode == "BasketMode"
          ? _safeParseLotSize(scripInfo.ls, depthData.ls, "1")
          : _safeParseLotSize(depthData.ls, scripInfo.ls, "1");

      // Use safe parsing for price values
      final safeLtp = _safeParseNumeric(depthData.lp ?? depthData.c, "0.00");
      final safePerChange = _safeParseNumeric(depthData.pc, "0.00");

      OrderScreenArgs orderArgs = OrderScreenArgs(
          exchange: widget.watchListData['exch']?.toString() ?? "",
          tSym: widget.watchListData['tsym']?.toString() ?? "",
          isExit: false,
          token: widget.watchListData['token']?.toString() ?? "",
          transType: transType,
          lotSize: lotSize,
          ltp: safeLtp,
          perChange: safePerChange,
          orderTpye: '',
          holdQty: '',
          isModify: false,
          raw: {});

      // Add small delay to ensure state is properly set
      await Future.delayed(const Duration(milliseconds: 150));

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": isBasketMode
        },
      );
    } catch (e) {
      print('Place order error: $e');
      print('Watch list data: ${widget.watchListData}');
      print('Depth data: ${depthData.toJson()}');
      // Show error to user
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Error placing order: ${e.toString()}');
      }
    } finally {
      // Reset navigation state after a delay
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isNavigating = false;
            });
          }
        });
      }
    }
  }
}

class _PriceDataWidgetWeb extends ConsumerStatefulWidget {
  final String token;
  final Map<String, dynamic> initialData;

  const _PriceDataWidgetWeb({
    required this.token,
    required this.initialData,
  });

  @override
  ConsumerState<_PriceDataWidgetWeb> createState() =>
      _PriceDataWidgetWebState();
}

class _PriceDataWidgetWebState extends ConsumerState<_PriceDataWidgetWeb> {
  late String ltp;
  late String change;
  late String perChange;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    // Initialize with initial data values
    ltp = widget.initialData['ltp']?.toString() ?? '0.00';
    change = widget.initialData['change']?.toString() ?? '0.00';
    perChange = widget.initialData['perChange']?.toString() ?? '0.00';

    // Pre-load from current socket data if available
    final socketData = ref.read(websocketProvider).socketDatas[widget.token];
    if (socketData != null) {
      ltp = socketData['lp']?.toString() ?? ltp;
      change = socketData['chng']?.toString() ?? change;
      perChange = socketData['pc']?.toString() ?? perChange;
    }

    // Setup subscription with debounce to avoid excessive updates
    _setupSubscription();
  }

  void _setupSubscription() {
    // Using a more efficient approach to listen to only the relevant token's data
    _subscription =
        ref.read(websocketProvider).socketDataStream.listen((rawData) {
      // Skip processing if widget is in the process of disposal
      if (!mounted) return;

      // Safely cast the data to handle LinkedMap type
      final data = Map<String, dynamic>.from(rawData as Map? ?? {});

      // Only process if data contains our token
      if (!data.containsKey(widget.token)) return;

      final rawNewData = data[widget.token];
      if (rawNewData == null) return;

      final newData = Map<String, dynamic>.from(rawNewData as Map);

      // Only update state if values actually changed
      bool valueChanged = false;

      final newLtp = newData['lp']?.toString();
      final newChange = newData['chng']?.toString();
      final newPerChange = newData['pc']?.toString();

      if (newLtp != null &&
          newLtp != ltp &&
          newLtp != '0.00' &&
          newLtp != '0.0' &&
          newLtp != 'null') {
        ltp = newLtp;
        valueChanged = true;
      }

      if (newChange != null &&
          newChange != change &&
          newChange != '0.0' &&
          newChange != 'null') {
        change = newChange;
        valueChanged = true;
      }

      if (newPerChange != null &&
          newPerChange != perChange &&
          newPerChange != '0.0' &&
          newPerChange != 'null') {
        perChange = newPerChange;
        valueChanged = true;
      }

      // Only rebuild if values actually changed and not already rebuilding
      if (valueChanged) {
        // Immediately update UI for price changes
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    // Ensure subscription is properly cleaned up
    _subscription?.cancel();
    super.dispose();
  }

  // Helper method to safely format price values
  String _safeFormatPrice(String value) {
    if (value == 'null' ||
        value.isEmpty ||
        value == '0.0' ||
        value == 'NaN' ||
        value == 'Infinity') {
      return '0.00';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // Don't read theme on every rebuild - cache it once per build
    final theme = ref.read(themeProvider);

    // Format price values and handle invalid data
    final displayLtp = _safeFormatPrice(ltp);
    final displayChange = _safeFormatPrice(change);
    final displayPerChange = _safeFormatPrice(perChange);

    final changeColor =
        displayChange.startsWith("-") || displayPerChange.startsWith('-')
            ? theme.isDarkMode
                ? WebDarkColors.loss
                : WebColors.loss
            : (displayChange == "0.00" || displayPerChange == "0.00")
                ? theme.isDarkMode
                    ? WebDarkColors.textSecondary
                    : WebColors.textSecondary
                : theme.isDarkMode
                    ? WebDarkColors.profit
                    : WebColors.profit;

    // Build the UI with web-optimized text styles
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayLtp,
            style: WebTextStyles.custom(
              fontSize: 14,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: FontWeight.w700,
              // height: 1.2,
              // letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 8), // Adjusted spacing to match Vue project
          Text(
            "$displayChange ($displayPerChange%)",
            style: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: changeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]);
  }
}
