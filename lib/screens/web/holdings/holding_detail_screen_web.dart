import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../models/portfolio_model/holdings_model.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/ledger_provider.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart' hide WebTextStyles;
import '../../../utils/responsive_navigation.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/alert_dialogue.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../main.dart';

class HoldingDetailScreenWeb extends ConsumerStatefulWidget {
  final dynamic holding;
  final ExchTsym exchTsym;
  final BuildContext? parentContext;

  const HoldingDetailScreenWeb({
    super.key,
    required this.holding,
    required this.exchTsym,
    this.parentContext,
  });

  @override
  ConsumerState<HoldingDetailScreenWeb> createState() => _HoldingDetailScreenWebState();
}

class _HoldingDetailScreenWebState extends ConsumerState<HoldingDetailScreenWeb> {
  StreamSubscription? _socketSubscription;
  late ExchTsym _exchTsym;
  late dynamic _holdingData;

  // Track touch events to prevent multiple button presses
  bool _isProcessingBuy = false;
  bool _isProcessingSell = false;

  @override
  void initState() {
    super.initState();
    // Make copies of the data to avoid modifying the original objects
    _exchTsym = _copyExchTsym(widget.exchTsym);
    _holdingData = widget.holding;

    // Don't pre-load data here - moved to didChangeDependencies
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
  void dispose() {
    _socketSubscription?.cancel();
    
    // Close WebSocket connection when screen is disposed
    try {
      ProviderScope.containerOf(context).read(websocketProvider).closeSocket(false);
    } catch (e) {
      // Context might not be available during disposal, ignore error
      print('WebSocket close error during disposal: $e');
    }
    
    super.dispose();
  }

  // Create a copy of the ExchTsym to avoid modifying the original
  ExchTsym _copyExchTsym(ExchTsym original) {
    final copy = ExchTsym();
    copy.token = original.token;
    copy.exch = original.exch;
    copy.tsym = original.tsym;
    copy.lp = original.lp;
    copy.perChange = original.perChange;
    copy.change = original.change;
    copy.close = original.close;
    copy.profitNloss = original.profitNloss;
    copy.pNlChng = original.pNlChng;
    copy.ls = original.ls;
    return copy;
  }

  // Pre-load data to avoid flickering
  Future<void> _preLoadData() async {
    if (!mounted) return;

    // Get the latest socket data for this token immediately
    final wsProvider = ref.read(websocketProvider);
    final socketData = wsProvider.socketDatas[_exchTsym.token];

    if (socketData != null) {
      // Update with initial socket data
      final lp = socketData['lp']?.toString();
      final pc = socketData['pc']?.toString();
      final chng = socketData['chng']?.toString();
      final c = socketData['c']?.toString();

      if (lp != null && lp != "null") {
        _exchTsym.lp = lp;
      }

      if (pc != null && pc != "null") {
        _exchTsym.perChange = pc;
      }

      if (chng != null && chng != "null") {
        _exchTsym.change = chng;
      }

      if (c != null && c != "null") {
        _exchTsym.close = c;
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

        final data = socketData[_exchTsym.token];
        if (data != null) {
          // Update with incremental socket data
          setState(() {
            final lp = data['lp']?.toString();
            final pc = data['pc']?.toString();
            final chng = data['chng']?.toString();

            if (_isValidValue(lp)) _exchTsym.lp = lp;
            if (_isValidValue(pc)) _exchTsym.perChange = pc;
            if (_isValidValue(chng)) _exchTsym.change = chng;

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
    final ltp = double.tryParse(_exchTsym.lp ?? "0.0") ?? 0.0;
    final qty = _holdingData.currentQty ?? 0;
    final avgPrice = double.tryParse(_holdingData.upldprc ?? "0.0") ?? 0.0;

    if (ltp > 0 && qty > 0 && avgPrice > 0) {
      // Current value
      _holdingData.currentValue = (ltp * qty).toStringAsFixed(2);

      // Profit/Loss
      final pnl = (ltp - avgPrice) * qty;
      _exchTsym.profitNloss = pnl.toStringAsFixed(2);

      // P&L Percentage
      if (avgPrice > 0) {
        final pnlPerc = (pnl / (avgPrice * qty)) * 100;
        _exchTsym.pNlChng = pnlPerc.toStringAsFixed(2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final scripInfo = ref.watch(marketWatchProvider);

    DepthInputArgs depthArgs = DepthInputArgs(
        exch: _exchTsym.exch ?? "",
        token: _exchTsym.token ?? "",
        tsym: scripInfo.getQuotes?.tsym ?? '',
        instname: scripInfo.getQuotes?.instname ?? "",
        symbol: scripInfo.getQuotes?.symbol ?? '',
        expDate: scripInfo.getQuotes?.expDate ?? '',
        option: scripInfo.getQuotes?.option ?? '');

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
                shadcn.TextButton(
                  density: shadcn.ButtonDensity.icon,
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
          // Content
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // P&L Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _buildPnLSection(theme),
                  ),
                  
                  // Action Buttons
                  _buildActionButtons(theme, scripInfo),
                  
                  // Details Section
                  _buildDetailsSection(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSection(ThemesProvider theme, MarketWatchProvider scripInfo, DepthInputArgs depthArgs) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symbol and Exchange
        Row(
          children: [
            Flexible(
              child: Text(
                "${_exchTsym.tsym?.replaceAll("-EQ", "") ?? ''} ${_exchTsym.expDate ?? ''} ${_exchTsym.option ?? ''} ",
                style: WebTextStyles.dialogTitle(
                  isDarkTheme: theme.isDarkMode,
                  color: colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${_exchTsym.exch}",
              style: WebTextStyles.dialogTitle(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Price and Change
        Row(
          children: [
            Text(
              "${_exchTsym.lp != "null" ? _exchTsym.lp ?? _exchTsym.close ?? 0.00 : '0.00'}",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: (_exchTsym.change == "null" || _exchTsym.change == null) ||
                        _exchTsym.change == "0.00"
                    ? colorScheme.mutedForeground
                    : (_exchTsym.change?.startsWith("-") == true || _exchTsym.perChange?.startsWith("-") == true)
                        ? colorScheme.destructive
                        : colorScheme.chart2,
                fontWeight: WebFonts.medium,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${(double.tryParse(_exchTsym.change ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(_exchTsym.perChange ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemesProvider theme, MarketWatchProvider scripInfo) {
    final qty = _holdingData.currentQty ?? 0;
    final hasQty = qty > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add and Exit buttons in a row
          if (hasQty) ...[
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Add",
                    true,
                    theme,
                    _isProcessingBuy ? () {} : _handleBuy,
                    isLoading: _isProcessingBuy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Exit",
                    false,
                    theme,
                    _isProcessingSell ? () {} : _handleSell,
                    isLoading: _isProcessingSell,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Chart button
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildActionButton(
          //         "Chart",
          //         false,
          //         theme,
          //         _handleChartTap,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    bool isPrimary,
    ThemesProvider theme,
    VoidCallback onPressed, {
    bool isLoading = false,
  }) {
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
        onPressed: isLoading ? null : onPressed,
        shape: shadcn.ButtonShape.rectangle,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Text(
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

  Widget _buildPledgeUnpledgeButton(ThemesProvider theme, LDProvider ledgerdate) {
    final borderColor = theme.isDarkMode ? WebDarkColors.btnOutlinedBorder : WebColors.btnOutlinedBorder;
    return Center(
      child: InkWell(
        onTap: () async {
          if (ledgerdate.pledgeandunpledge == null) {
            await ledgerdate.getCurrentDate("pandu");
            ledgerdate.fetchpledgeandunpledge(context);
          }
          Navigator.pushNamed(context, Routes.pledgeandun, arguments: "DDDDD");
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pledge-Unpledge",
                style: WebTextStyles.buttonMd(
                  isDarkTheme: theme.isDarkMode,
                  color: borderColor,
                  fontWeight: WebFonts.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPnLSection(ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final displayValue = _exchTsym.profitNloss ?? "0.00";
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "P&L",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayValue,
              style: WebTextStyles.head(
                isDarkTheme: theme.isDarkMode,
                color: _getPnLColor(displayValue),
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPnLColor(String value) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final numValue = double.tryParse(value) ?? 0.0;
    
    if (numValue > 0) {
      return colorScheme.chart2;
    } else if (numValue < 0) {
      return colorScheme.destructive;
    } else {
      return colorScheme.mutedForeground;
    }
  }

  Widget _buildDetailsSection(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowOfInfoData(
            "Net Qty",
            "${_holdingData.currentQty ?? 0}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Avg Price",
            "${_holdingData.upldprc ?? 0}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Product",
            _holdingData.sPrdtAli != "null" ? "${_holdingData.sPrdtAli}" : "--",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Non POA / Sell",
            "${_holdingData.saleableQty ?? 0}/${_holdingData.npoadqty ?? 0}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Invested",
            "${_holdingData.invested == "0.00" ? _exchTsym.close ?? 0.00 : _holdingData.invested ?? 0.00}",
            theme,
          ),
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Current Value",
            (int.parse("${_holdingData.currentQty ?? 0}") *
                    double.parse(_exchTsym.lp?.toString() ?? "0.0"))
                .toStringAsFixed(2),
            theme,
          ),
          if (_holdingData.btstqty != "0") ...[
            const SizedBox(height: 8),
            _rowOfInfoData(
              "T1 Qty",
              "${_holdingData.btstqty ?? 0}",
              theme,
            ),
          ],
          if (_holdingData.rpnl != null && _holdingData.rpnl != "0") ...[
            const SizedBox(height: 8),
            _rowOfInfoData(
              "Realised P&L",
              "${_holdingData.rpnl ?? 0}",
              theme,
            ),
          ],
          const SizedBox(height: 8),
          _rowOfInfoData(
            "Pledged Qty",
            "${_holdingData.brkcolqty ?? 0}",
            theme,
          ),
        ],
      ),
    );
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
                fontWeight: WebFonts.medium,
              ),
            ),
            Text(
              value1,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.foreground,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Handle buy button click
  Future<void> _handleBuy() async {
    if (_isProcessingBuy) return;
    
    print("=== _handleBuy started ===");

    try {
      setState(() {
        _isProcessingBuy = true;
      });

      // Get root navigator context - this is crucial for overlay access
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext == null) {
        print("ERROR: Root context is null");
        if (mounted) {
          setState(() {
            _isProcessingBuy = false;
          });
          showResponsiveWarningMessage(context, "Unable to access root context");
        }
        return;
      }

      print("Fetching scrip info for token: ${_exchTsym.token}, exch: ${_exchTsym.exch}");
      final scripData = ref.read(marketWatchProvider);
      
      // Add timeout to prevent hanging
      await scripData.fetchScripInfo(
        _exchTsym.token ?? "",
        _exchTsym.exch ?? "",
        rootContext,
        true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("ERROR: fetchScripInfo timed out after 10 seconds");
          throw Exception("Request timed out");
        },
      );

      print("Scrip info fetched successfully");

      if (!mounted) {
        print("Widget not mounted, returning");
        return;
      }

      if (scripData.scripInfoModel == null) {
        print("ERROR: scripInfoModel is null");
        if (mounted) {
          setState(() {
            _isProcessingBuy = false;
          });
          showResponsiveWarningMessage(rootContext, "Unable to fetch scrip information");
        }
        return;
      }

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";
      print("Lot size: $lotSize");

      final OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: _exchTsym.exch ?? "",
        tSym: _exchTsym.tsym ?? "",
        isExit: false,
        token: _exchTsym.token ?? "",
        transType: true,
        prd: _holdingData.prd ?? "",
        lotSize: lotSize,
        ltp: _exchTsym.lp ?? "0.00",
        perChange: _exchTsym.perChange ?? "0.00",
        orderTpye: _holdingData.sPrdtAli ?? '',
        holdQty: _holdingData.currentQty?.toString() ?? '',
        isModify: false,
        raw: {},
      );

      print("Opening place order screen...");
      // Use parent context (from hold_table) if available, otherwise use root context
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
        print("Place order screen opened successfully");
      } else {
        print("ERROR: targetContext is not mounted");
        if (mounted) {
          setState(() {
            _isProcessingBuy = false;
          });
        }
        return;
      }

      print("Closing sheet...");
      // Close the sheet AFTER opening the order screen
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (e) {
          print("Error closing sheet: $e");
          // Ignore sheet close errors
        }
      }

      if (mounted) {
        setState(() {
          _isProcessingBuy = false;
        });
      }
      print("=== _handleBuy completed successfully ===");
    } catch (e, stackTrace) {
      print("ERROR in _handleBuy: $e");
      print("Stack trace: $stackTrace");
      
      // Try to close sheet on error
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (_) {
          // Ignore sheet close errors
        }
      }
      
      // Show error using root context
      if (mounted) {
        setState(() {
          _isProcessingBuy = false;
        });
        
        final rootCtx = rootNavigatorKey.currentContext;
        if (rootCtx != null) {
          try {
            showResponsiveWarningMessage(
                rootCtx, "Error adding holding: ${e.toString()}");
          } catch (displayError) {
            print("Failed to show error message: $displayError");
          }
        }
      }
    }
  }

  // Handle chart button click (Show market depth)
  Future<void> _handleChartTap() async {
    final scripData = ref.read(marketWatchProvider);
    await scripData.fetchScripQuoteIndex(
      _exchTsym.token ?? "",
      _exchTsym.exch ?? "",
      context,
    );

    final quots = scripData.getQuotes;
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch?.toString() ?? "",
        token: quots.token?.toString() ?? "",
        tsym: quots.tsym?.toString() ?? "",
        instname: quots.instname?.toString() ?? "",
        symbol: quots.symbol?.toString() ?? "",
        expDate: quots.expDate?.toString() ?? "",
        option: quots.option?.toString() ?? "",
      );
      scripData.scripdepthsize(false);
      await scripData.calldepthApis(context, depthArgs, "");
    }
  }

  // Handle sell button click
  Future<void> _handleSell() async {
    if (_isProcessingSell) return;
    
    print("=== _handleSell started ===");

    try {
      setState(() {
        _isProcessingSell = true;
      });

      // Get root navigator context - this is crucial for overlay access
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext == null) {
        print("ERROR: Root context is null");
        if (mounted) {
          setState(() {
            _isProcessingSell = false;
          });
          showResponsiveWarningMessage(context, "Unable to access root context");
        }
        return;
      }

      if (_holdingData.saleableQty == null || _holdingData.saleableQty == 0) {
        print("ERROR: No saleable quantity");
        if (mounted) {
          setState(() {
            _isProcessingSell = false;
          });
          showDialog(
            context: rootContext,
            builder: (BuildContext context) {
              return AlertDialogue(
                scripName: "${_exchTsym.tsym}",
                exch: "${_exchTsym.exch}",
                content:
                    'You are unable to exit because there are no sellable quantity.',
              );
            },
          );
        }
        return;
      }

      print("Fetching scrip info for token: ${_exchTsym.token}, exch: ${_exchTsym.exch}");
      final scripData = ref.read(marketWatchProvider);
      
      // Add timeout to prevent hanging
      await scripData.fetchScripInfo(
        _exchTsym.token ?? "",
        _exchTsym.exch ?? "",
        rootContext,
        true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("ERROR: fetchScripInfo timed out after 10 seconds");
          throw Exception("Request timed out");
        },
      );

      print("Scrip info fetched successfully");

      if (!mounted) {
        print("Widget not mounted, returning");
        return;
      }

      if (scripData.scripInfoModel == null) {
        print("ERROR: scripInfoModel is null");
        if (mounted) {
          setState(() {
            _isProcessingSell = false;
          });
          showResponsiveWarningMessage(rootContext, "Unable to fetch scrip information");
        }
        return;
      }

      final lotSize = scripData.scripInfoModel!.ls?.toString() ?? "1";
      print("Lot size: $lotSize");

      final OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: _exchTsym.exch ?? "",
        tSym: _exchTsym.tsym ?? "",
        isExit: true,
        token: _exchTsym.token ?? "",
        transType: false,
        prd: _holdingData.prd ?? "",
        lotSize: lotSize,
        ltp: _exchTsym.lp ?? "0.00",
        perChange: _exchTsym.perChange ?? "0.00",
        orderTpye: _holdingData.sPrdtAli ?? '',
        holdQty: _holdingData.saleableQty?.toString() ?? '0',
        isModify: false,
        raw: {},
      );

      print("Opening place order screen...");
      // Use parent context (from hold_table) if available, otherwise use root context
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
        print("Place order screen opened successfully");
      } else {
        print("ERROR: targetContext is not mounted");
        if (mounted) {
          setState(() {
            _isProcessingSell = false;
          });
        }
        return;
      }

      print("Closing sheet...");
      // Close the sheet AFTER opening the order screen
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (e) {
          print("Error closing sheet: $e");
          // Ignore sheet close errors
        }
      }

      if (mounted) {
        setState(() {
          _isProcessingSell = false;
        });
      }
      print("=== _handleSell completed successfully ===");
    } catch (e, stackTrace) {
      print("ERROR in _handleSell: $e");
      print("Stack trace: $stackTrace");
      
      // Try to close sheet on error
      if (mounted) {
        try {
          shadcn.closeSheet(context);
        } catch (_) {
          // Ignore sheet close errors
        }
      }
      
      // Show error using root context
      if (mounted) {
        setState(() {
          _isProcessingSell = false;
        });
        
        final rootCtx = rootNavigatorKey.currentContext;
        if (rootCtx != null) {
          try {
            showResponsiveWarningMessage(
                rootCtx, "Error exiting holding: ${e.toString()}");
          } catch (displayError) {
            print("Failed to show error message: $displayError");
          }
        }
      }
    }
  }

}
