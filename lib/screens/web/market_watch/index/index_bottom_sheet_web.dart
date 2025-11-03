import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../provider/index_list_provider.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/list_divider.dart';

class IndexBottomSheetWeb extends ConsumerStatefulWidget {
  final dynamic defaultIndex;
  final int indexPosition;
  const IndexBottomSheetWeb(
      {super.key, required this.defaultIndex, required this.indexPosition});

  @override
  ConsumerState<IndexBottomSheetWeb> createState() => _IndexBottomSheetWebState();
}

class _IndexBottomSheetWebState extends ConsumerState<IndexBottomSheetWeb> {
  late PageController _pageController;
  final List<String> _exchanges = ["NSE", "BSE", "MCX"];
  int _currentPageIndex = 0;
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    final indexProvide = ref.read(indexListProvider);
    // Find the initial page index based on current selected exchange
    _currentPageIndex =
        _exchanges.indexOf(indexProvide.slectedExch.toUpperCase());
    if (_currentPageIndex == -1) _currentPageIndex = 0;

    _pageController = PageController(initialPage: _currentPageIndex);
    
    // Initialize scroll controllers for each exchange/page
    for (int i = 0; i < _exchanges.length; i++) {
      _scrollControllers[i] = ScrollController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all scroll controllers
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    _scrollControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final indexProvide = ref.watch(indexListProvider);
    final marketWatch = ref.watch(marketWatchProvider);

    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    "Indices",
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
                            padding: const EdgeInsets.all(5),
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

            // Tabs section - full width
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? WebDarkColors.background
                    : WebColors.background,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tabs content
                  Container(
                    height: 40,
                    child: Row(
                      children: [
                        // Exchange tabs - each taking equal width
                        ..._exchanges.asMap().entries.map((entry) {
                          final index = entry.key;
                          final exchange = entry.value;
                          final isSelected = _currentPageIndex == index;

                          return Container(
                            width: 95.0, // Fixed width to match watchlist tabs
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    _currentPageIndex = index;
                                  });
                                  // Use jumpToPage to avoid animation through intermediate tabs
                                  _pageController.jumpToPage(index);
                                  // Call the existing function to update the list
                                  await indexProvide.fetchIndexList(
                                      exchange, context);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      child: Text(
                                        exchange,
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: isSelected
                                              ? theme.isDarkMode
                                                  ? WebDarkColors.primary
                                                  : WebColors.primary
                                              : theme.isDarkMode
                                                  ? WebDarkColors.textSecondary
                                                  : WebColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    // Animated underline indicator
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      height: 2,
                                      width: isSelected ? 77 : 0,
                                      margin: const EdgeInsets.only(top: 1),
                                      decoration: BoxDecoration(
                                        color: WebColors.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider(
            //     color: theme.isDarkMode
            //         ? WebDarkColors.divider
            //         : WebColors.divider),

            // Info text
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    assets.dInfo,
                    color: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Click icon to replace symbol in Slot ${widget.indexPosition + 1}",
                    style: WebTextStyles.caption(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                          fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable list content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _exchanges.length,
                onPageChanged: (index) async {
                  setState(() {
                    _currentPageIndex = index;
                  });
                  // Call the existing function to update the list
                  await indexProvide.fetchIndexList(
                      _exchanges[index], context);
                },
                itemBuilder: (context, pageIndex) {
                  final scrollController = _scrollControllers[pageIndex]!;
                  
                  return indexProvide.isLoad
                      ? const Center(child: CircularProgressIndicator())
                      : indexProvide.indValuesList.isNotEmpty
                          ? ScrollConfiguration(
                              behavior: const MaterialScrollBehavior()
                                  .copyWith(scrollbars: false),
                              child: RawScrollbar(
                                controller: scrollController,
                                thumbVisibility: true,
                                thickness: 6,
                                radius: const Radius.circular(0),
                                thumbColor: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                        .withOpacity(0.5)
                                    : WebColors.textSecondary.withOpacity(0.5),
                                child: ListView.builder(
                                  controller: scrollController,
                                  shrinkWrap: false,
                                  physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  itemCount: indexProvide.indValuesList.length * 2 - 1,
                                  itemBuilder: (BuildContext context, idx) {
                                    // For odd indices, show divider
                                    if (idx.isOdd) {
                                      return ListDivider();
                                    }

                                    int index = idx ~/ 2;
                                    // Get the current index data
                                    var itemData = indexProvide.indValuesList[index];

                                    // Determine if the index is checked
                                    bool ischeck = indexProvide.defaultIndexList!
                                        .indValues!
                                        .any((element) =>
                                            element.token == itemData.token);

                                    return IndexListItemWithStreamWeb(
                                      key: ValueKey('index-item-${itemData.token}'),
                                      itemData: itemData,
                                      indexProvider: indexProvide,
                                      marketWatch: marketWatch,
                                      ischeck: ischeck,
                                      isDarkMode: theme.isDarkMode,
                                      indexPosition: widget.indexPosition,
                                    );
                                  }),
                              ),
                            )
                          : Center(
                              child: Text(
                                "No Data found",
                                style: WebTextStyles.sub(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textSecondary
                                      : WebColors.textSecondary,
                                  fontWeight: WebFonts.regular,
                                ),
                              ),
                            );
                },
              ),
            )
          ],
        ),
    );
  }
}

// New optimized widget with its own socket stream subscription
class IndexListItemWithStreamWeb extends StatefulWidget {
  final dynamic itemData;
  final dynamic indexProvider;
  final dynamic marketWatch;
  final bool ischeck;
  final bool isDarkMode;
  final int indexPosition;

  const IndexListItemWithStreamWeb(
      {Key? key,
      required this.itemData,
      required this.indexProvider,
      required this.marketWatch,
      required this.ischeck,
      required this.isDarkMode,
      required this.indexPosition})
      : super(key: key);

  @override
  State<IndexListItemWithStreamWeb> createState() =>
      _IndexListItemWithStreamWebState();
}

class _IndexListItemWithStreamWebState
    extends State<IndexListItemWithStreamWeb> {
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

    final websocket =
        ProviderScope.containerOf(context).read(websocketProvider);

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
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        color: widget.ischeck
            ? (widget.isDarkMode
                ? WebDarkColors.surfaceVariant
                : WebColors.surfaceVariant)
            : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fix hierarchy: Expanded outside RepaintBoundary
            Expanded(
              child: RepaintBoundary(
                child: _StaticIndexContentWeb(
                  itemData: widget.itemData,
                  exch: widget.indexProvider.slectedExch,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            ),

            // Dynamic content that needs to update
            _DynamicPriceContentWeb(
              ltp: _ltp,
              ch: _ch,
              chp: _chp,
              isDarkMode: widget.isDarkMode,
            ),

            // Action button to replace the symbol
            RepaintBoundary(
              child: _ActionButtonWeb(
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

      // Only close the dialog if we have valid data
      Navigator.pop(context);

      // Call depth APIs with the safely constructed arguments
      if (depthArgs.token.isNotEmpty && depthArgs.exch.isNotEmpty) {
        await widget.marketWatch.calldepthApis(context, depthArgs, "");
      }
    } catch (e) {
      // Handle any exceptions
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Error loading index details", backgroundColor: Colors.red);
      debugPrint("Error in index onTap: $e");
    }
  }
}

// Static content widget that won't rebuild with price changes
class _StaticIndexContentWeb extends StatelessWidget {
  final dynamic itemData;
  final String? exch;
  final bool isDarkMode;

  const _StaticIndexContentWeb({
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
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            itemData.idxname!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: isDarkMode,
              color: isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

         Text(
           exch ?? "",
            style: WebTextStyles.custom(
              fontSize: 10,
              isDarkTheme: isDarkMode,
              color: isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

// Dynamic price content that rebuilds with socket data
class _DynamicPriceContentWeb extends StatelessWidget {
  final String ltp;
  final String ch;
  final String chp;
  final bool isDarkMode;

  // Cache for text styles to avoid recreation
  static final Map<String, TextStyle> _styleCache = {};

  // Cache for color calculations
  static final Map<String, Color> _colorCache = {};

  const _DynamicPriceContentWeb({
    Key? key,
    required this.ltp,
    required this.ch,
    required this.chp,
    required this.isDarkMode,
  }) : super(key: key);

  // Get cached text style
  TextStyle _getCachedStyle(Color color, double size, FontWeight? fw) {
    final key = '${color.value}|$size|${fw?.toString() ?? "null"}';
    if (!_styleCache.containsKey(key)) {
      _styleCache[key] = WebTextStyles.custom(
        fontSize: size,
        isDarkTheme: isDarkMode,
        color: color,
        fontWeight: fw ?? WebFonts.regular,
        letterSpacing: 0.0,
      );
    }
    return _styleCache[key]!;
  }

  // Get cached color based on change value
  Color _getCachedChangeColor(String value, String percentValue) {
    final key = '$value|$percentValue';
    if (!_colorCache.containsKey(key)) {
      if (value.toString().startsWith("-") ||
          percentValue.toString().startsWith('-')) {
        _colorCache[key] = isDarkMode
            ? WebDarkColors.error
            : WebColors.error;
      } else if ((value.toString() == "null" ||
              percentValue.toString() == "null") ||
          (value.toString() == "0.00" || percentValue.toString() == "0.00")) {
        _colorCache[key] = isDarkMode
            ? WebDarkColors.textSecondary
            : WebColors.textSecondary;
      } else {
        _colorCache[key] = isDarkMode
            ? WebDarkColors.success
            : WebColors.success;
      }
    }
    return _colorCache[key]!;
  }

  @override
  Widget build(BuildContext context) {
    // Pre-calculate all styles at once to avoid repeated calculations
    final priceStyle = _getCachedStyle(
      isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
      13,
      FontWeight.w700,
    );

    final changeColor = _getCachedChangeColor(ch, chp);
    final changeStyle = _getCachedStyle(
      changeColor,
      13,
      FontWeight.w700,
    );

    // Create the price text once with proper formatting
    final String formattedChange =
        "${ch == "null" ? 0.00 : ch} (${chp == "null" ? 0.00 : chp}%)";

    // Avoid unnecessary nested widgets when possible
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text("$ltp", style: changeStyle),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(formattedChange, style: priceStyle),
          ),
        ],
      ),
    );
  }
}

// Action button widget
class _ActionButtonWeb extends StatelessWidget {
  final bool ischeck;
  final dynamic itemData;
  final dynamic indexProvider;
  final bool isDarkMode;
  final int indexPosition;

  const _ActionButtonWeb(
      {Key? key,
      required this.ischeck,
      required this.itemData,
      required this.indexProvider,
      required this.isDarkMode,
      required this.indexPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0), // or any custom margin
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: (isDarkMode
                  ? WebDarkColors.primary
                  : WebColors.primary)
              .withOpacity(0.3),
          highlightColor: (isDarkMode
                  ? WebDarkColors.primary
                  : WebColors.primary)
              .withOpacity(0.2),
          onTap: () async {
            if (ischeck) {
              Fluttertoast.showToast(
                msg: "Scrip Already Exist!!",
                backgroundColor: Colors.amber,
              );
            } else {
              await indexProvider.changeIndex(
                  itemData, context, indexPosition);
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              ischeck ? assets.bookmarkIcon : assets.bookmarkedIcon,
              color: isDarkMode && ischeck
                  ? WebDarkColors.primary
                  : ischeck
                      ? WebColors.primary
                      : (isDarkMode
                          ? WebDarkColors.icon
                          : WebColors.icon),
              width: 18,
              height: 18,
            ),
          ),
        ),
      ),
    );
  }
}

