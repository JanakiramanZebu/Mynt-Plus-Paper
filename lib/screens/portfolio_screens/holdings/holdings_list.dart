import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/portfolio_model/holdings_model.dart';

import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';

// A wrapper widget that only rebuilds when necessary
class HoldingsList extends ConsumerStatefulWidget {
  final HoldingsModel holdingData;
  final ExchTsym exchTsym;

  const HoldingsList(
      {super.key, required this.holdingData, required this.exchTsym});

  @override
  ConsumerState<HoldingsList> createState() => _HoldingsListState();
}

class _HoldingsListState extends ConsumerState<HoldingsList> {
  // Use a cache to prevent unnecessary rebuilds
  static final Map<String, Widget> _staticComponentsCache = {};

  // Clear cache when theme changes to force rebuild of components
  static void clearAllCaches() {
    _staticComponentsCache.clear();
    _StaticQuantityInfo._styles.clear();
    _StaticInvestmentInfo._styles.clear();
    _DynamicLtpInfoState._styles.clear();
    _DynamicPercentChangeState._styles.clear();
    _DynamicPnlInfoState._styles.clear();
    _DynamicCurrentValueInfoState._styles.clear();
  }

  @override
  void initState() {
    super.initState();
    // Setup a listener for theme changes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We need to access the theme here to listen for changes
    ref.listenManual(themeProvider, (previous, next) {
      if (previous?.isDarkMode != next.isDarkMode) {
        // Clear the cache when theme changes
        _staticComponentsCache.clear();
        if (mounted) setState(() {});
      }
    });
  }

  // Get or create a cached static component
  Widget _getCachedStaticComponent(String key, Widget Function() builder) {
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
  Widget build(BuildContext context) {
    // Watch theme to rebuild when theme changes
    final theme = ref.watch(themeProvider);
    ref.listen(themeProvider, (previous, next) {
      if (previous?.isDarkMode != next.isDarkMode) {
        clearAllCaches();
      }
    });
    final contentColor =
        theme.isDarkMode ? colors.colorWhite : const Color(0xff666666);
    final labelColor = const Color(0xff666666);
    final dividerColor =
        theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider;

    // Add theme to keys to ensure components rebuild when theme changes
    final themeKey = theme.isDarkMode ? 'dark' : 'light';
    final symbolKey = 'symbol-${widget.exchTsym.tsym}-$themeKey';
    final exchangeKey = 'exch-${widget.exchTsym.exch}-$themeKey';
    final qtyKey =
        'qty-${widget.holdingData.currentQty}-${widget.holdingData.upldprc}-${widget.holdingData.npoadqty}-${widget.holdingData.btstqty}-$themeKey';
    final investKey =
        'invest-${widget.holdingData.invested}-${widget.exchTsym.close}-$themeKey';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Static header information (symbol name)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Symbol name - static
              _getCachedStaticComponent(
                symbolKey,
                () => TextWidget.subText(
                    text: "${widget.exchTsym.tsym}",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    color: const Color(0xff141414),
                    fw: 0),
              ),
              _DynamicPnlInfo(
                profitLoss: widget.exchTsym.profitNloss ?? '0.00',
                pnlChange: widget.exchTsym.pNlChng ?? '0.00',
              ),

              // LTP - dynamic, will update from socket
            ]),
            const SizedBox(height: 10),
            // Exchange badge (static) and price change (dynamic)
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   // Static exchange badge - won't rebuild
            //   // _getCachedStaticComponent(exchangeKey,
            //   //     () => CustomExchBadge(exch: "${widget.exchTsym.exch}")),
            //   // Dynamic percentage change
            // ]),
            // RepaintBoundary(child: Divider(color: dividerColor)),
            // Quantity info (static) and P&L (dynamic)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Static quantity information - use cached version
              Row(
                children: [
                  _getCachedStaticComponent(
                      qtyKey,
                      () => _StaticQuantityInfo(
                            holdingData: widget.holdingData,
                            exchTsym: widget.exchTsym,
                            labelColor: labelColor,
                            contentColor: contentColor,
                          )),
                  const SizedBox(width: 4),
                  _getCachedStaticComponent(
                    investKey,
                    () => _StaticPriceInfo(
                      holdingData: widget.holdingData,
                      exchTsym: widget.exchTsym,
                      labelColor: labelColor,
                      contentColor: contentColor,
                    ),
                  ),
                ],
              ),
              _DynamicLtpInfo(
                ltp: widget.exchTsym.lp ?? '0.00',
                labelColor: labelColor,
                contentColor: contentColor,
              ),
            ]),
            const SizedBox(height: 8),
            // Investment (static) and current value (dynamic)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Static investment information - use cached version
              _StaticInvestmentInfo(
                holdingData: widget.holdingData,
                exchTsym: widget.exchTsym,
                labelColor: labelColor,
                contentColor: contentColor,
              ),

              // Row(
              //   children: [
              //     _DynamicPercentChange(
              //       perChange: widget.exchTsym.perChange ?? '0.00',
              //     ),
              //   ],
              // )

              // Dynamic current value information
              _DynamicCurrentValueInfo(
                currentValue: widget.holdingData.currentValue ?? '0.00',
                labelColor: labelColor,
                contentColor: contentColor,
              )
            ])
          ])),
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
  static TextStyle _getStyle(
      Color color, double size, int? fw, String key, bool isDarkMode) {
    final styleKey = '${color.value}|$size|$fw|$isDarkMode';
    if (!_styles.containsKey(styleKey)) {
      _styles[styleKey] =
          TextWidget.textStyle(color: color, fontSize: size, theme: isDarkMode);
    }
    return _styles[styleKey]!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final theme = ref.watch(themeProvider);
      return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text("Qty ",
            style: _getStyle(labelColor, 12, 3, 'qty-label', theme.isDarkMode)),
        Text("${holdingData.currentQty ?? 0}",
            style:
                _getStyle(contentColor, 12, 3, 'qty-value', theme.isDarkMode)),
        // if (holdingData.npoadqty.toString() != "null") ...[
        //   Text(" NPQ",
        //       style: _getStyle(
        //           const Color(0xff666666), 12, 0, 'npq', theme.isDarkMode))
        // ],
        // if (holdingData.btstqty != "0")
        //   Text(" T1: {holdingData.btstqty}",
        //       style: _getStyle(
        //           const Color(0xff666666), 12, 0, 't1-qty', theme.isDarkMode))
      ]);
    });
  }
}

class _StaticPriceInfo extends StatelessWidget {
  final HoldingsModel holdingData;
  final ExchTsym exchTsym;
  final Color labelColor;
  final Color contentColor;

  // Cached text styles
  static final Map<String, TextStyle> _styles = {};

  const _StaticPriceInfo({
    Key? key,
    required this.holdingData,
    required this.exchTsym,
    required this.labelColor,
    required this.contentColor,
  }) : super(key: key);

  // Get or create a text style
  static TextStyle _getStyle(
      Color color, double size, int? fw, String key, bool isDarkMode) {
    final styleKey = '${color.value}|$size|$fw|$isDarkMode';
    if (!_styles.containsKey(styleKey)) {
      _styles[styleKey] = TextWidget.textStyle(
          color: color, fontSize: size, theme: isDarkMode, fw: fw);
    }
    return _styles[styleKey]!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final theme = ref.watch(themeProvider);
      return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text("Avg ",
            style: _getStyle(labelColor, 12, 3, 'qty-label', theme.isDarkMode)),
        Text("${holdingData.avgPrc}",
            style:
                _getStyle(contentColor, 12, 3, 'qty-value', theme.isDarkMode)),
      ]);
    });
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
  static TextStyle _getStyle(
      Color color, double size, int? fw, String key, bool isDarkMode) {
    final styleKey = '${color.value}|$size|$fw|$isDarkMode';
    if (!_styles.containsKey(styleKey)) {
      _styles[styleKey] =
          TextWidget.textStyle(color: color, fontSize: size, theme: isDarkMode);
    }
    return _styles[styleKey]!;
  }

  @override
  Widget build(BuildContext context) {
    final investedValue = double.parse(
        "${holdingData.invested ?? 0.00}");

    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(themeProvider);

        return Row(
          children: [
            Text(
              "Inv ",
              style:
                  _getStyle(labelColor, 12, 3, 'inv-label', theme.isDarkMode),
            ),
            Text(
              "${getFormatter(value: investedValue, v4d: false, noDecimal: false)}",
              style:
                  _getStyle(contentColor, 12, 3, 'inv-value', theme.isDarkMode),
            ),
          ],
        );
      },
    );
  }
}

// A widget that only displays and updates the LTP (Last Traded Price)
class _DynamicLtpInfo extends ConsumerStatefulWidget {
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
  ConsumerState<_DynamicLtpInfo> createState() => _DynamicLtpInfoState();
}

class _DynamicLtpInfoState extends ConsumerState<_DynamicLtpInfo> {
  late String _ltp;
  // FIX: Add StreamSubscription for direct socket updates
  StreamSubscription? _subscription;

  // Cached text styles
  static final Map<String, TextStyle> _styles = {};

  @override
  void initState() {
    super.initState();
    _ltp = widget.ltp;
    // FIX: Setup direct socket listener for this token
    _setupSocketListener();
  }

  // FIX: Add method to listen directly to socket updates
  void _setupSocketListener() {
    // Get token from parent chain (if available)
    final String? token = widget.key?.toString().split(':').firstOrNull;
    if (token == null || token.isEmpty) return;

    // Get socket provider using the ref from ConsumerStatefulWidget
    final websocket = ref.read(websocketProvider);

    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(token)) {
        final socketData = data[token];
        if (socketData != null) {
          final lp = socketData['lp']?.toString();
          if (lp != null && lp != "null" && lp != _ltp) {
            if (mounted) {
              setState(() {
                _ltp = lp;
              });
            }
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(_DynamicLtpInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ltp != widget.ltp) {
      _ltp = widget.ltp;
    }
    // Clear style cache when theme changes
    if (oldWidget.labelColor != widget.labelColor ||
        oldWidget.contentColor != widget.contentColor) {
      _styles.clear();
    }
  }

  @override
  void dispose() {
    // FIX: Clean up subscription
    _subscription?.cancel();
    // Avoid accessing anything from context in dispose
    super.dispose();
  }

  // Get or create a text style
  static TextStyle _getStyle(
      Color color, double size, int? fw, String key, bool isDarkMode) {
    final key = '${color.value}|$size|$fw|$isDarkMode';
    if (!_styles.containsKey(key)) {
      _styles[key] =
          TextWidget.textStyle(color: color, fontSize: size, theme: isDarkMode);
    }
    return _styles[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return RepaintBoundary(
      child: Row(children: [
        Text("LTP ",
            style: _getStyle(
                widget.labelColor, 12, 3, 'ltp-label', theme.isDarkMode)),
        Text("${_ltp}",
            style: _getStyle(
                widget.contentColor, 12, 3, 'ltp-value', theme.isDarkMode))
      ]),
    );
  }
}

// A widget that only displays and updates the price change percentage
class _DynamicPercentChange extends ConsumerStatefulWidget {
  final String perChange;

  const _DynamicPercentChange({
    Key? key,
    required this.perChange,
  }) : super(key: key);

  @override
  ConsumerState<_DynamicPercentChange> createState() =>
      _DynamicPercentChangeState();
}

class _DynamicPercentChangeState extends ConsumerState<_DynamicPercentChange> {
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
  static TextStyle _getStyle(
      Color color, double size, int? fw, bool isDarkMode) {
    final key = '${color.value}|$size|$fw|$isDarkMode';

    if (!_styles.containsKey(key)) {
      _styles[key] =
          TextWidget.textStyle(color: color, fontSize: size, theme: isDarkMode);
    }
    return _styles[key]!;
  }

  @override
  Widget build(BuildContext context) {
    // Use theme from ConsumerState
    final theme = ref.watch(themeProvider);

    final textColor = _perChange.startsWith("-")
        ? colors.darkred
        : _perChange == "0.00"
            ? colors.ltpgrey
            : colors.ltpgreen;

    return RepaintBoundary(
      child: Text(" (${_perChange}%)",
          style: _getStyle(textColor, 12, 0, theme.isDarkMode)),
    );
  }
}

// A widget that only displays and updates P&L information
class _DynamicPnlInfo extends ConsumerStatefulWidget {
  final String profitLoss;
  final String pnlChange;

  const _DynamicPnlInfo({
    Key? key,
    required this.profitLoss,
    required this.pnlChange,
  }) : super(key: key);

  @override
  ConsumerState<_DynamicPnlInfo> createState() => _DynamicPnlInfoState();
}

class _DynamicPnlInfoState extends ConsumerState<_DynamicPnlInfo> {
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
  static TextStyle _getStyle(
      Color color, double size, int? fw, bool isDarkMode) {
    final key = '${color.value}|$size|$fw|$isDarkMode';
    if (!_styles.containsKey(key)) {
      _styles[key] = TextWidget.textStyle(
          color: color, fontSize: size, theme: isDarkMode, fw: fw);
    }
    return _styles[key]!;
  }

  @override
  Widget build(BuildContext context) {
    // Use theme from ConsumerState for any theme-specific styling
    final theme = ref.watch(themeProvider);

    final pnlColor = _profitLoss.startsWith("-")
        ? colors.ltpred
        : _profitLoss == "0.00"
            ? colors.ltpgrey
            : colors.ltpgreen;

    final pnlChangeColor = _pnlChange.startsWith("-")
        ? colors.ltpred
        : _pnlChange == "NaN"
            ? colors.ltpred
            : colors.ltpgreen;

    return RepaintBoundary(
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text("${_profitLoss}",
            style: _getStyle(pnlColor, 16, 0, theme.isDarkMode)),
        Text(" (${_pnlChange == "NaN" ? 0.0 : _pnlChange}%)",
            style: _getStyle(pnlChangeColor, 12, 0, theme.isDarkMode))
      ]),
    );
  }
}

// A widget that only displays and updates current value information
class _DynamicCurrentValueInfo extends ConsumerStatefulWidget {
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
  ConsumerState<_DynamicCurrentValueInfo> createState() =>
      _DynamicCurrentValueInfoState();
}

class _DynamicCurrentValueInfoState
    extends ConsumerState<_DynamicCurrentValueInfo> {
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

    // Update colors if the theme changed
    if (oldWidget.contentColor != widget.contentColor ||
        oldWidget.labelColor != widget.labelColor) {
      // Colors changed, so we need to rebuild
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Avoid accessing anything from context in dispose
    super.dispose();
  }

  // Get or create a text style
  static TextStyle _getStyle(
      Color color, double size, int? fw, String key, bool isDarkMode) {
    final key = '${color.value}|$size|$fw|$isDarkMode';

    if (!_styles.containsKey(key)) {
      _styles[key] =
          TextWidget.textStyle(color: color, fontSize: size, theme: isDarkMode);
    }
    return _styles[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return RepaintBoundary(
      child: Row(children: [
        Text("Cur ",
            style: _getStyle(
                widget.labelColor, 12, 3, 'cur-label', theme.isDarkMode)),
        Text(
            "${getFormatter(value: double.parse(_currentValue), v4d: false, noDecimal: false)}",
            style: _getStyle(
                widget.contentColor, 12, 3, 'cur-value', theme.isDarkMode))
      ]),
    );
  }
}
