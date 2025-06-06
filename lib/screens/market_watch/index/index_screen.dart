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

class DefaultIndexList extends ConsumerStatefulWidget {
  final bool src;
  const DefaultIndexList({super.key, required this.src});

  @override
  ConsumerState<DefaultIndexList> createState() => _DefaultIndexListState();
}

class _DefaultIndexListState extends ConsumerState<DefaultIndexList> with AutomaticKeepAliveClientMixin {
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
    
    // Watch the indexListProvider to rebuild when the default index list changes
    final indexProvider = ref.watch(indexListProvider);
    
    final indexValues = indexProvider.defaultIndexList?.indValues;
    if (indexValues == null || indexValues.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Width calculation moved here to avoid context in initState
    final itemWidth = MediaQuery.of(context).size.width * 0.47;
    
    // Create a unique key based on the indices to force rebuild when they change
    final indexKey = ValueKey(indexValues.map((i) => "${i.exch}|${i.token}").join("-"));
        
        return Container(
          key: indexKey, // Add key here to force rebuild when indices change
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
            final key = ValueKey('index-${indexItem.token}-${indexItem.exch}');
            
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

// A completely static wrapper to prevent rebuilds
class OptimizedIndexItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Store providers as locals to avoid reference in nested closures
    final theme = ref.read(themeProvider);
    final marketWatch = ref.read(marketWatchProvider);
    final indexProvider = ref.read(indexListProvider);
    final token = indexItem.token?.toString();
    final exch = indexItem.exch?.toString();
    
    // Add a ValueKey that includes all important properties to ensure proper updates
    final itemKey = ValueKey('${exch}_${token}_${indexItem.idxname}');
    
    return RepaintBoundary(
      key: itemKey,
      child: InkWell(
        onTap: () => _handleTap(context, marketWatch, token, exch),
        onLongPress: () => _handleLongPress(context, indexProvider, marketWatch),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      width: src ? 0.6 : 0
                    ),
                    color: src
                        ? Colors.transparent
                        : theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8),
                    borderRadius: BorderRadius.circular(5)
                  ),
          width: itemWidth,
          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
              // Static part that never changes
              Expanded(
                child: RepaintBoundary(
                  child: _StaticIndexName(
                    name: indexItem.idxname?.toUpperCase() ?? "",
                    isDarkMode: theme.isDarkMode,
                    isSrc: src,
                  ),
                ),
              ),
              
              // Add spacing between static and dynamic parts
              const SizedBox(width: 4),
              
              // Dynamic part that updates with WebSocket data
              _LivePriceWidget(
                key: ValueKey('price_$token'),
                token: token ?? "",
                initialLtp: indexItem.ltp == null || indexItem.ltp == "null" ? "0.00" : indexItem.ltp,
                initialChange: indexItem.change == null || indexItem.change == "null" ? "0.00" : indexItem.change, 
                initialPerChange: indexItem.perChange == null || indexItem.perChange == "null" ? "0.00" : indexItem.perChange,
                isDarkMode: theme.isDarkMode,
                isSrc: src,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Handle tap on index item
  Future<void> _handleTap(BuildContext context, dynamic marketWatch, String? token, String? exch) async {
    try {
      // First, safely fetch the quote data
      await marketWatch.fetchScripQuoteIndex(
        token ?? "",
        exch ?? "",
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
  Future<void> _handleLongPress(BuildContext context, dynamic indexProvider, dynamic marketWatch) async {
    try {
      // Get the index position in the list (0-3 typically)
      final int indexPosition = indexProvider.defaultIndexList!.indValues!.indexWhere(
        (item) => item.token == indexItem.token && item.exch == indexItem.exch
      );
      
      // Only proceed if we found a valid index position
      if (indexPosition >= 0) {
        await indexProvider.fetchIndexList("NSE", context);
        
        // Pass the indexPosition directly - no conversion needed
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
              defaultIndex: indexItem, 
              src: src,
              indexPosition: indexPosition, // Pass the index position
            )
        );
        
        await indexProvider.fetchIndexList("exit", context);
        await marketWatch.requestMWScrip(context: context, isSubscribe: true);
      }
    } catch (e) {
      // Log or handle the error
      debugPrint("Error in index onLongPress: $e");
    }
  }
}

// Isolated WebSocket listener that only rebuilds when price data changes
class _LivePriceWidget extends StatefulWidget {
  final String token;
  final String initialLtp;
  final String initialChange;
  final String initialPerChange;
  final bool isDarkMode;
  final bool isSrc;
  
  const _LivePriceWidget({
    Key? key,
    required this.token,
    required this.initialLtp,
    required this.initialChange,
    required this.initialPerChange,
    required this.isDarkMode,
    required this.isSrc,
  }) : super(key: key);
  
  @override
  State<_LivePriceWidget> createState() => _LivePriceWidgetState();
}

class _LivePriceWidgetState extends State<_LivePriceWidget> {
  late String _ltp;
  late String _change;
  late String _perChange;
  StreamSubscription? _subscription;
  bool _isUpdatePending = false;
  final _debouncer = Debouncer(milliseconds: 300);
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    // Fix null display by ensuring proper default values
    _ltp = widget.initialLtp == "null" ? "0.00" : widget.initialLtp;
    _change = widget.initialChange == "null" ? "0.00" : widget.initialChange;
    _perChange = widget.initialPerChange == "null" ? "0.00" : widget.initialPerChange;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only setup once
    if (!_isInitialized) {
      _setupSocketListener();
      _isInitialized = true;
    }
  }
  
  @override
  void didUpdateWidget(_LivePriceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If token changed, update socket listener
    if (oldWidget.token != widget.token) {
      // Reset values
      _ltp = widget.initialLtp == "null" ? "0.00" : widget.initialLtp;
      _change = widget.initialChange == "null" ? "0.00" : widget.initialChange;
      _perChange = widget.initialPerChange == "null" ? "0.00" : widget.initialPerChange;
      
      // Reset socket subscription
      _subscription?.cancel();
      _isInitialized = false;
      _setupSocketListener();
      _isInitialized = true;
      
      // Force UI update
      if (mounted) setState(() {});
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _debouncer.cancel();
    super.dispose();
  }
  
  void _setupSocketListener() {
    if (widget.token.isEmpty) return;
    
    final websocket = ProviderScope.containerOf(context).read(websocketProvider);
    
    // First check if current socket data exists
    final existingData = websocket.socketDatas[widget.token];
    if (existingData != null) {
      _updateFromSocketData(existingData);
    }
    
    // Listen for future updates
    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(widget.token)) {
        final socketData = data[widget.token];
        if (socketData != null) {
          final hasChanged = _updateFromSocketData(socketData);
          
          if (hasChanged && mounted && !_isUpdatePending) {
            _isUpdatePending = true;
            
            // Debounce to prevent too many rebuilds
            _debouncer.run(() {
              if (mounted) {
                setState(() {});
                _isUpdatePending = false;
              }
            });
          }
        }
      }
    });
  }
  
  bool _updateFromSocketData(dynamic data) {
    bool hasChanged = false;
    
    // Handle null values from socket data
    final newLtp = data['lp']?.toString() ?? "0.00";
    if (newLtp != "null" && newLtp != _ltp) {
      _ltp = newLtp;
      hasChanged = true;
    }
    
    final newChange = data['chng']?.toString() ?? "0.00";
    if (newChange != "null" && newChange != _change) {
      _change = newChange;
      hasChanged = true;
    }
    
    final newPerChange = data['pc']?.toString() ?? "0.00";
    if (newPerChange != "null" && newPerChange != _perChange) {
      _perChange = newPerChange;
      hasChanged = true;
    }
    
    return hasChanged;
  }
  
  @override
  Widget build(BuildContext context) {
    // Calculate styling values
    final changeColor = _getChangeColor(_change, _perChange);
    
    return RepaintBoundary(
      child: widget.isSrc
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                    "₹$_ltp", 
                    style: _getTextStyle(
                      widget.isDarkMode ? const Color(0xffE5E5E5) : widget.isSrc ? const Color(0xff666666) : const Color(0xff000000),
                      13,
                      FontWeight.w600
                    )
                                ),
                                const SizedBox(width: 4),
                                Text(
                    "$_change ", 
                    style: _getTextStyle(changeColor, 12, FontWeight.w600)
                                ),
                                Text(
                    "($_perChange%)", 
                    style: _getTextStyle(changeColor, 12, FontWeight.w600)
                  )
                ]
                          ),
                        ],
                      )
        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                "₹$_ltp", 
                style: _getTextStyle(
                  widget.isDarkMode ? const Color(0xffE5E5E5) : const Color(0xff000000),
                  13,
                  FontWeight.w600
                )
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                    "$_change ", 
                    style: _getTextStyle(changeColor, 12, FontWeight.w600)
                                  ),
                                  Text(
                    "($_perChange%)", 
                    style: _getTextStyle(changeColor, 12, FontWeight.w600)
                                  ),
                                ],
                              )
                            ],
          ),
    );
  }
  
  // Cache for text styles
  static final Map<String, TextStyle> _textStyleCache = {};
  
  TextStyle _getTextStyle(Color color, double size, FontWeight weight) {
    final key = '${color.value}|$size|${weight.index}';
    return _textStyleCache.putIfAbsent(key, () => textStyle(color, size, weight));
  }
  
  // Cache for change colors
  static final Map<String, Color> _colorCache = {};
  
  Color _getChangeColor(String change, String perChange) {
    final key = '$change|$perChange';
    return _colorCache.putIfAbsent(key, () {
      if (change.startsWith("-") || perChange.startsWith('-')) {
        return colors.darkred;
      } else if ((change == "null" || perChange == "null") ||
                 (change == "0.00" || perChange == "0.00")) {
        return colors.ltpgrey;
      } else {
        return colors.ltpgreen;
      }
    });
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

// Debouncer helper class for throttling updates
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  void cancel() {
    _timer?.cancel();
  }
}
