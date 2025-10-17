import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/foundation.dart';
import 'package:mynt_plus/provider/user_profile_provider.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/snack_bar.dart';
import '../../utils/responsive_navigation.dart';
import '../../utils/responsive_snackbar.dart';
import '../market_watch/edit_scrip.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final marketWatch = ref.read(marketWatchProvider);
    final depthData = ref.watch(marketWatchProvider).getQuotes!;

    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(8), // Increased border radius for web
          splashColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
          highlightColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          onLongPress: () {
            if (marketWatch.isPreDefWLs == "Yes") {
              showResponsiveWarningMessage(context,
                  "This is a pre-defined watchlist that cannot be edited!");
            } else {
              ref
                  .read(marketWatchProvider)
                  .requestMWScrip(context: context, isSubscribe: false);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditScrip(wlName: marketWatch.wlName)));
            }
          },
          onTap: () async {
            // Prevent multiple navigation events on rapid clicks
            if (_isNavigating) return;

            try {
              setState(() {
                _isNavigating = true;
              });

              // Create proper DepthInputArgs object like in StocksScreen
              DepthInputArgs depthArgs = DepthInputArgs(
                  exch: widget.watchListData["exch"].toString(),
                  token: widget.watchListData["token"].toString(),
                  tsym: widget.watchListData["tsym"].toString(),
                  instname: widget.watchListData["symbol"].toString(),
                  symbol: widget.watchListData["symbol"].toString(),
                  expDate: widget.watchListData["expDate"]?.toString() ?? "",
                  option: widget.watchListData["option"]?.toString() ?? "");

              // Use the existing calldepthApis method which handles both web and mobile
              marketWatch.scripdepthsize(false);
              await marketWatch.calldepthApis(context, depthArgs, "");
            } catch (e) {
              // Handle any errors
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Increased padding for web
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
                          TextWidget.subText(
                            text: widget.watchListData["symbol"]
                                .toString()
                                .replaceAll("-EQ", "")
                                .toUpperCase(),
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
                            fw: 0,
                          ),
                          if (widget.watchListData["option"].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: TextWidget.subText(
                                text: "${widget.watchListData["option"]}",
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                theme: theme.isDarkMode,
                                fw: 0,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8), // Increased spacing for web
                      // Exchange badge and additional info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget.paraText(
                            text: '${widget.watchListData["exch"]}',
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            theme: theme.isDarkMode,
                            fw: 3,
                          ),
                          if (widget.watchListData['expDate'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextWidget.paraText(
                                text: " ${widget.watchListData['expDate']}",
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                theme: theme.isDarkMode,
                                fw: 0,
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
                                    ? colors.secondaryDark
                                    : colors.secondaryLight),
                            const SizedBox(width: 4),
                            TextWidget.paraText(
                              text: "${widget.watchListData['holdingQty']}",
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: 3,
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
                    // Action buttons (shown on hover)
                    if (_isHovered)
                      Container(
                        width: 200, // Increased width for web
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHoverButton(
                              label: _isNavigating ? 'Wait...' : 'Buy',
                              color: theme.isDarkMode
                                  ? colors.successDark
                                  : colors.successLight,
                              onPressed: _isNavigating ? null : () async {
                                try {
                                  await _placeOrderInput(context, depthData, true);
                                } catch (e) {
                                  // Additional safety catch at button level
                                  print('Buy button error: $e');
                                }
                              },
                            ),
                            _buildHoverButton(
                              label: _isNavigating ? 'Wait...' : 'Sell',
                              color: theme.isDarkMode
                                  ? colors.lossDark
                                  : colors.lossLight,
                              onPressed: _isNavigating ? null : () async {
                                try {
                                  await _placeOrderInput(context, depthData, false);
                                } catch (e) {
                                  // Additional safety catch at button level
                                  print('Sell button error: $e');
                                }
                              },
                            ),
                            _buildHoverButton(
                              label: 'Chart',
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              onPressed: () {
                                // Navigate to chart screen
                                ref.read(marketWatchProvider).singlePageloader(true);
                                ref.read(marketWatchProvider)
                                    .chngDephBtn("Chart");
                                ref.read(userProfileProvider)
                                    .setChartdialog(true);
                                
                                ref.read(marketWatchProvider).setChartScript(
                                    widget.watchListData["exch"].toString(),
                                    widget.watchListData["token"].toString(),
                                    widget.watchListData["tsym"].toString());
                                
                                ref.read(marketWatchProvider)
                                    .singlePageloader(false);
                              },
                            ),
                          ],
                        ),
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
    );
  }

  Widget _buildHoverButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final theme = ref.read(themeProvider);
    return SizedBox(
      width: 55, // Increased width for web
      height: 32, // Increased height for web
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6), // Increased border radius for web
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5), // Slightly thicker border for web
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: TextWidget.paraText(
                text: label,
                color: color,
                theme: theme.isDarkMode,
                fw: 1,
              ),
            ),
          ),
        ),
      ),
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
  String _safeParseLotSize(dynamic scripInfoLs, dynamic depthDataLs, String defaultValue) {
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

  Future<void> _placeOrderInput(BuildContext ctx, GetQuotes depthData, bool transType) async {
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
          context, 
          'Error placing order: ${e.toString()}'
        );
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
  ConsumerState<_PriceDataWidgetWeb> createState() => _PriceDataWidgetWebState();
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
    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      // Skip processing if widget is in the process of disposal
      if (!mounted) return;

      // Only process if data contains our token
      if (!data.containsKey(widget.token)) return;

      final newData = data[widget.token];
      if (newData == null) return;

      // Only update state if values actually changed
      bool valueChanged = false;

      final newLtp = newData['lp']?.toString();
      final newChange = newData['chng']?.toString();
      final newPerChange = newData['pc']?.toString();

      if (newLtp != null && newLtp != ltp && newLtp != '0.00' && newLtp != '0.0' && newLtp != 'null') {
        ltp = newLtp;
        valueChanged = true;
      }

      if (newChange != null && newChange != change && newChange != '0.0' && newChange != 'null') {
        change = newChange;
        valueChanged = true;
      }

      if (newPerChange != null && newPerChange != perChange && newPerChange != '0.0' && newPerChange != 'null') {
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
    if (value == 'null' || value.isEmpty || value == '0.0' || value == 'NaN' || value == 'Infinity') {
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
                ? colors.lossDark
                : colors.lossLight
            : (displayChange == "0.00" || displayPerChange == "0.00")
                ? theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight
                : theme.isDarkMode
                    ? colors.profitDark
                    : colors.profitLight;

    // Build the UI with web-optimized text styles
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget.titleText(
            text: displayLtp,
            color: changeColor,
            theme: theme.isDarkMode,
            fw: 2,
          ),
          const SizedBox(height: 4), // Increased spacing for web
          TextWidget.paraText(
            text: "$displayChange ($displayPerChange%)",
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 3,
          ),
        ]);
  }
}
