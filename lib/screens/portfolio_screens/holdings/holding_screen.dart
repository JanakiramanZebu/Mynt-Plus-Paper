import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer, ConsumerWidget;
import '../../../provider/fund_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/functions.dart';
import '../../../utils/no_emoji_inputformatter.dart';
import 'filter_scrip_bottom_sheet.dart';

import 'holdings_list.dart';

class HoldingScreen extends ConsumerStatefulWidget {
  const HoldingScreen({super.key});

  @override
  ConsumerState<HoldingScreen> createState() => _HoldingScreenState();
}

class _HoldingScreenState extends ConsumerState<HoldingScreen> {
  StreamSubscription? _socketSubscription;
  
  // Cached values to avoid recalculations
  double _totalPnlHolding = 0.0;
  double _oneDayChng = 0.0;
  double _invest = 0.0;
  double _totalCurrentVal = 0.0;
  double _oneDayChngPer = 0.0;
  String _totPnlPercHolding = "0.00";
  
  // Flag to track if initialization happened
  bool _isInitialized = false;
  
  // Map to track which tokens have been updated
  final Map<String, bool> _updatedTokens = {};
  
  // Last update time for throttling
  DateTime _lastSocketUpdateTime = DateTime.now();
  static const Duration _minUpdateInterval = Duration(milliseconds: 200);
  
  // Cached widgets to prevent rebuilds
  Widget? _cachedActionButtons;
  Widget? _cachedEmptyState;
  
  // Added for memoization in _buildSummarySection
  String? _cachedSummaryKey;
  Widget? _cachedSummarySection;
  
  // Added for action buttons memoization
  String? _cachedActionButtonsKey;
  
  // Static divider containers (one for dark, one for light theme)
  Widget? _cachedDarkDivider;
  Widget? _cachedLightDivider;
  
  @override
  void initState() {
    super.initState();
    
    // Delay initialization to avoid setState during build
    // Use a longer delay to ensure we batch multiple initialization steps
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _calculateInitialValues();
        _setupSocketSubscription();
      }
    });
  }
  
  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }
  
  void _setupSocketSubscription() {
    final socketProvider = ref.read(websocketProvider);
    
    // Use debounce to reduce update frequency
    _socketSubscription = socketProvider.socketDataStream.listen((socketDatas) {
      if (socketDatas.isEmpty) return;
      
      // Throttle updates more aggressively to reduce unnecessary rebuilds
      final now = DateTime.now();
      if (now.difference(_lastSocketUpdateTime) < _minUpdateInterval) {
        return; // Skip this update if it's too soon after the last one
      }
      
      _lastSocketUpdateTime = now;
      
      // Process updates in a microtask to batch them together
      Future.microtask(() {
        _updateHoldingsData(socketDatas);
      });
    });
  }
  
  // Update holdings data with socket updates - optimized version
  void _updateHoldingsData(Map socketDatas) {
    final holdingProvider = ref.read(portfolioProvider);
    final holdings = holdingProvider.showSearchHold
        ? holdingProvider.holdingSearchItem!
        : holdingProvider.holdingsModel!;
    
    if (holdings.isEmpty) return;
    
    bool hasUpdates = false;
    bool summaryUpdated = false;
    
    // Reset summary values only if we detect actual updates
    double newTotalPnl = 0.0;
    double newOneDayChng = 0.0;
    double newInvest = 0.0;
    double newTotalCurrentVal = 0.0;
    
    // Reset updated tokens tracking for this update cycle
    _updatedTokens.clear();
    
    // Record previous values to detect actual changes
    final double previousTotalPnl = _totalPnlHolding;
    final double previousOneDayChng = _oneDayChng;
    final double previousInvest = _invest;
    final double previousTotalCurrentVal = _totalCurrentVal;
    
    for (var holding in holdings) {
      if (holding.exchTsym == null || holding.exchTsym!.isEmpty) continue;
      
      var exchTsym = holding.exchTsym![0];
      if (exchTsym.token == null) continue;
      
      if (socketDatas.containsKey(exchTsym.token)) {
        final socketData = socketDatas[exchTsym.token];
        
        // Skip if socketData is empty (heartbeat) or null
        if (socketData == null || socketData.isEmpty) continue;
        
        // Cache current values for comparison
        final String currentLp = exchTsym.lp ?? "0.00";
        final String currentPerChange = exchTsym.perChange ?? "0.00";
        final String currentClose = exchTsym.close ?? "0.00";
        final String currentValue = holding.currentValue ?? "0.00";
        
        bool tokenUpdated = false;
        
        // Only update with non-zero values, otherwise keep existing values
        final lp = socketData['lp']?.toString();
        if (lp != null && lp != "null" && lp != "0" && lp != "0.0" && lp != "0.00" && lp != currentLp) {
          exchTsym.lp = lp;
          tokenUpdated = true;
        }
        
        final pc = socketData['pc']?.toString();
        if (pc != null && pc != "null" && pc != "0" && pc != "0.0" && pc != "0.00" && pc != currentPerChange) {
          exchTsym.perChange = pc;
          tokenUpdated = true;
        }
        
        final c = socketData['c']?.toString();
        if (c != null && c != "null" && c != "0" && c != "0.0" && c != "0.00" && c != currentClose) {
          exchTsym.close = c;
          tokenUpdated = true;
        }
        
        // Track if this token was updated
        if (tokenUpdated) {
          _updatedTokens[exchTsym.token!] = true;
          hasUpdates = true;
        }
        
        // Only calculate currentValue if we have valid lp AND it changed
        final lpValue = double.tryParse(exchTsym.lp ?? "0.00") ?? 0.0;
        if (lpValue > 0 && (tokenUpdated || !_isInitialized)) {
          final newCurrentValue = (int.parse("${holding.currentQty ?? 0}") * lpValue).toStringAsFixed(2);
          
          // Only update if actually changed
          if (newCurrentValue != currentValue) {
            holding.currentValue = newCurrentValue;
            tokenUpdated = true;
          
            // Use the close value for avgCost only if it's valid
            final closeValue = double.tryParse(exchTsym.close ?? "0.00") ?? 0.0;
            double avgCost = double.parse("${holding.upldprc == "0.00" ? 
                (closeValue > 0 ? closeValue.toString() : "0.00") : holding.upldprc ?? 0.00}");
            
            if (avgCost > 0) {
              holding.invested = (holding.currentQty! * avgCost).toStringAsFixed(2);
            }
            
            if (holding.currentQty == 0) {
              double sellAmt = double.parse(holding.sellAmt ?? "0.00");
              int usedQty = int.parse(holding.usedqty ?? "0");
              double price = usedQty > 0 ? (sellAmt / usedQty) : 0.0;
              double pnl = price - double.parse(holding.upldprc ?? "0.0");
              
              exchTsym.profitNloss = (pnl * usedQty).toStringAsFixed(2);
            } else {
              exchTsym.profitNloss = (double.parse(holding.currentValue ?? "0.00") - 
                  double.parse(holding.invested ?? "0.00")).toStringAsFixed(2);
            }
            
            exchTsym.pNlChng = holding.invested == "0.00" 
                ? "0.00" 
                : ((double.parse("${exchTsym.profitNloss ?? 0.0}") / 
                    double.parse("${holding.invested ?? 0.0}")) * 100).toStringAsFixed(2);
            
            exchTsym.oneDayChg = ((double.parse(exchTsym.lp ?? "0.00") - 
                    double.parse(exchTsym.close ?? "0.00")) * 
                    int.parse("${holding.currentQty ?? 0}")).toStringAsFixed(2);
          }
        }
      }
      
      // Accumulate summary values
      newTotalPnl += double.parse("${exchTsym.profitNloss ?? 0.0}");
      newOneDayChng += double.parse("${exchTsym.oneDayChg ?? 0.0}");
      newInvest += double.parse("${holding.invested ?? 0.0}");
      newTotalCurrentVal += double.parse("${holding.currentValue ?? 0.0}");
    }
    
    // Only update summary values if they've changed significantly
    // Using small threshold to avoid rounding issues causing unnecessary updates
    const double threshold = 0.01;
    if (!_isInitialized || 
        (previousTotalPnl - newTotalPnl).abs() > threshold || 
        (previousOneDayChng - newOneDayChng).abs() > threshold || 
        (previousInvest - newInvest).abs() > threshold || 
        (previousTotalCurrentVal - newTotalCurrentVal).abs() > threshold) {
      
      _totalPnlHolding = newTotalPnl;
      _oneDayChng = newOneDayChng;
      _invest = newInvest;
      _totalCurrentVal = newTotalCurrentVal;
      
      // Calculate summary percentages
      _oneDayChngPer = _totalCurrentVal > 0 ? (_oneDayChng / _totalCurrentVal) * 100 : 0.0;
      _totPnlPercHolding = _invest > 0
          ? ((_totalPnlHolding / _invest) * 100).toStringAsFixed(2)
          : "0.00";
          
      summaryUpdated = true;
    }
    
    // Only rebuild if we have actual updates and are mounted
    if ((hasUpdates || summaryUpdated) && mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }
  
  // Calculate initial values from provider data
  void _calculateInitialValues() {
    if (_isInitialized) return; // Prevent duplicate initialization
    
    final holdingProvider = ref.read(portfolioProvider);
    final websocket = ref.read(websocketProvider);
    
    // Process initial socket data
    if (websocket.socketDatas.isNotEmpty) {
      _processInitialData(websocket.socketDatas);
    } else {
      // If no socket data yet, just mark as initialized
      setState(() {
        _isInitialized = true;
      });
    }
  }
  
  // Process initial data without triggering setState during build
  void _processInitialData(Map socketDatas) {
    final holdingProvider = ref.read(portfolioProvider);
    final holdings = holdingProvider.showSearchHold
        ? holdingProvider.holdingSearchItem!
        : holdingProvider.holdingsModel!;
    
    if (holdings.isEmpty) return;
    
    // Reset summary values
    _totalPnlHolding = 0.0;
    _oneDayChng = 0.0;
    _invest = 0.0;
    _totalCurrentVal = 0.0;
    
    for (var holding in holdings) {
      if (holding.exchTsym == null || holding.exchTsym!.isEmpty) continue;
      
      var exchTsym = holding.exchTsym![0];
      if (socketDatas.containsKey(exchTsym.token)) {
        final socketData = socketDatas[exchTsym.token];
        
        // Skip if socketData is empty (heartbeat) or null
        if (socketData == null || socketData.isEmpty) continue;
        
        // Update with non-zero values if needed
                            final lp = socketData['lp']?.toString();
                            if (lp != null && lp != "null" && lp != "0" && lp != "0.0" && lp != "0.00") {
          exchTsym.lp = lp;
                            }
                            
        // Update other values as needed
                            final pc = socketData['pc']?.toString();
                            if (pc != null && pc != "null" && pc != "0" && pc != "0.0" && pc != "0.00") {
          exchTsym.perChange = pc;
                            }
                            
                            final c = socketData['c']?.toString();
                            if (c != null && c != "null" && c != "0" && c != "0.0" && c != "0.00") {
          exchTsym.close = c;
                            }
                            
        // Calculate current values
        final lpValue = double.tryParse(exchTsym.lp ?? "0.00") ?? 0.0;
                            if (lpValue > 0) {
          holding.currentValue = (int.parse("${holding.currentQty ?? 0}") * lpValue).toStringAsFixed(2);
          
          // Use the close value for avgCost only if it's valid
          final closeValue = double.tryParse(exchTsym.close ?? "0.00") ?? 0.0;
          double avgCost = double.parse("${holding.upldprc == "0.00" ? 
              (closeValue > 0 ? closeValue.toString() : "0.00") : holding.upldprc ?? 0.00}");
          
          if (avgCost > 0) {
            holding.invested = (holding.currentQty! * avgCost).toStringAsFixed(2);
          }
          
          if (holding.currentQty == 0) {
            double sellAmt = double.parse(holding.sellAmt ?? "0.00");
            int usedQty = int.parse(holding.usedqty ?? "0");
            double price = usedQty > 0 ? (sellAmt / usedQty) : 0.0;
            double pnl = price - double.parse(holding.upldprc ?? "0.0");
            
            exchTsym.profitNloss = (pnl * usedQty).toStringAsFixed(2);
          } else {
            exchTsym.profitNloss = (double.parse(holding.currentValue ?? "0.00") - 
                double.parse(holding.invested ?? "0.00")).toStringAsFixed(2);
          }
          
          exchTsym.pNlChng = holding.invested == "0.00" 
              ? "0.00" 
              : ((double.parse("${exchTsym.profitNloss ?? 0.0}") / 
                  double.parse("${holding.invested ?? 0.0}")) * 100).toStringAsFixed(2);
          
          exchTsym.oneDayChg = ((double.parse(exchTsym.lp ?? "0.00") - 
                  double.parse(exchTsym.close ?? "0.00")) * 
                  int.parse("${holding.currentQty ?? 0}")).toStringAsFixed(2);
        }
      }
      
      // Accumulate summary values
      _totalPnlHolding += double.parse("${exchTsym.profitNloss ?? 0.0}");
      _oneDayChng += double.parse("${exchTsym.oneDayChg ?? 0.0}");
      _invest += double.parse("${holding.invested ?? 0.0}");
      _totalCurrentVal += double.parse("${holding.currentValue ?? 0.0}");
    }
    
    // Calculate summary percentages
    _oneDayChngPer = _totalCurrentVal > 0 ? (_oneDayChng / _totalCurrentVal) * 100 : 0.0;
    _totPnlPercHolding = _invest > 0
        ? ((_totalPnlHolding / _invest) * 100).toStringAsFixed(2)
                            : "0.00";
    
    // Mark as initialized and update UI safely
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read providers only once for static data
    final theme = ref.read(themeProvider);
    final holdingProvider = ref.read(portfolioProvider);
    
    // Use a focused Consumer only for the loading status
    return Consumer(
      builder: (context, watch, _) {
        final isLoading = ref.watch(portfolioProvider).holdloader;
        
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // Summary section with investment and P&L information
              _buildSummarySection(),
              
              // Action buttons section - using cached buttons when possible
              _getActionButtons(),
              
              // Search bar (conditional)
              _buildSearchBar(),
              
              // Holdings list with selective rebuilding
              _buildHoldingsList()
            ]
          )
        );
      }
    );
  }
  
  // Method to calculate summary values from holdings data
  void _calculateSummaryValues() {
    final holdingProvider = ref.read(portfolioProvider);
    final holdings = holdingProvider.showSearchHold
        ? holdingProvider.holdingSearchItem!
        : holdingProvider.holdingsModel!;
    
    if (holdings.isEmpty) {
      _totalPnlHolding = 0.0;
      _oneDayChng = 0.0;
      _invest = 0.0;
      _totalCurrentVal = 0.0;
      _oneDayChngPer = 0.0;
      _totPnlPercHolding = "0.00";
      return;
    }
    
    double newTotalPnl = 0.0;
    double newOneDayChng = 0.0;
    double newInvest = 0.0;
    double newTotalCurrentVal = 0.0;
    
    for (var holding in holdings) {
      if (holding.exchTsym == null || holding.exchTsym!.isEmpty) continue;
      var exchTsym = holding.exchTsym![0];
      
      // Accumulate summary values
      newTotalPnl += double.parse("${exchTsym.profitNloss ?? 0.0}");
      newOneDayChng += double.parse("${exchTsym.oneDayChg ?? 0.0}");
      newInvest += double.parse("${holding.invested ?? 0.0}");
      newTotalCurrentVal += double.parse("${holding.currentValue ?? 0.0}");
    }
    
    _totalPnlHolding = newTotalPnl;
    _oneDayChng = newOneDayChng;
    _invest = newInvest;
    _totalCurrentVal = newTotalCurrentVal;
    
    // Calculate summary percentages
    _oneDayChngPer = _totalCurrentVal > 0 ? (_oneDayChng / _totalCurrentVal) * 100 : 0.0;
    _totPnlPercHolding = _invest > 0
        ? ((_totalPnlHolding / _invest) * 100).toStringAsFixed(2)
        : "0.00";
    
    // Reset summary section cache so it will be rebuilt
    _cachedSummarySection = null;
  }

  // Summary section with investment and P&L information
  Widget _buildSummarySection() {
    final theme = ref.read(themeProvider);
    
    // Add a Consumer to force rebuilds when holdings data changes
    return Consumer(
      builder: (context, watch, _) {
        // Watch holdings data but don't use it directly
        // This ensures the section rebuilds when API data updates
        ref.watch(portfolioProvider);
        
        // Recalculate summary values when provider updates
        _calculateSummaryValues();
        
        // Create a memoized version that only updates when the key data changes
        final memoKey = '${_totalPnlHolding.toStringAsFixed(2)}-${_oneDayChng.toStringAsFixed(2)}-' +
                      '${_invest.toStringAsFixed(2)}-${_totalCurrentVal.toStringAsFixed(2)}';
        
        // Add this field to the class to store the cached summary section
        if (_cachedSummarySection != null && _cachedSummaryKey == memoKey) {
          return _cachedSummarySection!;
        }
        
        // Wrap in RepaintBoundary to isolate painting
        _cachedSummaryKey = memoKey;
        _cachedSummarySection = RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? const Color(0xffB5C0CF).withOpacity(.15)
                  : const Color(0xffF1F3F8)
            ),
            child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                    // Investment column - static except for the value
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        Text(
                          "Invested",
                          style: textStyle(const Color(0xff5E6B7D), 12, FontWeight.w500)
                        ),
                                  const SizedBox(height: 6),
                                  Text(
                          "₹${getFormatter(value: _invest, v4d: false, noDecimal: false)}",
                                      style: textStyle(
                            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                          14,
                            FontWeight.w500
                          )
                        ),
                                ],
                              ),
                    // P&L column - dynamic based on profit/loss
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                        Text(
                          "Total P&L",
                          style: textStyle(const Color(0xff5E6B7D), 12, FontWeight.w500)
                        ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                              "₹${getFormatter(value: _totalPnlHolding, v4d: false, noDecimal: false)} ",
                                          style: textStyle(
                                _totalPnlHolding.toString().startsWith("-")
                                                  ? colors.darkred
                                                  : colors.ltpgreen,
                                              16,
                                FontWeight.w500
                              )
                            ),
                                      Text(
                              "(${_totPnlPercHolding == "NaN" ? 0.00 : _totPnlPercHolding}%)",
                                          style: textStyle(
                                _totPnlPercHolding.startsWith("-")
                                                  ? colors.darkred
                                                  : colors.ltpgreen,
                                              14,
                                FontWeight.w500
                              )
                            ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                    // Current value column
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                        Text(
                          "Current Value",
                          style: textStyle(const Color(0xff5E6B7D), 12, FontWeight.w500)
                        ),
                                    const SizedBox(height: 6),
                                    Text(
                          "₹${getFormatter(value: _totalCurrentVal, v4d: false, noDecimal: false)}",
                                        style: textStyle(
                            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                            14,
                            FontWeight.w500
                          )
                        ),
                                  ],
                                ),
                    // Day change column
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                        Text(
                          "1D Change",
                          style: textStyle(const Color(0xff5E6B7D), 12, FontWeight.w500)
                        ),
                                      const SizedBox(height: 6),
                        Row(
                          children: [
                                        Text(
                              "₹${getFormatter(value: _oneDayChng, v4d: false, noDecimal: false)}",
                                            style: textStyle(
                                _oneDayChng.toStringAsFixed(2).startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                16,
                                FontWeight.w500
                              )
                            ),
                                        Text(
                              " (${_oneDayChngPer.isNaN ? "0.00" : _oneDayChngPer.toStringAsFixed(2)}%)",
                                            style: textStyle(
                                _oneDayChngPer.toStringAsFixed(2).startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                14,
                                FontWeight.w500
                              )
                            )
                          ]
                        )
                      ]
                    )
                  ]
                )
              ],
            )
          )
        );
        
        return _cachedSummarySection!;
      }
    );
  }
  
  // Get cached action buttons or create new ones
  Widget _getActionButtons() {
    // Use a Consumer to watch for holdings data changes that might affect action buttons
    return Consumer(
      builder: (context, watch, _) {
        // Watch whether there are holdings and the showEdis flag
        final holdingProvider = ref.watch(portfolioProvider);
        
        // Generate key based on what matters for action buttons
        final hasHoldings = holdingProvider.holdingsModel != null && 
                           holdingProvider.holdingsModel!.isNotEmpty;
        final showEdis = holdingProvider.showEdis;
        final showSearch = holdingProvider.showSearchHold;
        final buttonStateKey = '$hasHoldings-$showEdis-$showSearch';
        
        // Check if we already have these buttons cached
        if (_cachedActionButtons != null && _cachedActionButtonsKey == buttonStateKey) {
          return _cachedActionButtons!;
        }
        
        // Generate new action buttons and cache them
        _cachedActionButtonsKey = buttonStateKey;
        _cachedActionButtons = _buildActionButtonsSection(
          hasHoldings: hasHoldings,
          showEdis: showEdis,
          showSearch: showSearch
        );
        
        return _cachedActionButtons!;
      }
    );
  }
  
  // Action buttons section
  Widget _buildActionButtonsSection({
    required bool hasHoldings,
    required bool showEdis,
    required bool showSearch
  }) {
    final holdingProvider = ref.read(portfolioProvider);
    final mf = ref.read(mfProvider);
    final theme = ref.read(themeProvider);
    
    return RepaintBoundary(
      child: Container(
                  decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
              width: 6
            )
          )
        ),
                  child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 2, top: 8, bottom: 8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                  if (hasHoldings && showEdis) ...[
                                  SizedBox(
                                      height: 27,
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.colorGrey),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32))
                          )
                        ),
                                          onPressed: () async {
                          await ref.read(fundProvider).fetchHstoken(context);
                          await ref.read(fundProvider).eDis(context);
                        },
                        child: Text(
                          "E-DIS",
                                              style: textStyle(
                            !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                                                  12,
                            FontWeight.w600
                                  )
                        )
                      )
                    ),
                    const SizedBox(width: 8)
                                ],
                                SizedBox(
                                    height: 27,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.colorGrey),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32))
                        )
                      ),
                                        onPressed: () async {
                                          await mf.mfApicallinit(context, 2);
                                        },
                      child: Text(
                        "My MF",
                                            style: textStyle(
                          !theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                          12,
                          FontWeight.w600
                        )
                      )
                    )
                  )
                ],
              ),
              if (hasHoldings && holdingProvider.holdingsModel!.length > 1)
                Row(
                  children: [
                    if (!showSearch)
                                  InkWell(
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        showModalBottomSheet(
                                            useSafeArea: true,
                                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                            ),
                                            context: context,
                                            builder: (context) {
                                              return const HoldingsScripFilterBottomSheet();
                            }
                          );
                                      },
                                      child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                                        child: SvgPicture.asset(
                                            assets.filterLines,
                                            color: theme.isDarkMode
                                                ? const Color(0xffBDBDBD)
                              : colors.colorGrey
                          ),
                        )
                      ),
                                InkWell(
                                    onTap: () {
                        ref.read(portfolioProvider).showHoldSearch(true);
                        // Reset cached widgets because UI structure changed
                        setState(() {
                          _cachedActionButtons = null;
                          _cachedActionButtonsKey = null;
                        });
                                    },
                                    child: Padding(
                        padding: const EdgeInsets.only(right: 12, left: 10),
                                        child: SvgPicture.asset(
                                            assets.searchIcon,
                                            width: 19,
                                            color: theme.isDarkMode
                                                ? const Color(0xffBDBDBD)
                            : colors.colorGrey
                        )
                      )
                    )
                  ]
                )
            ]
          )
        )
      )
    );
  }
  
  // Search bar section (shown conditionally)
  Widget _buildSearchBar() {
    final holdingProvider = ref.read(portfolioProvider);
    
    // Only watch the search visibility state with a focused Consumer
    return Consumer(
      builder: (context, watch, _) {
        final showSearch = ref.watch(portfolioProvider).showSearchHold;
        
        if (!showSearch) {
          return const SizedBox.shrink();
        }
        
        // Save theme reference to prevent repeated lookups
        final theme = ref.read(themeProvider);
        
        return RepaintBoundary(
          child: Container(
                    height: 62,
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                  width: 6
                )
              )
            ),
            child: Row(
              children: [
                      Expanded(
                          child: TextFormField(
                    controller: holdingProvider.holdingSearchCtrl,
                              style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                  16,
                      FontWeight.w600
                    ),
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                NoEmojiInputFormatter(),
                      FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
                              ],
                              decoration: InputDecoration(
                                  fillColor: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                  filled: true,
                                  hintStyle: GoogleFonts.inter(
                        textStyle: textStyle(const Color(0xff69758F), 15, FontWeight.w500)
                      ),
                                  prefixIconColor: const Color(0xff586279),
                                  prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SvgPicture.asset(
                          assets.searchIcon,
                                        color: const Color(0xff586279),
                                        fit: BoxFit.contain,
                          width: 20
                        ),
                                  ),
                                  suffixIcon: InkWell(
                                    onTap: () async {
                          holdingProvider.clearHoldSearch();
                                    },
                                    child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SvgPicture.asset(
                            assets.removeIcon,
                            fit: BoxFit.scaleDown,
                            width: 20
                          ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)
                      ),
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)
                      ),
                                  hintText: "Search Scrip Name",
                      contentPadding: const EdgeInsets.only(top: 20),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                              onChanged: (value) async {
                      holdingProvider.holdingSearch(value, context);
                    }
                  )
                ),
                      TextButton(
                          onPressed: () {
                    holdingProvider.clearHoldSearch();
                    holdingProvider.showHoldSearch(false);
                    // Reset cached widgets because UI structure changed
                    setState(() {
                      _cachedActionButtons = null;
                      _cachedActionButtonsKey = null;
                    });
                  },
                  child: Text(
                    "Close",
                              style: textStyles.textBtn.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                        : colors.colorBlue
                    )
                  )
                )
              ]
            )
          )
        );
      }
    );
  }
  
  // Holdings list section
  Widget _buildHoldingsList() {
    return Expanded(
                  child: RefreshIndicator(
                      onRefresh: () async {
          // Clear all cached widgets when manually refreshing
          setState(() {
            _cachedSummarySection = null;
            _cachedActionButtons = null;
            _cachedEmptyState = null;
            _cachedActionButtonsKey = null;
            _cachedSummaryKey = null;
            _updatedTokens.clear();
          });
          
          // Fetch fresh data
          await ref.read(portfolioProvider).fetchHoldings(context, "Refresh");
          
          // Recalculate all summaries with the new data
          _calculateSummaryValues();
        },
        child: _buildHoldingsListView()
      )
    );
  }
  
  // Get a cached divider container based on theme
  Widget _getDividerContainer(bool isDarkMode) {
    if (isDarkMode) {
      _cachedDarkDivider ??= Container(
        color: const Color(0xffB5C0CF).withOpacity(.15),
        height: 6
      );
      return _cachedDarkDivider!;
    } else {
      _cachedLightDivider ??= Container(
        color: const Color(0xffF1F3F8),
        height: 6
      );
      return _cachedLightDivider!;
    }
  }

  // Holdings list view based on search state
  Widget _buildHoldingsListView() {
    final theme = ref.read(themeProvider);
    final isDarkMode = theme.isDarkMode;
    
    // Use a consumer to watch both the search state AND holdings data for API changes
    return Consumer(
      builder: (context, watch, _) {
        final portfolioData = ref.watch(portfolioProvider);
        
        // Watch both search state and actual holdings data
        final showSearch = portfolioData.showSearchHold;
        
        // Get the appropriate list based on search state - this will now update when holdings API updates
        final items = showSearch
            ? portfolioData.holdingSearchItem!
            : portfolioData.holdingsModel!;
            
        // This will rebuild if the entire holdings list is refreshed from API
        if (items.isEmpty) {
          if (_cachedEmptyState == null) {
            _cachedEmptyState = const SizedBox(
              height: 400,
              child: Center(child: NoDataFound()),
            );
          }
          return _cachedEmptyState!;
        }
        
        // Pre-cache the divider containers
        final divider = _getDividerContainer(isDarkMode);
        
        // Use a more efficient ListView with selective rebuilding
        // Wrap in RepaintBoundary to isolate the whole list
        return RepaintBoundary(
          child: ListView.builder(
            // Use a key that only changes when the list fundamentally changes
            key: ValueKey('holdings-list-${items.length}'),
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: false,
                                itemBuilder: (BuildContext context, int idx) {
                                  final index = idx ~/ 2;
                                  
              // Return cached divider for odd indices
                                  if (idx.isOdd) {
                return divider;
              }
    
              final holding = items[index];
              if (holding.exchTsym == null || holding.exchTsym!.isEmpty) {
                return const SizedBox.shrink();
              }
              
              final token = holding.exchTsym![0].token;
              final isUpdated = _updatedTokens.containsKey(token);
              
              // Use a consistent key that only changes when the data changes
              return _HoldingItemWrapper(
                key: ValueKey('holding-$token-$isUpdated'),
                holding: holding,
                theme: theme,
                onTap: () {},  // Empty function as navigation is now handled inside the wrapper
                onLongPress: () {}, // Empty function as it's handled inside the wrapper
              );
            },
            itemCount: items.length * 2 - 1,
                                ),
                              );
                            }
    );
  }
}

// A wrapper widget to isolate individual holding items for better performance
class _HoldingItemWrapper extends ConsumerStatefulWidget {
  final dynamic holding;
  final ThemesProvider theme;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HoldingItemWrapper({
    Key? key,
    required this.holding,
    required this.theme,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  ConsumerState<_HoldingItemWrapper> createState() => _HoldingItemWrapperState();
}

class _HoldingItemWrapperState extends ConsumerState<_HoldingItemWrapper> {
  // Add navigation lock to prevent multiple taps
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    // Use Builder to get a fresh context for each item
    return Builder(
      builder: (newContext) {
        // Prevent rebuilds of internal components by using RepaintBoundary
        return RepaintBoundary(
          child: InkWell(
            onTap: () async {
              // Prevent multiple navigation events on rapid taps
              if (_isNavigating) return;
              
              try {
                setState(() {
                  _isNavigating = true;
                });
                
                // Navigate to holding detail with fresh context
                await _navigateToDetail(newContext);
              } finally {
                // Reset navigation lock after some delay
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
            onLongPress: () {
              // Use the newer context from Builder to avoid deactivated widget issues
              // Navigator.pushNamed(newContext, Routes.holdingExit);
            },
            child: HoldingsList(
              holdingData: widget.holding,
              exchTsym: widget.holding.exchTsym[0],
            ),
          ),
        );
      }
    );
  }
  
  Future<void> _navigateToDetail(BuildContext context) async {
    final marketWatch = ref.read(marketWatchProvider);
    
    // Only load data if it's needed (check if current token is different)
    if (marketWatch.getQuotes?.token != widget.holding.exchTsym![0].token) {
      try {
        await marketWatch.fetchLinkeScrip(
          "${widget.holding.exchTsym![0].token}",
          "${widget.holding.exchTsym![0].exch}",
          context
        );
        
        if (!mounted) return;
        
        if (marketWatch.linkedScrips != null && marketWatch.linkedScrips!.stat == "Ok") {
          await marketWatch.fetchScripQuote(
            "${widget.holding.exchTsym![0].token}",
            "${widget.holding.exchTsym![0].exch}",
                                        context
          );

          if (!mounted) return;
          
          // Only fetch tech data for certain exchanges
          if (widget.holding.exchTsym![0].exch == "NSE" || widget.holding.exchTsym![0].exch == "BSE") {
            await ref.read(marketWatchProvider).fetchTechData(
                                                context: context,
              exch: "${widget.holding.exchTsym![0].exch}",
              tradeSym: "${widget.holding.exchTsym![0].tsym}",
              lastPrc: "${widget.holding.exchTsym![0].lp}"
            );
          }
        }
      } catch (e) {
        print("Error loading holding data: $e");
        // Continue with navigation even if data loading fails
      }
    }
    
    // Check if widget is still mounted before navigating
    if (!mounted) return;
    
    // Navigate to detail screen
                                    Navigator.pushNamed(
      context, 
      Routes.holdingDetail,
                                        arguments: {
        "holdingData": widget.holding,
        "exchTsym": widget.holding.exchTsym![0]
      }
    );
  }
}
