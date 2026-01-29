// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../provider/index_list_provider.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';

import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/responsive_extensions.dart';
import 'index_bottom_sheet_web.dart';

class DefaultIndexListWeb extends ConsumerStatefulWidget {
  final bool src;
  const DefaultIndexListWeb({super.key, required this.src});

  @override
  ConsumerState<DefaultIndexListWeb> createState() => _DefaultIndexListWebState();
}

class _DefaultIndexListWebState extends ConsumerState<DefaultIndexListWeb>
    with AutomaticKeepAliveClientMixin {
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
    final theme = ref.watch(themeProvider);
    // Watch the indexListProvider to rebuild when the default index list changes
    final indexProvider = ref.watch(indexListProvider);
    final marketWatch = ref.read(marketWatchProvider);

    final indexValues = indexProvider.defaultIndexList?.indValues;
    if (indexValues == null || indexValues.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // For watchlist mode (src: false), only show first 2 indices
    final displayIndices = widget.src 
        ? indexValues  // AppBar mode: show all
        : (indexValues.length >= 2 
            ? indexValues.take(2).toList() 
            : indexValues);  // Watchlist mode: show only 2

    // Create a unique key based on the indices to force rebuild when they change
    final indexKey =
        ValueKey(indexValues.map((i) => "${i.exch}|${i.token}").join("-"));

    return widget.src
        ? Container(
            key: indexKey, // Add key here to force rebuild when indices change
            margin: EdgeInsets.zero, // Remove top margin to prevent overflow
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48, // Fixed height to fit in appbar
            child: RepaintBoundary(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(indexValues.length, (index) {
                    return Container(
                      margin: EdgeInsets.only(
                        right: index < indexValues.length - 1 ? 8 : 0,
                      ),
                      child: OptimizedIndexItemWeb(
                        key: ValueKey(
                            'index-${indexValues[index].token}-${indexValues[index].exch}'),
                        indexItem: indexValues[index],
                        itemWidth: null, // Let content determine width
                      ),
                    );
                  }),
                ),
              ),
            ),
          )
        : Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: context.responsive(mobile: 48.0, tablet: 52.0, desktop: 55.0),
            width: double.infinity,
            // Always use horizontal scroll - cards never shrink
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(displayIndices.length.clamp(1, 2), (i) {
                  if (i >= displayIndices.length) return const SizedBox.shrink();
                  final item = displayIndices[i];
                  // Fixed card width - never shrinks
                  final cardWidth = context.responsive(mobile: 160.0, tablet: 170.0, desktop: 180.0);
                  return Container(
                    width: cardWidth,
                    height: double.infinity,
                    margin: EdgeInsets.only(
                      right: i < displayIndices.length.clamp(1, 2) - 1 ? 4 : 0,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const RoundedRectangleBorder(),
                      child: InkWell(
                        customBorder: const RoundedRectangleBorder(),
                        splashColor: theme.isDarkMode
                            ? WebDarkColors.primary.withValues(alpha: 0.1)
                            : WebColors.primary.withValues(alpha: 0.1),
                        highlightColor: theme.isDarkMode
                            ? WebDarkColors.primary.withValues(alpha: 0.05)
                            : WebColors.primary.withValues(alpha: 0.05),
                        onTap: () {
                          _handleTap(
                              context,
                              marketWatch,
                              item.token?.toString() ?? "",
                              item.exch?.toString() ?? "");
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsive(mobile: 4.0, tablet: 6.0, desktop: 8.0),
                            vertical: context.responsive(mobile: 4.0, tablet: 6.0, desktop: 8.0),
                          ),
                          decoration: const BoxDecoration(
                            color: WebDarkColors.background,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  item.idxname ?? "",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: true,
                                    color: WebDarkColors.textPrimary,
                                    fontWeight: WebFonts.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(height: context.responsive(mobile: 2.0, tablet: 3.0, desktop: 4.0)),
                              Flexible(
                                child: _LivePriceWidgetWeb(
                                  key: ValueKey('price_${item.token ?? ""}'),
                                  token: item.token?.toString() ?? "",
                                  initialLtp:
                                      (item.ltp == null || item.ltp == "null")
                                          ? "0.00"
                                          : item.ltp?.toString() ?? "0.00",
                                  initialChange: (item.change == null ||
                                          item.change == "null")
                                      ? "0.00"
                                      : item.change?.toString() ?? "0.00",
                                  initialPerChange: (item.perChange == null ||
                                          item.perChange == "null")
                                      ? "0.00"
                                      : item.perChange?.toString() ?? "0.00",
                                  isDarkMode: theme.isDarkMode,
                                  src: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
  }


  Future<void> _handleTap(BuildContext context, dynamic marketWatch,
      String? token, String? exch) async {
    try {
      // First, safely fetch the quote data
      await marketWatch.fetchScripQuoteIndex(token ?? "", exch ?? "", context);

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
}

// A completely static wrapper to prevent rebuilds
class OptimizedIndexItemWeb extends ConsumerWidget {
  final dynamic indexItem;
  final double? itemWidth; // Make nullable to allow flexible width

  const OptimizedIndexItemWeb({
    super.key,
    required this.indexItem,
    this.itemWidth, // Optional - if null, content determines width
  });

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context, marketWatch, token, exch),
          onLongPress: () =>
              _handleLongPress(context, indexProvider, marketWatch),
          highlightColor: theme.isDarkMode
              ? WebDarkColors.primary.withOpacity(0.1)
              : WebColors.primary.withOpacity(0.1),
          splashColor: theme.isDarkMode
              ? WebDarkColors.primary.withOpacity(0.2)
              : WebColors.primary.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.transparent, // Transparent to match glassmorphism appbar
            ),
            constraints: BoxConstraints(
              maxHeight: 48, // Constrain height to prevent overflow
              minWidth: itemWidth ?? 0, // Use itemWidth if provided, else no min width
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Static part that never changes
                  RepaintBoundary(
                    child: _StaticIndexNameWeb(
                      name: indexItem.idxname?.toUpperCase() ?? "",
                      isDarkMode: theme.isDarkMode,
                    ),
                  ),

                  // Add spacing between static and dynamic parts
                  const SizedBox(height: 4),

                  // Dynamic part that updates with WebSocket data
                  _LivePriceWidgetWeb(
                    key: ValueKey('price_$token'),
                    token: token ?? "",
                    initialLtp: indexItem.ltp == null || indexItem.ltp == "null"
                        ? "0.00"
                        : indexItem.ltp,
                    initialChange:
                        indexItem.change == null || indexItem.change == "null"
                            ? "0.00"
                            : indexItem.change,
                    initialPerChange: indexItem.perChange == null ||
                            indexItem.perChange == "null"
                        ? "0.00"
                        : indexItem.perChange,
                    isDarkMode: theme.isDarkMode,
                    src: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, dynamic marketWatch,
      String? token, String? exch) async {
    try {
      // First, safely fetch the quote data
      await marketWatch.fetchScripQuoteIndex(token ?? "", exch ?? "", context);

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
  Future<void> _handleLongPress(
      BuildContext context, dynamic indexProvider, dynamic marketWatch) async {
    try {
      // Get the index position in the list (0-3 typically)
      final int indexPosition = indexProvider.defaultIndexList!.indValues!
          .indexWhere((item) =>
              item.token == indexItem.token && item.exch == indexItem.exch);

      // Only proceed if we found a valid index position
      if (indexPosition >= 0) {
        await indexProvider.fetchIndexList("NSE", context);

        // Pass the indexPosition directly - no conversion needed
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: IndexBottomSheetWeb(
                defaultIndex: indexItem,
                indexPosition: indexPosition, // Pass the index position
              ),
            );
          },
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
class _LivePriceWidgetWeb extends StatefulWidget {
  final String token;
  final String initialLtp;
  final String initialChange;
  final String initialPerChange;
  final bool isDarkMode;
  final bool src;

  const _LivePriceWidgetWeb({
    super.key,
    required this.token,
    required this.initialLtp,
    required this.initialChange,
    required this.initialPerChange,
    required this.isDarkMode,
    required this.src,
  });

  @override
  State<_LivePriceWidgetWeb> createState() => _LivePriceWidgetWebState();
}

class _LivePriceWidgetWebState extends State<_LivePriceWidgetWeb> {
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
    _perChange =
        widget.initialPerChange == "null" ? "0.00" : widget.initialPerChange;
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
  void didUpdateWidget(_LivePriceWidgetWeb oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If token changed, update socket listener
    if (oldWidget.token != widget.token) {
      // Reset values
      _ltp = widget.initialLtp == "null" ? "0.00" : widget.initialLtp;
      _change = widget.initialChange == "null" ? "0.00" : widget.initialChange;
      _perChange =
          widget.initialPerChange == "null" ? "0.00" : widget.initialPerChange;

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

    final websocket =
        ProviderScope.containerOf(context).read(websocketProvider);

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

    // Use Wrap - stays on same line when space available, wraps when not
    return RepaintBoundary(
      child: Wrap(
        spacing: 6,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            _ltp,
            style: _getTextStyle(changeColor, widget.src ? 13 : 13, 2),
          ),
          Text(
            "$_change ($_perChange%)",
            style: _getTextStyle(
              widget.isDarkMode ? WebDarkColors.textSecondary : WebDarkColors.textSecondary,
              widget.src ? 12 : 13,
              2,
            ),
          ),
        ],
      ),
    );
  }

  // Cache for text styles
  static final Map<String, TextStyle> _textStyleCache = {};

  TextStyle _getTextStyle(Color color, double size, [int? fw]) {
    final key = '${color.value}|$size|${fw ?? "null"}';
    return _textStyleCache.putIfAbsent(
      key,
      () => WebTextStyles.priceWatch(
          isDarkTheme: true,
          color: color,
      ),
    );
  }

  // Cache for change colors
  static final Map<String, Color> _colorCache = {};

  Color _getChangeColor(String change, String perChange) {
    final key = '$change|$perChange';
    return _colorCache.putIfAbsent(key, () {
      if (change.startsWith("-") || perChange.startsWith('-')) {
        return widget.isDarkMode ? WebDarkColors.error : WebColors.error;
      } else if ((change == "null" || perChange == "null") ||
          (change == "0.00" || perChange == "0.00")) {
        return widget.isDarkMode
            ? WebDarkColors.textSecondary
            : WebColors.textSecondary;
      } else {
        return widget.isDarkMode ? WebDarkColors.success : WebColors.success;
      }
    });
  }
}

// Reusable static content widget that won't rebuild
class _StaticIndexNameWeb extends StatelessWidget {
  final String name;
  final bool isDarkMode;

  // Cache for text styles to avoid recreation
  static final Map<String, TextStyle> _styleCache = {};

  const _StaticIndexNameWeb({
    required this.name,
    required this.isDarkMode,
  });

  // Get cached text style
  TextStyle _getNameStyle() {
    final key = 'name|${isDarkMode ? 1 : 0}';
    if (!_styleCache.containsKey(key)) {
      _styleCache[key] = WebTextStyles.symbolList(
        isDarkTheme: true,
        color: isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
      );
    }
    return _styleCache[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
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
