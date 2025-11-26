import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../provider/thems.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/websocket_provider.dart';
import 'dart:async';

class DashboardScreenWeb extends ConsumerStatefulWidget {
  const DashboardScreenWeb({super.key});

  @override
  ConsumerState<DashboardScreenWeb> createState() => _DashboardScreenWebState();
}

class _DashboardScreenWebState extends ConsumerState<DashboardScreenWeb> {
  final ScrollController _indexScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize default index list and fetch indices from API
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final indexProvider = ref.read(indexListProvider);
        // First get default list (fallback)
        await indexProvider.getDeafultIndexList(context);
        // Then fetch all indices from API - this will give us more indices
        // We can use fetchIndexList to get NSE indices, or fetchAllIndex for all exchanges
        // For now, let's fetch NSE indices which typically has the most popular ones
        await indexProvider.fetchIndexList("NSE", context);
        ref.read(marketWatchProvider).requestMWScrip(context: context, isSubscribe: true);
      }
    });
  }

  @override
  void dispose() {
    _indexScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final indexProvider = ref.watch(indexListProvider);
    
    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? WebDarkColors.background
          : WebColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top indices section
              // _buildTopIndicesSection(theme, indexProvider),
              Container(
                // height: 100,
                // width: 100,
                // color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIndicesSection(ThemesProvider theme, IndexListProvider indexProvider) {
    // Use indexList from API if available (has more indices), otherwise fallback to defaultIndexList
    final allIndexValues = indexProvider.indexList?.indValues ?? indexProvider.defaultIndexList?.indValues;
    // Limit to first 10 indices
    final indexValues = allIndexValues != null && allIndexValues.length > 10 
        ? allIndexValues.take(10).toList() 
        : allIndexValues;
    final hasIndices = indexValues != null && indexValues.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and navigation arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with icons
            Row(
              children: [
                Text(
                  'Top indices',
                  style: WebTextStyles.head(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                    fontWeight: WebFonts.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // Green up arrow icon
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: theme.isDarkMode ? WebDarkColors.success : WebColors.success,
                ),
                const SizedBox(width: 4),
                // Red down arrow icon
                Icon(
                  Icons.trending_down,
                  size: 16,
                  color: theme.isDarkMode ? WebDarkColors.error : WebColors.error,
                ),
              ],
            ),
            // Navigation arrows
            Row(
              children: [
                // Left arrow button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _scrollIndices(-200);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.isDarkMode
                            ? WebDarkColors.surface
                            : WebColors.surface,
                        border: Border.all(
                          color: theme.isDarkMode
                              ? WebDarkColors.divider
                              : WebColors.divider,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 14,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Right arrow button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _scrollIndices(200);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.isDarkMode
                            ? WebDarkColors.surface
                            : WebColors.surface,
                        border: Border.all(
                          color: theme.isDarkMode
                              ? WebDarkColors.divider
                              : WebColors.divider,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Index cards - horizontal scrollable
        if (hasIndices)
          Container(
            height: 140, // Fixed height for index cards
            child: Stack(
              children: [
                // Scrollable index list
                SingleChildScrollView(
                  controller: _indexScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: indexValues.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Container(
                        margin: EdgeInsets.only(
                          right: index < indexValues.length - 1 ? 12 : 0,
                        ),
                        child: _DashboardIndexCard(
                          indexItem: item,
                          isDarkMode: theme.isDarkMode,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Gradient overlay on the right to indicate scrollability
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          theme.isDarkMode
                              ? WebDarkColors.background
                              : WebColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 120,
            child: Center(
              child: Text(
                'Loading indices...',
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        // "See all indices" link
        GestureDetector(
          onTap: () {
            // TODO: Navigate to all indices screen
          },
          child: Text(
            'See all indices',
            style: WebTextStyles.caption(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.primary
                  : WebColors.primary,
              fontWeight: WebFonts.medium,
            ),
          ),
        ),
      ],
    );
  }

  void _scrollIndices(double offset) {
    if (_indexScrollController.hasClients) {
      _indexScrollController.animateTo(
        _indexScrollController.offset + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

// Custom index card widget for dashboard
class _DashboardIndexCard extends ConsumerStatefulWidget {
  final dynamic indexItem;
  final bool isDarkMode;

  const _DashboardIndexCard({
    required this.indexItem,
    required this.isDarkMode,
  });

  @override
  ConsumerState<_DashboardIndexCard> createState() => _DashboardIndexCardState();
}

class _DashboardIndexCardState extends ConsumerState<_DashboardIndexCard> {
  StreamSubscription? _subscription;
  String _ltp = "0.00";
  String _change = "0.00";
  String _perChange = "0.00";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final item = widget.indexItem;
    _ltp = (item.ltp == null || item.ltp == "null")
        ? "0.00"
        : item.ltp?.toString() ?? "0.00";
    _change = (item.change == null || item.change == "null")
        ? "0.00"
        : item.change?.toString() ?? "0.00";
    _perChange = (item.perChange == null || item.perChange == "null")
        ? "0.00"
        : item.perChange?.toString() ?? "0.00";
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

  void _setupSocketListener() {
    final token = widget.indexItem.token?.toString() ?? "";
    if (token.isEmpty) return;

    final websocket = ref.read(websocketProvider);

    // Check existing data
    final existingData = websocket.socketDatas[token];
    if (existingData != null) {
      _updateFromSocketData(existingData);
    }

    // Listen for updates
    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(token) && mounted) {
        final socketData = data[token];
        if (socketData != null) {
          _updateFromSocketData(socketData);
          setState(() {});
        }
      }
    });
  }

  void _updateFromSocketData(dynamic data) {
    final newLtp = data['lp']?.toString() ?? "0.00";
    if (newLtp != "null") _ltp = newLtp;

    final newChange = data['chng']?.toString() ?? "0.00";
    if (newChange != "null") _change = newChange;

    final newPerChange = data['pc']?.toString() ?? "0.00";
    if (newPerChange != "null") _perChange = newPerChange;
  }

  Color _getChangeColor() {
    if (_change.startsWith("-") || _perChange.startsWith('-')) {
      return widget.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else if (_change == "0.00" || _perChange == "0.00") {
      return widget.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    } else {
      return widget.isDarkMode ? WebDarkColors.success : WebColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor();
    final marketWatch = ref.read(marketWatchProvider);

    return GestureDetector(
      onTap: () async {
        try {
          await marketWatch.fetchScripQuoteIndex(
            widget.indexItem.token?.toString() ?? "",
            widget.indexItem.exch?.toString() ?? "",
            context,
          );
          // Handle navigation to index detail if needed
        } catch (e) {
          debugPrint("Error tapping index: $e");
        }
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? WebDarkColors.surface
              : WebColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isDarkMode
                ? WebDarkColors.divider.withOpacity(0.3)
                : WebColors.divider.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Index name with underline
            Text(
              widget.indexItem.idxname?.toUpperCase() ?? "",
              style: WebTextStyles.sub(
                isDarkTheme: widget.isDarkMode,
                color: widget.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
                fontWeight: WebFonts.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              height: 1,
              width: 30,
              color: widget.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
            const SizedBox(height: 4),
            // Current value with ₹ symbol
            Text(
              "₹$_ltp",
              style: WebTextStyles.title(
                isDarkTheme: widget.isDarkMode,
                color: changeColor,
                fontWeight: WebFonts.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Change and percentage
            Row(
              children: [
                Text(
                  _change.startsWith("-") ? _change : "+$_change",
                  style: WebTextStyles.caption(
                    isDarkTheme: widget.isDarkMode,
                    color: changeColor,
                    fontWeight: WebFonts.medium,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "($_perChange%)",
                  style: WebTextStyles.caption(
                    isDarkTheme: widget.isDarkMode,
                    color: changeColor,
                    fontWeight: WebFonts.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
