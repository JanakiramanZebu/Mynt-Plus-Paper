import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/marketwatch_model/search_scrip_new_model.dart';
import '../models/marketwatch_model/get_quotes.dart';
import '../provider/market_watch_provider.dart';
import '../provider/thems.dart';
import '../provider/websocket_provider.dart';
import '../res/global_state_text.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/custom_exch_badge.dart';
import '../sharedWidget/list_divider.dart';
import '../sharedWidget/no_data_found.dart';

class StockSearchScreen extends ConsumerStatefulWidget {
  const StockSearchScreen({super.key});

  @override
  ConsumerState<StockSearchScreen> createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends ConsumerState<StockSearchScreen> {
  // Controllers and focus management
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Search state management
  String _searchQuery = '';
  List<ScripNewValue> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounceTimer;
  
  // UI state management
  bool _showInitialState = true;
  
  // Data management
  List<ScripNewValue> _suggestedStocks = [];
  
  // Constants
  static const Duration _debounceDelay = Duration(milliseconds: 500);
  static const Duration _focusDelay = Duration(milliseconds: 200);
  static const List<String> _popularStocks = [
    'TCS', 'RELIANCE', 'HDFCBANK', 'INFY', 'ICICIBANK'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadSuggestedStocks();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    // Clear search results when leaving the screen
    ref.read(marketWatchProvider).searchClear();
    super.dispose();
  }

  Future<void> _loadSuggestedStocks() async {
    // Show fallback data immediately
    if (mounted) {
      setState(() {
        _suggestedStocks = _createFallbackStocks();
      });
    }

    // Load real data in background and update when ready
    _loadRealSuggestedStocks();
  }

  Future<void> _loadRealSuggestedStocks() async {
    try {
      final List<ScripNewValue> suggestedStocks = [];

      // Load stocks in parallel for better performance
      final futures = _popularStocks.map((symbol) => _fetchStockData(symbol));
      final results = await Future.wait(futures, eagerError: false);
      
      for (final result in results) {
        if (result != null) {
          suggestedStocks.add(result);
        }
      }

      if (mounted) {
        setState(() {
          // Always update with real data if available, otherwise keep fallback
          _suggestedStocks = suggestedStocks.isNotEmpty ? suggestedStocks : _createFallbackStocks();
        });
      }
    } catch (e) {
      debugPrint("Error loading suggested stocks: $e");
      // Keep fallback data on error
      if (mounted) {
        setState(() {
          _suggestedStocks = _createFallbackStocks();
        });
      }
    }
  }

  Future<ScripNewValue?> _fetchStockData(String symbol) async {
    try {
      await ref.read(marketWatchProvider).fetchSearchScrip(
        searchText: symbol,
        context: context,
        segment: "EQ",
        option: false,
      );

      final allResults = ref.read(marketWatchProvider).allSearchScrip ?? [];
      final stockResults = allResults
          .where((stock) =>
              stock.tsym?.toUpperCase() == symbol.toUpperCase() &&
              (stock.exch == "NSE" || stock.exch == "BSE"))
          .toList();

      return stockResults.isNotEmpty ? stockResults.first : null;
    } catch (e) {
      debugPrint("Error loading stock $symbol: $e");
      return null;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
        if (query.isNotEmpty && _showInitialState) {
          _showInitialState = false;
        }
      });

      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDelay, () => _performSearch(query));
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      _clearSearchResults();
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _searchError = null;
    });

    try {
      await ref.read(marketWatchProvider).fetchSearchScrip(
        searchText: query,
        context: context,
        segment: "EQ",
        option: false,
      );

      final allResults = ref.read(marketWatchProvider).allSearchScrip ?? [];
      final equityStocks = allResults
          .where((stock) => stock.exch == "NSE" || stock.exch == "BSE")
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = equityStocks;
          _isSearching = false;
          _searchError = null;
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
          _searchError = "Search failed. Please try again.";
        });
      }
    }
  }

  void _clearSearchResults() {
    if (mounted) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
        _searchError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: _showInitialState ? _buildCloseAppBar(theme) : _buildSearchAppBar(theme),
      body: _showInitialState
          ? _buildInitialState(theme)
          : _buildSearchContent(theme),
    );
  }

  Widget _buildInitialState(ThemesProvider theme) {
    return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: TextWidget.custmText(
              text: "Stock Report",
              fs: 30,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 1,
            ),
          ),
            // Search container in center
            _buildCenterSearchContainer(theme),
            const SizedBox(height: 32),

            // Suggested stocks grid
            _buildSuggestedStocksGrid(_suggestedStocks, theme),
          ],
      ),
    );
  }

  Widget _buildCenterSearchContainer(ThemesProvider theme) {
    return Container(
      height: 45,
      // margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            setState(() {
              _showInitialState = false;
            });
            // Focus the search field after a short delay
            Future.delayed(_focusDelay, () {
              _searchController.clear();
              _searchFocusNode.requestFocus();
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 7),
            child: Row(
              children: [
                // Search icon
                const SizedBox(width: 12),
                SvgPicture.asset(
                  assets.searchIcon,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                // Text input placeholder
                Expanded(
                  child: TextWidget.subText(
                    text: "Search",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackSuggestedStocks(ThemesProvider theme) {
    final fallbackStocks = _createFallbackStocks();
    return _buildSuggestedStocksGrid(fallbackStocks, theme);
  }

  List<ScripNewValue> _createFallbackStocks() {
    return _popularStocks.map((symbol) => ScripNewValue(
      tsym: symbol,
      cname: _getCompanyName(symbol),
      exch: 'NSE',
      token: '', // Don't use hardcoded tokens
      symbol: symbol,
      instname: _getCompanyName(symbol),
      expDate: '',
      option: '',
    )).toList();
  }

  String _getCompanyName(String symbol) {
    const companyNames = {
      'TCS': 'Tata Consultancy Services Ltd',
      'RELIANCE': 'Reliance Industries Ltd',
      'HDFCBANK': 'HDFC Bank Ltd',
      'INFY': 'Infosys Ltd',
      'ICICIBANK': 'ICICI Bank Ltd',
    };
    return companyNames[symbol] ?? '$symbol Ltd';
  }


  Widget _buildSuggestedStocksGrid(List<ScripNewValue> stocks, ThemesProvider theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: stocks.map((stock) => _buildInitialSuggestedChip(stock, theme)).toList(),
    );
  }

  Widget _buildInitialSuggestedChip(ScripNewValue stock, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () => _navigateToStockReport(stock),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextWidget.paraText(
                text: stock.tsym ?? "",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
            fw: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(ThemesProvider theme) {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState(theme);
    } else if (_isSearching) {
      return _buildLoadingState(theme);
    } else if (_searchError != null) {
      return _buildErrorState(theme);
    } else if (_searchResults.isEmpty) {
      return _buildNoResultsState(theme);
    } else {
      return _buildSearchResults(theme);
    }
  }

  Widget _buildEmptyState(ThemesProvider theme) {
    return Column(
      children: [
        // Show suggested stocks in search results format
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: _suggestedStocks.length,
            separatorBuilder: (context, index) => const ListDivider(),
            itemBuilder: (context, index) {
              final stock = _suggestedStocks[index];
              return _buildStockTile(stock, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemesProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
          ),
          const SizedBox(height: 16),
          TextWidget.paraText(
            text: "Searching stocks...",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemesProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          TextWidget.paraText(
            text: _searchError ?? "Something went wrong",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _performSearch(_searchQuery),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
            ),
            child: TextWidget.paraText(
              text: "Retry",
              theme: theme.isDarkMode,
              color: colors.colorWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(ThemesProvider theme) {
    return const Center(
      child: NoDataFound(),
    );
  }

  Widget _buildSearchResults(ThemesProvider theme) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        return _buildStockTile(stock, theme);
      },
    );
  }

  Widget _buildStockTile(ScripNewValue stock, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        splashColor: _getSplashColor(theme),
        highlightColor: _getHighlightColor(theme),
        onTap: () => _navigateToStockReport(stock),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          dense: false,
          title: _buildStockTitle(stock, theme),
          subtitle: _buildStockSubtitle(stock, theme),
        ),
      ),
    );
  }

  Color _getSplashColor(ThemesProvider theme) {
    return theme.isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.15);
  }

  Color _getHighlightColor(ThemesProvider theme) {
    return theme.isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);
  }

  Widget _buildStockTitle(ScripNewValue stock, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "${stock.symbol?.isNotEmpty == true ? stock.symbol : stock.tsym} ",
            style: _getTextStyle(theme, 14, true),
          ),
          if (stock.option != null)
            Text(
              "${stock.option}",
              style: _getTextStyle(theme, 14, true),
            ),
        ],
      ),
    );
  }

  Widget _buildStockSubtitle(ScripNewValue stock, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          CustomExchBadge(exch: "${stock.exch}"),
          if (stock.expDate != null) ...[
            const SizedBox(width: 4),
            TextWidget.paraText(
              text: stock.expDate!,
              color: _getSecondaryTextColor(theme),
              theme: theme.isDarkMode,
              fw: 0,
            ),
          ],
          if (stock.expDate == "" && stock.cname != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: TextWidget.paraText(
                text: stock.cname!,
                textOverflow: TextOverflow.ellipsis,
                color: _getSecondaryTextColor(theme),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  TextStyle _getTextStyle(ThemesProvider theme, double fontSize, bool isPrimary) {
    return TextWidget.textStyle(
      fontSize: fontSize,
      theme: theme.isDarkMode,
      color: isPrimary
          ? (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight)
          : _getSecondaryTextColor(theme),
      fw: 0,
    );
  }

  Color _getSecondaryTextColor(ThemesProvider theme) {
    return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
  }

 

  void _navigateToStockReport(ScripNewValue stock) async {
    // Check if we have valid token and exchange
    if (stock.token == null || stock.token!.isEmpty || stock.exch == null || stock.exch!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock data is not available. Please search for the stock first.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      // Fetch fresh LTP data first
      await ref.read(marketWatchProvider).fetchScripQuote(
        stock.token!,
        stock.exch!,
        context,
      );

      // Get the fresh quotes data
      final freshQuotes = ref.read(marketWatchProvider).getQuotes;
      
      if (freshQuotes != null && freshQuotes.stat == "Ok") {
        // Establish WebSocket connection for live updates (same as calldepthApis)
        await ref.read(websocketProvider).establishConnection(
          channelInput: "${stock.exch}|${stock.token}",
          task: "d",
          context: context,
        );
        
    final depthArgs = _createDepthInputArgs(stock);

        // Navigate with fresh LTP data + live updates enabled
    Navigator.pushNamed(
      context,
      Routes.newFundamental,
      arguments: {
        'wlValue': depthArgs,
            'depthData': freshQuotes,
          },
        );
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch stock data. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching stock data. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  DepthInputArgs _createDepthInputArgs(ScripNewValue stock) {
    return DepthInputArgs(
      exch: stock.exch ?? "",
      token: stock.token ?? "",
      tsym: stock.tsym ?? "",
      instname: stock.instname ?? "",
      symbol: stock.symbol ?? "",
      expDate: stock.expDate ?? "",
      option: stock.option ?? "",
    );
  }

  // AppBar with just X close button (initial state)
  PreferredSizeWidget _buildCloseAppBar(ThemesProvider theme) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 0,
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.grey.withOpacity(0.4),
                highlightColor: Colors.grey.withOpacity(0.2),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar with search field (when search is focused) - matches watchlist screen
  PreferredSizeWidget _buildSearchAppBar(ThemesProvider theme) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 1,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 48,
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      leading: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.grey.withOpacity(0.4),
          highlightColor: Colors.grey.withOpacity(0.2),
          onTap: () {
            _searchFocusNode.unfocus();
            setState(() {
              _showInitialState = true;
              _searchQuery = '';
              _searchResults = [];
            });
            _searchController.clear();
          },
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 18,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
          ),
        ),
      ),
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 12), // Add right margin to prevent going out of screen
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? colors.searchBgDark
              : colors.searchBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            // Center the search icon vertically
            Center(
              child: SvgPicture.asset(
                assets.searchIcon, 
                width: 18, 
                height: 18, 
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                onChanged: (value) {
                  _onSearchChanged();
                },
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: "Search for a stock",
                  hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    fw: 0,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12, // Increased vertical padding for better alignment
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: theme.isDarkMode
                      ? Colors.white.withOpacity(.15)
                      : Colors.black.withOpacity(.15),
                  highlightColor: theme.isDarkMode
                      ? Colors.white.withOpacity(.08)
                      : Colors.black.withOpacity(.08),
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      assets.removeIcon,
                      width: 16,
                      height: 16,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

}
