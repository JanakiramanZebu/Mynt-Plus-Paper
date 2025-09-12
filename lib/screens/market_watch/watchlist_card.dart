import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';
import '../../utils/responsive_navigation.dart';
import '../../utils/responsive_snackbar.dart';
import 'edit_scrip.dart';

class WatchlistCard extends ConsumerStatefulWidget {
  final dynamic watchListData;
  const WatchlistCard({super.key, required this.watchListData});

  @override
  ConsumerState<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends ConsumerState<WatchlistCard> {
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
          borderRadius: BorderRadius.circular(6),
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

            // Add delay for visual feedback
            // await Future.delayed(const Duration(milliseconds: 150));

            try {
              setState(() {
                _isNavigating = true;
              });
              // Add a small delay for the UI to reflect loading state if needed
              marketWatch.scripdepthsize(false);

              // Create proper DepthInputArgs object like in StocksScreen
              DepthInputArgs depthArgs = DepthInputArgs(
                  exch: widget.watchListData["exch"].toString(),
                  token: widget.watchListData["token"].toString(),
                  tsym: widget.watchListData["tsym"].toString(),
                  instname: widget.watchListData["symbol"].toString(),
                  symbol: widget.watchListData["symbol"].toString(),
                  expDate: widget.watchListData["expDate"]?.toString() ?? "",
                  option: widget.watchListData["option"]?.toString() ?? "");

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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            dense: false,
            // visualDensity: VisualDensity.compact,
            // minVerticalPadding: 0,
            title: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.watchListData["symbol"]
                        .toString()
                        .replaceAll("-EQ", "")
                        .toUpperCase(),
                    style: TextWidget.textStyle(
                      fontSize: 14,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                      theme: theme.isDarkMode,
                    ),
                  ),
                  if (widget.watchListData["option"].toString().isNotEmpty)
                    Text(
                      "${widget.watchListData["option"]}",
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                    ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomExchBadge(exch: '${widget.watchListData["exch"]}'),
                      if (widget.watchListData['expDate'].toString().isNotEmpty)
                        TextWidget.paraText(
                          text: " ${widget.watchListData['expDate']}",
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                      if (widget.watchListData['holdingQty'] != null &&
                          widget.watchListData['holdingQty']
                              .toString()
                              .isNotEmpty &&
                          widget.watchListData['holdingQty'] != "null") ...[
                        const SizedBox(width: 6),
                        SvgPicture.asset(assets.suitcase,
                            height: 12,
                            width: 16,
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
                          fw: 0,
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isHovered
                    ? Container(
                        width: 160,
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
                                Navigator.pushNamed(
                                    context, Routes.chartWebView,
                                    arguments: {
                                      'token': widget.watchListData["token"]
                                          .toString(),
                                      'symbol': widget.watchListData["symbol"]
                                          .toString(),
                                      'exch': widget.watchListData["exch"]
                                          .toString(),
                                    });
                              },
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                RepaintBoundary(
                  child: _PriceDataWidget(
                      token: widget.watchListData['token'],
                      initialData: widget.watchListData),
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
      width: 45,
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                label,
                style: TextWidget.textStyle(
                  fontSize: 11,
                  color: color,
                  theme: theme.isDarkMode,
                  fw: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
          ? scripInfo.ls?.toString() ?? depthData.ls ?? "1"
          : (depthData.ls?.isNotEmpty == true
              ? depthData.ls
              : scripInfo.ls?.toString() ?? "1");

      OrderScreenArgs orderArgs = OrderScreenArgs(
          exchange: widget.watchListData['exch']?.toString() ?? "",
          tSym: widget.watchListData['tsym']?.toString() ?? "",
          isExit: false,
          token: widget.watchListData['token']?.toString() ?? "",
          transType: transType,
          lotSize: lotSize,
          ltp: (depthData.lp ?? depthData.c ?? "0.00").toString(),
          perChange: (depthData.pc ?? "0.00").toString(),
          orderTpye: '',
          holdQty: '',
          isModify: false,
          raw: {});
      
      // Add small delay to ensure state is properly set
      await Future.delayed(const Duration(milliseconds: 100));
      
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

class _PriceDataWidget extends ConsumerStatefulWidget {
  final String token;
  final Map<String, dynamic> initialData;

  const _PriceDataWidget({
    required this.token,
    required this.initialData,
  });

  @override
  ConsumerState<_PriceDataWidget> createState() => _PriceDataWidgetState();
}

class _PriceDataWidgetState extends ConsumerState<_PriceDataWidget> {
  late String ltp;
  late String change;
  late String perChange;
  StreamSubscription? _subscription;
  bool _shouldUpdate = false;

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

      if (newLtp != null && newLtp != ltp && newLtp != '0.00') {
        ltp = newLtp;
        valueChanged = true;
      }

      if (newChange != null && newChange != change) {
        change = newChange;
        valueChanged = true;
      }

      if (newPerChange != null && newPerChange != perChange) {
        perChange = newPerChange;
        valueChanged = true;
      }

      // Only rebuild if values actually changed and not already rebuilding
      if (valueChanged) {
        // FIX: Remove debounce delay to ensure immediate LTP updates
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

  @override
  Widget build(BuildContext context) {
    // Don't read theme on every rebuild - cache it once per build
    final theme = ref.read(themeProvider);

    // Format price values and handle invalid data
    final displayLtp = ltp == 'null' || ltp.isEmpty ? '0.00' : ltp;
    final displayChange = change == 'null' || change.isEmpty ? '0.00' : change;
    final displayPerChange =
        perChange == 'null' || perChange.isEmpty ? '0.00' : perChange;

    // Use cached text styles to avoid creating new objects
    final priceTextStyle =
        TextWidget.textStyle(fontSize: 14, theme: theme.isDarkMode, fw: 1);

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

    final changeTextStyle = TextWidget.textStyle(
      fontSize: 16, // or keep 12 if you prefer
      color: changeColor,
      theme: theme.isDarkMode,
      fw: 0,
      // fw = 0 → FontWeight.w500 as per your logic
    );

    // Build the UI with minimal widget creation
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              displayLtp,
              style: changeTextStyle,
            ),
          ),
          // const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextWidget.paraText(
                text: "$displayChange ($displayPerChange%)",
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
                theme: theme.isDarkMode),
          ),
        ]);
  }
}
