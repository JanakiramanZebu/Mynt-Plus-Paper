// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';

import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../sharedWidget/functions.dart';
import 'index_bottom_sheet.dart';

class DefaultIndexList extends StatefulWidget {
  final bool src;
  const DefaultIndexList({super.key, required this.src});

  @override
  State<DefaultIndexList> createState() => _DefaultIndexListState();
}

class _DefaultIndexListState extends State<DefaultIndexList> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  
  // Keep this alive to prevent rebuilds when switching tabs
  @override
  bool get wantKeepAlive => true;
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final indexProvider = context.read(indexListProvider);
    
    final indexValues = indexProvider.defaultIndexList?.indValues;
    if (indexValues == null || indexValues.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Width calculation moved here to avoid context in initState
    final itemWidth = MediaQuery.of(context).size.width * 0.47;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.only(left: widget.src ? 0 : 12),
      height: widget.src ? 54 : 50,
      child: RepaintBoundary(
        child: ListView.builder(
          controller: _scrollController,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
          itemCount: indexValues.length,
            itemBuilder: (BuildContext context, int index) {
            final indexItem = indexValues[index];
            
            // Create a key for efficient widget reuse
            final key = ValueKey('index-${indexItem.token}');
            
            // Use const for spacing
            return Padding(
              padding: const EdgeInsets.only(right: 9),
              child: OptimizedIndexItem(
                key: key,
                indexItem: indexItem,
                src: widget.src,
                itemWidth: itemWidth,
              ),
            );
          },
        ),
      ),
    );
  }
}

// Rename _IndexItem to OptimizedIndexItem for clarity
class OptimizedIndexItem extends StatefulWidget {
  final dynamic indexItem;
  final bool src;
  final double itemWidth;

  const OptimizedIndexItem({
    Key? key,
    required this.indexItem,
    required this.src,
    required this.itemWidth,
  }) : super(key: key);

  @override
  OptimizedIndexItemState createState() => OptimizedIndexItemState();
}

// Rename _IndexItemState to OptimizedIndexItemState
class OptimizedIndexItemState extends State<OptimizedIndexItem> {
  StreamSubscription? _subscription;
  
  // Cache the values locally to avoid rebuilds
  String _ltp = '0.00';
  String _change = '0.00';
  String _perChange = '0.00';
  bool _isInitialized = false;
  
  // Track last update time to optimize rebuilds
  DateTime _lastUpdateTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Initialize with current values
    _ltp = widget.indexItem.ltp ?? '0.00';
    _change = widget.indexItem.change ?? '0.00';
    _perChange = widget.indexItem.perChange ?? '0.00';
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _setupSocketListener();
      _isInitialized = true;
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  // Set up a focused socket listener that only updates this item
  void _setupSocketListener() {
    final token = widget.indexItem.token?.toString();
    if (token == null) return;
    
    final websocket = ProviderScope.containerOf(context).read(websocketProvider);
    
    // Pre-load with socket data if available
    final socketData = websocket.socketDatas[token];
    if (socketData != null) {
      _updateFromSocketData(socketData);
    }
    
    // Set up subscription that only listens for this token
    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(token)) {
        final socketData = data[token];
        if (socketData != null) {
          // Only rebuild if data changed and enough time elapsed (throttle updates)
          if (_updateFromSocketData(socketData)) {
            final now = DateTime.now();
            if (now.difference(_lastUpdateTime).inMilliseconds > 300) { // Throttle to reduce jank
              _lastUpdateTime = now;
              if (mounted) setState(() {});
            }
          }
        }
      }
    });
  }
  
  // Update local state from socket data, return true if values changed
  bool _updateFromSocketData(dynamic socketData) {
    bool hasUpdates = false;
    
    if (socketData['lp'] != null && socketData['lp'].toString() != "null") {
      final newLtp = socketData['lp'].toString();
      if (newLtp != _ltp) {
        _ltp = newLtp;
        hasUpdates = true;
      }
    }
    
    if (socketData['chng'] != null && socketData['chng'].toString() != "null") {
      final newChange = socketData['chng'].toString();
      if (newChange != _change) {
        _change = newChange;
        hasUpdates = true;
      }
    }
    
    if (socketData['pc'] != null && socketData['pc'].toString() != "null") {
      final newPerChange = socketData['pc'].toString();
      if (newPerChange != _perChange) {
        _perChange = newPerChange;
        hasUpdates = true;
      }
    }
    
    return hasUpdates;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    
    return RepaintBoundary(
      child: InkWell(
        onTap: () => _handleTap(context),
        onLongPress: () => _handleLongPress(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              width: widget.src ? 0.6 : 0
            ),
            color: widget.src
                ? Colors.transparent
                : theme.isDarkMode
                    ? const Color(0xffB5C0CF).withOpacity(.15)
                    : const Color(0xffF1F3F8),
            borderRadius: BorderRadius.circular(5)
          ),
          width: widget.itemWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fix hierarchy: Expanded outside RepaintBoundary
              Expanded(
                child: RepaintBoundary(
                  child: _StaticIndexName(
                    name: widget.indexItem.idxname?.toUpperCase() ?? "",
                    isDarkMode: theme.isDarkMode,
                    isSrc: widget.src,
                  ),
                ),
              ),
              
              // Add spacing between static and dynamic parts
              const SizedBox(width: 4),
              
              // Dynamic content that rebuilds with price changes
              _DynamicPriceData(
                ltp: _ltp,
                change: _change,
                perChange: _perChange,
                isDarkMode: theme.isDarkMode,
                isSrc: widget.src,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Handle tap on index item
  Future<void> _handleTap(BuildContext context) async {
    try {
      final marketWatch = context.read(marketWatchProvider);
      
      // First, safely fetch the quote data
      await marketWatch.fetchScripQuoteIndex(
        widget.indexItem.token?.toString() ?? "",
        widget.indexItem.exch?.toString() ?? "",
                      context);

      final quots = marketWatch.getQuotes;
      
      // Make sure we have valid quote data before proceeding
      if (quots == null) {
        return;
      }
      
      // Create DepthInputArgs with null safety
                  DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch?.toString() ?? "",
        token: quots.token?.toString() ?? "",
        tsym: quots.tsym?.toString() ?? "",
        instname: quots.instname?.toString() ?? "",
        symbol: quots.symbol?.toString() ?? "",
        expDate: quots.expDate?.toString() ?? "",
        option: quots.option?.toString() ?? "");
      
      // Call depth APIs with the safely constructed arguments
      if (depthArgs.token.isNotEmpty && depthArgs.exch.isNotEmpty) {
        await marketWatch.calldepthApis(context, depthArgs, "");
      }
    } catch (e) {
      debugPrint("Error in index tap: $e");
    }
  }
  
  // Handle long press on index item
  Future<void> _handleLongPress(BuildContext context) async {
    try {
      final indexProvider = context.read(indexListProvider);
      await indexProvider.fetchIndexList("NSE", context);
      
      // Pass the indexItem directly - no conversion needed
                  await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
          builder: (_) => IndexBottomSheet(
            defaultIndex: widget.indexItem, 
            src: widget.src
          )
      );
      
      await indexProvider.fetchIndexList("exit", context);
                  await context
                      .read(marketWatchProvider)
                      .requestMWScrip(context: context, isSubscribe: true);
    } catch (e) {
      // Log or handle the error
      debugPrint("Error in index onLongPress: $e");
    }
  }
}

// Reusable static content widget that won't rebuild
class _StaticIndexName extends StatelessWidget {
  final String name;
  final bool isDarkMode;
  final bool isSrc;
  
  // Cache for text styles to avoid recreation
  static final Map<String, TextStyle> _styleCache = {};
  
  const _StaticIndexName({
    Key? key,
    required this.name,
    required this.isDarkMode,
    required this.isSrc,
  }) : super(key: key);
  
  // Get cached text style
  TextStyle _getNameStyle() {
    final key = 'name|${isDarkMode ? 1 : 0}';
    if (!_styleCache.containsKey(key)) {
      _styleCache[key] = textStyle(
        isDarkMode ? const Color(0xffB5C0CF) : const Color(0xff000000),
        14,
        FontWeight.w600
      );
    }
    return _styleCache[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    // Don't return an Expanded widget here - return just the Text
    return Text(
      name,
      maxLines: isSrc ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: _getNameStyle(),
    );
  }
}

// Reusable dynamic content widget for price data
class _DynamicPriceData extends StatelessWidget {
  final String ltp;
  final String change;
  final String perChange;
  final bool isDarkMode;
  final bool isSrc;
  
  // Cache for text styles to avoid recreation
  static final Map<String, TextStyle> _styleCache = {};
  
  // Cache for color calculations
  static final Map<String, Color> _colorCache = {};
  
  const _DynamicPriceData({
    Key? key,
    required this.ltp,
    required this.change,
    required this.perChange,
    required this.isDarkMode,
    required this.isSrc,
  }) : super(key: key);
  
  // Get cached text style
  TextStyle _getCachedStyle(Color color, double size, FontWeight weight) {
    final key = '${color.value}|$size|${weight.index}';
    if (!_styleCache.containsKey(key)) {
      _styleCache[key] = textStyle(color, size, weight);
    }
    return _styleCache[key]!;
  }
  
  // Get cached color based on change value
  Color _getCachedChangeColor(String value, String percentValue) {
    final key = '$value|$percentValue';
    if (!_colorCache.containsKey(key)) {
      if (value.startsWith("-") || percentValue.startsWith('-')) {
        _colorCache[key] = colors.darkred;
      } else if ((value == "null" || percentValue == "null") ||
               (value == "0.00" || percentValue == "0.00")) {
        _colorCache[key] = colors.ltpgrey;
      } else {
        _colorCache[key] = colors.ltpgreen;
      }
    }
    return _colorCache[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    // Calculate price style once
    final priceStyle = _getCachedStyle(
      isDarkMode
          ? const Color(0xffE5E5E5)
          : isSrc ? const Color(0xff666666) : const Color(0xff000000),
      13,
      FontWeight.w600);
    
    // Calculate change colors and styles once
    final changeColor = _getCachedChangeColor(change, perChange);
    final perChangeColor = _getCachedChangeColor(perChange, perChange);
    
    final changeStyle = _getCachedStyle(changeColor, 12, FontWeight.w600);
    final perChangeStyle = _getCachedStyle(perChangeColor, 12, FontWeight.w600);
    
    return RepaintBoundary(
      child: isSrc
                    ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
              const SizedBox(height: 24), // Align with name after spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                  Text("₹$ltp", style: priceStyle),
                                const SizedBox(width: 4),
                  Text("$change ", style: changeStyle),
                  Text("($perChange%)", style: perChangeStyle)
                ]
                          ),
                        ],
                      )
        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
              Text("₹$ltp", style: priceStyle),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                  Text("$change ", style: changeStyle),
                  Text("($perChange%)", style: perChangeStyle),
                            ],
                          )
                        ],
                      ),
    );
  }
}
