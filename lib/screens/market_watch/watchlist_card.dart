import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';
import 'edit_scrip.dart';

class WatchlistCard extends StatefulWidget {
  final dynamic watchListData;
  const WatchlistCard({super.key, required this.watchListData});

  @override
  State<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<WatchlistCard> {
  // Add navigation lock to prevent multiple navigation events
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    final marketWatch = context.read(marketWatchProvider);
    
    return ListTile(
        onLongPress: () {
          if (marketWatch.isPreDefWLs == "Yes") {
          ScaffoldMessenger.of(context).showSnackBar(warningMessage(
              context, "This is a pre-defined watchlist that cannot be edited!"));
          } else {
            context
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
            
            // Add a small delay for the UI to reflect loading state if needed
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${widget.watchListData["symbol"].toString().toUpperCase()} ",
                style: textStyles.scripNameTxtStyle.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack)),
            if (widget.watchListData["option"].toString().isNotEmpty)
              Text("${widget.watchListData["option"]}",
                  style: textStyles.scripNameTxtStyle
                      .copyWith(color: const Color(0xff666666))),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                CustomExchBadge(exch: '${widget.watchListData["exch"]}'),
                if (widget.watchListData['expDate'].toString().isNotEmpty)
                  Text(" ${widget.watchListData['expDate']}  ",
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
              if (widget.watchListData['holdingQty'] != null && 
                  widget.watchListData['holdingQty'].toString().isNotEmpty && 
                  widget.watchListData['holdingQty'] != "null") ...[
                  SvgPicture.asset(assets.suitcase,
                      height: 12,
                      width: 16,
                      color: theme.isDarkMode
                          ? colors.colorLightBlue
                          : colors.colorBlue),
                  Text(" ${widget.watchListData['holdingQty']}",
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                          fontWeight: FontWeight.w600))
                ]
              ],
            ),
          ],
        ),
      trailing: RepaintBoundary(
        child: _PriceDataWidget(token: widget.watchListData['token'], initialData: widget.watchListData),
      ),
    );
  }
}

class _PriceDataWidget extends StatefulWidget {
  final String token;
  final Map<String, dynamic> initialData;

  const _PriceDataWidget({
    required this.token,
    required this.initialData,
  });

  @override
  State<_PriceDataWidget> createState() => _PriceDataWidgetState();
}

class _PriceDataWidgetState extends State<_PriceDataWidget> {
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
    final websocket = context.read(websocketProvider);
    final socketData = websocket.socketDatas[widget.token];
    if (socketData != null) {
      ltp = socketData['lp']?.toString() ?? ltp;
      change = socketData['chng']?.toString() ?? change;
      perChange = socketData['pc']?.toString() ?? perChange;
    }
    
    // Setup subscription with debounce to avoid excessive updates
    _setupSubscription();
  }
  
  void _setupSubscription() {
    final websocket = context.read(websocketProvider);
    
    _subscription = websocket.socketDataStream.listen((data) {
      // Only process if data contains our token
      if (!data.containsKey(widget.token)) return;
      
      final newData = data[widget.token];
      if (newData == null) return;
      
      // Only update state if values actually changed
      bool valueChanged = false;
      
      if (newData['lp'] != null && newData['lp'].toString() != ltp) {
        ltp = newData['lp'].toString();
        valueChanged = true;
      }
      
      if (newData['chng'] != null && newData['chng'].toString() != change) {
        change = newData['chng'].toString();
        valueChanged = true;
      }
      
      if (newData['pc'] != null && newData['pc'].toString() != perChange) {
        perChange = newData['pc'].toString();
        valueChanged = true;
      }
      
      // Only rebuild if values actually changed and not already rebuilding
      if (valueChanged && mounted && !_shouldUpdate) {
        _shouldUpdate = true;
        
        // Debounce updates to avoid rapid UI rebuilds
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() {});
          }
          _shouldUpdate = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    
    // Use cached text styles to avoid creating new objects
    final priceTextStyle = textStyle(
        theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        14,
        FontWeight.w600);
        
    final changeColor = change.startsWith("-") || perChange.startsWith('-')
        ? colors.darkred
        : (change == "null" || perChange == "null" || 
           change == "0.00" || perChange == "0.00")
            ? colors.ltpgrey
            : colors.ltpgreen;
            
    final changeTextStyle = textStyle(changeColor, 12, FontWeight.w600);
    
    // Build the UI with minimal widget creation
    return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        Text("₹$ltp", style: priceTextStyle),
              const SizedBox(height: 4),
              Text(
          "$change ($perChange%)",
          style: changeTextStyle,
              )
      ]
    );
  }
}
