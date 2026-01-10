import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/screens/web/ordersbook/modify_gtt_web.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../res/res.dart';
import '../../../models/order_book_model/gtt_order_book.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../utils/responsive_snackbar.dart';
import '../../../main.dart';

class GttOrderBookDetailScreenWeb extends ConsumerStatefulWidget {
  final GttOrderBookModel gttOrder;
  final BuildContext? parentContext;

  const GttOrderBookDetailScreenWeb({
    super.key,
    required this.gttOrder,
    this.parentContext,
  });

  @override
  ConsumerState<GttOrderBookDetailScreenWeb> createState() => _GttOrderBookDetailScreenWebState();
}

class _GttOrderBookDetailScreenWebState extends ConsumerState<GttOrderBookDetailScreenWeb> {
  StreamSubscription? _socketSubscription;
  late GttOrderBookModel _gttOrder;

  @override
  void initState() {
    super.initState();
    _gttOrder = _copyGttOrderData(widget.gttOrder);
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  GttOrderBookModel _copyGttOrderData(GttOrderBookModel original) {
    final copy = GttOrderBookModel();
    copy.stat = original.stat;
    copy.emsg = original.emsg;
    copy.aiT = original.aiT;
    copy.alId = original.alId;
    copy.tsym = original.tsym;
    copy.exch = original.exch;
    copy.token = original.token;
    copy.remarks = original.remarks;
    copy.validity = original.validity;
    copy.norentm = original.norentm;
    copy.pp = original.pp;
    copy.ls = original.ls;
    copy.ti = original.ti;
    copy.brkname = original.brkname;
    copy.actid = original.actid;
    copy.trantype = original.trantype;
    copy.prctyp = original.prctyp;
    copy.qty = original.qty;
    copy.prc = original.prc;
    copy.c = original.c;
    copy.prd = original.prd;
    copy.ordersource = original.ordersource;
    copy.placeOrderParams = original.placeOrderParams;
    copy.placeOrderParamsLeg2 = original.placeOrderParamsLeg2;
    copy.d = original.d;
    copy.oivariable = original.oivariable;
    copy.symbol = original.symbol;
    copy.expDate = original.expDate;
    copy.option = original.option;
    copy.ltp = original.ltp;
    copy.open = original.open;
    copy.high = original.high;
    copy.close = original.close;
    copy.low = original.low;
    copy.change = original.change;
    copy.perChange = original.perChange;
    copy.gttOrderCurrentStatus = original.gttOrderCurrentStatus;
    copy.ordDate = original.ordDate;
    return copy;
  }

  // Pre-load data to avoid flickering
  Future<void> _preLoadData() async {
    if (!mounted) return;

    // Get the latest socket data for this token immediately
    final wsProvider = ref.read(websocketProvider);
    final socketData = wsProvider.socketDatas[_gttOrder.token];

    if (socketData != null) {
      final lp = socketData['lp']?.toString();
      final pc = socketData['pc']?.toString();
      final chng = socketData['chng']?.toString();

      if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
        _gttOrder.ltp = lp;
      }

      if (pc != null && pc != "null" && pc != "0" && pc != "0.00") {
        _gttOrder.perChange = pc;
      }

      if (chng != null && chng != "null") {
        _gttOrder.change = chng;
      }
    }

    // Set up socket subscription
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _setupSocketSubscription();
        setState(() {});
      }
    });
  }

  void _setupSocketSubscription() {
    if (!mounted) return;

    try {
      final wsProvider = ref.read(websocketProvider);

      _socketSubscription = wsProvider.socketDataStream.listen((socketData) {
        if (!mounted) return;

        final data = socketData[_gttOrder.token];
        if (data != null) {
          setState(() {
            final lp = data['lp']?.toString();
            final pc = data['pc']?.toString();
            final chng = data['chng']?.toString();

            if (_isValidValue(lp)) _gttOrder.ltp = lp;
            if (_isValidValue(pc)) _gttOrder.perChange = pc;
            if (_isValidValue(chng)) _gttOrder.change = chng;
          });
        }
      });
    } catch (e) {
      print("Error setting up socket subscription: $e");
    }
  }

  bool _isValidValue(String? value) {
    return value != null &&
        value != "null" &&
        value != "0" &&
        value != "0.0" &&
        value != "0.00";
  }

  bool _didInitDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didInitDependencies) {
      _didInitDependencies = true;

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
    final marketwatch = ref.watch(marketWatchProvider);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button (fixed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSymbolSection(theme, marketwatch),
                    ),
                    shadcn.TextButton(
                      density: shadcn.ButtonDensity.icon,
                      shape: shadcn.ButtonShape.circle,
                      size: shadcn.ButtonSize.normal,
                      child: const Icon(Icons.close),
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
                color: shadcn.Theme.of(context).colorScheme.border,
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action Buttons
                        _buildActionButtons(theme, marketwatch),
                        // GTT Type Section
                        // const SizedBox(height: 16),
                        // Order Parameters Section
                        _buildOrderParametersSection(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSymbolSection(ThemesProvider theme, MarketWatchProvider marketwatch) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    
    DepthInputArgs depthArgs = DepthInputArgs(
      exch: _gttOrder.exch ?? "",
      token: _gttOrder.token ?? "",
      tsym: _gttOrder.tsym ?? '',
      instname: marketwatch.getQuotes?.instname ?? "",
      symbol: _gttOrder.symbol ?? '',
      expDate: _gttOrder.expDate ?? '',
      option: _gttOrder.option ?? '',
    );

    return GestureDetector(
      onTap: () async {
        shadcn.closeSheet(context);
        await marketwatch.scripdepthsize(false);
        await marketwatch.calldepthApis(context, depthArgs, "");
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol (exchange removed to match executed order detail)
          Row(
            children: [
              Flexible(
                child: Text(
                  "${_gttOrder.symbol?.replaceAll("-EQ", "").toUpperCase() ?? ''} ${_gttOrder.expDate ?? ''} ${_gttOrder.option ?? ''} ",
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: colorScheme.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Price and Change
          Row(
            children: [
              Text(
                _gttOrder.ltp ?? _gttOrder.prc ?? '0.00',
                style: WebTextStyles.title(
                  isDarkTheme: theme.isDarkMode,
                  color: (_gttOrder.change == "null" || _gttOrder.change == null) ||
                          _gttOrder.change == "0.00"
                      ? colorScheme.mutedForeground
                      : (_gttOrder.change?.startsWith("-") == true || _gttOrder.perChange?.startsWith("-") == true)
                          ? colorScheme.destructive
                          : colorScheme.chart2,
                  fontWeight: WebFonts.medium,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "${(double.tryParse(_gttOrder.change ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${_gttOrder.perChange ?? '0.00'}%)",
                style: WebTextStyles.sub(
                  isDarkTheme: theme.isDarkMode,
                  color: colorScheme.mutedForeground,
                  fontWeight: WebFonts.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemesProvider theme, MarketWatchProvider marketwatch) {
    final status = _gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? '';
    final isPending = status == 'PENDING' || status == 'TRIGGER_PENDING';

    if (!isPending) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  "Modify Order",
                  true,
                  theme,
                  () => _handleModify(marketwatch),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  "Cancel Order",
                  false,
                  theme,
                  _handleCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme, VoidCallback onPressed) {
    final backgroundColor = isPrimary
        ? (theme.isDarkMode ? WebDarkColors.primaryLight : WebColors.primaryLight)
        : (theme.isDarkMode
            ? WebDarkColors.textSecondary.withOpacity(0.6)
            : WebColors.buttonSecondary);
    final textColor = isPrimary
        ? Colors.white
        : (theme.isDarkMode ? Colors.white : WebColors.primaryLight);
    final borderColor = theme.isDarkMode ? WebDarkColors.primaryLight : WebColors.primaryLight;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isPrimary
            ? null
            : Border.all(
                color: borderColor,
                width: 1,
              ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: shadcn.TextButton(
        size: shadcn.ButtonSize.large,
        density: shadcn.ButtonDensity.dense,
        onPressed: onPressed,
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          text,
          style: WebTextStyles.buttonMd(
            isDarkTheme: theme.isDarkMode,
            color: textColor,
            fontWeight: WebFonts.bold,
          ),
        ),
      ),
    );
  }


  Widget _buildOrderParametersSection(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_gttOrder.placeOrderParams != null) ...[
            // Text(
            //   "${_gttOrder.placeOrderParams?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger",
            //   style: WebTextStyles.title(
            //     isDarkTheme: theme.isDarkMode,
            //     color: shadcn.Theme.of(context).colorScheme.foreground,
            //     fontWeight: WebFonts.bold,
            //   ),
            // ),
            _rowOfInfoDataWithColor(
              "Status",
              _getGttStatusText(),
              theme,
              _getGttStatusColor(theme),
            ),
            _rowOfInfoData(
              "Trigger Price",
              _gttOrder.oivariable?.isNotEmpty == true 
                  ? "${_gttOrder.oivariable?.first.d}" 
                  : _gttOrder.d ?? "-",
              theme,
            ),
            // const SizedBox(height: 12),
            _rowOfInfoData(
              "Product",
              _getProductName(_gttOrder.placeOrderParams?.prd),
              theme,
            ),
            _rowOfInfoData(
              "Order Type",
              _gttOrder.placeOrderParams?.prctyp ?? '-',
              theme,
            ),
            _rowOfInfoData(
              "Quantity",
              "${_gttOrder.placeOrderParams?.qty ?? 0}",
              theme,
            ),
            _rowOfInfoData(
              "Price",
              _gttOrder.placeOrderParams?.prctyp == "MKT" 
                  ? "MKT" 
                  : _gttOrder.placeOrderParams?.prc ?? '-',
              theme,
            ),
          ],
          if (_gttOrder.placeOrderParamsLeg2 != null) ...[
            const SizedBox(height: 24),
            Text(
              "${_gttOrder.placeOrderParamsLeg2?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger @ ${_gttOrder.oivariable?.isNotEmpty == true ? _gttOrder.oivariable?.last.d ?? '' : '-'}",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: shadcn.Theme.of(context).colorScheme.foreground,
                fontWeight: WebFonts.bold,
              ),
            ),
            const SizedBox(height: 12),
            _rowOfInfoData(
              "Product",
              _getProductName(_gttOrder.placeOrderParamsLeg2?.prd),
              theme,
            ),
            _rowOfInfoData(
              "Order Type",
              _gttOrder.placeOrderParamsLeg2?.prctyp ?? '-',
              theme,
            ),
            _rowOfInfoData(
              "Quantity",
              "${_gttOrder.placeOrderParamsLeg2?.qty ?? 0}",
              theme,
            ),
            _rowOfInfoData(
              "Price",
              _gttOrder.placeOrderParamsLeg2?.prctyp == "MKT" 
                  ? "MKT" 
                  : _gttOrder.placeOrderParamsLeg2?.prc ?? '-',
              theme,
            ),
          ],
          if (_gttOrder.remarks != null && _gttOrder.remarks != "") ...[
            const SizedBox(height: 24),
            Text(
              "Remarks",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: shadcn.Theme.of(context).colorScheme.foreground,
                fontWeight: WebFonts.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${_gttOrder.remarks}",
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getProductName(String? prd) {
    switch (prd) {
      case "C":
        return "CNC";
      case "I":
        return "MIS";
      case "M":
        return "NRML";
      default:
        return "-";
    }
  }

  Widget _rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title1,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.regular,
              ),
            ),
            Text(
              value1,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _rowOfInfoDataWithColor(String title, String value, ThemesProvider theme, Color valueColor) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.regular,
              ),
            ),
            Text(
              value,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: valueColor,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getGttStatusText() {
    final status = _gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? 'PENDING';
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'TRIGGER_PENDING':
        return 'Trigger Pending';
      case 'CANCELLED':
      case 'CANCELED':
        return 'Cancelled';
      case 'TRIGGERED':
        return 'Triggered';
      case 'EXECUTED':
        return 'Executed';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getGttStatusColor(ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final status = _gttOrder.gttOrderCurrentStatus?.toUpperCase() ?? 'PENDING';
    
    switch (status) {
      case 'PENDING':
      case 'TRIGGER_PENDING':
        return colorScheme.chart1; // Orange/warning
      case 'EXECUTED':
        return colorScheme.chart2; // Green/success
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        return colorScheme.destructive; // Red/error
      case 'TRIGGERED':
        return colorScheme.chart2; // Green/success
      default:
        return colorScheme.mutedForeground;
    }
  }

  Future<void> _handleCancel() async {
    try {
      final targetContext = widget.parentContext ?? rootNavigatorKey.currentContext;
      if (targetContext == null) {
        if (mounted) {
          ResponsiveSnackBar.showError(context, "Unable to access target context");
        }
        return;
      }

      // Get theme before closing sheet (widget might be disposed after)
      final theme = ref.read(themeProvider);

      // Close the sheet first (exact same pattern as open order details)
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (e) {
          // Ignore sheet close errors
        }
      }

      // Wait for sheet to close, then show dialog (exact same pattern as open order details)
      await Future.delayed(const Duration(milliseconds: 150));

      // Show dialog after sheet closes using targetContext (same as open order details)
      final shouldCancel = await _showCancelGttOrderDialog(theme, targetContext);

      if (shouldCancel != true) {
        return;
      }

      // Cancel the GTT order (provider already shows success message and refreshes order book)
      await ref.read(orderProvider).cancelGttOrder(_gttOrder.alId ?? '', targetContext);
    } catch (e) {
      final rootCtx = rootNavigatorKey.currentContext;
      if (rootCtx != null && rootCtx.mounted) {
        ResponsiveSnackBar.showError(rootCtx, 'Failed to cancel GTT order: ${e.toString()}');
      }
    }
  }

  Future<bool?> _showCancelGttOrderDialog(ThemesProvider theme, BuildContext dialogContext) async {
    final symbol = _gttOrder.tsym?.replaceAll("-EQ", "") ?? 'N/A';
    final exchange = _gttOrder.exch ?? '';
    final displayText = '$symbol $exchange'.trim();

    return showDialog<bool>(
      context: dialogContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
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
                        'Cancel GTT Order',
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
                          onTap: () => Navigator.of(dialogContext).pop(false),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content area
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Are you sure you want to cancel this GTT order?',
                              textAlign: TextAlign.center,
                              style: WebTextStyles.dialogContent(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            displayText,
                            textAlign: TextAlign.center,
                            style: WebTextStyles.dialogContent(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? WebDarkColors.primary
                                  : WebColors.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                'Yes, Cancel',
                                style: WebTextStyles.buttonMd(
                                  isDarkTheme: theme.isDarkMode,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleModify(MarketWatchProvider marketwatch) async {
    try {
      // Use parent context (table context) - same as action handler uses
      final targetContext = widget.parentContext ?? rootNavigatorKey.currentContext;
      if (targetContext == null) {
        if (mounted) {
          ResponsiveSnackBar.showError(context, "Unable to access target context");
        }
        return;
      }

      await marketwatch.fetchScripInfo(
        "${_gttOrder.token}",
        "${_gttOrder.exch}",
        targetContext,
        true,
      );

      if (!mounted) return;

      final scripInfo = marketwatch.scripInfoModel;
      if (scripInfo == null) {
        if (mounted) {
          ResponsiveSnackBar.showError(targetContext, 'Unable to fetch scrip information');
        }
        return;
      }

      // Close the sheet first (like position/holdings screens)
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (e) {
          // Ignore sheet close errors
        }
      }

      // Wait for sheet to close
      await Future.delayed(const Duration(milliseconds: 150));

      // Check context is still valid after sheet close
      if (!targetContext.mounted) {
        return;
      }

      // Show modify dialog - use exact same pattern as action handler
      ModifyGttWeb.showDraggable(
        context: targetContext,
        gttOrderBook: _gttOrder,
        scripInfo: scripInfo,
      );
    } catch (e) {
      final rootCtx = rootNavigatorKey.currentContext;
      if (rootCtx != null && rootCtx.mounted) {
        ResponsiveSnackBar.showError(rootCtx, 'Failed to open modify GTT order: ${e.toString()}');
      }
    }
  }
}
