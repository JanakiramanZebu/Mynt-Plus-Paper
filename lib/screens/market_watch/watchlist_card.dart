import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';
import 'edit_scrip.dart';
import 'stock_events_dialog.dart';

class WatchlistCard extends ConsumerStatefulWidget {
  final dynamic watchListData;
  const WatchlistCard({super.key, required this.watchListData});

  @override
  ConsumerState<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends ConsumerState<WatchlistCard> {
  // Add navigation lock to prevent multiple navigation events
  bool _isNavigating = false;

  // Helper function to check if expiry date matches today
  bool _isExpiryToday(String? expDateStr) {
    if (expDateStr == null || expDateStr.isEmpty) return false;

    try {
      // Parse the expiry date format "11 NOV 25"
      final parts = expDateStr.trim().split(' ');
      if (parts.length != 3) return false;

      final day = int.tryParse(parts[0]);
      if (day == null) return false;

      final monthStr = parts[1].toUpperCase();
      final yearStr = parts[2];

      // Map month abbreviations to numbers
      const months = {
        'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
        'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
      };

      final month = months[monthStr];
      if (month == null) return false;

      // Parse year (assuming 2-digit year)
      final year = int.tryParse('20$yearStr');
      if (year == null) return false;

      final expDate = DateTime(year, month, day);
      final today = DateTime.now();

      return expDate.year == today.year &&
             expDate.month == today.month &&
             expDate.day == today.day;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final marketWatch = ref.read(marketWatchProvider);
    final events = marketWatch.filterStockEventsByToken(widget.watchListData['token']);

    return Material(
      color: Colors.transparent,
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
            warningMessage(context,
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
            marketWatch.setETF(false);
            await marketWatch.calldepthApis(context, widget.watchListData, "");
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
                      color:theme.isDarkMode
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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    if (_isExpiryToday(widget.watchListData['expDate'])) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.btnBg
                                  : colors.btnBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: theme.isDarkMode
                                    ? colors.searchBgDark.withOpacity(0.3)
                                    : colors.searchBg.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                        child: TextWidget.captionText(
                          text: "Expiry",
                          color: theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
                          theme: theme.isDarkMode,
                          fw: 1,
                        ),
                      ),
                    ],
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
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                    ],
                     if (marketWatch.hasStockEvents(events,widget.watchListData['token'])) ...[
                      
                      const SizedBox(width: 6),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              isDismissible: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              enableDrag: true,
                              builder: (context) => Container(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: DraggableScrollableSheet(
                                  initialChildSize: 0.6,
                                  expand: false,
                                  minChildSize: 0.4,
                                  maxChildSize: 0.9,
                                  builder: (context, scrollController) => StockEventsDialog(
                                    stockToken: widget.watchListData['token'],
                                    stockName: widget.watchListData['symbol'],
                                  ),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.darkiconcolor.withOpacity(0.2)
                                  : colors.darkiconcolor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: theme.isDarkMode
                                    ? colors.darkiconcolor.withOpacity(0.3)
                                    : colors.darkiconcolor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // SvgPicture.asset(assets.barChart,
                                //     height: 12,
                                //     width: 16,
                                //     color: theme.isDarkMode
                                //         ? colors.secondaryDark
                                //         : colors.secondaryLight),
                                // const SizedBox(width: 4),
                                TextWidget.captionText(
                                  text: events["dividend"]!=null?"DIVIDEND":events["bonus"]!=null?"BONUS":events["split"]!=null?"SPLIT":events["rights"]!=null?"RIGHTS":"EVENT",
                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                    
                  ],
                ),
              ),
            ],
          ),
          trailing: RepaintBoundary(
            child: _PriceDataWidget(
                token: widget.watchListData['token'],
                initialData: widget.watchListData),
          ),
        ),
      ),
    );
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
            ? theme.isDarkMode ? colors.lossDark : colors.lossLight
            : (displayChange == "0.00" || displayPerChange == "0.00")
                ? theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight
                : theme.isDarkMode ? colors.profitDark : colors.profitLight;

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
