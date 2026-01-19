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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _buildSymbolSection(theme, scripInfo, depthArgs),
                ),
                MyntCloseButton(
                  onPressed: () {
                    shadcn.closeSheet(context);
                  },
                ),
              ],
            ),
          ),
          // Border divider
          Container(
            height: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
          // Content
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons
                  _buildActionButtons(theme, scripInfo, positions),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _buildPnLSection(theme, positions),
                  ),
                  // Details Section
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
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symbol and Exchange
        Row(
          children: [
            Flexible(
              child: Text(
                "${_positionData.symbol?.replaceAll("-EQ", "") ?? ''} ${_positionData.expDate ?? ''} ${_positionData.option ?? ''} ",
                style: MyntWebTextStyles.title(
                  context,
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${_positionData.exch}",
              style: MyntWebTextStyles.title(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Price and Change
        Row(
          children: [
            Text(
              "${_positionData.lp != "null" ? _positionData.lp ?? '0.00' : '0.00'}",
              style: MyntWebTextStyles.title(
                context,
                color: (_positionData.chng == "null" ||
                            _positionData.chng == null) ||
                        _positionData.chng == "0.00"
                    ? resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary)
                    : (_positionData.chng?.startsWith("-") == true ||
                            _positionData.perChange?.startsWith("-") == true)
                        ? resolveThemeColor(context,
                            dark: MyntColors.lossDark, light: MyntColors.loss)
                        : resolveThemeColor(context,
                            dark: MyntColors.profitDark,
                            light: MyntColors.profit),
                fontWeight: MyntFonts.medium,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${(double.tryParse(_positionData.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(_positionData.perChange ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
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
    final hasQty = _positionData.qty != "0" && _positionData.qty != null;
    final isDay = positions.isDay;
    final isBOorCO =
        _positionData.sPrdtAli == "BO" || _positionData.sPrdtAli == "CO";

    // Don't show buttons for BO/CO products
    if (isBOorCO) {
      return const SizedBox.shrink();
    }

    // Don't show Add/Exit if it's day or position is closed
    final showAddExit = hasQty && !isDay && !isClosed;
    final showConvert = !isClosed && hasQty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add and Exit buttons in a row
          if (showAddExit) ...[
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Add",
                    true,
                    theme,
                    _handleAdd,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Exit",
                    false,
                    theme,
                    _handleExit,
                  ),
                ),
              ],
            ),
            if (showConvert) const SizedBox(height: 12),
          ],
          // Convert Position as text button
          if (showConvert)
            MyntTextButton(
              onPressed: _handleConvert,
              label: 'Convert Position',
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme,
      VoidCallback onPressed) {
    if (isPrimary) {
      return MyntPrimaryButton(
        label: text,
        onPressed: onPressed,
        isFullWidth: true,
      );
    } else {
      return MyntOutlinedButton(
        label: text,
        onPressed: onPressed,
        isFullWidth: true,
      );
    }
  }

  bool _isPositionClosed() {
    return _positionData.qty == "0" || _positionData.qty == null;
  }

  // Handle add position
  Future<void> _handleAdd() async {
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

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";
      final netQty = int.tryParse(_positionData.netqty ?? "0") ?? 0;

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: _positionData.exch ?? "",
        tSym: _positionData.tsym ?? "",
        isExit: false,
        token: _positionData.token ?? "",
        transType: netQty < 0 ? false : true,
        prd: _positionData.prd ?? "",
        lotSize: lotSize,
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
              rootCtx, "Error adding position: ${e.toString()}");
        } catch (displayError) {
          print("Failed to show error message: $displayError");
        }
      }
    }
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

  Widget _buildPnLSection(ThemesProvider theme, PortfolioProvider positions) {
    final displayValue = positions.isNetPnl
        ? (_positionData.profitNloss ?? _positionData.rpnl ?? "0.00")
        : (_positionData.mTm ?? "0.00");

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              positions.isNetPnl ? "P&L" : "MTM",
              style: MyntWebTextStyles.title(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
                fontWeight: MyntFonts.medium,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayValue,
              style: MyntWebTextStyles.head(
                context,
                color: _getPnLColor(displayValue),
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowOfInfoData(
            "Net Qty",
            "${(int.tryParse(_positionData.netqty?.toString() ?? '0') ?? 0) ~/ (_positionData.exch == 'MCX' ? (int.tryParse(_positionData.ls?.toString() ?? '1') ?? 1) : 1)}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Avg Price",
            "${_positionData.netupldprc ?? 0.00}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Product",
            _positionData.sPrdtAli != "null"
                ? "${_positionData.sPrdtAli}"
                : "--",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Buy Qty ( Day / CF )",
            "${(int.tryParse(_positionData.daybuyqty?.toString() ?? '0') ?? 0) ~/ (_positionData.exch == 'MCX' ? (int.tryParse(_positionData.ls?.toString() ?? '1') ?? 1) : 1)} / ${_positionData.cfbuyqty ?? 0}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Sell Qty ( Day / CF )",
            "${(int.tryParse(_positionData.daysellqty?.toString() ?? '0') ?? 0) ~/ (_positionData.exch == 'MCX' ? (int.tryParse(_positionData.ls?.toString() ?? '1') ?? 1) : 1)} / ${_positionData.cfsellqty ?? 0}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Buy Avg prc ( Day / CF )",
            "${_positionData.daybuyavgprc ?? 0.00} / ${_positionData.cfbuyavgprc ?? 0.00}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Sell Avg prc ( Day / CF )",
            "${_positionData.daysellavgprc ?? 0.00} / ${_positionData.cfsellavgprc ?? 0.00}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Actual Avg Price",
            "${_positionData.upldprc ?? 0.00}",
            theme,
          ),
        ],
      ),
    );
  }

  Widget _rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title1,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
                fontWeight: MyntFonts.medium,
              ),
            ),
            Text(
              value1,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
