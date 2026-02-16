import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mynt_plus/api/core/api_export.dart';
import 'package:mynt_plus/locator/locator.dart';
import 'package:mynt_plus/locator/preference.dart';
import 'package:mynt_plus/models/marketwatch_model/linked_scrips.dart';
import 'package:mynt_plus/models/marketwatch_model/opt_chain_model.dart';
import 'package:mynt_plus/models/order_book_model/place_order_model.dart';
import 'package:mynt_plus/models/order_book_model/order_margin_model.dart';
import 'package:mynt_plus/provider/core/default_change_notifier.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/models/portfolio_model/position_book_model.dart';
import 'package:mynt_plus/utils/responsive_snackbar.dart';

final strategyBuilderProvider =
    ChangeNotifierProvider((ref) => StrategyBuilderProvider(ref));

/// Basket item model for strategy builder
class StrategyBasketItem {
  final String tsym;
  final String token;
  final String exch;
  final String strprc;
  final String optt; // CE or PE
  final String expdate;
  String buySell; // BUY or SELL
  int ordlot;
  double entryPrice;
  double ltp;
  bool checkbox;
  int lotSize;

  // Greeks
  double? iv;
  double? delta;
  double? gamma;
  double? theta;
  double? vega;

  StrategyBasketItem({
    required this.tsym,
    required this.token,
    required this.exch,
    required this.strprc,
    required this.optt,
    required this.expdate,
    required this.buySell,
    required this.ordlot,
    required this.entryPrice,
    required this.ltp,
    this.checkbox = true,
    this.lotSize = 1,
    this.iv,
    this.delta,
    this.gamma,
    this.theta,
    this.vega,
  });

  StrategyBasketItem copyWith({
    String? tsym,
    String? token,
    String? exch,
    String? strprc,
    String? optt,
    String? expdate,
    String? buySell,
    int? ordlot,
    double? entryPrice,
    double? ltp,
    bool? checkbox,
    int? lotSize,
    double? iv,
    double? delta,
    double? gamma,
    double? theta,
    double? vega,
  }) {
    return StrategyBasketItem(
      tsym: tsym ?? this.tsym,
      token: token ?? this.token,
      exch: exch ?? this.exch,
      strprc: strprc ?? this.strprc,
      optt: optt ?? this.optt,
      expdate: expdate ?? this.expdate,
      buySell: buySell ?? this.buySell,
      ordlot: ordlot ?? this.ordlot,
      entryPrice: entryPrice ?? this.entryPrice,
      ltp: ltp ?? this.ltp,
      checkbox: checkbox ?? this.checkbox,
      lotSize: lotSize ?? this.lotSize,
      iv: iv ?? this.iv,
      delta: delta ?? this.delta,
      gamma: gamma ?? this.gamma,
      theta: theta ?? this.theta,
      vega: vega ?? this.vega,
    );
  }
}

/// Predefined strategy model
class PredefinedStrategy {
  final String title;
  final String type; // Bullish, Bearish, Neutral
  final String image;
  final List<StrategyLeg> legs;

  PredefinedStrategy({
    required this.title,
    required this.type,
    required this.image,
    required this.legs,
  });
}

/// Strategy leg definition
class StrategyLeg {
  final String action; // BUY or SELL
  final String optionType; // CE or PE
  final String strikeType; // ATM, ITM, OTM
  final int strikeOffset; // 0 for ATM, positive for OTM, negative for ITM

  StrategyLeg({
    required this.action,
    required this.optionType,
    required this.strikeType,
    required this.strikeOffset,
  });
}

/// Payoff metrics
class PayoffMetrics {
  final String maxProfit;
  final String maxLoss;
  final double popPercent;
  final String riskRewardRatio;
  final List<double> breakevens;

  PayoffMetrics({
    this.maxProfit = '--',
    this.maxLoss = '--',
    this.popPercent = 0,
    this.riskRewardRatio = '--',
    this.breakevens = const [],
  });
}

/// Payoff data point
class PayoffDataPoint {
  final double price;
  final double profit;

  PayoffDataPoint(this.price, this.profit);
}

class StrategyBuilderProvider extends DefaultChangeNotifier {
  final Ref ref;
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();

  StrategyBuilderProvider(this.ref);

  // Basket items
  final List<StrategyBasketItem> _basket = [];
  List<StrategyBasketItem> get basket => _basket;

  // Selected stock/index
  String _selectedSymbol = 'NIFTY 50';
  String get selectedSymbol => _selectedSymbol;

  String _selectedToken = '26000';
  String get selectedToken => _selectedToken;

  String _selectedExch = 'NSE';
  String get selectedExch => _selectedExch;

  // Spot price
  double _spotPrice = 0;
  double get spotPrice => _spotPrice;
  double _spotPriceChangePercent = 0;
  double get spotPriceChangePercent => _spotPriceChangePercent;

  // Expiry dates
  List<String> _expiryDates = [];
  List<String> get expiryDates => _expiryDates;

  String _selectedExpiry = '';
  String get selectedExpiry => _selectedExpiry;

  // Option chain data
  List<OptionValues> _optionChain = [];
  List<OptionValues> get optionChain => _optionChain;

  List<OptionExp> _expiryDataRaw = [];

  // Strategy type tab
  String _strategyTypeTab = 'Bullish';
  String get strategyTypeTab => _strategyTypeTab;

  // Active predefined strategy
  String? _activePredefinedStrategy;
  String? get activePredefinedStrategy => _activePredefinedStrategy;

  // Lot multiplier
  int _lotMultiplier = 1;
  int get lotMultiplier => _lotMultiplier;

  // Payoff tab
  int _payoffTab = 0;
  int get payoffTab => _payoffTab;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isOrderLoading = false;
  bool get isOrderLoading => _isOrderLoading;

  // Target controls
  double _targetSpotPrice = 0;
  double get targetSpotPrice => _targetSpotPrice;

  int _targetDaysToExpiry = 0;
  int get targetDaysToExpiry => _targetDaysToExpiry;

  int _daysToExpiry = 0;
  int get daysToExpiry => _daysToExpiry;

  // SD lines toggle
  bool _showSDLines = false;
  bool get showSDLines => _showSDLines;

  // Strike count for option chain
  int _selectedStrikeCount = 15;
  int get selectedStrikeCount => _selectedStrikeCount;

  Future<void> setStrikeCount(int count, BuildContext context) async {
    if (count == _selectedStrikeCount) return;
    _selectedStrikeCount = count;
    notifyListeners();
    await loadOptionChain(context);
  }

  /// Calculate SD price levels based on spot price, average IV, and days to expiry
  /// Returns a map with keys: -2σ, -1σ, +1σ, +2σ
  Map<String, double> get sdPrices {
    // Only return empty if we have no spot price at all
    if (_spotPrice <= 0) {
      return {};
    }

    // Calculate average IV from basket items that have IV
    double avgIV = 0.15; // Default 15% IV if no IV data available
    final itemsWithIV = _basket.where((item) => item.checkbox && item.iv != null && item.iv! > 0).toList();
    if (itemsWithIV.isNotEmpty) {
      avgIV = itemsWithIV.map((item) => item.iv!).reduce((a, b) => a + b) / itemsWithIV.length;
    }

    // Calculate 1 standard deviation price move
    // SD move = spotPrice × IV × √(T/365)
    // Use minimum of 7 days for calculation to show meaningful SD lines
    final daysForCalc = _daysToExpiry > 0 ? _daysToExpiry : 7;
    final timeInYears = daysForCalc / 365.0;
    final sdMove = _spotPrice * avgIV * math.sqrt(timeInYears);

    return {
      '-2σ': _spotPrice - (2 * sdMove),
      '-1σ': _spotPrice - sdMove,
      '+1σ': _spotPrice + sdMove,
      '+2σ': _spotPrice + (2 * sdMove),
    };
  }

  // Payoff data
  List<PayoffDataPoint> _payoffData = [];
  List<PayoffDataPoint> get payoffData => _payoffData;

  List<PayoffDataPoint> _targetPayoffData = [];
  List<PayoffDataPoint> get targetPayoffData => _targetPayoffData;

  PayoffMetrics _metrics = PayoffMetrics();
  PayoffMetrics get metrics => _metrics;

  // Margin
  String _totalMargin = '--';
  String get totalMargin => _totalMargin;

  // My strategies
  final List<PredefinedStrategy> _myStrategies = [];
  List<PredefinedStrategy> get myStrategies => _myStrategies;

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _searchLoading = false;
  bool get searchLoading => _searchLoading;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> get searchResults => _searchResults;

  // Flag to trigger auto-showing option chain dialog
  bool _shouldShowOptionChain = false;
  bool get shouldShowOptionChain => _shouldShowOptionChain;

  // Analyze mode (from positions)
  bool _isAnalyzeMode = false;
  bool get isAnalyzeMode => _isAnalyzeMode;

  void clearShouldShowOptionChain() {
    _shouldShowOptionChain = false;
  }

  // WebSocket subscription
  final List<String> _subscribedTokens = [];
  Timer? _refreshTimer;

  // Predefined strategies
  List<PredefinedStrategy> get predefinedStrategies {
    return [
      // Bullish strategies
      PredefinedStrategy(
        title: 'Long Call',
        type: 'Bullish',
        image: 'predefined_strategies/bullish/Buy_Call.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'ATM', strikeOffset: 0),
        ],
      ),
      PredefinedStrategy(
        title: 'Short Put',
        type: 'Bullish',
        image: 'predefined_strategies/bullish/Sell_Put.svg',
        legs: [
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'ATM', strikeOffset: 0),
        ],
      ),
      PredefinedStrategy(
        title: 'Bull Call Spread',
        type: 'Bullish',
        image: 'predefined_strategies/bullish/Bull_Call_Spread.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'ATM', strikeOffset: 0),
          StrategyLeg(action: 'SELL', optionType: 'CE', strikeType: 'OTM', strikeOffset: 1),
        ],
      ),
      PredefinedStrategy(
        title: 'Bull Put Spread',
        type: 'Bullish',
        image: 'predefined_strategies/bullish/Bull_Put_Spread.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'PE', strikeType: 'OTM', strikeOffset: -1),
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'ATM', strikeOffset: 0),
        ],
      ),
      PredefinedStrategy(
        title: 'Long Combo (Risk Reversal)',
        type: 'Bullish',
        image: 'predefined_strategies/bullish/Range_Forward.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'OTM', strikeOffset: 1),
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'OTM', strikeOffset: -1),
        ],
      ),
      // Bearish strategies
      PredefinedStrategy(
        title: 'Long Put',
        type: 'Bearish',
        image: 'predefined_strategies/bearish/Buy_Put.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'PE', strikeType: 'ATM', strikeOffset: 0),
        ],
      ),
      PredefinedStrategy(
        title: 'Short Call',
        type: 'Bearish',
        image: 'predefined_strategies/bearish/Sell_Call.svg',
        legs: [
          StrategyLeg(action: 'SELL', optionType: 'CE', strikeType: 'ATM', strikeOffset: 0),
        ],
      ),
      PredefinedStrategy(
        title: 'Bear Call Spread',
        type: 'Bearish',
        image: 'predefined_strategies/bearish/Bear_Call_Spread.svg',
        legs: [
          StrategyLeg(action: 'SELL', optionType: 'CE', strikeType: 'ATM', strikeOffset: 0),
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'OTM', strikeOffset: 1),
        ],
      ),
      PredefinedStrategy(
        title: 'Bear Put Spread',
        type: 'Bearish',
        image: 'predefined_strategies/bearish/Bear_Put_Spread.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'PE', strikeType: 'ATM', strikeOffset: 0),
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'OTM', strikeOffset: -1),
        ],
      ),
      // Neutral strategies
      PredefinedStrategy(
        title: 'Short Straddle',
        type: 'Neutral',
        image: 'predefined_strategies/neutral/Short_Straddle.svg',
        legs: [
          StrategyLeg(action: 'SELL', optionType: 'CE', strikeType: 'ATM', strikeOffset: 0),
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'ATM', strikeOffset: 0),
        ],
      ),
      PredefinedStrategy(
        title: 'Long Straddle',
        type: 'Neutral',
        image: 'predefined_strategies/others/Long_Straddle.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'ATM', strikeOffset: 0),
          StrategyLeg(action: 'BUY', optionType: 'PE', strikeType: 'ATM', strikeOffset: 0),
        ],
      ),
      PredefinedStrategy(
        title: 'Short Strangle',
        type: 'Neutral',
        image: 'predefined_strategies/neutral/Short_Strangle.svg',
        legs: [
          StrategyLeg(action: 'SELL', optionType: 'CE', strikeType: 'OTM', strikeOffset: 1),
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'OTM', strikeOffset: -1),
        ],
      ),
      PredefinedStrategy(
        title: 'Long Strangle',
        type: 'Neutral',
        image: 'predefined_strategies/others/Long_Strangle.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'OTM', strikeOffset: 1),
          StrategyLeg(action: 'BUY', optionType: 'PE', strikeType: 'OTM', strikeOffset: -1),
        ],
      ),
      PredefinedStrategy(
        title: 'Iron Condor',
        type: 'Neutral',
        image: 'predefined_strategies/neutral/Short_Iron_Condor.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'PE', strikeType: 'OTM', strikeOffset: -2),
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'OTM', strikeOffset: -1),
          StrategyLeg(action: 'SELL', optionType: 'CE', strikeType: 'OTM', strikeOffset: 1),
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'OTM', strikeOffset: 2),
        ],
      ),
      PredefinedStrategy(
        title: 'Iron Butterfly',
        type: 'Neutral',
        image: 'predefined_strategies/neutral/Iron_Butterfly.svg',
        legs: [
          StrategyLeg(action: 'BUY', optionType: 'PE', strikeType: 'OTM', strikeOffset: -1),
          StrategyLeg(action: 'SELL', optionType: 'PE', strikeType: 'ATM', strikeOffset: 0),
          StrategyLeg(action: 'SELL', optionType: 'CE', strikeType: 'ATM', strikeOffset: 0),
          StrategyLeg(action: 'BUY', optionType: 'CE', strikeType: 'OTM', strikeOffset: 1),
        ],
      ),
    ];
  }

  /// Get filtered strategies by tab
  List<PredefinedStrategy> get filteredStrategies {
    if (_strategyTypeTab == 'MyStrategy') {
      return _myStrategies;
    }
    return predefinedStrategies.where((s) => s.type == _strategyTypeTab).toList();
  }

  /// Initialize the strategy builder
  Future<void> initialize(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch initial quote for NIFTY 50
      final quote = await api.getScripQuote(_selectedToken, _selectedExch);
      if (quote.stat == 'Ok') {
        _spotPrice = double.tryParse(quote.lp ?? '0') ?? 0;
        _targetSpotPrice = _spotPrice;
        final chng = double.tryParse(quote.chng ?? '0') ?? 0;
        final prevClose = _spotPrice - chng;
        _spotPriceChangePercent = prevClose > 0 ? (chng / prevClose) * 100 : 0;
      }

      // Fetch linked scrips for expiry list
      await _loadExpiryDates(context);

      // Subscribe to index updates
      _subscribeToIndex();

      // Start refresh timer
      _startRefreshTimer();
    } catch (e) {
      log('[StrategyBuilder] Initialize error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load expiry dates
  Future<void> _loadExpiryDates(BuildContext context) async {
    try {
      final linkedData = await api.getLinkedScrip(_selectedToken, _selectedExch);
      if (linkedData.stat == "Ok" && linkedData.optExp != null && linkedData.optExp!.isNotEmpty) {
        final sortedExpiries = [...linkedData.optExp!];
        sortedExpiries.sort((a, b) {
          final dateA = _parseExpiryDate(a.exd ?? '');
          final dateB = _parseExpiryDate(b.exd ?? '');
          return dateA.compareTo(dateB);
        });

        _expiryDataRaw = sortedExpiries;
        _expiryDates = sortedExpiries.map((e) => e.exd ?? '').toSet().toList();

        if (_expiryDates.isNotEmpty && _selectedExpiry.isEmpty) {
          _selectedExpiry = _expiryDates[0];
          await loadOptionChain(context);
        }
      }
    } catch (e) {
      log('[StrategyBuilder] Load expiry dates error: $e');
    }
  }

  DateTime _parseExpiryDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final monthMap = {
          'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4,
          'MAY': 5, 'JUN': 6, 'JUL': 7, 'AUG': 8,
          'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
        };
        final month = monthMap[parts[1].toUpperCase()] ?? 1;
        int year = int.parse(parts[2]);
        // Handle 2-digit year (e.g., '26' -> 2026)
        if (year < 100) {
          year = 2000 + year;
        }
        log('[StrategyBuilder] _parseExpiryDate: dateStr=$dateStr, parsed day=$day, month=$month, year=$year');
        return DateTime(year, month, day);
      }
    } catch (e) {
      log('[StrategyBuilder] _parseExpiryDate error: $e');
    }
    return DateTime.now();
  }

  /// Load option chain
  Future<void> loadOptionChain(BuildContext context) async {
    if (_selectedExpiry.isEmpty) return;

    try {
      final selectedExpiryData = _expiryDataRaw.firstWhere(
        (e) => e.exd == _selectedExpiry,
        orElse: () => OptionExp(),
      );

      if (selectedExpiryData.tsym == null) return;

      final chainData = await api.getOptionChain(
        strPrc: _spotPrice.toStringAsFixed(2),
        tradeSym: selectedExpiryData.tsym!,
        exchange: selectedExpiryData.exch ?? 'NFO',
        context: context,
        numofStrike: _selectedStrikeCount.toString(),
      );

      if (chainData != null && chainData.stat == 'Ok' && chainData.optValue != null) {
        _optionChain = chainData.optValue!;

        // Calculate days to expiry
        final expiryDate = _parseExpiryDate(_selectedExpiry);
        _daysToExpiry = expiryDate.difference(DateTime.now()).inDays;
        log('[StrategyBuilder] daysToExpiry calculated: $_daysToExpiry, expiryDate=$expiryDate, now=${DateTime.now()}, selectedExpiry=$_selectedExpiry');
        _targetDaysToExpiry = 0;

        // Subscribe to option chain updates
        _subscribeToOptions();
      }
    } catch (e) {
      log('[StrategyBuilder] Load option chain error: $e');
    }
    notifyListeners();
  }

  /// Set selected expiry and reload option chain
  Future<void> setSelectedExpiry(String expiry, BuildContext context) async {
    if (expiry == _selectedExpiry) return;
    _selectedExpiry = expiry;
    notifyListeners();
    await loadOptionChain(context);
  }

  /// Search for stocks/indices - uses same API as watchlist search
  /// API: https://be.mynt.in/global/SearchScrip
  Future<void> searchStocks(String query) async {
    _searchQuery = query;
    if (query.length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchLoading = true;
    notifyListeners();

    try {
      // Use searchScripForStrategyBuilder with fixed exchange filter
      final results = await api.searchScripForStrategyBuilder(
        searchText: query,
        exchanges: ["NSE", "NFO", "BSE"],
      );

      if (results.stat == 'Ok' && results.values != null && results.values!.isNotEmpty) {
        // Filter for indices/underlyings that have F&O (UNDIND, INDEX, or stocks with F&O)
        _searchResults = results.values!
            .where((r) =>
                r.instname == 'UNDIND' ||
                r.instname == 'INDEX' ||
                r.exch == 'NSE' // Include NSE stocks that may have F&O
            )
            .map((r) => {
                  'displayName': r.dname ?? r.tsym ?? '',
                  'tsym': r.tsym ?? '',
                  'token': r.token ?? '',
                  'exch': r.exch ?? '',
                  'instname': r.instname ?? '',
                })
            .toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      log('[StrategyBuilder] Search error: $e');
      _searchResults = [];
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  /// Select stock from search
  Future<void> selectStock(Map<String, dynamic> stock, BuildContext context) async {
    _selectedSymbol = stock['displayName'] ?? stock['tsym'];
    _selectedToken = stock['token'];
    _selectedExch = stock['exch'];
    _searchResults = [];
    _searchQuery = '';
    _selectedExpiry = '';
    _expiryDates = [];
    _optionChain = [];
    _targetSpotPrice = 0; // Reset target to fallback to spot price
    _lotMultiplier = 1;
    _basket.clear();
    _payoffData = [];
    _targetPayoffData = [];
    _daysToExpiry = 0;

    // Set loading state BEFORE showing dialog so it displays loader immediately
    _isLoading = true;
    // Set flag to show option chain dialog
    _shouldShowOptionChain = true;
    notifyListeners();

    // Load new data (dialog shows loader, will update when data is ready)
    await _loadDataAfterStockSelection(context);
  }

  /// Load data after stock selection (separate from initialize to avoid double-setting isLoading)
  Future<void> _loadDataAfterStockSelection(BuildContext context) async {
    try {
      // Fetch initial quote for selected stock
      final quote = await api.getScripQuote(_selectedToken, _selectedExch);
      if (quote.stat == 'Ok') {
        _spotPrice = double.tryParse(quote.lp ?? '0') ?? 0;
        _targetSpotPrice = _spotPrice;
        final chng = double.tryParse(quote.chng ?? '0') ?? 0;
        final prevClose = _spotPrice - chng;
        _spotPriceChangePercent = prevClose > 0 ? (chng / prevClose) * 100 : 0;
      }

      // Fetch linked scrips for expiry list
      await _loadExpiryDates(context);

      // Subscribe to index updates
      _subscribeToIndex();

      // Start refresh timer
      _startRefreshTimer();
    } catch (e) {
      log('[StrategyBuilder] Load data after stock selection error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set strategy type tab
  void setStrategyTypeTab(String tab) {
    _strategyTypeTab = tab;
    notifyListeners();
  }

  /// Set active predefined strategy
  Future<void> setActivePredefinedStrategy(PredefinedStrategy strategy, BuildContext context) async {
    _activePredefinedStrategy = strategy.title;
    _lotMultiplier = 1;

    // Clear basket and add strategy legs
    _basket.clear();

    if (_optionChain.isEmpty) {
      await loadOptionChain(context);
    }

    // Find ATM strike
    double minDiff = double.infinity;
    int atmIndex = 0;
    final ceOptions = _optionChain.where((o) => o.optt == 'CE').toList();

    for (int i = 0; i < ceOptions.length; i++) {
      final strike = double.tryParse(ceOptions[i].strprc ?? '0') ?? 0;
      final diff = (strike - _spotPrice).abs();
      if (diff < minDiff) {
        minDiff = diff;
        atmIndex = i;
      }
    }

    // Add legs
    for (var leg in strategy.legs) {
      final options = _optionChain.where((o) => o.optt == leg.optionType).toList();
      options.sort((a, b) =>
        (double.tryParse(a.strprc ?? '0') ?? 0).compareTo(double.tryParse(b.strprc ?? '0') ?? 0)
      );

      int targetIndex = atmIndex + leg.strikeOffset;
      if (leg.optionType == 'PE') {
        // For PE, OTM means lower strike (negative offset from ATM)
        targetIndex = atmIndex - leg.strikeOffset;
      }

      targetIndex = targetIndex.clamp(0, options.length - 1);

      if (options.isNotEmpty && targetIndex < options.length) {
        final option = options[targetIndex];
        addToBasket(option, leg.action, context);
      }
    }

    _calculatePayoff();
    notifyListeners();
  }

  /// Add option to basket
  Future<void> addToBasket(OptionValues option, String buySell, BuildContext context) async {
    // Robust parsing for LTP and Lot Size
    final cleanLp = (option.lp ?? '0').replaceAll(',', '').replaceAll(' ', '');
    final ltp = double.tryParse(cleanLp) ?? 0.0;
    
    final cleanLs = (option.ls ?? '1').replaceAll(',', '').replaceAll(' ', '');
    final lotSize = int.tryParse(cleanLs) ?? 1;

    // Check if the same option (token) already exists in basket
    final existingIndex = _basket.indexWhere(
      (b) => b.token == (option.token ?? ''),
    );

    StrategyBasketItem basketItem;

    if (existingIndex != -1) {
      final existing = _basket[existingIndex];
      if (existing.buySell == buySell) {
        // Same direction already exists — block duplicate
        ResponsiveSnackBar.show(context: context, message: '${option.tsym ?? ''} is already added');
        return;
      } else {
        // Opposite direction — replace buy/sell
        _basket[existingIndex].buySell = buySell;
        _updateItemGreeks(_basket[existingIndex]);
        basketItem = _basket[existingIndex];
      }
    } else {
      basketItem = StrategyBasketItem(
        tsym: option.tsym ?? '',
        token: option.token ?? '',
        exch: option.exch ?? 'NFO',
        strprc: option.strprc ?? '0',
        optt: option.optt ?? 'CE',
        expdate: _selectedExpiry,
        buySell: buySell,
        ordlot: 1,
        entryPrice: ltp,
        ltp: ltp,
        lotSize: lotSize,
        checkbox: true,
      );

      // Bake current multiplier into existing items' ordlot before resetting
      if (_lotMultiplier > 1) {
        for (var item in _basket) {
          item.ordlot = item.ordlot * _lotMultiplier;
        }
        _lotMultiplier = 1;
      }
      _basket.add(basketItem);
    }

    // Calculate payoff immediately for instant chart feedback
    _calculatePayoff();
    notifyListeners();

    // Call APIs for payoff, Greeks, and margin (will update with API data)
    await Future.wait([
      _fetchPayoffFromAPI(),
      _fetchGreeksFromAPI(basketItem),
      _calculateMargin(context),
    ]);

    notifyListeners();
  }

  /// Remove from basket
  Future<void> removeFromBasket(int index, BuildContext context) async {
    if (index >= 0 && index < _basket.length) {
      _basket.removeAt(index);
      _calculatePayoff();
      notifyListeners();

      // Recalculate margin after removing item
      await _calculateMargin(context);
      notifyListeners();
    }
  }

  /// Toggle buy/sell
  Future<void> toggleBuySell(int index, BuildContext context) async {
    if (index >= 0 && index < _basket.length) {
      _basket[index].buySell = _basket[index].buySell == 'BUY' ? 'SELL' : 'BUY';
      _updateItemGreeks(_basket[index]); // Recalculate Greeks
      _calculatePayoff();
      notifyListeners();

      // Recalculate margin
      await _calculateMargin(context);
      notifyListeners();
    }
  }

  /// Toggle CE/PE
  Future<void> toggleCePe(int index, BuildContext context) async {
    if (index >= 0 && index < _basket.length) {
      final item = _basket[index];
      final newOptt = item.optt == 'CE' ? 'PE' : 'CE';

      // Find corresponding option in chain
      final option = _optionChain.firstWhere(
        (o) => o.strprc == item.strprc && o.optt == newOptt,
        orElse: () => OptionValues(),
      );

      if (option.token != null) {
        _basket[index] = item.copyWith(
          optt: newOptt,
          tsym: option.tsym,
          token: option.token,
          ltp: double.tryParse(option.lp ?? '0') ?? 0,
          entryPrice: double.tryParse(option.lp ?? '0') ?? 0,
        );
        _updateItemGreeks(_basket[index]); // Recalculate Greeks
        _calculatePayoff();
        notifyListeners();

        // Recalculate margin
        await _calculateMargin(context);
        notifyListeners();
      }
    }
  }

  /// Update lots
  Future<void> updateLots(int index, int lots, BuildContext context) async {
    if (index >= 0 && index < _basket.length && lots > 0) {
      _basket[index].ordlot = lots;
      _updateItemGreeks(_basket[index]); // Recalculate Greeks
      _calculatePayoff();
      notifyListeners();

      // Recalculate margin
      await _calculateMargin(context);
      notifyListeners();
    }
  }

  /// Update entry price
  Future<void> updateEntryPrice(int index, double price, BuildContext context) async {
    if (index >= 0 && index < _basket.length) {
      _basket[index].entryPrice = price;
      _calculatePayoff();
      notifyListeners();

      // Recalculate margin
      await _calculateMargin(context);
      notifyListeners();
    }
  }

  /// Update expiry for basket item
  void updateExpiry(int index, String expiry, BuildContext context) async {
    if (index >= 0 && index < _basket.length) {
      final item = _basket[index];

      // Find option with new expiry
      // This would require loading option chain for the new expiry
      _basket[index] = item.copyWith(expdate: expiry);
      notifyListeners();
    }
  }

  /// Update strike for basket item
  Future<void> updateStrike(int index, String strike, BuildContext context) async {
    if (index >= 0 && index < _basket.length) {
      final item = _basket[index];

      // Find option with new strike
      final option = _optionChain.firstWhere(
        (o) => o.strprc == strike && o.optt == item.optt,
        orElse: () => OptionValues(),
      );

      if (option.token != null) {
        _basket[index] = item.copyWith(
          strprc: strike,
          tsym: option.tsym,
          token: option.token,
          ltp: double.tryParse(option.lp ?? '0') ?? 0,
          entryPrice: double.tryParse(option.lp ?? '0') ?? 0,
        );
        _updateItemGreeks(_basket[index]); // Recalculate Greeks
        _calculatePayoff();
        notifyListeners();

        // Recalculate margin
        await _calculateMargin(context);
        notifyListeners();
      }
    }
  }

  /// Toggle checkbox
  Future<void> toggleCheckbox(int index, BuildContext context) async {
    if (index >= 0 && index < _basket.length) {
      _basket[index].checkbox = !_basket[index].checkbox;
      _calculatePayoff();
      notifyListeners();

      // Recalculate margin
      await _calculateMargin(context);
      notifyListeners();
    }
  }

  /// Toggle all checkboxes
  Future<void> toggleAllCheckboxes(bool value, BuildContext context) async {
    for (var item in _basket) {
      item.checkbox = value;
    }
    _calculatePayoff();
    notifyListeners();

    // Recalculate margin
    await _calculateMargin(context);
    notifyListeners();
  }

  /// Check if all selected
  bool get isAllSelected => _basket.isNotEmpty && _basket.every((item) => item.checkbox);

  /// Clear basket
  void clearBasket() {
    _basket.clear();
    _lotMultiplier = 1;
    _activePredefinedStrategy = null;
    _payoffData = [];
    _targetPayoffData = [];
    _metrics = PayoffMetrics();
    _totalMargin = '--'; // Reset margin
    notifyListeners();
  }

  /// Save current basket as a custom strategy
  void saveStrategy(String name, BuildContext context) {
    if (_basket.isEmpty) {
      ResponsiveSnackBar.showError(context, 'Basket is empty. Add options before saving.');
      return;
    }

    if (name.trim().isEmpty) {
      ResponsiveSnackBar.showError(context, 'Please enter a strategy name.');
      return;
    }

    // Check if strategy name already exists
    final existingIndex = _myStrategies.indexWhere((s) => s.title.toLowerCase() == name.toLowerCase());

    // Convert basket items to strategy legs
    final legs = _basket.map((item) {
      // Determine strike type based on position relative to spot
      final strike = double.tryParse(item.strprc) ?? 0;
      final diff = strike - _spotPrice;
      String strikeType;
      int strikeOffset;

      if (diff.abs() < 50) {
        strikeType = 'ATM';
        strikeOffset = 0;
      } else if ((item.optt == 'CE' && diff > 0) || (item.optt == 'PE' && diff < 0)) {
        strikeType = 'OTM';
        strikeOffset = (diff.abs() / 50).round();
      } else {
        strikeType = 'ITM';
        strikeOffset = -(diff.abs() / 50).round();
      }

      return StrategyLeg(
        action: item.buySell,
        optionType: item.optt,
        strikeType: strikeType,
        strikeOffset: strikeOffset,
      );
    }).toList();

    final strategy = PredefinedStrategy(
      title: name.trim(),
      type: 'MyStrategy',
      image: 'custom_strategy.png',
      legs: legs,
    );

    if (existingIndex >= 0) {
      // Update existing strategy
      _myStrategies[existingIndex] = strategy;
      ResponsiveSnackBar.showSuccess(context, 'Strategy "$name" updated successfully');
    } else {
      // Add new strategy
      _myStrategies.add(strategy);
      ResponsiveSnackBar.showSuccess(context, 'Strategy "$name" saved successfully');
    }

    notifyListeners();
  }

  /// Delete a saved strategy
  void deleteStrategy(String name) {
    _myStrategies.removeWhere((s) => s.title == name);
    notifyListeners();
  }

  /// Set lot multiplier
  Future<void> setLotMultiplier(int multiplier, BuildContext context) async {
    if (multiplier > 0) {
      _lotMultiplier = multiplier;
      _calculatePayoff();
      notifyListeners();

      // Recalculate margin
      await _calculateMargin(context);
      notifyListeners();
    }
  }

  /// Set payoff tab
  void setPayoffTab(int tab) {
    _payoffTab = tab;
    notifyListeners();
  }

  /// Set target spot price
  void setTargetSpotPrice(double price) {
    _targetSpotPrice = price;
    _calculatePayoff();
    notifyListeners();
  }

  /// Set target days to expiry
  void setTargetDaysToExpiry(int days) {
    _targetDaysToExpiry = days;
    _calculatePayoff();
    notifyListeners();
  }

  /// Toggle SD lines
  void toggleSDLines() {
    _showSDLines = !_showSDLines;
    notifyListeners();
  }

  // ============ Black-Scholes Greeks Calculation ============

  /// Standard normal cumulative distribution function
  double _normCdf(double x) {
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    const p = 0.3275911;

    final sign = x < 0 ? -1 : 1;
    x = x.abs() / math.sqrt(2);

    final t = 1.0 / (1.0 + p * x);
    final y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-x * x);

    return 0.5 * (1.0 + sign * y);
  }

  /// Standard normal probability density function
  double _normPdf(double x) {
    return math.exp(-0.5 * x * x) / math.sqrt(2 * math.pi);
  }

  /// Calculate d1 for Black-Scholes
  double _calcD1(double S, double K, double T, double r, double sigma) {
    if (T <= 0 || sigma <= 0) return 0;
    return (math.log(S / K) + (r + 0.5 * sigma * sigma) * T) / (sigma * math.sqrt(T));
  }

  /// Calculate d2 for Black-Scholes
  double _calcD2(double d1, double T, double sigma) {
    if (T <= 0 || sigma <= 0) return 0;
    return d1 - sigma * math.sqrt(T);
  }

  /// Black-Scholes call price
  double _bsCallPrice(double S, double K, double T, double r, double sigma) {
    if (T <= 0) return math.max(0, S - K);
    final d1 = _calcD1(S, K, T, r, sigma);
    final d2 = _calcD2(d1, T, sigma);
    return S * _normCdf(d1) - K * math.exp(-r * T) * _normCdf(d2);
  }

  /// Black-Scholes put price
  double _bsPutPrice(double S, double K, double T, double r, double sigma) {
    if (T <= 0) return math.max(0, K - S);
    final d1 = _calcD1(S, K, T, r, sigma);
    final d2 = _calcD2(d1, T, sigma);
    return K * math.exp(-r * T) * _normCdf(-d2) - S * _normCdf(-d1);
  }

  /// Calculate Implied Volatility using Newton-Raphson method
  double _calcIV(double optionPrice, double S, double K, double T, double r, bool isCall) {
    if (T <= 0 || optionPrice <= 0 || S <= 0 || K <= 0) return 0.15; // Default 15% IV

    // Better initial guess based on approximate formula
    // IV ≈ sqrt(2 * π / T) * (optionPrice / S)
    double sigma = math.sqrt(2 * math.pi / T) * (optionPrice / S);
    sigma = sigma.clamp(0.05, 2.0); // Clamp initial guess between 5% and 200%

    const maxIterations = 100;
    const tolerance = 0.0001;

    for (int i = 0; i < maxIterations; i++) {
      final price = isCall ? _bsCallPrice(S, K, T, r, sigma) : _bsPutPrice(S, K, T, r, sigma);
      final d1 = _calcD1(S, K, T, r, sigma);
      final vega = S * math.sqrt(T) * _normPdf(d1);

      if (vega.abs() < 1e-10) break;

      final diff = price - optionPrice;
      if (diff.abs() < tolerance) break;

      sigma = sigma - diff / vega;

      // Keep sigma within reasonable bounds (5% to 300% IV)
      if (sigma <= 0.05) sigma = 0.05;
      if (sigma > 3.0) sigma = 3.0;
    }

    // Ensure minimum IV of 5% for reasonable Greeks
    return math.max(sigma, 0.05);
  }

  /// Calculate Greeks for an option
  Map<String, double> _calculateGreeks(double S, double K, double T, double r, double sigma, bool isCall) {
    if (T <= 0 || sigma <= 0) {
      return {'delta': 0, 'gamma': 0, 'theta': 0, 'vega': 0};
    }

    final d1 = _calcD1(S, K, T, r, sigma);
    final d2 = _calcD2(d1, T, sigma);
    final sqrtT = math.sqrt(T);

    // Delta
    double delta;
    if (isCall) {
      delta = _normCdf(d1);
    } else {
      delta = _normCdf(d1) - 1;
    }

    // Gamma (same for call and put)
    final gamma = _normPdf(d1) / (S * sigma * sqrtT);

    // Theta (per day, so divide by 365)
    double theta;
    final term1 = -(S * _normPdf(d1) * sigma) / (2 * sqrtT);
    if (isCall) {
      theta = (term1 - r * K * math.exp(-r * T) * _normCdf(d2)) / 365;
    } else {
      theta = (term1 + r * K * math.exp(-r * T) * _normCdf(-d2)) / 365;
    }

    // Vega (per 1% move in volatility)
    final vega = S * sqrtT * _normPdf(d1) / 100;

    return {
      'delta': delta,
      'gamma': gamma,
      'theta': theta,
      'vega': vega,
    };
  }

  /// Calculate and update Greeks for a basket item
  void _updateItemGreeks(StrategyBasketItem item) {
    if (_spotPrice <= 0 || _daysToExpiry < 0) return;

    final S = _spotPrice;
    final K = double.tryParse(item.strprc) ?? 0;
    if (K <= 0) return;

    // Time to expiry in years (use at least 1 day to avoid division by zero)
    final T = math.max(_daysToExpiry, 1) / 365.0;
    const r = 0.07; // Risk-free rate (7% for India)
    final isCall = item.optt == 'CE';

    // Calculate IV from current option price
    final iv = _calcIV(item.ltp, S, K, T, r, isCall);

    // Calculate Greeks using Black-Scholes
    final greeks = _calculateGreeks(S, K, T, r, iv, isCall);

    // Direction multiplier (BUY = +1, SELL = -1)
    final multiplier = item.buySell == 'SELL' ? -1.0 : 1.0;

    // Store per-option Greeks for display
    // Delta: per-option delta with direction (0 to 1 for calls, -1 to 0 for puts)
    // Gamma: change in delta per 1-point move (per option)
    // Theta: daily decay per option in currency
    // Vega: change per 1% IV move per option
    item.iv = iv * 100; // Convert to percentage
    item.delta = greeks['delta']! * multiplier; // Per-option delta with direction
    item.gamma = greeks['gamma']!; // Per-option gamma
    item.theta = greeks['theta']! * multiplier; // Per-option daily theta (NOT multiplied by lotSize)
    item.vega = greeks['vega']! * multiplier; // Per-option vega (NOT multiplied by lotSize)
  }

  // ============ End Black-Scholes Greeks Calculation ============

  /// Calculate net premium (per contract, not total cost)
  /// For display purposes: shows premium paid/received per contract
  double get netPremium {
    double total = 0;
    for (var item in _basket) {
      if (!item.checkbox) continue;
      final sign = item.buySell == 'SELL' ? 1 : -1;
      // Don't multiply by lotSize - show per-contract premium
      total += item.entryPrice * item.ordlot * _lotMultiplier * sign;
    }
    return total;
  }

  /// Calculate total premium cost (includes lotSize for actual P&L calculations)
  double get totalPremiumCost {
    double total = 0;
    for (var item in _basket) {
      if (!item.checkbox) continue;
      final sign = item.buySell == 'SELL' ? 1 : -1;
      total += item.entryPrice * item.ordlot * item.lotSize * _lotMultiplier * sign;
    }
    return total;
  }

  // ============ API-based Payoff and Greeks Calculation ============

  /// Fetch payoff data from API
  Future<void> _fetchPayoffFromAPI() async {
    if (_basket.isEmpty || _spotPrice == 0) {
      _payoffData = [];
      _targetPayoffData = [];
      _metrics = PayoffMetrics();
      return;
    }

    final selectedItems = _basket.where((item) => item.checkbox).toList();
    if (selectedItems.isEmpty) {
      _payoffData = [];
      _targetPayoffData = [];
      _metrics = PayoffMetrics();
      return;
    }

    try {
      // Build legs array for API
      final legs = selectedItems.map((item) => {
        "exch": item.exch,
        "token": item.token,
        "tsym": item.tsym,
        "optt": item.optt,
        "pp": "2",
        "ls": item.lotSize.toString(),
        "ti": "0.05",
        "strprc": item.strprc,
        "instname": "OPTIDX",
        "cname": "${_selectedSymbol} ${item.expdate} ${item.strprc} ${item.optt} ",
        "dname": "${_selectedSymbol} ${item.expdate} ${item.strprc} ${item.optt} ",
        "bar": item.optt == 'CE' ? "#FF1717" : "#17FF17",
        "p": "",
        "ltp": item.ltp,
        "ask": item.ltp,
        "bid": item.ltp.toString(),
        "ch": "0",
        "chp": "0",
        "coi": 0,
        "oi": "0",
        "oich": "0",
        "vol": "0",
        "buySell": item.buySell,
        "expdate": _expiryDates,
        "ordvai": "MKT",
        "ordlot": (item.ordlot * _lotMultiplier).toString(),
        "ordprc": item.entryPrice.toString(),
        "checkbox": item.checkbox,
        "ser": item.expdate,
        "tsyms": _selectedSymbol,
        "inx": DateTime.now().millisecondsSinceEpoch.toDouble(),
        "exp": "${item.strprc} ${item.optt}",
      }).toList();

      final response = await api.getPayoffCalculation(
        strategy: "custom",
        isPosition: _isAnalyzeMode,
        spotPrice: _spotPrice.toStringAsFixed(2),
        daysToExpiry: _daysToExpiry,
        legs: legs,
      );

      log('[StrategyBuilder] Payoff API Response: $response');

      // Parse response and update payoff data
      if (response['status'] == 'success' || response['payoffData'] != null) {
        final payoffData = response['payoffData'] ?? response;

        // Extract stock prices and payoffs from API response
        final stockPrices = (payoffData['stockPrices'] as List?)?.cast<num>() ?? [];
        final payoffsExpiry = (payoffData['payoffsExpiry'] as List?)?.cast<num>() ?? [];
        final payoffsTarget = (payoffData['payoffsTarget'] as List?)?.cast<num>() ?? [];
        final breakevens = (payoffData['breakevens'] as List?)?.cast<num>() ?? [];

        // Convert to PayoffDataPoint list
        _payoffData = [];
        _targetPayoffData = [];

        for (int i = 0; i < stockPrices.length && i < payoffsExpiry.length; i++) {
          _payoffData.add(PayoffDataPoint(
            stockPrices[i].toDouble(),
            payoffsExpiry[i].toDouble(),
          ));
        }

        for (int i = 0; i < stockPrices.length && i < payoffsTarget.length; i++) {
          _targetPayoffData.add(PayoffDataPoint(
            stockPrices[i].toDouble(),
            payoffsTarget[i].toDouble(),
          ));
        }

        if (_payoffData.isEmpty) {
          log('[StrategyBuilder] API returned empty payoff data, using local calculation');
          _calculatePayoff();
          return;
        }

        // Extract metrics
        final maxProfit = payoffData['maxProfit'];
        final maxLoss = payoffData['maxLoss'];
        final pop = payoffData['pop'] ?? 0;

        _metrics = PayoffMetrics(
          maxProfit: maxProfit?.toString() ?? '--',
          maxLoss: maxLoss?.toString() ?? '--',
          popPercent: (pop is num) ? pop.toDouble() : 0,
          riskRewardRatio: '--',
          breakevens: breakevens.map((e) => e.toDouble()).toList(),
        );

        log('[StrategyBuilder] Parsed ${_payoffData.length} payoff points');
      } else {
        // Fallback to local calculation if API fails
        log('[StrategyBuilder] API response invalid, using local calculation');
        _calculatePayoff();
      }
    } catch (e) {
      log('[StrategyBuilder] Payoff API Error: $e');
      // Fallback to local calculation
      _calculatePayoff();
    }
  }

  /// Fetch Greeks from API for a basket item
  Future<void> _fetchGreeksFromAPI(StrategyBasketItem item) async {
    if (_spotPrice <= 0 || _daysToExpiry < 0) return;

    try {
      final options = {
        "exch": item.exch,
        "token": item.token,
        "tsym": item.tsym,
        "optt": item.optt,
        "pp": "2",
        "ls": item.lotSize.toString(),
        "ti": "0.05",
        "strprc": item.strprc,
        "instname": "OPTIDX",
        "cname": "${_selectedSymbol} ${item.expdate} ${item.strprc} ${item.optt} ",
        "dname": "${_selectedSymbol} ${item.expdate} ${item.strprc} ${item.optt} ",
        "bar": item.optt == 'CE' ? "#FF1717" : "#17FF17",
        "p": "",
        "ltp": item.ltp,
        "ask": item.ltp,
        "bid": item.ltp.toString(),
        "ch": "0",
        "chp": "0",
        "coi": 0,
        "oi": "0",
        "oich": "0",
        "vol": "0",
        "buySell": item.buySell,
        "expdate": _expiryDates,
        "ordvai": "MKT",
        "ordlot": (item.ordlot * _lotMultiplier).toString(),
        "ordprc": item.entryPrice.toString(),
        "checkbox": item.checkbox,
        "ser": item.expdate,
        "tsyms": _selectedSymbol,
        "inx": DateTime.now().millisecondsSinceEpoch.toDouble(),
        "exp": "${item.strprc} ${item.optt}",
      };

      final response = await api.getOptionGreeks(
        spotPrice: _spotPrice.toStringAsFixed(2),
        expiryDay: _daysToExpiry,
        options: options,
      );

      log('[StrategyBuilder] Greeks API Response: $response');

      // Parse response and update item Greeks
      if (response['status'] == 'success' || response['delta'] != null || response['greeks'] != null) {
        final greeks = response['greeks'] ?? response;

        // Direction multiplier (BUY = +1, SELL = -1)
        final multiplier = item.buySell == 'SELL' ? -1.0 : 1.0;

        item.iv = (greeks['iv'] as num?)?.toDouble() ?? 0;
        item.delta = ((greeks['delta'] as num?)?.toDouble() ?? 0) * multiplier;
        item.gamma = (greeks['gamma'] as num?)?.toDouble() ?? 0;
        item.theta = ((greeks['theta'] as num?)?.toDouble() ?? 0) * multiplier; // Per-option theta
        item.vega = ((greeks['vega'] as num?)?.toDouble() ?? 0) * multiplier; // Per-option vega

        log('[StrategyBuilder] Updated Greeks for ${item.tsym}');
      } else {
        // Fallback to local calculation if API fails
        log('[StrategyBuilder] Greeks API response invalid, using local calculation');
        _updateItemGreeks(item);
      }
    } catch (e) {
      log('[StrategyBuilder] Greeks API Error: $e');
      // Fallback to local calculation
      _updateItemGreeks(item);
    }
  }

  // ============ End API-based Calculation ============

  /// Calculate payoff (local fallback)
  void _calculatePayoff() {
    if (_basket.isEmpty || _spotPrice == 0) {
      _payoffData = [];
      _targetPayoffData = [];
      _metrics = PayoffMetrics();
      return;
    }

    final selectedItems = _basket.where((item) => item.checkbox).toList();
    if (selectedItems.isEmpty) {
      _payoffData = [];
      _targetPayoffData = [];
      _metrics = PayoffMetrics();
      return;
    }

    // Calculate net position to determine unlimited profit/loss potential
    // Net long calls = unlimited profit on upside
    // Net short calls = unlimited loss on upside
    int netCallQty = 0;
    double totalPremiumPaid = 0; // For long positions

    for (var item in selectedItems) {
      final qty = item.ordlot * item.lotSize * _lotMultiplier;
      final premium = item.entryPrice * qty;

      if (item.optt == 'CE') {
        netCallQty += item.buySell == 'BUY' ? qty : -qty;
      }

      if (item.buySell == 'BUY') {
        totalPremiumPaid += premium;
      }
    }

    // Determine unlimited profit/loss scenarios
    bool hasUnlimitedProfit = netCallQty > 0; // Net long calls
    bool hasUnlimitedLoss = netCallQty < 0; // Net short calls

    // Calculate analytical breakevens for single-leg strategies
    final List<double> breakevens = [];

    if (selectedItems.length == 1) {
      final item = selectedItems.first;
      final strike = double.tryParse(item.strprc) ?? 0;
      final premium = item.entryPrice;

      if (item.optt == 'CE') {
        // Call option: breakeven = strike + premium (for both buy and sell)
        breakevens.add(strike + premium);
      } else {
        // Put option: breakeven = strike - premium (for both buy and sell)
        breakevens.add(strike - premium);
      }
    }

    // Calculate price range (±20% from spot) for graph
    final minPrice = _spotPrice * 0.8;
    final maxPrice = _spotPrice * 1.2;
    final step = (_spotPrice * 0.02); // 2% steps

    final List<PayoffDataPoint> expiryPayoff = [];
    final List<PayoffDataPoint> targetPayoff = [];

    double calculatedMaxProfit = double.negativeInfinity;
    double calculatedMaxLoss = double.infinity;

    double? prevProfit;

    for (double price = minPrice; price <= maxPrice; price += step) {
      double totalProfit = 0;

      for (var item in selectedItems) {
        String cleanStrike = item.strprc.replaceAll(',', '').replaceAll(' ', '');
        final strike = double.tryParse(cleanStrike) ?? 0;
        final premium = item.entryPrice;
        final lots = item.ordlot * _lotMultiplier;
        final lotSize = item.lotSize;
        final qty = lots * lotSize;

        double optionValue = 0;
        if (item.optt == 'CE') {
          optionValue = math.max(0, price - strike);
        } else {
          optionValue = math.max(0, strike - price);
        }

        double profit;
        if (item.buySell == 'BUY') {
          profit = (optionValue - premium) * qty;
        } else {
          profit = (premium - optionValue) * qty;
        }

        totalProfit += profit;
      }

      expiryPayoff.add(PayoffDataPoint(price, totalProfit));

      // Calculate Target Payoff (T+t) using Black-Scholes
      double totalTargetProfit = 0;
      final targetDaysRemaining = math.max(0, _daysToExpiry - _targetDaysToExpiry);
      final T_target = targetDaysRemaining / 365.0;
      const r_riskFree = 0.07; // 7% Risk Free Rate

      for (var item in selectedItems) {
        String cleanStrike = item.strprc.replaceAll(',', '').replaceAll(' ', '');
        final strike = double.tryParse(cleanStrike) ?? 0;
        final premium = item.entryPrice;
        final lots = item.ordlot * _lotMultiplier;
        final lotSize = item.lotSize;
        final qty = lots * lotSize;
        
        // Handle IV provided as percentage (e.g., 20) vs decimal (0.20)
        double iv = (item.iv ?? 0) > 0 ? item.iv! : 20.0;
        if (iv > 1.0) {
          iv = iv / 100.0;
        }

        double targetOptionValue = 0;
        if (item.optt == 'CE') {
          targetOptionValue = _bsCallPrice(price, strike, T_target, r_riskFree, iv);
        } else {
          targetOptionValue = _bsPutPrice(price, strike, T_target, r_riskFree, iv);
        }

        double profit;
        if (item.buySell == 'BUY') {
          profit = (targetOptionValue - premium) * qty;
        } else {
          profit = (premium - targetOptionValue) * qty;
        }
        totalTargetProfit += profit;
      }
      targetPayoff.add(PayoffDataPoint(price, totalTargetProfit));



      // Track max/min from sampled range
      if (totalProfit > calculatedMaxProfit) calculatedMaxProfit = totalProfit;
      if (totalProfit < calculatedMaxLoss) calculatedMaxLoss = totalProfit;

      // Detect breakeven (sign change) for multi-leg strategies
      if (selectedItems.length > 1 && prevProfit != null && prevProfit * totalProfit < 0) {
        final prevPrice = price - step;
        final be = prevPrice + (step * prevProfit.abs() / (prevProfit.abs() + totalProfit.abs()));
        // Avoid duplicate breakevens
        if (!breakevens.any((b) => (b - be).abs() < step)) {
          breakevens.add(be);
        }
      }
      prevProfit = totalProfit;
    }

    // Determine final max profit/loss considering unlimited scenarios
    double finalMaxProfit;
    double finalMaxLoss;

    if (hasUnlimitedProfit) {
      finalMaxProfit = double.infinity;
    } else {
      finalMaxProfit = calculatedMaxProfit;
    }

    if (hasUnlimitedLoss) {
      finalMaxLoss = double.negativeInfinity;
    } else {
      // For all-long positions, max loss = total premium paid
      bool allLong = selectedItems.every((item) => item.buySell == 'BUY');
      if (allLong) {
        finalMaxLoss = -totalPremiumPaid;
      } else {
        finalMaxLoss = calculatedMaxLoss;
      }
    }



    _payoffData = expiryPayoff;
    _targetPayoffData = targetPayoff;

    // Calculate POP using Black-Scholes probability
    double pop = 0;
    if (breakevens.isNotEmpty && _daysToExpiry >= 0) {
      // Use Black-Scholes probability distribution
      // POP = probability that spot will be above/below breakeven at expiry

      final T = math.max(_daysToExpiry, 1) / 365.0; // Time to expiry in years
      const r = 0.07; // Risk-free rate (7% for India)

      // Get average IV from basket items
      double avgIV = 0.20; // Default 20% IV
      final itemsWithIV = selectedItems.where((item) => item.iv != null && item.iv! > 0).toList();
      if (itemsWithIV.isNotEmpty) {
        avgIV = itemsWithIV.map((item) => item.iv!).reduce((a, b) => a + b) / itemsWithIV.length;
        // Convert from percentage to decimal if needed
        if (avgIV > 1.0) avgIV = avgIV / 100.0;
      }

      if (selectedItems.length == 1) {
        // Single leg strategy - use analytical POP
        final item = selectedItems.first;
        final be = breakevens.first;

        // Calculate d2 for probability: d2 = [ln(S/K) + (r - σ²/2) * T] / (σ * √T)
        // where K is the breakeven price
        final d2 = (math.log(_spotPrice / be) + (r - 0.5 * avgIV * avgIV) * T) / (avgIV * math.sqrt(T));

        if (item.optt == 'CE') {
          // Long Call: profitable if spot > breakeven, POP = N(d2)
          // Short Call: profitable if spot < breakeven, POP = N(-d2) = 1 - N(d2)
          pop = item.buySell == 'BUY' ? _normCdf(d2) * 100 : (1 - _normCdf(d2)) * 100;
        } else {
          // Long Put: profitable if spot < breakeven, POP = N(-d2) = 1 - N(d2)
          // Short Put: profitable if spot > breakeven, POP = N(d2)
          pop = item.buySell == 'BUY' ? (1 - _normCdf(d2)) * 100 : _normCdf(d2) * 100;
        }
      } else {
        // Multi-leg strategy - use Monte Carlo or simplified approach
        // For simplicity, calculate probability of being in profit zone
        // based on the weighted average of breakeven probabilities
        double totalPop = 0;
        for (final be in breakevens) {
          final d2 = (math.log(_spotPrice / be) + (r - 0.5 * avgIV * avgIV) * T) / (avgIV * math.sqrt(T));
          // Check if profit is above or below this breakeven
          final aboveBe = expiryPayoff.where((p) => p.price > be).toList();
          bool profitAbove = aboveBe.isNotEmpty && aboveBe.last.profit > 0;

          if (profitAbove) {
            totalPop += _normCdf(d2);
          } else {
            totalPop += (1 - _normCdf(d2));
          }
        }
        pop = breakevens.isNotEmpty ? (totalPop / breakevens.length) * 100 : 0;
      }
    }

    // Risk/Reward ratio - only calculate when both are finite
    String riskReward = 'N/A';
    if (finalMaxLoss.isFinite && finalMaxLoss.abs() > 0 && finalMaxProfit.isFinite) {
      final ratio = finalMaxProfit / finalMaxLoss.abs();
      riskReward = ratio.toStringAsFixed(2);
    }

    _metrics = PayoffMetrics(
      maxProfit: finalMaxProfit.isFinite ? finalMaxProfit.toStringAsFixed(2) : 'Unlimited',
      maxLoss: finalMaxLoss.isFinite ? finalMaxLoss.toStringAsFixed(2) : 'Unlimited',
      popPercent: pop,
      riskRewardRatio: riskReward,
      breakevens: breakevens,
    );
  }

  /// Calculate margin using GetBasketMargin API
  Future<void> _calculateMargin(BuildContext context) async {
    if (_basket.isEmpty) {
      _totalMargin = '--';
      return;
    }

    final selectedItems = _basket.where((item) => item.checkbox).toList();
    if (selectedItems.isEmpty) {
      _totalMargin = '--';
      return;
    }

    try {
      // Build basket list for API
      final basketList = <Map<String, dynamic>>[];

      for (int i = 1; i < selectedItems.length; i++) {
        final item = selectedItems[i];
        final qty = item.ordlot * item.lotSize * _lotMultiplier;
        basketList.add({
          "exch": item.exch,
          "tsym": item.tsym,
          "qty": qty.toString(),
          "prc": item.entryPrice.toString(),
          "prd": "M", // NRML - matches order placement
          "trantype": item.buySell == 'BUY' ? 'B' : 'S',
          "prctyp": "MKT",
          "trgprc": "0",
        });
      }

      // First item is the main order
      final firstItem = selectedItems.first;
      final firstQty = firstItem.ordlot * firstItem.lotSize * _lotMultiplier;

      final input = OrderMarginInput(
        exch: firstItem.exch,
        tsym: firstItem.tsym,
        qty: firstQty.toString(),
        prc: firstItem.entryPrice.toString(),
        prd: 'M', // NRML - matches order placement
        trantype: firstItem.buySell == 'BUY' ? 'B' : 'S',
        prctyp: 'MKT',
        blprc: '',
        bpprc: '',
        trgprc: '0',
        rorgqty: '',
        rorgprc: '',
      );

      final response = await api.getBasketMargin(input, basketList);

      log('[StrategyBuilder] Margin API Response: ${response.stat}');

      if (response.stat == 'Ok') {
        // Parse margin from response
        final margin = double.tryParse(response.marginused ?? '0') ?? 0;
        _totalMargin = margin.toStringAsFixed(2);
      } else {
        _totalMargin = '--';
        log('[StrategyBuilder] Margin API Error: ${response.emsg}');
      }
    } catch (e) {
      log('[StrategyBuilder] Margin API Error: $e');
      _totalMargin = '--';
    }
  }

  /// Place order
  Future<void> placeOrder(BuildContext context) async {
    if (_basket.isEmpty) {
      ResponsiveSnackBar.showError(context, 'Basket is empty');
      return;
    }

    final selectedItems = _basket.where((item) => item.checkbox).toList();
    if (selectedItems.isEmpty) {
      ResponsiveSnackBar.showError(context, 'No items selected');
      return;
    }

    _isOrderLoading = true;
    notifyListeners();

    try {
      int successCount = 0;
      int failCount = 0;

      for (var item in selectedItems) {
        final qty = item.ordlot * item.lotSize * _lotMultiplier;

        final orderPayload = PlaceOrderInput(
          exch: item.exch,
          tsym: item.tsym,
          qty: qty.toString(),
          prc: item.entryPrice.toString(),
          prd: 'M', // NRML
          trantype: item.buySell == 'BUY' ? 'B' : 'S',
          prctype: 'LMT',
          ret: 'DAY',
          amo: '',
          trgprc: '',
          trailprc: '',
          blprc: '',
          bpprc: '',
          dscqty: '',
          mktProt: '',
          channel: 'WEB',
        );

        final result = await api.getPlaceOrder(orderPayload, '');
        if (result.stat == 'Ok') {
          successCount++;
        } else {
          failCount++;
          log('[StrategyBuilder] Order failed: ${item.tsym} - ${result.emsg}');
        }
      }

      if (successCount > 0) {
        ResponsiveSnackBar.showSuccess(context, '$successCount order(s) placed successfully');
      }
      if (failCount > 0) {
        ResponsiveSnackBar.showError(context, '$failCount order(s) failed');
      }
    } catch (e) {
      ResponsiveSnackBar.showError(context, 'Failed to place orders');
      log('[StrategyBuilder] Place order error: $e');
    } finally {
      _isOrderLoading = false;
      notifyListeners();
    }
  }

  /// Get available strikes for expiry
  List<String> getStrikesForExpiry(String expiry) {
    final strikes = <String>{};
    for (var option in _optionChain) {
      if (option.strprc != null) {
        strikes.add(option.strprc!);
      }
    }
    final sortedStrikes = strikes.toList()
      ..sort((a, b) => (double.tryParse(a) ?? 0).compareTo(double.tryParse(b) ?? 0));
    return sortedStrikes;
  }

  /// Calculate Greeks total for the entire position
  /// Returns sum of per-option Greeks for all selected items
  double greeksTotal(String column) {
    double total = 0;
    for (var item in _basket) {
      if (!item.checkbox) continue;
      double? value;
      // For single lot positions, Total = Individual values
      // All Greeks are stored as per-option values
      final positionMultiplier = item.ordlot * _lotMultiplier;

      switch (column) {
        case 'delta':
          // Per-option delta summed across lots
          value = (item.delta ?? 0) * positionMultiplier;
          break;
        case 'gamma':
          // Per-option gamma summed across lots
          value = (item.gamma ?? 0) * positionMultiplier;
          break;
        case 'theta':
          // Per-option theta summed across lots
          value = (item.theta ?? 0) * positionMultiplier;
          break;
        case 'vega':
          // Per-option vega summed across lots
          value = (item.vega ?? 0) * positionMultiplier;
          break;
      }
      total += value ?? 0;
    }
    return total;
  }

  /// WebSocket subscriptions
  void _subscribeToIndex() {
    final websocketProv = ref.read(websocketProvider);
    final subscriptionKey = '$_selectedExch|$_selectedToken';

    websocketProv.connectTouchLine(
      input: subscriptionKey,
      task: 't',
      context: WidgetsBinding.instance.rootElement!,
    );
  }

  void _subscribeToOptions() {
    final websocketProv = ref.read(websocketProvider);

    // Unsubscribe from previous
    if (_subscribedTokens.isNotEmpty) {
      websocketProv.connectTouchLine(
        input: _subscribedTokens.join('#'),
        task: 'u',
        context: WidgetsBinding.instance.rootElement!,
      );
      _subscribedTokens.clear();
    }

    // Subscribe to new
    final keys = <String>[];
    for (var option in _optionChain) {
      if (option.exch != null && option.token != null) {
        keys.add('${option.exch}|${option.token}');
        _subscribedTokens.add('${option.exch}|${option.token}');
      }
    }

    if (keys.isNotEmpty) {
      websocketProv.connectTouchLine(
        input: keys.join('#'),
        task: 't',
        context: WidgetsBinding.instance.rootElement!,
      );
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshFromWebSocket();
    });
  }

  void _refreshFromWebSocket() {
    final websocketProv = ref.read(websocketProvider);
    final socketData = websocketProv.socketDatas;

    bool hasUpdates = false;

    // Update spot price - try both key formats
    final spotTokenKey = _selectedToken;
    final spotExchTokenKey = '$_selectedExch|$_selectedToken';
    final indexData = socketData[spotTokenKey] ?? socketData[spotExchTokenKey];
    if (indexData != null && indexData['lp'] != null) {
      final newPrice = double.tryParse(indexData['lp'].toString()) ?? 0;
      if (newPrice > 0 && newPrice != _spotPrice) {
        _spotPrice = newPrice;
        // Update percent change from websocket data
        final pc = double.tryParse(indexData['pc']?.toString() ?? '');
        if (pc != null) {
          _spotPriceChangePercent = pc;
        } else {
          // Fallback: calculate from change value
          final chng = double.tryParse(indexData['c']?.toString() ?? indexData['chng']?.toString() ?? '0') ?? 0;
          final prevClose = newPrice - chng;
          if (prevClose > 0) {
            _spotPriceChangePercent = (chng / prevClose) * 100;
          }
        }
        hasUpdates = true;
      }
    }

    // Update basket items LTP
    for (int i = 0; i < _basket.length; i++) {
      final item = _basket[i];
      // Try both formats: just token and exch|token
      final tokenKey = item.token;
      final exchTokenKey = '${item.exch}|${item.token}';
      final data = socketData[tokenKey] ?? socketData[exchTokenKey];
      if (data != null && data['lp'] != null) {
        final newLtp = double.tryParse(data['lp'].toString()) ?? 0;
        if (newLtp != item.ltp) {
          _basket[i] = item.copyWith(ltp: newLtp);
          hasUpdates = true;
        }
      }
    }

    // Update option chain
    for (int i = 0; i < _optionChain.length; i++) {
      final option = _optionChain[i];
      if (option.token == null) continue;

      // Try both formats: just token and exch|token
      final tokenKey = option.token!;
      final exchTokenKey = '${option.exch}|${option.token}';
      final data = socketData[tokenKey] ?? socketData[exchTokenKey];

      if (data != null && data['lp'] != null) {
        _optionChain[i] = OptionValues(
          exch: option.exch,
          token: option.token,
          tsym: option.tsym,
          optt: option.optt,
          pp: option.pp,
          ls: option.ls,
          ti: option.ti,
          lp: data['lp'].toString(),
          perChange: data['pc']?.toString() ?? option.perChange,
          close: option.close,
          oi: data['oi']?.toString() ?? option.oi,
          poi: option.poi,
          strprc: option.strprc,
        );
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      // Note: Greeks are NOT updated live - they are calculated once when option is added
      // Only LTP and option chain prices are updated via WebSocket
      notifyListeners();
    }
  }

  /// Load positions into the strategy builder for analysis
  Future<void> loadFromPositions(List<PositionBookModel> positions, BuildContext context) async {
    _isAnalyzeMode = true;
    _lotMultiplier = 1;
    _basket.clear();
    _payoffData = [];
    _targetPayoffData = [];
    _metrics = PayoffMetrics();
    _activePredefinedStrategy = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (positions.isEmpty) return;

      // Resolve underlying symbol from first position's tsym
      final firstPos = positions.first;
      // Extract underlying symbol (e.g., "NIFTY" from "NIFTY28FEB25C24500")
      final tsym = firstPos.tsym ?? '';
      final symbol = firstPos.symbol ?? firstPos.dname ?? tsym;
      _selectedSymbol = symbol;
      _selectedExch = firstPos.exch ?? 'NFO';

      // Fetch spot price for the underlying
      // Try to find underlying token - use the symbol to search
      try {
        final results = await api.searchScripForStrategyBuilder(
          searchText: symbol,
          exchanges: ["NSE", "NFO", "BSE"],
        );
        if (results.stat == 'Ok' && results.values != null) {
          final underlying = results.values!.firstWhere(
            (r) => r.instname == 'UNDIND' || r.instname == 'INDEX',
            orElse: () => results.values!.first,
          );
          _selectedToken = underlying.token ?? '';
          _selectedExch = underlying.exch ?? 'NSE';

          final quote = await api.getScripQuote(_selectedToken, _selectedExch);
          if (quote.stat == 'Ok') {
            _spotPrice = double.tryParse(quote.lp ?? '0') ?? 0;
            _targetSpotPrice = _spotPrice;
          }
        }
      } catch (e) {
        log('[StrategyBuilder] Error fetching underlying for analyze: $e');
      }

      // Load expiry dates
      await _loadExpiryDates(context);

      // Map each position to a basket item
      for (var pos in positions) {
        final netqty = int.tryParse(pos.netqty ?? '0') ?? 0;
        if (netqty == 0) continue;

        final buySell = netqty > 0 ? 'BUY' : 'SELL';
        final lotSize = int.tryParse(pos.ls ?? '1') ?? 1;
        final ordlot = lotSize > 0 ? (netqty.abs() / lotSize).round() : 1;
        final avgPrc = double.tryParse(pos.avgPrc ?? '0') ?? 0;
        final ltp = double.tryParse(pos.lp ?? '0') ?? 0;

        // Parse option type and strike from option field (format: "CE 24500" or "PE 25000")
        String optt = 'CE';
        String strprc = '0';
        final optionField = pos.option ?? '';
        if (optionField.contains('CE')) {
          optt = 'CE';
          strprc = optionField.replaceAll('CE', '').trim();
        } else if (optionField.contains('PE')) {
          optt = 'PE';
          strprc = optionField.replaceAll('PE', '').trim();
        }

        // Convert position expDate (space-separated "24 FEB 26") to
        // API format (dash-separated "24-FEB-26") for matching
        final posExpDate = pos.expDate ?? '';
        final apiExpDate = posExpDate.replaceAll(' ', '-');

        // Find matching expiry from loaded expiry dates, fallback to converted format
        String matchedExpiry = _selectedExpiry;
        if (_expiryDates.contains(apiExpDate)) {
          matchedExpiry = apiExpDate;
        } else {
          // Try to find a match by comparing parsed dates
          for (final exp in _expiryDates) {
            if (exp.replaceAll('-', ' ') == posExpDate || exp == apiExpDate) {
              matchedExpiry = exp;
              break;
            }
          }
          // If still no match, use converted format
          if (matchedExpiry == _selectedExpiry && apiExpDate.isNotEmpty) {
            matchedExpiry = apiExpDate;
          }
        }

        final item = StrategyBasketItem(
          tsym: pos.tsym ?? '',
          token: pos.token ?? '',
          exch: pos.exch ?? 'NFO',
          strprc: strprc,
          optt: optt,
          expdate: matchedExpiry,
          buySell: buySell,
          ordlot: ordlot,
          entryPrice: avgPrc,
          ltp: ltp,
          lotSize: lotSize,
          checkbox: true,
        );

        _basket.add(item);

        // Calculate Greeks for each item
        _updateItemGreeks(item);
      }

      // Calculate days to expiry from first basket item's expiry (now in API format)
      if (_basket.isNotEmpty) {
        final expiryDate = _parseExpiryDate(_basket.first.expdate);
        _daysToExpiry = expiryDate.difference(DateTime.now()).inDays;
        if (_daysToExpiry < 0) _daysToExpiry = 0;
        _targetDaysToExpiry = 0;
        _selectedExpiry = _basket.first.expdate;
      }

      // Calculate payoff
      _calculatePayoff();

      // Subscribe to updates
      _subscribeToIndex();
      _startRefreshTimer();

      // Try to fetch API payoff, greeks, and margin
      await Future.wait([
        _fetchPayoffFromAPI(),
        _calculateMargin(context),
        ...basket.map((item) => _fetchGreeksFromAPI(item)),
      ]);
    } catch (e) {
      log('[StrategyBuilder] loadFromPositions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exit analyze mode and reset state
  void exitAnalyzeMode() {
    _isAnalyzeMode = false;
    _lotMultiplier = 1;
    _basket.clear();
    _payoffData = [];
    _targetPayoffData = [];
    _metrics = PayoffMetrics();
    _activePredefinedStrategy = null;
    _totalMargin = '--';
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    // Unsubscribe
    if (_subscribedTokens.isNotEmpty) {
      try {
        final websocketProv = ref.read(websocketProvider);
        websocketProv.connectTouchLine(
          input: _subscribedTokens.join('#'),
          task: 'u',
          context: WidgetsBinding.instance.rootElement!,
        );
      } catch (e) {
        // Ignore if already disposed
      }
    }

    super.dispose();
  }
}
