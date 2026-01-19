import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../../../utils/responsive_snackbar.dart';
import '../../../../models/order_book_model/order_book_model.dart';

class StocksScreenWeb extends ConsumerStatefulWidget {
  const StocksScreenWeb({super.key});

  @override
  ConsumerState<StocksScreenWeb> createState() => _StocksScreenWebState();
}

class _StocksScreenWebState extends ConsumerState<StocksScreenWeb> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final holdingProvide = ref.watch(portfolioProvider).holdingsModel;
      final marketWatch = ref.watch(marketWatchProvider);
      final theme = ref.watch(themeProvider);

      if (ref.watch(portfolioProvider).loading) {
        return Center(
          child: CircularProgressIndicator(
            color: resolveThemeColor(context,
                dark: MyntColors.primary, light: MyntColors.primary),
          ),
        );
      }

      if (holdingProvide == null || holdingProvide.isEmpty) {
        return Container(
          color: shadcn.Theme.of(context).colorScheme.background,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "No Holdings",
                  style: MyntWebTextStyles.title(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 300,
                  child: Text(
                    "You haven't made any investments yet. Build your portfolio today!",
                    textAlign: TextAlign.center,
                    style: MyntWebTextStyles.para(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        color: shadcn.Theme.of(context).colorScheme.background,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: holdingProvide.length,
          padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
          separatorBuilder: (_, __) => const ListDivider(),
          itemBuilder: (BuildContext context, int index) {
            return RepaintBoundary(
              child: _HoldingsCardWeb(
                holding: holdingProvide[index],
                index: index,
                hoveredIndex: hoveredIndex,
                onHover: (int? idx) => setState(() => hoveredIndex = idx),
                marketWatch: marketWatch,
                theme: theme,
              ),
            );
          },
        ),
      );
    });
  }
}

class _HoldingsCardWeb extends ConsumerStatefulWidget {
  final dynamic holding;
  final int index;
  final int? hoveredIndex;
  final Function(int?) onHover;
  final MarketWatchProvider marketWatch;
  final ThemesProvider theme;

  const _HoldingsCardWeb({
    required this.holding,
    required this.index,
    required this.hoveredIndex,
    required this.onHover,
    required this.marketWatch,
    required this.theme,
  });

  @override
  ConsumerState<_HoldingsCardWeb> createState() => _HoldingsCardWebState();
}

class _HoldingsCardWebState extends ConsumerState<_HoldingsCardWeb> {
  bool _isHovered = false;
  bool _isNavigating = false;

  String get _token => widget.holding.exchTsym?[0].token?.toString() ?? "";
  String get _exch => widget.holding.exchTsym?[0].exch?.toString() ?? "";
  String get _tsym => widget.holding.exchTsym?[0].tsym?.toString() ?? "";
  String get _symbol => widget.holding.exchTsym?[0].symbol?.toString() ?? "";
  String get _option => widget.holding.exchTsym?[0].option?.toString() ?? "";
  String get _expDate => widget.holding.exchTsym?[0].expDate?.toString() ?? "";
  String get _currentQty => widget.holding.currentQty?.toString() ?? "0";

  @override
  Widget build(BuildContext context) {
    final isHovered = widget.hoveredIndex == widget.index || _isHovered;

    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};

        if (socketDatas.containsKey(_token)) {
          final socketData = socketDatas[_token];
          final lp = socketData['lp']?.toString();
          if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
            widget.holding.exchTsym![0].lp = lp;
          }
          final chng = socketData['chng']?.toString();
          if (chng != null && chng != "null") {
            widget.holding.exchTsym![0].change = chng;
          }
          final pc = socketData['pc']?.toString();
          if (pc != null && pc != "null") {
            widget.holding.exchTsym![0].perChange = pc;
          }
        }

        return MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            widget.onHover(widget.index);
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            widget.onHover(null);
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: widget.theme.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              highlightColor: widget.theme.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              onTap: () async {
                if (_isNavigating) return;
                try {
                  setState(() => _isNavigating = true);
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    ref.read(marketWatchProvider).setIsDepthVisibleWeb(false);

                    DepthInputArgs depthArgs = DepthInputArgs(
                      exch: _exch,
                      token: _token,
                      tsym: _tsym,
                      instname: _symbol,
                      symbol: _symbol,
                      expDate: _expDate,
                      option: _option,
                    );

                    widget.marketWatch.scripdepthsize(false);
                    await widget.marketWatch
                        .calldepthApis(context, depthArgs, "");
                  });
                } catch (e) {
                  debugPrint('Error opening chart: $e');
                } finally {
                  if (mounted) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() => _isNavigating = false);
                      }
                    });
                  }
                }
              },
              child: Container(
                color: isHovered
                    ? MyntColors.primary.withOpacity(0.10)
                    : shadcn.Theme.of(context).colorScheme.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row: Symbol name | LTP
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Symbol name and option
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _symbol.replaceAll("-EQ", "").toUpperCase(),
                                style: MyntWebTextStyles.symbol(
                                  context,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                                ),
                              ),
                              if (_option.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    _option,
                                    style: MyntWebTextStyles.symbol(
                                      context,
                                      color: resolveThemeColor(context,
                                          dark: MyntColors.textPrimaryDark,
                                          light: MyntColors.textPrimary),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Right: LTP only
                        RepaintBoundary(
                          child: _LTPWidgetWeb(
                            token: _token,
                            initialData: {
                              'ltp': widget.holding.exchTsym?[0].lp ?? '0.00',
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Second row: Exchange | Action buttons | Price Change
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Exchange info
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_exch ',
                              style: MyntWebTextStyles.exch(
                                context,
                                fontWeight: FontWeight.w500,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                              ),
                            ),
                            if (_expDate.isNotEmpty)
                              Text(
                                _expDate,
                                style: MyntWebTextStyles.exch(
                                  context,
                                  fontWeight: FontWeight.w500,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                                ),
                              ),
                            if (_currentQty != "0" &&
                                _currentQty.isNotEmpty) ...[
                              SvgPicture.asset(
                                assets.suitcase,
                                height: 14,
                                width: 18,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.iconDark,
                                    light: MyntColors.icon),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentQty,
                                style: MyntWebTextStyles.exch(
                                  context,
                                  fontWeight: FontWeight.w500,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textSecondaryDark,
                                      light: MyntColors.textSecondary),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Left spacer to push buttons toward center
                        Expanded(
                          child: Container(),
                        ),
                        // Fixed-width container for action buttons (centered in available space)
                        AnimatedOpacity(
                          opacity: isHovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          child: IgnorePointer(
                            ignoring: !isHovered,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHoverButton(
                                  label: 'B',
                                  color: Colors.white,
                                  backgroundColor: resolveThemeColor(context,
                                      dark: MyntColors.primary,
                                      light: MyntColors.primary),
                                  onPressed: () async {
                                    try {
                                      await _placeOrderInput(context, true);
                                    } catch (e) {
                                      debugPrint('Buy button error: $e');
                                    }
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildHoverButton(
                                  label: 'S',
                                  color: Colors.white,
                                  backgroundColor: resolveThemeColor(context,
                                      dark: MyntColors.tertiary,
                                      light: MyntColors.tertiary),
                                  onPressed: () async {
                                    try {
                                      await _placeOrderInput(context, false);
                                    } catch (e) {
                                      debugPrint('Sell button error: $e');
                                    }
                                  },
                                ),
                                const SizedBox(width: 4),
                                _buildHoverButton(
                                  iconAsset: assets.depthIcon,
                                  color: Colors.black,
                                  backgroundColor: Colors.white,
                                  borderColor: resolveThemeColor(context,
                                      dark: MyntColors.dividerDark,
                                      light: MyntColors.divider),
                                  borderRadius: 5.0,
                                  onPressed: () async {
                                    if (_isNavigating) return;
                                    try {
                                      setState(() => _isNavigating = true);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) async {
                                        ref
                                            .read(marketWatchProvider)
                                            .setIsDepthVisibleWeb(true);

                                        DepthInputArgs depthArgs =
                                            DepthInputArgs(
                                          exch: _exch,
                                          token: _token,
                                          tsym: _tsym,
                                          instname: _symbol,
                                          symbol: _symbol,
                                          expDate: _expDate,
                                          option: _option,
                                        );

                                        widget.marketWatch
                                            .scripdepthsize(false);
                                        await widget.marketWatch.calldepthApis(
                                            context, depthArgs, "");
                                      });
                                    } catch (e) {
                                      debugPrint('Error opening chart: $e');
                                    } finally {
                                      if (mounted) {
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                          if (mounted) {
                                            setState(
                                                () => _isNavigating = false);
                                          }
                                        });
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right spacer to push price change to right
                        Expanded(
                          child: Container(),
                        ),
                        // Right: Price change only
                        RepaintBoundary(
                          child: _PriceChangeWidgetWeb(
                            token: _token,
                            initialData: {
                              'change':
                                  widget.holding.exchTsym?[0].change ?? '0.00',
                              'perChange':
                                  widget.holding.exchTsym?[0].perChange ??
                                      '0.00',
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoverButton({
    String? label,
    String? iconAsset,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    required VoidCallback? onPressed,
  }) {
    final borderRadiusValue = borderRadius ?? 5.0;
    return SizedBox(
      width: 24,
      height: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: iconAsset != null
                  ? SvgPicture.asset(
                      iconAsset,
                      width: 13,
                      height: 13,
                      colorFilter: ColorFilter.mode(
                        color,
                        BlendMode.srcIn,
                      ),
                    )
                  : Text(
                      label ?? "",
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrderInput(BuildContext ctx, bool transType) async {
    try {
      if (_isNavigating) return;

      setState(() => _isNavigating = true);

      print('==================== PLACE ORDER DEBUG ====================');
      print('Symbol: $_tsym | Token: $_token | Exchange: $_exch');
      print('Transaction Type: ${transType ? "BUY" : "SELL"}');

      // Fetch scrip info first
      await ref
          .read(marketWatchProvider)
          .fetchScripInfo(_token, _exch, context, true);
      await ref
          .read(marketWatchProvider)
          .fetchScripQuote(_token, _exch, context);

      // Ensure scripInfo is loaded
      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        throw Exception('Failed to load scrip information');
      }

      // Get fresh quote data
      final freshQuoteData = ref.read(marketWatchProvider).getQuotes;
      print(
          'Fresh Quote Data: lp=${freshQuoteData?.lp ?? "NULL"}, c=${freshQuoteData?.c ?? "NULL"}, pc=${freshQuoteData?.pc ?? "NULL"}');

      // Also check websocket data for the current token
      final wsProvider = ref.read(websocketProvider);
      final socketData = wsProvider.socketDatas[_token];
      print(
          'Websocket Data: ${socketData != null ? "lp=${socketData['lp']}, pc=${socketData['pc']}" : "NO WEBSOCKET DATA"}');

      // Priority: Websocket data > Fresh quote data > Holding data
      String? ltp;
      String? perChange;

      bool isValidPrice(String? value) {
        if (value == null || value.isEmpty) return false;
        final normalized = value.trim();
        return normalized != '0' &&
            normalized != '0.0' &&
            normalized != '0.00' &&
            normalized != 'null' &&
            normalized != 'NaN' &&
            normalized != 'Infinity';
      }

      // Try websocket data first
      if (socketData != null) {
        final wsLtp = socketData['lp']?.toString();
        final wsPc = socketData['pc']?.toString();
        if (isValidPrice(wsLtp)) {
          ltp = wsLtp;
          perChange = wsPc;
          print('✓ Using WEBSOCKET data: ltp=$ltp');
        } else {
          print('✗ Websocket data invalid: ltp=$wsLtp');
        }
      } else {
        print('✗ No websocket data available');
      }

      // Fallback to fresh quote data
      if (!isValidPrice(ltp) && freshQuoteData != null) {
        final quoteLtp = freshQuoteData.lp ?? freshQuoteData.c;
        if (isValidPrice(quoteLtp)) {
          ltp = quoteLtp;
          perChange = freshQuoteData.pc;
          print('✓ Using QUOTE data: ltp=$ltp');
        } else {
          print('✗ Quote data invalid: ltp=$quoteLtp');
        }
      }

      // Fallback to holding data
      if (!isValidPrice(ltp)) {
        final holdingLtp = widget.holding.exchTsym?[0].lp?.toString();
        if (isValidPrice(holdingLtp)) {
          ltp = holdingLtp;
          perChange = widget.holding.exchTsym?[0].perChange?.toString();
          print('✓ Using HOLDING data: ltp=$ltp');
        } else {
          print('✗ Holding data invalid: ltp=$holdingLtp');
        }
      }

      print('Holding Data Raw: ${widget.holding.exchTsym?[0].lp}');

      // Use lot size from scripInfo or quote data
      final lotSize = _safeParseLotSize(scripInfo.ls, freshQuoteData?.ls, "1");

      // Use safe parsing for price values
      final safeLtp = _safeParseNumeric(ltp, "0.00");
      final safePerChange = _safeParseNumeric(perChange, "0.00");

      print('Final Values: safeLtp=$safeLtp, safePerChange=$safePerChange');
      print('===========================================================');

      // If we still don't have valid LTP data after all fallbacks, show error
      if (safeLtp == "0.00" || safeLtp.isEmpty) {
        print('⚠️ ERROR: No valid price data - blocking order screen');
        if (mounted) {
          ResponsiveSnackBar.showError(
            context,
            'Price data not available yet. Please wait a moment and try again.',
          );
        }
        return;
      }

      print('✓ Opening order screen with LTP: $safeLtp');

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: _exch,
        tSym: _tsym,
        isExit: false,
        token: _token,
        transType: transType,
        lotSize: lotSize,
        ltp: safeLtp,
        perChange: safePerChange,
        orderTpye: '',
        holdQty: _currentQty,
        isModify: false,
        raw: {},
      );

      // Add small delay to ensure state is properly set
      await Future.delayed(const Duration(milliseconds: 150));

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": ""
        },
      );
    } catch (e) {
      debugPrint('Place order error: $e');
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Error placing order: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _isNavigating = false);
          }
        });
      }
    }
  }

  String _safeParseNumeric(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    String stringValue = value.toString().trim();
    if (stringValue.isEmpty ||
        stringValue == 'null' ||
        stringValue == '0.0' ||
        stringValue == '0' ||
        stringValue == 'NaN' ||
        stringValue == 'Infinity') {
      return defaultValue;
    }
    try {
      double.parse(stringValue);
      return stringValue;
    } catch (e) {
      try {
        int.parse(stringValue);
        return stringValue;
      } catch (e) {
        return defaultValue;
      }
    }
  }

  String _safeParseLotSize(
      dynamic scripInfoLs, dynamic depthDataLs, String defaultValue) {
    String scripInfoValue = _safeParseNumeric(scripInfoLs, "");
    if (scripInfoValue.isNotEmpty && scripInfoValue != defaultValue) {
      return scripInfoValue;
    }
    String depthDataValue = _safeParseNumeric(depthDataLs, "");
    if (depthDataValue.isNotEmpty && depthDataValue != defaultValue) {
      return depthDataValue;
    }
    return defaultValue;
  }
}

// Widget for LTP only (used in first row)
class _LTPWidgetWeb extends ConsumerStatefulWidget {
  final String token;
  final Map<String, dynamic> initialData;

  const _LTPWidgetWeb({
    required this.token,
    required this.initialData,
  });

  @override
  ConsumerState<_LTPWidgetWeb> createState() => _LTPWidgetWebState();
}

class _LTPWidgetWebState extends ConsumerState<_LTPWidgetWeb> {
  late String ltp;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialData['ltp']?.toString() ?? '0.00';

    // Pre-load from current socket data if available
    final socketData = ref.read(websocketProvider).socketDatas[widget.token];
    if (socketData != null) {
      ltp = socketData['lp']?.toString() ?? ltp;
    }

    _setupSubscription();
  }

  void _setupSubscription() {
    _subscription =
        ref.read(websocketProvider).socketDataStream.listen((rawData) {
      if (!mounted) return;

      final data = Map<String, dynamic>.from(rawData as Map? ?? {});
      if (!data.containsKey(widget.token)) return;

      final rawNewData = data[widget.token];
      if (rawNewData == null) return;

      final newData = Map<String, dynamic>.from(rawNewData as Map);
      final newLtp = newData['lp']?.toString();

      if (newLtp != null &&
          newLtp != ltp &&
          newLtp != '0.00' &&
          newLtp != '0.0' &&
          newLtp != 'null') {
        setState(() {
          ltp = newLtp;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

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
    final displayLtp = _safeFormatPrice(ltp);

    final changeColor = displayLtp.startsWith("-") || displayLtp.startsWith('-')
        ? resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss)
        : (displayLtp == "0.00" || displayLtp == "0.00")
            ? resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary)
            : resolveThemeColor(context,
                dark: MyntColors.profitDark, light: MyntColors.profit);
    return Text(
      displayLtp,
      style: MyntWebTextStyles.price(
        context,
        color: changeColor,
      ),
    );
  }
}

// Widget for Price Change only (used in second row)
class _PriceChangeWidgetWeb extends ConsumerStatefulWidget {
  final String token;
  final Map<String, dynamic> initialData;

  const _PriceChangeWidgetWeb({
    required this.token,
    required this.initialData,
  });

  @override
  ConsumerState<_PriceChangeWidgetWeb> createState() =>
      _PriceChangeWidgetWebState();
}

class _PriceChangeWidgetWebState extends ConsumerState<_PriceChangeWidgetWeb> {
  late String change;
  late String perChange;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    change = widget.initialData['change']?.toString() ?? '0.00';
    perChange = widget.initialData['perChange']?.toString() ?? '0.00';

    // Pre-load from current socket data if available
    final socketData = ref.read(websocketProvider).socketDatas[widget.token];
    if (socketData != null) {
      change = socketData['chng']?.toString() ?? change;
      perChange = socketData['pc']?.toString() ?? perChange;
    }

    _setupSubscription();
  }

  void _setupSubscription() {
    _subscription =
        ref.read(websocketProvider).socketDataStream.listen((rawData) {
      if (!mounted) return;

      final data = Map<String, dynamic>.from(rawData as Map? ?? {});
      if (!data.containsKey(widget.token)) return;

      final rawNewData = data[widget.token];
      if (rawNewData == null) return;

      final newData = Map<String, dynamic>.from(rawNewData as Map);
      bool valueChanged = false;

      final newChange = newData['chng']?.toString();
      final newPerChange = newData['pc']?.toString();

      if (newChange != null &&
          newChange != change &&
          newChange != '0.0' &&
          newChange != 'null') {
        change = newChange;
        valueChanged = true;
      }

      if (newPerChange != null &&
          newPerChange != perChange &&
          newPerChange != '0.0' &&
          newPerChange != 'null') {
        perChange = newPerChange;
        valueChanged = true;
      }

      if (valueChanged && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

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
    final displayChange = _safeFormatPrice(change);
    final displayPerChange = _safeFormatPrice(perChange);

    return Text(
      "$displayChange ($displayPerChange%)",
      style: MyntWebTextStyles.priceChange(
        context,
        fontWeight: FontWeight.w500,
        color: resolveThemeColor(context,
            dark: MyntColors.textSecondaryDark,
            light: MyntColors.textSecondary),
      ),
    );
  }
}
