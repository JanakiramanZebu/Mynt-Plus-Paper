import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../models/marketwatch_model/get_quotes.dart';

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../utils/responsive_navigation.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../../../sharedWidget/snack_bar.dart';
import 'convert_position_dialogue_web.dart';
import '../../../main.dart';

class PositionDetailScreenWeb extends ConsumerStatefulWidget {
  final PositionBookModel positionList;
  final BuildContext? parentContext;

  const PositionDetailScreenWeb({
    super.key,
    required this.positionList,
    this.parentContext,
  });

  @override
  ConsumerState<PositionDetailScreenWeb> createState() =>
      _PositionDetailScreenWebState();
}

class _PositionDetailScreenWebState
    extends ConsumerState<PositionDetailScreenWeb> {
  StreamSubscription? _socketSubscription;
  late PositionBookModel _positionData;

  @override
  void initState() {
    super.initState();
    // Make a copy of the position data to avoid modifying the original
    _positionData = _copyPosition(widget.positionList);
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  // Create a copy of the position to avoid modifying the original
  PositionBookModel _copyPosition(PositionBookModel original) {
    final copy = PositionBookModel();
    copy.token = original.token;
    copy.exch = original.exch;
    copy.tsym = original.tsym;
    copy.symbol = original.symbol;
    copy.expDate = original.expDate;
    copy.option = original.option;
    copy.lp = original.lp;
    copy.perChange = original.perChange;
    copy.chng = original.chng;
    copy.netqty = original.netqty;
    copy.avgPrc = original.avgPrc;
    copy.netupldprc = original.netupldprc;
    copy.upldprc = original.upldprc;
    copy.sPrdtAli = original.sPrdtAli;
    copy.profitNloss = original.profitNloss;
    copy.mTm = original.mTm;
    copy.rpnl = original.rpnl;
    copy.daybuyqty = original.daybuyqty;
    copy.daysellqty = original.daysellqty;
    copy.cfbuyqty = original.cfbuyqty;
    copy.cfsellqty = original.cfsellqty;
    copy.daybuyavgprc = original.daybuyavgprc;
    copy.daysellavgprc = original.daysellavgprc;
    copy.cfbuyavgprc = original.cfbuyavgprc;
    copy.cfsellavgprc = original.cfsellavgprc;
    copy.qty = original.qty;
    copy.prd = original.prd;
    copy.ls = original.ls;
    return copy;
  }

  // Pre-load data to avoid flickering
  Future<void> _preLoadData() async {
    if (!mounted) return;

    // Get the latest socket data for this token immediately
    final wsProvider = ref.read(websocketProvider);
    final socketData = wsProvider.socketDatas[_positionData.token];

    if (socketData != null) {
      // Update with initial socket data
      final lp = socketData['lp']?.toString();
      final pc = socketData['pc']?.toString();
      final chng = socketData['chng']?.toString();

      if (lp != null && lp != "null") {
        _positionData.lp = lp;
      }

      if (pc != null && pc != "null") {
        _positionData.perChange = pc;
      }

      if (chng != null && chng != "null") {
        _positionData.chng = chng;
      }

      _updateProfitLossValues();
    }

    // Set up socket subscription only after initial data is set
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _setupSocketSubscription();
        setState(() {});
      }
    });
  }

  // Set up the socket subscription
  void _setupSocketSubscription() {
    if (!mounted) return;

    try {
      final wsProvider = ref.read(websocketProvider);

      _socketSubscription = wsProvider.socketDataStream.listen((socketData) {
        if (!mounted) return;

        final data = socketData[_positionData.token];
        if (data != null) {
          // Update with incremental socket data
          setState(() {
            final lp = data['lp']?.toString();
            final pc = data['pc']?.toString();
            final chng = data['chng']?.toString();

            if (_isValidValue(lp)) _positionData.lp = lp;
            if (_isValidValue(pc)) _positionData.perChange = pc;
            if (_isValidValue(chng)) _positionData.chng = chng;

            _updateProfitLossValues();
          });
        }
      });
    } catch (e) {
      print("Error setting up socket subscription: $e");
    }
  }

  // Helper method to check if a value is valid
  bool _isValidValue(String? value) {
    return value != null &&
        value != "null" &&
        value != "0" &&
        value != "0.0" &&
        value != "0.00";
  }

  // Calculate profit and loss values
  void _updateProfitLossValues() {
    final ltp = double.tryParse(_positionData.lp ?? "0.0") ?? 0.0;
    final qty = int.tryParse(_positionData.netqty ?? "0") ?? 0;
    final avgPrice = double.tryParse(_positionData.avgPrc ?? "0.0") ?? 0.0;

    if (ltp > 0 && qty != 0 && avgPrice > 0) {
      final pnl = (ltp - avgPrice) * qty;
      _positionData.profitNloss = pnl.toStringAsFixed(2);
      _positionData.mTm = pnl.toStringAsFixed(2);
    }
  }

  bool _didInitDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only run this once
    if (!_didInitDependencies) {
      _didInitDependencies = true;

      // Use a microtask to ensure widget is fully mounted
      Future.microtask(() {
        if (mounted) {
          _preLoadData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final scripInfo = ref.watch(marketWatchProvider);
    final positions = ref.read(portfolioProvider);

    DepthInputArgs depthArgs = DepthInputArgs(
      exch: _positionData.exch ?? "",
      token: _positionData.token ?? "",
      tsym: _positionData.tsym ?? '',
      instname: scripInfo.getQuotes?.instname ?? "",
      symbol: _positionData.symbol ?? '',
      expDate: _positionData.expDate ?? '',
      option: _positionData.option ?? '',
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      color: resolveThemeColor(context,
          dark: MyntColors.listItemBgDark, light: MyntColors.textWhite),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Close icon and "Position Details" title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark, light: MyntColors.divider),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                shadcn.IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => shadcn.closeSheet(context),
                  variance: shadcn.ButtonVariance.ghost,
                  size: shadcn.ButtonSize.small,
                ),
                const SizedBox(width: 12),
                Text(
                  "Position Details",
                  style: MyntWebTextStyles.title(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                    fontWeight: MyntFonts.medium,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symbol and Price Section
                  _buildSymbolSection(theme, scripInfo, depthArgs),
                  const SizedBox(height: 24),

                  // Action Buttons: Exit and Conversion
                  _buildActionButtons(theme, scripInfo, positions),
                  const SizedBox(height: 24),

                  // Details Section with Dividers
                  _buildDetailsSection(theme, positions),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSection(ThemesProvider theme,
      MarketWatchProvider scripInfo, DepthInputArgs depthArgs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symbol and Exchange
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "${_positionData.symbol?.replaceAll("-EQ", "") ?? ''}-EQ",
              style: MyntWebTextStyles.head(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
                fontWeight: MyntFonts.semiBold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _positionData.exch ?? "NSE",
              style: MyntWebTextStyles.para(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),

        // Price and Change
        Row(
          children: [
            Text(
              "${_positionData.lp != "null" ? _positionData.lp ?? '0.00' : '0.00'}",
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
                fontWeight: MyntFonts.medium,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${(double.tryParse(_positionData.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(_positionData.perChange ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
              style: MyntWebTextStyles.body(
                context,
                color: (_positionData.chng?.startsWith("-") == true ||
                        _positionData.perChange?.startsWith("-") == true)
                    ? resolveThemeColor(context,
                        dark: MyntColors.lossDark, light: MyntColors.loss)
                    : resolveThemeColor(context,
                        dark: MyntColors.profitDark, light: MyntColors.profit),
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Old action buttons removed - not used in new UI design

  Widget _buildActionButtons(ThemesProvider theme,
      MarketWatchProvider scripInfo, PortfolioProvider positions) {
    final isClosed = _isPositionClosed();

    // Don't show buttons if position is closed
    if (isClosed) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: MyntOutlinedButton(
              label: "Exit",
              onPressed: _handleExit,
              isFullWidth: true,
              textColor: resolveThemeColor(context,
                  dark: MyntColors.primaryDark, light: MyntColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Conversion button (right) - Styled as primary filled
        Expanded(
          child: SizedBox(
            height: 44,
            child: MyntPrimaryButton(
              label: "Conversion",
              onPressed: _handleConvert,
              isFullWidth: true,
            ),
          ),
        ),
      ],
    );
  }

  bool _isPositionClosed() {
    return _positionData.qty == "0" || _positionData.qty == null;
  }

  // Handle exit position
  Future<void> _handleExit() async {
    try {
      // Get root navigator context
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext == null) {
        if (mounted) {
          showResponsiveWarningMessage(
              context, "Unable to access root context");
        }
        return;
      }

      final scripData = ref.read(marketWatchProvider);
      await scripData
          .fetchScripInfo(
        _positionData.token ?? "",
        _positionData.exch ?? "",
        rootContext,
        true,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timed out");
        },
      );

      if (scripData.scripInfoModel == null) {
        if (!mounted) return;
        showResponsiveWarningMessage(
            rootContext, "Unable to fetch scrip information");
        return;
      }

      final netQty = int.tryParse(_positionData.netqty ?? "0") ?? 0;
      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: _positionData.exch ?? "",
        tSym: _positionData.tsym ?? "",
        isExit: true,
        token: _positionData.token ?? "",
        transType: netQty < 0 ? true : false,
        prd: _positionData.prd ?? "",
        lotSize: _positionData.netqty ?? "",
        ltp: _positionData.lp ?? "0.00",
        perChange: _positionData.perChange ?? "0.00",
        orderTpye: '',
        holdQty: _positionData.netqty ?? '',
        isModify: false,
        raw: {},
      );

      // Use parent context (from position_table) if available, otherwise use root context
      final targetContext = widget.parentContext ?? rootContext;

      if (targetContext.mounted) {
        ResponsiveNavigation.toPlaceOrderScreen(
          context: targetContext,
          arguments: {
            "orderArg": orderArgs,
            "scripInfo": scripData.scripInfoModel!,
            "isBskt": "",
          },
        );
      } else {
        if (mounted) {
          showResponsiveWarningMessage(context, "Unable to access context");
        }
        return;
      }

      // Close the sheet AFTER opening the order screen
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (e) {
          // Ignore sheet close errors
        }
      }
    } catch (e) {
      if (!mounted) return;

      // Try to close sheet on error
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (_) {
          // Ignore sheet close errors
        }
      }

      final rootCtx = rootNavigatorKey.currentContext;
      if (rootCtx != null) {
        try {
          showResponsiveWarningMessage(
              rootCtx, "Error exiting position: ${e.toString()}");
        } catch (displayError) {
          print("Failed to show error message: $displayError");
        }
      }
    }
  }

  // Handle convert position
  Future<void> _handleConvert() async {
    try {
      // Close the sheet first
      if (!mounted) return;
      await shadcn.closeSheet(context);

      // Show dialog after sheet closes using post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final rootContext = rootNavigatorKey.currentContext;
        if (rootContext != null) {
          showDialog(
            context: rootContext,
            barrierColor: resolveThemeColor(context,
                dark: MyntColors.modalBarrierDark,
                light: MyntColors.modalBarrierLight),
            builder: (BuildContext context) {
              return ConvertPositionDialogueWeb(convertPosition: _positionData);
            },
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      print("Error opening convert dialog: $e");
    }
  }

  Color _getPnLColor(String value) {
    final numValue = double.tryParse(value) ?? 0.0;

    if (numValue > 0) {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (numValue < 0) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }
  }

  Widget _buildDetailsSection(
      ThemesProvider theme, PortfolioProvider positions) {
    final pnlValue = positions.isNetPnl
        ? (_positionData.profitNloss ?? _positionData.rpnl ?? "0.00")
        : (_positionData.mTm ?? "0.00");
    final pnlColor = _getPnLColor(pnlValue);

    return Column(
      children: [
        // P&L item
        _rowOfInfoData(
          "P&L",
          Text(
            pnlValue,
            style: MyntWebTextStyles.body(context,
                color: pnlColor, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Net Qty",
          Text(
            "${(int.tryParse(_positionData.netqty?.toString() ?? '0') ?? 0) ~/ (_positionData.exch == 'MCX' ? (int.tryParse(_positionData.ls?.toString() ?? '1') ?? 1) : 1)}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Avg Price",
          Text(
            "${_positionData.netupldprc ?? 0.00}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Product",
          Text(
            _positionData.sPrdtAli != "null"
                ? "${_positionData.sPrdtAli}"
                : "--",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Buy Qty ( Day / CF )",
          Text(
            "${(int.tryParse(_positionData.daybuyqty?.toString() ?? '0') ?? 0) ~/ (_positionData.exch == 'MCX' ? (int.tryParse(_positionData.ls?.toString() ?? '1') ?? 1) : 1)} / ${_positionData.cfbuyqty ?? 0}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Sell Qty ( Day / CF )",
          Text(
            "${(int.tryParse(_positionData.daysellqty?.toString() ?? '0') ?? 0) ~/ (_positionData.exch == 'MCX' ? (int.tryParse(_positionData.ls?.toString() ?? '1') ?? 1) : 1)} / ${_positionData.cfsellqty ?? 0}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Buy Avg prc ( Day / CF )",
          Text(
            "${_positionData.daybuyavgprc ?? 0.00} / ${_positionData.cfbuyavgprc ?? 0.00}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Sell Avg prc ( Day / CF )",
          Text(
            "${_positionData.daysellavgprc ?? 0.00} / ${_positionData.cfsellavgprc ?? 0.00}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Actual Avg Price",
          Text(
            "${_positionData.upldprc ?? 0.00}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Buy / Sell Value",
          Text(
            "929.90 / 0.00", // Placeholder matching screenshot style
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _rowOfInfoData(String title1, Widget valueWidget, ThemesProvider theme,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title1,
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                  fontWeight: MyntFonts.medium,
                ),
              ),
              valueWidget,
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
      ],
    );
  }
}
