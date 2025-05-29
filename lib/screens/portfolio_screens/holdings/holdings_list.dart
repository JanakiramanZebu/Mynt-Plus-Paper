import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/portfolio_model/holdings_model.dart';

import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';

// A wrapper widget that only rebuilds when necessary
class HoldingsList extends ConsumerWidget {
  final HoldingsModel holdingData;
  final ExchTsym exchTsym;
  
  // Use a cache to prevent unnecessary rebuilds
  static final Map<String, Widget> _staticComponentsCache = {};
  
  const HoldingsList({
    super.key, 
    required this.holdingData, 
    required this.exchTsym
  });

  // Get or create a cached static component
  static Widget _getCachedStaticComponent(String key, Widget Function() builder) {
    if (!_staticComponentsCache.containsKey(key)) {
      _staticComponentsCache[key] = builder();
      
      // Limit cache size
      if (_staticComponentsCache.length > 200) {
        final firstKey = _staticComponentsCache.keys.first;
        _staticComponentsCache.remove(firstKey);
      }
    }
    
    return _staticComponentsCache[key]!;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-calculate values that won't change during widget lifetime
    final theme = ref.read(themeProvider);
    final contentColor = theme.isDarkMode ? colors.colorWhite : colors.colorBlack;
    final labelColor = const Color(0xff5E6B7D);
    final dividerColor = theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider;
    
    // Create keys for static components
    final symbolKey = 'symbol-${exchTsym.tsym}';
    final exchangeKey = 'exch-${exchTsym.exch}';
    final qtyKey = 'qty-${holdingData.currentQty}-${holdingData.upldprc}-${holdingData.npoadqty}-${holdingData.btstqty}';
    final investKey = 'invest-${holdingData.invested}-${exchTsym.close}';
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Static header information (symbol name)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              // Symbol name - static
              _getCachedStaticComponent(
                symbolKey,
                () => Text(
                  "${exchTsym.tsym} ",
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.scripNameTxtStyle.copyWith(
                    color: contentColor
                  )
                )
              ),
              // LTP - dynamic, will update from socket
              _DynamicLtpInfo(
                ltp: exchTsym.lp ?? '0.00',
                labelColor: labelColor,
                contentColor: contentColor,
                  )
                ]
              ),
              const SizedBox(height: 4),
          // Exchange badge (static) and price change (dynamic)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              // Static exchange badge - won't rebuild
              _getCachedStaticComponent(
                exchangeKey,
                () => CustomExchBadge(exch: "${exchTsym.exch}")
              ),
              // Dynamic percentage change
              _DynamicPercentChange(
                perChange: exchTsym.perChange ?? '0.00',
              )
                ]
              ),
              const SizedBox(height: 4),
          RepaintBoundary(child: Divider(color: dividerColor)),
              const SizedBox(height: 3),
          // Quantity info (static) and P&L (dynamic)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              // Static quantity information - use cached version
              _getCachedStaticComponent(
                qtyKey,
                () => _StaticQuantityInfo(
                  holdingData: holdingData,
                  exchTsym: exchTsym,
                  labelColor: labelColor,
                  contentColor: contentColor,
                )
              ),
              // Dynamic P&L information
              _DynamicPnlInfo(
                profitLoss: exchTsym.profitNloss ?? '0.00',
                pnlChange: exchTsym.pNlChng ?? '0.00',
                  )
                ]
              ),
              const SizedBox(height: 10),
          // Investment (static) and current value (dynamic)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              // Static investment information - use cached version
              _getCachedStaticComponent(
                investKey,
                () => _StaticInvestmentInfo(
                  holdingData: holdingData,
                  exchTsym: exchTsym,
                  labelColor: labelColor,
                  contentColor: contentColor,
                )
              ),
              // Dynamic current value information
              _DynamicCurrentValueInfo(
                currentValue: holdingData.currentValue ?? '0.00',
                labelColor: labelColor,
                contentColor: contentColor,
                  )
                ]
              )
            ]
          )
        );
      }
}

// A widget that only contains static quantity information
class _StaticQuantityInfo extends StatelessWidget {
  final HoldingsModel holdingData;
  final ExchTsym exchTsym;
  final Color labelColor;
  final Color contentColor;
  
  // Cached text styles
  static final Map<String, TextStyle> _styles = {};
  
  const _StaticQuantityInfo({
    Key? key, 
    required this.holdingData, 
    required this.exchTsym,
    required this.labelColor,
    required this.contentColor,
  }) : super(key: key);
  
  // Get or create a text style
  static TextStyle _getStyle(Color color, double size, FontWeight weight, String key) {
    if (!_styles.containsKey(key)) {
      _styles[key] = TextStyle(fontWeight: weight, color: color, fontSize: size);
    }
    return _styles[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Qty: ",
          style: _getStyle(labelColor, 14, FontWeight.w500, 'qty-label')
        ),
        Text(
          "${holdingData.currentQty ?? 0} @ ₹${holdingData.upldprc ?? exchTsym.close ?? 0.00}",
          style: _getStyle(contentColor, 14, FontWeight.w500, 'qty-value')
        ),
        if (holdingData.npoadqty.toString() != "null") ...[
          Text(
            " NPQ",
            style: _getStyle(const Color(0xff666666), 12, FontWeight.w500, 'npq')
          )
        ],
        if (holdingData.btstqty != "0") 
          Text(
            " T1: ${holdingData.btstqty}",
            style: _getStyle(const Color(0xff666666), 12, FontWeight.w500, 't1-qty')
          )
      ]
    );
  }
}

// A widget that only contains static investment information
class _StaticInvestmentInfo extends StatelessWidget {
  final HoldingsModel holdingData;
  final ExchTsym exchTsym;
  final Color labelColor;
  final Color contentColor;
  
  // Cached text styles
  static final Map<String, TextStyle> _styles = {};
  
  const _StaticInvestmentInfo({
    Key? key, 
    required this.holdingData, 
    required this.exchTsym,
    required this.labelColor,
    required this.contentColor,
  }) : super(key: key);
  
  // Get or create a text style
  static TextStyle _getStyle(Color color, double size, FontWeight weight, String key) {
    if (!_styles.containsKey(key)) {
      _styles[key] = TextStyle(fontWeight: weight, color: color, fontSize: size);
    }
    return _styles[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    final investedValue = double.parse(
      "${holdingData.invested == "0.00" 
        ? exchTsym.close ?? 0.00 
        : holdingData.invested ?? 0.00}"
    );
    
    return Row(
      children: [
        Text(
          "Inv: ",
          style: _getStyle(labelColor, 14, FontWeight.w500, 'inv-label')
        ),
        Text(
          "₹${getFormatter(value: investedValue, v4d: false, noDecimal: false)}",
          style: _getStyle(contentColor, 14, FontWeight.w500, 'inv-value')
        )
      ]
    );
  }
}

// A widget that only displays and updates the LTP (Last Traded Price)
class _DynamicLtpInfo extends StatefulWidget {
  final String ltp;
  final Color labelColor;
  final Color contentColor;
  
  const _DynamicLtpInfo({
    Key? key,
    required this.ltp,
    required this.labelColor,
    required this.contentColor,
  }) : super(key: key);
  
  @override
  _DynamicLtpInfoState createState() => _DynamicLtpInfoState();
}

class _DynamicLtpInfoState extends State<_DynamicLtpInfo> {
  late String _ltp;
  
  // Cached text styles
  static final Map<String, TextStyle> _styles = {};
  
  @override
  void initState() {
    super.initState();
    _ltp = widget.ltp;
  }
  
  @override
  void didUpdateWidget(_DynamicLtpInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ltp != widget.ltp) {
      _ltp = widget.ltp;
    }
  }
  
  @override
  void dispose() {
    // Avoid accessing anything from context in dispose
    super.dispose();
  }
  
  // Get or create a text style
  static TextStyle _getStyle(Color color, double size, FontWeight weight, String key) {
    if (!_styles.containsKey(key)) {
      _styles[key] = TextStyle(fontWeight: weight, color: color, fontSize: size);
    }
    return _styles[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        children: [
          Text(
            " LTP: ",
            style: _getStyle(widget.labelColor, 13, FontWeight.w600, 'ltp-label')
          ),
          Text(
            "₹${_ltp}",
            style: _getStyle(widget.contentColor, 14, FontWeight.w500, 'ltp-value')
          )
        ]
      ),
    );
  }
}

// A widget that only displays and updates the price change percentage
class _DynamicPercentChange extends StatefulWidget {
  final String perChange;
  
  const _DynamicPercentChange({
    Key? key,
    required this.perChange,
  }) : super(key: key);
  
  @override
  _DynamicPercentChangeState createState() => _DynamicPercentChangeState();
}

class _DynamicPercentChangeState extends State<_DynamicPercentChange> {
  late String _perChange;
  
  // Cached text styles
  static final Map<String, TextStyle> _styles = {};
  
  @override
  void initState() {
    super.initState();
    _perChange = widget.perChange;
  }
  
  @override
  void didUpdateWidget(_DynamicPercentChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perChange != widget.perChange) {
      _perChange = widget.perChange;
    }
  }
  
  @override
  void dispose() {
    // Avoid accessing anything from context in dispose
    super.dispose();
  }
  
  // Get or create a text style
  static TextStyle _getStyle(Color color, double size, FontWeight weight) {
    final key = '${color.value}|$size|${weight.index}';
    if (!_styles.containsKey(key)) {
      _styles[key] = TextStyle(fontWeight: weight, color: color, fontSize: size);
    }
    return _styles[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    final textColor = _perChange.startsWith("-")
      ? colors.darkred
      : _perChange == "0.00"
        ? colors.ltpgrey
        : colors.ltpgreen;
        
    return RepaintBoundary(
      child: Text(
        " (${_perChange}%)",
        style: _getStyle(textColor, 12, FontWeight.w500)
      ),
    );
  }
}

// A widget that only displays and updates P&L information
class _DynamicPnlInfo extends StatefulWidget {
  final String profitLoss;
  final String pnlChange;
  
  const _DynamicPnlInfo({
    Key? key,
    required this.profitLoss,
    required this.pnlChange,
  }) : super(key: key);
  
  @override
  _DynamicPnlInfoState createState() => _DynamicPnlInfoState();
}

class _DynamicPnlInfoState extends State<_DynamicPnlInfo> {
  late String _profitLoss;
  late String _pnlChange;
  
  // Cached text styles
  static final Map<String, TextStyle> _styles = {};
  
  @override
  void initState() {
    super.initState();
    _profitLoss = widget.profitLoss;
    _pnlChange = widget.pnlChange;
  }
  
  @override
  void didUpdateWidget(_DynamicPnlInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profitLoss != widget.profitLoss) {
      _profitLoss = widget.profitLoss;
    }
    if (oldWidget.pnlChange != widget.pnlChange) {
      _pnlChange = widget.pnlChange;
    }
  }
  
  @override
  void dispose() {
    // Avoid accessing anything from context in dispose
    super.dispose();
  }
  
  // Get or create a text style
  static TextStyle _getStyle(Color color, double size, FontWeight weight) {
    final key = '${color.value}|$size|${weight.index}';
    if (!_styles.containsKey(key)) {
      _styles[key] = TextStyle(fontWeight: weight, color: color, fontSize: size);
    }
    return _styles[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    final pnlColor = _profitLoss.startsWith("-") 
      ? colors.darkred 
      : _profitLoss == "0.00" ? colors.ltpgrey : colors.ltpgreen;
      
    final pnlChangeColor = _pnlChange.startsWith("-") 
      ? colors.darkred 
      : _pnlChange == "NaN" ? colors.darkred : colors.ltpgreen;
    
    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "₹${_profitLoss}",
            style: _getStyle(pnlColor, 14, FontWeight.w500)
          ),
          Text(
            " (${_pnlChange == "NaN" ? 0.0 : _pnlChange}%)",
            style: _getStyle(pnlChangeColor, 12, FontWeight.w500)
          )
        ]
      ),
    );
  }
}

// A widget that only displays and updates current value information
class _DynamicCurrentValueInfo extends StatefulWidget {
  final String currentValue;
  final Color labelColor;
  final Color contentColor;
  
  const _DynamicCurrentValueInfo({
    Key? key,
    required this.currentValue,
    required this.labelColor,
    required this.contentColor,
  }) : super(key: key);
  
  @override
  _DynamicCurrentValueInfoState createState() => _DynamicCurrentValueInfoState();
}

class _DynamicCurrentValueInfoState extends State<_DynamicCurrentValueInfo> {
  late String _currentValue;
  
  // Cached text styles
  static final Map<String, TextStyle> _styles = {};
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;
  }
  
  @override
  void didUpdateWidget(_DynamicCurrentValueInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _currentValue = widget.currentValue;
    }
  }
  
  @override
  void dispose() {
    // Avoid accessing anything from context in dispose
    super.dispose();
  }
  
  // Get or create a text style
  static TextStyle _getStyle(Color color, double size, FontWeight weight, String key) {
    if (!_styles.containsKey(key)) {
      _styles[key] = TextStyle(fontWeight: weight, color: color, fontSize: size);
    }
    return _styles[key]!;
  }
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        children: [
          Text(
            "Cur: ",
            style: _getStyle(widget.labelColor, 14, FontWeight.w500, 'cur-label')
          ),
          Text(
            "₹${getFormatter(
              value: double.parse(_currentValue), 
              v4d: false, 
              noDecimal: false
            )}",
            style: _getStyle(widget.contentColor, 14, FontWeight.w500, 'cur-value')
          )
        ]
      ),
    );
  }
}
