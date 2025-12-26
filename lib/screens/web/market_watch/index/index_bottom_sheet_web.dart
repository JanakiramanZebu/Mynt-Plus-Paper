import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../provider/index_list_provider.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../utils/responsive_snackbar.dart';

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

  Widget _buildExchangeTab(
    String exchange,
    int index,
    bool isSelected,
    ThemesProvider theme,
    dynamic indexProvide,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () async {
          setState(() {
            _currentPageIndex = index;
          });
          // Use jumpToPage to avoid animation through intermediate tabs
          _pageController.jumpToPage(index);
          // Call the existing function to update the list
          await indexProvide.fetchIndexList(exchange, context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : (theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface),
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            exchange,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
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
                    style: WebTextStyles.dialogTitle(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.inputBorder
                        : WebColors.inputBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int index = 0; index < _exchanges.length; index++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildExchangeTab(
                        _exchanges[index],
                        index,
                        _currentPageIndex == index,
                        theme,
                        indexProvide,
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
                    widget.indexPosition < 2
                        ? "Click icon to replace symbol in Slot ${widget.indexPosition + 1}"
                        : "Click icon to replace symbol",
                    style: WebTextStyles.caption(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                          fontWeight: FontWeight.w500,
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
                                      return const ListDivider();
                                    }

                                    int index = idx ~/ 2;
                                    // Get the current index data
                                    var itemData = indexProvide.indValuesList[index];

                                    // Determine if the index is checked
                                    // Only check first 2 indices (slots) for watchlist
                                    final defaultIndices = indexProvide.defaultIndexList?.indValues ?? [];
                                    final watchlistSlots = defaultIndices.length >= 2 
                                        ? defaultIndices.take(2).toList() 
                                        : defaultIndices;
                                    bool ischeck = watchlistSlots
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
      {super.key,
      required this.itemData,
      required this.indexProvider,
      required this.marketWatch,
      required this.ischeck,
      required this.isDarkMode,
      required this.indexPosition});

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: widget.isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
        highlightColor: widget.isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        onTap: () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: widget.ischeck
              ? (widget.isDarkMode
                  ? WebDarkColors.surfaceVariant
                  : WebColors.surfaceVariant)
              : Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Index info
              Expanded(
                flex: 3,
                child: RepaintBoundary(
                  child: _StaticIndexContentWeb(
                    itemData: widget.itemData,
                    exch: widget.indexProvider.slectedExch,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              ),

              // Right side - Price data and action button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dynamic content that needs to update
                  RepaintBoundary(
                    child: _DynamicPriceContentWeb(
                      ltp: _ltp,
                      ch: _ch,
                      chp: _chp,
                      isDarkMode: widget.isDarkMode,
                    ),
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
            ],
          ),
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
        ResponsiveSnackBar.showError(context, "Could not fetch details for this index");
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
      ResponsiveSnackBar.showError(context, "Error loading index details");
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
    required this.itemData,
    required this.exch,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Don't return an Expanded here since it's already wrapped in an Expanded
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Index name
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              itemData.idxname!.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WebTextStyles.symbolList(
                isDarkTheme: isDarkMode,
                color: isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Exchange badge
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              exch ?? "",
              style: WebTextStyles.exchText(
                isDarkTheme: isDarkMode,
                color: WebColors.textSecondary,
              ),
            ),
          ],
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

  const _DynamicPriceContentWeb({
    required this.ltp,
    required this.ch,
    required this.chp,
    required this.isDarkMode,
  });

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
    // Format price values and handle invalid data
    final displayLtp = _safeFormatPrice(ltp);
    final displayChange = _safeFormatPrice(ch);
    final displayPerChange = _safeFormatPrice(chp);

    // Calculate change color based on watchlist_card_web.dart logic
    final changeColor =
        displayChange.startsWith("-") || displayPerChange.startsWith('-')
            ? isDarkMode
                ? WebDarkColors.loss
                : WebColors.loss
            : (displayChange == "0.00" || displayPerChange == "0.00")
                ? isDarkMode
                    ? WebDarkColors.textSecondary
                    : WebColors.textSecondary
                : isDarkMode
                    ? WebDarkColors.profit
                    : WebColors.profit;

    // Build the UI with web-optimized text styles matching watchlist_card_web.dart
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayLtp,
            style: WebTextStyles.priceWatch(
              isDarkTheme: isDarkMode,
              color: isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8), // Adjusted spacing to match watchlist
          Text(
            "$displayChange ($displayPerChange%)",
            style: WebTextStyles.pricePercent(
              isDarkTheme: isDarkMode,
              color: changeColor,
            ),
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
      {required this.ischeck,
      required this.itemData,
      required this.indexProvider,
      required this.isDarkMode,
      required this.indexPosition});

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
              ResponsiveSnackBar.showWarning(context, "Scrip Already Exist!!");
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

