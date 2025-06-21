import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';

class IndexBottomSheet extends ConsumerWidget {
  final dynamic defaultIndex;
  final bool src;
  final int indexPosition;
  const IndexBottomSheet(
      {super.key,
      required this.defaultIndex,
      required this.src,
      required this.indexPosition});

  // int tabIndex = 0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double widgetSize = 740;
    final double initialSize = 600.0 / MediaQuery.of(context).size.height;
    double maxSize = widgetSize / MediaQuery.of(context).size.height;
    maxSize = maxSize > 0.9 ? 0.9 : maxSize;
    final theme = ref.read(themeProvider);
    final indexProvide = ref.watch(indexListProvider);
    final marketWatch = ref.watch(marketWatchProvider);
    
    // Remove the StreamBuilder and use direct subscription in each item
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.2,
      maxChildSize: maxSize,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomDragHandler(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Index List",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            18,
                            FontWeight.w600)),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: !theme.isDarkMode
                                    ? colors.colorWhite
                                    : const Color.fromARGB(255, 18, 18, 18)),
                          ),
                          menuItemStyleData: MenuItemStyleData(
                              customHeights:
                                  indexProvide.getCustomItemsHeight()),
                          buttonStyleData: ButtonStyleData(
                              height: 36,
                              width: 90,
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF)
                                          .withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(32)))),
                          isExpanded: true,
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w500),
                          hint: Text(indexProvide.slectedExch,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorBlack,
                                  13,
                                  FontWeight.w500)),
                          items: indexProvide.addDividersAfterExpDates(),
                          value: indexProvide.slectedExch,
                          onChanged: (value) async {
                            indexProvide.fetchIndexList("$value", context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider),
              Expanded(
                child: indexProvide.isLoad
                    ? const Center(child: CircularProgressIndicator())
                    : indexProvide.indValuesList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: false,
                            controller: controller,
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            itemCount:
                                indexProvide.indValuesList.length * 2 - 1,
                            itemBuilder: (BuildContext context, idx) {
                              // For odd indices, show divider
                              if (idx.isOdd) {
                                return const ListDivider();
                              }
                              
                              int index = idx ~/ 2;
                              // Get the current index data
                              var itemData = indexProvide.indValuesList[index];
                              
                              // Determine if the index is checked
                              bool ischeck = indexProvide.defaultIndexList!.indValues!.any(
                                (element) => element.token == itemData.token);
                              
                              return IndexListItemWithStream(
                                key: ValueKey('index-item-${itemData.token}'),
                                itemData: itemData,
                                indexProvider: indexProvide,
                                marketWatch: marketWatch,
                                ischeck: ischeck,
                                src: src,
                                isDarkMode: theme.isDarkMode,
                                indexPosition: indexPosition,
                              );
                            })
                        : Center(
                            child: Text("No Data found",
                                style: textStyle(const Color(0xff777777), 15,
                                    FontWeight.w500)),
                          ),
              )
            ],
          ),
        );
      }
    );
  }
}

// New optimized widget with its own socket stream subscription
class IndexListItemWithStream extends StatefulWidget {
  final dynamic itemData;
  final dynamic indexProvider;
  final dynamic marketWatch;
  final bool ischeck;
  final bool src;
  final bool isDarkMode;
  final int indexPosition;

  const IndexListItemWithStream({
    Key? key,
    required this.itemData,
    required this.indexProvider,
    required this.marketWatch,
    required this.ischeck,
    required this.src,
    required this.isDarkMode,
    required this.indexPosition,
  }) : super(key: key);

  @override
  State<IndexListItemWithStream> createState() => _IndexListItemWithStreamState();
}

class _IndexListItemWithStreamState extends State<IndexListItemWithStream> {
  StreamSubscription? _subscription;
  String _ltp = '0';
  String _ch = '0.00';
  String _chp = '0.00';
  bool _isInitialized = false;
  Timer? _refreshTimer;
  
  // Track last update time to optimize rebuilds
  DateTime _lastUpdateTime = DateTime.now();
  
  // Track when this widget was created
  final DateTime _creationTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Initialize with values from widget data if available
    _initializeFromItemData();
    
    // Set up periodic refresh timer to ensure UI stays updated
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isVisibleInViewport()) {
        setState(() {});
      }
    });
  }
  
  // Initialize values from widget item data if available
  void _initializeFromItemData() {
    // Try to use values from the item data first
    if (widget.itemData.ltp != null && 
        widget.itemData.ltp != "null" && 
        widget.itemData.ltp != "0.00" && 
        widget.itemData.ltp != "0") {
      _ltp = widget.itemData.ltp!;
    }
    
    if (widget.itemData.change != null && 
        widget.itemData.change != "null" && 
        widget.itemData.change != "0.00" && 
        widget.itemData.change != "0") {
      _ch = widget.itemData.change!;
    }
    
    if (widget.itemData.perChange != null && 
        widget.itemData.perChange != "null" && 
        widget.itemData.perChange != "0.00" && 
        widget.itemData.perChange != "0") {
      _chp = widget.itemData.perChange!;
    }
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
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  // Helper to check if this item is likely visible in the viewport
  bool _isVisibleInViewport() {
    // This is a simple heuristic - items created recently are likely visible
    return DateTime.now().difference(_creationTime).inMilliseconds < 500;
  }
  
  // Set up a focused socket listener that only updates this item
  void _setupSocketListener() {
    final token = widget.itemData.token?.toString();
    if (token == null) return;
    
    final websocket = ProviderScope.containerOf(context).read(websocketProvider);
    
    // Pre-load with socket data if available - FORCE update immediately
    final socketData = websocket.socketDatas[token];
    if (socketData != null) {
      _updateFromSocketData(socketData);
      // Force immediate UI update without throttling for initial data
      if (mounted) setState(() {});
    }
    
    // Set up subscription that only listens for this token
    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(token)) {
        final socketData = data[token];
        if (socketData != null) {
          // Check if data actually changed
          final hasChanged = _updateFromSocketData(socketData);
          
          // Always update visible items immediately for better UX
          if (hasChanged && mounted) {
            // Skip throttling for important updates (like price changes)
            if (_isVisibleInViewport()) {
              setState(() {});
            } else {
              // Only throttle updates for off-screen items
              final now = DateTime.now();
              if (now.difference(_lastUpdateTime).inMilliseconds > 300) {
                _lastUpdateTime = now;
                setState(() {});
              }
            }
          }
        }
      }
    });
  }
  
  // Update local state from socket data, return true if values changed
  bool _updateFromSocketData(dynamic socketData) {
    bool hasUpdates = false;
    
    // Handle lp (last price)
    if (socketData.containsKey('lp') && socketData['lp'] != null) {
      final newLtp = socketData['lp'].toString();
      if (newLtp != "null" && newLtp != _ltp) {
        _ltp = newLtp;
        hasUpdates = true;
      }
    }
    
    // Handle chng (change)
    if (socketData.containsKey('chng') && socketData['chng'] != null) {
      final newCh = socketData['chng'].toString();
      if (newCh != "null" && newCh != _ch) {
        _ch = newCh;
        hasUpdates = true;
      }
    }
    
    // Handle pc (percent change)
    if (socketData.containsKey('pc') && socketData['pc'] != null) {
      final newChp = socketData['pc'].toString();
      if (newChp != "null" && newChp != _chp) {
        _chp = newChp;
        hasUpdates = true;
      }
    }
    
    // Calculate change and perChange if missing but we have ltp and close price
    if (socketData.containsKey('c') && 
        socketData['c'] != null && 
        socketData.containsKey('lp') && 
        socketData['lp'] != null) {
      
      try {
        final close = double.parse(socketData['c'].toString());
        final ltp = double.parse(socketData['lp'].toString());
        
        if (close > 0 && ltp > 0) {
          // Calculate change if it's missing or invalid
          if (!socketData.containsKey('chng') || 
              socketData['chng'] == null || 
              socketData['chng'] == "null") {
            final change = (ltp - close).toStringAsFixed(2);
            if (change != _ch) {
              _ch = change;
              hasUpdates = true;
            }
          }
          
          // Calculate percent change if it's missing or invalid
          if (!socketData.containsKey('pc') || 
              socketData['pc'] == null || 
              socketData['pc'] == "null") {
            final perChange = ((ltp - close) * 100 / close).toStringAsFixed(2);
            if (perChange != _chp) {
              _chp = perChange;
              hasUpdates = true;
            }
          }
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    
    return hasUpdates;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fix hierarchy: Expanded outside RepaintBoundary
            Expanded(
              child: RepaintBoundary(
                child: _StaticIndexContent(
                  itemData: widget.itemData,
                  exch: widget.indexProvider.slectedExch,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            ),
            
            // Dynamic content that needs to update
            _DynamicPriceContent(
              ltp: _ltp,
              ch: _ch,
              chp: _chp,
              isDarkMode: widget.isDarkMode,
            ),
            
            // Action button that only appears in certain contexts
            // Use RepaintBoundary to isolate rendering
            if (!widget.src)
              RepaintBoundary(
                child: _ActionButton(
                  ischeck: widget.ischeck,
                  itemData: widget.itemData,
                  indexProvider: widget.indexProvider,
                  isDarkMode: widget.isDarkMode,
                  indexPosition: widget.indexPosition,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleTap(BuildContext context) async {
    try {
      // First, safely fetch the quote data
      await widget.marketWatch.fetchScripQuoteIndex(
          widget.itemData.token?.toString() ?? "",
          widget.indexProvider.slectedExch?.toString() ?? "",
          context);

      final quots = widget.marketWatch.getQuotes;
      
      // Make sure we have valid quote data before proceeding
      if (quots == null) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Could not fetch details for this index",
            backgroundColor: Colors.red);
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
      
      // Only close the bottom sheet if we have valid data
      Navigator.pop(context);
      
      // Call depth APIs with the safely constructed arguments
      if (depthArgs.token.isNotEmpty && depthArgs.exch.isNotEmpty) {
        await widget.marketWatch.calldepthApis(context, depthArgs, "");
      }
    } catch (e) {
      // Handle any exceptions
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Error loading index details",
          backgroundColor: Colors.red);
      debugPrint("Error in index onTap: $e");
    }
  }
}

// Static content widget that won't rebuild with price changes
class _StaticIndexContent extends StatelessWidget {
  final dynamic itemData;
  final String? exch;
  final bool isDarkMode;
  
  const _StaticIndexContent({
    Key? key,
    required this.itemData,
    required this.exch,
    required this.isDarkMode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Don't return an Expanded here since it's already wrapped in an Expanded
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          itemData.idxname!.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyles.scripNameTxtStyle.copyWith(
            color: isDarkMode ? colors.colorWhite : colors.colorBlack
          ),
        ),
        const SizedBox(height: 4),
        CustomExchBadge(exch: exch ?? ""),
      ],
    );
  }
}

// Dynamic price content that rebuilds with socket data
class _DynamicPriceContent extends StatelessWidget {
  final String ltp;
  final String ch;
  final String chp;
  final bool isDarkMode;
  
  // Cache for text styles to avoid recreation
  static final Map<String, TextStyle> _styleCache = {};
  
  // Cache for color calculations
  static final Map<String, Color> _colorCache = {};
  
  const _DynamicPriceContent({
    Key? key,
    required this.ltp,
    required this.ch,
    required this.chp,
    required this.isDarkMode,
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
      if (value.toString().startsWith("-") || percentValue.toString().startsWith('-')) {
        _colorCache[key] = colors.darkred;
      } else if ((value.toString() == "null" || percentValue.toString() == "null") ||
                (value.toString() == "0.00" || percentValue.toString() == "0.00")) {
        _colorCache[key] = colors.ltpgrey;
      } else {
        _colorCache[key] = colors.ltpgreen;
      }
    }
    return _colorCache[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    // Pre-calculate all styles at once to avoid repeated calculations
    final priceStyle = _getCachedStyle(
      isDarkMode ? colors.colorWhite : colors.colorBlack,
      14,
      FontWeight.w600
    );
    
    final changeColor = _getCachedChangeColor(ch, chp);
    final changeStyle = _getCachedStyle(changeColor, 12, FontWeight.w600);
    
    // Create the price text once with proper formatting
    final String formattedChange = "${ch == "null" ? 0.00 : ch} (${chp == "null" ? 0.00 : chp}%)";
    
    // Avoid unnecessary nested widgets when possible
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text("₹$ltp", style: priceStyle),
          const SizedBox(height: 4),
          Text(formattedChange, style: changeStyle),
        ],
      ),
    );
  }
}

// Action button widget
class _ActionButton extends StatelessWidget {
  final bool ischeck;
  final dynamic itemData;
  final dynamic indexProvider;
  final bool isDarkMode;
  final int indexPosition;
  
  const _ActionButton({
    Key? key,
    required this.ischeck,
    required this.itemData,
    required this.indexProvider,
    required this.isDarkMode,
    required this.indexPosition,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (ischeck) {
          Fluttertoast.showToast(
              msg: "Scrip Already Exist!!",
              backgroundColor: Colors.amber);
        } else {
          // Get the first available position in the index list (0 by default)
          await indexProvider.changeIndex(
              itemData, context, indexPosition); // Use the actual position that was long-pressed

          Navigator.of(context).pop();
        }
      },
      icon: SvgPicture.asset(
        color: isDarkMode && ischeck
            ? colors.colorLightBlue
            : ischeck
                ? colors.colorBlue
                : colors.colorGrey,
        ischeck ? assets.bookmarkIcon : assets.bookmarkedIcon,
      ),
    );
  }
}
